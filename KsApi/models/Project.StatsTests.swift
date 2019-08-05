@testable import KsApi
import Foundation
import Prelude
import XCTest

final class ProjectStatsTests: XCTestCase {
  func testFundingProgress() {
    let halfFunded = Project.template
      |> Project.lens.stats.fundingProgress .~ 0.5

    XCTAssertEqual(0.5, halfFunded.stats.fundingProgress)
    XCTAssertEqual(50, halfFunded.stats.percentFunded)

    let badGoalData = Project.template
      |> Project.lens.stats.pledged .~ 0
      <> Project.lens.stats.goal .~ 0

    XCTAssertEqual(0.0, badGoalData.stats.fundingProgress)
    XCTAssertEqual(0, badGoalData.stats.percentFunded)
  }

  func testPledgedUsd() {
    let project = .template
      |> Project.lens.stats.staticUsdRate .~ 2.0
      |> Project.lens.stats.pledged .~ 1_000

    XCTAssertEqual(2_000, project.stats.pledgedUsd)
  }

  func testPledgedUsd_roundsDown() {
    let project = .template
      |> Project.lens.stats.staticUsdRate .~ 0.2999
      |> Project.lens.stats.pledged .~ 1_000

    // 1000 * 0.2999 = 299.9
    XCTAssertEqual(299, project.stats.pledgedUsd)
  }

  func testGoalUsd_roundsDown() {
    let project = .template
      |> Project.lens.stats.staticUsdRate .~ 0.2999
      |> Project.lens.stats.goal .~ 1_000

    // 1000 * 0.2999 = 299.9
    XCTAssertEqual(299, project.stats.goalUsd)
  }

  func testPledgedCurrentCurrency() {
    let projectUnknownCurrencyRate = .template
      |> Project.lens.stats.currentCurrencyRate .~ nil
      |> Project.lens.stats.pledged .~ 1_000

    XCTAssertNil(projectUnknownCurrencyRate.stats.pledgedCurrentCurrency)

    let projectProjectUserCurrencyRate = .template
      |> Project.lens.stats.currentCurrencyRate .~ 0.2999
      |> Project.lens.stats.pledged .~ 1_000

    // 1000 * 0.2999 = 299.9
    XCTAssertEqual(299, projectProjectUserCurrencyRate.stats.pledgedCurrentCurrency, "Converted pledged amount rounds down")
  }

  func testGoalCurrentCurrency() {
    let projectUnknownCurrencyRate = .template
      |> Project.lens.stats.currentCurrencyRate .~ nil
      |> Project.lens.stats.goal .~ 1_000

    XCTAssertNil(projectUnknownCurrencyRate.stats.goalCurrentCurrency)

    let projectProjectUserCurrencyRate = .template
      |> Project.lens.stats.currentCurrencyRate .~ 0.2999
      |> Project.lens.stats.goal .~ 1_000

    // 1000 * 0.2999 = 299.9
    XCTAssertEqual(299, projectProjectUserCurrencyRate.stats.goalCurrentCurrency,
                   "Converted goal amount rounds down")
  }

  func testCurrentCountry() {
    let project = .template
      |> Project.lens.stats.currentCurrency .~ "USD"

    XCTAssertEqual(Project.Country.us, project.stats.currentCountry,
                   "Current country returns country when currency code corresponds to known country")

    let projectUnknownCurrency = .template
      |> Project.lens.stats.currentCurrency .~ "ZZZ"

    XCTAssertNil(projectUnknownCurrency.stats.currentCountry,
                 "Current country returns nil when currency code does not correspond to known country")

    let projectNilCurrency = .template
      |> Project.lens.stats.currentCurrency .~ nil

    XCTAssertNil(projectNilCurrency.stats.currentCountry)
  }

  func testOmitUSCurrencyCode() {
    let project = .template
      |> Project.lens.stats.currentCurrency .~ "USD"

    XCTAssertTrue(project.stats.omitUSCurrencyCode,
                  "Omits US currency code for users with a preferred currency of USD")

    let projectNilCurrentCurrency = project
      |> Project.lens.stats.currentCurrency .~ nil

    XCTAssertTrue(projectNilCurrentCurrency.stats.omitUSCurrencyCode,
                  // swiftlint:disable:next line_length
                  "Omits US currency code for users without a preferred currency (which then defaults to USD)")

    let projectNonUSCurrentCurrency = project
      |> Project.lens.stats.currentCurrency .~ "SEK"

    XCTAssertFalse(projectNonUSCurrentCurrency.stats.omitUSCurrencyCode,
                   "Does not omit US currency code for users whose preferred currency is not USD")
  }

  func testNeedsConversion() {
    let project = .template
      |> Project.lens.stats.currentCurrency .~ "USD"
      |> Project.lens.stats.currency .~ "SEK"

    XCTAssertTrue(project.stats.needsConversion,
                  "Needs conversion is true when project currency is different from users preferred currency")

    let projectUnknownPreferredCurrency = .template
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currency .~ Project.Country.au.currencyCode

    XCTAssertTrue(projectUnknownPreferredCurrency.stats.needsConversion,
                  // swiftlint:disable:next line_length
                  "Needs conversion is true when project currency is not USD, and the user has no preferred currency")

    let projectSameCurrency = .template
      |> Project.lens.stats.currentCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode

    XCTAssertFalse(projectSameCurrency.stats.needsConversion,
                   "Needs conversion is false when project currency is the same as users preferred currency")
  }
}
