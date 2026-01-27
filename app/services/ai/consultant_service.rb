module Ai
  class ConsultantService
    def initialize(user:, message:, today: Date.current)
      @user = user
      @message = message
      @today = today
      @client = Ai::OllamaClient.new
    end

    def call
      response = @client.chat([
        { role: "system", content: system_prompt },
        { role: "user", content: user_prompt }
      ])
      warning = "Nao e consultoria financeira profissional."
      response.downcase.include?(warning.downcase) ? response : "#{response.strip}\n\n#{warning}"
    end

    private

    def system_prompt
      <<~PROMPT
        Voce e uma consultora financeira pessoal do app MyFinance.
        Responda em portugues do Brasil, com orientacoes praticas e objetivas.
        Use apenas os dados fornecidos no contexto.
        Se faltar dado, pergunte antes de concluir.
        Nao invente numeros ou categorias.
        Sempre inclua um aviso curto: "Nao e consultoria financeira profissional."
      PROMPT
    end

    def user_prompt
      <<~PROMPT
        Contexto do usuario:
        #{context_payload}

        Pergunta:
        #{@message}
      PROMPT
    end

    def context_payload
      transactions = @user.transactions.includes(:category)
                          .where("occurred_on >= ?", @today - 365)
      current_month = @today.beginning_of_month

      income_month = transactions.select(&:income?).sum { |t| t.monthly_amount_for(current_month) }
      expense_month = transactions.select(&:expense?).sum { |t| t.monthly_amount_for(current_month) }
      balance_month = income_month - expense_month

      recent = transactions.sort_by { |t| [t.occurred_on, t.created_at] }.reverse.first(10)

      top_categories = transactions.select(&:expense?)
                                  .group_by { |t| t.category&.name || "Sem categoria" }
                                  .transform_values { |txs| txs.sum { |t| t.monthly_amount_for(current_month) } }
                                  .sort_by { |_name, total| -total }
                                  .first(5)

      last_three_months = (2).downto(0).map { |i| @today.beginning_of_month - i.months }
      monthly_series = last_three_months.map do |month|
        total = transactions.sum { |t| t.monthly_impact(month) }
        "#{month.strftime('%b/%y')}: #{format_currency(total)}"
      end

      <<~CONTEXT
        Mes atual: #{current_month.strftime('%B/%Y')}
        Receita do mes: #{format_currency(income_month)}
        Despesa do mes: #{format_currency(expense_month)}
        Saldo do mes: #{format_currency(balance_month)}

        Variacao dos ultimos 3 meses (saldo):
        #{monthly_series.join("\n")}

        Top 5 categorias de despesa (mes atual):
        #{format_category_lines(top_categories)}

        Ultimas 10 transacoes:
        #{format_recent_lines(recent)}
      CONTEXT
    end

    def format_recent_lines(transactions)
      return "Sem transacoes registradas." if transactions.empty?
      transactions.map do |t|
        category = t.category&.name || "Sem categoria"
        method = t.payment_method || "nao informado"
        installments = t.installments.to_i > 1 ? " (#{t.installments}x)" : ""
        "#{t.occurred_on.strftime('%d/%m/%Y')} - #{t.title} - #{t.kind} - #{format_currency(t.amount)} - #{category} - #{method}#{installments}"
      end.join("\n")
    end

    def format_category_lines(categories)
      return "Sem despesas no mes atual." if categories.empty?
      categories.map { |(name, total)| "- #{name}: #{format_currency(total)}" }.join("\n")
    end

    def format_currency(value)
      "R$ #{format('%.2f', value)}"
    end
  end
end
