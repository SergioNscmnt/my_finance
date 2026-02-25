class AssetsController < ApplicationController
  CURRENCY_LABELS_PT_BR = {
    "BRL" => "Real brasileiro",
    "USD" => "Dólar americano",
    "EUR" => "Euro",
    "GBP" => "Libra esterlina",
    "JPY" => "Iene japonês",
    "CAD" => "Dólar canadense",
    "AUD" => "Dólar australiano",
    "CHF" => "Franco suíço",
    "CNY" => "Yuan chinês",
    "ARS" => "Peso argentino",
    "MXN" => "Peso mexicano",
    "CLP" => "Peso chileno",
    "UYU" => "Peso uruguaio",
    "PYG" => "Guarani paraguaio",
    "BOB" => "Boliviano",
    "PEN" => "Sol peruano",
    "COP" => "Peso colombiano"
  }.freeze

  before_action :set_wallet
  before_action :set_asset, only: %i[show edit update destroy live_quote]
  before_action :set_form_options, only: %i[new create edit update]

  def index
    @assets = @wallet.assets.order(:ticker)
  end

  def show
    @transactions = @asset.investment_transactions.ordered
    @position = Investments::PositionCalculator.new(wallet: @wallet, asset: @asset).call.first
    @live_quote = MarketData::BrapiService.new.quote_for_asset(@asset)
  end

  def search_tickers
    q = params[:q].to_s.strip
    items = MarketData::BrapiService.new.search_tickers(query: q, limit: 30)

    render json: {
      items: items.map do |item|
        {
          value: item[:symbol],
          text: "#{item[:symbol]} - #{item[:name]}",
          ticker: item[:symbol],
          name: item[:name],
          currency: item[:currency],
          asset_type: item[:asset_type].presence || "stock"
        }
      end
    }
  end

  def live_quote
    quote = MarketData::BrapiService.new.quote_for_asset(@asset)
    if quote[:available]
      render json: quote
    else
      render json: quote, status: :unprocessable_entity
    end
  end

  def new
    @asset = @wallet.assets.new
    @return_to = params[:return_to]
  end

  def create
    @asset = @wallet.assets.new(asset_params)
    return_to = params[:return_to].presence
    if @asset.save
      redirect_to(return_to || @asset, notice: "Ativo criado com sucesso.")
    else
      @return_to = return_to
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @return_to = params[:return_to]
  end

  def update
    return_to = params[:return_to].presence
    if @asset.update(asset_params)
      redirect_to(return_to || @asset, notice: "Ativo atualizado com sucesso.")
    else
      @return_to = return_to
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @asset.destroy
    redirect_to assets_path, notice: "Ativo removido com sucesso."
  end

  private

  def set_wallet
    @wallet = if params[:wallet_id]
                current_user.wallets.find(params[:wallet_id])
              else
                current_user.wallets.first_or_create!(name: "Principal", currency: "BRL")
              end
  end

  def set_asset
    @asset = @wallet.assets.find(params[:id])
  end

  def asset_params
    params.require(:asset).permit(:name, :ticker, :asset_type, :currency)
  end

  def set_form_options
    @asset_type_options = Asset.asset_type_options_pt_br

    currencies_map = Frankfurter::MarketDataService.new.currencies
    @currency_options =
      if currencies_map.present?
        currencies_map
          .sort_by { |code, _name| code }
          .map { |code, name| ["#{code} - #{currency_name_pt_br(code, name)}", code] }
      else
        fallback = %w[BRL USD EUR GBP JPY]
        fallback.map { |code| ["#{code} - #{currency_name_pt_br(code, code)}", code] }
      end
  end

  def currency_name_pt_br(code, fallback_name)
    CURRENCY_LABELS_PT_BR.fetch(code.to_s.upcase, fallback_name)
  end
end
