import Library
import LiveStream
import Prelude
import UIKit

internal final class LiveStreamDiscoveryUpcomingAndReplayCell: UITableViewCell, ValueCell {
  private let viewModel: LiveStreamDiscoveryUpcomingAndReplayCellViewModelType
    = LiveStreamDiscoveryUpcomingAndReplayCellViewModel()

  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var creatorImageView: CircleAvatarImageView!
  @IBOutlet private weak var creatorLabel: SimpleHTMLLabel!
  @IBOutlet private weak var infoStackView: UIStackView!
  @IBOutlet private weak var dateContainerView: UIView!
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var imageOverlayView: UIView!
  @IBOutlet private weak var replayButton: UIButton!
  @IBOutlet private weak var streamAvailabilityLabel: UILabel!
  @IBOutlet private weak var streamImageView: UIImageView!
  @IBOutlet private weak var streamTitleContainerView: UIView!
  @IBOutlet private weak var streamTitleLabel: UILabel!

  internal func configureWith(value: LiveStreamEvent) {
    self.viewModel.inputs.configureWith(liveStreamEvent: value)
  }

  // swiftlint:disable:next function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { insets, cell in
        cell.traitCollection.isVerticallyCompact
          ? .init(top: Styles.grid(6), left: insets.left * 6, bottom: Styles.grid(4), right: insets.right * 6)
          : .init(top: Styles.grid(6), left: insets.left, bottom: Styles.grid(4), right: insets.right)
    }

    _ = self.cardView
      |> cardStyle()
      |> dropShadowStyle()

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    _ = self.creatorLabel
      |> SimpleHTMLLabel.lens.boldFont .~ UIFont.ksr_title3(size: 14).bolded
      |> SimpleHTMLLabel.lens.baseAttributes .~ [
        NSParagraphStyleAttributeName: paragraphStyle,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont.ksr_title3(size: 14)
      ]
      |> SimpleHTMLLabel.lens.numberOfLines .~ 0

    _ = self.infoStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _ = self.dateContainerView
      |> liveStreamDateContainerStyle

    _ = self.dateLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.font .~ .ksr_title3(size: 16)

    _ = self.streamTitleContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(2), leftRight: Styles.grid(3))

    _ = self.streamTitleLabel
      |> UILabel.lens.font .~ .ksr_title3(size: 16)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.replayButton
      |> UIButton.lens.enabled .~ false
      |> UIButton.lens.backgroundColor .~ UIColor.white.withAlphaComponent(0.8)
      |> UIButton.lens.titleColor(forState: .normal) .~ .ksr_text_dark_grey_900
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.Replay() }
      |> UIButton.lens.titleLabel.font .~ .ksr_title3(size: 16)
      |> UIButton.lens.adjustsImageWhenDisabled .~ false
      |> UIButton.lens.image(forState: .normal) .~
        Library.image(named: "replay-icon", tintColor: .ksr_text_dark_grey_900)
      |> UIButton.lens.contentEdgeInsets .~ .init(top: Styles.gridHalf(3),
                                                  left: Styles.grid(4),
                                                  bottom: Styles.gridHalf(3),
                                                  right: Styles.grid(3))
      |> UIButton.lens.imageEdgeInsets .~ .init(top: 0, left: Styles.grid(-2), bottom: 0, right: 0)
      |> roundedStyle()

    _ = self.streamAvailabilityLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_body(size: 13)
      |> UILabel.lens.numberOfLines .~ 0
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.creatorImageView.rac.imageUrl = self.viewModel.outputs.creatorImageUrl
    self.creatorLabel.rac.html = self.viewModel.outputs.creatorLabelText
    self.dateContainerView.rac.hidden = self.viewModel.outputs.dateContainerViewHidden
    self.dateLabel.rac.text = self.viewModel.outputs.dateLabelText
    self.imageOverlayView.rac.backgroundColor = self.viewModel.outputs.imageOverlayColor
    self.replayButton.rac.hidden = self.viewModel.outputs.replayButtonHidden
    self.streamAvailabilityLabel.rac.hidden = self.viewModel.outputs.streamAvailabilityLabelHidden
    self.streamAvailabilityLabel.rac.text = self.viewModel.outputs.streamAvailabilityLabelText
    self.streamImageView.rac.imageUrl = self.viewModel.outputs.streamImageUrl
    self.streamTitleLabel.rac.text = self.viewModel.outputs.streamTitleLabelText
  }
}
