import AlamofireImage
import Library
import LiveStream
import Prelude

internal final class LiveStreamDiscoveryCell: UITableViewCell, ValueCell {
  private let viewModel: LiveStreamDiscoveryCellViewModelType = LiveStreamDiscoveryCellViewModel()

  @IBOutlet private weak var backgroundImageView: UIImageView!
  @IBOutlet private weak var blurView: UIView!
  @IBOutlet private weak var countdownStackView: UIStackView!
  @IBOutlet private var colonViews: [UILabel]!
  @IBOutlet private weak var creatorImageView: UIImageView!
  @IBOutlet private weak var creatorLabel: UILabel!
  @IBOutlet private weak var creatorStackView: UIStackView!
  @IBOutlet private weak var dateContainerView: UIView!
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var detailsStackView: UIStackView!
  @IBOutlet private weak var dayCountLabel: UILabel!
  @IBOutlet private weak var daysLabel: UILabel!
  @IBOutlet private weak var hourCountLabel: UILabel!
  @IBOutlet private weak var hoursLabel: UILabel!
  @IBOutlet private weak var minuteCountLabel: UILabel!
  @IBOutlet private weak var minutesLabel: UILabel!
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var secondCountLabel: UILabel!
  @IBOutlet private weak var secondsLabel: UILabel!
  @IBOutlet private weak var watchButton: UIButton!

  internal func configureWith(value: LiveStreamEvent) {
    self.viewModel.inputs.configureWith(liveStreamEvent: value)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { insets, cell in
        cell.traitCollection.isVerticallyCompact
          ? .init(top: Styles.grid(2), left: insets.left * 6, bottom: Styles.grid(4), right: insets.right * 6)
          : .init(top: Styles.grid(2), left: insets.left, bottom: Styles.grid(4), right: insets.right)
    }

    _ = self.backgroundImageView
      |> roundedStyle()

    _ = self.blurView
      |> roundedStyle()

    _ = self.countdownStackView
      |> UIStackView.lens.distribution .~ .equalCentering
      |> UIStackView.lens.alignment .~ .firstBaseline
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.creatorImageView
      |> UIImageView.lens.backgroundColor .~ .ksr_grey_500

    _ = self.creatorLabel
      |> UILabel.lens.font .~ .ksr_subhead()

    _ = self.creatorStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.dateContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
      |> roundedStyle()

    _ = self.daysLabel
      |> UILabel.lens.text %~ { _ in localizedString(key: "days", defaultValue: "days") }

    _ = self.dateLabel
      |> UILabel.lens.font .~ .ksr_subhead()

    _ = self.detailsStackView
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(4))
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _ = self.hoursLabel
      |> UILabel.lens.text %~ { _ in localizedString(key: "hours", defaultValue: "hours") }

    _ = self.minutesLabel
      |> UILabel.lens.text %~ { _ in localizedString(key: "minutes", defaultValue: "minutes") }

    _ = self.nameLabel
      |> UILabel.lens.font .~ .ksr_headline()
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(4)
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(8), leftRight: Styles.grid(3))

    _ = self.secondsLabel
      |> UILabel.lens.text %~ { _ in localizedString(key: "seconds", defaultValue: "seconds") }

    _ = self.watchButton
      |> greenButtonStyle

    _ = [self.dayCountLabel, self.hourCountLabel, self.minuteCountLabel, self.secondCountLabel]
      ||> UILabel.lens.font %~~ { _, l in countdownFont(label: l) }
      ||> UILabel.lens.textAlignment .~ .center

    _ = [self.daysLabel, self.hoursLabel, self.minutesLabel, self.secondsLabel]
      ||> UILabel.lens.font .~ .ksr_footnote()
      ||> UILabel.lens.textAlignment .~ .center
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    //self.backgroundImageView.rac.imageUrl = self.viewModel.outputs.backgroundImageUrl

    self.viewModel.outputs.backgroundImageUrl
      .observeForUI()
      .on(event: { [weak self] _ in self?.backgroundImageView.image = nil })
      .skipNil()
      .observeValues { [weak self] url in
        let filter = AspectScaledToFillSizeFilter(size: CGSize(width: 200, height: 150))
        self?.backgroundImageView.af_setImage(withURL: url, filter: filter)
    }

    self.countdownStackView.rac.hidden = self.viewModel.outputs.countdownStackViewHidden
    self.creatorLabel.rac.text = self.viewModel.outputs.creatorLabelText
    self.creatorImageView.rac.imageUrl = self.viewModel.outputs.creatorImageUrl
    self.dateLabel.rac.text = self.viewModel.outputs.dateLabelText
    self.dayCountLabel.rac.text = self.viewModel.outputs.dayCountLabelText
    self.hourCountLabel.rac.text = self.viewModel.outputs.hourCountLabelText
    self.minuteCountLabel.rac.text = self.viewModel.outputs.minuteCountLabelText
    self.nameLabel.rac.text = self.viewModel.outputs.nameLabelText
    self.secondCountLabel.rac.text = self.viewModel.outputs.secondCountLabelText
    self.watchButton.rac.hidden = self.viewModel.outputs.watchButtonHidden
  }
}

// Returns a fancy monospaced font for the countdown.
private func countdownFont(label: UILabel) -> UIFont {

  let baseFont: UIFont = label.traitCollection.isRegularRegular
    ? .ksr_title1() : .ksr_title1(size: 24)

  let monospacedDescriptor = baseFont.fontDescriptor
    .addingAttributes(
      [
        UIFontDescriptorFeatureSettingsAttribute: [
          [
            UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
            UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
          ],
          [
            UIFontFeatureTypeIdentifierKey: kStylisticAlternativesType,
            UIFontFeatureSelectorIdentifierKey: kStylisticAltTwoOnSelector
          ],
          [
            UIFontFeatureTypeIdentifierKey: kStylisticAlternativesType,
            UIFontFeatureSelectorIdentifierKey: kStylisticAltOneOnSelector
          ]
        ]
      ]
  )

  return UIFont(descriptor: monospacedDescriptor, size: 0.0)
}
