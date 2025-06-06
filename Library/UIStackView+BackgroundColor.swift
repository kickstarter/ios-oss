import Prelude
import UIKit

extension UIStackView {
  public func pinBackground(_ color: UIColor = LegacyColors.ksr_support_100.uiColor()) {
    let view = UIView()
      |> UIView.lens.backgroundColor .~ color
      |> UIView.lens.layer.cornerRadius .~ 6.0
      |> UIView.lens.translatesAutoresizingMaskIntoConstraints .~ false

    self.insertSubview(view, at: 0)
    view.pin(to: self)
  }
}

private extension UIView {
  func pin(to view: UIView) {
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: view.leadingAnchor),
      trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topAnchor.constraint(equalTo: view.topAnchor),
      bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}
