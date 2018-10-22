import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class AddNewCardViewController: UIViewController {
  @IBOutlet fileprivate weak var cardNumberLabel: UILabel!
  @IBOutlet fileprivate weak var cardNumberTextField: UITextField!
  @IBOutlet fileprivate weak var cardholderNameLabel: UILabel!
  @IBOutlet fileprivate weak var cardholderNameTextField: UITextField!
  @IBOutlet fileprivate weak var expirationLabel: UILabel!
  @IBOutlet fileprivate weak var expirationTextField: UITextField!
  @IBOutlet fileprivate weak var securityCodeLabel: UILabel!
  @IBOutlet fileprivate weak var securityCodeTextField: UITextField!
  @IBOutlet fileprivate weak var zipCodeLabel: UILabel!
  @IBOutlet fileprivate weak var zipCodeTextField: UITextField!

  internal static func instantiate() -> AddNewCardViewController {
    return Storyboard.Settings.instantiate(AddNewCardViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func bindStyles() {
    super.bindStyles()

    _ = [self.cardNumberTextField, self.cardholderNameTextField, self.expirationTextField,
         self.securityCodeTextField, self.zipCodeTextField]
      ||> formFieldStyle
  }
}
