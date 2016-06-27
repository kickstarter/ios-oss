import Foundation
import UIKit.UIActivity

public let SafariActivityType = "com.kickstarter.kickstarter.safari"

public final class SafariActivity: UIActivity {
  private var url: NSURL?

  public convenience init(url: NSURL) {
    self.init()

    self.url = url
  }

  public override func activityType() -> String? {
    return SafariActivityType
  }

  public override func activityTitle() -> String? {
    return "Safari"
  }

  public override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
    let urls = activityItems.filter { $0 is NSURL && ($0 as? NSURL)?.host != nil }
    return !urls.isEmpty
  }

  public override func performActivity() {
    guard let url = self.url else { return }

    UIApplication.sharedApplication().openURL(url)
    self.activityDidFinish(true)
  }
}
