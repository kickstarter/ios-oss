import UIKit.UILabel

@IBDesignable
public final class StyledLabel: UILabel {
  private var _fontStyle: FontStyle? = .Body
  private var _color: Color? = .TextDefault
  private var _weight: Weight = .Default

  @IBInspectable
  public var fontStyle: String {
    get {
      return _fontStyle?.rawValue ?? ""
    }
    set {
      _fontStyle = FontStyle(rawValue: newValue)
      updateStyle()
    }
  }

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
  public var weight: String {
    get {
      return _weight.rawValue
    }
    set {
      _weight = Weight(rawValue: newValue) ?? .Default
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
    self.textColor = _color?.toUIColor() ?? Color.mismatchedColor

    switch (_fontStyle, _weight) {
    case let (font?, .Default):
      self.font = font.toUIFont()
    case let (font?, .Medium):
      let descriptor = font.toUIFont().fontDescriptor()
      let mediumDescriptor = descriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
      self.font = UIFont(descriptor: mediumDescriptor, size: 0.0)
    case (_, _):
      self.font = FontStyle.mismatchedFont
    }
  }
}
