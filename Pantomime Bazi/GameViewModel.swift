//
//  AppLanguage.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//
import Foundation
import SwiftUI
import Observation
import AVFoundation
import AudioToolbox

// MARK: - Language

enum AppLanguage: String, CaseIterable {
    case english = "EN"
    case persian = "FA"
    var isRTL: Bool { self == .persian }
    var flagEmoji: String { self == .english ? "🇺🇸" : "🇮🇷" }
    var label: String { self == .english ? "EN" : "فا" }
}

// MARK: - Team

struct Team: Identifiable {
    let id = UUID()
    var name: String
    var playerCount: Int = 2
    var score: Int = 0
    var color: Color

    static let defaultColors: [Color] = [
        Color(hex: "#FF3B5C"), Color(hex: "#3B82F6"), Color(hex: "#10B981"),
        Color(hex: "#F59E0B"), Color(hex: "#8B5CF6"), Color(hex: "#EC4899"),
    ]

    static func defaultName(index: Int, language: AppLanguage) -> String {
        if language == .persian {
            let names = ["تیم یک", "تیم دو", "تیم سه", "تیم چهار", "تیم پنج", "تیم شش"]
            return index < names.count ? names[index] : "تیم \(index + 1)"
        }
        return "Team \(index + 1)"
    }
}

// MARK: - Game Settings

struct GameSettings {
    var teams: [Team] = [
        Team(name: "Team 1", playerCount: 2, color: Team.defaultColors[0]),
        Team(name: "Team 2", playerCount: 2, color: Team.defaultColors[1]),
    ]
    var rounds: Int = 3
    var timePerTurn: Int = 60
    var language: AppLanguage = .english
}

// MARK: - App Settings

@Observable
final class AppSettings {
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var partyMusicEnabled: Bool = false
    var countdownBeepEnabled: Bool = true
    var showWordTranslation: Bool = true

    private var musicPlayer: AVAudioPlayer?
    private var musicTask: Task<Void, Never>?

    // MARK: Party music
    // Add a file named "party.mp3" to your Xcode bundle to use real music.
    // Without it, we fall back to a rhythmic system-sound pattern.

    func startPartyMusic() {
        guard partyMusicEnabled, soundEnabled else { return }
        stopPartyMusic()

        // Try bundled audio file first
        if let url = Bundle.main.url(forResource: "party", withExtension: "mp3") {
            musicPlayer = try? AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = 0.4
            musicPlayer?.play()
            return
        }

        // Fallback: rhythmic system beeps via async task
        musicTask = Task { @MainActor in
            let beats: [SystemSoundID] = [1103, 1104, 1103, 1104]
            var i = 0
            while !Task.isCancelled {
                AudioServicesPlaySystemSound(beats[i % beats.count])
                try? await Task.sleep(for: .milliseconds(500))
                i += 1
            }
        }
    }

    func stopPartyMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
        musicTask?.cancel()
        musicTask = nil
    }

    // MARK: Sound effects

    func playTap() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1104)
    }

    func playCorrect() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1325)
    }

    func playCountdownBeep() {
        guard countdownBeepEnabled, soundEnabled else { return }
        AudioServicesPlaySystemSound(1052)
    }

    // MARK: Haptics

    func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    func hapticNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}

// MARK: - Navigation

enum AppRoute: Hashable {
    case teamReady
    case playing
    case gameOver
}

enum GamePhase: Equatable {
    case setup, teamReady, playing, gameOver
}

// MARK: - Game ViewModel

@Observable
final class GameViewModel {
    var navPath: [AppRoute] = []
    var settings = GameSettings()
    var phase: GamePhase = .setup

    // Word state — picked fresh each turn on TeamReady screen
    var currentWord: WordEntry? = nil
    var wordRevealed: Bool = false

    // Per-turn word pool (filtered by the categories selected on TeamReady)
    var turnCategories: Set<WordCategory> = Set(WordCategory.allCases)
    var customWords: [WordEntry] = []        // user-added custom words
    private var turnWordPool: [WordEntry] = []
    private var usedWordIDs: Set<UUID> = []

    var timeRemaining: Int = 60
    var isPaused: Bool = false

    var currentTeamIndex: Int = 0
    var currentRound: Int = 1

    private var timerTask: Task<Void, Never>?

    var language: AppLanguage { settings.language }
    var currentTeam: Team { settings.teams[currentTeamIndex] }

    // MARK: - Start Game

    func startGame() {
        currentRound = 1
        currentTeamIndex = 0
        usedWordIDs = []
        for i in settings.teams.indices { settings.teams[i].score = 0 }
        phase = .teamReady
        navPath = [.teamReady]
    }

    // MARK: - Pick word for this turn (called from TeamReady before starting)

    func pickWord(categories: Set<WordCategory>) {
        turnCategories = categories
        rebuildPool(categories: categories)
        drawNextWord()
    }

    func redrawWord() {
        drawNextWord()
    }

    private func rebuildPool(categories: Set<WordCategory>) {
        let db = wordDatabase.filter { categories.contains($0.category) } + customWords
        turnWordPool = db.filter { !usedWordIDs.contains($0.id) }.shuffled()
        // If everything used, reset used set
        if turnWordPool.isEmpty {
            usedWordIDs = []
            turnWordPool = db.shuffled()
        }
    }

    private func drawNextWord() {
        if turnWordPool.isEmpty { rebuildPool(categories: turnCategories) }
        guard let word = turnWordPool.first else { return }
        currentWord = word
        usedWordIDs.insert(word.id)
        turnWordPool.removeFirst()
    }

    // MARK: - Turn control

    func startTurn(appSettings: AppSettings) {
        wordRevealed = false
        isPaused = false
        timeRemaining = settings.timePerTurn
        phase = .playing
        navPath = [.playing]
        appSettings.startPartyMusic()
        startTimer(appSettings: appSettings)
    }

    func toggleReveal() { wordRevealed.toggle() }

    func teamGuessedCorrectly(appSettings: AppSettings) {
        settings.teams[currentTeamIndex].score += 1
        appSettings.playCorrect()
        appSettings.hapticNotification(.success)
        appSettings.stopPartyMusic()
        endTurn()
    }

    func endTurn() {
        stopTimer()
        advanceTurn()
    }

    // MARK: - Exit

    func exitGame() {
        stopTimer()
        for i in settings.teams.indices { settings.teams[i].score = 0 }
        phase = .setup
        navPath = []
    }

    // MARK: - Timer

    private func startTimer(appSettings: AppSettings) {
        stopTimer()
        timerTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled else { return }
                if self.isPaused { continue }
                if self.timeRemaining > 0 {
                    if self.timeRemaining == 10 { appSettings.playCountdownBeep() }
                    self.timeRemaining -= 1
                } else {
                    appSettings.stopPartyMusic()
                    appSettings.hapticNotification(.warning)
                    self.stopTimer()
                    self.advanceTurn()
                    return
                }
            }
        }
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    // MARK: - Advance turn

    private func advanceTurn() {
        let nextTeam = currentTeamIndex + 1
        if nextTeam >= settings.teams.count {
            if currentRound >= settings.rounds {
                phase = .gameOver
                navPath = [.gameOver]
            } else {
                currentRound += 1
                currentTeamIndex = 0
                phase = .teamReady
                navPath = [.teamReady]
            }
        } else {
            currentTeamIndex = nextTeam
            phase = .teamReady
            navPath = [.teamReady]
        }
    }

    var sortedTeams: [Team] { settings.teams.sorted { $0.score > $1.score } }
}
