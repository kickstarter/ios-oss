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

  @IBOutlet private weak var borderLineView: UIView!
  @IBOutlet private weak var indicatorView: UIView!
  @IBOutlet private weak var indicatorViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet private weak var indicatorViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var sortsStackView: UIStackView!
  @IBOutlet private var sortsStackViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet private var sortsStackViewTrailingConstraint: NSLayoutConstraint!
  private var sortsStackViewCenterXConstraint: NSLayoutConstraint?

  internal static func instantiate() -> SortPagerViewController {
    return Storyboard.Discovery.instantiate(SortPagerViewController)
  }

  internal func configureWith(sorts sorts: [DiscoveryParams.Sort]) {
    self.viewModel.inputs.configureWith(sorts: sorts)
  }

  internal func select(sort sort: DiscoveryParams.Sort) {
    self.viewModel.inputs.select(sort: sort)
  }

  internal func updateStyle(categoryId categoryId: Int?) {
    self.viewModel.inputs.updateStyle(categoryId: categoryId)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.sortsStackViewCenterXConstraint = self.sortsStackView.centerXAnchor
      .constraintEqualToAnchor(self.view.centerXAnchor)
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  internal override func bindViewModel() {
    self.indicatorView.rac.hidden = self.viewModel.outputs.indicatorViewIsHidden

    self.viewModel.outputs.createSortButtons
      .observeForUI()
      .observeNext { [weak self] in
        self?.createSortButtons($0)
    }

    self.viewModel.outputs.setSelectedButton
      .observeForUI()
      .observeNext { [weak self] in
        self?.selectButton(atIndex: $0)
    }

    self.viewModel.outputs.pinSelectedIndicatorToPage
      .observeForUI()
      .observeNext { [weak self] page, animated in
        self?.pinSelectedIndicator(toPage: page, animated: animated)
    }

    self.viewModel.outputs.updateSortStyle
      .observeForUI()
      .observeNext { [weak self] (id, sorts, animated) in
        self?.updateSortStyle(forCategoryId: id, sorts: sorts, animated: animated)
    }

    self.viewModel.outputs.notifyDelegateOfSelectedSort
      .observeForUI()
      .observeNext { [weak self] sort in
        guard let _self = self else { return }
        _self.delegate?.sortPager(_self, selectedSort: sort)
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.scrollView
      |> UIScrollView.lens.scrollsToTop .~ false

    self.view
      |> UIView.lens.backgroundColor .~ .whiteColor()

    self.borderLineView
      |> discoveryBorderLineStyle

    if self.view.traitCollection.isRegularRegular {
      self.sortsStackViewCenterXConstraint?.active = true
      self.sortsStackViewLeadingConstraint.active = false
      self.sortsStackViewTrailingConstraint.active = false
    } else {
      self.sortsStackViewCenterXConstraint?.active = false
      self.sortsStackViewLeadingConstraint.active = true
      self.sortsStackViewTrailingConstraint.active = true
    }
  }

  override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation,
                                                 duration: NSTimeInterval) {
    self.viewModel.inputs.willRotateToInterfaceOrientation()
  }

  internal override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
    self.viewModel.inputs.didRotateFromInterfaceOrientation()
  }

  internal func setSortPagerEnabled(isEnabled: Bool) {
    self.view.userInteractionEnabled = isEnabled

    self.scrollView.alpha = isEnabled ? 1.0 : 0.0

    if isEnabled {
      self.borderLineView |> discoveryBorderLineStyle
    } else {
      self.borderLineView |> UIView.lens.alpha .~ 0.0
    }
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

  private func selectButton(atIndex index: Int) {
    for (idx, button) in self.sortsStackView.arrangedSubviews.enumerate() {
      (button as? UIButton)
        ?|> UIButton.lens.selected .~ (idx == index)
    }
  }

  private func pinSelectedIndicator(toPage page: Int, animated: Bool) {
    guard let button = self.sortsStackView.arrangedSubviews[page] as? UIButton else { return }

    let padding = page == 0 ? Styles.grid(2) : Styles.grid(4) - 3

    let leadingConstant = self.sortsStackView.frame.origin.x + button.frame.origin.x + padding
    let widthConstant = button.titleLabel?.frame.width ?? button.frame.width

    self.indicatorViewLeadingConstraint.constant = leadingConstant
    self.indicatorViewWidthConstraint.constant = widthConstant

    let rightSort = leadingConstant + widthConstant + Styles.grid(11) - self.scrollView.contentOffset.x
    let leftSort = leadingConstant - Styles.grid(11) - self.scrollView.contentOffset.x

    UIView.animateWithDuration(animated ? 0.2 : 0.0) {
      self.scrollView.layoutIfNeeded()

      if rightSort > self.view.bounds.width {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentSize.width - self.view.bounds.width,
                                                y: 0)
      } else if leftSort < 0.0 {
        self.scrollView.contentOffset = CGPoint(x: 0.0, y: 0)
      }
    }
  }

  private func updateSortStyle(forCategoryId categoryId: Int?,
                                             sorts: [DiscoveryParams.Sort],
                                             animated: Bool) {

    let zipped = zip(sorts, self.sortsStackView.arrangedSubviews)
    for (sort, view) in zipped {
      let index = sorts.indexOf(sort)
      (view as? UIButton)
        ?|> discoverySortPagerButtonStyle(sort: sort,
                                          categoryId: categoryId,
                                          isLeftMost: index == 0,
                                          isRightMost: index == sorts.count - 1,
                                          isRegularRegular: view.traitCollection.isRegularRegular)
    }
    self.scrollView.layoutIfNeeded()

    UIView.transitionWithView(self.view,
                              duration: animated ? 0.2 : 0.0,
                              options: [.TransitionCrossDissolve, .CurveEaseOut],
                              animations: {
                                [self.indicatorView, self.borderLineView]
                                  ||> UIView.lens.backgroundColor .~
                                    discoveryPrimaryColor(forCategoryId: categoryId)
                              },
                              completion: nil)
  }

  @objc private func sortButtonTapped(button: UIButton) {
    self.viewModel.inputs.sortButtonTapped(index: button.tag)
  }
}
