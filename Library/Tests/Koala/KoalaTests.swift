import XCTest
@testable import Library
@testable import KsApi
import Prelude

final class KoalaTests: XCTestCase {

  func testDefaultProperties() {
    let client = MockTrackingClient()
    let bundle = MockBundle()
    let device = MockDevice(userInterfaceIdiom: .Phone)
    let screen = MockScreen()
    let koala = Koala(client: client, loggedInUser: nil, bundle: bundle, device: device, screen: screen)

    koala.trackAppOpen()
    XCTAssertEqual(1, client.properties.count)

    let properties = client.properties.last!

    XCTAssertEqual("Apple", properties["manufacturer"] as? String)

    XCTAssertEqual(bundle.infoDictionary?["CFBundleVersion"] as? Int, properties["app_version"] as? Int)
    XCTAssertEqual(bundle.infoDictionary?["CFBundleShortVersionString"] as? String,
                   properties["app_release"] as? String)
    XCTAssertNotNil(properties["model"])
    XCTAssertEqual(device.systemName, properties["os"] as? String)
    XCTAssertEqual(device.systemVersion, properties["os_version"] as? String)
    XCTAssertEqual(screen.bounds.width, properties["screen_width"] as? CGFloat)
    XCTAssertEqual(screen.bounds.height, properties["screen_height"] as? CGFloat)

    XCTAssertEqual("iphone", properties["koala_lib"] as? String)
    XCTAssertEqual("native", properties["client_type"] as? String)
    XCTAssertEqual("phone", properties["device_format"] as? String)
    XCTAssertEqual("ios", properties["client_platform"] as? String)

    XCTAssertNil(properties["user_uid"])
    XCTAssertFalse(properties["user_logged_in"] as! Bool)
  }

  func testDefaultPropertiesWithLoggedInUser() {
    let client = MockTrackingClient()
    let user = User.template
      |> User.lens.stats.backedProjectsCount .~ 2
      <> User.lens.stats.createdProjectsCount .~ 3
      <> User.lens.stats.starredProjectsCount .~ 4
    let koala = Koala(client: client, loggedInUser: user)

    koala.trackAppOpen()
    XCTAssertEqual(1, client.properties.count)

    let properties = client.properties.last!

    XCTAssertEqual(user.id, properties["user_uid"] as? Int)
    XCTAssertTrue(properties["user_logged_in"] as! Bool)
    XCTAssertEqual(user.stats.backedProjectsCount!, properties["user_backed_projects_count"] as? Int)
    XCTAssertEqual(user.stats.createdProjectsCount!, properties["user_created_projects_count"] as? Int)
    XCTAssertEqual(user.stats.starredProjectsCount!, properties["user_starred_projects_count"] as? Int)
  }

