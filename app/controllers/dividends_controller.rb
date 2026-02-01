class DividendsController < ApplicationController
  before_action :set_wallet
  before_action :set_asset
  before_action :set_dividend, only: %i[edit update destroy]

  def new
    @dividend = @asset.dividends.new
  end

  def create
    @dividend = @asset.dividends.new(dividend_params.merge(wallet: @wallet))
    if @dividend.save
      redirect_to investments_income_path, notice: "Provento registrado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @dividend.update(dividend_params)
      redirect_to investments_income_path, notice: "Provento atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dividend.destroy
    redirect_to investments_income_path, notice: "Provento removido com sucesso."
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

  def set_dividend
    @dividend = @asset.dividends.find(params[:id])
  end

  def dividend_params
    params.require(:dividend).permit(:kind, :amount, :paid_on, :reinvested)
  end
end
