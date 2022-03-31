import Foundation

public enum HTMLParserTemplates {
  case validNonGIFImage
  case validGIFImage
  case validImageWithCaption
  case validImageWithCaptionAndLink
  case validAudio
  case validVideo
  case validVideoHigh
  case validHiddenVideo
  case validIFrame
  case validIFrameWithEmbeddedSource
  case validHeaderText
  case validParagraphTextWithStyles
  case validParagraphTextWithLinksAndStyles
  case validListWithNestedLinks
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
    case .validAudio:
      return self.validAudio
    case .validVideo:
      return self.validVideo
    case .validHiddenVideo:
      return self.validHiddenVideo
    case .validVideoHigh:
      return self.validVideoHigh
    case .validIFrame:
      return self.validExternalSource
    case .validIFrameWithEmbeddedSource:
      return self.validEmbeddedExternalSource
    case .validHeaderText:
      return self.validHeaderText
    case .validParagraphTextWithLinksAndStyles:
      return self.validParagraphTextWithLinksAndStyles
    case .validParagraphTextWithStyles:
      return self.validParagraphTextWithStyles
    case .validListWithNestedLinks:
      return self.validListWithNestLinks
    default:
      return self.erroredStory
    }
  }

  // MARK: Private Properties

  private var validListWithNestLinks: String {
    """
    <ul><li><a href="https://www.meneame.net/" target=\\\"_blank\\\" rel=\\\"noopener\\\"><em><strong>Meneane</strong></em></a><a href="https://www.meneame.net/" target=\\\"_blank\\\" rel=\\\"noopener\\\">Another URL in this list</a> and some text</li></ul>
    """
  }

  private var validParagraphTextWithStyles: String {
    """
    <p>This is a paragraph about bacon – Bacon ipsum dolor amet ham chuck short ribs, shank flank cupim frankfurter chicken. Sausage frankfurter chicken ball tip, drumstick brisket pork chop turkey. Andouille bacon ham hock, pastrami sausage pork chop corned beef frankfurter shank chislic short ribs. Hamburger bacon pork belly, drumstick pork chop capicola kielbasa pancetta buffalo pork. Meatball doner pancetta ham ribeye. Picanha ham venison ribeye short loin beef, tail pig ball tip buffalo salami shoulder ground round chicken. Porchetta capicola drumstick, tongue fatback pork pork belly cow sirloin ham hock flank venison beef ribs.<strong><em>Bold word Italic word</em></strong></p>
    """
  }

  private var validParagraphTextWithLinksAndStyles: String {
    """
      <p><a href="http://record.pt/" target=\"_blank\" rel=\"noopener\"><strong>What about a bold link to that same newspaper website?</strong></a></p>
      \n
      <p><a href="http://recordblabla.pt/" target=\"_blank\" rel=\"noopener\"><em>Maybe an italic one?</em></a></p>
    """
  }

  private var validHeaderText: String {
    """
    <h1 id=\"h:please-participate-i\" class=\"page-anchor\">Please participate in helping me finish my film! Just pick a level in the right hand column and click to donate — it only takes a minute.</h1>
    \n<br>\n
    """
  }

  private var validAudio: String {
    """
    \n
    <div class="template asset" contenteditable="false" data-id="2236466">
    <figure>
    <audio controls="controls" preload="none"><source src="https://d15chbti7ht62o.cloudfront.net/assets/002/236/466/f17de99e2a9e76a4954418c16d963f9b_mp3.mp3?2015" type="audio/mp3"><source src="https://d15chbti7ht62o.cloudfront.net/assets/002/236/466/f17de99e2a9e76a4954418c16d963f9b_aac.aac?2015" type="audio/aac"><source src="https://d15chbti7ht62o.cloudfront.net/assets/002/236/466/f17de99e2a9e76a4954418c16d963f9b_ogg.ogg?2015" type="audio/ogg"><source src="https://d15chbti7ht62o.cloudfront.net/assets/002/236/466/f17de99e2a9e76a4954418c16d963f9b_webm.webm?2015" type="audio/webm"></audio>
    </figure>
    \n
    """
  }

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

  private var validHiddenVideo: String {
    """
      <div class=\"template asset\" contenteditable=\"false\" data-id=\"35786501\">
         \n
         <figure class=\"page-anchor\" id=\"asset-35786501\">
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
      </figure>
      \n
    </div>
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

  private var validEmbeddedExternalSource: String {
    """
    <div class=\"template oembed\" contenteditable=\"false\" data-href=\"https://www.youtube.com/watch?v=GcoaQ3LlqWI&amp;t=8s\">\n<iframe width=\"356\" height=\"400\" src=\"https://cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fwww.tiktok.com%2Fembed%2Fv2%2F7056148230324653359&amp;display_name=tiktok&amp;url=https%3A%2F%2Fwww.tiktok.com%2F%40mister.larrie%2Fvideo%2F7056148230324653359&amp;image=https%3A%2F%2Fp16-sign.tiktokcdn-us.com%2Ftos-useast5-p-0068-tx%2Fc2fb40eb0e5d416b8b4e8e6cc9da6877_1642887536%7Etplv-tiktok-play.jpeg%3Fx-expires%3D1646848800%26x-signature%3D%252BVY%252Bg5hMnnAHb%252B24XUDHSPRNFUQ%253D&amp;key=d3cf44f504524614bc66d6797c5dd848&amp;type=text%2Fhtml&amp;schema=tiktok" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>\n\n</div>
    \n\n
    """
  }

  private var erroredStory: String {
    ""
  }
}
