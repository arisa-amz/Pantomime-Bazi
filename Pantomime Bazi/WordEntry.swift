//
//  WordEntry.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//


import Foundation

struct WordEntry: Identifiable {
    let id = UUID()
    let english: String
    let persian: String
    let category: WordCategory
}

enum WordCategory: String, CaseIterable, Identifiable {
    case animals = "Animals"
    case actions = "Actions"
    case professions = "Professions"
    case movies = "Movies & TV"
    case food = "Food"
    case sports = "Sports"
    case everyday = "Everyday Life"
    case nature = "Nature"
    case emotions = "Emotions"
    case famous = "Famous People"

    var id: String { rawValue }

    var persianName: String {
        switch self {
        case .animals: return "حیوانات"
        case .actions: return "حرکات"
        case .professions: return "مشاغل"
        case .movies: return "فیلم و سریال"
        case .food: return "غذا"
        case .sports: return "ورزش"
        case .everyday: return "زندگی روزمره"
        case .nature: return "طبیعت"
        case .emotions: return "احساسات"
        case .famous: return "افراد مشهور"
        }
    }

    var emoji: String {
        switch self {
        case .animals: return "🐾"
        case .actions: return "🏃"
        case .professions: return "👩‍💼"
        case .movies: return "🎬"
        case .food: return "🍕"
        case .sports: return "⚽"
        case .everyday: return "🏠"
        case .nature: return "🌿"
        case .emotions: return "😄"
        case .famous: return "⭐"
        }
    }

    var color: AppColor {
        switch self {
        case .animals: return .orange
        case .actions: return .red
        case .professions: return .purple
        case .movies: return .pink
        case .food: return .yellow
        case .sports: return .green
        case .everyday: return .blue
        case .nature: return .teal
        case .emotions: return .coral
        case .famous: return .gold
        }
    }
}

enum AppColor {
    case orange, red, purple, pink, yellow, green, blue, teal, coral, gold

    var main: String {
        switch self {
        case .orange: return "#FF6B35"
        case .red: return "#FF3B5C"
        case .purple: return "#8B5CF6"
        case .pink: return "#EC4899"
        case .yellow: return "#F59E0B"
        case .green: return "#10B981"
        case .blue: return "#3B82F6"
        case .teal: return "#14B8A6"
        case .coral: return "#F97316"
        case .gold: return "#EAB308"
        }
    }
}

