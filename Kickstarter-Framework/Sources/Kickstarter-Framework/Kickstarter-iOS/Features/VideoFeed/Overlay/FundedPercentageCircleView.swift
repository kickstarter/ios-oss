import KDS
import Library
import SwiftUI

/// Animated circular progress indicator that displays a project's funded percentage.
/// The circle animates from 0% up to the target `fundedPercent` when the view appears.
struct FundedPercentageCircleView: View {
  private enum Constants {
    static let size: CGFloat = 40
    static let lineWidth: CGFloat = 6
    static let animationDuration: Double = 1.25
    static let innerCircleOpacity: Double = 0.3
    static let checkmarkIcon = "video-feed-checkmark-icon"
    static let checkmarkIconSize: CGFloat = 12
    // TODO: Update with Video Feed Translations [mbl-3158](https://kickstarter.atlassian.net/browse/MBL-3158)
    static let accessibilityLabel: String = "FPO: Funded percentage"
  }

  let fundedPercent: Double

  @State private var animatedProgress: Double = 0

  // MARK: - Body

  var body: some View {
    ZStack {
      self.InnerCircle
      self.FilledCircle
      self.PercentFundedAmount
    }
    .frame(width: Constants.size, height: Constants.size)
    .onAppear {
      withAnimation(.easeOut(duration: Constants.animationDuration)) {
        self.animatedProgress = self.fundedPercent
      }
    }
    .onChange(of: self.fundedPercent) { _, newValue in
      self.animatedProgress = 0

      withAnimation(.easeOut(duration: Constants.animationDuration)) {
        self.animatedProgress = newValue
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
    let fundedAmount = Int((self.fundedPercent * 100).rounded())

    if fundedAmount >= 100 {
      if let icon = Library.image(named: Constants.checkmarkIcon, inBundle: Bundle.main) {
        Image(uiImage: icon.withRenderingMode(.alwaysTemplate))
          .font(.system(size: Constants.checkmarkIconSize, weight: .semibold))
          .foregroundColor(Color(Colors.Icon.light.uiColor()))
      }
    } else {
      Text("\(fundedAmount)")
        .font(Font(UIFont.ksr_caption2()).bold())
        .foregroundColor(Color(Colors.Text.light.uiColor()))
        .monospacedDigit()
        .minimumScaleFactor(0.5)
        .lineLimit(1)
    }
  }
}
