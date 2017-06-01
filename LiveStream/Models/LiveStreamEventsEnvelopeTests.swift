import XCTest
import Argo
@testable import LiveStream

final class LiveStreamEventsEnvelopeTests: XCTestCase {
  func testParseJson() {
    let json: [String:Any] = [
      "success": true,
      "number_live_streams": 1,
      "live_streams": [
        [
          "id": 12084,
          "name": "A little info ",
          "description": "",
          "start_date": "2017-01-12T21:00:00.000+01:00",
          "live_now": false,
          "event_over": true,
          "has_replay": true,
          "background_image_url": "https://s3.amazonaws.com/huzza-web/events/background_ima",
          "background_image": [
            "large": "https://s3.amazonaws.com/huzza-web/events/background_images/000/012/08",
            "medium": "https://s3.amazonaws.com/huzza-web/events/background_images/000/012/0",
            "small_cropped": "https://s3.amazonaws.com/huzza-web/events/background_images/00"
          ],
          "feature_score": 0,
          "number_subscribed": 0,
          "web_url": "https://live.kickstarter.com/cary/live/a-little-info",
          "project": [
            "uid": 1350297466,
            "name": "3 for 3 Demo",
            "web_url": "https://www.kickstarter.com/projects/1605538413/3-for-3-demo",
            "deadline": "2017-03-13T19:11:12.000+01:00",
            "cover_image_url": "https://ksr-ugc.imgix.net/assets/015/139/273/ac311ce7d42769ee"
          ],
          "creator": [
            "uid": "1605538413",
            "creator_name": "Cary",
            "creator_avatar": "https://s3.amazonaws.com/huzza-web/artists/avatars/000/007/99"
          ]
        ],
        [
          "id": 12085,
          "name": "A little info ",
          "description": "",
          "start_date": "2017-01-12T21:00:00.000+01:00",
          "live_now": false,
          "event_over": true,
          "has_replay": true,
          "background_image_url": "https://s3.amazonaws.com/huzza-web/events/background_ima",
          "background_image": [
            "large": "https://s3.amazonaws.com/huzza-web/events/background_images/000/012/08",
            "medium": "https://s3.amazonaws.com/huzza-web/events/background_images/000/012/0",
            "small_cropped": "https://s3.amazonaws.com/huzza-web/events/background_images/00"
          ],
          "feature_score": 0,
          "number_subscribed": 0,
          "web_url": "https://live.kickstarter.com/cary/live/a-little-info",
          "project": [
            "uid": 1350297466,
            "name": "3 for 3 Demo",
            "web_url": "https://www.kickstarter.com/projects/1605538413/3-for-3-demo",
            "deadline": "2017-03-13T19:11:12.000+01:00",
            "cover_image_url": "https://ksr-ugc.imgix.net/assets/015/139/273/ac311ce7d42769ee"
          ],
          "creator": [
            "uid": "1605538413",
            "creator_name": "Cary",
            "creator_avatar": "https://s3.amazonaws.com/huzza-web/artists/avatars/000/007/99"
          ]
        ]
      ]
    ]

    let eventsEnvelope = LiveStreamEventsEnvelope.decodeJSONDictionary(json)

    XCTAssertNil(eventsEnvelope.error)
    XCTAssertEqual(1, eventsEnvelope.value?.numberOfLiveStreams)
    XCTAssertEqual(12084, eventsEnvelope.value?.liveStreamEvents[0].id)
    XCTAssertEqual(12085, eventsEnvelope.value?.liveStreamEvents[1].id)
  }
}
