import Library
import LiveStream
import Prelude
import UIKit

import ReactiveSwift
import Result

internal protocol LiveStreamDiscoveryUpcomingCellViewModelInputs {
  func configureWith(liveStreamEvent: LiveStreamEvent)
}

internal protocol LiveStreamDiscoveryUpcomingCellViewModelOutputs {
  var creatorImageUrl: Signal<URL?, NoError> { get }
  var creatorLabelText: Signal<String, NoError> { get }
  var dateContainerViewHidden: Signal<Bool, NoError> { get }
  var dateLabelText: Signal<String, NoError> { get }
  var imageOverlayColor: Signal<UIColor, NoError> { get }
  var replayButtonHidden: Signal<Bool, NoError> { get }
  var streamAvailabilityLabelHidden: Signal<Bool, NoError> { get }
  var streamAvailabilityLabelText: Signal<String, NoError> { get }
  var streamImageUrl: Signal<URL?, NoError> { get }
  var streamTitleLabelText: Signal<String, NoError> { get }
}

internal protocol LiveStreamDiscoveryUpcomingCellViewModelType {
  var inputs: LiveStreamDiscoveryUpcomingCellViewModelInputs { get }
  var outputs: LiveStreamDiscoveryUpcomingCellViewModelOutputs { get }
}

internal final class LiveStreamDiscoveryUpcomingCellViewModel: LiveStreamDiscoveryUpcomingCellViewModelType, LiveStreamDiscoveryUpcomingCellViewModelInputs, LiveStreamDiscoveryUpcomingCellViewModelOutputs {

  internal init() {
    let liveStreamEvent = self.configData.signal.skipNil()

    self.creatorImageUrl = liveStreamEvent
      .map { URL(string: $0.creator.avatar) }

    self.streamImageUrl = liveStreamEvent
      .map { URL(string: $0.backgroundImage.smallCropped) }

    self.streamTitleLabelText = liveStreamEvent
      .map { $0.name }

    self.imageOverlayColor = liveStreamEvent
      .map {
        $0.hasReplay == .some(true)
          ? UIColor.hex(0x353535)
          : UIColor.ksr_navy_900
    }

    self.creatorLabelText = liveStreamEvent
      .map {
        $0.hasReplay == .some(true)
          ? localizedString(key: "Replay_live_stream_with_creator_name",
                            defaultValue: "Replay live stream with<br><b>%{creator_name}</b>",
                            substitutions: ["creator_name": $0.creator.name])
          : Strings.Upcoming_with_creator_name(creator_name: $0.creator.name)
    }

    self.dateLabelText = liveStreamEvent
      .map { formattedDateString(date: $0.startDate) }

    self.replayButtonHidden = liveStreamEvent
      .map { $0.hasReplay != .some(true) }

    self.streamAvailabilityLabelText = liveStreamEvent
      .map(availabilityText(forLiveStreamEvent:))

    self.streamAvailabilityLabelHidden = self.replayButtonHidden

    self.dateContainerViewHidden = self.replayButtonHidden.map(negate)
  }

  private let configData = MutableProperty<LiveStreamEvent?>(nil)
  internal func configureWith(liveStreamEvent: LiveStreamEvent) {
    self.configData.value = liveStreamEvent
  }

  internal let creatorImageUrl: Signal<URL?, NoError>
  internal let creatorLabelText: Signal<String, NoError>
  internal let dateContainerViewHidden: Signal<Bool, NoError>
  internal let dateLabelText: Signal<String, NoError>
  internal let imageOverlayColor: Signal<UIColor, NoError>
  internal let replayButtonHidden: Signal<Bool, NoError>
  internal let streamAvailabilityLabelHidden: Signal<Bool, NoError>
  internal let streamAvailabilityLabelText: Signal<String, NoError>
  internal let streamImageUrl: Signal<URL?, NoError>
  internal let streamTitleLabelText: Signal<String, NoError>

  internal var inputs: LiveStreamDiscoveryUpcomingCellViewModelInputs { return self }
  internal var outputs: LiveStreamDiscoveryUpcomingCellViewModelOutputs { return self }
}

private func availabilityText(forLiveStreamEvent event: LiveStreamEvent) -> String {
  guard let availableDate = AppEnvironment.current.calendar
    .date(byAdding: .day, value: 2, to: event.startDate)?.timeIntervalSince1970
    else { return "" }

  let (time, units) = Format.duration(secondsInUTC: availableDate, abbreviate: false)

  return Strings.Available_to_watch_for_time_more_units(time: time, units: units)
}

private func formattedDateString(date: Date) -> String {

  let format = DateFormatter.dateFormat(fromTemplate: "dMMMhmzzz",
                                        options: 0,
                                        locale: AppEnvironment.current.locale) ?? "MMM d, h:mm a zzz"

  return Format.date(secondsInUTC: date.timeIntervalSince1970, dateFormat: format)
}



//=====================================



internal final class LiveStreamDiscoveryUpcomingCell: UITableViewCell, ValueCell {
  private let viewModel: LiveStreamDiscoveryUpcomingCellViewModelType = LiveStreamDiscoveryUpcomingCellViewModel()

  @IBOutlet weak var cardView: UIView!
  @IBOutlet weak var creatorImageView: CircleAvatarImageView!
  @IBOutlet weak var creatorLabel: SimpleHTMLLabel!
  @IBOutlet weak var infoStackView: UIStackView!
  @IBOutlet weak var dateContainerView: UIView!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var imageOverlayView: UIView!
  @IBOutlet weak var replayButton: UIButton!
  @IBOutlet weak var streamAvailabilityLabel: UILabel!
  @IBOutlet weak var streamImageView: UIImageView!
  @IBOutlet weak var streamTitleContainerView: UIView!
  @IBOutlet weak var streamTitleLabel: UILabel!

  internal func configureWith(value: LiveStreamEvent) {
    self.viewModel.inputs.configureWith(liveStreamEvent: value)
  }

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

    _ = self.imageOverlayView
      |> UIView.lens.alpha .~ 0.9

    _ = self.dateContainerView
      |> roundedStyle()
      |> UIView.lens.backgroundColor .~ UIColor.white.withAlphaComponent(0.9)
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.gridHalf(3), leftRight: Styles.grid(3))

    _ = self.dateLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_900
      |> UILabel.lens.font .~ .ksr_title3(size: 16)

    _ = self.streamTitleContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(2), leftRight: Styles.grid(3))

    _ = self.streamTitleLabel
      |> UILabel.lens.font .~ .ksr_title3(size: 15)
      |> UILabel.lens.textColor .~ .ksr_text_navy_900
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.replayButton
      |> UIButton.lens.enabled .~ false
      |> UIButton.lens.backgroundColor .~ UIColor.white.withAlphaComponent(0.8)
      |> UIButton.lens.titleColor(forState: .normal) .~ .ksr_text_navy_900
      |> UIButton.lens.title(forState: .normal) .~ Strings.Replay()
      |> UIButton.lens.titleLabel.font .~ .ksr_title3(size: 16)
      |> UIButton.lens.adjustsImageWhenDisabled .~ false
      |> UIButton.lens.image(forState: .normal) .~ Library.image(named: "replay-icon", tintColor: .ksr_text_navy_900)
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
