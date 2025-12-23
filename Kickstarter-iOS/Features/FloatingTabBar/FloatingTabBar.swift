import KDS
import UIKit

/* A custom floating-style `UITabBar` that visually groups tab items inside a
 - Sets tabs in a centered container using a horizontal `UIStackView`.
 - Draws a background “pill” behind the tab items, including shadow.
 - Animates a selection indicator view behind the currently selected tab
 - Hides tab item titles and presents an icon-only navigation experience.
 */

final class FloatingTabBar: UITabBar {
  private enum Constants {
    static let tabBarItemSize: CGFloat = Spacing.unit_10
    static let tabBarWidth: CGFloat = 152
    static let tabBarCornerRadius: CGFloat = Spacing.unit_04
    static let tabBarShadowOpacity: Float = 0.28
    static let tabBarShadowRadius: CGFloat = Spacing.unit_07
    static let tabBarShadowOffsetY: CGFloat = Spacing.unit_02
    static let tabBarVerticalPadding: CGFloat = Spacing.unit_02
    static let tabBarHorizontalInset: CGFloat = Spacing.unit_03

    static let selectedTabBackgroundCornerRadius: CGFloat = Spacing.unit_02
    static let selectedTabBackgroundSize: CGSize = CGSize(
      width: Constants.tabBarItemSize,
      height: Constants.tabBarItemSize
    )
    static let selectedTabAnimationDuration: TimeInterval = 0.18
  }

  private let tabBarBackgroundView = UIView()
  private let selectedTabBackgroundView = UIView()

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundImage = UIImage()
    self.shadowImage = UIImage()
    self.isTranslucent = true
    self.backgroundColor = .clear

    self.tintColor = Colors.FloatingTabBar.iconColorSelected.uiColor()
    self.unselectedItemTintColor = Colors.FloatingTabBar.iconColorUnselected.uiColor()

    let appearance = UITabBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.stackedLayoutAppearance.selected.iconColor = Colors.FloatingTabBar.iconColorSelected.uiColor()
    appearance.stackedLayoutAppearance.normal.iconColor = Colors.FloatingTabBar.iconColorUnselected.uiColor()

    // Hide icon labels.
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
      .foregroundColor: UIColor.clear
    ]
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
      .foregroundColor: UIColor.clear
    ]

    self.standardAppearance = appearance
    self.scrollEdgeAppearance = appearance

    self.setupSubviews()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  private func setupSubviews() {
    // Tab Bar pill background
    self.tabBarBackgroundView.backgroundColor = Colors.FloatingTabBar.background.uiColor()
    self.tabBarBackgroundView.layer.cornerRadius = Constants.tabBarCornerRadius
    self.tabBarBackgroundView.layer.masksToBounds = false
    self.tabBarBackgroundView.layer.shadowColor = UIColor.black.cgColor
    self.tabBarBackgroundView.layer.shadowOpacity = Constants.tabBarShadowOpacity
    self.tabBarBackgroundView.layer.shadowRadius = Constants.tabBarShadowRadius
    self.tabBarBackgroundView.layer.shadowOffset = CGSize(width: 0, height: Constants.tabBarShadowOffsetY)

    // Selected tab pill
    self.selectedTabBackgroundView.backgroundColor = Colors.FloatingTabBar.iconHighlight.uiColor()
    self.selectedTabBackgroundView.layer.cornerRadius = Constants.selectedTabBackgroundCornerRadius
    self.selectedTabBackgroundView.clipsToBounds = true

    self.addSubview(self.tabBarBackgroundView)
    self.addSubview(self.selectedTabBackgroundView)
    self.sendSubviewToBack(self.tabBarBackgroundView)
  }

  /// Move the green background when the selected item changes.
  override var selectedItem: UITabBarItem? {
    didSet {
      self.updateSelection(animated: true)
    }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.layoutTabs()

    self.updateSelection(animated: false)
  }

  /// Centers and lays out the tabs.
  private func layoutTabs() {
    guard let itemViews = sortedTabViews(), itemViews.isEmpty == false else {
      self.tabBarBackgroundView.isHidden = true
      self.selectedTabBackgroundView.isHidden = true

      return
    }

    self.tabBarBackgroundView.isHidden = false
    self.selectedTabBackgroundView.isHidden = false

    let tabHeight = Constants.tabBarItemSize + (Constants.tabBarVerticalPadding * 2)
    let iconsCenterY = itemViews[0].center.y

    let tabFrame = CGRect(
      x: (bounds.width - Constants.tabBarWidth) / 2.0,
      y: iconsCenterY - (tabHeight / 2.0),
      width: Constants.tabBarWidth,
      height: tabHeight
    )

    self.tabBarBackgroundView.frame = tabFrame

    /// Evenly space icons within the tab bar.
    let count = CGFloat(itemViews.count)
    let usableWidth = Constants.tabBarWidth - (Constants.tabBarHorizontalInset * 2)
    let totalIconWidth = count * Constants.tabBarItemSize
    let spacing = (usableWidth - totalIconWidth) / max(count - 1, 1)

    var currentCenterX =
      tabFrame.minX + Constants.tabBarHorizontalInset + (Constants.tabBarItemSize / 2.0)

    for view in itemViews {
      view.frame = CGRect(
        x: currentCenterX - (Constants.tabBarItemSize / 2.0),
        y: tabFrame.midY - (Constants.tabBarItemSize / 2.0),
        width: Constants.tabBarItemSize,
        height: Constants.tabBarItemSize
      )

      currentCenterX += Constants.tabBarItemSize + spacing
    }
  }

  /// Animates the green  background behind the selected tab.
  private func updateSelection(animated: Bool) {
    guard
      let selectedItem,
      let tabs = sortedTabViews(),
      let selectedIndex = items?.firstIndex(of: selectedItem),
      selectedIndex < tabs.count
    else { return }

    let targetTabView = tabs[selectedIndex]
    let indicatorSize = Constants.selectedTabBackgroundSize

    let frame = CGRect(
      x: targetTabView.center.x - (indicatorSize.width / 2.0),
      y: self.tabBarBackgroundView.frame.midY - (indicatorSize.height / 2.0),
      width: indicatorSize.width,
      height: indicatorSize.height
    )

    if animated {
      UIView.animate(
        withDuration: Constants.selectedTabAnimationDuration,
        delay: 0,
        options: [.curveEaseInOut],
        animations: {
          self.selectedTabBackgroundView.frame = frame
        },
        completion: nil
      )
    } else {
      self.selectedTabBackgroundView.frame = frame
    }
  }

  /// Sorts views left to right.
  private func sortedTabViews() -> [UIView]? {
    let controls = subviews.compactMap { $0 as? UIControl }

    return controls.isEmpty ? nil : controls.sorted { $0.frame.minX < $1.frame.minX }
  }
}
