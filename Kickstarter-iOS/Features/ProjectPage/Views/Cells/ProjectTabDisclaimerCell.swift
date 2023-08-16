import KsApi
import Library
import Prelude
import UIKit

protocol ProjectTabDisclaimerCellDelegate: AnyObject {
  func projectTabDisclaimerCell(_ cell: ProjectTabDisclaimerCell,
                                didTapURL: URL)
}

final class ProjectTabDisclaimerCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  weak var delegate: ProjectTabDisclaimerCellDelegate?
  private let viewModel = ProjectTabDisclaimerCellViewModel()

  private lazy var descriptionTextView: UITextView = {
    UITextView(frame: .zero)
      |> \.delegate .~ self
  }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.bindStyles()
    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Bindings

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegateLinkTappedWithURL
      .observeForUI()
      .observeValues { [weak self] url in
        guard let self = self else { return }
        self.delegate?.projectTabDisclaimerCell(self, didTapURL: url)
      }

    self.viewModel.outputs.updateURLFromProjectType
      .observeForUI()
      .observeValues { [weak self] disclaimerType in
        guard let self = self else { return }

        _ = self.descriptionTextView
          |> \.attributedText .~ self.attributedText(from: disclaimerType)
      }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> \.separatorInset .~
      .init(leftRight: Styles.projectPageLeftRightInset)

    _ = self.contentView
      |> \.layoutMargins .~
      .init(
        topBottom: Styles.projectPageTopBottomInset,
        leftRight: Styles.projectPageLeftRightInset
      )

    _ = self.descriptionTextView
      |> tappableLinksViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: - Configuration

  func configureWith(value: ProjectDisclaimerType) {
    self.viewModel.inputs.configure(with: value)
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.descriptionTextView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func attributedText(from type: ProjectDisclaimerType) -> NSAttributedString {
    let regularFontAttribute: String.Attributes = [
      .font: UIFont.ksr_subhead(),
      .foregroundColor: UIColor.ksr_support_700
    ]
    let coloredFontAttribute: String.Attributes = [
      .font: UIFont.ksr_subhead(),
      .foregroundColor: UIColor.ksr_create_700,
      .underlineStyle: NSUnderlineStyle.single.rawValue
    ]

    /**
       FIXME: (Minor)
      Ideally we would submit this string to the kickstarter repo:
      `<a href=\"%{environmental_resources_link}\">Visit our Environmental Resources Center</a>to learn how Kickstarter encourages sustainable practices.`
      Instead of: `to learn how Kickstarter encourages sustainable practices.`
      And that way could just do: `Strings.To_learn_how_Kickstarter_encourages_sustainable_practices(environmental_resources_link: environmentLink)` after line 120.
     **/

    let additionalText = type == .environmental ?
      NSAttributedString(
        string: Strings.To_learn_how_Kickstarter_encourages_sustainable_practices(),
        attributes: regularFontAttribute
      ) :
      NSAttributedString(string: "")

    var linkString: String
    let baseUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl
    switch type {
    case .aiDisclosure:
      guard let link = HelpType.aiDisclosure
        .url(withBaseUrl: baseUrl)?.absoluteString else {
        return additionalText
      }
      // FIXME: Use translatable string.
      linkString = "<a href=\"\(link)\">Learn about AI policy on Kickstarter</a>"
    case .environmental:
      guard let environmentLink = HelpType.environment
        .url(withBaseUrl: baseUrl)?.absoluteString else {
        return additionalText
      }
      linkString = Strings
        .Visit_our_Environmental_Resources_Center_Alternative(environment_link: environmentLink)
    }

    guard let linkAttributedString = try? NSMutableAttributedString(
      data: Data(linkString.utf8),
      options: [
        .documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue
      ],
      documentAttributes: nil
    ) else { return additionalText }

    let fullRange = (linkAttributedString.string as NSString)
      .range(of: linkAttributedString.string)
    linkAttributedString.addAttributes(coloredFontAttribute, range: fullRange)

    if additionalText.length == 0 {
      return linkAttributedString
    }

    let combinedString = linkAttributedString + NSAttributedString(string: " ") +
      additionalText

    return combinedString
  }
}

// MARK: - UITextViewDelegate

extension ProjectTabDisclaimerCell: UITextViewDelegate {
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
    self.viewModel.inputs.linkTapped(url: url)
    return false
  }
}

// MARK: - Styles

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ Styles.grid(3)
}
