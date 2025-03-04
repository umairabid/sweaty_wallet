import BaseController from "controllers/base_controller"

export default class extends BaseController {
  connect() {
    this.date_dropdown().onchange = (e) => {
      Turbo.visit(`/?date=${e.target.value}`);
    }
  }

  date_dropdown() {
    return document.getElementById('dashboard_dates_dropdown')
  }
}
