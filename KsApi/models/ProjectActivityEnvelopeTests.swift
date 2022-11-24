@testable import KsApi
import XCTest

final class ProjectActivityEnvelopeTests: XCTestCase {
  func test() {
    let dict: [String: Any] = [
      "urls": [
        "api": [
          "more_activities": "https://api.kickstarter.com/v1/projects/585534558/activities?currency=USD&cursor=93896288&signature=1608143509.1808b80cca292aa6bd422a23a411be2d7e8149d8",
          "newer_activities": "https://api.kickstarter.com/v1/projects/585534558/activities?currency=USD&signature=1608143509.37659885e6797639728dd060fa75c3ca9553251e&since=1608057109"
        ]
      ],
      "activities": [
        [
          "id": 138_285_118,
          "category": "update",
          "project_id": 585_534_558,
          "project_photo": "https://ksr-ugc.imgix.net/assets/013/633/871/f6903ec3876e23e596507f6f1839ac09_original.JPG?ixlib=rb-2.1.0&fill=crop&w=120&h=120&v=1473255769&auto=format&frame=1&q=92&s=2dc93a909b59883a6391785adadb3ff2",
          "update_id": 1_678_113,
          "created_at": 1_521_754_266,
          "user": [
            "id": 1_178_169_226,
            "name": "Katie Mandel Bruce",
            "slug": "katiem",
            "is_registered": nil,
            "is_email_verified": nil,
            "chosen_currency": nil,
            "is_superbacker": nil,
            "avatar": [
              "thumb": "https://ksr-ugc.imgix.net/assets/008/236/721/d406e60ddcc2d3bd3ed541bb915ef53e_original.jpeg?ixlib=rb-2.1.0&w=40&h=40&fit=crop&v=1461511746&auto=format&frame=1&q=92&s=4f9153ea1cb719a4842cf795820acd25",
              "small": "https://ksr-ugc.imgix.net/assets/008/236/721/d406e60ddcc2d3bd3ed541bb915ef53e_original.jpeg?ixlib=rb-2.1.0&w=80&h=80&fit=crop&v=1461511746&auto=format&frame=1&q=92&s=89ae627aba2c664d513ab93ebbc28753",
              "medium": "https://ksr-ugc.imgix.net/assets/008/236/721/d406e60ddcc2d3bd3ed541bb915ef53e_original.jpeg?ixlib=rb-2.1.0&w=160&h=160&fit=crop&v=1461511746&auto=format&frame=1&q=92&s=6b5d8f08ea5e27cf225bd65e85b7744a"
            ],
            "needs_password": true,
            "urls": [
              "web": [
                "user": "https://www.kickstarter.com/profile/katiem"
              ],
              "api": [
                "user": "https://api.kickstarter.com/v1/users/1178169226?signature=1608143509.23e4f60ff06de5e28d7b37b18c1cebc352550a78"
              ]
            ],
            "backed_projects": 389,
            "join_date": "2013-12-09T01:24:28Z",
            "location": nil
          ],
          "update": [
            "id": 1_678_113,
            "project_id": 585_534_558,
            "type": "FreeformPost",
            "likers": [],
            "has_liked": false,
            "title": "test test",
            "sequence": 2,
            "public": false,
            "is_public": false,
            "urls": [
              "api": [
                "update": "https://api.kickstarter.com/v1/projects/585534558/updates/1678113?signature=1608143509.b6949f108ce6fa36d312466cf649d924ef7e8a0a",
                "comments": "https://api.kickstarter.com/v1/projects/585534558/updates/1678113/comments?signature=1608143411.5d5b1158e4404366d6d7a97624f6211d3dac23c8"
              ],
              "web": [
                "update": "https://www.kickstarter.com/projects/katiem/dogs-of-new-york-city/posts/1678113"
              ]
            ],
            "visible": true,
            "published_at": 1_521_754_266,
            "updated_at": 1_521_754_266,
            "comments_count": 0,
            "likes_count": 0,
            "body": "<p>Testing again</p>"
          ],
          "next_activity_id": 94_020_612
        ]
      ]
    ]

    let env: ProjectActivityEnvelope? = ProjectActivityEnvelope.decodeJSONDictionary(dict)

    XCTAssertNotNil(env)
  }
}
