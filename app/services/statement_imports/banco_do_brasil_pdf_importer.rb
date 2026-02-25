require "date"
require "open3"

module StatementImports
  class BancoDoBrasilPdfImporter
    DEFAULT_CATEGORY_NAME = "Cartão de Crédito"
    DEFAULT_BANK_NAME = "Banco do Brasil"

    def initialize(user:, pdf_path:, statement_reference_month:, delete_pdf_after_import: false)
      @user = user
      @pdf_path = pdf_path
      @statement_reference_month = statement_reference_month.to_date.beginning_of_month
      @delete_pdf_after_import = delete_pdf_after_import
    end

    def call
      lines = extract_text_lines
      category = find_or_create_card_category!
      report = import_lines(lines, category: category)
      delete_pdf_if_requested!
      report
    end

    private

    def extract_text_lines
      text = extract_pdf_text
      text.to_s.lines.map(&:strip).reject(&:blank?)
    end

    def extract_pdf_text
      unless File.exist?(@pdf_path)
        raise ArgumentError, "Arquivo PDF não encontrado."
      end

      stdout, stderr, status = Open3.capture3("pdftotext", "-layout", "-enc", "UTF-8", @pdf_path, "-")
      if status.success? && stdout.present?
        return stdout
      end

      raise StandardError, "Não foi possível ler o PDF (pdftotext): #{stderr.to_s.strip.presence || 'erro desconhecido'}"
    rescue Errno::ENOENT
      raise StandardError, "Comando 'pdftotext' não disponível no ambiente."
    end

    def find_or_create_card_category!
      existing = @user.categories.find_by(credit_card: true, card_bank: DEFAULT_BANK_NAME)
      return existing if existing

      @user.categories.create!(
        name: DEFAULT_CATEGORY_NAME,
        kind: :expense,
        credit_card: true,
        card_bank: DEFAULT_BANK_NAME,
        statement_closing_day: 20,
        statement_due_day: 1,
        reminder_days_before_due: 5
      )
    end

    def import_lines(lines, category:)
      created = 0
      existing = 0
      ignored = 0

      lines.each do |line|
        parsed = parse_line(line)
        if parsed.nil?
          ignored += 1
          next
        end

        attrs = {
          user_id: @user.id,
          category_id: category.id,
          kind: :expense,
          title: parsed[:title],
          amount: parsed[:amount],
          occurred_on: parsed[:occurred_on],
          payment_method: :credit_card,
          installments: parsed[:installments]
        }

        tx = Transaction.find_by(attrs)
        if tx
          existing += 1
        else
          Transaction.create!(attrs)
          created += 1
        end
      end

      {
        created: created,
        existing: existing,
        ignored: ignored
      }
    end

    def parse_line(line)
      match = line.match(/\A(\d{2}\/\d{2})\s+(.+?)\s+R\$\s*(-?[\d\.,]+)\z/)
      return nil unless match

      day_month = match[1]
      raw_desc = match[2].squish
      amount = parse_amount(match[3])
      return nil if amount <= 0

      installments = 1
      occurred_on = parse_occurred_on(day_month)
      title = normalize_title(raw_desc)

      parc_match = raw_desc.match(/\s+PARC\s+(\d{2})\/(\d{2})\b/i)
      if parc_match
        current_installment = parc_match[1].to_i
        total_installments = parc_match[2].to_i
        return nil if current_installment <= 0 || total_installments <= 0

        installments = total_installments
        start_month = @statement_reference_month << (current_installment - 1)
        occurred_on = start_month

        # No extrato, valor da linha parcelada é a parcela do mês. Convertendo para total
        # para manter a regra mensal do model (amount / installments).
        amount = (amount * total_installments).round(2)
        title = normalize_title(raw_desc.sub(/\s+PARC\s+\d{2}\/\d{2}\b/i, ""))
      end

      {
        title: title,
        amount: amount,
        occurred_on: occurred_on,
        installments: installments
      }
    end

    def parse_amount(raw)
      BigDecimal(raw.to_s.gsub(".", "").gsub(",", "."))
    end

    def parse_occurred_on(day_month)
      day, month = day_month.split("/").map(&:to_i)
      year = month <= @statement_reference_month.month ? @statement_reference_month.year : @statement_reference_month.year - 1
      Date.new(year, month, day)
    end

    def normalize_title(value)
      value.to_s
           .gsub(/\s+BR\z/i, "")
           .gsub(/\s+CA\z/i, "")
           .squish
    end

    def delete_pdf_if_requested!
      return unless @delete_pdf_after_import
      return if @pdf_path.blank? || !File.exist?(@pdf_path)

      File.delete(@pdf_path)
    rescue StandardError
      # noop: falha de limpeza não invalida importação já concluída
      nil
    end
  end
end
