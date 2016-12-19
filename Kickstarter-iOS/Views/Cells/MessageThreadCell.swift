import KsApi
import Library
import Prelude
import ReactiveExtensions
import UIKit

internal final class MessageThreadCell: UITableViewCell, ValueCell {
  private let viewModel: MessageThreadCellViewModelType = MessageThreadCellViewModel()

  @IBOutlet private weak var avatarImageView: UIImageView!
  @IBOutlet private weak var bodyLabel: UILabel!
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var replyIndicator: UIView?
  @IBOutlet private weak var unreadIndicatorView: UIView?

  func configureWith(value value: MessageThread) {
    self.viewModel.inputs.configureWith(messageThread: value)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> MessageThreadCell.lens.backgroundColor .~ .whiteColor()
      |> MessageThreadCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(6), leftRight: Styles.grid(16))
          : layoutMargins
    }
  }

  internal override func bindViewModel() {

    self.viewModel.outputs.participantAvatarURL
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.avatarImageView.af_cancelImageRequest()
        self?.avatarImageView.image = nil
      })
      .skipNil()
      .observeNext { [weak self] url in
        self?.avatarImageView.af_setImageWithURL(url)
    }

    self.viewModel.outputs.participantName
      .observeForUI()
      .observeNext { [weak self] in
        self?.nameLabel.setHTML($0)
    }

    self.replyIndicator?.rac.hidden = self.viewModel.outputs.replyIndicatorHidden
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.dateLabel.rac.text = self.viewModel.outputs.date
    self.dateLabel.rac.accessibilityLabel = self.viewModel.outputs.dateAccessibilityLabel
    self.unreadIndicatorView?.rac.hidden = self.viewModel.outputs.unreadIndicatorHidden
    self.bodyLabel.rac.text = self.viewModel.outputs.messageBody
  }
}
