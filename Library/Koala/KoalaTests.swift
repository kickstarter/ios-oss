@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class KoalaTests: TestCase {
  func testDefaultProperties() {
    let bundle = MockBundle()
    let client = MockTrackingClient()
    let config = Config.template
      |> Config.lens.countryCode .~ "GB"
      |> Config.lens.locale .~ "en"
    let device = MockDevice(userInterfaceIdiom: .phone)
    let screen = MockScreen()
    let koala = Koala(
      bundle: bundle, client: client, config: config, device: device, loggedInUser: nil,
      screen: screen
    )

    koala.trackAppOpen()
    XCTAssertEqual(["App Open", "Opened App"], client.events)

    let properties = client.properties.last

    XCTAssertEqual("Apple", properties?["manufacturer"] as? String)

    XCTAssertEqual(bundle.infoDictionary?["CFBundleVersion"] as? Int, properties?["app_version"] as? Int)
    XCTAssertEqual(
      bundle.infoDictionary?["CFBundleShortVersionString"] as? String,
      properties?["app_release"] as? String
    )
    XCTAssertNotNil(properties?["model"])
    XCTAssertEqual(device.systemName, properties?["os"] as? String)
    XCTAssertEqual(device.systemVersion, properties?["os_version"] as? String)
    XCTAssertEqual(UInt(screen.bounds.width), properties?["screen_width"] as? UInt)
    XCTAssertEqual(UInt(screen.bounds.height), properties?["screen_height"] as? UInt)

    XCTAssertEqual("kickstarter_ios", properties?["mp_lib"] as? String)
    XCTAssertEqual("native", properties?["client_type"] as? String)
    XCTAssertEqual("phone", properties?["device_format"] as? String)
    XCTAssertEqual("ios", properties?["client_platform"] as? String)

    XCTAssertNil(properties?["user_uid"])
    XCTAssertEqual(false, properties?["user_logged_in"] as? Bool)
    XCTAssertEqual("GB", properties?["user_country"] as? String)
  }

  func testDefaultPropertiesVoiceOver() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    withEnvironment(isVoiceOverRunning: { true }) {
      koala.trackAppOpen()

      let properties = client.properties.last

      XCTAssertEqual(true, properties?["is_voiceover_running"] as? Bool)
    }

    withEnvironment(isVoiceOverRunning: { false }) {
      koala.trackAppOpen()

      let properties = client.properties.last

      XCTAssertEqual(false, properties?["is_voiceover_running"] as? Bool)
    }
  }

  func testDefaultPropertiesWithLoggedInUser() {
    let client = MockTrackingClient()
    let user = User.template
      |> \.stats.backedProjectsCount .~ 2
      |> \.stats.createdProjectsCount .~ 3
      |> \.stats.starredProjectsCount .~ 4
      |> \.location .~ .template
    let koala = Koala(client: client, loggedInUser: user)

    koala.trackAppOpen()
    XCTAssertEqual(["App Open", "Opened App"], client.events)

    let properties = client.properties.last

    XCTAssertEqual(user.id, properties?["user_uid"] as? Int)
    XCTAssertEqual(true, properties?["user_logged_in"] as? Bool)
    XCTAssertEqual(user.stats.backedProjectsCount, properties?["user_backed_projects_count"] as? Int)
    XCTAssertEqual(user.stats.createdProjectsCount, properties?["user_created_projects_count"] as? Int)
    XCTAssertEqual(user.stats.starredProjectsCount, properties?["user_starred_projects_count"] as? Int)
    XCTAssertEqual(user.location?.country, properties?["user_country"] as? String)
  }

  func testDeviceFormatAndClientPlatform_ForIPhoneIdiom() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, device: MockDevice(userInterfaceIdiom: .phone), loggedInUser: nil)
    koala.trackAppOpen()

    XCTAssertEqual("phone", client.properties.last?["device_format"] as? String)
    XCTAssertEqual("ios", client.properties.last?["client_platform"] as? String)
  }

  func testDeviceFormatAndClientPlatform_ForIPadIdiom() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, device: MockDevice(userInterfaceIdiom: .pad), loggedInUser: nil)
    koala.trackAppOpen()

    XCTAssertEqual("tablet", client.properties.last?["device_format"] as? String)
    XCTAssertEqual("ios", client.properties.last?["client_platform"] as? String)
  }

  func testDeviceFormatAndClientPlatform_ForTvIdiom() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, device: MockDevice(userInterfaceIdiom: .tv), loggedInUser: nil)
    koala.trackAppOpen()

    XCTAssertEqual("tv", client.properties.last?["device_format"] as? String)
    XCTAssertEqual("tvos", client.properties.last?["client_platform"] as? String)
  }

  func testTrackProject() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, loggedInUser: nil)
    let project = Project.template

    koala.trackProjectShow(project, refTag: .discovery, cookieRefTag: .recommended)
    XCTAssertEqual(3, client.properties.count)

    let properties = client.properties.last

    XCTAssertEqual("Project Page", client.events.last)
    XCTAssertEqual(project.stats.backersCount, properties?["project_backers_count"] as? Int)
    XCTAssertEqual(project.country.countryCode, properties?["project_country"] as? String)
    XCTAssertEqual(project.country.currencyCode, properties?["project_currency"] as? String)
    XCTAssertEqual(project.stats.goal, properties?["project_goal"] as? Int)
    XCTAssertEqual(project.id, properties?["project_pid"] as? Int)
    XCTAssertEqual(project.stats.pledged, properties?["project_pledged"] as? Int)
    XCTAssertEqual(project.stats.fundingProgress, properties?["project_percent_raised"] as? Float)
    XCTAssertNotNil(project.video)
    XCTAssertEqual(project.category.name, properties?["project_category"] as? String)
    XCTAssertEqual(project.category._parent?.name, properties?["project_parent_category"] as? String)
    XCTAssertEqual(project.location.name, properties?["project_location"] as? String)
    XCTAssertEqual(project.stats.backersCount, properties?["project_backers_count"] as? Int)

    XCTAssertEqual(24 * 15, properties?["project_hours_remaining"] as? Int)
    XCTAssertEqual(60 * 60 * 24 * 30, properties?["project_duration"] as? Int)

    XCTAssertEqual("discovery", properties?["ref_tag"] as? String)
    XCTAssertEqual("recommended", properties?["referrer_credit"] as? String)

    XCTAssertEqual(project.creator.id, properties?["creator_uid"] as? Int)
    XCTAssertEqual(
      project.creator.stats.backedProjectsCount,
      properties?["creator_backed_projects_count"] as? Int
    )
    XCTAssertEqual(
      project.creator.stats.createdProjectsCount,
      properties?["creator_created_projects_count"] as? Int
    )
    XCTAssertEqual(
      project.creator.stats.starredProjectsCount,
      properties?["creator_starred_projects_count"] as? Int
    )
  }

  func testProjectProperties_LoggedInUser() {
    let client = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      <> Project.lens.personalization.isStarred .~ false
    let loggedInUser = User.template |> \.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackProjectShow(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(3, client.properties.count)

    let properties = client.properties.last

    XCTAssertEqual(false, properties?["user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, properties?["user_is_backer"] as? Bool)
    XCTAssertEqual(false, properties?["user_has_starred"] as? Bool)
  }

  func testProjectProperties_LoggedInBacker() {
    let client = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.isStarred .~ false
    let loggedInUser = User.template |> \.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackProjectShow(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(3, client.properties.count)

    let properties = client.properties.last

    XCTAssertEqual(false, properties?["user_is_project_creator"] as? Bool)
    XCTAssertEqual(true, properties?["user_is_backer"] as? Bool)
    XCTAssertEqual(false, properties?["user_has_starred"] as? Bool)
  }

  func testProjectProperties_LoggedInStarrer() {
    let client = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.isStarred .~ true
    let loggedInUser = User.template |> \.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackProjectShow(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(3, client.properties.count)

    let properties = client.properties.last

    XCTAssertEqual(false, properties?["user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, properties?["user_is_backer"] as? Bool)
    XCTAssertEqual(true, properties?["user_has_starred"] as? Bool)
  }

  func testProjectProperties_LoggedInCreator() {
    let client = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      <> Project.lens.personalization.isStarred .~ false
    let loggedInUser = project.creator
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackProjectShow(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(3, client.properties.count)

    let properties = client.properties.last

    XCTAssertEqual(true, properties?["user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, properties?["user_is_backer"] as? Bool)
    XCTAssertEqual(false, properties?["user_has_starred"] as? Bool)
  }

  func testDiscoveryProperties() {
    let client = MockTrackingClient()
    let params = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      <> DiscoveryParams.lens.starred .~ false
      <> DiscoveryParams.lens.social .~ false
      <> DiscoveryParams.lens.recommended .~ false
      <> DiscoveryParams.lens.category .~ Category.art
      <> DiscoveryParams.lens.query .~ "collage"
      <> DiscoveryParams.lens.sort .~ .popular

    let loggedInUser = User.template |> \.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackDiscovery(params: params, page: 1)

    let properties = client.properties.last

    XCTAssertEqual(1, properties?["discover_category_id"] as? Int)
    XCTAssertEqual(false, properties?["discover_recommended"] as? Bool)
    XCTAssertEqual(false, properties?["discover_social"] as? Bool)
    XCTAssertEqual(true, properties?["discover_staff_picks"] as? Bool)
    XCTAssertEqual(false, properties?["discover_starred"] as? Bool)
    XCTAssertEqual("collage", properties?["discover_term"] as? String)
    XCTAssertEqual(false, properties?["discover_everything"] as? Bool)
    XCTAssertEqual("popularity", properties?["discover_sort"] as? String)
    XCTAssertEqual(1, properties?["page"] as? Int)
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

    koala.trackDiscovery(params: params, page: 1)

    let properties = client.properties.last

    XCTAssertNil(properties?["discover_category_id"])
    XCTAssertEqual(false, properties?["discover_recommended"] as? Bool)
    XCTAssertEqual(false, properties?["discover_social"] as? Bool)
    XCTAssertEqual(true, properties?["discover_staff_picks"] as? Bool)
    XCTAssertEqual(false, properties?["discover_starred"] as? Bool)
    XCTAssertEqual(false, properties?["discover_everything"] as? Bool)
    XCTAssertEqual("popularity", properties?["discover_sort"] as? String)
    XCTAssertEqual(1, properties?["page"] as? Int)
  }

  func testDiscoveryProperties_Everything() {
    let client = MockTrackingClient()

    let params = .defaults
      |> DiscoveryParams.lens.sort .~ .magic

    let loggedInUser = User.template |> \.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackDiscovery(params: params, page: 1)

    let properties = client.properties.last

    XCTAssertNil(properties?["discover_category_id"])
    XCTAssertNil(properties?["discover_recommended"])
    XCTAssertNil(properties?["discover_social"])
    XCTAssertNil(properties?["discover_staff_picks"])
    XCTAssertNil(properties?["discover_starred"])
    XCTAssertNil(properties?["discover_term"])
    XCTAssertEqual(true, properties?["discover_everything"] as? Bool)
    XCTAssertEqual("magic", properties?["discover_sort"] as? String)
    XCTAssertEqual(1, properties?["page"] as? Int)
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
    XCTAssertEqual("Apple", client.properties.last?["manufacturer"] as? String)
    XCTAssertEqual("Apple", callBackProperties?["manufacturer"] as? String)
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

  func testTrackDiscoveryPullToRefresh() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackDiscoveryPullToRefresh()
    XCTAssertEqual(["Triggered Refresh"], client.events)
  }

  func testTrackBackThisButtonClicked() {
    let client = MockTrackingClient()
    let project = Project.template
    let loggedInUser = User.template |> \.id .~ 42

    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackBackThisButtonClicked(stateType: .pledge, project: project, screen: .projectPage)

    let properties = client.properties.last

    XCTAssertEqual(["Back this Project Button Clicked"], client.events)
    XCTAssertEqual("Project page", properties?["screen"] as? String)
  }

  func testTrackSelectRewardButtonClicked() {
    let client = MockTrackingClient()
    let reward = Reward.template
    let backing = .template
      |> Backing.lens.reward .~ reward
    let project = .template
      |> Project.lens.personalization.backing .~ backing
    let loggedInUser = User.template |> \.id .~ 42

    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackSelectRewardButtonClicked(
      project: project,
      reward: reward,
      backing: backing,
      screen: .backThisPage
    )

    let properties = client.properties.last

    XCTAssertEqual(["Select Reward Button Clicked"], client.events)
    XCTAssertEqual("Back this page", properties?["screen"] as? String)
  }
}
