import UIKit

final class CreatePasswordViewController: UIViewController, MessageBannerViewControllerPresenting {
  // MARK: - Properties

  private lazy var createPasswordTableViewController: CreatePasswordTableViewController = {
    CreatePasswordTableViewController.instantiate()
  }()

  internal var messageBannerViewController: MessageBannerViewController?

  // MARK: - Lifecycle

  static func instantiate() -> CreatePasswordViewController {
    return CreatePasswordViewController()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if let childView = self.createPasswordTableViewController.tableView {
      childView.translatesAutoresizingMaskIntoConstraints = false

      self.addChild(self.createPasswordTableViewController)
      self.view.addSubview(childView)
      self.createPasswordTableViewController.didMove(toParent: self)

      childView.constrainEdges(to: self.view)
    }

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)
  }
}
