import AVFoundation
import AVKit
import Library
import LiveStream
import Prelude
import UIKit

import ReactiveSwift
import Result

internal protocol LiveStreamDiscoveryLiveNowCellViewModelInputs {
  func configureWith(liveStreamEvent: LiveStreamEvent)
}

internal protocol LiveStreamDiscoveryLiveNowCellViewModelOutputs {
  var creatorImageUrl: Signal<URL?, NoError> { get }
  var creatorLabelText: Signal<String, NoError> { get }
  var playVideoUrl: Signal<URL?, NoError> { get }
  var streamTitleLabel: Signal<String, NoError> { get }
}

internal protocol LiveStreamDiscoveryLiveNowCellViewModelType {
  var inputs: LiveStreamDiscoveryLiveNowCellViewModelInputs { get }
  var outputs: LiveStreamDiscoveryLiveNowCellViewModelOutputs { get }
}

internal final class LiveStreamDiscoveryLiveNowCellViewModel: LiveStreamDiscoveryLiveNowCellViewModelType,
LiveStreamDiscoveryLiveNowCellViewModelInputs, LiveStreamDiscoveryLiveNowCellViewModelOutputs {

  internal init() {
    let liveStreamEvent = self.configData.signal.skipNil()

    self.creatorImageUrl = liveStreamEvent
      .map { URL(string: $0.creator.avatar) }

    self.playVideoUrl = liveStreamEvent
      .switchMap { event in
        AppEnvironment.current.liveStreamService.fetchEvent(eventId: event.id, uid: nil)
          .demoteErrors()
          .prefix(value: event)
          .map { $0.hlsUrl.map(URL.init(string:)) }
          .skipNil()
          .take(first: 1)
    }

    self.creatorLabelText = liveStreamEvent
      .map { Strings.Creator_name_is_live_now(creator_name: $0.creator.name) }

    self.streamTitleLabel = liveStreamEvent
      .map { $0.name }
  }

  private let configData = MutableProperty<LiveStreamEvent?>(nil)
  internal func configureWith(liveStreamEvent: LiveStreamEvent) {
    self.configData.value = liveStreamEvent
  }

  internal let creatorImageUrl: Signal<URL?, NoError>
  internal let creatorLabelText: Signal<String, NoError>
  internal let playVideoUrl: Signal<URL?, NoError>
  internal let streamTitleLabel: Signal<String, NoError>

  internal var inputs: LiveStreamDiscoveryLiveNowCellViewModelInputs { return self }
  internal var outputs: LiveStreamDiscoveryLiveNowCellViewModelOutputs { return self }
}

internal final class LiveStreamDiscoveryLiveNowCell: UITableViewCell, ValueCell {
  private let viewModel: LiveStreamDiscoveryLiveNowCellViewModelType = LiveStreamDiscoveryLiveNowCellViewModel()

  @IBOutlet weak var cardView: UIView!
  @IBOutlet weak var creatorImageView: UIImageView!
  @IBOutlet weak var creatorLabel: UILabel!
  @IBOutlet weak var creatorStackView: UIStackView!
  @IBOutlet weak var imageOverlayView: UIView!
  @IBOutlet weak var liveContainerView: UIView!
  @IBOutlet weak var liveLabel: UILabel!
  @IBOutlet weak var streamImageView: UIImageView!
  @IBOutlet weak var streamPlayerView: AVPlayerView!
  @IBOutlet weak var streamTitleContainerView: UIView!
  @IBOutlet weak var streamTitleLabel: UILabel!

  internal func configureWith(value: LiveStreamEvent) {
    self.viewModel.inputs.configureWith(liveStreamEvent: value)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.streamPlayerView.layer.contentsGravity = AVLayerVideoGravityResizeAspectFill

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { insets, cell in
        cell.traitCollection.isVerticallyCompact
          ? .init(top: Styles.grid(2), left: insets.left * 6, bottom: Styles.grid(4), right: insets.right * 6)
          : .init(top: Styles.grid(2), left: insets.left, bottom: Styles.grid(4), right: insets.right)
    }

    _ = self.liveContainerView
      |> roundedStyle()
      |> UIView.lens.backgroundColor .~ .ksr_green_500
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.gridHalf(1), leftRight: Styles.gridHalf(3))

    _ = self.liveLabel
      |> UILabel.lens.text .~ Strings.Live()
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_title3(size: 13)
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.streamTitleContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(2), leftRight: Styles.grid(3))

    _ = self.streamTitleLabel
      |> UILabel.lens.font .~ .ksr_title3(size: 15)
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.numberOfLines .~ 0
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.creatorImageView.rac.imageUrl = self.viewModel.outputs.creatorImageUrl
    self.creatorLabel.rac.text = self.viewModel.outputs.creatorLabelText

    self.viewModel.outputs.playVideoUrl
      .observeForUI()
      .observeValues { [weak self] in self?.loadVideo(url: $0) }

    self.streamTitleLabel.rac.text = self.viewModel.outputs.streamTitleLabel
  }

  private func loadVideo(url: URL?) {
    self.streamPlayerView.alpha = 0

    self.streamPlayerView.playerLayer?.player = url
      .map(AVPlayer.init(url:))
    self.streamPlayerView.playerLayer?.player?.play()
    self.streamPlayerView.playerLayer?.player?.isMuted = true

    UIView.animate(withDuration: 0.3) {

    }
  }
}
