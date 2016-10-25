import Library
import Prelude
import ReactiveCocoa
import UIKit

protocol FindFriendsHeaderCellDelegate: class {
  func findFriendsHeaderCellDismissHeader()
  func findFriendsHeaderCellGoToFriends()
}

internal final class FindFriendsHeaderCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var closeButton: UIButton!
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

    self.titleLabel
      |> UILabel.lens.font .~ .ksr_title3()
      |> UILabel.lens.textColor .~ .ksr_text_navy_900
      |> UILabel.lens.text %~ { _ in Strings.Discover_more_projects() }

    self.subtitleLabel
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.text %~ { _ in Strings.Follow_your_Facebook_friends_and_get_notified() }

    self.closeButton
      |> UIButton.lens.targets .~ [(self, action: #selector(closeButtonTapped), .TouchUpInside)]

    self.findFriendsButton
      |> navyButtonStyle
      |> UIButton.lens.targets .~ [(self, action: #selector(findFriendsButtonTapped), .TouchUpInside)]
      |> UIButton.lens.title(forState: .Normal) %~ { _ in
        Strings.social_following_header_button_find_your_friends()
    }

    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.backgroundColor .~ .whiteColor()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(6), leftRight: Styles.grid(20))
          : .init(all: Styles.grid(4))
      }
  }

  @objc func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc func findFriendsButtonTapped() {
    self.viewModel.inputs.findFriendsButtonTapped()
  }
}
