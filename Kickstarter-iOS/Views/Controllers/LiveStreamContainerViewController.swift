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

  @IBOutlet private weak var creatorAvatarImageView: UIImageView!
  @IBOutlet private weak var creatorAvatarLabel: SimpleHTMLLabel!
  @IBOutlet private weak var creatorAvatarLiveDotImageView: UIImageView!
  @IBOutlet private weak var creatorAvatarWidthConstraint: NSLayoutConstraint!
  @IBOutlet private weak var detailsContainerStackView: UIStackView!
  @IBOutlet private weak var gradientView: GradientView!
  @IBOutlet private weak var loaderActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var loaderLabel: UILabel!
  @IBOutlet private weak var loaderStackView: UIStackView!
  @IBOutlet private weak var loaderView: UIView!
  @IBOutlet private var separatorViews: [UIView]!
  @IBOutlet private weak var titleStackView: UIStackView!
  @IBOutlet private var videoContainerAspectRatioConstraint_4_3: NSLayoutConstraint!
  @IBOutlet private var videoContainerAspectRatioConstraint_16_9: NSLayoutConstraint!
  @IBOutlet private weak var watchingBadgeView: UIView!
  @IBOutlet private weak var watchingLabel: UILabel!

  fileprivate let eventDetailsViewModel: LiveStreamEventDetailsViewModelType
    = LiveStreamEventDetailsViewModel()
  fileprivate weak var liveStreamChatViewController: LiveStreamChatViewController?
  fileprivate weak var liveStreamViewController: LiveStreamViewController?
  fileprivate let shareViewModel: ShareViewModelType = ShareViewModel()
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
    vc.eventDetailsViewModel.inputs.configureWith(project: project, liveStreamEvent: liveStreamEvent)
    vc.shareViewModel.inputs.configureWith(shareContext: .liveStream(project, liveStreamEvent))

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

    self.liveStreamChatViewController = self.childViewControllers
      .flatMap { $0 as? LiveStreamChatViewController }
      .first

    _ = self.liveStreamViewController?.chatMessages.observeValues { [weak self] in
      self?.liveStreamChatViewController?.received(chatMessages: $0)
    }

    NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.eventDetailsViewModel.inputs.userSessionStarted()
    }

    NotificationCenter.default
      .addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.deviceOrientationDidChange(
          orientation: UIApplication.shared.statusBarOrientation
        )
    }

    self.viewModel.inputs.viewDidLoad()
    self.eventDetailsViewModel.inputs.viewDidLoad()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.watchingBadgeView.layer.cornerRadius = self.watchingBadgeView.frame.size.height / 2

    self.layoutNavBarTitle()
  }

  public override var inputAccessoryView: UIView? {
    guard let inputView = self.liveStreamChatInputView else { return nil }
    return inputView
  }

  public override var canBecomeFirstResponder: Bool {
    return true
  }

  public override var prefersStatusBarHidden: Bool {
    return true
  }

  //FIXME: make this an input/output and test
  public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    if self.presentedViewController != nil {
      if self.presentedViewController is LiveStreamContainerMoreMenuViewController {
        self.viewModel.inputs.willDismissMoreMenuViewController()
      }

      self.dismiss(animated: true)
    }
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
      |> UIView.lens.backgroundColor .~ .hex(0x353535)

    _  = self.loaderActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true

    _  = self.loaderLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .white

    _ = self.separatorViews
      ||> UIView.lens.backgroundColor .~ .white
      ||> UIView.lens.alpha .~ 0.2

    _  = self.titleStackView
      |> UIStackView.lens.axis .~ .horizontal
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.distribution .~ .fill
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(4))

    let creatorLabelFont = self.traitCollection.isRegularRegular
      ? UIFont.ksr_title3(size: 18)
      : UIFont.ksr_title3(size: 14)

    let creatorLabelBaseAttributes = [
      NSFontAttributeName: creatorLabelFont,
      NSForegroundColorAttributeName: UIColor.white
    ]
    let creatorLabelBoldAttributes = [
      NSFontAttributeName: creatorLabelFont.bolded
    ]

    _  = self.creatorAvatarLabel
      |> SimpleHTMLLabel.lens.numberOfLines .~ 0
      |> SimpleHTMLLabel.lens.textColor .~ .white
      |> SimpleHTMLLabel.lens.baseAttributes .~ creatorLabelBaseAttributes
      |> SimpleHTMLLabel.lens.boldAttributes .~ creatorLabelBoldAttributes

    _  = self.creatorAvatarImageView
      |> UIImageView.lens.layer.masksToBounds .~ true

    self.creatorAvatarWidthConstraint.constant = self.traitCollection.isRegularRegular
      ? Styles.grid(10) : Styles.grid(5)

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

    _ = self.watchingBadgeView
      |> UIView.lens.backgroundColor .~ UIColor.white.withAlphaComponent(0.1)
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))
      |> roundedStyle()

    _ = self.watchingLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_headline(size: 12)

    _ = self.titleStackView
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins %~~ { _, s in
        s.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(4), leftRight: Styles.grid(12))
          : .init(all: Styles.grid(4))
    }

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

    self.eventDetailsViewModel.outputs.openLoginToutViewController
      .observeValues { [weak self] _ in
        self?.openLoginTout()
    }

    self.viewModel.outputs.configureLiveStreamViewController
      .observeForUI()
      .observeValues { [weak self] _, userId, event in
        guard let _self = self else { return }
        _self.liveStreamViewController?.configureWith(
          event: event,
          userId: userId,
          delegate: _self,
          liveStreamService: AppEnvironment.current.liveStreamService
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

    self.creatorAvatarLabel.rac.html = self.viewModel.outputs.creatorIntroText

    self.creatorAvatarImageView.rac.imageUrl = self.eventDetailsViewModel.outputs.creatorAvatarUrl

    self.navBarLiveDotImageView.rac.hidden = self.viewModel.outputs.navBarLiveDotImageViewHidden
    self.creatorAvatarLiveDotImageView.rac.hidden = self.viewModel.outputs.creatorAvatarLiveDotImageViewHidden
    self.watchingBadgeView.rac.hidden = self.viewModel.outputs.numberWatchingBadgeViewHidden

    self.navBarTitleStackViewBackgroundView.rac.hidden = self.viewModel.outputs.navBarTitleViewHidden

    self.viewModel.outputs.titleViewText
      .observeForUI()
      .observeValues { [weak self] in
        self?.navBarTitleLabel.text = $0
        self?.view.setNeedsLayout()
    }

    self.loaderActivityIndicatorView.rac.animating = self.viewModel.outputs.loaderActivityIndicatorAnimating
    self.watchingLabel.rac.text = self.eventDetailsViewModel.outputs.numberOfPeopleWatchingText

    Signal.merge(
      self.viewModel.outputs.showErrorAlert,
      self.eventDetailsViewModel.outputs.showErrorAlert
    )
    .observeForUI()
    .observeValues { [weak self] in
      self?.present(UIAlertController.genericError($0), animated: true, completion: nil)
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] in self?.showShareSheet(controller: $0) }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goTo(project: $0, refTag: $1) }

    //FIXME: get chat hidden state from vm
    self.viewModel.outputs.presentMoreMenu
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.presentMoreMenu(liveStreamEvent: $0, chatHidden: false)
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

  fileprivate func openLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .liveStreamSubscribe)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
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

  private func showShareSheet(controller: UIActivityViewController) {
    controller.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in
      self?.shareViewModel.inputs.shareActivityCompletion(
        with: .init(activityType: activityType,
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

  private func goTo(project: Project, refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project, refTag: refTag)
    self.present(vc, animated: true, completion: nil)
  }

  private func presentMoreMenu(liveStreamEvent: LiveStreamEvent, chatHidden: Bool) {
    let vc = LiveStreamContainerMoreMenuViewController.configuredWith(
      liveStreamEvent: liveStreamEvent,
      delegate: self,
      chatHidden: chatHidden
    )

    vc.modalPresentationStyle = .overCurrentContext
    self.present(vc, animated: true, completion: nil)
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

    closeBarButtonItem.accessibilityHint = localizedString(
      key: "Closes_the_live_stream",
      defaultValue: "Closes the live stream."
    )

    return closeBarButtonItem
  }()

  private lazy var liveStreamChatInputView: LiveStreamChatInputView? = {
    let chatInputView = LiveStreamChatInputView.fromNib()
    chatInputView?.configureWith(delegate: self)
    chatInputView?.frame = .init(x: 0, y: 0, width: 0, height: Styles.grid(8))
    return chatInputView
  }()

  private lazy var modalOverlayView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.hex(0x1B1B1C).withAlphaComponent(0.7)
    return view
  }()

  // MARK: Actions

  @objc private func goToProjectButtonTapped() {
    self.viewModel.inputs.goToProjectButtonTapped()
  }

  @objc private func close() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc private func subscribe() {
    self.eventDetailsViewModel.inputs.subscribeButtonTapped()
  }
}

