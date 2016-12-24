import KsApi
import Library
import Prelude
import UIKit

private typealias Line = (start: CGPoint, end: CGPoint)

public final class FundingGraphView: UIView {
  fileprivate let goalLabel = UILabel()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.setUp()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setUp()
  }

  fileprivate func setUp() {
    self.backgroundColor = .clear
    self.addSubview(self.goalLabel)
    _ = self.goalLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 12)
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.backgroundColor .~ .ksr_green_500
      |> UILabel.lens.textAlignment .~ .center
  }

  internal var fundedPointRadius: CGFloat = 12.0 {
    didSet {
      self.setNeedsDisplay()
    }
  }

  internal var lineThickness: CGFloat = 1.5 {
    didSet {
      self.setNeedsDisplay()
    }
  }

  internal var project: Project! {
    didSet {
      self.setNeedsDisplay()
    }
  }

  internal var stats: [ProjectStatsEnvelope.FundingDateStats]! {
    didSet {
      self.setNeedsDisplay()
    }
  }

  internal var yAxisTickSize: CGFloat = 1.0 {
    didSet {
      self.setNeedsDisplay()
    }
  }

  // swiftlint:disable function_body_length
  public override func draw(_ rect: CGRect) {
    super.draw(rect)

    // Map the date and pledged amount to (dayNumber, pledgedAmount).
    let datePledgedPoints = stats
      .enumerated()
      .map { index, stat in CGPoint(x: index, y: stat.cumulativePledged) }

    let durationInDays = totalNumberOfDays(startDate: project.dates.launchedAt,
                                           endDate: project.dates.deadline)

    let goal = project.stats.goal

    let pointsPerDay = (self.bounds.width - self.layoutMargins.left) / durationInDays

    let pointsPerDollar = self.bounds.height /
      (CGFloat(DashboardFundingCellViewModel.tickCount) * self.yAxisTickSize)

    // Draw the funding progress grey line and fill.
    let line = UIBezierPath()
    line.lineWidth = self.lineThickness

    var lastPoint = CGPoint(x: self.layoutMargins.left, y: self.bounds.height)
    line.move(to: lastPoint)

    datePledgedPoints.forEach { point in
      let x = point.x * pointsPerDay + self.layoutMargins.left
      let y = self.bounds.height - min(point.y * pointsPerDollar, self.bounds.height)
      line.addLine(to: CGPoint(x: x, y: y))
      lastPoint = CGPoint(x: x, y: y)
    }

    // Stroke the darker graph line before filling with lighter color.
    UIColor.ksr_text_navy_500.setStroke()
    line.stroke()

    line.addLine(to: CGPoint(x: lastPoint.x, y: self.bounds.height))
    line.close()

    UIColor.ksr_navy_400.setFill()
    line.fill(with: .color, alpha: 0.4)

    let projectHasFunded = stats.last?.cumulativePledged ?? 0 >= goal
    if projectHasFunded {

      let rightFundedStat = stats.split { $0.cumulativePledged < goal }.last?.first
      let rightFundedPoint = CGPoint(
        x: dateToDayNumber(
          launchDate: stats.first?.date ?? 0,
          currentDate: rightFundedStat?.date ?? 0
        ),
        y: CGFloat(rightFundedStat?.cumulativePledged ?? 0)
      )

      let leftFundedStat = stats.filter { $0.cumulativePledged < goal }.last
      let leftFundedPoint = isNil(leftFundedStat) ?
        CGPoint(x: 0.0, y: 0.0) :
        CGPoint(
          x: dateToDayNumber(
            launchDate: stats.first?.date ?? 0,
            currentDate: leftFundedStat?.date ?? 0),
          y: CGFloat(leftFundedStat?.cumulativePledged ?? 0)
      )

      let leftPointX = leftFundedPoint.x * pointsPerDay + self.layoutMargins.left
      let leftPointY = self.bounds.height - min(leftFundedPoint.y * pointsPerDollar, self.bounds.height)

      let rightPointX = rightFundedPoint.x * pointsPerDay + self.layoutMargins.left
      let rightPointY = self.bounds.height - min(rightFundedPoint.y * pointsPerDollar, self.bounds.height)

      // Surrounding left and right points, used to find slope of line containing funded point.
      let lineAPoint1 = CGPoint(x: leftPointX, y: leftPointY)
      let lineAPoint2 = CGPoint(x: rightPointX, y: rightPointY)
      let lineA = Line(start: lineAPoint1, end: lineAPoint2)

      // Intersecting funded horizontal line.
      let lineBPoint1 = CGPoint(x: self.layoutMargins.left,
                                y: self.bounds.height -
                                  min(CGFloat(goal) * pointsPerDollar, self.bounds.height))
      let lineBPoint2 = CGPoint(x: self.bounds.width,
                                y: self.bounds.height -
                                  min(CGFloat(goal) * pointsPerDollar, self.bounds.height))
      let lineB = Line(start: lineBPoint1, end: lineBPoint2)

      let fundedPoint = intersection(ofLine: lineA, withLine: lineB)

      let fundedDotOutline = UIBezierPath(
        ovalIn: CGRect(
          x: fundedPoint.x - (self.fundedPointRadius / 2),
          y: fundedPoint.y - (self.fundedPointRadius / 2),
          width: self.fundedPointRadius,
          height: self.fundedPointRadius
        )
      )

      let fundedDotFill = UIBezierPath(
        ovalIn: CGRect(
          x: fundedPoint.x - (self.fundedPointRadius / 2 / 2),
          y: fundedPoint.y - (self.fundedPointRadius / 2 / 2),
          width: self.fundedPointRadius / 2,
          height: self.fundedPointRadius / 2
        )
      )

      // Draw funding progress line in green from funding point on.
      let fundedProgressLine = UIBezierPath()
      fundedProgressLine.lineWidth = self.lineThickness

      var lastFundedPoint = CGPoint(x: fundedPoint.x, y: fundedPoint.y)
      fundedProgressLine.move(to: lastFundedPoint)

      datePledgedPoints.forEach { point in
        let x = point.x * pointsPerDay + self.layoutMargins.left
        if x >= fundedPoint.x {
          let y = self.bounds.height - point.y * pointsPerDollar
          fundedProgressLine.addLine(to: CGPoint(x: x, y: y))
          lastFundedPoint = CGPoint(x: x, y: y)
        }
      }

      // Stroke the darker graph line before filling with lighter color.
      UIColor.ksr_green_500.setStroke()
      fundedProgressLine.stroke()

      fundedProgressLine.addLine(to: CGPoint(x: lastFundedPoint.x, y: self.bounds.height))
      fundedProgressLine.addLine(to: CGPoint(x: fundedPoint.x, y: self.bounds.height))
      fundedProgressLine.close()

      UIColor.ksr_green_400.setFill()
      fundedProgressLine.fill(with: .color, alpha: 0.4)

      UIColor.ksr_green_500.set()
      fundedDotOutline.stroke()
      fundedDotFill.fill()

    } else {
      let goalLine = Line(start: CGPoint(x: 0.0, y: self.bounds.height - CGFloat(goal) * pointsPerDollar),
                          end: CGPoint(x: self.bounds.width,
                            y: self.bounds.height - CGFloat(goal) * pointsPerDollar))
      let goalPath = UIBezierPath()
      goalPath.lineWidth = self.lineThickness / 2
      goalPath.move(to: goalLine.start)
      goalPath.addLine(to: goalLine.end)

      UIColor.ksr_green_500.setStroke()
      goalPath.stroke()

      self.goalLabel.text = Strings.dashboard_graphs_funding_goal()
      self.goalLabel.sizeToFit()

      self.goalLabel.frame = self.goalLabel.frame.insetBy(dx: -6, dy: -3).integral

      self.goalLabel.center = CGPoint(x: self.bounds.width - 16 - self.goalLabel.frame.width / 2,
                                      y: goalLine.end.y - self.goalLabel.frame.height / 2)
    }

    self.goalLabel.isHidden = projectHasFunded
  }
  // swiftlint:enable function_body_length
}

