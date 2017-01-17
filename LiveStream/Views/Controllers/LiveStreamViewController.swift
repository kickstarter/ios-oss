import Argo
import FirebaseAnalytics
import FirebaseAuth
import FirebaseDatabase
import Prelude
import ReactiveSwift
import Result
import UIKit

public protocol LiveStreamViewControllerDelegate: class {
  func liveStreamViewControllerStateChanged(controller: LiveStreamViewController?,
                                            state: LiveStreamViewControllerState)

  func liveStreamViewControllerNumberOfPeopleWatchingChanged(controller: LiveStreamViewController?,
                                                             numberOfPeople: Int)
}

public final class LiveStreamViewController: UIViewController {
  fileprivate var viewModel: LiveStreamViewModelType = LiveStreamViewModel()
  private var firebaseRef: FIRDatabaseReference?
  private var videoViewController: LiveVideoViewController?
  private weak var delegate: LiveStreamViewControllerDelegate?
  private var liveStreamService: LiveStreamServiceProtocol!

  public func configureWith(event: LiveStreamEvent,
                            userId: Int?,
                            delegate: LiveStreamViewControllerDelegate,
                            liveStreamService: LiveStreamServiceProtocol) {
    self.delegate = delegate
    self.liveStreamService = liveStreamService
    self.viewModel.inputs.configureWith(event: event, userId: userId)
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
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
      .observeValues { [weak self] in
        self?.delegate?.liveStreamViewControllerNumberOfPeopleWatchingChanged(controller: self,
                                                                             numberOfPeople: $0)
    }

    self.viewModel.outputs.createPresenceReference
      .map(prepare(databaseReference:config:))
      .skipNil()
      .observeValues { [weak self] in self?.createPresenceReference(ref: $0, refConfig: $1) }

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
        self?.delegate?.liveStreamViewControllerStateChanged(controller: self, state: $0)
    }

    self.viewModel.outputs.initializeFirebase
      .observeForUI()
      .observeValues { [weak self] event, userId in
        self?.initializeFirebase(withEvent: event, userId: userId)
    }

    self.viewModel.outputs.disableIdleTimer
      .observeForUI()
      .observeValues {
        UIApplication.shared.isIdleTimerDisabled = $0
    }
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

  deinit {
    self.firebaseRef?.removeAllObservers()
    KsLiveApp.firebaseApp()?.delete({ _ in })
    self.firebaseRef?.database.goOffline()
  }

  // MARK: Firebase

  private func initializeFirebase(withEvent event: LiveStreamEvent, userId: Int?) {

    self.liveStreamService.initializeDatabase(
      userId: userId,
      failed: {
        self.viewModel.inputs.firebaseAppFailedToInitialize()
      },
      succeeded: { ref in
        self.firebaseRef = ref
        self.viewModel.inputs.createdDatabaseRef(ref: ref)

        KsLiveApp.firebaseAuth()?.signInAnonymously { user, _ in
          guard let firebaseUserId = user?.uid else { return }
          self.viewModel.inputs.setFirebaseUserId(userId: firebaseUserId)
        }
    })
  }

  private func createPresenceReference(ref: FIRDatabaseReference, refConfig: FirebaseRefConfig) {
    let ref = ref.child(refConfig.ref)
    ref.setValue(true)
    ref.onDisconnectRemoveValue()
  }

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

private func prepare(databaseReference ref: FirebaseDatabaseReferenceType,
                     config: FirebaseRefConfig) -> (FIRDatabaseReference, FirebaseRefConfig)? {

  guard let ref = ref as? FIRDatabaseReference else { return nil }
  return (ref, config)
}
