import BaseController from "controllers/base_controller"
import create_drawer from "lib/create_drawer"
import * as TomSelectModule from "tom-select"

export default class extends BaseController {
  connect() {
    this.removeBackdrop();
  }

  open_drawer() {
    this.get_drawer().show()
  }

  close_edit_drawer() {
    this.get_drawer().hide()
  }

  get_drawer() {
    if (this.drawer) return this.drawer
    this.drawer = create_drawer(`drawer-transaction-form-${this.transaction_id()}`)
    return this.drawer
  }

  transaction_id() {
    return this.element.dataset.transaction_id
  }

  make_editable(event) {
    event.preventDefault()
    const button = event.currentTarget.closest('button')
    const td = button.parentElement
    const select = td.querySelector('select')
    const form = select.form
    const tom_select =this.get_autocomplete_select(select).enable()
    form.classList.toggle('hidden')
    button.classList.toggle('hidden')
  }

  get_autocomplete_select(select) {
    if (this.autocomplete_select) return this.autocomplete_select     
    this.autocomplete_select = new TomSelect(select)
    return this.autocomplete_select
  }

  update_category(event) {
    const select = event.currentTarget.closest('select')
    const form = select.form
    form.requestSubmit()
  }
}
