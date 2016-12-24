import Library
import KsApi
import Prelude
import UIKit

internal final class ProfileHeaderView: UICollectionReusableView, ValueCell {
  fileprivate let viewModel: ProfileHeaderViewModelType = ProfileHeaderViewModel()

  @IBOutlet fileprivate weak var avatarImageView: UIImageView!
  @IBOutlet fileprivate weak var backedProjectsLabel: UILabel!
  @IBOutlet fileprivate weak var createdProjectsLabel: UILabel!
  @IBOutlet fileprivate weak var dividerView: UIView!
  @IBOutlet fileprivate weak var nameLabel: UILabel!

  internal func configureWith(value user: User) {
    self.viewModel.inputs.user(user)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.backedProjectsLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.font .~ .ksr_subhead(size: 12)

    _ = self.createdProjectsLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.font .~ .ksr_subhead(size: 12)

    _ = self.dividerView
      |> UIView.lens.backgroundColor .~ .ksr_navy_400

    _ = self.nameLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ .ksr_headline(size: 15)

    _ = [self.backedProjectsLabel, self.createdProjectsLabel]
      ||> UILabel.lens.adjustsFontSizeToFitWidth .~ true
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.backedProjectsLabel.rac.text = self.viewModel.outputs.backedProjectsCountLabel
    self.createdProjectsLabel.rac.text = self.viewModel.outputs.createdProjectsCountLabel
    self.createdProjectsLabel.rac.hidden = self.viewModel.outputs.createdProjectsLabelHidden
    self.createdProjectsLabel.rac.hidden = self.viewModel.outputs.createdProjectsCountLabelHidden
    self.dividerView.rac.hidden = self.viewModel.outputs.dividerViewHidden
    self.nameLabel.rac.text = self.viewModel.outputs.userName

    self.viewModel.outputs.avatarURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.avatarImageView.af_cancelImageRequest()
        self?.avatarImageView.image = nil
        })
      .skipNil()
      .observeValues { [weak self] url in
        self?.avatarImageView.ksr_setImageWithURL(url)
    }
  }
}
