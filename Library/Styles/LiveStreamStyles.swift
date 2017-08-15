import Prelude
import Prelude_UIKit
import UIKit

public let darkSubscribeButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .normal) .~ .ksr_text_dark_grey_900
  <> UIButton.lens.tintColor .~ .ksr_text_dark_grey_900
  <> UIButton.lens.backgroundColor(forState: .normal) .~ .clear
  <> UIButton.lens.titleColor(forState: .highlighted) .~ .white
  <> UIButton.lens.backgroundColor(forState: .selected) .~ UIColor.ksr_navy_600.withAlphaComponent(0.1)
  <> UIButton.lens.backgroundColor(forState: .highlighted) .~ UIColor.ksr_navy_600.withAlphaComponent(0.1)
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_navy_600.cgColor
  <> UIButton.lens.layer.borderWidth .~ 1.0
  <> UIButton.lens.semanticContentAttribute .~ .forceRightToLeft
  <> UIButton.lens.contentEdgeInsets %~~ { insets, button in
    button.traitCollection.isRegularRegular
      ? insets
      : .init(topBottom: Styles.gridHalf(3), leftRight: Styles.gridHalf(6))
  }
  <> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(right: -Styles.grid(1))

public let lightSubscribeButtonStyle = darkSubscribeButtonStyle
  <> UIButton.lens.titleColor(forState: .normal) .~ .white
  <> UIButton.lens.tintColor .~ .white
  <> UIButton.lens.titleColor(forState: .highlighted) .~ .white
  <> UIButton.lens.layer.borderColor .~ UIColor.white.cgColor

public let liveStreamGoToProjectStyle =
  UIButton.lens.title(forState: .normal) %~ { _ in Strings.Go_to_project_page() }
    <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: Styles.grid(4))
    <> UIButton.lens.titleLabel.font %~~ { _, button in
      button.traitCollection.isRegularRegular
        ? .ksr_headline()
        : .ksr_headline(size: 13)
}

public let liveStreamDateContainerStyle =
  roundedStyle()
    <> UIView.lens.backgroundColor .~ UIColor.white.withAlphaComponent(0.8)
    <> UIView.lens.layoutMargins .~ .init(topBottom: Styles.gridHalf(3), leftRight: Styles.grid(3))
