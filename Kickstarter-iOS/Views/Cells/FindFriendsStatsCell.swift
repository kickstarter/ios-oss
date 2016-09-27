import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

protocol FindFriendsStatsCellDelegate: class {
  func findFriendsStatsCellShowFollowAllFriendsAlert(friendCount friendCount: Int)
}

internal final class FindFriendsStatsCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var backedProjectsLabel: UILabel!
  @IBOutlet private weak var bulletSeparatorView: UIView!
  @IBOutlet private weak var friendsLabel: UILabel!
  @IBOutlet private weak var friendsCountLabel: UILabel!
  @IBOutlet private weak var backedProjectsCountLabel: UILabel!
  @IBOutlet private weak var followAllButton: UIButton!

  internal weak var delegate: FindFriendsStatsCellDelegate?

  private let viewModel: FindFriendsStatsCellViewModelType = FindFriendsStatsCellViewModel()

  func configureWith(value value: (stats: FriendStatsEnvelope, source: FriendsSource)) {
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
      .observeNext { [weak self] count in
        self?.delegate?.findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: count)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self.friendsLabel
      |> UILabel.lens.textColor .~ .ksr_navy_600
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.text %~ { _ in Strings.social_following_stats_friends() }

    self.friendsCountLabel
      |> UILabel.lens.textColor .~ .ksr_navy_900
      |> UILabel.lens.font .~ .ksr_title2()

    self.backedProjectsLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.text %~ { _ in Strings.social_following_stats_backed_projects() }

    self.self.backedProjectsCountLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_900
      |> UILabel.lens.font .~ .ksr_title2()

    self.followAllButton
      |> borderButtonStyle
      |> UIButton.lens.targets .~ [(self, action: #selector(followAllButtonTapped), .TouchUpInside)]

    self.bulletSeparatorView
      |> UIView.lens.backgroundColor .~ .ksr_grey_500
      |> UIView.lens.alpha .~ 0.7

    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins .~ .init(all: Styles.grid(4))
  }

  @objc func followAllButtonTapped() {
    self.viewModel.inputs.followAllButtonTapped()
  }
}
