class DashboardController < ApplicationController
  def index
    scope = scoped_transactions.includes(:category)
    transactions = scope.to_a

    # Totais do mês corrente por tipo (considerando parcelas de cartão)
    @receita_total = transactions.select(&:income?).sum { |t| t.monthly_amount_for(Date.current) }
    @despesa_total = transactions.select(&:expense?).sum { |t| t.monthly_amount_for(Date.current) }
    @balance       = Transaction.cumulative_balance_for(transactions, Date.current)

    # Variação mensal do saldo acumulado.
    this_month = @balance
    prev_month = Transaction.cumulative_balance_for(transactions, 1.month.ago)
    @monthly_change = this_month - prev_month

    # Série mensal para gráficos/resumos (com parcelas)
    @monthly = build_monthly_series(transactions)

    # Metas (se existir associação)
    @goals_count = current_user.respond_to?(:goals) ? current_user.goals.count : 0

    @category_filter  = params[:category].presence
    @category_options = current_user.categories.expense.order(:name).pluck(:name)
    @list_label = "Transações por mês"
    @transactions = current_user.transactions
                                .includes(:category)
                                .order(occurred_on: :desc, created_at: :desc)
                                .to_a
    @transactions_grouped = group_by_month(@transactions)

    load_credit_card_invoice_data(transactions)
    build_chart_data(transactions)
  end

  private

  # Aplica filtros seguros de data (from/to) e reutiliza em todos os cálculos.
  def scoped_transactions
    scope = current_user.transactions
    scope
  end

  def group_by_month(transactions)
    entries = transactions.flat_map do |transaction|
      next [] if transaction.occurred_on < Date.current

      monthly_reference_months_for(transaction).filter_map do |month|
        next if transaction.monthly_amount_for(month).zero?

        { transaction: transaction, month: month }
      end
    end

    grouped = entries.group_by { |entry| entry[:month] }
    grouped = grouped.transform_values do |month_entries|
      month_entries.sort_by do |entry|
        transaction = entry[:transaction]
        [transaction.occurred_on, transaction.created_at || Time.at(0), transaction.id || 0]
      end.reverse
    end

    grouped.sort_by { |month, _| month }.reverse.to_h
  end

  def monthly_reference_months_for(transaction)
    transaction.billing_months
  end

  def build_chart_data(transactions)
    @chart_months = chart_range_months
    months = (@chart_months - 1).downto(0).map { |i| Date.current.beginning_of_month - i.months }
    @chart_labels  = months.map { |d| d.strftime("%b/%y") }
    @chart_income  = months.map { |d| transactions.select(&:income?).sum { |t| t.monthly_amount_for(d) } }
    @chart_expense = months.map { |d| transactions.select(&:expense?).sum { |t| t.monthly_amount_for(d) } }
    @chart_balance = months.map { |d| Transaction.cumulative_balance_for(transactions, d) }

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
      start_month = t.billing_start_month
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
      Transaction.cumulative_balance_for(transactions, month)
    end
  end

  def load_credit_card_invoice_data(transactions)
    CreditCardInvoiceSyncer.new(current_user, transactions: transactions).sync!

    current_month = Date.current.beginning_of_month
    invoices_scope = current_user.credit_card_invoices.includes(:category)

    @current_month_credit_card_invoices = invoices_scope
                                          .where(billing_month: current_month)
                                          .order(:due_on)
                                          .to_a

    @credit_card_due_soon_invoices = invoices_scope
                                     .where(status: %i[open overdue])
                                     .order(:due_on)
                                     .to_a
                                     .select do |invoice|
      reminder_days = invoice.category.reminder_days_before_due.to_i
      invoice.due_on.between?(Date.current, Date.current + reminder_days.days)
    end
  end
end
