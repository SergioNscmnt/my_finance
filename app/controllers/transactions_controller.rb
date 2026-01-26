class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[edit update destroy]
  before_action :set_collections, only: %i[index]

  def index; end

  def new
    @transaction = current_user.transactions.new(kind: params[:type] || params[:kind] || :income)
    @categories  = current_user.categories.order(:name)

    if request.headers["Turbo-Frame"] == "modal"
      render :new
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "transaction_form",
            partial: "transactions/form",
            locals: { transaction: @transaction, categories: @categories, frame_id: "transaction_form" }
          )
        end
        format.html do
          set_collections
          render :index
        end
      end
    end
  end

  def create
    @transaction = current_user.transactions.new(transaction_params)
    if @transaction.save
      @dashboard_data = dashboard_data
      respond_to do |format|
        format.turbo_stream { render :create }
        format.html { redirect_to transactions_path, notice: "Transação criada" }
      end
    else
      @categories = current_user.categories.order(:name)
      template = turbo_modal? ? :new : :index
      render template, status: :unprocessable_entity
    end
  end

  def edit
    @categories = current_user.categories.order(:name)
  end

  def update
    if @transaction.update(transaction_params)
      @dashboard_data = dashboard_data
      respond_to do |format|
        format.turbo_stream { render :update }
        format.html { redirect_to transactions_path, notice: "Transação atualizada" }
      end
    else
      @categories = current_user.categories.order(:name)
      template = request.headers["Turbo-Frame"] == "modal" ? :edit : :edit
      render template, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction.destroy
    @dashboard_data = dashboard_data
    respond_to do |format|
      format.turbo_stream { render :destroy }
      format.html { redirect_to transactions_path, notice: "Transação removida" }
    end
  end

  private

  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:title, :amount, :kind, :occurred_on, :category_id, :payment_method, :installments)
  end

  def filtered_transactions
    scope = current_user.transactions

    from_date = safe_date(params[:from])
    to_date   = safe_date(params[:to])

    scope = scope.where(occurred_on: from_date..) if from_date
    scope = scope.where(occurred_on: ..to_date)   if to_date

    if params[:type].present? && Transaction.kinds.key?(params[:type])
      scope = scope.where(kind: params[:type])
    end

    scope
  end

  def set_collections
    scope = filtered_transactions.includes(:category).order(occurred_on: :desc, created_at: :desc)
    @pagy, @transactions = pagy(scope, items: 10)
    @transaction  ||= current_user.transactions.new(kind: params[:type] || params[:kind] || :income)
    @categories   ||= current_user.categories.order(:name)
  end

  # Converte string para Date de forma segura, retornando nil em caso de erro.
  def safe_date(raw)
    return nil if raw.blank?
    Date.parse(raw)
  rescue ArgumentError
    nil
  end

  def turbo_modal?
    request.headers["Turbo-Frame"] == "modal"
  end

  def dashboard_data
    scope = current_user.transactions.includes(:category)
    transactions = scope.to_a

    receita_total = transactions.select(&:income?).sum { |t| t.monthly_amount_for(Date.current) }
    despesa_total = transactions.select(&:expense?).sum { |t| t.monthly_amount_for(Date.current) }
    balance = receita_total - despesa_total

    this_month = transactions.sum { |t| t.monthly_impact(Date.current) }
    prev_month = transactions.sum { |t| t.monthly_impact(1.month.ago) }
    monthly_change = this_month - prev_month

    months_param = begin
      m = params[:months].to_i
      [1, 3, 6, 9, 12, 24, 36].include?(m) ? m : 1
    end

    months = (months_param - 1).downto(0).map { |i| Date.current.beginning_of_month - i.months }
    chart_labels  = months.map { |d| d.strftime("%b/%y") }
    chart_income  = months.map { |d| transactions.select(&:income?).sum { |t| t.monthly_amount_for(d) } }
    chart_expense = months.map { |d| transactions.select(&:expense?).sum { |t| t.monthly_amount_for(d) } }

    pie_labels = ["Receitas", "Despesas"]
    pie_values = [receita_total, despesa_total]

    current_month_expenses = transactions.select(&:expense?)

    totals = current_month_expenses
               .group_by { |t| t.category&.name || "Sem categoria" }
               .transform_values { |txs| txs.sum { |t| t.monthly_amount_for(Date.current) } }

    # Inclui todas as categorias de despesa com 0, para manter barras e opções.
    current_user.categories.expense.order(:name).pluck(:name).each { |name| totals[name] ||= 0 }
    totals["Sem categoria"] ||= 0

    filter = params[:category].presence
    filter_name = nil
    if filter
      match = current_user.categories.expense.find { |c| c.name.downcase.include?(filter.downcase) }
      filter_name = match&.name
      totals[filter_name] ||= 0 if filter_name
    end

    ordered = totals.to_a.sort_by { |_name, total| -total }
    selected = ordered.first(5)

    if filter_name && selected.none? { |(name, _)| name == filter_name }
      selected << [filter_name, totals[filter_name]]
    end

    if selected.size < 5
      ordered.each do |entry|
        next if selected.any? { |(name, _)| name == entry.first }
        selected << entry
        break if selected.size >= 5
      end
    end

    category_labels = selected.map(&:first)
    category_values = selected.map(&:last)

    {
      receita_total: receita_total,
      despesa_total: despesa_total,
      balance: balance,
      monthly_change: monthly_change,
      chart_months: months_param,
      chart_labels: chart_labels,
      chart_income: chart_income,
      chart_expense: chart_expense,
      pie_labels: pie_labels,
      pie_values: pie_values,
      category_labels: category_labels,
      category_values: category_values,
      category_filter: params[:category].presence,
      category_options: current_user.categories.expense.order(:name).pluck(:name),
      goals_count: current_user.respond_to?(:goals) ? current_user.goals.count : 0
    }
  end
end
