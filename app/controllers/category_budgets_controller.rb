class CategoryBudgetsController < ApplicationController
  include BudgetPlanningLoader

  before_action :set_category_budget, only: %i[edit update destroy]
  before_action :set_budget_categories, only: %i[new edit create update]

  def new
    @category_budget = current_user.category_budgets.new(budget_month: selected_budget_month)
  end

  def edit; end

  def create
    @category_budget = current_user.category_budgets.new(category_budget_params)

    if @category_budget.save
      redirect_to planning_path(budget_month: month_param(@category_budget.budget_month)), notice: "Orçamento por categoria criado."
    elsif turbo_modal?
      render :new, status: :unprocessable_entity
    else
      redirect_to planning_path(budget_month: month_param(@category_budget.budget_month)), alert: @category_budget.errors.full_messages.to_sentence
    end
  end

  def update
    if @category_budget.update(category_budget_params)
      load_budget_planner_data(@category_budget.budget_month)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to planning_path(budget_month: month_param(@category_budget.budget_month)), notice: "Orçamento por categoria atualizado." }
      end
    else
      if turbo_modal?
        render :edit, status: :unprocessable_entity
      else
        redirect_to planning_path(budget_month: month_param(@category_budget.budget_month)), alert: @category_budget.errors.full_messages.to_sentence
      end
    end
  end

  def destroy
    budget_month = @category_budget.budget_month
    @category_budget.destroy
    redirect_to planning_path(budget_month: month_param(budget_month)), notice: "Orçamento por categoria removido."
  end

  private

  def set_category_budget
    @category_budget = current_user.category_budgets.find(params[:id])
  end

  def category_budget_params
    permitted = params.require(:category_budget).permit(:category_id, :amount, :budget_month)
    if permitted[:budget_month].present? && permitted[:budget_month].match?(/\A\d{4}-\d{2}\z/)
      permitted[:budget_month] = Date.strptime(permitted[:budget_month], "%Y-%m").beginning_of_month
    end
    permitted
  end

  def set_budget_categories
    @budget_categories = current_user.categories.expense.order(:name)
  end

  def turbo_modal?
    request.headers["Turbo-Frame"] == "modal"
  end

end
