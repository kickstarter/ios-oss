import Library
import Prelude
import ReactiveSwift
import UIKit

protocol FindFriendsHeaderCellDelegate: class {
  func findFriendsHeaderCellDismissHeader()
  func findFriendsHeaderCellGoToFriends()
}

internal final class FindFriendsHeaderCell: UITableViewCell, ValueCell {

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var closeButton: UIButton!
  @IBOutlet fileprivate weak var containerView: UIView!
  @IBOutlet fileprivate weak var findFriendsButton: UIButton!
  @IBOutlet fileprivate weak var subtitleLabel: UILabel!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

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
      |> UILabel.lens.text %~ { _ in Strings.Follow_your_Facebook_friends_and_get_notified() }

    self.closeButton
      |> UIButton.lens.tintColor .~ .ksr_navy_700
      |> UIButton.lens.targets .~ [(self, action: #selector(closeButtonTapped), .touchUpInside)]
      |> UIButton.lens.contentEdgeInsets .~ .init(top: Styles.grid(1), left: Styles.grid(3),
                                                  bottom: Styles.grid(3), right: Styles.grid(2))
      |> UIButton.lens.accessibilityLabel %~ { _ in
        Strings.social_following_header_accessibility_button_close_find_friends_header_label()
    }

    self.findFriendsButton
      |> navyButtonStyle
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 12)
      |> UIButton.lens.targets .~ [(self, action: #selector(findFriendsButtonTapped), .touchUpInside)]
      |> UIButton.lens.contentEdgeInsets .~ .init(topBottom: Styles.gridHalf(3), leftRight: Styles.grid(4))
      |> UIButton.lens.title(forState: .normal) %~ { _ in
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
