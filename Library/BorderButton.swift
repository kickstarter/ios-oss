import class UIKit.UIButton
import class UIKit.UIFont
import struct UIKit.UIControlState
import struct UIKit.CGFloat
import class Foundation.NSCoder
import struct UIKit.CGRect

private let DefaultBorderWidth: CGFloat = 1.0
private let DefaultCornerRadius: CGFloat = 6.0

public final class BorderButton: UIButton {
  public var color: Color? = .White {
    didSet {
      self.backgroundColor = color?.toUIColor() ?? Color.mismatchedColor
    }
  }

  public var borderColor: Color? = .GrayDark {
    didSet {
      self.layer.borderColor = borderColor?.toUIColor().cgColor ?? Color.mismatchedColor.cgColor
    }
  }

  public var titleColorNormal: Color? = .Black {
    didSet {
      self.setTitleColor(
        titleColorNormal?.toUIColor() ?? Color.mismatchedColor, for: UIControlState()
      )
    }
  }

  public var titleColorHighlighted: Color? = .GrayLight {
    didSet {
      if let titleColorHighlighted = titleColorHighlighted {
        self.setTitleColor(titleColorHighlighted.toUIColor(), for: UIControlState.highlighted)
      } else {
        self.setTitleColor(Color.mismatchedColor, for: UIControlState())
      }
    }
  }

  public var titleFontStyle: FontStyle? = .Body {
    didSet {
      self.titleLabel?.font = self.computedTitleFont
    }
  }

  public var titleWeight: Weight? = .Default {
    didSet {
      self.titleLabel?.font = self.computedTitleFont
    }
  }

  public var _color: String = Color.White.rawValue {
    didSet {
      color = Color(rawValue: _color)
    }
  }

  public var _borderColor: String = Color.Black.rawValue {
    didSet {
      borderColor = Color(rawValue: _borderColor)
    }
  }

  public var _titleColorNormal: String = Color.TextDefault.rawValue {
    didSet {
      titleColorNormal = Color(rawValue: _titleColorNormal)
    }
  }

  public var _titleColorHighlighted: String = Color.TextLightGray.rawValue {
    didSet {
      titleColorHighlighted = Color(rawValue: _titleColorHighlighted)
    }
  }

  public var _titleFontStyle: String = FontStyle.Body.rawValue {
    didSet {
      titleFontStyle = FontStyle(rawValue: _titleFontStyle)
    }
  }

  public var _titleWeight: String = Weight.Default.rawValue {
    didSet {
      titleWeight = Weight(rawValue: _titleWeight)
    }
  }

  fileprivate var computedTitleFont: UIFont {
    switch (titleFontStyle, titleWeight) {
    case let (font?, .Default?):
      return font.toUIFont()
    case let (font?, .Medium?):
      return font.toUIFont().bolded
    case (_, _):
      return FontStyle.mismatchedFont
    }
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.layer.cornerRadius = DefaultCornerRadius
    self.layer.borderWidth = DefaultBorderWidth

    self.titleLabel?.textAlignment = .center
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)

    self.layer.cornerRadius = DefaultCornerRadius
    self.layer.borderWidth = DefaultBorderWidth

    self.titleLabel?.textAlignment = .center
  }

}
