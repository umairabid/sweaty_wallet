require "factory_bot_rails"

class Seeds::NewTestUser
  include Callable

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    User.transaction do
      user = FactoryBot.create(:user, email: @email, password: @password)
      connector = FactoryBot.create(:connector, user: user)
      deposit_account = FactoryBot.create(:account, connector: connector)
      credit_card = FactoryBot.create(:account,
                                      name: "Credit Card Account",
                                      connector: connector,
                                      account_type: "credit_card",
                                      external_id: "credit_card_external_id",
                                      balance: 432.45)

      dates = ((Date.today - 3.months)..Date.today).to_a
      (10001..10750).each do |i|
        FactoryBot.create(:transaction,
                          account: credit_card,
                          external_id: i,
                          description: debit_descriptions.sample,
                          date: dates.sample,
                          is_credit: false)
      end
      (10751..11000).each do |i|
        FactoryBot.create(:transaction,
                          account: credit_card,
                          external_id: i,
                          description: credit_descriptions.sample,
                          date: dates.sample,
                          is_credit: true)
      end
      (10001..10400).each do |i|
        FactoryBot.create(:transaction,
                          account: deposit_account,
                          external_id: i,
                          description: debit_descriptions.sample,
                          date: dates.sample,
                          is_credit: false)
      end
      (10401..10600).each do |i|
        FactoryBot.create(:transaction,
                          account: deposit_account,
                          external_id: i,
                          description: credit_descriptions.sample,
                          date: dates.sample,
                          is_credit: true)
      end
    end
  end

  private

  def credit_descriptions
    @credit_descriptions ||= [

      "E-TRANSFER ***acD",
      "ACCT BAL REBATE",
      "Payroll Deposit",
      "Reversed service fee",
      "PAYMENT - THANK YOU",
    ]

  end

  def debit_descriptions 
    @debit_descriptions ||= [
      "GUMROAD.CO* TRAVIS STE",
      "Hydro Bill Pmt | B.C. HYDRO-PAP",
      "UBER CANADA/UBERTRIP",
      "Scheduled payment | ONLINE TRANSFER",
      "ABC*30914-CLUB16",
      "TD MORTGAGE",
      "Monthly fee",
      "Fees/Dues | PQ",
      "Auto Insurance | ICBC",
      "Visa Debit purchase - 4487 | MICROSOFT*XBOX",
      "DASHVAPES INC/17199556",
      "DIGITALOCEAN.COM",
      "BCAA-MEMBERSHIP",
      "FREEDOM MOBILE",
      "GOOGLE *YouTube",
      "Online Banking payment - 8602 | WALMART MC",
      "MONTHLY ACCOUNT FEE",
      "E-TRANSFER ***mzc",
      "IW124 TFR-TO C/C",
      "UBER* TRIP",
      "NETFLIX.COM",
      "GOOGLE *TV",
      "PAYMENT - THANK YOU / PAI",
      "HP *INSTANT INK CA",
      "FRESHCO #8942 _F",
      "Online Banking payment - 1515 | ABBOTSFORD-TAX",
      "DD/DOORDASHNANDOSPERIP",
      "POPARIDE",
      "DD/DOORDASHDHALIWALSWE",
      "FirstReport/PremierRappor",
      "AMZN Mktp CA*AQ25F0BO3",
      "E-TRANSFER ***VRd",
      "Online Banking transfer - 4167",
      "e-Transfer sent | keyboard | 3MQJUH",
      "Visa Debit purchase - 9314 | MICROSOFT*XBOX",
      "Online Banking payment - 7622 | INTERNET LIGHT.",
      "AMZN Mktp CA*4W1EO13O3",
      "Abbotsford SD",
      "DD/DOORDASHMIDORIJAPAN",
      "e-Transfer sent | UMAIR ABID | XAF9AK",
      "CAD SODA SNACK VENDING",
      "Monthly Fee Rebate",
      "DASHVAPES INC/17171729",
      "K & M TUNE-UP CENTRE LTD",
      "REMITLY* E1FEB _V",
      "AMZN Mktp CA*DW5P78MY3",
      "Online Banking transfer - 2997",
      "Visa Debit purchase - 0122 | MICROSOFT*XBOX",
      "WAL-MART SUPERCENTER#1113",
      "KFC #1837",
      "EYEBUYDIRECT",
      "E-TRANSFER ***U77",
      "FRESHCO #8942",
      "DASHVAPES INC/17145099",
      "CHV43028 CLEARBROOK CH",
      "DD/DOORDASHTANDOORITAD",
      "Wikimedia",
      "REMITLY* KB02C _V",
      "DASHVAPES INC/17131393",
      "DASMESH FOODS AND VIDEO",
      "FRUITICANA # 15",
      "IN434 TFR-TO C/C",
      "LITTLE CAESARS #5108",
      "TIM HORTONS #4749",
      "GATEWAY PIZZA & CURRY",
      "AFGHAN SUPER MARKET",
      "THE HOME DEPOT #7141",
      "COLES 229",
      "SQ *FAMOUS WOK ABBOTSFORD",
      "HUDSON'S BAY #1162",
      "#368 SPORT CHEK",
      "DAIRY QUEEN #27218",
      "DOLLARAMA # 787",
      "TIM HORTONS #2089",
      "MCDONALD'S #40387",
      "DOMINOS PIZZA 10087",
      "BC LIQUOR #149",
      "REAL CDN SUPERSTORE #1",
      "VALUE VILLAGE # 2014",
      "SHOPPERS DRUG MART #22",
      "7 ELEVEN STORE #14846",
      "DOLLARAMA # 660",
      "STARBUCKS COFFEE #5846",
      "FRASERWAY SELF-SERVE LTD",
      "TIM HORTONS #7551",
      "SSL COMPUTERS",
      "SQ *THE CAKE GURU",
      "PETRO CANADA02627",
      "WAL-MART SUPERCENTER#3019",
      "ABBOTSFORD SUPER MARKET L",
      "BULK BARN #747 ABBOTSFORD",
      "PETRO CANADA70005",
      "WAL-MART #3019",
      "Online Banking payment - 2516 | INTERNET LIGHT.",
      "Visa Debit purchase - 1703 | BCAA - INSURANC",
      "C-LOVERS FISH & CHIPS ABB",
      "Deposit interest",
    ]
  end
end
