//swiftlint:disable file_length
import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import Result
import UIKit

//swiftlint:disable:next type_body_length
public final class LiveStreamContainerViewController: UIViewController {

  @IBOutlet private weak var gradientView: GradientView!
  @IBOutlet private weak var liveStreamContainerView: UIView!
  @IBOutlet private weak var loaderActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var loaderLabel: UILabel!
  @IBOutlet private weak var loaderStackView: UIStackView!
  @IBOutlet private weak var loaderView: UIView!
  @IBOutlet private weak var separatorView: UIView!
  @IBOutlet private var videoContainerAspectRatioConstraint_4_3: NSLayoutConstraint!
  @IBOutlet private var videoContainerAspectRatioConstraint_16_9: NSLayoutConstraint!

  internal weak var liveStreamContainerPageViewController: LiveStreamContainerPageViewController?
  private weak var chatViewControllerDelegate: LiveStreamChatViewControllerDelegate?
  private var deviceOrientationObserver: Any?
  private var sessionEndedObserver: Any?
  private var sessionStartedObserver: Any?
  private let shareViewModel: ShareViewModelType = ShareViewModel()
  fileprivate let viewModel: LiveStreamContainerViewModelType = LiveStreamContainerViewModel()

  public static func configuredWith(project: Project,
                                    liveStreamEvent: LiveStreamEvent,
                                    refTag: RefTag,
                                    presentedFromProject: Bool) -> LiveStreamContainerViewController {

    let vc = Storyboard.LiveStream.instantiate(LiveStreamContainerViewController.self)
    vc.viewModel.inputs.configureWith(project: project,
                                      liveStreamEvent: liveStreamEvent,
                                      refTag: refTag,
                                      presentedFromProject: presentedFromProject)

    vc.shareViewModel.inputs.configureWith(shareContext: .liveStream(project, liveStreamEvent))

    return vc
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.setupLiveStreamViewController()

    self.navigationItem.leftBarButtonItem = self.closeBarButtonItem

    self.navigationItem.titleView = self.navBarTitleView

    self.liveStreamContainerPageViewController = self.childViewControllers
      .flatMap { $0 as? LiveStreamContainerPageViewController }
      .first

    self.deviceOrientationObserver = NotificationCenter.default
      .addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.deviceOrientationDidChange(
          orientation: UIApplication.shared.statusBarOrientation
        )
    }

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        AppEnvironment.current.currentUser?.liveAuthToken.doIfSome {
          self?.liveStreamViewController.userSessionChanged(
            session: .loggedIn(token: $0)
          )
        }
    }

    self.sessionEndedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.liveStreamViewController.userSessionChanged(session: .anonymous)
    }

    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    self.sessionEndedObserver.doIfSome {
      NotificationCenter.default.removeObserver($0)
    }

    self.sessionStartedObserver.doIfSome {
      NotificationCenter.default.removeObserver($0)
    }

    self.deviceOrientationObserver.doIfSome {
      NotificationCenter.default.removeObserver($0)
    }
  }

  //swiftlint:disable:next function_body_length
  public override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseLiveStreamControllerStyle()

    _  = self.loaderStackView
      |> UIStackView.lens.axis .~ .vertical
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.distribution .~ .fillEqually

    _  = self.loaderView
      |> UIView.lens.backgroundColor .~ .black

    _  = self.loaderActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true

    _  = self.loaderLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .white

    _ = self.separatorView
      |> UIView.lens.backgroundColor .~ .white
      |> UIView.lens.alpha .~ 0.2

    if self.traitCollection.isVerticallyCompact {
      self.videoContainerAspectRatioConstraint_4_3.isActive = false
      self.videoContainerAspectRatioConstraint_16_9.isActive = true
      self.view.addConstraint(self.videoContainerAspectRatioConstraint_16_9)
      self.view.removeConstraint(self.videoContainerAspectRatioConstraint_4_3)
    } else {
      self.videoContainerAspectRatioConstraint_4_3.isActive = true
      self.videoContainerAspectRatioConstraint_16_9.isActive = false
      self.view.removeConstraint(self.videoContainerAspectRatioConstraint_16_9)
      self.view.addConstraint(self.videoContainerAspectRatioConstraint_4_3)
    }

    self.gradientView.startPoint = .zero
    self.gradientView.endPoint = .init(x: 0, y: 1)
    self.gradientView.setGradient([(UIColor.black.withAlphaComponent(0.5), 0),
                                   (UIColor.black.withAlphaComponent(0), 1.0)])
  }

  //swiftlint:disable:next function_body_length
  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configureLiveStreamViewController
      .observeForUI()
      .observeValues { [weak self] _, liveStreamEvent in
        guard let _self = self else { return }
        _self.liveStreamViewController.configureWith(
          liveStreamEvent: liveStreamEvent,
          delegate: _self,
          liveStreamService: AppEnvironment.current.liveStreamService
        )
    }

    self.viewModel.outputs.configurePageViewController
      .observeForUI()
      .observeValues { [weak self] project, liveStreamEvent, refTag, presentedFromProject in
        guard let _self = self else { return }

        _self.liveStreamContainerPageViewController?.configureWith(
          project: project,
          liveStreamEvent: liveStreamEvent,
          liveStreamChatViewControllerDelegate: _self,
          refTag: refTag,
          presentedFromProject: presentedFromProject
        )
    }

    self.viewModel.outputs.videoViewControllerHidden
      .observeForUI()
      .observeValues { [weak self] in
        self?.liveStreamViewController.view.isHidden = $0
    }

    self.loaderLabel.rac.text = self.viewModel.outputs.loaderText
    self.loaderStackView.rac.hidden = self.viewModel.outputs.loaderStackViewHidden

    self.viewModel.outputs.dismiss
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: true, completion: nil)
    }

    self.loaderActivityIndicatorView.rac.animating = self.viewModel.outputs.loaderActivityIndicatorAnimating

    self.viewModel.outputs.showErrorAlert
      .observeForUI()
      .observeValues { [weak self] in
        self?.present(UIAlertController.genericError($0), animated: true, completion: nil)
    }

    self.viewModel.outputs.displayModalOverlayView
      .observeForUI()
      .observeValues { [weak self] in
        self?.displayModalOverlay()
    }

    self.viewModel.outputs.removeModalOverlayView
      .observeForUI()
      .observeValues { [weak self] in
        self?.removeModelOverLay()
    }

    self.viewModel.outputs.configureNavBarTitleView
      .observeForUI()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        self?.navBarTitleView.configureWith(liveStreamEvent: $0, delegate: _self)
    }

    self.viewModel.outputs.navBarTitleViewHidden
      .observeForUI()
      .observeValues { [weak self] in
        self?.navBarTitleView.isHidden = $0
    }

    self.viewModel.outputs.addShareBarButtonItem
      .observeForUI()
      .observeValues { [weak self] in
        if $0 {
          self?.navigationItem.rightBarButtonItem = self?.shareBarButtonItem
        } else {
          self?.navigationItem.rightBarButtonItem = nil
        }
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] in self?.showShareSheet(controller: $0) }
  }

  public override var prefersStatusBarHidden: Bool {
    return true
  }

  private func setupLiveStreamViewController() {
    self.liveStreamContainerView.addSubview(self.liveStreamViewController.view)

    NSLayoutConstraint.activate([
      self.liveStreamViewController.view.leftAnchor.constraint(
        equalTo: self.liveStreamContainerView.leftAnchor),
      self.liveStreamViewController.view.topAnchor.constraint(
        equalTo: self.liveStreamContainerView.topAnchor),
      self.liveStreamViewController.view.rightAnchor.constraint(
        equalTo: self.liveStreamContainerView.rightAnchor),
      self.liveStreamViewController.view.bottomAnchor.constraint(
        equalTo: self.liveStreamContainerView.bottomAnchor)
      ])

    self.liveStreamViewController.willMove(toParentViewController: self)
    self.addChildViewController(self.liveStreamViewController)
    self.liveStreamViewController.didMove(toParentViewController: self)
  }

  fileprivate lazy var navBarTitleView: LiveStreamNavTitleView = {
    let navBarTitleView = LiveStreamNavTitleView.fromNib()
    navBarTitleView.backgroundColor = .clear
    navBarTitleView.translatesAutoresizingMaskIntoConstraints = false
    return navBarTitleView
  }()

  private func showShareSheet(controller: UIActivityViewController) {
    controller.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in
      self?.shareViewModel.inputs.shareActivityCompletion(with: .init(activityType: activityType,
                                                                      completed: completed,
                                                                      returnedItems: returnedItems,
                                                                      activityError: error)
      )
    }

    if UIDevice.current.userInterfaceIdiom == .pad {
      controller.modalPresentationStyle = .popover
      controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
      self.present(controller, animated: true, completion: nil)
    } else {
      self.present(controller, animated: true, completion: nil)
    }
  }

  private func displayModalOverlay() {
    self.view.addSubview(self.modalOverlayView)

    self.modalOverlayView.alpha = 0

    NSLayoutConstraint.activate([
      self.modalOverlayView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.modalOverlayView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.modalOverlayView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.modalOverlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
      ])

    UIView.animate(withDuration: 0.3) {
      self.modalOverlayView.alpha = 1
    }
  }

  private func removeModelOverLay() {
    UIView.animate(withDuration: 0.3, animations: {
      self.modalOverlayView.alpha = 0
    }) { _ in
      self.modalOverlayView.removeFromSuperview()
    }
  }

  // MARK: Subviews

  private lazy var closeBarButtonItem: UIBarButtonItem = {
    let closeBarButtonItem = UIBarButtonItem()
      |> closeBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .white
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(close))

    closeBarButtonItem.accessibilityLabel = Strings.Close_live_stream()
    closeBarButtonItem.accessibilityHint = Strings.Closes_live_stream()

    return closeBarButtonItem
  }()

  lazy private var shareBarButtonItem: UIBarButtonItem = {
    let shareBarButtonItem = UIBarButtonItem()
      |> shareBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .white
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(share))

    shareBarButtonItem.accessibilityLabel = Strings.Share_this_live_stream()

    return shareBarButtonItem
  }()

  private lazy var modalOverlayView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.hex(0x1B1B1C).withAlphaComponent(0.7)
    return view
  }()

  fileprivate lazy var liveStreamViewController: LiveStreamViewController = {
    let liveStreamViewController = LiveStreamViewController(
        liveStreamService: AppEnvironment.current.liveStreamService
    )

    liveStreamViewController.view.translatesAutoresizingMaskIntoConstraints = false

    return liveStreamViewController
  }()

  // MARK: Actions

  @objc private func close() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc private func share() {
    self.shareViewModel.inputs.shareButtonTapped()
  }
}

