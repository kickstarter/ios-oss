import Argo
import Prelude
import ReactiveSwift
import Result
import UIKit

public protocol LiveStreamViewControllerDelegate: class {
  func liveStreamViewController(_ controller: LiveStreamViewController?,
                                stateChangedTo state: LiveStreamViewControllerState)

  func liveStreamViewController(_ controller: LiveStreamViewController?,
                                numberOfPeopleWatchingChangedTo numberOfPeople: Int)

  func liveStreamViewController(_ controller: LiveStreamViewController?,
                                didReceiveLiveStreamApiError error: LiveApiError)
}

public final class LiveStreamViewController: UIViewController {
  fileprivate var viewModel: LiveStreamViewModelType
  private var videoViewController: LiveVideoViewController?
  private weak var delegate: LiveStreamViewControllerDelegate?
  private var liveStreamService: LiveStreamServiceProtocol?

  public init(liveStreamService: LiveStreamServiceProtocol) {

    liveStreamService.setup()

    self.viewModel = LiveStreamViewModel(liveStreamService: liveStreamService)

    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configureWith(liveStreamEvent: LiveStreamEvent,
                            delegate: LiveStreamViewControllerDelegate,
                            liveStreamService: LiveStreamServiceProtocol) {
    self.delegate = delegate
    self.liveStreamService = liveStreamService
    self.viewModel.inputs.configureWith(liveStreamEvent: liveStreamEvent)
  }

  //swiftlint:disable:next function_body_length
  public func bindVM() {
    self.viewModel.outputs.createVideoViewController
      .observeForUI()
      .observeValues { [weak self] in
        self?.createVideoViewController(liveStreamType: $0)
    }

    self.viewModel.outputs.removeVideoViewController
      .observeForUI()
      .observeValues { [weak self] in
        self?.videoViewController?.removeFromParentViewController()
        self?.videoViewController = nil
    }

    self.viewModel.outputs.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged
      .observeValues { [weak self] number in
        self.doIfSome {
          $0.delegate?.liveStreamViewController($0, numberOfPeopleWatchingChangedTo: number)
        }
    }

    self.viewModel.outputs.notifyDelegateLiveStreamViewControllerStateChanged
      .observeValues { [weak self] state in
        self.doIfSome {
          $0.delegate?.liveStreamViewController($0, stateChangedTo: state)
        }
    }

    self.viewModel.outputs.notifyDelegateLiveStreamApiErrorOccurred
      .observeValues { [weak self] error in
        self.doIfSome {
          $0.delegate?.liveStreamViewController($0, didReceiveLiveStreamApiError: error)
        }
    }

    self.viewModel.outputs.disableIdleTimer
      .observeForUI()
      .observeValues {
        UIApplication.shared.isIdleTimerDisabled = $0
    }
  }

  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    self.viewModel.inputs.viewDidDisappear()
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .black

    self.bindVM()
    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    guard let videoView = self.videoViewController?.view else { return }

    self.layoutVideoView(view: videoView)
  }

  public func userSessionChanged(session: LiveStreamSession) {
    self.viewModel.inputs.userSessionChanged(session: session)
  }

  // MARK: Video

  private func addChildVideoViewController(controller: UIViewController) {
    self.addChildViewController(controller)
    controller.didMove(toParentViewController: self)
    self.view.addSubview(controller.view)
  }

  private func layoutVideoView(view: UIView) {
    view.frame = self.view.bounds
  }

  private func createVideoViewController(liveStreamType: LiveStreamType) {
    let videoViewController = LiveVideoViewController(liveStreamType: liveStreamType, delegate: self)

    self.videoViewController?.removeFromParentViewController()
    self.videoViewController = videoViewController
    self.addChildVideoViewController(controller: videoViewController)
  }
}

extension LiveStreamViewController: LiveVideoViewControllerDelegate {
  public func liveVideoViewControllerPlaybackStateChanged(controller: LiveVideoViewController,
                                                          state: LiveVideoPlaybackState) {
    self.viewModel.inputs.videoPlaybackStateChanged(state: state)
  }
}
