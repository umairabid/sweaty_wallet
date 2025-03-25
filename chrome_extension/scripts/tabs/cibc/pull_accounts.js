function getAccounType(element) {
  const classList = element.classList;
  if (classList.contains("deposit-accounts")) return "deposit_account";
  if (classList.contains("credit-accounts")) return "credit_card";
  if (classList.contains("lending-accounts")) return "lending";
  if (classList.contains("investment-accounts")) return "investment";
}

function extractAccountId(anchor) {
  const url = anchor.attributes.href.value;
  const fragment = url.split("#")[1];
  return fragment.split("/").pop();
}

function extractAccountInfo(type, cardContainer) {
  const accountAnchor = cardContainer.querySelector(".account-name h3 a");
  const external_id = extractAccountId(accountAnchor);
  const name = accountAnchor.querySelector("span").innerHTML;
  const balanceString =
    cardContainer.querySelector(".account-balance p").innerHTML;
  const balance = parseFloat(balanceString.replace(/[^0-9.-]/g, ""));
  return {
    type: type,
    balance: balance,
    account_name: name,
    is_active: true,
    external_id: external_id,
    encrypted_external_id: external_id,
    currency: "CAD",
  };
}

function scrapeAccounts() {
  const accounts = [];
  const accountGroups = document.getElementsByClassName("account-groups")[0];

  for (let i = 0; i < accountGroups.children.length; i++) {
    const accountGroup = accountGroups.children[i];
    const type = getAccounType(accountGroup);
    const cardContainers = accountGroup.querySelectorAll(".card-container");
    for (let i = 0; i < cardContainers.length; i++) {
      const cardContainer = cardContainers[i];
      const accountAnchor = cardContainer.querySelector(".account-name h3 a");

      if (accountAnchor) {
        const accountInfo = extractAccountInfo(
          type,
          cardContainer,
          accountAnchor
        );
        accounts.push(accountInfo);
      }
    }
  }
  return accounts;
}

export function pullAccounts() {
  return scrapeAccounts();
}
