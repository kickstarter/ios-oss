import FBSDKLoginKit
import Library
import Prelude
import ReactiveSwift
import UIKit

protocol FindFriendsFacebookConnectCellDelegate: class {
  func findFriendsFacebookConnectCellDidFacebookConnectUser()
  func findFriendsFacebookConnectCellDidDismissHeader()
  func findFriendsFacebookConnectCellShowErrorAlert(_ alert: AlertError)
}

internal final class FindFriendsFacebookConnectCell: UITableViewCell, ValueCell {

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var closeButton: UIButton!
  @IBOutlet fileprivate weak var containerView: UIView!
  @IBOutlet fileprivate weak var facebookConnectButton: UIButton!
  @IBOutlet fileprivate weak var subtitleLabel: UILabel!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  internal weak var delegate: FindFriendsFacebookConnectCellDelegate?

  fileprivate let viewModel: FindFriendsFacebookConnectCellViewModelType =
    FindFriendsFacebookConnectCellViewModel()

  internal lazy var fbLoginManager: FBSDKLoginManager = {
    let manager = FBSDKLoginManager()
    manager.loginBehavior = .systemAccount
    manager.defaultAudience = .friends
    return manager
  }()

  internal func configureWith(value: FriendsSource) {
    self.viewModel.inputs.configureWith(source: value)
  }

  internal override func bindViewModel() {
    self.closeButton.rac.hidden = self.viewModel.outputs.hideCloseButton
    self.titleLabel.rac.text = self.viewModel.outputs.facebookConnectCellTitle
    self.subtitleLabel.rac.text = self.viewModel.outputs.facebookConnectCellSubtitle
    self.facebookConnectButton.rac.title = self.viewModel.outputs.facebookConnectButtonTitle

    self.viewModel.outputs.attemptFacebookLogin
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.attemptFacebookLogin()
    }

    self.viewModel.outputs.notifyDelegateToDismissHeader
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.findFriendsFacebookConnectCellDidDismissHeader()
    }

    self.viewModel.outputs.notifyDelegateUserFacebookConnected
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.findFriendsFacebookConnectCellDidFacebookConnectUser()
    }

    self.viewModel.outputs.postUserUpdatedNotification
      .observeValues(NotificationCenter.default.post)

    self.viewModel.outputs.showErrorAlert
      .observeForUI()
      .observeValues { [weak self] alert in
        self?.delegate?.findFriendsFacebookConnectCellShowErrorAlert(alert)
    }

    self.viewModel.outputs.updateUserInEnvironment
      .observeValues { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        self?.viewModel.inputs.userUpdated()
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> feedTableViewCellStyle

    _ = self.cardView
      |> cardStyle()

    _ = self.containerView
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    _ = self.titleLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900

    _ = self.subtitleLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 12)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = self.closeButton
      |> UIButton.lens.tintColor .~ .ksr_dark_grey_900
      |> UIButton.lens.targets .~ [(self, action: #selector(closeButtonTapped), .touchUpInside)]
      |> UIButton.lens.contentEdgeInsets .~ .init(top: Styles.grid(1), left: Styles.grid(3),
                                                  bottom: Styles.grid(3), right: Styles.grid(2))

    _ = self.facebookConnectButton
      |> facebookButtonStyle
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 12)
      |> UIButton.lens.targets .~ [(self, action: #selector(facebookConnectButtonTapped), .touchUpInside)]
      |> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 8)
      |> UIButton.lens.titleEdgeInsets .~ .init(left: Styles.grid(1))
  }

  // MARK: Facebook Login
  fileprivate func attemptFacebookLogin() {
    self.fbLoginManager
      .logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: nil) { result, error in
        if let error = error {
          self.viewModel.inputs.facebookLoginFail(error: error)
        } else if let result = result, !result.isCancelled {
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
