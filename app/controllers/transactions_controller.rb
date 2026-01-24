class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[edit update destroy]
  before_action :set_collections, only: %i[index]

  def index; end

  def new
    @transaction = current_user.transactions.new(kind: params[:type] || params[:kind] || :income)
    @categories  = current_user.categories.order(:name)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "transaction_form",
          partial: "transactions/form",
          locals: { transaction: @transaction, categories: @categories }
        )
      end
      format.html do
        set_collections
        render :index
      end
    end
  end

  def create
    @transaction = current_user.transactions.new(transaction_params)
    if @transaction.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to transactions_path, notice: "Transação criada" }
      end
    else
      set_collections
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    @categories = current_user.categories.order(:name)
  end

  def update
    if @transaction.update(transaction_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to transactions_path, notice: "Transação atualizada" }
      end
    else
      @categories = current_user.categories.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to transactions_path, notice: "Transação removida" }
    end
  end

  private

  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:title, :amount, :kind, :occurred_on, :category_id)
  end

  def filtered_transactions
    scope = current_user.transactions

    from_date = safe_date(params[:from])
    to_date   = safe_date(params[:to])

    scope = scope.where(occurred_on: from_date..) if from_date
    scope = scope.where(occurred_on: ..to_date)   if to_date

    if params[:type].present? && Transaction.kinds.key?(params[:type])
      scope = scope.where(kind: params[:type])
    end

    scope
  end

  def set_collections
    @transactions ||= filtered_transactions.includes(:category).order(occurred_on: :desc, created_at: :desc)
    @transaction  ||= current_user.transactions.new(kind: params[:type] || params[:kind] || :income)
    @categories   ||= current_user.categories.order(:name)
  end

  # Converte string para Date de forma segura, retornando nil em caso de erro.
  def safe_date(raw)
    return nil if raw.blank?
    Date.parse(raw)
  rescue ArgumentError
    nil
  end
end
