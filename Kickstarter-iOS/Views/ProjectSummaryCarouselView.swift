import Foundation
import UIKit

final class ProjectSummaryCarouselView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundColor = .red

    self.heightAnchor.constraint(equalToConstant: 50).isActive = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
