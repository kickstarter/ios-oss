import SwiftUI

struct ChangeEmailView: View {
  @State var emailText: String
  
    var body: some View {
      NavigationView {
        List {
          HStack {
            Text("Current Email")
            Spacer()
            TextField("title", text: $emailText)
          }
        }
      }
    }
}

struct ChangeEmailView_Previews: PreviewProvider {
    static var previews: some View {
      ChangeEmailView(emailText: "msadoon@gmail.com")
    }
}
