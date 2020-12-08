import Foundation
import KsApi
import ReactiveSwift
import UIKit

public protocol ProjectPamphletCreatorHeaderCellViewModelInputs {
  func configure(with project: Project)
  func viewProgressButtonTapped()
}

public protocol ProjectPamphletCreatorHeaderCellViewModelOutputs {
  var buttonTitle: Signal<String, Never> { get }
  var launchDateLabelAttributedText: Signal<NSAttributedString, Never> { get }
  var notifyDelegateViewProgressButtonTapped: Signal<Project, Never> { get }
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

    self.notifyDelegateViewProgressButtonTapped = self.projectSignal
      .takeWhen(self.viewProgressButtonTappedSignal.ignoreValues())
  }

  private let (projectSignal, projectObserver) = Signal<Project, Never>.pipe()
  public func configure(with project: Project) {
    self.projectObserver.send(value: project)
  }

  private let (viewProgressButtonTappedSignal, viewProgressButtonTappedObserver) =
    Signal<Void, Never>.pipe()
  public func viewProgressButtonTapped() {
    self.viewProgressButtonTappedObserver.send(value: ())
  }

  public let buttonTitle: Signal<String, Never>
  public let launchDateLabelAttributedText: Signal<NSAttributedString, Never>
  public let notifyDelegateViewProgressButtonTapped: Signal<Project, Never>

  public var inputs: ProjectPamphletCreatorHeaderCellViewModelInputs { return self }
  public var outputs: ProjectPamphletCreatorHeaderCellViewModelOutputs { return self }
}

private func title(for project: Project) -> String {
  return project.state == .live ? Strings.View_progress() : Strings.View_dashboard()
}

private func attributedLaunchDateString(with project: Project)
  -> NSAttributedString? {
  let date = Format.date(
    secondsInUTC: project.dates.launchedAt,
    dateStyle: .long,
    timeStyle: .none,
    timeZone: UTCTimeZone
  )
  let fullString = Strings.You_launched_this_project_on_launch_date(launch_date: date)

  let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: fullString)
  let fullRange = (fullString as NSString).localizedStandardRange(of: fullString)
  let rangeDate: NSRange = (fullString as NSString).localizedStandardRange(of: date)

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
