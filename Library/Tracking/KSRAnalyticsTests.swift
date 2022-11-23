@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class KSRAnalyticsTests: TestCase {
  // MARK: - Session Properties Tests

  func testSessionProperties() {
    let bundle = MockBundle()
    let segmentClient = MockTrackingClient()
    let config = Config.template
      |> Config.lens.countryCode .~ "GB"
      |> Config.lens.locale .~ "en"
      |> Config.lens.abExperiments .~ [
        "native_checkout": "experimental",
        "other_experiment": "control"
      ]
      |> Config.lens.features .~ [
        "android_flag": true,
        "ios_feature_something": false,
        "ios_enabled_feature": true
      ]
    let device = MockDevice(userInterfaceIdiom: .phone)
    let screen = MockScreen()
    let ksrAnalytics = KSRAnalytics(
      bundle: bundle,
      config: config,
      device: device,
      loggedInUser: nil,
      screen: screen,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(
      ["native_checkout[experimental]", "other_experiment[control]"],
      segmentClientProperties?["session_variants_internal"] as? [String]
    )

    XCTAssertEqual("native", segmentClientProperties?["session_client"] as? String)
    XCTAssertEqual(1_234_567_890, segmentClientProperties?["session_app_build_number"] as? Int)
    XCTAssertEqual("1.2.3.4.5.6.7.8.9.0", segmentClientProperties?["session_app_release_version"] as? String)
    XCTAssertEqual("phone", segmentClientProperties?["session_device_type"] as? String)
    XCTAssertEqual("portrait", segmentClientProperties?["session_device_orientation"] as? String)

    XCTAssertEqual("ios", segmentClientProperties?["session_os"] as? String)
    XCTAssertEqual(false, segmentClientProperties?["session_user_is_logged_in"] as? Bool)
    XCTAssertEqual("native_ios", segmentClientProperties?["session_platform"] as? String)
    XCTAssertEqual("en", segmentClientProperties?["session_display_language"] as? String)
    XCTAssertEqual("GB", segmentClientProperties?["session_country"] as? String)

    XCTAssertEqual(14, segmentClientProperties?.keys.filter { $0.hasPrefix("session_") }.count)
  }

  func testSessionProperties_OptimizelyClient() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.allKnownExperiments .~ [
        OptimizelyExperiment.Key.nativeProjectCards.rawValue
      ]

    withEnvironment(optimizelyClient: optimizelyClient) {
      let segmentClient = MockTrackingClient()
      let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

      ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

      XCTAssertEqual(
        [["native_project_cards": "control"]],
        segmentClient.properties.last?["session_variants_optimizely"] as? [[String: String]]
      )
    }
  }

  func testSessionProperties_Language() {
    withEnvironment(language: Language.es) {
      let segmentClient = MockTrackingClient()
      let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

      ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

      XCTAssertEqual("es", segmentClient.properties.last?["session_display_language"] as? String)
    }
  }

  func testSessionProperties_VoiceOver() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    withEnvironment(isVoiceOverRunning: { true }) {
      ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

      let segmentClientProperties = segmentClient.properties.last

      XCTAssertEqual(true, segmentClientProperties?["session_is_voiceover_running"] as? Bool)
    }

    withEnvironment(isVoiceOverRunning: { false }) {
      ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

      let segmentClientProperties = segmentClient.properties.last

      XCTAssertEqual(false, segmentClientProperties?["session_is_voiceover_running"] as? Bool)
    }
  }

  func testSessionProperties_LoggedIn() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: User.template,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(true, segmentClientProperties?["session_user_is_logged_in"] as? Bool)
  }

  func testSessionProperties_DeviceFormatAndClientPlatform_ForIPhoneIdiom() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      device: MockDevice(userInterfaceIdiom: .phone),
      loggedInUser: nil,
      segmentClient: segmentClient
    )
    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    XCTAssertEqual("phone", segmentClient.properties.last?["session_device_type"] as? String)
    XCTAssertEqual("native_ios", segmentClient.properties.last?["session_platform"] as? String)
  }

  func testSessionProperties_DeviceFormatAndClientPlatform_ForIPadIdiom() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      device: MockDevice(userInterfaceIdiom: .pad),
      loggedInUser: nil,
      segmentClient: segmentClient
    )
    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    XCTAssertEqual("tablet", segmentClient.properties.last?["session_device_type"] as? String)
    XCTAssertEqual("native_ios", segmentClient.properties.last?["session_platform"] as? String)
  }

  func testSessionProperties_DeviceFormatAndClientPlatform_ForTvIdiom() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      device: MockDevice(userInterfaceIdiom: .tv),
      loggedInUser: nil,
      segmentClient: segmentClient
    )
    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    XCTAssertEqual("tv", segmentClient.properties.last?["session_device_type"] as? String)
    XCTAssertEqual("tvos", segmentClient.properties.last?["session_platform"] as? String)
  }

  func testSessionProperties_DeviceOrientation_FaceDown() {
    let segmentClient = MockTrackingClient()
    let device = MockDevice(orientation: .faceDown)
    let ksrAnalytics = KSRAnalytics(
      device: device,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    XCTAssertEqual("face_down", segmentClient.properties.last?["session_device_orientation"] as? String)
  }

  func testSessionProperties_DeviceOrientation_FaceUp() {
    let segmentClient = MockTrackingClient()
    let device = MockDevice(orientation: .faceUp)
    let ksrAnalytics = KSRAnalytics(
      device: device,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    XCTAssertEqual("face_up", segmentClient.properties.last?["session_device_orientation"] as? String)
  }

  func testSessionProperties_DeviceOrientation_LandscapeLeft() {
    let segmentClient = MockTrackingClient()
    let device = MockDevice(orientation: .landscapeLeft)
    let ksrAnalytics = KSRAnalytics(
      device: device,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    XCTAssertEqual("landscape_left", segmentClient.properties.last?["session_device_orientation"] as? String)
  }

  func testSessionProperties_DeviceOrientation_LandscapeRight() {
    let segmentClient = MockTrackingClient()
    let device = MockDevice(orientation: .landscapeRight)
    let ksrAnalytics = KSRAnalytics(
      device: device,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    XCTAssertEqual("landscape_right", segmentClient.properties.last?["session_device_orientation"] as? String)
  }

  func testSessionProperties_DeviceOrientation_Portrait() {
    let segmentClient = MockTrackingClient()
    let device = MockDevice(orientation: .portrait)
    let ksrAnalytics = KSRAnalytics(
      device: device,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    XCTAssertEqual("portrait", segmentClient.properties.last?["session_device_orientation"] as? String)
  }

  func testSessionProperties_DeviceOrientation_PortraitUpsideDown() {
    let segmentClient = MockTrackingClient()
    let device = MockDevice(orientation: .portraitUpsideDown)
    let ksrAnalytics = KSRAnalytics(
      device: device,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    XCTAssertEqual(
      "portrait_upside_down",
      segmentClient.properties.last?["session_device_orientation"] as? String
    )
  }

  func testSessionProperties_DeviceOrientation_Unknown() {
    let segmentClient = MockTrackingClient()
    let device = MockDevice(orientation: .unknown)
    let ksrAnalytics = KSRAnalytics(
      device: device,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    XCTAssertEqual("unknown", segmentClient.properties.last?["session_device_orientation"] as? String)
  }

  // MARK: - Login & Signup Tests

  func testTrackLoginSubmitButtonClicked() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: nil,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackLoginSubmitButtonClicked()

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("log_in", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("log_in_submit", segmentClient.properties.last?["context_cta"] as? String)
  }

  func testTrackSignupSubmitButtonClicked() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: nil,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackSignupSubmitButtonClicked(isSubscribed: true)

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("sign_up", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("sign_up_submit", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("subscription_true", segmentClient.properties.last?["context_type"] as? String)
  }

  func testTrackSignupPageViewed() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: nil,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackSignupPageViewed()

    XCTAssertEqual(["Page Viewed"], segmentClient.events)
    XCTAssertEqual("sign_up", segmentClient.properties.last?["context_page"] as? String)
  }

  func testTrackLoginPageViewed() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: nil,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackLoginPageViewed()

    XCTAssertEqual(["Page Viewed"], segmentClient.events)
    XCTAssertEqual("log_in", segmentClient.properties.last?["context_page"] as? String)
  }

  // MARK: - Project Properties Tests

  func testProjectProperties() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: nil,
      segmentClient: segmentClient
    )
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [Reward.template, .noReward]
      |> \.category .~ (.illustration
        |> \.id .~ 123
        |> \.parentId .~ 321
      )
      |> Project.lens.stats.staticUsdRate .~ 2.0
      |> Project.lens.stats.commentsCount .~ 10
      |> Project.lens.prelaunchActivated .~ true
      |> Project.lens.displayPrelaunch .~ true

    ksrAnalytics
      .trackProjectViewed(project, refTag: .discovery, sectionContext: .overview)

    XCTAssertEqual(1, segmentClient.properties.count)

    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual("Page Viewed", segmentClient.events.last)
    XCTAssertEqual(project.stats.backersCount, segmentClientProperties?["project_backers_count"] as? Int)
    XCTAssertEqual(project.country.currencyCode, segmentClientProperties?["project_currency"] as? String)
    XCTAssertEqual(String(project.id), segmentClientProperties?["project_pid"] as? String)
    XCTAssertEqual(
      project.stats.percentFunded,
      segmentClientProperties?["project_percent_raised"] as? Int
    )
    XCTAssertEqual(project.category.analyticsName, segmentClientProperties?["project_subcategory"] as? String)
    XCTAssertEqual("Art", segmentClientProperties?["project_category"] as? String)
    XCTAssertEqual(String(project.creator.id), segmentClientProperties?["project_creator_uid"] as? String)
    XCTAssertEqual(24 * 15, segmentClientProperties?["project_hours_remaining"] as? Int)
    XCTAssertEqual(30, segmentClientProperties?["project_duration"] as? Int)
    XCTAssertEqual(
      "2016-10-16T22:35:15Z",
      segmentClientProperties?["project_deadline"] as? String
    )
    XCTAssertEqual(
      "2016-09-16T22:35:15Z",
      segmentClientProperties?["project_launched_at"] as? String
    )
    XCTAssertEqual("live", segmentClientProperties?["project_state"] as? String)
    XCTAssertEqual(project.stats.pledged, segmentClientProperties?["project_current_pledge_amount"] as? Int)
    XCTAssertEqual(1_213.75, segmentClientProperties?["project_current_amount_pledged_usd"] as? Decimal)
    XCTAssertEqual(2_427.5, segmentClientProperties?["project_goal_usd"] as? Decimal)
    XCTAssertEqual(false, segmentClientProperties?["project_has_add_ons"] as? Bool)
    XCTAssertEqual(true, segmentClientProperties?["project_has_video"] as? Bool)
    XCTAssertEqual(10, segmentClientProperties?["project_comments_count"] as? Int)
    XCTAssertEqual(true, segmentClientProperties?["project_prelaunch_activated"] as? Bool)
    XCTAssertEqual(1, segmentClientProperties?["project_rewards_count"] as? Int)
    XCTAssertEqual(project.tags?.joined(separator: ", "), segmentClientProperties?["project_tags"] as? String)
    XCTAssertEqual(1, segmentClientProperties?["project_updates_count"] as? Int)
    XCTAssertEqual(27, segmentClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)

    XCTAssertEqual(false, segmentClientProperties?["project_user_is_backer"] as? Bool)
    XCTAssertNil(segmentClientProperties?["project_user_is_project_creator"])
    XCTAssertNil(segmentClientProperties?["project_user_has_starred"])

    XCTAssertEqual("discovery", segmentClientProperties?["session_ref_tag"] as? String)
  }

  func testProjectProperties_LoggedInUser() {
    let segmentClient = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      <> Project.lens.personalization.isStarred .~ false
    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackProjectViewed(project, refTag: nil, sectionContext: .overview)

    XCTAssertEqual(1, segmentClient.properties.count)

    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(false, segmentClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["project_user_has_watched"] as? Bool)
    XCTAssertEqual(project.tags?.joined(separator: ", "), segmentClientProperties?["project_tags"] as? String)

    XCTAssertEqual(27, segmentClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  func testProjectProperties_LoggedInBacker() {
    let segmentClient = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.isStarred .~ false
    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackProjectViewed(project, refTag: nil, sectionContext: .overview)
    XCTAssertEqual(1, segmentClient.properties.count)

    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(false, segmentClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(true, segmentClientProperties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["project_user_has_watched"] as? Bool)
    XCTAssertEqual(project.tags?.joined(separator: ", "), segmentClientProperties?["project_tags"] as? String)

    XCTAssertEqual(27, segmentClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  func testProjectProperties_LoggedInStarrer() {
    let segmentClient = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.isStarred .~ true
    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackProjectViewed(project, refTag: nil, sectionContext: .overview)
    XCTAssertEqual(1, segmentClient.properties.count)

    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(false, segmentClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(true, segmentClientProperties?["project_user_has_watched"] as? Bool)
    XCTAssertEqual(project.tags?.joined(separator: ", "), segmentClientProperties?["project_tags"] as? String)

    XCTAssertEqual(27, segmentClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  func testProjectProperties_LoggedInCreator() {
    let segmentClient = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      <> Project.lens.personalization.isStarred .~ false
    let loggedInUser = project.creator
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackProjectViewed(project, refTag: nil, sectionContext: .overview)
    XCTAssertEqual(1, segmentClient.properties.count)

    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(true, segmentClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["project_user_has_watched"] as? Bool)
    XCTAssertEqual(project.tags?.joined(separator: ", "), segmentClientProperties?["project_tags"] as? String)

    XCTAssertEqual(27, segmentClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  func testProjectProperties_SpanishCategory() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: nil,
      segmentClient: segmentClient
    )
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [Reward.template, .noReward]
      |> \.category .~ .spanishTemplate
      |> Project.lens.stats.staticUsdRate .~ 2.0
      |> Project.lens.stats.commentsCount .~ 10
      |> Project.lens.prelaunchActivated .~ true
      |> Project.lens.displayPrelaunch .~ true

    ksrAnalytics
      .trackProjectViewed(project, refTag: .discovery, sectionContext: .overview)

    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(project.category.analyticsName, segmentClientProperties?["project_subcategory"] as? String)
    XCTAssertEqual("Art", segmentClientProperties?["project_category"] as? String)
  }

  // MARK: - Discovery Properties Tests

  func testDiscoveryProperties() {
    let segmentClient = MockTrackingClient()
    let params = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      <> DiscoveryParams.lens.starred .~ false
      <> DiscoveryParams.lens.social .~ false
      <> DiscoveryParams.lens.recommended .~ false
      <> DiscoveryParams.lens.category .~ (Category.documentary
        |> Category.lens.parent .~ .init(
          analyticsName: Category.filmAndVideo.analyticsName,
          id: Category.filmAndVideo.id,
          name: Category.filmAndVideo.name
        )
      )
      <> DiscoveryParams.lens.query .~ "collage"
      <> DiscoveryParams.lens.sort .~ .popular
      <> DiscoveryParams.lens.page .~ 2

    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackDiscovery(params: params)

    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(30, segmentClientProperties?["discover_subcategory_id"] as? Int)
    XCTAssertEqual("Documentary", segmentClientProperties?["discover_subcategory_name"] as? String)
    XCTAssertEqual(false, segmentClientProperties?["discover_recommended"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["discover_social"] as? Bool)
    XCTAssertEqual(true, segmentClientProperties?["discover_pwl"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["discover_watched"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["discover_everything"] as? Bool)
    XCTAssertEqual(Category.filmAndVideo.intID, segmentClientProperties?["discover_category_id"] as? Int)
    XCTAssertEqual(Category.filmAndVideo.name, segmentClientProperties?["discover_category_name"] as? String)
    XCTAssertEqual("popular", segmentClientProperties?["discover_sort"] as? String)
    XCTAssertEqual("category_popular", segmentClientProperties?["discover_ref_tag"] as? String)
    XCTAssertEqual("collage", segmentClientProperties?["discover_search_term"] as? String)
  }

  func testDiscoveryProperties_NoCategory() {
    let segmentClient = MockTrackingClient()
    let params = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      <> DiscoveryParams.lens.starred .~ false
      <> DiscoveryParams.lens.social .~ false
      <> DiscoveryParams.lens.recommended .~ false
      <> DiscoveryParams.lens.category .~ nil
      <> DiscoveryParams.lens.sort .~ .popular

    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackDiscovery(params: params)

    let segmentClientProperties = segmentClient.properties.last

    XCTAssertNil(segmentClientProperties?["discover_category_id"])
    XCTAssertNil(segmentClientProperties?["discover_subcategory_id"])
    XCTAssertEqual(false, segmentClientProperties?["discover_recommended"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["discover_social"] as? Bool)
    XCTAssertEqual(true, segmentClientProperties?["discover_pwl"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["discover_watched"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["discover_everything"] as? Bool)
    XCTAssertEqual("popular", segmentClientProperties?["discover_sort"] as? String)
  }

  func testDiscoveryProperties_Everything() {
    let segmentClient = MockTrackingClient()

    let params = .defaults
      |> DiscoveryParams.lens.sort .~ .magic

    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackDiscovery(params: params)

    let segmentClientProperties = segmentClient.properties.last

    XCTAssertNil(segmentClientProperties?["discover_category_id"])
    XCTAssertNil(segmentClientProperties?["discover_subcategory_id"])
    XCTAssertNil(segmentClientProperties?["discover_recommended"])
    XCTAssertNil(segmentClientProperties?["discover_social"])
    XCTAssertNil(segmentClientProperties?["discover_pwl"])
    XCTAssertNil(segmentClientProperties?["discover_watched"])
    XCTAssertNil(segmentClientProperties?["discover_search_term"])
    XCTAssertEqual(true, segmentClientProperties?["discover_everything"] as? Bool)
    XCTAssertEqual("magic", segmentClientProperties?["discover_sort"] as? String)
  }

  // MARK: - Project Page Tracking

  func testTrackProjectViewed_SectionContext_Campaign() {
    let segmentClient = MockTrackingClient()
    let project = Project.template
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics
      .trackProjectViewed(project, refTag: .discovery, sectionContext: .campaign)

    XCTAssertEqual(["Page Viewed"], segmentClient.events)
    XCTAssertEqual(["project"], segmentClient.properties(forKey: "context_page"))
    XCTAssertEqual(["campaign"], segmentClient.properties(forKey: "context_section"))
    XCTAssertEqual(["discovery"], segmentClient.properties(forKey: "session_ref_tag"))

    self.assertProjectProperties(segmentClient.properties.last)
  }

  func testTrackCheckoutPaymentMethodViewed_PledgeViewContext_Pledge() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .restricted
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(5).timeIntervalSince1970

    ksrAnalytics.trackCheckoutPaymentPageViewed(
      project: .template,
      reward: reward,
      pledgeViewContext: .pledge,
      checkoutData: .template,
      refTag: .activity
    )

    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(["Page Viewed"], segmentClient.events)

    self.assertProjectProperties(segmentClientProps)
    self.assertCheckoutProperties(segmentClientProps)

    XCTAssertEqual("activity", segmentClientProps?["session_ref_tag"] as? String)
  }

  func testTrackUpdatePledgeScreenViewed_PledgeViewContext_Update() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .restricted
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(5).timeIntervalSince1970

    ksrAnalytics.trackCheckoutPaymentPageViewed(
      project: .template,
      reward: reward,
      pledgeViewContext: .update,
      checkoutData: .template,
      refTag: .activity
    )

    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(["Page Viewed"], segmentClient.events)
    XCTAssertEqual("update_pledge", segmentClientProps?["context_page"] as? String)

    self.assertProjectProperties(segmentClientProps)

    self.assertCheckoutProperties(segmentClientProps)

    XCTAssertEqual("activity", segmentClientProps?["session_ref_tag"] as? String)
  }

  func testTrackUpdatePledgeScreenViewed_PledgeViewContext_UpdateReward() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .restricted
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(5).timeIntervalSince1970

    ksrAnalytics.trackCheckoutPaymentPageViewed(
      project: .template,
      reward: reward,
      pledgeViewContext: .updateReward,
      checkoutData: .template,
      refTag: .activity
    )

    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(["Page Viewed"], segmentClient.events)
    XCTAssertEqual("update_pledge", segmentClientProps?["context_page"] as? String)

    self.assertProjectProperties(segmentClientProps)
    self.assertCheckoutProperties(segmentClientProps)

    XCTAssertEqual("activity", segmentClientProps?["session_ref_tag"] as? String)
  }

  func testTrackUpdatePledgeScreenViewed_PledgeViewContext_ChangePayment() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .restricted
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(5).timeIntervalSince1970

    ksrAnalytics.trackCheckoutPaymentPageViewed(
      project: .template,
      reward: reward,
      pledgeViewContext: .changePaymentMethod,
      checkoutData: .template,
      refTag: .activity
    )

    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(["Page Viewed"], segmentClient.events)
    XCTAssertEqual("change_payment", segmentClientProps?["context_page"] as? String)

    self.assertProjectProperties(segmentClientProps)
    self.assertCheckoutProperties(segmentClientProps)

    XCTAssertEqual("activity", segmentClientProps?["session_ref_tag"] as? String)
  }

  func testLogEventsCallback() {
    let bundle = MockBundle()
    let segmentClient = MockTrackingClient()
    let config = Config.template
    let device = MockDevice(userInterfaceIdiom: .phone)
    let screen = MockScreen()
    let ksrAnalytics = KSRAnalytics(
      bundle: bundle,
      config: config,
      device: device,
      loggedInUser: nil,
      screen: screen,
      segmentClient: segmentClient
    )

    var callBackEvents = [String]()
    var callBackProperties: [String: Any]?
    ksrAnalytics.logEventCallback = { event, properties in
      callBackEvents.append(event)
      callBackProperties = properties
    }

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual(["CTA Clicked"], callBackEvents)

    XCTAssertEqual("native", callBackProperties?["session_client"] as? String)
    XCTAssertEqual(1_234_567_890, callBackProperties?["session_app_build_number"] as? Int)
    XCTAssertEqual("1.2.3.4.5.6.7.8.9.0", callBackProperties?["session_app_release_version"] as? String)
    XCTAssertEqual("phone", callBackProperties?["session_device_type"] as? String)
    XCTAssertEqual("portrait", callBackProperties?["session_device_orientation"] as? String)
    XCTAssertEqual("ios", callBackProperties?["session_os"] as? String)
    XCTAssertEqual(false, callBackProperties?["session_user_is_logged_in"] as? Bool)
    XCTAssertEqual("native_ios", callBackProperties?["session_platform"] as? String)
    XCTAssertEqual("en", callBackProperties?["session_display_language"] as? String)
    XCTAssertEqual("US", callBackProperties?["session_country"] as? String)
    XCTAssertEqual(true, callBackProperties?["session_apple_pay_capable"] as? Bool)
    XCTAssertEqual(false, callBackProperties?["session_is_voiceover_running"] as? Bool)
    XCTAssertEqual("global_nav", callBackProperties?["context_location"] as? String)
    XCTAssertEqual("search", callBackProperties?["context_page"] as? String)
    XCTAssertEqual("discover", callBackProperties?["context_cta"] as? String)
  }

  func testProjectCardClicked_Page_Discover() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackProjectCardClicked(
      page: .discovery,
      project: .template,
      typeContext: .init(params: DiscoveryParams.recommendedDefaults),
      location: .discoverAdvanced,
      params: DiscoveryParams.recommendedDefaults
    )

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("project", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("recommended", segmentClient.properties.last?["context_type"] as? String)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("discover_advanced", segmentClient.properties.last?["context_location"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
    self.assertDiscoveryProperties(segmentClient.properties.last)
  }

  func testProjectCardClicked_Page_Activities() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackProjectCardClicked(
      page: .activities,
      project: .template
    )

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("project", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("activity_feed", segmentClient.properties.last?["context_page"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
  }

  func testProjectCardClicked_Page_Profile_Section_Backed() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackProjectCardClicked(
      page: .profile,
      project: .template,
      location: .accountMenu,
      section: .backed
    )

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("project", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("profile", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("account_menu", segmentClient.properties.last?["context_location"] as? String)
    XCTAssertEqual("backed", segmentClient.properties.last?["context_section"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
  }

  func testProjectCardClicked_Page_Profile_Section_Watched() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackProjectCardClicked(
      page: .profile,
      project: .template,
      location: .accountMenu,
      section: .watched
    )

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("project", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("profile", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("account_menu", segmentClient.properties.last?["context_location"] as? String)
    XCTAssertEqual("watched", segmentClient.properties.last?["context_section"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
  }

  func testProjectCardClicked_Page_Thanks() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .restricted
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(5).timeIntervalSince1970

    ksrAnalytics.trackProjectCardClicked(
      page: .thanks,
      project: .template,
      checkoutData: .template,
      typeContext: .recommended,
      location: .curated,
      reward: reward
    )

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("project", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("recommended", segmentClient.properties.last?["context_type"] as? String)
    XCTAssertEqual("thanks", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("curated", segmentClient.properties.last?["context_location"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
    self.assertCheckoutProperties(segmentClient.properties.last)
  }

  func testProjectCardClicked_Page_Search() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackProjectCardClicked(
      page: .search,
      project: .template,
      typeContext: .results,
      location: .searchResults,
      params: DiscoveryParams.recommendedDefaults
    )

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("project", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("results", segmentClient.properties.last?["context_type"] as? String)
    XCTAssertEqual("search", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("search_results", segmentClient.properties.last?["context_location"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
    self.assertDiscoveryProperties(segmentClient.properties.last)
  }

  func testProjectVideoPlaybackStarted() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackProjectVideoPlaybackStarted(
      project: .template,
      videoLength: 100,
      videoPosition: 20
    )

    XCTAssertEqual(["Video Playback Started"], segmentClient.events)
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual(100, segmentClient.properties.last?["video_length"] as? Int)
    XCTAssertEqual(20, segmentClient.properties.last?["video_position"] as? Int)

    self.assertProjectProperties(segmentClient.properties.last)
  }

  func testWatchProjectButtonClicked_DiscoveryLocationContext() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackWatchProjectButtonClicked(
      project: .template,
      page: .discovery,
      params: DiscoveryParams.recommendedDefaults,
      typeContext: .watch
    )

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("watch_project", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("watch", segmentClient.properties.last?["context_type"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
    self.assertDiscoveryProperties(segmentClient.properties.last)
  }

  func testUnWatchProjectButtonClicked_DiscoveryLocationContext() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackWatchProjectButtonClicked(
      project: .template,
      page: .discovery,
      params: DiscoveryParams.recommendedDefaults,
      typeContext: .unwatch
    )

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("watch_project", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("unwatch", segmentClient.properties.last?["context_type"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
    self.assertDiscoveryProperties(segmentClient.properties.last)
  }

  func testWatchProjectButtonClicked_ProjectPageLocationContext() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackWatchProjectButtonClicked(
      project: .template,
      page: .projectPage,
      typeContext: .watch
    )

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("watch_project", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("watch", segmentClient.properties.last?["context_type"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
  }

  func testUnWatchProjectButtonClicked_ProjectPageLocationContext() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackWatchProjectButtonClicked(
      project: .template,
      page: .projectPage,
      typeContext: .unwatch
    )

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("watch_project", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("unwatch", segmentClient.properties.last?["context_type"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
  }

  func testTrackGotoCreatorDetailsClicked() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackGotoCreatorDetailsClicked(
      project: .template
    )

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("creator_details", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)
    self.assertProjectProperties(segmentClient.properties.last)
  }

  func testTrackPledgeCTAButtonClicked_PledgeState() {
    let segmentClient = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let ksrAnalytics = KSRAnalytics(
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackPledgeCTAButtonClicked(stateType: .pledge, project: project)

    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)
    XCTAssertEqual("pledge_initiate", segmentClientProps?["context_cta"] as? String)
  }

  func testTrackRewardButtonClicked() {
    let segmentClient = MockTrackingClient()
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .restricted
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(5).timeIntervalSince1970
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let ksrAnalytics = KSRAnalytics(
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackRewardClicked(
      project: project,
      reward: reward,
      checkoutPropertiesData: .template,
      refTag: .category
    )

    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)

    self.assertCheckoutProperties(segmentClientProperties)
    self.assertProjectProperties(segmentClientProperties, loggedInUser: true)
    XCTAssertEqual("category", segmentClientProperties?["session_ref_tag"] as? String)
    XCTAssertEqual("reward_continue", segmentClientProperties?["context_cta"] as? String)
    XCTAssertEqual("rewards", segmentClientProperties?["context_page"] as? String)
  }

  func testTrackRewardsViewed() {
    let segmentClient = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let ksrAnalytics = KSRAnalytics(
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackRewardsViewed(
      project: project,
      checkoutPropertiesData: .template,
      refTag: .category
    )

    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(["Page Viewed"], segmentClient.events)

    self.assertProjectProperties(segmentClientProperties, loggedInUser: true)

    XCTAssertEqual("category", segmentClientProperties?["session_ref_tag"] as? String)
    XCTAssertEqual("rewards", segmentClientProperties?["context_page"] as? String)
  }

  func testTrackPledgeConfirmButtonClicked() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)
    let reward = Reward.template
      |> Reward.lens.endsAt .~ 5.0
      |> Reward.lens.shipping.preference .~ .restricted

    ksrAnalytics.trackPledgeConfirmButtonClicked(
      project: .template,
      reward: reward,
      typeContext: .creditCard,
      checkoutData: .template,
      refTag: nil
    )

    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)

    self.assertProjectProperties(segmentClientProps)
    self.assertCheckoutProperties(segmentClientProps)

    XCTAssertEqual(
      KSRAnalytics.CTAContext.pledgeConfirm.trackingString,
      segmentClientProps?["context_cta"] as? String
    )
    XCTAssertEqual(
      KSRAnalytics.TypeContext.creditCard.trackingString,
      segmentClientProps?["context_type"] as? String
    )
    XCTAssertEqual(
      "checkout",
      segmentClientProps?["context_page"] as? String
    )
  }

  func testTrackProjectCurrency_WhenDifferentFromCountry_ComesFromCountryCurrencyNotCountry_Success() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)
    let reward = Reward.template
      |> Reward.lens.endsAt .~ 5.0
      |> Reward.lens.shipping.preference .~ .restricted

    let project = Project.template
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.currency .~ Project.Country.de.currencyCode

    ksrAnalytics.trackPledgeConfirmButtonClicked(
      project: project,
      reward: reward,
      typeContext: .creditCard,
      checkoutData: .template,
      refTag: nil
    )

    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(
      "EUR",
      segmentClientProps?["project_currency"] as? String
    )
  }

  func testTrackPledgeSubmitButtonClicked_Pledge() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)
    let reward = Reward.template
      |> Reward.lens.endsAt .~ 5.0
      |> Reward.lens.shipping.preference .~ .restricted

    ksrAnalytics.trackPledgeSubmitButtonClicked(
      project: .template,
      reward: reward,
      typeContext: .creditCard,
      checkoutData: .template,
      refTag: nil
    )

    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)

    self.assertProjectProperties(segmentClientProps)
    self.assertCheckoutProperties(segmentClientProps)

    XCTAssertEqual(
      KSRAnalytics.CTAContext.pledgeSubmit.trackingString,
      segmentClientProps?["context_cta"] as? String
    )
    XCTAssertEqual(
      KSRAnalytics.TypeContext.creditCard.trackingString,
      segmentClientProps?["context_type"] as? String
    )
    XCTAssertEqual(
      "checkout",
      segmentClientProps?["context_page"] as? String
    )
  }

  func testTrackPledgeSubmitButtonClicked_ApplePay() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)
    let reward = Reward.template
      |> Reward.lens.endsAt .~ 5.0
      |> Reward.lens.shipping.preference .~ .restricted

    ksrAnalytics.trackPledgeSubmitButtonClicked(
      project: .template,
      reward: reward,
      typeContext: .applePay,
      checkoutData: .template,
      refTag: nil
    )

    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)

    self.assertProjectProperties(segmentClientProps)
    self.assertCheckoutProperties(segmentClientProps)

    XCTAssertEqual(
      KSRAnalytics.CTAContext.pledgeSubmit.trackingString,
      segmentClientProps?["context_cta"] as? String
    )
    XCTAssertEqual(
      KSRAnalytics.TypeContext.applePay.trackingString,
      segmentClientProps?["context_type"] as? String
    )
    XCTAssertEqual(
      "checkout",
      segmentClientProps?["context_page"] as? String
    )
  }

  func testTrackManagePledgePageViewed() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      segmentClient: segmentClient
    )

    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .restricted
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(5).timeIntervalSince1970

    ksrAnalytics
      .trackManagePledgePageViewed(
        project: project,
        reward: reward,
        checkoutData: .template
      )

    XCTAssertEqual(["Page Viewed"], segmentClient.events)
    XCTAssertEqual("manage_pledge", segmentClient.properties.last?["context_page"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
    self.assertCheckoutProperties(segmentClient.properties.last)
  }

  func testTrackCampaignDetailsButtonClicked() {
    let segmentClient = MockTrackingClient()

    let ksrAnalytics = KSRAnalytics(
      segmentClient: segmentClient
    )

    let project = Project.template

    ksrAnalytics.trackCampaignDetailsButtonClicked(project: project)

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)

    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual("campaign_details", segmentClientProps?["context_cta"] as? String)
    XCTAssertEqual("project", segmentClientProps?["context_page"] as? String)

    self.assertProjectProperties(segmentClientProps)
  }

  // MARK: - Activities Tracking

  func testTrackExploreButtonClicked() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackExploreButtonClicked()

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)

    XCTAssertEqual(segmentClient.properties(forKey: "context_cta"), ["discover"])
    XCTAssertEqual(segmentClient.properties(forKey: "context_page"), ["activity_feed"])
  }

  // MARK: - Search Tracking

  func testTrackSearchViewed() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackProjectSearchView(
      params: .defaults |> DiscoveryParams.lens.query .~ "mavericks",
      results: 2
    )

    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(["Page Viewed"], segmentClient.events)
    XCTAssertEqual("search", segmentClientProps?["context_page"] as? String)
    XCTAssertEqual("mavericks", segmentClientProps?["discover_search_term"] as? String)
    XCTAssertEqual(2, segmentClientProps?["discover_search_results_count"] as? Int)
  }

  func testUserProperties_loggedOut() {
    let segmentClient = MockTrackingClient()
    let config = Config.template |> Config.lens.countryCode .~ "US"
    let ksrAnalytics = KSRAnalytics(
      config: config,
      loggedInUser: nil,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    let segmentClientProps = segmentClient.properties.last

    XCTAssertNil(segmentClientProps?["user_uid"])
    XCTAssertEqual(0, segmentClientProps?.keys.filter { $0.hasPrefix("user_") }.count)
  }

  func testUserProperties_loggedIn() {
    let segmentClient = MockTrackingClient()

    let user = User.template
      |> User.lens.stats.backedProjectsCount .~ 5
      |> User.lens.location .~ Location.usa
      |> User.lens.facebookConnected .~ true
      |> User.lens.stats.starredProjectsCount .~ 2
      |> User.lens.stats.createdProjectsCount .~ 7
      |> User.lens.stats.draftProjectsCount .~ 8
      |> User.lens.id .~ 10
      |> User.lens.isAdmin .~ false

    let ksrAnalytics = KSRAnalytics(
      loggedInUser: user,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)

    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual("10", segmentClientProps?["user_uid"] as? String)
    XCTAssertEqual(5, segmentClientProps?["user_backed_projects_count"] as? Int)
    XCTAssertEqual(15, segmentClientProps?["user_created_projects_count"] as? Int)
    XCTAssertEqual(false, segmentClientProps?["user_is_admin"] as? Bool)
    XCTAssertEqual(7, segmentClientProps?["user_launched_projects_count"] as? Int)
    XCTAssertEqual(2, segmentClientProps?["user_watched_projects_count"] as? Int)
    XCTAssertEqual(true, segmentClientProps?["user_facebook_connected"] as? Bool)
  }

  func testTabBarClicked() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    let tabBarActivity = KSRAnalytics.TabBarItemLabel.activity
    let tabBarDashboard = KSRAnalytics.TabBarItemLabel.dashboard
    let tabBarHome = KSRAnalytics.TabBarItemLabel.discovery
    let tabBarProfile = KSRAnalytics.TabBarItemLabel.profile
    let search = KSRAnalytics.TabBarItemLabel.search

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: tabBarActivity, previousTabBarItemLabel: search)

    XCTAssertEqual([], segmentClient.events)

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: tabBarDashboard, previousTabBarItemLabel: search)

    XCTAssertEqual([], segmentClient.events)

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: tabBarHome, previousTabBarItemLabel: search)

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)

    XCTAssertEqual("discover", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("global_nav", segmentClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: tabBarProfile, previousTabBarItemLabel: search)

    XCTAssertEqual(
      ["CTA Clicked"],
      segmentClient.events
    )

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: search, previousTabBarItemLabel: tabBarProfile)

    XCTAssertEqual([
      "CTA Clicked"
    ], segmentClient.events)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("global_nav", segmentClient.properties.last?["context_location"] as? String)
  }

  func testSearchTabBarClicked() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackSearchTabBarClicked(prevTabBarItemLabel: .profile)

    XCTAssertEqual([
      "CTA Clicked"
    ], segmentClient.events)
    XCTAssertEqual("search", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("global_nav", segmentClient.properties.last?["context_location"] as? String)
    XCTAssertEqual("profile", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackSearchTabBarClicked(prevTabBarItemLabel: .dashboard)

    XCTAssertEqual([
      "CTA Clicked",
      "CTA Clicked"
    ], segmentClient.events)
    XCTAssertEqual("search", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("global_nav", segmentClient.properties.last?["context_location"] as? String)
    XCTAssertEqual("other", segmentClient.properties.last?["context_page"] as? String)
  }

  func testTrackDiscoverySortProperties() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackDiscoverySelectedSort(
      prevSort: .popular,
      params: .recommendedDefaults,
      discoverySortContext: .magic
    )

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)

    self.assertTrackDiscoveryEventProperties(
      props: segmentClient.properties.last,
      prevSort: .popular,
      discoveryContext: .magic
    )

    ksrAnalytics.trackDiscoverySelectedSort(
      prevSort: .endingSoon,
      params: .recommendedDefaults,
      discoverySortContext: .popular
    )

    XCTAssertEqual(["CTA Clicked", "CTA Clicked"], segmentClient.events)

    self.assertTrackDiscoveryEventProperties(
      props: segmentClient.properties.last,
      prevSort: .endingSoon,
      discoveryContext: .popular
    )

    ksrAnalytics.trackDiscoverySelectedSort(
      prevSort: .magic,
      params: .recommendedDefaults,
      discoverySortContext: .newest
    )

    XCTAssertEqual(["CTA Clicked", "CTA Clicked", "CTA Clicked"], segmentClient.events)

    self.assertTrackDiscoveryEventProperties(
      props: segmentClient.properties.last,
      prevSort: .magic,
      discoveryContext: .newest
    )

    ksrAnalytics.trackDiscoverySelectedSort(
      prevSort: .newest,
      params: .recommendedDefaults,
      discoverySortContext: .endingSoon
    )

    XCTAssertEqual(["CTA Clicked", "CTA Clicked", "CTA Clicked", "CTA Clicked"], segmentClient.events)

    self.assertTrackDiscoveryEventProperties(
      props: segmentClient.properties.last,
      prevSort: .newest,
      discoveryContext: .endingSoon
    )
  }

  func testTrackDiscoveryModalSelectedFilter() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    let allProjectParams = DiscoveryParams.defaults |> DiscoveryParams.lens.includePOTD .~ true
    ksrAnalytics
      .trackDiscoveryModalSelectedFilter(
        params: allProjectParams,
        typeContext: .allProjects,
        locationContext: .discoverOverlay
      )
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("all", segmentClient.properties.last?["context_type"] as? String)
    XCTAssertEqual(true, segmentClient.properties.last?["discover_everything"] as? Bool)

    let pwlParams = DiscoveryParams.defaults |> DiscoveryParams.lens.staffPicks .~ true
    ksrAnalytics
      .trackDiscoveryModalSelectedFilter(
        params: pwlParams,
        typeContext: .pwl,
        locationContext: .discoverOverlay
      )
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("pwl", segmentClient.properties.last?["context_type"] as? String)
    XCTAssertEqual(true, segmentClient.properties.last?["discover_pwl"] as? Bool)

    let recommendedParams = DiscoveryParams.defaults |> DiscoveryParams.lens.recommended .~ true
    ksrAnalytics
      .trackDiscoveryModalSelectedFilter(
        params: recommendedParams,
        typeContext: .recommended,
        locationContext: .discoverOverlay
      )
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("recommended", segmentClient.properties.last?["context_type"] as? String)
    XCTAssertEqual(true, segmentClient.properties.last?["discover_recommended"] as? Bool)

    let socialParams = DiscoveryParams.defaults |> DiscoveryParams.lens.social .~ true
    ksrAnalytics
      .trackDiscoveryModalSelectedFilter(
        params: socialParams,
        typeContext: .social,
        locationContext: .discoverOverlay
      )
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("social", segmentClient.properties.last?["context_type"] as? String)
    XCTAssertEqual(true, segmentClient.properties.last?["discover_social"] as? Bool)

    let artParams = DiscoveryParams.defaults
      |> DiscoveryParams.lens.category .~ Category.art
    ksrAnalytics
      .trackDiscoveryModalSelectedFilter(
        params: artParams,
        typeContext: .categoryName,
        locationContext: .discoverOverlay
      )
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("discover_overlay", segmentClient.properties.last?["context_location"] as? String)
    XCTAssertEqual("category_name", segmentClient.properties.last?["context_type"] as? String)
    XCTAssertEqual("Art", segmentClient.properties.last?["discover_category_name"] as? String)
    XCTAssertEqual("Art", segmentClient.properties.last?["discover_subcategory_name"] as? String)

    let illustrationParams = DiscoveryParams.defaults
      |> DiscoveryParams.lens.category .~ Category.illustration
    ksrAnalytics
      .trackDiscoveryModalSelectedFilter(
        params: illustrationParams,
        typeContext: .subcategoryName,
        locationContext: .discoverOverlay
      )
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("discover_overlay", segmentClient.properties.last?["context_location"] as? String)
    XCTAssertEqual("subcategory_name", segmentClient.properties.last?["context_type"] as? String)
    XCTAssertEqual("Art", segmentClient.properties.last?["discover_category_name"] as? String)
    XCTAssertEqual("Illustration", segmentClient.properties.last?["discover_subcategory_name"] as? String)

    let watchedParams = DiscoveryParams.defaults |> DiscoveryParams.lens.starred .~ true
    ksrAnalytics
      .trackDiscoveryModalSelectedFilter(
        params: watchedParams,
        typeContext: .watched,
        locationContext: .discoverOverlay
      )
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("watched", segmentClient.properties.last?["context_type"] as? String)
    XCTAssertEqual(true, segmentClient.properties.last?["discover_watched"] as? Bool)
  }

  func testTrackDiscoveryModalSelectedFilter_Category_Spanish() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)
    let artParams = DiscoveryParams.defaults
      |> DiscoveryParams.lens.category .~ Category.documentarySpanish
    ksrAnalytics
      .trackDiscoveryModalSelectedFilter(
        params: artParams,
        typeContext: .categoryName,
        locationContext: .discoverOverlay
      )
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("category_name", segmentClient.properties.last?["context_type"] as? String)
    XCTAssertEqual("Film & Video", segmentClient.properties.last?["discover_category_name"] as? String)
    XCTAssertEqual("Documentary", segmentClient.properties.last?["discover_subcategory_name"] as? String)
  }

  func testTrackProjectViewedEvent() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackProjectViewed(Project.template, sectionContext: .overview) // approved event

    XCTAssertEqual(
      ["Page Viewed"], segmentClient.events,
      "Approved event is tracked by segment client"
    )
    XCTAssertEqual(["project"], segmentClient.properties(forKey: "context_page"))
    XCTAssertEqual(["overview"], segmentClient.properties(forKey: "context_section"))
  }

  func testIdentifyingTrackingClient() {
    let user = User.template

    AppEnvironment.current.ksrAnalytics.identify(newUser: user)

    XCTAssertEqual(self.segmentTrackingClient.userId, "\(user.id)")
    XCTAssertEqual(self.segmentTrackingClient.traits?["name"] as? String, user.name)

    let notifications = user.notifications.encode()

    for (key, _) in notifications {
      XCTAssertEqual(notifications[key] as? Bool, self.segmentTrackingClient.traits?[key] as? Bool)
    }

    AppEnvironment.logout()

    XCTAssertNil(self.segmentTrackingClient.userId)
    XCTAssertNil(self.segmentTrackingClient.traits)
  }

  func testIdentifyingTrackingClient_OnInitialUserSet() {
    let user = User.template

    withEnvironment {
      AppEnvironment.current.ksrAnalytics.identify(newUser: user)

      XCTAssertEqual(self.segmentTrackingClient.userId, "\(1)")
      XCTAssertEqual(self.segmentTrackingClient.traits?["name"] as? String, user.name)
    }
  }

  func testIdentifyingTrackingClient_RepeatsIfAnalyticsIdentityDataChanges() {
    let user = User.template
      |> User.lens.notifications.follower .~ false
    let updatedUser = user
      |> User.lens.notifications.follower .~ true

    withEnvironment {
      AppEnvironment.current.ksrAnalytics.identify(newUser: user)

      XCTAssertNotNil(self.segmentTrackingClient.userId)
      XCTAssertNotNil(self.segmentTrackingClient.traits)

      AppEnvironment.logout()

      XCTAssertNil(self.segmentTrackingClient.userId)
      XCTAssertNil(self.segmentTrackingClient.traits)

      AppEnvironment.current.ksrAnalytics.identify(newUser: updatedUser)

      XCTAssertNotNil(self.segmentTrackingClient.userId)
      XCTAssertNotNil(self.segmentTrackingClient.traits)
    }
  }

  func testIdentifyingTrackingClient_RepeatAllIfAnyChanges() {
    let mockKeyValueStore = MockKeyValueStore()

    let user = User.template
      |> User.lens.notifications.mobileUpdates .~ true
      |> User.lens.notifications.messages .~ true

    withEnvironment(userDefaults: mockKeyValueStore) {
      let updatedUser = User.template
        |> User.lens.notifications.mobileUpdates .~ true
        |> User.lens.notifications.messages .~ false

      AppEnvironment.current.ksrAnalytics.identify(newUser: updatedUser)

      XCTAssertEqual(self.segmentTrackingClient.userId, "\(1)")
      XCTAssertEqual(self.segmentTrackingClient.traits?["name"] as? String, user.name)

      let notifications = updatedUser.notifications.encode()

      for (key, _) in notifications {
        XCTAssertEqual(notifications[key] as? Bool, self.segmentTrackingClient.traits?[key] as? Bool)
      }
    }
  }

  func testTrackAddOnsContinueButtonClicked() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .restricted
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(5).timeIntervalSince1970

    ksrAnalytics
      .trackAddOnsContinueButtonClicked(
        project: project,
        reward: reward,
        checkoutData: .template,
        refTag: nil
      )

    XCTAssertEqual(["CTA Clicked"], segmentClient.events)

    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual("add_ons_continue", segmentClientProps?["context_cta"] as? String)

    XCTAssertEqual("add_ons", segmentClientProps?["context_page"] as? String)

    self.assertProjectProperties(segmentClientProps)

    self.assertCheckoutProperties(segmentClientProps)
  }

  func testContextProperties() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackTabBarClicked(tabBarItemLabel: .discovery, previousTabBarItemLabel: .search)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("global_nav", segmentClient.properties.last?["context_location"] as? String)
    XCTAssertEqual("search", segmentClient.properties.last?["context_page"] as? String)
  }

  func testContextLocationProperties() {
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(segmentClient: segmentClient)

    ksrAnalytics.trackDiscovery(params: .defaults)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackExploreButtonClicked()
    XCTAssertEqual("activity_feed", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackLoginSubmitButtonClicked()
    XCTAssertEqual("log_in", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackPledgeCTAButtonClicked(stateType: .pledge, project: .template)
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackSearchTabBarClicked(prevTabBarItemLabel: .discovery)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("search", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("global_nav", segmentClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackSearchTabBarClicked(prevTabBarItemLabel: .activity)
    XCTAssertEqual("activity_feed", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("search", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("global_nav", segmentClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackSearchTabBarClicked(prevTabBarItemLabel: .search)
    XCTAssertEqual("search", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("search", segmentClient.properties.last?["context_cta"] as? String)
    XCTAssertEqual("global_nav", segmentClient.properties.last?["context_location"] as? String)

    let watchedParams = DiscoveryParams.defaults |> DiscoveryParams.lens.starred .~ true
    ksrAnalytics.trackProfilePageFilterSelected(params: watchedParams)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("watched", segmentClient.properties.last?["context_type"] as? String)
    XCTAssertEqual("account_menu", segmentClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackProjectSearchView(params: .defaults)
    XCTAssertEqual("search", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackProjectViewed(.template, sectionContext: .overview)
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("overview", segmentClient.properties.last?["context_section"] as? String)

    ksrAnalytics.trackProjectViewed(.template, sectionContext: .campaign)
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("campaign", segmentClient.properties.last?["context_section"] as? String)

    ksrAnalytics.trackProjectViewed(.template, sectionContext: .comments)
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("comments", segmentClient.properties.last?["context_section"] as? String)

    ksrAnalytics.trackProjectViewed(.template, sectionContext: .updates)
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("updates", segmentClient.properties.last?["context_section"] as? String)

    ksrAnalytics.trackProjectViewed(.template, sectionContext: .tabSelected(.overview))
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("overview", segmentClient.properties.last?["context_section"] as? String)

    ksrAnalytics.trackProjectViewed(.template, sectionContext: .tabSelected(.campaign))
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("campaign", segmentClient.properties.last?["context_section"] as? String)

    ksrAnalytics.trackProjectViewed(.template, sectionContext: .tabSelected(.faqs))
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("faq", segmentClient.properties.last?["context_section"] as? String)

    ksrAnalytics.trackProjectViewed(.template, sectionContext: .tabSelected(.risks))
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("risks", segmentClient.properties.last?["context_section"] as? String)

    ksrAnalytics.trackProjectViewed(.template, sectionContext: .tabSelected(.environmentalCommitments))
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("environment", segmentClient.properties.last?["context_section"] as? String)

    ksrAnalytics
      .trackRewardClicked(
        project: .template,
        reward: .template,
        checkoutPropertiesData: .template,
        refTag: nil
      )
    XCTAssertEqual("rewards", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics
      .trackRewardsViewed(
        project: .template,
        checkoutPropertiesData: .template,
        refTag: nil
      )
    XCTAssertEqual("rewards", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackProjectSearchView(params: .defaults)
    XCTAssertEqual("search", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackLoginPageViewed()
    XCTAssertEqual("log_in", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackSignupPageViewed()
    XCTAssertEqual("sign_up", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackThanksPageViewed(project: .template, reward: .template, checkoutData: nil)
    XCTAssertEqual("thanks", segmentClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("new_pledge", segmentClient.properties.last?["context_type"] as? String)

    ksrAnalytics
      .trackAddOnsPageViewed(project: .template, reward: .template, checkoutData: .template, refTag: nil)
    XCTAssertEqual("add_ons", segmentClient.properties.last?["context_page"] as? String)
  }

  func testCTAContextTrackingStrings() {
    XCTAssertEqual(KSRAnalytics.CTAContext.addOnsContinue.trackingString, "add_ons_continue")
    XCTAssertEqual(KSRAnalytics.CTAContext.pledgeConfirm.trackingString, "pledge_confirm")
    XCTAssertEqual(KSRAnalytics.CTAContext.pledgeInitiate.trackingString, "pledge_initiate")
    XCTAssertEqual(KSRAnalytics.CTAContext.pledgeSubmit.trackingString, "pledge_submit")
    XCTAssertEqual(KSRAnalytics.CTAContext.project.trackingString, "project")
    XCTAssertEqual(KSRAnalytics.CTAContext.rewardContinue.trackingString, "reward_continue")
    XCTAssertEqual(KSRAnalytics.CTAContext.discover.trackingString, "discover")
    XCTAssertEqual(KSRAnalytics.CTAContext.discoverFilter.trackingString, "discover_filter")
    XCTAssertEqual(KSRAnalytics.CTAContext.discoverSort.trackingString, "discover_sort")
    XCTAssertEqual(KSRAnalytics.CTAContext.search.trackingString, "search")
    XCTAssertEqual(KSRAnalytics.CTAContext.watchProject.trackingString, "watch_project")
    XCTAssertEqual(KSRAnalytics.CTAContext.campaignDetails.trackingString, "campaign_details")
    XCTAssertEqual(KSRAnalytics.CTAContext.creatorDetails.trackingString, "creator_details")
    XCTAssertEqual(KSRAnalytics.CTAContext.logInInitiate.trackingString, "log_in_initiate")
    XCTAssertEqual(KSRAnalytics.CTAContext.logInOrSignUp.trackingString, "log_in_or_sign_up")
    XCTAssertEqual(KSRAnalytics.CTAContext.logInSubmit.trackingString, "log_in_submit")
    XCTAssertEqual(KSRAnalytics.CTAContext.signUpInitiate.trackingString, "sign_up_initiate")
    XCTAssertEqual(KSRAnalytics.CTAContext.signUpSubmit.trackingString, "sign_up_submit")
    XCTAssertEqual(KSRAnalytics.CTAContext.forgotPassword.trackingString, "forgot_password")
  }

  func testSectionContextTrackingStrings() {
    XCTAssertEqual(KSRAnalytics.SectionContext.campaign.trackingString, "campaign")
    XCTAssertEqual(KSRAnalytics.SectionContext.comments.trackingString, "comments")
    XCTAssertEqual(KSRAnalytics.SectionContext.overview.trackingString, "overview")
    XCTAssertEqual(KSRAnalytics.SectionContext.updates.trackingString, "updates")
  }

  func testTypeContextTrackingStrings() {
    XCTAssertEqual(KSRAnalytics.TypeContext.amountGoal.trackingString, "amount_goal")
    XCTAssertEqual(KSRAnalytics.TypeContext.amountPledged.trackingString, "amount_pledged")
    XCTAssertEqual(KSRAnalytics.TypeContext.apple.trackingString, "apple")
    XCTAssertEqual(KSRAnalytics.TypeContext.applePay.trackingString, "apple_pay")
    XCTAssertEqual(KSRAnalytics.TypeContext.backed.trackingString, "backed")
    XCTAssertEqual(KSRAnalytics.TypeContext.categoryName.trackingString, "category_name")
    XCTAssertEqual(KSRAnalytics.TypeContext.creditCard.trackingString, "credit_card")
    XCTAssertEqual(KSRAnalytics.TypeContext.discovery(.endingSoon).trackingString, "ending_soon")
    XCTAssertEqual(KSRAnalytics.TypeContext.discovery(.magic).trackingString, "magic")
    XCTAssertEqual(KSRAnalytics.TypeContext.discovery(.newest).trackingString, "newest")
    XCTAssertEqual(KSRAnalytics.TypeContext.discovery(.popular).trackingString, "popular")
    XCTAssertEqual(KSRAnalytics.TypeContext.allProjects.trackingString, "all")
    XCTAssertEqual(KSRAnalytics.TypeContext.watched.trackingString, "watched")
    XCTAssertEqual(KSRAnalytics.TypeContext.categoryName.trackingString, "category_name")
    XCTAssertEqual(KSRAnalytics.TypeContext.subcategoryName.trackingString, "subcategory_name")
    XCTAssertEqual(KSRAnalytics.TypeContext.facebook.trackingString, "facebook")
    XCTAssertEqual(KSRAnalytics.TypeContext.pledge(.fixErroredPledge).trackingString, "fix_errored_pledge")
    XCTAssertEqual(KSRAnalytics.TypeContext.pledge(.managePledge).trackingString, "manage_pledge")
    XCTAssertEqual(KSRAnalytics.TypeContext.pledge(.newPledge).trackingString, "new_pledge")
    XCTAssertEqual(KSRAnalytics.TypeContext.location.trackingString, "location")
    XCTAssertEqual(KSRAnalytics.TypeContext.percentRaised.trackingString, "percent_raised")
    XCTAssertEqual(KSRAnalytics.TypeContext.projectState.trackingString, "project_state")
    XCTAssertEqual(KSRAnalytics.TypeContext.pwl.trackingString, "pwl")
    XCTAssertEqual(KSRAnalytics.TypeContext.recommended.trackingString, "recommended")
    XCTAssertEqual(KSRAnalytics.TypeContext.results.trackingString, "results")
    XCTAssertEqual(KSRAnalytics.TypeContext.searchTerm.trackingString, "search_term")
    XCTAssertEqual(KSRAnalytics.TypeContext.social.trackingString, "social")
    XCTAssertEqual(KSRAnalytics.TypeContext.subcategoryName.trackingString, "subcategory_name")
    XCTAssertEqual(KSRAnalytics.TypeContext.subscriptionFalse.trackingString, "subscription_false")
    XCTAssertEqual(KSRAnalytics.TypeContext.subscriptionTrue.trackingString, "subscription_true")
    XCTAssertEqual(KSRAnalytics.TypeContext.tag.trackingString, "tag")
    XCTAssertEqual(KSRAnalytics.TypeContext.unwatch.trackingString, "unwatch")
    XCTAssertEqual(KSRAnalytics.TypeContext.watch.trackingString, "watch")
  }

  func testLocationContextTrackingStrings() {
    XCTAssertEqual(KSRAnalytics.LocationContext.accountMenu.trackingString, "account_menu")
    XCTAssertEqual(KSRAnalytics.LocationContext.curated.trackingString, "curated")
    XCTAssertEqual(KSRAnalytics.LocationContext.discoverAdvanced.trackingString, "discover_advanced")
    XCTAssertEqual(KSRAnalytics.LocationContext.discoverOverlay.trackingString, "discover_overlay")
    XCTAssertEqual(KSRAnalytics.LocationContext.globalNav.trackingString, "global_nav")
    XCTAssertEqual(KSRAnalytics.LocationContext.recommendations.trackingString, "recommendations")
    XCTAssertEqual(KSRAnalytics.LocationContext.searchResults.trackingString, "search_results")
  }

  func testPaymentTypeTrackingStrings() {
    XCTAssertEqual(PaymentType.applePay.trackingString, "apple_pay")
    XCTAssertEqual(PaymentType.googlePay.trackingString, nil)
    XCTAssertEqual(PaymentType.creditCard.trackingString, "credit_card")
  }

  /*
   Helper for testing discoverProperties from a template DiscoveryParams.recommendedDefaults
   */

  private func assertDiscoveryProperties(_ props: [String: Any]?) {
    XCTAssertEqual(true, props?["discover_recommended"] as? Bool)
    XCTAssertEqual(false, props?["discover_everything"] as? Bool)
    XCTAssertEqual("recs_home", props?["discover_ref_tag"] as? String)

    XCTAssertNil(props?["discover_pwl"] as? Bool)
    XCTAssertNil(props?["discover_social"] as? Bool)
    XCTAssertNil(props?["discover_watched"] as? Bool)
    XCTAssertNil(props?["discover_subcategory_id"] as? Int)
    XCTAssertNil(props?["discover_subcategory_name"] as? String)
    XCTAssertNil(props?["discover_category_id"] as? Int)
    XCTAssertNil(props?["discover_category_name"] as? String)
    XCTAssertNil(props?["discover_sort"] as? String)
    XCTAssertNil(props?["discover_search_term"] as? String)
  }

  /*
   Helper for testing projectProperties from a template Project
   */
  private func assertProjectProperties(
    _ props: [String: Any]?,
    isBacker: Bool = false,
    loggedInUser: Bool = false
  ) {
    XCTAssertEqual(10, props?["project_backers_count"] as? Int)
    XCTAssertEqual("Art", props?["project_category"] as? String)
    XCTAssertEqual("USD", props?["project_currency"] as? String)
    XCTAssertEqual("1", props?["project_pid"] as? String)
    XCTAssertEqual(50, props?["project_percent_raised"] as? Int)
    XCTAssertEqual("Ceramics", props?["project_subcategory"] as? String)
    XCTAssertEqual("1", props?["project_creator_uid"] as? String)
    XCTAssertEqual(24 * 15, props?["project_hours_remaining"] as? Int)
    XCTAssertEqual(30, props?["project_duration"] as? Int)
    XCTAssertEqual("2016-10-16T22:35:15Z", props?["project_deadline"] as? String)
    XCTAssertEqual("2016-09-16T22:35:15Z", props?["project_launched_at"] as? String)
    XCTAssertEqual("live", props?["project_state"] as? String)
    XCTAssertEqual(1_000, props?["project_current_pledge_amount"] as? Int)
    XCTAssertEqual(1_213.75, props?["project_current_amount_pledged_usd"] as? Decimal)
    XCTAssertEqual(2_427.5, props?["project_goal_usd"] as? Decimal)
    XCTAssertEqual(true, props?["project_has_video"] as? Bool)
    XCTAssertEqual(10, props?["project_comments_count"] as? Int)
    XCTAssertEqual(0, props?["project_rewards_count"] as? Int)
    XCTAssertEqual("Action & Adventure, Adaptation, Board Games", props?["project_tags"] as? String)
    XCTAssertEqual(1, props?["project_updates_count"] as? Int)
    XCTAssertEqual(true, props?["project_is_repeat_creator"] as? Bool)

    isBacker ? XCTAssertEqual(true, props?["project_user_is_backer"] as? Bool) :
      XCTAssertEqual(false, props?["project_user_is_backer"] as? Bool)

    loggedInUser ? XCTAssertEqual(false, props?["project_user_is_project_creator"] as? Bool) :
      XCTAssertNil(props?["project_user_is_project_creator"] as? Bool)

    XCTAssertNil(props?["project_user_has_starred"])
    XCTAssertNil(props?["project_prelaunch_activated"] as? Bool)
    XCTAssertEqual(false, props?["project_has_add_ons"] as? Bool)
  }

  /*
   Helper for testing pledgeProperties from a template Reward
   */
  private func assertPledgeProperties(_ props: [String: Any]?) {
    XCTAssertEqual(true, props?["pledge_backer_reward_has_items"] as? Bool)
    XCTAssertEqual(1, props?["pledge_backer_reward_id"] as? Int)
    XCTAssertEqual(10.00, props?["pledge_backer_reward_minimum"] as? Double)
  }

  /*
   Helper for testing checkoutProperties from a template ksrAnalytics.CheckoutPropertiesData
   */
  private func assertCheckoutProperties(_ props: [String: Any]?) {
    XCTAssertEqual(2, props?["checkout_add_ons_count_total"] as? Int)
    XCTAssertEqual(1, props?["checkout_add_ons_count_unique"] as? Int)
    XCTAssertEqual(8.00, props?["checkout_add_ons_minimum_usd"] as? Decimal)
    XCTAssertEqual(10.00, props?["checkout_bonus_amount_usd"] as? Decimal)
    XCTAssertEqual("CREDIT_CARD", props?["checkout_payment_type"] as? String)
    XCTAssertEqual("SUPER reward", props?["checkout_reward_title"] as? String)
    XCTAssertEqual(5.00, props?["checkout_reward_minimum_usd"] as? Decimal)
    XCTAssertEqual("2", props?["checkout_reward_id"] as? String)
    XCTAssertEqual(20.00, props?["checkout_amount_total_usd"] as? Decimal)
    XCTAssertEqual(true, props?["checkout_reward_is_limited_quantity"] as? Bool)
    XCTAssertEqual(true, props?["checkout_reward_is_limited_time"] as? Bool)
    XCTAssertEqual(true, props?["checkout_reward_shipping_enabled"] as? Bool)
    XCTAssertEqual("restricted", props?["checkout_reward_shipping_preference"] as? String)
    XCTAssertEqual(true, props?["checkout_user_has_eligible_stored_apple_pay_card"] as? Bool)
    XCTAssertEqual(10.00, props?["checkout_shipping_amount_usd"] as? Decimal)
    XCTAssertEqual(
      "1970-05-23T21:21:18Z",
      props?["checkout_reward_estimated_delivery_on"] as? String
    )
  }

  /*
   Helper to test all event properties for Discovery Explore Sorts
   */
  private func assertTrackDiscoveryEventProperties(
    props: [String: Any]?,
    prevSort: DiscoveryParams.Sort,
    discoveryContext: KSRAnalytics.TypeContext.DiscoverySortContext
  ) {
    XCTAssertEqual("discover_sort", props?["context_cta"] as? String)
    XCTAssertEqual(discoveryContext.trackingString, props?["context_type"] as? String)
    XCTAssertEqual("discover", props?["context_page"] as? String)
    XCTAssertEqual("discover_advanced", props?["context_location"] as? String)
    XCTAssertEqual(prevSort.trackingString, props?["discover_sort"] as? String)
    XCTAssertEqual(false, props?["discover_everything"] as? Bool)
    XCTAssertEqual(true, props?["discover_recommended"] as? Bool)
    XCTAssertEqual("recs_home", props?["discover_ref_tag"] as? String)
  }
}

extension KSRAnalytics.CheckoutPropertiesData {
  static let template = KSRAnalytics.CheckoutPropertiesData(
    addOnsCountTotal: 2,
    addOnsCountUnique: 1,
    addOnsMinimumUsd: 8.00,
    bonusAmountInUsd: 10.00,
    checkoutId: "1",
    estimatedDelivery: 12_345_678,
    paymentType: "CREDIT_CARD",
    revenueInUsd: 20.00,
    rewardId: "2",
    rewardMinimumUsd: 5.00,
    rewardTitle: "SUPER reward",
    shippingEnabled: true,
    shippingAmountUsd: 10.00,
    userHasStoredApplePayCard: true
  )
}
