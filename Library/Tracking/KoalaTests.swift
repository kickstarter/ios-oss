@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class KoalaTests: TestCase {
  // MARK: - Session Properties Tests

  func testSessionProperties() {
    let bundle = MockBundle()
    let client = MockTrackingClient()
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
    let koala = Koala(
      bundle: bundle,
      client: client,
      config: config,
      device: device,
      loggedInUser: nil,
      screen: screen,
      distinctId: "abc-123"
    )

    koala.trackAppOpen()

    let properties = client.properties.last

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
      let client = MockTrackingClient()
      let koala = Koala(client: client)

      koala.trackAppOpen()

      let properties = client.properties.last

      XCTAssertEqual("es", properties?["session_display_language"] as? String)
    }
  }

  func testSessionProperties_VoiceOver() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    withEnvironment(isVoiceOverRunning: { true }) {
      koala.trackAppOpen()

      let properties = client.properties.last

      XCTAssertEqual(true, properties?["session_is_voiceover_running"] as? Bool)
    }

    withEnvironment(isVoiceOverRunning: { false }) {
      koala.trackAppOpen()

      let properties = client.properties.last

      XCTAssertEqual(false, properties?["session_is_voiceover_running"] as? Bool)
    }
  }

  func testSessionProperties_LoggedIn() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, loggedInUser: User.template)

    koala.trackAppOpen()

    let properties = client.properties.last

    XCTAssertEqual(true, properties?["session_user_logged_in"] as? Bool)
  }

  func testSessionProperties_DeviceFormatAndClientPlatform_ForIPhoneIdiom() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, device: MockDevice(userInterfaceIdiom: .phone), loggedInUser: nil)
    koala.trackAppOpen()

    XCTAssertEqual("phone", client.properties.last?["session_device_format"] as? String)
    XCTAssertEqual("ios", client.properties.last?["session_client_platform"] as? String)
  }

  func testSessionProperties_DeviceFormatAndClientPlatform_ForIPadIdiom() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, device: MockDevice(userInterfaceIdiom: .pad), loggedInUser: nil)
    koala.trackAppOpen()

    XCTAssertEqual("tablet", client.properties.last?["session_device_format"] as? String)
    XCTAssertEqual("ios", client.properties.last?["session_client_platform"] as? String)
  }

  func testSessionProperties_DeviceFormatAndClientPlatform_ForTvIdiom() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, device: MockDevice(userInterfaceIdiom: .tv), loggedInUser: nil)
    koala.trackAppOpen()

    XCTAssertEqual("tv", client.properties.last?["session_device_format"] as? String)
    XCTAssertEqual("tvos", client.properties.last?["session_client_platform"] as? String)
  }

  func testSessionProperties_DeviceOrientation() {
    let client = MockTrackingClient()
    let device = MockDevice(orientation: .faceDown)
    let koala = Koala(client: client, device: device)

    koala.trackAppOpen()

    let props = client.properties.last

    XCTAssertEqual("Face Down", props?["session_device_orientation"] as? String)
  }

  // MARK: - Project Properties Tests

  func testProjectProperties() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, loggedInUser: nil)
    let project = Project.template
      |> Project.lens.rewards .~ [Reward.template]
      |> \.category .~ (.illustration
        |> \.id .~ 123
        |> \.parentId .~ 321
      )
      |> Project.lens.stats.staticUsdRate .~ 2.0
      |> Project.lens.stats.commentsCount .~ 10
      |> Project.lens.prelaunchActivated .~ true

    koala.trackProjectViewed(project, refTag: .discovery, cookieRefTag: .recommended)

    XCTAssertEqual(1, client.properties.count)

    let properties = client.properties.last

    XCTAssertEqual("Project Page Viewed", client.events.last)
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
    let client = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      <> Project.lens.personalization.isStarred .~ false
    let loggedInUser = User.template |> \.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackProjectViewed(project, refTag: nil, cookieRefTag: nil)

    XCTAssertEqual(1, client.properties.count)

    let properties = client.properties.last

    XCTAssertEqual(false, properties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, properties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, properties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, properties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  func testProjectProperties_LoggedInBacker() {
    let client = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.isStarred .~ false
    let loggedInUser = User.template |> \.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackProjectViewed(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(1, client.properties.count)

    let properties = client.properties.last

    XCTAssertEqual(false, properties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(true, properties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, properties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, properties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  func testProjectProperties_LoggedInStarrer() {
    let client = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.isStarred .~ true
    let loggedInUser = User.template |> \.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackProjectViewed(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(1, client.properties.count)

    let properties = client.properties.last

    XCTAssertEqual(false, properties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, properties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(true, properties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, properties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  func testProjectProperties_LoggedInCreator() {
    let client = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      <> Project.lens.personalization.isStarred .~ false
    let loggedInUser = project.creator
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackProjectViewed(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(1, client.properties.count)

    let properties = client.properties.last

    XCTAssertEqual(true, properties?["project_user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, properties?["project_user_is_backer"] as? Bool)
    XCTAssertEqual(false, properties?["project_user_has_watched"] as? Bool)

    XCTAssertEqual(27, properties?.keys.filter { $0.hasPrefix("project_") }.count)
  }

  // MARK: - Discovery Properties Tests

  func testDiscoveryProperties() {
    let client = MockTrackingClient()
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
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackDiscovery(params: params)

    let properties = client.properties.last

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
    let client = MockTrackingClient()
    let params = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      <> DiscoveryParams.lens.starred .~ false
      <> DiscoveryParams.lens.social .~ false
      <> DiscoveryParams.lens.recommended .~ false
      <> DiscoveryParams.lens.category .~ nil
      <> DiscoveryParams.lens.sort .~ .popular

    let loggedInUser = User.template |> \.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackDiscovery(params: params)

    let properties = client.properties.last

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
    let client = MockTrackingClient()

    let params = .defaults
      |> DiscoveryParams.lens.sort .~ .magic

    let loggedInUser = User.template |> \.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackDiscovery(params: params)

    let properties = client.properties.last

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
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    let project = Project.cosmicSurgery
    let reward = Reward.template

    koala.trackRewardClicked(project: project, reward: reward, context: .newPledge, refTag: .recommended)

    let props = client.properties.last

    XCTAssertEqual(false, props?["pledge_backer_reward_has_items"] as? Bool)
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
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    let project = Project.cosmicSurgery
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 5.0

    koala.trackRewardClicked(project: project, reward: reward, context: .changeReward, refTag: nil)

    let props = client.properties.last

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
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    let project = Project.cosmicSurgery
    let reward = Reward.template
      |> Reward.lens.shipping .~ (Reward.Shipping.template
        |> Reward.Shipping.lens.preference .~ Reward.Shipping.Preference.restricted)

    koala.trackRewardClicked(project: project, reward: reward, context: .manageReward, refTag: nil)

    let props = client.properties.last

    XCTAssertEqual("restricted", props?["pledge_backer_reward_shipping_preference"] as? String)
    XCTAssertEqual("manage_reward", props?["context_pledge_flow"] as? String)
  }

  // MARK: - Project Page Tracking

  func testTrackCreatorDetailsClicked() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackCreatorDetailsClicked(
      project: .template,
      location: .projectPage,
      refTag: .discovery,
      cookieRefTag: .discovery
    )

    XCTAssertEqual(["Creator Details Clicked"], client.events)
    XCTAssertEqual(["project_screen"], client.properties(forKey: "context_location"))
    XCTAssertEqual(["discovery"], client.properties(forKey: "session_ref_tag"))
    XCTAssertEqual(["discovery"], client.properties(forKey: "session_referrer_credit"))

    self.assertProjectProperties(client.properties.last)
  }

  func testTrackCampaignDetailsButtonClicked() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackCampaignDetailsButtonClicked(
      project: .template,
      location: .projectPage,
      refTag: .discovery,
      cookieRefTag: .discovery
    )

    XCTAssertEqual(["Campaign Details Button Clicked"], client.events)
    XCTAssertEqual(["project_screen"], client.properties(forKey: "context_location"))
    XCTAssertEqual(["discovery"], client.properties(forKey: "session_ref_tag"))
    XCTAssertEqual(["discovery"], client.properties(forKey: "session_referrer_credit"))

    self.assertProjectProperties(client.properties.last)
  }

  func testTrackCampignDetailsPledgeButtonClicked() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackCampaignDetailsPledgeButtonClicked(
      project: .template,
      location: .campaign,
      refTag: .discovery,
      cookieRefTag: .discovery
    )

    XCTAssertEqual(["Campaign Details Pledge Button Clicked"], client.events)
    XCTAssertEqual(["campaign_screen"], client.properties(forKey: "context_location"))
    XCTAssertEqual(["discovery"], client.properties(forKey: "session_ref_tag"))
    XCTAssertEqual(["discovery"], client.properties(forKey: "session_referrer_credit"))

    self.assertProjectProperties(client.properties.last)
  }

  func testTrackCheckoutPaymentMethodViewed() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackCheckoutPaymentPageViewed(
      project: .template,
      reward: .template,
      context: .newPledge,
      refTag: RefTag.activity,
      cookieRefTag: RefTag.activity
    )

    let props = client.properties.last

    XCTAssertEqual(["Checkout Payment Page Viewed"], client.events)

    self.assertProjectProperties(props)
    self.assertPledgeProperties(props)

    XCTAssertEqual("activity", props?["session_ref_tag"] as? String)
    XCTAssertEqual("new_pledge", props?["context_pledge_flow"] as? String)
  }

  func testTrackViewedPaymentMethods() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackViewedPaymentMethods()
    XCTAssertEqual(["Viewed Payment Methods"], client.events)
  }

  func testTrackViewedAddNewCard() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackViewedAddNewCard()
    XCTAssertEqual(["Viewed Add New Card"], client.events)
  }

  func testTrackDeletedPaymentMethod() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackDeletedPaymentMethod()
    XCTAssertEqual(["Deleted Payment Method"], client.events)
  }

  func testTrackDeletePaymentMethodError() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackDeletePaymentMethodError()
    XCTAssertEqual(["Errored Delete Payment Method"], client.events)
  }

  func testTrackSavedPaymentMethod() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackSavedPaymentMethod()
    XCTAssertEqual(["Saved Payment Method"], client.events)
  }

  func testTrackFailedPaymentMethodCreation() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackFailedPaymentMethodCreation()
    XCTAssertEqual(["Failed Payment Method Creation"], client.events)
  }

  func testLogEventsCallback() {
    let bundle = MockBundle()
    let client = MockTrackingClient()
    let config = Config.template
    let device = MockDevice(userInterfaceIdiom: .phone)
    let screen = MockScreen()
    let koala = Koala(
      bundle: bundle, client: client, config: config, device: device, loggedInUser: nil,
      screen: screen
    )

    var callBackEvents = [String]()
    var callBackProperties: [String: Any]?
    koala.logEventCallback = { event, properties in
      callBackEvents.append(event)
      callBackProperties = properties
    }

    koala.trackAppOpen()

    XCTAssertEqual(["App Open", "Opened App"], client.events)
    XCTAssertEqual(["App Open", "Opened App"], callBackEvents)
    XCTAssertEqual("Apple", client.properties.last?["session_device_manufacturer"] as? String)
    XCTAssertEqual("Apple", callBackProperties?["session_device_manufacturer"] as? String)
  }

  func testProjectCardClicked() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackProjectCardClicked(
      project: Project.template,
      params: DiscoveryParams.recommendedDefaults,
      location: .discovery
    )

    XCTAssertEqual(["Project Card Clicked"], client.events)
    XCTAssertEqual("explore_screen", client.properties.last?["context_location"] as? String)

    self.assertProjectProperties(client.properties.last)
    self.assertDiscoveryProperties(client.properties.last)
  }

  func testWatchProjectButtonClicked_DiscoveryLocationContext() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackWatchProjectButtonClicked(
      project: .template,
      location: .discovery,
      params: DiscoveryParams.recommendedDefaults
    )

    XCTAssertEqual(["Watch Project Button Clicked"], client.events)
    XCTAssertEqual("explore_screen", client.properties.last?["context_location"] as? String)

    self.assertProjectProperties(client.properties.last)
    self.assertDiscoveryProperties(client.properties.last)
  }

  func testWatchProjectButtonClicked_ProjectPageLocationContext() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackWatchProjectButtonClicked(
      project: .template,
      location: .projectPage
    )

    XCTAssertEqual(["Watch Project Button Clicked"], client.events)
    XCTAssertEqual("project_screen", client.properties.last?["context_location"] as? String)

    self.assertProjectProperties(client.properties.last)
  }

  func testTrackViewedAccount() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackAccountView()

    XCTAssertEqual(["Viewed Account"], client.events)
  }

  func testTrackCreatePassword_viewed() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackCreatePassword(event: .viewed)

    XCTAssertEqual([Koala.CreatePasswordTrackingEvent.viewed.rawValue], client.events)
  }

  func testTrackCreatePassword_passwordCreated() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackCreatePassword(event: .passwordCreated)

    XCTAssertEqual([Koala.CreatePasswordTrackingEvent.passwordCreated.rawValue], client.events)
  }

  func testTrackViewedChangeEmail() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackChangeEmailView()

    XCTAssertEqual(["Viewed Change Email"], client.events)
  }

  func testTrackChangeEmail() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackChangeEmail()

    XCTAssertEqual(["Changed Email"], client.events)
  }

  func testTrackViewedChangePassword() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackChangePasswordView()

    XCTAssertEqual(["Viewed Change Password"], client.events)
  }

  func testTrackChangePassword() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackChangePassword()

    XCTAssertEqual(["Changed Password"], client.events)
  }

  func testTrackChangedCurrency() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackChangedCurrency(.CAD)

    XCTAssertEqual(["Selected Chosen Currency"], client.events)
    XCTAssertEqual(Currency.CAD.descriptionText, client.properties.last?["currency"] as? String)
  }

  func testTrackPledgeCTAButtonClicked_FixState() {
    let client = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackPledgeCTAButtonClicked(stateType: .fix, project: project)

    XCTAssertEqual(["Manage Pledge Button Clicked"], client.events)
  }

  func testTrackPledgeCTAButtonClicked_PledgeState() {
    let client = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackPledgeCTAButtonClicked(stateType: .pledge, project: project)

    XCTAssertEqual(["Project Page Pledge Button Clicked"], client.events)
  }

  func testTrackPledgeCTAButtonClicked_ManageState() {
    let client = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackPledgeCTAButtonClicked(stateType: .manage, project: project)

    XCTAssertEqual(["Manage Pledge Button Clicked"], client.events)
  }

  func testTrackPledgeCTAButtonClicked_ViewBackingState() {
    let client = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackPledgeCTAButtonClicked(stateType: .viewBacking, project: project)

    XCTAssertEqual(["View Your Pledge Button Clicked"], client.events)
  }

  func testTrackPledgeCTAButtonClicked_ViewRewardState() {
    let client = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackPledgeCTAButtonClicked(stateType: .viewRewards, project: project)

    XCTAssertEqual(["View Rewards Button Clicked"], client.events)
  }

  func testTrackPledgeCTAButtonClicked_ViewTheRewardsState() {
    let client = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackPledgeCTAButtonClicked(stateType: .viewTheRewards, project: project)

    XCTAssertEqual(["Project Page Pledge Button Clicked"], client.events)
  }

  func testTrackPledgeCTAButtonClicked_SeeTheRewardsState() {
    let client = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackPledgeCTAButtonClicked(stateType: .seeTheRewards, project: project)

    XCTAssertEqual(["Project Page Pledge Button Clicked"], client.events)
  }

  func testTrackPledgeCTAButtonClicked_ViewYourRewardsState() {
    let client = MockTrackingClient()
    let user = User.template |> \.id .~ 42
    let project = Project.template
      |> Project.lens.creator .~ user

    let koala = Koala(client: client, loggedInUser: user)

    koala.trackPledgeCTAButtonClicked(stateType: .viewYourRewards, project: project)

    XCTAssertEqual(["View Your Rewards Button Clicked"], client.events)
  }

  func testTrackSelectRewardButtonClicked() {
    let client = MockTrackingClient()
    let reward = Reward.template
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackRewardClicked(
      project: project,
      reward: reward,
      context: .newPledge,
      refTag: .category
    )

    let properties = client.properties.last

    XCTAssertEqual(["Select Reward Button Clicked"], client.events)

    self.assertPledgeProperties(properties)
    self.assertProjectProperties(properties)

    XCTAssertEqual("new_pledge", properties?["context_pledge_flow"] as? String)
    XCTAssertEqual("category", properties?["session_ref_tag"] as? String)
  }

  func testTrackCancelPledgeButtonClicked() {
    let client = MockTrackingClient()
    let loggedInUser = User.template

    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackCancelPledgeButtonClicked(
      project: .template,
      backingAmount: 200.0
    )

    let properties = client.properties.last

    XCTAssertEqual(["Cancel Pledge Button Clicked"], client.events)
    XCTAssertEqual(200.0, properties?["pledge_total"] as? Double)
  }

  func testTrackUpdatePaymentMethodClicked() {
    let client = MockTrackingClient()
    let loggedInUser = User.template
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackUpdatePaymentMethodButton(project: .template, pledgeAmount: 22.00)

    let properties = client.properties.last

    XCTAssertEqual(["Update Payment Method Button Clicked"], client.events)
    XCTAssertEqual(22.00, properties?["pledge_total"] as? Double)
  }

  func testTrackUpdatePledgeButtonClicked() {
    let client = MockTrackingClient()
    let loggedInUser = User.template
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackUpdatePledgeButtonClicked(
      project: .template,
      pledgeAmount: 50.00
    )

    let properties = client.properties.last

    XCTAssertEqual(["Update Pledge Button Clicked"], client.events)
    XCTAssertEqual(50.00, properties?["pledge_total"] as? Double)
  }

  func testTrackPledgeSubmitButtonClicked() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackPledgeSubmitButtonClicked(
      project: .template,
      reward: .template,
      checkoutData: .template, refTag: nil
    )

    let props = client.properties.last

    XCTAssertEqual(["Pledge Submit Button Clicked"], client.events)

    self.assertProjectProperties(props)
    self.assertPledgeProperties(props)
    self.assertCheckoutProperties(props)
  }

  func testTrackAddNewCardButtonClicked() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackAddNewCardButtonClicked(
      context: .newPledge,
      project: .template,
      refTag: .activity,
      reward: .template
    )

    let props = client.properties.last

    XCTAssertEqual(["Add New Card Button Clicked"], client.events)

    self.assertProjectProperties(props)
    self.assertPledgeProperties(props)

    XCTAssertEqual("new_pledge", props?["context_pledge_flow"] as? String)
    XCTAssertEqual("activity", props?["session_ref_tag"] as? String)
  }

  func testTrackManagePledgeOptionClicked_CancelPledgeSelected() {
    self.assertManagePledgeOptionClickedProperties(of: .cancelPledge, property: "cancel_pledge")
  }

  func testTrackManagePledgeOptionClicked_ChangePaymentMethod() {
    self.assertManagePledgeOptionClickedProperties(
      of: .changePaymentMethod,
      property: "change_payment_method"
    )
  }

  func testTrackManagePledgeOptionClicked_ChooseAnotherReward() {
    self.assertManagePledgeOptionClickedProperties(
      of: .chooseAnotherReward,
      property: "choose_another_reward"
    )
  }

  func testTrackManagePledgeOptionClicked_ContactCreator() {
    self.assertManagePledgeOptionClickedProperties(
      of: .contactCreator,
      property: "contact_creator"
    )
  }

  func testTrackManagePledgeOptionClicked_UpdatePledge() {
    self.assertManagePledgeOptionClickedProperties(
      of: .updatePledge,
      property: "update_pledge"
    )
  }

  func testTrackManagePledgeOptionClicked_ViewRewards() {
    self.assertManagePledgeOptionClickedProperties(
      of: .viewRewards,
      property: "view_rewards"
    )
  }

  // MARK: - Onboarding Tracking

  func testOnboardingGetStartedButtonClicked() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackOnboardingGetStartedButtonClicked()

    XCTAssertEqual(["Onboarding Get Started Button Clicked"], client.events)

    XCTAssertEqual(["landing_page"], client.properties(forKey: "context_location"))
  }

  func testOnboardingCarouselSwipedButtonClicked() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackOnboardingCarouselSwiped()

    XCTAssertEqual(["Onboarding Carousel Swiped"], client.events)

    XCTAssertEqual(["landing_page"], client.properties(forKey: "context_location"))
  }

  func testOnboardingSkipButtonClicked() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackOnboardingSkipButtonClicked()

    XCTAssertEqual(["Onboarding Skip Button Clicked"], client.events)

    XCTAssertEqual(["onboarding"], client.properties(forKey: "context_location"))
  }

  func testOnboardingContinueButtonClicked() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackOnboardingContinueButtonClicked()

    XCTAssertEqual(["Onboarding Continue Button Clicked"], client.events)

    XCTAssertEqual(["onboarding"], client.properties(forKey: "context_location"))
  }

  // MARK: - Search Tracking

  func testTrackSearchViewed() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackProjectSearchView()

    XCTAssertEqual(["Search Page Viewed"], client.events)
  }

  func testTrackSearchResults() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackSearchResults(
      query: "query",
      params: DiscoveryParams.defaults,
      refTag: .search,
      hasResults: true
    )

    let props = client.properties.last

    XCTAssertEqual(["Search Results Loaded"], client.events)
    XCTAssertEqual("query", props?["search_term"] as? String)
    XCTAssertEqual("search", props?["discover_ref_tag"] as? String)
    XCTAssertEqual(true, props?["has_results"] as? Bool)
  }

  private func assertManagePledgeOptionClickedProperties(
    of type: Koala.ManagePledgeMenuCTAType,
    property: String
  ) {
    let client = MockTrackingClient()
    let loggedInUser = User.template
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackManagePledgeOptionClicked(project: .template, managePledgeMenuCTA: type)

    let properties = client.properties.last
    XCTAssertEqual(["Manage Pledge Option Clicked"], client.events)
    XCTAssertEqual(property, properties?["cta"] as? String)
  }

  func testUserProperties_loggedOut() {
    let client = MockTrackingClient()
    let config = Config.template |> Config.lens.countryCode .~ "US"
    let koala = Koala(client: client, config: config, loggedInUser: nil)

    koala.trackAppOpen()

    let props = client.properties.last

    XCTAssertEqual("US", props?["user_country"] as? String)
    XCTAssertNil(props?["user_uid"])
  }

  func testUserProperties_loggedIn() {
    let client = MockTrackingClient()

    let user = User.template
      |> User.lens.stats.backedProjectsCount .~ 5
      |> User.lens.location .~ Location.usa
      |> User.lens.facebookConnected .~ true
      |> User.lens.stats.starredProjectsCount .~ 2
      |> User.lens.stats.createdProjectsCount .~ 3
      |> User.lens.id .~ 10
      |> User.lens.isAdmin .~ false

    let koala = Koala(client: client, loggedInUser: user)

    koala.trackAppOpen()

    let props = client.properties.last

    XCTAssertEqual("US", props?["user_country"] as? String)
    XCTAssertEqual(10, props?["user_uid"] as? Int)
  }

  func testTabBarClicked() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    let tabBarActivity = Koala.TabBarItemLabel.activity
    let tabBarDashboard = Koala.TabBarItemLabel.dashboard
    let tabBarHome = Koala.TabBarItemLabel.discovery
    let tabBarProfile = Koala.TabBarItemLabel.profile
    let tabBarSearch = Koala.TabBarItemLabel.search

    koala.trackTabBarClicked(tabBarActivity)

    XCTAssertEqual(["Tab Bar Clicked"], client.events)
    XCTAssertEqual("activity", client.properties.last?["context_tab_bar_label"] as? String)

    koala.trackTabBarClicked(tabBarDashboard)

    XCTAssertEqual(["Tab Bar Clicked", "Tab Bar Clicked"], client.events)
    XCTAssertEqual("dashboard", client.properties.last?["context_tab_bar_label"] as? String)

    koala.trackTabBarClicked(tabBarHome)

    XCTAssertEqual(["Tab Bar Clicked", "Tab Bar Clicked", "Tab Bar Clicked"], client.events)
    XCTAssertEqual("discovery", client.properties.last?["context_tab_bar_label"] as? String)

    koala.trackTabBarClicked(tabBarProfile)

    XCTAssertEqual(
      ["Tab Bar Clicked", "Tab Bar Clicked", "Tab Bar Clicked", "Tab Bar Clicked"],
      client.events
    )
    XCTAssertEqual("profile", client.properties.last?["context_tab_bar_label"] as? String)

    koala.trackTabBarClicked(tabBarSearch)

    XCTAssertEqual([
      "Tab Bar Clicked",
      "Tab Bar Clicked",
      "Tab Bar Clicked",
      "Tab Bar Clicked",
      "Tab Bar Clicked"
    ], client.events)
    XCTAssertEqual("search", client.properties.last?["context_tab_bar_label"] as? String)
  }

  func testDataLakeApprovedEvents() {
    let koalaClient = MockTrackingClient()
    let dataLakeClient = MockTrackingClient()
    let koala = Koala(dataLakeClient: dataLakeClient, client: koalaClient)

    koala.trackAppOpen() // non-white-listed event

    XCTAssertEqual(["App Open", "Opened App"], koalaClient.events, "Event is tracked by koala client")
    XCTAssertEqual([], dataLakeClient.events, "Event is not tracked by data lake client")

    koala.trackProjectViewed(Project.template) // white-listed event

    XCTAssertEqual(
      ["App Open", "Opened App", "Project Page Viewed"], koalaClient.events,
      "White-listed event is tracked by koala client"
    )
    XCTAssertEqual(
      ["Project Page Viewed"], dataLakeClient.events,
      "White-listed event is tracked by data lake client"
    )
  }

  func testContextProperties() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackAppOpen()

    XCTAssertEqual(1_475_361_315.0, client.properties.last?["context_timestamp"] as? TimeInterval)
  }

  func testContextLocationProperties() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackActivities(count: 1)
    XCTAssertEqual("activity_feed_screen", client.properties.last?["context_location"] as? String)

    koala.trackAddNewCardButtonClicked(
      context: .newPledge,
      location: .pledgeAddNewCard,
      project: .template,
      refTag: nil,
      reward: .template
    )
    XCTAssertEqual("pledge_add_new_card_screen", client.properties.last?["context_location"] as? String)

    koala.trackAddNewCardButtonClicked(
      context: .newPledge,
      location: .settingsAddNewCard,
      project: .template,
      refTag: nil,
      reward: .template
    )
    XCTAssertEqual("settings_add_new_card_screen", client.properties.last?["context_location"] as? String)

    koala.trackCheckoutPaymentPageViewed(
      project: .template,
      reward: .template,
      context: .newPledge,
      refTag: nil,
      cookieRefTag: nil
    )
    XCTAssertEqual("pledge_screen", client.properties.last?["context_location"] as? String)

    koala.trackCollectionViewed(params: .defaults)
    XCTAssertEqual("editorial_collection_screen", client.properties.last?["context_location"] as? String)

    koala.trackDiscovery(params: .defaults)
    XCTAssertEqual("explore_screen", client.properties.last?["context_location"] as? String)

    koala.trackDiscoveryModalSelectedFilter(params: .defaults)
    XCTAssertEqual("explore_screen", client.properties.last?["context_location"] as? String)

    koala.trackEditorialHeaderTapped(params: .defaults, refTag: .discovery)
    XCTAssertEqual("explore_screen", client.properties.last?["context_location"] as? String)

    koala.trackFacebookLoginOrSignupButtonClicked(intent: .generic)
    XCTAssertEqual("login_or_signup_screen", client.properties.last?["context_location"] as? String)

    koala.trackForgotPasswordViewed()
    XCTAssertEqual("forgot_password_screen", client.properties.last?["context_location"] as? String)

    koala.trackLoginButtonClicked(intent: .generic)
    XCTAssertEqual("login_or_signup_screen", client.properties.last?["context_location"] as? String)

    koala.trackLoginOrSignupButtonClicked(intent: .generic)
    XCTAssertEqual("explore_screen", client.properties.last?["context_location"] as? String)

    koala.trackLoginOrSignupPageViewed(intent: .generic)
    XCTAssertEqual("login_or_signup_screen", client.properties.last?["context_location"] as? String)

    koala.trackLoginSubmitButtonClicked()
    XCTAssertEqual("login_screen", client.properties.last?["context_location"] as? String)

    koala.trackPledgeCTAButtonClicked(stateType: .pledge, project: .template)
    XCTAssertEqual("project_screen", client.properties.last?["context_location"] as? String)

    koala.trackProjectSearchView()
    XCTAssertEqual("search_screen", client.properties.last?["context_location"] as? String)

    koala.trackProjectViewed(.template)
    XCTAssertEqual("project_screen", client.properties.last?["context_location"] as? String)

    koala.trackRewardClicked(project: .template, reward: .template, context: .newPledge, refTag: nil)
    XCTAssertEqual("rewards_screen", client.properties.last?["context_location"] as? String)

    koala.trackSearchResults(query: "", params: .defaults, refTag: .search, hasResults: false)
    XCTAssertEqual("search_screen", client.properties.last?["context_location"] as? String)

    koala.trackSwipedProject(.template, refTag: nil)
    XCTAssertEqual("project_screen", client.properties.last?["context_location"] as? String)

    koala.trackSignupSubmitButtonClicked()
    XCTAssertEqual("sign_up", client.properties.last?["context_location"] as? String)

    koala.trackThanksPageViewed(project: .template, reward: .template, checkoutData: nil)
    XCTAssertEqual("thanks_screen", client.properties.last?["context_location"] as? String)

    koala.track2FAViewed()
    XCTAssertEqual("two_factor_auth_verify_screen", client.properties.last?["context_location"] as? String)
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
    XCTAssertEqual(false, props?["pledge_backer_reward_has_items"] as? Bool)
    XCTAssertEqual(1, props?["pledge_backer_reward_id"] as? Int)
    XCTAssertEqual(true, props?["pledge_backer_reward_is_limited_quantity"] as? Bool)
    XCTAssertEqual(false, props?["pledge_backer_reward_is_limited_time"] as? Bool)
    XCTAssertEqual(10.00, props?["pledge_backer_reward_minimum"] as? Double)
    XCTAssertEqual(false, props?["pledge_backer_reward_shipping_enabled"] as? Bool)

    XCTAssertNil(props?["pledge_backer_reward_shipping_preference"] as? String)
  }

  /*
   Helper for testing checkoutProperties from a template Koala.CheckoutPropertiesData
   */
  private func assertCheckoutProperties(_ props: [String: Any]?) {
    XCTAssertEqual("20.00", props?["checkout_amount"] as? String)
    XCTAssertEqual("CREDIT_CARD", props?["checkout_payment_type"] as? String)
    XCTAssertEqual("SUPER reward", props?["checkout_reward_title"] as? String)
    XCTAssertEqual(2, props?["checkout_reward_id"] as? Int)
    XCTAssertEqual(2_000, props?["checkout_revenue_in_usd_cents"] as? Int)
    XCTAssertEqual(false, props?["checkout_reward_shipping_enabled"] as? Bool)
    XCTAssertEqual(true, props?["checkout_user_has_eligible_stored_apple_pay_card"] as? Bool)
    XCTAssertNil(props?["checkout_shipping_amount"] as? Double)
    XCTAssertNil(props?["checkout_reward_estimated_delivery_on"] as? TimeInterval)
  }
}

extension Koala.CheckoutPropertiesData {
  static let template = Koala.CheckoutPropertiesData(
    amount: "20.00",
    checkoutId: 1,
    estimatedDelivery: nil,
    paymentType: "CREDIT_CARD",
    revenueInUsdCents: 2_000,
    rewardId: 2,
    rewardTitle: "SUPER reward",
    shippingEnabled: false,
    shippingAmount: nil,
    userHasStoredApplePayCard: true
  )
}
