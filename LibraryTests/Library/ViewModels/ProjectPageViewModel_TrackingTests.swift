import AVFoundation
@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ProjectPageViewModel_TrackingTests: TestCase {
  fileprivate var vm: ProjectPageViewModelType!

  internal override func setUp() {
    super.setUp()

    self.vm = ProjectPageViewModel()
  }

  // Tests that ref tags and referral credit cookies are tracked and saved like we expect.
  func testTracksRefTag() {
    let project = Project.template
    let projectPamphletData = Project.ProjectPamphletData(project: .template, backingId: nil)

    withEnvironment(apiService: MockService(
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success([
        Reward.noReward,
        Reward.template
      ])
    )) {
      self.vm.inputs.configureWith(projectOrParam: .left(project), refInfo: RefInfo(.category))
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear(animated: false)

      self.scheduler.advance()

      XCTAssertEqual(
        ["Page Viewed"],
        self.segmentTrackingClient.events, "A project page event is tracked."
      )

      XCTAssertEqual(
        [RefTag.category.stringTag],
        self.segmentTrackingClient.properties.compactMap { $0["session_ref_tag"] as? String },
        "The ref tag is tracked in the event."
      )
      XCTAssertEqual(
        1, self.cookieStorage.cookies?.count,
        "A single cookie is set"
      )
      XCTAssertEqual(
        "ref_\(project.id)", self.cookieStorage.cookies?.last?.name,
        "A referral cookie is set for the project."
      )
      XCTAssertEqual(
        "category?",
        (self.cookieStorage.cookies?.last?.value.prefix(9)).map(String.init),
        "A referral cookie is set for the category ref tag."
      )

      // Start up another view model with the same project
      let newVm: ProjectPageViewModelType = ProjectPageViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refInfo: RefInfo(.recommended))
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewDidAppear(animated: true)

      self.scheduler.advance()

      XCTAssertEqual(
        [
          "Page Viewed", "Page Viewed"
        ],
        self.segmentTrackingClient.events, "A project page event is tracked."
      )

      XCTAssertEqual(
        [
          RefTag.category.stringTag,
          RefTag.recommended.stringTag
        ],
        self.segmentTrackingClient.properties.compactMap { $0["session_ref_tag"] as? String },
        "The new ref tag is tracked in an event."
      )
      XCTAssertEqual(
        1, self.cookieStorage.cookies?.count,
        "A single cookie has been set."
      )
    }
  }

  // Tests that ref tags for similar projects and referral credit cookies are tracked and saved like we expect.
  func testTracksRefTag_SimilarProjects() {
    let project = Project.template
    let projectPamphletData = Project.ProjectPamphletData(project: .template, backingId: nil)

    withEnvironment(apiService: MockService(
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success([
        Reward.noReward,
        Reward.template
      ])
    )) {
      self.vm.inputs.configureWith(projectOrParam: .left(project), refInfo: RefInfo(.similarProjects))
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear(animated: false)

      self.scheduler.advance()

      XCTAssertEqual(
        ["Page Viewed"],
        self.segmentTrackingClient.events, "A project page event is tracked."
      )

      XCTAssertEqual(
        [RefTag.similarProjects.stringTag],
        self.segmentTrackingClient.properties.compactMap { $0["session_ref_tag"] as? String },
        "The ref tag is tracked in the event."
      )
      XCTAssertEqual(
        1, self.cookieStorage.cookies?.count,
        "A single cookie is set"
      )
      XCTAssertEqual(
        "ref_\(project.id)", self.cookieStorage.cookies?.last?.name,
        "A referral cookie is set for the project."
      )

      // Start up another view model with the same project
      let newVm: ProjectPageViewModelType = ProjectPageViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refInfo: RefInfo(.recommended))
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewDidAppear(animated: true)

      self.scheduler.advance()

      XCTAssertEqual(
        [
          "Page Viewed", "Page Viewed"
        ],
        self.segmentTrackingClient.events, "A project page event is tracked."
      )

      XCTAssertEqual(
        [
          RefTag.similarProjects.stringTag,
          RefTag.recommended.stringTag
        ],
        self.segmentTrackingClient.properties.compactMap { $0["session_ref_tag"] as? String },
        "The new ref tag is tracked in an event."
      )
      XCTAssertEqual(
        1, self.cookieStorage.cookies?.count,
        "A single cookie has been set."
      )
    }
  }

  func testProjectPageViewed_Tracking_OnError() {
    let service = MockService(fetchProjectPamphletResult: .failure(.couldNotParseJSON))

    withEnvironment(apiService: service) {
      self.configureInitialState(.init(left: .template))

      self.scheduler.advance()

      XCTAssertEqual(
        [],
        self.segmentTrackingClient.events,
        "Project Page Viewed doesnt track if the request fails"
      )
    }
  }

  func testProjectPageViewed_OnViewDidAppear() {
    let projectPamphletData = Project.ProjectPamphletData(project: .template, backingId: nil)

    withEnvironment(apiService: MockService(
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success([Reward.noReward, Reward.template])
    )) {
      XCTAssertEqual([], self.segmentTrackingClient.events)

      self.configureInitialState(.init(left: .template))

      self.scheduler.advance()

      XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)

      XCTAssertEqual(["project"], self.segmentTrackingClient.properties(forKey: "context_page"))
      XCTAssertEqual(["overview"], self.segmentTrackingClient.properties(forKey: "context_section"))
      XCTAssertEqual(["discovery"], self.segmentTrackingClient.properties(forKey: "session_ref_tag"))
    }
  }

  func testMockCookieStorageSet_SeparateSchedulers() {
    let project = Project.template
    let scheduler1 = TestScheduler(startDate: MockDate().date)
    let scheduler2 = TestScheduler(startDate: scheduler1.currentDate.addingTimeInterval(1))
    let projectPamphletData = Project.ProjectPamphletData(project: .template, backingId: nil)

    withEnvironment(
      apiService: MockService(
        fetchProjectPamphletResult: .success(projectPamphletData),
        fetchProjectRewardsResult: .success([.template])
      ),
      scheduler: scheduler1
    ) {
      let newVm: ProjectPageViewModelType = ProjectPageViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refInfo: RefInfo(.category))
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewDidAppear(animated: true)

      scheduler1.advance()

      XCTAssertEqual(1, self.cookieStorage.cookies?.count, "A single cookie has been set.")
    }

    withEnvironment(
      apiService: MockService(
        fetchProjectPamphletResult: .success(projectPamphletData),
        fetchProjectRewardsResult: .success([.template])
      ),
      scheduler: scheduler2
    ) {
      let newVm: ProjectPageViewModelType = ProjectPageViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refInfo: RefInfo(.recommended))
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewDidAppear(animated: true)

      scheduler2.advance()

      XCTAssertEqual(2, self.cookieStorage.cookies?.count, "Two cookies are set on separate schedulers.")
    }
  }

  func testMockCookieStorageSet_SameScheduler() {
    let project = Project.template
    let scheduler1 = TestScheduler(startDate: MockDate().date)

    withEnvironment(scheduler: scheduler1) {
      let newVm: ProjectPageViewModelType = ProjectPageViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refInfo: RefInfo(.category))
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewDidAppear(animated: true)

      scheduler1.advance()

      XCTAssertEqual(1, self.cookieStorage.cookies?.count, "A single cookie has been set.")
    }

    withEnvironment(scheduler: scheduler1) {
      let newVm: ProjectPageViewModelType = ProjectPageViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refInfo: RefInfo(.recommended))
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewDidAppear(animated: true)

      scheduler1.advance()

      XCTAssertEqual(
        1, self.cookieStorage.cookies?.count,
        "A single cookie has been set on the same scheduler."
      )
    }
  }

  func testTracksRefTag_WithBadData() {
    let project = Project.template
    let projectPamphletData = Project.ProjectPamphletData(project: .template, backingId: nil)

    withEnvironment(apiService: MockService(
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectFriendsResult: .success([.template]),
      fetchProjectRewardsResult: .success([.template])
    )) {
      self.vm.inputs.configureWith(
        projectOrParam: .left(project), refInfo: RefInfo(.unrecognized("category%3F1232"))
      )
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear(animated: false)

      self.scheduler.advance()

      XCTAssertEqual(
        ["Page Viewed"],
        self.segmentTrackingClient.events, "A project page event is tracked."
      )

      XCTAssertEqual(
        [RefTag.category.stringTag],
        self.segmentTrackingClient.properties.compactMap { $0["session_ref_tag"] as? String },
        "The ref tag is tracked in the event."
      )
      XCTAssertEqual(
        1, self.cookieStorage.cookies?.count,
        "A single cookie is set"
      )
      XCTAssertEqual(
        "ref_\(project.id)", self.cookieStorage.cookies?.last?.name,
        "A referral cookie is set for the project."
      )
      XCTAssertEqual(
        "category?",
        (self.cookieStorage.cookies?.last?.value.prefix(9)).map(String.init),
        "A referral cookie is set for the category ref tag."
      )

      // Start up another view model with the same project
      let newVm: ProjectPageViewModelType = ProjectPageViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refInfo: RefInfo(.recommended))
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewDidAppear(animated: true)

      self.scheduler.advance()

      XCTAssertEqual(
        [
          "Page Viewed", "Page Viewed"
        ],
        self.segmentTrackingClient.events, "A project page event is tracked."
      )

      XCTAssertEqual(
        [
          RefTag.category.stringTag,
          RefTag.recommended.stringTag
        ],
        self.segmentTrackingClient.properties.compactMap { $0["session_ref_tag"] as? String },
        "The new ref tag is tracked in an event."
      )
      XCTAssertEqual(
        1, self.cookieStorage.cookies?.count,
        "A single cookie has been set."
      )
    }
  }

  func testTrackingDoesNotOccurOnLoad() {
    let project = Project.template

    self.vm.inputs.configureWith(
      projectOrParam: .left(project), refInfo: RefInfo(.unrecognized("category%3F1232"))
    )
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    XCTAssertEqual([], self.segmentTrackingClient.events)
  }

  func testTrackingProjectPageViewed_LoggedIn_AdvertisingConsentNotAllowed_EventsNotTracked() {
    let segmentClient = MockTrackingClient()
    let appTrackingTransparency = MockAppTrackingTransparency()
    appTrackingTransparency.shouldRequestAuthStatus = false
    let ksrAnalytics = KSRAnalytics(
      config: .template,
      loggedInUser: User.template,
      segmentClient: segmentClient,
      appTrackingTransparency: appTrackingTransparency
    )

    let projectPamphletData = Project.ProjectPamphletData(project: .template, backingId: nil)

    withEnvironment(
      apiService: MockService(
        fetchProjectPamphletResult: .success(projectPamphletData),
        fetchProjectRewardsResult: .success([Reward.noReward, Reward.template])
      ),
      currentUser: User.template,
      ksrAnalytics: ksrAnalytics
    ) {
      self.vm.inputs.configureWith(projectOrParam: .left(.template), refInfo: RefInfo(.discovery))
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear(animated: false)

      self.scheduler.advance()

      XCTAssertEqual(segmentClient.events, [])
    }
  }

  func testTrackingProjectPageViewed_LoggedIn_AdvertisingConsentAllowed_EventsTracked() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      config: .template,
      loggedInUser: User.template,
      segmentClient: segmentClient,
      appTrackingTransparency: MockAppTrackingTransparency()
    )

    let projectPamphletData = Project.ProjectPamphletData(project: .template, backingId: nil)

    withEnvironment(
      apiService: MockService(
        fetchProjectPamphletResult: .success(projectPamphletData),
        fetchProjectRewardsResult: .success([Reward.noReward, Reward.template])
      ),
      currentUser: User.template,
      ksrAnalytics: ksrAnalytics
    ) {
      self.vm.inputs.configureWith(projectOrParam: .left(.template), refInfo: RefInfo(.discovery))
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear(animated: false)

      self.scheduler.advance()

      XCTAssertEqual(segmentClient.events, ["Page Viewed"])

      XCTAssertEqual(segmentClient.properties(forKey: "session_user_is_logged_in", as: Bool.self), [true])
      XCTAssertEqual(segmentClient.properties(forKey: "user_uid", as: String.self), ["1"])
      XCTAssertEqual(segmentClient.properties(forKey: "session_ref_tag"), ["discovery"])
      XCTAssertEqual(segmentClient.properties(forKey: "project_subcategory"), ["Ceramics"])
      XCTAssertEqual(segmentClient.properties(forKey: "project_category"), ["Art"])
      XCTAssertEqual(segmentClient.properties(forKey: "project_country"), ["US"])
      XCTAssertEqual(segmentClient.properties(forKey: "project_user_has_watched", as: Bool.self), [nil])
    }
  }

  func testTrackingProjectPageViewed_LoggedOut() {
    let config = Config.template
      |> \.countryCode .~ "GB"

    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      config: config,
      loggedInUser: nil,
      segmentClient: segmentClient,
      appTrackingTransparency: MockAppTrackingTransparency()
    )

    let projectPamphletData = Project.ProjectPamphletData(project: .template, backingId: nil)

    withEnvironment(
      apiService: MockService(
        fetchProjectPamphletResult: .success(projectPamphletData),
        fetchProjectRewardsResult: .success([Reward.noReward, Reward.template])
      ),
      currentUser: nil,
      ksrAnalytics: ksrAnalytics
    ) {
      self.vm.inputs.configureWith(projectOrParam: .left(.template), refInfo: RefInfo(.discovery))
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear(animated: false)

      self.scheduler.advance()

      XCTAssertEqual(segmentClient.events, ["Page Viewed"])

      XCTAssertEqual(segmentClient.properties(forKey: "session_ref_tag"), ["discovery"])

      XCTAssertEqual(segmentClient.properties(forKey: "session_user_is_logged_in", as: Bool.self), [false])
      XCTAssertEqual(segmentClient.properties(forKey: "user_uid", as: Int.self), [nil])
      XCTAssertEqual(segmentClient.properties(forKey: "project_subcategory"), ["Ceramics"])
      XCTAssertEqual(segmentClient.properties(forKey: "project_category"), ["Art"])
      XCTAssertEqual(segmentClient.properties(forKey: "project_country"), ["US"])
      XCTAssertEqual(segmentClient.properties(forKey: "project_user_has_watched", as: Bool.self), [nil])
    }
  }

  func testTrackUserBlockedFromProject_EventsEmitted() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      config: .template,
      loggedInUser: User.template,
      segmentClient: segmentClient,
      appTrackingTransparency: MockAppTrackingTransparency()
    )

    let projectPamphletData = Project.ProjectPamphletData(project: .template, backingId: nil)

    withEnvironment(
      apiService: MockService(
        blockUserResult: .success(EmptyResponseEnvelope()),
        fetchProjectPamphletResult: .success(projectPamphletData)
      ),
      currentUser: User.template,
      ksrAnalytics: ksrAnalytics
    ) {
      self.vm.inputs.configureWith(projectOrParam: .left(.template), refInfo: RefInfo(.discovery))
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear(animated: false)
      self.vm.inputs.blockUser(id: 111)

      self.scheduler.advance()

      XCTAssertEqual(segmentClient.events, ["CTA Clicked", "CTA Clicked"])

      XCTAssertEqual(
        segmentClient.properties(forKey: "session_user_is_logged_in", as: Bool.self),
        [true, true]
      )
      XCTAssertEqual(segmentClient.properties(forKey: "user_uid", as: String.self), ["1", "1"])
      XCTAssertEqual(segmentClient.properties(forKey: "context_cta"), ["block_user", "block_user"])
      XCTAssertEqual(
        segmentClient.properties(forKey: "context_location"),
        ["creator_details_menu", "creator_details_menu"]
      )
      XCTAssertEqual(segmentClient.properties(forKey: "context_page"), ["project", "project"])
      XCTAssertEqual(segmentClient.properties(forKey: "context_section"), ["overview", "overview"])
      XCTAssertEqual(segmentClient.properties(forKey: "context_type"), ["initiate", "confirm"])
      XCTAssertEqual(segmentClient.properties(forKey: "interaction_target_uid"), ["111", "111"])
    }
  }

  // MARK: - Functions

  private func configureInitialState(
    _ projectOrParam: Either<Project, any ProjectPageParam>,
    secretRewardToken: String? = nil
  ) {
    self.vm.inputs.configureWith(
      projectOrParam: projectOrParam,
      refInfo: RefInfo(.discovery),
      secretRewardToken: secretRewardToken
    )
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear(animated: false)
  }
}
