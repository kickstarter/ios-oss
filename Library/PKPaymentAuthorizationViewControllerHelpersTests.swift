import Foundation
@testable import KsApi
@testable import Library
import PassKit
import Prelude
import XCTest

final class PKPaymentAuthorizationViewControllerHelpersTests: XCTestCase {
  func test_supportedNetworksForProject_allCardTypes() {
    let project = Project.template
      |> \.availableCardTypes .~ [
        "AMEX",
        "DISCOVER",
        "JCB",
        "MASTERCARD",
        "VISA",
        //        "DINERS", // figure out what to do with this type
        "UNION_PAY"
      ]

    let supportedNetworks = PKPaymentAuthorizationViewController.supportedNetworks(for: project)

    XCTAssertEqual(supportedNetworks.count, project.availableCardTypes?.count)
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

    let supportedNetworks = PKPaymentAuthorizationViewController.supportedNetworks(for: project)

    XCTAssertEqual(supportedNetworks.count, 0)
  }

  func test_supportedNetworksForProject_AvailableCardTypes_IsNil_US_Project() {
    let project = Project.template
      |> \.availableCardTypes .~ nil
      |> \.country .~ .us

    let supportedNetworks = PKPaymentAuthorizationViewController.supportedNetworks(for: project)

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

    let supportedNetworks = PKPaymentAuthorizationViewController.supportedNetworks(for: project)

    XCTAssertTrue(supportedNetworks.contains(.amex))
    XCTAssertTrue(supportedNetworks.contains(.JCB))
    XCTAssertTrue(supportedNetworks.contains(.masterCard))
    XCTAssertTrue(supportedNetworks.contains(.visa))
  }
}
