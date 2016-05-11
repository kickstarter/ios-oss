import Library
import Models
import UIKit

internal final class CommentCell: UITableViewCell, ValueCell {
  private let viewModel = CommentCellViewModel()

  @IBOutlet internal weak var avatarImageView: UIImageView!
  @IBOutlet internal weak var bodyLabel: UILabel!
  @IBOutlet internal weak var creatorView: UIView!
  @IBOutlet internal weak var nameLabel: UILabel!
  @IBOutlet internal weak var timestampLabel: UILabel!
  @IBOutlet internal weak var youView: UIView!

  internal override func bindViewModel() {
    self.viewModel.outputs.avatarUrl
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.avatarImageView.af_cancelImageRequest()
        self?.avatarImageView.image = nil
        })
      .ignoreNil()
      .observeNext { [weak self] url in
        self?.avatarImageView.af_setImageWithURL(url)
    }

    self.bodyLabel.rac.text = self.viewModel.outputs.body
    self.bodyLabel.rac.textColor = self.viewModel.outputs.bodyColor
    self.bodyLabel.rac.font = self.viewModel.outputs.bodyFont
    self.creatorView.rac.hidden = self.viewModel.outputs.creatorHidden
    self.nameLabel.rac.text = self.viewModel.outputs.name
    self.timestampLabel.rac.text = self.viewModel.outputs.timestamp
    self.youView.rac.hidden = self.viewModel.outputs.youHidden
  }

  internal func configureWith(value value: (Comment, Project, User?)) {
    self.viewModel.inputs.comment(value.0, project: value.1, viewer: value.2)
  }
}
