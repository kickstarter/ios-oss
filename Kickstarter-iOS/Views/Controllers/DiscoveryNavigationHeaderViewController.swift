import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol DiscoveryNavigationHeaderViewDelegate: class {
  /// Call to update param s when filter selected.
  func discoveryNavigationHeaderFilterSelectedParams(params: DiscoveryParams)
}

internal final class DiscoveryNavigationHeaderViewController: UIViewController {
  private let viewModel: DiscoveryNavigationHeaderViewModelType = DiscoveryNavigationHeaderViewModel()

  @IBOutlet private weak var arrowImageView: UIImageView!
  @IBOutlet private weak var borderLineView: UIView!
  @IBOutlet private weak var borderLineHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var dividerLabel: UILabel!
  @IBOutlet private weak var favoriteContainerView: UIView!
  @IBOutlet private weak var favoriteButton: UIButton!
  @IBOutlet private weak var gradientBackgroundView: GradientView!
  @IBOutlet private weak var heartImageView: UIImageView!
  @IBOutlet private weak var heartOutlineImageView: UIImageView!
  @IBOutlet private weak var primaryLabel: UILabel!
  @IBOutlet private weak var secondaryLabel: UILabel!
  @IBOutlet private weak var titleButton: UIButton!
  @IBOutlet private weak var titleStackView: UIStackView!

  internal weak var delegate: DiscoveryNavigationHeaderViewDelegate?

