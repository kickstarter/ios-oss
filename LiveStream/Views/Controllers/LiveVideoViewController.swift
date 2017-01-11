import ReactiveExtensions
import OpenTok

public protocol LiveVideoViewControllerDelegate: class {
  func liveVideoViewControllerPlaybackStateChanged(controller: LiveVideoViewController,
                                                   state: LiveVideoPlaybackState)
}

public final class LiveVideoViewController: UIViewController {
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
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    self.bindVM()

    self.view.backgroundColor = .black
    self.view.addSubview(self.videoGridView)

    self.viewModel.inputs.viewDidLoad()
  }

  public func bindVM() {
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
  }

  private func configureHLSPlayer(streamUrl: String) {
    guard let url = URL(string: streamUrl) else { return }

    let player = HLSPlayerView(hlsStreamUrl: url, delegate: self)

    self.addVideoView(view: player)
  }

  private func createAndConfigureSession(sessionConfig: OpenTokSessionConfig) {
    self.session = OTSession(
      apiKey: sessionConfig.apiKey, sessionId: sessionConfig.sessionId, delegate: self
    )
    self.session?.connect(withToken: sessionConfig.token, error: nil)
  }

  private func addAndConfigureSubscriber(stream: OTStream) {
    // FIXME: for some reason this IUO initializer is causing problems, maybe opentok 2.10 addresses this
    guard let subscriber = OTSubscriber(stream: stream, delegate: nil) else { return }

    self.session?.subscribe(subscriber, error: nil)
    self.subscribers.append(subscriber)

    self.addVideoView(view: subscriber.view)
  }

  private func addVideoView(view: UIView) {
    self.videoGridView.addVideoView(view: view)
  }

  private func removeVideoView(view: UIView) {
    self.videoGridView.removeVideoView(view: view)
  }

  private func removeSubscriberForStream(stream: OTStream) {
    self.subscribers.filter({ $0.stream.streamId == stream.streamId })
      .first
      .doIfSome(self.removeSubscriber(subscriber:))
  }

  private func removeSubscriber(subscriber: OTSubscriber) {
    self.removeVideoView(view: subscriber.view)
    self.session?.unsubscribe(subscriber, error: nil)
    self.subscribers.index(of: subscriber).doIfSome { self.subscribers.remove(at: $0) }
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

  public func sessionDidConnect(_ session: OTSession!) {
    self.viewModel.inputs.sessionDidConnect()
  }

  public func sessionDidDisconnect(_ session: OTSession!) {}

  public func session(_ session: OTSession!, streamCreated stream: OTStream!) {
    self.viewModel.inputs.sessionStreamCreated(stream: stream)
  }

  public func session(_ session: OTSession!, streamDestroyed stream: OTStream!) {
    self.viewModel.inputs.sessionStreamDestroyed(stream: stream)
  }

  public func session(_ session: OTSession!, didFailWithError error: OTError!) {
    self.viewModel.inputs.sessionDidFailWithError(error: error)
  }
}
