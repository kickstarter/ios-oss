import Foundation
import Prelude
import ReactiveSwift

public protocol PledgeSummaryCellViewModelInputs {
  func tapped(_ url: URL)
}

public protocol PledgeSummaryCellViewModelOutputs {
  var notifyDelegateOpenHelpType: Signal<HelpType, Never> { get }
}

public protocol PledgeSummaryCellViewModelType {
  var inputs: PledgeSummaryCellViewModelInputs { get }
  var outputs: PledgeSummaryCellViewModelOutputs { get }
}

public class PledgeSummaryCellViewModel: PledgeSummaryCellViewModelType,
  PledgeSummaryCellViewModelInputs, PledgeSummaryCellViewModelOutputs {
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

  public var inputs: PledgeSummaryCellViewModelInputs { return self }
  public var outputs: PledgeSummaryCellViewModelOutputs { return self }
}
