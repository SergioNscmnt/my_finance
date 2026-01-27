import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    type: String,
    labels: Array,
    datasets: Array,
    axis: String
  }

  connect() {
    if (!window.Chart) return
    this.handleThemeChange = () => this.render(true)
    window.addEventListener("theme:change", this.handleThemeChange)
    this.render()
  }

  disconnect() {
    if (this.handleThemeChange) {
      window.removeEventListener("theme:change", this.handleThemeChange)
    }
    if (this.chart) this.chart.destroy()
  }

  render(force = false) {
    if (force && this.chart) {
      this.chart.destroy()
      this.chart = null
    }

    const ctx = this.element.getContext("2d")

    const indexAxis = this.hasAxisValue ? this.axisValue : "x"
    const valueAxis = indexAxis === "y" ? "x" : "y"
    const isDark = document.documentElement.classList.contains("dark")
    const textColor = isDark ? "#e2e8f0" : "#0f172a"
    const gridColor = isDark ? "rgba(148, 163, 184, 0.2)" : "rgba(148, 163, 184, 0.35)"

    this.chart = new Chart(ctx, {
      type: this.typeValue,
      data: {
        labels: this.labelsValue,
        datasets: this.datasetsValue
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        indexAxis,
        plugins: {
          legend: {
            position: "bottom",
            labels: { color: textColor }
          },
        },
        scales: this.typeValue === "doughnut" ? {} : {
          [valueAxis]: {
            ticks: {
              color: textColor,
              callback: (value) => new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 }).format(value)
            },
            grid: { color: gridColor }
          },
          [indexAxis]: {
            ticks: { color: textColor },
            grid: { color: gridColor }
          }
        }
      }
    })
  }
}
