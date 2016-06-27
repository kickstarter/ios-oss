import KsApi
import UIKit

public final class ProjectActivityItemProvider: UIActivityItemProvider {

  private var project: Project?

  public convenience init(project: Project) {
    self.init(placeholderItem: project.name)

    self.project = project
  }

  public override func activityViewController(activityViewController: UIActivityViewController,
                                              itemForActivityType activityType: String) -> AnyObject? {
    if let project = self.project {
      if activityType == UIActivityTypeMail || activityType == UIActivityTypeMessage {
        return project.name
      } else if activityType == UIActivityTypePostToTwitter {
        return Strings.project_checkout_share_twitter_via_kickstarter(project_or_update_title: project.name)
      } else if activityType == UIActivityTypeCopyToPasteboard ||
        activityType == UIActivityTypePostToFacebook {
        return project.urls.web.project
      }
    }
    return self.activityViewControllerPlaceholderItem(activityViewController)
  }
}
