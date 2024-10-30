import Foundation
import KsApi
import Prelude
import ReactiveSwift

public enum PledgeSummaryRewardCellDataType {
  case header
  case reward
  case shipping
  case bonusSupport
}

public struct PledgeSummaryRewardCellData: Hashable {
  public let id = UUID()
  public let type: PledgeSummaryRewardCellDataType?
  public let headerText: NSAttributedString?
  public let showHeader: Bool
  public let text: String
  public let amount: NSAttributedString
}

public protocol PledgeExpandableHeaderRewardCellViewModelInputs {
  func configure(with data: PledgeSummaryRewardCellData)
}

public protocol PledgeExpandableHeaderRewardCellViewModelOutputs {
  var amountAttributedText: Signal<NSAttributedString, Never> { get }
  var headerLabelText: Signal<NSAttributedString?, Never> { get }
  var labelText: Signal<String, Never> { get }
  var type: Signal<PledgeSummaryRewardCellDataType, Never> { get }
}

public protocol PledgeExpandableHeaderRewardCellViewModelType {
  var inputs: PledgeExpandableHeaderRewardCellViewModelInputs { get }
  var outputs: PledgeExpandableHeaderRewardCellViewModelOutputs { get }
}

public final class PledgeExpandableHeaderRewardCellViewModel: PledgeExpandableHeaderRewardCellViewModelType,
  PledgeExpandableHeaderRewardCellViewModelInputs, PledgeExpandableHeaderRewardCellViewModelOutputs {
  public init() {
    let data = self.configureWithDataProperty.signal.skipNil()
    let showHeader = data.map(\.showHeader)

    self.amountAttributedText = data.map(\.amount)
    self.headerLabelText = Signal.combineLatest(data, showHeader)
      .map { data, showHeader in
        showHeader == true ? data.headerText : nil
      }
    self.labelText = data.map(\.text)

    self.type = data.map(\.type).skipNil()
  }

  private let configureWithDataProperty = MutableProperty<PledgeSummaryRewardCellData?>(nil)
  public func configure(with data: PledgeSummaryRewardCellData) {
    self.configureWithDataProperty.value = data
  }

  public let amountAttributedText: Signal<NSAttributedString, Never>
  public let headerLabelText: Signal<NSAttributedString?, Never>
  public let labelText: Signal<String, Never>
  public let type: Signal<PledgeSummaryRewardCellDataType, Never>

  public var inputs: PledgeExpandableHeaderRewardCellViewModelInputs { return self }
  public var outputs: PledgeExpandableHeaderRewardCellViewModelOutputs { return self }
}
