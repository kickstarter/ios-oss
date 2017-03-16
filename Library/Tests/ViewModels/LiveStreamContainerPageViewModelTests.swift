import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

private class TestLiveStreamChatHandler: LiveStreamChatHandler {
  var chatMessages: Signal<[LiveStreamChatMessage], NoError> { return .empty}
  func sendChatMessage(message: String) {}
  func configureChatUserInfo(info: LiveStreamChatUserInfo) {}
}

internal final class LiveStreamContainerPageViewModelTests: TestCase {
  private let vm: LiveStreamContainerPageViewModelType = LiveStreamContainerPageViewModel()

  private let chatButtonTextColor = TestObserver<UIColor, NoError>()
  private let chatButtonTitleFontName = TestObserver<String, NoError>()
  private let chatButtonTitleFontSize = TestObserver<CGFloat, NoError>()
  private let indicatorLineViewXPosition = TestObserver<Int, NoError>()
  private let infoButtonTextColor = TestObserver<UIColor, NoError>()
  private let infoButtonTitleFontName = TestObserver<String, NoError>()
  private let infoButtonTitleFontSize = TestObserver<CGFloat, NoError>()
  private let loadViewControllersIntoPagesDataSource = TestObserver<[LiveStreamContainerPage], NoError>()
  private let pagedToPage = TestObserver<LiveStreamContainerPage, NoError>()
  private let pagedToPageDirection = TestObserver<UIPageViewControllerNavigationDirection, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.chatButtonTextColor.observe(self.chatButtonTextColor.observer)
    self.vm.outputs.chatButtonTitleFont.map { $0.fontName }.observe(self.chatButtonTitleFontName.observer)
    self.vm.outputs.chatButtonTitleFont.map { $0.pointSize }.observe(self.chatButtonTitleFontSize.observer)
    self.vm.outputs.indicatorLineViewXPosition.observe(self.indicatorLineViewXPosition.observer)
    self.vm.outputs.infoButtonTextColor.observe(self.infoButtonTextColor.observer)
    self.vm.outputs.infoButtonTitleFont.map { $0.fontName }.observe(self.infoButtonTitleFontName.observer)
    self.vm.outputs.infoButtonTitleFont.map { $0.pointSize }.observe(self.infoButtonTitleFontSize.observer)
    self.vm.outputs.loadViewControllersIntoPagesDataSource.observe(
      self.loadViewControllersIntoPagesDataSource.observer)
    self.vm.outputs.pagedToPage.map(first).observe(self.pagedToPage.observer)
    self.vm.outputs.pagedToPage.map(second).observe(self.pagedToPageDirection.observer)
  }

  func testColors() {
    self.chatButtonTextColor.assertValueCount(0)
    self.infoButtonTextColor.assertValueCount(0)

    let handler = TestLiveStreamChatHandler()

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template,
                                 liveStreamChatHandler: handler, refTag: .projectPage,
                                 presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.didLoadViewControllersIntoPagesDataSource()

    self.chatButtonTextColor.assertValues([.ksr_grey_500])
    self.infoButtonTextColor.assertValues([.white])

    self.vm.inputs.willTransition(toPage: 1)
    self.vm.inputs.pageTransition(completed: true)

    self.chatButtonTextColor.assertValues([.ksr_grey_500, .white])
    self.infoButtonTextColor.assertValues([.white, .ksr_grey_500])

    self.vm.inputs.willTransition(toPage: 0)
    self.vm.inputs.pageTransition(completed: true)

    self.chatButtonTextColor.assertValues([.ksr_grey_500, .white, .ksr_grey_500])
    self.infoButtonTextColor.assertValues([.white, .ksr_grey_500, .white])
  }

  func testFonts() {
    self.chatButtonTitleFontName.assertValueCount(0)
    self.infoButtonTitleFontSize.assertValueCount(0)
    self.infoButtonTitleFontName.assertValueCount(0)
    self.infoButtonTitleFontSize.assertValueCount(0)

    let handler = TestLiveStreamChatHandler()

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template,
                                 liveStreamChatHandler: handler, refTag: .projectPage,
                                 presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.didLoadViewControllersIntoPagesDataSource()

    self.chatButtonTitleFontName.assertValues([".SFUIText"])
    self.chatButtonTitleFontSize.assertValues([14])
    self.infoButtonTitleFontName.assertValues([".SFUIText-Semibold"])
    self.infoButtonTitleFontSize.assertValues([14])

    self.vm.inputs.willTransition(toPage: 1)
    self.vm.inputs.pageTransition(completed: true)

    self.chatButtonTitleFontName.assertValues([".SFUIText", ".SFUIText-Semibold"])
    self.chatButtonTitleFontSize.assertValues([14, 14])
    self.infoButtonTitleFontName.assertValues([".SFUIText-Semibold", ".SFUIText"])
    self.infoButtonTitleFontSize.assertValues([14, 14])

    self.vm.inputs.willTransition(toPage: 0)
    self.vm.inputs.pageTransition(completed: true)

    self.chatButtonTitleFontName.assertValues([".SFUIText", ".SFUIText-Semibold", ".SFUIText"])
    self.chatButtonTitleFontSize.assertValues([14, 14, 14])
    self.infoButtonTitleFontName.assertValues([".SFUIText-Semibold", ".SFUIText", ".SFUIText-Semibold"])
    self.infoButtonTitleFontSize.assertValues([14, 14, 14])
  }

  func testPagedToPage() {
    self.pagedToPage.assertValueCount(0)
    self.pagedToPageDirection.assertValueCount(0)

    let handler = TestLiveStreamChatHandler()

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template,
                                 liveStreamChatHandler: handler, refTag: .projectPage,
                                 presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.didLoadViewControllersIntoPagesDataSource()

    XCTAssertTrue(self.pagedToPage.values[0].isInfoPage)
    self.pagedToPageDirection.assertValues([.forward])

    self.vm.inputs.chatButtonTapped()

    XCTAssertTrue(self.pagedToPage.values[1].isChatPage)
    self.pagedToPageDirection.assertValues([.forward, .forward])

    self.vm.inputs.infoButtonTapped()

    XCTAssertTrue(self.pagedToPage.values[2].isInfoPage)
    self.pagedToPageDirection.assertValues([.forward, .forward, .reverse])
  }

  func testLoadViewControllersIntoPagesDataSource() {
    self.loadViewControllersIntoPagesDataSource.assertValueCount(0)

    let handler = TestLiveStreamChatHandler()

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template,
                                 liveStreamChatHandler: handler, refTag: .projectPage,
                                 presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.loadViewControllersIntoPagesDataSource.assertValueCount(1)
    XCTAssertTrue(self.loadViewControllersIntoPagesDataSource.values[0][0].isInfoPage)
    XCTAssertTrue(self.loadViewControllersIntoPagesDataSource.values[0][1].isChatPage)
  }

  func testIndicatorLineViewXPosition() {
    self.indicatorLineViewXPosition.assertValueCount(0)

    let handler = TestLiveStreamChatHandler()

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template,
                                 liveStreamChatHandler: handler, refTag: .projectPage,
                                 presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.didLoadViewControllersIntoPagesDataSource()

    self.indicatorLineViewXPosition.assertValues([0])

    self.vm.inputs.willTransition(toPage: 1)
    self.vm.inputs.pageTransition(completed: true)

    self.indicatorLineViewXPosition.assertValues([0, 1])

    self.vm.inputs.willTransition(toPage: 0)
    self.vm.inputs.pageTransition(completed: true)

    self.indicatorLineViewXPosition.assertValues([0, 1, 0])
  }
}
