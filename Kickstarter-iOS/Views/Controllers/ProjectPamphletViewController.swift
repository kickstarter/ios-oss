import KsApi
import Library
import Prelude
import UIKit

public protocol ProjectPamphletViewControllerDelegate: AnyObject {
  func projectPamphlet(
    _ controller: ProjectPamphletViewController,
    panGestureRecognizerDidChange recognizer: UIPanGestureRecognizer
  )
  func projectPamphletViewController(
    _ projectPamphletViewController: ProjectPamphletViewController,
    didTapBackThisProject project: Project,
    refTag: RefTag?
  )
  func deprecatedProjectPamphletViewController(
    _ projectPamphletViewController: ProjectPamphletViewController,
    didTapBackThisProject project: Project,
    refTag: RefTag?
  )
}

public final class ProjectPamphletViewController: UIViewController {
  internal weak var delegate: ProjectPamphletViewControllerDelegate?
  fileprivate let viewModel: ProjectPamphletViewModelType = ProjectPamphletViewModel()

  fileprivate var navBarController: ProjectNavBarViewController!
  fileprivate var contentController: ProjectPamphletContentViewController!

  @IBOutlet private var navBarTopConstraint: NSLayoutConstraint!

  private let pledgeCTAContainerViewMargins = Styles.grid(3)
  private let pledgeCTAContainerView: PledgeCTAContainerView = {
    PledgeCTAContainerView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  public static func configuredWith(
    projectOrParam: Either<Project, Param>,
    refTag: RefTag?
  ) -> ProjectPamphletViewController {
    let vc = Storyboard.ProjectPamphlet.instantiate(ProjectPamphletViewController.self)
    vc.viewModel.inputs.configureWith(projectOrParam: projectOrParam, refTag: refTag)
    return vc
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    if featureNativeCheckoutEnabled() {
      self.configurePledgeCTAContainerView()
    }

    self.navBarController = self.children
      .compactMap { $0 as? ProjectNavBarViewController }.first
    self.navBarController.delegate = self

    self.contentController = self.children
      .compactMap { $0 as? ProjectPamphletContentViewController }.first
    self.contentController.delegate = self

    self.viewModel.inputs.initial(topConstraint: self.initialTopConstraint)

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.setInitial(
      constraints: [navBarTopConstraint],
      constant: self.initialTopConstraint
    )

    if featureNativeCheckoutEnabled() {
      self.updateContentInsets()
    }
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  private var initialTopConstraint: CGFloat {
    return self.parent?.view.safeAreaInsets.top ?? 0.0
  }

  private func configurePledgeCTAContainerView() {
    // Configure subviews
    _ = (self.pledgeCTAContainerView, self.view)
      |> ksr_addSubviewToParent()

    self.pledgeCTAContainerView.pledgeCTAButton.addTarget(
      self, action: #selector(ProjectPamphletViewController.backThisProjectTapped), for: .touchUpInside
    )

    // Configure constraints
    let pledgeCTAContainerViewConstraints = [
      self.pledgeCTAContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.pledgeCTAContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.pledgeCTAContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ]

    NSLayoutConstraint.activate(pledgeCTAContainerViewConstraints)
  }

  public override func bindStyles() {
    super.bindStyles()

    if featureNativeCheckoutEnabled() {
      _ = self.pledgeCTAContainerView
        |> \.layoutMargins .~ .init(all: self.pledgeCTAContainerViewMargins)

      _ = self.pledgeCTAContainerView.layer
        |> checkoutLayerCardRoundedStyle
        |> \.backgroundColor .~ UIColor.white.cgColor
        |> \.shadowColor .~ UIColor.black.cgColor
        |> \.shadowOpacity .~ 0.12
        |> \.shadowOffset .~ CGSize(width: 0, height: -1.0)
        |> \.shadowRadius .~ 1.0
        |> \.maskedCorners .~ [CACornerMask.layerMaxXMinYCorner, CACornerMask.layerMinXMinYCorner]
    }
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToRewards
      .observeForControllerAction()
      .observeValues { [weak self] params in
        let (project, refTag) = params

        self?.goToRewards(project: project, refTag: refTag)
      }

    self.viewModel.outputs.goToDeprecatedRewards
      .observeForControllerAction()
      .observeValues { [weak self] params in
        let (project, refTag) = params

        self?.goToDeprecatedRewards(project: project, refTag: refTag)
      }

    self.viewModel.outputs.configureChildViewControllersWithProject
      .observeForUI()
      .observeValues { [weak self] project, refTag in
        self?.contentController.configureWith(project: project)
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

    self.viewModel.outputs.configurePledgeCTAView
      .observeForUI()
      .observeValues { [weak self] value in
        self?.pledgeCTAContainerView.configureWith(value: value)
      }
  }

  public override func willTransition(
    to newCollection: UITraitCollection,
    with _: UIViewControllerTransitionCoordinator
  ) {
    self.viewModel.inputs.willTransition(toNewCollection: newCollection)
  }

  // MARK: - Private Helpers

  private func setInitial(constraints: [NSLayoutConstraint?], constant: CGFloat) {
    constraints.forEach {
      $0?.constant = constant
    }
  }

  private func goToDeprecatedRewards(project: Project, refTag: RefTag?) {
    self.delegate?.deprecatedProjectPamphletViewController(
      self,
      didTapBackThisProject: project,
      refTag: refTag
    )
  }

  private func goToRewards(project: Project, refTag: RefTag?) {
    self.delegate?.projectPamphletViewController(
      self,
      didTapBackThisProject: project,
      refTag: refTag
    )
  }

  private func updateContentInsets() {
    let buttonSize = self.pledgeCTAContainerView.pledgeCTAButton.systemLayoutSizeFitting(
      UIView.layoutFittingCompressedSize
    )
    let bottomInset = buttonSize.height + 2 * self.pledgeCTAContainerViewMargins

    self.contentController.additionalSafeAreaInsets = UIEdgeInsets(bottom: bottomInset)
  }

  // MARK: - Selectors

  @objc func backThisProjectTapped() {
    self.viewModel.inputs.backThisProjectTapped()
  }
}

extension ProjectPamphletViewController: ProjectPamphletContentViewControllerDelegate {
  public func projectPamphletContent(
    _: ProjectPamphletContentViewController,
    didScrollToTop: Bool
  ) {
    self.navBarController.setDidScrollToTop(didScrollToTop)
  }

  public func projectPamphletContent(
    _: ProjectPamphletContentViewController,
    imageIsVisible: Bool
  ) {
    self.navBarController.setProjectImageIsVisible(imageIsVisible)
  }

  public func projectPamphletContent(
    _: ProjectPamphletContentViewController,
    scrollViewPanGestureRecognizerDidChange recognizer: UIPanGestureRecognizer
  ) {
    self.delegate?.projectPamphlet(self, panGestureRecognizerDidChange: recognizer)
  }
}

extension ProjectPamphletViewController: VideoViewControllerDelegate {
  public func videoViewControllerDidFinish(_: VideoViewController) {
    self.navBarController.projectVideoDidFinish()
  }

  public func videoViewControllerDidStart(_: VideoViewController) {
    self.navBarController.projectVideoDidStart()
  }
}

extension ProjectPamphletViewController: ProjectNavBarViewControllerDelegate {
  public func projectNavBarControllerDidTapTitle(_: ProjectNavBarViewController) {
    self.contentController.tableView.scrollToTop()
  }
}
