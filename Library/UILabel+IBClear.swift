import class UIKit.UILabel

public extension UILabel {

  /**
   Turn this option on in IB to have the value of the label cleared on initialization.
  */
  @IBInspectable
  public var clearIBValue: Bool {
    set(clear) {
#if !TARGET_INTERFACE_BUILDER
      if clear {
        self.text = ""
      }
#endif
    }
    get {
      return false
    }
  }
}
