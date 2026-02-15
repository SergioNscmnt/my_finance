class CreditCardInvoicesController < ApplicationController
  before_action :set_invoice

  def pay
    @invoice.update!(status: :paid, paid_at: Time.current)
    redirect_to dashboard_path, notice: "Fatura marcada como paga."
  end

  private

  def set_invoice
    @invoice = current_user.credit_card_invoices.find(params[:id])
  end
end
