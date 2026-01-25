class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]

  def index
    scope = current_user.categories.order(:name)
    @pagy, @categories = pagy(scope, items: 10)
    @category = current_user.categories.new
  end

  def new
    @category = current_user.categories.new(kind: :income)
  end

  def create
    @category = current_user.categories.new(category_params)
    if @category.save
      respond_to do |format|
        format.turbo_stream { redirect_to categories_path, status: :see_other, turbo_frame: "_top", notice: "Categoria criada" }
        format.html { redirect_to categories_path, notice: "Categoria criada" }
      end
    else
      template = turbo_modal? ? :new : :index
      render template, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      respond_to do |format|
        format.turbo_stream { redirect_to categories_path, status: :see_other, turbo_frame: "_top", notice: "Categoria atualizada" }
        format.html { redirect_to categories_path, notice: "Categoria atualizada" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to categories_path, notice: "Categoria removida" }
    end
  end

  private

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :kind)
  end

  def turbo_modal?
    request.headers["Turbo-Frame"] == "modal"
  end
end
