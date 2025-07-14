// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct ThirdPartyEventItemInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    itemId: String,
    itemName: String,
    price: GraphQLNullable<Double> = nil
  ) {
    __data = InputDict([
      "itemId": itemId,
      "itemName": itemName,
      "price": price
    ])
  }

  /// The ID of the item.
  public var itemId: String {
    get { __data["itemId"] }
    set { __data["itemId"] = newValue }
  }

  /// The name of the item.
  public var itemName: String {
    get { __data["itemName"] }
    set { __data["itemName"] = newValue }
  }

  /// The monetary price of the item, in units of the specified currency parameter.
  public var price: GraphQLNullable<Double> {
    get { __data["price"] }
    set { __data["price"] = newValue }
  }
}