// Calculates the point of intersection of Line 1 and Line 2.
private func intersection(ofLine line1: Line, withLine line2: Line) -> CGPoint {
  guard line1.start.x != line1.end.x else {
    return CGPoint(x: line1.start.x, y: line2.start.y)
  }

  let line1Slope = slope(ofLine: line1)
  let line1YIntercept = yIntercept(ofLine: line1)

  let line2Slope = slope(ofLine: line2)
  let line2YIntercept = yIntercept(ofLine: line2)

  let x = (line2YIntercept - line1YIntercept) / (line1Slope - line2Slope)
  let y = line1Slope * x + line1YIntercept

  return CGPoint(x: x, y: y)
}

// Calculates where a given line will intercept the y-axis, if ever.
private func yIntercept(ofLine line: Line) -> CGFloat {
  return slope(ofLine: line) * (-line.start.x) + line.start.y
}

// Calculates the slope between two given points, if any.
private func slope(ofLine line: Line) -> CGFloat {
  if line.start.x == line.end.x {
    fatalError()
  }
  return (line.end.y - line.start.y) / (line.end.x - line.start.x)
}

// Returns the day number, given the start and current date in seconds.
private func dateToDayNumber(launchDate: TimeInterval,
                                        currentDate: TimeInterval,
                                        calendar: Calendar = .current) -> CGFloat {
  let startOfCurrentDate = fabs(
    calendar.startOfDay(
      for: Date(timeIntervalSinceReferenceDate: currentDate)).timeIntervalSince1970
  )

  let startOfLaunchDate = fabs(
    calendar.startOfDay(
      for: Date(timeIntervalSinceReferenceDate: launchDate)).timeIntervalSince1970
  )

  return CGFloat((startOfCurrentDate - startOfLaunchDate) / 60.0 / 60.0 / 24.0)
}

// Returns the number of days in a given date range.
private func totalNumberOfDays(startDate: TimeInterval,
                                         endDate: TimeInterval,
                                         calendar: Calendar = .current) -> CGFloat {
  let startOfStartDate = fabs(
    calendar.startOfDay(for: Date(timeIntervalSinceReferenceDate: startDate)).timeIntervalSince1970
  )

  let startOfEndDate = fabs(
    calendar.startOfDay(for: Date(timeIntervalSinceReferenceDate: endDate)).timeIntervalSince1970
  )

  return CGFloat((startOfEndDate - startOfStartDate) / 60.0 / 60.0 / 24.0)
}
