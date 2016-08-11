import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol SortPagerViewControllerDelegate: class {
  func sortPager(viewController: UIViewController, selectedSort sort: DiscoveryParams.Sort)
}

internal final class SortPagerViewController: UIViewController {
  internal weak var delegate: SortPagerViewControllerDelegate?
  private let viewModel: SortPagerViewModelType = SortPagerViewModel()

  @IBOutlet private weak var indicatorViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet private weak var indicatorViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var sortsStackView: UIStackView!

  internal func configureWith(sorts sorts: [DiscoveryParams.Sort]) {
    self.viewModel.inputs.configureWith(sorts: sorts)
  }

  internal func select(sort sort: DiscoveryParams.Sort) {
    self.viewModel.inputs.select(sort: sort)
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.createSortButtons
      .observeForUI()
      .observeNext { [weak self] in
        self?.createSortButtons($0)
    }

    self.viewModel.outputs.scrollPercentage
      .observeForUI()
      .observeNext { [weak self] in self?.scrollTo(percentage: $0) }

    self.viewModel.outputs.pinSelectedIndicatorToPage
      .observeForUI()
      .observeNext { [weak self] in self?.pinSelectedIndicator(toPage: $0) }

    self.viewModel.outputs.notifyDelegateOfSelectedSort
      .observeNext { [weak self] sort in
        guard let _self = self else { return }
        _self.delegate?.sortPager(_self, selectedSort: sort)
    }
  }

  private func createSortButtons(sorts: [DiscoveryParams.Sort]) {

    self.sortsStackView
      |> UIStackView.lens.arrangedSubviews .~ sorts.enumerate().map { idx, sort in
        self.buttonFor(sort: sort, index: idx)
    }
  }

  private func scrollTo(percentage percentage: CGFloat) {
    let contentOffset = CGPoint(
      x: percentage * (self.scrollView.contentSize.width - self.scrollView.bounds.width),
      y: 0.0
    )

    let sortButtonRight = percentage * self.scrollView.contentSize.width - self.scrollView.contentOffset.x
    let sortButtonLeft = sortButtonRight - self.indicatorViewWidthConstraint.constant

    if sortButtonRight + Styles.grid(6) > self.view.bounds.width
      || sortButtonLeft - Styles.grid(6) < 0.0 {
      self.scrollView.setContentOffset(contentOffset, animated: true)
    }
  }

  private func pinSelectedIndicator(toPage page: Int) {
    let view = self.sortsStackView.arrangedSubviews[page]

    UIView.animateWithDuration(0.2) {
      self.indicatorViewLeadingConstraint.constant = view.frame.origin.x
      self.indicatorViewWidthConstraint.constant = view.frame.width
      self.scrollView.layoutIfNeeded()
    }
  }

  private func buttonFor(sort sort: DiscoveryParams.Sort, index: Int) -> UIButton {
    return UIButton()
      |> discoveryPagerSortButtonStyle(sort: sort)
      |> UIButton.lens.tag .~ index
      |> UIButton.lens.targets .~ [
        (self, #selector(sortButtonTapped(_:)), .TouchUpInside)
    ]
  }

  @objc private func sortButtonTapped(button: UIButton) {
    self.viewModel.inputs.sortButtonTapped(index: button.tag)
  }
}
