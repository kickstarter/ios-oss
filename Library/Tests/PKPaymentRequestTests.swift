import Argo
import Runes
import PassKit
import XCTest
@testable import Library

public final class PKPaymentRequestTests: XCTestCase {

  func testDecodingSnakeCase_MinimalData() {
    let json: [String:Any] = [
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
    XCTAssertEqual([.visa, .masterCard, .amex, .discover], decoded.value?.supportedNetworks ?? [])
  }

  func testDecodingSnakeCase_FullData() {
    let json: [String:Any] = [
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
    XCTAssertEqual([.capability3DS], decoded.value?.merchantCapabilities)
    XCTAssertEqual("merchant.test", decoded.value?.merchantIdentifier)
    XCTAssertEqual(1, decoded.value?.paymentSummaryItems.count)
    XCTAssertEqual("The thing", decoded.value?.paymentSummaryItems.first?.label)
    XCTAssertEqual(10, decoded.value?.paymentSummaryItems.first?.amount)
    XCTAssertEqual(PKPaymentSummaryItemType.pending, decoded.value?.paymentSummaryItems.first?.type)
    XCTAssertEqual(PKShippingType.delivery, decoded.value?.shippingType)
    XCTAssertEqual([.visa, .masterCard, .amex, .discover], decoded.value?.supportedNetworks ?? [])
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
    XCTAssertEqual([.visa, .masterCard, .amex, .discover], decoded.value?.supportedNetworks ?? [])
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
    XCTAssertEqual([.capability3DS, .capabilityCredit], decoded.value?.merchantCapabilities)
    XCTAssertEqual("merchant.test", decoded.value?.merchantIdentifier)
    XCTAssertEqual(1, decoded.value?.paymentSummaryItems.count)
    XCTAssertEqual("The thing", decoded.value?.paymentSummaryItems.first?.label)
    XCTAssertEqual(10, decoded.value?.paymentSummaryItems.first?.amount)
    XCTAssertEqual(PKPaymentSummaryItemType.pending, decoded.value?.paymentSummaryItems.first?.type)
    XCTAssertEqual(PKShippingType.delivery, decoded.value?.shippingType)
    XCTAssertEqual([.visa, .masterCard, .amex, .discover], decoded.value?.supportedNetworks ?? [])

  }

  func testEncoding() {
    let json: [String: Any] = [
      "countryCode": "US",
      "currencyCode": "USD",
      "merchantCapabilities": [
        PKMerchantCapability.capability3DS.rawValue, PKMerchantCapability.capabilityCredit.rawValue
      ],
      "merchantIdentifier": "merchant.test",
      "paymentSummaryItems": [
        [
          "label": "The thing",
          "amount": 10,
          "type": PKPaymentSummaryItemType.pending.rawValue
        ]
      ],
      "shippingType": PKShippingType.delivery.rawValue,
      "supportedNetworks": ["Visa", "MasterCard", "AmEx", "Discover"]
    ]
    let decoded = PKPaymentRequest.decodeJSONDictionary(json)

    XCTAssertEqual(json as NSDictionary, (decoded.value?.encode())! as NSDictionary)
  }
}
