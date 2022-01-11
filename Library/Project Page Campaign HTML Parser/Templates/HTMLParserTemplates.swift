import Foundation

public enum HTMLParserTemplates {
  case validNonGIFImage
  case validGIFImage
  case validImageWithCaption
  case validImageWithCaptionAndLink
  case validVideo
  case validVideoHigh
  case validIFrame
  case validParagraphText
  case validHeaderText
  case validList
  case validParagraphTextWithStyles
  case validHeaderTextWithStyles
  case validListWithStyles
  case errored

  var data: String {
    switch self {
    case .validNonGIFImage:
      return self.validNonGIFImage
    case .validGIFImage:
      return self.validGIFImage
    case .validImageWithCaption:
      return self.validImageWithCaption
    case .validImageWithCaptionAndLink:
      return self.validImageWithCaptionAndLink
    case .validVideo:
      return self.validVideo
    case .validVideoHigh:
      return self.validVideoHigh
    case .validIFrame:
      return self.validExternalSource
    default:
      return self.erroredStory
    }
  }

  // MARK: Private Properties

  private var validVideo: String {
    """
    \n
    <div class="video-player" data-video-url="https://v.kickstarter.com/1642030675_192c029616b9f219c821971712835747963f13cc/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_high.mp4" data-image="https://dr0rfahizzuzj.cloudfront.net/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_high.jpg?2021" data-dimensions='{"width":640,"height":360}' data-context="Story Description">
       \n
       <video class="landscape" preload="none">
          \n
          <source src="https://v.kickstarter.com/1642030675_192c029616b9f219c821971712835747963f13cc/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_base.mp4" type='video/mp4; codecs="avc1.42E01E, mp4a.40.2"'></source>
          \nYou'll need an HTML5 capable browser to see this content.\n
       </video>
       \n<img class="has_played_hide full-width poster landscape" alt=" project video thumbnail" src="https://dr0rfahizzuzj.cloudfront.net/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_high.jpg?2021">\n
       <div class="play_button_container absolute-center has_played_hide">\n<button aria-label="Play video" class="play_button_big play_button_dark radius2px" type="button">\n<span class="ksr-icon__play" aria-hidden="true"></span>\nPlay\n</button>\n</div>
       \n
    </div>
    \n
    """
  }

  private var validVideoHigh: String {
    """
    \n
    <div class="video-player" data-video-url="https://v.kickstarter.com/1642030675_192c029616b9f219c821971712835747963f13cc/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_high.mp4" data-image="https://dr0rfahizzuzj.cloudfront.net/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_high.jpg?2021" data-dimensions='{"width":640,"height":360}' data-context="Story Description">
       \n
       <video class="landscape" preload="none">
          \n
          <source src="https://v.kickstarter.com/1642030675_192c029616b9f219c821971712835747963f13cc/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_high.mp4" type='video/mp4; codecs="avc1.64001E, mp4a.40.2"'></source>
          \n
          <source src="https://v.kickstarter.com/1642030675_192c029616b9f219c821971712835747963f13cc/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_base.mp4" type='video/mp4; codecs="avc1.42E01E, mp4a.40.2"'></source>
          \nYou'll need an HTML5 capable browser to see this content.\n
       </video>
       \n<img class="has_played_hide full-width poster landscape" alt=" project video thumbnail" src="https://dr0rfahizzuzj.cloudfront.net/assets/035/455/706/2610a2ac226ce966cc74ff97c8b6344d_h264_high.jpg?2021">\n
       <div class="play_button_container absolute-center has_played_hide">\n<button aria-label="Play video" class="play_button_big play_button_dark radius2px" type="button">\n<span class="ksr-icon__play" aria-hidden="true"></span>\nPlay\n</button>\n</div>
       \n
    </div>
    \n
    """
  }

  private var validImageWithCaption: String {
    """
    <div class=\"template asset\" contenteditable=\"false\" data-alt-text=\"\" data-caption=\"Viktor Pushkarev using lino-cutting to create the cover art.\" data-id=\"35418752\">\n<figure>\n<img alt=\"\" class=\"fit\" src=\"https://ksr-qa-ugc.imgix.net/assets/035/418/752/b1fe3dc3ff2aa64161aaf7cd6def0b97_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1635677740&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=6f32811c554177afaafc447642d83788\">\n<figcaption class=\"px2\">Viktor Pushkarev using lino-cutting to create the cover art.</figcaption>\n</figure>\n\n</div>\n\n\n
    """
  }

  private var validNonGIFImage: String {
    """
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33981078">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/981/078/6a3036d55ab3c3d6f271ab0b5c532912_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624426643&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=aaa772a0ea57e4697c14311f1f2e0086">\n </figure>\n\n </div>\n\n\n
    """
  }

  private var validGIFImage: String {
    """
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915794">\n
      <figure>\n <img alt="" class="fit js-lazy-image" data-src="https://ksr-qa-ugc.imgix.net/assets/033/915/794/8dca97fb0636aeb1a4a937025f369e7e_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894386&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=cde086d146601f4d9c6fe07e0d93bb84" src="https://ksr-qa-ugc.imgix.net/assets/033/915/794/8dca97fb0636aeb1a4a937025f369e7e_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894386&amp;auto=format&amp;frame=1&amp;q=92&amp;s=22f83142462421f48d7adca547d22367">\n </figure>\n\n </div>\n\n\n
    """
  }

  private var validImageWithCaptionAndLink: String {
    """
    <a href="https://producthype.co/most-powerful-crowdfunding-newsletter/?utm_source=ProductHype&amp;utm_medium=Banner&amp;utm_campaign=Homi" target="_blank" rel="noopener">
      <div class="template asset" contenteditable="false" data-alt-text="" data-caption=\"Viktor Pushkarev using lino-cutting to create the cover art.\" data-id="34488736">\n
        <figure>\n <img alt="" class="fit js-lazy-image" data-src="https://ksr-qa-ugc.imgix.net/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1628654686&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=061483d5e8fac13bd635b67e2ae8a258" src="https://ksr-qa-ugc.imgix.net/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1628654686&amp;auto=format&amp;frame=1&amp;q=92&amp;s=463cb21e97dd89bd564e6fc898ea6075">\n </figure>\n\n </div>\n </a>\n\n
    """
  }

  private var validExternalSource: String {
    """
    <div class=\"template oembed\" contenteditable=\"false\" data-href=\"https://www.youtube.com/watch?v=GcoaQ3LlqWI&amp;t=8s\">\n<iframe width=\"356\" height=\"200\" src=\"https://www.youtube.com/embed/GcoaQ3LlqWI?start=8&amp;feature=oembed&amp;wmode=transparent\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>\n\n</div>
    \n\n
    """
  }

  private var erroredStory: String {
    ""
  }
}
