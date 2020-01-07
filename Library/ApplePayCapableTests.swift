import Foundation
@testable import KsApi
@testable import Library
import PassKit
import Prelude
import XCTest

final class ApplePayCapableTests: XCTestCase {
  private var applePayCapable: ApplePayCapable = ApplePayCapable()

  override func setUp() {
    super.setUp()

    self.applePayCapable = ApplePayCapable()
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

    let supportedNetworks = self.applePayCapable.supportedNetworks(for: project)

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

    let supportedNetworks = self.applePayCapable.supportedNetworks(for: project)

    XCTAssertEqual(supportedNetworks.count, 0)
  }

  func test_supportedNetworksForProject_AvailableCardTypes_IsNil_US_Project() {
    let project = Project.template
      |> \.availableCardTypes .~ nil
      |> \.country .~ .us

    let supportedNetworks = self.applePayCapable.supportedNetworks(for: project)

    XCTAssertTrue(supportedNetworks.contains(.amex))
    XCTAssertTrue(supportedNetworks.contains(.discover))
    XCTAssertTrue(supportedNetworks.contains(.JCB))
    XCTAssertTrue(supportedNetworks.contains(.masterCard))
    XCTAssertTrue(supportedNetworks.contains(.visa))
    XCTAssertTrue(supportedNetworks.contains(.chinaUnionPay))
  }

  func test_supportedNetworksForProject_AvailableCardTypes_IsNil_NonUS_Project() {
    let project = Project.template
      |> \.availableCardTypes .~ nil
      |> \.country .~ .de

    let supportedNetworks = self.applePayCapable.supportedNetworks(for: project)

    XCTAssertTrue(supportedNetworks.contains(.amex))
    XCTAssertTrue(supportedNetworks.contains(.JCB))
    XCTAssertTrue(supportedNetworks.contains(.masterCard))
    XCTAssertTrue(supportedNetworks.contains(.visa))
  }
}

