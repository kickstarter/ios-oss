import Foundation
import XCTest
@testable import KsApi

final class CreateApplePayBackingInputTests: XCTestCase {
  func testCreateApplePayBacking_toInputDictionary_noNilValues() {
    let input = CreateApplePayBackingInput(amount: "10.00",
                                           locationId: 123,
                                           paymentInstrumentName: "instrumentName",
                                           paymentNetwork: "paymentNetwork",
                                           projectId: 12345,
                                           rewardId: 321,
                                           stripeToken: "stripeTokenXYZ",
                                           transactionIdentifier: "transactionId")

    let inputDictionary = input.toInputDictionary()

    XCTAssertEqual(inputDictionary["amount"] as! String, "10.00")
    XCTAssertEqual(inputDictionary["locationId"] as! String, "123")
    XCTAssertEqual(inputDictionary["paymentInstrumentName"] as! String, "instrumentName")
    XCTAssertEqual(inputDictionary["paymentNetwork"] as! String, "paymentNetwork")
    XCTAssertEqual(inputDictionary["projectId"] as! String, "12345")
    XCTAssertEqual(inputDictionary["rewardId"] as! String, "321")
    XCTAssertEqual(inputDictionary["token"] as! String, "stripeTokenXYZ")
    XCTAssertEqual(inputDictionary["transactionIdentifier"] as! String, "transactionId")
  }

  func testCreateApplePayBacking_toInputDictionary_withNilValues() {
    let input = CreateApplePayBackingInput(amount: "10.50",
                                            locationId: nil,
                                            paymentInstrumentName: "instrumentName",
                                            paymentNetwork: "paymentNetwork",
                                            projectId: 12345,
                                            rewardId: nil,
                                            stripeToken: "stripeTokenXYZ",
                                            transactionIdentifier: "transactionId")

    let inputDictionary = input.toInputDictionary()

    XCTAssertEqual(inputDictionary["amount"] as! String, "10.50")
    XCTAssertEqual(inputDictionary["paymentInstrumentName"] as! String, "instrumentName")
    XCTAssertEqual(inputDictionary["paymentNetwork"] as! String, "paymentNetwork")
    XCTAssertEqual(inputDictionary["projectId"] as! String, "12345")
    XCTAssertEqual(inputDictionary["token"] as! String, "stripeTokenXYZ")
    XCTAssertEqual(inputDictionary["transactionIdentifier"] as! String, "transactionId")
    XCTAssertNil(inputDictionary["locationId"])
    XCTAssertNil(inputDictionary["rewardId"])
  }
}
