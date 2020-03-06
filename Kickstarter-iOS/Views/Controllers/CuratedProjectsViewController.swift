import Library
import Prelude
import UIKit

final class CuratedProjectsViewController: UIViewController {
  // MARK: - Properties

  private lazy var tableView: UITableView = {
    UITableView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var doneButton: UIBarButtonItem = {
    UIBarButtonItem(
      title: Strings.Done(),
      style: .plain,
      target: self,
      action: #selector(CuratedProjectsViewController.doneButtonTapped)
    )
  }()

  private lazy var headerView: UIView = {
    CategorySelectionHeaderView(frame: .zero, context: .curatedProjects)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.setRightBarButton(self.doneButton, animated: false)
    self.navigationItem.hidesBackButton = true

    self.configureSubviews()
    self.setupConstraints()
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Configuration

  private func configureSubviews() {
    _ = (self.headerView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.tableView, self.view)
      |> ksr_addSubviewToParent()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.headerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      self.tableView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
    ])
  }

  // MARK: - Styles

  public override func bindStyles() {
    super.bindStyles()

    _ = self.tableView
      |> collectionViewStyle

    _ = self.doneButton
      |> doneButtonStyle

    _ = self.headerView
      |> headerViewStyle
  }

  // MARK: - Accessors

  @objc func doneButtonTapped() {
    self.dismiss(animated: true)
  }
}

// MARK: - Styles

private let collectionViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .white
}

private let doneButtonStyle: BarButtonStyle = { button in
  button
    |> \.tintColor .~ .white
}

private let headerViewStyle: ViewStyle = { view in
  view
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
}
