import KsApi
import Library
import Prelude
import UIKit

public protocol ProjectPamphletViewControllerDelegate: class {
  func projectPamphlet(_ controller: ProjectPamphletViewController,
                       panGestureRecognizerDidChange recognizer: UIPanGestureRecognizer)
  func projectPamphletViewController(_ projectPamphletViewController: ProjectPamphletViewController,
                                     didTapBackThisProject project: Project,
                                     refTag: RefTag?)
}

public final class ProjectPamphletViewController: UIViewController {
  internal weak var delegate: ProjectPamphletViewControllerDelegate?
  fileprivate let viewModel: ProjectPamphletViewModelType = ProjectPamphletViewModel()

  fileprivate var navBarController: ProjectNavBarViewController!
  fileprivate var contentController: ProjectPamphletContentViewController!

  @IBOutlet weak private var navBarTopConstraint: NSLayoutConstraint!

  private let backThisProjectContainerViewMargins = Styles.grid(3)
  private let backThisProjectContainerView: UIView = {
    return UIView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let backThisProjectButton: UIButton = {
     return MultiLineButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  public static func configuredWith(projectOrParam: Either<Project, Param>,
                                    refTag: RefTag?) -> ProjectPamphletViewController {

    let vc = Storyboard.ProjectPamphlet.instantiate(ProjectPamphletViewController.self)
    vc.viewModel.inputs.configureWith(projectOrParam: projectOrParam, refTag: refTag)
    return vc
  }

  public override var prefersStatusBarHidden: Bool {
    return UIApplication.shared.statusBarOrientation.isLandscape
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    if shouldShowNativeCheckout() {
      self.configureViews()
    }

    self.navBarController = self.children
      .compactMap { $0 as? ProjectNavBarViewController }.first
    self.navBarController.delegate = self

    self.contentController = self.children
      .compactMap { $0 as? ProjectPamphletContentViewController }.first
    self.contentController.delegate = self

    self.viewModel.inputs.initial(topConstraint: initialTopConstraint)

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.setInitial(constraints: [navBarTopConstraint],
                    constant: initialTopConstraint)

    if self.shouldShowNativeCheckout() {
      self.updateContentInsets()
    }
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  private var initialTopConstraint: CGFloat {
    if #available(iOS 11.0, *) {
      return parent?.view.safeAreaInsets.top ?? 0.0
    } else {
      return UIApplication.shared.statusBarFrame.size.height
    }
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self.backThisProjectContainerView
      |> \.layoutMargins .~ .init(all: backThisProjectContainerViewMargins)

    _ = self.backThisProjectContainerView.layer
      |> checkoutLayerCardStyleRounded
      |> \.backgroundColor .~ UIColor.white.cgColor
      |> \.shadowColor .~ UIColor.black.cgColor
      |> \.shadowOpacity .~ 0.12
      |> \.shadowOffset .~ CGSize(width: 0, height: -1.0)
      |> \.shadowRadius .~ 1.0

    if #available(iOS 11.0, *) {
      _ = self.backThisProjectContainerView.layer
        |> \.maskedCorners .~ [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    _ = self.backThisProjectButton
      |> checkoutGreenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in
        return Strings.project_back_button()
    }

    _ = self.backThisProjectButton.titleLabel
      ?|> checkoutGreenButtonTitleLabelStyle
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToRewards
      .observeForControllerAction()
      .observeValues { [weak self] params in
        let (project, refTag) = params

        self?.goToRewards(project: project, refTag: refTag)
    }

    self.viewModel.outputs.configureChildViewControllersWithProjectAndLiveStreams
      .observeForUI()
      .observeValues { [weak self] project, liveStreamEvents, refTag in
        self?.contentController.configureWith(project: project, liveStreamEvents: liveStreamEvents)
        self?.navBarController.configureWith(project: project, refTag: refTag)
    }

    self.viewModel.outputs.setNavigationBarHiddenAnimated
      .observeForUI()
      .observeValues { [weak self] in self?.navigationController?.setNavigationBarHidden($0, animated: $1) }

    self.viewModel.outputs.setNeedsStatusBarAppearanceUpdate
      .observeForUI()
      .observeValues { [weak self] in
        UIView.animate(withDuration: 0.3) { self?.setNeedsStatusBarAppearanceUpdate() }
    }

    self.viewModel.outputs.topLayoutConstraintConstant
      .observeForUI()
      .observeValues { [weak self] value in
        self?.navBarTopConstraint.constant = value
    }
  }

  public override func willTransition(to newCollection: UITraitCollection,
                                      with coordinator: UIViewControllerTransitionCoordinator) {
    self.viewModel.inputs.willTransition(toNewCollection: newCollection)
  }

  // MARK: - Private View Setup Functions

  private func configureViews() {
    // Configure subviews
    self.backThisProjectContainerView.addSubview(self.backThisProjectButton)

    self.view.addSubview(self.backThisProjectContainerView)

    self.backThisProjectButton.addTarget(self, action: #selector(backThisProjectTapped), for: .touchUpInside)

    // Configure constraints
    let backThisProjectContainerViewConstraints = [
      self.backThisProjectContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.backThisProjectContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.backThisProjectContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ]

    let containerMargins = self.backThisProjectContainerView.layoutMarginsGuide
    let minHeight = Styles.minTouchSize.height

    let backThisProjectButtonConstraints = [
      self.backThisProjectButton.leftAnchor.constraint(equalTo: containerMargins.leftAnchor),
      self.backThisProjectButton.rightAnchor.constraint(equalTo: containerMargins.rightAnchor),
      self.backThisProjectButton.bottomAnchor.constraint(equalTo: containerMargins.bottomAnchor),
      self.backThisProjectButton.topAnchor.constraint(equalTo: containerMargins.topAnchor),
      self.backThisProjectButton.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
    ]

    NSLayoutConstraint.activate(backThisProjectContainerViewConstraints + backThisProjectButtonConstraints)
  }

  // MARK: - Private Helpers

  private func setInitial(constraints: [NSLayoutConstraint?], constant: CGFloat) {
    constraints.forEach {
      $0?.constant = constant
    }
  }

  private func goToRewards(project: Project, refTag: RefTag?) {
    self.delegate?.projectPamphletViewController(self,
                                                 didTapBackThisProject: project,
                                                 refTag: refTag)
  }

  private func shouldShowNativeCheckout() -> Bool {
    // Show native checkout only if the `ios_native_checkout` flag is enabled
    return AppEnvironment.current.config?.features[Feature.checkout.rawValue] == .some(true)
  }

  private func updateContentInsets() {
    let buttonSize = self.backThisProjectButton.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    let bottomInset = buttonSize.height + 2 * self.backThisProjectContainerViewMargins

    if #available(iOS 11.0, *) {
      self.contentController.additionalSafeAreaInsets = UIEdgeInsets(bottom: bottomInset)
    } else {
      let insets = self.contentController.tableView.contentInset

      self.contentController.tableView.contentInset = UIEdgeInsets(top: insets.top,
                                                                   left: insets.left,
                                                                   bottom: bottomInset,
                                                                   right: insets.right)
    }
  }

  // MARK: - Selectors

  @objc func backThisProjectTapped() {
    self.viewModel.inputs.backThisProjectTapped()
  }
}

extension ProjectPamphletViewController: ProjectPamphletContentViewControllerDelegate {
  public func projectPamphletContent(_ controller: ProjectPamphletContentViewController,
                                     didScrollToTop: Bool) {
    self.navBarController.setDidScrollToTop(didScrollToTop)
  }

  public func projectPamphletContent(_ controller: ProjectPamphletContentViewController,
                                     imageIsVisible: Bool) {
    self.navBarController.setProjectImageIsVisible(imageIsVisible)
  }

  public func projectPamphletContent(
    _ controller: ProjectPamphletContentViewController,
    scrollViewPanGestureRecognizerDidChange recognizer: UIPanGestureRecognizer) {

      self.delegate?.projectPamphlet(self, panGestureRecognizerDidChange: recognizer)
  }
}

extension ProjectPamphletViewController: VideoViewControllerDelegate {
  public func videoViewControllerDidFinish(_ controller: VideoViewController) {
    self.navBarController.projectVideoDidFinish()
  }

  public func videoViewControllerDidStart(_ controller: VideoViewController) {
    self.navBarController.projectVideoDidStart()
  }
}

extension ProjectPamphletViewController: ProjectNavBarViewControllerDelegate {
  public func projectNavBarControllerDidTapTitle(_ controller: ProjectNavBarViewController) {
    self.contentController.tableView.scrollToTop()
  }
}
