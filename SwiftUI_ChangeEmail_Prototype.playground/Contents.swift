import SwiftUI
import PlaygroundSupport

/// 0x028858
public var ksr_create_700: Color {
    return hex(0x028858)
}

/// 0xF3F3F3
public var ksr_support_100: Color {
    return hex(0xF3F3F3)
}

/// 0x222222
public var ksr_support_700: Color {
    return hex(0x222222)
}

/// 0xD1D1D1
public var ksr_support_300: Color {
    return hex(0xD1D1D1)
}

/// 0x696969
public var ksr_support_400: Color {
    return hex(0x696969)
}

func hex(_ value: UInt32) -> Color {
    let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
    let g = CGFloat((value & 0xFF00) >> 8) / 255.0
    let b = CGFloat(value & 0xFF) / 255.0
    
    return Color(UIColor(red: r, green: g, blue: b, alpha: 1.0))
}

public func ksr_body(size: CGFloat? = nil) -> Font {
    return preferredFont(style: .body, size: size)
}

fileprivate func preferredFont(style: UIFont.TextStyle, size: CGFloat? = nil) -> Font {
    let defaultSize: CGFloat
    switch style {
    case UIFont.TextStyle.body: defaultSize = 17
    case UIFont.TextStyle.callout: defaultSize = 16
    case UIFont.TextStyle.caption1: defaultSize = 12
    case UIFont.TextStyle.caption2: defaultSize = 11
    case UIFont.TextStyle.footnote: defaultSize = 13
    case UIFont.TextStyle.headline: defaultSize = 17
    case UIFont.TextStyle.subheadline: defaultSize = 15
    case UIFont.TextStyle.title1: defaultSize = 28
    case UIFont.TextStyle.title2: defaultSize = 22
    case UIFont.TextStyle.title3: defaultSize = 20
    default: defaultSize = 17
    }
    
    let font: UIFont
    if #available(iOS 13.0, *) {
        font = UIFont.preferredFont(
            forTextStyle: style,
            compatibleWith: .current
        )
    } else {
        font = UIFont.preferredFont(forTextStyle: style)
    }
    let descriptor = font.fontDescriptor
    return Font(UIFont(
        descriptor: descriptor,
        size: ceil(font.pointSize / defaultSize * (size ?? defaultSize)))
    )
}

struct ChangeEmailView: View {
    @State var emailText: String
    @State private var newEmailText = ""
    @State private var password = ""
    
    let ksr_support100 = Color(red: 243/255, green: 243/255, blue: 243/255)
    
    init(emailText: String) {
        self.emailText = emailText
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.configureWithOpaqueBackground()
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
    
    var body: some View {
        NavigationView { // Deprecated on iOS 16
            List {
                Group {
                    HStack {
                        Text("Current Email")
                            .frame(maxWidth: .infinity,
                                   alignment: .leading)
                            .font(ksr_body())
                            .foregroundColor(ksr_support_700)
                        Spacer()
                        TextField("", text: $emailText)
                            .frame(maxWidth: .infinity,
                                   alignment: .trailing)
                            .font(ksr_body())
                            .foregroundColor(ksr_support_700)
                    }
                    .padding(.vertical, 8)
                }
                
                Group {
                    HStack {
                        Text("New email")
                            .frame(maxWidth: .infinity,
                                   alignment: .leading)
                            .font(ksr_body())
                            .foregroundColor(ksr_support_700)
                        Spacer()
                        TextField("", text: $newEmailText, prompt:
                                    Text("New email")
                        )
                        .frame(maxWidth: .infinity,
                               alignment: .trailing)
                        .font(ksr_body())
                        .foregroundColor(ksr_support_700)
                        .multilineTextAlignment(.trailing)
                    }
                    .padding(.vertical, 8)
                    
                    HStack {
                        Text("Current password")
                            .frame(maxWidth: .infinity,
                                   alignment: .leading)
                            .font(ksr_body())
                            .foregroundColor(ksr_support_700)
                        Spacer()
                        TextField("", text: $password, prompt: Text("Password"))
                            .frame(maxWidth: .infinity,
                                   alignment: .trailing)
                            .font(ksr_body())
                            .foregroundColor(ksr_support_700)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.vertical, 8)
                }
            }
            .background(ksr_support_100)
            .listStyle(.plain)
            .navigationTitle("Change email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        print("save")
                    }
                    .foregroundColor(ksr_create_700)
                    .font(.system(size: 17, weight: .medium))
                }
            }
        }
    }
}

PlaygroundPage.current.setLiveView(ChangeEmailView(emailText: "msadoon@gmail.com"))
