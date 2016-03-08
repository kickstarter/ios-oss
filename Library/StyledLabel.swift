import UIKit.UILabel

@IBDesignable
public class StyledLabel: UILabel {
  private var _fontTextStyle: FontText = FontText.Body
  private var _colorStyle: Color = Color.TextDefault
  private var _weightStyle: Weight = Weight.Default

  @IBInspectable
  public var fontTextStyle: String {
    get {
      return _fontTextStyle.rawValue
    }
    set {
      guard let fontStyle = FontText(rawValue: newValue) else {
        assertionFailure("Couldn't find Styles.FontText value. Make sure you typed correct name in IB.")
        return
      }
      _fontTextStyle = fontStyle
      updateStyle()
    }
  }

  @IBInspectable
  public var colorStyle: String {
    get {
      return _colorStyle.rawValue
    }
    set {
      guard let colorStyle = Color(rawValue: newValue) else {
        assertionFailure("Couldn't find Styles.Color value. Make sure you typed correct name in IB.")
        return
      }
      _colorStyle = colorStyle
      updateStyle()
    }
  }

  @IBInspectable
  public var weightStyle: String {
    get {
      return _weightStyle.rawValue
    }
    set {
      guard let weightStyle = Weight(rawValue: newValue) else {
        assertionFailure("Couldn't find Styles.Weight value. Make sure you typed correct name in IB.")
        return
      }
      _weightStyle = weightStyle
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
    self.textColor = _colorStyle.toUIColor()
    self.font = _fontTextStyle.toUIFont()

    if _weightStyle == .Medium {
      self.font = UIFont(descriptor: self.font.fontDescriptor().fontDescriptorByAddingAttributes([UIFontWeightTrait: UIFontWeightMedium]), size: 0.0)
    }
  }
}