  func testDeviceFormatAndClientPlatform_ForIPhoneIdiom() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, loggedInUser: nil, device: MockDevice(userInterfaceIdiom: .Phone))
    koala.trackAppOpen()

    XCTAssertEqual("phone", client.properties.last!["device_format"] as? String)
    XCTAssertEqual("ios", client.properties.last!["client_platform"] as? String)
  }

  func testDeviceFormatAndClientPlatform_ForIPadIdiom() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, loggedInUser: nil, device: MockDevice(userInterfaceIdiom: .Pad))
    koala.trackAppOpen()

    XCTAssertEqual("tablet", client.properties.last!["device_format"] as? String)
    XCTAssertEqual("ios", client.properties.last!["client_platform"] as? String)
  }

  func testDeviceFormatAndClientPlatform_ForTvIdiom() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, loggedInUser: nil, device: MockDevice(userInterfaceIdiom: .TV))
    koala.trackAppOpen()

    XCTAssertEqual("tv", client.properties.last!["device_format"] as? String)
    XCTAssertEqual("tvos", client.properties.last!["client_platform"] as? String)
  }

  func testTrackProject() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, loggedInUser: nil)
    let project = Project.template

    koala.trackProjectShow(project, refTag: .discovery, cookieRefTag: .recommended)
    XCTAssertEqual(1, client.properties.count)

    let properties = client.properties.last!
    let event = client.events.last!

    XCTAssertEqual("Project Page", event)
    XCTAssertEqual(project.stats.backersCount, properties["project_backers_count"] as? Int)
    XCTAssertEqual(project.country.countryCode, properties["project_country"] as? String)
    XCTAssertEqual(project.country.currencyCode, properties["project_currency"] as? String)
    XCTAssertEqual(project.stats.goal, properties["project_goal"] as? Int)
    XCTAssertEqual(project.id, properties["project_pid"] as? Int)
    XCTAssertEqual(project.stats.pledged, properties["project_pledged"] as? Int)
    XCTAssertEqual(project.stats.fundingProgress, properties["project_percent_raised"] as? Float)
    XCTAssertNotNil(project.video)
    XCTAssertEqual(project.category.name, properties["project_category"] as? String)
    XCTAssertEqual(project.category.parent?.name, properties["project_parent_category"] as? String)
    XCTAssertEqual(project.location.name, properties["project_location"] as? String)
    XCTAssertEqual(project.stats.backersCount, properties["project_backers_count"] as? Int)

    XCTAssertEqual(24 * 15, properties["project_hours_remaining"] as? Int)
    XCTAssertEqual(60 * 60 * 24 * 30, properties["project_duration"] as? Int)

    XCTAssertEqual("discovery", properties["ref_tag"] as? String)
    XCTAssertEqual("recommended", properties["referrer_credit"] as? String)

    XCTAssertEqual(project.creator.id, properties["creator_uid"] as? Int)
    XCTAssertEqual(project.creator.stats.backedProjectsCount,
                   properties["creator_backed_projects_count"] as? Int)
    XCTAssertEqual(project.creator.stats.createdProjectsCount,
                   properties["creator_created_projects_count"] as? Int)
    XCTAssertEqual(project.creator.stats.starredProjectsCount,
                   properties["creator_starred_projects_count"] as? Int)
  }

  func testProjectProperties_LoggedInUser() {
    let client = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      <> Project.lens.personalization.isStarred .~ false
    let loggedInUser = User.template |> User.lens.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackProjectShow(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(1, client.properties.count)

    let properties = client.properties.last!

    XCTAssertEqual(false, properties["user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, properties["user_is_backer"] as? Bool)
    XCTAssertEqual(false, properties["user_has_starred"] as? Bool)
  }

  func testProjectProperties_LoggedInBacker() {
    let client = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.isStarred .~ false
    let loggedInUser = User.template |> User.lens.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackProjectShow(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(1, client.properties.count)

    let properties = client.properties.last!

    XCTAssertEqual(false, properties["user_is_project_creator"] as? Bool)
    XCTAssertEqual(true, properties["user_is_backer"] as? Bool)
    XCTAssertEqual(false, properties["user_has_starred"] as? Bool)
  }

  func testProjectProperties_LoggedInStarrer() {
    let client = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.isStarred .~ true
    let loggedInUser = User.template |> User.lens.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackProjectShow(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(1, client.properties.count)

    let properties = client.properties.last!

    XCTAssertEqual(false, properties["user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, properties["user_is_backer"] as? Bool)
    XCTAssertEqual(true, properties["user_has_starred"] as? Bool)
  }

  func testProjectProperties_LoggedInCreator() {
    let client = MockTrackingClient()
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      <> Project.lens.personalization.isStarred .~ false
    let loggedInUser = project.creator
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackProjectShow(project, refTag: nil, cookieRefTag: nil)
    XCTAssertEqual(1, client.properties.count)

    let properties = client.properties.last!

    XCTAssertEqual(true, properties["user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, properties["user_is_backer"] as? Bool)
    XCTAssertEqual(false, properties["user_has_starred"] as? Bool)
  }
}
