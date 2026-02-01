class InvestmentTransactionsController < ApplicationController
  before_action :set_wallet
  before_action :set_asset
  before_action :set_transaction, only: %i[edit update destroy]

  def new
    @investment_transaction = @asset.investment_transactions.new
  end

  def create
    @investment_transaction = @asset.investment_transactions.new(transaction_params.merge(wallet: @wallet))
    if @investment_transaction.save
      redirect_to @asset, notice: "Movimentação registrada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @investment_transaction.update(transaction_params)
      redirect_to @asset, notice: "Movimentação atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @investment_transaction.destroy
    redirect_to @asset, notice: "Movimentação removida com sucesso."
  end

  private

  def set_wallet
    @wallet = if params[:wallet_id]
                current_user.wallets.find(params[:wallet_id])
              else
                current_user.wallets.first_or_create!(name: "Principal", currency: "BRL")
              end
  end

  def set_asset
    @asset = @wallet.assets.find(params[:asset_id])
  end

  def set_transaction
    @investment_transaction = @asset.investment_transactions.find(params[:id])
  end

  def transaction_params
    params.require(:investment_transaction).permit(:kind, :quantity, :price, :fees, :occurred_on)
  end
end
