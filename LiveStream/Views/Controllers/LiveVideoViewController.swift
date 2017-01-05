import ReactiveExtensions
import OpenTok

public protocol LiveVideoViewControllerDelegate: class {
  func playbackStateChanged(controller: LiveVideoViewController, state: LiveVideoPlaybackState)
}

public final class LiveVideoViewController: UIViewController {
  private let viewModel: LiveVideoViewModelType = LiveVideoViewModel()
  private var session: OTSession!
  private var subscribers: [OTSubscriber] = []
  public weak var delegate: LiveVideoViewControllerDelegate?

  public required init(liveStreamType: LiveStreamType, delegate: LiveVideoViewControllerDelegate? = nil) {
    super.init(nibName: nil, bundle: nil)

    self.delegate = delegate
    self.bindVM()
    switch liveStreamType {
    case .hlsStream(let hlsStreamUrl):
      self.viewModel.inputs.configureWith(hlsStreamUrl: hlsStreamUrl)
    case .openTok(let sessionConfig):
      self.viewModel.inputs.configureWith(sessionConfig: sessionConfig)
    }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func destroy() {
    let subscribers = self.subscribers
    subscribers.forEach {
      self.removeSubscriber(subscriber: $0)
    }
    if !subscribers.isEmpty { self.session.disconnect(nil) }
    self.videoGridView.destroy()
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .blackColor()
    self.view.addSubview(self.videoGridView)

    self.viewModel.inputs.viewDidLoad()
  }

  //swiftlint:disable function_body_length
  public func bindVM() {
    self.viewModel.outputs.addAndConfigureHLSPlayerWithStreamUrl
      .observeForUI()
      .observeNext { [weak self] in
      self?.configureHLSPlayer(streamUrl: $0)
    }

    self.viewModel.outputs.createAndConfigureSessionWithConfig
      .observeNext { [weak self] in
        self?.createAndConfigureSession(sessionConfig: $0)
    }

    self.viewModel.outputs.addAndConfigureSubscriber
      .observeForUI()
      .observeNext { [weak self] in
        guard let stream = $0 as? OTStream else { return }
        self?.addAndConfigureSubscriber(stream: stream)
    }

    self.viewModel.outputs.removeSubscriber
      .observeForUI()
      .observeNext { [weak self] in
        guard let stream = $0 as? OTStream else { return }
        self?.removeSubscriberForStream(stream: stream)
    }

    self.viewModel.outputs.playbackState.observeNext { [weak self] in
      guard let _self = self else { return }
      self?.delegate?.playbackStateChanged(_self, state: $0)
    }
  }
  //swiftlint:enable function_body_length

  private func configureHLSPlayer(streamUrl streamUrl: String) {
    guard let url = NSURL(string: streamUrl) else { return }

    let player = HLSPlayerView(hlsStreamUrl: url, delegate: self)

    self.addVideoView(player)
  }

  private func createAndConfigureSession(sessionConfig sessionConfig: OpenTokSessionConfig) {
    self.session = OTSession(
      apiKey: sessionConfig.apiKey, sessionId: sessionConfig.sessionId, delegate: self
    )
    self.session.connectWithToken(sessionConfig.token, error: nil)
  }

  private func addAndConfigureSubscriber(stream stream: OTStream) {
    let subscriber = OTSubscriber(stream: stream, delegate: nil)
    self.session.subscribe(subscriber, error: nil)
    self.subscribers.append(subscriber)

    self.addVideoView(subscriber.view)
  }

  private func addVideoView(view: UIView) {
    self.videoGridView.addVideoView(view)
  }

  private func removeVideoView(view: UIView) {
    self.videoGridView.removeVideoView(view)
  }

  private func removeSubscriberForStream(stream stream: OTStream) {
    guard let subscriber = self.subscribers.filter({ $0.stream.streamId == stream.streamId }).first
      else { return }

    self.removeSubscriber(subscriber: subscriber)
  }

  private func removeSubscriber(subscriber subscriber: OTSubscriber) {
    self.removeVideoView(subscriber.view)
    self.session.unsubscribe(subscriber, error: nil)
    _ = self.subscribers.indexOf(subscriber).flatMap { self.subscribers.removeAtIndex($0) }
  }

  // MARK: Actions

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.videoGridView.frame = self.view.bounds
  }

  private lazy var videoGridView: VideoGridView = {
    let videoGridView = VideoGridView()
    return videoGridView
  }()
}

extension LiveVideoViewController: HLSPlayerViewDelegate {
  func playbackStatedChanged(playerView: HLSPlayerView, state: AVPlayerItemStatus) {
    self.viewModel.inputs.hlsPlayerStateChanged(state: state)
  }
}

extension LiveVideoViewController: OTSessionDelegate {

  public func sessionDidConnect(session: OTSession!) {
    self.viewModel.inputs.sessionDidConnect()
  }

  public func sessionDidReconnect(session: OTSession!) {}

  public func sessionDidDisconnect(session: OTSession!) {}

  public func sessionDidBeginReconnecting(session: OTSession!) {}

  public func session(session: OTSession!, streamCreated stream: OTStream!) {
    self.viewModel.inputs.sessionStreamCreated(stream: stream)
  }

  public func session(session: OTSession!, streamDestroyed stream: OTStream!) {
    self.viewModel.inputs.sessionStreamDestroyed(stream: stream)
  }

  public func session(session: OTSession!, didFailWithError error: OTError!) {
    self.viewModel.inputs.sessionDidFailWithError(error: error)
  }

  public func session(session: OTSession!, archiveStoppedWithId archiveId: String!) {}

  public func session(session: OTSession!, connectionCreated connection: OTConnection!) {}

  public func session(session: OTSession!, connectionDestroyed connection: OTConnection!) {}

  public func session(session: OTSession!, archiveStartedWithId archiveId: String!, name: String!) {}

  public func session(session: OTSession!, receivedSignalType type: String!,
                      fromConnection connection: OTConnection!, withString string: String!) {}
}
