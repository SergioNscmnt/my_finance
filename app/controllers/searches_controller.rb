class SearchesController < ApplicationController
  RESULT_LIMIT = 8
  PREVIEW_LIMIT = 3

  def index
    @query = params[:q].to_s.strip
    load_results(limit: RESULT_LIMIT)
  end

  def preview
    @query = params[:q].to_s.strip
    load_results(limit: PREVIEW_LIMIT)
    render partial: "searches/preview", formats: :html, layout: false
  end

  private

  def load_results(limit:)
    @transactions = []
    @categories = []
    @category_budgets = []
    @credit_card_invoices = []

    return if @query.blank?

    term = "%#{ActiveRecord::Base.sanitize_sql_like(@query.downcase)}%"

    @transactions = current_user.transactions
                                .includes(:category)
                                .joins(:category)
                                .where("LOWER(transactions.title) LIKE :term OR LOWER(categories.name) LIKE :term OR LOWER(categories.card_bank) LIKE :term", term: term)
                                .order(occurred_on: :desc, created_at: :desc)
                                .limit(limit)

    @categories = current_user.categories
                              .where("LOWER(name) LIKE :term OR LOWER(card_bank) LIKE :term", term: term)
                              .order(:name)
                              .limit(limit)

    @category_budgets = current_user.category_budgets
                                    .includes(:category)
                                    .joins(:category)
                                    .where("LOWER(categories.name) LIKE :term OR LOWER(categories.card_bank) LIKE :term", term: term)
                                    .order(budget_month: :desc)
                                    .limit(limit)

    @credit_card_invoices = current_user.credit_card_invoices
                                        .includes(:category)
                                        .joins(:category)
                                        .where("LOWER(categories.name) LIKE :term OR LOWER(categories.card_bank) LIKE :term", term: term)
                                        .order(due_on: :desc)
                                        .limit(limit)
  end
end
