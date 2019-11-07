import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

final class PledgeStatusLabelViewController: UIViewController {
  // MARK: - Properties

  private lazy var containerView: UIView = { UIView(frame: .zero) }()
  private lazy var label: UILabel = { UILabel(frame: .zero) }()

  private let viewModel: PledgeStatusLabelViewModelType = PledgeStatusLabelViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.containerView
      |> containerViewStyle

    _ = self.label
      |> labelStyle
  }

  private func configureSubviews() {
    _ = (self.containerView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.label, self.containerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.label.rac.attributedText = self.viewModel.outputs.labelText
  }

  // MARK: - Configuration

  internal func configure(with project: Project) {
    self.viewModel.inputs.configure(with: project)
  }
}

// MARK: - Styles

private let containerViewStyle: ViewStyle = { (view: UIView) in
  view
    |> \.backgroundColor .~ .ksr_grey_400
    |> \.layoutMargins .~ .init(all: Styles.grid(2))
    |> roundedStyle()
}

private let labelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.isAccessibilityElement .~ true
    |> \.numberOfLines .~ 0
    |> \.backgroundColor .~ .ksr_grey_400
}
