import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result
import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import Library

internal final class SearchEmptyStateCellViewModelTests: TestCase {
  fileprivate let vm: SearchEmptyStateCellViewModelType = SearchEmptyStateCellViewModel()

  fileprivate let searchTermNotFoundLabelText = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.searchTermNotFoundLabelText.observe(self.searchTermNotFoundLabelText.observer)
  }

  func testOutputs() {
    let discoveryParams = .defaults |> DiscoveryParams.lens.query .~ "abcdefgh"

    self.vm.inputs.configureWith(param: discoveryParams)

    self.searchTermNotFoundLabelText.assertValues
    ([Strings.We_couldnt_find_anything_for_search_term(search_term: "abcdefgh")],
                                         "Emits to the user that the search term could not be found.")
  }
}
