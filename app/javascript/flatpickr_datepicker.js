export default class FlatpickrDatepicker {
  constructor(options = {}) {
    this.selectors = options.selectors || []
    this.config = options.config || {}
  }

  init(root = document) {
    if (!window.flatpickr) return

    this.selectors.forEach((selector) => {
      this.findElements(root, selector).forEach((element) => this.mount(element))
    })
  }

  findElements(root, selector) {
    const elements = []

    if (root instanceof Element && root.matches(selector)) {
      elements.push(root)
    }

    root.querySelectorAll(selector).forEach((element) => elements.push(element))
    return elements
  }

  mount(element) {
    if (!element || element._flatpickr) return

    window.flatpickr(element, {
      ...this.config,
      altInputClass: element.className
    })
  }
}
