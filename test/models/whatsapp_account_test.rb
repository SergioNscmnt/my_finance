require "test_helper"

class WhatsappAccountTest < ActiveSupport::TestCase
  test "normalizes phone number" do
    account = WhatsappAccount.create!(
      user: users(:one),
      instance_name: "my_finance",
      phone_number: "+55 (69) 99999-1111"
    )

    assert_equal "5569999991111", account.phone_number
  end

  test "requires unique phone number per instance" do
    WhatsappAccount.create!(
      user: users(:one),
      instance_name: "my_finance",
      phone_number: "5569999991111"
    )

    duplicate = WhatsappAccount.new(
      user: users(:two),
      instance_name: "my_finance",
      phone_number: "55 69 99999-1111"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:phone_number], "já está em uso"
  end
end
