import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {

  }

  add_rule(e) {
    const parent = e.target.dataset.parent
    const parent_container = this.condition_rule_container(parent)
    console.log(parent_container)
    parent_container.appendChild(this.create_condition_form())
  }

  condition_rule_container(parent) {
    const cId = `condition-container-${parent}`
    let container = document.getElementById(cId)
    if (!container) {
      container = document.createElement('div')
      container.id = cId
      this.conditions_area_elem().appendChild(container)
    }
    return container
  }

  conditions_area_elem() {
    if (!this.conditions_area) {
      this.conditions_area = document.getElementById('conditions-area')
    }
    return this.conditions_area
  }

  create_condition_form() {
    const template = document.getElementById('accordion-collapse')
    const condition_form = template.cloneNode(true)
    condition_form.id = 'rule-1'
    condition_form.classList.remove('hidden')
    return condition_form
  }
}
