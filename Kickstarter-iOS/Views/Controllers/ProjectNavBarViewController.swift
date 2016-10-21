import KsApi
import Library
import Prelude
import Social
import UIKit

internal protocol ProjectNavBarViewControllerDelegate: class {
  func projectNavBarControllerDidTapTitle(controller: ProjectNavBarViewController)
}

internal final class ProjectNavBarViewController: UIViewController {
  internal var delegate: ProjectNavBarViewControllerDelegate?
  private let viewModel: ProjectNavBarViewModelType = ProjectNavBarViewModel()
  private let shareViewModel: ShareViewModelType = ShareViewModel()

  @IBOutlet private weak var backgroundGradientView: GradientView!
  @IBOutlet private weak var categoryButton: UIButton!
  @IBOutlet private weak var closeButton: UIButton!
  @IBOutlet private weak var navContainerView: UIView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var shareButton: UIButton!
  @IBOutlet private weak var starButton: UIButton!

  internal func configureWith(project project: Project) {
    self.viewModel.inputs.configureWith(project: project)
    self.shareViewModel.inputs.configureWith(shareContext: .project(project))
  }

  internal func setProjectImageIsVisible(visible: Bool) {
    self.viewModel.inputs.projectImageIsVisible(visible)
  }

  internal func projectVideoDidFinish() {
    self.viewModel.inputs.projectVideoDidFinish()
  }

  internal func projectVideoDidStart() {
    self.viewModel.inputs.projectVideoDidStart()
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.closeButton.addTarget(self, action: #selector(closeButtonTapped), forControlEvents: .TouchUpInside)
    self.shareButton.addTarget(self, action: #selector(shareButtonTapped), forControlEvents: .TouchUpInside)
    self.starButton.addTarget(self, action: #selector(starButtonTapped), forControlEvents: .TouchUpInside)
    self.projectNameLabel.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(projectNameTapped))
    )

    NSNotificationCenter
      .defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    NSNotificationCenter
      .defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
    }

    self.viewModel.inputs.viewDidLoad()
  }

  // swiftlint:disable function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    self.backgroundGradientView.startPoint = .zero
    self.backgroundGradientView.endPoint = CGPoint(x: 0, y: 1)
    self.backgroundGradientView.setGradient([
      (UIColor(white: 0, alpha: 0.5), 0),
      (UIColor(white: 0, alpha: 0), 1)
    ])

