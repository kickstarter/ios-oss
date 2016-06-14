import KsApi
import Library
import Prelude
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
    self.viewModel.outputs.createSortButtonsWithTitles
      .observeForUI()
      .observeNext { [weak self] in self?.createSortButtons($0) }

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

  private func createSortButtons(titles: [String]) {
    self.sortsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    titles.enumerate().forEach { idx, title in
      self.sortsStackView.addArrangedSubview(self.buttonFor(title: title, index: idx))
    }
  }

  private func scrollTo(percentage percentage: CGFloat) {
    let point = CGPoint(
      x: percentage * (self.scrollView.contentSize.width - self.scrollView.bounds.width),
      y: 0.0
    )
    self.scrollView.setContentOffset(point, animated: true)
  }

  private func pinSelectedIndicator(toPage page: Int) {
    let view = self.sortsStackView.arrangedSubviews[page]

    UIView.animateWithDuration(0.2) {
      self.indicatorViewLeadingConstraint.constant = view.frame.origin.x
      self.indicatorViewWidthConstraint.constant = view.frame.width
      self.scrollView.layoutIfNeeded()
    }
  }

  private func buttonFor(title title: String, index: Int) -> UIButton {
    let button = BorderButton()
    button.color = .Clear
    button.borderColor = .Clear
    button.titleColorNormal = .TextDarkGray
    button.titleColorHighlighted = .TextDefault
    button.titleFontStyle = .Subhead
    button.contentEdgeInsets = .init(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    button.setTitle(title, forState: .Normal)
    button.addTarget(self, action: #selector(sortButtonTapped(_:)), forControlEvents: .TouchUpInside)
    button.tag = index
    return button
  }

  @objc private func sortButtonTapped(button: UIButton) {
    self.viewModel.inputs.sortButtonTapped(index: button.tag)
  }
}
