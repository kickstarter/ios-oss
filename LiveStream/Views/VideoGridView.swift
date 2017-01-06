import UIKit
import ReactiveCocoa

public final class VideoGridView: UIView {

  public func addVideoView(view: UIView) {
    self.insertSubview(view, atIndex: 0)
    self.setNeedsLayout()
  }

  public func removeVideoView(view: UIView) {
    view.removeFromSuperview()
    self.setNeedsLayout()
  }

  //swiftlint:disable:next cyclomatic_complexity
  public override func layoutSubviews() {
    super.layoutSubviews()

    let fullWidth = self.bounds.size.width
    let fullHeight = self.bounds.size.height
    let halfWidth = fullWidth / 2
    let halfHeight = fullHeight / 2

    for (index, view) in self.subviews.enumerate() {
      switch (index, self.subviews.count) {
      //two views, side-by-side
      case (0, 2): view.frame = .init(x: 0, y: 0, width: halfWidth, height: fullHeight)
      case (1, 2): view.frame = .init(x: halfWidth, y: 0, width: halfWidth, height: fullHeight)

      //three views, one centred above the other two which are side-by-side
      case (0, 3): view.frame = .init(x: halfWidth / 2, y: 0, width: halfWidth, height: halfHeight)
      case (1, 3): view.frame = .init(x: 0, y: halfHeight, width: halfWidth, height: halfHeight)
      case (2, 3): view.frame = .init(x: halfWidth, y: halfHeight, width: halfWidth, height: halfHeight)

      //four views, in a 2x2 grid
      case (0, 4): view.frame = .init(x: 0, y: 0, width: halfWidth, height: halfHeight)
      case (1, 4): view.frame = .init(x: halfWidth, y: 0, width: halfWidth, height: halfHeight)
      case (2, 4): view.frame = .init(x: 0, y: halfHeight, width: halfWidth, height: halfHeight)
      case (3, 4): view.frame = .init(x: halfWidth, y: halfHeight, width: halfWidth, height: halfHeight)

      //one view, fills bounds
      default: view.frame = self.bounds
      }
    }
  }
}
