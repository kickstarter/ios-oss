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
    CGContextAddArc(context,
                    self.bounds.width/2,
                    self.bounds.height/2,
                    self.bounds.width/2,
                    CGFloat(-M_PI_2),
                    internalPercentageAngle,
                    0)
    context.closePath()
    context.fillPath()

    UIColor.ksr_orange_400.set()
    context.move(to: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2))
    context.addLine(to: CGPoint(x: self.bounds.width/2 + self.bounds.width/2 * cos(internalPercentageAngle), y: self.bounds.height/2 + self.bounds.height/2 * sin(internalPercentageAngle)))
    CGContextAddArc(context,
                    self.bounds.width/2,
                    self.bounds.height/2,
                    self.bounds.width/2,
                    CGFloat(-M_PI_2) + self.internalPercentage * CGFloat(2.0 * M_PI),
                    CGFloat(-M_PI_2) + internalAndExternalPercentage * CGFloat(2.0 * M_PI),
                    0)
    context.closePath()
    context.fillPath()

    UIColor.ksr_violet_500.set()
    context.move(to: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2))
    context.addLine(to: CGPoint(x: self.bounds.width/2 + self.bounds.width/2 *
                              cos(internalAndExternalPercentageAngle), y: self.bounds.height/2 + self.bounds.height/2 *
                              sin(internalAndExternalPercentageAngle)))
    CGContextAddArc(context,
                    self.bounds.width/2,
                    self.bounds.height/2,
                    self.bounds.width/2,
                    CGFloat(-M_PI_2) + internalAndExternalPercentage * CGFloat(2.0 * M_PI),
                    CGFloat(-M_PI_2),
                    0)
    context.closePath()
    context.fillPath()
  }
  // swiftlint:enable function_body_length
}
