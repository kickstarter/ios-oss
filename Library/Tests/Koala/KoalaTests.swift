import XCTest
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class KoalaTests: TestCase {

  func testDefaultProperties() {
    let bundle = MockBundle()
    let client = MockTrackingClient()
    let config = Config.template
      |> Config.lens.countryCode .~ "GB"
      |> Config.lens.locale .~ "en"
    let device = MockDevice(userInterfaceIdiom: .phone)
    let screen = MockScreen()
    let koala = Koala(bundle: bundle, client: client, config: config, device: device, loggedInUser: nil,
                      screen: screen)

    koala.trackAppOpen()
    XCTAssertEqual(["App Open", "Opened App"], client.events)

    let properties = client.properties.last

    XCTAssertEqual("Apple", properties?["manufacturer"] as? String)

    XCTAssertEqual(bundle.infoDictionary?["CFBundleVersion"] as? Int, properties?["app_version"] as? Int)
    XCTAssertEqual(bundle.infoDictionary?["CFBundleShortVersionString"] as? String,
                   properties?["app_release"] as? String)
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
    XCTAssertFalse(properties?["user_logged_in"] as! Bool)
    XCTAssertEqual("GB", properties?["user_country"] as? String)
  }

  func testDefaultPropertiesWithLoggedInUser() {
    let client = MockTrackingClient()
    let user = .template
      |> User.lens.stats.backedProjectsCount .~ 2
      |> User.lens.stats.createdProjectsCount .~ 3
      |> User.lens.stats.starredProjectsCount .~ 4
      |> User.lens.location .~ .template
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

    XCTAssertEqual("phone", client.properties.last!["device_format"] as? String)
    XCTAssertEqual("ios", client.properties.last!["client_platform"] as? String)
  }

  func testDeviceFormatAndClientPlatform_ForIPadIdiom() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, device: MockDevice(userInterfaceIdiom: .pad), loggedInUser: nil)
    koala.trackAppOpen()

    XCTAssertEqual("tablet", client.properties.last!["device_format"] as? String)
    XCTAssertEqual("ios", client.properties.last!["client_platform"] as? String)
  }

  func testDeviceFormatAndClientPlatform_ForTvIdiom() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, device: MockDevice(userInterfaceIdiom: .tv), loggedInUser: nil)
    koala.trackAppOpen()

    XCTAssertEqual("tv", client.properties.last!["device_format"] as? String)
    XCTAssertEqual("tvos", client.properties.last!["client_platform"] as? String)
  }

  func testTrackProject() {
    let client = MockTrackingClient()
    let koala = Koala(client: client, loggedInUser: nil)
    let project = Project.template
      |> Project.lens.liveStreams .~ [
        .template
          |> Project.LiveStream.lens.isLiveNow .~ true
    ]

    koala.trackProjectShow(project, refTag: .discovery, cookieRefTag: .recommended)
    XCTAssertEqual(2, client.properties.count)

    let properties = client.properties.last!
    let event = client.events.last!

    XCTAssertEqual("Viewed Project Page", event)
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
    XCTAssertEqual("live_stream_live", properties["live_stream_type"] as? String)

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
    XCTAssertEqual(2, client.properties.count)

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
    XCTAssertEqual(2, client.properties.count)

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
    XCTAssertEqual(2, client.properties.count)

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
    XCTAssertEqual(2, client.properties.count)

    let properties = client.properties.last!

    XCTAssertEqual(true, properties["user_is_project_creator"] as? Bool)
    XCTAssertEqual(false, properties["user_is_backer"] as? Bool)
    XCTAssertEqual(false, properties["user_has_starred"] as? Bool)
  }

  func testProjectProperties_LiveStreams_NoLiveStreams() {
    let client = MockTrackingClient()
    let project = .template
      |> Project.lens.liveStreams .~ nil
    let koala = Koala(client: client)

    koala.trackProjectShow(project, refTag: nil, cookieRefTag: nil)

    XCTAssertEqual([nil, nil], client.properties(forKey: "live_stream_type", as: String.self))
  }

  func testProjectProperties_LiveStreams_CurrentlyLive() {
    let client = MockTrackingClient()
    let project = .template
      |> Project.lens.liveStreams .~ [
        .template
          |> Project.LiveStream.lens.isLiveNow .~ true,
        .template
          |> Project.LiveStream.lens.isLiveNow .~ false
    ]
    let koala = Koala(client: client)

    koala.trackProjectShow(project, refTag: nil, cookieRefTag: nil)

    XCTAssertEqual(["live_stream_live", "live_stream_live"],
                   client.properties(forKey: "live_stream_type", as: String.self))
  }

  func testProjectProperties_LiveStreams_Upcoming() {
    let client = MockTrackingClient()
    let project = .template
      |> Project.lens.liveStreams .~ [
        .template
          |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 + 60 * 60)
          |> Project.LiveStream.lens.isLiveNow .~ false,
        .template
          |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 - 60 * 60)
          |> Project.LiveStream.lens.isLiveNow .~ false
    ]
    let koala = Koala(client: client)

    koala.trackProjectShow(project, refTag: nil, cookieRefTag: nil)

    XCTAssertEqual(["live_stream_countdown", "live_stream_countdown"],
                   client.properties(forKey: "live_stream_type", as: String.self))
  }

  func testProjectProperties_LiveStreams_Replay() {
    let client = MockTrackingClient()
    let project = .template
      |> Project.lens.liveStreams .~ [
        .template
          |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 - 60 * 60)
          |> Project.LiveStream.lens.isLiveNow .~ false
    ]
    let koala = Koala(client: client)

    koala.trackProjectShow(project, refTag: nil, cookieRefTag: nil)

    XCTAssertEqual(["live_stream_replay", "live_stream_replay"],
                   client.properties(forKey: "live_stream_type", as: String.self))
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

    let loggedInUser = User.template |> User.lens.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackDiscovery(params: params, page: 1)

    let properties = client.properties.last!

    XCTAssertEqual(1, properties["discover_category_id"] as? Int)
    XCTAssertEqual(false, properties["discover_recommended"] as? Bool)
    XCTAssertEqual(false, properties["discover_social"] as? Bool)
    XCTAssertEqual(true, properties["discover_staff_picks"] as? Bool)
    XCTAssertEqual(false, properties["discover_starred"] as? Bool)
    XCTAssertEqual("collage", properties["discover_term"] as? String)
    XCTAssertEqual(false, properties["discover_everything"] as? Bool)
    XCTAssertEqual("popularity", properties["discover_sort"] as? String)
    XCTAssertEqual(1, properties["page"] as? Int)
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

    let loggedInUser = User.template |> User.lens.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackDiscovery(params: params, page: 1)

    let properties = client.properties.last!

    XCTAssertNil(properties["discover_category_id"])
    XCTAssertEqual(false, properties["discover_recommended"] as? Bool)
    XCTAssertEqual(false, properties["discover_social"] as? Bool)
    XCTAssertEqual(true, properties["discover_staff_picks"] as? Bool)
    XCTAssertEqual(false, properties["discover_starred"] as? Bool)
    XCTAssertEqual(false, properties["discover_everything"] as? Bool)
    XCTAssertEqual("popularity", properties["discover_sort"] as? String)
    XCTAssertEqual(1, properties["page"] as? Int)
  }

  func testDiscoveryProperties_Everything() {
    let client = MockTrackingClient()
    let params = .defaults
      |> DiscoveryParams.lens.sort .~ .magic

    let loggedInUser = User.template |> User.lens.id .~ 42
    let koala = Koala(client: client, loggedInUser: loggedInUser)

    koala.trackDiscovery(params: params, page: 1)

    let properties = client.properties.last!

    XCTAssertNil(properties["discover_category_id"])
    XCTAssertNil(properties["discover_recommended"])
    XCTAssertNil(properties["discover_social"])
    XCTAssertNil(properties["discover_staff_picks"])
    XCTAssertNil(properties["discover_starred"])
    XCTAssertNil(properties["discover_term"])
    XCTAssertEqual(true, properties["discover_everything"] as? Bool)
    XCTAssertEqual("magic", properties["discover_sort"] as? String)
    XCTAssertEqual(1, properties["page"] as? Int)
  }

  func testTrackChangedLiveStreamOrientation() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)
    let liveStream = .template
      |> Project.LiveStream.lens.isLiveNow .~ true

    koala.trackChangedLiveStreamOrientation(
      project: .template,
      liveStream: liveStream,
      toOrientation: .landscapeLeft
    )

    XCTAssertEqual(["Changed Live Stream Orientation"], client.events)
    XCTAssertEqual(["live_stream_live"], client.properties(forKey: "context", as: String.self))
    XCTAssertEqual(["landscape"], client.properties(forKey: "type", as: String.self))

    koala.trackChangedLiveStreamOrientation(
      project: .template,
      liveStream: liveStream,
      toOrientation: .portrait
    )

    XCTAssertEqual(["Changed Live Stream Orientation", "Changed Live Stream Orientation"], client.events)
    XCTAssertEqual(["live_stream_live", "live_stream_live"], client.properties(forKey: "context",
                                                                               as: String.self))
    XCTAssertEqual(["landscape", "portrait"], client.properties(forKey: "type", as: String.self))
  }

  func testTrackLiveStreamToggleSubscription() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackLiveStreamToggleSubscription(
      project: .template,
      liveStream: .template,
      subscribed: true
    )

    XCTAssertEqual(["Confirmed KSR Live Subscribe Button"], client.events)
    XCTAssertEqual(["live_stream_live"], client.properties(forKey: "context", as: String.self))

    koala.trackLiveStreamToggleSubscription(
      project: .template,
      liveStream: .template,
      subscribed: false
    )

    XCTAssertEqual(["Confirmed KSR Live Subscribe Button", "Confirmed KSR Live Unsubscribe Button"],
                   client.events)
    XCTAssertEqual(["live_stream_live", "live_stream_live"],
                   client.properties(forKey: "context", as: String.self))
  }

  func testTrackViewedLiveStreamCountdown() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackViewedLiveStreamCountdown(
      project: .template,
      liveStream: .template,
      refTag: .projectPage
    )

    XCTAssertEqual(["Viewed Live Stream Countdown"], client.events)
    XCTAssertEqual(["project_page"], client.properties(forKey: "ref_tag", as: String.self))
  }

  func testTrackClosedLiveStream() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    let liveStream = .template
      |> Project.LiveStream.lens.isLiveNow .~ true

    koala.trackClosedLiveStream(
      project: .template,
      liveStream: liveStream,
      startDate: MockDate().date,
      endDate: MockDate().addingTimeInterval(300).date,
      refTag: .projectPage
    )

    XCTAssertEqual(["Closed Live Stream"], client.events)
    XCTAssertEqual(["project_page"], client.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual(["live_stream_live"], client.properties(forKey: "type", as: String.self))
    XCTAssertEqual([300], client.properties(forKey: "duration", as: Int.self))
  }

  func testTrackClosedLiveStreamCountdown() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    let liveStream = .template
      |> Project.LiveStream.lens.isLiveNow .~ false
      |> Project.LiveStream.lens.startDate .~ (MockDate().addingTimeInterval(60)).timeIntervalSince1970

    koala.trackClosedLiveStream(
      project: .template,
      liveStream: liveStream,
      startDate: MockDate().date,
      endDate: MockDate().addingTimeInterval(300).date,
      refTag: .projectPage
    )

    XCTAssertEqual(["Closed Live Stream"], client.events)
    XCTAssertEqual(["project_page"], client.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual(["live_stream_countdown"], client.properties(forKey: "type", as: String.self))
    XCTAssertEqual([300], client.properties(forKey: "duration", as: Int.self))
  }

  func testTrackClosedLiveStreamReplay() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    let liveStream = .template
      |> Project.LiveStream.lens.isLiveNow .~ false
      |> Project.LiveStream.lens.startDate .~ (MockDate().addingTimeInterval(-60)).timeIntervalSince1970

    koala.trackClosedLiveStream(
      project: .template,
      liveStream: liveStream,
      startDate: MockDate().date,
      endDate: MockDate().addingTimeInterval(300).date,
      refTag: .projectPage
    )

    XCTAssertEqual(["Closed Live Stream"], client.events)
    XCTAssertEqual(["project_page"], client.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual(["live_stream_replay"], client.properties(forKey: "type", as: String.self))
    XCTAssertEqual([300], client.properties(forKey: "duration", as: Int.self))
  }

  func testTrackViewedLiveStream() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)

    koala.trackViewedLiveStream(
      project: .template,
      liveStream: .template,
      refTag: .projectPage
    )

    XCTAssertEqual(["Viewed Live Stream"], client.events)
    XCTAssertEqual(["project_page"], client.properties(forKey: "ref_tag", as: String.self))
  }

  func testTrackWatchedLiveStream_CurrentlyLive() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)
    let liveStream = .template
      |> Project.LiveStream.lens.isLiveNow .~ true

    koala.trackWatchedLiveStream(
      project: .template,
      liveStream: liveStream,
      refTag: .projectPage,
      duration: 1
    )

    XCTAssertEqual(["Watched Live Stream"], client.events)
    XCTAssertEqual(["project_page"], client.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([1], client.properties(forKey: "duration", as: Int.self))
  }

  func testTrackWatchedLiveStream_Replay() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)
    let liveStream = .template
      |> Project.LiveStream.lens.isLiveNow .~ false

    koala.trackWatchedLiveStream(
      project: .template,
      liveStream: liveStream,
      refTag: .projectPage,
      duration: 2
    )

    XCTAssertEqual(["Watched Live Stream Replay"], client.events)
    XCTAssertEqual(["project_page"], client.properties(forKey: "ref_tag", as: String.self))
    XCTAssertEqual([2], client.properties(forKey: "duration", as: Int.self))
  }

  func testTrackBaseLiveStreamProperties() {
    let client = MockTrackingClient()
    let koala = Koala(client: client)
    let liveStream = .template
      |> Project.LiveStream.lens.id .~ 42
      |> Project.LiveStream.lens.isLiveNow .~ true
      |> Project.LiveStream.lens.name .~ "Cool Live Stream"
      |> Project.LiveStream.lens.startDate .~ 1234567

    koala.trackViewedLiveStream(
      project: .template,
      liveStream: liveStream,
      refTag: .projectPage
    )

    XCTAssertEqual([42], client.properties(forKey: "live_stream_id", as: Int.self))
    XCTAssertEqual([true], client.properties(forKey: "live_stream_is_live_now", as: Bool.self))
    XCTAssertEqual(["live_stream_live"], client.properties(forKey: "live_stream_state", as: String.self))
    XCTAssertEqual(["Cool Live Stream"], client.properties(forKey: "live_stream_name", as: String.self))
    XCTAssertEqual([1234567], client.properties(forKey: "live_stream_start_date", as: TimeInterval.self))
  }
}
