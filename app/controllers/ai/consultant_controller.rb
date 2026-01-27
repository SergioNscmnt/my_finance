class Ai::ConsultantController < ApplicationController
  def create
    message = params[:message].to_s.strip
    if message.blank?
      render json: { error: "Mensagem vazia." }, status: :unprocessable_entity
      return
    end

    reply = Ai::ConsultantService.new(user: current_user, message: message).call
    render json: { reply: reply }
  rescue Ai::OllamaClient::Error => error
    Rails.logger.warn("Ollama consult error: #{error.message}")
    render json: {
      error: "Nao consegui acessar o Ollama. Verifique se ele esta rodando e tente novamente."
    }, status: :service_unavailable
  end
end
