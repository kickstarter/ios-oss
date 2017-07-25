import XCTest
@testable import KsApi
import Prelude

final class UpdateDraftTests: XCTestCase {

  func testJSONParsing_WithCompleteData() {

    let decoded = UpdateDraft.decodeJSONDictionary([
      "body": "world",
      "id": 1,
      "public": true,
      "project_id": 2,
      "sequence": 3,
      "title": "hello",
      "visible": true,
      "urls": [
        "web": [
          "update": "https://www.kickstarter.com/projects/udoo/udoo-x86/posts/1571540"
        ]
      ],
      "images": [["id": 3, "thumb": "thumb.jpg", "full": "full.jpg"]],
      "video": ["id": 4, "frame": "frame.jpg", "status": "successful"]
      ])

    XCTAssertNil(decoded.error)
    let draft = decoded.value
    XCTAssertEqual(1, draft?.update.id)
    XCTAssertEqual(3, draft?.images.first?.id)
    XCTAssertEqual(4, draft?.video?.id)
  }

  func testAttachmentThumbUrl() {

    let image = UpdateDraft.Attachment.image(.template |> UpdateDraft.Image.lens.full .~ "full.jpg")
    XCTAssertEqual("full.jpg", image.thumbUrl)

    let video = UpdateDraft.Attachment.video(.template |> UpdateDraft.Video.lens.frame .~ "frame.jpg")
    XCTAssertEqual("frame.jpg", video.thumbUrl)
  }
}
