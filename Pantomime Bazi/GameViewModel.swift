//
//  AppLanguage.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//

import Foundation
import Observation
import SwiftUI

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
    static let defaultIcons = [
        "🎭", "🦁", "🐯", "🐻", "🦊", "🐺", "🦄", "🐸", "🐧", "🦋",
        "🌟", "⚡", "🔥", "💎", "🚀", "🎸", "🏆", "👑", "🎯", "🎪",
    ]

    static func defaultName(index: Int, language: AppLanguage) -> String {
        language == .persian
            ? ["تیم یک", "تیم دو", "تیم سه", "تیم چهار", "تیم پنج", "تیم شش"][
                safe: index
            ] ?? "تیم \(index+1)"
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
    let bonusPoints: Int  // 0, 1, or 2 based on how fast they guessed
    let wordChangePenalty: Int  // 1 if actor swapped the word before timer, else 0
    let guessed: Bool

    var finalPoints: Int {
        guard guessed else { return 0 }
        return max(1, basePoints - faultCount - wordChangePenalty) + bonusPoints
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
// Language-aware pool: Persian mode draws Persian-audience words, English draws English-audience.
// Full-cycle guarantee: every word is shown once before any word repeats.
// Pool key = (points, language) so Persian and English cycles are independent.

struct PoolKey: Hashable {
    let points: Int
    let language: AppLanguage
}

final class WordPoolManager {
    // Words waiting to be drawn in the current cycle
    private var pools: [PoolKey: [WordEntry]] = [:]
    // Words already drawn this cycle — used to guarantee no repeat until full cycle done
    private var usedIDs: [PoolKey: Set<UUID>] = [:]
    // Which category set each pool was built for
    private var poolCategories: [PoolKey: Set<WordCategory>] = [:]

    func reset() {
        pools = [:]
        usedIDs = [:]
        poolCategories = [:]
    }

    func draw(points: Int, categories: Set<WordCategory>, language: AppLanguage)
        -> WordEntry?
    {
        let key = PoolKey(points: points, language: language)
        let needsRebuild =
            pools[key] == nil
            || pools[key]!.isEmpty
            || poolCategories[key] != categories
        if needsRebuild {
            rebuild(key: key, categories: categories, language: language)
        }
        guard var pool = pools[key], !pool.isEmpty else { return nil }
        let word = pool.removeFirst()
        pools[key] = pool
        usedIDs[key, default: []].insert(word.id)
        return word
    }

    private func rebuild(
        key: PoolKey,
        categories: Set<WordCategory>,
        language: AppLanguage
    ) {
        poolCategories[key] = categories

        // Use the language-specific database entirely
        let db = wordDatabase(for: language)
        let all = db.filter { w in
            w.points == key.points && categories.contains(w.category)
                && !w.isCustom
        }

        // Full-cycle guarantee: only draw words not yet seen this cycle.
        // When all words exhausted, reset and start a fresh cycle.
        let used = usedIDs[key, default: []]
        let fresh = all.filter { !used.contains($0.id) }

        if fresh.isEmpty {
            usedIDs[key] = []
            pools[key] = all.shuffled()
        } else {
            pools[key] = fresh.shuffled()
        }
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
    var wordChangedPenalty: Int = 0  // 1 if word was swapped before timer
    var wordChangedCount: Int = 0  // how many times word was swapped (max 2)

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

    // Tracks category+difficulty combos already played by each team this game.
    // Key: team UUID, Value: Set of "category_points" strings e.g. "Animals_5"
    var playedCombos: [UUID: Set<String>] = [:]

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
            return language == .persian
                ? "بازیکن \(playerNum)" : "Player \(playerNum)"
        }
    }

    // MARK: - Game start

    func startGame() {
        currentRound = 1
        currentTeamIndex = 0
        actorIndexPerTeam = [:]
        turnRecords = []
        playedCombos = [:]
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
        selectedPoints = 0  // 0 = no difficulty selected yet
        turnCategories = []  // none selected by default; user picks fresh each turn
        faultCount = 0
        wordChangedPenalty = 0
        wordChangedCount = 0
        wordRevealed = false
        timerStarted = false
        phase = .wordPick
        navPath = [.teamReady, .wordPick]
        // Don't pre-draw — no categories selected yet
    }

    // MARK: - Word Selection (by opponent on WordPickView)

    func refreshWord() {
        guard customWordInput.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }
        guard selectedPoints > 0, !turnCategories.isEmpty else { return }
        if let w = wordPool.draw(
            points: selectedPoints,
            categories: turnCategories,
            language: language
        ) {
            currentWord = w
            currentWordPoints = w.points
        }
    }

    /// Called when opponent confirms their word choice and wants to start
    func confirmWordAndStart(appSettings: AppSettings) {
        let customText = customWordInput.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
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
        wordChangedPenalty = 0
        wordChangedCount = 0
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
        guard wordChangedCount < 2 else { return }  // max 2 swaps allowed
        wordChangedCount += 1
        currentWordPoints = max(1, currentWordPoints - 1)
        // penalty = total swaps done so far (1 after first swap, 2 after second)
        wordChangedPenalty = wordChangedCount
        if let w = wordPool.draw(
            points: selectedPoints,
            categories: turnCategories,
            language: language
        ) {
            currentWord = w
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
        let fractionRemaining =
            Double(timeRemaining) / Double(settings.timePerTurn)
        let bonus: Int
        if fractionRemaining > 0.70 {
            bonus = 2
        } else if fractionRemaining > 0.40 {
            bonus = 1
        } else {
            bonus = 0
        }

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
            wordChangePenalty: wordChangedPenalty,
            guessed: guessed,
            actorName: currentActorName
        )
        turnRecords.append(rec)
        lastTurnRecord = rec
        // Record the category+difficulty combo so it can't be replayed at same difficulty
        if !word.isCustom {
            let teamID = settings.teams[currentTeamIndex].id
            let combo = "\(word.category.rawValue)_\(word.points)"
            playedCombos[teamID, default: []].insert(combo)
        }
    }

    // MARK: - Advance

    func proceedToNextTurn() {
        let justActed = currentTeamIndex
        let teamID = settings.teams[justActed].id
        actorIndexPerTeam[teamID, default: 0] += 1

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

    // MARK: - Timer

    private func runTimer(appSettings: AppSettings) {
        stopTimer()
        timerTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled else { return }
                if self.isPaused { continue }
                if self.timeRemaining > 0 {
                    if self.timeRemaining <= 10 {
                        appSettings.playCountdownBeep()
                    }
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

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    // MARK: - Category/Difficulty restrictions

    /// Points already played by the current acting team in the given category
    func usedPoints(for category: WordCategory) -> Set<Int> {
        let teamID = settings.teams[currentTeamIndex].id
        let played = playedCombos[teamID, default: []]
        var used = Set<Int>()
        for pts in [3, 5, 7] {
            if played.contains("\(category.rawValue)_\(pts)") {
                used.insert(pts)
            }
        }
        return used
    }

    /// True if the acting team has played this category at ALL three difficulties
    func isCategoryFullyBlocked(_ category: WordCategory) -> Bool {
        usedPoints(for: category).count == 3
    }

    // MARK: - Exit

    func exitGame() {
        stopTimer()
        for i in settings.teams.indices { settings.teams[i].totalScore = 0 }
        turnRecords = []
        phase = .setup
        navPath = []
    }

    var sortedTeams: [Team] {
        settings.teams.sorted { $0.totalScore > $1.totalScore }
    }
}
