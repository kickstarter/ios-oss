#if os(iOS)
import KsApi
import UIKit

public final class ProjectActivityItemProvider: UIActivityItemProvider {

  fileprivate var project: Project?

  public convenience init(project: Project) {
    self.init(placeholderItem: project.name)

    self.project = project
  }

  public override func activityViewController(_ activityViewController: UIActivityViewController,
                                              itemForActivityType activityType: UIActivityType) -> Any? {
    if let project = self.project {
      if activityType == UIActivityType.mail || activityType == UIActivityType.message {
        return project.name
      } else if activityType == UIActivityType.postToTwitter {
        return Strings.project_checkout_share_twitter_via_kickstarter(project_or_update_title: project.name)
      } else if activityType == UIActivityType.copyToPasteboard ||
        activityType == UIActivityType.postToFacebook {
        return project.urls.web.project
      }
    }
    return self.activityViewControllerPlaceholderItem(activityViewController)
  }
}
#endif
