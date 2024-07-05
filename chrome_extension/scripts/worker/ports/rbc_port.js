class RbcPort {
  constructor() {
    this.message_listener = this.message_listener.bind(this)
    this.commands = {
      ping: () => {},
      pull_accounts: () => {},
      pull_transactions_credit_card: () => {},
      pull_transactions_deposit_account: () => {},
    }
  }

  ping() {
    return new Promise((resolve) => {
      if (!this.port) {
        return resolve({ status: "rbc_not_found" })
      }

      this.execute_command("ping", {}, (response) => {
        if (response.received) {
          resolve({ success: true, status: "found_rbc" })
        }
      })
    })
  }

  pull_accounts() {
    return new Promise((resolve) => {
      this.execute_command("pull_accounts", {}, (response) => resolve({ success: true, status: "pulled_accounts", accounts: response }))
    })
  }

  pull_transactions(params) {
    return new Promise((resolve) => {
      this.execute_command(
        `pull_transactions_${params.type}`,
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
          })
        },
      )
    })
  }

  set_port(port) {
    this.port = port
    this.port.onMessage.addListener(this.message_listener)
  }

  execute_command(name, params, callback) {
    if (!name || !this.commands[name]) return

    this.commands[name] = callback
    this.port.postMessage({ name, params })
  }

  message_listener(message) {
    const { name } = message
    if (!name || !this.commands[name]) return

    this.commands[name](message.params)
    this.commands[name] = () => {}
  }
}

export default RbcPort
