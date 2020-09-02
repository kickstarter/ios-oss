@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgeExpandableHeaderRewardCellViewModelTests: TestCase {
  internal let vm: PledgeExpandableHeaderRewardCellViewModelType = PledgeExpandableHeaderRewardCellViewModel()

  private let amountAttributedText = TestObserver<NSAttributedString, Never>()
  private let labelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amountAttributedText.observe(self.amountAttributedText.observer)
    self.vm.outputs.labelText.observe(self.labelText.observer)
  }

  func testOutputs() {
    self.amountAttributedText.assertDidNotEmitValue()
    self.labelText.assertDidNotEmitValue()

    let text = "Text"
    let amount = NSAttributedString(string: "Test string")

    self.vm.inputs.configure(with: (text, amount))

    self.amountAttributedText.assertValues([amount])
    self.labelText.assertValues([text])
  }
}