    self.categoryButton
      |> roundedStyle(cornerRadius: 12)
      |> UIButton.lens.titleEdgeInsets
        .~ .init(top: 0, left: Styles.grid(1), bottom: 0, right: Styles.grid(-1))
      |> UIButton.lens.contentEdgeInsets
        .~ .init(top: Styles.grid(1), left: Styles.grid(2), bottom: Styles.grid(1), right: Styles.grid(3))
      |> UIButton.lens.image(forState: .Normal) .~ image(named: "category-icon")
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 12)
      |> (UIButton.lens.titleLabel • UILabel.lens.lineBreakMode) .~ .ByTruncatingTail
      |> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .init(white: 0, alpha: 0.1)
      |> UIButton.lens.adjustsImageWhenHighlighted .~ true
      |> UIButton.lens.adjustsImageWhenDisabled .~ true
      |> UIButton.lens.userInteractionEnabled .~ false
      |> UIButton.lens.accessibilityTraits .~ UIAccessibilityTraitStaticText

    self.closeButton
      |> UIButton.lens.title(forState: .Normal) .~ nil
      |> UIButton.lens.tintColor .~ .whiteColor()
      |> UIButton.lens.image(forState: .Normal) .~ image(named: "close-icon")
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.accessibility_projects_buttons_close() }

    self.navContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.gridHalf(1))

    self.projectNameLabel
      |> UILabel.lens.font .~ .ksr_body(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.textAlignment .~ .Center
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.minimumScaleFactor .~ 0.8
      |> UILabel.lens.adjustsFontSizeToFitWidth .~ true
      |> UILabel.lens.userInteractionEnabled .~ true

    self.shareButton
      |> UIButton.lens.title(forState: .Normal) .~ nil
      |> UIButton.lens.tintColor .~ .whiteColor()
      |> UIButton.lens.image(forState: .Normal) .~ image(named: "share-icon")
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.dashboard_accessibility_label_share_project() }

    self.starButton
      |> UIButton.lens.title(forState: .Normal) .~ nil
      |> UIButton.lens.tintColor .~ .whiteColor()
      |> UIButton.lens.image(forState: .Normal) .~ image(named: "star-icon")
      |> UIButton.lens.image(forState: .Highlighted) .~ image(named: "star-filled-icon")
      |> UIButton.lens.image(forState: .Selected) .~ image(named: "star-filled-icon")
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.project_accessibility_button_star_label() }
  }
  // swiftlint:enable function_body_length

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.categoryButton.rac.backgroundColor = self.viewModel.outputs.categoryButtonBackgroundColor
    self.categoryButton.rac.tintColor = self.viewModel.outputs.categoryButtonTintColor
    self.viewModel.outputs.categoryButtonTitleColor
      .observeForUI()
      .observeNext { [weak self] in self?.categoryButton.setTitleColor($0, forState: .Normal) }
    self.categoryButton.rac.title = self.viewModel.outputs.categoryButtonText
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.starButton.rac.accessibilityHint = self.viewModel.outputs.starButtonAccessibilityHint
    self.starButton.rac.selected = self.viewModel.outputs.starButtonSelected

    self.viewModel.outputs.showProjectStarredPrompt
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.showProjectStarredPrompt(message: $0)
    }

    self.viewModel.outputs.goToLoginTout
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.goToLoginTout()
    }

    self.viewModel.outputs.categoryHiddenAndAnimate
      .observeForUI()
      .observeNext { [weak self] hidden, animate in
        UIView.animateWithDuration(animate ? 0.2 : 0) {
          self?.categoryButton.alpha = hidden ? 0 : 1
        }
    }

    self.viewModel.outputs.titleHiddenAndAnimate
      .observeForUI()
      .observeNext { [weak self] hidden, animate in
        UIView.animateWithDuration(animate ? 0.2 : 0) {
          self?.projectNameLabel.alpha = hidden ? 0 : 1
        }
    }

    self.viewModel.outputs.backgroundOpaqueAndAnimate
      .observeForUI()
      .observeNext { [weak self] opaque, animate in
        UIView.animateWithDuration(animate ? 0.2 : 0) {
          self?.closeButton.tintColor = opaque ? .ksr_text_navy_700 : .whiteColor()
          self?.shareButton.tintColor = opaque ? .ksr_text_navy_700 : .whiteColor()
          self?.starButton.tintColor = opaque ? .ksr_text_navy_700 : .whiteColor()
          self?.navContainerView.backgroundColor = opaque ? .whiteColor() : .clearColor()
        }
    }

    self.viewModel.outputs.dismissViewController
      .observeForUI()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(true, completion: nil)
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeNext { [weak self] in self?.showShareSheet($0) }

    self.shareViewModel.outputs.showShareCompose
      .observeForControllerAction()
      .observeNext { [weak self] in self?.showShareCompose($0) }
  }
  // swiftlint:enable function_body_length

  private func showProjectStarredPrompt(message message: String) {
    let alert = UIAlertController.alert(nil, message: message, handler: nil)
    self.presentViewController(alert, animated: true, completion: nil)
  }

  private func goToLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .starProject)
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  private func showShareSheet(controller: UIActivityViewController) {
    controller.completionWithItemsHandler = { [weak self] in
      self?.shareViewModel.inputs.shareActivityCompletion(activityType: $0,
                                                          completed: $1,
                                                          returnedItems: $2,
                                                          activityError: $3)
    }

    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      controller.modalPresentationStyle = .Popover
      let popover = controller.popoverPresentationController
      popover?.sourceView = self.shareButton
    }

    self.presentViewController(controller, animated: true, completion: nil)
  }

  private func showShareCompose(controller: SLComposeViewController) {
    controller.completionHandler = { [weak self] in
      self?.shareViewModel.inputs.shareComposeCompletion(result: $0)
    }
    self.presentViewController(controller, animated: true, completion: nil)
  }

  @objc private func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc private func shareButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @objc private func starButtonTapped() {
    self.viewModel.inputs.starButtonTapped()
  }

  @objc private func projectNameTapped() {
    self.delegate?.projectNavBarControllerDidTapTitle(self)
  }
}
