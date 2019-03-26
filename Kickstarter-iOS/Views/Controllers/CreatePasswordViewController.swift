import Library
import Prelude
import UIKit

protocol CreatePasswordViewControllerDelegate: class {
  func saveButtonSetIsEnabled(_ isEnabled: Bool)
  func saveButtonStartAnimating()
  func saveButtonStopAnimating()
  func showError(with message: String)
}

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
      childView.translatesAutoresizingMaskIntoConstraints = false

      self.addChild(self.createPasswordTableViewController)
      self.view.addSubview(childView)
      self.createPasswordTableViewController.didMove(toParent: self)

      childView.constrainEdges(to: self.view)
    }

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.saveButtonView.addTarget(
      self.createPasswordTableViewController,
      action: #selector(createPasswordTableViewController.saveButtonTapped(_:))
    )
  }
}

extension CreatePasswordViewController: CreatePasswordViewControllerDelegate {
  func saveButtonSetIsEnabled(_ isEnabled: Bool) {
    self.saveButtonView.setIsEnabled(isEnabled: isEnabled)
  }

  func saveButtonStartAnimating() {
    self.saveButtonView.startAnimating()
  }

  func saveButtonStopAnimating() {
    self.saveButtonView.stopAnimating()
  }

  func showError(with message: String) {
    self.messageBannerViewController?.showBanner(with: .error, message: message)
  }
}
