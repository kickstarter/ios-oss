import Prelude

extension Message {
  internal static let template = Message(
    body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam augue dolor, " +
      "accumsan nec aliquam a, porttitor sed dui. Integer iaculis ipsum fringilla metus " +
      "porttitor euismod. Donec in libero vitae lectus ultrices vehicula id eget dolor. " +
    "Nulla lacinia erat a ullamcorper sollicitudin.",
    createdAt: Date(timeIntervalSince1970: 1475361315).timeIntervalSince1970,
    id: 1,
    recipient: .template,
    sender: .template |> User.lens.id %~ { $0 + 1 }
  )
}
