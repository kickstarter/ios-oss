import UIKit.UIButton
import UIKit.UIFont

@IBDesignable
public class BorderButton: UIButton {
  private var _color: Color? = .White
  private var _borderColor: Color? = .GrayDark
  private var _titleColorNormal: Color? = .Black
  private var _titleColorHighlighted: Color? = .GrayLight
  private var _titleFontTextStyle: FontText? = .Body
  private var _titleWeightStyle: Weight = .Default

  @IBInspectable
  public var color: String {
    get {
      return _color?.rawValue ?? ""
    }
    set {
      _color = Color(rawValue: newValue)
      updateStyle()
    }
  }

  @IBInspectable
  public var borderColor: String {
    get {
      return _borderColor?.rawValue ?? ""
    }
    set {
      _borderColor = Color(rawValue: newValue)
      updateStyle()
    }
  }

  @IBInspectable
  public var titleColorNormal: String {
    get {
      return _titleColorNormal?.rawValue ?? ""
    }
    set {
      _titleColorNormal = Color(rawValue: newValue)
      updateStyle()
    }
  }

  @IBInspectable
  public var titleColorHighlighted: String {
    get {
      return _titleColorHighlighted?.rawValue ?? ""
    }
    set {
      _titleColorHighlighted = Color(rawValue: newValue)
      updateStyle()
    }
  }

  @IBInspectable
  public var titleFontTextStyle: String {
    get {
      return _titleFontTextStyle?.rawValue ?? ""
    }
    set {
      _titleFontTextStyle = FontText(rawValue: newValue)
      updateStyle()
    }
  }

  @IBInspectable
  public var titleWeightStyle: String {
    get {
      return _titleWeightStyle.rawValue
    }
    set {
      _titleWeightStyle = Weight(rawValue: newValue) ?? .Default
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
    self.backgroundColor = _color?.toUIColor() ?? Color.Error.toUIColor()
    self.layer.borderColor = _borderColor?.toUIColor().CGColor ?? Color.Error.toUIColor().CGColor
    self.setTitleColor(_titleColorNormal?.toUIColor() ?? Color.Error.toUIColor(), forState: UIControlState.Normal)
    if let validHighlight = _titleColorHighlighted {
      self.setTitleColor(validHighlight.toUIColor(), forState: UIControlState.Highlighted)
    } else {
      self.setTitleColor(Color.Error.toUIColor(), forState: UIControlState.Normal)
    }

    switch (_titleFontTextStyle, _titleWeightStyle) {
    case let (font?, .Default):
      self.titleLabel?.font = font.toUIFont()
    case let (font?, .Medium):
      let descriptor = font.toUIFont().fontDescriptor()
      let mediumDescriptor = descriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
      self.titleLabel?.font = UIFont(descriptor: mediumDescriptor, size: 0.0)
    case (_, _):
      self.titleLabel?.font = UIFont(name: "Marker Felt", size: 15.0)
    }

    self.layer.cornerRadius = 6.0
    self.layer.borderWidth = 0.8
  }
}

