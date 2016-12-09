import FBSDKLoginKit
import Library
import Prelude
import ReactiveCocoa
import UIKit

protocol FindFriendsFacebookConnectCellDelegate: class {
  func findFriendsFacebookConnectCellDidFacebookConnectUser()
  func findFriendsFacebookConnectCellDidDismissHeader()
  func findFriendsFacebookConnectCellShowErrorAlert(alert: AlertError)
}

internal final class FindFriendsFacebookConnectCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var closeButton: UIButton!
  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var facebookConnectButton: UIButton!
  @IBOutlet private weak var subtitleLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!

  internal weak var delegate: FindFriendsFacebookConnectCellDelegate?

  private let viewModel: FindFriendsFacebookConnectCellViewModelType =
    FindFriendsFacebookConnectCellViewModel()

  internal lazy var fbLoginManager: FBSDKLoginManager = {
    let manager = FBSDKLoginManager()
    manager.loginBehavior = .SystemAccount
    manager.defaultAudience = .Friends
    return manager
  }()

  internal func configureWith(value source: FriendsSource) {
    self.viewModel.inputs.configureWith(source: source)
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
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

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> feedTableViewCellStyle

    self.cardView
      |> dropShadowStyle()

    self.containerView
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    self.titleLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.text %~ { _ in Strings.Discover_more_projects() }

    self.subtitleLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 12)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.text %~ { _ in Strings.Connect_with_Facebook_to_follow_friends_and_get_notified() }

    self.closeButton
      |> UIButton.lens.tintColor .~ .ksr_navy_700
      |> UIButton.lens.targets .~ [(self, action: #selector(closeButtonTapped), .TouchUpInside)]
      |> UIButton.lens.contentEdgeInsets .~ .init(top: Styles.grid(1), left: Styles.grid(3),
                                                  bottom: Styles.grid(3), right: Styles.grid(2))

    self.facebookConnectButton
      |> facebookButtonStyle
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 12)
      |> UIButton.lens.targets .~ [(self, action: #selector(facebookConnectButtonTapped), .TouchUpInside)]
      |> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 8)
      |> UIButton.lens.titleEdgeInsets .~ .init(left: Styles.grid(1))
      |> UIButton.lens.title(forState: .Normal) %~ { _ in
        Strings.general_social_buttons_connect_with_facebook()
    }
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

  @objc func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc func facebookConnectButtonTapped() {
    self.viewModel.inputs.facebookConnectButtonTapped()
  }
}
