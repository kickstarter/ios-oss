import Foundation
import UIKit
import KsApi

public extension UIActivityViewController {
  public static func shareProject(project project: Project,
                                          completionHandler: (activityType: String?,
                                                              shouldShowPasteboardAlert: Bool,
                                                              completed: Bool) -> Void)
    -> UIActivityViewController {

    let activityItemProvider = ProjectActivityItemProvider.init(project: project)
    let projectURL = NSURL(string: project.urls.web.project) ?? NSURL()
    let activityItems = [activityItemProvider, projectURL]
      let vc = UIActivityViewController(activityItems: activityItems,
                                        applicationActivities: [SafariActivity(url: projectURL)])
    vc.excludedActivityTypes = [
      UIActivityTypePostToWeibo,
      UIActivityTypePrint,
      UIActivityTypeSaveToCameraRoll,
      UIActivityTypeAssignToContact
    ]
    vc.completionWithItemsHandler = {
      (activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) in
      completionHandler(activityType: activityType,
                        shouldShowPasteboardAlert: activityType == UIActivityTypeCopyToPasteboard,
                        completed: completed)
    }
    return vc
  }

  public static func shareUpdate(update update: Update,
                                        completionHandler: (activityType: String?,
                                        shouldShowPasteboardAlert: Bool,
                                        completed: Bool) -> Void)
    -> UIActivityViewController {

      let activityItemProvider = UpdateActivityItemProvider.init(update: update)
      let updateURL = NSURL(string: update.urls.web.update) ?? NSURL()
      let activityItems = [activityItemProvider, updateURL]
      let vc = UIActivityViewController(activityItems: activityItems,
                                        applicationActivities: [SafariActivity(url: updateURL)])
      vc.excludedActivityTypes = [
        UIActivityTypePostToWeibo,
        UIActivityTypePrint,
        UIActivityTypeSaveToCameraRoll,
        UIActivityTypeAssignToContact
      ]
      // exclude these types for backer-only updates
      if !update.isPublic {
        vc.excludedActivityTypes? += [
          UIActivityTypeMail,
          UIActivityTypeMessage,
          UIActivityTypePostToFacebook,
          UIActivityTypePostToTwitter
        ]
      }
      vc.completionWithItemsHandler = {
        (activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) in
        completionHandler(activityType: activityType,
                          shouldShowPasteboardAlert: activityType == UIActivityTypeCopyToPasteboard,
                          completed: completed)
      }
      return vc
  }
}
