import UIKit

extension UITableView {
  public func ksr_sizeHeaderFooterViewsToFit() {
    let keyPaths: [ReferenceWritableKeyPath<UITableView, UIView?>] = [
      \.tableHeaderView,
      \.tableFooterView
    ]

    keyPaths.forEach { keyPath in
      if let view = self[keyPath: keyPath] {
        let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        if view.frame.height != size.height {
          view.frame.size.height = size.height

          self[keyPath: keyPath] = view
        }
      }
    }
  }
}
