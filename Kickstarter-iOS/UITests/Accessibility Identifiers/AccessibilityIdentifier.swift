import Foundation

public enum AccessibilityIdentifier {

  public enum RootTabBar: String {
    case activity = "tabBar_activity"
    case dashboard = "tabBar_dashboard"
    case explore = "tabBar_explore"
    case profile = "tabBar_profile"
    case search = "tabBar_search"
    case tabBar = "root_tabBar"
  }

  public enum Search: String {
    case cancelButton = "search_cancel_button"
    case tableView = "search_tableView"
    case textField = "search_textField"
  }
}
