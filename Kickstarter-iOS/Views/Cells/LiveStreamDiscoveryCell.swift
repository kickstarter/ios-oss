import Library
import LiveStream
import Prelude

import ReactiveSwift
import Result

public protocol LiveStreamDiscoveryCellViewModelInputs {
  func configureWith(liveStreamEvent: LiveStreamEvent)
}

public protocol LiveStreamDiscoveryCellViewModelOutputs {
  var backgroundImageUrl: Signal<URL?, NoError> { get }
  var countdownStackViewHidden: Signal<Bool, NoError> { get }
  var creatorImageUrl: Signal<URL?, NoError> { get }
  var creatorLabelText: Signal<String, NoError> { get }
  var dateLabelText: Signal<String, NoError> { get }
  var dayCountLabelText: Signal<String, NoError> { get }
  var hourCountLabelText: Signal<String, NoError> { get }
  var minuteCountLabelText: Signal<String, NoError> { get }
  var nameLabelText: Signal<String, NoError> { get }
  var secondCountLabelText: Signal<String, NoError> { get }
  var watchButtonHidden: Signal<Bool, NoError> { get }
}

public protocol LiveStreamDiscoveryCellViewModelType {
  var inputs: LiveStreamDiscoveryCellViewModelInputs { get }
  var outputs: LiveStreamDiscoveryCellViewModelOutputs { get }
}

public final class LiveStreamDiscoveryCellViewModel: LiveStreamDiscoveryCellViewModelType, LiveStreamDiscoveryCellViewModelInputs, LiveStreamDiscoveryCellViewModelOutputs {

  public init() {
    let liveStreamEvent = self.liveStreamEventProperty.signal.skipNil()

    self.backgroundImageUrl = liveStreamEvent
      .map { URL(string: $0.backgroundImageUrl) }

    self.countdownStackViewHidden = liveStreamEvent
      .map { $0.liveNow || $0.hasReplay }

    self.creatorLabelText = liveStreamEvent
      .map { Strings.project_creator_by_creator(creator_name: $0.creator.name) }

    self.creatorImageUrl = liveStreamEvent
      .map { URL(string: $0.creator.avatar) }

    self.dateLabelText = liveStreamEvent
      .map { event in
        localizedString(
          key: "",
          defaultValue: "Live stream – %{date}",
          substitutions: ["date": Format.date(secondsInUTC: event.startDate.timeIntervalSince1970, dateStyle: .medium, timeStyle: .short)]
        )
    }

    self.nameLabelText = liveStreamEvent.map { $0.name }

    self.watchButtonHidden = liveStreamEvent
      .map { $0.hasReplay && !$0.liveNow }

    let countdown = liveStreamEvent
      .switchMap(countdown(forEvent:))

    self.dayCountLabelText = countdown.map { $0.day }.skipRepeats()
    self.hourCountLabelText = countdown.map { $0.hour }.skipRepeats()
    self.minuteCountLabelText = countdown.map { $0.minute }.skipRepeats()
    self.secondCountLabelText = countdown.map { $0.second }.skipRepeats()
  }

  private let liveStreamEventProperty = MutableProperty<LiveStreamEvent?>(nil)
  public func configureWith(liveStreamEvent: LiveStreamEvent) {
    self.liveStreamEventProperty.value = liveStreamEvent
  }

  public let backgroundImageUrl: Signal<URL?, NoError>
  public let countdownStackViewHidden: Signal<Bool, NoError>
  public let creatorImageUrl: Signal<URL?, NoError>
  public let creatorLabelText: Signal<String, NoError>
  public let dateLabelText: Signal<String, NoError>
  public let dayCountLabelText: Signal<String, NoError>
  public let hourCountLabelText: Signal<String, NoError>
  public let minuteCountLabelText: Signal<String, NoError>
  public let nameLabelText: Signal<String, NoError>
  public let secondCountLabelText: Signal<String, NoError>
  public let watchButtonHidden: Signal<Bool, NoError>

  public var inputs: LiveStreamDiscoveryCellViewModelInputs { return self }
  public var outputs: LiveStreamDiscoveryCellViewModelOutputs { return self }
}



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
      |> UIImageView.lens.contentHuggingPriorityForAxis(.horizontal) .~ UILayoutPriorityDefaultLow
      |> UIImageView.lens.contentHuggingPriorityForAxis(.vertical) .~ UILayoutPriorityDefaultLow
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

private func countdown(forEvent event: LiveStreamEvent)
  -> SignalProducer<(day: String, hour: String, minute: String, second: String), NoError> {

    return timer(interval: .seconds(1), on: AppEnvironment.current.scheduler)
      .prefix(value: AppEnvironment.current.scheduler.currentDate)
      .map { currentDate -> DateComponents in
        AppEnvironment.current.calendar.dateComponents([.day, .hour, .minute, .second],
                                                       from: currentDate,
                                                       to: event.startDate)
      }
      .map { components -> (day: String, hour: String, minute: String, second: String) in
        (
          day: String(format: "%02d", max(0, components.day ?? 0)),
          hour: String(format: "%02d", max(0, components.hour ?? 0)),
          minute: String(format: "%02d", max(0, components.minute ?? 0)),
          second: String(format: "%02d", max(0, components.second ?? 0))
        )
    }
}
