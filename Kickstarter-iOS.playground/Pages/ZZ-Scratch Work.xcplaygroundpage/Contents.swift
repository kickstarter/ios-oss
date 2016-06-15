import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground

let liveView = UIView(frame: .init(x: 0, y: 0, width: 800, height: 600))
  |> UIView.lens.backgroundColor .~ .ksr_mint
  |> UIView.lens.layoutMargins .~ .init(all: 32)
XCPlaygroundPage.currentPage.liveView = liveView

let first = UIView()
  |> UIView.lens.backgroundColor .~ .ksr_blue
  |> UIView.lens.layoutMargins .~ .init(all: 64)
  |> UIView.lens.translatesAutoresizingMaskIntoConstraints .~ false
  |> UIView.lens.preservesSuperviewLayoutMargins .~ true
liveView.addSubview(first)

first.topAnchor.constraintEqualToAnchor(liveView.layoutMarginsGuide.topAnchor).active = true
first.leadingAnchor.constraintEqualToAnchor(liveView.layoutMarginsGuide.leadingAnchor).active = true
first.trailingAnchor.constraintEqualToAnchor(liveView.layoutMarginsGuide.trailingAnchor).active = true
first.bottomAnchor.constraintEqualToAnchor(liveView.layoutMarginsGuide.bottomAnchor).active = true

let second = UIView()
  |> UIView.lens.backgroundColor .~ .ksr_pink
  |> UIView.lens.translatesAutoresizingMaskIntoConstraints .~ false
  |> UIView.lens.preservesSuperviewLayoutMargins .~ true
first.addSubview(second)

second.topAnchor.constraintEqualToAnchor(first.layoutMarginsGuide.topAnchor).active = true
second.leadingAnchor.constraintEqualToAnchor(first.layoutMarginsGuide.leadingAnchor).active = true
second.trailingAnchor.constraintEqualToAnchor(first.layoutMarginsGuide.trailingAnchor).active = true
second.bottomAnchor.constraintEqualToAnchor(first.layoutMarginsGuide.bottomAnchor).active = true
