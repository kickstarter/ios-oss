import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol SortPagerViewControllerDelegate: class {
  func sortPager(_ viewController: UIViewController, selectedSort sort: DiscoveryParams.Sort)
}

internal final class SortPagerViewController: UIViewController {
  internal weak var delegate: SortPagerViewControllerDelegate?
  fileprivate let viewModel: SortPagerViewModelType = SortPagerViewModel()

  @IBOutlet fileprivate weak var borderLineView: UIView!
  @IBOutlet fileprivate weak var indicatorView: UIView!
  @IBOutlet fileprivate weak var indicatorViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var indicatorViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var scrollView: UIScrollView!
  @IBOutlet fileprivate weak var sortsStackView: UIStackView!
  @IBOutlet fileprivate var sortsStackViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate var sortsStackViewTrailingConstraint: NSLayoutConstraint!
  fileprivate var sortsStackViewCenterXConstraint: NSLayoutConstraint?

  internal static func instantiate() -> SortPagerViewController {
    return Storyboard.Discovery.instantiate(SortPagerViewController.self)
  }

  internal func configureWith(sorts: [DiscoveryParams.Sort]) {
    self.viewModel.inputs.configureWith(sorts: sorts)
  }

  internal func select(sort: DiscoveryParams.Sort) {
    self.viewModel.inputs.select(sort: sort)
  }

  internal func updateStyle(categoryId: Int?) {
    self.viewModel.inputs.updateStyle(categoryId: categoryId)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.sortsStackViewCenterXConstraint = self.sortsStackView.centerXAnchor
      .constraint(equalTo: self.view.centerXAnchor)
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  internal override func bindViewModel() {
    self.indicatorView.rac.hidden = self.viewModel.outputs.indicatorViewIsHidden

    self.viewModel.outputs.createSortButtons
      .observeForUI()
      .observeValues { [weak self] in
        self?.createSortButtons($0)
    }

    self.viewModel.outputs.setSelectedButton
      .observeForUI()
      .observeValues { [weak self] in
        self?.selectButton(atIndex: $0)
    }

    self.viewModel.outputs.pinSelectedIndicatorToPage
      .observeForUI()
      .observeValues { [weak self] page, animated in
        self?.pinSelectedIndicator(toPage: page, animated: animated)
    }

    self.viewModel.outputs.updateSortStyle
      .observeForUI()
      .observeValues { [weak self] (id, sorts, animated) in
        self?.updateSortStyle(forCategoryId: id, sorts: sorts, animated: animated)
    }

    self.viewModel.outputs.notifyDelegateOfSelectedSort
      .observeForUI()
      .observeValues { [weak self] sort in
        guard let _self = self else { return }
        _self.delegate?.sortPager(_self, selectedSort: sort)
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.scrollView
      |> UIScrollView.lens.scrollsToTop .~ false

    _ = self.view
      |> UIView.lens.backgroundColor .~ .white

    _ = self.borderLineView
      |> discoveryBorderLineStyle

    if self.view.traitCollection.isRegularRegular {
      self.sortsStackViewCenterXConstraint?.isActive = true
      self.sortsStackViewLeadingConstraint.isActive = false
      self.sortsStackViewTrailingConstraint.isActive = false
    } else {
      self.sortsStackViewCenterXConstraint?.isActive = false
      self.sortsStackViewLeadingConstraint.isActive = true
      self.sortsStackViewTrailingConstraint.isActive = true
    }
  }

  override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation,
                                                 duration: TimeInterval) {
    self.viewModel.inputs.willRotateToInterfaceOrientation()
  }

  internal override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    self.viewModel.inputs.didRotateFromInterfaceOrientation()
  }

  internal func setSortPagerEnabled(_ isEnabled: Bool) {
    self.view.isUserInteractionEnabled = isEnabled

    self.scrollView.alpha = isEnabled ? 1.0 : 0.0

    if isEnabled {
      _ = self.borderLineView |> discoveryBorderLineStyle
    } else {
      _ = self.borderLineView |> UIView.lens.alpha .~ 0.0
    }
  }

  fileprivate func createSortButtons(_ sorts: [DiscoveryParams.Sort]) {
    _ = self.sortsStackView
      |> UIStackView.lens.arrangedSubviews .~ sorts.enumerated().map { idx, sort in
          UIButton()
            |> UIButton.lens.tag .~ idx
            |> UIButton.lens.targets .~ [
              (self, #selector(sortButtonTapped(_:)), .touchUpInside)
          ]
    }
  }

  fileprivate func selectButton(atIndex index: Int) {
    for (idx, button) in self.sortsStackView.arrangedSubviews.enumerated() {
      _ = (button as? UIButton)
        ?|> UIButton.lens.selected .~ (idx == index)
    }
  }

  fileprivate func pinSelectedIndicator(toPage page: Int, animated: Bool) {
    guard let button = self.sortsStackView.arrangedSubviews[page] as? UIButton else { return }

    let padding = page == 0 ? Styles.grid(2) : Styles.grid(4) - 3

    let leadingConstant = self.sortsStackView.frame.origin.x + button.frame.origin.x + padding
    let widthConstant = button.titleLabel?.frame.width ?? button.frame.width

    self.indicatorViewLeadingConstraint.constant = leadingConstant
    self.indicatorViewWidthConstraint.constant = widthConstant

    let rightSort = leadingConstant + widthConstant + Styles.grid(11) - self.scrollView.contentOffset.x
    let leftSort = leadingConstant - Styles.grid(11) - self.scrollView.contentOffset.x

    UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: {
      self.scrollView.layoutIfNeeded()

      if rightSort > self.view.bounds.width {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentSize.width - self.view.bounds.width,
                                                y: 0)
      } else if leftSort < 0.0 {
        self.scrollView.contentOffset = CGPoint(x: 0.0, y: 0)
      }
    }) 
  }

  fileprivate func updateSortStyle(forCategoryId categoryId: Int?,
                                   sorts: [DiscoveryParams.Sort],
                                   animated: Bool) {

    let zipped = zip(sorts, self.sortsStackView.arrangedSubviews)
    for (sort, view) in zipped {
      let index = sorts.index(of: sort)
      _ = (view as? UIButton)
        ?|> discoverySortPagerButtonStyle(sort: sort,
                                          categoryId: categoryId,
                                          isLeftMost: index == 0,
                                          isRightMost: index == sorts.count - 1,
                                          isRegularRegular: view.traitCollection.isRegularRegular)
    }
    self.scrollView.layoutIfNeeded()

    UIView.transition(
      with: self.view,
      duration: animated ? 0.2 : 0.0,
      options: [.transitionCrossDissolve, .curveEaseOut],
      animations: {
        _ = [self.indicatorView, self.borderLineView]
          ||> UIView.lens.backgroundColor .~ discoveryPrimaryColor(forCategoryId: categoryId)
      },
      completion: nil)
  }

  @objc fileprivate func sortButtonTapped(_ button: UIButton) {
    self.viewModel.inputs.sortButtonTapped(index: button.tag)
  }
}
