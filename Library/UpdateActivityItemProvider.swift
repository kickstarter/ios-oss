#if os(iOS)
import KsApi
import UIKit

public final class UpdateActivityItemProvider: UIActivityItemProvider {

  fileprivate var update: Update?

  public convenience init(update: Update) {
    self.init(placeholderItem: update.title)

    self.update = update
  }

  public override func activityViewController(_ activityViewController: UIActivityViewController,
                                              itemForActivityType activityType: UIActivityType) -> Any? {

    guard let update = self.update else {
      return self.activityViewControllerPlaceholderItem(activityViewController)
    }

    if activityType == UIActivityType.mail {
      return Strings.social_update_sequence_and_title(
        update_number: String(update.sequence),
        update_title: update.title
      )
    } else if activityType == UIActivityType.message {
      return update.title
    } else if activityType == UIActivityType.postToTwitter {
      return Strings.project_checkout_share_twitter_via_kickstarter(
          project_or_update_title: update.title
      )
    } else if activityType == UIActivityType.copyToPasteboard ||
      activityType == UIActivityType.postToFacebook {
      return update.urls.web.update
    }

    return Strings.social_update_sequence_and_title(
      update_number: String(update.sequence),
      update_title: update.title
    )
  }
}
#endif
