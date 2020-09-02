import UIKit

public final class EasyButton: UIButton {
  public var hitMargin = CGFloat(5)

  public override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
    let area = self.bounds.insetBy(dx: -self.hitMargin, dy: -self.hitMargin)
    return area.contains(point)
  }
}
