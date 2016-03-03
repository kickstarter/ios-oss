import class UIKit.UIImageView
import func ObjectiveC.objc_getAssociatedObject
import func ObjectiveC.objc_setAssociatedObject
import enum ObjectiveC.objc_AssociationPolicy
import class Foundation.NSCoder
import func UIKit./

private var circleAvatarAssociation: UInt8 = 0

public extension UIImageView {

  @IBInspectable
  public var circleAvatar: Bool {
    get {
      return (objc_getAssociatedObject(self, &circleAvatarAssociation) as? Bool) ?? false
    }
    set(value) {
      objc_setAssociatedObject(self, &circleAvatarAssociation, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    if self.circleAvatar {
      self.layer.cornerRadius = self.bounds.width / 2.0
      self.layer.masksToBounds = true
    } else {
      self.layer.cornerRadius = 0.0
      self.layer.masksToBounds = false
    }
  }
}
