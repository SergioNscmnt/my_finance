class CategoryBudgetsController < ApplicationController
  before_action :set_category_budget, only: %i[update destroy]

  def create
    @category_budget = current_user.category_budgets.new(category_budget_params)

    if @category_budget.save
      redirect_to dashboard_path, notice: "Orçamento por categoria criado."
    else
      redirect_to dashboard_path, alert: @category_budget.errors.full_messages.to_sentence
    end
  end

  def update
    if @category_budget.update(category_budget_params)
      redirect_to dashboard_path, notice: "Orçamento por categoria atualizado."
    else
      redirect_to dashboard_path, alert: @category_budget.errors.full_messages.to_sentence
    end
  end

  def destroy
    @category_budget.destroy
    redirect_to dashboard_path, notice: "Orçamento por categoria removido."
  end

  private

  def set_category_budget
    @category_budget = current_user.category_budgets.find(params[:id])
  end

  def category_budget_params
    params.require(:category_budget).permit(:category_id, :amount)
  end
end
