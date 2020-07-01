import Foundation
import Library
import Prelude
import UIKit

final class RewardAddOnSelectionViewController: UITableViewController {
  // MARK: - Properties

  public lazy var headerLabel: UILabel = UILabel(frame: .zero)
  public lazy var headerView: UIView = UIView(frame: .zero)
  public lazy var headerRootStackView: UIStackView = UIStackView(frame: .zero)

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureHeaderView()

    self.navigationItem.title = localizedString(
      key: "Edit_reward",
      defaultValue: "Edit reward"
    )

    self.tableView.tableHeaderView = self.headerView
    self.tableView.tableFooterView = UIView(frame: .zero)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.tableView.ksr_sizeHeaderFooterViewsToFit()
  }

  // MARK: - Configuration

  private func configureHeaderView() {
    _ = (self.headerRootStackView, self.headerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent(priority: UILayoutPriority(rawValue: 999))

    _ = ([self.headerLabel], self.headerRootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.headerLabel
      |> checkoutBackgroundStyle

    _ = self.headerLabel
      |> \.numberOfLines .~ 0
      |> \.font .~ UIFont.ksr_title1().bolded
      |> \.text .~ localizedString(
        key: "Customize_your_reward_with_optional_addons",
        defaultValue: "Customize your reward with optional add-ons."
      )

    _ = self.headerRootStackView
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(4))
      |> \.axis .~ .vertical
  }
}