extension LiveStreamContainerViewController: LiveStreamViewControllerDelegate {
  public func liveStreamViewControllerNumberOfPeopleWatchingChanged(controller: LiveStreamViewController?,
                                                                    numberOfPeople: Int) {
    self.eventDetailsViewModel.inputs.setNumberOfPeopleWatching(numberOfPeople: numberOfPeople)
  }

  public func liveStreamViewControllerStateChanged(controller: LiveStreamViewController?,
                                                   state: LiveStreamViewControllerState) {
    self.viewModel.inputs.liveStreamViewControllerStateChanged(state: state)
    self.eventDetailsViewModel.inputs.liveStreamViewControllerStateChanged(state: state)
  }
}

extension LiveStreamContainerViewController: LiveStreamChatInputViewDelegate {
  func liveStreamChatInputViewDidTapMoreButton(chatInputView: LiveStreamChatInputView) {
    self.viewModel.inputs.moreMenuButtonTapped()
  }

  func liveStreamChatInputViewDidSend(chatInputView: LiveStreamChatInputView, message: String) {
    self.liveStreamViewController?.sendChatMessage(message: message)
  }

  func liveStreamChatInputViewRequestedLogin(chatInputView: LiveStreamChatInputView) {
    self.openLoginTout()
  }
}

extension LiveStreamContainerViewController: LiveStreamContainerMoreMenuViewControllerDelegate {
  func moreMenuViewControllerWillDismiss(controller: LiveStreamContainerMoreMenuViewController) {
    self.viewModel.inputs.willDismissMoreMenuViewController()
    self.dismiss(animated: true)
  }

  func moreMenuViewControllerDidSetChatHidden(controller: LiveStreamContainerMoreMenuViewController, hidden: Bool) {

  }

  func moreMenuViewControllerDidShare(controller: LiveStreamContainerMoreMenuViewController, liveStreamEvent: LiveStreamEvent) {
    self.viewModel.inputs.willDismissMoreMenuViewController()
    self.dismiss(animated: true) {
      self.shareViewModel.inputs.shareButtonTapped()
    }
  }

  func moreMenuViewControllerDidTapGoToProject(controller: LiveStreamContainerMoreMenuViewController, liveStreamEvent: LiveStreamEvent) {

  }
}
