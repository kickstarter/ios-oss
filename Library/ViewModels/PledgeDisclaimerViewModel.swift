import Foundation
import KsApi
import ReactiveSwift

public typealias PledgeDisclaimerViewData = (
  iconImageName: String,
  attributedText: NSAttributedString
)

public protocol PledgeDisclaimerViewModelOutputs {
  var iconImageName: Signal<String, Never> { get }
  var attributedText: Signal<NSAttributedString, Never> { get }
  var notifyDelegateLinkTappedWithURL: Signal<URL, Never> { get }
}

public protocol PledgeDisclaimerViewModelInputs {
  func configure(with data: PledgeDisclaimerViewData)
  func linkTapped(url: URL)
}

public protocol PledgeDisclaimerViewModelType {
  var inputs: PledgeDisclaimerViewModelInputs { get }
  var outputs: PledgeDisclaimerViewModelOutputs { get }
}

public final class PledgeDisclaimerViewModel: PledgeDisclaimerViewModelType,
  PledgeDisclaimerViewModelInputs, PledgeDisclaimerViewModelOutputs {
  public init() {
    self.notifyDelegateLinkTappedWithURL = self.linkTappedURLProperty.signal.skipNil()
    self.iconImageName = self.configDataProperty.signal.skipNil().map(\.iconImageName)
    self.attributedText = self.configDataProperty.signal.skipNil().map(\.attributedText)
  }

  private let configDataProperty = MutableProperty<PledgeDisclaimerViewData?>(nil)
  public func configure(with data: PledgeDisclaimerViewData) {
    self.configDataProperty.value = data
  }

  private let linkTappedURLProperty = MutableProperty<URL?>(nil)
  public func linkTapped(url: URL) {
    self.linkTappedURLProperty.value = url
  }

  public let attributedText: Signal<NSAttributedString, Never>
  public let iconImageName: Signal<String, Never>
  public let notifyDelegateLinkTappedWithURL: Signal<URL, Never>

  public var inputs: PledgeDisclaimerViewModelInputs { return self }
  public var outputs: PledgeDisclaimerViewModelOutputs { return self }
}
