@testable import Library
@testable import KsApi
import Foundation
import XCTest
import PassKit
import Prelude

final class PKPaymentAuthorizationViewControllerHelpersTests: XCTestCase {
  func test_supportedNetworksForProject_allCardTypes() {
    let project = Project.template
      |> \.availableCardTypes .~ ["Visa",
                                  "MasterCard",
                                  "American Express",
                                  "Discover",
                                  "JCB",
                                  "Diners Club",
                                  "UnionPay"]

    let supportedNetworks = PKPaymentAuthorizationViewController.supportedNetworks(for: project)

    XCTAssertEqual(supportedNetworks.count, project.availableCardTypes?.count)
  }

  func test_supportedNetworksForProject_AvailableCardTypes_IsNil_US_Project() {
    let project = Project.template
      |> \.country .~ .us

    let supportedNetworks = PKPaymentAuthorizationViewController.supportedNetworks(for: project)

    XCTAssertEqual(supportedNetworks, [.amex,
                                       .masterCard,
                                       .visa,
                                       .discover,
                                       .chinaUnionPay])
  }

  func test_supportedNetworksForProject_AvailableCardTypes_IsNil_NonUS_Project() {
    let project = Project.template
      |> \.country .~ .de

    let supportedNetworks = PKPaymentAuthorizationViewController.supportedNetworks(for: project)

    XCTAssertEqual(supportedNetworks, [.amex,
                                       .masterCard,
                                       .visa])
  }
}
