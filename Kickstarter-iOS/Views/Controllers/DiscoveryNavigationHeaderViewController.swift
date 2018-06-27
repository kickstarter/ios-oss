import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol DiscoveryNavigationHeaderViewDelegate: class {
  /// Call to update params when filter selected.
  func discoveryNavigationHeaderFilterSelectedParams(_ params: DiscoveryParams)
}

internal final class DiscoveryNavigationHeaderViewController: UIViewController {
  fileprivate let viewModel: DiscoveryNavigationHeaderViewModelType = DiscoveryNavigationHeaderViewModel()

  @IBOutlet fileprivate weak var arrowImageView: UIImageView!
  @IBOutlet fileprivate weak var bgView: UIView!
  @IBOutlet fileprivate weak var bookmarkImageView: UIImageView!
  @IBOutlet fileprivate weak var bookmarkOutlineImageView: UIImageView!
  @IBOutlet fileprivate weak var debugContainerView: UIView!
  @IBOutlet fileprivate weak var debugImageView: UIImageView!
  @IBOutlet fileprivate weak var dividerLabel: UILabel!
  @IBOutlet fileprivate weak var environmentSwitcherButton: UIButton!
  @IBOutlet fileprivate weak var exploreLabel: UILabel!
  @IBOutlet fileprivate weak var favoriteButton: UIButton!
  @IBOutlet fileprivate weak var favoriteContainerView: UIView!
  @IBOutlet fileprivate weak var primaryLabel: UILabel!
  @IBOutlet fileprivate weak var secondaryLabel: UILabel!
  @IBOutlet fileprivate weak var titleButton: UIButton!
  @IBOutlet fileprivate weak var containerStackView: UIStackView!
  @IBOutlet fileprivate weak var outerStackViewTopConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var titleStackView: UIStackView! {
    didSet {
      titleStackView.pinBackground()
    }
  }

  internal weak var delegate: DiscoveryNavigationHeaderViewDelegate?

  internal static func instantiate() -> DiscoveryNavigationHeaderViewController {
    return Storyboard.Discovery.instantiate(DiscoveryNavigationHeaderViewController.self)
  }

