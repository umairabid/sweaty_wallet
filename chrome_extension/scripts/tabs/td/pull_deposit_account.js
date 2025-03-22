function toDate() {
  const today = new Date();
  return today.toISOString().slice(0, 10);
}

function fromDate() {
  const today = new Date();
  const monthsAgo = 3;
  today.setMonth(today.getMonth() - monthsAgo);

  return today.toISOString().slice(0, 10);
}

function mapTransaction(account_id, transaction) {
  const is_debit = !!transaction.withdrawalAmt;
  const date = transaction.date;
  const type = is_debit ? "debit" : "credit";
  const amount = is_debit ? transaction.withdrawalAmt : transaction.depositAmt;
  const description = transaction.description;
  const balance = transaction.accountBalance;
  const secondary_external_id =
    `${date}-${description}-${type}-${amount}-${balance}`.replace(/ /g, "");
  return {
    external_id: transaction.transactionId,
    secondary_external_id: secondary_external_id,
    external_account_id: account_id,
    description: description,
    date: date,
    type: type,
    amount: amount,
    external_object: transaction,
  };
}

function makeRequest(msg) {
  return new Promise((resolve) => {
    function reqListener() {
      const response = JSON.parse(this.responseText);
      const mapTransactionFunc = mapTransaction.bind(
        null,
        msg.params.accountId
      );
      const transactions =
        response.transactionList.transactions.map(mapTransactionFunc);
      resolve(transactions);
    }
    const req = new XMLHttpRequest();
    req.open(
      "POST",
      `https://easyweb.td.com/ms/uainq/v1/accounts/${msg.params.identifier}/transactions`
    );
    req.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    req.setRequestHeader("TraceabilityID", crypto.randomUUID());
    req.setRequestHeader("Messageid", crypto.randomUUID());
    req.setRequestHeader("Originating-App-Name", "RWUI-uf-fs");
    req.setRequestHeader("Originating-App-Version-Num", "1.5.34");
    req.setRequestHeader("TimeStamp", new Date().getTime());
    req.setRequestHeader("Originating-Channel-Name", "EWP");
    req.setRequestHeader("Accept-Secondary-Language", "fr_CA");
    req.addEventListener("load", reqListener);
    req.send(
      JSON.stringify({
        description: "chq/sav_initLoad",
        endDt: toDate(),
        startDt: fromDate(),
      })
    );
  });
}

function parse_description(text) {
  if (text.indexOf("\nView more") !== -1) {
    return text.split("\nView more")[0].replace("View more", "").trim();
  }
  return text;
}

function parse_transaction(row, external_account_id) {
  const tds = row.querySelectorAll("td");
  if (tds.length === 0) return null;

  const date = tds[0] && tds[0].innerText.trim();
  const description = tds[1] && tds[1].innerText.trim();
  const debit = tds[2] && tds[2].innerText.trim();
  const credit = tds[3] && tds[3].innerText.trim();
  const balance = tds[4] && tds[4].innerText.trim();

  if (!date || (!debit && !credit && !balance)) return null;

  const type = debit ? "debit" : "credit";
  const amount = debit || credit;
  const parsed_description = parse_description(description);
  const secondary_external_id = `${date}-${parsed_description}-${type}-${amount}-${balance}`;

  return {
    external_id: secondary_external_id.replace(/ /g, ""),
    secondary_external_id: secondary_external_id.replace(/ /g, ""),
    external_account_id,
    description: parsed_description,
    date,
    type,
    amount,
    external_object: { balance: balance },
  };
}

function parse_transactions(transaction_rows, external_account_id) {
  const transactions = [];
  for (let i = 0; i < transaction_rows.length; i++) {
    const row = transaction_rows[i];
    const transaction = parse_transaction(row, external_account_id);
    if (transaction) transactions.push(transaction);
  }
  return transactions;
}

export function pullDepositAccountFromApi(msg) {
  return makeRequest(msg).then((res) => {
    return {
      name: msg.name,
      params: res,
    };
  });
}

export function pullDepositAccountFromPage(msg) {
  return new Promise((resolve) => {
    const transaction_rows = document.querySelectorAll(
      "#tabcontent1 #content1 table tr"
    );
    const transactions = parse_transactions(
      transaction_rows,
      msg.params.identifier
    );
    resolve({
      name: msg.name,
      params: transactions,
    });
  });
}
