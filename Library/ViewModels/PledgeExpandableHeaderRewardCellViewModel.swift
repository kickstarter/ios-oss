import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias PledgeExpandableHeaderRewardCellData = (
  headerText: NSAttributedString?,
  showHeader: Bool,
  text: String,
  amount: NSAttributedString
)

public protocol PledgeExpandableHeaderRewardCellViewModelInputs {
  func configure(with data: PledgeExpandableHeaderRewardCellData)
}

public protocol PledgeExpandableHeaderRewardCellViewModelOutputs {
  var amountAttributedText: Signal<NSAttributedString, Never> { get }
  var headerLabelText: Signal<NSAttributedString?, Never> { get }
  var labelText: Signal<String, Never> { get }
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
  }

  private let configureWithDataProperty = MutableProperty<PledgeExpandableHeaderRewardCellData?>(nil)
  public func configure(with data: PledgeExpandableHeaderRewardCellData) {
    self.configureWithDataProperty.value = data
  }

  public let amountAttributedText: Signal<NSAttributedString, Never>
  public let headerLabelText: Signal<NSAttributedString?, Never>
  public let labelText: Signal<String, Never>

  public var inputs: PledgeExpandableHeaderRewardCellViewModelInputs { return self }
  public var outputs: PledgeExpandableHeaderRewardCellViewModelOutputs { return self }
}
