import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const form = document.getElementById('new_connector_form');
    form.classList.add('hidden');
  }

  close_modal() {
    this.dispatch('close_modal')
  }
}
