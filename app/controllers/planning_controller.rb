class PlanningController < ApplicationController
  include BudgetPlanningLoader

  def index
    load_budget_planner_data
  end
end
