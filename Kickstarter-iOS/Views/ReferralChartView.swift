import Library
import UIKit

public final class ReferralChartView: UIView {

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.backgroundColor = .clearColor()
  }

  public init() {
    super.init(frame: .zero)
    self.backgroundColor = .clearColor()
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

  public var ringThicknessPercentage: CGFloat = 0.1 {
    didSet {
      self.setNeedsDisplay()
    }
  }

  // swiftlint:disable function_body_length
  public override func drawRect(rect: CGRect) {
    super.drawRect(rect)

    let context = UIGraphicsGetCurrentContext()

    let internalPercentageAngle = CGFloat(-M_PI_2) + self.internalPercentage * CGFloat(2.0 * M_PI)
    let internalAndExternalPercentage = min(self.internalPercentage + self.externalPercentage, 1.0)
    let internalAndExternalPercentageAngle = CGFloat(-M_PI_2) + internalAndExternalPercentage *
      CGFloat(2.0 * M_PI)

    UIColor.ksr_green_700.set()
    CGContextMoveToPoint(context, self.bounds.width/2, self.bounds.height/2)
    CGContextAddLineToPoint(context, self.bounds.width/2, 0)
    CGContextAddArc(context,
                    self.bounds.width/2,
                    self.bounds.height/2,
                    self.bounds.width/2,
                    CGFloat(-M_PI_2),
                    internalPercentageAngle,
                    0)
    CGContextClosePath(context)
    CGContextFillPath(context)

    UIColor.ksr_orange_400.set()
    CGContextMoveToPoint(context, self.bounds.width/2, self.bounds.height/2)
    CGContextAddLineToPoint(context,
                            self.bounds.width/2 + self.bounds.width/2 * cos(internalPercentageAngle),
                            self.bounds.height/2 + self.bounds.height/2 * sin(internalPercentageAngle))
    CGContextAddArc(context,
                    self.bounds.width/2,
                    self.bounds.height/2,
                    self.bounds.width/2,
                    CGFloat(-M_PI_2) + self.internalPercentage * CGFloat(2.0 * M_PI),
                    CGFloat(-M_PI_2) + internalAndExternalPercentage * CGFloat(2.0 * M_PI),
                    0)
    CGContextClosePath(context)
    CGContextFillPath(context)

    UIColor.ksr_violet_850.set()
    CGContextMoveToPoint(context, self.bounds.width/2, self.bounds.height/2)
    CGContextAddLineToPoint(context,
                            self.bounds.width/2 + self.bounds.width/2 *
                              cos(internalAndExternalPercentageAngle),
                            self.bounds.height/2 + self.bounds.height/2 *
                              sin(internalAndExternalPercentageAngle))
    CGContextAddArc(context,
                    self.bounds.width/2,
                    self.bounds.height/2,
                    self.bounds.width/2,
                    CGFloat(-M_PI_2) + internalAndExternalPercentage * CGFloat(2.0 * M_PI),
                    CGFloat(-M_PI_2),
                    0)
    CGContextClosePath(context)
    CGContextFillPath(context)

    UIColor.ksr_grey_100.set()
    CGContextFillEllipseInRect(
      context,
      rect.insetBy(
        dx: self.ringThicknessPercentage * self.bounds.width,
        dy: self.ringThicknessPercentage * self.bounds.height
      )
    )
  }
  // swiftlint:enable function_body_length

}
