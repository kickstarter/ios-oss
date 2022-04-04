import UIKit

public enum Storyboard: String {
  case Activity
  case Backing
  case BackerDashboard
  case CommentsDialog
  case Dashboard
  case DashboardProjectsDrawer
  case DebugPushNotifications
  case Discovery
  case DiscoveryPage
  case EmptyStates
  case Friends
  case Help
  case LaunchScreen
  case Login
  case Main
  case Messages
  case PaymentMethods
  case Profile
  case ProjectActivity
  case ProjectPamphlet
  case Search
  case Settings
  case SettingsNewsletters
  case SettingsNotifications
  case SettingsPrivacy
  case Thanks
  case Update
  case UpdateDraft
  case Video

  public func instantiate<VC: UIViewController>(_: VC.Type, inBundle bundle: Bundle = .framework) -> VC {
    guard
      let vc = UIStoryboard(name: self.rawValue, bundle: Bundle(identifier: bundle.identifier))
      .instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC
    else { fatalError("Couldn't instantiate \(VC.storyboardIdentifier) from \(self.rawValue)") }

    return vc
  }
}
