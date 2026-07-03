require "test_helper"

class WhatsappAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    login_as(@user)
  end

  test "creates whatsapp account for current user" do
    assert_difference -> { @user.whatsapp_accounts.count }, 1 do
      post whatsapp_accounts_path, params: {
        whatsapp_account: {
          phone_number: "+55 (69) 99999-1111",
          instance_name: "my_finance"
        }
      }
    end

    account = @user.whatsapp_accounts.order(:id).last
    assert_redirected_to account_path
    assert_equal "5569999991111", account.phone_number
    assert_equal "my_finance", account.instance_name
    assert account.enabled?
  end

  test "account page lists only current user whatsapp accounts" do
    own_account = @user.whatsapp_accounts.create!(phone_number: "5569999991111", instance_name: "own_instance")
    other_account = @other_user.whatsapp_accounts.create!(phone_number: "5569888882222", instance_name: "other_instance")

    get account_path

    assert_response :success
    assert_includes response.body, own_account.instance_name
    assert_includes response.body, "99999-1111"
    assert_not_includes response.body, other_account.instance_name
    assert_not_includes response.body, "88888-2222"
  end

  test "does not update another user's whatsapp account" do
    other_account = @other_user.whatsapp_accounts.create!(phone_number: "5569888882222", instance_name: "other_instance", enabled: true)

    patch whatsapp_account_path(other_account), params: { whatsapp_account: { enabled: false } }

    assert_redirected_to account_path
    assert other_account.reload.enabled?
  end

  test "toggles current user whatsapp account status" do
    account = @user.whatsapp_accounts.create!(phone_number: "5569999991111", instance_name: "my_finance", enabled: true)

    patch whatsapp_account_path(account), params: { whatsapp_account: { enabled: false } }

    assert_redirected_to account_path
    assert_not account.reload.enabled?

    patch whatsapp_account_path(account), params: { whatsapp_account: { enabled: true } }

    assert_redirected_to account_path
    assert account.reload.enabled?
  end

  test "removes current user whatsapp account and preserves events" do
    account = @user.whatsapp_accounts.create!(phone_number: "5569999991111", instance_name: "my_finance")
    event = EvolutionWebhookEvent.create!(
      user: @user,
      whatsapp_account: account,
      event_name: "MESSAGES_UPSERT",
      instance_name: "my_finance",
      sender_phone: account.phone_number,
      message_id: "preserved-message",
      payload: { "event" => "MESSAGES_UPSERT" }
    )

    assert_difference "WhatsappAccount.count", -1 do
      assert_no_difference "EvolutionWebhookEvent.count" do
        delete whatsapp_account_path(account)
      end
    end

    assert_redirected_to account_path
    assert_nil event.reload.whatsapp_account
  end

  test "does not remove another user's whatsapp account" do
    other_account = @other_user.whatsapp_accounts.create!(phone_number: "5569888882222", instance_name: "other_instance")

    assert_no_difference "WhatsappAccount.count" do
      delete whatsapp_account_path(other_account)
    end

    assert_redirected_to account_path
    assert WhatsappAccount.exists?(other_account.id)
  end

  test "test message reports configuration errors without changing account" do
    previous_base_url = ENV["EVOLUTION_API_BASE_URL"]
    previous_api_key = ENV["EVOLUTION_API_KEY"]
    previous_instance = ENV["EVOLUTION_INSTANCE_NAME"]
    ENV["EVOLUTION_API_BASE_URL"] = nil
    ENV["EVOLUTION_API_KEY"] = nil
    ENV["EVOLUTION_INSTANCE_NAME"] = nil
    account = @user.whatsapp_accounts.create!(phone_number: "5569999991111", instance_name: "my_finance", enabled: true)

    post test_message_whatsapp_account_path(account)

    assert_redirected_to account_path
    assert account.reload.enabled?
  ensure
    ENV["EVOLUTION_API_BASE_URL"] = previous_base_url
    ENV["EVOLUTION_API_KEY"] = previous_api_key
    ENV["EVOLUTION_INSTANCE_NAME"] = previous_instance
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password" }
    assert_redirected_to root_path
  end
end
