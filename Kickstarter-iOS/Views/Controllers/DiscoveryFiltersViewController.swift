import Library
import UIKit

internal protocol DiscoveryFiltersViewControllerDelegate: class {
  func discoveryFilters(viewController: DiscoveryFiltersViewController, selectedRow: SelectableRow)
}

internal final class DiscoveryFiltersViewController: UITableViewController {
  private let dataSource = DiscoveryFiltersDataSource()
  private let viewModel: DiscoveryFiltersViewModelType = DiscoveryFiltersViewModel()
  internal weak var delegate: DiscoveryFiltersViewControllerDelegate?

  internal func configureWith(selectedRow selectedRow: SelectableRow) {
    self.viewModel.inputs.configureWith(selectedRow: selectedRow)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.backgroundView = {
      $0.setGradient([
        (UIColor.hex(0x0A1342), 0.0),
        (UIColor.hex(0x132F67), 1.0)
      ])
      return $0
    }(GradientView())

    self.tableView.estimatedRowHeight = 44.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.loadTopRows
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dataSource.load(topRows: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.loadCategoryRows
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dataSource.load(categoryRows: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.notifyDelegateOfSelectedRow
      .observeForControllerAction()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.discoveryFilters(_self, selectedRow: $0)
    }
  }

  internal override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    if let expandableRow = self.dataSource.expandableRow(indexPath: indexPath) {
      self.viewModel.inputs.tapped(expandableRow: expandableRow)
    } else if let selectableRow = self.dataSource.selectableRow(indexPath: indexPath) {
      self.viewModel.inputs.tapped(selectableRow: selectableRow)
    }
  }
}
