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
    itemForActivityType activityType: UIActivity.ActivityType?
  ) -> Any? {
    guard let update = self.update, let type = activityType else {
      return self.activityViewControllerPlaceholderItem(activityViewController)
    }

    switch type {
    case UIActivity.ActivityType.message:
      return self.formattedString(for: update)
    case UIActivity.ActivityType.postToTwitter:
      return Strings.project_checkout_share_twitter_via_kickstarter(
        project_or_update_title: self.formattedString(for: update)
      )
    case UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.postToFacebook:
      return update.urls.web.update
    default:
      return Strings.social_update_sequence_and_title(
        update_number: String(update.sequence),
        update_title: self.formattedString(for: update)
      )
    }
  }

  private func formattedString(for update: Update) -> String {
    return [update.title, update.urls.web.update].joined(separator: "\n")
  }
}
