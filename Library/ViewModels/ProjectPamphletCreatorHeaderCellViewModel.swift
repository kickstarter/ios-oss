import Foundation
import KsApi
import ReactiveSwift
import UIKit

public protocol ProjectPamphletCreatorHeaderCellViewModelInputs {
  func configure(with project: Project)
}

public protocol ProjectPamphletCreatorHeaderCellViewModelOutputs {
  var buttonTitle: Signal<String, Never> { get }
  var launchDateLabelAttributedText: Signal<NSAttributedString, Never> { get }
}

public protocol ProjectPamphletCreatorHeaderCellViewModelType {
  var inputs: ProjectPamphletCreatorHeaderCellViewModelInputs { get }
  var outputs: ProjectPamphletCreatorHeaderCellViewModelOutputs { get }
}

public final class ProjectPamphletCreatorHeaderCellViewModel: ProjectPamphletCreatorHeaderCellViewModelType,
ProjectPamphletCreatorHeaderCellViewModelInputs, ProjectPamphletCreatorHeaderCellViewModelOutputs {

  public init() {
    self.buttonTitle = self.projectSignal
      .map(title(for:))

    self.launchDateLabelAttributedText = self.projectSignal
      .map(attributedLaunchDateString(with:))
      .skipNil()
  }

  private let (projectSignal, projectObserver) = Signal<Project, Never>.pipe()
  public func configure(with project: Project) {
    self.projectObserver.send(value: project)
  }

  public let buttonTitle: Signal<String, Never>
  public let launchDateLabelAttributedText: Signal<NSAttributedString, Never>

  public var inputs: ProjectPamphletCreatorHeaderCellViewModelInputs { return self }
  public var outputs: ProjectPamphletCreatorHeaderCellViewModelOutputs { return self }
}

private func title(for project: Project) -> String {
  return project.state == .live ? "View progress" : "View dashboard"
}

private func attributedLaunchDateString(with project: Project)
  -> NSAttributedString? {
    let date = Format.date(secondsInUTC: project.dates.launchedAt, dateStyle: .medium, timeStyle: .none)
    let fullString = "You launched this project on \(date)"

    let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: fullString)
    let fullRange = (fullString as NSString).localizedStandardRange(of: fullString)
    let rangeDate: NSRange = (fullString as NSString).localizedStandardRange(of: date)

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .left

    let regularFontAttribute = [
      NSAttributedString.Key.paragraphStyle: paragraphStyle,
      NSAttributedString.Key.font: UIFont.ksr_caption1(),
      NSAttributedString.Key.foregroundColor: UIColor.ksr_text_dark_grey_500
    ]
    let boldFontAttribute = [NSAttributedString.Key.font: UIFont.ksr_caption1().bolded]

    attributedString.addAttributes(regularFontAttribute, range: fullRange)
    attributedString.addAttributes(boldFontAttribute, range: rangeDate)
    return attributedString
}
