class TdPort {
  constructor() {
    this.message_listener = this.message_listener.bind(this);
    this.on_port_change_callback = () => {};
    this.commands = {
      ping: () => {},
      pull_accounts: () => {},
      pull_tranactions_credit_card: () => {},
      pull_tranactions_deposit_account: () => {},
    };
  }

  ping() {
    return new Promise((resolve) => {
      if (!this.port) {
        return resolve({ status: "td_not_found" });
      }

      this.execute_command("ping", {}, (response) => {
        if (response.received) {
          resolve({ success: true, status: "td_found" });
        }
      });
    });
  }

  pull_accounts() {
    return new Promise((resolve) => {
      if (!this.is_connected_with_new_frontend()) {
        this.on_port_change_callback = this.pull_accounts;
        console.log("issuing redirect");
        this.execute_internal_command("redirect_to_new_frontend", {}, () => {
          this.execute_command("pull_accounts", {}, (res) => {
            console.log(res);
          });
        });
      } else {
        this.execute_command("pull_accounts", {}, (res) => {
          console.log(res);
        });
      }
    });
  }

  pull_transactions(params) {
    return new Promise((resolve) => {
      this.execute_command(
        `pull_tranactions_${params.type}`,
        {
          encrypted_identifier: params.encrypted_identifier,
          identifier: params.identifier,
        },
        (response) => {
          resolve({
            success: true,
            status: `pulled_transactions_for_${params.type}`,
            identifier: params.identifier,
            transactions: response,
          });
        }
      );
    });
  }

  is_connected_with_new_frontend() {
    if (this.port == null) return false;

    return this.port.sender.url.startsWith("https://easyweb.td.com/ui/ew/fs");
  }

  set_port(port) {
    console.log(port);
    this.port = port;
    this.port.onMessage.addListener(this.message_listener);
    this.on_port_change_callback();
    this.on_port_change_callback = () => {};
  }

  execute_internal_command(name, params, callback) {
    this.commands[name] = callback;
    this.port.postMessage({ name: name, params: params });
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

export default TdPort;
