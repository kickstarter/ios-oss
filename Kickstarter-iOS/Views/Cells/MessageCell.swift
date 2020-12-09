import KsApi
import Library
import Prelude
import ReactiveExtensions
import UIKit

internal final class MessageCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: MessageCellViewModelType = MessageCellViewModel()

  @IBOutlet private var avatarImageView: UIImageView!
  @IBOutlet private var dividerView: UIView!
  @IBOutlet private var nameLabel: UILabel!
  @IBOutlet private var timestampLabel: UILabel!
  @IBOutlet private var bodyTextView: UITextView!

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
      |> MessageCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(6), leftRight: Styles.grid(16))
          : .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
      }

    _ = self.avatarImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.bodyTextView
      |> UITextView.lens.textColor .~ .ksr_support_400
      |> UITextView.lens.font .~ UIFont.ksr_subhead(size: 14.0)

    _ = self.dividerView
      |> separatorStyle

    _ = self.nameLabel
      |> UILabel.lens.textColor .~ .ksr_support_700
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 13.0)

    _ = self.timestampLabel
      |> UILabel.lens.textColor .~ .ksr_support_400
      |> UILabel.lens.font .~ .ksr_caption1()
  }

  internal override func bindViewModel() {
    self.nameLabel.rac.text = self.viewModel.outputs.name
    self.timestampLabel.rac.text = self.viewModel.outputs.timestamp
    self.timestampLabel.rac.accessibilityLabel = self.viewModel.outputs.timestampAccessibilityLabel
    self.bodyTextView.rac.text = self.viewModel.outputs.body

    self.viewModel.outputs.avatarURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.avatarImageView.af.cancelImageRequest()
        self?.avatarImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] in
        self?.avatarImageView.af.setImage(withURL: $0)
      }
  }
}
