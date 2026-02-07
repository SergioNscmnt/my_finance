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
    sync_massive_dividends_if_enabled
    @recent_dividends = @wallet.dividends.order(paid_on: :desc).limit(12)
  end

  def dividends
    load_portfolio_context
    sync_massive_dividends_if_enabled
    @dividends = @wallet.dividends.order(paid_on: :desc)
  end

  def integrations
    load_portfolio_context
  end

  def sync_massive
    load_portfolio_context

    unless @integration_status[:massive_enabled]
      redirect_to investments_integrations_path, alert: "Massive API não está configurada."
      return
    end

    report = MassiveApi::DividendSyncService.new(wallet: @wallet).call
    redirect_to investments_integrations_path, notice: "Sync Massive concluído: #{report[:synced]} sincronizados, #{report[:skipped]} ignorados, #{report[:errors]} erros."
  end

  def sync_instruments
    service = MassiveApi::InstrumentsSyncService.new
    unless service.enabled?
      redirect_to investments_integrations_path, alert: "Massive API não está configurada."
      return
    end

    report = service.call
    redirect_to investments_integrations_path, notice: "Catálogo Massive atualizado: #{report[:synced]} registros sincronizados em #{report[:pages]} páginas."
  end

  def new_buy
    @wallet = current_user.wallets.first_or_create!(name: "Principal", currency: "BRL")
    @catalog_available = MarketInstrument.active.exists?
    @selected_instrument = MarketInstrument.find_by(id: params[:instrument_id])
    @snapshot = MassiveApi::InstrumentAnalyticsService.new.snapshot(@selected_instrument) if @selected_instrument
    @buy_transaction = @wallet.investment_transactions.new(occurred_on: Date.current, fees: 0)
  end

  def create_buy
    @wallet = current_user.wallets.first_or_create!(name: "Principal", currency: "BRL")
    @catalog_available = MarketInstrument.active.exists?
    @selected_instrument = MarketInstrument.find_by(id: buy_params[:instrument_id])

    if @selected_instrument.nil?
      @buy_transaction = @wallet.investment_transactions.new(occurred_on: Date.current, fees: 0)
      flash.now[:alert] = "Selecione um ativo válido."
      render :new_buy, status: :unprocessable_entity
      return
    end

    @snapshot = MassiveApi::InstrumentAnalyticsService.new.snapshot(@selected_instrument)
    current_price = @snapshot[:current_price].to_d
    if current_price <= 0
      @buy_transaction = @wallet.investment_transactions.new(occurred_on: Date.current, fees: 0)
      flash.now[:alert] = "Não foi possível obter cotação atual para #{@selected_instrument.ticker}."
      render :new_buy, status: :unprocessable_entity
      return
    end

    @buy_transaction = build_buy_transaction(@selected_instrument, current_price: current_price)

    if @buy_transaction.save
      redirect_to investments_portfolio_path, notice: "Compra registrada: #{@selected_instrument.ticker} (#{@buy_transaction.quantity} unidades)."
    else
      render :new_buy, status: :unprocessable_entity
    end
  end

  def search_instruments
    q = params[:q].to_s.strip
    page = [params[:page].to_i, 1].max
    per_page = params[:per_page].to_i
    per_page = 30 if per_page <= 0
    per_page = 100 if per_page > 100

    scope = MarketInstrument.active
    if q.present?
      pattern = "%#{q.upcase}%"
      scope = scope.where("upper(ticker) LIKE ? OR upper(name) LIKE ?", pattern, pattern)
    end

    total_count = scope.count
    records = scope.ordered.offset((page - 1) * per_page).limit(per_page)
    total_pages = (total_count.to_f / per_page).ceil
    next_page = page < total_pages ? page + 1 : nil

    render json: {
      items: records.map { |instrument| instrument_search_payload(instrument) },
      pagination: {
        page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: total_pages,
        next_page: next_page
      }
    }
  end

  private

  def load_portfolio_context
    @wallet = current_user.wallets.first_or_create!(name: "Principal", currency: "BRL")
    @positions = Investments::PositionCalculator.new(wallet: @wallet).call
    market_data = MassiveApi::MarketDataService.new
    @quotes_by_asset_id = market_data.quotes_for(assets: @positions.map(&:asset))
    @history_by_asset_id = market_data.histories_for(assets: @positions.map(&:asset), days: 120)
    @enriched_positions = Investments::PortfolioEnricher.new(
      positions: @positions,
      quotes_by_asset_id: @quotes_by_asset_id
    ).call
    @integration_status = {
      massive_enabled: market_data.enabled?,
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

  def sync_massive_dividends_if_enabled
    return unless ActiveModel::Type::Boolean.new.cast(ENV.fetch("MASSIVE_AUTO_SYNC_DIVIDENDS", false))

    @dividend_sync = MassiveApi::DividendSyncService.new(wallet: @wallet).call
  end

  def buy_params
    params.require(:buy_order).permit(:instrument_id, :quantity, :fees, :occurred_on)
  end

  def build_buy_transaction(instrument, current_price:)
    asset = @wallet.assets.where("upper(ticker) = ?", instrument.ticker.upcase).first_or_initialize
    asset.name = instrument.name
    asset.asset_type = instrument.asset_type
    asset.currency = instrument.currency.presence || "USD"
    asset.save!

    asset.investment_transactions.new(
      wallet: @wallet,
      kind: :buy,
      quantity: buy_params[:quantity],
      price: current_price.positive? ? current_price : 0,
      fees: buy_params[:fees].presence || 0,
      occurred_on: buy_params[:occurred_on]
    )
  end

  def instrument_search_payload(instrument)
    {
      value: instrument.id,
      text: "#{instrument.ticker} - #{instrument.name} (#{instrument.asset_type})",
      ticker: instrument.ticker,
      name: instrument.name,
      asset_type: instrument.asset_type
    }
  end
end
