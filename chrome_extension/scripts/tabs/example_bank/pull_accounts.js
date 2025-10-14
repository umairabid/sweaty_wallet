function getAccountType(element) {
  const classList = element.classList;
  if (classList.contains("deposit-accounts")) return "deposit_account";
  if (classList.contains("credit-accounts")) return "credit_card";
  if (classList.contains("lending-accounts")) return "lending";
  if (classList.contains("investment-accounts")) return "investment";
}

function extractAccountInfo(type, cardContainer) {
  const external_id = cardContainer.getAttribute("data-account-id");
  const nameElement = cardContainer.querySelector(".account-name h3 span");
  const name = nameElement ? nameElement.textContent.trim() : "";
  const balanceElement = cardContainer.querySelector(".account-balance p");
  const balanceString = balanceElement ? balanceElement.textContent : "$0.00";
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

  console.log("Account groups container:", accountGroups);

  if (!accountGroups) {
    console.error("Account groups container not found");
    return accounts;
  }

  for (let i = 0; i < accountGroups.children.length; i++) {
    const accountGroup = accountGroups.children[i];
    console.log("Processing account group:", accountGroup);
    const type = getAccountType(accountGroup);

    if (!type) continue;

    const cardContainers = accountGroup.querySelectorAll(".card-container");

    for (let j = 0; j < cardContainers.length; j++) {
      const cardContainer = cardContainers[j];
      const accountId = cardContainer.getAttribute("data-account-id");

      if (accountId) {
        const accountInfo = extractAccountInfo(type, cardContainer);
        accounts.push(accountInfo);
      }
    }
  }

  return accounts;
}

export function pullAccounts() {
  return scrapeAccounts();
}
