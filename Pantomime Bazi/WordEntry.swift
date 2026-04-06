//
//  WordEntry.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//
//



import Foundation

// Which language audience this word is best suited for.
// .persian  = shown only in Persian mode (culturally Iranian words)
// .english  = shown only in English mode (international words)
// .both     = universal — shown in both modes
enum WordAudience { case persian, english, both }

struct WordEntry: Identifiable {
    let id: UUID
    let display: String
    let category: WordCategory
    let points: Int
    let hint: String?
    let hintPersian: String?
    let isCustom: Bool
    let _english: String
    let _persian: String
    let audience: WordAudience  // which language mode this word appears in

    // DB word (two languages)
    init(english: String, persian: String, category: WordCategory, points: Int,
         audience: WordAudience = .both) {
        self.id = UUID()
        self.display = english
        self.category = category
        self.points = points
        self.hint = nil
        self.hintPersian = nil
        self.isCustom = false
        self._english = english
        self._persian = persian
        self.audience = audience
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
        self.audience = .both
    }

    func displayText(language: AppLanguage) -> String {
        isCustom ? display : (language == .persian ? _persian : _english)
    }

    func hintText(language: AppLanguage) -> String? { nil }
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
    case music       = "Music"
    case places      = "Places"

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
        case .music:       return "موسیقی"
        case .places:      return "مکان‌ها"
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
        case .music:       return "🎵"
        case .places:      return "🗺️"
        }
    }
}

// MARK: - Word Database
// 12 categories × 30 words = 360 words
// Points: 3 = easy, 5 = medium, 7 = hard