  internal func configureWith(params params: DiscoveryParams) {
    self.viewModel.inputs.configureWith(params: params)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.gradientBackgroundView.startPoint = CGPoint(x: 0.0, y: 1.0)
    self.gradientBackgroundView.endPoint = CGPoint(x: 1.0, y: 0.0)

    self.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped),
                                  forControlEvents: .TouchUpInside)

    self.titleButton.addTarget(self, action: #selector(titleButtonTapped), forControlEvents: .TouchUpInside)

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
    self.primaryLabel.rac.font = self.viewModel.outputs.primaryLabelFont
    self.primaryLabel.rac.alpha = self.viewModel.outputs.primaryLabelOpacity
    self.secondaryLabel.rac.text = self.viewModel.outputs.secondaryLabelText
    self.secondaryLabel.rac.hidden = self.viewModel.outputs.secondaryLabelIsHidden
    self.secondaryLabel.rac.textColor = self.viewModel.outputs.subviewColor
    self.secondaryLabel.rac.font = self.viewModel.outputs.secondaryLabelFont
    self.dividerLabel.rac.hidden = self.viewModel.outputs.dividerIsHidden
    self.dividerLabel.rac.textColor = self.viewModel.outputs.subviewColor
    self.titleButton.rac.accessibilityLabel = self.viewModel.outputs.titleButtonAccessibilityLabel
    self.titleButton.rac.accessibilityHint = self.viewModel.outputs.titleButtonAccessibilityHint

    self.viewModel.outputs.animateArrowToDown
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.animateArrow(toDown: $0)
    }

    self.viewModel.outputs.updateFavoriteButton
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.updateFavoriteButton(selected: $0, animated: $1)
    }

    self.viewModel.outputs.gradientViewCategoryIdForColor
      .observeForControllerAction()
      .observeNext { [weak self] id, isFullScreen in
        self?.setBackgroundGradient(categoryId: id, isFullScreen: isFullScreen)
    }

    self.viewModel.outputs.notifyDelegateFilterSelectedParams
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.delegate?.discoveryNavigationHeaderFilterSelectedParams($0)
    }

    self.viewModel.outputs.showDiscoveryFilters
      .observeForControllerAction()
      .observeNext { [weak self] row, cats in
        self?.showDiscoveryFilters(selectedRow: row, categories: cats)
    }

    self.viewModel.outputs.dismissDiscoveryFilters
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(false, completion: nil)
    }

    self.viewModel.outputs.showFavoriteOnboardingAlert
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.showFavoriteCategoriesAlert(categoryName: $0)
    }

    self.viewModel.outputs.favoriteViewIsDimmed
      .observeForControllerAction()
      .observeNext { [weak self] isDimmed in
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
          self?.favoriteContainerView.alpha = isDimmed ? 0.4 : 1.0
        },
        completion: nil)
    }
  }
  // swiftlint:enable function_body_length

  internal override func bindStyles() {
    super.bindStyles()

    self.borderLineView
      |> discoveryBorderLineStyle

    self.borderLineHeightConstraint.constant = 1.0 / UIScreen.mainScreen().scale

    self.dividerLabel
      |> discoveryNavDividerLabelStyle
      |> UILabel.lens.isAccessibilityElement .~ false

    self.favoriteContainerView
      |> UIView.lens.layoutMargins .~ .init(left: Styles.grid(2))

    self.primaryLabel
      |> UILabel.lens.isAccessibilityElement .~ false

    self.secondaryLabel
      |> UILabel.lens.isAccessibilityElement .~ false

    self.titleStackView
      |> discoveryNavTitleStackViewStyle
  }

  private func showDiscoveryFilters(selectedRow selectedRow: SelectableRow, categories: [KsApi.Category]) {
    let vc = DiscoveryFiltersViewController.configuredWith(selectedRow: selectedRow, categories: categories)
    vc.delegate = self
    vc.modalPresentationStyle = .OverFullScreen
    self.presentViewController(vc, animated: false, completion: nil)
  }

  private func showFavoriteCategoriesAlert(categoryName categoryName: String) {
    let alertController = UIAlertController(
      title: categoryName,
      message: Strings.discovery_favorite_categories_alert_message(),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.discovery_favorite_categories_alert_buttons_got_it(),
        style: .Cancel,
        handler: nil
      )
    )

    self.presentViewController(alertController, animated: true, completion: nil)
  }

  private func animateArrow(toDown toDown: Bool) {
    let scale: CGFloat = toDown ? 1.0 : -1.0

    UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
      self.arrowImageView.transform = CGAffineTransformMakeScale(1.0, scale)
     },
     completion: nil)
  }

  // swiftlint:disable function_body_length
  private func updateFavoriteButton(selected selected: Bool, animated: Bool) {
    let duration = animated ? 0.4 : 0.0

    if selected {
      self.heartImageView.transform = CGAffineTransformMakeScale(0.0, 0.0)

      UIView.animateWithDuration(duration,
                                 delay: 0.0,
                                 usingSpringWithDamping: 0.6,
                                 initialSpringVelocity: 0.8,
                                 options: .CurveEaseOut,
                                 animations: {
                                  self.heartImageView.alpha = 1.0
                                  self.heartImageView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                                  self.heartOutlineImageView.transform =
                                    CGAffineTransformMakeScale(1.4, 1.4)
                                  },
                                 completion: nil)

      UIView.animateWithDuration(duration,
                                 delay: animated ? 0.1 : 0.0,
                                 usingSpringWithDamping: 0.6,
                                 initialSpringVelocity: 0.8,
                                 options: .CurveEaseOut,
                                 animations: {
                                  self.heartOutlineImageView.transform =
                                    CGAffineTransformMakeScale(1.0, 1.0)
                                  self.heartOutlineImageView.alpha = 0.0
                                  },
                                 completion: nil)
    } else {
      UIView.animateWithDuration(duration,
                                 delay: 0.0,
                                 usingSpringWithDamping: 0.6,
                                 initialSpringVelocity: 0.8,
                                 options: .CurveEaseOut,
                                 animations: {
                                  self.heartImageView.transform = CGAffineTransformMakeScale(0.0, 0.0)
                                  self.heartOutlineImageView.transform =
                                    CGAffineTransformMakeScale(1.4, 1.4)
                                  self.heartOutlineImageView.alpha = 1.0
                                  },
                                 completion: nil)

      UIView.animateWithDuration(duration,
                                 delay: animated ? 0.1 : 0.0,
                                 usingSpringWithDamping: 0.6,
                                 initialSpringVelocity: 0.8,
                                 options: .CurveEaseOut,
                                 animations: {
                                  self.heartOutlineImageView.transform =
                                    CGAffineTransformMakeScale(1.0, 1.0)
                                  },
                                 completion: { _ in
                                  self.heartImageView.alpha = 0.0
      })
    }
  }
  // swiftlint:ensable function_body_length

  private func setBackgroundGradient(categoryId categoryId: Int?, isFullScreen: Bool) {

    let (startColor, endColor) = discoveryGradientColors(forCategoryId: categoryId)

    if isFullScreen {
      UIView.transitionWithView(self.gradientBackgroundView,
                                duration: 0.2,
                                options: [.TransitionCrossDissolve, .CurveEaseOut],
                                animations: {
                                  self.gradientBackgroundView.setGradient([
                                    (color: startColor, location: 0.0),
                                    (color: endColor, location: 0.2)])
                                  },
                                completion: nil)

      UIView.animateWithDuration(0.2,
                                 delay: 0.1,
                                 options: .CurveEaseIn,
                                 animations: {
                                  self.borderLineView.transform = CGAffineTransformMakeScale(0.93, 1.0)
                                 },
                                 completion: nil)
    } else {
      UIView.animateWithDuration(0.1,
                                 delay: 0.0,
                                 options: .CurveEaseOut,
                                 animations: {
                                  self.borderLineView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                                 },
                                 completion: nil)

      UIView.transitionWithView(self.gradientBackgroundView,
                                duration: 0.2,
                                options: [.TransitionCrossDissolve, .CurveEaseOut],
                                animations: {
                                  self.gradientBackgroundView.setGradient([
                                    (color: startColor, location: 0.0),
                                    (color: endColor, location: 1.0)])
                                  },
                                completion: nil)
    }
  }

  @objc private func titleButtonTapped() {
    self.viewModel.inputs.titleButtonTapped()
  }

  @objc private func favoriteButtonTapped() {
    self.viewModel.inputs.favoriteButtonTapped()
  }
}

extension DiscoveryNavigationHeaderViewController: DiscoveryFiltersViewControllerDelegate {
  internal func discoveryFiltersDidClose(viewController: DiscoveryFiltersViewController) {
    self.viewModel.inputs.titleButtonTapped()
  }

  internal func discoveryFilters(viewController: DiscoveryFiltersViewController, selectedRow: SelectableRow) {
    self.viewModel.inputs.filtersSelected(row: selectedRow)
  }
}
