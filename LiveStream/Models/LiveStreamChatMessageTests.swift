// swiftlint:disable function_body_length
import XCTest
import Argo
@testable import LiveStream

private struct TestFirebaseDataSnapshotType: FirebaseDataSnapshotType {
  let key: String
  let value: Any?
}

final class LiveStreamChatMessageTests: XCTestCase {
  func testParseJson() {
    let json: [String:Any] = [
      "id": "KDeCy9vvd7ZCRwHc8Ca",
      "creator": false,
      "message": "Test chat message",
      "name": "Test Name",
      "profilePic": "http://www.kickstarter.com/picture.jpg",
      "timestamp": 1234234123,
      "userId": "id_1312341234321"
    ]

    let chatMessage = LiveStreamChatMessage.decodeJSONDictionary(json)

    XCTAssertNil(chatMessage.error)
    XCTAssertEqual("KDeCy9vvd7ZCRwHc8Ca", chatMessage.value?.id)
    XCTAssertEqual(false, chatMessage.value?.isCreator)
    XCTAssertEqual("Test chat message", chatMessage.value?.message)
    XCTAssertEqual("Test Name", chatMessage.value?.name)
    XCTAssertEqual("http://www.kickstarter.com/picture.jpg", chatMessage.value?.profilePictureUrl)
    XCTAssertEqual(1234234123, chatMessage.value?.date)
    XCTAssertEqual("id_1312341234321", chatMessage.value?.userId)
  }

  func testParseFirebaseDataSnapshot() {
    let snapshot = TestFirebaseDataSnapshotType(
      key: "KDeCy9vvd7ZCRwHc8Ca", value: [
        "id": "KDeCy9vvd7ZCRwHc8Ca",
        "creator": false,
        "message": "Test chat message",
        "name": "Test Name",
        "profilePic": "http://www.kickstarter.com/picture.jpg",
        "timestamp": 1234234123,
        "userId": "id_1312341234321"
      ])

    let chatMessage = LiveStreamChatMessage.decode(snapshot)

    XCTAssertNil(chatMessage.error)
    XCTAssertEqual("KDeCy9vvd7ZCRwHc8Ca", chatMessage.value?.id)
    XCTAssertEqual(false, chatMessage.value?.isCreator)
    XCTAssertEqual("Test chat message", chatMessage.value?.message)
    XCTAssertEqual("Test Name", chatMessage.value?.name)
    XCTAssertEqual("http://www.kickstarter.com/picture.jpg", chatMessage.value?.profilePictureUrl)
    XCTAssertEqual(1234234123, chatMessage.value?.date)
    XCTAssertEqual("id_1312341234321", chatMessage.value?.userId)
  }
}