let wordDatabase: [WordEntry] = [

    // ── ANIMALS (حیوانات) ────────────────────────────────
    // Easy (3pts) — familiar, iconic animals
    WordEntry(english: "Penguin",     persian: "پنگوئن",    category: .animals, points: 3),
    WordEntry(english: "Elephant",    persian: "فیل",       category: .animals, points: 3),
    WordEntry(english: "Monkey",      persian: "میمون",     category: .animals, points: 3),
    WordEntry(english: "Duck",        persian: "اردک",      category: .animals, points: 3),
    WordEntry(english: "Bear",        persian: "خرس",       category: .animals, points: 3),
    WordEntry(english: "Lion",        persian: "شیر",       category: .animals, points: 3),
    WordEntry(english: "Frog",        persian: "قورباغه",   category: .animals, points: 3),
    WordEntry(english: "Butterfly",   persian: "پروانه",    category: .animals, points: 3),
    WordEntry(english: "Cat",         persian: "گربه",      category: .animals, points: 3),
    WordEntry(english: "Dog",         persian: "سگ",        category: .animals, points: 3),
    // Medium (5pts)
    WordEntry(english: "Kangaroo",    persian: "کانگارو",   category: .animals, points: 5),
    WordEntry(english: "Flamingo",    persian: "فلامینگو",  category: .animals, points: 5),
    WordEntry(english: "Crocodile",   persian: "تمساح",    category: .animals, points: 5),
    WordEntry(english: "Giraffe",     persian: "زرافه",     category: .animals, points: 5),
    WordEntry(english: "Parrot",      persian: "طوطی",      category: .animals, points: 5),
    WordEntry(english: "Dolphin",     persian: "دلفین",     category: .animals, points: 5),
    WordEntry(english: "Peacock",     persian: "طاووس",     category: .animals, points: 5),
    WordEntry(english: "Camel",       persian: "شتر",       category: .animals, points: 5),
    WordEntry(english: "Panda",       persian: "پاندا",     category: .animals, points: 5),
    WordEntry(english: "Penguin",     persian: "پنگوئن",    category: .animals, points: 5),
    // Hard (7pts)
    WordEntry(english: "Crab",        persian: "خرچنگ",    category: .animals, points: 7),
    WordEntry(english: "Spider",      persian: "عنکبوت",   category: .animals, points: 7),
    WordEntry(english: "Gorilla",     persian: "گوریل",    category: .animals, points: 7),
    WordEntry(english: "Snake",       persian: "مار",       category: .animals, points: 7),
    WordEntry(english: "Chameleon",   persian: "آفتاب‌پرست",category: .animals, points: 7),
    WordEntry(english: "Platypus",    persian: "اردک‌نوک",  category: .animals, points: 7),
    WordEntry(english: "Sloth",       persian: "تنبل‌خرس",  category: .animals, points: 7),
    WordEntry(english: "Manta ray",   persian: "سفره‌ماهی", category: .animals, points: 7),
    WordEntry(english: "Polar bear",  persian: "خرس قطبی", category: .animals, points: 7),
    WordEntry(english: "Flamingo",    persian: "فلامینگو",  category: .animals, points: 7),

    // ── ACTIONS (حرکات) ──────────────────────────────────
    // Easy
    WordEntry(english: "Sleeping",    persian: "خوابیدن",       category: .actions, points: 3),
    WordEntry(english: "Crying",      persian: "گریه کردن",     category: .actions, points: 3),
    WordEntry(english: "Running",     persian: "دویدن",          category: .actions, points: 3),
    WordEntry(english: "Dancing",     persian: "رقصیدن",         category: .actions, points: 3),
    WordEntry(english: "Swimming",    persian: "شنا کردن",       category: .actions, points: 3),
    WordEntry(english: "Yawning",     persian: "خمیازه کشیدن",  category: .actions, points: 3),
    WordEntry(english: "Sneezing",    persian: "عطسه کردن",     category: .actions, points: 3),
    WordEntry(english: "Eating",      persian: "غذا خوردن",     category: .actions, points: 3),
    WordEntry(english: "Jumping",     persian: "پریدن",          category: .actions, points: 3),
    WordEntry(english: "Laughing",    persian: "خندیدن",         category: .actions, points: 3),
    // Medium
    WordEntry(english: "Cooking",         persian: "آشپزی کردن",     category: .actions, points: 5),
    WordEntry(english: "Driving",         persian: "رانندگی کردن",   category: .actions, points: 5),
    WordEntry(english: "Painting",        persian: "نقاشی کردن",     category: .actions, points: 5),
    WordEntry(english: "Praying",         persian: "نماز خواندن",    category: .actions, points: 5),
    WordEntry(english: "Ironing clothes", persian: "اتو کردن لباس",  category: .actions, points: 5),
    WordEntry(english: "Brushing teeth",  persian: "مسواک زدن",      category: .actions, points: 5),
    WordEntry(english: "Taking selfie",   persian: "سلفی گرفتن",     category: .actions, points: 5),
    WordEntry(english: "Knitting",        persian: "بافتن",            category: .actions, points: 5),
    WordEntry(english: "Rock climbing",   persian: "کوه‌نوردی",       category: .actions, points: 5),
    WordEntry(english: "Meditating",      persian: "مدیتیشن کردن",   category: .actions, points: 5),
    // Hard
    WordEntry(english: "Tightrope walking",persian: "بندبازی",        category: .actions, points: 7),
    WordEntry(english: "Sword swallowing",persian: "قورت دادن شمشیر", category: .actions, points: 7),
    WordEntry(english: "Pickpocketing",   persian: "جیب‌بری",         category: .actions, points: 7),
    WordEntry(english: "Lip syncing",     persian: "پلی‌بک خواندن",   category: .actions, points: 7),
    WordEntry(english: "Sleepwalking",    persian: "خوابگردی",         category: .actions, points: 7),
    WordEntry(english: "Speed reading",   persian: "سریع‌خوانی",      category: .actions, points: 7),
    WordEntry(english: "Ventriloquism",   persian: "شکم‌سخنی",        category: .actions, points: 7),
    WordEntry(english: "Scuba diving",    persian: "غواصی",            category: .actions, points: 7),
    WordEntry(english: "Parkour",         persian: "پارکور",           category: .actions, points: 7),
    WordEntry(english: "Fire eating",     persian: "آتش خوردن",        category: .actions, points: 7),

    // ── PROFESSIONS (مشاغل) ──────────────────────────────
    // Easy
    WordEntry(english: "Doctor",      persian: "دکتر",        category: .professions, points: 3),
    WordEntry(english: "Teacher",     persian: "معلم",        category: .professions, points: 3),
    WordEntry(english: "Chef",        persian: "آشپز",        category: .professions, points: 3),
    WordEntry(english: "Firefighter", persian: "آتش‌نشان",    category: .professions, points: 3),
    WordEntry(english: "Police",      persian: "پلیس",        category: .professions, points: 3),
    WordEntry(english: "Farmer",      persian: "کشاورز",      category: .professions, points: 3),
    WordEntry(english: "Pilot",       persian: "خلبان",       category: .professions, points: 3),
    WordEntry(english: "Dentist",     persian: "دندانپزشک",   category: .professions, points: 3),
    WordEntry(english: "Barber",      persian: "آرایشگر",     category: .professions, points: 3),
    WordEntry(english: "Baker",       persian: "نانوا",       category: .professions, points: 3),
    // Medium
    WordEntry(english: "Surgeon",     persian: "جراح",        category: .professions, points: 5),
    WordEntry(english: "Astronaut",   persian: "فضانورد",     category: .professions, points: 5),
    WordEntry(english: "Magician",    persian: "شعبده‌باز",   category: .professions, points: 5),
    WordEntry(english: "Lifeguard",   persian: "نجات‌غریق",   category: .professions, points: 5),
    WordEntry(english: "Journalist",  persian: "خبرنگار",     category: .professions, points: 5),
    WordEntry(english: "Wrestler",    persian: "کشتی‌گیر",    category: .professions, points: 5),
    WordEntry(english: "Janitor",     persian: "سرایدار",     category: .professions, points: 5),
    WordEntry(english: "Taxi driver", persian: "راننده تاکسی",category: .professions, points: 5),
    WordEntry(english: "Plumber",     persian: "لوله‌کش",     category: .professions, points: 5),
    WordEntry(english: "Hairdresser", persian: "آرایشگر مو",  category: .professions, points: 5),
    // Hard
    WordEntry(english: "Mime artist",   persian: "پانتومیمیست",  category: .professions, points: 7),
    WordEntry(english: "Sommelier",     persian: "کارشناس نوشیدنی",category: .professions, points: 7, audience: .english),
    WordEntry(english: "Archaeologist", persian: "باستان‌شناس",  category: .professions, points: 7),
    WordEntry(english: "Taxidermist",   persian: "پرسازی حیوانات",category: .professions, points: 7),
    WordEntry(english: "Cartographer",  persian: "نقشه‌کش",      category: .professions, points: 7, audience: .english),
    WordEntry(english: "Auctioneer",    persian: "حراج‌دار",     category: .professions, points: 7, audience: .english),
    WordEntry(english: "Locksmith",     persian: "قفل‌ساز",      category: .professions, points: 7),
    WordEntry(english: "Puppeteer",     persian: "عروسک‌گردان",  category: .professions, points: 7),
    WordEntry(english: "Contortionist", persian: "بدن‌نرم",      category: .professions, points: 7),
    WordEntry(english: "Town crier",    persian: "جارچی",         category: .professions, points: 7, audience: .english),

    // ── MOVIES & TV (فیلم و سریال) ───────────────────────
    // Easy — iconic globally known + beloved Iranian films/shows
    WordEntry(english: "Titanic",        persian: "تایتانیک",        category: .movies, points: 3),
    WordEntry(english: "The Lion King",  persian: "شیرشاه",          category: .movies, points: 3),
    WordEntry(english: "Harry Potter",   persian: "هری پاتر",        category: .movies, points: 3),
    WordEntry(english: "Tom and Jerry",  persian: "تام و جری",       category: .movies, points: 3, audience: .persian),
    WordEntry(english: "Spider-Man",     persian: "مرد عنکبوتی",     category: .movies, points: 3),
    WordEntry(english: "Home Alone",     persian: "تنها در خانه",    category: .movies, points: 3, audience: .persian),
    WordEntry(english: "Frozen",         persian: "یخ‌زده",          category: .movies, points: 3),
    WordEntry(english: "Shrek",          persian: "شرک",              category: .movies, points: 3),
    WordEntry(english: "Finding Nemo",   persian: "در جستجوی نمو",   category: .movies, points: 3),
    WordEntry(english: "The Mask",       persian: "ماسک",             category: .movies, points: 3, audience: .persian),
    // Medium
    WordEntry(english: "The Matrix",     persian: "ماتریکس",          category: .movies, points: 5),
    WordEntry(english: "Joker",          persian: "جوکر",             category: .movies, points: 5),
    WordEntry(english: "Avengers",       persian: "انتقام‌جویان",     category: .movies, points: 5),
    WordEntry(english: "Game of Thrones",persian: "بازی تاج و تخت",  category: .movies, points: 5),
    WordEntry(english: "Breaking Bad",   persian: "بریکینگ بد",      category: .movies, points: 5),
    WordEntry(english: "Interstellar",   persian: "میان‌ستاره‌ای",    category: .movies, points: 5),
    WordEntry(english: "Squid Game",     persian: "بازی مرکب",        category: .movies, points: 5),
    WordEntry(english: "Friends",        persian: "دوستان",           category: .movies, points: 5),
    WordEntry(english: "The Godfather",  persian: "پدرخوانده",        category: .movies, points: 5),
    WordEntry(english: "Toy Story",      persian: "داستان اسباب‌بازی", category: .movies, points: 5),
    // Hard
    WordEntry(english: "Inception",      persian: "تلقین",            category: .movies, points: 7),
    WordEntry(english: "Parasite",       persian: "انگل",             category: .movies, points: 7),
    WordEntry(english: "Schindler's List",persian: "فهرست شیندلر",   category: .movies, points: 7, audience: .english),
    WordEntry(english: "2001: A Space Odyssey",persian: "ادیسه فضایی",category: .movies, points: 7, audience: .english),
    WordEntry(english: "The Truman Show",persian: "نمایش ترومن",     category: .movies, points: 7),
    WordEntry(english: "Forrest Gump",   persian: "فارست گامپ",      category: .movies, points: 7),
    WordEntry(english: "Goodfellas",     persian: "رفقای خوب",       category: .movies, points: 7, audience: .english),
    WordEntry(english: "Pulp Fiction",   persian: "داستان‌های عامه‌پسند",category: .movies, points: 7, audience: .english),
    WordEntry(english: "Fight Club",     persian: "باشگاه مشت‌زنی",  category: .movies, points: 7, audience: .english),
    WordEntry(english: "The Dark Knight",persian: "شوالیه تاریکی",   category: .movies, points: 7),

    // ── FOOD (غذا) ───────────────────────────────────────
    // Easy — universally known + Iranian staples
    WordEntry(english: "Pizza",         persian: "پیتزا",        category: .food, points: 3),
    WordEntry(english: "Hamburger",     persian: "همبرگر",       category: .food, points: 3),
    WordEntry(english: "Sushi",         persian: "سوشی",         category: .food, points: 3),
    WordEntry(english: "Ice cream",     persian: "بستنی",        category: .food, points: 3),
    WordEntry(english: "Kebab",         persian: "کباب",         category: .food, points: 3),
    WordEntry(english: "Rice",          persian: "برنج",         category: .food, points: 3),
    WordEntry(english: "Bread",         persian: "نان",          category: .food, points: 3),
    WordEntry(english: "Watermelon",    persian: "هندوانه",      category: .food, points: 3, audience: .persian),
    WordEntry(english: "Sandwich",      persian: "ساندویچ",      category: .food, points: 3),
    WordEntry(english: "Soup",          persian: "سوپ",          category: .food, points: 3),
    // Medium
    WordEntry(english: "Spaghetti",     persian: "اسپاگتی",      category: .food, points: 5),
    WordEntry(english: "Ghormeh sabzi", persian: "قورمه سبزی",   category: .food, points: 5, audience: .persian),
    WordEntry(english: "Fesenjaan",     persian: "فسنجان",       category: .food, points: 5, audience: .persian),
    WordEntry(english: "Baklava",       persian: "باقلوا",       category: .food, points: 5, audience: .persian),
    WordEntry(english: "Cotton candy",  persian: "پشمک",         category: .food, points: 5, audience: .persian),
    WordEntry(english: "Tacos",         persian: "تاکو",         category: .food, points: 5),
    WordEntry(english: "Ramen",         persian: "رامن",         category: .food, points: 5),
    WordEntry(english: "Croissant",     persian: "کروآسان",      category: .food, points: 5),
    WordEntry(english: "Tahdig",        persian: "ته‌دیگ",       category: .food, points: 5, audience: .persian),
    WordEntry(english: "Doner kebab",   persian: "دونر کباب",    category: .food, points: 5, audience: .persian),
    // Hard
    WordEntry(english: "Fondue",        persian: "فوندو",        category: .food, points: 7, audience: .english),
    WordEntry(english: "Soufflé",       persian: "سوفله",        category: .food, points: 7, audience: .english),
    WordEntry(english: "Ceviche",       persian: "سویچه",        category: .food, points: 7, audience: .english),
    WordEntry(english: "Dim sum",       persian: "دیم سام",      category: .food, points: 7, audience: .english),
    WordEntry(english: "Ash reshteh",   persian: "آش رشته",      category: .food, points: 7, audience: .persian),
    WordEntry(english: "Khoresh bademjan",persian: "خورش بادمجان",category: .food, points: 7, audience: .persian),
    WordEntry(english: "Lutefisk",      persian: "ماهی نروژی",   category: .food, points: 7, audience: .english),
    WordEntry(english: "Haggis",        persian: "هگیس",         category: .food, points: 7, audience: .english),
    WordEntry(english: "Miso soup",     persian: "سوپ میسو",     category: .food, points: 7),
    WordEntry(english: "Paella",        persian: "پائلا",        category: .food, points: 7, audience: .english),

    // ── SPORTS (ورزش) ────────────────────────────────────
    // Easy
    WordEntry(english: "Football",      persian: "فوتبال",       category: .sports, points: 3),
    WordEntry(english: "Basketball",    persian: "بسکتبال",      category: .sports, points: 3),
    WordEntry(english: "Swimming",      persian: "شنا",          category: .sports, points: 3),
    WordEntry(english: "Tennis",        persian: "تنیس",         category: .sports, points: 3),
    WordEntry(english: "Boxing",        persian: "بوکس",         category: .sports, points: 3),
    WordEntry(english: "Volleyball",    persian: "والیبال",      category: .sports, points: 3),
    WordEntry(english: "Running",       persian: "دو",           category: .sports, points: 3),
    WordEntry(english: "Cycling",       persian: "دوچرخه‌سواری", category: .sports, points: 3),
    WordEntry(english: "Skiing",        persian: "اسکی",         category: .sports, points: 3),
    WordEntry(english: "Wrestling",     persian: "کشتی",         category: .sports, points: 3, audience: .persian),
    // Medium
    WordEntry(english: "Archery",       persian: "تیراندازی با کمان",category: .sports, points: 5),
    WordEntry(english: "Weightlifting", persian: "وزنه‌برداری",  category: .sports, points: 5),
    WordEntry(english: "Horse riding",  persian: "اسب‌سواری",    category: .sports, points: 5),
    WordEntry(english: "Karate",        persian: "کاراته",        category: .sports, points: 5),
    WordEntry(english: "Gymnastics",    persian: "ژیمناستیک",    category: .sports, points: 5),
    WordEntry(english: "Surfing",       persian: "موج‌سواری",    category: .sports, points: 5),
    WordEntry(english: "Golf",          persian: "گلف",          category: .sports, points: 5),
    WordEntry(english: "Fencing",       persian: "شمشیربازی",    category: .sports, points: 5),
    WordEntry(english: "Polo",          persian: "چوگان",        category: .sports, points: 5, audience: .persian),
    WordEntry(english: "Table tennis",  persian: "پینگ‌پنگ",     category: .sports, points: 5),
    // Hard
    WordEntry(english: "Synchronized swimming",persian: "شنای همگام",category: .sports, points: 7),
    WordEntry(english: "Bungee jumping",persian: "بانجی جامپینگ", category: .sports, points: 7),
    WordEntry(english: "Curling",       persian: "کرلینگ",       category: .sports, points: 7, audience: .english),
    WordEntry(english: "Javelin throw", persian: "پرتاب نیزه",   category: .sports, points: 7),
    WordEntry(english: "Skeleton",      persian: "اسکلتون",      category: .sports, points: 7, audience: .english),
    WordEntry(english: "Hammer throw",  persian: "پرتاب چکش",    category: .sports, points: 7, audience: .english),
    WordEntry(english: "Rhythmic gymnastics",persian: "ژیمناستیک ریتمیک",category: .sports, points: 7),
    WordEntry(english: "Bobsled",       persian: "بابزلد",       category: .sports, points: 7, audience: .english),
    WordEntry(english: "Sumo",          persian: "سومو",         category: .sports, points: 7),
    WordEntry(english: "Parkour",       persian: "پارکور",       category: .sports, points: 7),

    // ── EVERYDAY LIFE (زندگی روزمره) ────────────────────
    // Easy
    WordEntry(english: "Wedding",       persian: "عروسی",        category: .everyday, points: 3),
    WordEntry(english: "Hospital",      persian: "بیمارستان",    category: .everyday, points: 3),
    WordEntry(english: "Airport",       persian: "فرودگاه",      category: .everyday, points: 3),
    WordEntry(english: "Supermarket",   persian: "سوپرمارکت",   category: .everyday, points: 3),
    WordEntry(english: "School",        persian: "مدرسه",        category: .everyday, points: 3),
    WordEntry(english: "Traffic jam",   persian: "ترافیک",       category: .everyday, points: 3),
    WordEntry(english: "Birthday party",persian: "جشن تولد",     category: .everyday, points: 3),
    WordEntry(english: "Alarm clock",   persian: "ساعت زنگ‌دار", category: .everyday, points: 3),
    WordEntry(english: "Elevator",      persian: "آسانسور",      category: .everyday, points: 3),
    WordEntry(english: "Queue",         persian: "صف",           category: .everyday, points: 3),
    // Medium
    WordEntry(english: "Moving house",  persian: "اسباب‌کشی",    category: .everyday, points: 5),
    WordEntry(english: "Power outage",  persian: "قطع برق",      category: .everyday, points: 5),
    WordEntry(english: "Parking lot",   persian: "پارکینگ",      category: .everyday, points: 5),
    WordEntry(english: "Laundry",       persian: "لباسشویی",     category: .everyday, points: 5),
    WordEntry(english: "Job interview", persian: "مصاحبه کاری",  category: .everyday, points: 5),
    WordEntry(english: "Blind date",    persian: "قرار کور",     category: .everyday, points: 5),
    WordEntry(english: "Surprise party",persian: "جشن غافلگیری", category: .everyday, points: 5),
    WordEntry(english: "Stuck in lift", persian: "گیر کردن در آسانسور",category: .everyday, points: 5),
    WordEntry(english: "Missing bus",   persian: "از دست دادن اتوبوس",category: .everyday, points: 5),
    WordEntry(english: "Online shopping",persian: "خرید آنلاین", category: .everyday, points: 5),
    // Hard
    WordEntry(english: "Passive aggressive",persian: "رفتار منفعلانه‌پرخاشگر",category: .everyday, points: 7),
    WordEntry(english: "Ghosting",      persian: "نادیده گرفتن", category: .everyday, points: 7),
    WordEntry(english: "IKEA assembly", persian: "مونتاژ ایکیا",  category: .everyday, points: 7, audience: .english),
    WordEntry(english: "Road rage",     persian: "عصبانیت رانندگی",category: .everyday, points: 7),
    WordEntry(english: "Social anxiety",persian: "اضطراب اجتماعی",category: .everyday, points: 7),
    WordEntry(english: "Awkward silence",persian: "سکوت ناخوشایند",category: .everyday, points: 7),
    WordEntry(english: "Midlife crisis",persian: "بحران میانسالی", category: .everyday, points: 7),
    WordEntry(english: "Video call fail",persian: "خرابی ویدیوکال",category: .everyday, points: 7),
    WordEntry(english: "Autocorrect fail",persian: "اشتباه تصحیح خودکار",category: .everyday, points: 7),
    WordEntry(english: "Public speaking",persian: "سخنرانی عمومی",category: .everyday, points: 7),

    // ── NATURE (طبیعت) ───────────────────────────────────
    // Easy
    WordEntry(english: "Rainbow",       persian: "رنگین‌کمان",   category: .nature, points: 3),
    WordEntry(english: "Sunset",        persian: "غروب آفتاب",   category: .nature, points: 3),
    WordEntry(english: "Desert",        persian: "بیابان",       category: .nature, points: 3),
    WordEntry(english: "Jungle",        persian: "جنگل",         category: .nature, points: 3),
    WordEntry(english: "Ocean",         persian: "اقیانوس",      category: .nature, points: 3),
    WordEntry(english: "Mountain",      persian: "کوه",          category: .nature, points: 3),
    WordEntry(english: "River",         persian: "رودخانه",      category: .nature, points: 3),
    WordEntry(english: "Waterfall",     persian: "آبشار",        category: .nature, points: 3),
    WordEntry(english: "Snow",          persian: "برف",          category: .nature, points: 3),
    WordEntry(english: "Wind",          persian: "باد",          category: .nature, points: 3),
    // Medium
    WordEntry(english: "Tornado",       persian: "گردباد",       category: .nature, points: 5),
    WordEntry(english: "Snowstorm",     persian: "کولاک",        category: .nature, points: 5),
    WordEntry(english: "Lightning",     persian: "صاعقه",        category: .nature, points: 5),
    WordEntry(english: "Oasis",         persian: "واحه",         category: .nature, points: 5),
    WordEntry(english: "Aurora",        persian: "شفق قطبی",     category: .nature, points: 5),
    WordEntry(english: "Coral reef",    persian: "صخره مرجانی",  category: .nature, points: 5),
    WordEntry(english: "Quicksand",     persian: "شن روان",      category: .nature, points: 5),
    WordEntry(english: "Eclipse",       persian: "خسوف",         category: .nature, points: 5),
    WordEntry(english: "Monsoon",       persian: "مون‌سون",      category: .nature, points: 5),
    WordEntry(english: "Fog",           persian: "مه",           category: .nature, points: 5),
    // Hard
    WordEntry(english: "Earthquake",    persian: "زلزله",        category: .nature, points: 7),
    WordEntry(english: "Volcano",       persian: "آتشفشان",      category: .nature, points: 7),
    WordEntry(english: "Avalanche",     persian: "بهمن",         category: .nature, points: 7),
    WordEntry(english: "Glacier",       persian: "یخچال طبیعی",  category: .nature, points: 7),
    WordEntry(english: "Tide",          persian: "جزر و مد",     category: .nature, points: 7),
    WordEntry(english: "Black hole",    persian: "سیاهچاله",     category: .nature, points: 7),
    WordEntry(english: "Drought",       persian: "خشکسالی",      category: .nature, points: 7),
    WordEntry(english: "Permafrost",    persian: "یخبندان دائمی",category: .nature, points: 7),
    WordEntry(english: "Bioluminescence",persian: "نور زیستی",   category: .nature, points: 7),
    WordEntry(english: "Solar flare",   persian: "شعله خورشیدی", category: .nature, points: 7),

    // ── EMOTIONS (احساسات) ──────────────────────────────
    // Easy
    WordEntry(english: "Happiness",     persian: "شادی",         category: .emotions, points: 3),
    WordEntry(english: "Fear",          persian: "ترس",          category: .emotions, points: 3),
    WordEntry(english: "Anger",         persian: "عصبانیت",      category: .emotions, points: 3),
    WordEntry(english: "Sadness",       persian: "غم",           category: .emotions, points: 3),
    WordEntry(english: "Surprise",      persian: "تعجب",         category: .emotions, points: 3),
    WordEntry(english: "Love",          persian: "عشق",          category: .emotions, points: 3),
    WordEntry(english: "Disgust",       persian: "انزجار",       category: .emotions, points: 3),
    WordEntry(english: "Confusion",     persian: "سردرگمی",      category: .emotions, points: 3),
    WordEntry(english: "Excitement",    persian: "هیجان",        category: .emotions, points: 3),
    WordEntry(english: "Pride",         persian: "غرور",         category: .emotions, points: 3),
    // Medium
    WordEntry(english: "Jealousy",      persian: "حسادت",        category: .emotions, points: 5),
    WordEntry(english: "Embarrassment", persian: "خجالت",        category: .emotions, points: 5),
    WordEntry(english: "Boredom",       persian: "حوصله‌سر رفتن",category: .emotions, points: 5),
    WordEntry(english: "Nostalgia",     persian: "دلتنگی",       category: .emotions, points: 5, audience: .persian),
    WordEntry(english: "Loneliness",    persian: "تنهایی",       category: .emotions, points: 5),
    WordEntry(english: "Relief",        persian: "آسودگی",       category: .emotions, points: 5),
    WordEntry(english: "Guilt",         persian: "احساس گناه",   category: .emotions, points: 5),
    WordEntry(english: "Anxiety",       persian: "اضطراب",       category: .emotions, points: 5),
    WordEntry(english: "Envy",          persian: "رشک",          category: .emotions, points: 5),
    WordEntry(english: "Gratitude",     persian: "سپاسگزاری",    category: .emotions, points: 5),
    // Hard
    WordEntry(english: "Schadenfreude", persian: "شادی از بدبختی دیگری",category: .emotions, points: 7),
    WordEntry(english: "Melancholy",    persian: "مالیخولیا",    category: .emotions, points: 7),
    WordEntry(english: "Awe",           persian: "شگفتی",        category: .emotions, points: 7),
    WordEntry(english: "Despair",       persian: "یأس",          category: .emotions, points: 7),
    WordEntry(english: "Euphoria",      persian: "سرخوشی",       category: .emotions, points: 7),
    WordEntry(english: "Betrayal",      persian: "خیانت",        category: .emotions, points: 7),
    WordEntry(english: "Anticipation",  persian: "انتظار",       category: .emotions, points: 7),
    WordEntry(english: "Homesickness",  persian: "دلتنگی خانه",  category: .emotions, points: 7),
    WordEntry(english: "Heartbreak",    persian: "دل شکستگی",    category: .emotions, points: 7),
    WordEntry(english: "Serenity",      persian: "آرامش",        category: .emotions, points: 7),

    // ── FAMOUS PEOPLE (افراد مشهور) ─────────────────────
    // Easy — globally iconic
    WordEntry(english: "Charlie Chaplin",  persian: "چارلی چاپلین",      category: .famous, points: 3),
    WordEntry(english: "Michael Jackson",  persian: "مایکل جکسون",       category: .famous, points: 3),
    WordEntry(english: "Cristiano Ronaldo",persian: "کریستیانو رونالدو", category: .famous, points: 3),
    WordEntry(english: "Einstein",         persian: "انیشتین",            category: .famous, points: 3),
    WordEntry(english: "Napoleon",         persian: "ناپلئون",            category: .famous, points: 3),
    WordEntry(english: "Superman",         persian: "سوپرمن",             category: .famous, points: 3),
    WordEntry(english: "Santa Claus",      persian: "بابانوئل",           category: .famous, points: 3),
    WordEntry(english: "Dracula",          persian: "دراکولا",            category: .famous, points: 3),
    WordEntry(english: "Batman",           persian: "بتمن",               category: .famous, points: 3),
    WordEntry(english: "Sherlock Holmes",  persian: "شرلوک هولمز",       category: .famous, points: 3),
    // Medium
    WordEntry(english: "Cleopatra",        persian: "کلئوپاترا",          category: .famous, points: 5),
    WordEntry(english: "Beyoncé",          persian: "بیانسه",             category: .famous, points: 5),
    WordEntry(english: "Bruce Lee",        persian: "بروس لی",            category: .famous, points: 5),
    WordEntry(english: "Freddie Mercury",  persian: "فردی مرکوری",        category: .famous, points: 5),
    WordEntry(english: "Muhammad Ali",     persian: "محمد علی",           category: .famous, points: 5),
    WordEntry(english: "Marilyn Monroe",   persian: "مریلین مونرو",       category: .famous, points: 5),
    WordEntry(english: "Mona Lisa",        persian: "مونالیزا",           category: .famous, points: 5),
    WordEntry(english: "James Bond",       persian: "جیمز باند",          category: .famous, points: 5),
    WordEntry(english: "Taylor Swift",     persian: "تیلور سوئیفت",      category: .famous, points: 5),
    WordEntry(english: "Steve Jobs",       persian: "استیو جابز",         category: .famous, points: 5),
    // Hard
    WordEntry(english: "Elon Musk",        persian: "ایلان ماسک",         category: .famous, points: 7),
    WordEntry(english: "Leonardo da Vinci",persian: "لئوناردو داوینچی",   category: .famous, points: 7),
    WordEntry(english: "Oprah Winfrey",    persian: "اوپرا وینفری",       category: .famous, points: 7),
    WordEntry(english: "Shakespeare",      persian: "شکسپیر",             category: .famous, points: 7),
    WordEntry(english: "Nikola Tesla",     persian: "نیکولا تسلا",        category: .famous, points: 7),
    WordEntry(english: "Mahatma Gandhi",   persian: "مهاتما گاندی",       category: .famous, points: 7),
    WordEntry(english: "Marie Curie",      persian: "ماری کوری",          category: .famous, points: 7),
    WordEntry(english: "Picasso",          persian: "پیکاسو",             category: .famous, points: 7),
    WordEntry(english: "Genghis Khan",     persian: "چنگیز خان",          category: .famous, points: 7, audience: .persian),
    WordEntry(english: "Nostradamus",      persian: "نوستراداموس",        category: .famous, points: 7, audience: .english),

    // ── MUSIC (موسیقی) ────────────────────────────────────
    // Easy
    WordEntry(english: "Guitar",           persian: "گیتار",              category: .music, points: 3),
    WordEntry(english: "Drums",            persian: "طبل",                category: .music, points: 3),
    WordEntry(english: "Piano",            persian: "پیانو",              category: .music, points: 3),
    WordEntry(english: "Singing",          persian: "آواز خواندن",        category: .music, points: 3),
    WordEntry(english: "Violin",           persian: "ویولن",              category: .music, points: 3),
    WordEntry(english: "Headphones",       persian: "هدفون",              category: .music, points: 3),
    WordEntry(english: "Concert",          persian: "کنسرت",             category: .music, points: 3),
    WordEntry(english: "Microphone",       persian: "میکروفون",           category: .music, points: 3),
    WordEntry(english: "Dancing",          persian: "رقص",                category: .music, points: 3),
    WordEntry(english: "DJ",               persian: "دی‌جی",              category: .music, points: 3),
    // Medium
    WordEntry(english: "Karaoke",          persian: "کارائوکه",           category: .music, points: 5),
    WordEntry(english: "Music video",      persian: "موزیک ویدیو",        category: .music, points: 5),
    WordEntry(english: "Trumpet",          persian: "ترومپت",             category: .music, points: 5),
    WordEntry(english: "Saxophone",        persian: "ساکسیفون",           category: .music, points: 5),
    WordEntry(english: "Record player",    persian: "گرامافون",           category: .music, points: 5),
    WordEntry(english: "Air guitar",       persian: "گیتار هوایی",        category: .music, points: 5),
    WordEntry(english: "Choir",            persian: "گروه کر",            category: .music, points: 5),
    WordEntry(english: "Rap battle",       persian: "مسابقه رپ",          category: .music, points: 5),
    WordEntry(english: "Flash mob",        persian: "فلش‌ماب",            category: .music, points: 5),
    WordEntry(english: "Busking",          persian: "نوازندگی خیابانی",   category: .music, points: 5),
    // Hard
    WordEntry(english: "Conducting",       persian: "رهبری ارکستر",      category: .music, points: 7),
    WordEntry(english: "Beatboxing",       persian: "بیت‌باکسینگ",        category: .music, points: 7),
    WordEntry(english: "Throat singing",   persian: "آواز گلویی",         category: .music, points: 7),
    WordEntry(english: "Theremin",         persian: "ترمین",              category: .music, points: 7),
    WordEntry(english: "Flamenco",         persian: "فلامنکو",            category: .music, points: 7),
    WordEntry(english: "Sitar playing",    persian: "نواختن سیتار",       category: .music, points: 7, audience: .persian),
    WordEntry(english: "Opera singing",    persian: "اپرا خواندن",        category: .music, points: 7),
    WordEntry(english: "Ney playing",      persian: "نی نواختن",          category: .music, points: 7, audience: .persian),
    WordEntry(english: "Daf playing",      persian: "دف زدن",             category: .music, points: 7, audience: .persian),
    WordEntry(english: "Tar playing",      persian: "تار نواختن",         category: .music, points: 7, audience: .persian),

    // ── PLACES (مکان‌ها) ─────────────────────────────────
    // Easy
    WordEntry(english: "Beach",            persian: "ساحل",               category: .places, points: 3),
    WordEntry(english: "Library",          persian: "کتابخانه",           category: .places, points: 3),
    WordEntry(english: "Restaurant",       persian: "رستوران",            category: .places, points: 3),
    WordEntry(english: "Zoo",              persian: "باغ وحش",            category: .places, points: 3),
    WordEntry(english: "Museum",           persian: "موزه",               category: .places, points: 3),
    WordEntry(english: "Cinema",           persian: "سینما",              category: .places, points: 3),
    WordEntry(english: "Park",             persian: "پارک",               category: .places, points: 3),
    WordEntry(english: "Market",           persian: "بازار",              category: .places, points: 3),
    WordEntry(english: "Mosque",           persian: "مسجد",               category: .places, points: 3),
    WordEntry(english: "Gym",              persian: "باشگاه",             category: .places, points: 3),
    // Medium
    WordEntry(english: "Amusement park",   persian: "شهر بازی",           category: .places, points: 5),
    WordEntry(english: "Opera house",      persian: "اپرا هاوس",          category: .places, points: 5),
    WordEntry(english: "Ice rink",         persian: "پیست یخ",            category: .places, points: 5),
    WordEntry(english: "Space station",    persian: "ایستگاه فضایی",      category: .places, points: 5),
    WordEntry(english: "Haunted house",    persian: "خانه ارواح",         category: .places, points: 5),
    WordEntry(english: "Grand Bazaar",     persian: "بازار بزرگ",         category: .places, points: 5, audience: .persian),
    WordEntry(english: "Casino",           persian: "کازینو",             category: .places, points: 5),
    WordEntry(english: "Sauna",            persian: "سونا",               category: .places, points: 5),
    WordEntry(english: "Submarine",        persian: "زیردریایی",          category: .places, points: 5),
    WordEntry(english: "Prison",           persian: "زندان",              category: .places, points: 5),
    // Hard
    WordEntry(english: "Colosseum",        persian: "کولوسئوم",           category: .places, points: 7),
    WordEntry(english: "Stonehenge",       persian: "استون‌هنج",          category: .places, points: 7, audience: .english),
    WordEntry(english: "The Vatican",      persian: "واتیکان",            category: .places, points: 7, audience: .english),
    WordEntry(english: "Area 51",          persian: "منطقه ۵۱",           category: .places, points: 7),
    WordEntry(english: "Bermuda Triangle", persian: "مثلث برمودا",        category: .places, points: 7),
    WordEntry(english: "Machu Picchu",     persian: "ماچو پیکچو",         category: .places, points: 7),
    WordEntry(english: "Pompeii",          persian: "پمپئی",              category: .places, points: 7, audience: .english),
    WordEntry(english: "The Louvre",       persian: "موزه لوور",          category: .places, points: 7),
    WordEntry(english: "Alcatraz",         persian: "آلکاتراز",           category: .places, points: 7, audience: .english),
    WordEntry(english: "Chernobyl",        persian: "چرنوبیل",            category: .places, points: 7, audience: .english),
]
