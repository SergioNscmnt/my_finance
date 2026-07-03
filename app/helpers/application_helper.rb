require "securerandom"

module ApplicationHelper
  include Pagy::Frontend

  ICON_PATHS = {
    "alert-triangle" => [
      { d: "M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z" },
      { d: "M12 9v4" },
      { d: "M12 17h.01" }
    ],
    "arrow-down-left" => [
      { d: "M17 7 7 17" },
      { d: "M17 17H7V7" }
    ],
    "arrow-up-right" => [
      { d: "M7 17 17 7" },
      { d: "M7 7h10v10" }
    ],
    "banknote" => [
      { d: "M3 6h18v12H3z" },
      { d: "M7 10h.01" },
      { d: "M17 14h.01" },
      { d: "M12 9a3 3 0 1 1 0 6 3 3 0 0 1 0-6Z" }
    ],
    "book-open" => [
      { d: "M2 4h7a3 3 0 0 1 3 3v15a3 3 0 0 0-3-3H2Z" },
      { d: "M22 4h-7a3 3 0 0 0-3 3v15a3 3 0 0 1 3-3h7Z" }
    ],
    "briefcase" => [
      { d: "M10 6V5a2 2 0 0 1 2-2h0a2 2 0 0 1 2 2v1" },
      { d: "M3 7h18v12a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2Z" },
      { d: "M3 13h18" },
      { d: "M9 13v2h6v-2" }
    ],
    "calendar" => [
      { d: "M8 2v4" },
      { d: "M16 2v4" },
      { d: "M3 10h18" },
      { d: "M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z" }
    ],
    "car" => [
      { d: "M7 17h10" },
      { d: "M5 17H3v-5l2-5a3 3 0 0 1 2.8-2h8.4A3 3 0 0 1 19 7l2 5v5h-2" },
      { d: "M7 17a2 2 0 1 0 0 4 2 2 0 0 0 0-4Z" },
      { d: "M17 17a2 2 0 1 0 0 4 2 2 0 0 0 0-4Z" },
      { d: "M6 12h12" }
    ],
    "chart-line" => [
      { d: "M3 3v18h18" },
      { d: "m7 15 4-4 3 3 5-7" }
    ],
    "circle-dollar" => [
      { d: "M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20Z" },
      { d: "M12 6v12" },
      { d: "M15 9.5A2.5 2.5 0 0 0 12.5 8H11a2 2 0 0 0 0 4h2a2 2 0 0 1 0 4h-1.5A2.5 2.5 0 0 1 9 14.5" }
    ],
    "credit-card" => [
      { d: "M3 6h18a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2Z" },
      { d: "M1 10h22" },
      { d: "M7 15h3" }
    ],
    "film" => [
      { d: "M4 4h16v16H4Z" },
      { d: "M8 4v16" },
      { d: "M16 4v16" },
      { d: "M4 8h4" },
      { d: "M16 8h4" },
      { d: "M4 16h4" },
      { d: "M16 16h4" }
    ],
    "gift" => [
      { d: "M20 12v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-8" },
      { d: "M2 7h20v5H2Z" },
      { d: "M12 22V7" },
      { d: "M12 7H8.5A2.5 2.5 0 1 1 11 4.5L12 7Z" },
      { d: "M12 7h3.5A2.5 2.5 0 1 0 13 4.5L12 7Z" }
    ],
    "heart-pulse" => [
      { d: "M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.6l-1-1a5.5 5.5 0 0 0-7.8 7.8l1 1L12 21l7.8-7.6 1-1a5.5 5.5 0 0 0 0-7.8Z" },
      { d: "M3.5 12h4l1.5-3 3 6 1.5-3h4" }
    ],
    "home" => [
      { d: "m3 11 9-8 9 8" },
      { d: "M5 10v10h14V10" },
      { d: "M10 20v-6h4v6" }
    ],
    "layers" => [
      { d: "m12 2 9 5-9 5-9-5 9-5Z" },
      { d: "m3 12 9 5 9-5" },
      { d: "m3 17 9 5 9-5" }
    ],
    "lock" => [
      { d: "M6 10V8a6 6 0 0 1 12 0v2" },
      { d: "M5 10h14v11H5Z" },
      { d: "M12 15v2" }
    ],
    "mail" => [
      { d: "M4 5h16a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2Z" },
      { d: "m22 7-10 6L2 7" }
    ],
    "message-circle" => [
      { d: "M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8Z" }
    ],
    "map" => [
      { d: "M9 18 3 21V6l6-3 6 3 6-3v15l-6 3-6-3Z" },
      { d: "M9 3v15" },
      { d: "M15 6v15" }
    ],
    "pie-chart" => [
      { d: "M21 12a9 9 0 1 1-9-9v9h9Z" },
      { d: "M12 3a9 9 0 0 1 9 9" }
    ],
    "plug" => [
      { d: "M12 22v-5" },
      { d: "M9 8V2" },
      { d: "M15 8V2" },
      { d: "M6 8h12v3a6 6 0 0 1-12 0Z" }
    ],
    "paw" => [
      { d: "M11 18.5 8.5 21a2 2 0 0 1-3-2.5l1-2A5.5 5.5 0 0 1 12 13a5.5 5.5 0 0 1 5.5 3.5l1 2A2 2 0 0 1 15.5 21L13 18.5a1.4 1.4 0 0 0-2 0Z" },
      { d: "M5.5 10.5a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z" },
      { d: "M18.5 10.5a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z" },
      { d: "M9 7a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z" },
      { d: "M15 7a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z" }
    ],
    "receipt" => [
      { d: "M4 2v20l2-1 2 1 2-1 2 1 2-1 2 1 2-1 2 1V2l-2 1-2-1-2 1-2-1-2 1-2-1-2 1-2-1Z" },
      { d: "M8 8h8" },
      { d: "M8 12h8" },
      { d: "M8 16h5" }
    ],
    "shopping-bag" => [
      { d: "M6 7h12l1 14H5Z" },
      { d: "M9 7a3 3 0 0 1 6 0" }
    ],
    "save" => [
      { d: "M5 3h12l2 2v16H5Z" },
      { d: "M8 3v6h8V3" },
      { d: "M8 21v-7h8v7" }
    ],
    "search" => [
      { d: "M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16Z" },
      { d: "m21 21-4.35-4.35" }
    ],
    "send" => [
      { d: "m22 2-7 20-4-9-9-4Z" },
      { d: "M22 2 11 13" }
    ],
    "tag" => [
      { d: "M20.59 13.41 13.42 20.58a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82Z" },
      { d: "M7 7h.01" }
    ],
    "target" => [
      { d: "M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20Z" },
      { d: "M12 18a6 6 0 1 0 0-12 6 6 0 0 0 0 12Z" },
      { d: "M12 14a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z" }
    ],
    "trash" => [
      { d: "M3 6h18" },
      { d: "M8 6V4h8v2" },
      { d: "M19 6l-1 15H6L5 6" },
      { d: "M10 11v6" },
      { d: "M14 11v6" }
    ],
    "utensils" => [
      { d: "M4 3v7" },
      { d: "M8 3v7" },
      { d: "M6 3v19" },
      { d: "M4 10h4" },
      { d: "M16 3a4 4 0 0 1 4 4v4a4 4 0 0 1-4 4Z" },
      { d: "M16 15v7" }
    ],
    "user" => [
      { d: "M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z" },
      { d: "M4 21a8 8 0 0 1 16 0" }
    ],
    "wallet" => [
      { d: "M19 7V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2" },
      { d: "M16 12h6v5h-6a2.5 2.5 0 0 1 0-5Z" },
      { d: "M18 14.5h.01" }
    ]
  }.freeze

  CATEGORY_ICON_BY_NAME = {
    "alimentação" => "utensils",
    "alimentacao" => "utensils",
    "animais de estimação" => "paw",
    "animais de estimacao" => "paw",
    "bônus" => "gift",
    "bonus" => "gift",
    "compras" => "shopping-bag",
    "contas e serviços" => "plug",
    "contas e servicos" => "plug",
    "educação" => "book-open",
    "educacao" => "book-open",
    "freelance" => "briefcase",
    "investimento" => "chart-line",
    "investimentos" => "chart-line",
    "lazer" => "film",
    "moradia" => "home",
    "outras despesas" => "tag",
    "outras receitas" => "circle-dollar",
    "reembolso" => "receipt",
    "salário" => "banknote",
    "salario" => "banknote",
    "saúde" => "heart-pulse",
    "saude" => "heart-pulse",
    "transporte" => "car"
  }.freeze

  ICON_DEFAULT_CLASSES = "h-4 w-4 shrink-0".freeze

  def icon_svg(name, class_name: ICON_DEFAULT_CLASSES, title: nil)
    paths = ICON_PATHS.fetch(name.to_s)
    title_id = title.present? ? "icon-title-#{SecureRandom.hex(4)}" : nil

    content = []
    content << tag.title(title, id: title_id) if title.present?
    content.concat(paths.map { |attrs| tag.path(**attrs) })

    tag.svg(
      safe_join(content),
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "1.8",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: class_name,
      aria: title.present? ? { labelledby: title_id } : { hidden: true }
    )
  end

  def category_icon(category, class_name: ICON_DEFAULT_CLASSES)
    icon_name =
      if category&.credit_card?
        "credit-card"
      else
        CATEGORY_ICON_BY_NAME[normalized_category_name(category)] || (category&.income? ? "banknote" : "tag")
      end

    icon_svg(icon_name, class_name: class_name)
  end

  def whatsapp_phone_display(phone_number)
    digits = phone_number.to_s.gsub(/\D/, "")
    return phone_number if digits.length < 10

    country = digits.length > 11 ? "+#{digits[0..1]} " : ""
    local = digits.length > 11 ? digits[2..] : digits
    area = local[0..1]
    number = local[2..]
    formatted_number = number.length == 9 ? "#{number[0..4]}-#{number[5..]}" : "#{number[0..3]}-#{number[4..]}"

    "#{country}(#{area}) #{formatted_number}"
  end

  private

  def normalized_category_name(category)
    category&.name.to_s.strip.downcase
  end
end
