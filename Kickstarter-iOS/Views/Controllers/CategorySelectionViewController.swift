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
      |> \.contentInsetAdjustmentBehavior .~ .never
      |> \.contentInset .~ .init(bottom: self.view.safeAreaInsets.bottom)
      |> \.bounces .~ true
      |> \.alwaysBounceVertical .~ true
      |> \.dataSource .~ self.dataSource

    self.tableView.registerCellClass(CategorySelectionCell.self)

    self.configureHeaderView()

    self.viewModel.inputs.viewDidLoad()
  }

  override public func bindStyles() {
    super.bindStyles() 
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.tableView.ksr_sizeHeaderFooterViewsToFit()
  }

  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadCategorySections
      .observeForUI()
      .observeValues { [weak self] categories in
        self?.dataSource.load(categories: categories)
        self?.tableView.reloadData()
      }
  }

  private func configureHeaderView() {
    let headerContainer = UIView(frame: .zero)
      |> \.backgroundColor .~ UIColor.ksr_trust_700
      |> \.accessibilityTraits .~ .header
      |> \.isAccessibilityElement .~ true

    let categorySelectionHeader = CategorySelectionHeaderView(frame: .zero)

    _ = (categorySelectionHeader, headerContainer)
      |> ksr_addSubviewToParent()

    self.tableView.tableHeaderView = headerContainer

    _ = (categorySelectionHeader, headerContainer)
      |> ksr_constrainViewToEdgesInParent()

    let widthConstraint = categorySelectionHeader.widthAnchor
      .constraint(equalTo: self.tableView.widthAnchor)
      |> \.priority .~ .defaultHigh

    NSLayoutConstraint.activate([widthConstraint])
  }
}
