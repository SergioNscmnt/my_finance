require "prawn"

Prawn::Fonts::AFM.hide_m17n_warning = true

class ReportsPdfGenerator
  include ActionView::Helpers::NumberHelper

  REPORT_TITLES = {
    "cash_flow" => "Fluxo de Caixa",
    "category_summary" => "Resumo por Categoria",
    "equity_evolution" => "Evolução Patrimonial"
  }.freeze

  BLUE = "2563EB".freeze
  SLATE = "334155".freeze
  LIGHT_SLATE = "E2E8F0".freeze
  GREEN = "059669".freeze
  RED = "DC2626".freeze

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
    document = Prawn::Document.new(page_size: "A4", margin: 36)

    header(document)
    summary_cards(document)

    case @report_type
    when "category_summary"
      category_summary(document)
    when "equity_evolution"
      equity_evolution(document)
    else
      cash_flow(document)
    end

    footer(document)
    document.render
  end

  private

  def header(pdf)
    pdf.fill_color BLUE
    pdf.text "MyFinance", size: 22, style: :bold
    pdf.fill_color SLATE
    pdf.move_down 4
    pdf.text report_title, size: 15, style: :bold
    pdf.move_down 2
    pdf.text "Período: #{format_date(@period_start)} até #{format_date(@period_end)}", size: 9
    pdf.text "Conta: #{account_label} • Usuário: #{@user.name}", size: 9
    pdf.move_down 16
    pdf.stroke_color LIGHT_SLATE
    pdf.stroke_horizontal_rule
    pdf.move_down 16
  end

  def summary_cards(pdf)
    card_width = (pdf.bounds.width - 24) / 4.0
    y = pdf.cursor

    [
      ["Renda Total", currency(@totals[:income]), GREEN],
      ["Gastos Totais", currency(@totals[:expense]), RED],
      ["Economia", currency(@totals[:savings]), @totals[:savings].to_f.negative? ? RED : GREEN],
      ["Taxa Poupança", "#{@totals[:savings_rate]}%", BLUE]
    ].each_with_index do |(label, value, color), index|
      x = pdf.bounds.left + (card_width + 8) * index
      pdf.bounding_box([x, y], width: card_width, height: 68) do
        pdf.fill_color "F8FAFC"
        pdf.stroke_color LIGHT_SLATE
        pdf.fill_and_stroke_rounded_rectangle [0, 68], card_width, 68, 8
        pdf.fill_color color
        pdf.text_box value, at: [10, 42], width: card_width - 20, height: 18, size: 12, style: :bold, overflow: :shrink_to_fit
        pdf.fill_color SLATE
        pdf.text_box label, at: [10, 20], width: card_width - 20, height: 12, size: 7, style: :bold
      end
    end

    pdf.fill_color SLATE
    pdf.move_down 84
  end

  def cash_flow(pdf)
    section_title(pdf, "Evolução mensal")
    bar_chart(pdf, @month_labels, @monthly_income, @monthly_expense)
    pdf.move_down 18
    simple_table(
      pdf,
      ["Mês", "Entradas", "Saídas", "Economia"],
      @month_labels.each_with_index.map do |label, index|
        [
          label,
          currency(@monthly_income[index]),
          currency(@monthly_expense[index]),
          currency(@monthly_savings[index])
        ]
      end
    )
  end

  def category_summary(pdf)
    section_title(pdf, "Gastos por categoria")

    rows = @category_totals.map do |category, total|
      share = @totals[:expense].to_f.positive? ? ((total.to_f / @totals[:expense].to_f) * 100).round(1) : 0
      [category&.name || "Sem categoria", currency(total), "#{share}%"]
    end

    if rows.any?
      simple_table(pdf, ["Categoria", "Total", "Participação"], rows)
    else
      empty_state(pdf, "Nenhum gasto encontrado para o período.")
    end

    pdf.move_down 18
    section_title(pdf, "Maiores gastos")
    biggest_expenses_table(pdf)
  end

  def equity_evolution(pdf)
    section_title(pdf, "Evolução patrimonial estimada")
    running_total = 0.0
    rows = @month_labels.each_with_index.map do |label, index|
      running_total += @monthly_savings[index].to_f
      [label, currency(@monthly_income[index]), currency(@monthly_expense[index]), currency(running_total)]
    end

    simple_table(pdf, ["Mês", "Entradas", "Saídas", "Saldo acumulado"], rows)
    pdf.move_down 18
    section_title(pdf, "Leitura do período")
    paragraph(pdf, "A evolução patrimonial é estimada pela soma acumulada da economia mensal dentro do período selecionado.")
  end

  def biggest_expenses_table(pdf)
    rows = @biggest_expenses.map do |entry|
      transaction = entry[:transaction]
      [
        transaction.title,
        transaction.category&.name || "Sem categoria",
        currency(entry[:amount])
      ]
    end

    if rows.any?
      simple_table(pdf, ["Despesa", "Categoria", "Valor"], rows)
    else
      empty_state(pdf, "Nenhuma despesa encontrada para o período.")
    end
  end

  def bar_chart(pdf, labels, income_values, expense_values)
    max_value = [income_values, expense_values, [1]].flatten.map(&:to_f).max
    chart_height = 130
    bar_group_width = pdf.bounds.width / labels.size
    base_y = pdf.cursor - chart_height

    pdf.stroke_color LIGHT_SLATE
    pdf.line [pdf.bounds.left, base_y], [pdf.bounds.right, base_y]
    pdf.stroke

    labels.each_with_index do |label, index|
      group_x = pdf.bounds.left + (bar_group_width * index) + 4
      income_height = (income_values[index].to_f / max_value) * (chart_height - 24)
      expense_height = (expense_values[index].to_f / max_value) * (chart_height - 24)

      pdf.fill_color LIGHT_SLATE
      pdf.fill_rectangle [group_x, base_y + expense_height], 8, expense_height
      pdf.fill_color BLUE
      pdf.fill_rectangle [group_x + 10, base_y + income_height], 8, income_height
      pdf.fill_color SLATE
      pdf.draw_text label, at: [group_x - 1, base_y - 12], size: 6
    end

    pdf.fill_color SLATE
    pdf.move_down chart_height + 20
    pdf.text "Legenda: azul = entradas, cinza = saídas", size: 8
  end

  def simple_table(pdf, headers, rows)
    column_count = headers.size
    column_width = pdf.bounds.width / column_count
    row_height = 24

    draw_row(pdf, headers, column_width, row_height, header: true)

    rows.each do |row|
      start_new_page_if_needed(pdf, row_height + 8)
      draw_row(pdf, row, column_width, row_height)
    end
  end

  def draw_row(pdf, cells, column_width, row_height, header: false)
    y = pdf.cursor
    fill = header ? "E2E8F0" : "FFFFFF"
    pdf.fill_color fill
    pdf.fill_rectangle [pdf.bounds.left, y], pdf.bounds.width, row_height
    pdf.stroke_color LIGHT_SLATE
    pdf.stroke_rectangle [pdf.bounds.left, y], pdf.bounds.width, row_height

    cells.each_with_index do |cell, index|
      pdf.fill_color header ? SLATE : "0F172A"
      pdf.text_box cell.to_s,
                   at: [pdf.bounds.left + (column_width * index) + 6, y - 7],
                   width: column_width - 12,
                   height: row_height - 8,
                   size: header ? 8 : 8,
                   style: header ? :bold : :normal,
                   overflow: :shrink_to_fit
    end

    pdf.move_down row_height
  end

  def section_title(pdf, title)
    start_new_page_if_needed(pdf, 60)
    pdf.fill_color "0F172A"
    pdf.text title, size: 13, style: :bold
    pdf.move_down 8
  end

  def paragraph(pdf, text)
    pdf.fill_color SLATE
    pdf.text text, size: 10, leading: 3
  end

  def empty_state(pdf, text)
    pdf.fill_color "64748B"
    pdf.text text, size: 10, style: :italic
  end

  def footer(pdf)
    pdf.repeat(:all) do
      pdf.bounding_box([pdf.bounds.left, 20], width: pdf.bounds.width, height: 20) do
        pdf.fill_color "94A3B8"
        pdf.text "Gerado em #{format_date(Date.current)} • MyFinance", size: 7, align: :center
      end
    end
  end

  def start_new_page_if_needed(pdf, height)
    pdf.start_new_page if pdf.cursor < height
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

  def currency(value)
    number_to_currency(value, unit: "R$ ", separator: ",", delimiter: ".")
  end

  def format_date(date)
    I18n.l(date.to_date, format: "%d/%m/%Y")
  end
end
