function toDate() {
  const today = new Date()
  return today.toISOString().slice(0, 10)
}

function fromDate() {
  const today = new Date()
  const monthsAgo = 3
  today.setMonth(today.getMonth() - monthsAgo)

  return today.toISOString().slice(0, 10)
}

function mapTransaction(account_id, transaction) {
  const is_debit = !!transaction.withdrawalAmt
  return {
    external_id: transaction.transactionId,
    external_account_id: account_id,
    description: transaction.description,
    date: transaction.date,
    type: is_debit ? "debit" : "credit",
    amount: is_debit ? transaction.withdrawalAmt : transaction.depositAmt,
  }
}

function makeRequest(msg) {
  return new Promise((resolve) => {
    function reqListener() {
      const response = JSON.parse(this.responseText)
      const mapTransactionFunc = mapTransaction.bind(null, msg.params.accountId)
      const transactions = response.transactionList.transactions.map(mapTransactionFunc)
      resolve(transactions)
    }
    const req = new XMLHttpRequest()
    req.open("POST", `https://easyweb.td.com/ms/uainq/v1/accounts/${msg.params.identifier}/transactions`)
    req.setRequestHeader("Content-Type", "application/json;charset=UTF-8")
    req.setRequestHeader("TraceabilityID", crypto.randomUUID())
    req.setRequestHeader("Messageid", crypto.randomUUID())
    req.setRequestHeader("Originating-App-Name", "RWUI-uf-fs")
    req.setRequestHeader("Originating-App-Version-Num", "1.5.34")
    req.setRequestHeader("TimeStamp", new Date().getTime())
    req.setRequestHeader("Originating-Channel-Name", "EWP")
    req.setRequestHeader("Accept-Secondary-Language", "fr_CA")
    req.addEventListener("load", reqListener)
    req.send(
      JSON.stringify({
        description: "chq/sav_initLoad",
        endDt: toDate(),
        startDt: fromDate(),
      }),
    )
  })
}

export default function pullDepositAccount(msg) {
  return makeRequest(msg).then((res) => {
    return {
      name: msg.name,
      params: res,
    }
  })
}
