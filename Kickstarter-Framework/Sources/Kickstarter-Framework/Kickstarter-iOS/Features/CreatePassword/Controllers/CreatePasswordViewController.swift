import Library
import Prelude
import UIKit

final class CreatePasswordViewController: UIViewController, MessageBannerViewControllerPresenting {
  // MARK: - Properties

  private lazy var createPasswordTableViewController: CreatePasswordTableViewController = {
    let tableViewController = CreatePasswordTableViewController.instantiate()
    tableViewController.delegate = self
    return tableViewController
  }()

  internal var messageBannerViewController: MessageBannerViewController?

  private lazy var saveButtonView: LoadingBarButtonItemView = {
    let buttonView = LoadingBarButtonItemView.instantiate()
    buttonView.setTitle(title: Strings.Save())
    return buttonView
  }()

  // MARK: - Lifecycle

  static func instantiate() -> CreatePasswordViewController {
    return CreatePasswordViewController()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title %~ { _ in Strings.Create_password() }

    _ = self.navigationItem
      |> \.rightBarButtonItem .~ UIBarButtonItem(customView: self.saveButtonView)

    if let childView = self.createPasswordTableViewController.tableView {
      self.addChild(self.createPasswordTableViewController)
      _ = (childView, self.view) |> ksr_addSubviewToParent()
      self.createPasswordTableViewController.didMove(toParent: self)

      _ = (childView, self.view) |> ksr_constrainViewToEdgesInParent()
    }

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.saveButtonView.addTarget(
      self.createPasswordTableViewController,
      action: #selector(CreatePasswordTableViewController.saveButtonTapped(_:))
    )
  }
}

extension CreatePasswordViewController: CreatePasswordTableViewControllerDelegate {
  func createPasswordTableViewController(
    _: CreatePasswordTableViewController,
    setSaveButtonIsEnabled isEnabled: Bool
  ) {
    self.saveButtonView.setIsEnabled(isEnabled: isEnabled)
  }

  func createPasswordTableViewControllerStartAnimatingSaveButton(_: CreatePasswordTableViewController) {
    self.saveButtonView.startAnimating()
  }

  func createPasswordTableViewControllerStopAnimatingSaveButton(_: CreatePasswordTableViewController) {
    self.saveButtonView.stopAnimating()
  }

  func createPasswordTableViewController(
    _: CreatePasswordTableViewController,
    showErrorMessage message: String
  ) {
    self.messageBannerViewController?.showBanner(with: .error, message: message)
  }
}
