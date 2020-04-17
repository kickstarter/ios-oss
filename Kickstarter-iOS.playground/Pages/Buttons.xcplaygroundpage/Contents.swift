import Library
import PlaygroundSupport
import Prelude
import Prelude_UIKit
import UIKit

let (parent, child) = playgroundControllers(device: .phone4inch, orientation: .portrait)

PlaygroundPage.current.liveView = parent

let rootStackView = UIStackView(frame: child.view.bounds)
  |> UIStackView.lens.alignment .~ .leading
  |> UIStackView.lens.axis .~ .vertical
  |> UIStackView.lens.distribution .~ .fillEqually
  |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
  |> UIStackView.lens.layoutMargins .~ .init(all: 16)

child.view.addSubview(rootStackView)

func disabled<C: UIControlProtocol>() -> ((C) -> C) {
  return C.lens.isEnabled .~ false
}

let baseButtonsStyles: [(UIButton) -> UIButton] = [
  apricotButtonStyle <> UIButton.lens.title(for: .normal) .~ "Apricot button",
  blackButtonStyle <> UIButton.lens.title(for: .normal) .~ "Black button",
  blueButtonStyle <> UIButton.lens.title(for: .normal) .~ "Blue button",
  greenButtonStyle <> UIButton.lens.title(for: .normal) .~ "Green button",
  greyButtonStyle <> UIButton.lens.title(for: .normal) .~ "Grey button"
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
