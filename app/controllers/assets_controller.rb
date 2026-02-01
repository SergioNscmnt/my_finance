class AssetsController < ApplicationController
  before_action :set_wallet
  before_action :set_asset, only: %i[show edit update destroy]

  def index
    @assets = @wallet.assets.order(:ticker)
  end

  def show
    @transactions = @asset.investment_transactions.ordered
    @position = Investments::PositionCalculator.new(wallet: @wallet, asset: @asset).call.first
  end

  def new
    @asset = @wallet.assets.new
  end

  def create
    @asset = @wallet.assets.new(asset_params)
    if @asset.save
      redirect_to @asset, notice: "Ativo criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @asset.update(asset_params)
      redirect_to @asset, notice: "Ativo atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @asset.destroy
    redirect_to assets_path, notice: "Ativo removido com sucesso."
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
    @asset = @wallet.assets.find(params[:id])
  end

  def asset_params
    params.require(:asset).permit(:name, :ticker, :asset_type, :currency)
  end
end
