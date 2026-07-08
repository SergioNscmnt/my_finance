module BudgetPlanningLoader
  extend ActiveSupport::Concern

  private

  def load_budget_planner_data(budget_month = selected_budget_month)
    transactions = current_user.transactions.includes(:category).to_a

    @selected_budget_month = budget_month
    @balance = Transaction.cumulative_balance_for(transactions, budget_month)

    @category_budget = current_user.category_budgets.new(budget_month: budget_month)
    @budget_categories = current_user.categories.expense.order(:name)
    @category_budgets = current_user.category_budgets
                                    .where(budget_month: budget_month)
                                    .includes(:category)
                                    .joins(:category)
                                    .order("categories.name ASC")

    budget_category_ids = @category_budgets.map(&:category_id)
    @budget_spent_by_category_id = Hash.new(0.0)

    transactions.each do |transaction|
      next unless transaction.expense?
      next unless budget_category_ids.include?(transaction.category_id)

      @budget_spent_by_category_id[transaction.category_id] += transaction.monthly_amount_for(budget_month)
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

    @planned_budget_total = @category_budgets.to_a.sum { |budget| budget.amount.to_d }
    @budget_spent_total = @category_budgets.sum { |budget| @budget_spent_by_category_id[budget.category_id].to_f }
    @budget_remaining_total = @planned_budget_total.to_f - @budget_spent_total.to_f
    @budget_usage_percent = @planned_budget_total.to_f.positive? ? ((@budget_spent_total.to_f / @planned_budget_total.to_f) * 100).round(1) : 0.0
    @available_after_budget = @balance
    @budget_labels = @category_budgets.map { |budget| budget.category.name }
    @budget_values = @category_budgets.map { |budget| budget.amount.to_f }
    @budget_history = build_budget_history(transactions, budget_month)
  end

  def selected_budget_month
    safe_month(params[:budget_month]) || Date.current.beginning_of_month
  end

  def safe_month(raw)
    return nil if raw.blank?

    Date.parse(raw.to_s).beginning_of_month
  rescue ArgumentError
    nil
  end

  def month_param(date)
    date.to_date.strftime("%Y-%m")
  end

  def build_budget_history(transactions, selected_month)
    (5.downto(0).map { |offset| selected_month.advance(months: -offset) }).map do |month|
      budgets = current_user.category_budgets.where(budget_month: month).to_a
      budget_category_ids = budgets.map(&:category_id)
      planned = budgets.sum { |budget| budget.amount.to_f }
      spent = transactions.sum do |transaction|
        next 0.0 unless transaction.expense?
        next 0.0 unless budget_category_ids.include?(transaction.category_id)

        transaction.monthly_amount_for(month)
      end

      usage = planned.positive? ? ((spent / planned) * 100).round(1) : 0.0

      {
        month: month,
        planned: planned,
        spent: spent,
        usage: usage,
        accuracy: planned.positive? ? (100 - [(usage - 100).abs, 100].min).round(1) : 0.0
      }
    end
  end
end
