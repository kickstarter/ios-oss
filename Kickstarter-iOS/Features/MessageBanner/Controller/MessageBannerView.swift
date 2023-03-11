import SwiftUI

final class MessageBannerObservable: ObservableObject {
  @Published var showMessage: String?
}

final class MessageBannerWrapperViewController: UIViewController, MessageBannerViewControllerPresenting {
  var messageBannerViewController: MessageBannerViewController?

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  func configureHostingController<T: View>(view: T) {
    let hostingViewController = UIHostingController(rootView: view)

    self.messageBannerViewController = self.configureMessageBannerViewController(on: hostingViewController)
  }
}

struct MessageBannerView<T: View>: UIViewControllerRepresentable {
  var hostingView: T
  @ObservedObject var messageBannerObservable: MessageBannerObservable

  func makeUIViewController(context _: Context) -> MessageBannerViewController {
    let messageBannerWrapperViewController = MessageBannerWrapperViewController.instantiate()
    messageBannerWrapperViewController.configureHostingController(view: self.hostingView)

    return messageBannerWrapperViewController.messageBannerViewController ?? MessageBannerViewController()
  }

  func updateUIViewController(_ uiViewController: MessageBannerViewController, context _: Context) {
    guard let message = messageBannerObservable.showMessage else { return }

    uiViewController.showBanner(with: .error, message: message)
  }
}
