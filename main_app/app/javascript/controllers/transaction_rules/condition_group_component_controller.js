import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.group_id = this.element.dataset.group_id
  }

  add_rule(e) {
    const elem = e.target
    const form = document.getElementById(`conditions-group-form-${this.group_id}`)
    elem.classList.toggle("hidden")
    form.classList.toggle("hidden")
  }

  display_value_field(e) {
    const elems = document.getElementsByClassName("condition-value")
    for (let i = 0; i < elems.length; i++) {
      elems[i].classList.add("hidden")
    }
    this.value_type = e.target.value
    if (this.value_type !== "group") {
      const form = document.getElementById(`conditions-group-form-${this.group_id}`)
      const elem = form.querySelector(`#condition_${this.value_type}`)
      elem.classList.toggle("hidden")
    } else {
      document.getElementById(`save-condition-${this.group_id}`).classList.remove("hidden")
    }
  }

  validate_value(e) {
    const value = e.target.value
    const elements = value.split(",").map((item) => item.trim())
    const nonEmptyElements = elements.filter((item) => item.length > 0)
    const is_valid = nonEmptyElements.length > 0
    const elem = document.getElementById(`save-condition-${this.group_id}`)
    if (is_valid) {
      elem.classList.remove("hidden")
    } else {
      elem.classList.add("hidden")
    }
  }

  dismiss_form(e) {
    const form = document.getElementById(`conditions-group-form-${this.group_id}`)
    form.classList.add("hidden")
    const elem = document.getElementById(`conditions-group-button-${this.group_id}`)
    elem.classList.remove("hidden")
  }
}
