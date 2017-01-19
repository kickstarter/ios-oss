import Library
import LiveStream
import Prelude

internal final class LiveStreamDiscoveryCell: UITableViewCell, ValueCell {
  private let viewModel: LiveStreamDiscoveryCellViewModelType = LiveStreamDiscoveryCellViewModel()

  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var countdownStackView: UIStackView!
  @IBOutlet private var colonViews: [UILabel]!
  @IBOutlet weak var creatorImageView: UIImageView!
  @IBOutlet weak var creatorLabel: UILabel!
  @IBOutlet weak var creatorStackView: UIStackView!
  @IBOutlet weak var dateContainerView: UIView!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var detailsStackView: UIStackView!
  @IBOutlet weak var dayCountLabel: UILabel!
  @IBOutlet weak var daysLabel: UILabel!
  @IBOutlet weak var hourCountLabel: UILabel!
  @IBOutlet weak var hoursLabel: UILabel!
  @IBOutlet weak var minuteCountLabel: UILabel!
  @IBOutlet weak var minutesLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var rootStackView: UIStackView!
  @IBOutlet weak var rootView: UIView!
  @IBOutlet weak var secondCountLabel: UILabel!
  @IBOutlet weak var secondsLabel: UILabel!
  @IBOutlet weak var watchButton: UIButton!


  internal func configureWith(value: LiveStreamEvent) {
    self.viewModel.inputs.configureWith(liveStreamEvent: value)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins .~ .init(topBottom: Styles.grid(4), leftRight: Styles.grid(2))

    _ = self.backgroundImageView
      |> UIImageView.lens.contentHuggingPriorityForAxis(.horizontal) .~ UILayoutPriorityDefaultHigh
      |> UIImageView.lens.contentHuggingPriorityForAxis(.vertical) .~ UILayoutPriorityDefaultHigh
      |> UIImageView.lens.contentCompressionResistancePriorityForAxis(.horizontal) .~ UILayoutPriorityDefaultLow
      |> UIImageView.lens.contentCompressionResistancePriorityForAxis(.vertical) .~ UILayoutPriorityDefaultLow

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

    _ = self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(4)

    _ = self.rootView
      |> dropShadowStyle()
      |> roundedStyle()
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(8), leftRight: Styles.grid(3))

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

    self.backgroundImageView.rac.imageUrl = self.viewModel.outputs.backgroundImageUrl
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
