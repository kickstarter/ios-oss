import ReactiveExtensions
import OpenTok

public protocol LiveVideoViewControllerDelegate: class {
  // FIXME: prefix this with liveVideoView...
  func playbackStateChanged(controller: LiveVideoViewController, state: LiveVideoPlaybackState)
}

public final class LiveVideoViewController: UIViewController {
  private let viewModel: LiveVideoViewModelType = LiveVideoViewModel()
  private weak var session: OTSession?
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

  // FIXME: we may be able to move this to deinit
  public func destroy() {
    self.session?.disconnect(nil)
    self.subscribers.forEach(self.removeSubscriber(subscriber:))
    self.videoGridView.destroy()
  }

  deinit {
    // FIXME: check for retain cycle
    print("did this get called?")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    self.bindVM()

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
      .observeForUI()
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

    self.viewModel.outputs.notifyDelegateOfPlaybackStateChange
      .observeNext { [weak self] in
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
    self.session?.connectWithToken(sessionConfig.token, error: nil)
  }

  private func addAndConfigureSubscriber(stream stream: OTStream) {
    let subscriber = OTSubscriber(stream: stream, delegate: nil)

    // FIXME: possibly a retain cycle with subscribers > subscriber > view > videoGrid

    self.session?.subscribe(subscriber, error: nil)
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
    self.subscribers.filter({ $0.stream.streamId == stream.streamId })
      .first
      .doIfSome(self.removeSubscriber(subscriber:))
  }

  private func removeSubscriber(subscriber subscriber: OTSubscriber) {
    self.removeVideoView(subscriber.view)
    self.session?.unsubscribe(subscriber, error: nil)
    self.subscribers.indexOf(subscriber).doIfSome { self.subscribers.removeAtIndex($0) }
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

  public func sessionDidDisconnect(session: OTSession!) {}

  public func session(session: OTSession!, streamCreated stream: OTStream!) {
    self.viewModel.inputs.sessionStreamCreated(stream: stream)
  }

  public func session(session: OTSession!, streamDestroyed stream: OTStream!) {
    self.viewModel.inputs.sessionStreamDestroyed(stream: stream)
  }

  public func session(session: OTSession!, didFailWithError error: OTError!) {
    self.viewModel.inputs.sessionDidFailWithError(error: error)
  }
}
