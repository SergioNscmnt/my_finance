module Webhooks
  class EvolutionController < ActionController::Base
    protect_from_forgery with: :null_session

    before_action :validate_webhook_token!

    def create
      result = Evolution::WebhookProcessor.new(payload: request.request_parameters.presence || params.to_unsafe_h).call

      render json: {
        status: result.status,
        message: result.message,
        event_id: result.event&.id
      }, status: :accepted
    rescue ActiveRecord::RecordInvalid => error
      render json: { status: "invalid", message: error.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
    rescue StandardError => error
      Rails.logger.error("[Evolution] webhook falhou: #{error.class}: #{error.message}")
      render json: { status: "failed", message: "Erro ao processar webhook" }, status: :internal_server_error
    end

    private

    def validate_webhook_token!
      configured_token = ENV["EVOLUTION_WEBHOOK_TOKEN"].to_s
      provided_token = request.headers["X-Evolution-Webhook-Token"].presence ||
                       request.headers["X-Webhook-Token"].presence ||
                       request.authorization.to_s.delete_prefix("Bearer ").presence

      return if configured_token.present? &&
                provided_token.present? &&
                ActiveSupport::SecurityUtils.secure_compare(provided_token, configured_token)

      render json: { status: "unauthorized" }, status: :unauthorized
    end
  end
end
