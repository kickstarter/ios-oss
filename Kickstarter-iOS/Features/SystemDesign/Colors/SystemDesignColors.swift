import Prelude
import Prelude_UIKit
import UIKit

public enum SystemDesignColorStyle: String, CaseIterable {
  case alert
  case black
  case celebrate100
  case celebrate300
  case celebrate500
  case celebrate700
  case create100
  case create300
  case create500
  case create700
  case facebookBlue
  case inform
  case support100
  case support200
  case support300
  case support400
  case support500
  case support700
  case trust100
  case trust300
  case trust500
  case trust700
  case warn
  case white
  case cellSeparator
}

extension SystemDesignColorStyle {
  public func load() -> UIColor? {
    UIColor(named: self.rawValue)
  }
}

public func adaptiveColor(_ style: SystemDesignColorStyle) -> UIColor {
  style.load()! // not ideal to force unwrap. need to work on a better approach.
}
