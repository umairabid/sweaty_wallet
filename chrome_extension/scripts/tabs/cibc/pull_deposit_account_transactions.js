function getRows(postedHeader) {
  const table = postedHeader.closest("table");
  const tbody = table.querySelector("tbody");
  return tbody.querySelectorAll("tr");
}

function amountInfo(row) {
  const debitSpan = row.querySelector("td.debit span");
  const debit = debitSpan ? debitSpan.innerText.trim() : "Not applicable";
  const credtSpan = row.querySelector("td.credit span");
  const credt = credtSpan ? credtSpan.innerText.trim() : "Not applicable";
  const balance = row.querySelector(".balance span").innerText.trim();
  const type = debit == "Not applicable" ? "credit" : "debit";
  const amount = parseFloat(
    (type == "debit" ? debit : credt).replace(/[^0-9.-]/g, "")
  );
  return { type, amount, balance };
}

function locationDescriptionInfo(transactionsTd) {
  const locationSpan = transactionsTd.querySelector("span.transactionLocation");
  const descriptionSpan = transactionsTd.querySelector(
    "span.transactionDescription"
  );
  const location = locationSpan && locationSpan.innerText.trim();
  const description = descriptionSpan && descriptionSpan.innerText.trim();
  return { location, description };
}

function parseTransaction(row, external_account_id) {
  const dateSpan = row.querySelector("td.date");
  if (!dateSpan) return null;
  const date = dateSpan.innerText.trim();
  const transactionsTd = row.querySelector("td.transactions");
  const { type, amount, balance } = amountInfo(row);
  const { location, description } = locationDescriptionInfo(transactionsTd);
  const id = `${date}-${location}-${description}-${type}-${amount}-${balance}`;
  const secondary_external_id = id.replace(/ /g, "");
  const external_id = secondary_external_id;

  return {
    external_id,
    secondary_external_id,
    external_account_id,
    description: description,
    date,
    type,
    amount,
    external_object: { balance: balance },
  };
}

function scrapTransactions(external_account_id) {
  const postedHeader = document.querySelector("#postedDateHeader");
  const rows = getRows(postedHeader);
  const transactions = [];
  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    const transaction = parseTransaction(row, external_account_id);

    if (transaction) transactions.push(transaction);
  }
  return transactions;
}

export function pullDepositAccountTransacttions(external_account_id) {
  return scrapTransactions(external_account_id);
}
