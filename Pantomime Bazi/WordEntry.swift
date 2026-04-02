//
//  WordEntry.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//

import Foundation

struct WordEntry: Identifiable {
    let id: UUID
    let display: String
    let category: WordCategory
    let points: Int
    let hint: String?         // English acting hint
    let hintPersian: String?  // Persian acting hint
    let isCustom: Bool
    let _english: String
    let _persian: String

    // DB word (two languages)
    init(english: String, persian: String, category: WordCategory, points: Int,
         hint: String? = nil, hintPersian: String? = nil) {
        self.id = UUID()
        self.display = english
        self.category = category
        self.points = points
        self.hint = hint
        self.hintPersian = hintPersian
        self.isCustom = false
        self._english = english
        self._persian = persian
    }

    // Custom word (ephemeral, single language, always 9 pts, no hint)
    init(customText: String) {
        self.id = UUID()
        self.display = customText
        self.category = .everyday
        self.points = 9
        self.hint = nil
        self.hintPersian = nil
        self.isCustom = true
        self._english = customText
        self._persian = customText
    }

    func displayText(language: AppLanguage) -> String {
        isCustom ? display : (language == .persian ? _persian : _english)
    }

    func hintText(language: AppLanguage) -> String? {
        language == .persian ? (hintPersian ?? hint) : hint
    }
}


enum AppLanguage: String, CaseIterable {
    case english = "EN"
    case persian = "FA"
    var isRTL: Bool { self == .persian }
    var flagEmoji: String { self == .english ? "🇺🇸" : "🇮🇷" }
    var label: String { self == .english ? "EN" : "فا" }
}

enum WordCategory: String, CaseIterable, Identifiable {
    case animals     = "Animals"
    case actions     = "Actions"
    case professions = "Professions"
    case movies      = "Movies & TV"
    case food        = "Food"
    case sports      = "Sports"
    case everyday    = "Everyday Life"
    case nature      = "Nature"
    case emotions    = "Emotions"
    case famous      = "Famous People"

    var id: String { rawValue }

    var persianName: String {
        switch self {
        case .animals:     return "حیوانات"
        case .actions:     return "حرکات"
        case .professions: return "مشاغل"
        case .movies:      return "فیلم و سریال"
        case .food:        return "غذا"
        case .sports:      return "ورزش"
        case .everyday:    return "زندگی روزمره"
        case .nature:      return "طبیعت"
        case .emotions:    return "احساسات"
        case .famous:      return "افراد مشهور"
        }
    }

    var emoji: String {
        switch self {
        case .animals:     return "🐾"
        case .actions:     return "🏃"
        case .professions: return "👩‍💼"
        case .movies:      return "🎬"
        case .food:        return "🍕"
        case .sports:      return "⚽"
        case .everyday:    return "🏠"
        case .nature:      return "🌿"
        case .emotions:    return "😄"
        case .famous:      return "⭐"
        }
    }
}

// MARK: - Word Database
// Points: 3 = easy, 5 = medium, 7 = hard (with hint)

