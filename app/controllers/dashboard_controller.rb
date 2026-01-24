class DashboardController < ApplicationController
  def index
    scope = scoped_transactions

    # Totais por tipo para cards
    @receita_total = scope.where(kind: :income).sum(:amount)
    @despesa_total = scope.where(kind: :expense).sum(:amount)
    @balance       = @receita_total - @despesa_total

    # Variação mensal (mês atual vs anterior)
    this_month = scope.where(occurred_on: Date.current.all_month).sum("CASE WHEN kind = 0 THEN amount ELSE -amount END")
    prev_month = scope.where(occurred_on: 1.month.ago.all_month).sum("CASE WHEN kind = 0 THEN amount ELSE -amount END")
    @monthly_change = this_month - prev_month

    # Série mensal para gráficos/resumos
    month_expr = Arel.sql("DATE_FORMAT(occurred_on, '%Y-%m')")
    delta_expr = Arel.sql("CASE WHEN kind = 0 THEN amount ELSE -amount END")

    @monthly = scope.group(month_expr)
                    .order(month_expr)
                    .sum(delta_expr)

    # Metas (se existir associação)
    @goals_count = current_user.respond_to?(:goals) ? current_user.goals.count : 0

    # Transações recentes para listas/estado vazio no dashboard
    @transactions = scope.includes(:category).order(occurred_on: :desc, created_at: :desc).limit(10)
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
end
