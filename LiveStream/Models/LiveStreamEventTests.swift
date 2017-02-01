// swiftlint:disable function_body_length
import Argo
import Prelude
import XCTest
@testable import LiveStream

public extension Decodable {
  public static func decodeJSONDictionary(_ json: [String: Any]) -> Decoded<DecodedType> {
    return Self.decode(JSON(json))
  }
}

final class LiveStreamEventTests: XCTestCase {

  func testParseJSON() {
    let json: [String:Any] = [
      "success": true,
      "id": 123,
      "stream": [
        "name": "Live Stream Event Name",
        "description": "Live Stream Event Description",
        "background_image": [
          "medium": "http://www.background.com/medium.jpg",
          "small_cropped": "http://www.background.com/small-cropped.jpg"
        ],
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
        "firebase_api_key": "apikey",
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
    ]
    let liveStreamEvent = LiveStreamEvent.decodeJSONDictionary(json)

    var dateComponents = DateComponents()
    dateComponents.day = 1
    dateComponents.month = 12
    dateComponents.year = 2016
    dateComponents.timeZone = TimeZone(secondsFromGMT: 0)

    let date = Calendar.current.date(from: dateComponents)

    // Stream
    XCTAssertNil(liveStreamEvent.error)
    XCTAssertEqual(123, liveStreamEvent.value?.id)
    XCTAssertEqual("Live Stream Event Name", liveStreamEvent.value?.name)
    XCTAssertEqual("Live Stream Event Description", liveStreamEvent.value?.description)
    XCTAssertEqual("http://www.background.com/medium.jpg", liveStreamEvent.value?.backgroundImage.medium)
    XCTAssertEqual("http://www.background.com/small-cropped.jpg",
                   liveStreamEvent.value?.backgroundImage.smallCropped)
    XCTAssertEqual(date, liveStreamEvent.value?.startDate)
    XCTAssertEqual("http://www.kickstarter.com", liveStreamEvent.value?.webUrl)
    XCTAssertEqual("http://www.kickstarter.com", liveStreamEvent.value?.project.webUrl)
    XCTAssertEqual("Live Stream Project Name", liveStreamEvent.value?.project.name)
    XCTAssertEqual(false, liveStreamEvent.value?.isRtmp)
    XCTAssertEqual(300, liveStreamEvent.value?.maxOpenTokViewers)
    XCTAssertEqual("http://www.kickstarter.com", liveStreamEvent.value?.hlsUrl)
    XCTAssertEqual(true, liveStreamEvent.value?.liveNow)
    XCTAssertEqual(false, liveStreamEvent.value?.isScale)
    XCTAssertEqual(true, liveStreamEvent.value?.hasReplay)
    XCTAssertEqual("http://www.kickstarter.com", liveStreamEvent.value?.replayUrl)

    // Creator
    XCTAssertEqual("Creator Name", liveStreamEvent.value?.creator.name)
    XCTAssertEqual("http://www.kickstarter.com", liveStreamEvent.value?.creator.avatar)

    // Firebase
    XCTAssertEqual("huzza-web", liveStreamEvent.value?.firebase?.project)
    XCTAssertEqual("apikey", liveStreamEvent.value?.firebase?.apiKey)
    XCTAssertEqual("events/path", liveStreamEvent.value?.firebase?.greenRoomPath)
    XCTAssertEqual("events/path", liveStreamEvent.value?.firebase?.hlsUrlPath)
    XCTAssertEqual("presence/path", liveStreamEvent.value?.firebase?.numberPeopleWatchingPath)
    XCTAssertEqual("globalpresence/path", liveStreamEvent.value?.firebase?.scaleNumberPeopleWatchingPath)
    XCTAssertEqual("messages/path", liveStreamEvent.value?.firebase?.chatPath)

    // OpenTok
    XCTAssertEqual("45698472", liveStreamEvent.value?.openTok?.appId)
    XCTAssertEqual("1_MX40NTY5ODQ3Mn5-MT", liveStreamEvent.value?.openTok?.sessionId)
    XCTAssertEqual("T1==cGFydG5lcl9pZD00=", liveStreamEvent.value?.openTok?.token)

    // User
    XCTAssertEqual(true, liveStreamEvent.value?.user?.isSubscribed)
  }

  func testDecoding_JSONFromListStream() {
    let json: [String:Any] = [
      "id": 123,
      "name": "Blob Live!",
      "description": "Blobby McBlob comin' to you live!",
      "start_date": "2017-01-18T04:30:00.000-08:00",
      "live_now": false,
      "event_over": false,
      "has_replay": false,
      "background_image": [
        "medium": "http://www.background.com/medium.jpg",
        "small_cropped": "http://www.background.com/small-cropped.jpg"
      ],
      "feature_score": 0,
      "number_subscribed": 114,
      "web_url": "http://www.com",
      "project": [
        "uid": 2047782949,
        "name": "Blob around the world",
        "web_url": "http://www.project.com",
        "deadline": "2016-09-08T15:19:45.000-07:00",
        "cover_image_url": "http://www.cover.jpg"
      ],
      "creator": [
        "uid": "1590380888",
        "creator_name": "Blobby McBlob",
        "creator_avatar": "http://www.creator.jpg"
      ]
    ]

    let liveStreamEventDecoded = LiveStreamEvent.decodeJSONDictionary(json)
    let liveStreamEvent = liveStreamEventDecoded.value

    XCTAssertNotNil(liveStreamEvent)
    XCTAssertNil(liveStreamEventDecoded.error)

    XCTAssertEqual(123, liveStreamEvent?.id)

    // Creator
    XCTAssertEqual("http://www.creator.jpg", liveStreamEvent?.creator.avatar)
    XCTAssertEqual("Blobby McBlob", liveStreamEvent?.creator.name)

    // Firebase
    XCTAssertNil(liveStreamEvent?.firebase)

    // Opentok
    XCTAssertNil(liveStreamEvent?.openTok)

    // Stream
    XCTAssertEqual("http://www.background.com/medium.jpg", liveStreamEvent?.backgroundImage.medium)
    XCTAssertEqual("http://www.background.com/small-cropped.jpg",
                   liveStreamEvent?.backgroundImage.smallCropped)
    XCTAssertEqual("Blobby McBlob comin' to you live!", liveStreamEvent?.description)
    XCTAssertEqual(false, liveStreamEvent?.hasReplay)
    XCTAssertNil(liveStreamEvent?.hlsUrl)
    XCTAssertNil(liveStreamEvent?.isRtmp)
    XCTAssertNil(liveStreamEvent?.isScale)
    XCTAssertEqual(false, liveStreamEvent?.liveNow)
    XCTAssertNil(liveStreamEvent?.maxOpenTokViewers)
    XCTAssertEqual("Blob Live!", liveStreamEvent?.name)
    XCTAssertEqual("http://www.project.com", liveStreamEvent?.project.webUrl)
    XCTAssertEqual("Blob around the world", liveStreamEvent?.project.name)
    XCTAssertNil(liveStreamEvent?.replayUrl)
    XCTAssertEqual(Date(timeIntervalSince1970: 1484742600), liveStreamEvent?.startDate)
    XCTAssertEqual("http://www.com", liveStreamEvent?.webUrl)

    // User
    XCTAssertNil(liveStreamEvent?.user)
  }

  func testCanoncialComparator() {
    let now = Date()

    let currentlyLiveStream = .template
      |> LiveStreamEvent.lens.id .~ 1
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.startDate .~ now

    let futureLiveStreamSoon = .template
      |> LiveStreamEvent.lens.id .~ 2
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ now.addingTimeInterval(60 * 60)

    let futureLiveStreamWayFuture = .template
      |> LiveStreamEvent.lens.id .~ 3
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ now.addingTimeInterval(48 * 60 * 60)

    let pastLiveStreamRecent = .template
      |> LiveStreamEvent.lens.id .~ 4
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ now.addingTimeInterval(-60 * 60)

    let pastLiveStreamWayPast = .template
      |> LiveStreamEvent.lens.id .~ 5
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ now.addingTimeInterval(-24 * 60 * 60)

    let liveStreamEvents = [
      futureLiveStreamWayFuture,
      pastLiveStreamWayPast,
      currentlyLiveStream,
      pastLiveStreamRecent,
      futureLiveStreamSoon,
      ]

    let sortedLiveStreamEvents = [
      currentlyLiveStream,
      futureLiveStreamSoon,
      futureLiveStreamWayFuture,
      pastLiveStreamRecent,
      pastLiveStreamWayPast,
    ]

    XCTAssertEqual(
      sortedLiveStreamEvents,
      liveStreamEvents.sorted(comparator: LiveStreamEvent.canonicalLiveStreamEventComparator(now: now))
    )
  }
}
