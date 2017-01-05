extension LiveStreamEvent {
  internal static let template = LiveStreamEvent(
    creator: Creator(
      name: "Creator Name",
      avatar: "https://www.kickstarter.com/creator-avatar.jpg"
    ),
    firebase: Firebase(
      project: "",
      apiKey: "",
      hlsUrlPath: "",
      greenRoomPath: "",
      numberPeopleWatchingPath: "",
      scaleNumberPeopleWatchingPath: "",
      chatPath: ""
    ),
    id: 123,
    openTok: OpenTok(
      appId: "123",
      sessionId: "123",
      token: "123"
    ),
    stream: Stream(
      name: "Test LiveStreamEvent",
      description: "Test LiveStreamEvent",
      hlsUrl: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8",
      liveNow: false,
      startDate: NSDate(),
      backgroundImageUrl: "",
      maxOpenTokViewers: 300,
      webUrl: "",
      projectWebUrl: "",
      projectName: "Test Project",
      isRtmp: false,
      isScale: false,
      hasReplay: false,
      replayUrl: nil
    ),
    user: User(isSubscribed: false)
  )
}
