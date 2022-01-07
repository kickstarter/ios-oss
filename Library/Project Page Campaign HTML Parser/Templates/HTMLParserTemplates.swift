import Foundation

public enum HTMLParserTemplates {
  case validFullStory
  case validNonGIFImage
  case validGIFImage
  case validImageWithCaption
  case validImageWithCaptionAndLink
  case validVideo
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
    case .errored:
      return self.erroredStory
    default:
      return self.fullStory
    }
  }

  // MARK: Private Properties

  private var validImageWithCaptionAndLink: String {
    """
    <a href="https://producthype.co/most-powerful-crowdfunding-newsletter/?utm_source=ProductHype&amp;utm_medium=Banner&amp;utm_campaign=Homi" target="_blank" rel="noopener">
      <div class="template asset" contenteditable="false" data-alt-text="" data-caption=\"Viktor Pushkarev using lino-cutting to create the cover art.\" data-id="34488736">\n
        <figure>\n <img alt="" class="fit js-lazy-image" data-src="https://ksr-qa-ugc.imgix.net/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1628654686&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=061483d5e8fac13bd635b67e2ae8a258" src="https://ksr-qa-ugc.imgix.net/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1628654686&amp;auto=format&amp;frame=1&amp;q=92&amp;s=463cb21e97dd89bd564e6fc898ea6075">\n </figure>\n\n </div>\n </a>\n\n
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

  private var fullStory: String {
    """
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33981078">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/981/078/6a3036d55ab3c3d6f271ab0b5c532912_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624426643&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=aaa772a0ea57e4697c14311f1f2e0086">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915738">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/738/8b2becfb496e629aa012c34d23ce0f91_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894014&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=45a158b415e3031e568e6d903fa25258">\n </figure>\n\n </div>\n\n\n
    <p>Dressing in multilayers is how we keep ourselves warm—a thin base layer, a sweater, and a jacket, and we’re all good for the crisp and chill. However, when we enter an indoor space or sweat during exercise, we started to feel too warm, damp, and stuffy. When this happens, it is not so convenient to take the long underwear off in public or to move around with heavy outerwear in hand. </p>\n
    <p> <strong>We're here to make things easier. </strong> </p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33921340">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/921/340/27ce5c78284d19efefc67e26d59f0107_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623940547&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=55b40a2c8ebd8a10a46f06d2ac4e7018">\n </figure>\n\n </div>\n\n\n
    <p>We created BASE+ with the vision to revolutionize the concept of everyday wear and layering clothing. Unlike conventional thermals, BASE+ can cut down your apparel, keeping you comfy and active from fall to spring, from outdoor to indoor.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915757">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/757/d6adb5d9b8c989780c40fecb29aa3839_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894126&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=160a2f9e7ff75eb0926902065f6162cb">\n </figure>\n\n </div>\n\n\n
    <p>We took inspiration from the concept of mountaineering layering and assembled the key elements—moisture wicking, heat regualting, and outer protection—into one design, using the double layer structure to leverage the strength of each textile.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="34106907">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/034/106/907/73feea7e40af7069fc6c71ea4bac4306_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1625470004&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=ec4000b2fc18e91988fe2cc9d9aecc9e">\n </figure>\n\n </div>\n\n\n
    <p>HOMI BASE+’s double layer design integrates various features into one piece. The outer layer gives your body the basic protection against the outside world; the inner layer provides everything you want from next to skin clothing; the additional far infrared fabric used in highlighted areas helps improve blood circulation.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33981035">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/981/035/14d2c66540cbeb5da3ed24d893491180_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624426263&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=f297a3da00f031392eaf8a32d1ecd2a6">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915779">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/779/bc05c6e482669dd1a568c1c9a49e86a7_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894264&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=38fbf0d45b9260c5e5e5f6d738f93aee">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915784">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/784/5d5bccf0d4701f7ea608788c87d1066b_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894313&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=cdece1f428ae476a8bf8db824d78f006">\n </figure>\n\n </div>\n\n\n
    <h1 id="h:moisture-wicking-and" class="page-anchor">Moisture Wicking &amp; Breathable</h1>\n
    <p> <strong>Feel fresh and clean at all times</strong> </p>\n
    <p>Does your long underwear make you feel stifling and constrictive sometimes? Then try HOMI BASE+. The special fabric used for its inner layer has a similar fiber structure to Merino wool, which performs superbly in moisture wicking and breathability. </p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915800">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/800/f4d94616f6dcf1bedd65eaebcefb702f_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894453&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=22eb4e16601056c492d969254b60633d">\n </figure>\n\n </div>\n\n\n
    <p>Our fabric is excellent in dispersing and spreading the moisture out, transporting moisture away and activating evaporative cooling. So when your body releases moisture or perspiration, they will be transported away as vapors immediately, keeping you cool and dry.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915794">\n
      <figure>\n <img alt="" class="fit js-lazy-image" data-src="https://ksr-qa-ugc.imgix.net/assets/033/915/794/8dca97fb0636aeb1a4a937025f369e7e_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894386&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=cde086d146601f4d9c6fe07e0d93bb84" src="https://ksr-qa-ugc.imgix.net/assets/033/915/794/8dca97fb0636aeb1a4a937025f369e7e_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894386&amp;auto=format&amp;frame=1&amp;q=92&amp;s=22f83142462421f48d7adca547d22367">\n </figure>\n\n </div>\n\n\n
    <h1 id="h:thermal-insulating-a" class="page-anchor">Thermal Insulating &amp; Regulating</h1>\n
    <p> <strong>Retaining heat the professional way</strong> </p>\n
    <p>Our body temperature changes during and after we exercise, and usually we have to adjust ourselves to feel comfortable by constantly taking off or putting on clothes. <strong>Now, BASE+ is here to handle all the work with SUSTAIN THERMO TECH.</strong> </p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915809">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/809/51d366c207d3947a7ddcc35d39d2ec28_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894515&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=8b25bbb26bc6c639ba6c932197048622">\n </figure>\n\n </div>\n\n\n
    <p>Preventing the heat from escaping is the core of SUSTAIN THERMO TECH. In addition to the fine fibers that trap body heat, the double layer structure creates an in-shirt insulation space that retains the warm air, keeping you snug and flexible. </p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915812">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/812/9eb2a6703fa70344f16ea461a33e843b_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894548&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=0c11ec6d6c2d5a7d4608504dad84d76f">\n </figure>\n\n </div>\n\n\n
    <h1 id="h:hypoallergenic-and-s" class="page-anchor">Hypoallergenic &amp; Soft Texture</h1>\n
    <p> <strong>No pesky pilling after washing</strong> </p>\n
    <p>We make sure that the inner layer of BASE+ is smooth and sleek, touching your skin gently enough just like your favorite undershirt. The skin-friendly fabric is soft, stretchy, and doesn’t pill. It remains smooth after the wash, causing no itchy feelings.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915818">\n
      <figure>\n <img alt="" class="fit js-lazy-image" data-src="https://ksr-qa-ugc.imgix.net/assets/033/915/818/9e434e7ccc0e8e15cdaba5f6f88682fa_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894611&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=9b92ad48c6ef49df6b183e1c2a6a52b0" src="https://ksr-qa-ugc.imgix.net/assets/033/915/818/9e434e7ccc0e8e15cdaba5f6f88682fa_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894611&amp;auto=format&amp;frame=1&amp;q=92&amp;s=4c9f640df4a95ad4ea7eed0241e9013b">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915822">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/822/f85fa58ee7d0db6e6e7d8fc0d149d18a_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894637&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=a53bca71a6da14164512f45244b9f7b9">\n </figure>\n\n </div>\n\n\n
    <h1 id="h:taking-thermal-exper" class="page-anchor">Taking Thermal Experience to the Next Level</h1>\n
    <p>As shoulders and elbow joints get cold the fastest and heat up the slowest in our upper body, we add an additional far infrared layer to these parts to provide extra protection. It helps strengthen your overall circulation and relax tight shoulder muscles.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33981074">\n
      <figure>\n <img alt="" class="fit js-lazy-image" data-src="https://ksr-qa-ugc.imgix.net/assets/033/981/074/7569b8dfab30fef95a39992c6ec9c33f_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624426603&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=9c781101d034294b126c9f4b2d109d51" src="https://ksr-qa-ugc.imgix.net/assets/033/981/074/7569b8dfab30fef95a39992c6ec9c33f_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624426603&amp;auto=format&amp;frame=1&amp;q=92&amp;s=f33c3d689dcff92b793750333ef8ca96">\n </figure>\n\n </div>\n\n\n
    <p>The far infrared fabric can absorb, emit, and reflect far infrared rays from the human body. The ray can go through the skin to resonate and generate heat, which boosts blood flow and relieves muscle pain. </p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915831">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/831/b96fc5c81e9c6cd43e3162c2f1deb83e_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894754&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=d3a42d7375a01cbb24ceef72fa88ebcc">\n </figure>\n\n </div>\n\n\n
    <p>This additional fabric provides extra warmth, optimum thermal performance, and muscle relaxation without disturbing the other features provided by the base layer fabric.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33993858">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/993/858/6ff7fb614aa119d4edfc066d4e1a4766_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624520440&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=df728040fea3a255dc716818f3bebbcf">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915845">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/845/12f684ccf1e3e6ece913f4c3b08bdedd_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894837&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=b533fd19e06d1aa641831cf6576a77f1">\n </figure>\n\n </div>\n\n\n
    <h1 id="h:antimicrobial-and-an" class="page-anchor">Antimicrobial &amp; Anti-Odor</h1>\n
    <p> <strong>Silver Nano fights against the unpleasant</strong> </p>\n
    <p>The excellent wicking ability of the base layer keeps the fabric dry, which already stops the odor-causing factors from thriving. In addition to that, we apply the Silver Nano clothing technology to the outer fabric.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915849">\n
      <figure>\n <img alt="" class="fit js-lazy-image" data-src="https://ksr-qa-ugc.imgix.net/assets/033/915/849/3be64b2d28a4734e45d0b57269b19dde_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894875&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=b8a1b7dc354f49d076fc1506793de358" src="https://ksr-qa-ugc.imgix.net/assets/033/915/849/3be64b2d28a4734e45d0b57269b19dde_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894875&amp;auto=format&amp;frame=1&amp;q=92&amp;s=9cf000a930775a90bb2604b773a7ec91">\n </figure>\n\n </div>\n\n\n
    <p>Silver nanoparticles reduce the factors that cause undesirable smells by penetrating their cell wall. With this antimicrobial shield, you can walk around feeling jaunty and clean.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915855">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/855/9ee55a25c9e23edd6b479bc5e1ad6ec6_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623894917&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=79a0bc461c3cf563ab3006647f3054bb">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33993872">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/993/872/e04437235f0a8f96a43a8b97ab302f1d_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624520637&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=9112e6435a2721ba2b28130db1957260">\n </figure>\n\n </div>\n\n\n
    <h1 id="h:wind-and-sun-resista" class="page-anchor">Wind &amp; Sun Resistant</h1>\n
    <p> <strong>Fewer worries on the road</strong> </p>\n
    <p>No matter if you are biking in the city, running in the evening, or hiking on a sunny day, BASE+ protects your skin from chills and ultraviolet rays. The double layer structure not only provides UPF 50+ sun protection but also blocks mild winds. </p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33981082">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/981/082/1c9ecad9f0192df9eaea33a7eeb709cb_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624426684&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=8d2d3aa6030c655d3a116ff9839ad441">\n </figure>\n\n </div>\n\n\n
    <h1 id="h:quick-drying-and-wri" class="page-anchor">Quick Drying &amp; Wrinkle Free</h1>\n
    <p> <strong>Your new favorite daily wear</strong> </p>\n
    <p>The special diamond lattice knitted fabric is quick drying, wrinkle free, and won’t shrink or stretch after washing. It will always be sleek and ready for you to put on and head out.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915875">\n
      <figure>\n <img alt="" class="fit js-lazy-image" data-src="https://ksr-qa-ugc.imgix.net/assets/033/915/875/7a6b93c17c4113ebb9734219aef45bf0_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895108&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=0c9e2055e4c9f33ea5291544202659a2" src="https://ksr-qa-ugc.imgix.net/assets/033/915/875/7a6b93c17c4113ebb9734219aef45bf0_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895108&amp;auto=format&amp;frame=1&amp;q=92&amp;s=8918b457b6d6cb2b58266ac4fb36332d">\n </figure>\n\n </div>\n\n\n
    <p>BASE+ is a T-shirt that you can wear comfortably from day to night, from fall to spring. And it is durable and easy to take care of! </p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915872">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/872/ccad14213de847a24ced3b85e5a467ba_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895081&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=c19dd7a8e2bc3066826404cab53ddebd">\n </figure>\n\n </div>\n\n\n
    <h1 id="h:zippered-sleeve-pock" class="page-anchor">Zippered Sleeve Pocket</h1>\n
    <p> <strong>Keep your valuable necessities at hand</strong> </p>\n
    <p>BASE+ brings you not only comfort but also convenience. Without disturbing the shirt's silhouette, we added a hidden pocket with YKK zippers to the left sleeve. This tiny pocket is ideal for your essential items, such as cards, wireless earbuds, or bills. It can be very handy when you are on the move!</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915884">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/884/e35ce32bf0b60d23e1aaf21f3852eaa5_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895167&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=861089dd1680d7ba33affa216f653928">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33917474">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/917/474/cfba702ffacd76c4247299794e56a3b6_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623913466&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=ddb660446208e9f5264aea84dbc4dc10">\n </figure>\n\n </div>\n\n\n
    <h1 id="h:reflective-stripes" class="page-anchor">Reflective Stripes</h1>\n
    <p> <strong>Functional adornment for your safety</strong> </p>\n
    <p>When jogging or biking during nighttime, we often need to pay close attention to vehicles coming from our side. To improve the wearers’ safety, we added reflective stripes to the cuff. The reflection will move along with your swinging arms to increase your visibility from various angles.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915890">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/890/c5039a58e02f03620fad1517795e088a_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895206&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=c7e7eac503874a0def71cde36e8e8b6a">\n </figure>\n\n </div>\n\n\n
    <h1 id="h:365cap-triple-layer" class="page-anchor">365CAP: Triple Layer Cap to Protect Your Head All Year Round</h1>\n
    <p>Do you also feel stuffy and sweaty when wearing a hat for a long time? As our head is what we need to protect first when confronting the freezing wind or burning sun, we created a hat that gives you optimum comfort and protection in all kinds of weather conditions.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915897">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/897/cb38208a4e79e202269ae186ded7bf12_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895261&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=c408411da385acbe87dcf187e8936301">\n </figure>\n\n </div>\n\n\n
    <p>Similar to the design concept of BASE+, 365CAP uses the triple layer structure to insulate the heat and regulate your head temperature, keeping your head sung in winter and cool in summer. This is a hat that you can wear all year round!</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915911">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/911/5c61e3d699b317dcfe16516379a3d924_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895378&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=2a57144317aa33cf89b4378eaadf5b2f">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33993682">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/993/682/66db08dbab1b517a83cf3bb00357d86b_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624518371&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=63e248165825b0e22e74a660718bf902">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33981087">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/981/087/1704e640a1423def87d2c437c3877f43_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624426720&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=a0a75eaa2040c8e9a250009d62815acd">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915922">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/922/5d477a5716a88ccef4d943c127f64f51_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895486&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=39bc2a5342fcd73546c900a468276c76">\n </figure>\n\n </div>\n\n\n
    <p>We are here to help you keep life as simple as possible. Designed with the multilayer concept, HOMI BASE+ and 365CAP provide excellent features that help you wear smarter and say goodbye to stuffy garment. While BASE+ can be worn all day in fall, winter, and spring, 365CAP can accompany you in all seasons. </p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33921080">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/921/080/e8cd27b2aa64e68ef7642e63e8b2bf77_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623939337&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=eda9520d196117b7e545ed7dc2957403">\n </figure>\n\n </div>\n\n\n
    <p>Versatile in style, these two everyday wear can accompany you when you are moving around in the city, venture into the great outdoors, or even chilling at home. Designed for urbanites and adventurers, HOMI BASE+ and 365CAP keep you sharp, fresh, and active at the most comfortable temperature all the time!</p>\n
    <br>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33994181">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/994/181/faf751fa1a10bfae359e9b7c6c5c6893_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624524107&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=2c03d70f0edf73cdec57e508b48f9f73">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915941">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/941/9da4129324577f5759d772ac58c197c2_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895651&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=59831f3f6aecc740709e74381bb7d19c">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915942">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/942/a6f6a66e8341e90ecb1ca0ad93d67579_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895670&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=b93a01fd6e61fef6945ff2b6bdec9d32">\n </figure>\n\n </div>\n\n\n
    <p>HOMI BASE+ and 365CAP accompanied award winning traceur Yoann Leroux to overcome all the complex environments—from the ground to the top, and from the labyrinthine backstreets in Paris to the great outdoors. </p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915946">\n
      <figure>\n <img alt="" class="fit js-lazy-image" data-src="https://ksr-qa-ugc.imgix.net/assets/033/915/946/916e2d20a31af55dc25d352123f0df97_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895725&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=6fe14fce0d22255eba30fff80ff681f4" src="https://ksr-qa-ugc.imgix.net/assets/033/915/946/916e2d20a31af55dc25d352123f0df97_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895725&amp;auto=format&amp;frame=1&amp;q=92&amp;s=00b87f6e6be1b29a245765648537d49e">\n </figure>\n\n </div>\n\n\n
    <p>During his parkour and freerunning sessions, the highly breathable, moisture wicking, and heat regulating features of BASE+ continually kept his body at the most comfortable state, and the sun and wind resistant feature saved him from wearing another extra layer of cloth. Plus the head protection provided by 365CAP, HOMI’s optimized activewear helped Yoann stay comfy, light, and sharp in his daily training and extreme sports activities.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915957">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/957/f4c661332ae5c02b0e4c8a071ed7acb3_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895828&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=7b94896582480ede9988fd23be3f6f28">\n </figure>\n\n </div>\n\n\n
    <h1 id="h:base" class="page-anchor">BASE+ </h1>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915970">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/970/40d5accca5c86e68cbb37321a4f45533_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623895890&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=a819b2f57bef324f7e0306b86629c23f">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33994089">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/994/089/c65bbd29ef9eacbb1d0471faa84f2e0d_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624523229&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=c12835d4ed93dddfb2c87354fd95b9d3">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="34109358">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/034/109/358/7bbc3a2808e4fc0968b9a2109c5c176a_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1625491586&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=7e2529197ced85bfa06986fb7fa918e9">\n </figure>\n\n </div>\n\n\n
    <ul>\n
      <li>Unisex design with a hidden pocket on the left sleeve.</li>\n
      <li> <strong>For regular fit, it’s recommended to choose one size bigger than what you normally wear.</strong> If you prefer slim fit, you may choose the size you usually wear. </li>\n
      <li>Laundry Care: Machine Washable / Dry Normal Low Heat / Do Not Bleach</li>\n </ul>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915988">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/988/f107eb0d915833fe12906c893ac32d61_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623896018&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=8b363eeaef2f079bedf33b1967071137">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33915995">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/915/995/08199d61b8baa9e00498982811a17121_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623896082&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=cbabedd2a49069cacf867fec1d88652a">\n </figure>\n\n </div>\n\n\n
    <h1 id="h:365cap" class="page-anchor">365CAP </h1>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33916009">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/916/009/80a578a9a8ab3c7534e06c68f405a3f7_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623896217&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=06a9fe250734d96289cd7fe0076efd25">\n </figure>\n\n </div>\n\n\n
    <ul>\n
      <li>Unisize design with adjustable backstrap</li>\n
      <li>Laundry care: Machine washable / Do Not Dry / Do Not Bleach</li>\n </ul>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33917075">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/917/075/5fe6a7a707742ab8dab95d6a9cf2e453_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623908981&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=5a9430a43285b2f665fd385b753cf087">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33981163">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/981/163/0f6fb9976a0d950b3286a09613fc5ad5_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624427642&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=49c354b0c62b7449a1dfce55ef109635">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="34577332">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/034/577/332/2fbf52d410c2aeead53e6792a65372e5_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1629378264&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=a7635c216d8f427eb8d985976266fbb8">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33981166">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/981/166/b9d4d2cb0f15f1e9b08fa93d4095150f_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624427676&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=bef6e7bc8db6a6410df8d178833654ab">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33981168">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/981/168/85060cfb20bb3e681b62d6fb267892f7_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624427688&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=3babbf225f607715ac547a8253cc6741">\n </figure>\n\n </div>\n\n\n
    <br>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33917454">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/917/454/50caa9624330af01d3d1b82e92f8b897_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623913333&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=6e701496740852dda41b9800c34ea9a9">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33917457">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/917/457/8258cbb6098a94664c89ced19ef9a5e5_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623913352&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=a3291b66c79de1643acd742f07748738">\n </figure>\n\n </div>\n\n\n
    <p> <strong>BASE+</strong> </p>\n
    <ul>\n
      <li>Base Layer - SUSTAIN THERMO TECH polyester (OEKO-TEX® Certificate)</li>\n
      <li>Far Infrared Fabric (Far Infrared Emission Value Report)</li>\n
      <li>Soft Shell - Silver Nano polyester (Antibacterial Test Report)
        <br>\n </li>\n </ul>\n
    <p> <strong>365CAP</strong> </p>\n
    <ul>\n
      <li>Outer Layer - Water Repellent Nylon (OEKO-TEX® Certificate, bluesign® Certificate, Water Repellent Test Report)</li>\n
      <li>Middle Layer - SUSTAIN THERMO TECH polyester (OEKO-TEX® Certificate)</li>\n
      <li>Inner Layer - Silver Nano cooling polyester (UPF Protection Test Report, Antibacterial Test Report, Heat Insulation Test Report)</li>\n </ul>\n
    <p> <a href="https://drive.google.com/drive/folders/1qqeiaN1IdvMYfcw1ejoB_6TcgkB3ChR-?usp=sharing" target="_blank" rel="noopener">Click here</a> to view all the test reports. </p>\n
    <br>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33917459">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/917/459/dc027aeb4ede8ad81f950af0b412e353_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623913370&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=11d7968f916bad97bc4357fc9b950629">\n </figure>\n\n </div>\n\n\n
    <p>After creating a series of optimized thermal outerwear, we wanted to focus on next-to-skin apparel. We were picturing a design that can be an alternative to multilayer clothing and can be worn every day on various occasions. To bring this idea to life, we brainstormed on all the features to put on one T-shirt and researched the fabrics and structure. From selecting the fabrics to testing, producing the prototypes, and finalizing the design, we paid attention to every detail and aimed to generate the best outcome. </p>\n
    <p>Our products are 100% made in Taiwan. We use high quality materials and work with established local manufacturers. We also produce the products according to bluesign® and OEKO-TEX® standards, making sure that our production is sustainable and energy-efficient. After all the planning, testing, and prototypes, we are now proud to present our design and are ready for mass production.</p>\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33917464">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/917/464/597c9fab3173b6e50cac210ca5034b2d_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1623913407&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=1b107b1b6ef74f7b6163238b2be804f2">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33981048">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/981/048/5dc60ef6c6a4cb01391534617de96398_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624426381&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=4e567fd1d40e008cd8e04eae203f7956">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33981052">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/981/052/000cf36e292969b8d2c520b4ad602f25_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624426394&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=34db8be0cdc332c11b04714ca3fb383d">\n </figure>\n\n </div>\n\n\n
    <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33981056">\n
      <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/981/056/1071f72ca5f0841d7ac608053f865c57_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624426414&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=9d199469de63e1aee57124896e9a0679">\n </figure>\n\n </div>\n\n\n
    <p>Founded in 2013 and based in Taiwan, HOMI CREATIONS combines technology and modern aesthetics to create products that align with the ideal lifestyle we envision—smart, stylish, and minimal.</p>\n
    <p>For our SUSTAIN collection featuring thermal apparel, we leverage the advanced technologies and resources we have in Taiwan to create professional, functional clothes that are in style. Our previous projects include <a href="https://www.kickstarter.com/projects/sustainsportcr/sustain-sport-heated-scarf-the-warmest-scarf-in-th?ref=profile_created" target="_blank" rel="noopener">HOMI Heated Scarf</a>, <a href="https://www.kickstarter.com/projects/sustainsportcr/homi-the-japanese-carbon-fiber-adventure-jacket?ref=profile_created" target="_blank" rel="noopener">HOMI Jacket</a>, and <a href="https://www.kickstarter.com/projects/sustainsportcr/homi-vest-click-to-heat-for-all-things-adventure?ref=profile_created" target="_blank" rel="noopener">HOMI Vest</a>. </p>\n
    <br>\n
    <h1 id="h:press-kit-youtube" class="page-anchor">
      <a href="https://drive.google.com/drive/folders/1sg48taAL4hUleIJUEDCsXerRI0cBzwia?usp=sharing" target="_blank" rel="noopener">Press Kit</a> | <a href="https://www.youtube.com/watch?v=0PQo9q0yBKI" target="_blank" rel="noopener">YouTube</a>
    </h1>\n\n
    <a href="https://homi-base-double-layer-thermal.kickbooster.me/boost" target="_blank" rel="noopener">
      <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="34042781">\n
        <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/034/042/781/61c0e86bc7e182075d34707bfe3d23f4_original.png?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624951288&amp;auto=format&amp;gif-q=50&amp;lossless=true&amp;s=47770b1d67c3d57f95f7e28550440065">\n </figure>\n\n </div>\n </a>\n\n
    <a href="https://producthype.co/most-powerful-crowdfunding-newsletter/?utm_source=ProductHype&amp;utm_medium=Banner&amp;utm_campaign=Homi" target="_blank" rel="noopener">
      <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="34488736">\n
        <figure>\n <img alt="" class="fit js-lazy-image" data-src="https://ksr-qa-ugc.imgix.net/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1628654686&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=061483d5e8fac13bd635b67e2ae8a258" src="https://ksr-qa-ugc.imgix.net/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1628654686&amp;auto=format&amp;frame=1&amp;q=92&amp;s=463cb21e97dd89bd564e6fc898ea6075">\n </figure>\n\n </div>\n </a>\n\n
    <a href="https://www.twowgo.com/" target="_blank" rel="noopener">
      <div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="33967472">\n
        <figure>\n <img alt="" class="fit" src="https://ksr-qa-ugc.imgix.net/assets/033/967/472/b67d04bda2e22d2a1bd41603abeb0d64_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1624339680&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=4ce648d1f699090bc364d6c8f0060d58">\n </figure>\n\n </div>\n </a>
    """
  }

  private var erroredStory: String {
    ""
  }
}
