import KsApi
import Library
import Prelude
import UIKit

internal final class CommentsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case comments
  }

  func load() {
    self.set(values: comments(), cellClass: CommentCell.self, inSection: Section.comments.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as CommentCell, value as DemoComment):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}

private func comments() -> [DemoComment] {
  let decoder = JSONDecoder()
  do {
    let jsonData = try JSONSerialization.data(withJSONObject: sampleComments, options: [])
    let comments = try decoder.decode([DemoComment].self, from: jsonData)
    return comments
  } catch {
    print(error)
    return []
  }
}

struct DemoComment: Codable {
  let id: Int
  let firstName, lastName: String
  let username: String?
  let postTime, body: String
  let type: UserTypeEnum
  let isRemoved: Bool?
  let imageURL: String
  let isFailed: Bool?

  enum CodingKeys: String, CodingKey {
    case id
    case firstName = "first_name"
    case lastName = "last_name"
    case username, postTime, body, type
    case isRemoved = "is_removed"
    case imageURL
    case isFailed = "is_failed"
  }

  enum UserTypeEnum: String, Codable {
    case backer
    case superbacker
    case creator
  }
}

private let sampleComments: [[String: Any]] =
  [
    [
      "id": 1,
      "first_name": "Kale",
      "last_name": "Mewrcik",
      "username": "kmewrcik0",
      "postTime": "06:15am Yesterday",
      "body": "Hi Nimble! Where are you incorporated? Thank you!",
      "type": "superbacker",
      "is_removed": true,
      "imageURL": "https://pixinvent.com/materialize-material-design-admin-template/app-assets/images/user/12.jpg"
    ],
    [
      "id": 2,
      "first_name": "Ariella",
      "last_name": "Cassin",
      "username": "acassin1",
      "postTime": "01:10pm Yesterday",
      "body": "The 36 second video with an obvious break and needlessly sped up when backers have asked repeatedly for a no frills, unedited start to finish video of a working product? That video? Yeah, I doubt its real. Its such a simple request. Ive backed at least 3 projects in which the creators have done live videos to take and answer questions and show off their product.\n\nWhy is Nimble being so weird about this?",
      "type": "backer",
      "imageURL": "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"
    ],
    [
      "id": 3,
      "first_name": "Essie",
      "last_name": "Cordero",
      "postTime": "10:30pm Yesterday",
      "body": "Hi thank you for your responses. To clarify the point you made to Kate Mathews. Are you saying that your currently you do not have a working unit that can paint nails in 10 minutes but you did in the past?",
      "type": "backer",
      "imageURL": "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"
    ],
    [
      "id": 4,
      "first_name": "Magdaia",
      "last_name": "McMichan",
      "username": "mmcmichan3",
      "postTime": "11:30pm Yesterday",
      "body": "@dave safeuniverse has some sort of obsession. Normal people would say their piece and let it go, and be a lot less hostile towards everyone.",
      "type": "creator",
      "imageURL": "https://cdn.business2community.com/wp-content/uploads/2014/04/profile-picture-300x300.jpg"
    ],
    [
      "id": 5,
      "first_name": "Niki",
      "last_name": "Flewan",
      "username": "nflewan4",
      "postTime": "About 2 hours 30 mins ago",
      "body": "@Kiki4str those videos show different things (some painting just one nail and not all 4) so it could be that’s a different button…or it’s just different models of the machine. I don’t see why that would point scam at all out of everything else.",
      "type": "backer",
      "imageURL": "https://jobscruze.com/front_media/Web/Resume_5/images/johnson.jpg"
    ],
    [
      "id": 6,
      "first_name": "Arda",
      "last_name": "Kemmet",
      "postTime": "About 2 hours ago",
      "body": "Never heard of TryCoral, but will gladly Google them to see if they have proof of a working prototype.",
      "type": "backer",
      "imageURL": "https://wpecommerce.org/wp-content/uploads/2014/11/lee-profile-600x600-300x300.jpg"
    ],
    [
      "id": 7,
      "first_name": "Maribeth",
      "last_name": "Bainbridge",
      "username": "mbainbridge6",
      "postTime": "About 2 hours ago",
      "body": "Hmm..\n\nWhich button on the machine really paints the nail??\n\nOn Instagram, one gif shows the most left button, what looks like the \"power on/off\" icon button, being pushed to paint the nails; the latest time lapse video, she pushes the middle button (looks like a circle icon) to paint the nails; and finally in the campaign video on this page, she pushes the right-most button (icon actually looks like a paint droplet or water droplet, which makes sense).\n\nSkepticism level high, guys ...",
      "type": "superbacker",
      "imageURL": "https://i.pinimg.com/474x/64/70/f0/6470f05eb580db65906515c76471d933.jpg"
    ],
    [
      "id": 8,
      "first_name": "Elsa",
      "last_name": "Treslove",
      "username": "Etreslove7",
      "postTime": "About 1 hour ago",
      "body": "Hi Nimble, Im just wondering what size the capsules are ml wise?",
      "type": "backer",
      "imageURL": "https://st.depositphotos.com/1625039/1874/i/950/depositphotos_18745257-stock-photo-attractive-young-man-profile.jpg"
    ],
    [
      "id": 9,
      "first_name": "Gwenette",
      "last_name": "Trusslove",
      "username": "gtrusslove8",
      "postTime": "About 45 minutes ago",
      "body": "It is true what SafeUniverse is saying Doug. To do business in NY you have to be a registered business in NY even if you are registered in another state. What can Nimble provide to show they are registered in NY SafeUniverse?",
      "type": "backer",
      "imageURL": "https://i.pinimg.com/originals/f5/06/d5/f506d5971e0f09bef23d018488018b5f.jpg"
    ],
    [
      "id": 10,
      "first_name": "Erin",
      "last_name": "Nail",
      "username": "enail9",
      "postTime": "About 15 minutes ago",
      "body": "How often Nimble have to say that they are a real registered Company?\n\nScam here, Scam there...\n\nI still hope that Nimble ships there device.\n\nBut if you dont Trust that offer, dont back.\n\nBut Legal Notice at your Main Website I still miss.",
      "type": "backer",
      "imageURL": "https://i.pinimg.com/originals/68/85/2f/68852f0a3cefd77c0686d4043616e5c7.jpg"
    ],
    [
      "id": 11,
      "first_name": "Duane",
      "last_name": "Davioud",
      "username": "ddaviouda",
      "postTime": "About 15 minutes ago",
      "body": "@Nimble Thank you for the effort and heart you have put into this project. I REALLY want to back this project (and tell all my friends about it) because if it works as it claims, I will be using this machine a lot. However, I have to agree with commenters below. Unless you can offer an uncut video of a paint job from start-to-finish, including both shots of the process AND completed nails, many of us are too nervous to fully back this campaign. I understand that filming and editing takes time, and you likely want to do a good job, as this video will be representing your product and company. However, perhaps in this case time and transparency are more important in than perfect editing. It appears you have known about this request for at least a couple of weeks and you claim to be working on creating such a video. Can you please offer a timeline as to when we can expect this video to be completed? (Please do not link me to your frequently-updated Instagram and Facebook pages as I check these regularly and neither of these sites includes the specific video we are requesting.) Thank you very much! Hoping very much to fully support this product!",
      "type": "backer",
      "imageURL": "https://i.pinimg.com/236x/68/f7/d9/68f7d9ba482190ce2374e3514ea582ec--girl-profile-profile-face.jpg"
    ],
    [
      "id": 12,
      "first_name": "Mike",
      "last_name": "Jones",
      "postTime": "Just now",
      "body": "Hi Nimble! Where are you incorporated? Thank you!",
      "type": "superbacker",
      "is_failed": true,
      "imageURL": "https://thumbs.dreamstime.com/b/african-american-man-close-up-his-face-screaming-mouths-wide-open-looking-angry-isolated-white-background-144047493.jpg"
    ]
  ]
