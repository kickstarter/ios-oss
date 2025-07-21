@testable import Library
import ReactiveExtensions_TestHelpers
import XCTest

final class KSRSearchBarViewModelTests: XCTestCase {
  private let viewModel = KSRSearchBarViewModel()

  private let changeSearchFieldFocusObserver = TestObserver<Bool, Never>()
  private let resignFirstResponderObserver = TestObserver<(), Never>()
  private let searchFieldTextObserver = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.viewModel.outputs.changeSearchFieldFocus.observe(self.changeSearchFieldFocusObserver.observer)
    self.viewModel.outputs.resignFirstResponder.observe(self.resignFirstResponderObserver.observer)
    self.viewModel.outputs.searchFieldText.observe(self.searchFieldTextObserver.observer)
  }

  func testSearchFieldFocus_OnBeginEditing() {
    self.viewModel.inputs.searchFieldDidBeginEditing()
    self.changeSearchFieldFocusObserver.assertValues([true])
  }

  func testSearchFieldFocus_OnEditingDidEnd() {
    self.viewModel.inputs.searchTextEditingDidEnd()
    self.changeSearchFieldFocusObserver.assertValues([false])
  }

  func testSearchTextChanged() {
    self.viewModel.inputs.searchTextChanged("hello world")
    self.searchFieldTextObserver.assertValues(["hello world"])
  }

  func testClearSearchText() {
    self.viewModel.inputs.searchTextChanged("hello world")
    self.viewModel.inputs.clearSearchText()
    self.searchFieldTextObserver.assertValues(["hello world", ""])
    self.resignFirstResponderObserver.assertDidNotEmitValue()
  }

  func testCancelButtonPressed() {
    self.viewModel.inputs.searchTextChanged("hello world")
    self.viewModel.inputs.cancelButtonPressed()
    self.searchFieldTextObserver.assertValues(["hello world", ""])
    self.resignFirstResponderObserver.assertValueCount(1)
  }

  func testSearchTextEditingDidEnd_ResignsFirstResponder() {
    self.viewModel.inputs.searchTextEditingDidEnd()
    self.resignFirstResponderObserver.assertValueCount(1)
  }
}
