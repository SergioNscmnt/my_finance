require "test_helper"

class EvolutionWebhookEventTest < ActiveSupport::TestCase
  setup do
    @account = WhatsappAccount.create!(
      user: users(:one),
      instance_name: "my_finance",
      phone_number: "5569999991111"
    )
  end

  test "normalizes sender phone" do
    event = EvolutionWebhookEvent.create!(
      user: users(:one),
      whatsapp_account: @account,
      event_name: "MESSAGES_UPSERT",
      instance_name: "my_finance",
      sender_phone: "5569999991111@s.whatsapp.net",
      message_id: "abc",
      payload: { "event" => "MESSAGES_UPSERT" }
    )

    assert_equal "5569999991111", event.sender_phone
  end

  test "requires unique message per instance and sender" do
    attrs = {
      user: users(:one),
      whatsapp_account: @account,
      event_name: "MESSAGES_UPSERT",
      instance_name: "my_finance",
      sender_phone: "5569999991111",
      message_id: "abc",
      payload: { "event" => "MESSAGES_UPSERT" }
    }

    EvolutionWebhookEvent.create!(attrs)
    duplicate = EvolutionWebhookEvent.new(attrs)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:message_id], "já está em uso"
  end
end
