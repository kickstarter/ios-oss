//swiftlint:disable file_length
import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import Result
import UIKit

//swiftlint:disable:next type_body_length
internal final class LiveStreamContainerViewController: UIViewController {

  @IBOutlet private weak var availableForLabel: UILabel!
  @IBOutlet private weak var creatorAvatarImageView: UIImageView!
  @IBOutlet private weak var creatorAvatarLabel: UILabel!
  @IBOutlet private weak var creatorAvatarLiveDotImageView: UIImageView!
  @IBOutlet private weak var detailsContainerStackView: UIStackView!
  @IBOutlet private weak var detailsLoadingActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var detailsStackView: UIStackView!
  @IBOutlet private weak var liveStreamParagraphLabel: UILabel!
  @IBOutlet private weak var liveStreamTitleLabel: UILabel!
  @IBOutlet private weak var loaderActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var loaderButton: UIButton!
  @IBOutlet private weak var loaderContainerStackView: UIStackView!
  @IBOutlet private weak var loaderLabel: UILabel!
  @IBOutlet private weak var loaderStackView: UIStackView!
  @IBOutlet private weak var loaderView: UIView!
  @IBOutlet private weak var loaderViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var numberWatchingButton: UIButton!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var subscribeActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var subscribeButton: UIButton!
  @IBOutlet private weak var subscribeLabel: UILabel!
  @IBOutlet private weak var subscribeStackView: UIStackView!
  @IBOutlet private weak var titleDetailsSeparator: UIView!
  @IBOutlet private weak var titleStackView: UIStackView!
  @IBOutlet private weak var titleStackViewHeightConstraint: NSLayoutConstraint!

  fileprivate let eventDetailsViewModel: LiveStreamEventDetailsViewModelType
    = LiveStreamEventDetailsViewModel()
  private var liveStreamViewController: LiveStreamViewController?
  private let shareViewModel: ShareViewModelType = ShareViewModel()
  fileprivate let viewModel: LiveStreamContainerViewModelType = LiveStreamContainerViewModel()

  internal static func configuredWith(project: Project,
                                      liveStream: Project.LiveStream,
                                      event: LiveStreamEvent?) -> LiveStreamContainerViewController {

    let vc = Storyboard.LiveStream.instantiate(LiveStreamContainerViewController.self)
    vc.viewModel.inputs.configureWith(project: project, event: event)
    vc.eventDetailsViewModel.inputs.configureWith(project: project, liveStream: liveStream, event: event)

    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    let closeBarButtonItem = UIBarButtonItem()
      |> closeBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .white
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(close))

    self.navigationItem.leftBarButtonItem = closeBarButtonItem
    self.navigationItem.rightBarButtonItem = self.shareBarButtonItem

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

