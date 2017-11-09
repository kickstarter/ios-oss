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
  private let topSeparatorViewHidden = TestObserver<Bool, NoError>()
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
    self.vm.outputs.topSeparatorViewHidden.observe(self.topSeparatorViewHidden.observer)
    self.vm.outputs.separatorViewHidden.observe(self.separatorViewHidden.observer)
  }

  func testCommentsSubpage() {
    self.vm.inputs.configureWith(subpage: .comments(12, .middle))

    self.countLabelTextColor.assertValue(.ksr_text_dark_grey_900)
    self.countLabelText.assertValues(["12"])
    self.countLabelBorderColor.assertValue(.clear)
    self.countLabelBackgroundColor.assertValue(.ksr_navy_300)
    self.liveNowImageViewHidden.assertValue(true)
    self.labelText.assertValues(["Comments"])
    self.labelTextColor.assertValue(.ksr_text_dark_grey_900)

    self.topSeparatorViewHidden.assertValue(true)
    self.separatorViewHidden.assertValue(false)
  }

  func testLiveStreamsSubpage() {
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.configureWith(subpage: .liveStream(liveStreamEvent: liveStreamEvent, .first))

    self.countLabelTextColor.assertValue(.ksr_text_green_700)
    self.countLabelText.assertValues(["Watch live"])
    self.countLabelBorderColor.assertValue(.ksr_green_500)
    self.countLabelBackgroundColor.assertValue(.white)
    self.liveNowImageViewHidden.assertValue(false)
    self.labelText.assertValues(["Live streaming now"])
    self.labelTextColor.assertValue(.ksr_text_green_700)
    self.topSeparatorViewHidden.assertValue(false)
    self.separatorViewHidden.assertValue(false)
  }

  func testReplayLiveStreamsSubpage() {
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false

    self.vm.inputs.configureWith(subpage: .liveStream(liveStreamEvent: liveStreamEvent, .first))

    self.countLabelTextColor.assertValue(.ksr_text_dark_grey_900)
    self.countLabelText.assertValues(["Replay"])
    self.countLabelBorderColor.assertValue(.clear)
    self.countLabelBackgroundColor.assertValue(.ksr_navy_300)
    self.liveNowImageViewHidden.assertValue(true)
    self.labelText.assertValues(["Past live stream"])
    self.labelTextColor.assertValue(.ksr_text_dark_grey_900)
    self.topSeparatorViewHidden.assertValue(false)
    self.separatorViewHidden.assertValue(false)
  }

  func testUpdatesSubpage() {
    self.vm.inputs.configureWith(subpage: .updates(12, .last))

    self.countLabelTextColor.assertValue(.ksr_text_dark_grey_900)
    self.countLabelText.assertValues(["12"])
    self.countLabelBorderColor.assertValue(.clear)
    self.countLabelBackgroundColor.assertValue(.ksr_navy_300)
    self.liveNowImageViewHidden.assertValue(true)
    self.labelText.assertValues(["Updates"])
    self.labelTextColor.assertValue(.ksr_text_dark_grey_900)
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
    let liveStream = ProjectPamphletSubpage.liveStream(liveStreamEvent: LiveStreamEvent.template, .first)

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
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ self.scheduler.currentDate
        .addingTimeInterval(60 * 60)

    self.vm.inputs.configureWith(subpage: .liveStream(liveStreamEvent: liveStreamEvent, .first))

    self.countLabelTextColor.assertValue(.ksr_text_dark_grey_900)
    self.countLabelText.assertValues(["in 1 hr"])
    self.countLabelBorderColor.assertValue(.clear)
    self.countLabelBackgroundColor.assertValue(.ksr_navy_300)
    self.liveNowImageViewHidden.assertValue(true)
    self.labelText.assertValues(["Upcoming live stream"])
    self.labelTextColor.assertValue(.ksr_text_dark_grey_900)
    self.topSeparatorViewHidden.assertValue(false)
    self.separatorViewHidden.assertValue(false)
  }
}
