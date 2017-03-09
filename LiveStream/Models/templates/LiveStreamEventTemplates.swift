import Foundation

extension LiveStreamEvent {

  internal static let template = LiveStreamEvent(
    backgroundImage: LiveStreamEvent.BackgroundImage(
      medium: "http://www.background.com/medium.jpg",
      smallCropped: "http://www.background.com/small-cropped.jpg"
    ),
    creator: Creator(
      avatar: "https://www.kickstarter.com/creator-avatar.jpg",
      name: "Creator Name"
    ),
    description: "Test LiveStreamEvent",
    firebase: Firebase(
      apiKey: "deadbeef",
      chatAvatarUrl: "http://www.kickstarter.com/avatar.jpg",
      chatPath: "/chat",
      chatUserId: "id_1234",
      chatUserName: "Chat User Name",
      greenRoomPath: "/green-room",
      hlsUrlPath: "/hls",
      numberPeopleWatchingPath: "/watching",
      project: "beefcafe",
      scaleNumberPeopleWatchingPath: "/scale-watching",
      token: "chat_auth_token"
    ),
    hasReplay: false,
    hlsUrl: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8",
    id: 123,
    isRtmp: false,
    isScale: false,
    liveNow: false,
    maxOpenTokViewers: 300,
    name: "Test LiveStreamEvent",
    openTok: OpenTok(
      appId: "123",
      sessionId: "123",
      token: "123"
    ),
    project: Project(id: 1, name: "Test Project", webUrl: ""),
    replayUrl: nil,
    startDate: Date(timeIntervalSince1970: 1234567890),
    user: nil,
    webUrl: "",
    numberPeopleWatching: 0
  )
}
