class CategoryBudgetsController < ApplicationController
  before_action :set_category_budget, only: %i[edit update destroy]
  before_action :set_budget_categories, only: %i[edit update]

  def edit; end

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
      load_budget_planner_data
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to dashboard_path, notice: "Orçamento por categoria atualizado." }
      end
    else
      if turbo_modal?
        render :edit, status: :unprocessable_entity
      else
        redirect_to dashboard_path, alert: @category_budget.errors.full_messages.to_sentence
      end
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

  def set_budget_categories
    @budget_categories = current_user.categories.expense.order(:name)
  end

  def turbo_modal?
    request.headers["Turbo-Frame"] == "modal"
  end

  def load_budget_planner_data
    transactions = current_user.transactions.includes(:category).to_a

    receita_total = transactions.select(&:income?).sum { |t| t.monthly_amount_for(Date.current) }
    despesa_total = transactions.select(&:expense?).sum { |t| t.monthly_amount_for(Date.current) }
    @balance = receita_total - despesa_total

    @category_budget = current_user.category_budgets.new
    @budget_categories = current_user.categories.expense.order(:name)
    @category_budgets = current_user.category_budgets.includes(:category).joins(:category).order("categories.name ASC")

    budget_category_ids = @category_budgets.map(&:category_id)
    @budget_spent_by_category_id = Hash.new(0.0)

    transactions.each do |transaction|
      next unless transaction.expense?
      next unless budget_category_ids.include?(transaction.category_id)

      @budget_spent_by_category_id[transaction.category_id] += transaction.monthly_amount_for(Date.current)
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

    @planned_budget_total = @category_budgets.sum(:amount)
    # "Disponível" deve refletir o saldo atual; planejamento só impacta após gasto real.
    @available_after_budget = @balance
    @budget_labels = @category_budgets.map { |budget| budget.category.name }
    @budget_values = @category_budgets.map { |budget| budget.amount.to_f }
  end
end
