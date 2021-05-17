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
    case let (cell as CommentCell, value as String):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}

private func comments() -> [String] {
  [
    "Hi Nimble! Where are you incorporated? Thank you!",
    "The 36 second video with an obvious break and needlessly sped up when backers have asked repeatedly for a no frills, unedited start to finish video of a working product? That video? Yeah, I doubt it's real. It's such a simple request. I've backed at least 3 projects in which the creators have done live videos to take and answer questions and show off their product.\n\nWhy is Nimble being so weird about this?",
    "Hi thank you for your responses. To clarify the point you made to Kate Mathews. Are you saying that your currently you do not have a working unit that can paint nails in 10 minutes but you did in the past?",
    "@dave safeuniverse has some sort of obsession. Normal people would say their piece and let it go, and be a lot less hostile towards everyone.",
    "@Kiki4str those videos show different things (some painting just one nail and not all 4) so it could be that’s a different button…or it’s just different models of the machine. I don’t see why that would point scam at all out of everything else.",
    "Never heard of TryCoral, but will gladly Google them to see if they have proof of a working prototype.",
    "Hmm..\n\nWhich button on the machine really paints the nail??\n\nOn Instagram, one gif shows the most left button, what looks like the \"power on/off\" icon button, being pushed to paint the nails; the latest time lapse video, she pushes the middle button (looks like a circle icon) to paint the nails; and finally in the campaign video on this page, she pushes the right-most button (icon actually looks like a paint droplet or water droplet, which makes sense).\n\nSkepticism level high, guys ...",
    "Hi Nimble, I'm just wondering what size the capsules are ml wise?",
    "It is true what SafeUniverse is saying Doug. To do business in NY you have to be a registered business in NY even if you are registered in another state. What can Nimble provide to show they are registered in NY SafeUniverse?",
    "How often Nimble have to say that they are a real registered Company?\n\nScam here, Scam there...\n\nI still hope that Nimble ships there device.\n\nBut if you dont Trust that offer, dont back.\n\nBut Legal Notice at your Main Website I still miss.",
    "@Nimble Thank you for the effort and heart you have put into this project. I REALLY want to back this project (and tell all my friends about it) because if it works as it claims, I will be using this machine a lot. However, I have to agree with commenters below. Unless you can offer an uncut video of a paint job from start-to-finish, including both shots of the process AND completed nails, many of us are too nervous to fully back this campaign. I understand that filming and editing takes time, and you likely want to do a good job, as this video will be representing your product and company. However, perhaps in this case time and transparency are more important in than perfect editing. It appears you have known about this request for at least a couple of weeks and you claim to be working on creating such a video. Can you please offer a timeline as to when we can expect this video to be completed? (Please do not link me to your frequently-updated Instagram and Facebook pages as I check these regularly and neither of these sites includes the specific video we are requesting.) Thank you very much! Hoping very much to fully support this product!"
  ]
}
