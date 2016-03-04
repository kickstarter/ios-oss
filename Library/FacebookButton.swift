import UIKit.UIButton
import UIKit.UIFont

@IBDesignable
public class FacebookButton: UIButton {
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
    self.setTitleColor(KSColor.White.color, forState: UIControlState.Normal)
    self.backgroundColor = SocialColor.FacebookBlue.color
    self.layer.cornerRadius = 6
  }
}
