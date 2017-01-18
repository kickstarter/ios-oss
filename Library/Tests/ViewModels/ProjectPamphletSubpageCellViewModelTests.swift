import ReactiveSwift
import ReactiveExtensions
import Result
import XCTest
import Prelude
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class ProjectPamphletSubpageCellViewModelTests: TestCase {
  private let vm: ProjectPamphletSubpageCellViewModelType = ProjectPamphletSubpageCellViewModel()

  private let countLabelBackgroundColor = TestObserver<UIColor, NoError>()
  private let countLabelBorderColor = TestObserver<UIColor, NoError>()
  private let countLabelText = TestObserver<String, NoError>()
  private let countLabelTextColor = TestObserver<UIColor, NoError>()
  private let liveNowImageViewHidden = TestObserver<Bool, NoError>()
  private let labelText = TestObserver<String, NoError>()
  private let labelTextColor = TestObserver<UIColor, NoError>()
  private let topGradientViewHidden = TestObserver<Bool, NoError>()
  private let separatorViewHidden = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.countLabelBackgroundColor.observe(self.countLabelBackgroundColor.observer)
    self.vm.outputs.countLabelBorderColor.observe(self.countLabelBorderColor.observer)
    self.vm.outputs.countLabelText.observe(self.countLabelText.observer)
    self.vm.outputs.countLabelTextColor.observe(self.countLabelTextColor.observer)
    self.vm.outputs.liveNowImageViewHidden.observe(self.liveNowImageViewHidden.observer)
    self.vm.outputs.labelText.observe(self.labelText.observer)
    self.vm.outputs.labelTextColor.observe(self.labelTextColor.observer)
    self.vm.outputs.topGradientViewHidden.observe(self.topGradientViewHidden.observer)
    self.vm.outputs.separatorViewHidden.observe(self.separatorViewHidden.observer)
  }

  func testCommentsSubpage() {
    self.vm.inputs.configureWith(subpage: .comments(12, .middle))

    self.countLabelTextColor.assertValue(.ksr_text_navy_700)
    self.countLabelText.assertValue("12")
    self.countLabelBorderColor.assertValue(.clear)
    self.countLabelBackgroundColor.assertValue(.ksr_navy_300)
    self.liveNowImageViewHidden.assertValue(true)
    self.labelText.assertValue("Comments")
    self.labelTextColor.assertValue(.ksr_text_navy_700)
    self.topGradientViewHidden.assertValue(true)
    self.separatorViewHidden.assertValue(false)
  }

  func testLiveStreamsSubpage() {
    let liveStream = Project.LiveStream.template
      |> Project.LiveStream.lens.isLiveNow .~ true

    self.vm.inputs.configureWith(subpage: .liveStream(liveStream: liveStream, .first))

    self.countLabelTextColor.assertValue(.ksr_text_green_700)
    self.countLabelText.assertValue("Watch live")
    self.countLabelBorderColor.assertValue(.ksr_green_500)
    self.countLabelBackgroundColor.assertValue(.white)
    self.liveNowImageViewHidden.assertValue(false)
    self.labelText.assertValue("Live Streaming now")
    self.labelTextColor.assertValue(.ksr_text_green_700)
    self.topGradientViewHidden.assertValue(false)
    self.separatorViewHidden.assertValue(false)
  }

  func testReplayLiveStreamsSubpage() {
    let liveStream = Project.LiveStream.template
      |> Project.LiveStream.lens.isLiveNow .~ false

    self.vm.inputs.configureWith(subpage: .liveStream(liveStream: liveStream, .first))

    self.countLabelTextColor.assertValue(.ksr_text_navy_700)
    self.countLabelText.assertValue("Replay")
    self.countLabelBorderColor.assertValue(.clear)
    self.countLabelBackgroundColor.assertValue(.ksr_navy_300)
    self.liveNowImageViewHidden.assertValue(true)
    self.labelText.assertValue("Past Live Stream")
    self.labelTextColor.assertValue(.ksr_text_navy_700)
    self.topGradientViewHidden.assertValue(false)
    self.separatorViewHidden.assertValue(false)
  }

  func testUpdatesSubpage() {
    self.vm.inputs.configureWith(subpage: .updates(12, .last))

    self.countLabelTextColor.assertValue(.ksr_text_navy_700)
    self.countLabelText.assertValue("12")
    self.countLabelBorderColor.assertValue(.clear)
    self.countLabelBackgroundColor.assertValue(.ksr_navy_300)
    self.liveNowImageViewHidden.assertValue(true)
    self.labelText.assertValue("Updates")
    self.labelTextColor.assertValue(.ksr_text_navy_700)
    self.topGradientViewHidden.assertValue(true)
    self.separatorViewHidden.assertValue(true)
  }

  func testPositionFirst() {
    self.vm.inputs.configureWith(subpage: .comments(1, .first))

    self.topGradientViewHidden.assertValue(false)
    self.separatorViewHidden.assertValue(false)
  }

  func testPositionMiddle() {
    self.vm.inputs.configureWith(subpage: .comments(1, .middle))

    self.topGradientViewHidden.assertValue(true)
    self.separatorViewHidden.assertValue(false)
  }

  func testPositionLast() {
    self.vm.inputs.configureWith(subpage: .comments(1, .last))

    self.topGradientViewHidden.assertValue(true)
    self.separatorViewHidden.assertValue(true)
  }

  func testSubpageTypes() {
    let comments = ProjectPamphletSubpage.comments(1, .first)
    let updates = ProjectPamphletSubpage.updates(1, .first)
    let liveStream = ProjectPamphletSubpage.liveStream(liveStream: Project.LiveStream.template, .first)

    XCTAssertTrue(comments.isComments)
    XCTAssertFalse(comments.isLiveStream)
    XCTAssertFalse(comments.isUpdates)
    XCTAssertEqual(comments.count, 1)

    XCTAssertTrue(updates.isUpdates)
    XCTAssertFalse(updates.isLiveStream)
    XCTAssertFalse(updates.isComments)
    XCTAssertEqual(updates.count, 1)

    XCTAssertTrue(liveStream.isLiveStream)
    XCTAssertFalse(liveStream.isComments)
    XCTAssertFalse(liveStream.isUpdates)
    XCTAssertEqual(liveStream.count, 0)
  }

  func testUpcomingLiveStreamsSubpage() {
    let liveStream = Project.LiveStream.template
      |> Project.LiveStream.lens.isLiveNow .~ false
      |> Project.LiveStream.lens.startDate .~ self.scheduler.currentDate
        .addingTimeInterval(60 * 60).timeIntervalSince1970

    self.vm.inputs.configureWith(subpage: .liveStream(liveStream: liveStream, .first))

    self.countLabelTextColor.assertValue(.ksr_text_navy_700)
    self.countLabelText.assertValue("in 1 hr")
    self.countLabelBorderColor.assertValue(.clear)
    self.countLabelBackgroundColor.assertValue(.ksr_navy_300)
    self.liveNowImageViewHidden.assertValue(true)
    self.labelText.assertValue("Upcoming Live Stream")
    self.labelTextColor.assertValue(.ksr_text_navy_700)
    self.topGradientViewHidden.assertValue(false)
    self.separatorViewHidden.assertValue(false)
  }
}
