import Experimentation
import KDS
import Library
import SwiftUI

struct StatsigDebugView: View {
  let client: StatsigClientType?

  var isStatsigEnabled: Bool {
    self.client.isSome
  }

  @ViewBuilder
  private var status: some View {
    if self.isStatsigEnabled {
      HStack {
        Image(systemName: "checkmark.circle.fill")
          .accessibilityHidden(true)
        Text("Statsig is working!")
      }
      .frame(maxWidth: .infinity)
      .background(Colors.Background.Accent.Green.subtle.swiftUIColor())

    } else {
      HStack {
        Image(systemName: "exclamationmark.triangle")
          .accessibilityHidden(true)
        Text("No Statsig client is configured.")
      }
      .frame(maxWidth: .infinity)
      .background(Colors.Background.Warning.subtle.swiftUIColor())
    }
  }

  public var body: some View {
    return VStack(alignment: .center, spacing: Spacing.unit_02) {
      self.status
      Divider()
      Text("**Warning**: Statsig's debugger is useful, but manual overrides can be buggy.")
      Button {
        self.showDebugger()
      } label: {
        Text("Open debug view")
      }
      .disabled(!self.isStatsigEnabled)
      Divider()
      Text("Reload the Statsig user, and all their experiments and flags.")
      Button {
        self.reload()
      } label: {
        HStack {
          Image(systemName: "arrow.clockwise")
            .accessibilityHidden(true)
          Text("Reload Statsig")
        }
      }
      .disabled(!self.isStatsigEnabled)
      Spacer()
    }
    .font(InterFont.bodyMD.swiftUIFont())
    .foregroundStyle(Colors.Text.secondary.swiftUIColor())
    .buttonStyle(KSRButtonStyleModifier(style: KSRButtonStyle.green))
    .padding(Spacing.unit_03)
  }

  private func showDebugger() {
    // Statsig doesn't expose a view controller, only this method to present from the root view.
    // We have to dismiss the beta controller first; then we can show the debugger.
    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true) {
      self.client?.showDebugger()
    }
  }

  private func reload() {
    let user = AppEnvironment.current.statsigUser()
    self.client?.reload(withUser: user)
  }
}

#Preview {
  StatsigDebugView(client: nil)
}
