namespace :bootstrap do
  desc "Cria categorias padrão de receita e despesa para todos os usuários"
  task categories: :environment do
    default_categories = {
      income: ["Salário", "Bônus", "Freelance", "Reembolso", "Investimentos (receita)", "Outras receitas"],
      expense: ["Alimentação", "Transporte", "Moradia", "Saúde", "Lazer", "Educação", "Contas e Serviços", "Compras", "Investimentos (despesa)", "Outras despesas"]
    }

    User.find_each do |user|
      default_categories.each do |kind, names|
        names.each do |name|
          Category.find_or_create_by!(user: user, kind: kind, name: name)
        end
      end
    end

    puts "Categorias padrão criadas/atualizadas para #{User.count} usuário(s)."
  end
end