extension LiveStreamContainerViewController: LiveStreamViewControllerDelegate {
  public func liveStreamViewController(_ controller: LiveStreamViewController?,
                                       numberOfPeopleWatchingChangedTo numberOfPeople: Int) {
    self.navBarTitleView.set(numberOfPeopleWatching: numberOfPeople)
  }

  public func liveStreamViewController(_ controller: LiveStreamViewController?,
                                       stateChangedTo state: LiveStreamViewControllerState) {
    self.viewModel.inputs.liveStreamViewControllerStateChanged(state: state)
  }

  public func liveStreamViewController(_ controller: LiveStreamViewController?,
                                       didReceiveLiveStreamApiError error: LiveApiError) {
    self.viewModel.inputs.liveStreamApiErrorOccurred(error: error)
  }
}

extension LiveStreamContainerViewController: LiveStreamChatViewControllerDelegate {
  internal func liveStreamChatViewController(
    _ controller: LiveStreamChatViewController,
    willDismissMoreMenuViewController moreMenuViewController: LiveStreamContainerMoreMenuViewController) {
    self.viewModel.inputs.willDismissMoreMenuViewController()
  }

  internal func liveStreamChatViewController(
    _ controller: LiveStreamChatViewController,
    willPresentMoreMenuViewController moreMenuViewController: LiveStreamContainerMoreMenuViewController) {
    self.viewModel.inputs.willPresentMoreMenuViewController()
  }

  internal func liveStreamChatViewController(_ controller: LiveStreamChatViewController,
                                             didReceiveLiveStreamApiError error: LiveApiError) {
    self.viewModel.inputs.liveStreamApiErrorOccurred(error: error)
  }
}

extension LiveStreamContainerViewController: LiveStreamNavTitleViewDelegate {
  func liveStreamNavTitleView(_ navTitleView: LiveStreamNavTitleView,
                              requiresLayoutWithPreferredSize size: CGSize) {
    guard let navigationBarWidth = self.navigationController?.navigationBar.frame.size.width else { return }

    let newOrigin = CGPoint(x: (navigationBarWidth / 2) - (size.width / 2),
                            y: navTitleView.frame.origin.y)

    navTitleView.frame = CGRect(
      origin: newOrigin,
      size: CGSize(width: size.width, height: Styles.grid(5))
    )
  }
}
