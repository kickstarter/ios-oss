import Library
import Prelude
import UIKit

class PaymentMethodsViewController: UIViewController {

  @IBOutlet private weak var headerLabel: UILabel!
  @IBOutlet private weak var tableView: UITableView!

  public static func instantiate() -> PaymentMethodsViewController {
    return Storyboard.Settings.instantiate(PaymentMethodsViewController.self)
  }

  override func viewDidLoad() {
        super.viewDidLoad()
    }

  override func bindStyles() {
    super.bindStyles()

    _ = headerLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in
        Strings.Change_payment_method()
    }
  }
}
