module EncryptedFinancialAttributes
  extend ActiveSupport::Concern

  class_methods do
    def encrypts_decimal(*names)
      names.each do |name|
        attribute name, :decimal
        encrypts name, support_unencrypted_data: true
      end
    end
  end
end
