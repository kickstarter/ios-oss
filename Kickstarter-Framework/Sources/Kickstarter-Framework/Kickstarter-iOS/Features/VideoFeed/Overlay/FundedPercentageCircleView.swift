import KDS
import Library
import SwiftUI

/// Animated circular progress indicator that displays a project's funded percentage.
/// The circle animates from 0% up to the target `fundedPercent` when the view appears.
struct FundedPercentageCircleView: View {
  private enum Constants {
    static let baseSize: CGFloat = 40
    static let lineWidth: CGFloat = 6
    static let animationDuration: Double = 1.25
    static let innerCircleOpacity: Double = 0.3
    static let checkmarkIcon = "video-feed-checkmark-icon"
    static let checkmarkIconSize: CGFloat = 12
    static let accessibilityLabel: String = Strings.Funded_percentage()
  }

  let fundedPercent: Int
  var animationDisabled: Bool = false

  @State private var animatedProgress: Double
  @ScaledMetric private var size: CGFloat = Constants.baseSize

  /// SwiftUI's `@State` initializes before `onAppear` fires, so we need a custom init so that
  /// the snapshot tests can capture a filled in circle.
  init(fundedPercent: Int, animationDisabled: Bool = false) {
    self.fundedPercent = fundedPercent
    self.animationDisabled = animationDisabled

    self._animatedProgress = State(initialValue: Double(fundedPercent) / 100.0)
  }

  // MARK: - Body

  var body: some View {
    ZStack {
      self.InnerCircle
      self.FilledCircle
      self.PercentFundedAmount
    }
    .frame(width: self.size, height: self.size)
    .onAppear {
      guard UIView.areAnimationsEnabled else { return }

      self.animatedProgress = 0

      withAnimation(.easeOut(duration: Constants.animationDuration)) {
        self.animatedProgress = Double(self.fundedPercent) / 100.0
      }
    }
    .onChange(of: self.fundedPercent) { _, newValue in
      self.animatedProgress = 0

      if self.animationDisabled {
        self.animatedProgress = Double(newValue) / 100.0
      } else {
        withAnimation(.easeOut(duration: Constants.animationDuration)) {
          self.animatedProgress = Double(newValue) / 100.0
        }
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Constants.accessibilityLabel)
  }

  private var InnerCircle: some View {
    Circle()
      .stroke(
        Color(Colors.Icon.light.uiColor()).opacity(Constants.innerCircleOpacity),
        lineWidth: Constants.lineWidth
      )
  }

  private var FilledCircle: some View {
    Circle()
      .trim(from: 0, to: self.animatedProgress)
      .stroke(
        Color(Colors.Icon.light.uiColor()),
        style: StrokeStyle(lineWidth: Constants.lineWidth, lineCap: .round)
      )
      /// SwiftUI defaults the rotation to about 3 o'clock. Rotating it more here so it starts at 12 o'clock.
      .rotationEffect(.degrees(-90))
  }

  @ViewBuilder
  private var PercentFundedAmount: some View {
    if self.fundedPercent >= 100 {
      if let icon = Library.image(named: Constants.checkmarkIcon) {
        Image(uiImage: icon.withRenderingMode(.alwaysTemplate))
          .font(.system(size: Constants.checkmarkIconSize, weight: .semibold))
          .foregroundColor(Color(Colors.Icon.light.uiColor()))
      }
    } else {
      Text("\(self.fundedPercent)")
        .font(Font(UIFont.ksr_caption1()))
        .bold()
        .foregroundColor(Color(Colors.Text.light.uiColor()))
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .allowsTightening(true)
        .padding(Constants.lineWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}
