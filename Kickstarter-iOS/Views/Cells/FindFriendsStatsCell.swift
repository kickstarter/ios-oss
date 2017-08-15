import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

protocol FindFriendsStatsCellDelegate: class {
  func findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: Int)
}

internal final class FindFriendsStatsCell: UITableViewCell, ValueCell {

  @IBOutlet fileprivate weak var backedProjectsLabel: UILabel!
  @IBOutlet fileprivate weak var bulletSeparatorView: UIView!
  @IBOutlet fileprivate weak var friendsLabel: UILabel!
  @IBOutlet fileprivate weak var friendsCountLabel: UILabel!
  @IBOutlet fileprivate weak var backedProjectsCountLabel: UILabel!
  @IBOutlet fileprivate weak var followAllButton: UIButton!

  internal weak var delegate: FindFriendsStatsCellDelegate?

  fileprivate let viewModel: FindFriendsStatsCellViewModelType = FindFriendsStatsCellViewModel()

  func configureWith(value: (stats: FriendStatsEnvelope, source: FriendsSource)) {
    self.viewModel.inputs.configureWith(stats: value.stats, source: value.source)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.friendsCountLabel.rac.text = self.viewModel.outputs.friendsCountText

    self.backedProjectsCountLabel.rac.text = self.viewModel.outputs.backedProjectsCountText

    self.followAllButton.rac.hidden = self.viewModel.outputs.hideFollowAllButton

    self.followAllButton.rac.title = self.viewModel.outputs.followAllText

    self.viewModel.outputs.notifyDelegateShowFollowAllFriendsAlert
      .observeForUI()
      .observeValues { [weak self] count in
        self?.delegate?.findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: count)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.friendsLabel
      |> UILabel.lens.textColor .~ .ksr_navy_600
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.text %~ { _ in Strings.social_following_stats_friends() }

    _ = self.friendsCountLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.font .~ .ksr_title2()

    _ = self.backedProjectsLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.text %~ { _ in Strings.social_following_stats_backed_projects() }

    _ = self.self.backedProjectsCountLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.font .~ .ksr_title2()

    _ = self.followAllButton
      |> borderButtonStyle
      |> UIButton.lens.targets .~ [(self, action: #selector(followAllButtonTapped), .touchUpInside)]

    _ = self.bulletSeparatorView
      |> UIView.lens.backgroundColor .~ .ksr_grey_500
      |> UIView.lens.alpha .~ 0.7

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.backgroundColor .~ .white
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(4), leftRight: Styles.grid(20))
          : .init(all: Styles.grid(4))
    }
  }

  @objc func followAllButtonTapped() {
    self.viewModel.inputs.followAllButtonTapped()
  }
}
