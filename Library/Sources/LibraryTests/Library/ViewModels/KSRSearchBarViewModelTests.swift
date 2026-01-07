@testable import Library
import ReactiveExtensions_TestHelpers
import XCTest

final class KSRSearchBarViewModelTests: XCTestCase {
  private let vm = KSRSearchBarViewModel()

  private let changeSearchFieldFocusObserver = TestObserver<Bool, Never>()
  private let resignFirstResponderObserver = TestObserver<(), Never>()
  private let searchFieldTextObserver = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.changeSearchFieldFocus.observe(self.changeSearchFieldFocusObserver.observer)
    self.vm.outputs.resignFirstResponder.observe(self.resignFirstResponderObserver.observer)
    self.vm.outputs.searchFieldText.observe(self.searchFieldTextObserver.observer)
  }

  func testSearchFieldFocus_OnBeginEditing() {
    self.vm.inputs.searchFieldDidBeginEditing()
    self.changeSearchFieldFocusObserver.assertValues([true])
  }

  func testSearchFieldFocus_OnEditingDidEnd() {
    self.vm.inputs.searchTextEditingDidEnd()
    self.changeSearchFieldFocusObserver.assertValues([false])
  }

  func testSearchTextChanged() {
    self.vm.inputs.searchTextChanged("hello world")
    self.searchFieldTextObserver.assertValues(["hello world"])
  }

  func testClearSearchText() {
    self.vm.inputs.searchTextChanged("hello world")
    self.vm.inputs.clearSearchText()
    self.searchFieldTextObserver.assertValues(["hello world", ""])
    self.resignFirstResponderObserver.assertDidNotEmitValue()
  }

  func testCancelButtonPressed() {
    self.vm.inputs.searchTextChanged("hello world")
    self.vm.inputs.cancelButtonPressed()
    self.searchFieldTextObserver.assertValues(["hello world", ""])
    self.resignFirstResponderObserver.assertValueCount(1)
  }

  func testSearchTextEditingDidEnd_ResignsFirstResponder() {
    self.vm.inputs.searchTextEditingDidEnd()
    self.resignFirstResponderObserver.assertValueCount(1)
  }
}
