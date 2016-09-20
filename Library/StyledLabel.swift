import class UIKit.UILabel
import class UIKit.UIFont

public final class StyledLabel: UILabel {
  public var fontStyle: FontStyle? = .Body {
    didSet {
      self.font = self.computedFont
    }
  }

  public var weight: Weight? = .Default {
    didSet {
      self.font = self.computedFont
    }
  }

  public var color: Color? = .TextDefault {
    didSet {
      self.textColor = color?.toUIColor() ?? Color.mismatchedColor
    }
  }

  public var _fontStyle: String = FontStyle.Body.rawValue {
    didSet {
      self.fontStyle = FontStyle(rawValue: _fontStyle)
    }
  }

  public var _weight: String = Weight.Default.rawValue {
    didSet {
      self.weight = Weight(rawValue: _weight)
    }
  }

  public var _color: String = Color.TextDefault.rawValue {
    didSet {
      self.color = Color(rawValue: _color)
    }
  }

  // Computes a font from the component of font style and weight.
  private var computedFont: UIFont {
    switch (fontStyle, weight) {
    case let (font?, .Default?):
      return font.toUIFont()
    case let (font?, .Medium?):
      return font.toUIFont().bolded
    case (_, _):
      return FontStyle.mismatchedFont
    }
  }
}
