/**
 Supported languages.
*/
enum Language : String {
  case en
  case es
  case fr
  case de
}

extension Language : Equatable {}
func == (lhs: Language, rhs: Language) -> Bool {
  switch (lhs, rhs) {
  case (.en, .en), (.es, .es), (.fr, .fr), (.de, .de):
    return true
  default:
    return false
  }
}
