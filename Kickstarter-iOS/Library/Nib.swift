import UIKit

public enum Nib: String {
  case BackerDashboardEmptyStateCell
  case BackerDashboardProjectCell
  case DiscoveryPostcardCell
  case LiveStreamNavTitleView
  case RewardCell
  case ThanksCategoryCell
  case DiscoveryProjectCategoryView
}

extension UITableView {
  public func register(nib: Nib, inBundle bundle: Bundle = .framework) {
    self.register(UINib(nibName: nib.rawValue, bundle: bundle), forCellReuseIdentifier: nib.rawValue)
  }
}

protocol NibLoading {
  associatedtype CustomNibType
  
  static func fromNib(nib: Nib) -> CustomNibType?
}

extension NibLoading {
  static func fromNib(nib: Nib) -> Self? {
    guard let view = UINib(nibName: nib.rawValue, bundle: .framework)
      .instantiate(withOwner: self, options: nil)
      .first as? Self else {
        assertionFailure("Nib not found")
        return nil
    }
    
    return view
  }
}
