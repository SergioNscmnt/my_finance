class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[edit update destroy]
  before_action :set_collections, only: %i[index]

  def index; end

  def new
    @transaction = current_user.transactions.new(kind: params[:type] || params[:kind] || :income)
    @categories  = current_user.categories.order(:name)

    return render :new if turbo_modal?

    redirect_to transactions_path
  end

  def create
    @transaction = current_user.transactions.new(transaction_params)
    if @transaction.save
      @dashboard_data = dashboard_data
      @dashboard_transactions_grouped, @dashboard_transactions_label = dashboard_transactions_payload
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
      @dashboard_transactions_grouped, @dashboard_transactions_label = dashboard_transactions_payload
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
    @dashboard_transactions_grouped, @dashboard_transactions_label = dashboard_transactions_payload
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

    if params[:type].present? && Transaction.kinds.key?(params[:type])
      scope = scope.where(kind: params[:type])
    end

    if params[:title].present?
      scope = scope.where("title ILIKE ?", "%#{params[:title].strip}%")
    end

    on_date = safe_date(params[:on])
    scope = scope.where(occurred_on: on_date) if on_date

    if params[:category_id].present?
      scope = scope.where(category_id: params[:category_id])
    end

    scope
  end

  def set_collections
    scope = filtered_transactions.includes(:category).order(occurred_on: :desc, created_at: :desc)
    @transactions = scope.to_a
    @categories   ||= current_user.categories.order(:name)
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

    category_budget = current_user.category_budgets.new
    budget_categories = current_user.categories.expense.order(:name)
    category_budgets = current_user.category_budgets.includes(:category).joins(:category).order("categories.name ASC")
    budget_category_ids = category_budgets.map(&:category_id)

    budget_spent_by_category_id = Hash.new(0.0)
    transactions.each do |transaction|
      next unless transaction.expense?
      next unless budget_category_ids.include?(transaction.category_id)

      budget_spent_by_category_id[transaction.category_id] += transaction.monthly_amount_for(Date.current)
    end

    budget_remaining_by_category_id = {}
    budget_progress_by_category_id = {}
    category_budgets.each do |budget|
      planned_amount = budget.amount.to_f
      spent_amount = budget_spent_by_category_id[budget.category_id].to_f
      remaining_amount = planned_amount - spent_amount
      progress = planned_amount.positive? ? ((spent_amount / planned_amount) * 100).round(1) : 0.0

      budget_remaining_by_category_id[budget.category_id] = remaining_amount
      budget_progress_by_category_id[budget.category_id] = progress
    end

    planned_budget_total = category_budgets.sum(:amount)
    # "Disponível" deve refletir o saldo atual; planejamento só impacta após gasto real.
    available_after_budget = balance
    budget_labels = category_budgets.map { |budget| budget.category.name }
    budget_values = category_budgets.map { |budget| budget.amount.to_f }

    CreditCardInvoiceSyncer.new(current_user, transactions: transactions).sync!
    invoices_scope = current_user.credit_card_invoices.includes(:category)
    current_month = Date.current.beginning_of_month
    current_month_credit_card_invoices = invoices_scope.where(billing_month: current_month).order(:due_on).to_a
    credit_card_due_soon_invoices = invoices_scope
                                    .where(status: %i[open overdue])
                                    .order(:due_on)
                                    .to_a
                                    .select do |invoice|
      reminder_days = invoice.category.reminder_days_before_due.to_i
      invoice.due_on.between?(Date.current, Date.current + reminder_days.days)
    end

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
      goals_count: current_user.respond_to?(:goals) ? current_user.goals.count : 0,
      category_budget: category_budget,
      budget_categories: budget_categories,
      category_budgets: category_budgets,
      planned_budget_total: planned_budget_total,
      available_after_budget: available_after_budget,
      budget_labels: budget_labels,
      budget_values: budget_values,
      budget_spent_by_category_id: budget_spent_by_category_id,
      budget_remaining_by_category_id: budget_remaining_by_category_id,
      budget_progress_by_category_id: budget_progress_by_category_id,
      current_month_credit_card_invoices: current_month_credit_card_invoices,
      credit_card_due_soon_invoices: credit_card_due_soon_invoices
    }
  end

  def dashboard_transactions_payload
    transactions = current_user.transactions
                               .includes(:category)
                               .order(occurred_on: :desc, created_at: :desc)
                               .limit(5)
                               .to_a
    grouped = transactions.group_by { |t| t.occurred_on.beginning_of_month }
    grouped = grouped.sort_by { |month, _| month }.reverse

    [grouped, "Últimas 5 transações"]
  end

  def safe_date(raw)
    return nil if raw.blank?
    Date.parse(raw)
  rescue ArgumentError
    nil
  end
end
