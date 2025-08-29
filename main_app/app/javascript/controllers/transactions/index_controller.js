import BaseController from "controllers/base_controller"
import create_drawer from "lib/create_drawer"
import create_modal from "lib/create_modal"
import { blockingJob } from "lib/blocking_job"
import _ from "lodash"

export default class extends BaseController {
  connect() {
    this.init_search_drawer()
    this.init_columns_modal()
    this.init_new_transaction_drawer()
    this.bindPruneParams()
  }

  bindPruneParams() {
    this.filtersForm = document.getElementById('transactions_search_form')
    this.filtersForm.addEventListener('submit', this.pruneFilters.bind(this))
    this.columnsForm = document.getElementById('select_columns_form')
    this.columnsForm.addEventListener('submit', this.pruneColumns.bind(this))
  }

  open_search() {
    this.advance_search_drawer.show()
  }

  close_search() {
    this.advance_search_drawer.hide()
  }

  init_search_drawer() {
    this.advance_search_drawer = create_drawer(`advance_search_drawer`)
  }

  init_columns_modal() {
    this.columns_modal = create_modal("select_columns_modal");
  }

  init_new_transaction_drawer() {
    this.new_transaction_drawer = create_drawer(`new_transaction_drawer`);
  }

  close_columns_modal() {
    this.columns_modal.hide()
  }

  open_columns_modal() {
    this.columns_modal.show()
  }

  open_add_drawer() {
    this.new_transaction_drawer.show()
  }

  close_add_drawer() {
    this.new_transaction_drawer.hide()
  }

  suggest_categories(event) {
    event.preventDefault()
    const button = event.currentTarget.closest('button')
    const url = button.dataset.action_url
    const ids = this.extractTransactionRowIdsByClass()
    const promise = blockingJob({ url, params: { ids } })
    promise.then(result => {
      const currentUrl = new URL(window.location.href);
      currentUrl.searchParams.append('with_suggestions', 1)
      Turbo.visit(currentUrl.toString())
    })
  }

  extractTransactionRowIdsByClass() {
    const ids = [];
    const elements = document.querySelectorAll('.transaction_row');

    elements.forEach(element => {
      const id = element.id;
      if (id.startsWith('transaction_row_')) {
        const numericalPart = id.substring('transaction_row_'.length);
        const numericalId = parseInt(numericalPart, 10);

        if (!isNaN(numericalId)) {
          ids.push(numericalId);
        }
      }
    });

    return ids;
  }

  pruneFilters(event) {
    for (let i = 0; i < this.filtersForm.elements.length; i++) {
      const element = this.filtersForm.elements[i];

      if (element.name == 'filter[show_duplicates]' && element.type.value == 'hidden') {
        element.disabled = true
      } else if (element.value == '' || element.value == 0) {
        element.disabled = true;
      }
    }
  }

  pruneColumns(event) {
    const selectedColumns = []
    const regex = /\[columns]\[(.+)\]/
    for (let i = 0; i < this.columnsForm.elements.length; i++) {
      const element = this.columnsForm.elements[i];
      if (element.checked == true) {
        const column_name = element.name.match(regex)[1]
        selectedColumns.push(column_name)
      }
    }

    const isDefault = _.isEqual(selectedColumns, window.APP_CONSTANTS.DEFAULT_TRANSACTION_COLUMNS)
    for (let i = 0; i < this.columnsForm.elements.length; i++) {
      const element = this.columnsForm.elements[i];
      if (regex.test(element.name) == false) {
        continue
      }
      const column_name = element.name.match(regex)[1]
      if (isDefault) {
        element.disabled = true
      } else if (_.indexOf(selectedColumns, column_name) == -1) {
        element.disabled = true
      }
    }
  }

}
