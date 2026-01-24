class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = current_user.categories.order(:name)
    @category = current_user.categories.new
  end

  def create
    @category = current_user.categories.new(category_params)
    if @category.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to categories_path, notice: "Categoria criada" }
      end
    else
      render :index, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      respond_to do |format|
        format.turbo_stream
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
end
