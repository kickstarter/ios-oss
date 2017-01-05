import KsApi
import Library
import Prelude
import ReactiveExtensions
import UIKit

internal final class MessageCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: MessageCellViewModelType = MessageCellViewModel()

  @IBOutlet fileprivate weak var avatarImageView: UIImageView!
  @IBOutlet fileprivate weak var nameLabel: UILabel!
  @IBOutlet fileprivate weak var timestampLabel: UILabel!
  @IBOutlet fileprivate weak var bodyTextView: UITextView!

  override func awakeFromNib() {
    super.awakeFromNib()

    // NB: removes the default padding around UITextView.
    self.bodyTextView.textContainerInset = UIEdgeInsets.zero
    self.bodyTextView.textContainer.lineFragmentPadding = 0
  }

  internal func configureWith(value message: Message) {
    self.viewModel.inputs.configureWith(message: message)
  }

  internal override func bindStyles() {
    super.bindStyles()
    
    _ = self
      |> baseTableViewCellStyle()
      |> MessageCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(6), leftRight: Styles.grid(16))
          : layoutMargins
    }
  }

  internal override func bindViewModel() {
    self.nameLabel.rac.text = self.viewModel.outputs.name
    self.timestampLabel.rac.text = self.viewModel.outputs.timestamp
    self.timestampLabel.rac.accessibilityLabel = self.viewModel.outputs.timestampAccessibilityLabel
    self.bodyTextView.rac.text = self.viewModel.outputs.body

    self.viewModel.outputs.avatarURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.avatarImageView.af_cancelImageRequest()
        self?.avatarImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] in
        self?.avatarImageView.af_setImage(withURL: $0)
    }
  }
}
