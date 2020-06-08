import KsApi
import Library
import Prelude
import UIKit

public typealias PledgeSummaryCellData = (project: Project, total: Double)

final class PledgeSummaryViewController: UIViewController {
  // MARK: - Properties

  private lazy var titleAndTotalStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var amountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var confirmationLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var totalConversionLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var totalStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let viewModel: PledgeSummaryViewModelType = PledgeSummaryViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.confirmationLabel
      |> \.numberOfLines .~ 0
      |> checkoutBackgroundStyle

    _ = self.titleAndTotalStackView
      |> adaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
      |> titleAndTotalStackViewStyle

    _ = self.totalStackView
      |> totalStackViewStyle(self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory)

    _ = self.titleLabel
      |> titleLabelStyle

    _ = self.amountLabel
      |> amountLabelStyle

    _ = self.totalConversionLabel
      |> totalConversionLabelStyle
  }

  private func configureSubviews() {
    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleAndTotalStackView, self.confirmationLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleLabel, self.totalStackView], self.titleAndTotalStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.amountLabel, self.totalConversionLabel], self.totalStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  // MARK: - View model

  internal override func bindViewModel() {
    super.bindViewModel()

    self.confirmationLabel.rac.hidden = self.viewModel.outputs.confirmationLabelHidden

    self.confirmationLabel.rac.attributedText = self.viewModel.outputs.confirmationLabelAttributedText

    self.viewModel.outputs.notifyDelegateOpenHelpType
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        self?.presentHelpWebViewController(with: helpType, presentationStyle: .formSheet)
      }

    self.amountLabel.rac.attributedText = self.viewModel.outputs.amountLabelAttributedText
    self.totalConversionLabel.rac.text = self.viewModel.outputs.totalConversionLabelText
  }

  // MARK: - Configuration

  internal func configure(with data: PledgeSummaryViewData) {
    self.viewModel.inputs.configure(with: data)
  }
}

extension PledgeSummaryViewController: UITextViewDelegate {
  func textView(
    _: UITextView, shouldInteractWith _: NSTextAttachment,
    in _: NSRange, interaction _: UITextItemInteraction
  ) -> Bool {
    return false
  }

  func textView(
    _: UITextView, shouldInteractWith url: URL, in _: NSRange,
    interaction _: UITextItemInteraction
  ) -> Bool {
    self.viewModel.inputs.tapped(url)
    return false
  }
}

// MARK: - Styles

private let amountLabelStyle: LabelStyle = { (label: UILabel) in
  _ = label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ NSTextAlignment.right
    |> \.adjustsFontSizeToFitWidth .~ true
    |> \.isAccessibilityElement .~ true
    |> \.minimumScaleFactor .~ 0.75

  _ = label
    |> checkoutBackgroundStyle

  return label
}

private let titleAndTotalStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ UIStackView.Alignment.top
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(3)
}

private let titleLabelStyle: LabelStyle = { (label: UILabel) -> UILabel in
  _ = label
    |> checkoutTitleLabelStyle
    |> \.text %~ { _ in Strings.Total() }

  _ = label
    |> checkoutBackgroundStyle

  return label
}

private let totalConversionLabelStyle: LabelStyle = { label in
  _ = label
    |> \.font .~ .ksr_footnote()
    |> \.textColor .~ .ksr_text_dark_grey_500

  _ = label |> checkoutBackgroundStyle

  return label
}

private func totalStackViewStyle(_ isAccessibilityCategory: Bool) -> StackViewStyle {
  return { stackView in
    stackView
      |> verticalStackViewStyle
      |> \.spacing .~ Styles.grid(1)
      |> \.alignment .~
      (isAccessibilityCategory ? UIStackView.Alignment.leading : UIStackView.Alignment.trailing)
  }
}
