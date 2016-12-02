import Library
import Prelude
import ReactiveCocoa
import UIKit

protocol FindFriendsHeaderCellDelegate: class {
  func findFriendsHeaderCellDismissHeader()
  func findFriendsHeaderCellGoToFriends()
}

internal final class FindFriendsHeaderCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var closeButton: UIButton!
  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var findFriendsButton: UIButton!
  @IBOutlet private weak var subtitleLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!

  internal weak var delegate: FindFriendsHeaderCellDelegate?

  private let viewModel: FindFriendsHeaderCellViewModelType = FindFriendsHeaderCellViewModel()

  func configureWith(value source: FriendsSource) {
    self.viewModel.inputs.configureWith(source: source)
  }

  override func bindViewModel() {
    self.viewModel.outputs.notifyDelegateGoToFriends
      .observeForUI()
      .observeNext { [weak self] in self?.delegate?.findFriendsHeaderCellGoToFriends()
    }

    self.viewModel.outputs.notifyDelegateToDismissHeader
      .observeForUI()
      .observeNext { [weak self] in self?.delegate?.findFriendsHeaderCellDismissHeader()
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(10), leftRight: Styles.grid(20))
          : .init(top: Styles.grid(3), left: Styles.grid(2), bottom: Styles.gridHalf(3),
                  right: Styles.grid(2))
    }

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
      |> UIButton.lens.targets .~ [(self, action: #selector(closeButtonTapped), .TouchUpInside)]
      |> UIButton.lens.contentEdgeInsets .~ .init(top: Styles.grid(1), left: Styles.grid(3), bottom: Styles.grid(3), right: Styles.grid(2))

    self.findFriendsButton
      |> navyButtonStyle
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 12)
      |> UIButton.lens.targets .~ [(self, action: #selector(findFriendsButtonTapped), .TouchUpInside)]
      |> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 8, leftRight: 24)
      |> UIButton.lens.title(forState: .Normal) %~ { _ in
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
