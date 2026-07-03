class AccountsController < ApplicationController
  def show
    @user = current_user
    @whatsapp_account = current_user.whatsapp_accounts.new(instance_name: ENV["EVOLUTION_INSTANCE_NAME"].presence)
    @whatsapp_accounts = current_user.whatsapp_accounts.order(created_at: :desc)
  end

  def update
    @user = current_user
    attrs = account_params.to_h

    if attrs["password"].blank?
      attrs.delete("password")
      attrs.delete("password_confirmation")
    end

    if @user.update(attrs)
      redirect_to account_path, notice: "Preferências atualizadas com sucesso."
    else
      @whatsapp_account = current_user.whatsapp_accounts.new(instance_name: ENV["EVOLUTION_INSTANCE_NAME"].presence)
      @whatsapp_accounts = current_user.whatsapp_accounts.order(created_at: :desc)
      flash.now[:alert] = "Não foi possível atualizar sua conta."
      render :show, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
