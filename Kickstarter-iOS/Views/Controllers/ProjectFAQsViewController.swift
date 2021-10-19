import Foundation
import KsApi
import Library
import Prelude

public enum ProjectFAQsViewControllerStyles {
  public enum Layout {
    public static let standardMargin = Styles.grid(3)
    public static let topMargin = Styles.grid(2)
  }
}

internal final class ProjectFAQsViewController: UIViewController {
  // MARK: - Properties

  private let dataSource = ProjectFAQsDataSource()

  private let viewModel: ProjectFAQsViewModelType = ProjectFAQsViewModel()

  private lazy var headerLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var tableView: UITableView = {
    UITableView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Accessors

  internal static func configuredWith(project: Project) -> ProjectFAQsViewController {
    let vc = ProjectFAQsViewController.instantiate()
    vc.viewModel.inputs.configureWith(project: project)

    return vc
  }

  private func configureSubviews() {
    _ = (self.headerLabel, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.tableView, self.view)
      |> ksr_addSubviewToParent()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.headerLabel.leadingAnchor
        .constraint(
          equalTo: self.view.leadingAnchor,
          constant: ProjectFAQsViewControllerStyles.Layout.standardMargin
        ),
      self.headerLabel.trailingAnchor
        .constraint(
          equalTo: self.view.trailingAnchor,
          constant: -ProjectFAQsViewControllerStyles.Layout.standardMargin
        ),
      self.headerLabel.topAnchor
        .constraint(equalTo: self.view.topAnchor, constant: ProjectFAQsViewControllerStyles.Layout.topMargin),
      self.tableView.topAnchor
        .constraint(
          equalTo: self.headerLabel.bottomAnchor,
          constant: ProjectFAQsViewControllerStyles.Layout.topMargin
        ),
      self.tableView.leadingAnchor
        .constraint(
          equalTo: self.view.leadingAnchor,
          constant: Styles.grid(1)
        ),
      self.tableView.trailingAnchor
        .constraint(
          equalTo: self.headerLabel.trailingAnchor
        ),
      self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ])
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView
      .register(
        ProjectFAQsEmptyStateCell.self,
        forCellReuseIdentifier: ProjectFAQsEmptyStateCell.defaultReusableId
      )
    self.tableView
      .register(
        ProjectFAQsCell.self,
        forCellReuseIdentifier: ProjectFAQsCell.defaultReusableId
      )

    _ = self.tableView
      |> \.delegate .~ self
      |> \.dataSource .~ self.dataSource

    self.configureSubviews()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.headerLabel
      |> headerLabelStyle

    _ = self.tableView
      |> tableViewStyle
  }

  // MARK: - View model

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadFAQs
      .observeForUI()
      .observeValues { [weak self] project, isExpandedStates in
        self?.dataSource.load(project: project, isExpandedStates: isExpandedStates)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.updateDataSource
      .observeForUI()
      .observeValues { [weak self] project, isExpandedStates in
        self?.dataSource.load(project: project, isExpandedStates: isExpandedStates)
        self?.tableView.reloadData()
      }
  }
}

// MARK: - Styles

// TODO: - Internationalize string
private let headerLabelStyle: LabelStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_white
    |> \.font .~ UIFont.ksr_title1().bolded
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.text .~ "Frequently asked questions"
    |> \.textColor .~ .ksr_support_700
}

private let tableViewStyle: TableViewStyle = { view in
  view
    |> \.estimatedRowHeight .~ 100.0
    |> \.rowHeight .~ UITableView.automaticDimension
    |> \.showsVerticalScrollIndicator .~ false
}

extension ProjectFAQsViewController: UITableViewDelegate {
  func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    let values = self.dataSource.isExpandedValuesForFAQsSection() ?? []
    self.viewModel.inputs.didSelectRowAt(row: indexPath.row, values: values)
  }
}
