import UIKit
import Prelude

public class ClearNavigationBar: UINavigationBar {

  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }

  private func setup() {
    self.backgroundGradientView.startPoint = .zero
    self.backgroundGradientView.endPoint = CGPoint(x: 0, y: 1)
    self.backgroundGradientView.setGradient([
      (UIColor(white: 0, alpha: 0.5), 0),
      (UIColor(white: 0, alpha: 0), 1)
      ])

    self
      |> UINavigationBar.lens.titleTextAttributes .~ [
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont.ksr_callout()
      ]
      |> UINavigationBar.lens.translucent .~ true
      |> UINavigationBar.lens.barTintColor .~ .whiteColor()
      |> UINavigationBar.lens.shadowImage .~ UIImage()

    self.setBackgroundImage(UIImage(), forBarMetrics: .Default)

    self.addSubview(self.backgroundGradientView)
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    self.backgroundGradientView.frame = self.bounds

    if self.subviews.indexOf(self.backgroundGradientView) != 0 {
      self.sendSubviewToBack(self.backgroundGradientView)
    }
  }

  lazy var backgroundGradientView: GradientView = {
    let gradientView = GradientView()
    return gradientView
  }()
}