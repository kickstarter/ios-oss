import KsApi
import Library
import Prelude
import ReactiveExtensions
import UIKit

protocol MessageCellDelegate: AnyObject {
  func messageCellDidTapHeader(_ cell: MessageCell, _ sender: User)
}

internal final class MessageCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: MessageCellViewModelType = MessageCellViewModel()

  @IBOutlet private var avatarImageView: UIImageView!
  @IBOutlet private var dividerView: UIView!
  @IBOutlet private var nameLabel: UILabel!
  @IBOutlet private var timestampLabel: UILabel!
  @IBOutlet private var bodyTextView: UITextView!
  @IBOutlet var participantStackView: UIStackView!

  weak var delegate: MessageCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()

    // NB: removes the default padding around UITextView.
    self.bodyTextView.textContainerInset = UIEdgeInsets.zero
    self.bodyTextView.textContainer.lineFragmentPadding = 0

    self.participantStackView.addGestureRecognizer(UITapGestureRecognizer(
      target: self,
      action: #selector(self.messageCellHeaderTapped)
    ))

    self.configureAccessibilityElements()
  }

  private func configureAccessibilityElements() {
    self.participantStackView.isAccessibilityElement = true
    self.participantStackView.accessibilityTraits.insert(.button)
    self.timestampLabel.isAccessibilityElement = true
    self.bodyTextView.isAccessibilityElement = true
    self.isAccessibilityElement = false
    self.accessibilityContainerType = .semanticGroup
    self.accessibilityElements = [self.participantStackView!, self.timestampLabel!, self.bodyTextView!]
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
      |> UITextView.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
      |> UITextView.lens.font .~ UIFont.ksr_subhead(size: 14.0)

    _ = self.dividerView
      |> separatorStyle

    _ = self.nameLabel
      |> UILabel.lens.textColor .~ LegacyColors.ksr_support_700.uiColor()
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 13.0)

    _ = self.timestampLabel
      |> UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
      |> UILabel.lens.font .~ .ksr_caption1()
  }

  internal override func bindViewModel() {
    self.nameLabel.rac.text = self.viewModel.outputs.name
    self.participantStackView.rac.accessibilityLabel = self.viewModel.outputs.name
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

    self.viewModel.outputs.messageSender
      .observeForUI()
      .observeValues { [weak self] sender in
        guard let self = self else { return }
        self.delegate?.messageCellDidTapHeader(self, sender)
      }
  }

  @objc private func messageCellHeaderTapped() {
    self.viewModel.inputs.cellHeaderTapped()
  }
}
