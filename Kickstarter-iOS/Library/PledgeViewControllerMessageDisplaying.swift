import Foundation
import UIKit

protocol PledgeViewControllerMessageDisplaying: AnyObject {
  func pledgeViewController(_ pledgeViewController: UIViewController, didErrorWith message: String)
  func pledgeViewController(_ pledgeViewController: UIViewController, didSucceedWith message: String)
}
