import AVFoundation
import AVKit
import KsApi
import Library
import Prelude
import UIKit

private let durationKeyPath = "currentItem.duration"
private let rateKeyPath = "rate"

internal protocol VideoViewControllerDelegate: class {
  func videoViewControllerDidFinish(controller: VideoViewController)
  func videoViewControllerDidStart(controller: VideoViewController)
}

internal final class VideoViewController: UIViewController {
  internal weak var delegate: VideoViewControllerDelegate?
  private let viewModel: VideoViewModelType = VideoViewModel()
  private var playerController: AVPlayerViewController!
  private var timeObserver: AnyObject?

  @IBOutlet private weak var playButton: UIButton!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var videoOverlayView: UIView!
  @IBOutlet private weak var videoContainerView: UIView!

  internal static func configuredWith(project project: Project) -> VideoViewController {
    let vc = Storyboard.Video.instantiate(VideoViewController)
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.playerController = self.childViewControllers.flatMap { $0 as? AVPlayerViewController }.first

    self.playButton.addTarget(self, action: #selector(playButtonTapped), forControlEvents: .TouchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear()
  }

  internal override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    self.viewModel.inputs.viewDidDisappear(animated: animated)
  }

  internal override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    self.viewModel.inputs.viewWillDisappear()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.playButton
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.accessibility_projects_buttons_play_video() }

    self.projectImageView
      |> UIImageView.lens.accessibilityElementsHidden .~ true

    self.videoOverlayView
      |> UIView.lens.backgroundColor .~ .blackColor()
      |> UIView.lens.alpha .~ 0.1
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.playButton.rac.hidden = self.viewModel.outputs.playButtonHidden
    self.videoContainerView.rac.hidden = self.viewModel.outputs.videoViewHidden
    self.videoOverlayView.rac.hidden = self.viewModel.outputs.playButtonHidden

    self.viewModel.outputs.addCompletionObserver
      .observeForControllerAction()
      .observeNext { [weak self] time in
        self?.addCompletionObserver(atTime: time)
    }

    self.viewModel.outputs.configurePlayerWithURL
      .observeForControllerAction()
      .observeNext { [weak self] url in
        self?.configurePlayer(withURL: url)
    }

    self.viewModel.outputs.notifyDelegateThatVideoDidFinish
      .observeForUI()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.videoViewControllerDidFinish(_self)
    }

    self.viewModel.outputs.notifyDelegateThatVideoDidStart
      .observeForUI()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.videoViewControllerDidStart(_self)
    }

    self.viewModel.outputs.pauseVideo
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.playerController.player?.pause()
    }

    self.viewModel.outputs.playVideo
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.playerController.player?.play()
    }

    self.viewModel.outputs.projectImageHidden
      .observeForControllerAction()
      .observeNext { [weak self] hidden in
        UIView.animateWithDuration(0.5) {
          self?.projectImageView.alpha = hidden ? 0 : 1
        }
    }

    self.viewModel.outputs.projectImageURL
      .observeForControllerAction()
      .on(next: { [weak self] _ in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
        })
      .ignoreNil()
      .observeNext { [weak self] url in
        self?.projectImageView.af_setImageWithURL(url)
    }

    self.viewModel.outputs.seekToBeginning
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.playerController.player?.seekToTime(kCMTimeZero)
    }
  }
  // swiftlint:enable function_body_length

  func addCompletionObserver(atTime time: CMTime) {
    guard let player = self.playerController.player else { return }

    self.timeObserver = player.addBoundaryTimeObserverForTimes(
      [NSValue(CMTime: time)],
      queue: dispatch_get_main_queue()) { [weak self] _ in
        self?.viewModel.inputs.crossedCompletionThreshold()
    }
  }

  internal func configurePlayer(withURL url: NSURL) {
    self.playerController.player = AVPlayer(URL: url)

    self.playerController.player?.addObserver(self, forKeyPath: durationKeyPath, options: .New, context: nil)

    self.playerController.player?.addObserver(self, forKeyPath: rateKeyPath, options: .New, context: nil)
  }

  internal override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                                change: [String : AnyObject]?,
                                                context: UnsafeMutablePointer<Void>) {

    guard let player = self.playerController.player else { return }

    if keyPath == rateKeyPath {
      guard let rate = change?[NSKeyValueChangeNewKey] as? Double else { return }
      guard let currentTime = player.currentItem?.currentTime() else { return }
      self.viewModel.inputs.rateChanged(toNew: rate, atTime: currentTime)

    } else if keyPath == durationKeyPath {
      guard let duration = player.currentItem?.duration else { return }
      self.viewModel.inputs.durationChanged(toNew: duration)
    }
  }

  @objc private func playButtonTapped() {
    self.viewModel.inputs.playButtonTapped()
  }

  deinit {
    if let timeObserver = self.timeObserver {
      self.playerController.player?.removeTimeObserver(timeObserver)
    }
    self.playerController.player?.removeObserver(self, forKeyPath: durationKeyPath)
    self.playerController.player?.removeObserver(self, forKeyPath: rateKeyPath)
  }
}
