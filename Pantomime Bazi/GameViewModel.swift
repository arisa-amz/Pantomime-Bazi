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
    var playerCount: Int = 2          // used when useNamedMembers is false
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

// MARK: - Turn Record (for scoresheet)
struct TurnRecord: Identifiable {
    let id = UUID()
    let teamIndex: Int
    let teamName: String
    let word: String
    let category: WordCategory
    let isCustom: Bool
    let basePoints: Int
    let faultCount: Int
    let hintUsed: Bool
    let guessed: Bool

    var finalPoints: Int {
        guard guessed else { return 0 }
        let deductions = faultCount + (hintUsed ? 1 : 0)
        return max(1, basePoints - deductions)
    }

    var actorName: String? = nil
}

// MARK: - Game Settings
struct GameSettings {
    var teams: [Team] = [
        Team(name: "Team 1", color: Team.defaultColors[0]),
        Team(name: "Team 2", color: Team.defaultColors[1]),
    ]
    var rounds: Int = 3
    var timePerTurn: Int = 60
    var language: AppLanguage = .english
}

// MARK: - Game Phase
enum GamePhase: Equatable {
    case setup, onboarding, teamReady, playing, turnResult, gameOver
}

// MARK: - Word Pool Manager
// Tracks used words per point tier so no word repeats until the tier is exhausted
final class WordPoolManager {
    private var usedIDs: [Int: Set<UUID>] = [3: [], 5: [], 7: []]
    private var pools:   [Int: [WordEntry]] = [:]

    func reset() { usedIDs = [3: [], 5: [], 7: []]; pools = [:] }

    func draw(points: Int, categories: Set<WordCategory>) -> WordEntry? {
        if pools[points] == nil || pools[points]!.isEmpty {
            rebuild(points: points, categories: categories)
        }
        guard var pool = pools[points], !pool.isEmpty else { return nil }
        let word = pool.removeFirst()
        pools[points] = pool
        usedIDs[points, default: []].insert(word.id)
        return word
    }

