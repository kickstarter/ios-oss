import KsApi
import Library
import Prelude
import ReactiveExtensions
import UIKit

internal final class MessageThreadCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: MessageThreadCellViewModelType = MessageThreadCellViewModel()

  @IBOutlet fileprivate weak var avatarImageView: UIImageView!
  @IBOutlet fileprivate weak var bodyLabel: UILabel!
  @IBOutlet fileprivate weak var dateLabel: UILabel!
  @IBOutlet fileprivate weak var nameLabel: UILabel!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!
  @IBOutlet fileprivate weak var replyIndicator: UIView?
  @IBOutlet fileprivate weak var unreadIndicatorView: UIView?

  func configureWith(value: MessageThread) {
    self.viewModel.inputs.configureWith(messageThread: value)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> MessageThreadCell.lens.backgroundColor .~ .white
      |> MessageThreadCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(6), leftRight: Styles.grid(16))
          : layoutMargins
    }
  }

  internal override func bindViewModel() {

    self.viewModel.outputs.participantAvatarURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.avatarImageView.af_cancelImageRequest()
        self?.avatarImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] url in
        self?.avatarImageView.af_setImage(withURL: url)
    }

    self.viewModel.outputs.participantName
      .observeForUI()
      .observeValues { [weak self] in
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
