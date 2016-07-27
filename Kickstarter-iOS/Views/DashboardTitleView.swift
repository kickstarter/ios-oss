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
  private let viewModel: DashboardTitleViewViewModelType = DashboardTitleViewViewModel()

  @IBOutlet private weak var titleButton: UIButton!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var arrowImageView: UIImageView!

  internal weak var delegate: DashboardTitleViewDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()

    self.titleButton
      |> UIView.lens.accessibilityLabel %~ { _ in Strings.tabbar_dashboard() }
      |> UIView.lens.accessibilityTraits .~ UIAccessibilityTraitStaticText

    self.titleButton.addTarget(self,
                               action: #selector(titleButtonTapped),
                               forControlEvents: .TouchUpInside)

    self.titleLabel |> dashboardTitleViewTextStyle

    self.arrowImageView
      |> UIImageView.lens.hidden .~ true
      |> UIImageView.lens.tintColor .~ .ksr_navy_700

    self.titleButton.rac.accessibilityLabel = self.viewModel.outputs.titleAccessibilityLabel
    self.titleButton.rac.accessibilityHint = self.viewModel.outputs.titleAccessibilityHint
    self.titleLabel.rac.text = self.viewModel.outputs.titleText
    self.titleButton.rac.enabled = self.viewModel.outputs.titleButtonIsEnabled

    self.viewModel.outputs.hideArrow
      .observeForUI()
      .observeNext { [weak self] hide in
        guard let _self = self else { return }
        UIView.animateWithDuration(0.2) {
          _self.arrowImageView.hidden = hide
        }
        if !hide {
          _self.titleButton |> UIView.lens.accessibilityTraits .~ UIAccessibilityTraitButton
        }
    }

    self.viewModel.outputs.updateArrowState
      .observeForUI()
      .observeNext { [weak self] drawerState in
        self?.animateArrow(forDrawerState: drawerState)
    }

    self.viewModel.outputs.notifyDelegateShowHideProjectsDrawer
      .observeForUI()
      .observeNext { [weak self] in
        self?.delegate?.dashboardTitleViewShowHideProjectsDrawer()
    }

    self.viewModel.outputs.titleButtonIsEnabled
      .observeForUI()
      .observeNext { [weak self] isEnabled in
        guard let _titleLabel = self?.titleLabel else { return }
        if isEnabled {
          _titleLabel |> UILabel.lens.font .~ UIFont.ksr_footnote(size: 14.0).bolded
        }
    }
  }

  internal func updateData(data: DashboardTitleViewData) {
    self.viewModel.inputs.updateData(data)
  }

  private func animateArrow(forDrawerState drawerState: DrawerState) {
    var scale: CGFloat = 1.0
    switch drawerState {
    case .open:
      scale = -1.0
    case .closed:
      scale = 1.0
    }

    UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
      self.arrowImageView.transform = CGAffineTransformMakeScale(1.0, scale)
      }, completion: nil)
  }

  @objc private func titleButtonTapped() {
    self.viewModel.inputs.titleButtonTapped()
  }
}
