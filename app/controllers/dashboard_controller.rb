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
    data = transactions
             .select(&:expense?)
             .group_by { |t| t.category&.name || "Sem categoria" }
             .map { |name, txs| [name, txs.sum { |t| t.monthly_amount_for(Date.current) }] }
             .reject { |_name, total| total.zero? }
             .sort_by { |_name, total| -total }
             .first(6)
    return [[], []] if data.empty?
    labels = data.map(&:first)
    values = data.map(&:last)
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
