import ReactiveExtensions
import Library
import LiveStream
import OpenTok
import AVFoundation
import AVKit

private let statusKeyPath = "status"

public protocol LiveVideoViewControllerDelegate: class {
  func liveVideoViewControllerPlaybackStateChanged(controller: LiveVideoViewController?,
                                                   state: LiveVideoPlaybackState)
}

public final class LiveVideoViewController: UIViewController {
  private var playerController: AVPlayerViewController?
  fileprivate let viewModel: LiveVideoViewModelType = LiveVideoViewModel()
  private var session: OTSession?
  private var subscribers: [OTSubscriber] = []
  public weak var delegate: LiveVideoViewControllerDelegate?

  public required init(liveStreamType: LiveStreamType, delegate: LiveVideoViewControllerDelegate? = nil) {
    super.init(nibName: nil, bundle: nil)

    self.delegate = delegate
    self.viewModel.inputs.configureWith(liveStreamType: liveStreamType)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    self.session?.disconnect(nil)
    self.session = nil
    self.subscribers.forEach(self.removeSubscriber(subscriber:))
    self.playerController?.player?.currentItem?.removeObserver(self, forKeyPath: statusKeyPath)
    self.playerController?.player?.replaceCurrentItem(with: nil)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .ksr_grey_900
    self.view.addSubview(self.videoGridView)

    NotificationCenter.default.addObserver(forName: .UIApplicationDidEnterBackground,
                                           object: nil, queue: nil) { [weak self] _ in
      self?.viewModel.inputs.didEnterBackground()
    }

    NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground,
                                           object: nil, queue: nil) { [weak self] _ in
      self?.viewModel.inputs.willEnterForeground()
    }

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    self.viewModel.inputs.viewDidDisappear()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.videoGridView.frame = self.view.bounds
  }

  //swiftlint:disable:next function_body_length
  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.addAndConfigureHLSPlayerWithStreamUrl
      .observeForUI()
      .observeValues { [weak self] in
        self?.configureHLSPlayer(streamUrl: $0)
    }

    self.viewModel.outputs.createAndConfigureSessionWithConfig
      .observeForUI()
      .observeValues { [weak self] in
        self?.createAndConfigureSession(sessionConfig: $0)
    }

    self.viewModel.outputs.addAndConfigureSubscriber
      .observeForUI()
      .observeValues { [weak self] in
        guard let stream = $0 as? OTStream else { return }
        self?.addAndConfigureSubscriber(stream: stream)
    }

    self.viewModel.outputs.removeSubscriber
      .observeForUI()
      .observeValues { [weak self] in
        guard let stream = $0 as? OTStream else { return }
        self?.removeSubscriberForStream(stream: stream)
    }

    self.viewModel.outputs.notifyDelegateOfPlaybackStateChange
      .observeValues { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.liveVideoViewControllerPlaybackStateChanged(controller: _self, state: $0)
    }

    self.viewModel.outputs.unsubscribeAllSubscribersFromSession
      .observeForUI()
      .observeValues { [weak self] in
        self?.subscribers.forEach { subscriber in
          self?.session?.unsubscribe(subscriber, error: nil)
        }
    }

    self.viewModel.outputs.resubscribeAllSubscribersToSession
      .observeForUI()
      .observeValues { [weak self] in
        self?.subscribers.forEach { subscriber in
          self?.session?.subscribe(subscriber, error: nil)
        }
    }

    self.viewModel.outputs.shouldPauseHlsPlayer
      .observeForUI()
      .observeValues { [weak self] pause in
        if pause {
          self?.playerController?.player?.pause()
        } else {
          self?.playerController?.player?.play()
        }
    }
  }

  private func configureHLSPlayer(streamUrl: String) {
    guard let url = URL(string: streamUrl) else { return }

    // Required for audio to play even if phone is set to silent
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
    } catch {}

    let player = AVPlayer(url: url)
    let controller = AVPlayerViewController()
    controller.player = player
    controller.videoGravity = AVLayerVideoGravityResizeAspectFill

    player.currentItem?.addObserver(self, forKeyPath: statusKeyPath, options: .new, context: nil)

    self.addVideoView(view: controller.view)
    self.addChildViewController(controller)
    controller.didMove(toParentViewController: self)

    controller.player?.play()

    self.playerController = controller
  }

  public override func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey : Any]?,
                                    context: UnsafeMutableRawPointer?) {
    guard let status = self.playerController?.player?.currentItem?.status else { return }

    if keyPath == statusKeyPath {
      self.viewModel.inputs.hlsPlayerStateChanged(state: status)
    }
  }

  private func createAndConfigureSession(sessionConfig: OpenTokSessionConfig) {
    let settings = OTSessionSettings()
    settings.connectionEventsSuppressed = true

    self.session = OTSession(
      apiKey: sessionConfig.apiKey, sessionId: sessionConfig.sessionId, delegate: self, settings: settings
    )
    self.session?.connect(withToken: sessionConfig.token, error: nil)
  }

  private func addAndConfigureSubscriber(stream: OTStream) {
    guard let subscriber = OTSubscriber(stream: stream, delegate: self),
      let subscriberView = subscriber.view
      else { return }

    self.session?.subscribe(subscriber, error: nil)
    self.subscribers.append(subscriber)

    self.addVideoView(view: subscriberView)
  }

  private func addVideoView(view: UIView) {
    self.videoGridView.addVideoView(view: view)
  }

  private func removeVideoView(view: UIView) {
    self.videoGridView.removeVideoView(view: view)
  }

  private func removeSubscriberForStream(stream: OTStream) {
    self.subscribers.filter({ $0.stream?.streamId == stream.streamId })
      .first
      .doIfSome(self.removeSubscriber(subscriber:))
  }

  private func removeSubscriber(subscriber: OTSubscriber) {
    subscriber.delegate = nil
    subscriber.view.doIfSome { self.removeVideoView(view: $0) }
    self.session?.unsubscribe(subscriber, error: nil)
    self.subscribers.index(of: subscriber).doIfSome { self.subscribers.remove(at: $0) }
  }

  private lazy var videoGridView: VideoGridView = {
    let videoGridView = VideoGridView()
    return videoGridView
  }()
}

