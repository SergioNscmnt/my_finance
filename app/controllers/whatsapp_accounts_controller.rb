class WhatsappAccountsController < ApplicationController
  before_action :set_whatsapp_account, only: %i[update destroy test_message]

  def create
    @whatsapp_account = current_user.whatsapp_accounts.new(whatsapp_account_params)

    if @whatsapp_account.save
      redirect_to account_path, notice: "Vínculo WhatsApp cadastrado com sucesso."
    else
      prepare_account_context
      flash.now[:alert] = "Não foi possível cadastrar o vínculo WhatsApp."
      render "accounts/show", status: :unprocessable_entity
    end
  end

  def update
    if @whatsapp_account.update(whatsapp_account_params)
      status = @whatsapp_account.enabled? ? "ativado" : "desativado"
      redirect_to account_path, notice: "Vínculo WhatsApp #{status} com sucesso."
    else
      redirect_to account_path, alert: @whatsapp_account.errors.full_messages.to_sentence
    end
  end

  def destroy
    @whatsapp_account.destroy
    redirect_to account_path, notice: "Vínculo WhatsApp removido com sucesso."
  end

  def test_message
    Evolution::Client.new.send_text(
      number: @whatsapp_account.phone_number,
      text: "Teste do MyFinance: seu WhatsApp está vinculado à aplicação.",
      instance_name: @whatsapp_account.instance_name
    )
    redirect_to account_path, notice: "Mensagem de teste enviada para #{helpers.whatsapp_phone_display(@whatsapp_account.phone_number)}."
  rescue Evolution::Client::ConfigurationError, Evolution::Client::RequestError => error
    redirect_to account_path, alert: "Não foi possível enviar o teste: #{error.message}"
  end

  private

  def set_whatsapp_account
    @whatsapp_account = current_user.whatsapp_accounts.find_by(id: params[:id])
    redirect_to account_path, alert: "Vínculo WhatsApp não encontrado." if @whatsapp_account.blank?
  end

  def whatsapp_account_params
    params.require(:whatsapp_account).permit(:phone_number, :instance_name, :enabled)
  end

  def prepare_account_context
    @user = current_user
    @whatsapp_accounts = current_user.whatsapp_accounts.order(created_at: :desc)
  end
end
