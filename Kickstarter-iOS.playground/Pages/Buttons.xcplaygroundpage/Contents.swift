import Library
import Prelude
import Prelude_UIKit
import UIKit
import PlaygroundSupport

let (parent, child) = playgroundControllers(device: .phone4_7inch, orientation: .portrait)

let rootStackView = UIStackView(frame: child.view.bounds)
  |> UIStackView.lens.alignment .~ .leading
  |> UIStackView.lens.axis .~ .vertical
  |> UIStackView.lens.distribution .~ .fillEqually
  |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
  |> UIStackView.lens.layoutMargins .~ .init(all: 16)
child.view.addSubview(rootStackView)

func disabled <C: UIControlProtocol> () -> ((C) -> C) {
  return C.lens.enabled .~ false
}

let baseButtonsStyles: [(UIButton) -> UIButton] = [
  greenButtonStyle       <> UIButton.lens.title(forState: .normal) .~ "Green button",
  navyButtonStyle        <> UIButton.lens.title(forState: .normal) .~ "Navy button",
  lightNavyButtonStyle   <> UIButton.lens.title(forState: .normal) .~ "Light navy button",
  neutralButtonStyle     <> UIButton.lens.title(forState: .normal) .~ "Neutral button",
  borderButtonStyle      <> UIButton.lens.title(forState: .normal) .~ "Border button",
  blackButtonStyle       <> UIButton.lens.title(forState: .normal) .~ "Black button",
  textOnlyButtonStyle    <> UIButton.lens.title(forState: .normal) .~ "Text only button",
  greenBorderButtonStyle <> UIButton.lens.title(forState: .normal) .~ "Green border button",
]

let buttonsStyles: [[(UIButton) -> UIButton]] = baseButtonsStyles.map { [$0, $0 <> disabled()] }

let rowStackViewStyle =
  UIStackView.lens.alignment .~ .top
    <> UIStackView.lens.axis .~ .horizontal
    <> UIStackView.lens.distribution .~ .equalSpacing
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

PlaygroundPage.current.liveView = parent
