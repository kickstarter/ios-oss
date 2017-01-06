import XCTest
import Argo
@testable import LiveStream

public extension Decodable {
  public static func decodeJSONDictionary(json: [String: AnyObject]) -> Decoded<DecodedType> {
    return Self.decode(JSON(json))
  }
}

final class LiveStreamEventTests: XCTestCase {

  //swiftlint:disable function_body_length
  func testParseJSON() {
    let liveStreamEvent = LiveStreamEvent.decodeJSONDictionary([
      "success": true,
      "id": 123,
      "stream": [
        "name": "Live Stream Event Name",
        "description": "Live Stream Event Description",
        "background_image_url": "http://www.kickstarter.com",
        "start_date": "2016-12-01T00:00:00.000-00:00",
        "web_url": "http://www.kickstarter.com",
        "project_web_url": "http://www.kickstarter.com",
        "project_name": "Live Stream Project Name",
        "is_rtmp": false,
        "max_opentok_viewers": 300,
        "hls_url": "http://www.kickstarter.com",
        "live_now": true,
        "is_scale": false,
        "has_replay": true,
        "replay_url": "http://www.kickstarter.com"
      ],
      "creator": [
        "creator_name": "Creator Name",
        "creator_avatar": "http://www.kickstarter.com"
      ],
      "firebase": [
        "firebase_project": "huzza-web",
        "firebase_api_key": "AIzaSyAt0TtpY7f8QL7zbuh37KwCHQzWoKJ1_pQ",
        "green_room_path": "events/path",
        "hls_url_path": "events/path",
        "number_people_watching_path": "presence/path",
        "scale_number_people_watching_path": "globalpresence/path",
        "chat_path": "messages/path"
      ],
      "opentok": [
        "app": "45698472",
        "session": "1_MX40NTY5ODQ3Mn5-MT",
        "token": "T1==cGFydG5lcl9pZD00="
      ],
      "user": [
        "is_subscribed": true
      ]
    ])

    let dateComponents = NSDateComponents()
    dateComponents.day = 1
    dateComponents.month = 12
    dateComponents.year = 2016
    dateComponents.timeZone = NSTimeZone(forSecondsFromGMT: 0)

    let date = NSCalendar.currentCalendar().dateFromComponents(dateComponents)

    // Stream
    XCTAssertNil(liveStreamEvent.error)
    XCTAssertEqual(123, liveStreamEvent.value?.id)
    XCTAssertEqual("Live Stream Event Name", liveStreamEvent.value?.stream.name)
    XCTAssertEqual("Live Stream Event Description", liveStreamEvent.value?.stream.description)
    XCTAssertEqual("http://www.kickstarter.com", liveStreamEvent.value?.stream.backgroundImageUrl)
    XCTAssertEqual(date, liveStreamEvent.value?.stream.startDate)
    XCTAssertEqual("http://www.kickstarter.com", liveStreamEvent.value?.stream.webUrl)
    XCTAssertEqual("http://www.kickstarter.com", liveStreamEvent.value?.stream.projectWebUrl)
    XCTAssertEqual("Live Stream Project Name", liveStreamEvent.value?.stream.projectName)
    XCTAssertEqual(false, liveStreamEvent.value?.stream.isRtmp)
    XCTAssertEqual(300, liveStreamEvent.value?.stream.maxOpenTokViewers)
    XCTAssertEqual("http://www.kickstarter.com", liveStreamEvent.value?.stream.hlsUrl)
    XCTAssertEqual(true, liveStreamEvent.value?.stream.liveNow)
    XCTAssertEqual(false, liveStreamEvent.value?.stream.isScale)
    XCTAssertEqual(true, liveStreamEvent.value?.stream.hasReplay)
    XCTAssertEqual("http://www.kickstarter.com", liveStreamEvent.value?.stream.replayUrl)

    // Creator
    XCTAssertEqual("Creator Name", liveStreamEvent.value?.creator.name)
    XCTAssertEqual("http://www.kickstarter.com", liveStreamEvent.value?.creator.avatar)

    // Firebase
    XCTAssertEqual("huzza-web", liveStreamEvent.value?.firebase.project)
    XCTAssertEqual("AIzaSyAt0TtpY7f8QL7zbuh37KwCHQzWoKJ1_pQ", liveStreamEvent.value?.firebase.apiKey)
    XCTAssertEqual("events/path", liveStreamEvent.value?.firebase.greenRoomPath)
    XCTAssertEqual("events/path", liveStreamEvent.value?.firebase.hlsUrlPath)
    XCTAssertEqual("presence/path", liveStreamEvent.value?.firebase.numberPeopleWatchingPath)
    XCTAssertEqual("globalpresence/path", liveStreamEvent.value?.firebase.scaleNumberPeopleWatchingPath)
    XCTAssertEqual("messages/path", liveStreamEvent.value?.firebase.chatPath)

    // OpenTok
    XCTAssertEqual("45698472", liveStreamEvent.value?.openTok.appId)
    XCTAssertEqual("1_MX40NTY5ODQ3Mn5-MT", liveStreamEvent.value?.openTok.sessionId)
    XCTAssertEqual("T1==cGFydG5lcl9pZD00=", liveStreamEvent.value?.openTok.token)

    // User
    XCTAssertEqual(true, liveStreamEvent.value?.user.isSubscribed)
  }
  //swiftlint:enable function_body_length
}
