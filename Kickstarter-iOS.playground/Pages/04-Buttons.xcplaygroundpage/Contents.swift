import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground

let liveView = UIView(frame: .init(x: 0, y: 0, width: 440, height: 600))
  |> UIView.lens.backgroundColor .~ .ksr_offWhite
XCPlaygroundPage.currentPage.liveView = liveView

let rootStackView = UIStackView(frame: liveView.bounds)
  |> UIStackView.lens.alignment .~ .Leading
  |> UIStackView.lens.axis .~ .Vertical
  |> UIStackView.lens.distribution .~ .FillEqually
  |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
  |> UIStackView.lens.layoutMargins .~ .init(all: 16)
liveView.addSubview(rootStackView)

let positiveButton = positiveButtonStyle <> UIButton.lens.titleText(forState: .Normal) .~ "Positive button"
let neutralButton  = neutralButtonStyle  <> UIButton.lens.titleText(forState: .Normal) .~ "Neutral button"
let borderButton   = borderButtonStyle   <> UIButton.lens.titleText(forState: .Normal) .~ "Border button"
let blackButton    = blackButtonStyle    <> UIButton.lens.titleText(forState: .Normal) .~ "Black button"

func disabled <C: UIControlProtocol> () -> (C -> C) {
  return C.lens.enabled .~ false
}

let buttonsStyles: [[UIButton -> UIButton]] = [
  [ positiveButton,      positiveButton      <> disabled() ],
  [ neutralButton,       neutralButton       <> disabled() ],
  [ borderButton,        borderButton        <> disabled() ],
  [ blackButton,         blackButton         <> disabled() ],
  [ facebookButtonStyle, facebookButtonStyle <> disabled() ],
]

let rowStackViewStyle =
  UIStackView.lens.alignment .~ .Top
    <> UIStackView.lens.axis .~ .Horizontal
    <> UIStackView.lens.distribution .~ .EqualSpacing
    <> UIStackView.lens.spacing .~ 24.0

for buttonStyles in buttonsStyles {
  rootStackView.addArrangedSubview(
    UIStackView()
      |> rowStackViewStyle
      |> UIStackView.lens.arrangedSubviews .~ buttonStyles.map { UIButton() |> $0 }
  )
}
