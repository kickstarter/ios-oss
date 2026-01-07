@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ExternalElementSourceViewElementCellViewModelTests: TestCase {
  private let vm: ExternalSourceViewElementCellViewModelType = ExternalSourceViewElementCellViewModel()
  private let expectedExternalURLString = "https://source.com"
  private let expectedContentHeight = 32
  private let htmlText = TestObserver<String, Never>()
  private let contentHeight = TestObserver<Int, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.htmlText.observe(self.htmlText.observer)
    self.vm.outputs.contentHeight.observe(self.contentHeight.observer)
  }

  func testExternalSourceElementData_Success() {
    let externalSourceElement = ExternalSourceViewElement(
      embeddedURLString: expectedExternalURLString,
      embeddedURLContentHeight: expectedContentHeight
    )

    self.vm.inputs.configureWith(element: externalSourceElement)

    self.htmlText.assertLastValue(self.expectedExternalURLString)
    self.contentHeight.assertLastValue(self.expectedContentHeight)
  }
}
