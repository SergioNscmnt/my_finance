class CreditCardInvoicePaymentService
  Result = Struct.new(:invoice, :reset_count, keyword_init: true)

  def initialize(invoice:)
    @invoice = invoice
  end

  def call
    reset_count = 0

    ActiveRecord::Base.transaction do
      mark_invoice_as_paid!
      reset_count = reset_planned_category_limits!
    end

    Result.new(invoice: @invoice, reset_count: reset_count)
  end

  private

  def mark_invoice_as_paid!
    return if @invoice.paid?

    @invoice.update!(status: :paid, paid_at: Time.current)
  end

  def reset_planned_category_limits!
    @invoice.user.category_budgets.where(category_id: @invoice.category_id).update_all(amount: 0, updated_at: Time.current)
  end
end
