import SwiftUI

struct MessageBannerView: UIViewControllerRepresentable {
  var hostViewController: MessageBannerViewControllerPresenting

  func makeUIViewController(context _: Context) -> some UIViewController {
    /**
     hostViewController.configureMessageBannerViewController(on: hostViewController)
     */
    UIViewController()
  }

  func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}

/** Not working at the moment
 struct MessageBannerView_Previews: PreviewProvider {
 static var previews: some View {
   let viewController = UIViewController()
   MessageBannerView(hostViewController: viewController)
 }
 }
 */
