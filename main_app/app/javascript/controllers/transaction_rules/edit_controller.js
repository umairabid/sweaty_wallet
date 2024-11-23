import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.rule_dropdown().onchange = (e) => {
      Turbo.visit(`/transaction_rules/${e.target.value}/edit`);
    }
  }

  rule_dropdown() {
    return document.getElementById('transaction_rule_dropdown')
  }
}
