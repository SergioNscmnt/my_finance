module Investments
  class QuotesController < ApplicationController
    MAX_ASSET_IDS = 200

    def index
      asset_ids = extract_asset_ids
      return render json: { error: "asset_ids is required" }, status: :unprocessable_entity if asset_ids.empty?

      if asset_ids.size > MAX_ASSET_IDS
        return render json: { error: "asset_ids limit exceeded (max #{MAX_ASSET_IDS})" }, status: :unprocessable_entity
      end

      assets = current_user.assets.where(id: asset_ids).index_by(&:id)
      freshness_policy = MarketData::QuoteFreshnessPolicy.new
      quote_cache = MarketData::QuoteCache.new
      cached_quotes = quote_cache.read_many(asset_ids)

      quotes = asset_ids.map do |asset_id|
        asset = assets[asset_id]
        next build_unavailable_payload(asset_id: asset_id) unless asset

        cached_payload = cached_quotes[asset_id]
        if cached_payload
          stale = freshness_policy.stale?(
            provider_timestamp: cached_payload[:provider_timestamp],
            retrieved_at: cached_payload[:retrieved_at]
          )

          payload = cached_payload.merge(stale: stale)
          quote_cache.write(asset_id: asset_id, payload: payload, ttl: stale ? 5.minutes : 30.seconds)
          next build_payload(asset: asset, quote_payload: payload)
        end

        db_quote = Quote.where(asset_id: asset_id).latest_first.first
        if db_quote
          payload = {
            asset_id: asset_id,
            price: db_quote.price.to_f,
            change_percent: db_quote.change_percent&.to_f,
            provider: db_quote.provider,
            provider_timestamp: db_quote.provider_timestamp,
            retrieved_at: db_quote.retrieved_at
          }

          stale = freshness_policy.stale?(
            provider_timestamp: payload[:provider_timestamp],
            retrieved_at: payload[:retrieved_at]
          )
          payload[:stale] = stale

          quote_cache.write(asset_id: asset_id, payload: payload, ttl: stale ? 5.minutes : 30.seconds)
          next build_payload(asset: asset, quote_payload: payload)
        end

        build_unavailable_payload(asset_id: asset_id, symbol: asset.symbol)
      end

      render json: {
        requested_at: Time.current.iso8601,
        count: quotes.size,
        quotes: quotes
      }
    end

    private

    def extract_asset_ids
      raw = params[:asset_ids]
      values = raw.is_a?(Array) ? raw : raw.to_s.split(",")

      values.map { |value| value.to_s.strip }
            .reject(&:blank?)
            .map(&:to_i)
            .select(&:positive?)
            .uniq
    end

    def build_payload(asset:, quote_payload:)
      {
        asset_id: asset.id,
        symbol: asset.symbol,
        price: quote_payload[:price],
        change_percent: quote_payload[:change_percent],
        provider: quote_payload[:provider],
        provider_timestamp: quote_payload[:provider_timestamp].presence,
        retrieved_at: quote_payload[:retrieved_at].presence,
        stale: !!quote_payload[:stale],
        available: true
      }
    end

    def build_unavailable_payload(asset_id:, symbol: nil)
      {
        asset_id: asset_id,
        symbol: symbol,
        price: nil,
        change_percent: nil,
        provider: nil,
        provider_timestamp: nil,
        retrieved_at: nil,
        stale: true,
        available: false
      }
    end
  end
end
