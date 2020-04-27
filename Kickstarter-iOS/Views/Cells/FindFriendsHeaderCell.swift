import Library
import Prelude
import ReactiveSwift
import UIKit

protocol FindFriendsHeaderCellDelegate: AnyObject {
  func findFriendsHeaderCellDismissHeader()
  func findFriendsHeaderCellGoToFriends()
}

internal final class FindFriendsHeaderCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var closeButton: UIButton!
  @IBOutlet fileprivate var containerView: UIView!
  @IBOutlet fileprivate var findFriendsButton: UIButton!
  @IBOutlet fileprivate var subtitleLabel: UILabel!
  @IBOutlet fileprivate var titleLabel: UILabel!

  internal weak var delegate: FindFriendsHeaderCellDelegate?

  fileprivate let viewModel: FindFriendsHeaderCellViewModelType = FindFriendsHeaderCellViewModel()

  func configureWith(value source: FriendsSource) {
    self.viewModel.inputs.configureWith(source: source)
  }

  override func bindViewModel() {
    self.viewModel.outputs.notifyDelegateGoToFriends
      .observeForUI()
      .observeValues { [weak self] in self?.delegate?.findFriendsHeaderCellGoToFriends()
      }

    self.viewModel.outputs.notifyDelegateToDismissHeader
      .observeForUI()
      .observeValues { [weak self] in self?.delegate?.findFriendsHeaderCellDismissHeader()
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
      |> UILabel.lens.textColor .~ .ksr_soft_black
      |> UILabel.lens.text %~ { _ in Strings.Discover_more_projects() }

    _ = self.subtitleLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 12)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.text %~ { _ in Strings.Follow_your_Facebook_friends_and_get_notified() }

    _ = self.closeButton
      |> UIButton.lens.tintColor .~ .ksr_soft_black
      |> UIButton.lens.targets .~ [(self, action: #selector(self.closeButtonTapped), .touchUpInside)]
      |> UIButton.lens.contentEdgeInsets .~ .init(
        top: Styles.grid(1), left: Styles.grid(3),
        bottom: Styles.grid(3), right: Styles.grid(2)
      )
      |> UIButton.lens.accessibilityLabel %~ { _ in
        Strings.social_following_header_accessibility_button_close_find_friends_header_label()
      }

    _ = self.findFriendsButton
      |> fbFollowButtonStyle
      |> UIButton.lens.targets .~ [(self, action: #selector(self.findFriendsButtonTapped), .touchUpInside)]
      |> UIButton.lens.title(for: .normal) %~ { _ in
        Strings.social_following_header_button_find_your_friends()
      }
  }

  @objc func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc func findFriendsButtonTapped() {
    self.viewModel.inputs.findFriendsButtonTapped()
  }
}
