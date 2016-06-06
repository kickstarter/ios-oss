import Foundation
import UIKit
import KsApi
import Library

public final class ProjectActivityItemProvider: UIActivityItemProvider {

  private var project: Project?

  convenience init(project: Project) {
    self.init(placeholderItem: project.name)

    self.project = project
  }

  public override func activityViewController(activityViewController: UIActivityViewController,
                                              itemForActivityType activityType: String) -> AnyObject? {
    if let project = self.project {
      if activityType == UIActivityTypeMail || activityType == UIActivityTypeMessage {
        return project.name
      } else if activityType == UIActivityTypePostToTwitter {
        return localizedString(key: "project.checkout.share.twitter_via_kickstarter",
                               defaultValue: "%{project_or_update_title}, via Kickstarter",
                               count: nil,
                               substitutions: ["project_or_update_title": project.name])
      } else if activityType == UIActivityTypeCopyToPasteboard ||
        activityType == UIActivityTypePostToFacebook {
        return project.urls.web.project
      }
    }
    return self.activityViewControllerPlaceholderItem(activityViewController)
  }
}
