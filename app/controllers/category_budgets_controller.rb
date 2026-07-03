class CategoryBudgetsController < ApplicationController
  before_action :set_category_budget, only: %i[edit update destroy]
  before_action :set_budget_categories, only: %i[edit update]

  def edit; end

  def create
    @category_budget = current_user.category_budgets.new(category_budget_params)

    if @category_budget.save
      redirect_to dashboard_path(budget_month: month_param(@category_budget.budget_month)), notice: "Orçamento por categoria criado."
    else
      redirect_to dashboard_path(budget_month: month_param(@category_budget.budget_month)), alert: @category_budget.errors.full_messages.to_sentence
    end
  end

  def update
    if @category_budget.update(category_budget_params)
      load_budget_planner_data(@category_budget.budget_month)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to dashboard_path(budget_month: month_param(@category_budget.budget_month)), notice: "Orçamento por categoria atualizado." }
      end
    else
      if turbo_modal?
        render :edit, status: :unprocessable_entity
      else
        redirect_to dashboard_path(budget_month: month_param(@category_budget.budget_month)), alert: @category_budget.errors.full_messages.to_sentence
      end
    end
  end

  def destroy
    budget_month = @category_budget.budget_month
    @category_budget.destroy
    redirect_to dashboard_path(budget_month: month_param(budget_month)), notice: "Orçamento por categoria removido."
  end

  private

  def set_category_budget
    @category_budget = current_user.category_budgets.find(params[:id])
  end

  def category_budget_params
    params.require(:category_budget).permit(:category_id, :amount, :budget_month)
  end

  def set_budget_categories
    @budget_categories = current_user.categories.expense.order(:name)
  end

  def turbo_modal?
    request.headers["Turbo-Frame"] == "modal"
  end

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
    # "Disponível" deve refletir o saldo atual; planejamento só impacta após gasto real.
    @available_after_budget = @balance
    @budget_labels = @category_budgets.map { |budget| budget.category.name }
    @budget_values = @category_budgets.map { |budget| budget.amount.to_f }
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
end
