import Foundation
import Library
import UIKit

class ImageViewElementCell: UITableViewCell, ValueCell {
  var imageElement = UIImageView()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.initialize()
  }

  override func prepareForReuse() {
    self.imageElement.image = nil
  }

  func initialize() {
    self.addSubview(self.imageElement)
    self.imageElement.contentMode = .scaleAspectFit
    NSLayoutConstraint.activate([
      self.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      self.topAnchor.constraint(equalTo: self.topAnchor)
    ])
  }

  func configureWith(value: ImageViewElement) {
    self.imageElement.image = value.image
  }
}
