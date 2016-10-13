import Library
import KsApi
import Prelude
import UIKit

internal final class ProfileHeaderView: UICollectionReusableView, ValueCell {
  private let viewModel: ProfileHeaderViewModelType = ProfileHeaderViewModel()

  @IBOutlet private weak var avatarImageView: UIImageView!
  @IBOutlet private weak var backedProjectsLabel: UILabel!
  @IBOutlet private weak var createdProjectsLabel: UILabel!
  @IBOutlet private weak var dividerView: UIView!
  @IBOutlet private weak var nameLabel: UILabel!

  internal func configureWith(value user: User) {
    self.viewModel.inputs.user(user)
  }

  internal override func bindViewModel() {
    self.backedProjectsLabel.rac.text = self.viewModel.outputs.backedProjectsCountLabel
    self.createdProjectsLabel.rac.text = self.viewModel.outputs.createdProjectsCountLabel
    self.createdProjectsLabel.rac.hidden = self.viewModel.outputs.createdProjectsLabelHidden
    self.createdProjectsLabel.rac.hidden = self.viewModel.outputs.createdProjectsCountLabelHidden
    self.dividerView.rac.hidden = self.viewModel.outputs.dividerViewHidden
    self.nameLabel.rac.text = self.viewModel.outputs.userName

    self.viewModel.outputs.avatarURL
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.avatarImageView.af_cancelImageRequest()
        self?.avatarImageView.image = nil
        })
      .ignoreNil()
      .observeNext { [weak self] url in
        self?.avatarImageView.af_setImageWithURL(url)
    }
  }
}
