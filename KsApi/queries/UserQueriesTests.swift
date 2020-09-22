@testable import KsApi
import Prelude
import XCTest

final class UserQueriesTests: XCTestCase {
  func testAccountQuery() {
    let query = Query.user(accountQueryFields())

    XCTAssertEqual(
      "me { chosenCurrency email hasPassword id imageUrl: imageUrl(blur: false, width: 1024) isAppleConnected isDeliverable isEmailVerified name uid }",
      query.description
    )
    XCTAssertEqual(
      "{ me { chosenCurrency email hasPassword id imageUrl: imageUrl(blur: false, width: 1024) isAppleConnected isDeliverable isEmailVerified name uid } }",
      Query.build(NonEmptySet(query))
    )
  }

  func testChangeEmailQuery() {
    let query = Query.user(changeEmailQueryFields())

    XCTAssertEqual(
      "me { email id imageUrl: imageUrl(blur: false, width: 1024) isDeliverable isEmailVerified name uid }",
      query.description
    )
    XCTAssertEqual(
      "{ me { email id imageUrl: imageUrl(blur: false, width: 1024) isDeliverable isEmailVerified name uid } }",
      Query.build(NonEmptySet(query))
    )
  }

  func testStoredCardsQuery() {
    let query = Query.user(storedCardsQueryFields())

    XCTAssertEqual(
      "me { id imageUrl: imageUrl(blur: false, width: 1024) name storedCards { nodes { expirationDate id lastFour type } totalCount } uid }",
      query.description
    )
    XCTAssertEqual(
      "{ me { id imageUrl: imageUrl(blur: false, width: 1024) name storedCards { nodes { expirationDate id lastFour type } totalCount } uid } }",
      Query.build(NonEmptySet(query))
    )
  }

  func testBackingsQuery() {
    let query = Query.user(backingsQueryFields(status: BackingState.errored.rawValue))
    XCTAssertEqual(
      "me { backings(status: errored) { nodes { addOns { nodes { amount { amount currency symbol } backersCount convertedAmount { amount currency symbol } description displayName endsAt estimatedDeliveryOn id isMaxPledge items { nodes { id name } } limit limitPerBacker name remainingQuantity shippingPreference shippingRules { cost { amount currency symbol } id location { country countryName displayableName id name } } startsAt } } amount { amount currency symbol } backer { id imageUrl: imageUrl(blur: false, width: 1024) name uid } backerCompleted bonusAmount { amount currency symbol } cancelable creditCard: paymentSource { ... on CreditCard { expirationDate id lastFour paymentType state type } } errorReason id location { country countryName displayableName id name } pledgedOn project { actions { displayConvertAmount } backersCount category { id name parentCategory { id name } } country { code name } creator { id imageUrl: imageUrl(blur: false, width: 1024) name uid } currency deadlineAt description finalCollectionDate fxRate goal { amount currency symbol } image { id url(width: 1024) } isProjectWeLove launchedAt location { country countryName displayableName id name } name pid pledged { amount currency symbol } slug state stateChangedAt url usdExchangeRate } project { actions { displayConvertAmount } backersCount category { id name parentCategory { id name } } country { code name } creator { id imageUrl: imageUrl(blur: false, width: 1024) name uid } currency deadlineAt description fxRate goal { amount currency symbol } image { id url(width: 1024) } isProjectWeLove launchedAt location { country countryName displayableName id name } name pid pledged { amount currency symbol } slug state stateChangedAt url usdExchangeRate } reward { amount { amount currency symbol } backersCount convertedAmount { amount currency symbol } description displayName endsAt estimatedDeliveryOn id isMaxPledge items { nodes { id name } } limit limitPerBacker name remainingQuantity shippingPreference shippingRules { cost { amount currency symbol } id location { country countryName displayableName id name } } startsAt } sequence shippingAmount { amount currency symbol } status } totalCount } id imageUrl: imageUrl(blur: false, width: 1024) name uid }",
      query.description
    )
    XCTAssertEqual(
      "{ me { backings(status: errored) { nodes { addOns { nodes { amount { amount currency symbol } backersCount convertedAmount { amount currency symbol } description displayName endsAt estimatedDeliveryOn id isMaxPledge items { nodes { id name } } limit limitPerBacker name remainingQuantity shippingPreference shippingRules { cost { amount currency symbol } id location { country countryName displayableName id name } } startsAt } } amount { amount currency symbol } backer { id imageUrl: imageUrl(blur: false, width: 1024) name uid } backerCompleted bonusAmount { amount currency symbol } cancelable creditCard: paymentSource { ... on CreditCard { expirationDate id lastFour paymentType state type } } errorReason id location { country countryName displayableName id name } pledgedOn project { actions { displayConvertAmount } backersCount category { id name parentCategory { id name } } country { code name } creator { id imageUrl: imageUrl(blur: false, width: 1024) name uid } currency deadlineAt description finalCollectionDate fxRate goal { amount currency symbol } image { id url(width: 1024) } isProjectWeLove launchedAt location { country countryName displayableName id name } name pid pledged { amount currency symbol } slug state stateChangedAt url usdExchangeRate } project { actions { displayConvertAmount } backersCount category { id name parentCategory { id name } } country { code name } creator { id imageUrl: imageUrl(blur: false, width: 1024) name uid } currency deadlineAt description fxRate goal { amount currency symbol } image { id url(width: 1024) } isProjectWeLove launchedAt location { country countryName displayableName id name } name pid pledged { amount currency symbol } slug state stateChangedAt url usdExchangeRate } reward { amount { amount currency symbol } backersCount convertedAmount { amount currency symbol } description displayName endsAt estimatedDeliveryOn id isMaxPledge items { nodes { id name } } limit limitPerBacker name remainingQuantity shippingPreference shippingRules { cost { amount currency symbol } id location { country countryName displayableName id name } } startsAt } sequence shippingAmount { amount currency symbol } status } totalCount } id imageUrl: imageUrl(blur: false, width: 1024) name uid } }",
      Query.build(NonEmptySet(query))
    )
  }
}
