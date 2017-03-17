import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class BackerDashboardViewModelTests: TestCase {
  private let vm: BackerDashboardViewModelType = BackerDashboardViewModel()

  private let avatarURL = TestObserver<String, NoError>()
  private let backedButtonTitleText = TestObserver<String, NoError>()
  private let backerLocationText = TestObserver<String, NoError>()
  private let backerNameText = TestObserver<String, NoError>()
  private let configurePagesDataSourceTab = TestObserver<BackerDashboardTab, NoError>()
  private let configurePagesDataSourceSort = TestObserver<DiscoveryParams.Sort, NoError>()
  private let embeddedViewTopConstraintConstant = TestObserver<CGFloat, NoError>()
  private let goToMessages = TestObserver<(), NoError>()
  private let goToProject = TestObserver<Project, NoError>()
  private let goToSettings = TestObserver<(), NoError>()
  private let navigateToTab = TestObserver<BackerDashboardTab, NoError>()
  private let notifyPageToScrollToProject = TestObserver<Int, NoError>()
  private let pinSelectedIndicatorToTab = TestObserver<BackerDashboardTab, NoError>()
  private let pinSelectedIndicatorToTabAnimated = TestObserver<Bool, NoError>()
  private let savedButtonTitleText = TestObserver<String, NoError>()
  private let setSelectedButton = TestObserver<BackerDashboardTab, NoError>()
  private let sortBarIsHidden = TestObserver<Bool, NoError>()
  private let updateProjectPlaylist = TestObserver<[Project], NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.avatarURL.map { $0?.absoluteString ?? "" }.observe(self.avatarURL.observer)
    self.vm.outputs.backedButtonTitleText.observe(self.backedButtonTitleText.observer)
    self.vm.outputs.backerLocationText.observe(self.backerLocationText.observer)
    self.vm.outputs.backerNameText.observe(self.backerNameText.observer)
    self.vm.outputs.configurePagesDataSource.map(first).observe(self.configurePagesDataSourceTab.observer)
    self.vm.outputs.configurePagesDataSource.map(second).observe(self.configurePagesDataSourceSort.observer)
    self.vm.outputs.embeddedViewTopConstraintConstant.observe(self.embeddedViewTopConstraintConstant.observer)
    self.vm.outputs.goToMessages.observe(self.goToMessages.observer)
    self.vm.outputs.goToProject.map(first).observe(self.goToProject.observer)
    self.vm.outputs.goToSettings.observe(self.goToSettings.observer)
    self.vm.outputs.navigateToTab.observe(self.navigateToTab.observer)
    self.vm.outputs.notifyPageToScrollToProject.observe(self.notifyPageToScrollToProject.observer)
    self.vm.outputs.pinSelectedIndicatorToTab.map(first).observe(self.pinSelectedIndicatorToTab.observer)
    self.vm.outputs.pinSelectedIndicatorToTab.map(second)
      .observe(self.pinSelectedIndicatorToTabAnimated.observer)
    self.vm.outputs.savedButtonTitleText.observe(self.savedButtonTitleText.observer)
    self.vm.outputs.setSelectedButton.observe(self.setSelectedButton.observer)
    self.vm.outputs.sortBarIsHidden.observe(self.sortBarIsHidden.observer)
    self.vm.outputs.updateProjectPlaylist.observe(self.updateProjectPlaylist.observer)
  }

  func testUserAndHeaderDisplayData() {
    let location = Location.template
      |> Location.lens.displayableName .~ "Siberia"

    let user = .template
      |> User.lens.name .~ "Princess Vespa"
      |> User.lens.location .~ location
      |> User.lens.stats.backedProjectsCount .~ 45
      |> User.lens.stats.starredProjectsCount .~ 58
      |> User.lens.avatar.large .~ "http://cats.com/furball.jpg"

    withEnvironment(apiService: MockService(fetchUserSelfResponse: user)) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

      self.avatarURL.assertValueCount(0)
      self.backedButtonTitleText.assertValueCount(0)
      self.backerLocationText.assertValueCount(0)
      self.backerNameText.assertValueCount(0)
      self.pinSelectedIndicatorToTab.assertValueCount(0)
      self.pinSelectedIndicatorToTabAnimated.assertValueCount(0)
      self.savedButtonTitleText.assertValueCount(0)
      self.setSelectedButton.assertValueCount(0)
      self.sortBarIsHidden.assertValueCount(0)

      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(false)

      self.scheduler.advance()

      // Signals emit twice as they are prefixed with the current user data.
      self.avatarURL.assertValues(["http://cats.com/furball.jpg", "http://cats.com/furball.jpg"])
      self.backedButtonTitleText.assertValues(["45\nbacked", "45\nbacked"])
      self.backerLocationText.assertValues(["Siberia", "Siberia"])
      self.backerNameText.assertValues(["Princess Vespa", "Princess Vespa"])
      self.pinSelectedIndicatorToTab.assertValues([.backed, .backed])
      self.pinSelectedIndicatorToTabAnimated.assertValues([false, false])
      self.savedButtonTitleText.assertValues(["58\nsaved", "58\nsaved"])
      self.setSelectedButton.assertValues([.backed])
      self.sortBarIsHidden.assertValues([true])
      self.embeddedViewTopConstraintConstant.assertValues([0.0])
    }
  }

  func testConfigurePagesData() {
    self.configurePagesDataSourceTab.assertValueCount(0)
    self.configurePagesDataSourceSort.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.configurePagesDataSourceTab.assertValues([.backed])
    self.configurePagesDataSourceSort.assertValues([.endingSoon])
  }

  func testTabNavigation() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(false)

    self.navigateToTab.assertValueCount(0)
    self.setSelectedButton.assertValues([.backed])
    self.pinSelectedIndicatorToTab.assertValues([.backed])
    self.pinSelectedIndicatorToTabAnimated.assertValues([false])

    self.vm.inputs.savedProjectsButtonTapped()

    self.navigateToTab.assertValues([.saved])
    self.setSelectedButton.assertValues([.backed, .saved])
    self.pinSelectedIndicatorToTab.assertValues([.backed, .saved])
    self.pinSelectedIndicatorToTabAnimated.assertValues([false, true])

    self.vm.inputs.backedProjectsButtonTapped()

    self.navigateToTab.assertValues([.saved, .backed])
    self.setSelectedButton.assertValues([.backed, .saved, .backed])
    self.pinSelectedIndicatorToTab.assertValues([.backed, .saved, .backed])
    self.pinSelectedIndicatorToTabAnimated.assertValues([false, true, true])
  }

  func testGoPlaces() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(false)

    self.goToProject.assertValueCount(0)

    self.vm.inputs.profileProjectsGoToProject(.template, projects: [.template], reftag: .profileBacked)

    self.goToProject.assertValues([.template])
    self.goToSettings.assertValueCount(0)

    self.vm.inputs.settingsButtonTapped()

    self.goToSettings.assertValueCount(1)
    self.goToMessages.assertValueCount(0)

    self.vm.inputs.messagesButtonTapped()

    self.goToMessages.assertValueCount(1)
  }

  func testUpdatePlaylist_AndNotifyPageToScroll() {
    let projects = [.template, .template |> Project.lens.id .~ 2]

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(false)
    self.vm.inputs.profileProjectsUpdatePlaylist(projects)

    self.updateProjectPlaylist.assertValues([projects])

    self.vm.inputs.transitionedToProject(at: 1)

    self.notifyPageToScrollToProject.assertValues([1])
  }

  func testTracking() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(false)

    XCTAssertEqual(["Profile View My", "Viewed Profile"], self.trackingClient.events)

    self.vm.inputs.viewWillAppear(true)

    XCTAssertEqual(["Profile View My", "Viewed Profile"], self.trackingClient.events,
                   "Tracking does not emit")

    self.vm.inputs.backedProjectsButtonTapped()

    XCTAssertEqual(["Profile View My", "Viewed Profile", "Viewed Profile Backed Tab"],
                   self.trackingClient.events)

    self.vm.inputs.savedProjectsButtonTapped()

    XCTAssertEqual(["Profile View My", "Viewed Profile", "Viewed Profile Backed Tab",
                    "Viewed Profile Saved Tab"], self.trackingClient.events)
  }
}
