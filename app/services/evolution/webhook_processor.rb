module Evolution
  class WebhookProcessor
    Response = Struct.new(:event, :status, :message, keyword_init: true)

    def initialize(payload:, client: Evolution::Client.new)
      @payload = Evolution::WebhookPayload.new(payload)
      @client = client
    end

    def call
      event = persist_event
      process_event(event)
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      duplicate = EvolutionWebhookEvent.find_by(
        instance_name: @payload.instance_name,
        sender_phone: @payload.sender_phone,
        message_id: @payload.message_id
      )
      Response.new(event: duplicate, status: :duplicate, message: "Mensagem já processada")
    end

    private

    def persist_event
      account = find_account

      EvolutionWebhookEvent.create!(
        user: account&.user,
        whatsapp_account: account,
        event_name: @payload.event_name,
        instance_name: @payload.instance_name,
        sender_phone: @payload.sender_phone,
        message_id: @payload.message_id,
        message_type: @payload.message_type,
        message_text: @payload.message_text,
        from_me: @payload.from_me?,
        payload: @payload.raw
      )
    end

    def process_event(event)
      if event.event_name != "MESSAGES_UPSERT"
        event.mark_ignored!("Evento não suportado")
        return Response.new(event: event, status: :ignored, message: "Evento ignorado")
      end

      if event.from_me?
        event.mark_ignored!("Mensagem enviada pelo próprio bot")
        return Response.new(event: event, status: :ignored, message: "Mensagem do bot ignorada")
      end

      if event.whatsapp_account.blank? || event.user.blank?
        event.mark_ignored!("Número de WhatsApp não vinculado")
        return Response.new(event: event, status: :ignored, message: "Número não vinculado")
      end

      event.whatsapp_account.update!(last_seen_at: Time.current)

      if event.message_text.blank?
        message = event.message_type.to_s.include?("image") ? "Recebi a imagem, mas a análise de foto ainda não está disponível. Envie a despesa ou receita em texto." : "Não consegui ler o texto da mensagem."
        event.mark_pending!(message)
        send_reply(event, message)
        return Response.new(event: event, status: :pending, message: message)
      end

      parser_result = Evolution::TransactionParser.new(
        user: event.user,
        text: event.message_text,
        occurred_on: @payload.occurred_on
      ).call

      unless parser_result.valid?
        message = "Não consegui registrar. Informe: #{parser_result.errors.join(', ')}."
        event.mark_pending!(message)
        send_reply(event, message)
        return Response.new(event: event, status: :pending, message: message)
      end

      transaction = create_transaction!(event, parser_result)
      event.mark_processed!(transaction: transaction)
      send_reply(event, confirmation_message(transaction))
      Response.new(event: event, status: :processed, message: "Transação registrada")
    rescue StandardError => error
      event.mark_failed!(error.message) if event&.persisted?
      raise
    end

    def find_account
      WhatsappAccount.enabled.find_by(instance_name: @payload.instance_name, phone_number: @payload.sender_phone)
    end

    def create_transaction!(event, parser_result)
      event.user.transactions.create!(
        title: parser_result.title,
        amount: parser_result.amount,
        kind: parser_result.kind,
        occurred_on: parser_result.occurred_on,
        category: parser_result.category,
        payment_method: parser_result.payment_method
      )
    end

    def confirmation_message(transaction)
      kind_label = transaction.income? ? "Receita" : "Despesa"
      payment_label = I18n.t("activerecord.attributes.transaction.payment_methods.#{transaction.payment_method}", default: transaction.payment_method.humanize)
      "#{kind_label} registrada: #{ApplicationController.helpers.number_to_currency(transaction.amount, unit: 'R$ ', separator: ',', delimiter: '.')} em #{transaction.category.name} via #{payment_label} no dia #{I18n.l(transaction.occurred_on)}."
    end

    def send_reply(event, message)
      @client.send_text(number: event.sender_phone, text: message, instance_name: event.instance_name)
    rescue Evolution::Client::ConfigurationError, Evolution::Client::RequestError => error
      Rails.logger.info("[Evolution] resposta não enviada: #{error.message}")
    end
  end
end
