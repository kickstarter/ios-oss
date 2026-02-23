import UIKit

/// Bottom sheet shown when the user taps the Share button.
/// - A “Share project” title
/// - A project preview card (image + title + creator)
/// - A grid of share options
final class VideoFeedShareProjectSheetViewController: VideoFeedBottomSheetViewController {
  private let previewCard = VideoFeedProjectSharePreviewCardView()

  private let shareGrid = VideoFeedShareTargetsGridView()

  private let titleText: String
  private let creatorText: String
  private let imageURL: URL?

  init(titleText: String, creatorText: String, imageURL: URL?) {
    self.titleText = titleText
    self.creatorText = creatorText
    self.imageURL = imageURL

    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()

    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = "Share project"
    titleLabel.font = .preferredFont(forTextStyle: .headline)

    let container = UIStackView(arrangedSubviews: [titleLabel, previewCard, shareGrid])
    container.axis = .vertical
    container.spacing = 16
    container.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(container)

    self.previewCard.heightAnchor.constraint(equalToConstant: 110).isActive = true

    NSLayoutConstraint.activate([
      container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      container.bottomAnchor.constraint(
        lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
        constant: -16
      )
    ])

    self.previewCard.configure(title: self.titleText, creator: self.creatorText, imageURL: self.imageURL)
  }
}

// MARK: - Share sheet subviews

/// Simple card used in the share sheet header.
private final class VideoFeedProjectSharePreviewCardView: UIView {
  private let imageView = UIImageView()
  private let titleLabel = UILabel()
  private let creatorLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setUpView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

  func configure(title: String, creator: String, imageURL _: URL?) {
    self.titleLabel.text = title
    self.creatorLabel.text = creator

    self.imageView.image = UIImage(systemName: "photo")
    self.imageView.tintColor = .secondaryLabel
  }

  private func setUpView() {
    backgroundColor = .secondarySystemBackground
    layer.cornerRadius = 12
    clipsToBounds = true

    self.imageView.translatesAutoresizingMaskIntoConstraints = false
    self.imageView.contentMode = .scaleAspectFill
    self.imageView.clipsToBounds = true
    self.imageView.backgroundColor = .tertiarySystemBackground

    self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
    self.titleLabel.font = .preferredFont(forTextStyle: .headline)
    self.titleLabel.numberOfLines = 2

    self.creatorLabel.translatesAutoresizingMaskIntoConstraints = false
    self.creatorLabel.font = .preferredFont(forTextStyle: .subheadline)
    self.creatorLabel.textColor = .secondaryLabel

    let textStack = UIStackView(arrangedSubviews: [titleLabel, creatorLabel])
    textStack.axis = .vertical
    textStack.spacing = 4
    textStack.translatesAutoresizingMaskIntoConstraints = false

    addSubview(self.imageView)
    addSubview(textStack)

    NSLayoutConstraint.activate([
      self.imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      self.imageView.topAnchor.constraint(equalTo: topAnchor),
      self.imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
      self.imageView.widthAnchor.constraint(equalToConstant: 110),

      textStack.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 12),
      textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      textStack.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
}

private final class VideoFeedShareTargetsGridView: UIView {
  private let stack = UIStackView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setUpView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setUpView() {
    self.stack.axis = .vertical
    self.stack.spacing = 12
    self.stack.translatesAutoresizingMaskIntoConstraints = false

    addSubview(self.stack)

    NSLayoutConstraint.activate([
      self.stack.leadingAnchor.constraint(equalTo: leadingAnchor),
      self.stack.trailingAnchor.constraint(equalTo: trailingAnchor),
      self.stack.topAnchor.constraint(equalTo: topAnchor),
      self.stack.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    /// Two simple rows of buttons.
    self.stack.addArrangedSubview(self.makeRow(items: ["Copy link", "Feed", "X", "Stories"]))
    self.stack.addArrangedSubview(self.makeRow(items: ["Email", "More", "Messages", "WhatsApp"]))
  }

  private func makeRow(items: [String]) -> UIStackView {
    let row = UIStackView()
    row.axis = .horizontal
    row.distribution = .fillEqually
    row.spacing = 12

    for title in items {
      let button = UIButton(type: .system)
      button.setTitle(title, for: .normal)
      button.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
      button.backgroundColor = .secondarySystemBackground
      button.layer.cornerRadius = 10

      button.addAction(UIAction { _ in }, for: .touchUpInside)
      row.addArrangedSubview(button)
    }

    return row
  }
}
