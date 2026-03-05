@testable import ServerDrivenUI
import ServerDrivenUITestHelpers
import SwiftUI
import Testing
import UIKit

// Captures blockSpacing from the current RichTextStyle
private struct StyleBlockSpacingCaptureView: View {
  @Environment(\.richTextStyle) var style
  @Binding var captured: CGFloat?

  var body: some View {
    Color.clear
      .onAppear { self.captured = self.style.blockSpacing }
  }
}

// Captures backgroundColor from the current RichTextStyle
private struct StyleBackgroundColorCaptureView: View {
  @Environment(\.richTextStyle) var style
  @Binding var captured: Color?

  var body: some View {
    Color.clear
      .onAppear {
        self.captured = self.style.backgroundColor.swiftUIColor()
      }
  }
}

// Observable controller used to drive style changes from tests
private final class StyleToggleController: ObservableObject {
  @Published var useLight: Bool = true
}

// Provides either Light or Dark style based on an observed controller
private struct StyleProviderCaptureView: View {
  @ObservedObject var controller: StyleToggleController
  @Binding var capturedColor: Color?

  var body: some View {
    StyleBackgroundColorCaptureView(captured: self.$capturedColor)
      .id(self.controller.useLight) // force recreation so onAppear runs again
      .environment(
        \.richTextStyle,
        self.controller.useLight ? LightRichTextStyle() as any RichTextStyle :
          DarkRichTextStyle() as any RichTextStyle
      )
  }
}

/// A tiny box that stores a value and exposes it as an optional Binding for capture in SwiftUI.
private final class Holder<T>: @unchecked Sendable {
  var value: T?

  init(value: T? = nil) {
    self.value = value
  }

  var binding: Binding<T?> {
    Binding(
      get: { self.value },
      set: { self.value = $0 }
    )
  }
}

// MARK: - Environment

@Test func environment_defaultStyle_isValid() async throws {
  let environmentValues = EnvironmentValues()
  let style = environmentValues.richTextStyle
  #expect(style.linkUnderlined == true)
  #expect(style.blockSpacing > 0)
  #expect(style.mediaCornerRadius >= 0)
}

@Test func richTextStyleModifier_injectsStyle() async throws {
  var environmentValues = EnvironmentValues()
  let injected = LightRichTextStyle()
  environmentValues.richTextStyle = injected
  let style = environmentValues.richTextStyle
  #expect(style.linkUnderlined == injected.linkUnderlined)
  #expect(style.blockSpacing == injected.blockSpacing)
  #expect(style.mediaCornerRadius == injected.mediaCornerRadius)
}

@Test @MainActor func view_receivesInjectedRichTextStyle_fromEnvironment() async throws {
  // Given a view that captures blockSpacing from the environment
  let holder = Holder<CGFloat>()
  let view = StyleBlockSpacingCaptureView(captured: holder.binding)
    .environment(\.richTextStyle, LightRichTextStyle())
  // When the view is hosted and laid out
  let hosting = UIHostingController(rootView: view)
  let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
  window.rootViewController = hosting
  window.makeKeyAndVisible()
  hosting.view.layoutIfNeeded()
  try await Task.sleep(nanoseconds: 200_000_000)
  // Then it reads the injected style from the environment
  #expect(holder.value != nil)
  #expect(holder.value == LightRichTextStyle().blockSpacing)
}

@Test @MainActor func swiftUIView_automaticRichTextStyle_rerendersWhenThemeChanges() async throws {
  // Given a provider that switches between Light and Dark styles
  let colorHolder = Holder<Color>()
  let controller = StyleToggleController()
  controller.useLight = true

  // And a hosted view that exposes the current backgroundColor
  let hosting = UIHostingController(rootView: StyleProviderCaptureView(
    controller: controller,
    capturedColor: colorHolder.binding
  ))
  let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
  window.rootViewController = hosting
  window.makeKeyAndVisible()

  // When the initial (light) view renders
  hosting.view.layoutIfNeeded()
  try await Task.sleep(nanoseconds: 150_000_000)
  let lightColor = colorHolder.value

  // Then the captured color should be non-nil
  #expect(lightColor != nil)

  // When we toggle to dark by updating the controller inside SwiftUI
  controller.useLight = false

  // And the view re-renders
  hosting.view.layoutIfNeeded()
  try await Task.sleep(nanoseconds: 300_000_000)
  let darkColor = colorHolder.value

  // Then the color should change to reflect the dark theme
  #expect(darkColor != nil)
  #expect(lightColor != darkColor)
}
