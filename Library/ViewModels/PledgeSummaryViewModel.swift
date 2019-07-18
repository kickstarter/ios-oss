import Foundation
import Prelude
import ReactiveSwift

public protocol PledgeSummaryViewModelInputs {
  func tapped(_ url: URL)
}

public protocol PledgeSummaryViewModelOutputs {
  var notifyDelegateOpenHelpType: Signal<HelpType, Never> { get }
}

public protocol PledgeSummaryViewModelType {
  var inputs: PledgeSummaryViewModelInputs { get }
  var outputs: PledgeSummaryViewModelOutputs { get }
}

public class PledgeSummaryViewModel: PledgeSummaryViewModelType,
  PledgeSummaryViewModelInputs, PledgeSummaryViewModelOutputs {
  public init() {
    self.notifyDelegateOpenHelpType = self.tappedUrlSignal.map { url -> HelpType? in
      let helpType = HelpType.allCases.filter { helpType in
        url.absoluteString == helpType.url(
          withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl
        )?.absoluteString
      }
      .first

      return helpType
    }
    .skipNil()
  }

  private let (tappedUrlSignal, tappedUrlObserver) = Signal<URL, Never>.pipe()
  public func tapped(_ url: URL) {
    self.tappedUrlObserver.send(value: url)
  }

  public let notifyDelegateOpenHelpType: Signal<HelpType, Never>

  public var inputs: PledgeSummaryViewModelInputs { return self }
  public var outputs: PledgeSummaryViewModelOutputs { return self }
}