let wordDatabase: [WordEntry] = [

    // ── ANIMALS ──────────────────────────────────────────
    WordEntry(english: "Penguin",    persian: "پنگوئن",   category: .animals, points: 3),
    WordEntry(english: "Elephant",   persian: "فیل",      category: .animals, points: 3),
    WordEntry(english: "Monkey",     persian: "میمون",    category: .animals, points: 3),
    WordEntry(english: "Duck",       persian: "اردک",     category: .animals, points: 3),
    WordEntry(english: "Bear",       persian: "خرس",      category: .animals, points: 3),
    WordEntry(english: "Lion",       persian: "شیر",      category: .animals, points: 3),
    WordEntry(english: "Frog",       persian: "قورباغه",  category: .animals, points: 3),
    WordEntry(english: "Butterfly",  persian: "پروانه",   category: .animals, points: 3),

    WordEntry(english: "Kangaroo",   persian: "کانگارو",  category: .animals, points: 5),
    WordEntry(english: "Flamingo",   persian: "فلامینگو", category: .animals, points: 5),
    WordEntry(english: "Crocodile",  persian: "تمساح",   category: .animals, points: 5),
    WordEntry(english: "Giraffe",    persian: "زرافه",    category: .animals, points: 5),
    WordEntry(english: "Parrot",     persian: "طوطی",     category: .animals, points: 5),
    WordEntry(english: "Dolphin",    persian: "دلفین",    category: .animals, points: 5),
    WordEntry(english: "Peacock",    persian: "طاووس",    category: .animals, points: 5),
    WordEntry(english: "Camel",      persian: "شتر",      category: .animals, points: 5),

    WordEntry(english: "Crab",       persian: "خرچنگ",   category: .animals, points: 7,
              hint: "Move sideways with your hands like claws snapping", hintPersian: "با دستانت به پهلو حرکت کن مثل چنگال‌هایی که قطع می‌کنند"),
    WordEntry(english: "Spider",     persian: "عنکبوت",  category: .animals, points: 7,
              hint: "Eight legs — use all four limbs and wiggle fingers as extra legs", hintPersian: "هشت پا — از هر چهار اندامت استفاده کن و انگشتانت را مثل پاهای اضافه تکان بده"),
    WordEntry(english: "Gorilla",    persian: "گوریل",   category: .animals, points: 7,
              hint: "Walk on knuckles and beat chest dramatically", hintPersian: "روی بند انگشتانت راه برو و با دراماتیک بودن سینه‌ات را بزن"),
    WordEntry(english: "Snake",      persian: "مار",      category: .animals, points: 7,
              hint: "Slither on the floor and flick your tongue", hintPersian: "روی زمین بلغز و زبانت را بیرون بینداز"),

    // ── ACTIONS ──────────────────────────────────────────
    WordEntry(english: "Sleeping",        persian: "خوابیدن",        category: .actions, points: 3),
    WordEntry(english: "Crying",          persian: "گریه کردن",      category: .actions, points: 3),
    WordEntry(english: "Running",         persian: "دویدن",           category: .actions, points: 3),
    WordEntry(english: "Dancing",         persian: "رقصیدن",          category: .actions, points: 3),
    WordEntry(english: "Swimming",        persian: "شنا کردن",        category: .actions, points: 3),
    WordEntry(english: "Yawning",         persian: "خمیازه کشیدن",   category: .actions, points: 3),
    WordEntry(english: "Sneezing",        persian: "عطسه کردن",      category: .actions, points: 3),

    WordEntry(english: "Cooking",         persian: "آشپزی کردن",     category: .actions, points: 5),
    WordEntry(english: "Driving",         persian: "رانندگی کردن",   category: .actions, points: 5),
    WordEntry(english: "Painting",        persian: "نقاشی کردن",     category: .actions, points: 5),
    WordEntry(english: "Praying",         persian: "نماز خواندن",    category: .actions, points: 5),
    WordEntry(english: "Ironing clothes", persian: "اتو کردن لباس",  category: .actions, points: 5),
    WordEntry(english: "Brushing teeth",  persian: "مسواک زدن",      category: .actions, points: 5),
    WordEntry(english: "Taking a selfie", persian: "سلفی گرفتن",     category: .actions, points: 5),
    WordEntry(english: "Whistling",       persian: "سوت زدن",        category: .actions, points: 5),

    WordEntry(english: "Knitting",        persian: "بافتنی بافتن",   category: .actions, points: 7,
              hint: "Move fingers rapidly as if weaving with two invisible needles", hintPersian: "انگشتانت را سریع حرکت بده انگار با دو سوزن نامرئی می‌بافی"),
    WordEntry(english: "Rock climbing",   persian: "کوه‌نوردی",      category: .actions, points: 7,
              hint: "Grip an imaginary wall above you and pull yourself up slowly", hintPersian: "یه دیوار خیالی بالای سرت را بگیر و خودت را آهسته بالا بکش"),
    WordEntry(english: "Skipping rope",   persian: "طناب زدن",       category: .actions, points: 7,
              hint: "Spin both arms in circles at your sides and jump repeatedly", hintPersian: "هر دو بازویت را در دایره در کنارت بچرخان و مکرراً بپر"),
    WordEntry(english: "Arguing",         persian: "دعوا کردن",      category: .actions, points: 7,
              hint: "Point finger aggressively at an imaginary person, mouth moving but no sound", hintPersian: "با خشم به یه نفر خیالی اشاره کن، دهانت حرکت کنه ولی صدا نباشه"),
    WordEntry(english: "Shaving",         persian: "ریش تراشیدن",    category: .actions, points: 7,
              hint: "Mime lathering your face then dragging a razor upward in slow strokes", hintPersian: "انگار صورتت را کف‌آلود می‌کنی و بعد تیغ را به آرامی بالا می‌کشی"),

    // ── PROFESSIONS ──────────────────────────────────────
    WordEntry(english: "Chef",        persian: "آشپز",       category: .professions, points: 3),
    WordEntry(english: "Teacher",     persian: "معلم",       category: .professions, points: 3),
    WordEntry(english: "Nurse",       persian: "پرستار",     category: .professions, points: 3),
    WordEntry(english: "Pilot",       persian: "خلبان",      category: .professions, points: 3),

    WordEntry(english: "Dentist",      persian: "دندانپزشک", category: .professions, points: 5),
    WordEntry(english: "Firefighter",  persian: "آتش‌نشان",  category: .professions, points: 5),
    WordEntry(english: "Hairdresser",  persian: "آرایشگر",   category: .professions, points: 5),
    WordEntry(english: "Photographer", persian: "عکاس",      category: .professions, points: 5),
    WordEntry(english: "Fisherman",    persian: "ماهیگیر",   category: .professions, points: 5),
    WordEntry(english: "Carpenter",    persian: "نجار",      category: .professions, points: 5),
    WordEntry(english: "Musician",     persian: "نوازنده",   category: .professions, points: 5),
    WordEntry(english: "Judge",        persian: "قاضی",      category: .professions, points: 5),

    WordEntry(english: "Magician",    persian: "جادوگر",    category: .professions, points: 7,
              hint: "Pull something from an invisible hat, wave a wand, look amazed at the result", hintPersian: "از کلاه نامرئی چیزی بیرون بکش، عصا را تکان بده، با تعجب به نتیجه نگاه کن"),
    WordEntry(english: "Surgeon",     persian: "جراح",      category: .professions, points: 7,
              hint: "Mime washing hands carefully, then cut an invisible patient open with extreme precision", hintPersian: "دستانت را با دقت بشور، بعد با دقت فوق‌العاده یه بیمار نامرئی را برش بده"),
    WordEntry(english: "Astronaut",   persian: "فضانورد",   category: .professions, points: 7,
              hint: "Walk in slow-motion bouncing steps as if in zero gravity, look through a helmet visor", hintPersian: "با قدم‌های آهسته و پرشی مثل بی‌وزنی راه برو، از ویزور کلاه به بیرون نگاه کن"),

    // ── MOVIES & TV ──────────────────────────────────────
    WordEntry(english: "Titanic",        persian: "تایتانیک",      category: .movies, points: 3),
    WordEntry(english: "Home Alone",     persian: "تنها در خانه",   category: .movies, points: 3),
    WordEntry(english: "The Lion King",  persian: "شاه شیر",        category: .movies, points: 3),
    WordEntry(english: "Shrek",          persian: "شرک",             category: .movies, points: 3),
    WordEntry(english: "Frozen",         persian: "یخ‌زده",          category: .movies, points: 3),

    WordEntry(english: "The Godfather",   persian: "پدرخوانده",       category: .movies, points: 5),
    WordEntry(english: "Jurassic Park",   persian: "پارک ژوراسیک",   category: .movies, points: 5),
    WordEntry(english: "Forrest Gump",    persian: "فارست گامپ",     category: .movies, points: 5),
    WordEntry(english: "Spider-Man",      persian: "مرد عنکبوتی",    category: .movies, points: 5),
    WordEntry(english: "Gladiator",       persian: "گلادیاتور",       category: .movies, points: 5),
    WordEntry(english: "Harry Potter",    persian: "هری پاتر",        category: .movies, points: 5),
    WordEntry(english: "The Avengers",    persian: "انتقام‌جویان",    category: .movies, points: 5),

    WordEntry(english: "The Matrix",     persian: "ماتریکس",         category: .movies, points: 7,
              hint: "Dodge bullets in slow motion, then look at two pills in your palm", hintPersian: "از گلوله‌ها در حرکت آهسته دور بشو، بعد به دو قرص در کف دستت نگاه کن"),
    WordEntry(english: "Schindler's List", persian: "فهرست شیندلر",  category: .movies, points: 7,
              hint: "Write names on a long imaginary list with a trembling hand, looking deeply sad", hintPersian: "با دست لرزان اسامی روی یه لیست طولانی خیالی بنویس، با عمیق‌ترین غم نگاه کن"),
    WordEntry(english: "Interstellar",   persian: "بین‌ستاره‌ای",    category: .movies, points: 7,
              hint: "Float through a wormhole, then reach through a bookshelf trying to touch someone", hintPersian: "از یه سیاهچاله عبور کن، بعد از قفسه کتاب دستت را درآور و سعی کن به کسی دست بزنی"),

    // ── FOOD ─────────────────────────────────────────────
    WordEntry(english: "Pizza",       persian: "پیتزا",      category: .food, points: 3),
    WordEntry(english: "Ice cream",   persian: "بستنی",      category: .food, points: 3),
    WordEntry(english: "Kebab",       persian: "کباب",       category: .food, points: 3),
    WordEntry(english: "Popcorn",     persian: "پاپ‌کورن",   category: .food, points: 3),
    WordEntry(english: "Watermelon",  persian: "هندوانه",    category: .food, points: 3),

    WordEntry(english: "Spaghetti",       persian: "اسپاگتی",    category: .food, points: 5),
    WordEntry(english: "Ghormeh Sabzi",   persian: "قورمه‌سبزی", category: .food, points: 5),
    WordEntry(english: "Baklava",         persian: "باقلوا",     category: .food, points: 5),
    WordEntry(english: "Hot dog",         persian: "هات داگ",    category: .food, points: 5),
    WordEntry(english: "Sushi",           persian: "سوشی",       category: .food, points: 5),
    WordEntry(english: "Sandwich",        persian: "ساندویچ",    category: .food, points: 5),

    WordEntry(english: "Ash Reshteh",   persian: "آش رشته",   category: .food, points: 7,
              hint: "Mime stirring a giant pot, then blow on the spoon and slurp noodles loudly", hintPersian: "یه دیگ بزرگ را هم بزن، روی قاشق فوت کن و با صدا رشته بخور"),
    WordEntry(english: "Cotton candy",  persian: "پشمک",       category: .food, points: 7,
              hint: "Spin an imaginary stick in slow circles gathering fluff, then pull pieces off gently", hintPersian: "یه چوب خیالی را آهسته در دایره بچرخان که پنبه جمع می‌شه، بعد آرام تکه‌هایش را بکن"),
    WordEntry(english: "Tahdig",        persian: "ته‌دیگ",     category: .food, points: 7,
              hint: "Flip an imaginary pot upside down, look down at it with pure pride and excitement", hintPersian: "یه دیگ خیالی را وارونه کن، با غرور و هیجان خالص به آن نگاه کن"),
    WordEntry(english: "Pomegranate",   persian: "انار",       category: .food, points: 7,
              hint: "Mime rolling a round fruit then cutting it open and picking out tiny seeds one by one", hintPersian: "یه میوه گرد خیالی را غلت بده، بعد ببُرش و دانه‌های کوچک را یکی‌یکی دربیار"),

    // ── SPORTS ───────────────────────────────────────────
    WordEntry(english: "Soccer",      persian: "فوتبال",    category: .sports, points: 3),
    WordEntry(english: "Basketball",  persian: "بسکتبال",   category: .sports, points: 3),
    WordEntry(english: "Boxing",      persian: "بوکس",      category: .sports, points: 3),
    WordEntry(english: "Swimming",    persian: "شنا",       category: .sports, points: 3),

    WordEntry(english: "Wrestling",        persian: "کشتی",              category: .sports, points: 5),
    WordEntry(english: "Table tennis",     persian: "پینگ‌پونگ",         category: .sports, points: 5),
    WordEntry(english: "Gymnastics",       persian: "ژیمناستیک",         category: .sports, points: 5),
    WordEntry(english: "Skiing",           persian: "اسکی",              category: .sports, points: 5),
    WordEntry(english: "Volleyball",       persian: "والیبال",            category: .sports, points: 5),
    WordEntry(english: "Cycling",          persian: "دوچرخه‌سواری",      category: .sports, points: 5),

    WordEntry(english: "Archery",      persian: "تیراندازی با کمان", category: .sports, points: 7,
              hint: "Pull back an imaginary bowstring slowly, aim one eye closed, then release with a snap", hintPersian: "زه یه کمان خیالی را آهسته بکش، با یه چشم بسته نشانه برو، بعد رهاش کن"),
    WordEntry(english: "Weightlifting", persian: "وزنه‌برداری",      category: .sports, points: 7,
              hint: "Squat deep, grip a bar, then heave it above your head and freeze — face strained", hintPersian: "عمیق اسکات کن، میله را بگیر، بعد آن را بالای سرت بلند کن و فریز شو — صورتت تنگ"),
    WordEntry(english: "Horse riding",  persian: "اسب‌سواری",        category: .sports, points: 7,
              hint: "Bounce up and down rhythmically, hold invisible reins, lean forward as if galloping", hintPersian: "ریتمیک بالا و پایین برو، عنان نامرئی را نگه دار، به جلو خم شو انگار داری می‌تازی"),
    WordEntry(english: "Karate",       persian: "کاراته",            category: .sports, points: 7,
              hint: "Stand in a wide stance, chop the air with sharp precise movements, then bow", hintPersian: "با پاهای باز بایست، هوا را با حرکات تیز دقیق ببُر، بعد تعظیم کن"),

    // ── EVERYDAY LIFE ────────────────────────────────────
    WordEntry(english: "Wedding",       persian: "عروسی",      category: .everyday, points: 3),
    WordEntry(english: "Hospital",      persian: "بیمارستان",  category: .everyday, points: 3),
    WordEntry(english: "Airport",       persian: "فرودگاه",    category: .everyday, points: 3),
    WordEntry(english: "Supermarket",   persian: "سوپرمارکت", category: .everyday, points: 3),

    WordEntry(english: "Traffic jam",    persian: "ترافیک",         category: .everyday, points: 5),
    WordEntry(english: "Alarm clock",    persian: "ساعت زنگ‌دار",   category: .everyday, points: 5),
    WordEntry(english: "Elevator",       persian: "آسانسور",        category: .everyday, points: 5),
    WordEntry(english: "Birthday party", persian: "جشن تولد",       category: .everyday, points: 5),
    WordEntry(english: "Barber shop",    persian: "آرایشگاه",       category: .everyday, points: 5),
    WordEntry(english: "Gas station",    persian: "پمپ بنزین",      category: .everyday, points: 5),
    WordEntry(english: "Pharmacy",       persian: "داروخانه",       category: .everyday, points: 5),

    WordEntry(english: "Power outage",  persian: "قطع برق",      category: .everyday, points: 7,
              hint: "Flick a switch that does nothing, look confused, then mime stumbling in the dark", hintPersian: "کلیدی را بزن که هیچ اتفاقی نمی‌افتد، گیج نگاه کن، بعد در تاریکی دست‌وپا بزن"),
    WordEntry(english: "Moving house",  persian: "اسباب‌کشی",   category: .everyday, points: 7,
              hint: "Carry heavy invisible boxes, huff and puff, then drop one and look relieved", hintPersian: "جعبه‌های سنگین نامرئی را حمل کن، نفس‌نفس بزن، بعد یکی را بینداز و سبک‌سنگین نگاه کن"),
    WordEntry(english: "Parking lot",   persian: "پارکینگ",      category: .everyday, points: 7,
              hint: "Drive in circles, signal left and right, look frustrated, then squeeze into a tiny space", hintPersian: "در دایره رانندگی کن، راهنما بده، ناامید نگاه کن، بعد در یه جای کوچک جا بگیر"),
    WordEntry(english: "Laundry",       persian: "لباسشویی",     category: .everyday, points: 7,
              hint: "Stuff invisible clothes into a drum, close door, mime turning dial then hang clothes", hintPersian: "لباس‌های نامرئی را در ماشین بریز، در را ببند، دکمه را بچرخان بعد لباس‌ها را آویزان کن"),

    // ── NATURE ───────────────────────────────────────────
    WordEntry(english: "Rainbow",   persian: "رنگین‌کمان",  category: .nature, points: 3),
    WordEntry(english: "Sunset",    persian: "غروب آفتاب",  category: .nature, points: 3),
    WordEntry(english: "Jungle",    persian: "جنگل",        category: .nature, points: 3),
    WordEntry(english: "Desert",    persian: "بیابان",      category: .nature, points: 3),

    WordEntry(english: "Waterfall",    persian: "آبشار",          category: .nature, points: 5),
    WordEntry(english: "Tornado",      persian: "گردباد",         category: .nature, points: 5),
    WordEntry(english: "Snowstorm",    persian: "کولاک",          category: .nature, points: 5),
    WordEntry(english: "Lightning",    persian: "صاعقه",          category: .nature, points: 5),
    WordEntry(english: "Oasis",        persian: "واحه",           category: .nature, points: 5),

    WordEntry(english: "Earthquake",  persian: "زلزله",          category: .nature, points: 7,
              hint: "Shake your whole body violently, then mime objects falling and duck for cover", hintPersian: "تمام بدنت را به شدت تکان بده، بعد اشیاء افتادن را نشان بده و زیر چیزی پناه ببر"),
    WordEntry(english: "Volcano",     persian: "آتشفشان",        category: .nature, points: 7,
              hint: "Start with arms pointing up to a peak, then spread them wide as lava erupts outward", hintPersian: "با دست‌هایی که به قله اشاره می‌کنند شروع کن، بعد آن‌ها را گسترش بده مثل گدازه‌ای که فوران می‌کند"),
    WordEntry(english: "Avalanche",   persian: "بهمن",           category: .nature, points: 7,
              hint: "Start walking uphill then suddenly spread arms wide and tumble forward in slow motion", hintPersian: "از سربالایی شروع کن، بعد ناگهان دستانت را گسترش بده و در آهسته به جلو بچرخ"),
    WordEntry(english: "Glacier",     persian: "یخچال طبیعی",   category: .nature, points: 7,
              hint: "Move in extreme slow motion like a heavy river of ice, arms carving a path", hintPersian: "در حرکت آهسته افراطی مثل رودخانه‌ای سنگین از یخ حرکت کن، دستانت مسیر را حک می‌کنند"),
    WordEntry(english: "Tide",        persian: "جزر و مد",      category: .nature, points: 7,
              hint: "Wave your arms forward then pull them back rhythmically like water advancing and retreating", hintPersian: "دستانت را به جلو تکان بده بعد ریتمیک عقب بکش مثل آبی که پیش می‌رود و عقب می‌کشد"),

    // ── EMOTIONS ─────────────────────────────────────────
    WordEntry(english: "Happiness",  persian: "شادی",    category: .emotions, points: 3),
    WordEntry(english: "Fear",       persian: "ترس",     category: .emotions, points: 3),
    WordEntry(english: "Anger",      persian: "عصبانیت", category: .emotions, points: 3),
    WordEntry(english: "Sadness",    persian: "غم",      category: .emotions, points: 3),
    WordEntry(english: "Surprise",   persian: "تعجب",    category: .emotions, points: 3),
    WordEntry(english: "Love",       persian: "عشق",     category: .emotions, points: 3),

    WordEntry(english: "Jealousy",       persian: "حسادت",           category: .emotions, points: 5),
    WordEntry(english: "Embarrassment",  persian: "خجالت",           category: .emotions, points: 5),
    WordEntry(english: "Excitement",     persian: "هیجان",           category: .emotions, points: 5),
    WordEntry(english: "Confusion",      persian: "سردرگمی",         category: .emotions, points: 5),
    WordEntry(english: "Pride",          persian: "غرور",            category: .emotions, points: 5),
    WordEntry(english: "Disgust",        persian: "انزجار",          category: .emotions, points: 5),

    WordEntry(english: "Boredom",    persian: "حوصله‌سر رفتن", category: .emotions, points: 7,
              hint: "Slump in a chair, tap fingers slowly, check an imaginary watch, let your eyes glaze", hintPersian: "روی صندلی آویزان شو، آهسته انگشت بزن، ساعت خیالی را چک کن، چشمانت خیره بشوند"),
    WordEntry(english: "Nostalgia",  persian: "دلتنگی",        category: .emotions, points: 7,
              hint: "Hold an imaginary photo, touch it gently with one finger, smile then look sad", hintPersian: "یه عکس خیالی را نگه دار، با یه انگشت آرام لمسش کن، لبخند بزن بعد غمگین نگاه کن"),
    WordEntry(english: "Loneliness", persian: "تنهایی",        category: .emotions, points: 7,
              hint: "Sit in a corner hugging knees, look around slowly at empty spaces", hintPersian: "در گوشه‌ای بنشین و زانو بزن، آهسته به فضاهای خالی نگاه کن"),

    // ── FAMOUS PEOPLE ────────────────────────────────────
    WordEntry(english: "Charlie Chaplin",    persian: "چارلی چاپلین",        category: .famous, points: 3),
    WordEntry(english: "Michael Jackson",    persian: "مایکل جکسون",         category: .famous, points: 3),
    WordEntry(english: "Cristiano Ronaldo",  persian: "کریستیانو رونالدو",   category: .famous, points: 3),

    WordEntry(english: "Einstein",        persian: "انیشتین",          category: .famous, points: 5),
    WordEntry(english: "Cleopatra",       persian: "کلئوپاترا",        category: .famous, points: 5),
    WordEntry(english: "Napoleon",        persian: "ناپلئون",           category: .famous, points: 5),
    WordEntry(english: "Beyoncé",         persian: "بیانسه",            category: .famous, points: 5),
    WordEntry(english: "Bruce Lee",       persian: "بروس لی",           category: .famous, points: 5),
    WordEntry(english: "Freddie Mercury", persian: "فردی مرکوری",       category: .famous, points: 5),
    WordEntry(english: "Muhammad Ali",    persian: "محمد علی",          category: .famous, points: 5),

    WordEntry(english: "Elon Musk",        persian: "ایلان ماسک",        category: .famous, points: 7,
              hint: "Point to the sky, mime launching a rocket, then drive a futuristic car with one hand", hintPersian: "به آسمان اشاره کن، موشک را پرتاب کن، بعد با یه دست یه ماشین آینده‌نگر برون"),
    WordEntry(english: "Leonardo da Vinci",persian: "لئوناردو داوینچی",  category: .famous, points: 7,
              hint: "Paint with a tiny brush, then flip the canvas — it's also a flying machine blueprint", hintPersian: "با قلم موی کوچک نقاشی کن، بعد بوم را برگردان — نقشه یه ماشین پرنده هم هست"),
    WordEntry(english: "Oprah Winfrey",    persian: "اوپرا وینفری",      category: .famous, points: 7,
              hint: "Point dramatically at the audience one by one, mouth 'You get a car!' with huge energy", hintPersian: "یکی‌یکی به مخاطبان اشاره کن، با انرژی زیاد «ماشین گرفتی!» را نشان بده"),
    WordEntry(english: "Shakespeare",     persian: "شکسپیر",            category: .famous, points: 7,
              hint: "Write with a quill, then mime delivering a dramatic monologue with one hand on heart", hintPersian: "با قلم بنویس، بعد با یه دست روی قلب، مونولوگ دراماتیک ایفا کن"),
    WordEntry(english: "Marilyn Monroe",  persian: "مریلین مونرو",       category: .famous, points: 7,
              hint: "Hold your skirt down over a vent, then sing with pouty lips to an imaginary microphone", hintPersian: "دامنت را روی دریچه هوا نگه دار، بعد با لب‌های برجسته به میکروفون خیالی آواز بخوان"),
]
