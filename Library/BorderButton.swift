import UIKit.UIButton
import UIKit.UIFont

@IBDesignable
public class BorderButton: UIButton {
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    onCreate()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    onCreate()
  }

  override public func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    onCreate()
  }

  func onCreate() {
    self.titleLabel?.font = UIFont.systemFontOfSize(14.0, weight: UIFontWeightRegular)
    self.setTitleColor(KSColor.Black, forState: UIControlState.Normal)
    self.backgroundColor = KSColor.White
    self.layer.cornerRadius = 6
    self.layer.borderColor = KSColor.GrayDark.CGColor
    self.layer.borderWidth = 0.8
  }
}
