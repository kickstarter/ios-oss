import AVFoundation
import AVKit
import KsApi
import Library
import Prelude
import UIKit

private let durationKeyPath = "currentItem.duration"
private let rateKeyPath = "rate"

public protocol VideoViewControllerDelegate: AnyObject {
  func videoViewControllerDidFinish(_ controller: VideoViewController)
  func videoViewControllerDidStart(_ controller: VideoViewController)
}

public final class VideoViewController: UIViewController {
  internal weak var delegate: VideoViewControllerDelegate?
  internal weak var playbackDelegate: AudioVideoViewControllerPlaybackDelegate?
  fileprivate let viewModel: VideoViewModelType = VideoViewModel()
  fileprivate var playerController: AVPlayerViewController!
  fileprivate var timeObserver: Any?

  @IBOutlet fileprivate var playButton: UIButton!
  @IBOutlet fileprivate var projectImageView: UIImageView!
  @IBOutlet fileprivate var videoContainerView: UIView!

  internal static func configuredWith(project: Project) -> VideoViewController {
    let vc = Storyboard.Video.instantiate(VideoViewController.self)
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.playerController = self.children.compactMap { $0 as? AVPlayerViewController }.first

    self.playButton.addTarget(self, action: #selector(self.playButtonTapped), for: .touchUpInside)

    self.viewModel.inputs.viewDidLoad()

    self.setupNotifications()
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear()
  }

  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    self.viewModel.inputs.viewDidDisappear(animated: animated)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.viewModel.inputs.viewWillDisappear()
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self.playButton
      |> UIButton.lens.image(for: .normal) .~ image(named: "play-arrow-icon")
      <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_white.withAlphaComponent(0.5)
      <> UIButton.lens.accessibilityLabel %~ { _ in Strings.accessibility_projects_buttons_play_video() }

    _ = self.projectImageView
      |> UIImageView.lens.accessibilityElementsHidden .~ true

    _ = self.projectImageView
      |> ignoresInvertColorsImageViewStyle
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.playButton.rac.hidden = self.viewModel.outputs.playButtonHidden
    self.videoContainerView.rac.hidden = self.viewModel.outputs.videoViewHidden

    self.viewModel.outputs.opacityForViews
      .observeForUI()
      .observeValues { [weak self] alpha in
        guard let _self = self else { return }
        UIView.animate(
          withDuration: alpha == 0.0 ? 0.0 : 0.3, delay: 0.0, options: .curveEaseOut,
          animations: {
            _self.playButton.alpha = alpha
          }, completion: nil
        )
      }

    self.viewModel.outputs.addCompletionObserver
      .observeForUI()
      .observeValues { [weak self] time in
        self?.addCompletionObserver(atTime: time)
      }

    self.viewModel.outputs.configurePlayerWithURL
      .observeForUI()
      .observeValues { [weak self] url in
        self?.configurePlayer(withURL: url)
      }

    self.viewModel.outputs.notifyDelegateThatVideoDidFinish
      .observeForUI()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.videoViewControllerDidFinish(_self)
      }

    self.viewModel.outputs.notifyDelegateThatVideoDidStart
      .observeForUI()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.videoViewControllerDidStart(_self)
      }

    self.viewModel.outputs.pauseVideo
      .observeForUI()
      .observeValues { [weak self] in
        self?.playerController.player?.pause()
      }

    self.viewModel.outputs.playVideo
      .observeForUI()
      .observeValues { [weak self] in
        self?.playerController.player?.play()
      }

    self.viewModel.outputs.projectImageHidden
      .observeForUI()
      .observeValues { [weak self] hidden in
        UIView.animate(withDuration: 0.5) {
          self?.projectImageView.alpha = hidden ? 0 : 1
        }
      }

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.projectImageView.af.cancelImageRequest()
        self?.projectImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] url in
        self?.projectImageView.ksr_setImageWithURL(url)
      }

    self.viewModel.outputs.seekToBeginning
      .observeForUI()
      .observeValues { [weak self] in
        self?.playerController.player?.seek(to: CMTime.zero)
      }
  }

  func addCompletionObserver(atTime time: CMTime) {
    guard let player = self.playerController.player else { return }

    self.timeObserver = player.addBoundaryTimeObserver(
      forTimes: [NSValue(time: time)],
      queue: DispatchQueue.main
    ) { [weak self] in
      self?.viewModel.inputs.crossedCompletionThreshold()
    }
  }

  internal func configurePlayer(withURL url: URL) {
    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])

    self.playerController.player = AVPlayer(url: url)

    self.playerController.player?.addObserver(self, forKeyPath: durationKeyPath, options: .new, context: nil)

    self.playerController.player?.addObserver(self, forKeyPath: rateKeyPath, options: .new, context: nil)
  }

  public override func observeValue(
    forKeyPath keyPath: String?, of _: Any?,
    change: [NSKeyValueChangeKey: Any]?,
    context _: UnsafeMutableRawPointer?
  ) {
    guard let player = self.playerController.player else { return }

    if keyPath == rateKeyPath {
      guard let rate = change?[NSKeyValueChangeKey.newKey] as? Double else { return }
      guard let currentTime = player.currentItem?.currentTime() else { return }
      self.viewModel.inputs.rateChanged(toNew: rate, atTime: currentTime)

    } else if keyPath == durationKeyPath {
      guard let duration = player.currentItem?.duration else { return }
      self.viewModel.inputs.durationChanged(toNew: duration)
    }
  }

  @objc fileprivate func playButtonTapped() {
    self.viewModel.inputs.playButtonTapped()
  }

  deinit {
    if let timeObserver = self.timeObserver {
      self.playerController.player?.removeTimeObserver(timeObserver)
    }
    self.playerController.player?.removeObserver(self, forKeyPath: durationKeyPath)
    self.playerController.player?.removeObserver(self, forKeyPath: rateKeyPath)
    self.playerController?.player?.replaceCurrentItem(with: nil)
  }

  private func setupNotifications() {
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(self.pauseVideo),
        name: .ksr_applicationDidEnterBackground,
        object: nil
      )
  }

  @objc private func pauseVideo() {
    self.viewModel.inputs.viewWillDisappear()
  }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
  return input.rawValue
}

extension VideoViewController: AudioVideoViewControllerPlaybackDelegate {
  func pauseAudioVideoPlayback() {
    if self.playerController.player?.timeControlStatus == .playing {
      self.playerController.player?.pause()
    }
  }
}
