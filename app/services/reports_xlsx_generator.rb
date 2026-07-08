require "caxlsx"

class ReportsXlsxGenerator
  REPORT_TITLES = {
    "cash_flow" => "Fluxo de Caixa",
    "category_summary" => "Resumo por Categoria",
    "equity_evolution" => "Evolução Patrimonial"
  }.freeze

  def initialize(user:, report_type:, period_start:, period_end:, account_filter:, months:, month_labels:, monthly_income:, monthly_expense:, monthly_savings:, category_totals:, biggest_expenses:, totals:)
    @user = user
    @report_type = report_type
    @period_start = period_start
    @period_end = period_end
    @account_filter = account_filter
    @months = months
    @month_labels = month_labels
    @monthly_income = monthly_income
    @monthly_expense = monthly_expense
    @monthly_savings = monthly_savings
    @category_totals = category_totals
    @biggest_expenses = biggest_expenses
    @totals = totals
  end

  def render
    package = Axlsx::Package.new
    package.use_shared_strings = true
    workbook = package.workbook
    styles = build_styles(workbook)

    add_dashboard_sheet(workbook, styles)
    add_monthly_sheet(workbook, styles)
    add_categories_sheet(workbook, styles)
    add_biggest_expenses_sheet(workbook, styles)

    package.to_stream.read
  end

  private

  def build_styles(workbook)
    {
      title: workbook.styles.add_style(bg_color: "1D4ED8", fg_color: "FFFFFF", b: true, sz: 16, alignment: { horizontal: :center }),
      subtitle: workbook.styles.add_style(fg_color: "475569", sz: 10),
      header: workbook.styles.add_style(bg_color: "E2E8F0", fg_color: "0F172A", b: true, alignment: { horizontal: :center }),
      money: workbook.styles.add_style(format_code: 'R$ #,##0.00;[Red]-R$ #,##0.00'),
      percent: workbook.styles.add_style(format_code: '0.0%'),
      metric_label: workbook.styles.add_style(bg_color: "F1F5F9", fg_color: "475569", b: true),
      metric_value: workbook.styles.add_style(bg_color: "F8FAFC", fg_color: "0F172A", b: true, sz: 14, format_code: 'R$ #,##0.00;[Red]-R$ #,##0.00'),
      metric_percent: workbook.styles.add_style(bg_color: "F8FAFC", fg_color: "0F172A", b: true, sz: 14, format_code: "0.0%"),
      text: workbook.styles.add_style(fg_color: "0F172A"),
      date: workbook.styles.add_style(format_code: "dd/mm/yyyy")
    }
  end

  def add_dashboard_sheet(workbook, styles)
    workbook.add_worksheet(name: "Dashboard") do |sheet|
      sheet.add_row ["MyFinance - #{report_title}"], style: styles[:title]
      sheet.merge_cells "A1:F1"
      sheet.add_row ["Período", @period_start, @period_end, "Conta", account_label, "Usuário: #{@user.name}"], style: [styles[:metric_label], styles[:date], styles[:date], styles[:metric_label], styles[:text], styles[:text]]
      sheet.add_row []
      sheet.add_row ["Renda Total", "Gastos Totais", "Economia", "Taxa de Poupança"], style: styles[:metric_label]
      sheet.add_row [@totals[:income], @totals[:expense], @totals[:savings], @totals[:savings_rate].to_f / 100], style: [styles[:metric_value], styles[:metric_value], styles[:metric_value], styles[:metric_percent]]
      sheet.add_row []
      sheet.add_row ["Mês", "Entradas", "Saídas", "Economia"], style: styles[:header]

      @month_labels.each_with_index do |label, index|
        sheet.add_row [label, @monthly_income[index], @monthly_expense[index], @monthly_savings[index]], style: [styles[:text], styles[:money], styles[:money], styles[:money]]
      end

      sheet.add_row []
      category_header_row = 9 + @month_labels.size
      category_data_start_row = category_header_row + 1
      sheet.add_row ["Categoria", "Total", "Participação"], style: styles[:header]
      @category_totals.each do |category, total|
        share = @totals[:expense].to_f.positive? ? total.to_f / @totals[:expense].to_f : 0
        sheet.add_row [category&.name || "Sem categoria", total, share], style: [styles[:text], styles[:money], styles[:percent]]
      end

      add_monthly_chart(sheet, "F4:N19", 8)
      add_category_chart(sheet, "F21:N36", category_data_start_row) if @category_totals.any?
      sheet.column_widths 14, 16, 16, 16, 18, 18
    end
  end

  def add_monthly_sheet(workbook, styles)
    workbook.add_worksheet(name: "Evolução Mensal") do |sheet|
      sheet.add_row ["Evolução Mensal"], style: styles[:title]
      sheet.merge_cells "A1:D1"
      sheet.add_row []
      sheet.add_row ["Mês", "Entradas", "Saídas", "Economia"], style: styles[:header]

      @month_labels.each_with_index do |label, index|
        sheet.add_row [label, @monthly_income[index], @monthly_expense[index], @monthly_savings[index]], style: [styles[:text], styles[:money], styles[:money], styles[:money]]
      end

      add_monthly_chart(sheet, "F3:N20", 4)
      sheet.column_widths 14, 16, 16, 16
    end
  end

  def add_categories_sheet(workbook, styles)
    workbook.add_worksheet(name: "Categorias") do |sheet|
      sheet.add_row ["Gastos por Categoria"], style: styles[:title]
      sheet.merge_cells "A1:C1"
      sheet.add_row []
      sheet.add_row ["Categoria", "Total", "Participação"], style: styles[:header]

      if @category_totals.any?
        @category_totals.each do |category, total|
          share = @totals[:expense].to_f.positive? ? total.to_f / @totals[:expense].to_f : 0
          sheet.add_row [category&.name || "Sem categoria", total, share], style: [styles[:text], styles[:money], styles[:percent]]
        end
        add_category_chart(sheet, "E3:M18", 4)
      else
        sheet.add_row ["Nenhum gasto encontrado no período.", nil, nil], style: styles[:subtitle]
      end

      sheet.column_widths 28, 16, 16
    end
  end

  def add_biggest_expenses_sheet(workbook, styles)
    workbook.add_worksheet(name: "Maiores Gastos") do |sheet|
      sheet.add_row ["Maiores Gastos do Período"], style: styles[:title]
      sheet.merge_cells "A1:D1"
      sheet.add_row []
      sheet.add_row ["Despesa", "Categoria", "Data", "Valor"], style: styles[:header]

      if @biggest_expenses.any?
        @biggest_expenses.each do |entry|
          transaction = entry[:transaction]
          sheet.add_row [
            transaction.title,
            transaction.category&.name || "Sem categoria",
            transaction.occurred_on,
            entry[:amount]
          ], style: [styles[:text], styles[:text], styles[:date], styles[:money]]
        end
      else
        sheet.add_row ["Nenhuma despesa encontrada no período.", nil, nil, nil], style: styles[:subtitle]
      end

      sheet.column_widths 32, 24, 14, 16
    end
  end

  def add_monthly_chart(sheet, position, row_start)
    return if @month_labels.empty?

    row_end = row_start + @month_labels.size - 1

    sheet.add_chart(Axlsx::Bar3DChart, start_at: position.split(":").first, end_at: position.split(":").last, title: "Entradas vs Saídas", bar_dir: :col) do |chart|
      chart.add_series data: sheet["B#{row_start}:B#{row_end}"], labels: sheet["A#{row_start}:A#{row_end}"], title: "Entradas"
      chart.add_series data: sheet["C#{row_start}:C#{row_end}"], labels: sheet["A#{row_start}:A#{row_end}"], title: "Saídas"
      chart.valAxis.title = "Valor"
      chart.catAxis.title = "Mês"
    end
  end

  def add_category_chart(sheet, position, row_start)
    return if @category_totals.empty?

    row_end = row_start + @category_totals.size - 1

    sheet.add_chart(Axlsx::Pie3DChart, start_at: position.split(":").first, end_at: position.split(":").last, title: "Gastos por Categoria") do |chart|
      chart.add_series data: sheet["B#{row_start}:B#{row_end}"], labels: sheet["A#{row_start}:A#{row_end}"]
    end
  end

  def report_title
    REPORT_TITLES.fetch(@report_type, REPORT_TITLES["cash_flow"])
  end

  def account_label
    {
      "all" => "Todas as Contas",
      "cash" => "Dinheiro",
      "pix" => "Pix",
      "credit_card" => "Cartão de Crédito"
    }.fetch(@account_filter, "Todas as Contas")
  end
end
