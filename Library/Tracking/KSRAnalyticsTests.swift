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
      distinctId: "abc-123"
    )

    ksrAnalytics.trackTabBarClicked(.activity)

    let properties = dataLakeClient.properties.last

    XCTAssertEqual(
      ["native_checkout[experimental]", "other_experiment[control]"],
      properties?["session_current_variants"] as? [String]
    )
    XCTAssertEqual(
      [
        "ios_enabled_feature"
      ],
      properties?["session_enabled_features"] as? [String]
    )

    XCTAssertEqual("native", properties?["session_client_type"] as? String)
    XCTAssertEqual("1234567890", properties?["session_app_build_number"] as? String)
    XCTAssertEqual("1.2.3.4.5.6.7.8.9.0", properties?["session_app_release_version"] as? String)
    XCTAssertEqual("phone", properties?["session_device_format"] as? String)
    XCTAssertEqual("Apple", properties?["session_device_manufacturer"] as? String)
    XCTAssertEqual("Portrait", properties?["session_device_orientation"] as? String)
    XCTAssertEqual("abc-123", properties?["session_device_distinct_id"] as? String)
    XCTAssertEqual(["service": "wifi"], properties?["session_cellular_connection"] as? [String: String]?)

    XCTAssertEqual("MockSystemName", properties?["session_os"] as? String)
    XCTAssertEqual("MockSystemVersion", properties?["session_os_version"] as? String)
    XCTAssertEqual(UInt(screen.bounds.width), properties?["session_screen_width"] as? UInt)
    XCTAssertEqual("kickstarter_ios", properties?["session_mp_lib"] as? String)
    XCTAssertEqual(false, properties?["session_user_logged_in"] as? Bool)
    XCTAssertEqual("ios", properties?["session_client_platform"] as? String)
    XCTAssertEqual("en", properties?["session_display_language"] as? String)

    XCTAssertEqual(23, properties?.keys.filter { $0.hasPrefix("session_") }.count)
  }

  func testSessionProperties_Language() {
    withEnvironment(language: Language.es) {
      let dataLakeClient = MockTrackingClient()
      let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

      ksrAnalytics.trackTabBarClicked(.activity)

      let properties = dataLakeClient.properties.last

      XCTAssertEqual("es", properties?["session_display_language"] as? String)
    }
  }

  func testSessionProperties_VoiceOver() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    withEnvironment(isVoiceOverRunning: { true }) {
      ksrAnalytics.trackTabBarClicked(.activity)

      let properties = dataLakeClient.properties.last

      XCTAssertEqual(true, properties?["session_is_voiceover_running"] as? Bool)
    }

    withEnvironment(isVoiceOverRunning: { false }) {
      ksrAnalytics.trackTabBarClicked(.activity)

      let properties = dataLakeClient.properties.last

      XCTAssertEqual(false, properties?["session_is_voiceover_running"] as? Bool)
    }
  }

  func testSessionProperties_LoggedIn() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: User.template)

    ksrAnalytics.trackTabBarClicked(.activity)

    let properties = dataLakeClient.properties.last

    XCTAssertEqual(true, properties?["session_user_logged_in"] as? Bool)
  }

  func testSessionProperties_DeviceFormatAndClientPlatform_ForIPhoneIdiom() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      device: MockDevice(userInterfaceIdiom: .phone),
      loggedInUser: nil
    )
    ksrAnalytics.trackTabBarClicked(.activity)

    XCTAssertEqual("phone", dataLakeClient.properties.last?["session_device_format"] as? String)
    XCTAssertEqual("ios", dataLakeClient.properties.last?["session_client_platform"] as? String)
  }

  func testSessionProperties_DeviceFormatAndClientPlatform_ForIPadIdiom() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      device: MockDevice(userInterfaceIdiom: .pad),
      loggedInUser: nil
    )
    ksrAnalytics.trackTabBarClicked(.activity)

    XCTAssertEqual("tablet", dataLakeClient.properties.last?["session_device_format"] as? String)
    XCTAssertEqual("ios", dataLakeClient.properties.last?["session_client_platform"] as? String)
  }

  func testSessionProperties_DeviceFormatAndClientPlatform_ForTvIdiom() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      dataLakeClient: dataLakeClient,
      device: MockDevice(userInterfaceIdiom: .tv),
      loggedInUser: nil
    )
    ksrAnalytics.trackTabBarClicked(.activity)

    XCTAssertEqual("tv", dataLakeClient.properties.last?["session_device_format"] as? String)
    XCTAssertEqual("tvos", dataLakeClient.properties.last?["session_client_platform"] as? String)
  }

  func testSessionProperties_DeviceOrientation() {
    let dataLakeClient = MockTrackingClient()
    let device = MockDevice(orientation: .faceDown)
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, device: device)

    ksrAnalytics.trackTabBarClicked(.activity)

    let props = dataLakeClient.properties.last

    XCTAssertEqual("Face Down", props?["session_device_orientation"] as? String)
  }

  // MARK: - Project Properties Tests

  func testProjectProperties() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: nil)
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

    let properties = dataLakeClient.properties.last

    XCTAssertEqual("Project Page Viewed", dataLakeClient.events.last)
    XCTAssertEqual(project.stats.backersCount, properties?["project_backers_count"] as? Int)
    XCTAssertEqual(project.country.countryCode, properties?["project_country"] as? String)
    XCTAssertEqual(project.country.currencyCode, properties?["project_currency"] as? String)
    XCTAssertEqual(project.stats.goal, properties?["project_goal"] as? Int)
    XCTAssertEqual(project.id, properties?["project_pid"] as? Int)
    XCTAssertEqual(project.stats.fundingProgress, properties?["project_percent_raised"] as? Float)
    XCTAssertEqual(project.category.name, properties?["project_subcategory"] as? String)
    XCTAssertEqual(123, properties?["project_subcategory_id"] as? Int)
    XCTAssertEqual("Art", properties?["project_category"] as? String)
    XCTAssertEqual(321, properties?["project_category_id"] as? Int)
    XCTAssertEqual(project.location.name, properties?["project_location"] as? String)
    XCTAssertEqual(project.creator.id, properties?["project_creator_uid"] as? Int)
    XCTAssertEqual(24 * 15, properties?["project_hours_remaining"] as? Int)
    XCTAssertEqual(30, properties?["project_duration"] as? Int)
    XCTAssertEqual(1_476_657_315, properties?["project_deadline"] as? Double)
    XCTAssertEqual(1_474_065_315, properties?["project_launched_at"] as? Double)
    XCTAssertEqual(2, properties?["project_static_usd_rate"] as? Float)
    XCTAssertEqual("live", properties?["project_state"] as? String)
    XCTAssertEqual(project.stats.pledged, properties?["project_current_pledge_amount"] as? Int)
    XCTAssertEqual(2_000, properties?["project_current_pledge_amount_usd"] as? Int)
    XCTAssertEqual(4_000, properties?["project_goal_usd"] as? Int)
    XCTAssertEqual(true, properties?["project_has_video"] as? Bool)
    XCTAssertEqual(10, properties?["project_comments_count"] as? Int)
    XCTAssertEqual(true, properties?["project_prelaunch_activated"] as? Bool)
    XCTAssertEqual(1, properties?["project_rewards_count"] as? Int)
    XCTAssertEqual(1, properties?["project_updates_count"] as? Int)

    XCTAssertEqual(false, properties?["project_user_is_project_creator"] as? Bool)
    XCTAssertNil(properties?["project_user_is_backer"])
    XCTAssertNil(properties?["project_user_has_starred"])

    XCTAssertEqual(28, properties?.keys.filter { $0.hasPrefix("project_") }.count)

    XCTAssertEqual("discovery", properties?["session_ref_tag"] as? String)
    XCTAssertEqual("recommended", properties?["session_referrer_credit"] as? String)
  }

  func testProjectProperties_LoggedInUser() {
    let dataLakeClient = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      <> Project.lens.personalization.isStarred .~ false
    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: loggedInUser)

    ksrAnalytics.trackProjectViewed(project, refTag: nil, cookieRefTag: nil)

    XCTAssertEqual(1, dataLakeClient.properties.count)

    let properties = dataLakeClient.properties.last

    XCTAssertEqual(false, properties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, properties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, properties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, properties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  func testProjectProperties_LoggedInBacker() {
    let dataLakeClient = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.isStarred .~ false
    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: loggedInUser)

    ksrAnalytics.trackProjectViewed(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(1, dataLakeClient.properties.count)

    let properties = dataLakeClient.properties.last

    XCTAssertEqual(false, properties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(true, properties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, properties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, properties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  func testProjectProperties_LoggedInStarrer() {
    let dataLakeClient = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.isStarred .~ true
    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: loggedInUser)

    ksrAnalytics.trackProjectViewed(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(1, dataLakeClient.properties.count)

    let properties = dataLakeClient.properties.last

    XCTAssertEqual(false, properties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, properties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(true, properties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, properties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  func testProjectProperties_LoggedInCreator() {
    let dataLakeClient = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      <> Project.lens.personalization.isStarred .~ false
    let loggedInUser = project.creator
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: loggedInUser)

    ksrAnalytics.trackProjectViewed(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(1, dataLakeClient.properties.count)

    let properties = dataLakeClient.properties.last

    XCTAssertEqual(true, properties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, properties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, properties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, properties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  // MARK: - Discovery Properties Tests

  func testDiscoveryProperties() {
    let dataLakeClient = MockTrackingClient()
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
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: loggedInUser)

    ksrAnalytics.trackDiscovery(params: params)

    let properties = dataLakeClient.properties.last

    XCTAssertEqual(30, properties?["discover_subcategory_id"] as? Int)
    XCTAssertEqual("Documentary", properties?["discover_subcategory_name"] as? String)
    XCTAssertEqual(false, properties?["discover_recommended"] as? Bool)
    XCTAssertEqual(false, properties?["discover_social"] as? Bool)
    XCTAssertEqual(true, properties?["discover_pwl"] as? Bool)
    XCTAssertEqual(false, properties?["discover_watched"] as? Bool)
    XCTAssertEqual(false, properties?["discover_everything"] as? Bool)
    XCTAssertEqual(Category.filmAndVideo.intID, properties?["discover_category_id"] as? Int)
    XCTAssertEqual(Category.filmAndVideo.name, properties?["discover_category_name"] as? String)
    XCTAssertEqual("popularity", properties?["discover_sort"] as? String)
    XCTAssertEqual("ios_project_collection_tag_557", properties?["discover_ref_tag"] as? String)
    XCTAssertEqual("collage", properties?["discover_search_term"] as? String)
  }

  func testDiscoveryProperties_NoCategory() {
    let dataLakeClient = MockTrackingClient()
    let params = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      <> DiscoveryParams.lens.starred .~ false
      <> DiscoveryParams.lens.social .~ false
      <> DiscoveryParams.lens.recommended .~ false
      <> DiscoveryParams.lens.category .~ nil
      <> DiscoveryParams.lens.sort .~ .popular

    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: loggedInUser)

    ksrAnalytics.trackDiscovery(params: params)

    let properties = dataLakeClient.properties.last

    XCTAssertNil(properties?["discover_category_id"])
    XCTAssertNil(properties?["discover_subcategory_id"])
    XCTAssertEqual(false, properties?["discover_recommended"] as? Bool)
    XCTAssertEqual(false, properties?["discover_social"] as? Bool)
    XCTAssertEqual(true, properties?["discover_pwl"] as? Bool)
    XCTAssertEqual(false, properties?["discover_watched"] as? Bool)
    XCTAssertEqual(false, properties?["discover_everything"] as? Bool)
    XCTAssertEqual("popularity", properties?["discover_sort"] as? String)
  }

  func testDiscoveryProperties_Everything() {
    let dataLakeClient = MockTrackingClient()

    let params = .defaults
      |> DiscoveryParams.lens.sort .~ .magic

    let loggedInUser = User.template |> \.id .~ 42
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: loggedInUser)

    ksrAnalytics.trackDiscovery(params: params)

    let properties = dataLakeClient.properties.last

    XCTAssertNil(properties?["discover_category_id"])
    XCTAssertNil(properties?["discover_subcategory_id"])
    XCTAssertNil(properties?["discover_recommended"])
    XCTAssertNil(properties?["discover_social"])
    XCTAssertNil(properties?["discover_pwl"])
    XCTAssertNil(properties?["discover_watched"])
    XCTAssertNil(properties?["discover_search_term"])
    XCTAssertEqual(true, properties?["discover_everything"] as? Bool)
    XCTAssertEqual("magic", properties?["discover_sort"] as? String)
  }

  // MARK: - Pledge Properties Tests

  func testPledgeProperties() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    let project = Project.cosmicSurgery
    let reward = Reward.template

    ksrAnalytics
      .trackRewardClicked(project: project, reward: reward, context: .newPledge, refTag: .recommended)

    let props = dataLakeClient.properties.last

    XCTAssertEqual(true, props?["pledge_backer_reward_has_items"] as? Bool)
    XCTAssertEqual(1, props?["pledge_backer_reward_id"] as? Int)
    XCTAssertEqual(true, props?["pledge_backer_reward_is_limited_quantity"] as? Bool)
    XCTAssertEqual(false, props?["pledge_backer_reward_is_limited_time"] as? Bool)
    XCTAssertEqual(10.00, props?["pledge_backer_reward_minimum"] as? Double)
    XCTAssertEqual(false, props?["pledge_backer_reward_shipping_enabled"] as? Bool)
    XCTAssertNil(props?["pledge_backer_reward_shipping_preference"] as? String)

    XCTAssertEqual("recommended", props?["session_ref_tag"] as? String)
    XCTAssertEqual("new_pledge", props?["context_pledge_flow"] as? String)
  }

  func testPledgeProperties_NoReward() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    let project = Project.cosmicSurgery
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 5.0

    ksrAnalytics.trackRewardClicked(project: project, reward: reward, context: .changeReward, refTag: nil)

    let props = dataLakeClient.properties.last

    XCTAssertEqual(false, props?["pledge_backer_reward_has_items"] as? Bool)
    XCTAssertEqual(0, props?["pledge_backer_reward_id"] as? Int)
    XCTAssertEqual(false, props?["pledge_backer_reward_is_limited_quantity"] as? Bool)
    XCTAssertEqual(false, props?["pledge_backer_reward_is_limited_time"] as? Bool)
    XCTAssertEqual(5.00, props?["pledge_backer_reward_minimum"] as? Double)
    XCTAssertEqual(false, props?["pledge_backer_reward_shipping_enabled"] as? Bool)
    XCTAssertNil(props?["pledge_backer_reward_shipping_preference"] as? String)

    XCTAssertEqual("change_reward", props?["context_pledge_flow"] as? String)
  }

  func testPledgeProperties_ShippingPreference() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    let project = Project.cosmicSurgery
    let reward = Reward.template
      |> Reward.lens.shipping .~ (Reward.Shipping.template
        |> Reward.Shipping.lens.preference .~ Reward.Shipping.Preference.restricted)

    ksrAnalytics.trackRewardClicked(project: project, reward: reward, context: .manageReward, refTag: nil)

    let props = dataLakeClient.properties.last

    XCTAssertEqual("restricted", props?["pledge_backer_reward_shipping_preference"] as? String)
    XCTAssertEqual("manage_reward", props?["context_pledge_flow"] as? String)
  }

  // MARK: - Project Page Tracking

  func testTrackCampaignDetailsButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackCampaignDetailsButtonClicked(
      project: .template,
      location: .projectPage,
      refTag: .discovery,
      cookieRefTag: .discovery
    )

    XCTAssertEqual(["Campaign Details Button Clicked"], dataLakeClient.events)
    XCTAssertEqual(["project_screen"], dataLakeClient.properties(forKey: "context_location"))
    XCTAssertEqual(["discovery"], dataLakeClient.properties(forKey: "session_ref_tag"))
    XCTAssertEqual(["discovery"], dataLakeClient.properties(forKey: "session_referrer_credit"))

    self.assertProjectProperties(dataLakeClient.properties.last)
  }

  func testTrackCampignDetailsPledgeButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackCampaignDetailsPledgeButtonClicked(
      project: .template,
      location: .campaign,
      refTag: .discovery,
      cookieRefTag: .discovery
    )

    XCTAssertEqual(["Campaign Details Pledge Button Clicked"], dataLakeClient.events)
    XCTAssertEqual(["campaign_screen"], dataLakeClient.properties(forKey: "context_location"))
    XCTAssertEqual(["discovery"], dataLakeClient.properties(forKey: "session_ref_tag"))
    XCTAssertEqual(["discovery"], dataLakeClient.properties(forKey: "session_referrer_credit"))

    self.assertProjectProperties(dataLakeClient.properties.last)
  }

  func testTrackCheckoutPaymentMethodViewed() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackCheckoutPaymentPageViewed(
      project: .template,
      reward: .template,
      context: .newPledge,
      refTag: RefTag.activity,
      cookieRefTag: RefTag.activity
    )

    let props = dataLakeClient.properties.last

    XCTAssertEqual(["Checkout Payment Page Viewed"], dataLakeClient.events)

    self.assertProjectProperties(props)
    self.assertPledgeProperties(props)

    XCTAssertEqual("activity", props?["session_ref_tag"] as? String)
    XCTAssertEqual("new_pledge", props?["context_pledge_flow"] as? String)
  }

  func testLogEventsCallback() {
    let bundle = MockBundle()
    let dataLakeClient = MockTrackingClient()
    let config = Config.template
    let device = MockDevice(userInterfaceIdiom: .phone)
    let screen = MockScreen()
    let ksrAnalytics = KSRAnalytics(
      bundle: bundle, dataLakeClient: dataLakeClient, config: config, device: device, loggedInUser: nil,
      screen: screen
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
  }

  func testProjectCardClicked() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackProjectCardClicked(
      project: Project.template,
      params: DiscoveryParams.recommendedDefaults,
      location: .discovery
    )

    XCTAssertEqual(["Project Card Clicked"], dataLakeClient.events)
    XCTAssertEqual("explore_screen", dataLakeClient.properties.last?["context_location"] as? String)

    self.assertProjectProperties(dataLakeClient.properties.last)
    self.assertDiscoveryProperties(dataLakeClient.properties.last)
  }

  func testWatchProjectButtonClicked_DiscoveryLocationContext() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackWatchProjectButtonClicked(
      project: .template,
      location: .discovery,
      params: DiscoveryParams.recommendedDefaults
    )

    XCTAssertEqual(["Watch Project Button Clicked"], dataLakeClient.events)
    XCTAssertEqual("explore_screen", dataLakeClient.properties.last?["context_location"] as? String)

    self.assertProjectProperties(dataLakeClient.properties.last)
    self.assertDiscoveryProperties(dataLakeClient.properties.last)
  }

  func testWatchProjectButtonClicked_ProjectPageLocationContext() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackWatchProjectButtonClicked(
      project: .template,
      location: .projectPage
    )

    XCTAssertEqual(["Watch Project Button Clicked"], dataLakeClient.events)
    XCTAssertEqual("project_screen", dataLakeClient.properties.last?["context_location"] as? String)

    self.assertProjectProperties(dataLakeClient.properties.last)
  }

  func testTrackPledgeCTAButtonClicked_FixState() {
    let dataLakeClient = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: loggedInUser)

    ksrAnalytics.trackPledgeCTAButtonClicked(stateType: .fix, project: project)

    XCTAssertEqual(["Manage Pledge Button Clicked"], dataLakeClient.events)
  }

  func testTrackPledgeCTAButtonClicked_PledgeState() {
    let dataLakeClient = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: loggedInUser)

    ksrAnalytics.trackPledgeCTAButtonClicked(stateType: .pledge, project: project)

    XCTAssertEqual(["Project Page Pledge Button Clicked"], dataLakeClient.events)
  }

  func testTrackPledgeCTAButtonClicked_ManageState() {
    let dataLakeClient = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: loggedInUser)

    ksrAnalytics.trackPledgeCTAButtonClicked(stateType: .manage, project: project)

    XCTAssertEqual(["Manage Pledge Button Clicked"], dataLakeClient.events)
  }

  func testTrackSelectRewardButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let reward = Reward.template
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: loggedInUser)

    ksrAnalytics.trackRewardClicked(
      project: project,
      reward: reward,
      context: .newPledge,
      refTag: .category
    )

    let properties = dataLakeClient.properties.last

    XCTAssertEqual(["Select Reward Button Clicked"], dataLakeClient.events)

    self.assertPledgeProperties(properties)
    self.assertProjectProperties(properties)

    XCTAssertEqual("new_pledge", properties?["context_pledge_flow"] as? String)
    XCTAssertEqual("category", properties?["session_ref_tag"] as? String)
  }

  func testTrackPledgeSubmitButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackPledgeSubmitButtonClicked(
      project: .template,
      reward: .template,
      checkoutData: .template,
      refTag: nil
    )

    let props = dataLakeClient.properties.last

    XCTAssertEqual(["Pledge Submit Button Clicked"], dataLakeClient.events)

    self.assertProjectProperties(props)
    self.assertPledgeProperties(props)
    self.assertCheckoutProperties(props)
  }

  func testTrackAddNewCardButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackAddNewCardButtonClicked(
      context: .newPledge,
      project: .template,
      refTag: .activity,
      reward: .template
    )

    let props = dataLakeClient.properties.last

    XCTAssertEqual(["Add New Card Button Clicked"], dataLakeClient.events)

    self.assertProjectProperties(props)
    self.assertPledgeProperties(props)

    XCTAssertEqual("new_pledge", props?["context_pledge_flow"] as? String)
    XCTAssertEqual("activity", props?["session_ref_tag"] as? String)
  }

  // MARK: - Onboarding Tracking

  func testOnboardingGetStartedButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackOnboardingGetStartedButtonClicked()

    XCTAssertEqual(["Onboarding Get Started Button Clicked"], dataLakeClient.events)

    XCTAssertEqual(["landing_page"], dataLakeClient.properties(forKey: "context_location"))
  }

  func testOnboardingCarouselSwipedButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackOnboardingCarouselSwiped()

    XCTAssertEqual(["Onboarding Carousel Swiped"], dataLakeClient.events)

    XCTAssertEqual(["landing_page"], dataLakeClient.properties(forKey: "context_location"))
  }

  func testOnboardingSkipButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackOnboardingSkipButtonClicked()

    XCTAssertEqual(["Onboarding Skip Button Clicked"], dataLakeClient.events)

    XCTAssertEqual(["onboarding"], dataLakeClient.properties(forKey: "context_location"))
  }

  func testOnboardingContinueButtonClicked() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackOnboardingContinueButtonClicked()

    XCTAssertEqual(["Onboarding Continue Button Clicked"], dataLakeClient.events)

    XCTAssertEqual(["onboarding"], dataLakeClient.properties(forKey: "context_location"))
  }

  // MARK: - Search Tracking

  func testTrackSearchViewed() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackProjectSearchView()

    XCTAssertEqual(["Search Page Viewed"], dataLakeClient.events)
  }

  func testTrackSearchResults() {
    let dataLakeClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackSearchResults(
      query: "query",
      params: DiscoveryParams.defaults,
      refTag: .search,
      hasResults: true
    )

    let props = dataLakeClient.properties.last

    XCTAssertEqual(["Search Results Loaded"], dataLakeClient.events)
    XCTAssertEqual("query", props?["search_term"] as? String)
    XCTAssertEqual("search", props?["discover_ref_tag"] as? String)
    XCTAssertEqual(true, props?["has_results"] as? Bool)
  }

  func testUserProperties_loggedOut() {
    let dataLakeClient = MockTrackingClient()
    let config = Config.template |> Config.lens.countryCode .~ "US"
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, config: config, loggedInUser: nil)

    ksrAnalytics.trackTabBarClicked(.activity)

    let props = dataLakeClient.properties.last

    XCTAssertEqual("US", props?["user_country"] as? String)
    XCTAssertNil(props?["user_uid"])
  }

  func testUserProperties_loggedIn() {
    let dataLakeClient = MockTrackingClient()

    let user = User.template
      |> User.lens.stats.backedProjectsCount .~ 5
      |> User.lens.location .~ Location.usa
      |> User.lens.facebookConnected .~ true
      |> User.lens.stats.starredProjectsCount .~ 2
      |> User.lens.stats.createdProjectsCount .~ 3
      |> User.lens.id .~ 10
      |> User.lens.isAdmin .~ false

    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, loggedInUser: user)

    ksrAnalytics.trackTabBarClicked(.activity)

    let props = dataLakeClient.properties.last

    XCTAssertEqual("US", props?["user_country"] as? String)
    XCTAssertEqual(10, props?["user_uid"] as? Int)
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

    ksrAnalytics.trackTabBarClicked(tabBarDashboard)

    XCTAssertEqual(["Tab Bar Clicked", "Tab Bar Clicked"], dataLakeClient.events)
    XCTAssertEqual("dashboard", dataLakeClient.properties.last?["context_tab_bar_label"] as? String)

    ksrAnalytics.trackTabBarClicked(tabBarHome)

    XCTAssertEqual(["Tab Bar Clicked", "Tab Bar Clicked", "Tab Bar Clicked"], dataLakeClient.events)
    XCTAssertEqual("discovery", dataLakeClient.properties.last?["context_tab_bar_label"] as? String)

    ksrAnalytics.trackTabBarClicked(tabBarProfile)

    XCTAssertEqual(
      ["Tab Bar Clicked", "Tab Bar Clicked", "Tab Bar Clicked", "Tab Bar Clicked"],
      dataLakeClient.events
    )
    XCTAssertEqual("profile", dataLakeClient.properties.last?["context_tab_bar_label"] as? String)

    ksrAnalytics.trackTabBarClicked(tabBarSearch)

    XCTAssertEqual([
      "Tab Bar Clicked",
      "Tab Bar Clicked",
      "Tab Bar Clicked",
      "Tab Bar Clicked",
      "Tab Bar Clicked"
    ], dataLakeClient.events)
    XCTAssertEqual("search", dataLakeClient.properties.last?["context_tab_bar_label"] as? String)
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
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient)

    ksrAnalytics.trackTabBarClicked(.activity)

    XCTAssertEqual("activity", dataLakeClient.properties.last?["context_tab_bar_label"] as? String)
  }

  func testContextLocationProperties() {
    let dataLakeClient = MockTrackingClient()
    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(dataLakeClient: dataLakeClient, segmentClient: segmentClient)

    ksrAnalytics.trackActivities(count: 1)
    XCTAssertEqual(
      "activity_feed_screen",
      segmentClient.screenProperties.last?["context_location"] as? String
    )

    ksrAnalytics.trackAddNewCardButtonClicked(
      context: .newPledge,
      location: .pledgeAddNewCard,
      project: .template,
      refTag: nil,
      reward: .template
    )
    XCTAssertEqual(
      "pledge_add_new_card_screen",
      dataLakeClient.properties.last?["context_location"] as? String
    )

    ksrAnalytics.trackAddNewCardButtonClicked(
      context: .newPledge,
      location: .settingsAddNewCard,
      project: .template,
      refTag: nil,
      reward: .template
    )
    XCTAssertEqual(
      "settings_add_new_card_screen",
      dataLakeClient.properties.last?["context_location"] as? String
    )

    ksrAnalytics.trackCheckoutPaymentPageViewed(
      project: .template,
      reward: .template,
      context: .newPledge,
      refTag: nil,
      cookieRefTag: nil
    )
    XCTAssertEqual("pledge_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackCollectionViewed(params: .defaults)
    XCTAssertEqual(
      "editorial_collection_screen",
      dataLakeClient.properties.last?["context_location"] as? String
    )

    ksrAnalytics.trackDiscovery(params: .defaults)
    XCTAssertEqual("explore_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackDiscoveryModalSelectedFilter(params: .defaults)
    XCTAssertEqual("explore_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackEditorialHeaderTapped(params: .defaults, refTag: .discovery)
    XCTAssertEqual("explore_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackFacebookLoginOrSignupButtonClicked(intent: .generic)
    XCTAssertEqual("login_or_signup_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackForgotPasswordViewed()
    XCTAssertEqual("forgot_password_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackLoginButtonClicked(intent: .generic)
    XCTAssertEqual("login_or_signup_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackLoginOrSignupButtonClicked(intent: .generic)
    XCTAssertEqual("explore_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackLoginOrSignupPageViewed(intent: .generic)
    XCTAssertEqual("login_or_signup_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackLoginSubmitButtonClicked()
    XCTAssertEqual("login_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackPledgeCTAButtonClicked(stateType: .pledge, project: .template)
    XCTAssertEqual("project_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackProjectSearchView()
    XCTAssertEqual("search_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackProjectViewed(.template)
    XCTAssertEqual("project_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackRewardClicked(project: .template, reward: .template, context: .newPledge, refTag: nil)
    XCTAssertEqual("rewards_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackSearchResults(query: "", params: .defaults, refTag: .search, hasResults: false)
    XCTAssertEqual("search_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackSwipedProject(.template, refTag: nil)
    XCTAssertEqual("project_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackSignupSubmitButtonClicked()
    XCTAssertEqual("sign_up", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.trackThanksPageViewed(project: .template, reward: .template, checkoutData: nil)
    XCTAssertEqual("thanks_screen", dataLakeClient.properties.last?["context_location"] as? String)

    ksrAnalytics.track2FAViewed()
    XCTAssertEqual(
      "two_factor_auth_verify_screen",
      dataLakeClient.properties.last?["context_location"] as? String
    )

    ksrAnalytics.trackEmailVerificationScreenViewed()
    XCTAssertEqual("email_verification", dataLakeClient.properties.last?["context_location"] as? String)
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
    XCTAssertEqual(1_000, props?["project_current_pledge_amount_usd"] as? Int)
    XCTAssertEqual(2_000, props?["project_goal_usd"] as? Int)
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
    XCTAssertEqual(true, props?["pledge_backer_reward_is_limited_quantity"] as? Bool)
    XCTAssertEqual(false, props?["pledge_backer_reward_is_limited_time"] as? Bool)
    XCTAssertEqual(10.00, props?["pledge_backer_reward_minimum"] as? Double)
    XCTAssertEqual(false, props?["pledge_backer_reward_shipping_enabled"] as? Bool)

    XCTAssertNil(props?["pledge_backer_reward_shipping_preference"] as? String)
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
    XCTAssertEqual(2_000, props?["checkout_revenue_in_usd_cents"] as? Int)
    XCTAssertEqual(true, props?["checkout_reward_shipping_enabled"] as? Bool)
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
    revenueInUsdCents: 2_000,
    rewardId: 2,
    rewardMinimumUsd: "5.00",
    rewardTitle: "SUPER reward",
    shippingEnabled: true,
    shippingAmount: 10,
    shippingAmountUsd: "10.00",
    userHasStoredApplePayCard: true
  )
}
