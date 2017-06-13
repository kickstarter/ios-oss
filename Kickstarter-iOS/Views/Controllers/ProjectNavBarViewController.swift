import KsApi
import Library
import Prelude
import Social
import UIKit

public protocol ProjectNavBarViewControllerDelegate: class {
  func projectNavBarControllerDidTapTitle(_ controller: ProjectNavBarViewController)
}

public final class ProjectNavBarViewController: UIViewController {
  internal weak var delegate: ProjectNavBarViewControllerDelegate?
  fileprivate let viewModel: ProjectNavBarViewModelType = ProjectNavBarViewModel()
  fileprivate let shareViewModel: ShareViewModelType = ShareViewModel()

  @IBOutlet fileprivate weak var backgroundGradientView: GradientView!
  @IBOutlet fileprivate weak var categoryButton: UIButton!
  @IBOutlet fileprivate weak var closeButton: UIButton!
  @IBOutlet fileprivate weak var navContainerView: UIView!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!
  @IBOutlet fileprivate weak var shareButton: UIButton!
  @IBOutlet fileprivate weak var starButton: UIButton!

  internal func configureWith(project: Project, refTag: RefTag?) {
    self.viewModel.inputs.configureWith(project: project, refTag: refTag)
    self.shareViewModel.inputs.configureWith(shareContext: .project(project), shareContextView: nil)
  }

  internal func setProjectImageIsVisible(_ visible: Bool) {
    self.viewModel.inputs.projectImageIsVisible(visible)
  }

  internal func projectVideoDidFinish() {
    self.viewModel.inputs.projectVideoDidFinish()
  }

  internal func projectVideoDidStart() {
    self.viewModel.inputs.projectVideoDidStart()
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    self.shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    self.starButton.addTarget(self, action: #selector(starButtonTapped), for: .touchUpInside)
    self.projectNameLabel.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(projectNameTapped))
    )

    NotificationCenter
      .default
      .addObserver(forName: Notification.Name.ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    NotificationCenter
      .default
      .addObserver(forName: Notification.Name.ksr_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
    }

    self.viewModel.inputs.viewDidLoad()
  }

    public override func bindStyles() {
    super.bindStyles()

    self.backgroundGradientView.startPoint = .zero
    self.backgroundGradientView.endPoint = CGPoint(x: 0, y: 1)
    self.backgroundGradientView.setGradient([
      (UIColor(white: 0, alpha: 0.5), 0),
      (UIColor(white: 0, alpha: 0), 1)
    ])

    _ = self.categoryButton
      |> roundedStyle(cornerRadius: 12)
      |> UIButton.lens.titleEdgeInsets
        .~ .init(top: 0, left: Styles.grid(1), bottom: 0, right: Styles.grid(-1))
      |> UIButton.lens.contentEdgeInsets
        .~ .init(top: Styles.grid(1), left: Styles.grid(2), bottom: Styles.grid(1), right: Styles.grid(3))
      |> UIButton.lens.image(forState: .normal) .~ image(named: "category-icon")
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 12)
      |> (UIButton.lens.titleLabel..UILabel.lens.lineBreakMode) .~ .byTruncatingTail
      |> UIButton.lens.backgroundColor(forState: .normal) .~ .init(white: 1.0, alpha: 0.8)
      //|> UIButton.lens.backgroundColor(forState: .highlighted) .~ .init(white: 0.0, alpha: 0.1)
      |> UIButton.lens.adjustsImageWhenHighlighted .~ true
      |> UIButton.lens.adjustsImageWhenDisabled .~ true
      |> UIButton.lens.userInteractionEnabled .~ false
      |> UIButton.lens.accessibilityTraits .~ UIAccessibilityTraitStaticText

    _ = self.closeButton
      |> UIButton.lens.title(forState: .normal) .~ nil
      |> UIButton.lens.image(forState: .normal) .~ image(named: "close-icon")
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.accessibility_projects_buttons_close() }
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.Closes_project() }

    _ = self.navContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.gridHalf(1))

    _ = self.projectNameLabel
      |> UILabel.lens.font .~ .ksr_body(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.textAlignment .~ .center
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.minimumScaleFactor .~ 0.8
      |> UILabel.lens.adjustsFontSizeToFitWidth .~ true
      |> UILabel.lens.userInteractionEnabled .~ true

    _ = self.shareButton
      |> shareButtonStyle

    _ = self.starButton
      |> saveButtonStyle
  }
  // swiftlint:enable function_body_length

    public override func bindViewModel() {
    super.bindViewModel()

    self.categoryButton.rac.tintColor = self.viewModel.outputs.categoryButtonTintColor
    self.viewModel.outputs.categoryButtonTitleColor
      .observeForUI()
      .observeValues { [weak self] in self?.categoryButton.setTitleColor($0, for: .normal) }
    self.categoryButton.rac.title = self.viewModel.outputs.categoryButtonText
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.starButton.rac.accessibilityHint = self.viewModel.outputs.starButtonAccessibilityHint
    self.starButton.rac.selected = self.viewModel.outputs.starButtonSelected

    self.viewModel.outputs.showProjectStarredPrompt
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.showProjectStarredPrompt(message: $0)
    }

    self.viewModel.outputs.goToLoginTout
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToLoginTout()
    }

    self.viewModel.outputs.categoryHiddenAndAnimate
      .observeForUI()
      .observeValues { [weak self] hidden, animate in
        UIView.animate(withDuration: animate ? 0.2 : 0) {
          self?.categoryButton.alpha = hidden ? 0 : 1
        }
    }

    self.viewModel.outputs.titleHiddenAndAnimate
      .observeForUI()
      .observeValues { [weak self] hidden, animate in
        UIView.animate(withDuration: animate ? 0.2 : 0) {
          self?.projectNameLabel.alpha = hidden ? 0 : 1
        }
    }

    self.viewModel.outputs.backgroundOpaqueAndAnimate
      .observeForUI()
      .observeValues { [weak self] opaque, animate in
        UIView.animate(withDuration: animate ? 0.2 : 0) {
          self?.closeButton.tintColor = opaque ? .ksr_text_navy_700 : .white
          self?.shareButton.tintColor = opaque ? .ksr_text_navy_700 : .white
          self?.starButton.tintColor = opaque ? .ksr_text_navy_700 : .white
          self?.navContainerView.backgroundColor = opaque ? .white : .clear
        }
    }

    self.viewModel.outputs.dismissViewController
      .observeForUI()
      .observeValues { [weak self] in
        self?.dismiss(animated: true, completion: nil)
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] controller, _ in self?.showShareSheet(controller) }
  }
  // swiftlint:enable function_body_length

  fileprivate func showProjectStarredPrompt(message: String) {
    let alert = UIAlertController.alert(nil, message: message, handler: nil)
    self.present(alert, animated: true, completion: nil)
  }

  fileprivate func goToLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .starProject)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func showShareSheet(_ controller: UIActivityViewController) {

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
      let popover = controller.popoverPresentationController
      popover?.sourceView = self.shareButton
    }

    self.present(controller, animated: true, completion: nil)
  }

  @objc fileprivate func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc fileprivate func shareButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @objc fileprivate func starButtonTapped() {
    self.viewModel.inputs.starButtonTapped()
  }

  @objc fileprivate func projectNameTapped() {
    self.delegate?.projectNavBarControllerDidTapTitle(self)
  }
}
