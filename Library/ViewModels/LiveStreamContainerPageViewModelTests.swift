import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

private let pages: [LiveStreamContainerPage] = [
  .info(project: .template, liveStreamEvent: .template, refTag: .projectPage, presentedFromProject: false),
  .chat(project: .template, liveStreamEvent: .template)
]

internal final class LiveStreamContainerPageViewModelTests: TestCase {
  private let vm: LiveStreamContainerPageViewModelType = LiveStreamContainerPageViewModel()

  private let chatButtonTextColor = TestObserver<UIColor, NoError>()
  private let chatButtonTitleFontName = TestObserver<String, NoError>()
  private let chatButtonTitleFontSize = TestObserver<CGFloat, NoError>()
  private let indicatorLineViewHidden = TestObserver<Bool, NoError>()
  private let indicatorLineViewXPosition = TestObserver<Int, NoError>()
  private let infoButtonTextColor = TestObserver<UIColor, NoError>()
  private let infoButtonTitleFontName = TestObserver<String, NoError>()
  private let infoButtonTitleFontSize = TestObserver<CGFloat, NoError>()
  private let loadViewControllersIntoPagesDataSource = TestObserver<[LiveStreamContainerPage], NoError>()
  private let pagedToPage = TestObserver<LiveStreamContainerPage, NoError>()
  private let pagedToPageDirection = TestObserver<UIPageViewControllerNavigationDirection, NoError>()
  private let pagerTabStripStackViewHidden = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.chatButtonTextColor.observe(self.chatButtonTextColor.observer)
    self.vm.outputs.chatButtonTitleFont.map { $0.fontName }.observe(self.chatButtonTitleFontName.observer)
    self.vm.outputs.chatButtonTitleFont.map { $0.pointSize }.observe(self.chatButtonTitleFontSize.observer)
    self.vm.outputs.indicatorLineViewHidden.observe(self.indicatorLineViewHidden.observer)
    self.vm.outputs.indicatorLineViewXPosition.observe(self.indicatorLineViewXPosition.observer)
    self.vm.outputs.infoButtonTextColor.observe(self.infoButtonTextColor.observer)
    self.vm.outputs.infoButtonTitleFont.map { $0.fontName }.observe(self.infoButtonTitleFontName.observer)
    self.vm.outputs.infoButtonTitleFont.map { $0.pointSize }.observe(self.infoButtonTitleFontSize.observer)
    self.vm.outputs.loadViewControllersIntoPagesDataSource.observe(
      self.loadViewControllersIntoPagesDataSource.observer)
    self.vm.outputs.pagedToPage.map(first).observe(self.pagedToPage.observer)
    self.vm.outputs.pagedToPage.map(second).observe(self.pagedToPageDirection.observer)
    self.vm.outputs.pagerTabStripStackViewHidden.observe(self.pagerTabStripStackViewHidden.observer)
  }

  func testColors() {
    self.chatButtonTextColor.assertValueCount(0)
    self.infoButtonTextColor.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template,
                                 refTag: .projectPage, presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.didLoadViewControllersIntoPagesDataSource()

    self.chatButtonTextColor.assertValues([.ksr_grey_500])
    self.infoButtonTextColor.assertValues([.white])

    let infoPage = LiveStreamContainerPage.info(project: .template, liveStreamEvent: .template,
                                                refTag: .projectPage, presentedFromProject: true)
    let chatPage = LiveStreamContainerPage.chat(project: .template, liveStreamEvent: .template)

    self.vm.inputs.willTransition(toPage: chatPage)
    self.vm.inputs.pageTransition(completed: true)

    self.chatButtonTextColor.assertValues([.ksr_grey_500, .white])
    self.infoButtonTextColor.assertValues([.white, .ksr_grey_500])

    self.vm.inputs.willTransition(toPage: infoPage)
    self.vm.inputs.pageTransition(completed: true)

    self.chatButtonTextColor.assertValues([.ksr_grey_500, .white, .ksr_grey_500])
    self.infoButtonTextColor.assertValues([.white, .ksr_grey_500, .white])
  }

  func testFonts() {
    self.chatButtonTitleFontName.assertValueCount(0)
    self.infoButtonTitleFontSize.assertValueCount(0)
    self.infoButtonTitleFontName.assertValueCount(0)
    self.infoButtonTitleFontSize.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template,
                                 refTag: .projectPage, presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.didLoadViewControllersIntoPagesDataSource()

    let infoPage = LiveStreamContainerPage.info(project: .template, liveStreamEvent: .template,
                                                refTag: .projectPage, presentedFromProject: true)
    let chatPage = LiveStreamContainerPage.chat(project: .template, liveStreamEvent: .template)

    self.chatButtonTitleFontName.assertValues([".SFUIText"])
    self.chatButtonTitleFontSize.assertValues([14])
    self.infoButtonTitleFontName.assertValues([".SFUIText-Semibold"])
    self.infoButtonTitleFontSize.assertValues([14])

    self.vm.inputs.willTransition(toPage: chatPage)
    self.vm.inputs.pageTransition(completed: true)

    self.chatButtonTitleFontName.assertValues([".SFUIText", ".SFUIText-Semibold"])
    self.chatButtonTitleFontSize.assertValues([14, 14])
    self.infoButtonTitleFontName.assertValues([".SFUIText-Semibold", ".SFUIText"])
    self.infoButtonTitleFontSize.assertValues([14, 14])

    self.vm.inputs.willTransition(toPage: infoPage)
    self.vm.inputs.pageTransition(completed: true)

    self.chatButtonTitleFontName.assertValues([".SFUIText", ".SFUIText-Semibold", ".SFUIText"])
    self.chatButtonTitleFontSize.assertValues([14, 14, 14])
    self.infoButtonTitleFontName.assertValues([".SFUIText-Semibold", ".SFUIText", ".SFUIText-Semibold"])
    self.infoButtonTitleFontSize.assertValues([14, 14, 14])
  }

  func testPagedToPage() {
    self.pagedToPage.assertValueCount(0)
    self.pagedToPageDirection.assertValueCount(0)

    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template
    let refTag = RefTag.projectPage
    let presentedFromProject = true

    let infoPage = LiveStreamContainerPage.info(
      project: project,
      liveStreamEvent: liveStreamEvent,
      refTag: refTag,
      presentedFromProject: presentedFromProject
    )
    let chatPage = LiveStreamContainerPage.chat(project: project, liveStreamEvent: liveStreamEvent)

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: refTag,
                                 presentedFromProject: presentedFromProject)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.didLoadViewControllersIntoPagesDataSource()

    self.pagedToPage.assertValues([infoPage])
    self.pagedToPageDirection.assertValues([.forward])

    self.vm.inputs.chatButtonTapped()

    self.pagedToPage.assertValues([infoPage, chatPage])
    self.pagedToPageDirection.assertValues([.forward, .forward])

    self.vm.inputs.infoButtonTapped()

    self.pagedToPage.assertValues([infoPage, chatPage, infoPage])
    self.pagedToPageDirection.assertValues([.forward, .forward, .reverse])
  }

  func testLoadViewControllersIntoPagesDataSource_ChatFeatureFlagAbsent() {
    self.loadViewControllersIntoPagesDataSource.assertValueCount(0)

    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template
    let refTag = RefTag.projectPage
    let presentedFromProject = true

    let infoPage = LiveStreamContainerPage.info(
      project: project,
      liveStreamEvent: liveStreamEvent,
      refTag: refTag,
      presentedFromProject: presentedFromProject
    )
    let chatPage = LiveStreamContainerPage.chat(project: project, liveStreamEvent: liveStreamEvent)

    self.vm.inputs.configureWith(project: project,
                                 liveStreamEvent: liveStreamEvent,
                                 refTag: refTag,
                                 presentedFromProject: presentedFromProject)

    self.vm.inputs.viewDidLoad()

    self.loadViewControllersIntoPagesDataSource.assertValues([[infoPage, chatPage]])
  }

  func testLoadViewControllersIntoPagesDataSource_ChatFeatureFlagEnabled() {
    let config = .template
      |> Config.lens.features .~ ["ios_live_stream_chat": true]

    withEnvironment(config: config) {
      self.loadViewControllersIntoPagesDataSource.assertValueCount(0)

      let project = Project.template
      let liveStreamEvent = LiveStreamEvent.template
      let refTag = RefTag.projectPage
      let presentedFromProject = true

      let infoPage = LiveStreamContainerPage.info(
        project: project,
        liveStreamEvent: liveStreamEvent,
        refTag: refTag,
        presentedFromProject: presentedFromProject
      )
      let chatPage = LiveStreamContainerPage.chat(project: project, liveStreamEvent: liveStreamEvent)

      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: refTag,
                                   presentedFromProject: presentedFromProject)

      self.vm.inputs.viewDidLoad()

      self.loadViewControllersIntoPagesDataSource.assertValues([[infoPage, chatPage]])
    }
  }

  func testLoadViewControllersIntoPagesDataSource_ChatFeatureFlag_Disabled() {
    let config = .template
      |> Config.lens.features .~ ["ios_live_stream_chat": false]

    withEnvironment(config: config) {
      self.loadViewControllersIntoPagesDataSource.assertValueCount(0)

      let project = Project.template
      let liveStreamEvent = LiveStreamEvent.template
      let refTag = RefTag.projectPage
      let presentedFromProject = true

      let infoPage = LiveStreamContainerPage.info(
        project: project,
        liveStreamEvent: liveStreamEvent,
        refTag: refTag,
        presentedFromProject: presentedFromProject
      )

      self.vm.inputs.configureWith(project: project,
                                   liveStreamEvent: liveStreamEvent,
                                   refTag: refTag,
                                   presentedFromProject: presentedFromProject)

      self.vm.inputs.viewDidLoad()

      self.loadViewControllersIntoPagesDataSource.assertValues([[infoPage]])
    }
  }

  func testIndicatorLineViewXPosition() {
    self.indicatorLineViewXPosition.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template,
                                 refTag: .projectPage, presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.didLoadViewControllersIntoPagesDataSource()

    let infoPage = LiveStreamContainerPage.info(project: .template, liveStreamEvent: .template,
                                                refTag: .projectPage, presentedFromProject: true)
    let chatPage = LiveStreamContainerPage.chat(project: .template, liveStreamEvent: .template)

    self.indicatorLineViewXPosition.assertValues([0])

    self.vm.inputs.willTransition(toPage: chatPage)
    self.vm.inputs.pageTransition(completed: true)

    self.indicatorLineViewXPosition.assertValues([0, 1])

    self.vm.inputs.willTransition(toPage: infoPage)
    self.vm.inputs.pageTransition(completed: true)

    self.indicatorLineViewXPosition.assertValues([0, 1, 0])
  }

  func testViewsHidden_ChatFeatureFlagEnabled() {
    let config = .template
      |> Config.lens.features .~ ["ios_live_stream_chat": true]

    withEnvironment(config: config) {
      self.pagerTabStripStackViewHidden.assertValueCount(0)
      self.indicatorLineViewHidden.assertValueCount(0)

      self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template,
                                   refTag: .projectPage, presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.pagerTabStripStackViewHidden.assertValues([false])
      self.indicatorLineViewHidden.assertValues([false])
    }
  }

  func testViewsHidden_ChatFeatureFlagDisabled() {
    let config = .template
      |> Config.lens.features .~ ["ios_live_stream_chat": false]

    withEnvironment(config: config) {
      self.pagerTabStripStackViewHidden.assertValueCount(0)
      self.indicatorLineViewHidden.assertValueCount(0)

      self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template,
                                   refTag: .projectPage, presentedFromProject: true)
      self.vm.inputs.viewDidLoad()

      self.pagerTabStripStackViewHidden.assertValues([true])
      self.indicatorLineViewHidden.assertValues([true])
    }
  }

  func testViewsHidden_ChatFeatureFlagAbsent() {
    self.pagerTabStripStackViewHidden.assertValueCount(0)
    self.indicatorLineViewHidden.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template,
                                 refTag: .projectPage, presentedFromProject: true)
    self.vm.inputs.viewDidLoad()

    self.pagerTabStripStackViewHidden.assertValues([false])
    self.indicatorLineViewHidden.assertValues([false])
  }
}
