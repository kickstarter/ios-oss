import Prelude
import Prelude_UIKit
import ReactiveSwift
import ReactiveExtensions
import Result
import UIKit

private let defaultFont = UIFont.systemFont(ofSize: 12)
private let defaultColor = UIColor.ksr_text_grey_900

public protocol SimpleHTMLLabelProtocol: UILabelProtocol {
  var baseAttributes: [String:AnyObject] { get set }
  var baseColor: UIColor { get set }
  var baseFont: UIFont { get set }
  var boldAttributes: [String:AnyObject] { get set }
  var boldColor: UIColor { get set }
  var boldFont: UIFont { get set }
  var html: String { get set }
  var italicAttributes: [String:AnyObject] { get set }
  var italicColor: UIColor { get set }
  var italicFont: UIFont { get set }
}

public final class SimpleHTMLLabel: UILabel, SimpleHTMLLabelProtocol {
  public var baseAttributes: [String:AnyObject] = [NSFontAttributeName: defaultFont] {
    didSet {
      self.setNeedsLayout()
    }
  }
  public var boldAttributes: [String:AnyObject] = [NSFontAttributeName: defaultFont] {
    didSet {
      self.setNeedsLayout()
    }
  }
  public var italicAttributes: [String:AnyObject] = [NSFontAttributeName: defaultFont] {
    didSet {
      self.setNeedsLayout()
    }
  }

  public var baseFont: UIFont {
    get {
      return (self.baseAttributes[NSFontAttributeName] as? UIFont) ?? defaultFont
    }
    set {
      self.baseAttributes = self.baseAttributes.withAllValuesFrom([NSFontAttributeName: newValue])
    }
  }

  public var baseColor: UIColor {
    get {
      return (self.baseAttributes[NSForegroundColorAttributeName] as? UIColor) ?? defaultColor
    }
    set {
      self.baseAttributes = self.baseAttributes.withAllValuesFrom([NSForegroundColorAttributeName: newValue])
    }
  }

  public var boldFont: UIFont {
    get {
      return (self.boldAttributes[NSFontAttributeName] as? UIFont) ?? defaultFont
    }
    set {
      self.boldAttributes = self.boldAttributes.withAllValuesFrom([NSFontAttributeName: newValue])
    }
  }

  public var boldColor: UIColor {
    get {
      return (self.boldAttributes[NSForegroundColorAttributeName] as? UIColor) ?? defaultColor
    }
    set {
      self.boldAttributes = self.boldAttributes.withAllValuesFrom([NSForegroundColorAttributeName: newValue])
    }
  }

  public var italicFont: UIFont {
    get {
      return (self.italicAttributes[NSFontAttributeName] as? UIFont) ?? defaultFont
    }
    set {
      self.italicAttributes = self.italicAttributes.withAllValuesFrom([NSFontAttributeName: newValue])
    }
  }

  public var italicColor: UIColor {
    get {
      return (self.italicAttributes[NSForegroundColorAttributeName] as? UIColor) ?? defaultColor
    }
    set {
      self.italicAttributes = self.italicAttributes.withAllValuesFrom(
        [NSForegroundColorAttributeName: newValue]
      )
    }
  }

  public var html: String = "" {
    didSet {
      self.setNeedsLayout()
    }
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    self.updateAttributedText()
  }

  fileprivate func updateAttributedText() {
    self.attributedText = self.html.simpleHtmlAttributedString(
      base: self.baseAttributes,
      bold: self.baseAttributes.withAllValuesFrom(self.boldAttributes),
      italic: self.baseAttributes.withAllValuesFrom(self.italicAttributes)
    )
  }
}

extension LensHolder where Object: SimpleHTMLLabelProtocol {

  public var baseAttributes: Lens<Object, [String:AnyObject]> {
    return Lens(
      view: { $0.baseAttributes },
      set: { $1.baseAttributes = $0; return $1 }
    )
  }

  public var baseColor: Lens<Object, UIColor> {
    return Lens(
      view: { $0.baseColor },
      set: { $1.baseColor = $0; return $1 }
    )
  }

  public var baseFont: Lens<Object, UIFont> {
    return Lens(
      view: { $0.baseFont },
      set: { $1.baseFont = $0; return $1 }
    )
  }

  public var boldAttributes: Lens<Object, [String:AnyObject]> {
    return Lens(
      view: { $0.boldAttributes },
      set: { $1.boldAttributes = $0; return $1 }
    )
  }

  public var boldColor: Lens<Object, UIColor> {
    return Lens(
      view: { $0.boldColor },
      set: { $1.boldColor = $0; return $1 }
    )
  }

  public var boldFont: Lens<Object, UIFont> {
    return Lens(
      view: { $0.boldFont },
      set: { $1.boldFont = $0; return $1 }
    )
  }

  public var html: Lens<Object, String> {
    return Lens(
      view: { $0.html },
      set: { $1.html = $0; return $1 }
    )
  }

  public var italicAttributes: Lens<Object, [String:AnyObject]> {
    return Lens(
      view: { $0.italicAttributes },
      set: { $1.italicAttributes = $0; return $1 }
    )
  }

  public var italicColor: Lens<Object, UIColor> {
    return Lens(
      view: { $0.italicColor },
      set: { $1.italicColor = $0; return $1 }
    )
  }

  public var italicFont: Lens<Object, UIFont> {
    return Lens(
      view: { $0.italicFont },
      set: { $1.italicFont = $0; return $1 }
    )
  }
}

private enum Associations {
  fileprivate static var html = 0
}

public extension Rac where Object: SimpleHTMLLabel {

  public var html: Signal<String, NoError> {
    nonmutating set {
      let prop: MutableProperty<String> = lazyMutableProperty(
        object,
        key: &Associations.html,
        setter: { [weak object] in object?.html = $0 },
        getter: { [weak object] in object?.html ?? "" })

      prop <~ newValue.observeForUI()
    }

    get {
      return .empty
    }
  }
}
