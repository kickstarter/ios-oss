import KsApi
import Library
import Prelude
import UIKit

internal protocol DiscoveryFiltersViewControllerDelegate: class {
  func discoveryFilters(viewController: DiscoveryFiltersViewController, selectedRow: SelectableRow)
  func discoveryFiltersDidClose(viewController: DiscoveryFiltersViewController)
}

internal final class DiscoveryFiltersViewController: UIViewController, UITableViewDelegate {
  @IBOutlet private weak var closeButton: UIButton!
  @IBOutlet private weak var backgroundGradientView: GradientView!
  @IBOutlet private weak var filtersTableView: UITableView!

  private let dataSource = DiscoveryFiltersDataSource()
  private let viewModel: DiscoveryFiltersViewModelType = DiscoveryFiltersViewModel()

  internal weak var delegate: DiscoveryFiltersViewControllerDelegate?

  internal static func configuredWith(selectedRow selectedRow: SelectableRow, categories: [KsApi.Category])
    -> DiscoveryFiltersViewController {

      let vc = Storyboard.Discovery.instantiate(DiscoveryFiltersViewController)
      vc.viewModel.inputs.configureWith(selectedRow: selectedRow, categories: categories)
      return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.filtersTableView.dataSource = self.dataSource
    self.filtersTableView.delegate = self

    self.backgroundGradientView.startPoint = CGPoint(x: 0.0, y: 1.0)
    self.backgroundGradientView.endPoint = CGPoint(x: 1.0, y: 0.0)

    self.closeButton.addTarget(self, action: #selector(closeButtonTapped), forControlEvents: .TouchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.animateInView
      .observeForUI()
      .observeNext { [weak self] in
        self?.animateIn(categoryId: $0)
    }

    self.viewModel.outputs.loadTopRows
      .observeForUI()
      .observeNext { [weak self] rows, id in
        self?.dataSource.load(topRows: rows, categoryId: id)
        self?.filtersTableView.reloadData()
    }

    self.viewModel.outputs.loadFavoriteRows
      .observeForUI()
      .observeNext { [weak self] rows, id in
        self?.dataSource.load(favoriteRows: rows, categoryId: id)
        self?.filtersTableView.reloadData()
    }

    self.viewModel.outputs.loadCategoryRows
      .observeForUI()
      .observeNext { [weak self] rows, id, selectedRowId in
        self?.dataSource.load(categoryRows: rows, categoryId: id)
        self?.filtersTableView.reloadData()
        if let indexPath = self?.dataSource.indexPath(forCategoryId: selectedRowId) {
          self?.filtersTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
        }
    }

    self.viewModel.outputs.notifyDelegateOfSelectedRow
      .observeForControllerAction()
      .observeNext { [weak self] selectedRow in
        guard let _self = self else { return }
        _self.animateOut()
        _self.delegate?.discoveryFilters(_self, selectedRow: selectedRow)
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.filtersTableView
      |> UITableView.lens.rowHeight .~ UITableViewAutomaticDimension
      |> UITableView.lens.estimatedRowHeight .~ 44.0
      |> UITableView.lens.backgroundColor .~ .clearColor()
  }

  internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let expandableRow = self.dataSource.expandableRow(indexPath: indexPath) {
      self.viewModel.inputs.tapped(expandableRow: expandableRow)
    } else if let selectableRow = self.dataSource.selectableRow(indexPath: indexPath) {
      self.viewModel.inputs.tapped(selectableRow: selectableRow)
    }
  }

  internal func tableView(tableView: UITableView,
                          willDisplayCell cell: UITableViewCell,
                                          forRowAtIndexPath indexPath: NSIndexPath) {

    if let cell = cell as? DiscoverySelectableRowCell {
      cell.willDisplay()
    } else if let cell = cell as? DiscoveryExpandableRowCell {
      cell.willDisplay()
    } else if let cell = cell as? DiscoveryExpandedSelectableRowCell {
      cell.willDisplay()

      if self.viewModel.outputs.shouldAnimateSelectableCell {
        let delay = indexPath.row - (self.dataSource.expandedRow() ?? 0)
        cell.animateIn(delayOffset: delay)
      }
    }
  }

  private func animateIn(categoryId categoryId: Int?) {
    let (startColor, endColor) = discoveryGradientColors(forCategoryId: categoryId)
    self.backgroundGradientView.setGradient([(startColor, 0.0), (endColor, 1.0)])
    self.backgroundGradientView.alpha = 0

    self.filtersTableView.frame.origin.y -= 20
    self.filtersTableView.alpha = 0

    UIView.animateWithDuration(0.2,
                               delay: 0.0,
                               options: .CurveEaseOut,
                               animations: {
                                self.backgroundGradientView.alpha = 1
                                },
                               completion: nil)

    UIView.animateWithDuration(0.2,
                               delay: 0.2,
                               usingSpringWithDamping: 0.6,
                               initialSpringVelocity: 1.0,
                               options: .CurveEaseOut, animations: {
                                self.filtersTableView.alpha = 1
                                self.filtersTableView.frame.origin.y += 20
                                },
                               completion: nil)
  }

  private func animateOut() {
    UIView.animateWithDuration(0.1,
                               delay: 0.0,
                               options: .CurveEaseOut,
                               animations: {
                                self.filtersTableView.alpha = 0
                                self.filtersTableView.frame.origin.y -= 20
                                },
                               completion: nil)

    UIView.animateWithDuration(0.2,
                               delay: 0.1,
                               options: .CurveEaseOut,
                               animations: {
                                self.backgroundGradientView.alpha = 0
                                self.filtersTableView.alpha = 0
                                },
                               completion: nil)
  }

  @objc private func closeButtonTapped(button: UIButton) {
    self.animateOut()
    self.delegate?.discoveryFiltersDidClose(self)
  }
}
