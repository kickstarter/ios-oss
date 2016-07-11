import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground

let groups = [
  ["Coral", "Green", "Grey"],
  ["Navy", "Orange", "Peach", "Red"],
  ["Sage", "Teal", "Violet"],
  ["Text Green", "Text Navy"]
]

let paletteStackView = UIStackView()
  |> UIStackView.lens.axis .~ .Horizontal
  |> UIStackView.lens.alignment .~ .Top
  |> UIStackView.lens.distribution .~ .EqualSpacing
  |> UIStackView.lens.spacing .~ 48.0
  |> UIStackView.lens.layoutMargins .~ .init(all: 32.0)
  |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
  |> UIStackView.lens.arrangedSubviews .~ groups.map { group in

    UIStackView()
      |> UIStackView.lens.axis .~ .Vertical
      |> UIStackView.lens.alignment .~ .Leading
      |> UIStackView.lens.spacing .~ 60.0
      |> UIStackView.lens.arrangedSubviews .~ group.map { colorName in
        let weights = UIColor.ksr_allColors[colorName]!

        return UIStackView()
          |> UIStackView.lens.axis .~ .Vertical
          |> UIStackView.lens.alignment .~ .Leading
          |> UIStackView.lens.spacing .~ 12.0
          |> UIStackView.lens.arrangedSubviews .~ weights.keys.sort(>).map { weight in
            let color = weights[weight]!

            return UIStackView()
              |> UIStackView.lens.axis .~ .Horizontal
              |> UIStackView.lens.alignment .~ .Center
              |> UIStackView.lens.spacing .~ 12.0
              |> UIStackView.lens.arrangedSubviews .~ [
                UIView()
                  |> UIView.lens.backgroundColor .~ color
                  |> UIView.lens.frame %~~ { _, view in
                    view.widthAnchor.constraintEqualToConstant(120.0).active = true
                    view.heightAnchor.constraintEqualToConstant(40.0).active = true
                    return view.frame
                  }
                  |> roundedStyle(),
                UIStackView()
                  |> UIStackView.lens.axis .~ .Vertical
                  |> UIStackView.lens.arrangedSubviews .~ [
                    UILabel()
                      |> UILabel.lens.text .~ "\(colorName) – \(weight)"
                      |> UILabel.lens.font .~ .ksr_headline(size: 14)
                      |> UILabel.lens.textColor .~ .ksr_navy_900,
                    UILabel()
                      |> UILabel.lens.text .~ "#\(color.hexString)"
                      |> UILabel.lens.font .~ .ksr_subhead(size: 14)
                      |> UILabel.lens.textColor .~ .ksr_navy_500
                ]
            ]
        }
    }
}

let size = paletteStackView.systemLayoutSizeFittingSize(
  CGSize(width: 1150, height: 1100),
  withHorizontalFittingPriority: UILayoutPriorityDefaultHigh,
  verticalFittingPriority: UILayoutPriorityDefaultHigh
)
paletteStackView.frame = CGRect(origin: .zero, size: size)

let container = UIView(frame: paletteStackView.frame)
container.backgroundColor = .whiteColor()
container.addSubview(paletteStackView)
XCPlaygroundPage.currentPage.liveView = container
container.frame.height
