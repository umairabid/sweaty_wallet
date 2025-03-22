function getRows(postedHeader) {
  const table = postedHeader.closest("table");
  const tbody = table.querySelector("tbody");
  return tbody.querySelectorAll("tr");
}

function amountInfo(row) {
  const debit = row.querySelector(".debit span").innerText.trim();
  const credt = row.querySelector(".credit span").innerText.trim();
  const balance = row.querySelector(".balance span").innerText.trim();
  const type = debit == "Not applicable" ? "credit" : "debit";
  const amount = parseFloat(
    (type == "debit" ? debit : credt).replace(/[^0-9.-]/g, "")
  );
  return { type, amount, balance };
}

function locationDescriptionInfo(transactionsTd) {
  const location = transactionsTd
    .querySelector("span.transactionLocation")
    .innerText.trim();
  const description = transactionsTd
    .querySelector("span.transactionDescription")
    .innerText.trim();
  return { location, description };
}

function parseTransaction(row) {
  const date = row.querySelector("td.date").innerText.trim();
  const transactionsTd = row.querySelector("td.transactions");
  const { type, amount, balance } = amountInfo(row);
  const { location, description } = locationDescriptionInfo(transactionsTd);
  const id = `${date}-${location}-${description}-${type}-${amount}-${balance}`;
  const secondary_external_id = id.replace(/ /g, "");
  const external_id = secondary_external_id;
  const is_credit = type == "credit";

  return { date, description, amount, balance };
}

function scrapTransactions() {
  const postedHeader = document.querySelector("#postedDateHeader");
  const rows = getRows(postedHeader);
  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    const transaction = parseTransaction(row);
    console.log(transaction);
  }
}

export function pullCreditCardTransacttions() {
  const transactions = scrapTransactions();
}
