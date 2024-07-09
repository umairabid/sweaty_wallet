function mapTransaction(account_id, transaction) {
  const is_debit = !!transaction.debit
  return {
    external_id: transaction.transactionId,
    external_account_id: account_id,
    description: transaction.transactionDesc,
    date: transaction.transactionDt,
    type: is_debit ? "debit" : "credit",
    amount: is_debit ? transaction.debit.amt : transaction.credit.amt,
  }
}

function creditCardTransactionPromise(accountId, cycle) {
  return new Promise((resolve) => {
    function reqCreditCardListener() {
      const response = JSON.parse(this.responseText)
      const mapTransactionFunc = mapTransaction.bind(null, accountId)
      const transactions = response.transactions.posted.map(mapTransactionFunc)
      resolve(transactions)
    }
    

    const req = new XMLHttpRequest()
    req.open("GET", `https://easyweb.td.com/waw/api/account/creditcard/transactions?accountKey=${accountId}&cycleId=${cycle}`)
    req.addEventListener("load", reqCreditCardListener)
    req.send()
  })
}

export default function pullCreditCardAccount(msg) {
  const promises = [
    creditCardTransactionPromise(msg.params.identifier, 0),
    creditCardTransactionPromise(msg.params.identifier, 1),
    creditCardTransactionPromise(msg.params.identifier, 2),
  ]
  return Promise.all(promises).then((res) => {
    return {
      name: msg.name,
      params: res.flat(),
    }
  })
}
