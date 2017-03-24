import Library
import Prelude
import Prelude_UIKit
import UIKit
import PlaygroundSupport

let groups = [
  ["Forest", "Green", "Grey", "Magenta"],
  ["Navy", "Orange", "Red"],
  ["Violet", "Text Green", "Text Navy"]
]

func paletteItemStackView(colorView colorView: UIView, labelsView: UIView) -> UIStackView {
  colorView
    |> roundedStyle()
    |> UIView.lens.frame %~~ { _, view in
        view.widthAnchor.constraint(equalToConstant: 120.0).isActive = true
        view.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
      return view.frame
  }

  return UIStackView()
    |> UIStackView.lens.axis .~ .horizontal
    |> UIStackView.lens.alignment .~ .center
    |> UIStackView.lens.spacing .~ 12.0
    |> UIStackView.lens.arrangedSubviews .~ [colorView, labelsView]
}

func labelsStackView(colorName colorName: String, startColor: UIColor, endColor: UIColor?, weight: Int? = nil) -> UIStackView {
  var weightValue = ""
  if let weight = weight {
    weightValue = " - \(weight)"
  }

  var endColorValue = ""
  if let endColor = endColor {
    endColorValue = " - #\(endColor.hexString)"
  }

  return UIStackView()
    |> UIStackView.lens.axis .~ .vertical
    |> UIStackView.lens.arrangedSubviews .~ [
      UILabel()
        |> UILabel.lens.text .~ "\(colorName)\(weightValue)"
        |> UILabel.lens.font .~ .ksr_headline(size: 14)
        |> UILabel.lens.textColor .~ .ksr_navy_900,
      UILabel()
        |> UILabel.lens.text .~ "#\(startColor.hexString)\(endColorValue)"
        |> UILabel.lens.font .~ .ksr_subhead(size: 14)
        |> UILabel.lens.textColor .~ .ksr_navy_500
  ]
}

//: A solid color block with labels in a stack view.

func colorBlockStackView(color color: UIColor, colorName: String, weight: Int? = nil) -> UIStackView {
  let view = UIView() |> UIView.lens.backgroundColor .~ color

  return paletteItemStackView(colorView: view, labelsView: labelsStackView(colorName: colorName,
                                                                           startColor: color,
                                                                           endColor: nil,
                                                                           weight: weight))
}

//: A gradient color block with labels in a stack view.

func gradientBlockStackView(colorName colorName: String, startColor: UIColor, endColor: UIColor) -> UIStackView {
  let view = GradientView()
  view.startPoint = CGPoint(x: 0.0, y: 1.0)
  view.endPoint = CGPoint(x: 1.0, y: 0.0)
  view.setGradient([(startColor, 0.0), (endColor, 1.0)])

  return paletteItemStackView(colorView: view, labelsView: labelsStackView(colorName: colorName,
                                                                           startColor: startColor,
                                                                           endColor: endColor))
}

let paletteStackView = UIStackView()
  |> UIStackView.lens.axis .~ .horizontal
  |> UIStackView.lens.alignment .~ .top
  |> UIStackView.lens.distribution .~ .equalSpacing
  |> UIStackView.lens.spacing .~ 0.0
  |> UIStackView.lens.layoutMargins .~ .init(all: 32.0)
  |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
  |> UIStackView.lens.arrangedSubviews .~ groups.map { group in

    UIStackView()
      |> UIStackView.lens.axis .~ .vertical
      |> UIStackView.lens.alignment .~ .leading
      |> UIStackView.lens.spacing .~ 60.0
      |> UIStackView.lens.arrangedSubviews .~ group.map { colorName in
        let weights = UIColor.ksr_allColors[colorName]!

        return UIStackView()
          |> UIStackView.lens.axis .~ .vertical
          |> UIStackView.lens.alignment .~ .leading
          |> UIStackView.lens.spacing .~ 12.0
          |> UIStackView.lens.arrangedSubviews .~ weights.keys.sorted().map { weight in
            let color = weights[weight]!
            return colorBlockStackView(color: color, colorName: colorName, weight: weight)
        }
    }
}

let dropShadowView = colorBlockStackView(color: .ksr_dropShadow, colorName: "Drop Shadow")


let gradient1 = gradientBlockStackView(colorName: "Lavender / Powder",
                                       startColor: .ksr_lavenderToPowderGradientStart,
                                       endColor: .ksr_lavenderToPowderGradientEnd)

let gradient2 = gradientBlockStackView(colorName: "Peach / Blush",
                                       startColor: .ksr_peachToBlushGradientStart,
                                       endColor: .ksr_peachToBlushGradientEnd)

let gradient3 = gradientBlockStackView(colorName: "Sand / Sage",
                                       startColor: .ksr_sandToSageGradientStart,
                                       endColor: .ksr_sandToSageGradientEnd)

let miscStackView = UIStackView()
  |> UIStackView.lens.axis .~ .vertical
  |> UIStackView.lens.alignment .~ .leading
  |> UIStackView.lens.distribution .~ .equalSpacing
  |> UIStackView.lens.spacing .~ 12.0
  |> UIStackView.lens.arrangedSubviews .~ [dropShadowView, gradient1, gradient2, gradient3]

paletteStackView.addArrangedSubview(miscStackView)

let size = paletteStackView.systemLayoutSizeFitting(
  CGSize(width: 1150, height: 1100),
  withHorizontalFittingPriority: UILayoutPriorityDefaultHigh,
  verticalFittingPriority: UILayoutPriorityDefaultHigh
)
paletteStackView.frame = CGRect(origin: .zero, size: size)

let container = UIView(frame: paletteStackView.frame)
container.backgroundColor = .white
container.addSubview(paletteStackView)
PlaygroundPage.current.liveView = container
container.frame.height
