import Foundation

extension Checkout {
  static func from(_ checkoutFragment: GraphAPI.CheckoutFragment?) -> Checkout? {
    guard
      let checkoutFragment = checkoutFragment,
      let state = Checkout.State(rawValue: checkoutFragment.state.rawValue)
    else { return nil }
    return Checkout(
      id: checkoutFragment.id,
      state: state,
      backing: Checkout.Backing(
        clientSecret: checkoutFragment.backing.clientSecret,
        requiresAction: checkoutFragment.backing.requiresAction ?? false
      )
    )
  }
}
