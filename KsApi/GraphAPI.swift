// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

/// GraphAPI namespace
public enum GraphAPI {
  /// Various backing states.
  public enum BackingState: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    case preauth
    case pledged
    case canceled
    case collected
    case errored
    case authenticationRequired
    case dropped
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "preauth": self = .preauth
        case "pledged": self = .pledged
        case "canceled": self = .canceled
        case "collected": self = .collected
        case "errored": self = .errored
        case "authentication_required": self = .authenticationRequired
        case "dropped": self = .dropped
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .preauth: return "preauth"
        case .pledged: return "pledged"
        case .canceled: return "canceled"
        case .collected: return "collected"
        case .errored: return "errored"
        case .authenticationRequired: return "authentication_required"
        case .dropped: return "dropped"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: BackingState, rhs: BackingState) -> Bool {
      switch (lhs, rhs) {
        case (.preauth, .preauth): return true
        case (.pledged, .pledged): return true
        case (.canceled, .canceled): return true
        case (.collected, .collected): return true
        case (.errored, .errored): return true
        case (.authenticationRequired, .authenticationRequired): return true
        case (.dropped, .dropped): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [BackingState] {
      return [
        .preauth,
        .pledged,
        .canceled,
        .collected,
        .errored,
        .authenticationRequired,
        .dropped,
      ]
    }
  }

  /// All available comment author badges
  public enum CommentBadge: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    /// Indicates the author is a creator
    case creator
    /// Indicates the author is a collaborator
    case collaborator
    /// Indicates the author is a superbacker
    case superbacker
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "creator": self = .creator
        case "collaborator": self = .collaborator
        case "superbacker": self = .superbacker
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .creator: return "creator"
        case .collaborator: return "collaborator"
        case .superbacker: return "superbacker"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: CommentBadge, rhs: CommentBadge) -> Bool {
      switch (lhs, rhs) {
        case (.creator, .creator): return true
        case (.collaborator, .collaborator): return true
        case (.superbacker, .superbacker): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [CommentBadge] {
      return [
        .creator,
        .collaborator,
        .superbacker,
      ]
    }
  }

  /// Two letter ISO code for a country.
  public enum CountryCode: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    case ad
    case ae
    case af
    case ag
    case ai
    case al
    case am
    case an
    case ao
    case aq
    case ar
    case `as`
    case at
    case au
    case aw
    case ax
    case az
    case ba
    case bb
    case bd
    case be
    case bf
    case bg
    case bh
    case bi
    case bj
    case bl
    case bm
    case bn
    case bo
    case bq
    case br
    case bs
    case bt
    case bv
    case bw
    case by
    case bz
    case ca
    case cc
    case cd
    case cf
    case cg
    case ch
    case ci
    case ck
    case cl
    case cm
    case cn
    case co
    case cr
    case cu
    case cw
    case cv
    case cx
    case cy
    case cz
    case de
    case dj
    case dk
    case dm
    case `do`
    case dz
    case ec
    case ee
    case eg
    case eh
    case er
    case es
    case et
    case fi
    case fj
    case fk
    case fm
    case fo
    case fr
    case ga
    case gb
    case gd
    case ge
    case gf
    case gg
    case gh
    case gi
    case gl
    case gm
    case gn
    case gp
    case gq
    case gr
    case gs
    case gt
    case gu
    case gw
    case gy
    case hk
    case hm
    case hn
    case hr
    case ht
    case hu
    case id
    case ie
    case il
    case im
    case `in`
    case io
    case iq
    case ir
    case `is`
    case it
    case je
    case jm
    case jo
    case jp
    case ke
    case kg
    case kh
    case ki
    case km
    case kn
    case kp
    case kr
    case kw
    case ky
    case kz
    case la
    case lb
    case lc
    case li
    case lk
    case lr
    case ls
    case lt
    case lu
    case lv
    case ly
    case ma
    case mc
    case md
    case me
    case mf
    case mg
    case mh
    case mk
    case ml
    case mm
    case mn
    case mo
    case mp
    case mq
    case mr
    case ms
    case mt
    case mu
    case mv
    case mw
    case mx
    case my
    case mz
    case na
    case nc
    case ne
    case nf
    case ng
    case ni
    case nl
    case no
    case np
    case nr
    case nu
    case nz
    case om
    case pa
    case pe
    case pf
    case pg
    case ph
    case pk
    case pl
    case pm
    case pn
    case pr
    case ps
    case pt
    case pw
    case py
    case qa
    case re
    case ro
    case rs
    case ru
    case rw
    case sa
    case sb
    case sc
    case sd
    case se
    case sg
    case sh
    case si
    case sj
    case sk
    case sl
    case sm
    case sn
    case so
    case sr
    case ss
    case st
    case sv
    case sx
    case sy
    case sz
    case tc
    case td
    case tf
    case tg
    case th
    case tj
    case tk
    case tl
    case tm
    case tn
    case to
    case tr
    case tt
    case tv
    case tw
    case tz
    case ua
    case ug
    case um
    case us
    case uy
    case uz
    case va
    case vc
    case ve
    case vg
    case vi
    case vn
    case vu
    case wf
    case ws
    case xk
    case ye
    case yt
    case za
    case zm
    case zw
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "AD": self = .ad
        case "AE": self = .ae
        case "AF": self = .af
        case "AG": self = .ag
        case "AI": self = .ai
        case "AL": self = .al
        case "AM": self = .am
        case "AN": self = .an
        case "AO": self = .ao
        case "AQ": self = .aq
        case "AR": self = .ar
        case "AS": self = .as
        case "AT": self = .at
        case "AU": self = .au
        case "AW": self = .aw
        case "AX": self = .ax
        case "AZ": self = .az
        case "BA": self = .ba
        case "BB": self = .bb
        case "BD": self = .bd
        case "BE": self = .be
        case "BF": self = .bf
        case "BG": self = .bg
        case "BH": self = .bh
        case "BI": self = .bi
        case "BJ": self = .bj
        case "BL": self = .bl
        case "BM": self = .bm
        case "BN": self = .bn
        case "BO": self = .bo
        case "BQ": self = .bq
        case "BR": self = .br
        case "BS": self = .bs
        case "BT": self = .bt
        case "BV": self = .bv
        case "BW": self = .bw
        case "BY": self = .by
        case "BZ": self = .bz
        case "CA": self = .ca
        case "CC": self = .cc
        case "CD": self = .cd
        case "CF": self = .cf
        case "CG": self = .cg
        case "CH": self = .ch
        case "CI": self = .ci
        case "CK": self = .ck
        case "CL": self = .cl
        case "CM": self = .cm
        case "CN": self = .cn
        case "CO": self = .co
        case "CR": self = .cr
        case "CU": self = .cu
        case "CW": self = .cw
        case "CV": self = .cv
        case "CX": self = .cx
        case "CY": self = .cy
        case "CZ": self = .cz
        case "DE": self = .de
        case "DJ": self = .dj
        case "DK": self = .dk
        case "DM": self = .dm
        case "DO": self = .do
        case "DZ": self = .dz
        case "EC": self = .ec
        case "EE": self = .ee
        case "EG": self = .eg
        case "EH": self = .eh
        case "ER": self = .er
        case "ES": self = .es
        case "ET": self = .et
        case "FI": self = .fi
        case "FJ": self = .fj
        case "FK": self = .fk
        case "FM": self = .fm
        case "FO": self = .fo
        case "FR": self = .fr
        case "GA": self = .ga
        case "GB": self = .gb
        case "GD": self = .gd
        case "GE": self = .ge
        case "GF": self = .gf
        case "GG": self = .gg
        case "GH": self = .gh
        case "GI": self = .gi
        case "GL": self = .gl
        case "GM": self = .gm
        case "GN": self = .gn
        case "GP": self = .gp
        case "GQ": self = .gq
        case "GR": self = .gr
        case "GS": self = .gs
        case "GT": self = .gt
        case "GU": self = .gu
        case "GW": self = .gw
        case "GY": self = .gy
        case "HK": self = .hk
        case "HM": self = .hm
        case "HN": self = .hn
        case "HR": self = .hr
        case "HT": self = .ht
        case "HU": self = .hu
        case "ID": self = .id
        case "IE": self = .ie
        case "IL": self = .il
        case "IM": self = .im
        case "IN": self = .in
        case "IO": self = .io
        case "IQ": self = .iq
        case "IR": self = .ir
        case "IS": self = .is
        case "IT": self = .it
        case "JE": self = .je
        case "JM": self = .jm
        case "JO": self = .jo
        case "JP": self = .jp
        case "KE": self = .ke
        case "KG": self = .kg
        case "KH": self = .kh
        case "KI": self = .ki
        case "KM": self = .km
        case "KN": self = .kn
        case "KP": self = .kp
        case "KR": self = .kr
        case "KW": self = .kw
        case "KY": self = .ky
        case "KZ": self = .kz
        case "LA": self = .la
        case "LB": self = .lb
        case "LC": self = .lc
        case "LI": self = .li
        case "LK": self = .lk
        case "LR": self = .lr
        case "LS": self = .ls
        case "LT": self = .lt
        case "LU": self = .lu
        case "LV": self = .lv
        case "LY": self = .ly
        case "MA": self = .ma
        case "MC": self = .mc
        case "MD": self = .md
        case "ME": self = .me
        case "MF": self = .mf
        case "MG": self = .mg
        case "MH": self = .mh
        case "MK": self = .mk
        case "ML": self = .ml
        case "MM": self = .mm
        case "MN": self = .mn
        case "MO": self = .mo
        case "MP": self = .mp
        case "MQ": self = .mq
        case "MR": self = .mr
        case "MS": self = .ms
        case "MT": self = .mt
        case "MU": self = .mu
        case "MV": self = .mv
        case "MW": self = .mw
        case "MX": self = .mx
        case "MY": self = .my
        case "MZ": self = .mz
        case "NA": self = .na
        case "NC": self = .nc
        case "NE": self = .ne
        case "NF": self = .nf
        case "NG": self = .ng
        case "NI": self = .ni
        case "NL": self = .nl
        case "NO": self = .no
        case "NP": self = .np
        case "NR": self = .nr
        case "NU": self = .nu
        case "NZ": self = .nz
        case "OM": self = .om
        case "PA": self = .pa
        case "PE": self = .pe
        case "PF": self = .pf
        case "PG": self = .pg
        case "PH": self = .ph
        case "PK": self = .pk
        case "PL": self = .pl
        case "PM": self = .pm
        case "PN": self = .pn
        case "PR": self = .pr
        case "PS": self = .ps
        case "PT": self = .pt
        case "PW": self = .pw
        case "PY": self = .py
        case "QA": self = .qa
        case "RE": self = .re
        case "RO": self = .ro
        case "RS": self = .rs
        case "RU": self = .ru
        case "RW": self = .rw
        case "SA": self = .sa
        case "SB": self = .sb
        case "SC": self = .sc
        case "SD": self = .sd
        case "SE": self = .se
        case "SG": self = .sg
        case "SH": self = .sh
        case "SI": self = .si
        case "SJ": self = .sj
        case "SK": self = .sk
        case "SL": self = .sl
        case "SM": self = .sm
        case "SN": self = .sn
        case "SO": self = .so
        case "SR": self = .sr
        case "SS": self = .ss
        case "ST": self = .st
        case "SV": self = .sv
        case "SX": self = .sx
        case "SY": self = .sy
        case "SZ": self = .sz
        case "TC": self = .tc
        case "TD": self = .td
        case "TF": self = .tf
        case "TG": self = .tg
        case "TH": self = .th
        case "TJ": self = .tj
        case "TK": self = .tk
        case "TL": self = .tl
        case "TM": self = .tm
        case "TN": self = .tn
        case "TO": self = .to
        case "TR": self = .tr
        case "TT": self = .tt
        case "TV": self = .tv
        case "TW": self = .tw
        case "TZ": self = .tz
        case "UA": self = .ua
        case "UG": self = .ug
        case "UM": self = .um
        case "US": self = .us
        case "UY": self = .uy
        case "UZ": self = .uz
        case "VA": self = .va
        case "VC": self = .vc
        case "VE": self = .ve
        case "VG": self = .vg
        case "VI": self = .vi
        case "VN": self = .vn
        case "VU": self = .vu
        case "WF": self = .wf
        case "WS": self = .ws
        case "XK": self = .xk
        case "YE": self = .ye
        case "YT": self = .yt
        case "ZA": self = .za
        case "ZM": self = .zm
        case "ZW": self = .zw
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .ad: return "AD"
        case .ae: return "AE"
        case .af: return "AF"
        case .ag: return "AG"
        case .ai: return "AI"
        case .al: return "AL"
        case .am: return "AM"
        case .an: return "AN"
        case .ao: return "AO"
        case .aq: return "AQ"
        case .ar: return "AR"
        case .as: return "AS"
        case .at: return "AT"
        case .au: return "AU"
        case .aw: return "AW"
        case .ax: return "AX"
        case .az: return "AZ"
        case .ba: return "BA"
        case .bb: return "BB"
        case .bd: return "BD"
        case .be: return "BE"
        case .bf: return "BF"
        case .bg: return "BG"
        case .bh: return "BH"
        case .bi: return "BI"
        case .bj: return "BJ"
        case .bl: return "BL"
        case .bm: return "BM"
        case .bn: return "BN"
        case .bo: return "BO"
        case .bq: return "BQ"
        case .br: return "BR"
        case .bs: return "BS"
        case .bt: return "BT"
        case .bv: return "BV"
        case .bw: return "BW"
        case .by: return "BY"
        case .bz: return "BZ"
        case .ca: return "CA"
        case .cc: return "CC"
        case .cd: return "CD"
        case .cf: return "CF"
        case .cg: return "CG"
        case .ch: return "CH"
        case .ci: return "CI"
        case .ck: return "CK"
        case .cl: return "CL"
        case .cm: return "CM"
        case .cn: return "CN"
        case .co: return "CO"
        case .cr: return "CR"
        case .cu: return "CU"
        case .cw: return "CW"
        case .cv: return "CV"
        case .cx: return "CX"
        case .cy: return "CY"
        case .cz: return "CZ"
        case .de: return "DE"
        case .dj: return "DJ"
        case .dk: return "DK"
        case .dm: return "DM"
        case .do: return "DO"
        case .dz: return "DZ"
        case .ec: return "EC"
        case .ee: return "EE"
        case .eg: return "EG"
        case .eh: return "EH"
        case .er: return "ER"
        case .es: return "ES"
        case .et: return "ET"
        case .fi: return "FI"
        case .fj: return "FJ"
        case .fk: return "FK"
        case .fm: return "FM"
        case .fo: return "FO"
        case .fr: return "FR"
        case .ga: return "GA"
        case .gb: return "GB"
        case .gd: return "GD"
        case .ge: return "GE"
        case .gf: return "GF"
        case .gg: return "GG"
        case .gh: return "GH"
        case .gi: return "GI"
        case .gl: return "GL"
        case .gm: return "GM"
        case .gn: return "GN"
        case .gp: return "GP"
        case .gq: return "GQ"
        case .gr: return "GR"
        case .gs: return "GS"
        case .gt: return "GT"
        case .gu: return "GU"
        case .gw: return "GW"
        case .gy: return "GY"
        case .hk: return "HK"
        case .hm: return "HM"
        case .hn: return "HN"
        case .hr: return "HR"
        case .ht: return "HT"
        case .hu: return "HU"
        case .id: return "ID"
        case .ie: return "IE"
        case .il: return "IL"
        case .im: return "IM"
        case .in: return "IN"
        case .io: return "IO"
        case .iq: return "IQ"
        case .ir: return "IR"
        case .is: return "IS"
        case .it: return "IT"
        case .je: return "JE"
        case .jm: return "JM"
        case .jo: return "JO"
        case .jp: return "JP"
        case .ke: return "KE"
        case .kg: return "KG"
        case .kh: return "KH"
        case .ki: return "KI"
        case .km: return "KM"
        case .kn: return "KN"
        case .kp: return "KP"
        case .kr: return "KR"
        case .kw: return "KW"
        case .ky: return "KY"
        case .kz: return "KZ"
        case .la: return "LA"
        case .lb: return "LB"
        case .lc: return "LC"
        case .li: return "LI"
        case .lk: return "LK"
        case .lr: return "LR"
        case .ls: return "LS"
        case .lt: return "LT"
        case .lu: return "LU"
        case .lv: return "LV"
        case .ly: return "LY"
        case .ma: return "MA"
        case .mc: return "MC"
        case .md: return "MD"
        case .me: return "ME"
        case .mf: return "MF"
        case .mg: return "MG"
        case .mh: return "MH"
        case .mk: return "MK"
        case .ml: return "ML"
        case .mm: return "MM"
        case .mn: return "MN"
        case .mo: return "MO"
        case .mp: return "MP"
        case .mq: return "MQ"
        case .mr: return "MR"
        case .ms: return "MS"
        case .mt: return "MT"
        case .mu: return "MU"
        case .mv: return "MV"
        case .mw: return "MW"
        case .mx: return "MX"
        case .my: return "MY"
        case .mz: return "MZ"
        case .na: return "NA"
        case .nc: return "NC"
        case .ne: return "NE"
        case .nf: return "NF"
        case .ng: return "NG"
        case .ni: return "NI"
        case .nl: return "NL"
        case .no: return "NO"
        case .np: return "NP"
        case .nr: return "NR"
        case .nu: return "NU"
        case .nz: return "NZ"
        case .om: return "OM"
        case .pa: return "PA"
        case .pe: return "PE"
        case .pf: return "PF"
        case .pg: return "PG"
        case .ph: return "PH"
        case .pk: return "PK"
        case .pl: return "PL"
        case .pm: return "PM"
        case .pn: return "PN"
        case .pr: return "PR"
        case .ps: return "PS"
        case .pt: return "PT"
        case .pw: return "PW"
        case .py: return "PY"
        case .qa: return "QA"
        case .re: return "RE"
        case .ro: return "RO"
        case .rs: return "RS"
        case .ru: return "RU"
        case .rw: return "RW"
        case .sa: return "SA"
        case .sb: return "SB"
        case .sc: return "SC"
        case .sd: return "SD"
        case .se: return "SE"
        case .sg: return "SG"
        case .sh: return "SH"
        case .si: return "SI"
        case .sj: return "SJ"
        case .sk: return "SK"
        case .sl: return "SL"
        case .sm: return "SM"
        case .sn: return "SN"
        case .so: return "SO"
        case .sr: return "SR"
        case .ss: return "SS"
        case .st: return "ST"
        case .sv: return "SV"
        case .sx: return "SX"
        case .sy: return "SY"
        case .sz: return "SZ"
        case .tc: return "TC"
        case .td: return "TD"
        case .tf: return "TF"
        case .tg: return "TG"
        case .th: return "TH"
        case .tj: return "TJ"
        case .tk: return "TK"
        case .tl: return "TL"
        case .tm: return "TM"
        case .tn: return "TN"
        case .to: return "TO"
        case .tr: return "TR"
        case .tt: return "TT"
        case .tv: return "TV"
        case .tw: return "TW"
        case .tz: return "TZ"
        case .ua: return "UA"
        case .ug: return "UG"
        case .um: return "UM"
        case .us: return "US"
        case .uy: return "UY"
        case .uz: return "UZ"
        case .va: return "VA"
        case .vc: return "VC"
        case .ve: return "VE"
        case .vg: return "VG"
        case .vi: return "VI"
        case .vn: return "VN"
        case .vu: return "VU"
        case .wf: return "WF"
        case .ws: return "WS"
        case .xk: return "XK"
        case .ye: return "YE"
        case .yt: return "YT"
        case .za: return "ZA"
        case .zm: return "ZM"
        case .zw: return "ZW"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: CountryCode, rhs: CountryCode) -> Bool {
      switch (lhs, rhs) {
        case (.ad, .ad): return true
        case (.ae, .ae): return true
        case (.af, .af): return true
        case (.ag, .ag): return true
        case (.ai, .ai): return true
        case (.al, .al): return true
        case (.am, .am): return true
        case (.an, .an): return true
        case (.ao, .ao): return true
        case (.aq, .aq): return true
        case (.ar, .ar): return true
        case (.as, .as): return true
        case (.at, .at): return true
        case (.au, .au): return true
        case (.aw, .aw): return true
        case (.ax, .ax): return true
        case (.az, .az): return true
        case (.ba, .ba): return true
        case (.bb, .bb): return true
        case (.bd, .bd): return true
        case (.be, .be): return true
        case (.bf, .bf): return true
        case (.bg, .bg): return true
        case (.bh, .bh): return true
        case (.bi, .bi): return true
        case (.bj, .bj): return true
        case (.bl, .bl): return true
        case (.bm, .bm): return true
        case (.bn, .bn): return true
        case (.bo, .bo): return true
        case (.bq, .bq): return true
        case (.br, .br): return true
        case (.bs, .bs): return true
        case (.bt, .bt): return true
        case (.bv, .bv): return true
        case (.bw, .bw): return true
        case (.by, .by): return true
        case (.bz, .bz): return true
        case (.ca, .ca): return true
        case (.cc, .cc): return true
        case (.cd, .cd): return true
        case (.cf, .cf): return true
        case (.cg, .cg): return true
        case (.ch, .ch): return true
        case (.ci, .ci): return true
        case (.ck, .ck): return true
        case (.cl, .cl): return true
        case (.cm, .cm): return true
        case (.cn, .cn): return true
        case (.co, .co): return true
        case (.cr, .cr): return true
        case (.cu, .cu): return true
        case (.cw, .cw): return true
        case (.cv, .cv): return true
        case (.cx, .cx): return true
        case (.cy, .cy): return true
        case (.cz, .cz): return true
        case (.de, .de): return true
        case (.dj, .dj): return true
        case (.dk, .dk): return true
        case (.dm, .dm): return true
        case (.do, .do): return true
        case (.dz, .dz): return true
        case (.ec, .ec): return true
        case (.ee, .ee): return true
        case (.eg, .eg): return true
        case (.eh, .eh): return true
        case (.er, .er): return true
        case (.es, .es): return true
        case (.et, .et): return true
        case (.fi, .fi): return true
        case (.fj, .fj): return true
        case (.fk, .fk): return true
        case (.fm, .fm): return true
        case (.fo, .fo): return true
        case (.fr, .fr): return true
        case (.ga, .ga): return true
        case (.gb, .gb): return true
        case (.gd, .gd): return true
        case (.ge, .ge): return true
        case (.gf, .gf): return true
        case (.gg, .gg): return true
        case (.gh, .gh): return true
        case (.gi, .gi): return true
        case (.gl, .gl): return true
        case (.gm, .gm): return true
        case (.gn, .gn): return true
        case (.gp, .gp): return true
        case (.gq, .gq): return true
        case (.gr, .gr): return true
        case (.gs, .gs): return true
        case (.gt, .gt): return true
        case (.gu, .gu): return true
        case (.gw, .gw): return true
        case (.gy, .gy): return true
        case (.hk, .hk): return true
        case (.hm, .hm): return true
        case (.hn, .hn): return true
        case (.hr, .hr): return true
        case (.ht, .ht): return true
        case (.hu, .hu): return true
        case (.id, .id): return true
        case (.ie, .ie): return true
        case (.il, .il): return true
        case (.im, .im): return true
        case (.in, .in): return true
        case (.io, .io): return true
        case (.iq, .iq): return true
        case (.ir, .ir): return true
        case (.is, .is): return true
        case (.it, .it): return true
        case (.je, .je): return true
        case (.jm, .jm): return true
        case (.jo, .jo): return true
        case (.jp, .jp): return true
        case (.ke, .ke): return true
        case (.kg, .kg): return true
        case (.kh, .kh): return true
        case (.ki, .ki): return true
        case (.km, .km): return true
        case (.kn, .kn): return true
        case (.kp, .kp): return true
        case (.kr, .kr): return true
        case (.kw, .kw): return true
        case (.ky, .ky): return true
        case (.kz, .kz): return true
        case (.la, .la): return true
        case (.lb, .lb): return true
        case (.lc, .lc): return true
        case (.li, .li): return true
        case (.lk, .lk): return true
        case (.lr, .lr): return true
        case (.ls, .ls): return true
        case (.lt, .lt): return true
        case (.lu, .lu): return true
        case (.lv, .lv): return true
        case (.ly, .ly): return true
        case (.ma, .ma): return true
        case (.mc, .mc): return true
        case (.md, .md): return true
        case (.me, .me): return true
        case (.mf, .mf): return true
        case (.mg, .mg): return true
        case (.mh, .mh): return true
        case (.mk, .mk): return true
        case (.ml, .ml): return true
        case (.mm, .mm): return true
        case (.mn, .mn): return true
        case (.mo, .mo): return true
        case (.mp, .mp): return true
        case (.mq, .mq): return true
        case (.mr, .mr): return true
        case (.ms, .ms): return true
        case (.mt, .mt): return true
        case (.mu, .mu): return true
        case (.mv, .mv): return true
        case (.mw, .mw): return true
        case (.mx, .mx): return true
        case (.my, .my): return true
        case (.mz, .mz): return true
        case (.na, .na): return true
        case (.nc, .nc): return true
        case (.ne, .ne): return true
        case (.nf, .nf): return true
        case (.ng, .ng): return true
        case (.ni, .ni): return true
        case (.nl, .nl): return true
        case (.no, .no): return true
        case (.np, .np): return true
        case (.nr, .nr): return true
        case (.nu, .nu): return true
        case (.nz, .nz): return true
        case (.om, .om): return true
        case (.pa, .pa): return true
        case (.pe, .pe): return true
        case (.pf, .pf): return true
        case (.pg, .pg): return true
        case (.ph, .ph): return true
        case (.pk, .pk): return true
        case (.pl, .pl): return true
        case (.pm, .pm): return true
        case (.pn, .pn): return true
        case (.pr, .pr): return true
        case (.ps, .ps): return true
        case (.pt, .pt): return true
        case (.pw, .pw): return true
        case (.py, .py): return true
        case (.qa, .qa): return true
        case (.re, .re): return true
        case (.ro, .ro): return true
        case (.rs, .rs): return true
        case (.ru, .ru): return true
        case (.rw, .rw): return true
        case (.sa, .sa): return true
        case (.sb, .sb): return true
        case (.sc, .sc): return true
        case (.sd, .sd): return true
        case (.se, .se): return true
        case (.sg, .sg): return true
        case (.sh, .sh): return true
        case (.si, .si): return true
        case (.sj, .sj): return true
        case (.sk, .sk): return true
        case (.sl, .sl): return true
        case (.sm, .sm): return true
        case (.sn, .sn): return true
        case (.so, .so): return true
        case (.sr, .sr): return true
        case (.ss, .ss): return true
        case (.st, .st): return true
        case (.sv, .sv): return true
        case (.sx, .sx): return true
        case (.sy, .sy): return true
        case (.sz, .sz): return true
        case (.tc, .tc): return true
        case (.td, .td): return true
        case (.tf, .tf): return true
        case (.tg, .tg): return true
        case (.th, .th): return true
        case (.tj, .tj): return true
        case (.tk, .tk): return true
        case (.tl, .tl): return true
        case (.tm, .tm): return true
        case (.tn, .tn): return true
        case (.to, .to): return true
        case (.tr, .tr): return true
        case (.tt, .tt): return true
        case (.tv, .tv): return true
        case (.tw, .tw): return true
        case (.tz, .tz): return true
        case (.ua, .ua): return true
        case (.ug, .ug): return true
        case (.um, .um): return true
        case (.us, .us): return true
        case (.uy, .uy): return true
        case (.uz, .uz): return true
        case (.va, .va): return true
        case (.vc, .vc): return true
        case (.ve, .ve): return true
        case (.vg, .vg): return true
        case (.vi, .vi): return true
        case (.vn, .vn): return true
        case (.vu, .vu): return true
        case (.wf, .wf): return true
        case (.ws, .ws): return true
        case (.xk, .xk): return true
        case (.ye, .ye): return true
        case (.yt, .yt): return true
        case (.za, .za): return true
        case (.zm, .zm): return true
        case (.zw, .zw): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [CountryCode] {
      return [
        .ad,
        .ae,
        .af,
        .ag,
        .ai,
        .al,
        .am,
        .an,
        .ao,
        .aq,
        .ar,
        .as,
        .at,
        .au,
        .aw,
        .ax,
        .az,
        .ba,
        .bb,
        .bd,
        .be,
        .bf,
        .bg,
        .bh,
        .bi,
        .bj,
        .bl,
        .bm,
        .bn,
        .bo,
        .bq,
        .br,
        .bs,
        .bt,
        .bv,
        .bw,
        .by,
        .bz,
        .ca,
        .cc,
        .cd,
        .cf,
        .cg,
        .ch,
        .ci,
        .ck,
        .cl,
        .cm,
        .cn,
        .co,
        .cr,
        .cu,
        .cw,
        .cv,
        .cx,
        .cy,
        .cz,
        .de,
        .dj,
        .dk,
        .dm,
        .do,
        .dz,
        .ec,
        .ee,
        .eg,
        .eh,
        .er,
        .es,
        .et,
        .fi,
        .fj,
        .fk,
        .fm,
        .fo,
        .fr,
        .ga,
        .gb,
        .gd,
        .ge,
        .gf,
        .gg,
        .gh,
        .gi,
        .gl,
        .gm,
        .gn,
        .gp,
        .gq,
        .gr,
        .gs,
        .gt,
        .gu,
        .gw,
        .gy,
        .hk,
        .hm,
        .hn,
        .hr,
        .ht,
        .hu,
        .id,
        .ie,
        .il,
        .im,
        .in,
        .io,
        .iq,
        .ir,
        .is,
        .it,
        .je,
        .jm,
        .jo,
        .jp,
        .ke,
        .kg,
        .kh,
        .ki,
        .km,
        .kn,
        .kp,
        .kr,
        .kw,
        .ky,
        .kz,
        .la,
        .lb,
        .lc,
        .li,
        .lk,
        .lr,
        .ls,
        .lt,
        .lu,
        .lv,
        .ly,
        .ma,
        .mc,
        .md,
        .me,
        .mf,
        .mg,
        .mh,
        .mk,
        .ml,
        .mm,
        .mn,
        .mo,
        .mp,
        .mq,
        .mr,
        .ms,
        .mt,
        .mu,
        .mv,
        .mw,
        .mx,
        .my,
        .mz,
        .na,
        .nc,
        .ne,
        .nf,
        .ng,
        .ni,
        .nl,
        .no,
        .np,
        .nr,
        .nu,
        .nz,
        .om,
        .pa,
        .pe,
        .pf,
        .pg,
        .ph,
        .pk,
        .pl,
        .pm,
        .pn,
        .pr,
        .ps,
        .pt,
        .pw,
        .py,
        .qa,
        .re,
        .ro,
        .rs,
        .ru,
        .rw,
        .sa,
        .sb,
        .sc,
        .sd,
        .se,
        .sg,
        .sh,
        .si,
        .sj,
        .sk,
        .sl,
        .sm,
        .sn,
        .so,
        .sr,
        .ss,
        .st,
        .sv,
        .sx,
        .sy,
        .sz,
        .tc,
        .td,
        .tf,
        .tg,
        .th,
        .tj,
        .tk,
        .tl,
        .tm,
        .tn,
        .to,
        .tr,
        .tt,
        .tv,
        .tw,
        .tz,
        .ua,
        .ug,
        .um,
        .us,
        .uy,
        .uz,
        .va,
        .vc,
        .ve,
        .vg,
        .vi,
        .vn,
        .vu,
        .wf,
        .ws,
        .xk,
        .ye,
        .yt,
        .za,
        .zm,
        .zw,
      ]
    }
  }

  /// Credit card payment types.
  public enum CreditCardPaymentType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    case androidPay
    case applePay
    case bankAccount
    case creditCard
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "ANDROID_PAY": self = .androidPay
        case "APPLE_PAY": self = .applePay
        case "BANK_ACCOUNT": self = .bankAccount
        case "CREDIT_CARD": self = .creditCard
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .androidPay: return "ANDROID_PAY"
        case .applePay: return "APPLE_PAY"
        case .bankAccount: return "BANK_ACCOUNT"
        case .creditCard: return "CREDIT_CARD"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: CreditCardPaymentType, rhs: CreditCardPaymentType) -> Bool {
      switch (lhs, rhs) {
        case (.androidPay, .androidPay): return true
        case (.applePay, .applePay): return true
        case (.bankAccount, .bankAccount): return true
        case (.creditCard, .creditCard): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [CreditCardPaymentType] {
      return [
        .androidPay,
        .applePay,
        .bankAccount,
        .creditCard,
      ]
    }
  }

  /// States of Credit Cards
  public enum CreditCardState: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    case unauthorized
    case verifying
    case active
    case inactive
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "UNAUTHORIZED": self = .unauthorized
        case "VERIFYING": self = .verifying
        case "ACTIVE": self = .active
        case "INACTIVE": self = .inactive
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .unauthorized: return "UNAUTHORIZED"
        case .verifying: return "VERIFYING"
        case .active: return "ACTIVE"
        case .inactive: return "INACTIVE"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: CreditCardState, rhs: CreditCardState) -> Bool {
      switch (lhs, rhs) {
        case (.unauthorized, .unauthorized): return true
        case (.verifying, .verifying): return true
        case (.active, .active): return true
        case (.inactive, .inactive): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [CreditCardState] {
      return [
        .unauthorized,
        .verifying,
        .active,
        .inactive,
      ]
    }
  }

  /// Credit card types.
  public enum CreditCardTypes: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    case amex
    case discover
    case jcb
    case mastercard
    case visa
    case diners
    case unionPay
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "AMEX": self = .amex
        case "DISCOVER": self = .discover
        case "JCB": self = .jcb
        case "MASTERCARD": self = .mastercard
        case "VISA": self = .visa
        case "DINERS": self = .diners
        case "UNION_PAY": self = .unionPay
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .amex: return "AMEX"
        case .discover: return "DISCOVER"
        case .jcb: return "JCB"
        case .mastercard: return "MASTERCARD"
        case .visa: return "VISA"
        case .diners: return "DINERS"
        case .unionPay: return "UNION_PAY"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: CreditCardTypes, rhs: CreditCardTypes) -> Bool {
      switch (lhs, rhs) {
        case (.amex, .amex): return true
        case (.discover, .discover): return true
        case (.jcb, .jcb): return true
        case (.mastercard, .mastercard): return true
        case (.visa, .visa): return true
        case (.diners, .diners): return true
        case (.unionPay, .unionPay): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [CreditCardTypes] {
      return [
        .amex,
        .discover,
        .jcb,
        .mastercard,
        .visa,
        .diners,
        .unionPay,
      ]
    }
  }

  /// A list of Iso4217–supported currencies.
  public enum CurrencyCode: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    case aud
    case cad
    case chf
    case dkk
    case eur
    case gbp
    case hkd
    case jpy
    case mxn
    case nok
    case nzd
    case pln
    case sek
    case sgd
    case usd
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "AUD": self = .aud
        case "CAD": self = .cad
        case "CHF": self = .chf
        case "DKK": self = .dkk
        case "EUR": self = .eur
        case "GBP": self = .gbp
        case "HKD": self = .hkd
        case "JPY": self = .jpy
        case "MXN": self = .mxn
        case "NOK": self = .nok
        case "NZD": self = .nzd
        case "PLN": self = .pln
        case "SEK": self = .sek
        case "SGD": self = .sgd
        case "USD": self = .usd
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .aud: return "AUD"
        case .cad: return "CAD"
        case .chf: return "CHF"
        case .dkk: return "DKK"
        case .eur: return "EUR"
        case .gbp: return "GBP"
        case .hkd: return "HKD"
        case .jpy: return "JPY"
        case .mxn: return "MXN"
        case .nok: return "NOK"
        case .nzd: return "NZD"
        case .pln: return "PLN"
        case .sek: return "SEK"
        case .sgd: return "SGD"
        case .usd: return "USD"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: CurrencyCode, rhs: CurrencyCode) -> Bool {
      switch (lhs, rhs) {
        case (.aud, .aud): return true
        case (.cad, .cad): return true
        case (.chf, .chf): return true
        case (.dkk, .dkk): return true
        case (.eur, .eur): return true
        case (.gbp, .gbp): return true
        case (.hkd, .hkd): return true
        case (.jpy, .jpy): return true
        case (.mxn, .mxn): return true
        case (.nok, .nok): return true
        case (.nzd, .nzd): return true
        case (.pln, .pln): return true
        case (.sek, .sek): return true
        case (.sgd, .sgd): return true
        case (.usd, .usd): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [CurrencyCode] {
      return [
        .aud,
        .cad,
        .chf,
        .dkk,
        .eur,
        .gbp,
        .hkd,
        .jpy,
        .mxn,
        .nok,
        .nzd,
        .pln,
        .sek,
        .sgd,
        .usd,
      ]
    }
  }

  /// Various project states.
  public enum ProjectState: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    /// Created and preparing for launch.
    case started
    /// Ready for launch with a draft submitted for auto-approval.
    case submitted
    /// Active and accepting pledges.
    case live
    /// Canceled by creator.
    case canceled
    /// Suspended for investigation, visible.
    case suspended
    /// Suspended and hidden.
    case purged
    /// Successfully funded by deadline.
    case successful
    /// Failed to fund by deadline.
    case failed
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "STARTED": self = .started
        case "SUBMITTED": self = .submitted
        case "LIVE": self = .live
        case "CANCELED": self = .canceled
        case "SUSPENDED": self = .suspended
        case "PURGED": self = .purged
        case "SUCCESSFUL": self = .successful
        case "FAILED": self = .failed
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .started: return "STARTED"
        case .submitted: return "SUBMITTED"
        case .live: return "LIVE"
        case .canceled: return "CANCELED"
        case .suspended: return "SUSPENDED"
        case .purged: return "PURGED"
        case .successful: return "SUCCESSFUL"
        case .failed: return "FAILED"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: ProjectState, rhs: ProjectState) -> Bool {
      switch (lhs, rhs) {
        case (.started, .started): return true
        case (.submitted, .submitted): return true
        case (.live, .live): return true
        case (.canceled, .canceled): return true
        case (.suspended, .suspended): return true
        case (.purged, .purged): return true
        case (.successful, .successful): return true
        case (.failed, .failed): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [ProjectState] {
      return [
        .started,
        .submitted,
        .live,
        .canceled,
        .suspended,
        .purged,
        .successful,
        .failed,
      ]
    }
  }

  /// A preference for shipping a reward
  public enum ShippingPreference: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    case `none`
    case restricted
    case unrestricted
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "none": self = .none
        case "restricted": self = .restricted
        case "unrestricted": self = .unrestricted
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .none: return "none"
        case .restricted: return "restricted"
        case .unrestricted: return "unrestricted"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: ShippingPreference, rhs: ShippingPreference) -> Bool {
      switch (lhs, rhs) {
        case (.none, .none): return true
        case (.restricted, .restricted): return true
        case (.unrestricted, .unrestricted): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [ShippingPreference] {
      return [
        .none,
        .restricted,
        .unrestricted,
      ]
    }
  }

  public final class FetchAddOnsQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query FetchAddOns($projectSlug: String!, $locationId: ID) {
        project(slug: $projectSlug) {
          __typename
          ...ProjectFragment
          addOns {
            __typename
            nodes {
              __typename
              ...RewardFragment
              shippingRulesExpanded(forLocation: $locationId) {
                __typename
                nodes {
                  __typename
                  ...ShippingRuleFragment
                }
              }
            }
          }
        }
      }
      """

    public let operationName: String = "FetchAddOns"

    public var queryDocument: String {
      var document: String = operationDefinition
      document.append("\n" + ProjectFragment.fragmentDefinition)
      document.append("\n" + CategoryFragment.fragmentDefinition)
      document.append("\n" + CountryFragment.fragmentDefinition)
      document.append("\n" + UserFragment.fragmentDefinition)
      document.append("\n" + MoneyFragment.fragmentDefinition)
      document.append("\n" + LocationFragment.fragmentDefinition)
      document.append("\n" + RewardFragment.fragmentDefinition)
      document.append("\n" + ShippingRuleFragment.fragmentDefinition)
      return document
    }

    public var projectSlug: String
    public var locationId: GraphQLID?

    public init(projectSlug: String, locationId: GraphQLID? = nil) {
      self.projectSlug = projectSlug
      self.locationId = locationId
    }

    public var variables: GraphQLMap? {
      return ["projectSlug": projectSlug, "locationId": locationId]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Query"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("project", arguments: ["slug": GraphQLVariable("projectSlug")], type: .object(Project.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(project: Project? = nil) {
        self.init(unsafeResultMap: ["__typename": "Query", "project": project.flatMap { (value: Project) -> ResultMap in value.resultMap }])
      }

      /// Fetches a project given its slug or pid.
      public var project: Project? {
        get {
          return (resultMap["project"] as? ResultMap).flatMap { Project(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "project")
        }
      }

      public struct Project: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Project"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(ProjectFragment.self),
            GraphQLField("addOns", type: .object(AddOn.selections)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Backing Add-ons
        public var addOns: AddOn? {
          get {
            return (resultMap["addOns"] as? ResultMap).flatMap { AddOn(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "addOns")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var projectFragment: ProjectFragment {
            get {
              return ProjectFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct AddOn: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["ProjectRewardConnection"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("nodes", type: .list(.object(Node.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(nodes: [Node?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "ProjectRewardConnection", "nodes": nodes.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A list of nodes.
          public var nodes: [Node?]? {
            get {
              return (resultMap["nodes"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Node?] in value.map { (value: ResultMap?) -> Node? in value.flatMap { (value: ResultMap) -> Node in Node(unsafeResultMap: value) } } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }, forKey: "nodes")
            }
          }

          public struct Node: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Reward"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLFragmentSpread(RewardFragment.self),
                GraphQLField("shippingRulesExpanded", arguments: ["forLocation": GraphQLVariable("locationId")], type: .object(ShippingRulesExpanded.selections)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// Shipping rules for all shippable countries.
            public var shippingRulesExpanded: ShippingRulesExpanded? {
              get {
                return (resultMap["shippingRulesExpanded"] as? ResultMap).flatMap { ShippingRulesExpanded(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "shippingRulesExpanded")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var rewardFragment: RewardFragment {
                get {
                  return RewardFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }

            public struct ShippingRulesExpanded: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["RewardShippingRulesConnection"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("nodes", type: .list(.object(Node.selections))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(nodes: [Node?]? = nil) {
                self.init(unsafeResultMap: ["__typename": "RewardShippingRulesConnection", "nodes": nodes.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// A list of nodes.
              public var nodes: [Node?]? {
                get {
                  return (resultMap["nodes"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Node?] in value.map { (value: ResultMap?) -> Node? in value.flatMap { (value: ResultMap) -> Node in Node(unsafeResultMap: value) } } }
                }
                set {
                  resultMap.updateValue(newValue.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }, forKey: "nodes")
                }
              }

              public struct Node: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["ShippingRule"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLFragmentSpread(ShippingRuleFragment.self),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var fragments: Fragments {
                  get {
                    return Fragments(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public struct Fragments {
                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public var shippingRuleFragment: ShippingRuleFragment {
                    get {
                      return ShippingRuleFragment(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  public final class FetchBackingQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query FetchBacking($id: ID!) {
        backing(id: $id) {
          __typename
          addOns {
            __typename
            nodes {
              __typename
              ...RewardFragment
            }
          }
          ...BackingFragment
        }
      }
      """

    public let operationName: String = "FetchBacking"

    public var queryDocument: String {
      var document: String = operationDefinition
      document.append("\n" + RewardFragment.fragmentDefinition)
      document.append("\n" + MoneyFragment.fragmentDefinition)
      document.append("\n" + ShippingRuleFragment.fragmentDefinition)
      document.append("\n" + LocationFragment.fragmentDefinition)
      document.append("\n" + BackingFragment.fragmentDefinition)
      document.append("\n" + UserFragment.fragmentDefinition)
      document.append("\n" + CreditCardFragment.fragmentDefinition)
      document.append("\n" + ProjectFragment.fragmentDefinition)
      document.append("\n" + CategoryFragment.fragmentDefinition)
      document.append("\n" + CountryFragment.fragmentDefinition)
      return document
    }

    public var id: GraphQLID

    public init(id: GraphQLID) {
      self.id = id
    }

    public var variables: GraphQLMap? {
      return ["id": id]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Query"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("backing", arguments: ["id": GraphQLVariable("id")], type: .object(Backing.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(backing: Backing? = nil) {
        self.init(unsafeResultMap: ["__typename": "Query", "backing": backing.flatMap { (value: Backing) -> ResultMap in value.resultMap }])
      }

      /// Fetches a backing given its id.
      public var backing: Backing? {
        get {
          return (resultMap["backing"] as? ResultMap).flatMap { Backing(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "backing")
        }
      }

      public struct Backing: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Backing"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("addOns", type: .object(AddOn.selections)),
            GraphQLFragmentSpread(BackingFragment.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The add-ons that the backer selected
        public var addOns: AddOn? {
          get {
            return (resultMap["addOns"] as? ResultMap).flatMap { AddOn(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "addOns")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var backingFragment: BackingFragment {
            get {
              return BackingFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct AddOn: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["RewardTotalCountConnection"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("nodes", type: .list(.object(Node.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(nodes: [Node?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "RewardTotalCountConnection", "nodes": nodes.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A list of nodes.
          public var nodes: [Node?]? {
            get {
              return (resultMap["nodes"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Node?] in value.map { (value: ResultMap?) -> Node? in value.flatMap { (value: ResultMap) -> Node in Node(unsafeResultMap: value) } } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }, forKey: "nodes")
            }
          }

          public struct Node: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Reward"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLFragmentSpread(RewardFragment.self),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var rewardFragment: RewardFragment {
                get {
                  return RewardFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }
        }
      }
    }
  }

  public final class FetchProjectCommentsQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query FetchProjectComments($slug: String!, $cursor: String, $limit: Int) {
        project(slug: $slug) {
          __typename
          comments(after: $cursor, first: $limit) {
            __typename
            edges {
              __typename
              node {
                __typename
                ...CommentFragment
              }
            }
            pageInfo {
              __typename
              endCursor
              hasNextPage
            }
            totalCount
          }
          id
          slug
        }
      }
      """

    public let operationName: String = "FetchProjectComments"

    public var queryDocument: String {
      var document: String = operationDefinition
      document.append("\n" + CommentFragment.fragmentDefinition)
      document.append("\n" + UserFragment.fragmentDefinition)
      return document
    }

    public var slug: String
    public var cursor: String?
    public var limit: Int?

    public init(slug: String, cursor: String? = nil, limit: Int? = nil) {
      self.slug = slug
      self.cursor = cursor
      self.limit = limit
    }

    public var variables: GraphQLMap? {
      return ["slug": slug, "cursor": cursor, "limit": limit]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Query"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("project", arguments: ["slug": GraphQLVariable("slug")], type: .object(Project.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(project: Project? = nil) {
        self.init(unsafeResultMap: ["__typename": "Query", "project": project.flatMap { (value: Project) -> ResultMap in value.resultMap }])
      }

      /// Fetches a project given its slug or pid.
      public var project: Project? {
        get {
          return (resultMap["project"] as? ResultMap).flatMap { Project(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "project")
        }
      }

      public struct Project: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Project"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("comments", arguments: ["after": GraphQLVariable("cursor"), "first": GraphQLVariable("limit")], type: .object(Comment.selections)),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("slug", type: .nonNull(.scalar(String.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(comments: Comment? = nil, id: GraphQLID, slug: String) {
          self.init(unsafeResultMap: ["__typename": "Project", "comments": comments.flatMap { (value: Comment) -> ResultMap in value.resultMap }, "id": id, "slug": slug])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// List of comments on the commentable
        public var comments: Comment? {
          get {
            return (resultMap["comments"] as? ResultMap).flatMap { Comment(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "comments")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        /// The project's unique URL identifier.
        public var slug: String {
          get {
            return resultMap["slug"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "slug")
          }
        }

        public struct Comment: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["CommentConnection"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("edges", type: .list(.object(Edge.selections))),
              GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
              GraphQLField("totalCount", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(edges: [Edge?]? = nil, pageInfo: PageInfo, totalCount: Int) {
            self.init(unsafeResultMap: ["__typename": "CommentConnection", "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, "pageInfo": pageInfo.resultMap, "totalCount": totalCount])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A list of edges.
          public var edges: [Edge?]? {
            get {
              return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
            }
          }

          /// Information to aid in pagination.
          public var pageInfo: PageInfo {
            get {
              return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
            }
          }

          public var totalCount: Int {
            get {
              return resultMap["totalCount"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "totalCount")
            }
          }

          public struct Edge: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["CommentEdge"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("node", type: .object(Node.selections)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(node: Node? = nil) {
              self.init(unsafeResultMap: ["__typename": "CommentEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// The item at the end of the edge.
            public var node: Node? {
              get {
                return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "node")
              }
            }

            public struct Node: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Comment"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLFragmentSpread(CommentFragment.self),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var fragments: Fragments {
                get {
                  return Fragments(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public struct Fragments {
                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var commentFragment: CommentFragment {
                  get {
                    return CommentFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }
            }
          }

          public struct PageInfo: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["PageInfo"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("endCursor", type: .scalar(String.self)),
                GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(endCursor: String? = nil, hasNextPage: Bool) {
              self.init(unsafeResultMap: ["__typename": "PageInfo", "endCursor": endCursor, "hasNextPage": hasNextPage])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// When paginating forwards, the cursor to continue.
            public var endCursor: String? {
              get {
                return resultMap["endCursor"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "endCursor")
              }
            }

            /// When paginating forwards, are there more items?
            public var hasNextPage: Bool {
              get {
                return resultMap["hasNextPage"]! as! Bool
              }
              set {
                resultMap.updateValue(newValue, forKey: "hasNextPage")
              }
            }
          }
        }
      }
    }
  }

  public final class FetchUpdateCommentsQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query FetchUpdateComments($postId: ID!, $cursor: String, $limit: Int) {
        post(id: $postId) {
          __typename
          ... on FreeformPost {
            comments(after: $cursor, first: $limit) {
              __typename
              edges {
                __typename
                node {
                  __typename
                  ...CommentFragment
                }
              }
              pageInfo {
                __typename
                endCursor
                hasNextPage
              }
              totalCount
            }
            id
          }
        }
      }
      """

    public let operationName: String = "FetchUpdateComments"

    public var queryDocument: String {
      var document: String = operationDefinition
      document.append("\n" + CommentFragment.fragmentDefinition)
      document.append("\n" + UserFragment.fragmentDefinition)
      return document
    }

    public var postId: GraphQLID
    public var cursor: String?
    public var limit: Int?

    public init(postId: GraphQLID, cursor: String? = nil, limit: Int? = nil) {
      self.postId = postId
      self.cursor = cursor
      self.limit = limit
    }

    public var variables: GraphQLMap? {
      return ["postId": postId, "cursor": cursor, "limit": limit]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Query"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("post", arguments: ["id": GraphQLVariable("postId")], type: .object(Post.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(post: Post? = nil) {
        self.init(unsafeResultMap: ["__typename": "Query", "post": post.flatMap { (value: Post) -> ResultMap in value.resultMap }])
      }

      /// Fetches a post given its ID.
      public var post: Post? {
        get {
          return (resultMap["post"] as? ResultMap).flatMap { Post(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "post")
        }
      }

      public struct Post: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["CreatorInterview", "FreeformPost"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLTypeCase(
              variants: ["FreeformPost": AsFreeformPost.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeCreatorInterview() -> Post {
          return Post(unsafeResultMap: ["__typename": "CreatorInterview"])
        }

        public static func makeFreeformPost(comments: AsFreeformPost.Comment? = nil, id: GraphQLID) -> Post {
          return Post(unsafeResultMap: ["__typename": "FreeformPost", "comments": comments.flatMap { (value: AsFreeformPost.Comment) -> ResultMap in value.resultMap }, "id": id])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asFreeformPost: AsFreeformPost? {
          get {
            if !AsFreeformPost.possibleTypes.contains(__typename) { return nil }
            return AsFreeformPost(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsFreeformPost: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["FreeformPost"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("comments", arguments: ["after": GraphQLVariable("cursor"), "first": GraphQLVariable("limit")], type: .object(Comment.selections)),
              GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(comments: Comment? = nil, id: GraphQLID) {
            self.init(unsafeResultMap: ["__typename": "FreeformPost", "comments": comments.flatMap { (value: Comment) -> ResultMap in value.resultMap }, "id": id])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// List of comments on the commentable
          public var comments: Comment? {
            get {
              return (resultMap["comments"] as? ResultMap).flatMap { Comment(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "comments")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public struct Comment: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["CommentConnection"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("edges", type: .list(.object(Edge.selections))),
                GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
                GraphQLField("totalCount", type: .nonNull(.scalar(Int.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(edges: [Edge?]? = nil, pageInfo: PageInfo, totalCount: Int) {
              self.init(unsafeResultMap: ["__typename": "CommentConnection", "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, "pageInfo": pageInfo.resultMap, "totalCount": totalCount])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// A list of edges.
            public var edges: [Edge?]? {
              get {
                return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
              }
              set {
                resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
              }
            }

            /// Information to aid in pagination.
            public var pageInfo: PageInfo {
              get {
                return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
              }
            }

            public var totalCount: Int {
              get {
                return resultMap["totalCount"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "totalCount")
              }
            }

            public struct Edge: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["CommentEdge"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("node", type: .object(Node.selections)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(node: Node? = nil) {
                self.init(unsafeResultMap: ["__typename": "CommentEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// The item at the end of the edge.
              public var node: Node? {
                get {
                  return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
                }
                set {
                  resultMap.updateValue(newValue?.resultMap, forKey: "node")
                }
              }

              public struct Node: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["Comment"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLFragmentSpread(CommentFragment.self),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var fragments: Fragments {
                  get {
                    return Fragments(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public struct Fragments {
                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public var commentFragment: CommentFragment {
                    get {
                      return CommentFragment(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }
            }

            public struct PageInfo: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["PageInfo"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("endCursor", type: .scalar(String.self)),
                  GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(endCursor: String? = nil, hasNextPage: Bool) {
                self.init(unsafeResultMap: ["__typename": "PageInfo", "endCursor": endCursor, "hasNextPage": hasNextPage])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// When paginating forwards, the cursor to continue.
              public var endCursor: String? {
                get {
                  return resultMap["endCursor"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "endCursor")
                }
              }

              /// When paginating forwards, are there more items?
              public var hasNextPage: Bool {
                get {
                  return resultMap["hasNextPage"]! as! Bool
                }
                set {
                  resultMap.updateValue(newValue, forKey: "hasNextPage")
                }
              }
            }
          }
        }
      }
    }
  }

  public struct BackingFragment: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment BackingFragment on Backing {
        __typename
        amount {
          __typename
          ...MoneyFragment
        }
        backer {
          __typename
          ...UserFragment
        }
        backerCompleted
        bonusAmount {
          __typename
          ...MoneyFragment
        }
        cancelable
        creditCard: paymentSource {
          __typename
          ...CreditCardFragment
        }
        id
        location {
          __typename
          ...LocationFragment
        }
        pledgedOn
        project {
          __typename
          ...ProjectFragment
        }
        reward {
          __typename
          ...RewardFragment
        }
        sequence
        shippingAmount {
          __typename
          ...MoneyFragment
        }
        status
      }
      """

    public static let possibleTypes: [String] = ["Backing"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("amount", type: .nonNull(.object(Amount.selections))),
        GraphQLField("backer", type: .object(Backer.selections)),
        GraphQLField("backerCompleted", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("bonusAmount", type: .nonNull(.object(BonusAmount.selections))),
        GraphQLField("cancelable", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("paymentSource", alias: "creditCard", type: .object(CreditCard.selections)),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .object(Location.selections)),
        GraphQLField("pledgedOn", type: .scalar(String.self)),
        GraphQLField("project", type: .object(Project.selections)),
        GraphQLField("reward", type: .object(Reward.selections)),
        GraphQLField("sequence", type: .scalar(Int.self)),
        GraphQLField("shippingAmount", type: .object(ShippingAmount.selections)),
        GraphQLField("status", type: .nonNull(.scalar(BackingState.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(amount: Amount, backer: Backer? = nil, backerCompleted: Bool, bonusAmount: BonusAmount, cancelable: Bool, creditCard: CreditCard? = nil, id: GraphQLID, location: Location? = nil, pledgedOn: String? = nil, project: Project? = nil, reward: Reward? = nil, sequence: Int? = nil, shippingAmount: ShippingAmount? = nil, status: BackingState) {
      self.init(unsafeResultMap: ["__typename": "Backing", "amount": amount.resultMap, "backer": backer.flatMap { (value: Backer) -> ResultMap in value.resultMap }, "backerCompleted": backerCompleted, "bonusAmount": bonusAmount.resultMap, "cancelable": cancelable, "creditCard": creditCard.flatMap { (value: CreditCard) -> ResultMap in value.resultMap }, "id": id, "location": location.flatMap { (value: Location) -> ResultMap in value.resultMap }, "pledgedOn": pledgedOn, "project": project.flatMap { (value: Project) -> ResultMap in value.resultMap }, "reward": reward.flatMap { (value: Reward) -> ResultMap in value.resultMap }, "sequence": sequence, "shippingAmount": shippingAmount.flatMap { (value: ShippingAmount) -> ResultMap in value.resultMap }, "status": status])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// Total amount pledged by the backer to the project, including shipping.
    public var amount: Amount {
      get {
        return Amount(unsafeResultMap: resultMap["amount"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "amount")
      }
    }

    /// The backer
    public var backer: Backer? {
      get {
        return (resultMap["backer"] as? ResultMap).flatMap { Backer(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "backer")
      }
    }

    /// If the backer_completed_at is set or not
    public var backerCompleted: Bool {
      get {
        return resultMap["backerCompleted"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "backerCompleted")
      }
    }

    /// Extra amount the backer pledged on top of the minimum.
    public var bonusAmount: BonusAmount {
      get {
        return BonusAmount(unsafeResultMap: resultMap["bonusAmount"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "bonusAmount")
      }
    }

    /// If the backing can be cancelled
    public var cancelable: Bool {
      get {
        return resultMap["cancelable"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "cancelable")
      }
    }

    /// Payment source used on a backing.
    public var creditCard: CreditCard? {
      get {
        return (resultMap["creditCard"] as? ResultMap).flatMap { CreditCard(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "creditCard")
      }
    }

    public var id: GraphQLID {
      get {
        return resultMap["id"]! as! GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    /// The backing location.
    public var location: Location? {
      get {
        return (resultMap["location"] as? ResultMap).flatMap { Location(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "location")
      }
    }

    /// When the backing was created
    public var pledgedOn: String? {
      get {
        return resultMap["pledgedOn"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "pledgedOn")
      }
    }

    /// The project
    public var project: Project? {
      get {
        return (resultMap["project"] as? ResultMap).flatMap { Project(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "project")
      }
    }

    /// The reward the backer is expecting
    public var reward: Reward? {
      get {
        return (resultMap["reward"] as? ResultMap).flatMap { Reward(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "reward")
      }
    }

    /// Sequence of the backing
    public var sequence: Int? {
      get {
        return resultMap["sequence"] as? Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "sequence")
      }
    }

    /// Shipping amount for the rewards chosen by the backer for their location
    public var shippingAmount: ShippingAmount? {
      get {
        return (resultMap["shippingAmount"] as? ResultMap).flatMap { ShippingAmount(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "shippingAmount")
      }
    }

    /// The status of a backing
    public var status: BackingState {
      get {
        return resultMap["status"]! as! BackingState
      }
      set {
        resultMap.updateValue(newValue, forKey: "status")
      }
    }

    public struct Amount: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Money"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MoneyFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(amount: String? = nil, currency: CurrencyCode? = nil, symbol: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Money", "amount": amount, "currency": currency, "symbol": symbol])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var moneyFragment: MoneyFragment {
          get {
            return MoneyFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Backer: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["User"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(UserFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, imageUrl: String, isCreator: Bool? = nil, name: String, uid: String) {
        self.init(unsafeResultMap: ["__typename": "User", "id": id, "imageUrl": imageUrl, "isCreator": isCreator, "name": name, "uid": uid])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var userFragment: UserFragment {
          get {
            return UserFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct BonusAmount: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Money"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MoneyFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(amount: String? = nil, currency: CurrencyCode? = nil, symbol: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Money", "amount": amount, "currency": currency, "symbol": symbol])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var moneyFragment: MoneyFragment {
          get {
            return MoneyFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct CreditCard: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["BankAccount", "CreditCard"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(CreditCardFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeBankAccount() -> CreditCard {
        return CreditCard(unsafeResultMap: ["__typename": "BankAccount"])
      }

      public static func makeCreditCard(expirationDate: String, id: String, lastFour: String, paymentType: CreditCardPaymentType, state: CreditCardState, type: CreditCardTypes) -> CreditCard {
        return CreditCard(unsafeResultMap: ["__typename": "CreditCard", "expirationDate": expirationDate, "id": id, "lastFour": lastFour, "paymentType": paymentType, "state": state, "type": type])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var creditCardFragment: CreditCardFragment {
          get {
            return CreditCardFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Location: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Location"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(LocationFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(country: String, countryName: String? = nil, displayableName: String, id: GraphQLID, name: String) {
        self.init(unsafeResultMap: ["__typename": "Location", "country": country, "countryName": countryName, "displayableName": displayableName, "id": id, "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var locationFragment: LocationFragment {
          get {
            return LocationFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Project: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Project"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(ProjectFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var projectFragment: ProjectFragment {
          get {
            return ProjectFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Reward: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Reward"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(RewardFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var rewardFragment: RewardFragment {
          get {
            return RewardFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct ShippingAmount: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Money"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MoneyFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(amount: String? = nil, currency: CurrencyCode? = nil, symbol: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Money", "amount": amount, "currency": currency, "symbol": symbol])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var moneyFragment: MoneyFragment {
          get {
            return MoneyFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }

  public struct CategoryFragment: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment CategoryFragment on Category {
        __typename
        id
        name
        parentCategory {
          __typename
          id
          name
        }
      }
      """

    public static let possibleTypes: [String] = ["Category"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("parentCategory", type: .object(ParentCategory.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: GraphQLID, name: String, parentCategory: ParentCategory? = nil) {
      self.init(unsafeResultMap: ["__typename": "Category", "id": id, "name": name, "parentCategory": parentCategory.flatMap { (value: ParentCategory) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var id: GraphQLID {
      get {
        return resultMap["id"]! as! GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    /// Category name.
    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

    /// Category parent
    public var parentCategory: ParentCategory? {
      get {
        return (resultMap["parentCategory"] as? ResultMap).flatMap { ParentCategory(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "parentCategory")
      }
    }

    public struct ParentCategory: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Category"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, name: String) {
        self.init(unsafeResultMap: ["__typename": "Category", "id": id, "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// Category name.
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }

  public struct CommentFragment: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment CommentFragment on Comment {
        __typename
        author {
          __typename
          ...UserFragment
        }
        authorBadges
        body
        createdAt
        deleted
        id
        parentId
        replies {
          __typename
          totalCount
        }
      }
      """

    public static let possibleTypes: [String] = ["Comment"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("author", type: .object(Author.selections)),
        GraphQLField("authorBadges", type: .list(.scalar(CommentBadge.self))),
        GraphQLField("body", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAt", type: .scalar(String.self)),
        GraphQLField("deleted", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("parentId", type: .scalar(String.self)),
        GraphQLField("replies", type: .object(Reply.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(author: Author? = nil, authorBadges: [CommentBadge?]? = nil, body: String, createdAt: String? = nil, deleted: Bool, id: GraphQLID, parentId: String? = nil, replies: Reply? = nil) {
      self.init(unsafeResultMap: ["__typename": "Comment", "author": author.flatMap { (value: Author) -> ResultMap in value.resultMap }, "authorBadges": authorBadges, "body": body, "createdAt": createdAt, "deleted": deleted, "id": id, "parentId": parentId, "replies": replies.flatMap { (value: Reply) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The author of the comment
    public var author: Author? {
      get {
        return (resultMap["author"] as? ResultMap).flatMap { Author(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "author")
      }
    }

    /// The badges for the comment author
    public var authorBadges: [CommentBadge?]? {
      get {
        return resultMap["authorBadges"] as? [CommentBadge?]
      }
      set {
        resultMap.updateValue(newValue, forKey: "authorBadges")
      }
    }

    /// The body of the comment
    public var body: String {
      get {
        return resultMap["body"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "body")
      }
    }

    /// When was this comment posted
    public var createdAt: String? {
      get {
        return resultMap["createdAt"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "createdAt")
      }
    }

    /// Whether the comment is deleted
    public var deleted: Bool {
      get {
        return resultMap["deleted"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "deleted")
      }
    }

    public var id: GraphQLID {
      get {
        return resultMap["id"]! as! GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    /// The ID of the parent comment
    public var parentId: String? {
      get {
        return resultMap["parentId"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "parentId")
      }
    }

    /// The replies on a comment
    public var replies: Reply? {
      get {
        return (resultMap["replies"] as? ResultMap).flatMap { Reply(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "replies")
      }
    }

    public struct Author: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["User"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(UserFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, imageUrl: String, isCreator: Bool? = nil, name: String, uid: String) {
        self.init(unsafeResultMap: ["__typename": "User", "id": id, "imageUrl": imageUrl, "isCreator": isCreator, "name": name, "uid": uid])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var userFragment: UserFragment {
          get {
            return UserFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Reply: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["CommentConnection"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("totalCount", type: .nonNull(.scalar(Int.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(totalCount: Int) {
        self.init(unsafeResultMap: ["__typename": "CommentConnection", "totalCount": totalCount])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var totalCount: Int {
        get {
          return resultMap["totalCount"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "totalCount")
        }
      }
    }
  }

  public struct CountryFragment: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment CountryFragment on Country {
        __typename
        code
        name
      }
      """

    public static let possibleTypes: [String] = ["Country"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("code", type: .nonNull(.scalar(CountryCode.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(code: CountryCode, name: String) {
      self.init(unsafeResultMap: ["__typename": "Country", "code": code, "name": name])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// ISO ALPHA-2 code.
    public var code: CountryCode {
      get {
        return resultMap["code"]! as! CountryCode
      }
      set {
        resultMap.updateValue(newValue, forKey: "code")
      }
    }

    /// Country name.
    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }
  }

  public struct CreditCardFragment: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment CreditCardFragment on PaymentSource {
        __typename
        ... on CreditCard {
          expirationDate
          id
          lastFour
          paymentType
          state
          type
        }
      }
      """

    public static let possibleTypes: [String] = ["BankAccount", "CreditCard"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLTypeCase(
          variants: ["CreditCard": AsCreditCard.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeBankAccount() -> CreditCardFragment {
      return CreditCardFragment(unsafeResultMap: ["__typename": "BankAccount"])
    }

    public static func makeCreditCard(expirationDate: String, id: String, lastFour: String, paymentType: CreditCardPaymentType, state: CreditCardState, type: CreditCardTypes) -> CreditCardFragment {
      return CreditCardFragment(unsafeResultMap: ["__typename": "CreditCard", "expirationDate": expirationDate, "id": id, "lastFour": lastFour, "paymentType": paymentType, "state": state, "type": type])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var asCreditCard: AsCreditCard? {
      get {
        if !AsCreditCard.possibleTypes.contains(__typename) { return nil }
        return AsCreditCard(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsCreditCard: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["CreditCard"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("expirationDate", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("lastFour", type: .nonNull(.scalar(String.self))),
          GraphQLField("paymentType", type: .nonNull(.scalar(CreditCardPaymentType.self))),
          GraphQLField("state", type: .nonNull(.scalar(CreditCardState.self))),
          GraphQLField("type", type: .nonNull(.scalar(CreditCardTypes.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(expirationDate: String, id: String, lastFour: String, paymentType: CreditCardPaymentType, state: CreditCardState, type: CreditCardTypes) {
        self.init(unsafeResultMap: ["__typename": "CreditCard", "expirationDate": expirationDate, "id": id, "lastFour": lastFour, "paymentType": paymentType, "state": state, "type": type])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// When the credit card expires.
      public var expirationDate: String {
        get {
          return resultMap["expirationDate"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "expirationDate")
        }
      }

      /// The card ID
      public var id: String {
        get {
          return resultMap["id"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// The last four digits of the credit card number.
      public var lastFour: String {
        get {
          return resultMap["lastFour"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "lastFour")
        }
      }

      /// The card's payment type.
      public var paymentType: CreditCardPaymentType {
        get {
          return resultMap["paymentType"]! as! CreditCardPaymentType
        }
        set {
          resultMap.updateValue(newValue, forKey: "paymentType")
        }
      }

      /// The card's state.
      public var state: CreditCardState {
        get {
          return resultMap["state"]! as! CreditCardState
        }
        set {
          resultMap.updateValue(newValue, forKey: "state")
        }
      }

      /// The card type.
      public var type: CreditCardTypes {
        get {
          return resultMap["type"]! as! CreditCardTypes
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }
    }
  }

  public struct LocationFragment: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment LocationFragment on Location {
        __typename
        country
        countryName
        displayableName
        id
        name
      }
      """

    public static let possibleTypes: [String] = ["Location"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("country", type: .nonNull(.scalar(String.self))),
        GraphQLField("countryName", type: .scalar(String.self)),
        GraphQLField("displayableName", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(country: String, countryName: String? = nil, displayableName: String, id: GraphQLID, name: String) {
      self.init(unsafeResultMap: ["__typename": "Location", "country": country, "countryName": countryName, "displayableName": displayableName, "id": id, "name": name])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The country code.
    public var country: String {
      get {
        return resultMap["country"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "country")
      }
    }

    /// The localized country name.
    public var countryName: String? {
      get {
        return resultMap["countryName"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "countryName")
      }
    }

    /// The displayable name. It includes the state code for US cities. ex: 'Seattle, WA'
    public var displayableName: String {
      get {
        return resultMap["displayableName"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "displayableName")
      }
    }

    public var id: GraphQLID {
      get {
        return resultMap["id"]! as! GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    /// The localized name
    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }
  }

  public struct MoneyFragment: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment MoneyFragment on Money {
        __typename
        amount
        currency
        symbol
      }
      """

    public static let possibleTypes: [String] = ["Money"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("amount", type: .scalar(String.self)),
        GraphQLField("currency", type: .scalar(CurrencyCode.self)),
        GraphQLField("symbol", type: .scalar(String.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(amount: String? = nil, currency: CurrencyCode? = nil, symbol: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "Money", "amount": amount, "currency": currency, "symbol": symbol])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// Floating-point numeric value of monetary amount represented as a string
    public var amount: String? {
      get {
        return resultMap["amount"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "amount")
      }
    }

    /// Currency of the monetary amount
    public var currency: CurrencyCode? {
      get {
        return resultMap["currency"] as? CurrencyCode
      }
      set {
        resultMap.updateValue(newValue, forKey: "currency")
      }
    }

    /// Symbol of the currency in which the monetary amount appears
    public var symbol: String? {
      get {
        return resultMap["symbol"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "symbol")
      }
    }
  }

  public struct ProjectFragment: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment ProjectFragment on Project {
        __typename
        actions {
          __typename
          displayConvertAmount
        }
        backersCount
        category {
          __typename
          ...CategoryFragment
        }
        country {
          __typename
          ...CountryFragment
        }
        creator {
          __typename
          ...UserFragment
        }
        currency
        deadlineAt
        description
        finalCollectionDate
        fxRate
        goal {
          __typename
          ...MoneyFragment
        }
        image {
          __typename
          id
          url(width: 1024)
        }
        isProjectWeLove
        launchedAt
        location {
          __typename
          ...LocationFragment
        }
        name
        pid
        pledged {
          __typename
          ...MoneyFragment
        }
        slug
        state
        stateChangedAt
        url
        usdExchangeRate
      }
      """

    public static let possibleTypes: [String] = ["Project"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("actions", type: .nonNull(.object(Action.selections))),
        GraphQLField("backersCount", type: .nonNull(.scalar(Int.self))),
        GraphQLField("category", type: .object(Category.selections)),
        GraphQLField("country", type: .nonNull(.object(Country.selections))),
        GraphQLField("creator", type: .object(Creator.selections)),
        GraphQLField("currency", type: .nonNull(.scalar(CurrencyCode.self))),
        GraphQLField("deadlineAt", type: .scalar(String.self)),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("finalCollectionDate", type: .scalar(String.self)),
        GraphQLField("fxRate", type: .nonNull(.scalar(Double.self))),
        GraphQLField("goal", type: .object(Goal.selections)),
        GraphQLField("image", type: .object(Image.selections)),
        GraphQLField("isProjectWeLove", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("launchedAt", type: .scalar(String.self)),
        GraphQLField("location", type: .object(Location.selections)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("pid", type: .nonNull(.scalar(Int.self))),
        GraphQLField("pledged", type: .nonNull(.object(Pledged.selections))),
        GraphQLField("slug", type: .nonNull(.scalar(String.self))),
        GraphQLField("state", type: .nonNull(.scalar(ProjectState.self))),
        GraphQLField("stateChangedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("url", type: .nonNull(.scalar(String.self))),
        GraphQLField("usdExchangeRate", type: .scalar(Double.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(actions: Action, backersCount: Int, category: Category? = nil, country: Country, creator: Creator? = nil, currency: CurrencyCode, deadlineAt: String? = nil, description: String, finalCollectionDate: String? = nil, fxRate: Double, goal: Goal? = nil, image: Image? = nil, isProjectWeLove: Bool, launchedAt: String? = nil, location: Location? = nil, name: String, pid: Int, pledged: Pledged, slug: String, state: ProjectState, stateChangedAt: String, url: String, usdExchangeRate: Double? = nil) {
      self.init(unsafeResultMap: ["__typename": "Project", "actions": actions.resultMap, "backersCount": backersCount, "category": category.flatMap { (value: Category) -> ResultMap in value.resultMap }, "country": country.resultMap, "creator": creator.flatMap { (value: Creator) -> ResultMap in value.resultMap }, "currency": currency, "deadlineAt": deadlineAt, "description": description, "finalCollectionDate": finalCollectionDate, "fxRate": fxRate, "goal": goal.flatMap { (value: Goal) -> ResultMap in value.resultMap }, "image": image.flatMap { (value: Image) -> ResultMap in value.resultMap }, "isProjectWeLove": isProjectWeLove, "launchedAt": launchedAt, "location": location.flatMap { (value: Location) -> ResultMap in value.resultMap }, "name": name, "pid": pid, "pledged": pledged.resultMap, "slug": slug, "state": state, "stateChangedAt": stateChangedAt, "url": url, "usdExchangeRate": usdExchangeRate])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// Actions you can currently perform
    public var actions: Action {
      get {
        return Action(unsafeResultMap: resultMap["actions"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "actions")
      }
    }

    /// Total backers for the project
    public var backersCount: Int {
      get {
        return resultMap["backersCount"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "backersCount")
      }
    }

    /// The project's category.
    public var category: Category? {
      get {
        return (resultMap["category"] as? ResultMap).flatMap { Category(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "category")
      }
    }

    /// The project's country
    public var country: Country {
      get {
        return Country(unsafeResultMap: resultMap["country"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "country")
      }
    }

    /// The project's creator.
    public var creator: Creator? {
      get {
        return (resultMap["creator"] as? ResultMap).flatMap { Creator(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "creator")
      }
    }

    /// The project's currency code.
    public var currency: CurrencyCode {
      get {
        return resultMap["currency"]! as! CurrencyCode
      }
      set {
        resultMap.updateValue(newValue, forKey: "currency")
      }
    }

    /// When is the project scheduled to end?
    public var deadlineAt: String? {
      get {
        return resultMap["deadlineAt"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "deadlineAt")
      }
    }

    /// A short description of the project.
    public var description: String {
      get {
        return resultMap["description"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "description")
      }
    }

    /// The date at which pledge collections will end
    public var finalCollectionDate: String? {
      get {
        return resultMap["finalCollectionDate"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "finalCollectionDate")
      }
    }

    /// Exchange rate for the current user's currency
    public var fxRate: Double {
      get {
        return resultMap["fxRate"]! as! Double
      }
      set {
        resultMap.updateValue(newValue, forKey: "fxRate")
      }
    }

    /// The minimum amount to raise for the project to be successful.
    public var goal: Goal? {
      get {
        return (resultMap["goal"] as? ResultMap).flatMap { Goal(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "goal")
      }
    }

    /// The project's primary image.
    public var image: Image? {
      get {
        return (resultMap["image"] as? ResultMap).flatMap { Image(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "image")
      }
    }

    /// Whether or not this is a Kickstarter-featured project.
    public var isProjectWeLove: Bool {
      get {
        return resultMap["isProjectWeLove"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "isProjectWeLove")
      }
    }

    /// When the project launched
    public var launchedAt: String? {
      get {
        return resultMap["launchedAt"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "launchedAt")
      }
    }

    /// Where the project is based.
    public var location: Location? {
      get {
        return (resultMap["location"] as? ResultMap).flatMap { Location(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "location")
      }
    }

    /// The project's name.
    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

    /// The project's pid.
    public var pid: Int {
      get {
        return resultMap["pid"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "pid")
      }
    }

    /// How much money is pledged to the project.
    public var pledged: Pledged {
      get {
        return Pledged(unsafeResultMap: resultMap["pledged"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "pledged")
      }
    }

    /// The project's unique URL identifier.
    public var slug: String {
      get {
        return resultMap["slug"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "slug")
      }
    }

    /// The project's current state.
    public var state: ProjectState {
      get {
        return resultMap["state"]! as! ProjectState
      }
      set {
        resultMap.updateValue(newValue, forKey: "state")
      }
    }

    /// The last time a project's state changed, time since epoch
    public var stateChangedAt: String {
      get {
        return resultMap["stateChangedAt"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "stateChangedAt")
      }
    }

    /// A URL to the project's page.
    public var url: String {
      get {
        return resultMap["url"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "url")
      }
    }

    /// Exchange rate to US Dollars (USD), null for draft projects.
    public var usdExchangeRate: Double? {
      get {
        return resultMap["usdExchangeRate"] as? Double
      }
      set {
        resultMap.updateValue(newValue, forKey: "usdExchangeRate")
      }
    }

    public struct Action: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ProjectActions"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("displayConvertAmount", type: .nonNull(.scalar(Bool.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(displayConvertAmount: Bool) {
        self.init(unsafeResultMap: ["__typename": "ProjectActions", "displayConvertAmount": displayConvertAmount])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Whether or not the user is in a state to see currency conversions
      public var displayConvertAmount: Bool {
        get {
          return resultMap["displayConvertAmount"]! as! Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "displayConvertAmount")
        }
      }
    }

    public struct Category: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Category"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(CategoryFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var categoryFragment: CategoryFragment {
          get {
            return CategoryFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Country: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Country"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(CountryFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(code: CountryCode, name: String) {
        self.init(unsafeResultMap: ["__typename": "Country", "code": code, "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var countryFragment: CountryFragment {
          get {
            return CountryFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Creator: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["User"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(UserFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, imageUrl: String, isCreator: Bool? = nil, name: String, uid: String) {
        self.init(unsafeResultMap: ["__typename": "User", "id": id, "imageUrl": imageUrl, "isCreator": isCreator, "name": name, "uid": uid])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var userFragment: UserFragment {
          get {
            return UserFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Goal: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Money"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MoneyFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(amount: String? = nil, currency: CurrencyCode? = nil, symbol: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Money", "amount": amount, "currency": currency, "symbol": symbol])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var moneyFragment: MoneyFragment {
          get {
            return MoneyFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Image: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Photo"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("url", arguments: ["width": 1024], type: .scalar(String.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, url: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Photo", "id": id, "url": url])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// URL of the photo
      public var url: String? {
        get {
          return resultMap["url"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "url")
        }
      }
    }

    public struct Location: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Location"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(LocationFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(country: String, countryName: String? = nil, displayableName: String, id: GraphQLID, name: String) {
        self.init(unsafeResultMap: ["__typename": "Location", "country": country, "countryName": countryName, "displayableName": displayableName, "id": id, "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var locationFragment: LocationFragment {
          get {
            return LocationFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Pledged: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Money"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MoneyFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(amount: String? = nil, currency: CurrencyCode? = nil, symbol: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Money", "amount": amount, "currency": currency, "symbol": symbol])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var moneyFragment: MoneyFragment {
          get {
            return MoneyFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }

  public struct RewardFragment: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment RewardFragment on Reward {
        __typename
        amount {
          __typename
          ...MoneyFragment
        }
        backersCount
        convertedAmount {
          __typename
          ...MoneyFragment
        }
        description
        displayName
        endsAt
        estimatedDeliveryOn
        id
        isMaxPledge
        items {
          __typename
          nodes {
            __typename
            id
            name
          }
        }
        limit
        limitPerBacker
        name
        project {
          __typename
          id
        }
        remainingQuantity
        shippingPreference
        shippingRules {
          __typename
          ...ShippingRuleFragment
        }
        startsAt
      }
      """

    public static let possibleTypes: [String] = ["Reward"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("amount", type: .nonNull(.object(Amount.selections))),
        GraphQLField("backersCount", type: .scalar(Int.self)),
        GraphQLField("convertedAmount", type: .nonNull(.object(ConvertedAmount.selections))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
        GraphQLField("endsAt", type: .scalar(String.self)),
        GraphQLField("estimatedDeliveryOn", type: .scalar(String.self)),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("isMaxPledge", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("items", type: .object(Item.selections)),
        GraphQLField("limit", type: .scalar(Int.self)),
        GraphQLField("limitPerBacker", type: .scalar(Int.self)),
        GraphQLField("name", type: .scalar(String.self)),
        GraphQLField("project", type: .object(Project.selections)),
        GraphQLField("remainingQuantity", type: .scalar(Int.self)),
        GraphQLField("shippingPreference", type: .scalar(ShippingPreference.self)),
        GraphQLField("shippingRules", type: .nonNull(.list(.object(ShippingRule.selections)))),
        GraphQLField("startsAt", type: .scalar(String.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(amount: Amount, backersCount: Int? = nil, convertedAmount: ConvertedAmount, description: String, displayName: String, endsAt: String? = nil, estimatedDeliveryOn: String? = nil, id: GraphQLID, isMaxPledge: Bool, items: Item? = nil, limit: Int? = nil, limitPerBacker: Int? = nil, name: String? = nil, project: Project? = nil, remainingQuantity: Int? = nil, shippingPreference: ShippingPreference? = nil, shippingRules: [ShippingRule?], startsAt: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "Reward", "amount": amount.resultMap, "backersCount": backersCount, "convertedAmount": convertedAmount.resultMap, "description": description, "displayName": displayName, "endsAt": endsAt, "estimatedDeliveryOn": estimatedDeliveryOn, "id": id, "isMaxPledge": isMaxPledge, "items": items.flatMap { (value: Item) -> ResultMap in value.resultMap }, "limit": limit, "limitPerBacker": limitPerBacker, "name": name, "project": project.flatMap { (value: Project) -> ResultMap in value.resultMap }, "remainingQuantity": remainingQuantity, "shippingPreference": shippingPreference, "shippingRules": shippingRules.map { (value: ShippingRule?) -> ResultMap? in value.flatMap { (value: ShippingRule) -> ResultMap in value.resultMap } }, "startsAt": startsAt])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// Amount for claiming this reward.
    public var amount: Amount {
      get {
        return Amount(unsafeResultMap: resultMap["amount"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "amount")
      }
    }

    /// count of backers for this reward
    public var backersCount: Int? {
      get {
        return resultMap["backersCount"] as? Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "backersCount")
      }
    }

    /// Amount for claiming this reward, in the current user's chosen currency
    public var convertedAmount: ConvertedAmount {
      get {
        return ConvertedAmount(unsafeResultMap: resultMap["convertedAmount"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "convertedAmount")
      }
    }

    /// A reward description.
    public var description: String {
      get {
        return resultMap["description"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "description")
      }
    }

    /// A reward's title plus the amount, or a default title (the reward amount) if it doesn't have a title.
    public var displayName: String {
      get {
        return resultMap["displayName"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "displayName")
      }
    }

    /// When the reward is scheduled to end
    public var endsAt: String? {
      get {
        return resultMap["endsAt"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "endsAt")
      }
    }

    /// Estimated delivery day.
    public var estimatedDeliveryOn: String? {
      get {
        return resultMap["estimatedDeliveryOn"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "estimatedDeliveryOn")
      }
    }

    public var id: GraphQLID {
      get {
        return resultMap["id"]! as! GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    /// Does reward amount meet or exceed maximum pledge for the project
    public var isMaxPledge: Bool {
      get {
        return resultMap["isMaxPledge"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "isMaxPledge")
      }
    }

    /// Items in the reward.
    public var items: Item? {
      get {
        return (resultMap["items"] as? ResultMap).flatMap { Item(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "items")
      }
    }

    /// A reward limit.
    public var limit: Int? {
      get {
        return resultMap["limit"] as? Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "limit")
      }
    }

    /// Per backer reward limit.
    public var limitPerBacker: Int? {
      get {
        return resultMap["limitPerBacker"] as? Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "limitPerBacker")
      }
    }

    /// A reward title.
    public var name: String? {
      get {
        return resultMap["name"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

    /// The project
    public var project: Project? {
      get {
        return (resultMap["project"] as? ResultMap).flatMap { Project(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "project")
      }
    }

    /// Remaining reward quantity.
    public var remainingQuantity: Int? {
      get {
        return resultMap["remainingQuantity"] as? Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "remainingQuantity")
      }
    }

    /// Shipping preference for this reward
    public var shippingPreference: ShippingPreference? {
      get {
        return resultMap["shippingPreference"] as? ShippingPreference
      }
      set {
        resultMap.updateValue(newValue, forKey: "shippingPreference")
      }
    }

    /// Shipping rules defined by the creator for this reward
    public var shippingRules: [ShippingRule?] {
      get {
        return (resultMap["shippingRules"] as! [ResultMap?]).map { (value: ResultMap?) -> ShippingRule? in value.flatMap { (value: ResultMap) -> ShippingRule in ShippingRule(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.map { (value: ShippingRule?) -> ResultMap? in value.flatMap { (value: ShippingRule) -> ResultMap in value.resultMap } }, forKey: "shippingRules")
      }
    }

    /// When the reward is scheduled to start
    public var startsAt: String? {
      get {
        return resultMap["startsAt"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "startsAt")
      }
    }

    public struct Amount: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Money"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MoneyFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(amount: String? = nil, currency: CurrencyCode? = nil, symbol: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Money", "amount": amount, "currency": currency, "symbol": symbol])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var moneyFragment: MoneyFragment {
          get {
            return MoneyFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct ConvertedAmount: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Money"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MoneyFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(amount: String? = nil, currency: CurrencyCode? = nil, symbol: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Money", "amount": amount, "currency": currency, "symbol": symbol])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var moneyFragment: MoneyFragment {
          get {
            return MoneyFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Item: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["RewardItemsConnection"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nodes", type: .list(.object(Node.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(nodes: [Node?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "RewardItemsConnection", "nodes": nodes.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// A list of nodes.
      public var nodes: [Node?]? {
        get {
          return (resultMap["nodes"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Node?] in value.map { (value: ResultMap?) -> Node? in value.flatMap { (value: ResultMap) -> Node in Node(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }, forKey: "nodes")
        }
      }

      public struct Node: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["RewardItem"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .scalar(String.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, name: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "RewardItem", "id": id, "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        /// An item name.
        public var name: String? {
          get {
            return resultMap["name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }
      }
    }

    public struct Project: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Project"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "Project", "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }
    }

    public struct ShippingRule: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ShippingRule"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(ShippingRuleFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var shippingRuleFragment: ShippingRuleFragment {
          get {
            return ShippingRuleFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }

  public struct ShippingRuleFragment: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment ShippingRuleFragment on ShippingRule {
        __typename
        cost {
          __typename
          ...MoneyFragment
        }
        id
        location {
          __typename
          ...LocationFragment
        }
      }
      """

    public static let possibleTypes: [String] = ["ShippingRule"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("cost", type: .object(Cost.selections)),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .object(Location.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(cost: Cost? = nil, id: GraphQLID, location: Location? = nil) {
      self.init(unsafeResultMap: ["__typename": "ShippingRule", "cost": cost.flatMap { (value: Cost) -> ResultMap in value.resultMap }, "id": id, "location": location.flatMap { (value: Location) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The shipping cost for this location.
    public var cost: Cost? {
      get {
        return (resultMap["cost"] as? ResultMap).flatMap { Cost(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "cost")
      }
    }

    public var id: GraphQLID {
      get {
        return resultMap["id"]! as! GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    /// The shipping location to which the rule pertains.
    public var location: Location? {
      get {
        return (resultMap["location"] as? ResultMap).flatMap { Location(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "location")
      }
    }

    public struct Cost: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Money"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MoneyFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(amount: String? = nil, currency: CurrencyCode? = nil, symbol: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Money", "amount": amount, "currency": currency, "symbol": symbol])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var moneyFragment: MoneyFragment {
          get {
            return MoneyFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Location: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Location"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(LocationFragment.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(country: String, countryName: String? = nil, displayableName: String, id: GraphQLID, name: String) {
        self.init(unsafeResultMap: ["__typename": "Location", "country": country, "countryName": countryName, "displayableName": displayableName, "id": id, "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var locationFragment: LocationFragment {
          get {
            return LocationFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }

  public struct UserFragment: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment UserFragment on User {
        __typename
        id
        imageUrl: imageUrl(blur: false, width: 1024)
        isCreator
        name
        uid
      }
      """

    public static let possibleTypes: [String] = ["User"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("imageUrl", alias: "imageUrl", arguments: ["blur": false, "width": 1024], type: .nonNull(.scalar(String.self))),
        GraphQLField("isCreator", type: .scalar(Bool.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("uid", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: GraphQLID, imageUrl: String, isCreator: Bool? = nil, name: String, uid: String) {
      self.init(unsafeResultMap: ["__typename": "User", "id": id, "imageUrl": imageUrl, "isCreator": isCreator, "name": name, "uid": uid])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var id: GraphQLID {
      get {
        return resultMap["id"]! as! GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    /// The user's avatar.
    public var imageUrl: String {
      get {
        return resultMap["imageUrl"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "imageUrl")
      }
    }

    /// Whether a user is a creator
    public var isCreator: Bool? {
      get {
        return resultMap["isCreator"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "isCreator")
      }
    }

    /// The user's provided name.
    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

    /// A user's uid
    public var uid: String {
      get {
        return resultMap["uid"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "uid")
      }
    }
  }
}
