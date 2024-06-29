import RbcPort from "./ports/rbc_port.js";
import TdPort from "./ports/td_port.js";

class Ports {
  constructor() {
    this.rbc_port = new RbcPort();
    this.td_port = new TdPort();
    this.connect();
  }

  connect() {
    var that = this;
    chrome.runtime.onConnect.addListener(function (port) {
      that.port_listener(port);
    });
  }

  port_listener(port) {
    if (port.name == "rbc_port") this.rbc_port.set_port(port);
    if (port.name == "td_port") this.td_port.set_port(port);
  }

  get_rbc_port() {
    return this.rbc_port;
  }

  get_td_port() {
    return this.td_port;
  }
}

export default Ports
