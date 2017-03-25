import XCTest
@testable import LiveStream

class LiveStreamTypesTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  func testNewChatMessageToDictionary() {
    let newChatMessage = NewLiveStreamChatMessage(
      message: "Message",
      name: "Test Name",
      profilePic: "http://www.profilepic.com/image.jpg",
      userId: "id_12345")

    let dictionary = newChatMessage.toFirebaseDictionary()

    XCTAssertEqual("Message", dictionary["message"] as? String)
    XCTAssertEqual("Test Name", dictionary["name"] as? String)
    XCTAssertEqual("http://www.profilepic.com/image.jpg", dictionary["profilePic"] as? String)
    XCTAssertEqual("id_12345", dictionary["userId"] as? String)
  }
}
