import AVFoundation
import UIKit

final class VideoFeedCell: UICollectionViewCell {
  /// Reuse identifier for collection view cells
  static let reuseIdentifier = "VideoFeedCell"

  // MARK: - Video

  /// The layer that actually renders video frames on screen
  private let playerLayer = AVPlayerLayer()

  /// The player assigned to this cell (owned by the controller)
  private var player: AVPlayer?

  /// True only for the currently snapped / active cell
  private var isActive: Bool = false

  /// Observes when the underlying player item becomes ready to play
  private var statusObservation: NSKeyValueObservation?

  /// Observes buffering readiness (helps decide when to show loading UI)
  private var keepUpObservation: NSKeyValueObservation?

  /// Observes whether the player is playing / paused / waiting (buffering)
  private var timeControlObservation: NSKeyValueObservation?

  /// Observes whether the player layer has a frame ready to show (prevents black screens)
  private var readyForDisplayObservation: NSKeyValueObservation?

  // MARK: - Loading UI (prevents "black" perception)

  /// Full-screen overlay used to hide black frames while video is not ready
  private let loadingOverlay = UIView()

  /// Spinner shown while we’re waiting on the first renderable frame or buffering
  private let loadingIndicator = UIActivityIndicatorView(style: .large)

  // MARK: - Overlay UI

  /// Container for all UI that sits above the video
  private let overlayContainer = UIView()

  /// Close button (top-left)
  private let closeButton = UIButton(type: .system)

  /// Right-side vertical stack (like/save/share/more)
  private let rightRailStack = UIStackView()

  /// Like button + count
  private let likeButton = UIButton(type: .system)
  private let likeCountLabel = UILabel()

  /// Save button + count
  private let saveButton = UIButton(type: .system)
  private let saveCountLabel = UILabel()

  /// Share button + count
  private let shareButton = UIButton(type: .system)
  private let shareCountLabel = UILabel()

  /// More button (no count)
  private let moreButton = UIButton(type: .system)

  /// Bottom-left content area (pill/title/stats/cta)
  private let bottomContainer = UIView()
  private let pillLabel = UILabel()
  private let titleLabel = UILabel()
  private let statsLabel = UILabel()
  private let ctaButton = UIButton(type: .system)

  // MARK: - Callbacks

  /// Called when the close button is tapped
  var onCloseTapped: (() -> Void)?

  /// Called when the CTA button is tapped
  var onCTAButtonTapped: (() -> Void)?

  /// Called when share is tapped
  var onShareTapped: (() -> Void)?

  /// Called when more is tapped
  var onMoreTapped: (() -> Void)?

  /// Called when save is tapped
  var onSaveTapped: (() -> Void)?

