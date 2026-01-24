import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ["select"];
  
  connect() {
    $(this.selectTarget).on('select2:select', function () {
      let event = new Event('change', { bubbles: true }) // fire a native event
      this.dispatchEvent(event);
    });
  }

  update(event) {
    console.log("UPDATE");
  }
}