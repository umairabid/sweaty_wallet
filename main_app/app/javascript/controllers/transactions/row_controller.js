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
    this.toggle_category_form(td)
  }

  get_autocomplete_select(select) {
    if (this.autocomplete_select) return this.autocomplete_select     

    const td = select.closest('td')
    this.autocomplete_select = new TomSelect(select, {
      onBlur: () => {
        this.toggle_category_form(td)
      },
    })
    return this.autocomplete_select
  }

  toggle_category_form(td) {
    const select = td.querySelector('select')
    const tom_select = this.get_autocomplete_select(select)
    const form = select.form
    const button = td.querySelector('button')
    if (form.classList.contains('hidden')) {
      tom_select.enable()
      tom_select.focus()
    } else {
      this.get_autocomplete_select(select).disable()
    }
    form.classList.toggle('hidden')
    button.classList.toggle('hidden')
  }
    

  update_category(event) {
    const select = event.currentTarget.closest('select')
    const form = select.form
    form.requestSubmit()
  }
}
