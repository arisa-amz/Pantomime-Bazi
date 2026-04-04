//
//  AppLanguage.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//



import Foundation
import SwiftUI
import Observation

// MARK: - Team Member
struct TeamMember: Identifiable, Hashable {
    let id = UUID()
    var name: String
}

// MARK: - Team
struct Team: Identifiable {
    let id = UUID()
    var name: String
    var icon: String = "🎭"
    var playerCount: Int = 2
    var members: [TeamMember] = []
    var useNamedMembers: Bool = false
    var color: Color
    var totalScore: Int = 0

    static let defaultColors: [Color] = [
        Color(hex: "#FF3B5C"), Color(hex: "#3B82F6"), Color(hex: "#10B981"),
        Color(hex: "#F59E0B"), Color(hex: "#8B5CF6"), Color(hex: "#EC4899"),
    ]
    static let defaultIcons = ["🎭","🦁","🐯","🐻","🦊","🐺","🦄","🐸","🐧","🦋",
                                "🌟","⚡","🔥","💎","🚀","🎸","🏆","👑","🎯","🎪"]

    static func defaultName(index: Int, language: AppLanguage) -> String {
        language == .persian
            ? ["تیم یک","تیم دو","تیم سه","تیم چهار","تیم پنج","تیم شش"][safe: index] ?? "تیم \(index+1)"
            : "Team \(index + 1)"
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Turn Record
struct TurnRecord: Identifiable {
    let id = UUID()
    let teamIndex: Int
    let teamName: String
    let word: String
    let category: WordCategory
    let isCustom: Bool
    let basePoints: Int
    let faultCount: Int
    let bonusPoints: Int   // 0, 1, or 2 based on how fast they guessed
    let guessed: Bool

    var finalPoints: Int {
        guard guessed else { return 0 }
        return max(1, basePoints - faultCount) + bonusPoints
    }

    var actorName: String? = nil
}

// MARK: - Game Settings
struct GameSettings {
    var teams: [Team] = [
        Team(name: "Team 1", color: Team.defaultColors[0]),
        Team(name: "Team 2", color: Team.defaultColors[1]),
    ]

    // Re-localise team names that still have default names when language changes
    mutating func relocaliseDefaultNames(to language: AppLanguage) {
        for i in teams.indices {
            let enName = Team.defaultName(index: i, language: .english)
            let faName = Team.defaultName(index: i, language: .persian)
            // Only update if name matches either default (user hasn't customised it)
            if teams[i].name == enName || teams[i].name == faName {
                teams[i].name = Team.defaultName(index: i, language: language)
            }
        }
    }
    var rounds: Int = 3
    var timePerTurn: Int = 60
    var language: AppLanguage = .english
}

// MARK: - Game Phase
enum GamePhase: Equatable {
    case setup, teamReady, wordPick, playing, turnResult, gameOver
}

// MARK: - Word Pool Manager
final class WordPoolManager {
    private var usedIDs: [Int: Set<UUID>] = [3: [], 5: [], 7: []]
    private var pools: [Int: [WordEntry]] = [:]
    private var poolCategories: [Int: Set<WordCategory>] = [:]

    func reset() {
        usedIDs = [3: [], 5: [], 7: []]; pools = [:]; poolCategories = [:]
    }

    func draw(points: Int, categories: Set<WordCategory>) -> WordEntry? {
        let needsRebuild = pools[points] == nil
            || pools[points]!.isEmpty
            || poolCategories[points] != categories
        if needsRebuild { rebuild(points: points, categories: categories) }
        guard var pool = pools[points], !pool.isEmpty else { return nil }
        let word = pool.removeFirst()
        pools[points] = pool
        usedIDs[points, default: []].insert(word.id)
        return word
    }

    private func rebuild(points: Int, categories: Set<WordCategory>) {
        poolCategories[points] = categories
        var candidates = wordDatabase.filter {
            $0.points == points && categories.contains($0.category) && !$0.isCustom
        }
        let used = usedIDs[points, default: []]
        let fresh = candidates.filter { !used.contains($0.id) }
        if fresh.isEmpty { usedIDs[points] = []; candidates = candidates.shuffled() }
        else { candidates = fresh.shuffled() }
        pools[points] = candidates
    }
}

// MARK: - GameViewModel
@Observable
final class GameViewModel {
    var navPath: [AppRoute] = []
    var settings = GameSettings()
    var phase: GamePhase = .setup

    // Word state
    var currentWord: WordEntry? = nil
    var wordRevealed: Bool = false
    var currentWordPoints: Int = 5
    var faultCount: Int = 0

    // Timer
    var timeRemaining: Int = 60
    var isPaused: Bool = false
    var timerStarted: Bool = false

    // Progress
    var currentTeamIndex: Int = 0
    var currentRound: Int = 1
    var actorIndexPerTeam: [UUID: Int] = [:]

    // Word pick state (opponent sets these on WordPickView)
    var turnCategories: Set<WordCategory> = []  // empty by default; user picks on WordPickView
    var customWordInput: String = ""
    var selectedPoints: Int = 5

    var turnRecords: [TurnRecord] = []
    var lastTurnRecord: TurnRecord? = nil

    private let wordPool = WordPoolManager()
    private var timerTask: Task<Void, Never>?

    var language: AppLanguage { settings.language }

    func updateLanguage(_ lang: AppLanguage) {
        settings.relocaliseDefaultNames(to: lang)
        settings.language = lang
    }
    var currentTeam: Team { settings.teams[currentTeamIndex] }

    var opponentTeamIndex: Int {
        (currentTeamIndex + settings.teams.count - 1) % settings.teams.count
    }
    var opponentTeam: Team { settings.teams[opponentTeamIndex] }

    var currentActorName: String? {
        let team = settings.teams[currentTeamIndex]
        guard team.useNamedMembers else { return nil }
        let teamID = team.id
        let idx = actorIndexPerTeam[teamID, default: 0]
        if !team.members.isEmpty {
            return team.members[idx % team.members.count].name
        } else {
            let count = max(1, team.playerCount)
            let playerNum = (idx % count) + 1
            return language == .persian ? "بازیکن \(playerNum)" : "Player \(playerNum)"
        }
    }

    // MARK: - Game start

    func startGame() {
        currentRound = 1
        currentTeamIndex = 0
        actorIndexPerTeam = [:]
        turnRecords = []
        wordPool.reset()
        for i in settings.teams.indices { settings.teams[i].totalScore = 0 }
        phase = .teamReady
        navPath = [.teamReady]
    }

    // MARK: - TeamReady → WordPick

    func proceedToWordPick() {
        // Reset word state for this turn
        currentWord = nil
        customWordInput = ""
        selectedPoints = 0       // 0 = no difficulty selected yet
        turnCategories = []      // none selected by default; user picks fresh each turn
        faultCount = 0
        wordRevealed = false
        timerStarted = false
        phase = .wordPick
        navPath = [.teamReady, .wordPick]
        // Don't pre-draw — no categories selected yet
    }

    // MARK: - Word Selection (by opponent on WordPickView)

    func refreshWord() {
        guard customWordInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard selectedPoints > 0, !turnCategories.isEmpty else { return }
        if let w = wordPool.draw(points: selectedPoints, categories: turnCategories) {
            currentWord = w
            currentWordPoints = w.points
        }
    }

    /// Called when opponent confirms their word choice and wants to start
    func confirmWordAndStart(appSettings: AppSettings) {
        let customText = customWordInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !customText.isEmpty {
            currentWord = WordEntry(customText: customText)
            currentWordPoints = 9
        } else if currentWord == nil {
            refreshWord()
        } else {
            currentWordPoints = currentWord!.points
        }
        customWordInput = ""
        wordRevealed = false
        faultCount = 0
        timerStarted = false
        isPaused = false
        timeRemaining = settings.timePerTurn
        phase = .playing
        navPath = [.playing]
    }

    // MARK: - Playing actions

    func startTimer(appSettings: AppSettings) {
        guard !timerStarted else { return }
        timerStarted = true
        appSettings.startPartyMusic()
        runTimer(appSettings: appSettings)
    }

    func toggleReveal() { wordRevealed.toggle() }

    /// Actor can swap the word before starting the timer — costs 1 point
    func changeWordBeforeStart() {
        guard !timerStarted else { return }
        // Deduct 1 pt (min 1)
        currentWordPoints = max(1, currentWordPoints - 1)
        // Draw a new word from the same pool
        if let w = wordPool.draw(points: selectedPoints, categories: turnCategories) {
            currentWord = w
            // Keep the deducted points value — don't reset to word.points
        }
        wordRevealed = false
    }

    func applyFault(appSettings: AppSettings) {
        guard currentWordPoints > 1 else { return }
        faultCount += 1
        currentWordPoints = max(1, currentWordPoints - 1)
        appSettings.playFault()
        appSettings.hapticNotification(.warning)
    }

    func teamGuessedCorrectly(appSettings: AppSettings) {
        // Time bonus: if >70% time remains (guessed in first 30%) → +2
        //             if >40% time remains (guessed in first 60%) → +1
        let fractionRemaining = Double(timeRemaining) / Double(settings.timePerTurn)
        let bonus: Int
        if fractionRemaining > 0.70 { bonus = 2 }
        else if fractionRemaining > 0.40 { bonus = 1 }
        else { bonus = 0 }

        let earned = currentWordPoints + bonus
        settings.teams[currentTeamIndex].totalScore += earned
        appSettings.playCorrect()
        appSettings.hapticNotification(.success)
        appSettings.stopPartyMusic()
        stopTimer()
        recordTurn(guessed: true, bonus: bonus)
        phase = .turnResult
        navPath = [.turnResult]
    }

    func endTurnNoGuess(appSettings: AppSettings) {
        stopTimer()
        appSettings.stopPartyMusic()
        recordTurn(guessed: false)
        phase = .turnResult
        navPath = [.turnResult]
    }

    private func recordTurn(guessed: Bool, bonus: Int = 0) {
        guard let word = currentWord else { return }
        let rec = TurnRecord(
            teamIndex: currentTeamIndex,
            teamName: settings.teams[currentTeamIndex].name,
            word: word.displayText(language: language),
            category: word.category,
            isCustom: word.isCustom,
            basePoints: word.points,
            faultCount: faultCount,
            bonusPoints: bonus,
            guessed: guessed,
            actorName: currentActorName
        )
        turnRecords.append(rec)
        lastTurnRecord = rec
    }

    // MARK: - Advance

    func proceedToNextTurn() {
        let justActed = currentTeamIndex
        let teamID = settings.teams[justActed].id
        actorIndexPerTeam[teamID, default: 0] += 1

        let nextTeam = currentTeamIndex + 1
        if nextTeam >= settings.teams.count {
            if currentRound >= settings.rounds {
                phase = .gameOver; navPath = [.gameOver]
            } else {
                currentRound += 1; currentTeamIndex = 0
                phase = .teamReady; navPath = [.teamReady]
            }
        } else {
            currentTeamIndex = nextTeam
            phase = .teamReady; navPath = [.teamReady]
        }
        currentWord = nil; selectedPoints = 5; customWordInput = ""
    }

    // MARK: - Timer

    private func runTimer(appSettings: AppSettings) {
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
                    self.recordTurn(guessed: false)
                    self.phase = .turnResult; self.navPath = [.turnResult]
                    return
                }
            }
        }
    }

    func stopTimer() { timerTask?.cancel(); timerTask = nil }

    // MARK: - Exit

    func exitGame() {
        stopTimer()
        for i in settings.teams.indices { settings.teams[i].totalScore = 0 }
        turnRecords = []; phase = .setup; navPath = []
    }

    var sortedTeams: [Team] { settings.teams.sorted { $0.totalScore > $1.totalScore } }
}
