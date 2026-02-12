import UIKit

public typealias PaddingLabelStyle = (PaddingLabel) -> PaddingLabel

public class PaddingLabel: UILabel {
  var insets: UIEdgeInsets = UIEdgeInsets(all: Styles.grid(1))

  public override func drawText(in rect: CGRect) {
    super.drawText(in: rect.inset(by: self.insets))
  }

  public override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(
      width: size.width + self.insets.left + self.insets.right,
      height: size.height + self.insets.top + self.insets.bottom
    )
  }

  // MARK: Initializers

  public convenience init(frame: CGRect, edgeInsets: UIEdgeInsets) {
    self.init(frame: frame)

    self.insets = edgeInsets
  }
}
