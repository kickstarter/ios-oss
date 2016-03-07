import UIKit.UIButton
import UIKit.UIFont

@IBDesignable
public class BorderButton: UIButton {

  @IBInspectable
  public var color:UIColor = KSColor.White {
    didSet {
      self.backgroundColor = color
    }
  }

  @IBInspectable
  public var borderColor:UIColor = KSColor.GrayDark {
    didSet {
      self.layer.borderColor = borderColor.CGColor
    }
  }

  @IBInspectable
  public var titleColor:UIColor = KSColor.Black {
    didSet {
      self.setTitleColor(titleColor, forState: UIControlState.Normal)
    }
  }

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
    self.layer.cornerRadius = 6
    self.layer.borderWidth = 0.8
    self.setTitleColor(titleColor, forState: UIControlState.Normal)
    self.backgroundColor = color
    self.layer.borderColor = borderColor.CGColor
  }
}
