import UIKit

public enum Storyboard: String {
  case Activity
  case Backing
  case Checkout
  case Comments
  case Dashboard
  case DashboardProjectsDrawer
  case DebugPushNotifications
  case Discovery
  case DiscoveryPage
  case EmptyStates
  case Friends
  case Help
  case LaunchScreen
  case LiveStream
  case LiveStreamDiscovery
  case Login
  case Main
  case Messages
  case Profile
  case ProjectActivity
  case ProjectPamphlet
  case RewardPledge
  case Search
  case Settings
  case Thanks
  case Update
  case UpdateDraft
  case Video
  case WebModal

  public func instantiate<VC: UIViewController>(_ viewController: VC.Type,
                                                inBundle bundle: Bundle = .framework) -> VC {
    guard
      let vc = UIStoryboard(name: self.rawValue, bundle: Bundle(identifier: bundle.identifier))
        .instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC
      else { fatalError("Couldn't instantiate \(VC.storyboardIdentifier) from \(self.rawValue)") }

    return vc
  }
}
