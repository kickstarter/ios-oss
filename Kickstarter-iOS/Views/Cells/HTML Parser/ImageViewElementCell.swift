import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

class ImageViewElementCell: UITableViewCell, ValueCell {
  // MARK: Properties

  private lazy var imageAndCaptionStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var textView: UITextView = { UITextView(frame: .zero) }()
  private lazy var storyImageView: GIFAnimatedImageView = { GIFAnimatedImageView(frame: .zero) }()
  private var textViewHeightConstraint: NSLayoutConstraint?
  private let viewModel = ImageViewElementCellViewModel()
  private var pinchGesture: UIPinchGestureRecognizer!
  weak var delegate: PinchToZoomDelegate?

  // MARK: Initializers

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.setupConstraints()
    self.bindStyles()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureWith(value imageData: (element: ImageViewElement, image: UIImage?)) {
    self.viewModel.inputs.configureWith(imageElement: imageData.element, image: imageData.image)
  }

  // MARK: View Model

  internal override func bindViewModel() {
    self.viewModel.outputs.attributedText
      .observeForUI()
      .observeValues { [weak self] attributedText in
        if attributedText.length > 0 {
          self?.textViewHeightConstraint?.isActive = false
        }

        self?.textView.attributedText = attributedText
      }

    self.viewModel.outputs.image
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.storyImageView.image = nil
      })
      .observeValues { [weak self] image in
        var newScale: CGFloat = 1.0
        let maxWidth = UIScreen.main.bounds.width - Styles.grid(3)
        let currentWidth = image.size.width
        let currentHeight = image.size.height

        if currentWidth <= maxWidth {
          self?.storyImageView.setImageWith(image, scaledImageSize: image.size)
        } else {
          newScale = currentWidth / maxWidth
          let newSize = CGSize(
            width: maxWidth,
            height: currentHeight * newScale
          )
          let scaledImage = image.scalePreservingAspectRatio(targetSize: newSize)

          switch image.sd_imageFormat {
          case .GIF:
            self?.storyImageView.setImageWith(image, scaledImageSize: scaledImage.size)
          default:
            self?.storyImageView.setImageWith(scaledImage, scaledImageSize: scaledImage.size)
          }
        }

        self?.storyImageView.invalidateIntrinsicContentSize()
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
      |> \.isUserInteractionEnabled .~ true
  }

  // MARK: Helpers

  private func configureViews() {
    _ = (self.imageAndCaptionStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.storyImageView, self.textView], self.imageAndCaptionStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
    self.pinchGesture.delegate = self

    self.storyImageView.addGestureRecognizer(self.pinchGesture)
  }

  private func setupConstraints() {
    self.textViewHeightConstraint = self.textView.heightAnchor.constraint(equalToConstant: 0)
    self.textViewHeightConstraint?.isActive = true
  }

  @objc func pinch(sender: UIPinchGestureRecognizer) {
    switch sender.state {
    case .began:
      guard let image = self.storyImageView.image else { return }

      let originWithoutParentView = self.storyImageView.convert(
        self.storyImageView.frame.origin,
        to: nil
      )

      let frameWithinWindow = CGRect(
        x: originWithoutParentView.x,
        y: originWithoutParentView.y,
        width: self.storyImageView.frame.width,
        height: self.storyImageView.frame.height
      )

      self.delegate?.pinchZoomDidBegin(
        self.pinchGesture,
        frame: frameWithinWindow,
        image: image
      )
    case .changed:
      self.delegate?.pinchZoomDidChange(self.pinchGesture) {
        if !self.storyImageView.isHidden {
          self.storyImageView.isHidden.toggle()
        }
      }
    case .ended, .failed, .cancelled:
      self.delegate?.pinchZoomDidEnd(self.pinchGesture) {
        self.storyImageView.isHidden = false
      }
    default:
      return
    }
  }
}
