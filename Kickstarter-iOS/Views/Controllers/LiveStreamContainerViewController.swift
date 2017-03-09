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
  @IBOutlet private weak var loaderActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var loaderLabel: UILabel!
  @IBOutlet private weak var loaderStackView: UIStackView!
  @IBOutlet private weak var loaderView: UIView!
  @IBOutlet private weak var separatorView: UIView!
  @IBOutlet private var videoContainerAspectRatioConstraint_4_3: NSLayoutConstraint!
  @IBOutlet private var videoContainerAspectRatioConstraint_16_9: NSLayoutConstraint!

  fileprivate weak var liveStreamViewController: LiveStreamViewController?
  fileprivate weak var liveStreamContainerPageViewController: LiveStreamContainerPageViewController?
  private weak var chatViewControllerDelegate: LiveStreamChatViewControllerDelegate?
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
    return vc
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.leftBarButtonItem = self.closeBarButtonItem

    self.navBarTitleStackViewBackgroundView.addSubview(self.navBarTitleStackView)
    self.navBarTitleStackView.addArrangedSubview(self.navBarLiveDotImageView)
    self.navBarTitleStackView.addArrangedSubview(self.navBarTitleLabel)

    NSLayoutConstraint.activate([
      self.navBarTitleStackView.leadingAnchor.constraint(
        equalTo: self.navBarTitleStackViewBackgroundView.leadingAnchor),
      self.navBarTitleStackView.topAnchor.constraint(
        equalTo: self.navBarTitleStackViewBackgroundView.topAnchor),
      self.navBarTitleStackView.trailingAnchor.constraint(
        equalTo: self.navBarTitleStackViewBackgroundView.trailingAnchor),
      self.navBarTitleStackView.bottomAnchor.constraint(
        equalTo: self.navBarTitleStackViewBackgroundView.bottomAnchor),
      ])

    self.navigationItem.titleView = navBarTitleStackViewBackgroundView

    self.liveStreamViewController = self.childViewControllers
      .flatMap { $0 as? LiveStreamViewController }
      .first

    self.liveStreamContainerPageViewController = self.childViewControllers
      .flatMap { $0 as? LiveStreamContainerPageViewController }
      .first

    NotificationCenter.default
      .addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.deviceOrientationDidChange(
          orientation: UIApplication.shared.statusBarOrientation
        )
    }

    self.viewModel.inputs.viewDidLoad()
  }

  //swiftlint:disable:next function_body_length
  public override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> LiveStreamContainerViewController.lens.view.backgroundColor .~ .black

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

    _  = self.navBarTitleStackViewBackgroundView
      |> UIView.lens.layer.cornerRadius .~ 2
      |> UIView.lens.layer.masksToBounds .~ true
      |> UIView.lens.backgroundColor .~ UIColor.black.withAlphaComponent(0.5)

    _  = self.navBarTitleStackView
      |> UIStackView.lens.axis .~ .horizontal
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.distribution .~ .fill
      |> UIStackView.lens.translatesAutoresizingMaskIntoConstraints .~ false
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.layoutMargins .~ .init(leftRight: Styles.grid(2))

    _  = self.navBarLiveDotImageView
      |> UIImageView.lens.image .~ UIImage(named: "live-dot")
      |> UIImageView.lens.contentMode .~ .scaleAspectFit
      |> UIImageView.lens.contentHuggingPriorityForAxis(.horizontal) .~ UILayoutPriorityDefaultHigh

    _  = self.navBarTitleLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.textAlignment .~ .center

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
      .observeValues { [weak self] _, userId, liveStreamEvent in
        guard let _self = self else { return }
        _self.liveStreamViewController?.configureWith(
          liveStreamEvent: liveStreamEvent,
          delegate: _self,
          liveStreamService: AppEnvironment.current.liveStreamService
        )
    }

    self.viewModel.outputs.configurePageViewController
      .observeForUI()
      .observeValues { [weak self] project, liveStreamEvent, refTag, presentedFromProject in
        guard
          let _self = self,
          let liveStreamViewController = self?.liveStreamViewController
          else {
            return
        }

        _self.liveStreamContainerPageViewController?.configureWith(
          project: project,
          liveStreamEvent: liveStreamEvent,
          liveStreamChatHandler: liveStreamViewController,
          liveStreamChatViewControllerDelegate: _self,
          refTag: refTag,
          presentedFromProject: presentedFromProject
        )
    }

    self.viewModel.outputs.videoViewControllerHidden
      .observeForUI()
      .observeValues { [weak self] in
        self?.liveStreamViewController?.view.isHidden = $0
    }

    self.loaderLabel.rac.text = self.viewModel.outputs.loaderText
    self.loaderStackView.rac.hidden = self.viewModel.outputs.loaderStackViewHidden

    self.viewModel.outputs.dismiss
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: true, completion: nil)
    }

    self.navBarLiveDotImageView.rac.hidden = self.viewModel.outputs.navBarLiveDotImageViewHidden

    self.navBarTitleStackViewBackgroundView.rac.hidden = self.viewModel.outputs.navBarTitleViewHidden

    self.viewModel.outputs.titleViewText
      .observeForUI()
      .observeValues { [weak self] in
        self?.navBarTitleLabel.text = $0
        self?.view.setNeedsLayout()
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
  }

  override public var prefersStatusBarHidden: Bool {
    return true
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.layoutNavBarTitle()
  }

  private func layoutNavBarTitle() {
    let stackViewSize = self.navBarTitleStackView.systemLayoutSizeFitting(
      CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height))

    let newOrigin = CGPoint(x: (self.view.frame.size.width / 2) - (stackViewSize.width / 2),
                         y: self.navBarTitleStackViewBackgroundView.frame.origin.y)

    self.navBarTitleStackViewBackgroundView.frame = CGRect(
      origin: newOrigin,
      size: CGSize(width: stackViewSize.width, height: Styles.grid(5))
    )
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

  private lazy var navBarTitleStackViewBackgroundView = { UIView() }()
  private lazy var navBarTitleStackView = { UIStackView() }()
  private lazy var navBarLiveDotImageView = { UIImageView() }()
  private lazy var navBarTitleLabel = { UILabel() }()

  private lazy var closeBarButtonItem: UIBarButtonItem = {
    let closeBarButtonItem = UIBarButtonItem()
      |> closeBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .white
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(close))

    closeBarButtonItem.accessibilityLabel = Strings.Close_live_stream()
    closeBarButtonItem.accessibilityHint = Strings.Closes_live_stream()

    return closeBarButtonItem
  }()

  private lazy var modalOverlayView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.hex(0x1B1B1C).withAlphaComponent(0.7)
    return view
  }()

  // MARK: Actions

  @objc private func close() {
    self.viewModel.inputs.closeButtonTapped()
  }
}

extension LiveStreamContainerViewController: LiveStreamViewControllerDelegate {
  public func liveStreamViewControllerNumberOfPeopleWatchingChanged(controller: LiveStreamViewController?,
                                                                    numberOfPeople: Int) {
//    self.eventDetailsViewModel.inputs.setNumberOfPeopleWatching(numberOfPeople: numberOfPeople)
  }

  public func liveStreamViewControllerStateChanged(controller: LiveStreamViewController?,
                                                   state: LiveStreamViewControllerState) {
    self.viewModel.inputs.liveStreamViewControllerStateChanged(state: state)
//    self.eventDetailsViewModel.inputs.liveStreamViewControllerStateChanged(state: state)
  }
}

extension LiveStreamContainerViewController: LiveStreamChatViewControllerDelegate {
  func willDismissMoreMenuViewController(controller: LiveStreamChatViewController,
                                         moreMenuViewController: LiveStreamContainerMoreMenuViewController) {
    self.viewModel.inputs.willDismissMoreMenuViewController()
  }

  func willPresentMoreMenuViewController(controller: LiveStreamChatViewController,
                                         moreMenuViewController: LiveStreamContainerMoreMenuViewController) {
    self.viewModel.inputs.willPresentMoreMenuViewController()
  }
}
