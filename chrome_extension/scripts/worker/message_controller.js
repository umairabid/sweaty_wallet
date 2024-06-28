import Ports from "./ports.js";

class MessageController {
  constructor() {
    this.listener = this.listener.bind(this);
    this.ports = new Ports();
    chrome.runtime.onMessageExternal.addListener(this.listener);
  }

  listener(request, sender, sendResponse) {
    console.log(request);
    const bank = request.bank;
    const message = request.message;

    let handler = null;

    if (bank) {
      const port = this.get_bank_port(bank);
      handler = port[message].bind(port)
    } else {
      handler = this[message].bind(this)
    }

    handler(request.params)
      .then(res => sendResponse(res))
  }

  get_bank_port(bank) {
    if (bank == 'rbc') return this.ports.get_rbc_port();
  }

  ping() {
    return Promise.resolve({ success: true })
  }
}

export default MessageController
