export default class ExamplePort {
  constructor() {
    this.message_listener = this.message_listener.bind(this);
    this.on_port_change_callback = () => {};
    this.commands = {
      ping: () => {},
      pull_accounts: () => {},
      pull_transactions_credit_card: () => {},
      pull_transactions_deposit_account: () => {},
      
      redirect_to_accounts_page: () => {},
      redirect_to_credit_card_url: () => {},
      redirect_to_deposit_acc_url: () => {},
    };
  }

  ping() {
    return new Promise((resolve) => {
      if (!this.port) {
        return resolve({ status: "example_not_found" });
      }

      this.execute_command("ping", {}, (response) => {
        if (response.received) {
          resolve({ success: true, status: "found_bank" });
        }
      });
    });
  }

  pull_accounts() {
    return new Promise((resolve) => {
      this.execute_command("redirect_to_accounts_page", { url: "https://app.sweatywallet.ca/example_banks" }, () => {
        this.execute_command("pull_accounts", {}, (response) =>
          resolve({
            success: true,
            status: "pulled_accounts",
            accounts: response,
          })
        );
      });
    });
  }

  pull_transactions(params) {
    console.log(params);
    if (params.type === "credit_card") {
      return this.pull_transactions_credit_card(params);
    }
    return this.pull_transactions_deposit_account(params);
  }

  pull_transactions_credit_card(params) {
    return new Promise((resolve) => {
      this.execute_command(
        "redirect_to_credit_card_url",
        { url: this.credit_card_url(params.encrypted_identifier) },
        () => {
          setTimeout(() => {
            this.execute_command(
              "pull_transactions_credit_card",
              { encrypted_identifier: params.encrypted_identifier },
              (response) =>
              resolve({
                identifier: params.identifier,
                success: true,
                status: "pulled_transactions",
                transactions: response,
              })
            );
          }, 2000);
        }
      );
    });
  }

  pull_transactions_deposit_account(params) {
    return new Promise((resolve) => {
      this.execute_command(
        "redirect_to_deposit_acc_url",
        { url: this.deposit_acc_url(params.encrypted_identifier) },
        () => {
          setTimeout(() => {
            this.execute_command(
              "pull_transactions_deposit_account",
              { encrypted_identifier: params.encrypted_identifier },
              (response) =>
              resolve({
                identifier: params.identifier,
                success: true,
                status: "pulled_transactions",
                transactions: response,
              })
            );
          }, 2000);
        }
      );
    });
  }

  credit_card_url(encrypted_identifier) {
    return `https://app.sweatywallet.ca/example_banks/${encrypted_identifier}`;
  }

  deposit_acc_url(encrypted_identifier) {
    return `https://app.sweatywallet.ca/example_banks/${encrypted_identifier}`;
  }

  set_port(port) {
    this.port = port;
    this.port.onMessage.addListener(this.message_listener);
    this.on_port_change_callback();
    this.on_port_change_callback = () => {};
  }

  execute_command(name, params, callback) {
    if (!name || !this.commands[name]) return;

    this.commands[name] = callback;
    this.port.postMessage({ name, params });
  }

  message_listener(message) {
    const { name } = message;
    if (!name || !this.commands[name]) return;

    this.commands[name](message.params);
    this.commands[name] = () => {};
  }
}
