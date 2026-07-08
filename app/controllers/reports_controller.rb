class ReportsController < ApplicationController
  def index
    @min_report_date = 2.years.ago.to_date
    @max_report_date = Date.current
    @period_start = bounded_date(params[:start_date], Date.current.beginning_of_year)
    @period_end = bounded_date(params[:end_date], Date.current)
    @period_start, @period_end = @period_end, @period_start if @period_start > @period_end
    @report_type = params[:report_type].presence || "cash_flow"
    @account_filter = params[:account].presence || "all"

    @transactions = scoped_transactions.to_a
    @months = period_months(@period_start, @period_end)
    @month_labels = @months.map { |month| I18n.l(month, format: "%b/%y").upcase.delete(".") }
    @period_label = "#{I18n.l(@period_start, format: "%d/%m/%Y")} - #{I18n.l(@period_end, format: "%d/%m/%Y")}"

    build_monthly_totals
    build_summary_metrics
    build_category_totals
    build_biggest_expenses
    build_report_documents

    export_report if export_format?
  end

  private

  def bounded_date(raw, fallback)
    date = raw.present? ? Date.parse(raw.to_s) : fallback
    [[date, @min_report_date].max, @max_report_date].min
  rescue ArgumentError
    [[fallback, @min_report_date].max, @max_report_date].min
  end

  def period_months(start_date, end_date)
    months = []
    cursor = start_date.beginning_of_month

    while cursor <= end_date.beginning_of_month
      months << cursor
      cursor = cursor.next_month
    end

    months
  end

  def scoped_transactions
    scope = current_user.transactions.includes(:category)
    return scope if @account_filter == "all"
    return scope.where(payment_method: @account_filter) if Transaction.payment_methods.key?(@account_filter)

    scope
  end

  def build_monthly_totals
    @monthly_income = @months.map { |month| total_for(month, :income) }
    @monthly_expense = @months.map { |month| total_for(month, :expense) }
    @monthly_savings = @monthly_income.zip(@monthly_expense).map { |income, expense| income - expense }
    @max_monthly_amount = [@monthly_income, @monthly_expense, [1]].flatten.map(&:to_f).max
  end

  def build_summary_metrics
    @total_income = @monthly_income.sum
    @total_expense = @monthly_expense.sum
    @total_savings = @total_income - @total_expense
    @savings_rate = @total_income.positive? ? ((@total_savings / @total_income) * 100).round(1) : 0.0

    period_days = (@period_end - @period_start).to_i + 1
    previous_period_end = @period_start - 1.day
    previous_period_start = previous_period_end - (period_days - 1).days
    previous_months = period_months(previous_period_start, previous_period_end)
    previous_income = previous_months.sum { |month| total_for(month, :income) }
    previous_expense = previous_months.sum { |month| total_for(month, :expense) }
    previous_savings = previous_income - previous_expense
    previous_rate = previous_income.positive? ? ((previous_savings / previous_income) * 100) : 0

    @income_variation = percentage_variation(@total_income, previous_income)
    @expense_variation = percentage_variation(@total_expense, previous_expense)
    @savings_variation = percentage_variation(@total_savings, previous_savings)
    @savings_rate_variation = (@savings_rate - previous_rate).round(1)
  end

  def build_category_totals
    totals = Hash.new(0.0)

    @transactions.each do |transaction|
      next unless transaction.expense?

      amount = @months.sum { |month| transaction.monthly_amount_for(month).to_f }
      next unless amount.positive?

      totals[transaction.category] += amount
    end

    @category_totals = totals.sort_by { |_category, total| -total }.first(4)
    @category_expense_total = @category_totals.sum { |_category, total| total }
  end

  def build_biggest_expenses
    @biggest_expenses = @transactions
                        .select(&:expense?)
                        .map do |transaction|
      {
        transaction: transaction,
        amount: @months.sum { |month| transaction.monthly_amount_for(month).to_f }
      }
    end
                        .select { |entry| entry[:amount].positive? }
                        .sort_by { |entry| -entry[:amount] }
                        .first(4)

    @biggest_expense_total = @biggest_expenses.sum { |entry| entry[:amount] }
  end

  def build_report_documents
    @report_documents = [
      {
        icon: "receipt",
        title: "Extrato Mensal Consolidado - #{I18n.l(Date.current.prev_month, format: "%b %Y")}",
        date: Date.current,
        format: "PDF"
      },
      {
        icon: "pie-chart",
        title: "Resumo por Categoria - #{@period_label}",
        date: Date.current - 3.days,
        format: "PDF"
      },
      {
        icon: "chart-line",
        title: "Planilha de Gastos Detalhada - #{@period_label}",
        date: Date.current - 7.days,
        format: "XLSX"
      },
      {
        icon: "book-open",
        title: "Prévia Financeira - #{@period_label}",
        date: Date.current - 12.days,
        format: "PDF"
      }
    ]
  end

  def total_for(month, kind)
    @transactions.select { |transaction| transaction.public_send("#{kind}?") }
                 .sum { |transaction| transaction.monthly_amount_for(month).to_f }
  end

  def percentage_variation(current, previous)
    return 0.0 unless previous.to_f.positive?

    (((current.to_f - previous.to_f) / previous.to_f) * 100).round(1)
  end

  def pdf_data
    {
      user: current_user,
      report_type: @report_type,
      period_start: @period_start,
      period_end: @period_end,
      account_filter: @account_filter,
      months: @months,
      month_labels: @month_labels,
      monthly_income: @monthly_income,
      monthly_expense: @monthly_expense,
      monthly_savings: @monthly_savings,
      category_totals: @category_totals,
      biggest_expenses: @biggest_expenses,
      totals: {
        income: @total_income,
        expense: @total_expense,
        savings: @total_savings,
        savings_rate: @savings_rate
      }
    }
  end

  def pdf_filename
    report_slug = @report_type.to_s.dasherize.presence || "relatorio"
    "myfinance-#{report_slug}-#{@period_start}-#{@period_end}.pdf"
  end

  def xlsx_filename
    report_slug = @report_type.to_s.dasherize.presence || "relatorio"
    "myfinance-#{report_slug}-#{@period_start}-#{@period_end}.xlsx"
  end

  def export_format?
    %w[pdf xlsx].include?(params[:export_format].to_s)
  end

  def export_report
    if params[:export_format] == "xlsx"
      send_data ReportsXlsxGenerator.new(**pdf_data).render,
                filename: xlsx_filename,
                type: Mime[:xlsx].to_s,
                disposition: "attachment"
    else
      send_data ReportsPdfGenerator.new(**pdf_data).render,
                filename: pdf_filename,
                type: "application/pdf",
                disposition: "inline"
    end
  end
end
