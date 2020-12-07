import KsApi
import Library
import Prelude
import ReactiveExtensions
import UIKit

internal final class MessageThreadCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: MessageThreadCellViewModelType = MessageThreadCellViewModel()

  @IBOutlet private var avatarImageView: UIImageView!
  @IBOutlet private var bodyLabel: UILabel!
  @IBOutlet private var dateLabel: UILabel!
  @IBOutlet private var dividerView: UIView!
  @IBOutlet private var nameLabel: UILabel!
  @IBOutlet private var projectNameLabel: UILabel!
  @IBOutlet private var replyIndicator: UIView!
  @IBOutlet private var unreadIndicatorView: UIView!

  func configureWith(value: MessageThread) {
    self.viewModel.inputs.configureWith(messageThread: value)
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    self.viewModel.inputs.setSelected(selected)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> MessageThreadCell.lens.backgroundColor .~ .ksr_white
      |> MessageThreadCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(6), leftRight: Styles.grid(16))
          : .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
      }

    _ = self.avatarImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.bodyLabel
      |> UILabel.lens.textColor .~ .ksr_support_400
      |> UILabel.lens.font .~ UIFont.ksr_subhead(size: 14.0)

    _ = self.dateLabel
      |> UILabel.lens.textColor .~ .ksr_support_700
      |> UILabel.lens.font .~ .ksr_caption1()

    _ = self.dividerView
      |> separatorStyle

    _ = self.nameLabel
      |> UILabel.lens.textColor .~ .ksr_support_700
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 13.0)

    _ = self.projectNameLabel
      |> UILabel.lens.textColor .~ .ksr_support_400
      |> UILabel.lens.font .~ UIFont.ksr_subhead(size: 15.0)
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.participantAvatarURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.avatarImageView.af.cancelImageRequest()
        self?.avatarImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] url in
        self?.avatarImageView.af.setImage(withURL: url)
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
