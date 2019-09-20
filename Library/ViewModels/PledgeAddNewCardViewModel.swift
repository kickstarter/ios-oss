import Foundation
import ReactiveSwift

public protocol PledgeAddNewCardViewModelOutputs {
  var notifyDelegateAddNewCardTappedWithIntent: Signal<AddNewCardIntent, Never> { get }
}

public protocol PledgeAddNewCardViewModelInputs {
  func addNewCardButtonTapped()
}

public protocol PledgeAddNewCardViewModelType {
  var inputs: PledgeAddNewCardViewModelInputs { get }
  var outputs: PledgeAddNewCardViewModelOutputs { get }
}

public final class PledgeAddNewCardViewModel: PledgeAddNewCardViewModelType, PledgeAddNewCardViewModelInputs,
  PledgeAddNewCardViewModelOutputs {
  public init() {
    self.notifyDelegateAddNewCardTappedWithIntent = self.addNewCardButtonTappedProperty.signal
      .mapConst(.pledgeView)
  }

  private let addNewCardButtonTappedProperty = MutableProperty(())
  public func addNewCardButtonTapped() {
    self.addNewCardButtonTappedProperty.value = ()
  }

  public let notifyDelegateAddNewCardTappedWithIntent: Signal<AddNewCardIntent, Never>

  public var inputs: PledgeAddNewCardViewModelInputs { return self }
  public var outputs: PledgeAddNewCardViewModelOutputs { return self }
}
