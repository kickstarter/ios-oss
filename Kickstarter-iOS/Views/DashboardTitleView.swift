import UIKit
import KsApi
import Library
import Prelude
import Prelude_UIKit

internal protocol DashboardTitleViewDelegate: class {
  /// Call when dashboard should show/hide the projects drawer view controller.
  func dashboardTitleViewShowHideProjectsDrawer()
}

internal final class DashboardTitleView: UIView {
  fileprivate let viewModel: DashboardTitleViewViewModelType = DashboardTitleViewViewModel()

  @IBOutlet fileprivate weak var titleButton: UIButton!
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var arrowImageView: UIImageView!

  internal weak var delegate: DashboardTitleViewDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()

    _ = self.titleButton
      |> UIButton.lens.contentEdgeInsets %~ { insets in .init(topBottom: insets.top, leftRight: 0) }
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.tabbar_dashboard() }
      |> UIButton.lens.accessibilityTraits .~ UIAccessibilityTraitStaticText
      |> UIButton.lens.targets .~ [(self, #selector(titleButtonTapped), .touchUpInside)]

    _ = self.arrowImageView
      |> UIImageView.lens.hidden .~ true
      |> UIImageView.lens.tintColor .~ .ksr_dark_grey_900

    _ = self.titleLabel |> dashboardTitleViewTextDisabledStyle

    self.titleButton.rac.accessibilityLabel = self.viewModel.outputs.titleAccessibilityLabel
    self.titleButton.rac.accessibilityHint = self.viewModel.outputs.titleAccessibilityHint
    self.titleLabel.rac.text = self.viewModel.outputs.titleText
    self.titleButton.rac.enabled = self.viewModel.outputs.titleButtonIsEnabled

    self.viewModel.outputs.hideArrow
      .observeForUI()
      .observeValues { [weak self] hide in
        guard let _self = self else { return }
        UIView.animate(withDuration: 0.2) {
          _self.arrowImageView.isHidden = hide
        }
        if !hide {
          _ = _self.titleButton |> UIView.lens.accessibilityTraits .~ UIAccessibilityTraitButton
        }
    }

    self.viewModel.outputs.updateArrowState
      .observeForUI()
      .observeValues { [weak self] drawerState in
        self?.animateArrow(forDrawerState: drawerState)
    }

    self.viewModel.outputs.notifyDelegateShowHideProjectsDrawer
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.dashboardTitleViewShowHideProjectsDrawer()
    }

    self.viewModel.outputs.titleButtonIsEnabled
      .observeForUI()
      .observeValues { [weak self] isEnabled in
        guard let _titleLabel = self?.titleLabel else { return }
        if isEnabled {
          _ = _titleLabel |> dashboardTitleViewTextEnabledStyle
        }
    }
  }

  internal func updateData(_ data: DashboardTitleViewData) {
    self.viewModel.inputs.updateData(data)
  }

  fileprivate func animateArrow(forDrawerState drawerState: DrawerState) {
    var scale: CGFloat = 1.0
    switch drawerState {
    case .open:
      scale = -1.0
    case .closed:
      scale = 1.0
    }

    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
      self.arrowImageView.transform = CGAffineTransform(scaleX: 1.0, y: scale)
      }, completion: nil)
  }

  @objc fileprivate func titleButtonTapped() {
    self.viewModel.inputs.titleButtonTapped()
  }
}
