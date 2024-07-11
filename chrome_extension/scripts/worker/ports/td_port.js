class TdPort {
  constructor() {
    this.message_listener = this.message_listener.bind(this)
    this.on_port_change_callback = () => {}
    this.commands = {
      ping: () => {},
      redirect_to_new_frontend_url: () => {},
      redirect_to_old_frontend_url: () => {},
      redirect_to_credit_card_url: () => {},
      redirect_to_deposit_acc_url: () => {},
      pull_accounts: () => {},
      pull_transactions_credit_card: () => {},
      load_three_month_transactions: () => {},
      pull_transactions_deposit_account: () => {},
    }
  }

  ping() {
    return new Promise((resolve) => {
      if (!this.port) {
        return resolve({ status: "td_not_found" })
      }

      this.execute_command("ping", {}, (response) => {
        if (response.received) {
          resolve({ success: true, status: "found_bank" })
        }
      })
    })
  }

  pull_accounts() {
    return new Promise((resolve) => {
      this.execute_command("redirect_to_new_frontend_url", { url: "https://easyweb.td.com/ui/ew/fs?fsType=PFS" }, () => {
        this.execute_command("pull_accounts", {}, (res) => {
          resolve({
            success: true,
            status: "pulled_accounts",
            accounts: res,
          })
        })
      })
    })
  }

  pull_transactions(params) {
    if (params.type === "credit_card") {
      return this.pull_transactions_credit_card(params)
    }
    return this.pull_transactions_deposit_account(params)
  }

  pull_transactions_credit_card(params) {
    return new Promise((resolve) => {
      this.execute_command(
        "redirect_to_credit_card_url",
        {
          url: this.account_url(params.encrypted_identifier),
        },
        () => {
          setTimeout(() => {
            this.execute_command("pull_transactions_credit_card", params, (res) => {
              resolve({
                success: true,
                identifier: params.identifier,
                status: "pulled_transactions_credit_card",
                transactions: res,
              })
            })
          }, 5000)
        },
      )
    })
  }

  pull_transactions_deposit_account(params) {
    return new Promise((resolve) => {
      console.log('init redirect')
      this.execute_command("redirect_to_deposit_acc_url", { url: this.account_url(params.encrypted_identifier) }, (response) => {
        console.log(response)
        setTimeout(() => {
          if (response.url.startsWith("https://easyweb.td.com/ui/ew/da")) {
            this.execute_command("pull_transactions_deposit_account", params, (res) => {
              resolve({
                success: true,
                status: "pulled_transactions_deposit_account",
                identifier: params.identifier,
                transactions: res,
              })
            })
          } else {
            this.execute_command("redirect_to_deposit_acc_url", { url: this.deposit_account_url_three_month(params.identifier) }, (response) => {
              setTimeout(() => {
                this.execute_command("pull_transactions_deposit_account", params, (res) => {
                  console.log(res)
                  resolve({
                    success: true,
                    status: "pulled_transactions_deposit_account",
                    identifier: params.identifier,
                    transactions: res,
                  })
                })
              }, 3000)
            })
          }
        }, 3000)
      })
    })
  }

  account_url(account_id) {
    return `https://easyweb.td.com/waw/ezw/servlet/TransferInFromNorthStarServlet?ezwTargetRoute=servlet%2Fca.tdbank.banking.servlet.AccountDetailsServlet&accountIdentifier=${account_id}`
  }

  deposit_account_url_three_month(account_id) {
    return `https://easyweb.td.com/waw/ezw/servlet/ca.tdbank.banking.servlet.AccountDetailsServlet?selectedAccount=${account_id}&period=L120&filter=f1&reverse=&xptype=PRXP&requestedPage=0&sortBy=date&sortByOrder=&fromjsp=activity`
  }

  set_port(port) {
    this.port = port
    this.port.onMessage.addListener(this.message_listener)
    this.on_port_change_callback()
    this.on_port_change_callback = () => {}
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

export default TdPort
