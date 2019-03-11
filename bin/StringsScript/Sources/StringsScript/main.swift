import StringsScriptCore

let tool = StringsScript()

do {
  try tool.run()
} catch {
  print("❌ Error: \(error.localizedDescription)")
}