extension OTStream: OTStreamType {}
extension OTError: OTErrorType {}
extension OTSubscriberVideoEventReason: OTSubscriberVideoEventReasonType {
  public var isQualityChangedReason: Bool {
    switch self {
    case .qualityChanged:
      return true
    case .publisherPropertyChanged,
         .subscriberPropertyChanged:
      return false
    }
  }
}

extension LiveVideoViewController: OTSessionDelegate {
  public func sessionDidConnect(_ session: OTSession) {
    self.viewModel.inputs.sessionDidConnect()
  }

  public func sessionDidDisconnect(_ session: OTSession) {}

  public func session(_ session: OTSession, streamCreated stream: OTStream) {
    self.viewModel.inputs.sessionStreamCreated(stream: stream)
  }

  public func session(_ session: OTSession, streamDestroyed stream: OTStream) {
    self.viewModel.inputs.sessionStreamDestroyed(stream: stream)
  }

  public func session(_ session: OTSession, didFailWithError error: OTError) {
    self.viewModel.inputs.sessionDidFailWithError(error: error)
  }
}

extension LiveVideoViewController: OTSubscriberDelegate {
  public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {}

  public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {}

  public func subscriberVideoDisabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
    self.viewModel.inputs.subscriberVideoDisabled(reason: reason)
  }

  public func subscriberVideoEnabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
    self.viewModel.inputs.subscriberVideoEnabled(reason: reason)
  }

  public func subscriberVideoDataReceived(_ subscriber: OTSubscriber) {}
}
