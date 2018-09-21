import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import Result
import UIKit

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

  private var liveVideoViewController: LiveVideoViewController?
  internal weak var liveStreamContainerPageViewController: LiveStreamContainerPageViewController?
  private var deviceOrientationChangedObserver: Any?
  private var sessionStartedObserver: Any?
  private let shareViewModel: ShareViewModelType = ShareViewModel()
  fileprivate let viewModel: LiveStreamContainerViewModelType = LiveStreamContainerViewModel()

  public static func configuredWith(project: Project,
                                    liveStreamEvent: LiveStreamEvent,
                                    refTag: RefTag,
                                    presentedFromProject: Bool) -> LiveStreamContainerViewController {

    AppEnvironment.current.liveStreamService.setup()

    let vc = Storyboard.LiveStream.instantiate(LiveStreamContainerViewController.self)
    vc.viewModel.inputs.configureWith(project: project,
                                      liveStreamEvent: liveStreamEvent,
                                      refTag: refTag,
                                      presentedFromProject: presentedFromProject)

    vc.shareViewModel.inputs.configureWith(shareContext: .liveStream(project, liveStreamEvent),
                                           shareContextView: nil)

    return vc
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
    self.navigationItem.rightBarButtonItem = self.shareBarButtonItem

    self.navigationItem.titleView = self.navBarTitleView

    self.liveStreamContainerPageViewController = self.childViewControllers
      .compactMap { $0 as? LiveStreamContainerPageViewController }
      .first

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    self.deviceOrientationChangedObserver = NotificationCenter.default
      .addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.deviceOrientationDidChange(
          orientation: UIApplication.shared.statusBarOrientation
        )
    }

    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    self.deviceOrientationChangedObserver.doIfSome(NotificationCenter.default.removeObserver)
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

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
      |> UILabel.lens.textAlignment .~ .center

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
    let gradient: [(UIColor?, Float)] =  [(UIColor.black.withAlphaComponent(0.5), 0),
                                          (UIColor.black.withAlphaComponent(0), 1)]
    self.gradientView.setGradient(gradient)
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configurePageViewController
      .observeForUI()
      .observeValues { [weak self] project, liveStreamEvent, refTag, presentedFromProject in
        guard let _self = self else { return }

        _self.liveStreamContainerPageViewController?.configureWith(
          project: project,
          liveStreamEvent: liveStreamEvent,
          refTag: refTag,
          presentedFromProject: presentedFromProject
        )
    }

    self.viewModel.outputs.videoViewControllerHidden
      .observeForUI()
      .observeValues { [weak self] in
        self?.liveVideoViewController?.view.isHidden = $0
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

    self.viewModel.outputs.configureNavBarTitleView
      .observeForUI()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        _self.navBarTitleView?.configureWith(liveStreamEvent: $0, delegate: _self)
    }

    self.viewModel.outputs.navBarTitleViewHidden
      .observeForUI()
      .observeValues { [weak self] in
        self?.navBarTitleView?.isHidden = $0
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] controller, _ in self?.showShareSheet(controller: controller) }

    self.viewModel.outputs.createVideoViewController
      .observeForUI()
      .observeValues { [weak self] in
        self?.createAndAddChildVideoViewController(withLiveStreamType: $0)
    }

    self.viewModel.outputs.removeVideoViewController
      .observeForUI()
      .observeValues { [weak self] in
        self?.liveVideoViewController?.removeFromParentViewController()
        self?.liveVideoViewController = nil
    }

    self.viewModel.outputs.numberOfPeopleWatching
      .observeValues { [weak self] number in
        self?.navBarTitleView?.set(numberOfPeopleWatching: number)
    }

    self.viewModel.outputs.disableIdleTimer
      .observeForUI()
      .observeValues {
        UIApplication.shared.isIdleTimerDisabled = $0
    }
  }

  public override var prefersStatusBarHidden: Bool {
    return true
  }

  private func layoutVideoView(view: UIView) {
    view.frame = self.view.bounds
  }

  private func createAndAddChildVideoViewController(withLiveStreamType liveStreamType: LiveStreamType) {
    self.liveVideoViewController?.removeFromParentViewController()

    let videoViewController = LiveVideoViewController(liveStreamType: liveStreamType, delegate: self)
    videoViewController.view.translatesAutoresizingMaskIntoConstraints = false
    self.liveStreamContainerView.addSubview(videoViewController.view)

    NSLayoutConstraint.activate([
      videoViewController.view.leftAnchor.constraint(
        equalTo: self.liveStreamContainerView.leftAnchor),
      videoViewController.view.topAnchor.constraint(
        equalTo: self.liveStreamContainerView.topAnchor),
      videoViewController.view.rightAnchor.constraint(
        equalTo: self.liveStreamContainerView.rightAnchor),
      videoViewController.view.bottomAnchor.constraint(
        equalTo: self.liveStreamContainerView.bottomAnchor)
      ])

    self.addChildViewController(videoViewController)
    videoViewController.didMove(toParentViewController: self)

    self.liveVideoViewController = videoViewController
  }

  fileprivate lazy var navBarTitleView: LiveStreamNavTitleView? = {
    guard let navBarTitleView = LiveStreamNavTitleView.fromNib() else { return nil }
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

  // MARK: Actions

  @objc private func close() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc private func share() {
    self.shareViewModel.inputs.shareButtonTapped()
  }
}

extension LiveStreamContainerViewController: LiveVideoViewControllerDelegate {
  public func liveVideoViewControllerPlaybackStateChanged(controller: LiveVideoViewController?,
                                                          state: LiveVideoPlaybackState) {
    self.viewModel.inputs.videoPlaybackStateChanged(state: state)
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
