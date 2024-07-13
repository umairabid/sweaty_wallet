import RbcPort from "./ports/rbc_port.js"
import TdPort from "./ports/td_port.js"
import WalmartMcPort from "./ports/walmart_mc_port.js"

class Ports {
  constructor() {
    this.rbc_port = new RbcPort()
    this.td_port = new TdPort()
    this.walmart_mc_port = new WalmartMcPort()
    this.connect()
  }

  connect() {
    const that = this

    chrome.runtime.onConnect.addListener((port) => {
      that.port_listener(port)
    })
  }

  port_listener(port) {
    if (port.name === "rbc_port") this.rbc_port.set_port(port)
    if (port.name === "td_port") this.td_port.set_port(port)
    if (port.name === "walmart_mc_port") this.walmart_mc_port.set_port(port)
  }

  get_rbc_port() {
    return this.rbc_port
  }

  get_td_port() {
    return this.td_port
  }

  get_walmart_mc_port() {
    return this.walmart_mc_port
  }
}

export default Ports
