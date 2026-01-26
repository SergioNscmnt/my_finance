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

    # Transações recentes para listas/estado vazio no dashboard
    @transactions = transactions.sort_by { |t| [t.occurred_on, t.created_at] }.reverse.first(10)

    build_chart_data(transactions)
  end

  private

  # Aplica filtros seguros de data (from/to) e reutiliza em todos os cálculos.
  def scoped_transactions
    scope = current_user.transactions
    from_date = safe_date(params[:from])
    to_date   = safe_date(params[:to])

    scope = scope.where(occurred_on: from_date..) if from_date
    scope = scope.where(occurred_on: ..to_date)   if to_date
    scope
  end

  # Converte string para Date; retorna nil se inválida.
  def safe_date(raw)
    return nil if raw.blank?
    Date.parse(raw)
  rescue ArgumentError
    nil
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
end
