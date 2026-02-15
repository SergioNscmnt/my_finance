class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]

  def index
    load_categories
    @category = current_user.categories.new
  end

  def new
    @category = current_user.categories.new(kind: :income)
  end

  def create
    @category = current_user.categories.new(category_params)
    if @category.save
      load_categories
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Categoria criada" }
        format.html { redirect_to categories_path, notice: "Categoria criada" }
      end
    else
      template = turbo_modal? ? :new : :index
      load_categories if template == :index
      render template, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      load_categories
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Categoria atualizada" }
        format.html { redirect_to categories_path, notice: "Categoria atualizada" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    load_categories
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "Categoria removida" }
      format.html { redirect_to categories_path, notice: "Categoria removida" }
    end
  end

  private

  def load_categories
    scope = current_user.categories.order(:name)
    @pagy, @categories = pagy(scope, items: 10)
  end

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(
      :name,
      :kind,
      :credit_card,
      :card_bank,
      :statement_closing_day,
      :statement_due_day,
      :reminder_days_before_due
    )
  end

  def turbo_modal?
    request.headers["Turbo-Frame"] == "modal"
  end
end
