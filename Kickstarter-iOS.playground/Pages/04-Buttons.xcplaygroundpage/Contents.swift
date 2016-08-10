import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground

let (parent, child) = playgroundControllers(device: .phone5_5inch, orientation: .portrait)

let rootStackView = UIStackView(frame: child.view.bounds)
  |> UIStackView.lens.alignment .~ .Leading
  |> UIStackView.lens.axis .~ .Vertical
  |> UIStackView.lens.distribution .~ .FillEqually
  |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
  |> UIStackView.lens.layoutMargins .~ .init(all: 16)
child.view.addSubview(rootStackView)

func disabled <C: UIControlProtocol> () -> (C -> C) {
  return C.lens.enabled .~ false
}

let baseButtonsStyles: [UIButton -> UIButton] = [
  greenButtonStyle     <> UIButton.lens.title(forState: .Normal) .~ "Green button",
  navyButtonStyle      <> UIButton.lens.title(forState: .Normal) .~ "Navy button",
  lightNavyButtonStyle <> UIButton.lens.title(forState: .Normal) .~ "Light navy button",
  neutralButtonStyle   <> UIButton.lens.title(forState: .Normal) .~ "Neutral button",
  borderButtonStyle    <> UIButton.lens.title(forState: .Normal) .~ "Border button",
  blackButtonStyle     <> UIButton.lens.title(forState: .Normal) .~ "Black button",
  textOnlyButtonStyle  <> UIButton.lens.title(forState: .Normal) .~ "Text only button"
]

let buttonsStyles: [[UIButton -> UIButton]] = baseButtonsStyles.map { [$0, $0 <> disabled()] }

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
