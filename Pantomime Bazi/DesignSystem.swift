//
//  AppColors.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//


import SwiftUI
import AudioToolbox
import AVFoundation

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a,r,g,b) = (255,(int>>8)*17,(int>>4&0xF)*17,(int&0xF)*17)
        case 6:  (a,r,g,b) = (255,int>>16,int>>8&0xFF,int&0xFF)
        case 8:  (a,r,g,b) = (int>>24,int>>16&0xFF,int>>8&0xFF,int&0xFF)
        default: (a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255,
                  blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - App Colors
struct AppColors {
    static let background     = Color(hex: "#EEF2FF")
    static let text           = Color(hex: "#1A1A2E")
    static let textSecondary  = Color(hex: "#6B7280")
    static let red            = Color(hex: "#FF3B5C")
    static let blue           = Color(hex: "#3B82F6")
    static let green          = Color(hex: "#10B981")
    static let yellow         = Color(hex: "#F59E0B")
    static let purple         = Color(hex: "#8B5CF6")
    static let pink           = Color(hex: "#EC4899")
    static let orange         = Color(hex: "#FF6B35")

    static func forCategory(_ cat: WordCategory) -> Color {
        switch cat {
        case .animals:     return orange
        case .actions:     return red
        case .professions: return purple
        case .movies:      return pink
        case .food:        return yellow
        case .sports:      return green
        case .everyday:    return blue
        case .nature:      return Color(hex: "#14B8A6")
        case .emotions:    return Color(hex: "#F97316")
        case .famous:      return Color(hex: "#EAB308")
        }
    }

    static func forPoints(_ pts: Int) -> Color {
        switch pts {
        case 3:  return green
        case 5:  return yellow
        case 7:  return red
        default: return blue
        }
    }
}

// MARK: - Typography
struct AppFonts {
    static func rounded(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Haptics
struct Haptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}

// MARK: - App Settings
@Observable
final class AppSettings {
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var partyMusicEnabled: Bool = false
    var countdownBeepEnabled: Bool = true
    var showWordTranslation: Bool = true
    var hasSeenOnboarding: Bool = false

    private var musicPlayer: AVAudioPlayer?
    private var musicTask: Task<Void, Never>?

    func startPartyMusic() {
        guard partyMusicEnabled, soundEnabled else { return }
        stopPartyMusic()
        if let url = Bundle.main.url(forResource: "party", withExtension: "mp3") {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try? AVAudioSession.sharedInstance().setActive(true)
            musicPlayer = try? AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = 0.45
            musicPlayer?.play()
        } else {
            // Rhythmic fallback beeps
            musicTask = Task { @MainActor in
                let sounds: [SystemSoundID] = [1103, 1104, 1103, 1104, 1103, 1103, 1104, 1103]
                var i = 0
                while !Task.isCancelled {
                    AudioServicesPlaySystemSound(sounds[i % sounds.count])
                    try? await Task.sleep(for: .milliseconds(480))
                    i += 1
                }
            }
        }
    }

    func stopPartyMusic() {
        musicPlayer?.stop(); musicPlayer = nil
        musicTask?.cancel(); musicTask = nil
    }

    func playTap() {
        guard soundEnabled else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        AudioServicesPlaySystemSound(1104)
    }

    func playCorrect() {
        guard soundEnabled else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        AudioServicesPlaySystemSound(1325)
    }

    func playFault() {
        guard soundEnabled else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        AudioServicesPlaySystemSound(1073)
    }

    func playCountdownBeep() {
        guard countdownBeepEnabled, soundEnabled else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        AudioServicesPlaySystemSound(1052)
    }

    func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    func hapticNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}

// MARK: - Navigation Routes
enum AppRoute: Hashable {
    case teamReady
    case playing
    case turnResult
    case gameOver
}

// MARK: - Reusable UI

struct FatCard<Content: View>: View {
    let color: Color
    @ViewBuilder let content: Content
    var body: some View {
        content.background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: color.opacity(0.15), radius: 12, y: 6)
        }
    }
}

struct LanguageToggle: View {
    @Binding var language: AppLanguage
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppLanguage.allCases, id: \.self) { lang in
                Button {
                    withAnimation(.spring(response: 0.3)) { language = lang }
                } label: {
                    HStack(spacing: 4) {
                        Text(lang.flagEmoji).font(.system(size: 15))
                        Text(lang.label).font(AppFonts.rounded(13, weight: .bold))
                    }
                    .padding(.horizontal, 11).padding(.vertical, 7)
                    .foregroundStyle(language == lang ? Color.white : AppColors.textSecondary)
                    .background { if language == lang { Capsule().fill(AppColors.text) } }
                }
            }
        }
        .padding(3)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
    }
}

struct StepperRow: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var color: Color = AppColors.blue
    var body: some View {
        HStack {
            Text(label).font(AppFonts.rounded(15, weight: .medium)).foregroundStyle(AppColors.text)
            Spacer()
            HStack(spacing: 12) {
                Button {
                    if value > range.lowerBound { value -= 1; Haptics.impact(.light) }
                } label: {
                    Image(systemName: "minus.circle.fill").font(.system(size: 26))
                        .foregroundStyle(value > range.lowerBound ? color : AppColors.textSecondary.opacity(0.3))
                }
                Text("\(value)").font(AppFonts.rounded(18, weight: .bold)).foregroundStyle(AppColors.text)
                    .frame(minWidth: 28, alignment: .center)
                Button {
                    if value < range.upperBound { value += 1; Haptics.impact(.light) }
                } label: {
                    Image(systemName: "plus.circle.fill").font(.system(size: 26))
                        .foregroundStyle(value < range.upperBound ? color : AppColors.textSecondary.opacity(0.3))
                }
            }
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String; let iconColor: Color
    let title: String; let subtitle: String
    @Binding var isOn: Bool
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor).frame(width: 40, height: 40)
                Image(systemName: icon).font(.system(size: 18, weight: .bold)).foregroundStyle(Color.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(AppFonts.rounded(15, weight: .bold)).foregroundStyle(AppColors.text)
                Text(subtitle).font(AppFonts.rounded(12)).foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden().tint(iconColor)
        }
        .padding(.vertical, 4)
    }
}

extension View {
    func layoutDir(_ lang: AppLanguage) -> some View {
        environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
    }
}

// MARK: - Points Badge
struct PointsBadge: View {
    let points: Int
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill").font(.system(size: 10, weight: .bold))
            Text("\(points)").font(AppFonts.rounded(13, weight: .black))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(AppColors.forPoints(points))
        .clipShape(Capsule())
    }
}