  /// Called when like is tapped
  var onLikeTapped: (() -> Void)?

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setUpView()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.setUpView()
  }

  deinit {
    /// Ensure KVO is released if the cell is deallocated
    statusObservation = nil
    keepUpObservation = nil
    timeControlObservation = nil
    readyForDisplayObservation = nil
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    /// Reset everything so reused cells don’t show stale video/UI
    self.setPlayer(nil)
    self.setActive(false)
    self.setLoading(true)

    self.titleLabel.text = nil
    self.statsLabel.text = nil
    self.pillLabel.text = nil
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    /// Keep the video layer exactly aligned with the cell’s bounds
    self.playerLayer.frame = contentView.bounds
  }

  // MARK: - Public

  func configure(with item: VideoFeedItem) {
    /// Apply the text UI (video playback is handled separately)
    self.titleLabel.text = item.title
    self.statsLabel.text = item.statsText
    self.pillLabel.text = item.categoryPillText

    /// Build a simple filled CTA style
    var ctaConfig = UIButton.Configuration.filled()
    ctaConfig.title = item.ctaTitle
    ctaConfig.baseBackgroundColor = .systemBackground
    ctaConfig.baseForegroundColor = .label
    ctaConfig.cornerStyle = .capsule
    ctaConfig.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
    self.ctaButton.configuration = ctaConfig
  }

  func setPlayer(_ newPlayer: AVPlayer?) {
    /// Drop old observers so we don’t get callbacks for an old item/player
    self.statusObservation = nil
    self.keepUpObservation = nil
    self.timeControlObservation = nil
    self.readyForDisplayObservation = nil

    player = newPlayer
    self.playerLayer.player = newPlayer

    /// We manage loading UI ourselves; don’t let AVFoundation “wait a bit” before playing
    newPlayer?.automaticallyWaitsToMinimizeStalling = false

    /// Observe whether the layer has a frame ready to show (this is the key anti-black-screen signal)
    self.readyForDisplayObservation = self.playerLayer.observe(
      \.isReadyForDisplay,
      options: [.initial, .new]
    ) { [weak self] _, _ in
      self?.updateLoadingBasedOnState()
    }

    /// Observe player playback/buffering state changes
    self.timeControlObservation = newPlayer?.observe(\.timeControlStatus, options: [
      .initial,
      .new
    ]) { [weak self] _, _ in
      self?.updateLoadingBasedOnState()
    }

    guard let player = newPlayer, let item = player.currentItem else {
      /// No player/item means we can’t render anything yet
      self.setLoading(true)
      return
    }

    /// Observe when the item becomes ready to play
    self.statusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] _, _ in
      /// We do NOT seek here; seeking happens only when the cell becomes active
      self?.updateLoadingBasedOnState()
      self?.attemptPlayIfReady()
    }

    /// Observe whether playback is likely to keep up (helps decide whether to show spinner)
    self.keepUpObservation = item.observe(\.isPlaybackLikelyToKeepUp, options: [
      .initial,
      .new
    ]) { [weak self] _, _ in
      self?.updateLoadingBasedOnState()
    }

    self.updateLoadingBasedOnState()
  }

  func setActive(_ active: Bool) {
    self.isActive = active

    /// Inactive cells should never keep audio playing
    guard active else {
      self.player?.pause()
      self.updateLoadingBasedOnState()
      return
    }

    /// Active cell should start playback as soon as it’s ready
    self.attemptPlayIfReady()
  }

  // MARK: - Playback

  private func attemptPlayIfReady() {
    guard self.isActive, let player, let item = player.currentItem else { return }

    /// If the asset isn’t ready yet, keep the loading overlay up
    guard item.status == .readyToPlay else {
      self.setLoading(true)
      return
    }

    /// Pause before seek so we don’t “jump” from a paused preview frame into a different time
    player.pause()

    /// Seek to a deterministic start frame when activating
    /// This avoids the visible “glitch/jump” during the snap → play transition
    player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
      guard let self else { return }
      guard self.isActive else { return }

      /// Start playback immediately after seek completes for a clean transition
      if #available(iOS 10.0, *) {
        player.playImmediately(atRate: 1.0)
      } else {
        player.play()
      }

      self.updateLoadingBasedOnState()
    }
  }

  private func updateLoadingBasedOnState() {
    guard let player = player, let item = player.currentItem else {
      self.setLoading(true)
      return
    }

    /// If we don’t have a renderable frame yet, hide the black screen behind the loading overlay
    if !self.playerLayer.isReadyForDisplay {
      self.setLoading(true)
      return
    }

    /// If the cell isn’t active, show the paused frame without a spinner
    guard self.isActive else {
      self.setLoading(false)
      return
    }

    /// Active cell: if the item isn’t ready, show loading
    if item.status != .readyToPlay {
      self.setLoading(true)
      return
    }

    /// Active cell: show loading while the player is explicitly waiting/buffering
    switch player.timeControlStatus {
    case .waitingToPlayAtSpecifiedRate:
      self.setLoading(true)
    case .playing, .paused:
      self.setLoading(false)
    @unknown default:
      self.setLoading(false)
    }
  }

  private func setLoading(_ isLoading: Bool) {
    self.loadingOverlay.isHidden = !isLoading

    /// Keep spinner state consistent with overlay visibility
    if isLoading {
      self.loadingIndicator.startAnimating()
    } else {
      self.loadingIndicator.stopAnimating()
    }
  }

  // MARK: - Setup

  private func setUpView() {
    contentView.backgroundColor = .black

    /// Put the video behind everything else
    self.playerLayer.videoGravity = .resizeAspectFill
    contentView.layer.insertSublayer(self.playerLayer, at: 0)

    self.setUpLoadingOverlay()

    /// Overlay container holds all UI above video
    self.overlayContainer.translatesAutoresizingMaskIntoConstraints = false
    self.overlayContainer.backgroundColor = .clear
    contentView.addSubview(self.overlayContainer)

    NSLayoutConstraint.activate([
      self.overlayContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      self.overlayContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      self.overlayContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
      self.overlayContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])

    self.setUpCloseButton()
    self.setUpRightRail()
    self.setUpBottomArea()
  }

  private func setUpLoadingOverlay() {
    /// Full-screen black overlay so we never show an empty black player layer
    self.loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
    self.loadingOverlay.backgroundColor = .black
    contentView.addSubview(self.loadingOverlay)

    NSLayoutConstraint.activate([
      self.loadingOverlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      self.loadingOverlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      self.loadingOverlay.topAnchor.constraint(equalTo: contentView.topAnchor),
      self.loadingOverlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])

    /// Centered spinner for “loading” state
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    self.loadingOverlay.addSubview(self.loadingIndicator)

    NSLayoutConstraint.activate([
      self.loadingIndicator.centerXAnchor.constraint(equalTo: self.loadingOverlay.centerXAnchor),
      self.loadingIndicator.centerYAnchor.constraint(equalTo: self.loadingOverlay.centerYAnchor)
    ])

    /// Start in loading state to avoid a flash of black
    self.setLoading(true)
  }

  private func setUpCloseButton() {
    /// Close button in top-left corner
    self.closeButton.translatesAutoresizingMaskIntoConstraints = false
    self.closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
    self.closeButton.tintColor = .white
    self.closeButton.backgroundColor = .clear
    self.closeButton.accessibilityLabel = "Close"

    self.closeButton.addTarget(self, action: #selector(self.closeTapped), for: .touchUpInside)

    self.overlayContainer.addSubview(self.closeButton)

    NSLayoutConstraint.activate([
      self.closeButton.leadingAnchor.constraint(
        equalTo: self.overlayContainer.leadingAnchor,
        constant: 16
      ),
      self.closeButton.topAnchor.constraint(
        equalTo: self.overlayContainer.safeAreaLayoutGuide.topAnchor,
        constant: 8
      ),
      self.closeButton.widthAnchor.constraint(equalToConstant: 44),
      self.closeButton.heightAnchor.constraint(equalToConstant: 44)
    ])
  }

  private func setUpRightRail() {
    /// Vertical action rail on the right side
    self.rightRailStack.translatesAutoresizingMaskIntoConstraints = false
    self.rightRailStack.axis = .vertical
    self.rightRailStack.alignment = .center
    self.rightRailStack.distribution = .equalSpacing
    self.rightRailStack.spacing = 14

    self.overlayContainer.addSubview(self.rightRailStack)

    NSLayoutConstraint.activate([
      self.rightRailStack.trailingAnchor.constraint(
        equalTo: self.overlayContainer.trailingAnchor,
        constant: -14
      ),
      self.rightRailStack.centerYAnchor.constraint(
        equalTo: self.overlayContainer.centerYAnchor,
        constant: 40
      )
    ])

    /// Configure buttons + labels
    self.configureRailButton(self.likeButton, systemImage: "hand.thumbsup", accessibilityLabel: "Like")
    self.configureCountLabel(self.likeCountLabel, text: "1k")

    self.configureRailButton(self.saveButton, systemImage: "bookmark", accessibilityLabel: "Save")
    self.configureCountLabel(self.saveCountLabel, text: "50")

    self.configureRailButton(
      self.shareButton,
      systemImage: "arrowshape.turn.up.right",
      accessibilityLabel: "Share"
    )
    self.configureCountLabel(self.shareCountLabel, text: "")

    self.configureRailButton(self.moreButton, systemImage: "ellipsis", accessibilityLabel: "More")

    /// Wire up taps to callbacks
    self.likeButton.addTarget(self, action: #selector(self.likeTapped), for: .touchUpInside)
    self.saveButton.addTarget(self, action: #selector(self.saveTapped), for: .touchUpInside)
    self.shareButton.addTarget(self, action: #selector(self.shareTapped), for: .touchUpInside)
    self.moreButton.addTarget(self, action: #selector(self.moreTapped), for: .touchUpInside)

    /// Build the rail layout
    self.rightRailStack.addArrangedSubview(self.makeRailItem(
      button: self.likeButton,
      label: self.likeCountLabel
    ))
    self.rightRailStack.addArrangedSubview(self.makeRailItem(
      button: self.saveButton,
      label: self.saveCountLabel
    ))
    self.rightRailStack.addArrangedSubview(self.makeRailItem(
      button: self.shareButton,
      label: self.shareCountLabel
    ))
    self.rightRailStack.addArrangedSubview(self.moreButton)

    NSLayoutConstraint.activate([
      self.moreButton.widthAnchor.constraint(equalToConstant: 44),
      self.moreButton.heightAnchor.constraint(equalToConstant: 44)
    ])
  }

  private func makeRailItem(button: UIButton, label: UILabel) -> UIStackView {
    /// Button + label stacked vertically
    let stack = UIStackView(arrangedSubviews: [button, label])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 4

    NSLayoutConstraint.activate([
      button.widthAnchor.constraint(equalToConstant: 44),
      button.heightAnchor.constraint(equalToConstant: 44)
    ])

    return stack
  }

  private func configureRailButton(_ button: UIButton, systemImage: String, accessibilityLabel: String) {
    /// Standard rail button styling
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(systemName: systemImage), for: .normal)
    button.tintColor = .white
    button.backgroundColor = .clear
    button.accessibilityLabel = accessibilityLabel
  }

  private func configureCountLabel(_ label: UILabel, text: String) {
    /// Standard rail count label styling
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = text
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
  }

  private func setUpBottomArea() {
    /// Bottom-left area for project info + CTA
    self.bottomContainer.translatesAutoresizingMaskIntoConstraints = false
    self.bottomContainer.backgroundColor = .clear
    self.overlayContainer.addSubview(self.bottomContainer)

    NSLayoutConstraint.activate([
      self.bottomContainer.leadingAnchor.constraint(
        equalTo: self.overlayContainer.leadingAnchor,
        constant: 16
      ),
      self.bottomContainer.trailingAnchor.constraint(
        equalTo: self.overlayContainer.trailingAnchor,
        constant: -72
      ),
      self.bottomContainer.bottomAnchor.constraint(
        equalTo: self.overlayContainer.safeAreaLayoutGuide.bottomAnchor,
        constant: -12
      )
    ])

    /// Pill label style (with a wrapper to create padding)
    self.pillLabel.translatesAutoresizingMaskIntoConstraints = false
    self.pillLabel.textColor = .white
    self.pillLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    self.pillLabel.backgroundColor = UIColor(white: 0.0, alpha: 0.35)
    self.pillLabel.layer.cornerRadius = 10
    self.pillLabel.layer.masksToBounds = true
    self.pillLabel.setContentHuggingPriority(.required, for: .horizontal)
    self.pillLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    let pillWrapper = UIView()
    pillWrapper.translatesAutoresizingMaskIntoConstraints = false
    pillWrapper.backgroundColor = .clear
    pillWrapper.addSubview(self.pillLabel)

    NSLayoutConstraint.activate([
      self.pillLabel.leadingAnchor.constraint(equalTo: pillWrapper.leadingAnchor, constant: 10),
      self.pillLabel.trailingAnchor.constraint(equalTo: pillWrapper.trailingAnchor, constant: -10),
      self.pillLabel.topAnchor.constraint(equalTo: pillWrapper.topAnchor, constant: 4),
      self.pillLabel.bottomAnchor.constraint(equalTo: pillWrapper.bottomAnchor, constant: -4)
    ])

    /// Title label style
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
    self.titleLabel.textColor = .white
    self.titleLabel.numberOfLines = 2
    self.titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

    /// Stats label style
    self.statsLabel.translatesAutoresizingMaskIntoConstraints = false
    self.statsLabel.textColor = .white
    self.statsLabel.numberOfLines = 2
    self.statsLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    self.statsLabel.alpha = 0.9

    /// CTA button tap handler
    self.ctaButton.translatesAutoresizingMaskIntoConstraints = false
    self.ctaButton.addTarget(self, action: #selector(self.ctaTapped), for: .touchUpInside)

    /// Stack everything vertically
    let stack = UIStackView(arrangedSubviews: [pillWrapper, titleLabel, statsLabel, ctaButton])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.alignment = .leading
    stack.spacing = 8

    self.bottomContainer.addSubview(stack)

    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: self.bottomContainer.leadingAnchor),
      stack.trailingAnchor.constraint(lessThanOrEqualTo: self.bottomContainer.trailingAnchor),
      stack.topAnchor.constraint(equalTo: self.bottomContainer.topAnchor),
      stack.bottomAnchor.constraint(equalTo: self.bottomContainer.bottomAnchor),

      /// Keep CTA at a reasonable tappable height
      self.ctaButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
    ])
  }

  // MARK: - Actions

  @objc private func closeTapped() { self.onCloseTapped?() }
  @objc private func ctaTapped() { self.onCTAButtonTapped?() }
  @objc private func shareTapped() { self.onShareTapped?() }
  @objc private func moreTapped() { self.onMoreTapped?() }
  @objc private func saveTapped() { self.onSaveTapped?() }
  @objc private func likeTapped() { self.onLikeTapped?() }
}
