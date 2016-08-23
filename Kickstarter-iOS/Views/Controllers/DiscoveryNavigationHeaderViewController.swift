import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol DiscoveryNavigationHeaderViewDelegate: class {
  /// Call to update params when filter selected.
  func discoveryNavigationHeaderFilterSelectedParams(params: DiscoveryParams)
}

internal final class DiscoveryNavigationHeaderViewController: UIViewController {
  private let viewModel: DiscoveryNavigationHeaderViewModelType = DiscoveryNavigationHeaderViewModel()

  @IBOutlet private weak var arrowImageView: UIImageView!
  @IBOutlet private weak var borderLineView: UIView!
  @IBOutlet private weak var dividerLabel: UILabel!
  @IBOutlet private weak var gradientBackgroundView: GradientView!
  @IBOutlet private weak var primaryLabel: UILabel!
  @IBOutlet private weak var secondaryLabel: UILabel!
  @IBOutlet private weak var titleButton: UIButton!
  @IBOutlet private weak var titleStackView: UIStackView!

  internal weak var delegate: DiscoveryNavigationHeaderViewDelegate?

  internal func configureWith(params params: DiscoveryParams) {
    self.viewModel.inputs.configureWith(params: params)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.titleButton
      |> UIButton.lens.targets .~ [(self, action: #selector(titleButtonTapped), .TouchUpInside)]

    self.primaryLabel
      |> UILabel.lens.isAccessibilityElement .~ false

    self.secondaryLabel
      |> UILabel.lens.isAccessibilityElement .~ false

    self.dividerLabel
      |> UILabel.lens.isAccessibilityElement .~ false

    self.gradientBackgroundView.startPoint = CGPoint(x: 0.0, y: 1.0)
    self.gradientBackgroundView.endPoint = CGPoint(x: 1.0, y: 0.0)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.arrowImageView.rac.tintColor = self.viewModel.outputs.subviewColor
    self.borderLineView.rac.backgroundColor = self.viewModel.outputs.subviewColor
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

    self.viewModel.outputs.gradientViewCategoryIdForColor
      .observeForControllerAction()
      .observeNext { [weak element = self.gradientBackgroundView] in
        let (startColor, endColor) = discoveryGradientColors(forCategoryId: $0)
        element?.setGradient([(color: startColor, location: 0.0), (color: endColor, location: 1.0)])
    }

    self.viewModel.outputs.notifyDelegateFilterSelectedParams
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.delegate?.discoveryNavigationHeaderFilterSelectedParams($0)
    }

    self.viewModel.outputs.showDiscoveryFilters
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.showDiscoveryFilters(selectedRow: $0)
    }

    self.viewModel.outputs.dismissDiscoveryFilters
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(false, completion: nil)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self.borderLineView
      |> discoveryBorderLineStyle

    self.dividerLabel
      |> discoveryNavDividerLabelStyle

    self.titleStackView
      |> discoveryNavTitleStackViewStyle
  }

  private func showDiscoveryFilters(selectedRow selectedRow: SelectableRow) {
    let vc = DiscoveryFiltersViewController.configuredWith(selectedRow: selectedRow)
    vc.delegate = self
    self.presentViewController(vc, animated: false, completion: nil)
  }

  private func animateArrow(toDown toDown: Bool) {
    let scale: CGFloat = toDown ? 1.0 : -1.0

    UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
      self.arrowImageView.transform = CGAffineTransformMakeScale(1.0, scale)
      }, completion: nil)
  }

  @objc private func titleButtonTapped() {
    self.viewModel.inputs.titleButtonTapped()
  }
}

extension DiscoveryNavigationHeaderViewController: DiscoveryFiltersViewControllerDelegate {
  internal func discoveryFilters(viewController: DiscoveryFiltersViewController, selectedRow: SelectableRow) {
    self.viewModel.inputs.filtersSelected(row: selectedRow)
  }
}
