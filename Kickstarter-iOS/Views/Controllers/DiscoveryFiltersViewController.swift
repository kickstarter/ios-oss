import KsApi
import Library
import Prelude
import UIKit

internal protocol DiscoveryFiltersViewControllerDelegate: class {
  func discoveryFilters(_ viewController: DiscoveryFiltersViewController, selectedRow: SelectableRow)
  func discoveryFiltersDidClose(_ viewController: DiscoveryFiltersViewController)
}

internal final class DiscoveryFiltersViewController: UIViewController, UITableViewDelegate {
  @IBOutlet private weak var bgView: UIView!
  @IBOutlet private weak var closeButton: UIButton!
  @IBOutlet private weak var filtersTableView: UITableView!

  private let dataSource = DiscoveryFiltersDataSource()
  private let viewModel: DiscoveryFiltersViewModelType = DiscoveryFiltersViewModel()

  internal weak var delegate: DiscoveryFiltersViewControllerDelegate?

  internal static func configuredWith(selectedRow: SelectableRow)
    -> DiscoveryFiltersViewController {

      let vc = Storyboard.Discovery.instantiate(DiscoveryFiltersViewController.self)
      vc.viewModel.inputs.configureWith(selectedRow: selectedRow)
      return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.filtersTableView.dataSource = self.dataSource
    self.filtersTableView.delegate = self

    self.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.animateInView
      .observeForUI()
      .observeValues { [weak self] in
        self?.animateIn()
    }

    self.viewModel.outputs.loadingIndicatorIsVisible
      .observeForUI()
      .observeValues { [weak self] isVisible in
        guard let _self = self else { return }
        if isVisible {
          _self.dataSource.loadCategoriesLoaderRow()
          _self.filtersTableView.reloadData()
        } else {
          _self.deleteCategoriesLoaderRow(_self.filtersTableView)
        }
    }

    self.viewModel.outputs.loadTopRows
      .observeForUI()
      .observeValues { [weak self] rows, id in
        self?.dataSource.load(topRows: rows, categoryId: id)
        self?.filtersTableView.reloadData()
    }

    self.viewModel.outputs.loadFavoriteRows
      .observeForUI()
      .observeValues { [weak self] rows, id in
        self?.dataSource.load(favoriteRows: rows, categoryId: id)
        self?.filtersTableView.reloadData()
    }

    self.viewModel.outputs.loadCategoryRows
      .observeForUI()
      .observeValues { [weak self] rows, id, selectedRowId in
        self?.dataSource.load(categoryRows: rows, categoryId: id)
        self?.reloadCategories(selectedRowId: selectedRowId)
    }

    self.viewModel.outputs.notifyDelegateOfSelectedRow
      .observeForControllerAction()
      .observeValues { [weak self] selectedRow in
        guard let _self = self else { return }
        _self.animateOut()
        _self.delegate?.discoveryFilters(_self, selectedRow: selectedRow)
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.bgView
      |> UIView.lens.backgroundColor .~ .white

    _ = self.filtersTableView
      |> UITableView.lens.rowHeight .~ UITableView.automaticDimension
      |> UITableView.lens.estimatedRowHeight .~ 55.0
      |> UITableView.lens.backgroundColor .~ .clear

    _ = self.closeButton
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Closes_filters() }
  }

  internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let expandableRow = self.dataSource.expandableRow(indexPath: indexPath) {
      self.viewModel.inputs.tapped(expandableRow: expandableRow)
    } else if let selectableRow = self.dataSource.selectableRow(indexPath: indexPath) {
      self.viewModel.inputs.tapped(selectableRow: selectableRow)
    }
  }

  internal func tableView(_ tableView: UITableView,
                          willDisplay cell: UITableViewCell,
                          forRowAt indexPath: IndexPath) {

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

  private func animateIn() {
    self.filtersTableView.frame.origin.y -= 20.0
    self.filtersTableView.alpha = 0

    UIView.animate(
      withDuration: 0.3,
      delay: 0.0,
      usingSpringWithDamping: 0.45,
      initialSpringVelocity: 1.0,
      options: .curveEaseOut,
      animations: {
        self.bgView.alpha = 1.0
        self.filtersTableView.alpha = 1.0
        self.filtersTableView.frame.origin.y += 20.0
      },
      completion: nil
    )
  }

  private func animateOut() {
    UIView.animate(
      withDuration: 0.2,
      delay: 0.0,
      options: .curveEaseIn,
      animations: {
        self.filtersTableView.alpha = 0.0
        self.filtersTableView.frame.origin.y -= 20.0
      },
      completion: nil
    )

    UIView.animate(
      withDuration: 0.3,
      delay: 0.1,
      options: .curveEaseOut,
      animations: {
        self.bgView.alpha = 0.0
      },
      completion: nil
    )
  }

  @objc private func closeButtonTapped(_ button: UIButton) {
    self.animateOut()
    self.delegate?.discoveryFiltersDidClose(self)
  }

  private func reloadCategories(selectedRowId: Int?) {
    if let indexPath = self.dataSource.indexPath(forCategoryId: selectedRowId) {
      self.filtersTableView.reloadData()
      self.filtersTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
    } else {
      UIView.transition(
        with: self.filtersTableView,
        duration: 0.2,
        options: .transitionCrossDissolve,
        animations: {
          self.filtersTableView.reloadData()
        },
        completion: nil
      )
    }
  }

  private func deleteCategoriesLoaderRow(_ tableView: UITableView) {
    guard let
      deleteCategoriesLoaderRow = self.dataSource.deleteCategoriesLoaderRow(tableView),
      !deleteCategoriesLoaderRow.isEmpty else {
        return
    }

    self.filtersTableView.beginUpdates()
    defer { self.filtersTableView.endUpdates() }

    self.filtersTableView.deleteRows(at: deleteCategoriesLoaderRow, with: .fade)
  }
}
