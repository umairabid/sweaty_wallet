class ConnectorExtension {
  constructor(opts = {}) {
    this.extension_id = opts.extension_id
    this.handle_success = opts.handle_success
    this.handle_error = opts.handle_error
    this.bank = opts.bank
    this.ping_extension = this.ping_extension.bind(this)
    this.connect_with_bank = this.connect_with_bank.bind(this)
    this.pull_accounts = this.pull_accounts.bind(this)
    this.pull_transactions = this.pull_transactions.bind(this)
  }

  pull_bank(bank) {
    return this.is_connected()
      .then(this.ping_extension)
      .then(this.connect_with_bank)
      .then(this.pull_accounts)
      .then(this.pull_transactions)
      .then((res) => {
        if (!res.success) {
          return res
        }
        return fetch("/accounts/import", {
          method: "POST",
          body: JSON.stringify({
            bank: bank,
            accounts: res.final_accounts,
          }),
          headers: {
            "Content-Type": "application/json",
          },
        })
        .then((res) => {
          return new Response(res.body).json().then((body) => {
            if (body.job_id) {
              return { success: true, status: "synced_accounts" }
            } else {
              return { success: false, status: "sync_failed" }
            }
          })
        })
      })
      .catch(() => {})
  }

  is_connected() {
    this.handle_success({ success: true, status: "initiating" })
    return new Promise((resolve, reject) => {
      if (!chrome) {
        return reject({ success: false, status: "chrome_unavailable" })
      }

      if (!chrome.runtime) {
        return reject({ success: false, status: "no_accessible_extension" })
      }

      const res = { success: true, status: "runtime_found" }
      this.handle_success(res)
      return resolve(res)
    })
  }

  ping_extension(res) {
    if (res.success) {
      return this.send_message_with_response_timeout({ message: "ping" }).then((res) => {
        if (res.success) {
          this.handle_success({ success: true, status: "installed" })
          return res
        } else {
          return { success: false, status: "unable_to_reach_extension" }
        }
      })
    } else {
      return res
    }
  }

  connect_with_bank(res) {
    if (res.success) {
      return this.send_message_with_response_timeout({
        message: "ping",
        bank: this.bank,
      })
        .then((res) => {
          if (res.success) {
            this.handle_success(res)
            return res
          } else {
            return { status: `bank_not_found`, success: false }
          }
        })
        .catch(() => {
          return { success: false, status: "bank_not_found" }
        })
    } else {
      return res
    }
  }

  pull_accounts(res) {
    if (res.success) {
      return this.send_message_with_response_timeout({
        message: "pull_accounts",
        bank: this.bank,
      })
        .then((res) => {
          if (res.success) {
            this.handle_success(res)
            return res
          } else {
            return { success: false, status: "pull_accounts_fail" }
          }
        })
        .catch(() => {
          return { success: false, status: "pull_accounts_fail" }
        })
    } else {
      return res
    }
  }

  pull_transactions(res) {
    if (res.success) {
      const transactions = {}
      const accounts_with_transactions = res.accounts.filter((a) => ["credit_card", "deposit_account"].includes(a.type))
      const promises = accounts_with_transactions.map((a) => {
        const message = {
          message: "pull_transactions",
          bank: this.bank,
          params: {
            type: a.type,
            identifier: a.external_id,
            encrypted_identifier: a.encrypted_external_id,
          },
        }
        return this.send_message_with_response_timeout.bind(this, message)
      })
      let promiseChain = Promise.resolve() // Start with a resolved promise
      promises.forEach((promise) => {
        promiseChain = promiseChain.then(() =>
          this.wrap_promise_in_delay(promise, 10000).then((res) => {
            transactions[res.identifier] = res.transactions
          }),
        )
      })

      return promiseChain
        .then(() => {
          const final_accounts = res.accounts.map((account) => {
            const final_account = { ...account }
            final_account.transactions = transactions[account.external_id] || []
            return final_account
          })
          const trans_res = { success: true, status: "pulled_transactions", final_accounts: final_accounts }
          this.handle_success(trans_res)
          return trans_res
        })
        .catch((res) => {
          return { success: false, status: "pull_transactions_fail" }
        })
    } else {
      return res
    }
  }

  wrap_promise_in_delay(promise, delayTime) {
    return new Promise((resolve, reject) => {
      promise()
        .then((result) => {
          this.delay(delayTime).then(() => resolve(result)) // Schedule next execution after delay
        })
        .catch((error) => reject(error)) // Propagate errors
    })
  }

  delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
  }

  send_message_with_response_timeout(message, timeout = 20000) {
    return new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => reject({ status: "unable_to_reach_extension" }), timeout)
      try {
        chrome.runtime.sendMessage(this.extension_id, message, (response) => {
          clearTimeout(timeoutId)
          if (response.success) {
            return resolve(response)
          }
          return reject({ success: false, status: "message_failed" })
        })
      } catch (err) {
        return reject({ success: false, status: "unable_to_reach_extension" })
      }
    })
  }
}

export default ConnectorExtension
