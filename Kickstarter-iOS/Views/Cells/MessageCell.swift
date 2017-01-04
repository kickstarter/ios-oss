import KsApi
import Library
import Prelude
import ReactiveExtensions
import UIKit

internal final class MessageCell: UITableViewCell, ValueCell {
  private let viewModel: MessageCellViewModelType = MessageCellViewModel()

  @IBOutlet private weak var avatarImageView: UIImageView!
  @IBOutlet private weak var dividerView: UIView!
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var timestampLabel: UILabel!
  @IBOutlet private weak var bodyTextView: UITextView!

  override func awakeFromNib() {
    super.awakeFromNib()

    // NB: removes the default padding around UITextView.
    self.bodyTextView.textContainerInset = UIEdgeInsetsZero
    self.bodyTextView.textContainer.lineFragmentPadding = 0
  }

  internal func configureWith(value message: Message) {
    self.viewModel.inputs.configureWith(message: message)
  }

  internal override func bindStyles() {
    self
      |> baseTableViewCellStyle()
      |> MessageCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(6), leftRight: Styles.grid(16))
          : .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
    }

    self.bodyTextView
      |> UITextView.lens.textColor .~ .ksr_navy_700
      |> UITextView.lens.font .~ UIFont.ksr_subhead(size: 14.0)

    self.dividerView
      |> separatorStyle

    self.nameLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 13.0)

    self.timestampLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.font .~ .ksr_caption1()
  }

  internal override func bindViewModel() {
    self.nameLabel.rac.text = self.viewModel.outputs.name
    self.timestampLabel.rac.text = self.viewModel.outputs.timestamp
    self.timestampLabel.rac.accessibilityLabel = self.viewModel.outputs.timestampAccessibilityLabel
    self.bodyTextView.rac.text = self.viewModel.outputs.body

    self.viewModel.outputs.avatarURL
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.avatarImageView.af_cancelImageRequest()
        self?.avatarImageView.image = nil
      })
      .ignoreNil()
      .observeNext { [weak self] in
        self?.avatarImageView.af_setImageWithURL($0)
    }
  }
}