let wordDatabase: [WordEntry] = [
    // ANIMALS
    WordEntry(english: "Penguin", persian: "پنگوئن", category: .animals),
    WordEntry(english: "Elephant", persian: "فیل", category: .animals),
    WordEntry(english: "Monkey", persian: "میمون", category: .animals),
    WordEntry(english: "Kangaroo", persian: "کانگارو", category: .animals),
    WordEntry(english: "Flamingo", persian: "فلامینگو", category: .animals),
    WordEntry(english: "Crocodile", persian: "تمساح", category: .animals),
    WordEntry(english: "Giraffe", persian: "زرافه", category: .animals),
    WordEntry(english: "Snake", persian: "مار", category: .animals),
    WordEntry(english: "Parrot", persian: "طوطی", category: .animals),
    WordEntry(english: "Crab", persian: "خرچنگ", category: .animals),
    WordEntry(english: "Dolphin", persian: "دلفین", category: .animals),
    WordEntry(english: "Spider", persian: "عنکبوت", category: .animals),
    WordEntry(english: "Peacock", persian: "طاووس", category: .animals),
    WordEntry(english: "Gorilla", persian: "گوریل", category: .animals),
    WordEntry(english: "Camel", persian: "شتر", category: .animals),
    WordEntry(english: "Bear", persian: "خرس", category: .animals),
    WordEntry(english: "Lion", persian: "شیر", category: .animals),
    WordEntry(english: "Frog", persian: "قورباغه", category: .animals),
    WordEntry(english: "Duck", persian: "اردک", category: .animals),
    WordEntry(english: "Butterfly", persian: "پروانه", category: .animals),

    // ACTIONS
    WordEntry(english: "Sleeping", persian: "خوابیدن", category: .actions),
    WordEntry(english: "Crying", persian: "گریه کردن", category: .actions),
    WordEntry(english: "Swimming", persian: "شنا کردن", category: .actions),
    WordEntry(english: "Cooking", persian: "آشپزی کردن", category: .actions),
    WordEntry(english: "Driving", persian: "رانندگی کردن", category: .actions),
    WordEntry(english: "Dancing", persian: "رقصیدن", category: .actions),
    WordEntry(english: "Painting", persian: "نقاشی کردن", category: .actions),
    WordEntry(english: "Running", persian: "دویدن", category: .actions),
    WordEntry(english: "Praying", persian: "نماز خواندن", category: .actions),
    WordEntry(english: "Sneezing", persian: "عطسه کردن", category: .actions),
    WordEntry(english: "Ironing clothes", persian: "اتو کردن لباس", category: .actions),
    WordEntry(english: "Brushing teeth", persian: "مسواک زدن", category: .actions),
    WordEntry(english: "Taking a selfie", persian: "سلفی گرفتن", category: .actions),
    WordEntry(english: "Knitting", persian: "بافتنی بافتن", category: .actions),
    WordEntry(english: "Rock climbing", persian: "کوه‌نوردی", category: .actions),
    WordEntry(english: "Skipping", persian: "طناب زدن", category: .actions),
    WordEntry(english: "Whistling", persian: "سوت زدن", category: .actions),
    WordEntry(english: "Yawning", persian: "خمیازه کشیدن", category: .actions),
    WordEntry(english: "Shaving", persian: "ریش تراشیدن", category: .actions),
    WordEntry(english: "Arguing", persian: "دعوا کردن", category: .actions),

    // PROFESSIONS
    WordEntry(english: "Dentist", persian: "دندانپزشک", category: .professions),
    WordEntry(english: "Pilot", persian: "خلبان", category: .professions),
    WordEntry(english: "Chef", persian: "آشپز", category: .professions),
    WordEntry(english: "Magician", persian: "جادوگر", category: .professions),
    WordEntry(english: "Surgeon", persian: "جراح", category: .professions),
    WordEntry(english: "Astronaut", persian: "فضانورد", category: .professions),
    WordEntry(english: "Firefighter", persian: "آتش‌نشان", category: .professions),
    WordEntry(english: "Hairdresser", persian: "آرایشگر", category: .professions),
    WordEntry(english: "Photographer", persian: "عکاس", category: .professions),
    WordEntry(english: "Fisherman", persian: "ماهیگیر", category: .professions),
    WordEntry(english: "Carpenter", persian: "نجار", category: .professions),
    WordEntry(english: "Musician", persian: "نوازنده", category: .professions),
    WordEntry(english: "Judge", persian: "قاضی", category: .professions),
    WordEntry(english: "Nurse", persian: "پرستار", category: .professions),
    WordEntry(english: "Teacher", persian: "معلم", category: .professions),

    // MOVIES & TV
    WordEntry(english: "Titanic", persian: "تایتانیک", category: .movies),
    WordEntry(english: "The Godfather", persian: "پدرخوانده", category: .movies),
    WordEntry(english: "Home Alone", persian: "تنها در خانه", category: .movies),
    WordEntry(english: "Jurassic Park", persian: "پارک ژوراسیک", category: .movies),
    WordEntry(english: "The Lion King", persian: "شاه شیر", category: .movies),
    WordEntry(english: "Schindler's List", persian: "فهرست شیندلر", category: .movies),
    WordEntry(english: "Forrest Gump", persian: "فارست گامپ", category: .movies),
    WordEntry(english: "Spider-Man", persian: "مرد عنکبوتی", category: .movies),
    WordEntry(english: "Gladiator", persian: "گلادیاتور", category: .movies),
    WordEntry(english: "The Matrix", persian: "ماتریکس", category: .movies),
    WordEntry(english: "Harry Potter", persian: "هری پاتر", category: .movies),
    WordEntry(english: "Frozen", persian: "یخ‌زده", category: .movies),
    WordEntry(english: "Interstellar", persian: "بین‌ستاره‌ای", category: .movies),
    WordEntry(english: "Shrek", persian: "شرک", category: .movies),
    WordEntry(english: "The Avengers", persian: "انتقام‌جویان", category: .movies),

    // FOOD
    WordEntry(english: "Spaghetti", persian: "اسپاگتی", category: .food),
    WordEntry(english: "Watermelon", persian: "هندوانه", category: .food),
    WordEntry(english: "Ice cream", persian: "بستنی", category: .food),
    WordEntry(english: "Pizza", persian: "پیتزا", category: .food),
    WordEntry(english: "Kebab", persian: "کباب", category: .food),
    WordEntry(english: "Ghormeh Sabzi", persian: "قورمه‌سبزی", category: .food),
    WordEntry(english: "Ash Reshteh", persian: "آش رشته", category: .food),
    WordEntry(english: "Baklava", persian: "باقلوا", category: .food),
    WordEntry(english: "Cotton candy", persian: "پشمک", category: .food),
    WordEntry(english: "Hot dog", persian: "هات داگ", category: .food),
    WordEntry(english: "Sushi", persian: "سوشی", category: .food),
    WordEntry(english: "Popcorn", persian: "پاپ‌کورن", category: .food),
    WordEntry(english: "Sandwich", persian: "ساندویچ", category: .food),
    WordEntry(english: "Tahdig", persian: "ته‌دیگ", category: .food),
    WordEntry(english: "Pomegranate", persian: "انار", category: .food),

    // SPORTS
    WordEntry(english: "Soccer", persian: "فوتبال", category: .sports),
    WordEntry(english: "Basketball", persian: "بسکتبال", category: .sports),
    WordEntry(english: "Wrestling", persian: "کشتی", category: .sports),
    WordEntry(english: "Table tennis", persian: "پینگ‌پونگ", category: .sports),
    WordEntry(english: "Gymnastics", persian: "ژیمناستیک", category: .sports),
    WordEntry(english: "Skiing", persian: "اسکی", category: .sports),
    WordEntry(english: "Boxing", persian: "بوکس", category: .sports),
    WordEntry(english: "Volleyball", persian: "والیبال", category: .sports),
    WordEntry(english: "Archery", persian: "تیراندازی با کمان", category: .sports),
    WordEntry(english: "Weightlifting", persian: "وزنه‌برداری", category: .sports),
    WordEntry(english: "Swimming", persian: "شنا", category: .sports),
    WordEntry(english: "Cycling", persian: "دوچرخه‌سواری", category: .sports),
    WordEntry(english: "Karate", persian: "کاراته", category: .sports),
    WordEntry(english: "Golf", persian: "گلف", category: .sports),
    WordEntry(english: "Horse riding", persian: "اسب‌سواری", category: .sports),

    // EVERYDAY LIFE
    WordEntry(english: "Traffic jam", persian: "ترافیک", category: .everyday),
    WordEntry(english: "Alarm clock", persian: "ساعت زنگ‌دار", category: .everyday),
    WordEntry(english: "Elevator", persian: "آسانسور", category: .everyday),
    WordEntry(english: "Supermarket", persian: "سوپرمارکت", category: .everyday),
    WordEntry(english: "Wedding", persian: "عروسی", category: .everyday),
    WordEntry(english: "Birthday party", persian: "جشن تولد", category: .everyday),
    WordEntry(english: "Hospital", persian: "بیمارستان", category: .everyday),
    WordEntry(english: "Barber shop", persian: "آرایشگاه", category: .everyday),
    WordEntry(english: "Airport", persian: "فرودگاه", category: .everyday),
    WordEntry(english: "Laundry", persian: "لباسشویی", category: .everyday),
    WordEntry(english: "Moving house", persian: "引اسباب‌کشی", category: .everyday),
    WordEntry(english: "Power outage", persian: "قطع برق", category: .everyday),
    WordEntry(english: "Parking lot", persian: "پارکینگ", category: .everyday),
    WordEntry(english: "Gas station", persian: "پمپ بنزین", category: .everyday),
    WordEntry(english: "Pharmacy", persian: "داروخانه", category: .everyday),

    // NATURE
    WordEntry(english: "Earthquake", persian: "زلزله", category: .nature),
    WordEntry(english: "Volcano", persian: "آتشفشان", category: .nature),
    WordEntry(english: "Rainbow", persian: "رنگین‌کمان", category: .nature),
    WordEntry(english: "Tornado", persian: "گردباد", category: .nature),
    WordEntry(english: "Waterfall", persian: "آبشار", category: .nature),
    WordEntry(english: "Desert", persian: "بیابان", category: .nature),
    WordEntry(english: "Jungle", persian: "جنگل", category: .nature),
    WordEntry(english: "Sunset", persian: "غروب آفتاب", category: .nature),
    WordEntry(english: "Snowstorm", persian: "کولاک", category: .nature),
    WordEntry(english: "Lightning", persian: "صاعقه", category: .nature),
    WordEntry(english: "Tide", persian: "جزر و مد", category: .nature),
    WordEntry(english: "Avalanche", persian: "بهمن", category: .nature),
    WordEntry(english: "Oasis", persian: "واحه", category: .nature),
    WordEntry(english: "Glacier", persian: "یخچال طبیعی", category: .nature),
    WordEntry(english: "Thunderstorm", persian: "طوفان رعد و برق", category: .nature),

    // EMOTIONS
    WordEntry(english: "Jealousy", persian: "حسادت", category: .emotions),
    WordEntry(english: "Embarrassment", persian: "خجالت", category: .emotions),
    WordEntry(english: "Boredom", persian: "حوصله‌سر رفتن", category: .emotions),
    WordEntry(english: "Excitement", persian: "هیجان", category: .emotions),
    WordEntry(english: "Anger", persian: "عصبانیت", category: .emotions),
    WordEntry(english: "Surprise", persian: "تعجب", category: .emotions),
    WordEntry(english: "Sadness", persian: "غم", category: .emotions),
    WordEntry(english: "Confusion", persian: "سردرگمی", category: .emotions),
    WordEntry(english: "Pride", persian: "غرور", category: .emotions),
    WordEntry(english: "Disgust", persian: "انزجار", category: .emotions),
    WordEntry(english: "Fear", persian: "ترس", category: .emotions),
    WordEntry(english: "Loneliness", persian: "تنهایی", category: .emotions),
    WordEntry(english: "Happiness", persian: "شادی", category: .emotions),
    WordEntry(english: "Love", persian: "عشق", category: .emotions),
    WordEntry(english: "Nostalgia", persian: "دلتنگی", category: .emotions),

    // FAMOUS PEOPLE
    WordEntry(english: "Charlie Chaplin", persian: "چارلی چاپلین", category: .famous),
    WordEntry(english: "Einstein", persian: "انیشتین", category: .famous),
    WordEntry(english: "Cleopatra", persian: "کلئوپاترا", category: .famous),
    WordEntry(english: "Cristiano Ronaldo", persian: "کریستیانو رونالدو", category: .famous),
    WordEntry(english: "Michael Jackson", persian: "مایکل جکسون", category: .famous),
    WordEntry(english: "Napoleon", persian: "ناپلئون", category: .famous),
    WordEntry(english: "Beyoncé", persian: "بیانسه", category: .famous),
    WordEntry(english: "Elon Musk", persian: "ایلان ماسک", category: .famous),
    WordEntry(english: "Leonardo da Vinci", persian: "لئوناردو داوینچی", category: .famous),
    WordEntry(english: "Marilyn Monroe", persian: "مریلین مونرو", category: .famous),
    WordEntry(english: "Bruce Lee", persian: "بروس لی", category: .famous),
    WordEntry(english: "Freddie Mercury", persian: "فردی مرکوری", category: .famous),
    WordEntry(english: "Oprah Winfrey", persian: "اوپرا وینفری", category: .famous),
    WordEntry(english: "Muhammad Ali", persian: "محمد علی", category: .famous),
    WordEntry(english: "Shakespeare", persian: "شکسپیر", category: .famous),
]