class ConnectorExtension {
  constructor(opts = {}) {
    this.extension_id = opts.extension_id;
    this.handle_success = opts.handle_success;
    this.handle_error = opts.handle_error;
    this.bank = opts.bank;
    this.ping_extension = this.ping_extension.bind(this);
    this.connect_with_bank = this.connect_with_bank.bind(this);
    this.pull_accounts = this.pull_accounts.bind(this);
    this.pull_transactions = this.pull_transactions.bind(this);
  }

  pull_bank() {
    return this.is_connected()
      .then(this.ping_extension)
      .then(this.connect_with_bank)
      .then(this.pull_accounts)
      .then(this.pull_transactions)
      .catch(() => {});
  }

  connect_with_bank() {
    return this.send_message_with_response_timeout({
      message: 'ping',
      bank: this.bank,
    })
      .then(this.handle_success)
      .catch((data) => {
        if (data.status === 'message_failed' || data.status === 'unable_to_reach_extension') {
          this.handle_error({
            status: `${this.bank}_not_found`,
          });
        }
      });
  }

  pull_accounts() {
    return this.send_message_with_response_timeout({
      message: 'pull_accounts',
      bank: this.bank,
    })
      .then(this.handle_success)
      .catch(this.handle_error);
  }

  ping_extension() {
    return this.ping().then(this.handle_success).catch(this.handle_error);
  }

  pull_transactions(response) {
    const transactions = {};
    const accounts_with_transactions = response.accounts.filter((a) => ['credit_card', 'deposit_account'].includes(a.type));
    const promises = accounts_with_transactions.map((a) => {
      const message = {
        message: 'pull_transactions',
        bank: this.bank,
        params: {
          type: a.type,
          identifier: a.external_id,
          encrypted_identifier: a.encrypted_external_id,
        },
      };
      return this.send_message_with_response_timeout.bind(this, message);
    });
    let promiseChain = Promise.resolve(); // Start with a resolved promise
    promises.forEach((promise) => {
      promiseChain = promiseChain.then(() =>
        this.wrap_promise_in_delay(promise, 10000).then((res) => {
          transactions[res.identifier] = res.transactions;
        }),
      );
    });

    return promiseChain
      .then(() =>
        response.accounts.map((account) => {
          const finalAccount = { ...account };
          finalAccount.transactions = transactions[account.external_id] || [];
          return finalAccount;
        }),
      )
      .catch(this.handle_error);
  }

  wrap_promise_in_delay(promise, delayTime) {
    return new Promise((resolve, reject) => {
      promise()
        .then((result) => {
          this.delay(delayTime).then(() => resolve(result)); // Schedule next execution after delay
        })
        .catch((error) => reject(error)); // Propagate errors
    });
  }

  delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  is_connected() {
    return new Promise((resolve, reject) => {
      if (!chrome) {
        return reject({ status: 'chrome_unavailable' });
      }

      if (!chrome.runtime) {
        return reject({ status: 'no_accessible_extension' });
      }

      return resolve({ status: 'runtime_found' });
    });
  }

  ping() {
    return this.send_message_with_response_timeout({ message: 'ping' })
      .then(() => ({ status: 'installed' }))
      .catch((res) => {
        if (res.status === 'unable_to_reach_extension' || res.status === 'message_failed') throw { status: 'not_installed' };
      });
  }

  send_message_with_response_timeout(message, timeout = 20000) {
    return new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => reject({ status: 'unable_to_reach_extension' }), timeout);
      try {
        chrome.runtime.sendMessage(this.extension_id, message, (response) => {
          clearTimeout(timeoutId);
          if (response.success) {
            return resolve(response);
          }
          return reject({ status: 'message_failed' });
        });
      } catch (err) {
        return reject({ status: 'unable_to_reach_extension' });
      }
    });
  }
}

export default ConnectorExtension;
