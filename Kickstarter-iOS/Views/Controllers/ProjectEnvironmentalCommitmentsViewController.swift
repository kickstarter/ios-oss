import Foundation
import KsApi
import Library
import Prelude

public enum ProjectEnvironmentalCommitmentsViewControllerStyles {
  public enum Layout {
    public static let standardMargin = Styles.grid(3)
    public static let topMargin = Styles.grid(2)
  }
}

internal final class ProjectEnvironmentalCommitmentsViewController: UIViewController {
  // MARK: - Properties

  private let dataSource = ProjectEnvironmentalCommitmentsDataSource()

  private let viewModel: ProjectEnvironmentalCommitmentsViewModelType =
    ProjectEnvironmentalCommitmentsViewModel()

  private lazy var headerLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var tableView: UITableView = {
    UITableView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Accessors

  internal static func configuredWith(environmentalCommitments: [ProjectEnvironmentalCommitment])
    -> ProjectEnvironmentalCommitmentsViewController {
    let vc = ProjectEnvironmentalCommitmentsViewController.instantiate()
    vc.viewModel.inputs.configureWith(environmentalCommitments: environmentalCommitments)

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
        ProjectEnvironmentalCommitmentCell.self,
        forCellReuseIdentifier: ProjectEnvironmentalCommitmentCell.defaultReusableId
      )
    self.tableView
      .register(
        ProjectEnvironmentalCommitmentFooterCell.self,
        forCellReuseIdentifier: ProjectEnvironmentalCommitmentFooterCell.defaultReusableId
      )

    _ = self.tableView
      |> \.dataSource .~ self.dataSource
      |> \.delegate .~ self

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
      |> \.tableFooterView .~
      UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
  }

  // MARK: - View model

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadEnvironmentalCommitments
      .observeForUI()
      .observeValues { [weak self] environmentalCommitments in
        self?.dataSource.load(environmentalCommitments: environmentalCommitments)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.showHelpWebViewController
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        self?.presentHelpWebViewController(with: helpType)
      }
  }
}

// MARK: - UITableViewDelegate

extension ProjectEnvironmentalCommitmentsViewController: UITableViewDelegate {
  func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath) {
    (cell as? ProjectEnvironmentalCommitmentFooterCell)?.delegate = self
  }
}

extension ProjectEnvironmentalCommitmentsViewController: ProjectEnvironmentalCommitmentFooterCellDelegate {
  func projectEnvironmentalCommitmentFooterCell(_: ProjectEnvironmentalCommitmentFooterCell, didTapURL: URL) {
    self.viewModel.inputs.projectEnvironmentalCommitmentFooterCellDidTapURL(didTapURL)
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
    |> \.text .~ "Environmental commitments"
    |> \.textColor .~ .ksr_support_700
}

private let tableViewStyle: TableViewStyle = { view in
  view
    |> \.estimatedRowHeight .~ 100.0
    |> \.rowHeight .~ UITableView.automaticDimension
    |> \.showsVerticalScrollIndicator .~ false
}
