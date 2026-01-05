import KDS

// This extension contains custom semantic colors for Newer Mobile Visioning Efforts that are not part of the official Figma design set.
// These colors are currently used for specific UI elements, like the new Floating Tab Bar
// which are not yet defined in the core Design System. This structure helps organize and
// isolate non-standard colors from the rest of the shared semantic palette.

public extension Colors {
  struct FloatingTabBar {
    public static let background = Colors.Elevation.Surface.raised

    public static let iconColorSelected = Colors.Icon.dark
    public static let iconColorUnselected = Colors.Icon.default
    public static let iconHighlight = Colors.Icon.highlight

    public static let profileIconBorderColor = Colors.Icon.light
  }
}
