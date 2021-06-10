import KsApi
import Library
import UIKit

public func commentsViewController(for project: Project? = nil,
                                   update: Update? = nil) -> UITableViewController {
  let isCommentThreadingFeatureEnabled = AppEnvironment.current.optimizelyClient?
    .isFeatureEnabled(featureKey: OptimizelyFeature.Key.commentThreading.rawValue) ?? false

  return isCommentThreadingFeatureEnabled ?
    CommentsViewController.configuredWith(project: project, update: update) :
    DeprecatedCommentsViewController.configuredWith(project: project, update: update)
}
