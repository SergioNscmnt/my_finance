class DashboardController < ApplicationController
  def index
    scope = scoped_transactions.includes(:category)
    transactions = scope.to_a

    # Totais do mês corrente por tipo (considerando parcelas de cartão)
    @receita_total = transactions.select(&:income?).sum { |t| t.monthly_amount_for(Date.current) }
    @despesa_total = transactions.select(&:expense?).sum { |t| t.monthly_amount_for(Date.current) }
    @balance       = @receita_total - @despesa_total

    # Variação mensal (mês atual vs anterior) considerando parcelas
    this_month = transactions.sum { |t| t.monthly_impact(Date.current) }
    prev_month = transactions.sum { |t| t.monthly_impact(1.month.ago) }
    @monthly_change = this_month - prev_month

    # Série mensal para gráficos/resumos (com parcelas)
    @monthly = build_monthly_series(transactions)

    # Metas (se existir associação)
    @goals_count = current_user.respond_to?(:goals) ? current_user.goals.count : 0

    @category_filter  = params[:category].presence
    @category_options = current_user.categories.expense.order(:name).pluck(:name)

    @list_label = "Últimas 5 transações"
    @transactions = current_user.transactions
                                .includes(:category)
                                .order(occurred_on: :desc, created_at: :desc)
                                .limit(5)
                                .to_a
    @transactions_grouped = group_by_month(@transactions)

    load_budget_planner_data(transactions)
    build_chart_data(transactions)
  end

  private

  # Aplica filtros seguros de data (from/to) e reutiliza em todos os cálculos.
  def scoped_transactions
    scope = current_user.transactions
    scope
  end

  def group_by_month(transactions)
    grouped = transactions.group_by { |t| t.occurred_on.beginning_of_month }
    grouped.sort_by { |month, _| month }.reverse
  end

  def build_chart_data(transactions)
    @chart_months = chart_range_months
    months = (@chart_months - 1).downto(0).map { |i| Date.current.beginning_of_month - i.months }
    @chart_labels  = months.map { |d| d.strftime("%b/%y") }
    @chart_income  = months.map { |d| transactions.select(&:income?).sum { |t| t.monthly_amount_for(d) } }
    @chart_expense = months.map { |d| transactions.select(&:expense?).sum { |t| t.monthly_amount_for(d) } }

    @pie_labels = ["Receitas", "Despesas"]
    @pie_values = [@receita_total, @despesa_total]

    @category_labels, @category_values = top_expense_categories(transactions)
  end

  def chart_range_months
    allowed = [1, 3, 6, 9, 12, 24, 36]
    months = params[:months].to_i
    allowed.include?(months) ? months : 1
  end

  def top_expense_categories(transactions)
    expenses = transactions.select(&:expense?)

    totals = expenses
               .group_by { |t| t.category&.name || "Sem categoria" }
               .transform_values { |txs| txs.sum { |t| t.monthly_amount_for(Date.current) } }

    # Adiciona todas as categorias de despesa com valor 0 para encher o gráfico.
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

    labels = selected.map(&:first)
    values = selected.map(&:last)
    [labels, values]
  end

  def build_monthly_series(transactions)
    months_ranges = transactions.map do |t|
      start_month = t.occurred_on.beginning_of_month
      end_month   = start_month + (t.installments - 1).months
      [start_month, end_month]
    end
    months = months_ranges.flat_map { |range| range }
    return {} if months.empty?
    from = months.min
    to   = months.max
    series_months = []
    cursor = from
    while cursor <= to
      series_months << cursor
      cursor = cursor.next_month
    end
    series_months.index_with do |month|
      transactions.sum { |t| t.monthly_impact(month) }
    end
  end

  def load_budget_planner_data(transactions)
    @category_budget = current_user.category_budgets.new
    @budget_categories = current_user.categories.expense.order(:name)
    @category_budgets = current_user.category_budgets.includes(:category).joins(:category).order("categories.name ASC")
    budget_category_ids = @category_budgets.map(&:category_id)

    @budget_spent_by_category_id = Hash.new(0.0)
    transactions.each do |transaction|
      next unless transaction.expense?
      next unless budget_category_ids.include?(transaction.category_id)

      @budget_spent_by_category_id[transaction.category_id] += transaction.monthly_amount_for(Date.current)
    end

    @budget_remaining_by_category_id = {}
    @budget_progress_by_category_id = {}
    @category_budgets.each do |budget|
      planned_amount = budget.amount.to_f
      spent_amount = @budget_spent_by_category_id[budget.category_id].to_f
      remaining_amount = planned_amount - spent_amount
      progress = planned_amount.positive? ? ((spent_amount / planned_amount) * 100).round(1) : 0.0

      @budget_remaining_by_category_id[budget.category_id] = remaining_amount
      @budget_progress_by_category_id[budget.category_id] = progress
    end

    @planned_budget_total = @category_budgets.sum(:amount)
    @available_after_budget = @balance - @planned_budget_total

    @budget_labels = @category_budgets.map { |budget| budget.category.name }
    @budget_values = @category_budgets.map { |budget| budget.amount.to_f }
  end
end
