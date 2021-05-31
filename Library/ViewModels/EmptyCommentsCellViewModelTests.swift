@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class EmptyCommentsCellViewModelTests: TestCase {
  let vm: EmptyCommentsCellViewModelType = EmptyCommentsCellViewModel()

  private let emptyStateText = TestObserver<String, Never>()
  private let expectedEmptyStateText = "No comments yet."

  override func setUp() {
    super.setUp()
    self.vm.outputs.emptyText.observe(self.emptyStateText.observer)
  }

  func testOutputs() {
    self.vm.inputs.configureWith(project: Project.template)

    self.emptyStateText.assertValue(expectedEmptyStateText, "The empty state text is emitted.")
  }
}
