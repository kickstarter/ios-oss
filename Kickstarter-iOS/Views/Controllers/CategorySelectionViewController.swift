import Foundation
import KsApi
import Library
import Prelude
import SpriteKit
import UIKit

public final class CategorySelectionViewController: UITableViewController {
  private let viewModel: CategorySelectionViewModelType = CategorySelectionViewModel()
  private let dataSource = CategorySelectionDataSource()

  public override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> baseTableControllerStyle()

    _ = self.tableView
      |> \.dataSource .~ self.dataSource

    self.tableView.registerCellClass(CategorySelectionCell.self)

    self.configureHeaderView()

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.tableView.ksr_sizeHeaderFooterViewsToFit()
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadCategorySections
      .observeForUI()
      .observeValues { [weak self] categories in
        self?.dataSource.load(categories: categories)
        self?.tableView.reloadData()

        self?.tableView.setNeedsLayout()
        self?.tableView.layoutIfNeeded()
      }
  }

  private func configureHeaderView() {
    let headerContainer = UIView(frame: .zero)
      |> \.backgroundColor .~ .white
      |> \.accessibilityTraits .~ .header
      |> \.isAccessibilityElement .~ true
      |> \.layoutMargins %~~ { _, _ in
        self.view.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(4), left: Styles.grid(30), bottom: Styles.grid(2), right: Styles.grid(30))
          : .init(all: Styles.grid(4))
      }

    let categorySelectionHeader = CategorySelectionHeaderView(frame: .zero)

    _ = (categorySelectionHeader, headerContainer)
      |> ksr_addSubviewToParent()

    self.tableView.tableHeaderView = headerContainer

    _ = (categorySelectionHeader, headerContainer)
      |> ksr_constrainViewToMarginsInParent()

    let widthConstraint = categorySelectionHeader.widthAnchor
      .constraint(equalTo: self.tableView.widthAnchor)
      |> \.priority .~ .defaultHigh

    NSLayoutConstraint.activate([widthConstraint])
  }
}
