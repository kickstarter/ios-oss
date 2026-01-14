import KDS
import UIKit

/* A custom floating-style `UITabBar`
 - Sets tabs in a centered container using a horizontal `UIStackView`.
 - Draws a background “pill” behind the tab items, including shadow.
 - Animates a selection indicator view behind the currently selected tab.
 - Hides tab item titles and presents an icons only.
 */

final class FloatingTabBar: UITabBar {
  private enum Constants {
    /// Base size for each tab item container
    static let baseItemSize: CGFloat = Spacing.unit_10
    /// Minimum tappable size for accessibility
    static let minTapSize: CGFloat = 44

    static let tabBarCornerRadius: CGFloat = Spacing.unit_04
    static let tabBarShadowOpacity: Float = 0.28
    static let tabBarShadowRadius: CGFloat = Spacing.unit_07
    static let tabBarShadowOffsetY: CGFloat = Spacing.unit_02
    static let tabBarVerticalPadding: CGFloat = Spacing.unit_02
    static let tabBarHorizontalInset: CGFloat = Spacing.unit_03

    static let selectedTabBackgroundCornerRadius: CGFloat = Spacing.unit_02
    static let selectedTabAnimationDuration: TimeInterval = 0.18
  }

  // MARK: - Accessibility Properties

  private let tabBarBackgroundView = UIView()
  private let selectedTabBackgroundView = UIView()

  /// Used to scale values based on Dynamic Type
  private let metrics = UIFontMetrics(forTextStyle: .body)
  private var itemSize: CGFloat {
    max(Constants.minTapSize, self.metrics.scaledValue(for: Constants.baseItemSize))
  }

  private var selectedIndicatorSize: CGSize {
    CGSize(width: self.itemSize, height: self.itemSize)
  }

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

    /// Hide icon labels
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

  // MARK: - Subviews

  private func setupSubviews() {
    /// Tab Bar background
    self.tabBarBackgroundView.backgroundColor = Colors.FloatingTabBar.background.uiColor()
    self.tabBarBackgroundView.layer.cornerRadius = Constants.tabBarCornerRadius
    self.tabBarBackgroundView.layer.masksToBounds = false
    self.tabBarBackgroundView.layer.shadowColor = UIColor.black.cgColor
    self.tabBarBackgroundView.layer.shadowOpacity = Constants.tabBarShadowOpacity
    self.tabBarBackgroundView.layer.shadowRadius = Constants.tabBarShadowRadius
    self.tabBarBackgroundView.layer.shadowOffset = CGSize(width: 0, height: Constants.tabBarShadowOffsetY)
    self.tabBarBackgroundView.isUserInteractionEnabled = false

    /// Selected tab
    self.selectedTabBackgroundView.backgroundColor = Colors.FloatingTabBar.iconHighlight.uiColor()
    self.selectedTabBackgroundView.layer.cornerRadius = Constants.selectedTabBackgroundCornerRadius
    self.selectedTabBackgroundView.clipsToBounds = true
    self.selectedTabBackgroundView.isUserInteractionEnabled = false

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

  /// The total width of the floating tab bar background.
  private func tabBarWidth(for itemCount: CGFloat) -> CGFloat {
    let horizontalPadding = self.metrics.scaledValue(for: Constants.tabBarHorizontalInset)
    let spacingBetweenTabs = self.metrics.scaledValue(for: Spacing.unit_02)

    let totalTabsWidth = itemCount * self.itemSize
    let totalSpacingWidth = max(itemCount - 1, 0) * spacingBetweenTabs

    let totalHorizontalPadding = horizontalPadding * 2 /// this is both sides

    return totalHorizontalPadding + totalTabsWidth + totalSpacingWidth
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

    let verticalPadding = self.metrics.scaledValue(for: Constants.tabBarVerticalPadding)
    let horizontalInset = self.metrics.scaledValue(for: Constants.tabBarHorizontalInset)

    let tabHeight = self.itemSize + (verticalPadding * 2)
    let iconsCenterY = itemViews[0].center.y
    let tabBarWidth = self.tabBarWidth(for: CGFloat(itemViews.count))

    let tabFrame = CGRect(
      x: (bounds.width - tabBarWidth) / 2.0,
      y: iconsCenterY - (tabHeight / 2.0),
      width: tabBarWidth,
      height: tabHeight
    )

    self.tabBarBackgroundView.frame = tabFrame

    /// Evenly space icons within the tab bar.
    let count = CGFloat(itemViews.count)
    let usableWidth = tabBarWidth - (horizontalInset * 2)
    let totalIconWidth = count * self.itemSize
    let spacing = (usableWidth - totalIconWidth) / max(count - 1, 1)

    var currentCenterX = tabFrame.minX + horizontalInset + (self.itemSize / 2.0)

    for view in itemViews {
      view.frame = CGRect(
        x: currentCenterX - (self.itemSize / 2.0),
        y: tabFrame.midY - (self.itemSize / 2.0),
        width: self.itemSize,
        height: self.itemSize
      )
      currentCenterX += self.itemSize + spacing
    }
  }

  /// Animates the green background behind the selected tab.
  private func updateSelection(animated: Bool) {
    guard
      let selectedItem,
      let tabs = sortedTabViews(),
      let selectedIndex = items?.firstIndex(of: selectedItem),
      selectedIndex < tabs.count
    else { return }

    let targetTabView = tabs[selectedIndex]
    let indicatorSize = self.selectedIndicatorSize

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
