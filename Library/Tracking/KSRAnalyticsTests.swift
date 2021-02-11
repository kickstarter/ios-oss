@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class KSRAnalyticsTests: TestCase {
  // MARK: - Session Properties Tests

  func testSessionProperties() {
    let bundle = MockBundle()
    let dataLakeClient = MockTrackingClient()
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
      dataLakeClient: dataLakeClient,
      config: config,
      device: device,
      loggedInUser: nil,
      screen: screen,
      segmentClient: segmentClient,
      distinctId: "abc-123"
    )

    ksrAnalytics.trackTabBarClicked(.activity)

    let dataLakeClientProperties = dataLakeClient.properties.last
    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(
      ["native_checkout[experimental]", "other_experiment[control]"],
      dataLakeClientProperties?["session_current_variants"] as? [String]
    )
    XCTAssertEqual(
      [
        "ios_enabled_feature"
      ],
      dataLakeClientProperties?["session_enabled_features"] as? [String]
    )

    XCTAssertEqual(
      ["native_checkout[experimental]", "other_experiment[control]"],
      segmentClientProperties?["session_current_variants"] as? [String]
    )
    XCTAssertEqual(
      [
        "ios_enabled_feature"
      ],
      segmentClientProperties?["session_enabled_features"] as? [String]
    )

    XCTAssertEqual("native", dataLakeClientProperties?["session_client"] as? String)
    XCTAssertEqual("1234567890", dataLakeClientProperties?["session_app_build_number"] as? String)
    XCTAssertEqual("1.2.3.4.5.6.7.8.9.0", dataLakeClientProperties?["session_app_release_version"] as? String)
    XCTAssertEqual("phone", dataLakeClientProperties?["session_device_type"] as? String)
    XCTAssertEqual("Apple", dataLakeClientProperties?["session_device_manufacturer"] as? String)
    XCTAssertEqual("Portrait", dataLakeClientProperties?["session_device_orientation"] as? String)
    XCTAssertEqual("abc-123", dataLakeClientProperties?["session_device_distinct_id"] as? String)
    XCTAssertEqual(
      ["service": "wifi"],
      dataLakeClientProperties?["session_cellular_connection"] as? [String: String]?
    )

    XCTAssertEqual("MockSystemName", dataLakeClientProperties?["session_os"] as? String)
    XCTAssertEqual("MockSystemVersion", dataLakeClientProperties?["session_os_version"] as? String)
    XCTAssertEqual(UInt(screen.bounds.width), dataLakeClientProperties?["session_screen_width"] as? UInt)
    XCTAssertEqual("kickstarter_ios", dataLakeClientProperties?["session_mp_lib"] as? String)
    XCTAssertEqual(false, dataLakeClientProperties?["session_user_logged_in"] as? Bool)
    XCTAssertEqual("ios", dataLakeClientProperties?["session_platform"] as? String)
    XCTAssertEqual("en", dataLakeClientProperties?["session_display_language"] as? String)

    XCTAssertEqual(23, dataLakeClientProperties?.keys.filter { $0.hasPrefix("session_") }.count)

    XCTAssertEqual("native", segmentClientProperties?["session_client"] as? String)
    XCTAssertEqual("1234567890", segmentClientProperties?["session_app_build_number"] as? String)
    XCTAssertEqual("1.2.3.4.5.6.7.8.9.0", segmentClientProperties?["session_app_release_version"] as? String)
    XCTAssertEqual("phone", segmentClientProperties?["session_device_type"] as? String)
    XCTAssertEqual("Apple", segmentClientProperties?["session_device_manufacturer"] as? String)
    XCTAssertEqual("Portrait", segmentClientProperties?["session_device_orientation"] as? String)
    XCTAssertEqual("abc-123", segmentClientProperties?["session_device_distinct_id"] as? String)
    XCTAssertEqual(
      ["service": "wifi"],
      segmentClientProperties?["session_cellular_connection"] as? [String: String]?
    )

    XCTAssertEqual("MockSystemName", segmentClientProperties?["session_os"] as? String)
    XCTAssertEqual("MockSystemVersion", segmentClientProperties?["session_os_version"] as? String)
    XCTAssertEqual(UInt(screen.bounds.width), segmentClientProperties?["session_screen_width"] as? UInt)
    XCTAssertEqual("kickstarter_ios", segmentClientProperties?["session_mp_lib"] as? String)
    XCTAssertEqual(false, segmentClientProperties?["session_user_logged_in"] as? Bool)
    XCTAssertEqual("ios", segmentClientProperties?["session_platform"] as? String)
    XCTAssertEqual("en", segmentClientProperties?["session_display_language"] as? String)

    XCTAssertEqual(23, segmentClientProperties?.keys.filter { $0.hasPrefix("session_") }.count)
  }

  func testSessionProperties_Language() {
    withEnvironment(language: Language.es) {
      let dataLakeClient = MockTrackingClient()
      let segmentClient = MockTrackingClient()
      let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

      ksrAnalytics.trackTabBarClicked(.activity)

      let dataLakeClientProperties = dataLakeClient.properties.last
      let segmentClientProperties = segmentClient.properties.last

      XCTAssertEqual("es", dataLakeClientProperties?["session_display_language"] as? String)
      XCTAssertEqual("es", segmentClientProperties?["session_display_language"] as? String)
    }
  }

  func testSessionProperties_VoiceOver() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    withEnvironment(isVoiceOverRunning: { true }) {
      ksrAnalytics.trackTabBarClicked(.activity)

      let dataLakeClientProperties = dataLakeClient.properties.last
      let segmentClientProperties = segmentClient.properties.last

      XCTAssertEqual(true, dataLakeClientProperties?["session_is_voiceover_running"] as? Bool)
      XCTAssertEqual(true, segmentClientProperties?["session_is_voiceover_running"] as? Bool)
    }

    withEnvironment(isVoiceOverRunning: { false }) {
      ksrAnalytics.trackTabBarClicked(.activity)

      let dataLakeClientProperties = dataLakeClient.properties.last
      let segmentClientProperties = segmentClient.properties.last

      XCTAssertEqual(false, dataLakeClientProperties?["session_is_voiceover_running"] as? Bool)
      XCTAssertEqual(false, segmentClientProperties?["session_is_voiceover_running"] as? Bool)
    }
  }

  func testSessionProperties_LoggedIn() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      loggedInUser: User.template,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(.activity)

    let dataLakeClientProperties = dataLakeClient.properties.last
    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(true, dataLakeClientProperties?["session_user_logged_in"] as? Bool)
    XCTAssertEqual(true, segmentClientProperties?["session_user_logged_in"] as? Bool)
  }

  func testSessionProperties_DeviceFormatAndClientPlatform_ForIPhoneIdiom() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      device: MockDevice(userInterfaceIdiom: .phone),
      loggedInUser: nil,
      segmentClient: segmentClient
    )
    ksrAnalytics.trackTabBarClicked(.activity)

    XCTAssertEqual("phone", dataLakeClient.properties.last?["session_device_type"] as? String)
    XCTAssertEqual("ios", dataLakeClient.properties.last?["session_platform"] as? String)

    XCTAssertEqual("phone", segmentClient.properties.last?["session_device_type"] as? String)
    XCTAssertEqual("ios", segmentClient.properties.last?["session_platform"] as? String)
  }

  func testSessionProperties_DeviceFormatAndClientPlatform_ForIPadIdiom() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      device: MockDevice(userInterfaceIdiom: .pad),
      loggedInUser: nil,
      segmentClient: segmentClient
    )
    ksrAnalytics.trackTabBarClicked(.activity)

    XCTAssertEqual("tablet", dataLakeClient.properties.last?["session_device_type"] as? String)
    XCTAssertEqual("ios", dataLakeClient.properties.last?["session_platform"] as? String)

    XCTAssertEqual("tablet", segmentClient.properties.last?["session_device_type"] as? String)
    XCTAssertEqual("ios", segmentClient.properties.last?["session_platform"] as? String)
  }

  func testSessionProperties_DeviceFormatAndClientPlatform_ForTvIdiom() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      device: MockDevice(userInterfaceIdiom: .tv),
      loggedInUser: nil,
      segmentClient: segmentClient
    )
    ksrAnalytics.trackTabBarClicked(.activity)

    XCTAssertEqual("tv", dataLakeClient.properties.last?["session_device_type"] as? String)
    XCTAssertEqual("tvos", dataLakeClient.properties.last?["session_platform"] as? String)

    XCTAssertEqual("tv", segmentClient.properties.last?["session_device_type"] as? String)
    XCTAssertEqual("tvos", segmentClient.properties.last?["session_platform"] as? String)
  }

  func testSessionProperties_DeviceOrientation() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let device = MockDevice(orientation: .faceDown)
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      device: device,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(.activity)

    let dataLakeProps = dataLakeClient.properties.last
    let segmentProps = segmentClient.properties.last

    XCTAssertEqual("Face Down", dataLakeProps?["session_device_orientation"] as? String)
    XCTAssertEqual("Face Down", segmentProps?["session_device_orientation"] as? String)
  }

  // MARK: - Project Properties Tests

  func testProjectProperties() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      loggedInUser: nil,
      segmentClient: segmentClient
    )
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [Reward.template]
      |> \.category .~ (.illustration
        |> \.id .~ 123
        |> \.parentId .~ 321
      )
      |> Project.lens.stats.staticUsdRate .~ 2.0
      |> Project.lens.stats.commentsCount .~ 10
      |> Project.lens.prelaunchActivated .~ true

    ksrAnalytics.trackProjectViewed(project, refTag: .discovery, cookieRefTag: .recommended)

    XCTAssertEqual(1, dataLakeClient.properties.count)
    XCTAssertEqual(1, segmentClient.properties.count)

    let dataLakeClientProperties = dataLakeClient.properties.last
    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual("Project Page Viewed", dataLakeClient.events.last)
    XCTAssertEqual(project.stats.backersCount, dataLakeClientProperties?["project_backers_count"] as? Int)
    XCTAssertEqual(project.country.countryCode, dataLakeClientProperties?["project_country"] as? String)
    XCTAssertEqual(project.country.currencyCode, dataLakeClientProperties?["project_currency"] as? String)
    XCTAssertEqual(project.stats.goal, dataLakeClientProperties?["project_goal"] as? Int)
    XCTAssertEqual(project.id, dataLakeClientProperties?["project_pid"] as? Int)
    XCTAssertEqual(
      project.stats.fundingProgress,
      dataLakeClientProperties?["project_percent_raised"] as? Float
    )
    XCTAssertEqual(project.category.name, dataLakeClientProperties?["project_subcategory"] as? String)
    XCTAssertEqual(123, dataLakeClientProperties?["project_subcategory_id"] as? Int)
    XCTAssertEqual("Art", dataLakeClientProperties?["project_category"] as? String)
    XCTAssertEqual(321, dataLakeClientProperties?["project_category_id"] as? Int)
    XCTAssertEqual(project.location.name, dataLakeClientProperties?["project_location"] as? String)
    XCTAssertEqual(project.stats.commentsCount, dataLakeClientProperties?["project_comments_count"] as? Int)
    XCTAssertEqual(project.creator.id, dataLakeClientProperties?["project_creator_uid"] as? Int)
    XCTAssertEqual(24 * 15, dataLakeClientProperties?["project_hours_remaining"] as? Int)
    XCTAssertEqual(30, dataLakeClientProperties?["project_duration"] as? Int)
    XCTAssertEqual(1_476_657_315, dataLakeClientProperties?["project_deadline"] as? Double)
    XCTAssertEqual(1_474_065_315, dataLakeClientProperties?["project_launched_at"] as? Double)
    XCTAssertEqual(2, dataLakeClientProperties?["project_static_usd_rate"] as? Float)
    XCTAssertEqual("live", dataLakeClientProperties?["project_state"] as? String)
    XCTAssertEqual(project.stats.pledged, dataLakeClientProperties?["project_current_pledge_amount"] as? Int)
    XCTAssertEqual(2_000, dataLakeClientProperties?["project_current_amount_pledged_usd"] as? Float)
    XCTAssertEqual(4_000, dataLakeClientProperties?["project_goal_usd"] as? Float)
    XCTAssertEqual(true, dataLakeClientProperties?["project_has_video"] as? Bool)
    XCTAssertEqual(10, dataLakeClientProperties?["project_comments_count"] as? Int)
    XCTAssertEqual(true, dataLakeClientProperties?["project_prelaunch_activated"] as? Bool)
    XCTAssertEqual(1, dataLakeClientProperties?["project_rewards_count"] as? Int)
    XCTAssertEqual(1, dataLakeClientProperties?["project_updates_count"] as? Int)

    XCTAssertEqual(false, dataLakeClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertNil(dataLakeClientProperties?["project_user_is_backer"])
    XCTAssertNil(dataLakeClientProperties?["project_user_has_starred"])

    XCTAssertEqual(28, dataLakeClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)

    XCTAssertEqual("discovery", dataLakeClientProperties?["session_ref_tag"] as? String)
    XCTAssertEqual("recommended", dataLakeClientProperties?["session_referrer_credit"] as? String)

    XCTAssertEqual("Project Page Viewed", segmentClient.events.last)
    XCTAssertEqual(project.stats.backersCount, segmentClientProperties?["project_backers_count"] as? Int)
    XCTAssertEqual(project.country.countryCode, segmentClientProperties?["project_country"] as? String)
    XCTAssertEqual(project.country.currencyCode, segmentClientProperties?["project_currency"] as? String)
    XCTAssertEqual(project.stats.goal, segmentClientProperties?["project_goal"] as? Int)
    XCTAssertEqual(project.id, segmentClientProperties?["project_pid"] as? Int)
    XCTAssertEqual(
      project.stats.fundingProgress,
      segmentClientProperties?["project_percent_raised"] as? Float
    )
    XCTAssertEqual(project.category.name, segmentClientProperties?["project_subcategory"] as? String)
    XCTAssertEqual(123, segmentClientProperties?["project_subcategory_id"] as? Int)
    XCTAssertEqual("Art", segmentClientProperties?["project_category"] as? String)
    XCTAssertEqual(321, segmentClientProperties?["project_category_id"] as? Int)
    XCTAssertEqual(project.location.name, segmentClientProperties?["project_location"] as? String)
    XCTAssertEqual(project.stats.commentsCount, dataLakeClientProperties?["project_comments_count"] as? Int)
    XCTAssertEqual(project.creator.id, segmentClientProperties?["project_creator_uid"] as? Int)
    XCTAssertEqual(24 * 15, segmentClientProperties?["project_hours_remaining"] as? Int)
    XCTAssertEqual(30, segmentClientProperties?["project_duration"] as? Int)
    XCTAssertEqual(1_476_657_315, segmentClientProperties?["project_deadline"] as? Double)
    XCTAssertEqual(1_474_065_315, segmentClientProperties?["project_launched_at"] as? Double)
    XCTAssertEqual(2, segmentClientProperties?["project_static_usd_rate"] as? Float)
    XCTAssertEqual("live", segmentClientProperties?["project_state"] as? String)
    XCTAssertEqual(project.stats.pledged, segmentClientProperties?["project_current_pledge_amount"] as? Int)
    XCTAssertEqual(2_000, segmentClientProperties?["project_current_amount_pledged_usd"] as? Float)
    XCTAssertEqual(4_000, segmentClientProperties?["project_goal_usd"] as? Float)
    XCTAssertEqual(true, segmentClientProperties?["project_has_video"] as? Bool)
    XCTAssertEqual(10, segmentClientProperties?["project_comments_count"] as? Int)
    XCTAssertEqual(true, segmentClientProperties?["project_prelaunch_activated"] as? Bool)
    XCTAssertEqual(1, segmentClientProperties?["project_rewards_count"] as? Int)
    XCTAssertEqual(1, segmentClientProperties?["project_updates_count"] as? Int)

    XCTAssertEqual(false, segmentClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertNil(segmentClientProperties?["project_user_is_backer"])
    XCTAssertNil(segmentClientProperties?["project_user_has_starred"])

    XCTAssertEqual(28, segmentClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)

    XCTAssertEqual("discovery", segmentClientProperties?["session_ref_tag"] as? String)
    XCTAssertEqual("recommended", segmentClientProperties?["session_referrer_credit"] as? String)
  }

  func testProjectProperties_LoggedInUser() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      <> Project.lens.personalization.isStarred .~ false
    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackProjectViewed(project, refTag: nil, cookieRefTag: nil)

    XCTAssertEqual(1, dataLakeClient.properties.count)
    XCTAssertEqual(1, segmentClient.properties.count)

    let dataLakeClientProperties = dataLakeClient.properties.last
    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(false, dataLakeClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, dataLakeClientProperties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, dataLakeClientProperties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, dataLakeClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)

    XCTAssertEqual(false, segmentClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, segmentClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  func testProjectProperties_LoggedInBacker() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.isStarred .~ false
    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackProjectViewed(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(1, dataLakeClient.properties.count)
    XCTAssertEqual(1, segmentClient.properties.count)

    let dataLakeClientProperties = dataLakeClient.properties.last
    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(false, dataLakeClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(true, dataLakeClientProperties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, dataLakeClientProperties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, dataLakeClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)

    XCTAssertEqual(false, segmentClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(true, segmentClientProperties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, segmentClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  func testProjectProperties_LoggedInStarrer() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.isStarred .~ true
    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackProjectViewed(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(1, dataLakeClient.properties.count)
    XCTAssertEqual(1, segmentClient.properties.count)

    let dataLakeClientProperties = dataLakeClient.properties.last
    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(false, dataLakeClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, dataLakeClientProperties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(true, dataLakeClientProperties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, dataLakeClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)

    XCTAssertEqual(false, segmentClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(true, segmentClientProperties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, segmentClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  func testProjectProperties_LoggedInCreator() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      <> Project.lens.personalization.isStarred .~ false
    let loggedInUser = project.creator
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackProjectViewed(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(1, dataLakeClient.properties.count)
    XCTAssertEqual(1, segmentClient.properties.count)

    let dataLakeClientProperties = dataLakeClient.properties.last
    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(true, dataLakeClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, dataLakeClientProperties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, dataLakeClientProperties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, dataLakeClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)

    XCTAssertEqual(true, segmentClientProperties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, segmentClientProperties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  // MARK: - Discovery Properties Tests

  func testDiscoveryProperties() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let params = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      <> DiscoveryParams.lens.starred .~ false
      <> DiscoveryParams.lens.social .~ false
      <> DiscoveryParams.lens.recommended .~ false
      <> DiscoveryParams.lens.category .~ (Category.documentary
        |> Category.lens.parent .~ .init(
          id: Category.filmAndVideo.id,
          name: Category.filmAndVideo.name
        )
      )
      <> DiscoveryParams.lens.query .~ "collage"
      <> DiscoveryParams.lens.sort .~ .popular
      <> DiscoveryParams.lens.tagId .~ .lightsOn
      <> DiscoveryParams.lens.page .~ 2

    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackDiscovery(params: params)

    let dataLakeClientProperties = dataLakeClient.properties.last
    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(30, dataLakeClientProperties?["discover_subcategory_id"] as? Int)
    XCTAssertEqual("Documentary", dataLakeClientProperties?["discover_subcategory_name"] as? String)
    XCTAssertEqual(false, dataLakeClientProperties?["discover_recommended"] as? Bool)
    XCTAssertEqual(false, dataLakeClientProperties?["discover_social"] as? Bool)
    XCTAssertEqual(true, dataLakeClientProperties?["discover_pwl"] as? Bool)
    XCTAssertEqual(false, dataLakeClientProperties?["discover_watched"] as? Bool)
    XCTAssertEqual(false, dataLakeClientProperties?["discover_everything"] as? Bool)
    XCTAssertEqual(Category.filmAndVideo.intID, dataLakeClientProperties?["discover_category_id"] as? Int)
    XCTAssertEqual(Category.filmAndVideo.name, dataLakeClientProperties?["discover_category_name"] as? String)
    XCTAssertEqual("popularity", dataLakeClientProperties?["discover_sort"] as? String)
    XCTAssertEqual("ios_project_collection_tag_557", dataLakeClientProperties?["discover_ref_tag"] as? String)
    XCTAssertEqual("collage", dataLakeClientProperties?["discover_search_term"] as? String)

    XCTAssertEqual(30, segmentClientProperties?["discover_subcategory_id"] as? Int)
    XCTAssertEqual("Documentary", segmentClientProperties?["discover_subcategory_name"] as? String)
    XCTAssertEqual(false, segmentClientProperties?["discover_recommended"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["discover_social"] as? Bool)
    XCTAssertEqual(true, segmentClientProperties?["discover_pwl"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["discover_watched"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["discover_everything"] as? Bool)
    XCTAssertEqual(Category.filmAndVideo.intID, segmentClientProperties?["discover_category_id"] as? Int)
    XCTAssertEqual(Category.filmAndVideo.name, segmentClientProperties?["discover_category_name"] as? String)
    XCTAssertEqual("popularity", segmentClientProperties?["discover_sort"] as? String)
    XCTAssertEqual("ios_project_collection_tag_557", segmentClientProperties?["discover_ref_tag"] as? String)
    XCTAssertEqual("collage", segmentClientProperties?["discover_search_term"] as? String)
  }

  func testDiscoveryProperties_NoCategory() {
    let dataLakeClient = MockTrackingClient()
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
      dataLakeClient: dataLakeClient,
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackDiscovery(params: params)

    let dataLakeClientProperties = dataLakeClient.properties.last
    let segmentClientProperties = segmentClient.properties.last

    XCTAssertNil(dataLakeClientProperties?["discover_category_id"])
    XCTAssertNil(dataLakeClientProperties?["discover_subcategory_id"])
    XCTAssertEqual(false, dataLakeClientProperties?["discover_recommended"] as? Bool)
    XCTAssertEqual(false, dataLakeClientProperties?["discover_social"] as? Bool)
    XCTAssertEqual(true, dataLakeClientProperties?["discover_pwl"] as? Bool)
    XCTAssertEqual(false, dataLakeClientProperties?["discover_watched"] as? Bool)
    XCTAssertEqual(false, dataLakeClientProperties?["discover_everything"] as? Bool)
    XCTAssertEqual("popularity", dataLakeClientProperties?["discover_sort"] as? String)

    XCTAssertNil(segmentClientProperties?["discover_category_id"])
    XCTAssertNil(segmentClientProperties?["discover_subcategory_id"])
    XCTAssertEqual(false, segmentClientProperties?["discover_recommended"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["discover_social"] as? Bool)
    XCTAssertEqual(true, segmentClientProperties?["discover_pwl"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["discover_watched"] as? Bool)
    XCTAssertEqual(false, segmentClientProperties?["discover_everything"] as? Bool)
    XCTAssertEqual("popularity", segmentClientProperties?["discover_sort"] as? String)
  }

  func testDiscoveryProperties_Everything() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()

    let params = .defaults
      |> DiscoveryParams.lens.sort .~ .magic

    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackDiscovery(params: params)

    let dataLakeClientProperties = dataLakeClient.properties.last
    let segmentClientProperties = segmentClient.properties.last

    XCTAssertNil(dataLakeClientProperties?["discover_category_id"])
    XCTAssertNil(dataLakeClientProperties?["discover_subcategory_id"])
    XCTAssertNil(dataLakeClientProperties?["discover_recommended"])
    XCTAssertNil(dataLakeClientProperties?["discover_social"])
    XCTAssertNil(dataLakeClientProperties?["discover_pwl"])
    XCTAssertNil(dataLakeClientProperties?["discover_watched"])
    XCTAssertNil(dataLakeClientProperties?["discover_search_term"])
    XCTAssertEqual(true, dataLakeClientProperties?["discover_everything"] as? Bool)
    XCTAssertEqual("magic", dataLakeClientProperties?["discover_sort"] as? String)

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

  // MARK: - Pledge Properties Tests

  func testPledgeProperties() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    let project = Project.cosmicSurgery
    let reward = Reward.template

    ksrAnalytics
      .trackRewardClicked(project: project, reward: reward, context: .newPledge, refTag: .recommended)

    let dataLakeClientProps = dataLakeClient.properties.last
    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(true, dataLakeClientProps?["pledge_backer_reward_has_items"] as? Bool)
    XCTAssertEqual(1, dataLakeClientProps?["pledge_backer_reward_id"] as? Int)
    XCTAssertEqual(10.00, dataLakeClientProps?["pledge_backer_reward_minimum"] as? Double)

    XCTAssertEqual("recommended", dataLakeClientProps?["session_ref_tag"] as? String)
    XCTAssertEqual("new_pledge", dataLakeClientProps?["context_pledge_flow"] as? String)

    XCTAssertEqual(true, segmentClientProps?["pledge_backer_reward_has_items"] as? Bool)
    XCTAssertEqual(1, segmentClientProps?["pledge_backer_reward_id"] as? Int)
    XCTAssertEqual(10.00, segmentClientProps?["pledge_backer_reward_minimum"] as? Double)

    XCTAssertEqual("recommended", segmentClientProps?["session_ref_tag"] as? String)
    XCTAssertEqual("new_pledge", segmentClientProps?["context_pledge_flow"] as? String)
  }

  func testPledgeProperties_NoReward() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    let project = Project.cosmicSurgery
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 5.0

    ksrAnalytics.trackRewardClicked(project: project, reward: reward, context: .changeReward, refTag: nil)

    let dataLakeClientProps = dataLakeClient.properties.last
    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(false, dataLakeClientProps?["pledge_backer_reward_has_items"] as? Bool)
    XCTAssertEqual(0, dataLakeClientProps?["pledge_backer_reward_id"] as? Int)
    XCTAssertEqual(5.00, dataLakeClientProps?["pledge_backer_reward_minimum"] as? Double)

    XCTAssertEqual("change_reward", dataLakeClientProps?["context_pledge_flow"] as? String)

    XCTAssertEqual(false, segmentClientProps?["pledge_backer_reward_has_items"] as? Bool)
    XCTAssertEqual(0, segmentClientProps?["pledge_backer_reward_id"] as? Int)
    XCTAssertEqual(5.00, segmentClientProps?["pledge_backer_reward_minimum"] as? Double)

    XCTAssertEqual("change_reward", segmentClientProps?["context_pledge_flow"] as? String)
  }

  func testPledgeProperties_ShippingPreference() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    let project = Project.cosmicSurgery
    let reward = Reward.template
      |> Reward.lens.shipping .~ (Reward.Shipping.template
        |> Reward.Shipping.lens.preference .~ Reward.Shipping.Preference.restricted)

    ksrAnalytics.trackRewardClicked(project: project, reward: reward, context: .manageReward, refTag: nil)

    let dataLakeClientProps = dataLakeClient.properties.last
    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual("manage_reward", dataLakeClientProps?["context_pledge_flow"] as? String)
    XCTAssertEqual("manage_reward", segmentClientProps?["context_pledge_flow"] as? String)
  }

  // MARK: - Project Page Tracking

  func testTrackCampaignDetailsButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackCampaignDetailsButtonClicked(
      project: .template,
      location: .projectPage,
      refTag: .discovery,
      cookieRefTag: .discovery
    )

    XCTAssertEqual(["Campaign Details Button Clicked"], dataLakeClient.events)
    XCTAssertEqual(["project"], dataLakeClient.properties(forKey: "context_page"))
    XCTAssertEqual(["discovery"], dataLakeClient.properties(forKey: "session_ref_tag"))
    XCTAssertEqual(["discovery"], dataLakeClient.properties(forKey: "session_referrer_credit"))

    self.assertProjectProperties(dataLakeClient.properties.last)

    XCTAssertEqual(["Campaign Details Button Clicked"], segmentClient.events)
    XCTAssertEqual(["project"], segmentClient.properties(forKey: "context_page"))
    XCTAssertEqual(["discovery"], segmentClient.properties(forKey: "session_ref_tag"))
    XCTAssertEqual(["discovery"], segmentClient.properties(forKey: "session_referrer_credit"))

    self.assertProjectProperties(segmentClient.properties.last)
  }

  func testTrackCampignDetailsPledgeButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackCampaignDetailsPledgeButtonClicked(
      project: .template,
      location: .campaign,
      refTag: .discovery,
      cookieRefTag: .discovery
    )

    XCTAssertEqual(["Campaign Details Pledge Button Clicked"], dataLakeClient.events)
    XCTAssertEqual(["campaign"], dataLakeClient.properties(forKey: "context_page"))
    XCTAssertEqual(["discovery"], dataLakeClient.properties(forKey: "session_ref_tag"))
    XCTAssertEqual(["discovery"], dataLakeClient.properties(forKey: "session_referrer_credit"))

    self.assertProjectProperties(dataLakeClient.properties.last)

    XCTAssertEqual(["Campaign Details Pledge Button Clicked"], segmentClient.events)
    XCTAssertEqual(["campaign"], segmentClient.properties(forKey: "context_page"))
    XCTAssertEqual(["discovery"], segmentClient.properties(forKey: "session_ref_tag"))
    XCTAssertEqual(["discovery"], segmentClient.properties(forKey: "session_referrer_credit"))

    self.assertProjectProperties(segmentClient.properties.last)
  }

  func testTrackCheckoutPaymentMethodViewed() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackCheckoutPaymentPageViewed(
      project: .template,
      reward: .template,
      context: .newPledge,
      refTag: RefTag.activity,
      cookieRefTag: RefTag.activity
    )

    let dataLakeClientProps = dataLakeClient.properties.last
    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(["Checkout Payment Page Viewed"], dataLakeClient.events)
    XCTAssertEqual(["Checkout Payment Page Viewed"], segmentClient.events)

    self.assertProjectProperties(dataLakeClientProps)
    self.assertPledgeProperties(dataLakeClientProps)

    self.assertProjectProperties(segmentClientProps)
    self.assertPledgeProperties(segmentClientProps)

    XCTAssertEqual("activity", dataLakeClientProps?["session_ref_tag"] as? String)
    XCTAssertEqual("new_pledge", dataLakeClientProps?["context_pledge_flow"] as? String)
    XCTAssertEqual("activity", segmentClientProps?["session_ref_tag"] as? String)
    XCTAssertEqual("new_pledge", segmentClientProps?["context_pledge_flow"] as? String)
  }

  func testLogEventsCallback() {
    let bundle = MockBundle()
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let config = Config.template
    let device = MockDevice(userInterfaceIdiom: .phone)
    let screen = MockScreen()
    let ksrAnalytics = KSRAnalytics(
      bundle: bundle, dataLakeClient: dataLakeClient, config: config, device: device, loggedInUser: nil,
      screen: screen,
      segmentClient: segmentClient
    )

    var callBackEvents = [String]()
    var callBackProperties: [String: Any]?
    ksrAnalytics.logEventCallback = { event, properties in
      callBackEvents.append(event)
      callBackProperties = properties
    }

    ksrAnalytics.trackTabBarClicked(.activity)

    XCTAssertEqual(["Tab Bar Clicked"], dataLakeClient.events)
    XCTAssertEqual(["Tab Bar Clicked"], callBackEvents)
    XCTAssertEqual("Apple", dataLakeClient.properties.last?["session_device_manufacturer"] as? String)
    XCTAssertEqual("Apple", callBackProperties?["session_device_manufacturer"] as? String)

    XCTAssertEqual(["Tab Bar Clicked"], segmentClient.events)
    XCTAssertEqual(["Tab Bar Clicked"], callBackEvents)
    XCTAssertEqual("Apple", segmentClient.properties.last?["session_device_manufacturer"] as? String)
    XCTAssertEqual("Apple", callBackProperties?["session_device_manufacturer"] as? String)
  }

  func testProjectCardClicked() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackProjectCardClicked(
      project: .template,
      params: DiscoveryParams.recommendedDefaults,
      location: .discovery
    )

    XCTAssertEqual(["Project Card Clicked"], dataLakeClient.events)
    XCTAssertEqual("discover", dataLakeClient.properties.last?["context_page"] as? String)

    self.assertProjectProperties(dataLakeClient.properties.last)
    self.assertDiscoveryProperties(dataLakeClient.properties.last)

    XCTAssertEqual(["Project Card Clicked"], segmentClient.events)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
    self.assertDiscoveryProperties(segmentClient.properties.last)
  }

  func testWatchProjectButtonClicked_DiscoveryLocationContext() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackWatchProjectButtonClicked(
      project: .template,
      location: .discovery,
      params: DiscoveryParams.recommendedDefaults
    )

    XCTAssertEqual(["Watch Project Button Clicked"], dataLakeClient.events)
    XCTAssertEqual("discover", dataLakeClient.properties.last?["context_page"] as? String)

    self.assertProjectProperties(dataLakeClient.properties.last)
    self.assertDiscoveryProperties(dataLakeClient.properties.last)

    XCTAssertEqual(["Watch Project Button Clicked"], segmentClient.events)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
    self.assertDiscoveryProperties(segmentClient.properties.last)
  }

  func testWatchProjectButtonClicked_ProjectPageLocationContext() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackWatchProjectButtonClicked(
      project: .template,
      location: .projectPage
    )

    XCTAssertEqual(["Watch Project Button Clicked"], dataLakeClient.events)
    XCTAssertEqual("project", dataLakeClient.properties.last?["context_page"] as? String)

    self.assertProjectProperties(dataLakeClient.properties.last)

    XCTAssertEqual(["Watch Project Button Clicked"], segmentClient.events)
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)

    self.assertProjectProperties(segmentClient.properties.last)
  }

  func testTrackPledgeCTAButtonClicked_FixState() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackPledgeCTAButtonClicked(stateType: .fix, project: project)

    XCTAssertEqual(["Manage Pledge Button Clicked"], dataLakeClient.events)
    XCTAssertEqual(["Manage Pledge Button Clicked"], segmentClient.events)
  }

  func testTrackPledgeCTAButtonClicked_PledgeState() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackPledgeCTAButtonClicked(stateType: .pledge, project: project)

    XCTAssertEqual(["Project Page Pledge Button Clicked"], dataLakeClient.events)
    XCTAssertEqual(["Project Page Pledge Button Clicked"], segmentClient.events)
  }

  func testTrackPledgeCTAButtonClicked_ManageState() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackPledgeCTAButtonClicked(stateType: .manage, project: project)

    XCTAssertEqual(["Manage Pledge Button Clicked"], dataLakeClient.events)
    XCTAssertEqual(["Manage Pledge Button Clicked"], segmentClient.events)
  }

  func testTrackSelectRewardButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let reward = Reward.template
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      loggedInUser: loggedInUser,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackRewardClicked(
      project: project,
      reward: reward,
      context: .newPledge,
      refTag: .category
    )

    let dataLakeClientProperties = dataLakeClient.properties.last
    let segmentClientProperties = segmentClient.properties.last

    XCTAssertEqual(["Select Reward Button Clicked"], dataLakeClient.events)
    XCTAssertEqual(["Select Reward Button Clicked"], segmentClient.events)

    self.assertPledgeProperties(dataLakeClientProperties)
    self.assertProjectProperties(dataLakeClientProperties)

    self.assertPledgeProperties(segmentClientProperties)
    self.assertProjectProperties(segmentClientProperties)

    XCTAssertEqual("new_pledge", dataLakeClientProperties?["context_pledge_flow"] as? String)
    XCTAssertEqual("category", dataLakeClientProperties?["session_ref_tag"] as? String)
    XCTAssertEqual("new_pledge", segmentClientProperties?["context_pledge_flow"] as? String)
    XCTAssertEqual("category", segmentClientProperties?["session_ref_tag"] as? String)
  }

  func testTrackPledgeSubmitButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)
    let reward = Reward.template
      |> Reward.lens.endsAt .~ 5.0
      |> Reward.lens.shipping.preference .~ .restricted

    ksrAnalytics.trackPledgeSubmitButtonClicked(
      project: .template,
      reward: reward,
      checkoutData: .template,
      refTag: nil
    )

    let dataLakeClientProps = dataLakeClient.properties.last
    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(["Pledge Submit Button Clicked"], dataLakeClient.events)

    self.assertProjectProperties(dataLakeClientProps)
    self.assertPledgeProperties(dataLakeClientProps)
    self.assertCheckoutProperties(dataLakeClientProps)

    XCTAssertEqual(["Pledge Submit Button Clicked"], segmentClient.events)

    self.assertProjectProperties(segmentClientProps)
    self.assertPledgeProperties(segmentClientProps)
    self.assertCheckoutProperties(segmentClientProps)
  }

  func testTrackPledgeSubmitButtonClicked_Context() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)
    let reward = Reward.template
      |> Reward.lens.endsAt .~ 5.0
      |> Reward.lens.shipping.preference .~ .restricted

    ksrAnalytics.trackPledgeSubmitButtonClicked(
      project: .template,
      reward: reward,
      context: .manageReward,
      refTag: nil
    )

    let dataLakeClientProps = dataLakeClient.properties.last
    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(["Pledge Submit Button Clicked"], dataLakeClient.events)

    self.assertProjectProperties(dataLakeClientProps)
    self.assertPledgeProperties(dataLakeClientProps)

    XCTAssertEqual(["Pledge Submit Button Clicked"], segmentClient.events)

    self.assertProjectProperties(segmentClientProps)
    self.assertPledgeProperties(segmentClientProps)
  }

  func testTrackAddNewCardButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackAddNewCardButtonClicked(
      context: .newPledge,
      project: .template,
      refTag: .activity,
      reward: .template
    )

    let dataLakeClientProps = dataLakeClient.properties.last
    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual(["Add New Card Button Clicked"], dataLakeClient.events)

    self.assertProjectProperties(dataLakeClientProps)
    self.assertPledgeProperties(dataLakeClientProps)

    XCTAssertEqual("new_pledge", dataLakeClientProps?["context_pledge_flow"] as? String)
    XCTAssertEqual("activity", dataLakeClientProps?["session_ref_tag"] as? String)

    XCTAssertEqual(["Add New Card Button Clicked"], segmentClient.events)

    self.assertProjectProperties(segmentClientProps)
    self.assertPledgeProperties(segmentClientProps)

    XCTAssertEqual("new_pledge", segmentClientProps?["context_pledge_flow"] as? String)
    XCTAssertEqual("activity", segmentClientProps?["session_ref_tag"] as? String)
  }

  // MARK: - Onboarding Tracking

  func testOnboardingGetStartedButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackOnboardingGetStartedButtonClicked()

    XCTAssertEqual(["Onboarding Get Started Button Clicked"], dataLakeClient.events)

    XCTAssertEqual(["landing_page"], dataLakeClient.properties(forKey: "context_page"))

    XCTAssertEqual(["Onboarding Get Started Button Clicked"], segmentClient.events)

    XCTAssertEqual(["landing_page"], segmentClient.properties(forKey: "context_page"))
  }

  func testOnboardingCarouselSwipedButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackOnboardingCarouselSwiped()

    XCTAssertEqual(["Onboarding Carousel Swiped"], dataLakeClient.events)

    XCTAssertEqual(["landing_page"], dataLakeClient.properties(forKey: "context_page"))

    XCTAssertEqual(["Onboarding Carousel Swiped"], segmentClient.events)

    XCTAssertEqual(["landing_page"], segmentClient.properties(forKey: "context_page"))
  }

  func testOnboardingSkipButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackOnboardingSkipButtonClicked()

    XCTAssertEqual(["Onboarding Skip Button Clicked"], dataLakeClient.events)

    XCTAssertEqual(["onboarding"], dataLakeClient.properties(forKey: "context_page"))

    XCTAssertEqual(["Onboarding Skip Button Clicked"], segmentClient.events)

    XCTAssertEqual(["onboarding"], segmentClient.properties(forKey: "context_page"))
  }

  func testOnboardingContinueButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackOnboardingContinueButtonClicked()

    XCTAssertEqual(["Onboarding Continue Button Clicked"], dataLakeClient.events)

    XCTAssertEqual(["onboarding"], dataLakeClient.properties(forKey: "context_page"))

    XCTAssertEqual(["Onboarding Continue Button Clicked"], segmentClient.events)

    XCTAssertEqual(["onboarding"], segmentClient.properties(forKey: "context_page"))
  }

  // MARK: - Search Tracking

  func testTrackSearchViewed() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackProjectSearchView()

    XCTAssertEqual(["Search Page Viewed"], dataLakeClient.events)
    XCTAssertEqual(["Search Page Viewed"], segmentClient.events)
  }

  func testTrackSearchResults() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackSearchResults(
      query: "query",
      params: DiscoveryParams.defaults,
      refTag: .search,
      hasResults: true
    )

    let dataLakeClientProps = dataLakeClient.properties.last
    let segmentClientClientProps = segmentClient.properties.last

    XCTAssertEqual(["Search Results Loaded"], dataLakeClient.events)
    XCTAssertEqual("query", dataLakeClientProps?["search_term"] as? String)
    XCTAssertEqual("search", dataLakeClientProps?["discover_ref_tag"] as? String)
    XCTAssertEqual(true, dataLakeClientProps?["has_results"] as? Bool)

    XCTAssertEqual(["Search Results Loaded"], segmentClient.events)
    XCTAssertEqual("query", segmentClientClientProps?["search_term"] as? String)
    XCTAssertEqual("search", segmentClientClientProps?["discover_ref_tag"] as? String)
    XCTAssertEqual(true, segmentClientClientProps?["has_results"] as? Bool)
  }

  func testUserProperties_loggedOut() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let config = Config.template |> Config.lens.countryCode .~ "US"
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      config: config,
      loggedInUser: nil,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(.activity)

    let dataLakeClientProps = dataLakeClient.properties.last
    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual("US", dataLakeClientProps?["user_country"] as? String)
    XCTAssertNil(dataLakeClientProps?["user_uid"])

    XCTAssertEqual("US", segmentClientProps?["user_country"] as? String)
    XCTAssertNil(segmentClientProps?["user_uid"])
  }

  func testUserProperties_loggedIn() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()

    let user = User.template
      |> User.lens.stats.backedProjectsCount .~ 5
      |> User.lens.location .~ Location.usa
      |> User.lens.facebookConnected .~ true
      |> User.lens.stats.starredProjectsCount .~ 2
      |> User.lens.stats.createdProjectsCount .~ 3
      |> User.lens.id .~ 10
      |> User.lens.isAdmin .~ false

    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      loggedInUser: user,
      segmentClient: segmentClient
    )

    ksrAnalytics.trackTabBarClicked(.activity)

    let dataLakeClientProps = dataLakeClient.properties.last
    let segmentClientProps = segmentClient.properties.last

    XCTAssertEqual("US", dataLakeClientProps?["user_country"] as? String)
    XCTAssertEqual(10, dataLakeClientProps?["user_uid"] as? Int)

    XCTAssertEqual("US", segmentClientProps?["user_country"] as? String)
    XCTAssertEqual(10, segmentClientProps?["user_uid"] as? Int)
  }

  func testTabBarClicked() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    let tabBarActivity = KSRAnalytics.TabBarItemLabel.activity
    let tabBarDashboard = KSRAnalytics.TabBarItemLabel.dashboard
    let tabBarHome = KSRAnalytics.TabBarItemLabel.discovery
    let tabBarProfile = KSRAnalytics.TabBarItemLabel.profile
    let tabBarSearch = KSRAnalytics.TabBarItemLabel.search

    ksrAnalytics.trackTabBarClicked(tabBarActivity)

    XCTAssertEqual(["Tab Bar Clicked"], dataLakeClient.events)
    XCTAssertEqual("activity", dataLakeClient.properties.last?["context_tab_bar_label"] as? String)

    XCTAssertEqual(["Tab Bar Clicked"], segmentClient.events)
    XCTAssertEqual("activity", segmentClient.properties.last?["context_tab_bar_label"] as? String)

    ksrAnalytics.trackTabBarClicked(tabBarDashboard)

    XCTAssertEqual(["Tab Bar Clicked", "Tab Bar Clicked"], dataLakeClient.events)
    XCTAssertEqual("dashboard", dataLakeClient.properties.last?["context_tab_bar_label"] as? String)

    XCTAssertEqual(["Tab Bar Clicked", "Tab Bar Clicked"], segmentClient.events)
    XCTAssertEqual("dashboard", segmentClient.properties.last?["context_tab_bar_label"] as? String)

    ksrAnalytics.trackTabBarClicked(tabBarHome)

    XCTAssertEqual(["Tab Bar Clicked", "Tab Bar Clicked", "Tab Bar Clicked"], dataLakeClient.events)
    XCTAssertEqual("discovery", dataLakeClient.properties.last?["context_tab_bar_label"] as? String)

    XCTAssertEqual(["Tab Bar Clicked", "Tab Bar Clicked", "Tab Bar Clicked"], segmentClient.events)
    XCTAssertEqual("discovery", segmentClient.properties.last?["context_tab_bar_label"] as? String)

    ksrAnalytics.trackTabBarClicked(tabBarProfile)

    XCTAssertEqual(
      ["Tab Bar Clicked", "Tab Bar Clicked", "Tab Bar Clicked", "Tab Bar Clicked"],
      dataLakeClient.events
    )
    XCTAssertEqual("profile", dataLakeClient.properties.last?["context_tab_bar_label"] as? String)

    XCTAssertEqual(
      ["Tab Bar Clicked", "Tab Bar Clicked", "Tab Bar Clicked", "Tab Bar Clicked"],
      segmentClient.events
    )
    XCTAssertEqual("profile", segmentClient.properties.last?["context_tab_bar_label"] as? String)

    ksrAnalytics.trackTabBarClicked(tabBarSearch)

    XCTAssertEqual([
      "Tab Bar Clicked",
      "Tab Bar Clicked",
      "Tab Bar Clicked",
      "Tab Bar Clicked",
      "Tab Bar Clicked"
    ], dataLakeClient.events)
    XCTAssertEqual("search", dataLakeClient.properties.last?["context_tab_bar_label"] as? String)

    XCTAssertEqual([
      "Tab Bar Clicked",
      "Tab Bar Clicked",
      "Tab Bar Clicked",
      "Tab Bar Clicked",
      "Tab Bar Clicked"
    ], segmentClient.events)
    XCTAssertEqual("search", segmentClient.properties.last?["context_tab_bar_label"] as? String)
  }

  func testTrackProjectViewedEvent() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackProjectViewed(Project.template) // approved event

    XCTAssertEqual(
      ["Project Page Viewed"], dataLakeClient.events,
      "Approved event is tracked by data lake client"
    )
    XCTAssertEqual(
      ["Project Page Viewed"], segmentClient.events,
      "Approved event is tracked by segment client"
    )
  }

  func testIdentifyingTrackingClient() {
    let user = User.template
      |> User.lens.stats.backedProjectsCount .~ 2
      |> User.lens.stats.createdProjectsCount .~ 3

    AppEnvironment.updateCurrentUser(user)

    XCTAssertEqual(self.segmentTrackingClient.userId, "\(user.id)")
    XCTAssertEqual(self.segmentTrackingClient.traits?["name"] as? String, user.name)
    XCTAssertEqual(self.segmentTrackingClient.traits?["is_creator"] as? Bool, user.isCreator)
    XCTAssertEqual(
      self.segmentTrackingClient.traits?["backed_projects_count"] as? Int,
      user.stats.backedProjectsCount
    )
    XCTAssertEqual(
      self.segmentTrackingClient.traits?["created_projects_count"] as? Int,
      user.stats.createdProjectsCount
    )

    let user2 = user
      |> User.lens.id .~ 9_999
      |> User.lens.name .~ "Another User"
      |> User.lens.stats.backedProjectsCount .~ 4
      |> User.lens.stats.createdProjectsCount .~ 0

    AppEnvironment.updateCurrentUser(user2)

    XCTAssertEqual(self.segmentTrackingClient.userId, "\(user2.id)")
    XCTAssertEqual(self.segmentTrackingClient.traits?["name"] as? String, user2.name)
    XCTAssertEqual(self.segmentTrackingClient.traits?["is_creator"] as? Bool, user2.isCreator)
    XCTAssertEqual(
      self.segmentTrackingClient.traits?["backed_projects_count"] as? Int,
      user2.stats.backedProjectsCount
    )
    XCTAssertEqual(
      self.segmentTrackingClient.traits?["created_projects_count"] as? Int,
      user2.stats.createdProjectsCount
    )

    AppEnvironment.logout()

    XCTAssertNil(self.segmentTrackingClient.userId)
    XCTAssertNil(self.segmentTrackingClient.traits)
  }

  func testContextProperties() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackTabBarClicked(.activity)

    XCTAssertEqual("activity", dataLakeClient.properties.last?["context_tab_bar_label"] as? String)
    XCTAssertEqual("activity", segmentClient.properties.last?["context_tab_bar_label"] as? String)
  }

  func testContextLocationProperties() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackActivities(count: 1)
    XCTAssertEqual(
      "activity_feed",
      dataLakeClient.properties.last?["context_page"] as? String
    )
    XCTAssertEqual(
      "activity_feed",
      segmentClient.properties.last?["context_page"] as? String
    )

    ksrAnalytics.trackAddNewCardButtonClicked(
      context: .newPledge,
      location: .pledgeAddNewCard,
      project: .template,
      refTag: nil,
      reward: .template
    )
    XCTAssertEqual(
      "pledge_add_new_card",
      dataLakeClient.properties.last?["context_page"] as? String
    )
    XCTAssertEqual(
      "pledge_add_new_card",
      segmentClient.properties.last?["context_page"] as? String
    )

    ksrAnalytics.trackAddNewCardButtonClicked(
      context: .newPledge,
      location: .settingsAddNewCard,
      project: .template,
      refTag: nil,
      reward: .template
    )
    XCTAssertEqual(
      "settings_add_new_card",
      dataLakeClient.properties.last?["context_page"] as? String
    )
    XCTAssertEqual(
      "settings_add_new_card",
      segmentClient.properties.last?["context_page"] as? String
    )

    ksrAnalytics.trackCheckoutPaymentPageViewed(
      project: .template,
      reward: .template,
      context: .newPledge,
      refTag: nil,
      cookieRefTag: nil
    )
    XCTAssertEqual("pledge", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("pledge", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackCollectionViewed(params: .defaults)
    XCTAssertEqual(
      "editorial_collection",
      dataLakeClient.properties.last?["context_page"] as? String
    )
    XCTAssertEqual(
      "editorial_collection",
      segmentClient.properties.last?["context_page"] as? String
    )

    ksrAnalytics.trackDiscovery(params: .defaults)
    XCTAssertEqual("discover", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackDiscoveryModalSelectedFilter(params: .defaults)
    XCTAssertEqual("discover", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackEditorialHeaderTapped(params: .defaults, refTag: .discovery)
    XCTAssertEqual("discover", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackFacebookLoginOrSignupButtonClicked(intent: .generic)
    XCTAssertEqual("log_in_sign_up", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("log_in_sign_up", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackForgotPasswordViewed()
    XCTAssertEqual("forgot_password", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("forgot_password", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackLoginButtonClicked(intent: .generic)
    XCTAssertEqual("log_in_sign_up", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("log_in_sign_up", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackLoginOrSignupButtonClicked(intent: .generic)
    XCTAssertEqual("discover", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("discover", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackLoginOrSignupPageViewed(intent: .generic)
    XCTAssertEqual("log_in_sign_up", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("log_in_sign_up", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackLoginSubmitButtonClicked()
    XCTAssertEqual("log_in", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("log_in", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackPledgeCTAButtonClicked(stateType: .pledge, project: .template)
    XCTAssertEqual("project", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackProjectSearchView()
    XCTAssertEqual("search", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("search", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackProjectViewed(.template)
    XCTAssertEqual("project", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackRewardClicked(project: .template, reward: .template, context: .newPledge, refTag: nil)
    XCTAssertEqual("rewards", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("rewards", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackSearchResults(query: "", params: .defaults, refTag: .search, hasResults: false)
    XCTAssertEqual("search", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("search", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackSwipedProject(.template, refTag: nil)
    XCTAssertEqual("project", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("project", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackSignupSubmitButtonClicked()
    XCTAssertEqual("sign_up", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("sign_up", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.trackThanksPageViewed(project: .template, reward: .template, checkoutData: nil)
    XCTAssertEqual("thanks", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("thanks", segmentClient.properties.last?["context_page"] as? String)

    ksrAnalytics.track2FAViewed()
    XCTAssertEqual(
      "two_factor_auth",
      dataLakeClient.properties.last?["context_page"] as? String
    )
    XCTAssertEqual(
      "two_factor_auth",
      segmentClient.properties.last?["context_page"] as? String
    )

    ksrAnalytics.trackEmailVerificationScreenViewed()
    XCTAssertEqual("email_verification", dataLakeClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("email_verification", segmentClient.properties.last?["context_page"] as? String)
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
  private func assertProjectProperties(_ props: [String: Any]?) {
    XCTAssertEqual(10, props?["project_backers_count"] as? Int)
    XCTAssertEqual("US", props?["project_country"] as? String)
    XCTAssertEqual("USD", props?["project_currency"] as? String)
    XCTAssertEqual(2_000, props?["project_goal"] as? Int)
    XCTAssertEqual(1, props?["project_pid"] as? Int)
    XCTAssertEqual(0.50, props?["project_percent_raised"] as? Float)
    XCTAssertEqual("Art", props?["project_subcategory"] as? String)
    XCTAssertEqual(1, props?["project_subcategory_id"] as? Int)

    XCTAssertEqual("Brooklyn", props?["project_location"] as? String)
    XCTAssertEqual(1, props?["project_creator_uid"] as? Int)
    XCTAssertEqual(24 * 15, props?["project_hours_remaining"] as? Int)
    XCTAssertEqual(30, props?["project_duration"] as? Int)
    XCTAssertEqual(1_476_657_315, props?["project_deadline"] as? Double)
    XCTAssertEqual(1_474_065_315, props?["project_launched_at"] as? Double)
    XCTAssertEqual(1, props?["project_static_usd_rate"] as? Float)
    XCTAssertEqual("live", props?["project_state"] as? String)
    XCTAssertEqual(1_000, props?["project_current_pledge_amount"] as? Int)
    XCTAssertEqual(1_000, props?["project_current_amount_pledged_usd"] as? Float)
    XCTAssertEqual(2_000, props?["project_goal_usd"] as? Float)
    XCTAssertEqual(true, props?["project_has_video"] as? Bool)
    XCTAssertEqual(10, props?["project_comments_count"] as? Int)
    XCTAssertEqual(0, props?["project_rewards_count"] as? Int)
    XCTAssertEqual(1, props?["project_updates_count"] as? Int)

    XCTAssertEqual(false, props?["project_user_is_project_creator"] as? Bool)
    XCTAssertNil(props?["project_user_is_backer"])
    XCTAssertNil(props?["project_user_has_starred"])
    XCTAssertNil(props?["project_category"] as? String)
    XCTAssertNil(props?["project_category_id"] as? String)
    XCTAssertNil(props?["project_prelaunch_activated"] as? Bool)
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
    XCTAssertEqual("8.00", props?["checkout_add_ons_minimum_usd"] as? String)
    XCTAssertEqual("43.00", props?["checkout_amount"] as? String)
    XCTAssertEqual("10.00", props?["checkout_bonus_amount"] as? String)
    XCTAssertEqual("10.00", props?["checkout_bonus_amount_usd"] as? String)
    XCTAssertEqual("CREDIT_CARD", props?["checkout_payment_type"] as? String)
    XCTAssertEqual("SUPER reward", props?["checkout_reward_title"] as? String)
    XCTAssertEqual("5.00", props?["checkout_reward_minimum_usd"] as? String)
    XCTAssertEqual(2, props?["checkout_reward_id"] as? Int)
    XCTAssertEqual(20.00, props?["checkout_amount_total_usd"] as? Double)
    XCTAssertEqual(true, props?["checkout_reward_is_limited_quantity"] as? Bool)
    XCTAssertEqual(true, props?["checkout_reward_is_limited_time"] as? Bool)
    XCTAssertEqual(true, props?["checkout_reward_shipping_enabled"] as? Bool)
    XCTAssertEqual("restricted", props?["checkout_reward_shipping_preference"] as? String)
    XCTAssertEqual(true, props?["checkout_user_has_eligible_stored_apple_pay_card"] as? Bool)
    XCTAssertEqual(10.00, props?["checkout_shipping_amount"] as? Double)
    XCTAssertEqual("10.00", props?["checkout_shipping_amount_usd"] as? String)
    XCTAssertEqual(12_345_678, props?["checkout_reward_estimated_delivery_on"] as? TimeInterval)
  }
}

extension KSRAnalytics.CheckoutPropertiesData {
  static let template = KSRAnalytics.CheckoutPropertiesData(
    addOnsCountTotal: 2,
    addOnsCountUnique: 1,
    addOnsMinimumUsd: "8.00",
    amount: "43.00",
    bonusAmount: "10.00",
    bonusAmountInUsd: "10.00",
    checkoutId: 1,
    estimatedDelivery: 12_345_678,
    paymentType: "CREDIT_CARD",
    revenueInUsd: 20.00,
    rewardId: 2,
    rewardMinimumUsd: "5.00",
    rewardTitle: "SUPER reward",
    shippingEnabled: true,
    shippingAmount: 10,
    shippingAmountUsd: "10.00",
    userHasStoredApplePayCard: true
  )
}
