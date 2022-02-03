import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

class ImageViewElementCell: UITableViewCell, ValueCell {
  // MARK: Properties

  private lazy var imageAndCaptionStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var textView: UITextView = { UITextView(frame: .zero) }()
  private lazy var storyImageView: UIImageView = { UIImageView(frame: .zero) }()
  private let viewModel = ImageViewElementCellViewModel()

  // MARK: Initializers

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.bindStyles()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureWith(value imageElement: ImageViewElement) {
    self.viewModel.inputs.configureWith(imageElement: imageElement)
  }

  // MARK: View Model

  internal override func bindViewModel() {
    self.viewModel.outputs.attributedText
      .observeForUI()
      .observeValues { [weak self] attributedText in
        self?.textView.attributedText = attributedText
      }

    self.viewModel.outputs.imageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.storyImageView.image = nil
      })
      .observeValues { [weak self] url in
        self?.storyImageView.ksr_setImageFromCache(url)
      }
  }

  // MARK: View Styles

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> \.separatorInset .~
      .init(
        top: 0,
        left: 0,
        bottom: 0,
        right: self.bounds.size.width + ProjectHeaderCellStyles.Layout.insets
      )

    _ = self.contentView
      |> \.layoutMargins .~ .init(
        topBottom: Styles.gridHalf(3),
        leftRight: Styles.grid(3)
      )

    _ = self.imageAndCaptionStackView
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(1)

    _ = self.textView
      |> textViewStyle

    _ = self.storyImageView
      |> imageViewStyle
  }

  // MARK: Helpers

  private func setupConstraints() {
    _ = [
      self.imageAndCaptionStackView,
      self.storyImageView,
      self.textView
    ]
      ||> \.translatesAutoresizingMaskIntoConstraints .~ false

    let aspectRatio = CGFloat(9.0 / 16.0)

    NSLayoutConstraint.activate([
      self.storyImageView.widthAnchor.constraint(equalTo: self.imageAndCaptionStackView.widthAnchor),
      self.storyImageView.heightAnchor.constraint(
        equalTo: self.storyImageView.widthAnchor,
        multiplier: aspectRatio
      )
    ])
  }

  private func configureViews() {
    _ = (self.imageAndCaptionStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.storyImageView, self.textView], self.imageAndCaptionStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }
}
