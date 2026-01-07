@testable import KsApi
import Prelude
import XCTest

class DiscoveryParamsTests: XCTestCase {
  func testDefault() {
    let params = DiscoveryParams.defaults
    XCTAssertNil(params.staffPicks)
  }

  func testQueryParams() {
    XCTAssertEqual([:], DiscoveryParams.defaults.queryParams)

    let params = DiscoveryParams.defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      |> DiscoveryParams.lens.hasVideo .~ true
      |> DiscoveryParams.lens.starred .~ true
      |> DiscoveryParams.lens.backed .~ false
      |> DiscoveryParams.lens.social .~ true
      |> DiscoveryParams.lens.recommended .~ true
      |> DiscoveryParams.lens.similarTo .~ Project.template
      |> DiscoveryParams.lens.category .~ Category.art
      |> DiscoveryParams.lens.query .~ "wallet"
      |> DiscoveryParams.lens.state .~ .live
      |> DiscoveryParams.lens.sort .~ .popular
      |> DiscoveryParams.lens.page .~ 1
      |> DiscoveryParams.lens.perPage .~ 20
      |> DiscoveryParams.lens.seed .~ 123

    let queryParams: [String: String] = [
      "staff_picks": "true",
      "has_video": "true",
      "backed": "-1",
      "social": "1",
      "recommended": "true",
      "category_id": Category.art.intID?.description ?? "-1",
      "term": "wallet",
      "state": "live",
      "starred": "1",
      "sort": "popularity",
      "page": "1",
      "per_page": "20",
      "seed": "123",
      "similar_to": Project.template.id.description
    ]

    XCTAssertEqual(queryParams, params.queryParams)
  }

  func testEquatable() {
    let params = DiscoveryParams.defaults
    XCTAssertEqual(params, params)
  }

  func testStringConvertible() {
    let params = DiscoveryParams.defaults
    XCTAssertNotNil(params.description)
    XCTAssertNotNil(params.debugDescription)
  }

  func testPOTD() {
    let p1 = DiscoveryParams.defaults
      |> DiscoveryParams.lens.includePOTD .~ true
    XCTAssertEqual(
      [:], p1.queryParams,
      "POTD flag is included with no filter."
    )

    let p2 = DiscoveryParams.defaults
      |> DiscoveryParams.lens.includePOTD .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    XCTAssertEqual(
      ["sort": "magic"],
      p2.queryParams,
      "POTD flag is included with no filter + magic sort."
    )
  }

  func testDecode() {
    XCTAssertNil(DiscoveryParams.decodeJSONDictionary([:])?.backed, "absent values aren't set")
    XCTAssertNil(DiscoveryParams.decodeJSONDictionary(["backed": "nope"])?.backed, "invalid values error")

    // server logic
    XCTAssertEqual(true, DiscoveryParams.decodeJSONDictionary(["has_video": "true"])?.hasVideo)
    XCTAssertEqual(true, DiscoveryParams.decodeJSONDictionary(["has_video": "1"])?.hasVideo)
    XCTAssertEqual(true, DiscoveryParams.decodeJSONDictionary(["has_video": "t"])?.hasVideo)
    XCTAssertEqual(true, DiscoveryParams.decodeJSONDictionary(["has_video": "T"])?.hasVideo)
    XCTAssertEqual(true, DiscoveryParams.decodeJSONDictionary(["has_video": "TRUE"])?.hasVideo)
    XCTAssertEqual(true, DiscoveryParams.decodeJSONDictionary(["has_video": "on"])?.hasVideo)
    XCTAssertEqual(true, DiscoveryParams.decodeJSONDictionary(["has_video": "ON"])?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decodeJSONDictionary(["has_video": "false"])?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decodeJSONDictionary(["has_video": "0"])?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decodeJSONDictionary(["has_video": "f"])?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decodeJSONDictionary(["has_video": "F"])?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decodeJSONDictionary(["has_video": "FALSE"])?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decodeJSONDictionary(["has_video": "off"])?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decodeJSONDictionary(["has_video": "OFF"])?.hasVideo)

    XCTAssertEqual(true, DiscoveryParams.decodeJSONDictionary(["include_potd": "true"])?.includePOTD)
    XCTAssertEqual(true, DiscoveryParams.decodeJSONDictionary(["recommended": "true"])?.recommended)
    XCTAssertEqual(true, DiscoveryParams.decodeJSONDictionary(["staff_picks": "true"])?.staffPicks)

    XCTAssertEqual(40, DiscoveryParams.decodeJSONDictionary(["page": "40"])?.page)
    XCTAssertEqual(41, DiscoveryParams.decodeJSONDictionary(["per_page": "41"])?.perPage)
    XCTAssertEqual(42, DiscoveryParams.decodeJSONDictionary(["seed": "42"])?.seed)

    XCTAssertNil(DiscoveryParams.decodeJSONDictionary(["backed": "42"])?.backed)
    XCTAssertNil(DiscoveryParams.decodeJSONDictionary(["backed": "0"])?.backed)
    XCTAssertEqual(true, DiscoveryParams.decodeJSONDictionary(["backed": "1"])?.backed)
    XCTAssertEqual(false, DiscoveryParams.decodeJSONDictionary(["backed": "-1"])?.backed)

    XCTAssertEqual(false, DiscoveryParams.decodeJSONDictionary(["social": "-1"])?.social)
    XCTAssertEqual(false, DiscoveryParams.decodeJSONDictionary(["starred": "-1"])?.starred)

    XCTAssertEqual("bugs", DiscoveryParams.decodeJSONDictionary(["term": "bugs"])?.query)
    XCTAssertEqual(.magic, DiscoveryParams.decodeJSONDictionary(["sort": "magic"])?.sort)
    XCTAssertEqual(.live, DiscoveryParams.decodeJSONDictionary(["state": "live"])?.state)
  }

  func testDiscoveryParamsSortTrackingString() {
    XCTAssertEqual(DiscoveryParams.Sort.endingSoon.trackingString, "ending_soon")
    XCTAssertEqual(DiscoveryParams.Sort.magic.trackingString, "magic")
    XCTAssertEqual(DiscoveryParams.Sort.newest.trackingString, "newest")
    XCTAssertEqual(DiscoveryParams.Sort.popular.trackingString, "popular")
  }
}
