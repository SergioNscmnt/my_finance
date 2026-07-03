class EncryptFinancialValues < ActiveRecord::Migration[7.1]
  SENSITIVE_DECIMAL_COLUMNS = {
    cash_accounts: {
      balance: { precision: 20, scale: 8, null: false, default: 0 }
    },
    category_budgets: {
      amount: { precision: 12, scale: 2, null: false }
    },
    credit_card_invoices: {
      total_amount: { precision: 12, scale: 2, null: false, default: 0 }
    },
    dividends: {
      amount: { precision: 12, scale: 2, null: false }
    },
    investment_goals: {
      target_amount: { precision: 15, scale: 2, null: false },
      monthly_contribution: { precision: 12, scale: 2, null: false, default: 0 }
    },
    investment_transactions: {
      quantity: { precision: 15, scale: 6, null: false },
      price: { precision: 15, scale: 6, null: false },
      fees: { precision: 12, scale: 2, null: false, default: 0 }
    },
    ledger_entries: {
      amount: { precision: 20, scale: 8, null: false }
    },
    orders: {
      quantity: { precision: 24, scale: 10, null: false },
      filled_price: { precision: 20, scale: 8, null: true },
      fees: { precision: 20, scale: 8, null: false, default: 0 }
    },
    positions: {
      quantity: { precision: 24, scale: 10, null: false, default: 0 },
      avg_cost: { precision: 20, scale: 8, null: false, default: 0 }
    },
    transactions: {
      amount: { precision: 12, scale: 2, null: false }
    }
  }.freeze

  def up
    each_sensitive_column do |table, column, options|
      change_column table, column, :text, null: options.fetch(:null)
    end

    each_sensitive_column_by_table do |table, columns|
      encrypt_existing_values(table, columns.keys)
    end
  end

  def down
    each_sensitive_column_by_table do |table, columns|
      write_plaintext_values(table, columns.keys)
    end

    each_sensitive_column do |table, column, options|
      change_column table,
                    column,
                    :decimal,
                    precision: options.fetch(:precision),
                    scale: options.fetch(:scale),
                    null: options.fetch(:null),
                    default: options[:default]
    end
  end

  private

  def each_sensitive_column
    SENSITIVE_DECIMAL_COLUMNS.each do |table, columns|
      columns.each do |column, options|
        yield table, column, options
      end
    end
  end

  def each_sensitive_column_by_table
    SENSITIVE_DECIMAL_COLUMNS.each do |table, columns|
      yield table, columns
    end
  end

  def encrypted_model_for(table, columns)
    Class.new(ActiveRecord::Base).tap do |klass|
      klass.table_name = table.to_s
      columns.each do |column|
        klass.attribute column, :decimal
        klass.encrypts column, support_unencrypted_data: true
      end
      klass.reset_column_information
    end
  end

  def encrypt_existing_values(table, columns)
    model = encrypted_model_for(table, columns)

    model.find_each do |record|
      columns.each do |column|
        value = record.public_send(column)
        next if value.nil?

        record.update_column(column, value)
      end
    end
  end

  def write_plaintext_values(table, columns)
    model = encrypted_model_for(table, columns)

    model.find_each do |record|
      assignments = columns.filter_map do |column|
        value = record.public_send(column)
        next if value.nil?

        "#{quote_column_name(column)} = #{quote(value.to_s)}"
      end
      next if assignments.empty?

      execute <<~SQL.squish
        UPDATE #{quote_table_name(table)}
        SET #{assignments.join(", ")}
        WHERE #{quote_column_name(model.primary_key)} = #{quote(record.id)}
      SQL
    end
  end
end
