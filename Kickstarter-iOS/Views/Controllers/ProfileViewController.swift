import UIKit
import Library

internal final class ProfileViewController: UIViewController {
  @IBOutlet weak var logoutButton: BorderButton!

  @IBAction func logoutButtonPressed(sender: AnyObject) {
    AppEnvironment.logout()
    NSNotificationCenter.defaultCenter().postNotification(
      NSNotification(name: CurrentUserNotifications.sessionEnded, object: nil)
    )
  }
}
