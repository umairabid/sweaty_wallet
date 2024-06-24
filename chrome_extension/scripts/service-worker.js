class RbcPort {
  constructor(port) {
    this.port = port;
    this.message_listener = this.message_listener.bind(this);
    this.port.onMessage.addListener(this.message_listener);
    this.commands = {
      ping: () => {},
      pull_accounts: () => {},
      pull_tranactions_credit_card: () => {},
      pull_tranactions_deposit_account: () => {}
    };
  }

  execute_command(name, params, callback) {
    if (!name || !this.commands[name]) return;

    this.commands[name] = callback;
    this.port.postMessage({ name: name, params: params });
  }

  message_listener(message) {
    const name = message.name;
    if (!name || !this.commands[name]) return;

    this.commands[name](message.params);
  }
}

class Ports {
  constructor() {
    this.rbc_port = null;
    this.td_port = null;
    this.connect();
  }

  connect() {
    var that = this;
    chrome.runtime.onConnect.addListener(function (port) {
      that.port_listener(port);
    });
  }

  port_listener(port) {
    if (port.name == "rbc_port") this.rbc_port = new RbcPort(port);
    if (port.name == "td_port") this.td_port = port;
  }

  get_rbc_port() {
    return this.rbc_port;
  }
}

const ports = new Ports();

chrome.runtime.onMessageExternal.addListener(function (
  request,
  sender,
  sendResponse
) {
  console.log(request);
  if (request.message == "ping") {
    sendResponse({ success: true });
  } else if (request.message == "ping_rbc") {
    const rbc_port = ports.get_rbc_port();
    if (!rbc_port) {
      sendResponse({ status: "rbc_not_found" });
      return;
    }
    rbc_port.execute_command(
      "ping",
      { message: "are you alive" },
      (response) => {
        if (response.received) {
          sendResponse({ success: true, status: "found_rbc" });
          return;
        }
      }
    );
  } else if (request.message == "pull_accounts_rbc") {
    const rbc_port = ports.get_rbc_port();
    rbc_port.execute_command("pull_accounts", {}, (response) => {
      sendResponse({
        success: true,
        status: 'pulled_accounts',
        accounts: response,
      });
    });
  } else if (request.message == "pull_transactions_rbc") {
    console.log('pulling transactions')
    const rbc_port = ports.get_rbc_port();
    rbc_port.execute_command(
      `pull_tranactions_${request.type}`,
      { encrypted_identifier: request.encrypted_identifier },
      (response) => {
        sendResponse({
          success: true,
          status: `pulled_transactions_for_${request.type}`,
          external_id: request.identifier,
          transactions: response,
        });
      }
    );
    /**
     * sendResponse({
      success: true,
      status: `pulled_transactions_for_${request.type}`,
      external_id: request.identifier,
      transactions: [{id: 1}],
    });
     */
  }
});
