import Foundation
@testable import KsApi
@testable import Library
import PassKit
import Prelude
import XCTest

final class ApplePayCapabilitiesTests: XCTestCase {
  private var applePayCapabilities: ApplePayCapabilities = ApplePayCapabilities()

  override func setUp() {
    super.setUp()

    self.applePayCapabilities = ApplePayCapabilities()
  }

  func test_supportedNetworksForProject_allCardTypes() {
    let project = Project.template
      |> \.availableCardTypes .~ [
        "AMEX",
        "DISCOVER",
        "JCB",
        "MASTERCARD",
        "VISA",
        "DINERS",
        "UNION_PAY"
      ]

    let supportedNetworks = self.applePayCapabilities.supportedNetworks(for: project)

    XCTAssertEqual(6, supportedNetworks.count)
    XCTAssertTrue(supportedNetworks.contains(.amex))
    XCTAssertTrue(supportedNetworks.contains(.discover))
    XCTAssertTrue(supportedNetworks.contains(.JCB))
    XCTAssertTrue(supportedNetworks.contains(.masterCard))
    XCTAssertTrue(supportedNetworks.contains(.visa))
    XCTAssertTrue(supportedNetworks.contains(.chinaUnionPay))
  }

  func test_supportedNetworksForProject_filtersUnknownCardTypes() {
    let project = Project.template
      |> \.availableCardTypes .~ ["American EX"]

    let supportedNetworks = self.applePayCapabilities.supportedNetworks(for: project)

    XCTAssertEqual(supportedNetworks.count, 0)
  }

  func test_supportedNetworksForProject_AvailableCardTypes_IsNil_US_ProjectCurrency() {
    let project = Project.template
      |> \.availableCardTypes .~ nil
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode

    let supportedNetworks = self.applePayCapabilities.supportedNetworks(for: project)

    XCTAssertEqual(supportedNetworks.count, 6)
    XCTAssertTrue(supportedNetworks.contains(.amex))
    XCTAssertTrue(supportedNetworks.contains(.discover))
    XCTAssertTrue(supportedNetworks.contains(.JCB))
    XCTAssertTrue(supportedNetworks.contains(.masterCard))
    XCTAssertTrue(supportedNetworks.contains(.visa))
    XCTAssertTrue(supportedNetworks.contains(.chinaUnionPay))
  }

  func test_supportedNetworksForProject_AvailableCardTypes_IsNil_NonUS_ProjectCurrency() {
    let project = Project.template
      |> \.availableCardTypes .~ nil
      |> Project.lens.stats.currency .~ Project.Country.de.currencyCode

    let supportedNetworks = self.applePayCapabilities.supportedNetworks(for: project)

    XCTAssertEqual(supportedNetworks.count, 4)
    XCTAssertTrue(supportedNetworks.contains(.amex))
    XCTAssertTrue(supportedNetworks.contains(.JCB))
    XCTAssertTrue(supportedNetworks.contains(.masterCard))
    XCTAssertTrue(supportedNetworks.contains(.visa))
  }
}
