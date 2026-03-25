import ApolloTestSupport
import Combine
import GraphAPI
import GraphAPITestMocks
@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApiTestHelpers
import XCTest

final class PPOProjectCardModelTests: XCTestCase {
  func testParsingNoAddress() throws {
    let model = try XCTUnwrap(self.mockModel(address: nil))
    XCTAssertNil(model.address.rawAddress)
  }

  func testParsingBasicAddress_skipsEmptyLines() throws {
    let address = Mock<GraphAPITestMocks.Address>(
      addressLine1: "123 First Street",
      addressLine2: "",
      city: "Los Angeles",
      countryCode: .case(.us),
      id: "0",
      phoneNumber: "",
      postalCode: "90025-1234",
      recipientName: "Firsty Lasty",
      region: "CA"
    )

    let model = try XCTUnwrap(self.mockModel(address: address))

    let lines = (try XCTUnwrap(model.address.rawAddress)).split(
      separator: "\n",
      omittingEmptySubsequences: false
    )
    XCTAssertEqual(lines, [
      "Firsty Lasty",
      "123 First Street",
      "Los Angeles, CA 90025-1234",
      "US"
    ])
  }

  func testParsingTwoLineAddress() throws {
    let address = Mock<GraphAPITestMocks.Address>(
      addressLine1: "123 First Street",
      addressLine2: "Apt #5678",
      city: "Los Angeles",
      countryCode: .case(.us),
      id: "0",
      postalCode: "90025-1234",
      recipientName: "Firsty Lasty",
      region: "CA"
    )

    let model = try XCTUnwrap(self.mockModel(address: address))

    let lines = (try XCTUnwrap(model.address.rawAddress)).split(
      separator: "\n",
      omittingEmptySubsequences: false
    )
    XCTAssertEqual(lines, [
      "Firsty Lasty",
      "123 First Street",
      "Apt #5678",
      "Los Angeles, CA 90025-1234",
      "US"
    ])
  }

  func testParsingTwoLineAddressPhone() throws {
    let address = Mock<GraphAPITestMocks.Address>(
      addressLine1: "123 First Street",
      addressLine2: "Apt #5678",
      city: "Los Angeles",
      countryCode: .case(.us),
      id: "0",
      phoneNumber: "(555) 555-5425",
      postalCode: "90025-1234",
      recipientName: "Firsty Lasty",
      region: "CA"
    )

    let model = try XCTUnwrap(self.mockModel(address: address))

    let lines = (try XCTUnwrap(model.address.rawAddress)).split(
      separator: "\n",
      omittingEmptySubsequences: false
    )
    XCTAssertEqual(lines, [
      "Firsty Lasty",
      "123 First Street",
      "Apt #5678",
      "Los Angeles, CA 90025-1234",
      "US",
      "(555) 555-5425"
    ])
  }

  private func mockModel(address: Mock<GraphAPITestMocks.Address>?) -> PPOProjectCardModel? {
    let mockEdge = GraphAPI.FetchPledgedProjectsQuery.mockEdge(addressMock: address)
    let node = GraphAPI.FetchPledgedProjectsQuery.Data.PledgeProjectsOverview.Pledges.Edge.Node
      .from(mockEdge.node!)
    return PPOProjectCardModel(node: node)
  }
}
