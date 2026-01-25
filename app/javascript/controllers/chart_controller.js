import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    type: String,
    labels: Array,
    datasets: Array
  }

  connect() {
    if (!window.Chart) return
    this.render()
  }

  disconnect() {
    if (this.chart) this.chart.destroy()
  }

  render() {
    const ctx = this.element.getContext("2d")
    this.chart = new Chart(ctx, {
      type: this.typeValue,
      data: {
        labels: this.labelsValue,
        datasets: this.datasetsValue
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: "bottom" },
        },
        scales: this.typeValue === "doughnut" ? {} : {
          y: { ticks: { callback: (value) => new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 }).format(value) } }
        }
      }
    })
  }
}
