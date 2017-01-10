#if os(iOS)
import Foundation
import UIKit

public let SafariActivityType = UIActivityType("com.kickstarter.kickstarter.safari")

public final class SafariActivity: UIActivity {
  fileprivate var url: URL?

  public convenience init(url: URL) {
    self.init()

    self.url = url
  }

  public override var activityType: UIActivityType? {
    return SafariActivityType
  }

  public override var activityTitle: String? {
    return "Safari"
  }

  public override var activityImage: UIImage? {
    return image(named: "safari-icon-full")
  }

  public override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
    let urls = activityItems.filter { $0 is URL && ($0 as? URL)?.host != nil }
    return !urls.isEmpty
  }

  public override func perform() {
    guard let url = self.url else { return }

    UIApplication.shared.openURL(url)
    self.activityDidFinish(true)
  }
}
#endif
