@testable import KsApi
import XCTest

class GraphAPI_UpdateUserProfileInput_UpdateUserProfileInputTests: XCTestCase {
  func testChangeCurrency_WithNewCurrency_Success() {
    let input = ChangeCurrencyInput(chosenCurrency: "DKK")

    let graphInput = GraphAPI.UpdateUserProfileInput.from(input)

    XCTAssertEqual(graphInput.chosenCurrency, GraphAPI.CurrencyCode.dkk)
  }
}
