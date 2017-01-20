import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result
import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import Library



internal final class NoSearchResultsCellViewModelTests: TestCase {
  fileprivate let vm: NoSearchResultsCellViewModelType = NoSearchResultsCellViewModel()

  fileprivate let searchTermNotFound = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.searchTermNotFound.observe(self.searchTermNotFound.observer)

  }

  func testOutputs() {

    let discoveryParams = .defaults |> DiscoveryParams.lens.query .~ "abcdefgh"
    self.vm.inputs.configureWith(param: discoveryParams)

    self.searchTermNotFound.assertValues(["We couldn't find anything for abcdefgh."], "Emits to the user that the search term could not be found." )
  }
}
