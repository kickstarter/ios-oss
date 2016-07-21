import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground

let (parent, child) = playgroundControllers(device: .phone4_7inch, orientation: .portrait)

let rootStackView = UIStackView(frame: child.view.bounds)
  |> UIStackView.lens.alignment .~ .Leading
  |> UIStackView.lens.axis .~ .Vertical
  |> UIStackView.lens.distribution .~ .FillEqually
  |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
  |> UIStackView.lens.layoutMargins .~ .init(all: 16)
child.view.addSubview(rootStackView)

let positiveButton = greenButtonStyle <> UIButton.lens.title(forState: .Normal) .~ "Positive button"
let neutralButton  = neutralButtonStyle  <> UIButton.lens.title(forState: .Normal) .~ "Neutral button"
let borderButton   = borderButtonStyle   <> UIButton.lens.title(forState: .Normal) .~ "Border button"
let blackButton    = blackButtonStyle    <> UIButton.lens.title(forState: .Normal) .~ "Black button"
let textOnlyButton = textOnlyButtonStyle <> UIButton.lens.title(forState: .Normal) .~ "Text only button"

func disabled <C: UIControlProtocol> () -> (C -> C) {
  return C.lens.enabled .~ false
}

let buttonsStyles: [[UIButton -> UIButton]] = [
  [ positiveButton,      positiveButton      <> disabled() ],
  [ neutralButton,       neutralButton       <> disabled() ],
  [ borderButton,        borderButton        <> disabled() ],
  [ blackButton,         blackButton         <> disabled() ],
  [ facebookButtonStyle, facebookButtonStyle <> disabled() ],
  [ textOnlyButton,      textOnlyButton      <> disabled() ],
]

let rowStackViewStyle =
  UIStackView.lens.alignment .~ .Top
    <> UIStackView.lens.axis .~ .Horizontal
    <> UIStackView.lens.distribution .~ .EqualSpacing
    <> UIStackView.lens.spacing .~ 24.0

buttonsStyles.forEach { styles in
  let rowStackView = UIStackView()
  rootStackView.addArrangedSubview(rowStackView)
  rowStackView |> rowStackViewStyle

  styles.forEach { style in
    let button = UIButton()
    rowStackView.addArrangedSubview(button)
    button |> style
  }
}

let frame = parent.view.frame
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
