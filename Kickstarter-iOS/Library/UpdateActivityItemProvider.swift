import Foundation
import UIKit
import KsApi
import Library

public final class UpdateActivityItemProvider: UIActivityItemProvider {

  private var update: Update?

  convenience init(update: Update) {
    self.init(placeholderItem: update.title)

    self.update = update
  }

  public override func activityViewController(activityViewController: UIActivityViewController,
                                              itemForActivityType activityType: String) -> AnyObject? {
    if let update = self.update {
      if activityType == UIActivityTypeMail {
        return localizedString(key: "social.update_number",
                               defaultValue: "Update #%{update_number}: %{update_title}\n",
                               count: nil,
                               substitutions: [
                                "update_number": String(update.sequence),
                                "update_title": update.title
          ])
      } else if activityType == UIActivityTypeMessage {
        return update.title
      } else if activityType == UIActivityTypePostToTwitter {
        return localizedString(key: "project.checkout.share.twitter_via_kickstarter",
                               defaultValue: "%{project_or_update_title}, via Kickstarter",
                               count: nil,
                               substitutions: ["project_or_update_title": update.title])
      } else if activityType == UIActivityTypeCopyToPasteboard ||
        activityType == UIActivityTypePostToFacebook {
        return update.urls.web.update
      }
    }
    return self.activityViewControllerPlaceholderItem(activityViewController)
  }
}