  internal func configureWith(params: DiscoveryParams) {
    self.viewModel.inputs.configureWith(params: params)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.environmentSwitcherButton.addTarget(self,
                                             action: #selector(environmentSwitcherTapped),
                                             for: .touchUpInside)

    self.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped),
                                  for: .touchUpInside)

    self.titleButton.addTarget(self, action: #selector(titleButtonTapped), for: .touchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

    internal override func bindViewModel() {
    super.bindViewModel()

    self.debugContainerView.rac.hidden = self.viewModel.outputs.debugContainerViewIsHidden
    self.exploreLabel.rac.hidden = self.viewModel.outputs.exploreLabelIsHidden
    self.favoriteContainerView.rac.hidden = self.viewModel.outputs.favoriteViewIsHidden
    self.favoriteButton.rac.accessibilityLabel = self.viewModel.outputs.favoriteButtonAccessibilityLabel
    self.primaryLabel.rac.text = self.viewModel.outputs.primaryLabelText
    self.secondaryLabel.rac.text = self.viewModel.outputs.secondaryLabelText
    self.secondaryLabel.rac.hidden = self.viewModel.outputs.secondaryLabelIsHidden
    self.dividerLabel.rac.hidden = self.viewModel.outputs.dividerIsHidden
    self.titleButton.rac.accessibilityLabel = self.viewModel.outputs.titleButtonAccessibilityLabel
    self.titleButton.rac.accessibilityHint = self.viewModel.outputs.titleButtonAccessibilityHint

    self.viewModel.outputs.primaryLabelOpacityAnimated
      .observeForUI()
      .observeValues { [weak self] (alpha, animated) in
        UIView.animate(withDuration: animated ? 0.2 : 0.0, delay: 0.0, options: .curveEaseOut, animations: {
          self?.primaryLabel.alpha = alpha
          },
          completion: nil)
    }

    self.viewModel.outputs.logoutWithParams
      .observeForUI()
      .observeValues { [weak self] in
        self?.logout(params: $0)
      }

    self.viewModel.outputs.arrowOpacityAnimated
      .observeForUI()
      .observeValues { [weak self] (alpha, animated) in
        UIView.animate(withDuration: animated ? 0.2 : 0.0, delay: 0.0, options: .curveEaseOut, animations: {
          self?.arrowImageView.alpha = alpha
          },
          completion: nil)
    }

    self.viewModel.outputs.primaryLabelFont
      .observeForUI()
      .observeValues { [weak self] isBold in
        guard let label = self?.primaryLabel else { return }

        _ = label
          |> UILabel.lens.font %~~ { _, label in
            label.traitCollection.isRegularRegular
              ? isBold ? UIFont.ksr_body(size: 18).bolded : UIFont.ksr_body(size: 18)
              : isBold ? UIFont.ksr_callout().bolded : UIFont.ksr_callout()
        }
    }

    self.viewModel.outputs.animateArrowToDown
      .observeForUI()
      .observeValues { [weak self] in
        self?.animateArrow(toDown: $0)
    }

    self.viewModel.outputs.updateFavoriteButton
      .observeForUI()
      .observeValues { [weak self] in
        self?.updateFavoriteButton(selected: $0, animated: $1)
    }

    self.viewModel.outputs.notifyDelegateFilterSelectedParams
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.discoveryNavigationHeaderFilterSelectedParams($0)
    }

    self.viewModel.outputs.showDiscoveryFilters
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.showDiscoveryFilters(selectedRow: $0)
    }

    self.viewModel.outputs.dismissDiscoveryFilters
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: false, completion: nil)
    }

    self.viewModel.outputs.showFavoriteOnboardingAlert
      .observeForUI()
      .observeValues { [weak self] in
        self?.showFavoriteCategoriesAlert(categoryName: $0)
    }

    self.viewModel.outputs.favoriteViewIsDimmed
      .observeForUI()
      .observeValues { [weak self] isDimmed in
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
          self?.favoriteContainerView.alpha = isDimmed ? 0.4 : 1.0
        },
        completion: nil)
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.arrowImageView
      |> UIView.lens.tintColor .~ discoveryPrimaryColor()

    _ = self.bgView
      |> UIView.lens.backgroundColor .~ .white

    _ = self.dividerLabel
      |> discoveryNavDividerLabelStyle
      |> UILabel.lens.isAccessibilityElement .~ false
      |> UILabel.lens.textColor .~ discoveryPrimaryColor()

    _ = self.exploreLabel
      |> UILabel.lens.font %~~ { _, label in
          label.traitCollection.isRegularRegular
            ? .ksr_body(size: 18)
            : .ksr_body(size: 17)
      }
      |> UILabel.lens.text %~ { _ in Strings.Explore() }

    _ = self.favoriteContainerView
      |> UIView.lens.layoutMargins .~ .init(left: Styles.grid(2))

    _ = self.bookmarkImageView
      |> UIView.lens.tintColor .~ discoveryPrimaryColor()

    _ = self.bookmarkOutlineImageView
      |> UIView.lens.tintColor .~ discoveryPrimaryColor()

    _ = self.debugImageView
      |> UIImageView.lens.image .~ image(named: "icon--debug")

    _ = self.primaryLabel
      |> UILabel.lens.isAccessibilityElement .~ false
      |> UILabel.lens.textColor .~ discoveryPrimaryColor()
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? UIFont.ksr_body(size: 18)
          : UIFont.ksr_body(size: 17)
    }

    _ = self.secondaryLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? UIFont.ksr_body(size: 18).bolded
          : UIFont.ksr_callout().bolded
      }
      |> UILabel.lens.isAccessibilityElement .~ false
      |> UILabel.lens.textColor .~ discoveryPrimaryColor()

    _ = self.containerStackView
      |> discoveryNavTitleStackViewStyle

    if self.view.traitCollection.isRegularRegular {
      self.outerStackViewTopConstraint.constant = -6.0
    }
  }

  fileprivate func showDiscoveryFilters(selectedRow: SelectableRow) {
    let vc = DiscoveryFiltersViewController.configuredWith(selectedRow: selectedRow)
    vc.delegate = self
    vc.modalPresentationStyle = .overFullScreen
    self.present(vc, animated: false, completion: nil)
  }

  fileprivate func showFavoriteCategoriesAlert(categoryName: String) {
    let alertController = UIAlertController(
      title: categoryName,
      message: Strings.To_access_all_your_favorite_categories_tap_the_explore_dropdown(),
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.discovery_favorite_categories_alert_buttons_got_it(),
        style: .cancel,
        handler: nil
      )
    )

    self.present(alertController, animated: true, completion: nil)
  }

  fileprivate func animateArrow(toDown: Bool) {
    let scale: CGFloat = toDown ? 1.0 : -1.0

    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
      self.arrowImageView.transform = CGAffineTransform(scaleX: 1.0, y: scale)
     },
     completion: nil)
  }

    fileprivate func updateFavoriteButton(selected: Bool, animated: Bool) {
    let duration = animated ? 0.4 : 0.0

    if selected {
      self.bookmarkImageView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)

      UIView.animate(
        withDuration: duration,
        delay: 0.0,
        usingSpringWithDamping: 0.6,
        initialSpringVelocity: 0.8,
        options: .curveEaseOut,
        animations: {
         self.bookmarkImageView.alpha = 1.0
         self.bookmarkImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
         self.bookmarkOutlineImageView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
         },
        completion: nil
      )

      UIView.animate(
        withDuration: duration,
        delay: animated ? 0.1 : 0.0,
        usingSpringWithDamping: 0.6,
        initialSpringVelocity: 0.8,
        options: .curveEaseOut,
        animations: {
        self.bookmarkOutlineImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
          self.bookmarkOutlineImageView.alpha = 0.0
        },
        completion: nil
      )
    } else {
      UIView.animate(
        withDuration: duration,
        delay: 0.0,
        usingSpringWithDamping: 0.6,
        initialSpringVelocity: 0.8,
        options: .curveEaseOut,
        animations: {
         self.bookmarkImageView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
         self.bookmarkOutlineImageView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
         self.bookmarkOutlineImageView.alpha = 1.0
        },
        completion: nil
      )

      UIView.animate(
        withDuration: duration,
        delay: animated ? 0.1 : 0.0,
        usingSpringWithDamping: 0.6,
        initialSpringVelocity: 0.8,
        options: .curveEaseOut,
        animations: {
         self.bookmarkOutlineImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        },
        completion: { _ in
         self.bookmarkImageView.alpha = 0.0
        }
      )
    }
  }

  @objc fileprivate func environmentSwitcherTapped() {
    self.showEnvironmentActionSheet()
  }

  @objc fileprivate func titleButtonTapped() {
    self.viewModel.inputs.titleButtonTapped()
  }

  @objc fileprivate func favoriteButtonTapped() {
    self.viewModel.inputs.favoriteButtonTapped()
  }

  private func showEnvironmentActionSheet() {

    let alert = UIAlertController(
      title: "Change Environment (\(AppEnvironment.current.apiService.serverConfig.environment.rawValue))",
      message: nil,
      preferredStyle: .actionSheet
    )

    EnvironmentType.allCases.forEach { environment in
      alert.addAction(UIAlertAction(title: environment.rawValue, style: .default) { [weak self] _ in
        self?.viewModel.inputs.environmentSwitcherButtonTapped(environment: environment)
      })
    }

    alert.addAction(
      UIAlertAction.init(title: "Cancel", style: .cancel)
    )

    self.present(alert, animated: true, completion: nil)
  }

  fileprivate func logout(params: DiscoveryParams) {
    AppEnvironment.logout()

    self.view.window?.rootViewController
      .flatMap { $0 as? RootTabBarViewController }
      .doIfSome { root in
        root.switchToDiscovery(params: params)
    }

    NotificationCenter.default.post(.init(name: .ksr_sessionEnded))
  }
}

extension DiscoveryNavigationHeaderViewController: DiscoveryFiltersViewControllerDelegate {
  internal func discoveryFiltersDidClose(_ viewController: DiscoveryFiltersViewController) {
    self.viewModel.inputs.titleButtonTapped()
  }

  internal func discoveryFilters(_ viewController: DiscoveryFiltersViewController,
                                 selectedRow: SelectableRow) {
    self.viewModel.inputs.filtersSelected(row: selectedRow)
  }
}
