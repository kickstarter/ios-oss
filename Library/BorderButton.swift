import UIKit.UIButton
import UIKit.UIFont

@IBDesignable
public class BorderButton: UIButton {
  private var _color: Color = .White
  private var _borderColor: Color = .GrayDark
  private var _titleColorNormal: Color = .Black
  private var _titleColorHighlighted: Color = .GrayLight
  private var _titleFontTextStyle: FontText = .Body
  private var _titleWeightStyle: Weight = .Default

  @IBInspectable
  public var color: String {
    get {
      return _color.rawValue
    }

    set {
      guard let colorValue = Color(rawValue: newValue) else {
        assertionFailure("Couldn't find Styles.Color value. Make sure you typed correct name in IB.")
        return
      }
      _color = colorValue
      updateStyle()
    }
  }

  @IBInspectable
  public var borderColor: String {
    get {
      return _borderColor.rawValue
    }

    set {
      guard let colorValue = Color(rawValue: newValue) else {
        assertionFailure("Couldn't find Styles.Color value. Make sure you typed correct name in IB.")
        return
      }
      _borderColor = colorValue
      updateStyle()
    }
  }

  @IBInspectable
  public var titleColorNormal: String {
    get {
      return _titleColorNormal.rawValue
    }

    set {
      guard let colorValue = Color(rawValue: newValue) else {
        assertionFailure("Couldn't find Styles.Color value. Make sure you typed correct name in IB.")
        return
      }
      _titleColorNormal = colorValue
      updateStyle()
    }
  }

  @IBInspectable
  public var titleColorHighlighted: String {
    get {
      return _titleColorHighlighted.rawValue
    }

    set {
      guard let colorValue = Color(rawValue: newValue) else {
        assertionFailure("Couldn't find Styles.Color value. Make sure you typed correct name in IB.")
        return
      }
      _titleColorHighlighted = colorValue
      updateStyle()
    }
  }

  @IBInspectable
  public var titleFontTextStyle: String {
    get {
      return _titleFontTextStyle.rawValue
    }

    set {
      guard let fontStyle = FontText(rawValue: newValue) else {
        assertionFailure("Couldn't find Styles.FontText value. Make sure you typed correct name in IB.")
        return
      }
      _titleFontTextStyle = fontStyle
      updateStyle()
    }
  }

  @IBInspectable
  public var titleWeightStyle: String {
    get {
      return _titleWeightStyle.rawValue
    }

    set {
      guard let weightStyle = Weight(rawValue: newValue) else {
        assertionFailure("Couldn't find Styles.Weight value. Make sure you typed correct name in IB.")
        return
      }
      _titleWeightStyle = weightStyle
      updateStyle()
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    updateStyle()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    updateStyle()
  }

  override public func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    updateStyle()
  }

  func updateStyle() {
    self.titleLabel?.font = _titleFontTextStyle.toUIFont()

    if _titleWeightStyle == .Medium {
      self.titleLabel?.font = UIFont(descriptor: _titleFontTextStyle.toUIFont().fontDescriptor().fontDescriptorByAddingAttributes([UIFontWeightTrait: UIFontWeightMedium]), size: 0.0)
    }

    self.layer.cornerRadius = 6
    self.layer.borderWidth = 0.8
    self.setTitleColor(_titleColorNormal.toUIColor(), forState: UIControlState.Normal)
    self.setTitleColor(_titleColorHighlighted.toUIColor(), forState: UIControlState.Highlighted)
    self.backgroundColor = _color.toUIColor()
    self.layer.borderColor = _borderColor.toUIColor().CGColor
  }
}

