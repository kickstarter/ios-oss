import UIKit.UILabel

@IBDesignable
public class StyledLabel: UILabel {
  private var _fontTextStyle: FontText? = FontText.Body
  private var _colorStyle: Color? = Color.TextDefault
  private var _weightStyle: Weight = Weight.Default

  @IBInspectable
  public var fontTextStyle: String {
    get {
      return _fontTextStyle?.rawValue ?? ""
    }
    set {
      _fontTextStyle = FontText(rawValue: newValue)
      updateStyle()
    }
  }

  @IBInspectable
  public var colorStyle: String {
    get {
      return _colorStyle?.rawValue ?? ""
    }
    set {
      _colorStyle = Color(rawValue: newValue)
      updateStyle()
    }
  }

  @IBInspectable
  public var weightStyle: String {
    get {
      return _weightStyle.rawValue
    }
    set {
      _weightStyle = Weight(rawValue: newValue) ?? .Default
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
    self.textColor = _colorStyle?.toUIColor() ?? Color.Error.toUIColor()

    switch (_fontTextStyle, _weightStyle) {
    case let (font?, .Default):
      self.font = font.toUIFont()
    case let (font?, .Medium):
      let descriptor = font.toUIFont().fontDescriptor()
      let mediumDescriptor = descriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
      self.font = UIFont(descriptor: mediumDescriptor, size: 0.0)
    case (_, _):
      self.font = UIFont(name: "Marker Felt", size: 15.0)
    }
  }
}
