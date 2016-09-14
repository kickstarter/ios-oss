import Argo
import PassKit
import XCTest
@testable import Library

public final class PKPaymentRequestTests: XCTestCase {

  func testDecodingSnakeCase_MinimalData() {
    let json: [String:AnyObject] = [
      "country_code": "US",
      "currency_code": "USD",
      "merchant_identifier": "merchant.test",
      "payment_summary_items": [
        [
          "label": "The thing",
          "amount": "10.0"
        ]
      ],
      "supported_networks": ["Visa", "MasterCard", "AmEx", "Discover"]
    ]

    let decoded = PKPaymentRequest.decodeJSONDictionary(json)

    XCTAssertNil(decoded.error)
    XCTAssertNotNil(decoded.value)

    XCTAssertEqual("US", decoded.value?.countryCode)
    XCTAssertEqual("USD", decoded.value?.currencyCode)
    XCTAssertEqual("merchant.test", decoded.value?.merchantIdentifier)
    XCTAssertEqual(1, decoded.value?.paymentSummaryItems.count)
    XCTAssertEqual("The thing", decoded.value?.paymentSummaryItems.first?.label)
    XCTAssertEqual(10, decoded.value?.paymentSummaryItems.first?.amount)
    XCTAssertEqual(["Visa", "MasterCard", "AmEx", "Discover"], decoded.value?.supportedNetworks ?? [])
  }

  func testDecodingSnakeCase_FullData() {
    let json: [String:AnyObject] = [
      "country_code": "US",
      "currency_code": "USD",
      "merchant_capabilities": "Capability3DS",
      "merchant_identifier": "merchant.test",
      "payment_summary_items": [
        [
          "label": "The thing",
          "amount": "10.0",
          "type": "Pending"
        ]
      ],
      "shipping_type": "Delivery",
      "supported_networks": ["Visa", "MasterCard", "AmEx", "Discover"]
    ]

    let decoded = PKPaymentRequest.decodeJSONDictionary(json)

    XCTAssertNil(decoded.error)
    XCTAssertNotNil(decoded.value)

    XCTAssertEqual("US", decoded.value?.countryCode)
    XCTAssertEqual("USD", decoded.value?.currencyCode)
    XCTAssertEqual([.Capability3DS], decoded.value?.merchantCapabilities)
    XCTAssertEqual("merchant.test", decoded.value?.merchantIdentifier)
    XCTAssertEqual(1, decoded.value?.paymentSummaryItems.count)
    XCTAssertEqual("The thing", decoded.value?.paymentSummaryItems.first?.label)
    XCTAssertEqual(10, decoded.value?.paymentSummaryItems.first?.amount)
    XCTAssertEqual(PKPaymentSummaryItemType.Pending, decoded.value?.paymentSummaryItems.first?.type)
    XCTAssertEqual(PKShippingType.Delivery, decoded.value?.shippingType)
    XCTAssertEqual(["Visa", "MasterCard", "AmEx", "Discover"], decoded.value?.supportedNetworks ?? [])
  }

  func testDecodingCamelCase_MinimalData() {
    let decoded = PKPaymentRequest.decodeJSONDictionary([
      "countryCode": "US",
      "currencyCode": "USD",
      "merchantIdentifier": "merchant.test",
      "paymentSummaryItems": [
        [
          "label": "The thing",
          "amount": "10.0"
        ]
      ],
      "supportedNetworks": ["Visa", "MasterCard", "AmEx", "Discover"]
      ])

    XCTAssertNil(decoded.error)
    XCTAssertNotNil(decoded.value)

    XCTAssertEqual("US", decoded.value?.countryCode)
    XCTAssertEqual("USD", decoded.value?.currencyCode)
    XCTAssertEqual("merchant.test", decoded.value?.merchantIdentifier)
    XCTAssertEqual(1, decoded.value?.paymentSummaryItems.count)
    XCTAssertEqual("The thing", decoded.value?.paymentSummaryItems.first?.label)
    XCTAssertEqual(10, decoded.value?.paymentSummaryItems.first?.amount)
    XCTAssertEqual(["Visa", "MasterCard", "AmEx", "Discover"], decoded.value?.supportedNetworks ?? [])
  }

  func testDecodingCamelCase_FullData() {
    let decoded = PKPaymentRequest.decodeJSONDictionary([
      "countryCode": "US",
      "currencyCode": "USD",
      "merchantCapabilities": ["Capability3DS", "CapabilityCredit"],
      "merchantIdentifier": "merchant.test",
      "paymentSummaryItems": [
        [
          "label": "The thing",
          "amount": "10.0",
          "type": "Pending"
        ]
      ],
      "shippingType": "Delivery",
      "supportedNetworks": ["Visa", "MasterCard", "AmEx", "Discover"]
      ])

    XCTAssertNil(decoded.error)
    XCTAssertNotNil(decoded.value)

    XCTAssertEqual("US", decoded.value?.countryCode)
    XCTAssertEqual("USD", decoded.value?.currencyCode)
    XCTAssertEqual([.Capability3DS, .CapabilityCredit], decoded.value?.merchantCapabilities)
    XCTAssertEqual("merchant.test", decoded.value?.merchantIdentifier)
    XCTAssertEqual(1, decoded.value?.paymentSummaryItems.count)
    XCTAssertEqual("The thing", decoded.value?.paymentSummaryItems.first?.label)
    XCTAssertEqual(10, decoded.value?.paymentSummaryItems.first?.amount)
    XCTAssertEqual(PKPaymentSummaryItemType.Pending, decoded.value?.paymentSummaryItems.first?.type)
    XCTAssertEqual(PKShippingType.Delivery, decoded.value?.shippingType)
    XCTAssertEqual(["Visa", "MasterCard", "AmEx", "Discover"], decoded.value?.supportedNetworks ?? [])
  }

  func testEncoding() {
    let json: [String:AnyObject] = [
      "countryCode": "US",
      "currencyCode": "USD",
      "merchantCapabilities": [
        PKMerchantCapability.Capability3DS.rawValue, PKMerchantCapability.CapabilityCredit.rawValue
      ],
      "merchantIdentifier": "merchant.test",
      "paymentSummaryItems": [
        [
          "label": "The thing",
          "amount": 10,
          "type": PKPaymentSummaryItemType.Pending.rawValue
        ]
      ],
      "shippingType": PKShippingType.Delivery.rawValue,
      "supportedNetworks": ["Visa", "MasterCard", "AmEx", "Discover"]
    ]
    let decoded = PKPaymentRequest.decodeJSONDictionary(json)

    XCTAssertEqual(json as NSDictionary, decoded.value?.encode())
  }
}
