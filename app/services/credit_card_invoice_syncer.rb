class CreditCardInvoiceSyncer
  def initialize(user, transactions: nil, today: Date.current)
    @user = user
    @transactions = transactions
    @today = today.to_date
  end

  def sync!
    categories = @user.categories.expense.where(credit_card: true).to_a
    return if categories.empty?
    categories_by_id = categories.index_by(&:id)

    transactions = @transactions || @user.transactions.includes(:category).to_a
    monthly_totals = Hash.new(0.0)

    transactions.each do |transaction|
      next unless transaction.expense?
      next unless transaction.credit_card?
      next unless transaction.category&.credit_card?

      start_month = transaction.billing_start_month
      installments = [transaction.installments.to_i, 1].max
      amount = transaction.per_installment_amount.to_f

      installments.times do |index|
        month = start_month + index.months
        monthly_totals[[transaction.category_id, month]] += amount
      end
    end

    categories.each do |category|
      current_month = @today.beginning_of_month
      monthly_totals[[category.id, current_month]] ||= 0.0
    end

    existing_invoices = @user.credit_card_invoices.where(category_id: categories_by_id.keys).to_a
    existing_keys = existing_invoices.map { |invoice| [invoice.category_id, invoice.billing_month] }
    all_keys = (monthly_totals.keys + existing_keys).uniq

    all_keys.each do |(category_id, billing_month)|
      category = categories_by_id[category_id]
      next unless category
      total_amount = monthly_totals[[category_id, billing_month]] || 0.0

      invoice = @user.credit_card_invoices.find_or_initialize_by(category_id: category_id, billing_month: billing_month)
      invoice.due_on = category.due_date_for_billing_month(billing_month)
      invoice.total_amount = total_amount.round(2)
      invoice.status = invoice.due_on < @today ? :overdue : :open unless invoice.paid?
      invoice.save!
    end

    @user.credit_card_invoices.where(category_id: categories.map(&:id)).where.not(status: :paid).find_each do |invoice|
      next if invoice.due_on.blank?
      invoice.update!(status: invoice.due_on < @today ? :overdue : :open)
    end
  end
end
