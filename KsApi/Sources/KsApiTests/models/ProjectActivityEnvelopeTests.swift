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
          "project_photo": "https://i.kickstarter.com/assets/013/633/871/f6903ec3876e23e596507f6f1839ac09_original.JPG?anim=false&height=120&origin=ugc&q=92&width=120&sig=2csAQU3sXsj8VBgpEtHrXft2yvyl7htuptyX4DoYm5A%3D",
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
              "thumb": "https://i.kickstarter.com/assets/008/236/721/d406e60ddcc2d3bd3ed541bb915ef53e_original.jpeg?anim=false&fit=crop&height=40&origin=ugc&q=92&width=40&sig=NkA974TJwGmfyemXcL6nRdJtxVRDsKlsCX85%2F2yqXzs%3D",
              "small": "https://i.kickstarter.com/assets/008/236/721/d406e60ddcc2d3bd3ed541bb915ef53e_original.jpeg?anim=false&fit=crop&height=80&origin=ugc&q=92&width=80&sig=htkJkInk%2B45yNoSnoGYzply6Vh2Y3IduXN13PYzNbEI%3D",
              "medium": "https://i.kickstarter.com/assets/008/236/721/d406e60ddcc2d3bd3ed541bb915ef53e_original.jpeg?anim=false&fit=crop&height=160&origin=ugc&q=92&width=160&sig=Yr9MKUdGLc8SCGrFBVvoz7t1hjOF2ZW0BCa5EQoj910%3D"
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
