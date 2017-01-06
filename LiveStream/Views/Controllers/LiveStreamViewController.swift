import Argo
import FirebaseAnalytics
import FirebaseDatabase
import Prelude
import ReactiveCocoa
import Result
import UIKit

public protocol LiveStreamViewControllerDelegate: class {
  func liveStreamViewControllerStateChanged(controller: LiveStreamViewController,
                                            state: LiveStreamViewControllerState)

  func liveStreamViewControllerNumberOfPeopleWatchingChanged(controller: LiveStreamViewController,
                                                             numberOfPeople: Int)
}

public final class LiveStreamViewController: UIViewController {
  private var viewModel: LiveStreamViewModelType = LiveStreamViewModel()
  private var firebaseRef: FIRDatabaseReference?
  private var videoViewController: LiveVideoViewController?
  public weak var delegate: LiveStreamViewControllerDelegate?

  public init(event: LiveStreamEvent, delegate: LiveStreamViewControllerDelegate) {
    super.init(nibName: nil, bundle: nil)

    self.delegate = delegate
    self.bindVM()

    let app = KsLiveApp.firebaseApp()
    let databaseRef = FIRDatabase.database(app: app).reference()

    self.viewModel.inputs.configureWith(databaseRef: databaseRef, event: event)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return [.Portrait, .Landscape]
  }

  //swiftlint:disable function_body_length
  public func bindVM() {
    self.viewModel.outputs.createVideoViewController
      .observeForUI()
      .observeNext { [weak self] in
        self?.createVideoViewController($0)
    }

    self.viewModel.outputs.removeVideoViewController
      .observeForUI()
      .observeNext { [weak self] in
        self?.videoViewController?.removeFromParentViewController()
        self?.videoViewController = nil
    }

    self.viewModel.outputs.notifyDelegateLiveStreamNumberOfPeopleWatchingChanged.observeNext { [weak self] in
      guard let _self = self else { return }
      _self.delegate?.liveStreamViewControllerNumberOfPeopleWatchingChanged(_self, numberOfPeople: $0)
    }

    self.viewModel.outputs.createGreenRoomObservers
      .map(prepare(databaseReference:config:))
      .ignoreNil()
      .observeNext { [weak self] in self?.createFirebaseGreenRoomObservers($0, refConfig: $1) }

    self.viewModel.outputs.createHLSObservers
      .map(prepare(databaseReference:config:))
      .ignoreNil()
      .observeNext { [weak self] in self?.createFirebaseHLSObservers($0, refConfig: $1) }

    self.viewModel.outputs.createNumberOfPeopleWatchingObservers
      .map(prepare(databaseReference:config:))
      .ignoreNil()
      .observeNext { [weak self] in self?.createFirebaseNumberOfPeopleWatchingObservers($0, refConfig: $1) }

    self.viewModel.outputs.createScaleNumberOfPeopleWatchingObservers
      .map(prepare(databaseReference:config:))
      .ignoreNil()
      .observeNext { [weak self] in
        self?.createFirebaseScaleNumberOfPeopleWatchingObservers($0, refConfig: $1)
    }

    self.viewModel.outputs.notifyDelegateLiveStreamViewControllerStateChanged
      .observeNext { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.liveStreamViewControllerStateChanged(_self, state: $0)
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

    self.layoutVideoView(videoView)
  }

  deinit {
    self.firebaseRef?.removeAllObservers()
  }

  // MARK: Firebase

  private func createFirebaseGreenRoomObservers(ref: FIRDatabaseReference, refConfig: FirebaseRefConfig) {
    let query = ref.child(refConfig.ref).queryOrderedByKey()

    query.observeEventType(.Value, withBlock: { [weak self] (snapshot) in
      self?.viewModel.inputs.observedGreenRoomOffChanged(off: snapshot.value)
    })
  }

  private func createFirebaseHLSObservers(ref: FIRDatabaseReference, refConfig: FirebaseRefConfig) {
    let query = ref.child(refConfig.ref).queryOrderedByKey()

    query.observeEventType(.Value, withBlock: { [weak self] (snapshot) in
      self?.viewModel.inputs.observedHlsUrlChanged(hlsUrl: snapshot.value)
    })
  }

  private func createFirebaseNumberOfPeopleWatchingObservers(ref: FIRDatabaseReference,
                                                             refConfig: FirebaseRefConfig) {
    let query = ref.child(refConfig.ref).queryOrderedByKey()

    query.observeEventType(.Value, withBlock: { [weak self] (snapshot) in
      self?.viewModel.inputs.observedNumberOfPeopleWatchingChanged(numberOfPeople: snapshot.value)
    })
  }

  private func createFirebaseScaleNumberOfPeopleWatchingObservers(ref: FIRDatabaseReference,
                                                             refConfig: FirebaseRefConfig) {
    let query = ref.child(refConfig.ref).queryOrderedByKey()

    query.observeEventType(.Value, withBlock: { [weak self] (snapshot) in
      self?.viewModel.inputs.observedScaleNumberOfPeopleWatchingChanged(numberOfPeople: snapshot.value)
    })
  }

  // MARK: Video

  private func addChildVideoViewController(controller: UIViewController) {
    self.addChildViewController(controller)
    controller.didMoveToParentViewController(self)
    self.view.addSubview(controller.view)
  }

  private func layoutVideoView(view: UIView) {
    view.frame = self.view.bounds
  }

  private func createVideoViewController(liveStreamType: LiveStreamType) {
    let videoViewController = LiveVideoViewController(liveStreamType: liveStreamType, delegate: self)

    self.videoViewController?.removeFromParentViewController()
    self.videoViewController = videoViewController
    self.addChildVideoViewController(videoViewController)
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
