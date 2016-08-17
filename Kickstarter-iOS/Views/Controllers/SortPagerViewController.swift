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

  @IBOutlet private weak var indicatorView: UIView!
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

  internal func updateStyle(categoryId categoryId: Int?) {
    self.viewModel.inputs.updateStyle(categoryId: categoryId)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.createSortButtons
      .observeForUI()
      .observeNext { [weak self] in
        self?.createSortButtons($0)
    }

    self.viewModel.outputs.pinSelectedIndicatorToPage
      .observeForUI()
      .observeNext { [weak self] in self?.pinSelectedIndicator(toPage: $0) }

    self.viewModel.outputs.notifyDelegateOfSelectedSort
      .observeNext { [weak self] sort in
        guard let _self = self else { return }
        _self.delegate?.sortPager(_self, selectedSort: sort)
    }

    self.viewModel.outputs.updateSortStyle
      .observeForUI()
      .observeNext { [weak self] (id, sorts) in
        self?.updateSortStyle(forCategoryId: id, sorts: sorts)
    }

    self.viewModel.outputs.setSelectedButton
      .observeForUI()
      .observeNext { [weak self] in
        self?.selectButton(atIndex: $0)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self.view |> UIView.lens.backgroundColor .~ .whiteColor()
  }

  private func createSortButtons(sorts: [DiscoveryParams.Sort]) {
    self.sortsStackView
      |> UIStackView.lens.arrangedSubviews .~ sorts.enumerate().map { idx, sort in
          UIButton()
            |> UIButton.lens.tag .~ idx
            |> UIButton.lens.targets .~ [
              (self, #selector(sortButtonTapped(_:)), .TouchUpInside)
          ]
    }
  }

  internal func pinSelectedIndicator(toPage page: Int) {
    guard let button = self.sortsStackView.arrangedSubviews[page] as? UIButton  else { return }

    let padding = page == 0 ? Styles.grid(2) : Styles.grid(4) - 3

    let leadingConstant = button.frame.origin.x + padding
    let widthConstant = button.titleLabel?.frame.width ?? button.frame.width

    self.indicatorViewLeadingConstraint.constant = leadingConstant
    self.indicatorViewWidthConstraint.constant = widthConstant

    let rightSort = leadingConstant + widthConstant + Styles.grid(11) - self.scrollView.contentOffset.x
    let leftSort = leadingConstant - Styles.grid(11) - self.scrollView.contentOffset.x

    UIView.animateWithDuration(0.2) {
      self.scrollView.layoutIfNeeded()

      if rightSort > self.view.bounds.width {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentSize.width - self.view.bounds.width,
                                                y: 0)
      } else if leftSort < 0.0 {
        self.scrollView.contentOffset = CGPoint(x: 0.0, y: 0)
      }
    }
  }

  private func updateSortStyle(forCategoryId categoryId: Int?, sorts: [DiscoveryParams.Sort]) {
    self.indicatorView |> UIView.lens.backgroundColor .~ discoveryIndicatorColor(forCategoryId: categoryId)

    let zipped = zip(sorts, self.sortsStackView.arrangedSubviews)

    for (sort, view) in zipped {
      let index = sorts.indexOf(sort)
      (view as? UIButton)
        ?|> discoverySortPagerButtonStyle(sort: sort,
                                                categoryId: categoryId,
                                                isLeftMost: index == 0,
                                                isRightMost: index == sorts.count - 1)
    }
    self.scrollView.layoutIfNeeded()
  }

  private func selectButton(atIndex index: Int) {
    for (idx, button) in self.sortsStackView.arrangedSubviews.enumerate() {
      (button as? UIButton)
        ?|> UIButton.lens.selected .~ (idx == index)
    }
  }

  @objc private func sortButtonTapped(button: UIButton) {
    self.viewModel.inputs.sortButtonTapped(index: button.tag)
  }
}
