import SwiftUI

final class MessageBannerWrapperViewController: UIViewController, MessageBannerViewControllerPresenting {
  var messageBannerViewController: MessageBannerViewController?
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureHostingController<T: View>(view: T) {
    let hostingViewController = UIHostingController(rootView: view)
    
    self.messageBannerViewController = self.configureMessageBannerViewController(on: hostingViewController)
  }
}

struct MessageBannerView<T: View>: UIViewControllerRepresentable {
  var hostingView: T
  
  func makeUIViewController(context _: Context) -> MessageBannerViewController {
      let messageBannerWrapperViewController = MessageBannerWrapperViewController.instantiate()
      messageBannerWrapperViewController.configureHostingController(view: hostingView)
      
    return messageBannerWrapperViewController.messageBannerViewController ?? MessageBannerViewController()
  }

  func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}
