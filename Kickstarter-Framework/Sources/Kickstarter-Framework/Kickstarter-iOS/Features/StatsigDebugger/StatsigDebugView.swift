import KDS
import Library
import SwiftUI

struct StatsigDebugView: View {
  public var body: some View {
    return VStack(alignment: .leading) {
      Button {
        self.showDebugger()
      } label: {
        Text("Open debug view")
      }
      Button {
        self.reload()
      } label: {
        HStack {
          Image(systemName: "arrow.clockwise")
            .accessibilityHidden(true)
          Text("Reload Statsig")
        }
      }
      Spacer()
    }
    .buttonStyle(KSRButtonStyleModifier(style: KSRButtonStyle.green))
    .padding(Spacing.unit_03)
  }

  private func showDebugger() {
    // Statsig doesn't expose a view controller, only this method to present from the root view.
    // We have to dismiss the beta controller first; then we can show the debugger.
    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true) {
      AppEnvironment.current.statsigClient?.showDebugger()
    }
  }

  private func reload() {
    if let userId = AppEnvironment.current.currentUser?.id {
      AppEnvironment.current.statsigClient?.reload(withUserID: String(userId))
    } else {
      AppEnvironment.current.statsigClient?.reload(withUserID: nil)
    }
  }
}

#Preview {
  StatsigDebugView()
}
