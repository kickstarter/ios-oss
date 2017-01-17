extension LiveStreamEvent {
  internal static let template = LiveStreamEvent(
    creator: Creator(
      avatar: "https://www.kickstarter.com/creator-avatar.jpg",
      name: "Creator Name"
    ),
    firebase: Firebase(
      apiKey: "deadbeef",
      chatPath: "/chat",
      greenRoomPath: "/green-room",
      hlsUrlPath: "/hls",
      numberPeopleWatchingPath: "/watching",
      project: "beefcafe",
      scaleNumberPeopleWatchingPath: "/scale-watching"
    ),
    id: 123,
    openTok: OpenTok(
      appId: "123",
      sessionId: "123",
      token: "123"
    ),
    stream: Stream(
      backgroundImageUrl: "",
      description: "Test LiveStreamEvent",
      hasReplay: false,
      hlsUrl: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8",
      isRtmp: false,
      isScale: false,
      liveNow: false,
      maxOpenTokViewers: 300,
      name: "Test LiveStreamEvent",
      projectWebUrl: "",
      projectName: "Test Project",
      replayUrl: nil,
      startDate: Date(timeIntervalSince1970: 1234567890),
      webUrl: ""
    ),
    user: User(isSubscribed: false)
  )
}
