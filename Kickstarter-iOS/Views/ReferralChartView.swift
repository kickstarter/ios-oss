import Library
import UIKit

public final class ReferralChartView: UIView {

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  public init() {
    super.init(frame: .zero)
    self.backgroundColor = .clear
  }

  public var internalPercentage: CGFloat = 0.0 {
    didSet {
      self.setNeedsDisplay()
    }
  }

  public var externalPercentage: CGFloat = 0.0 {
    didSet {
      self.setNeedsDisplay()
    }
  }

  // swiftlint:disable function_body_length
  public override func draw(_ rect: CGRect) {
    super.draw(rect)

    guard let context = UIGraphicsGetCurrentContext() else { return }

    let internalPercentageAngle = CGFloat(-M_PI_2) + self.internalPercentage * CGFloat(2.0 * M_PI)
    let internalAndExternalPercentage = min(self.internalPercentage + self.externalPercentage, 1.0)
    let internalAndExternalPercentageAngle = CGFloat(-M_PI_2) + internalAndExternalPercentage *
      CGFloat(2.0 * M_PI)

    UIColor.ksr_green_700.set()
    context.move(to: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2))
    context.addLine(to: CGPoint(x: self.bounds.width/2, y: 0))
    context.addArc(center: .init(x: self.bounds.width/2, y: self.bounds.height/2),
                   radius: self.bounds.width/2,
                   startAngle: CGFloat(-M_PI_2),
                   endAngle: internalPercentageAngle,
                   clockwise: false)
    context.closePath()
    context.fillPath()

    UIColor.ksr_orange_400.set()
    context.move(to: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2))
    context.addLine(
      to: CGPoint(
        x: self.bounds.width/2 + self.bounds.width/2 * cos(internalPercentageAngle),
        y: self.bounds.height/2 + self.bounds.height/2 * sin(internalPercentageAngle)
      )
    )
    context.addArc(center: .init(x: self.bounds.width/2, y: self.bounds.height/2),
                   radius: self.bounds.width/2,
                   startAngle: CGFloat(-M_PI_2) + self.internalPercentage * CGFloat(2.0 * M_PI),
                   endAngle: CGFloat(-M_PI_2) + internalAndExternalPercentage * CGFloat(2.0 * M_PI),
                   clockwise: false)
    context.closePath()
    context.fillPath()

    UIColor.ksr_violet_500.set()
    context.move(to: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2))
    context.addLine(
      to: CGPoint(
        x: self.bounds.width/2 + self.bounds.width/2 * cos(internalAndExternalPercentageAngle),
        y: self.bounds.height/2 + self.bounds.height/2 * sin(internalAndExternalPercentageAngle)
      )
    )
    context.addArc(center: .init(x: self.bounds.width/2, y: self.bounds.height/2),
                   radius: self.bounds.height/2,
                   startAngle: CGFloat(-M_PI_2) + internalAndExternalPercentage * CGFloat(2.0 * M_PI),
                   endAngle: CGFloat(-M_PI_2),
                   clockwise: false)
    context.closePath()
    context.fillPath()
  }
  // swiftlint:enable function_body_length
}
