import UIKit
import Library
import ReactiveCocoa
import FBSDKLoginKit

protocol FindFriendsFacebookConnectCellDelegate: class {
  func findFriendsFacebookConnectCellDidFacebookConnectUser()
  func findFriendsFacebookConnectCellDidDismissHeader()
  func findFriendsFacebookConnectCellShowErrorAlert(alert: AlertError)
}

internal final class FindFriendsFacebookConnectCell: UITableViewCell, ValueCell {

  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var facebookConnectButton: BorderButton!

  internal weak var delegate: FindFriendsFacebookConnectCellDelegate?

  private let viewModel: FindFriendsFacebookConnectCellViewModelType =
    FindFriendsFacebookConnectCellViewModel()

  internal lazy var fbLoginManager: FBSDKLoginManager = {
    let manager = FBSDKLoginManager()
    manager.loginBehavior = .SystemAccount
    manager.defaultAudience = .Friends
    return manager
  }()

  // swiftlint:disable function_body_length
  override func bindViewModel() {
    self.closeButton.rac.hidden = self.viewModel.outputs.hideCloseButton

    self.viewModel.outputs.attemptFacebookLogin
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.attemptFacebookLogin()
    }

    self.viewModel.outputs.notifyDelegateToDismissHeader
      .observeForUI()
      .observeNext { [weak self] in
        self?.delegate?.findFriendsFacebookConnectCellDidDismissHeader()
    }

    self.viewModel.outputs.notifyDelegateUserFacebookConnected
      .observeForUI()
      .observeNext { [weak self] in
        self?.delegate?.findFriendsFacebookConnectCellDidFacebookConnectUser()
    }

    self.viewModel.outputs.postUserUpdatedNotification
      .observeNext(NSNotificationCenter.defaultCenter().postNotification)

    self.viewModel.outputs.showErrorAlert
      .observeForUI()
      .observeNext { [weak self] alert in
        self?.delegate?.findFriendsFacebookConnectCellShowErrorAlert(alert)
    }

    self.viewModel.outputs.updateUserInEnvironment
      .observeNext { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        self?.viewModel.inputs.userUpdated()
    }
  }
  // swiftlint:enable function_body_length

  func configureWith(value source: FriendsSource) {
    self.viewModel.inputs.configureWith(source: source)
  }

  // MARK: Facebook Login
  private func attemptFacebookLogin() {
    self.fbLoginManager.logInWithReadPermissions(
      ["public_profile", "email", "user_friends"],
      fromViewController: nil) {
        (result: FBSDKLoginManagerLoginResult!, error: NSError!) in
        if error != nil {
          self.viewModel.inputs.facebookLoginFail(error: error)
        } else if !result.isCancelled {
          self.viewModel.inputs.facebookLoginSuccess(result: result)
        }
    }
  }

  @IBAction func closeButtonTapped(sender: AnyObject) {
    self.viewModel.inputs.closeButtonTapped()
  }

  @IBAction func facebookConnectButtonTapped(sender: AnyObject) {
    self.viewModel.inputs.facebookConnectButtonTapped()
  }
}
