class InvestmentsController < ApplicationController
  # TO DO: Implementar regra de negócio para investimentos
  # TO DO: Validação de entrada e saída dos dados;
  def portfolio
    load_portfolio_context
  end

  def analysis
    load_portfolio_context
    load_analysis_charts
  end

  def planning
    load_portfolio_context
    load_planning_context
  end

  def income
    load_portfolio_context
    @recent_dividends = @wallet.dividends.order(paid_on: :desc).limit(12)
  end

  def dividends
    load_portfolio_context
    @dividends = @wallet.dividends.order(paid_on: :desc)
  end

  def integrations
    load_portfolio_context
  end

  def live_rates
    market_data = Frankfurter::MarketDataService.new
    base = params[:base].presence || "USD"
    symbols = params[:symbols].to_s.split(",").map(&:strip)
    symbols = [ "BRL", "EUR", "GBP", "JPY" ] if symbols.empty?

    payload = market_data.latest_rates(base: base, symbols: symbols)
    if payload[:available]
      render json: payload
    else
      render json: payload, status: :unprocessable_entity
    end
  end

  private

  def load_portfolio_context
    @wallet = current_user.wallets.first_or_create!(name: "Principal", currency: "BRL")
    @positions = Investments::PositionCalculator.new(wallet: @wallet).call
    market_data = Frankfurter::MarketDataService.new
    @quotes_by_asset_id = market_data.quotes_for(assets: @positions.map(&:asset))
    @history_by_asset_id = market_data.histories_for(assets: @positions.map(&:asset), days: 120)
    @enriched_positions = Investments::PortfolioEnricher.new(
      positions: @positions,
      quotes_by_asset_id: @quotes_by_asset_id
    ).call
    @integration_status = {
      frankfurter_enabled: market_data.enabled?,
      quote_currency: market_data.quote_currency,
      quoted_assets: @enriched_positions.count(&:quote_available),
      total_assets: @positions.size
    }
    @allocation = Investments::AllocationCalculator.new(positions: @positions).call
    @performance = Investments::PerformanceCalculator.new(
      wallet: @wallet,
      positions: @positions,
      enriched_positions: @enriched_positions
    ).call
  end

  def load_analysis_charts
    months = 5.downto(0).map { |i| Date.current.beginning_of_month - i.months }
    labels = months.map { |date| I18n.l(date, format: "%b/%y") }

    invested_series = months.map do |date|
      positions = Investments::PositionCalculator.new(wallet: @wallet, as_of: date.end_of_month).call
      positions.sum(&:invested_amount)
    end

    dividends_series = months.map do |date|
      range = date.beginning_of_month..date.end_of_month
      @wallet.dividends.where(paid_on: range).sum(:amount)
    end

    @analysis_data = {
      labels: labels,
      invested: invested_series,
      dividends: dividends_series,
      allocation_labels: @allocation.keys.map { |kind| kind.to_s.humanize },
      allocation_values: @allocation.values
    }
  end

  def load_planning_context
    @goals = @wallet.investment_goals.order(target_date: :asc)
    @targets = @wallet.allocation_targets.order(:asset_class)
    @rebalance_alerts = @targets.map do |target|
      current = @allocation[target.asset_class.to_sym].to_d * 100
      diff = current - target.target_percentage
      {
        asset_class: target.asset_class,
        current: current,
        target: target.target_percentage,
        diff: diff
      }
    end
    @rebalance_alerts.select! { |alert| alert[:diff].abs >= 5 }
  end
end
