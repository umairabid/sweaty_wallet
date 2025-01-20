import BaseController from "../base_controller"

export default class extends BaseController {
  connect() {
    this.rule_dropdown().onchange = (e) => {
      Turbo.visit(`/transaction_rules/${e.target.value}/edit`);
    }
  }

  rule_dropdown() {
    return document.getElementById('transaction_rule_dropdown')
  }
}
