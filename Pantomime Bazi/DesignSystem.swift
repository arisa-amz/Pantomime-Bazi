//
//  AppColors.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//
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
        case .food:    return yellow
        case .movies:  return pink
        case .famous:  return Color(hex: "#EAB308")
        case .places:  return Color(hex: "#06B6D4")
        case .idioms:  return Color(hex: "#F97316")
        case .city:    return blue
        case .kids:    return Color(hex: "#EC4899")
        case .animals: return orange
        case .sports:  return green
        case .jobs:    return purple
        case .objects: return Color(hex: "#14B8A6")
        case .tech:    return Color(hex: "#8B5CF6")
        }
    }

    static func forPoints(_ pts: Int) -> Color {
        switch pts {
        case 3:  return green
        case 5:  return yellow
        case 7:  return red
        case 9:  return purple
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
// Reads hapticsEnabled from UserDefaults so the static helper respects the setting
// even in components that don't have direct access to AppSettings.
struct Haptics {
    static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "pantomim.hapticsEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "pantomim.hapticsEnabled")
    }
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}

// MARK: - App Settings
@Observable
final class AppSettings {
    var soundEnabled: Bool = true
    var partyMusicEnabled: Bool = true
    var countdownBeepEnabled: Bool = true

    var hapticsEnabled: Bool {
        get {
            UserDefaults.standard.object(forKey: "pantomim.hapticsEnabled") == nil
                ? true
                : UserDefaults.standard.bool(forKey: "pantomim.hapticsEnabled")
        }
        set { UserDefaults.standard.set(newValue, forKey: "pantomim.hapticsEnabled") }
    }

    // Persisted across launches via UserDefaults
    var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "pantomim.hasSeenOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "pantomim.hasSeenOnboarding") }
    }

    private var musicPlayer: AVAudioPlayer?
    private var faultPlayer: AVAudioPlayer?
    private var musicTask: Task<Void, Never>?

    init() {
        activateAudioSession()
        faultPlayer = makeBuzzPlayer()
    }

    private func activateAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback, mode: .default,
            options: [.mixWithOthers, .duckOthers]
        )
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // Descending two-tone game-show "WRONG!" buzzer:
    // Hits hard at 480Hz, sweeps down to 100Hz, with hard-clipped distortion for maximum impact.
    private func makeBuzzPlayer() -> AVAudioPlayer? {
        let sampleRate: Double = 44100
        let duration: Double = 0.45
        let frameCount = Int(sampleRate * duration)
        var samples = [Int16]()
        samples.reserveCapacity(frameCount)
        for i in 0..<frameCount {
            let t = Double(i) / sampleRate
            let progress = t / duration
            // Frequency sweeps 480Hz → 100Hz
            let freq = 480.0 - (380.0 * progress)
            // Mix fundamental + 3rd harmonic for harsh square-ish timbre
            let wave = sin(2 * .pi * freq * t) * 0.65
                     + sin(2 * .pi * freq * 3.0 * t) * 0.35
            // Instant attack, hold, sharp fade at the end
            let attack = min(1.0, Double(i) / (sampleRate * 0.004))
            let fade   = progress > 0.80 ? 1.0 - ((progress - 0.80) / 0.20) : 1.0
            // Hard clip at 0.90 → deliberate distortion = buzzer character
            let raw    = max(-0.90, min(0.90, wave * attack * fade))
            samples.append(Int16(raw * Double(Int16.max)))
        }
        let dataSize = frameCount * 2
        var wav = Data()
        func appendLE<T: FixedWidthInteger>(_ v: T) {
            var v = v.littleEndian
            wav.append(contentsOf: withUnsafeBytes(of: &v) { Array($0) })
        }
        wav.append(contentsOf: "RIFF".utf8); appendLE(UInt32(36 + dataSize))
        wav.append(contentsOf: "WAVEfmt ".utf8); appendLE(UInt32(16))
        appendLE(UInt16(1)); appendLE(UInt16(1))
        appendLE(UInt32(sampleRate)); appendLE(UInt32(UInt32(sampleRate) * 2))
        appendLE(UInt16(2)); appendLE(UInt16(16))
        wav.append(contentsOf: "data".utf8); appendLE(UInt32(dataSize))
        for s in samples { var s = s.littleEndian; wav.append(contentsOf: withUnsafeBytes(of: &s) { Array($0) }) }
        let player = try? AVAudioPlayer(data: wav, fileTypeHint: "wav")
        player?.volume = 1.0; player?.prepareToPlay()
        return player
    }

    func startPartyMusic() {
        guard partyMusicEnabled, soundEnabled else { return }
        stopPartyMusic()
        activateAudioSession()
        if let url = Bundle.main.url(forResource: "party", withExtension: "mp3") {
            musicPlayer = try? AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1; musicPlayer?.volume = 0.6; musicPlayer?.play()
        } else {
            musicTask = Task { @MainActor in
                let sounds: [SystemSoundID] = [1103, 1104, 1103, 1104, 1103, 1103, 1104, 1103]
                var i = 0
                while !Task.isCancelled {
                    AudioServicesPlaySystemSound(sounds[i % sounds.count])
                    try? await Task.sleep(for: .milliseconds(480)); i += 1
                }
            }
        }
    }

    func pausePartyMusic() {
        musicPlayer?.pause(); musicTask?.cancel(); musicTask = nil
    }

    func resumePartyMusic() {
        guard partyMusicEnabled, soundEnabled else { return }
        if let player = musicPlayer { player.play() }
        else {
            musicTask = Task { @MainActor in
                let sounds: [SystemSoundID] = [1103, 1104, 1103, 1104, 1103, 1103, 1104, 1103]
                var i = 0
                while !Task.isCancelled {
                    AudioServicesPlaySystemSound(sounds[i % sounds.count])
                    try? await Task.sleep(for: .milliseconds(480)); i += 1
                }
            }
        }
    }

    func stopPartyMusic() {
        musicPlayer?.stop(); musicPlayer = nil; musicTask?.cancel(); musicTask = nil
    }

    func playTap() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1104)
    }

    func playCorrect() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1325)
    }

    func playFault() {
        guard soundEnabled else { return }
        if let player = makeBuzzPlayer() {
            player.volume = 1.0; player.play(); faultPlayer = player
        }
    }

    func playCountdownBeep() {
        guard countdownBeepEnabled, soundEnabled else { return }
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
    case teamReady   // actor spotlight + scoreboard
    case wordPick    // opponent picks word
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
                .fill(Color.white).shadow(color: color.opacity(0.15), radius: 12, y: 6)
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
                .fill(Color.white).shadow(color: .black.opacity(0.08), radius: 8, y: 4)
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

struct PointsBadge: View {
    let points: Int
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill").font(.system(size: 10, weight: .bold))
            Text("\(points)").font(AppFonts.rounded(13, weight: .black))
        }
        .foregroundStyle(.white).padding(.horizontal, 10).padding(.vertical, 5)
        .background(AppColors.forPoints(points)).clipShape(Capsule())
    }
}

extension View {
    func layoutDir(_ lang: AppLanguage) -> some View {
        environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
    }
}
