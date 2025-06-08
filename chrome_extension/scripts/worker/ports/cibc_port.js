export default class CibcPort {
  constructor() {
    this.message_listener = this.message_listener.bind(this);
    this.on_port_change_callback = () => {};
    this.commands = {
      ping: () => {},
      pull_accounts: () => {},
      pull_transactions_credit_card: () => {},
      pull_transactions_deposit_account: () => {},

      redirect_to_credit_card_url: () => {},
      redirect_to_deposit_acc_url: () => {},
    };
  }

  ping() {
    return new Promise((resolve) => {
      if (!this.port) {
        return resolve({ status: "cibc_not_found" });
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
      this.execute_command("pull_accounts", {}, (response) =>
        resolve({
          success: true,
          status: "pulled_accounts",
          accounts: response,
        })
      );
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
    console.log("redirecting to credit card");
    return new Promise((resolve) => {
      this.execute_command(
        "redirect_to_credit_card_url",
        { url: this.credit_card_url(params.encrypted_identifier) },
        () => {
          console.log("credit card redirect received");
          setTimeout(() => {
            this.execute_command(
              "pull_transactions_credit_card",
              {},
              (response) =>
                resolve({
                  success: true,
                  status: "pulled_transactions_credit_card",
                  identifier: params.identifier,
                  transactions: response,
                })
            );
          }, 5000);
        }
      );
    });
  }

  pull_transactions_deposit_account(params) {
    console.log("pulling transactions for deposit account");
    return new Promise((resolve) => {
      this.execute_command(
        "redirect_to_deposit_acc_url",
        { url: this.deposit_account_url(params.encrypted_identifier) },
        () => {
          setTimeout(() => {
            this.execute_command(
              "pull_transactions_deposit_account",
              {},
              (response) =>
                resolve({
                  success: true,
                  status: "pulled_transactions_deposit_account",
                  identifier: params.identifier,
                  transactions: response,
                })
            );
          }, 5000);
        }
      );
    });
  }

  credit_card_url(id) {
    return `https://www.cibconline.cibc.com/ebm-resources/public/banking/cibc/client/web/index.html#/accounts/credit-cards/${id}`;
  }

  deposit_account_url(id) {
    return `https://www.cibconline.cibc.com/ebm-resources/public/banking/cibc/client/web/index.html#/accounts/deposits/${id}`;
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
