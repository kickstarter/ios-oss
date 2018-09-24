#if os(iOS)
import KsApi
import UIKit

public final class UpdateActivityItemProvider: UIActivityItemProvider {

  fileprivate var update: Update?

  public convenience init(update: Update) {
    self.init(placeholderItem: update.title)

    self.update = update
  }

  public override func activityViewController(
    _ activityViewController: UIActivityViewController,
    itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {

    guard let update = self.update, let type = activityType else {
      return self.activityViewControllerPlaceholderItem(activityViewController)
    }

    switch type {
    case UIActivity.ActivityType.mail:
      return Strings.social_update_sequence_and_title(
        update_number: String(update.sequence),
        update_title: update.title
      )
    case UIActivity.ActivityType.message:
      return update.title
    case UIActivity.ActivityType.postToTwitter:
      return Strings.project_checkout_share_twitter_via_kickstarter(
        project_or_update_title: update.title
      )
    case UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.postToFacebook:
      return update.urls.web.update
    default:
      return Strings.social_update_sequence_and_title(
        update_number: String(update.sequence),
        update_title: update.title
      )
    }
  }
}
#endif
