import UIKit.UIButton
import UIKit.UIFont

@IBDesignable
public final class BorderButton: UIButton {
  private var _color: Color? = .White
  private var _borderColor: Color? = .GrayDark
  private var _titleColorNormal: Color? = .Black
  private var _titleColorHighlighted: Color? = .GrayLight
  private var _titleFontStyle: FontStyle? = .Body
  private var _titleWeight: Weight = .Default

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
  public var titleFontStyle: String {
    get {
      return _titleFontStyle?.rawValue ?? ""
    }
    set {
      _titleFontStyle = FontStyle(rawValue: newValue)
      updateStyle()
    }
  }

  @IBInspectable
  public var titleWeight: String {
    get {
      return _titleWeight.rawValue
    }
    set {
      _titleWeight = Weight(rawValue: newValue) ?? .Default
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

  private func updateStyle() {
    self.backgroundColor = _color?.toUIColor() ?? Color.mismatchedColor
    self.layer.borderColor = _borderColor?.toUIColor().CGColor ?? Color.mismatchedColor.CGColor
    self.setTitleColor(_titleColorNormal?.toUIColor() ?? Color.mismatchedColor, forState: UIControlState.Normal)
    if let validHighlight = _titleColorHighlighted {
      self.setTitleColor(validHighlight.toUIColor(), forState: UIControlState.Highlighted)
    } else {
      self.setTitleColor(Color.mismatchedColor, forState: UIControlState.Normal)
    }

    switch (_titleFontStyle, _titleWeight) {
    case let (font?, .Default):
      self.titleLabel?.font = font.toUIFont()
    case let (font?, .Medium):
      let descriptor = font.toUIFont().fontDescriptor()
      let mediumDescriptor = descriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
      self.titleLabel?.font = UIFont(descriptor: mediumDescriptor, size: 0.0)
    case (_, _):
      self.titleLabel?.font = FontStyle.mismatchedFont
    }

    self.layer.cornerRadius = 6.0
    self.layer.borderWidth = 1.0
  }
}

