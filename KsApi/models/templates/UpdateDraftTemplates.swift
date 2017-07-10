import Prelude

extension UpdateDraft {
  internal static let template = UpdateDraft(
    update: .template,
    images: [],
    video: nil
  )

  internal static let blank = template
    |> UpdateDraft.lens.update.title .~ ""
    |> UpdateDraft.lens.update.body .~ ""
    |> UpdateDraft.lens.update.isPublic .~ true
}

extension UpdateDraft.Image {
  internal static let template = UpdateDraft.Image(
    id: 1,
    thumb: "test-thumb.png",
    full: "test-full.png"
  )
}

extension UpdateDraft.Video {
  internal static let template = UpdateDraft.Video(
    id: 1,
    status: .successful,
    frame: "test-frame.png"
  )
}
