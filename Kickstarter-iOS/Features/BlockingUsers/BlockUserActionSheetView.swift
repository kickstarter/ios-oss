import SwiftUI

@available(iOS 15.0, *)
struct BlockUserActionSheetView: View {
  let blockUser: () -> Void
  let viewProfile: (() -> Void)?

  var body: some View {
    // TODO: Use localized strings once translations are done
    EmptyView()
      .confirmationDialog("", isPresented: .constant(true), titleVisibility: .hidden) {
        if let viewProfile = viewProfile {
          Button("View profile") {
            viewProfile()
          }
        }

        Button(role: .destructive) {
          blockUser()
        } label: {
          Text("Block this user")
        }
      }
  }
}
