import Foundation
import KsApi
import Library
import UIKit

final class ProjectSummaryCarouselCell: UICollectionViewCell {
  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundColor = .gray
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ProjectSummaryCarouselCell: ValueCell {
  func configureWith(value _: ProjectSummaryEnvelope.ProjectSummaryItem) {}
}
