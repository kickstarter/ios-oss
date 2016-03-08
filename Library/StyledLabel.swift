import UIKit.UILabel

@IBDesignable
public class StyledLabel: UILabel {
  private var _styleFontText: FontText = FontText.Body
  private var _styleColor: Color = Color.TextDefault
  private var _styleWeight: Weight = Weight.Default

  @IBInspectable
  public var fontTextStyle: String {
    get {
      return _styleFontText.rawValue
    }

    set {
      guard let fontStyle = FontText(rawValue: newValue) else {
        assertionFailure("Couldn't find Styles.FontText value. Make sure you typed correct name in IB.")
        return
      }
      _styleFontText = fontStyle
      updateStyle()
    }
  }

  @IBInspectable
  public var colorStyle: String {
    get {
      return _styleColor.rawValue
    }

    set {
      guard let colorStyle = Color(rawValue: newValue) else {
        assertionFailure("Couldn't find Styles.Color value. Make sure you typed correct name in IB.")
        return
      }
      _styleColor = colorStyle
      updateStyle()
    }
  }

  @IBInspectable
  public var weightStyle: String {
    get {
      return _styleWeight.rawValue
    }

    set {
      guard let weightStyle = Weight(rawValue: newValue) else {
        assertionFailure("Couldn't find Styles.Weight value. Make sure you typed correct name in IB.")
        return
      }
      _styleWeight = weightStyle
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
    self.textColor = _styleColor.toUIColor()
    self.font = _styleFontText.toUIFont()

    if _styleWeight == .Medium {
      self.font = UIFont(descriptor: self.font.fontDescriptor().fontDescriptorByAddingAttributes([UIFontWeightTrait: UIFontWeightMedium]), size: 0.0)
    }
  }
}
