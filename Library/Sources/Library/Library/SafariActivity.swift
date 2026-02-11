import Foundation
import UIKit

public let SafariActivityType = UIActivity.ActivityType("com.kickstarter.kickstarter.safari")
public struct SafariURL {
  public let url: URL
}

public final class SafariActivity: UIActivity {
  fileprivate var url: URL?

  public convenience init(url: SafariURL) {
    self.init()

    self.url = url.url
  }

  public override var activityType: UIActivity.ActivityType? {
    return SafariActivityType
  }

  public override var activityTitle: String? {
    return "Safari"
  }

  public override var activityImage: UIImage? {
    return image(named: "safari-icon-full")
  }

  public override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
    let urls = activityItems.filter { $0 is SafariURL }
    return !urls.isEmpty
  }

  public override func perform() {
    guard let url = self.url else { return }

    UIApplication.shared.open(url)
    self.activityDidFinish(true)
  }
}
