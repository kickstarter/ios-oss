import Combine
import Foundation
import Library

public class PPOViewModel: ObservableObject {
  let greeting = "Hello, PPO"

  @Published public var bannerViewModel: MessageBannerViewViewModel? = nil

  private var cancellables = Set<AnyCancellable>()

  public init() {
    // TODO: Send actual banner messages in response to card actions instead.
    self.shouldSendSampleMessageSubject
      .sink { [weak self] _ in
//        self?.bannerViewModel = MessageBannerViewViewModel((
//          .success,
//          "Survey submitted! Need to change your address? Visit your backing details on our website."
//        ))
        self?.bannerViewModel = MessageBannerViewViewModel((.success, "Your payment has been processed."))
      }
      .store(in: &self.cancellables)
  }

  private let shouldSendSampleMessageSubject = PassthroughSubject<(), Never>()
  public func shouldSendSampleMessage() {
    self.shouldSendSampleMessageSubject.send(())
  }
}
