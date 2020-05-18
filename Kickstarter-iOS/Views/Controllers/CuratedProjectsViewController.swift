import KsApi
import Library
import Prelude
import UIKit

final class CuratedProjectsViewController: UIViewController {
  // MARK: - Properties

  private let dataSource = DiscoveryProjectsDataSource()

  private lazy var doneButton: UIBarButtonItem = {
    UIBarButtonItem(
      title: Strings.Done(),
      style: .plain,
      target: self,
      action: #selector(CuratedProjectsViewController.doneButtonTapped)
    )
  }()

  private lazy var headerView: CategorySelectionHeaderView = {
    CategorySelectionHeaderView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var loadingIndicator: UIActivityIndicatorView = {
    UIActivityIndicatorView()
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var tableView: UITableView = {
    UITableView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: CuratedProjectsViewModelType = CuratedProjectsViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationController?.configureTransparentNavigationBar()

    self.navigationItem.setRightBarButton(self.doneButton, animated: false)
    self.navigationItem.hidesBackButton = true

    self.tableView.register(nib: .DiscoveryPostcardCell)

    _ = self.tableView
      |> \.delegate .~ self
      |> \.dataSource .~ self.dataSource

    self.configureSubviews()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Configuration

  public func configure(with categories: [KsApi.Category], context: CuratedProjectsContext) {
    self.viewModel.inputs.configure(with: categories)

    self.headerView.configure(with: CategorySelectionOnboardingHeaderViewContext.curatedProjects(context))
  }

  private func configureSubviews() {
    _ = (self.headerView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.tableView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.loadingIndicator, self.view)
      |> ksr_addSubviewToParent()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.headerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      self.loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      self.loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
      self.tableView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
    ])
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.loadingIndicator.rac.animating = self.viewModel.outputs.isLoading

    self.viewModel.outputs.dismissViewController
      .observeForUI()
      .observeValues { [weak self] in
        self?.dismiss(animated: true)
      }

    self.viewModel.outputs.loadProjects
      .observeForUI()
      .observeValues { [weak self] projects in
        self?.dataSource.load(projects: projects)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] project, projects, refTag in
        self?.goToProject(project, projects: projects, refTag: refTag)
      }

    self.viewModel.outputs.showErrorMessage
      .observeForUI()
      .observeValues { [weak self] message in
        self?.present(UIAlertController.genericError(message), animated: true)
      }
  }

  // MARK: - Styles

  public override func bindStyles() {
    super.bindStyles()

    _ = self.tableView
      |> tableViewStyle

    _ = self.doneButton
      |> doneButtonStyle

    _ = self.headerView
      |> headerViewStyle

    _ = self.loadingIndicator
      |> baseActivityIndicatorStyle
  }

  // MARK: - Accessors

  @objc func doneButtonTapped() {
    self.viewModel.inputs.doneButtonTapped()
  }

  // MARK: - Functions

  fileprivate func goToProject(_ project: Project, projects: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(
      project: project,
      refTag: refTag,
      initialPlaylist: projects,
      navigatorDelegate: self
    )
    if UIDevice.current.userInterfaceIdiom == .pad {
      vc.modalPresentationStyle = .fullScreen
    }
    self.present(vc, animated: true, completion: nil)
  }
}

extension CuratedProjectsViewController: UITableViewDelegate {
  func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    let project = self.dataSource.projectAtIndexPath(indexPath)

    self.viewModel.inputs.projectTapped(project)
  }
}

extension CuratedProjectsViewController: ProjectNavigatorDelegate {
  func transitionedToProject(at _: Int) {}
}

// MARK: - Styles

private let doneButtonStyle: BarButtonStyle = { button in
  button
    |> \.tintColor .~ .white
}

private let headerViewStyle: ViewStyle = { view in
  view
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
}

private let tableViewStyle: TableViewStyle = { view in
  view
    |> \.backgroundColor .~ .white
    |> \.separatorStyle .~ .none
    |> \.rowHeight .~ UITableView.automaticDimension
    |> \.estimatedRowHeight .~ 550
}
