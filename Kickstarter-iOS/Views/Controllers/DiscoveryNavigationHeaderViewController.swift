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
  @IBOutlet fileprivate weak var borderLineView: UIView!
  @IBOutlet fileprivate weak var borderLineHeightConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var dividerLabel: UILabel!
  @IBOutlet fileprivate weak var favoriteContainerView: UIView!
  @IBOutlet fileprivate weak var favoriteButton: UIButton!
  @IBOutlet fileprivate weak var gradientBackgroundView: GradientView!
  @IBOutlet fileprivate weak var heartImageView: UIImageView!
  @IBOutlet fileprivate weak var heartOutlineImageView: UIImageView!
  @IBOutlet fileprivate weak var primaryLabel: UILabel!
  @IBOutlet fileprivate weak var secondaryLabel: UILabel!
  @IBOutlet fileprivate weak var titleButton: UIButton!
  @IBOutlet fileprivate weak var titleStackView: UIStackView!
  @IBOutlet fileprivate weak var outerStackViewTopConstraint: NSLayoutConstraint!

  internal weak var delegate: DiscoveryNavigationHeaderViewDelegate?

  internal static func instantiate() -> DiscoveryNavigationHeaderViewController {
    return Storyboard.Discovery.instantiate(DiscoveryNavigationHeaderViewController.self)
  }

  internal func configureWith(params: DiscoveryParams) {
    self.viewModel.inputs.configureWith(params: params)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.gradientBackgroundView.startPoint = CGPoint(x: 0.0, y: 1.0)
    self.gradientBackgroundView.endPoint = CGPoint(x: 1.0, y: 0.0)

    self.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped),
                                  for: .touchUpInside)

    self.titleButton.addTarget(self, action: #selector(titleButtonTapped), for: .touchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.arrowImageView.rac.tintColor = self.viewModel.outputs.subviewColor
    self.borderLineView.rac.backgroundColor = self.viewModel.outputs.subviewColor
    self.favoriteContainerView.rac.hidden = self.viewModel.outputs.favoriteViewIsHidden
    self.favoriteButton.rac.accessibilityLabel = self.viewModel.outputs.favoriteButtonAccessibilityLabel
    self.heartImageView.rac.tintColor = self.viewModel.outputs.subviewColor
    self.heartOutlineImageView.rac.tintColor = self.viewModel.outputs.subviewColor
    self.primaryLabel.rac.text = self.viewModel.outputs.primaryLabelText
    self.primaryLabel.rac.textColor = self.viewModel.outputs.subviewColor
    self.secondaryLabel.rac.text = self.viewModel.outputs.secondaryLabelText
    self.secondaryLabel.rac.hidden = self.viewModel.outputs.secondaryLabelIsHidden
    self.secondaryLabel.rac.textColor = self.viewModel.outputs.subviewColor
    self.dividerLabel.rac.hidden = self.viewModel.outputs.dividerIsHidden
    self.dividerLabel.rac.textColor = self.viewModel.outputs.subviewColor
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

    self.viewModel.outputs.gradientViewCategoryIdForColor
      .observeForUI()
      .observeValues { [weak self] id, isFullScreen in
        self?.setBackgroundGradient(categoryId: id, isFullScreen: isFullScreen)
    }

    self.viewModel.outputs.notifyDelegateFilterSelectedParams
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.discoveryNavigationHeaderFilterSelectedParams($0)
    }

    self.viewModel.outputs.showDiscoveryFilters
      .observeForControllerAction()
      .observeValues { [weak self] row, cats in
        self?.showDiscoveryFilters(selectedRow: row, categories: cats)
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
  // swiftlint:enable function_body_length

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.borderLineView
      |> discoveryBorderLineStyle

    self.borderLineHeightConstraint.constant = 1.0 / UIScreen.main.scale

    _ = self.dividerLabel
      |> discoveryNavDividerLabelStyle
      |> UILabel.lens.isAccessibilityElement .~ false

    _ = self.favoriteContainerView
      |> UIView.lens.layoutMargins .~ .init(left: Styles.grid(2))

    _ = self.primaryLabel
      |> UILabel.lens.isAccessibilityElement .~ false

    _ = self.secondaryLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? UIFont.ksr_body(size: 18).bolded
          : UIFont.ksr_callout().bolded
      }
      |> UILabel.lens.isAccessibilityElement .~ false

    _ = self.titleStackView
      |> discoveryNavTitleStackViewStyle

    if self.view.traitCollection.isRegularRegular {
      self.outerStackViewTopConstraint.constant = -6.0
    }
  }

  fileprivate func showDiscoveryFilters(selectedRow: SelectableRow, categories: [KsApi.Category]) {
    let vc = DiscoveryFiltersViewController.configuredWith(selectedRow: selectedRow, categories: categories)
    vc.delegate = self
    vc.modalPresentationStyle = .overFullScreen
    self.present(vc, animated: false, completion: nil)
  }

  fileprivate func showFavoriteCategoriesAlert(categoryName: String) {
    let alertController = UIAlertController(
      title: categoryName,
      message: Strings.discovery_favorite_categories_alert_message(),
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

  // swiftlint:disable function_body_length
  fileprivate func updateFavoriteButton(selected: Bool, animated: Bool) {
    let duration = animated ? 0.4 : 0.0

    if selected {
      self.heartImageView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)

      UIView.animate(withDuration: duration,
                                 delay: 0.0,
                                 usingSpringWithDamping: 0.6,
                                 initialSpringVelocity: 0.8,
                                 options: .curveEaseOut,
                                 animations: {
                                  self.heartImageView.alpha = 1.0
                                  self.heartImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                  self.heartOutlineImageView.transform =
                                    CGAffineTransform(scaleX: 1.4, y: 1.4)
                                  },
                                 completion: nil)

      UIView.animate(withDuration: duration,
                                 delay: animated ? 0.1 : 0.0,
                                 usingSpringWithDamping: 0.6,
                                 initialSpringVelocity: 0.8,
                                 options: .curveEaseOut,
                                 animations: {
                                  self.heartOutlineImageView.transform =
                                    CGAffineTransform(scaleX: 1.0, y: 1.0)
                                  self.heartOutlineImageView.alpha = 0.0
                                  },
                                 completion: nil)
    } else {
      UIView.animate(withDuration: duration,
                                 delay: 0.0,
                                 usingSpringWithDamping: 0.6,
                                 initialSpringVelocity: 0.8,
                                 options: .curveEaseOut,
                                 animations: {
                                  self.heartImageView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                                  self.heartOutlineImageView.transform =
                                    CGAffineTransform(scaleX: 1.4, y: 1.4)
                                  self.heartOutlineImageView.alpha = 1.0
                                  },
                                 completion: nil)

      UIView.animate(withDuration: duration,
                                 delay: animated ? 0.1 : 0.0,
                                 usingSpringWithDamping: 0.6,
                                 initialSpringVelocity: 0.8,
                                 options: .curveEaseOut,
                                 animations: {
                                  self.heartOutlineImageView.transform =
                                    CGAffineTransform(scaleX: 1.0, y: 1.0)
                                  },
                                 completion: { _ in
                                  self.heartImageView.alpha = 0.0
      })
    }
  }
  // swiftlint:ensable function_body_length

  fileprivate func setBackgroundGradient(categoryId: Int?, isFullScreen: Bool) {

    let (startColor, endColor) = discoveryGradientColors(forCategoryId: categoryId)

    if isFullScreen {
      UIView.transition(with: self.gradientBackgroundView,
                                duration: 0.2,
                                options: [.transitionCrossDissolve, .curveEaseOut],
                                animations: {
                                  self.gradientBackgroundView.setGradient([
                                    (color: startColor, location: 0.0),
                                    (color: endColor, location: 0.2)])
                                  },
                                completion: nil)

      UIView.animate(withDuration: 0.2,
                                 delay: 0.1,
                                 options: .curveEaseIn,
                                 animations: {
                                  self.borderLineView.transform = CGAffineTransform(scaleX: 0.93, y: 1.0)
                                 },
                                 completion: nil)
    } else {
      UIView.animate(withDuration: 0.1,
                                 delay: 0.0,
                                 options: .curveEaseOut,
                                 animations: {
                                  self.borderLineView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                 },
                                 completion: nil)

      UIView.transition(with: self.gradientBackgroundView,
                                duration: 0.2,
                                options: [.transitionCrossDissolve, .curveEaseOut],
                                animations: {
                                  self.gradientBackgroundView.setGradient([
                                    (color: startColor, location: 0.0),
                                    (color: endColor, location: 1.0)])
                                  },
                                completion: nil)
    }
  }

  @objc fileprivate func titleButtonTapped() {
    self.viewModel.inputs.titleButtonTapped()
  }

  @objc fileprivate func favoriteButtonTapped() {
    self.viewModel.inputs.favoriteButtonTapped()
  }
}

extension DiscoveryNavigationHeaderViewController: DiscoveryFiltersViewControllerDelegate {
  internal func discoveryFiltersDidClose(_ viewController: DiscoveryFiltersViewController) {
    self.viewModel.inputs.titleButtonTapped()
  }

  internal func discoveryFilters(_ viewController: DiscoveryFiltersViewController, selectedRow: SelectableRow) {
    self.viewModel.inputs.filtersSelected(row: selectedRow)
  }
}
