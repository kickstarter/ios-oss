import Foundation
import Library
import UIKit

class EmbeddedLinkViewElementCell: UITableViewCell, ValueCell {
  var imageElement = UIImageView()
  var captionLabel = UILabel()
  var topLabelConstraint: NSLayoutConstraint?
  
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
    self.captionLabel.attributedText = nil
  }
  
  func initialize() {
    self.addSubview(self.imageElement)
    self.imageElement.contentMode = .scaleAspectFit
    NSLayoutConstraint.activate([
      self.imageElement.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.imageElement.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.imageElement.topAnchor.constraint(equalTo: self.topAnchor),
      self.imageElement.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
    
    self.captionLabel.numberOfLines = 0
    self.addSubview(self.captionLabel)
    self.captionLabel.setContentHuggingPriority(.required, for: .vertical)
    NSLayoutConstraint.activate([
      self.captionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
      self.captionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
      self.captionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
    ])
    self.topLabelConstraint = self.captionLabel.topAnchor.constraint(equalTo: self.imageElement.bottomAnchor, constant: 16)
  }
  
  func configureWith(value: EmbeddedLinkViewElement) {
    self.imageElement.image = value.image
    
    guard let topLabelConstraint = self.topLabelConstraint else { return }
    if let captionText = value.attributedText {
      self.captionLabel.attributedText = captionText
      NSLayoutConstraint.activate([topLabelConstraint])
    } else {
      NSLayoutConstraint.deactivate([topLabelConstraint])
    }
  }
}
