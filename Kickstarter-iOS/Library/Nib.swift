import UIKit

public enum Nib: String {
  case BackerDashboardEmptyStateCell
  case BackerDashboardProjectCell
  case LiveStreamChatInputView
  case LiveStreamNavTitleView
  case RewardCell
}

extension UITableView {
  public func register(nib: Nib, inBundle bundle: Bundle = .framework) {
    self.register(UINib(nibName: nib.rawValue, bundle: bundle), forCellReuseIdentifier: nib.rawValue)
  }
}
