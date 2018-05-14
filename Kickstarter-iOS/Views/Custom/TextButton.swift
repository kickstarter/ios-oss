import Foundation

/* A button designed to dynamically grow in height and width to fit the text of the titleLabel */
final class TextButton: UIButton {
  init() {
    super.init(frame: .zero)
  
    configure()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    configure()
  }
  
  override var intrinsicContentSize: CGSize {
    if let titleLabel = titleLabel {
      return CGSize(width: titleLabel.frame.width + contentEdgeInsets.left + contentEdgeInsets.right,
                    height: titleLabel.frame.height + contentEdgeInsets.top + contentEdgeInsets.bottom)
    } else {
      return super.intrinsicContentSize
    }
  }
  
  private func configure() {
    titleLabel?.setContentCompressionResistancePriority(.required, for: .vertical)
    titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
    titleLabel?.setContentHuggingPriority(.required, for: .horizontal)
    titleLabel?.setContentHuggingPriority(.required, for: .vertical)
  }
}
