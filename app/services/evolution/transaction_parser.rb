module Evolution
  class TransactionParser
    Result = Struct.new(:amount, :kind, :category, :payment_method, :title, :occurred_on, :errors, keyword_init: true) do
      def valid?
        errors.blank?
      end
    end

    CATEGORY_KEYWORDS = {
      "Alimentação" => %w[alimentacao almoço almoco jantar cafe café lanche mercado restaurante padaria],
      "Transporte" => %w[transporte uber 99 taxi táxi combustivel combustível gasolina onibus ônibus],
      "Moradia" => %w[moradia aluguel condominio condomínio casa],
      "Saúde" => %w[saude saúde remedio remédio farmacia farmácia medico médico],
      "Lazer" => %w[lazer cinema passeio viagem bar],
      "Educação" => %w[educacao educação curso faculdade escola livro],
      "Contas e Serviços" => %w[conta contas luz energia agua água internet telefone servico serviço],
      "Compras" => %w[compra compras comprei notebook roupa loja],
      "Salário" => %w[salario salário pagamento ordenado remuneracao remuneração],
      "Bônus" => %w[bonus bônus bonificacao bonificação],
      "Freelance" => %w[freela freelance projeto],
      "Reembolso" => %w[reembolso reembolsaram]
    }.freeze

    INCOME_KEYWORDS = %w[recebi recebeu receber salario salário pagamento renda entrou entrada reembolso bônus bonus].freeze
    EXPENSE_KEYWORDS = %w[gastei gastou gasto paguei pagou pagar comprei comprou compra despesa cafe café almoço almoco jantar].freeze

    def initialize(user:, text:, occurred_on: Date.current)
      @user = user
      @text = text.to_s
      @normalized_text = normalize(@text)
      @occurred_on = occurred_on
    end

    def call
      errors = []
      amount = parse_amount
      kind = parse_kind
      payment_method = parse_payment_method
      category = parse_category(kind)

      errors << "valor não identificado" if amount.blank?
      errors << "tipo da transação não identificado" if kind.blank?
      errors << "categoria não identificada" if category.blank?
      errors << "forma de pagamento não identificada" if payment_method.blank?

      Result.new(
        amount: amount,
        kind: kind,
        category: category,
        payment_method: payment_method,
        title: build_title(category, kind),
        occurred_on: @occurred_on,
        errors: errors
      )
    end

    private

    def parse_amount
      match = @text.match(/r\$\s*(\d{1,3}(?:\.\d{3})*,\d{2}|\d+,\d{2}|\d+(?:\.\d{2})?)/i)
      match ||= @text.match(/\b(\d{1,3}(?:\.\d{3})*,\d{2}|\d+,\d{2})\b/)
      match ||= @text.match(/\bvalor\s+de\s+(\d+(?:\.\d{2})?)\b/i)
      return nil unless match

      raw_amount = match[1].to_s
      decimal = if raw_amount.include?(",")
                  raw_amount.delete(".").tr(",", ".")
                else
                  raw_amount
                end

      BigDecimal(decimal)
    rescue ArgumentError
      nil
    end

    def parse_kind
      return "income" if INCOME_KEYWORDS.any? { |keyword| includes_word?(keyword) }
      return "expense" if EXPENSE_KEYWORDS.any? { |keyword| includes_word?(keyword) }

      nil
    end

    def parse_payment_method
      return "credit_card" if @normalized_text.match?(/\bcartao\b/) || @normalized_text.match?(/\bcredito\b/)
      return "pix" if @normalized_text.match?(/\bpix\b/) || @normalized_text.match?(/\bted\b/)
      return "cash" if @normalized_text.match?(/\bdinheiro\b/) || @normalized_text.match?(/\bespecie\b/)

      @normalized_text.match?(/\brecebi\b|\bsalario\b/) ? "pix" : "cash"
    end

    def parse_category(kind)
      return nil if kind.blank?

      scoped_categories = @user.categories.public_send(kind)
      direct_match = scoped_categories.find { |category| @normalized_text.include?(normalize(category.name)) }
      return direct_match if direct_match

      CATEGORY_KEYWORDS.each do |category_name, keywords|
        next unless keywords.any? { |keyword| includes_word?(keyword) }

        category = scoped_categories.find { |candidate| normalize(candidate.name) == normalize(category_name) }
        return category if category
      end

      nil
    end

    def build_title(category, kind)
      return @text.truncate(80) if category.blank?

      kind == "income" ? category.name : "#{category.name} via WhatsApp"
    end

    def includes_word?(keyword)
      @normalized_text.match?(/\b#{Regexp.escape(normalize(keyword))}\b/)
    end

    def normalize(value)
      I18n.transliterate(value.to_s).downcase
    end
  end
end
