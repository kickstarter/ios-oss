import Foundation
import KsApi
import ReactiveSwift
import UIKit

public protocol ProjectPamphletCreatorHeaderCellViewModelInputs {
  func configure(with project: Project)
}

public protocol ProjectPamphletCreatorHeaderCellViewModelOutputs {
  var launchDateLabelAttributedText: Signal<NSAttributedString, Never> { get }
}

public protocol ProjectPamphletCreatorHeaderCellViewModelType {
  var inputs: ProjectPamphletCreatorHeaderCellViewModelInputs { get }
  var outputs: ProjectPamphletCreatorHeaderCellViewModelOutputs { get }
}

public final class ProjectPamphletCreatorHeaderCellViewModel: ProjectPamphletCreatorHeaderCellViewModelType,
  ProjectPamphletCreatorHeaderCellViewModelInputs, ProjectPamphletCreatorHeaderCellViewModelOutputs {
  public init() {
    self.launchDateLabelAttributedText = self.projectSignal
      .map(attributedLaunchDateString(with:))
      .skipNil()
  }

  private let (projectSignal, projectObserver) = Signal<Project, Never>.pipe()
  public func configure(with project: Project) {
    self.projectObserver.send(value: project)
  }

  public let launchDateLabelAttributedText: Signal<NSAttributedString, Never>

  public var inputs: ProjectPamphletCreatorHeaderCellViewModelInputs { return self }
  public var outputs: ProjectPamphletCreatorHeaderCellViewModelOutputs { return self }
}

private func attributedLaunchDateString(with project: Project) -> NSAttributedString? {
  var launchDate = ""

  if let date = project.dates.launchedAt {
    launchDate = Format.date(
      secondsInUTC: date,
      dateStyle: .long,
      timeStyle: .none,
      timeZone: UTCTimeZone
    )
  }

  let fullString = Strings.You_launched_this_project_on_launch_date(launch_date: launchDate)

  let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: fullString)
  let fullRange = (fullString as NSString).localizedStandardRange(of: fullString)
  let rangeDate: NSRange = (fullString as NSString).localizedStandardRange(of: launchDate)

  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.alignment = .left

  let regularFontAttribute = [
    NSAttributedString.Key.paragraphStyle: paragraphStyle,
    NSAttributedString.Key.font: UIFont.ksr_subhead(),
    NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700
  ]
  let boldFontAttribute = [NSAttributedString.Key.font: UIFont.ksr_subhead().bolded]

  attributedString.addAttributes(regularFontAttribute, range: fullRange)
  attributedString.addAttributes(boldFontAttribute, range: rangeDate)
  return attributedString
}
