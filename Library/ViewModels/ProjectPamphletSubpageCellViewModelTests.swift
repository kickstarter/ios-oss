@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ProjectPamphletSubpageCellViewModelTests: TestCase {
  private let vm: ProjectPamphletSubpageCellViewModelType = ProjectPamphletSubpageCellViewModel()

  private let countLabelBackgroundColor = TestObserver<UIColor, Never>()
  private let countLabelBorderColor = TestObserver<UIColor, Never>()
  private let countLabelText = TestObserver<String, Never>()
  private let countLabelTextColor = TestObserver<UIColor, Never>()
  private let labelText = TestObserver<String, Never>()
  private let labelTextColor = TestObserver<UIColor, Never>()
  private let topSeparatorViewHidden = TestObserver<Bool, Never>()
  private let separatorViewHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.countLabelBackgroundColor.observe(self.countLabelBackgroundColor.observer)
    self.vm.outputs.countLabelBorderColor.observe(self.countLabelBorderColor.observer)
    self.vm.outputs.countLabelText.observe(self.countLabelText.observer)
    self.vm.outputs.countLabelTextColor.observe(self.countLabelTextColor.observer)
    self.vm.outputs.labelText.observe(self.labelText.observer)
    self.vm.outputs.labelTextColor.observe(self.labelTextColor.observer)
    self.vm.outputs.topSeparatorViewHidden.observe(self.topSeparatorViewHidden.observer)
    self.vm.outputs.separatorViewHidden.observe(self.separatorViewHidden.observer)
  }

  func testCommentsSubpage() {
    self.vm.inputs.configureWith(subpage: .comments(12, .middle))

    self.countLabelTextColor.assertValue(.ksr_support_700)
    self.countLabelText.assertValues(["12"])
    self.countLabelBorderColor.assertValue(.clear)
    self.countLabelBackgroundColor.assertValue(.ksr_support_100)
    self.labelText.assertValues(["Comments"])
    self.labelTextColor.assertValue(.ksr_support_700)

    self.topSeparatorViewHidden.assertValue(true)
    self.separatorViewHidden.assertValue(false)
  }

  func testUpdatesSubpage() {
    self.vm.inputs.configureWith(subpage: .updates(12, .last))

    self.countLabelTextColor.assertValue(.ksr_support_700)
    self.countLabelText.assertValues(["12"])
    self.countLabelBorderColor.assertValue(.clear)
    self.countLabelBackgroundColor.assertValue(.ksr_support_100)
    self.labelText.assertValues(["Updates"])
    self.labelTextColor.assertValue(.ksr_support_700)
    self.topSeparatorViewHidden.assertValue(true)
    self.separatorViewHidden.assertValue(true)
  }

  func testPositionFirst() {
    self.vm.inputs.configureWith(subpage: .comments(1, .first))

    self.topSeparatorViewHidden.assertValue(false)
    self.separatorViewHidden.assertValue(false)
  }

  func testPositionMiddle() {
    self.vm.inputs.configureWith(subpage: .comments(1, .middle))

    self.topSeparatorViewHidden.assertValue(true)
    self.separatorViewHidden.assertValue(false)
  }

  func testPositionLast() {
    self.vm.inputs.configureWith(subpage: .comments(1, .last))

    self.topSeparatorViewHidden.assertValue(true)
    self.separatorViewHidden.assertValue(true)
  }

  func testSubpageTypes() {
    let comments = ProjectPamphletSubpage.comments(1, .first)
    let updates = ProjectPamphletSubpage.updates(1, .first)

    XCTAssertTrue(comments.isComments)
    XCTAssertFalse(comments.isUpdates)
    XCTAssertEqual(comments.count, 1)

    XCTAssertTrue(updates.isUpdates)
    XCTAssertFalse(updates.isComments)
    XCTAssertEqual(updates.count, 1)
  }
}
