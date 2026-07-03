require "test_helper"

class Webhooks::EvolutionControllerTest < ActionDispatch::IntegrationTest
  setup do
    @previous_token = ENV["EVOLUTION_WEBHOOK_TOKEN"]
    ENV["EVOLUTION_WEBHOOK_TOKEN"] = "test-secret"
    @user = users(:one)
    @user.categories.create!(name: "Alimentação", kind: :expense)
    @account = WhatsappAccount.create!(
      user: @user,
      instance_name: "my_finance",
      phone_number: "5569999991111"
    )
  end

  teardown do
    ENV["EVOLUTION_WEBHOOK_TOKEN"] = @previous_token
  end

  test "rejects invalid token" do
    assert_no_difference "EvolutionWebhookEvent.count" do
      post "/webhooks/evolution", params: payload(message_id: "invalid-token")
    end

    assert_response :unauthorized
  end

  test "creates transaction from linked whatsapp message" do
    assert_difference "EvolutionWebhookEvent.count", 1 do
      assert_difference "Transaction.count", 1 do
        post "/webhooks/evolution",
             params: payload(message_id: "msg-1"),
             headers: { "X-Evolution-Webhook-Token" => "test-secret" }
      end
    end

    assert_response :accepted
    event = EvolutionWebhookEvent.order(:id).last
    transaction = Transaction.order(:id).last

    assert event.processed?
    assert_equal transaction, event.created_transaction
    assert_equal @user, transaction.user
    assert_equal "expense", transaction.kind
    assert_equal BigDecimal("30.00"), transaction.amount
    assert_equal "credit_card", transaction.payment_method
  end

  test "does not duplicate transaction for repeated message" do
    2.times do
      post "/webhooks/evolution",
           params: payload(message_id: "msg-duplicate"),
           headers: { "X-Evolution-Webhook-Token" => "test-secret" }
      assert_response :accepted
    end

    assert_equal 1, EvolutionWebhookEvent.where(message_id: "msg-duplicate").count
    assert_equal 1, Transaction.where(title: "Alimentação via WhatsApp").count
  end

  test "ignores unlinked phone" do
    assert_no_difference "Transaction.count" do
      post "/webhooks/evolution",
           params: payload(message_id: "msg-unlinked", remote_jid: "5500000000000@s.whatsapp.net"),
           headers: { "X-Evolution-Webhook-Token" => "test-secret" }
    end

    assert_response :accepted
    assert EvolutionWebhookEvent.order(:id).last.ignored?
  end

  private

  def payload(message_id:, remote_jid: "5569999991111@s.whatsapp.net")
    {
      event: "MESSAGES_UPSERT",
      instance: "my_finance",
      data: {
        key: {
          id: message_id,
          remoteJid: remote_jid,
          fromMe: false
        },
        messageType: "conversation",
        messageTimestamp: Time.zone.local(2026, 7, 3, 9, 30).to_i,
        message: {
          conversation: "Bom dia, gastei R$ 30,00 no café da manhã no cartão de crédito."
        }
      }
    }
  end
end
