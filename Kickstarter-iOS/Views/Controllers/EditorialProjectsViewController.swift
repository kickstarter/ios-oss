import KsApi
import Library
import Prelude
import UIKit

public final class EditorialProjectsViewController: UIViewController {
  // MARK: - Properties

  private lazy var closeButton: UIButton = {
    UIButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var discoveryPageViewController: DiscoveryPageViewController = {
    DiscoveryPageViewController.configuredWith(sort: .newest)
  }()

  private lazy var headerView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: EditorialProjectViewModelType = EditorialProjectViewModel()

  // MARK: - Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()

    let params = DiscoveryParams.defaults
      |> DiscoveryParams.lens.tagId .~ .goRewardless

    self.discoveryPageViewController.change(filter: params)

    self.discoveryPageViewController.tableView.contentInsetAdjustmentBehavior = .never
//
//    self.edgesForExtendedLayout = [.top]
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    let currentTableViewInsets = self.discoveryPageViewController.tableView.contentInset

    print("*** headerView height \(self.headerView.frame.size.height)")
    print("*** discoveryPageViewController.view.safeAreaInsets.top \(discoveryPageViewController.view.safeAreaInsets.top)")
    print("*** self.view.safeAreaInsets.top \(self.view.safeAreaInsets.top)")
    print("*** adjustedContentInset \(self.discoveryPageViewController.tableView.adjustedContentInset.top)")

    print("*** adjusting to: \(self.headerView.frame.height + self.view.safeAreaInsets.top)")

    self.discoveryPageViewController.tableView.contentInset = currentTableViewInsets
      |> UIEdgeInsets.lens.top .~ (
        self.headerView.frame.height + self.view.safeAreaInsets.top
      )
      |> UIEdgeInsets.lens.bottom .~ self.view.safeAreaInsets.bottom

//    self.discoveryPageViewController.tableView.scrollIndicatorInsets =
//      self.discoveryPageViewController.tableView.contentInset

//    print("*** discoveryPageViewController.view \(self.discoveryPageViewController.view)")
//    print("*** view \(self.view)")
  }

  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Styles

  public override func bindStyles() {
    super.bindStyles()

//    self.view.backgroundColor = UIColor.hex(0x00007D)

//    self.discoveryPageViewController.view.layoutMargins = .zero

    _ = self.headerView
      |> \.backgroundColor .~ UIColor.hex(0x00007D)

    _ = self.discoveryPageViewController.view
      |> \.backgroundColor .~ .clear

    _ = self.closeButton
      |> UIButton.lens.title(for: .normal) .~ nil
      |> UIButton.lens.image(for: .normal) .~ image(named: "icon--cross", tintColor: .white)

    // TODO: Need accessibility label and hint for close button
  }

  // MARK: - View model

  public override func bindViewModel() {
    super.bindViewModel()
  }

  // MARK: - Layout

  private func configureSubviews() {
    _ = (self.headerView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.discoveryPageViewController.view, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.closeButton, self.view)
      |> ksr_addSubviewToParent()

    self.addChild(self.discoveryPageViewController)
    self.discoveryPageViewController.didMove(toParent: self)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.headerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
      self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.headerView.widthAnchor.constraint(equalTo: self.discoveryPageViewController.tableView.widthAnchor),
      self.closeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
      self.closeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height),
      self.closeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.width)
    ])

    // remove once header has content
    self.headerView.heightAnchor.constraint(equalToConstant: 250).isActive = true
  }
}