    private func rebuild(points: Int, categories: Set<WordCategory>) {
        var candidates = wordDatabase.filter {
            $0.points == points && categories.contains($0.category) && !$0.isCustom
        }
        // Remove already-used; if all used, reset tier
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

    // Turn state — set by opponent on TeamReady screen
    var currentWord: WordEntry? = nil
    var wordRevealed: Bool = false
    var currentWordPoints: Int = 5       // live score, decremented by fault/hint
    var faultCount: Int = 0
    var hintUsed: Bool = false
    var timerStarted: Bool = false       // true only after actor taps START

    var timeRemaining: Int = 60
    var isPaused: Bool = false

    var currentTeamIndex: Int = 0        // team whose member is ACTING
    var currentRound: Int = 1
    // Per-team actor index — each team cycles its own members independently
    var actorIndexPerTeam: [UUID: Int] = [:]

    var turnRecords: [TurnRecord] = []
    var lastTurnRecord: TurnRecord? = nil

    // Selected categories for this turn (opponent chooses)
    var turnCategories: Set<WordCategory> = Set(WordCategory.allCases)
    // Custom word input (opponent types)
    var customWordInput: String = ""
    // Selected points tier (opponent chooses)
    var selectedPoints: Int = 5

    private let wordPool = WordPoolManager()
    private var timerTask: Task<Void, Never>?

    var language: AppLanguage { settings.language }
    var currentTeam: Team { settings.teams[currentTeamIndex] }

    // Index of the OPPONENT team (the one picking the word)
    var opponentTeamIndex: Int {
        // Simplest: previous team picks for current team
        // With 2 teams: team 0 acts, team 1 picks
        let idx = (currentTeamIndex + settings.teams.count - 1) % settings.teams.count
        return idx
    }
    var opponentTeam: Team { settings.teams[opponentTeamIndex] }

    var currentActorName: String? {
        let team = settings.teams[currentTeamIndex]
        guard team.useNamedMembers else { return nil }
        let teamID = team.id
        let idx = actorIndexPerTeam[teamID, default: 0]
        if !team.members.isEmpty {
            // Named members defined — cycle through them
            return team.members[idx % team.members.count].name
        } else {
            // Toggle is on but no names entered — use "Player N" with playerCount
            let count = max(1, team.playerCount)
            let playerNum = (idx % count) + 1
            return language == .persian ? "بازیکن \(playerNum)" : "Player \(playerNum)"
        }
    }

    // MARK: - Start Game

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

    // MARK: - Word Selection (by opponent on TeamReady)

    func refreshWord() {
        guard customWordInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if let w = wordPool.draw(points: selectedPoints, categories: turnCategories) {
            currentWord = w
            currentWordPoints = w.points
        }
    }

    func setCustomWord() {
        let text = customWordInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        currentWord = WordEntry(customText: text)
        currentWordPoints = 7
    }

    func confirmWordAndStart(appSettings: AppSettings) {
        if !customWordInput.trimmingCharacters(in: .whitespaces).isEmpty {
            setCustomWord()
        } else if currentWord == nil {
            refreshWord()
        }
        customWordInput = ""
        wordRevealed = false
        faultCount = 0
        hintUsed = false
        timerStarted = false
        isPaused = false
        timeRemaining = settings.timePerTurn
        phase = .playing
        navPath = [.playing]
        appSettings.startPartyMusic()
    }

    // MARK: - Playing actions

    func startTimer(appSettings: AppSettings) {
        guard !timerStarted else { return }
        timerStarted = true
        runTimer(appSettings: appSettings)
    }

    func toggleReveal() { wordRevealed.toggle() }

    func applyFault(appSettings: AppSettings) {
        guard currentWordPoints > 1 else { return }
        faultCount += 1
        currentWordPoints = max(1, currentWordPoints - 1)
        appSettings.playFault()
        appSettings.hapticNotification(.warning)
    }

    func useHint(appSettings: AppSettings) {
        guard !hintUsed, currentWordPoints == 7, currentWord?.hint != nil else { return }
        hintUsed = true
        currentWordPoints = max(1, currentWordPoints - 1)
        appSettings.haptic(.medium)
    }

    func teamGuessedCorrectly(appSettings: AppSettings) {
        stopTimer()
        appSettings.stopPartyMusic()
        appSettings.playCorrect()
        appSettings.hapticNotification(.success)
        let pts = currentWordPoints
        settings.teams[currentTeamIndex].totalScore += pts
        recordTurn(guessed: true)
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

    private func recordTurn(guessed: Bool) {
        guard let word = currentWord else { return }
        let rec = TurnRecord(
            teamIndex: currentTeamIndex,
            teamName: settings.teams[currentTeamIndex].name,
            word: word.displayText(language: language),
            category: word.category,
            isCustom: word.isCustom,
            basePoints: word.points,
            faultCount: faultCount,
            hintUsed: hintUsed,
            guessed: guessed,
            actorName: currentActorName
        )
        turnRecords.append(rec)
        lastTurnRecord = rec
    }

    // MARK: - After turn result: advance

    func proceedToNextTurn() {
        // Advance the actor index for the team that JUST acted, before currentTeamIndex changes
        let justActedTeam = currentTeamIndex
        advanceActorIndex(for: justActedTeam)

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
        currentWord = nil
        selectedPoints = 5
        customWordInput = ""
    }

    private func advanceActorIndex(for teamIndex: Int) {
        let teamID = settings.teams[teamIndex].id
        actorIndexPerTeam[teamID, default: 0] += 1
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
                    self.phase = .turnResult
                    self.navPath = [.turnResult]
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
        turnRecords = []
        phase = .setup
        navPath = []
    }

    var sortedTeams: [Team] { settings.teams.sorted { $0.totalScore > $1.totalScore } }
}
