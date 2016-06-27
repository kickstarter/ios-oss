import KsApi
import UIKit

public final class UpdateActivityItemProvider: UIActivityItemProvider {

  private var update: Update?

  public convenience init(update: Update) {
    self.init(placeholderItem: update.title)

    self.update = update
  }

  public override func activityViewController(activityViewController: UIActivityViewController,
                                              itemForActivityType activityType: String) -> AnyObject? {

    guard let update = self.update else {
      return self.activityViewControllerPlaceholderItem(activityViewController)
    }

    if activityType == UIActivityTypeMail {
      return Strings.social_update_sequence_and_title(
        update_number: String(update.sequence),
        update_title: update.title
      )
    } else if activityType == UIActivityTypeMessage {
      return update.title
    } else if activityType == UIActivityTypePostToTwitter {
      return Strings.project_checkout_share_twitter_via_kickstarter(
          project_or_update_title: update.title
      )
    } else if activityType == UIActivityTypeCopyToPasteboard ||
      activityType == UIActivityTypePostToFacebook {
      return update.urls.web.update
    }

    return Strings.social_update_sequence_and_title(
      update_number: String(update.sequence),
      update_title: update.title
    )
  }
}
