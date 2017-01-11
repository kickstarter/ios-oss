import Argo
import FirebaseAnalytics
import FirebaseDatabase
import Prelude
import ReactiveSwift
import Result
import UIKit

public protocol LiveStreamViewControllerDelegate: class {
  func liveStreamViewControllerStateChanged(controller: LiveStreamViewController,
                                            state: LiveStreamViewControllerState)

  func liveStreamViewControllerNumberOfPeopleWatchingChanged(controller: LiveStreamViewController,
                                                             numberOfPeople: Int)
}

public final class LiveStreamViewController: UIViewController {
  fileprivate var viewModel: LiveStreamViewModelType = LiveStreamViewModel()
  private var firebaseRef: FIRDatabaseReference?
  private var videoViewController: LiveVideoViewController?
  public weak var delegate: LiveStreamViewControllerDelegate?

  public init(event: LiveStreamEvent, delegate: LiveStreamViewControllerDelegate) {
    super.init(nibName: nil, bundle: nil)

    self.delegate = delegate
    self.bindVM()

    guard let app = KsLiveApp.firebaseApp() else {
      self.viewModel.inputs.firebaseAppFailedToInitialize()
      return
    }
    let databaseRef = FIRDatabase.database(app: app).reference()

    self.viewModel.inputs.configureWith(databaseRef: databaseRef, event: event)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .landscape]
  }

  //swiftlint:disable function_body_length
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
      .observeValues { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.liveStreamViewControllerNumberOfPeopleWatchingChanged(controller: _self,
                                                                              numberOfPeople: $0)
    }

    self.viewModel.outputs.createGreenRoomObservers
      .map(prepare(databaseReference:config:))
      .skipNil()
      .observeValues { [weak self] in self?.createFirebaseGreenRoomObservers(ref: $0, refConfig: $1) }

    self.viewModel.outputs.createHLSObservers
      .map(prepare(databaseReference:config:))
      .skipNil()
      .observeValues { [weak self] in self?.createFirebaseHLSObservers(ref: $0, refConfig: $1) }

    self.viewModel.outputs.createNumberOfPeopleWatchingObservers
      .map(prepare(databaseReference:config:))
      .skipNil()
      .observeValues { [weak self] in
        self?.createFirebaseNumberOfPeopleWatchingObservers(ref: $0, refConfig: $1)
    }

    self.viewModel.outputs.createScaleNumberOfPeopleWatchingObservers
      .map(prepare(databaseReference:config:))
      .skipNil()
      .observeValues { [weak self] in
        self?.createFirebaseScaleNumberOfPeopleWatchingObservers(ref: $0, refConfig: $1)
    }

    self.viewModel.outputs.notifyDelegateLiveStreamViewControllerStateChanged
      .observeValues { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.liveStreamViewControllerStateChanged(controller: _self, state: $0)
    }
  }
  //swiftlint:enable function_body_length

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    guard let videoView = self.videoViewController?.view else { return }

    self.layoutVideoView(view: videoView)
  }

  deinit {
    self.firebaseRef?.removeAllObservers()
  }

  // MARK: Firebase

  private func createFirebaseGreenRoomObservers(ref: FIRDatabaseReference, refConfig: FirebaseRefConfig) {
    let query = ref.child(refConfig.ref).queryOrderedByKey()

    query.observe(.value, with: { [weak self] snapshot in
      self?.viewModel.inputs.observedGreenRoomOffChanged(off: snapshot.value)
    })
  }

  private func createFirebaseHLSObservers(ref: FIRDatabaseReference, refConfig: FirebaseRefConfig) {
    let query = ref.child(refConfig.ref).queryOrderedByKey()

    query.observe(.value, with: { [weak self] snapshot in
      self?.viewModel.inputs.observedHlsUrlChanged(hlsUrl: snapshot.value)
    })
  }

  private func createFirebaseNumberOfPeopleWatchingObservers(ref: FIRDatabaseReference,
                                                             refConfig: FirebaseRefConfig) {
    let query = ref.child(refConfig.ref).queryOrderedByKey()

    query.observe(.value, with: { [weak self] snapshot in
      self?.viewModel.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: snapshot.value)
    })
  }

  private func createFirebaseScaleNumberOfPeopleWatchingObservers(ref: FIRDatabaseReference,
                                                             refConfig: FirebaseRefConfig) {
    let query = ref.child(refConfig.ref).queryOrderedByKey()

    query.observe(.value, with: { [weak self] snapshot in
      self?.viewModel.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: snapshot.value)
    })
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

private func prepare(databaseReference
  ref: FirebaseDatabaseReferenceType,
  config: FirebaseRefConfig) -> (FIRDatabaseReference, FirebaseRefConfig)? {
  guard let ref = ref as? FIRDatabaseReference else { return nil }
  return (ref, config)
}
