// swiftlint:disable type_name
// swiftlint:disable force_unwrapping
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
@testable import LiveStream
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamNavTitleViewTests: TestCase {

  fileprivate let vm: DashboardFundingCellViewModelType = DashboardFundingCellViewModel()

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  func testReplay() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.startDate .~ (MockDate().addingTimeInterval(-86_400)).date
      |> LiveStreamEvent.lens.hasReplay .~ true
      |> LiveStreamEvent.lens.replayUrl .~ "http://www.replay.com"
      |> LiveStreamEvent.lens.liveNow .~ false

    guard let view = LiveStreamNavTitleView.fromNib() else {
      XCTFail("View should be created")
      return
    }

    view.bindStyles()
    view.configureWith(liveStreamEvent: liveStreamEvent, delegate: nil)
    let size = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        view.setNeedsDisplay()
        FBSnapshotVerifyView(view, identifier: "lang_\(language)")
      }
    }
  }

  func testLive() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.startDate .~ (MockDate().addingTimeInterval(-86_400)).date
      |> LiveStreamEvent.lens.liveNow .~ true

    guard let view = LiveStreamNavTitleView.fromNib() else {
      XCTFail("View should be created")
      return
    }

    view.bindStyles()
    view.configureWith(liveStreamEvent: liveStreamEvent, delegate: nil)
    let size = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        view.setNeedsDisplay()
        FBSnapshotVerifyView(view, identifier: "lang_\(language)")
      }
    }
  }

  func testLive_NumberOfPeopleWatching() {
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.startDate .~ (MockDate().addingTimeInterval(-86_400)).date
      |> LiveStreamEvent.lens.liveNow .~ true

    guard let view = LiveStreamNavTitleView.fromNib() else {
      XCTFail("View should be created")
      return
    }

    view.bindStyles()
    view.configureWith(liveStreamEvent: liveStreamEvent, delegate: nil)
    view.set(numberOfPeopleWatching: 2_500)

    let size = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        view.setNeedsDisplay()
        FBSnapshotVerifyView(view, identifier: "lang_\(language)")
      }
    }
  }
}
