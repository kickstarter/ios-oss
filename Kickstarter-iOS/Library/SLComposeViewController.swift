import Foundation
import Social
import KsApi
import Library
import AlamofireImage

public extension SLComposeViewController {
  public static func facebookShareProject(project project: Project,
                                          completionHandler: SLComposeViewControllerResult -> Void)
    -> SLComposeViewController? {

    guard let fbVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook),
      url = NSURL(string: project.urls.web.project) else { return nil }

    fbVC.addURL(url)

    if let photoURL = NSURL(string: project.photo.full),
      data = NSData(contentsOfURL: photoURL),
      image = UIImage(data: data) {
      fbVC.addImage(image)
    }
    fbVC.completionHandler = { (result: SLComposeViewControllerResult) in
      completionHandler(result)
    }
    return fbVC
  }

  public static func twitterShareProject(project project: Project,
                                         completionHandler: SLComposeViewControllerResult -> Void)
    -> SLComposeViewController? {

    guard let twitterVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter),
      url = NSURL(string: project.urls.web.project) else { return nil }

    let tweet = Strings.project_checkout_share_twitter_via_kickstarter(project_or_update_title: project.name)

    twitterVC.setInitialText(tweet)
    twitterVC.addURL(url)
    twitterVC.completionHandler = { (result: SLComposeViewControllerResult) in
      completionHandler(result)
    }

    return twitterVC
  }

  public static func twitterShareCheckout(project project: Project,
                                          completionHandler: SLComposeViewControllerResult -> Void)
    -> SLComposeViewController? {

    guard let twitterVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter),
      url = NSURL(string: project.urls.web.project) else { return nil }

    let tweet = Strings.project_checkout_share_twitter_I_just_backed_project_on_kickstarter(
        project_name: project.name
        )

    twitterVC.setInitialText(tweet)
    twitterVC.addURL(url)
    twitterVC.completionHandler = { (result: SLComposeViewControllerResult) in
      completionHandler(result)
    }

    return twitterVC
  }
}
