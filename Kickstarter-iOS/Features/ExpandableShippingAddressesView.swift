import Library
import SwiftUI

struct ShippingAddress: Identifiable, Hashable {
  var id: Int
  var name: String
  var street: String
  var cityState: String
  var zip: String
  var country: String
  var phoneNumber: String
}

struct ExpandableShippingAddressesView: View {
  @State var expanded = false
  @State var selectedAddress: ShippingAddress? = ShippingAddress(
    id: 1,
    name: "John Smith",
    street: "123 Fake Street",
    cityState: "Springfield, IL",
    zip: "12345",
    country: "United States",
    phoneNumber: "+1 (123) 456 7890"
  )

  var allAddresses = [
    ShippingAddress(
      id: 1,
      name: "John Smith",
      street: "123 Fake Street",
      cityState: "Springfield, IL",
      zip: "12345",
      country: "United States",
      phoneNumber: "+1 (123) 456 7890"
    ),
    ShippingAddress(
      id: 2,
      name: "Jane Smith",
      street: "123 Fake Street",
      cityState: "Springfield, IL",
      zip: "12345",
      country: "United States",
      phoneNumber: "+1 (123) 456 7890"
    ),
    ShippingAddress(
      id: 3,
      name: "Bob Smith",
      street: "123 Fake Street",
      cityState: "Springfield, IL",
      zip: "12345",
      country: "United States",
      phoneNumber: "+1 (123) 456 7890"
    ),
    ShippingAddress(
      id: 4,
      name: "Austin Smith",
      street: "123 Fake Street",
      cityState: "Springfield, IL",
      zip: "12345",
      country: "United States",
      phoneNumber: "+1 (123) 456 7890"
    )
  ]
  var allAddressesEmpty = [ShippingAddress]()

  var body: some View {
    VStack {
      /// Using a List to get out fo the box styling.
      List {
        /// If the list is expanded, show all addresses.
        if self.expanded {
          ForEach(self.allAddresses, id: \.self) { item in
            /// Showing either just the currently selected address or all saved addresses
            SelectableShippingAddressListItem(
              address: item,
              isSelected: item == self.selectedAddress
            ) { selectedAddress in
                withAnimation {
                  self.selectedAddress = selectedAddress
                }
            }
          }
          
          /// Button to confirm the selected address when the list is expanded and collapses the list..
            Button {
              withAnimation {
                  self.expanded.toggle()
                }
            } label: {
              Text("Use this address") // TODO: need to get this translated and added
                .font(Font(UIFont.ksr_body(size: 16).weighted(.semibold)))
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Color(.ksr_black))
            .foregroundColor(Color(.ksr_white))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
          /// If the list is collapsed, and there's a currently selected address, show just the selected address with the edit button.
        } else if let selectedAddress = self.selectedAddress {
          ForEach([self.selectedAddress], id: \.self) { item in
            SelectedShippingAddressListItem(
              expanded: self.$expanded,
              address: selectedAddress
            )
          }
          /// Other wise there are no addresses so show the option to add a new one.
        } else {
          Text("no address")  
        }
      }
    }
  }
}

/// The selected address and edit button to expand the list.
struct SelectedShippingAddressListItem: View {
  @Binding var expanded: Bool
  var address: ShippingAddress

  var body: some View {
    HStack(alignment: .top) {
      // Shipping Address
      Text(
        "\(self.address.name)\n\(self.address.street)\n\(self.address.cityState)\n\(self.address.zip),\(self.address.country)\n\(self.address.phoneNumber)"
      )
      .font(Font(UIFont.ksr_body(size: 14)))
      .padding()

      Spacer()

      // Edit button button
      Button {
        withAnimation {
            self.expanded.toggle()
          }
      } label: {
        Text(Strings.discovery_favorite_categories_buttons_edit())
          .font(Font(UIFont.ksr_body(size: 14)))
          .foregroundColor(Color(.ksr_create_700))
          .padding()
      }
    }
  }
}

/// The selectable address and radio button displayed in the expanded list
struct SelectableShippingAddressListItem: View {
  var address: ShippingAddress
  let isSelected: Bool
  let selectAddress: (ShippingAddress) -> Void

  var body: some View {
    HStack(alignment: .top) {
      // Radio selector button
      VStack {
        Spacer()

        Button {
          self.selectAddress(self.address)
        } label: {
          Image(self.isSelected ? "icon-payment-method-selected" : "icon-payment-method-unselected")
            .resizable()
            .scaledToFill()
            .frame(width: 14, height: 14)
        }

        Spacer()
      }

      // Shipping Address
      Text(
        "\(self.address.name)\n\(self.address.street)\n\(self.address.cityState)\n\(self.address.zip),\(self.address.country)\n\(self.address.phoneNumber)"
      )
      .font(Font(UIFont.ksr_body(size: 14)))
      .padding()
      
      Spacer()
    }
  }
}

#Preview {
  ExpandableShippingAddressesView()
}