    self.viewModel.inputs.viewDidLoad()
    self.eventDetailsViewModel.inputs.viewDidLoad()
  }

  //swiftlint:disable:next function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()

    _  = self.projectImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFill

    _  = self.loaderContainerStackView
      |> UIStackView.lens.axis .~ .horizontal
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.distribution .~ .fill

    _  = self.loaderStackView
      |> UIStackView.lens.axis .~ .vertical
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.distribution .~ .fillEqually

    _  = self.loaderView
      |> UIView.lens.backgroundColor .~ UIColor.hex(0x353535)

    _  = self.loaderActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.animating .~ true

    _  = self.loaderLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .white

    _  = self.loaderButton
      |> UIButton.lens.hidden .~ true

    _  = self.titleStackViewHeightConstraint.constant = Styles.grid(14)

    _  = self.titleStackView
      |> UIStackView.lens.axis .~ .horizontal
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.distribution .~ .fill
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(4))

    _  = self.availableForLabel
      |> UILabel.lens.font .~ UIFont.ksr_footnote(size: 11).italicized
      |> UILabel.lens.textColor .~ .white

    _  = self.titleDetailsSeparator
      |> UIView.lens.backgroundColor .~ UIColor.white.withAlphaComponent(0.2)

    _  = self.detailsStackView
      |> UIStackView.lens.axis .~ .vertical
      |> UIStackView.lens.distribution .~ .fill
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(4))
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _  = self.subscribeStackView
      |> UIStackView.lens.axis .~ .horizontal
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.distribution .~ .fill
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(3)
      |> UIStackView.lens.layoutMargins .~ .init(
        top: 0,
        left: Styles.grid(4),
        bottom: Styles.grid(4),
        right: Styles.grid(4))

    _  = self.creatorAvatarLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_footnote()

    _  = self.creatorAvatarImageView
      |> UIImageView.lens.image .~ nil
      |> UIImageView.lens.layer.masksToBounds .~ true

    _  = self.numberWatchingButton
      |> baseButtonStyle
      |> UIButton.lens.titleColor(forState: .normal) .~ .white
      |> UIButton.lens.backgroundColor .~ UIColor.white.withAlphaComponent(0.1)
      |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(left: -Styles.grid(2))
      |> UIButton.lens.image(forState: .normal) .~ UIImage(named: "eye")
      |> UIButton.lens.tintColor .~ self.subscribeButton.currentTitleColor
      |> UIButton.lens.titleLabel.font .~ UIFont.ksr_headline(size: 12)
      |> UIButton.lens.userInteractionEnabled .~ false
      |> UIButton.lens.title(forState: .normal) .~ String(0)

    _  = self.numberWatchingButton.semanticContentAttribute = .forceLeftToRight

    _  = self.liveStreamTitleLabel
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.font .~ .ksr_headline(size: 18)
      |> UILabel.lens.textColor .~ .white

    _  = self.liveStreamParagraphLabel
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.font .~ .ksr_body(size: 14)
      |> UILabel.lens.textColor .~ .white

    _  = self.subscribeLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 13)
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.textColor .~ .white

    _  = self.subscribeActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
      |> UIActivityIndicatorView.lens.animating .~ false

    _  = self.subscribeButton
      |> whiteBorderContainerButtonStyle
      |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(right: -Styles.grid(1))
      |> UIButton.lens.tintColor .~ self.subscribeButton.currentTitleColor
      |> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 10.0, leftRight: Styles.grid(2))

    _  = self.subscribeButton.semanticContentAttribute = .forceRightToLeft

    _  = self.detailsLoadingActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
      |> UIActivityIndicatorView.lens.animating .~ false

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
      |> UIImageView.lens.image .~ UIImage(named: "live_dot")
      |> UIImageView.lens.contentMode .~ .scaleAspectFit
      |> UIImageView.lens.contentHuggingPriorityForAxis(.horizontal) .~ UILayoutPriorityDefaultHigh

    _  = self.navBarTitleLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.textAlignment .~ .center
  }

  //swiftlint:disable:next function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.createAndConfigureLiveStreamViewController
      .observeForUI()
      .observeValues { [weak self] _, userId, event in
        guard let _self = self else { return }

        _self.addChildLiveStreamViewController(controller:
          LiveStreamViewController(event: event, userId: userId, delegate: _self)
        )
    }

    self.eventDetailsViewModel.outputs.retrievedLiveStreamEvent
      .observeValues(self.viewModel.inputs.retrievedLiveStreamEvent(event:))

    self.viewModel.outputs.videoViewControllerHidden
      .observeForUI()
      .observeValues { [weak self] in
        self?.liveStreamViewController?.view.isHidden = $0
    }

    self.viewModel.outputs.projectImageUrl
      .observeForUI()
      .on(event: { [weak self] image in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
      })
      .observeValues { [weak self] in self?.projectImageView.ksr_setImageWithURL($0) }

    self.loaderLabel.rac.text = self.viewModel.outputs.loaderText

    self.viewModel.outputs.dismiss
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: true, completion: nil)
    }

    self.creatorAvatarLabel.rac.attributedText = self.viewModel.outputs.creatorIntroText

    self.eventDetailsViewModel.outputs.creatorAvatarUrl
      .observeForUI()
      .on(event: { [weak self] image in
        self?.creatorAvatarImageView.af_cancelImageRequest()
        self?.creatorAvatarImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] in self?.creatorAvatarImageView.ksr_setImageWithURL($0) }

    self.navBarLiveDotImageView.rac.hidden = self.viewModel.outputs.navBarLiveDotImageViewHidden
    self.creatorAvatarLiveDotImageView.rac.hidden = self.viewModel.outputs.creatorAvatarLiveDotImageViewHidden
    self.numberWatchingButton.rac.hidden = self.viewModel.outputs.numberWatchingButtonHidden
    self.availableForLabel.rac.hidden = self.viewModel.outputs.availableForLabelHidden

    self.navBarTitleLabel.rac.text = self.viewModel.outputs.titleViewText

    self.liveStreamTitleLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamTitle
    self.liveStreamParagraphLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamParagraph
    self.subscribeLabel.rac.text = self.eventDetailsViewModel.outputs.subscribeLabelText
    self.subscribeButton.rac.title = self.eventDetailsViewModel.outputs.subscribeButtonText
    self.numberWatchingButton.rac.title = self.eventDetailsViewModel.outputs.numberOfPeopleWatchingText
    self.shareBarButtonItem.rac.enabled = self.eventDetailsViewModel.outputs.shareButtonEnabled

    self.eventDetailsViewModel.outputs.configureShareViewModel
      .observeForUI()
      .observeValues { [weak self] in
        self?.shareViewModel.inputs.configureWith(shareContext: ShareContext.liveStream($0, $1))
    }

    self.eventDetailsViewModel.outputs.subscribeButtonImage
      .observeForUI()
      .observeValues { [weak self] in
        let imageName = $0.flatMap { $0 }.coalesceWith("")
        self?.subscribeButton.setImage(UIImage(named: imageName), for: .normal)
    }

    self.availableForLabel.rac.text = self.eventDetailsViewModel.outputs.availableForText

    self.detailsLoadingActivityIndicatorView.rac.animating = self.eventDetailsViewModel.outputs
      .animateActivityIndicator

    self.detailsContainerStackView.rac.hidden = self.eventDetailsViewModel.outputs.animateActivityIndicator

    self.subscribeActivityIndicatorView.rac.animating = self.eventDetailsViewModel.outputs
      .animateSubscribeButtonActivityIndicator

    self.subscribeButton.rac.hidden = self.eventDetailsViewModel.outputs
      .animateSubscribeButtonActivityIndicator

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
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  internal override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    // FIXME: we might be able to leverage `dropShadowStyle` for this. let's revisit after we get screenshot 
    // tests
    _  = self.loaderView.layer
      |> CALayer.lens.masksToBounds .~ false
      |> CALayer.lens.shadowColor .~ UIColor.black.cgColor
      |> CALayer.lens.shadowOffset .~ CGSize(width: 0, height: 5)
      |> CALayer.lens.shadowOpacity .~ Float(0.5)

    self.loaderView.layer.shadowPath = UIBezierPath(rect: self.loaderView.bounds).cgPath
    self.numberWatchingButton.layer.cornerRadius = self.numberWatchingButton.frame.size.height / 2
    self.subscribeButton.layer.cornerRadius = self.subscribeButton.frame.size.height / 2
    self.creatorAvatarImageView.layer.cornerRadius = self.creatorAvatarImageView.frame.size.width / 2

    // FIXME: do we have to set frame like this?
    let titleSize = self.navBarTitleLabel.sizeThatFits(
      CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    )
    self.navBarTitleStackViewBackgroundView.frame = CGRect(
      origin:self.navBarTitleStackViewBackgroundView.frame.origin,
      size: CGSize(width: Styles.grid(4) + titleSize.width, height: Styles.grid(5))
    )

    self.loaderViewHeightConstraint.constant = self.videoFrame(landscape: self.isLandscape()).height

    if let view = self.liveStreamViewController?.view {
      self.layoutLiveStreamView(view: view)
    }
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

    super.viewWillTransition(to: size, with: coordinator)

    coordinator.animate(alongsideTransition: { _ in
      if let view = self.liveStreamViewController?.view { self.layoutLiveStreamView(view: view) }
    }, completion: { _ in
      self.navigationController?.setNavigationBarHidden(self.isLandscape(), animated: true)
    })
  }

  private func addChildLiveStreamViewController(controller: LiveStreamViewController) {
    self.liveStreamViewController = controller
    controller.view.isHidden = true
    self.addChildViewController(controller)
    controller.didMove(toParentViewController: self)
    self.view.addSubview(controller.view)
  }

  private func layoutLiveStreamView(view: UIView) {
    view.frame = self.videoFrame(landscape: self.isLandscape())
  }

  // FIXME: we shouldn't depend on these globals for portrait/landscape
  private func isLandscape() -> Bool {
    return UIApplication.shared.statusBarOrientation != .portrait
  }

  private func videoFrame(landscape: Bool) -> CGRect {
    return CGRect(x: 0, y: 0,
                  width: self.view.bounds.size.width,
                  height: self.view.bounds.size.height * (landscape ? 1 : 0.4))
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

  // MARK: Subviews

  // FIXME: these should all be IBOutlets

  lazy var navBarTitleStackViewBackgroundView = { UIView() }()
  lazy var navBarTitleStackView = { UIStackView() }()
  lazy var navBarLiveDotImageView = { UIImageView() }()
  lazy var navBarTitleLabel = { UILabel() }()

  lazy var shareBarButtonItem: UIBarButtonItem = {
    let shareBarButtonItem = UIBarButtonItem()
      |> shareBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .white
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(share))
      |> UIBarButtonItem.lens.enabled .~ false

    return shareBarButtonItem
  }()

  // MARK: Actions

  @objc private func close() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc private func share() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @IBAction private func subscribe(_ sender: UIButton) {
    self.eventDetailsViewModel.inputs.subscribeButtonTapped()
  }
}

extension LiveStreamContainerViewController: LiveStreamViewControllerDelegate {
  internal func liveStreamViewControllerNumberOfPeopleWatchingChanged(controller: LiveStreamViewController,
                                                                      numberOfPeople: Int) {
    self.eventDetailsViewModel.inputs.setNumberOfPeopleWatching(numberOfPeople: numberOfPeople)
  }

  internal func liveStreamViewControllerStateChanged(controller: LiveStreamViewController,
                                       state: LiveStreamViewControllerState) {
    self.viewModel.inputs.liveStreamViewControllerStateChanged(state: state)
    self.eventDetailsViewModel.inputs.liveStreamViewControllerStateChanged(state: state)
  }
}
