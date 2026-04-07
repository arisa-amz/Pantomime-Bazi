//
//  TeamReadyView.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//

import SwiftUI

// MARK: - Team Ready (actor spotlight + scoreboard only)

struct TeamReadyView: View {
    var vm: GameViewModel
    var appSettings: AppSettings

    var lang: AppLanguage { vm.language }
    func t(_ en: String, _ fa: String) -> String { lang == .persian ? fa : en }

    var actingTeam: Team { vm.settings.teams[vm.currentTeamIndex] }
    var opponentTeam: Team { vm.opponentTeam }

    @State private var appeared = false
    @State private var showExitConfirm = false

    var body: some View {
        ZStack {
            actingTeam.color.ignoresSafeArea()

            VStack(spacing: 0) {
                // Scoreboard pinned at top
                scoreBoard.padding(.top, 16)

                Spacer()

                VStack(spacing: 20) {
                    // Round badge
                    Text(
                        t(
                            "Round \(vm.currentRound) of \(vm.settings.rounds)",
                            "راند \(vm.currentRound) از \(vm.settings.rounds)"
                        )
                    )
                    .font(AppFonts.rounded(14, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .padding(.horizontal, 16).padding(.vertical, 6)
                    .background(Color.white.opacity(0.15)).clipShape(Capsule())

                    // Actor spotlight
                    actorSpotlight

                }

                Spacer()
            }
            .scaleEffect(appeared ? 1 : 0.88).opacity(appeared ? 1 : 0)

            // Button pinned to bottom of ZStack using a full-height VStack
            VStack {
                Spacer()
                Button {
                    appSettings.hapticNotification(.success)
                    vm.proceedToWordPick()
                } label: {
                    Text(t("PICK A WORD →", "انتخاب کلمه →"))
                        .font(
                            .system(size: 22, weight: .black, design: .rounded)
                        ).tracking(1)
                        .foregroundStyle(actingTeam.color)
                        .frame(maxWidth: .infinity).padding(.vertical, 22)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.2), radius: 14, y: 7)
                }
                .padding(.horizontal, 28).padding(.bottom, 48).padding(.top, 16)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showExitConfirm = true
                    appSettings.haptic(.light)
                } label: {
                    ZStack {
                        Circle().fill(Color.black.opacity(0.25)).frame(
                            width: 34,
                            height: 34
                        )
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Color.white)
                    }
                }
            }
        }
        .alert(
            t("Cancel the game?", "بازی رو لغو کنی؟"),
            isPresented: $showExitConfirm
        ) {
            Button(t("Yes, Exit", "آره، خروج"), role: .destructive) {
                appSettings.haptic(.medium)
                vm.exitGame()
            }
            Button(t("No, Continue", "نه، ادامه بده"), role: .cancel) {}
        } message: {
            Text(
                t(
                    "All rounds and scores will be lost. You'll need to set up a new game.",
                    "همه راندها و امتیازها از دست می‌روند. باید یه بازی جدید راه‌اندازی کنی."
                )
            )
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
        }
        .layoutDir(lang)
    }

    // MARK: - Actor spotlight

    var actorSpotlight: some View {
        Group {
            if let actorName = vm.currentActorName {
                VStack(spacing: 8) {
                    Text(t("🎭 It's your turn!", "🎭 نوبت توئه!"))
                        .font(AppFonts.rounded(15, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.8))
                    Text(actorName)
                        .font(
                            .system(size: 48, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(Color.white)
                    HStack(spacing: 6) {
                        Text(t("acting for", "بازی می‌کنه برای"))
                            .font(AppFonts.rounded(15)).foregroundStyle(
                                Color.white.opacity(0.7)
                            )
                        Text(actingTeam.icon)
                        Text(actingTeam.name)
                            .font(AppFonts.rounded(16, weight: .heavy))
                            .foregroundStyle(Color.white)
                    }
                }
                .padding(.vertical, 20).padding(.horizontal, 32)
                .background(Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 28)
            } else {
                // No named members
                VStack(spacing: 8) {
                    Text(actingTeam.icon).font(.system(size: 56))
                    Text(actingTeam.name)
                        .font(
                            .system(size: 42, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(Color.white)
                    Text(t("Get Ready to Act!", "آماده باش بازی کنی!"))
                        .font(AppFonts.rounded(18, weight: .heavy))
                        .foregroundStyle(Color.white.opacity(0.85))
                }
            }
        }
    }

    // MARK: - Scoreboard
    // 2 teams → classic full-width bar; 3+ teams → scrollable compact pills

    var scoreBoard: some View {
        Group {
            if vm.settings.teams.count == 2 {
                twoTeamBar
            } else {
                multiTeamPills
            }
        }
    }

    var twoTeamBar: some View {
        HStack(spacing: 0) {
            ForEach(Array(vm.settings.teams.enumerated()), id: \.element.id) {
                i,
                team in
                let isActive = i == vm.currentTeamIndex
                VStack(spacing: 3) {
                    Text(team.icon).font(.system(size: 18))
                    Text(team.name)
                        .font(AppFonts.rounded(11, weight: .heavy))
                        .foregroundStyle(Color.white).lineLimit(1)
                    Text("\(team.totalScore)")
                        .font(
                            .system(size: 22, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(isActive ? Color.yellow : Color.white)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(
                    isActive
                        ? Color.white.opacity(0.2) : Color.white.opacity(0.08)
                )

                if i == 0 {
                    Text("VS")
                        .font(
                            .system(size: 11, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.horizontal, 6)
                }
            }
        }
        .background(Color.black.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 28)
    }

    var multiTeamPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(vm.settings.teams.enumerated()), id: \.element.id)
                { i, team in
                    let isActive = i == vm.currentTeamIndex
                    HStack(spacing: 6) {
                        Text(team.icon).font(.system(size: 15))
                        VStack(alignment: .leading, spacing: 0) {
                            Text(team.name)
                                .font(AppFonts.rounded(10, weight: .heavy))
                                .foregroundStyle(
                                    isActive
                                        ? team.color : AppColors.textSecondary
                                )
                                .lineLimit(1)
                            Text(
                                "\(team.totalScore) "
                                    + (vm.language == .persian
                                        ? "امتیاز" : "pts")
                            )
                            .font(
                                .system(
                                    size: 14,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(
                                isActive ? team.color : AppColors.text
                            )
                        }
                        if isActive {
                            Image(systemName: "play.fill")
                                .font(.system(size: 8, weight: .black))
                                .foregroundStyle(team.color)
                        }
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(
                                color: isActive
                                    ? team.color.opacity(0.22)
                                    : .black.opacity(0.06),
                                radius: isActive ? 7 : 3,
                                y: 3
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isActive
                                    ? team.color.opacity(0.45) : Color.clear,
                                lineWidth: 2
                            )
                    )
                }
            }
            .padding(.horizontal, 28).padding(.vertical, 2)
        }
    }
}

// MARK: - Word Pick View (opponent chooses word)

struct WordPickView: View {
    var vm: GameViewModel
    var appSettings: AppSettings

    var lang: AppLanguage { vm.language }
    func t(_ en: String, _ fa: String) -> String { lang == .persian ? fa : en }

    var opponentTeam: Team { vm.opponentTeam }
    var actingTeam: Team { vm.settings.teams[vm.currentTeamIndex] }

    // Toggle: false = app picks from categories, true = custom word
    @State private var useCustomWord: Bool = false
    @State private var selectedPoints: Int = 0  // 0 = nothing selected yet
    @State private var showWordConfirm: Bool = false

    var body: some View {
        ZStack {
            opponentTeam.color.ignoresSafeArea()
            VStack(spacing: 0) {
                // ── Header ──
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Text(actingTeam.icon).font(.system(size: 22))
                        Text(t("Word Selection for", "انتخاب کلمه برای"))
                            .font(AppFonts.rounded(14)).foregroundStyle(
                                .white.opacity(0.75)
                            )
                        Text(actingTeam.name)
                            .font(AppFonts.rounded(16, weight: .black))
                            .foregroundStyle(.white)
                    }

                    // Toggle
                    HStack(spacing: 10) {
                        Text(t("Custom Word", "کلمه سفارشی"))
                            .font(AppFonts.rounded(14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.85))
                        Toggle("", isOn: $useCustomWord)
                            .labelsHidden()
                            .tint(AppColors.purple)
                            .onChange(of: useCustomWord) { _, _ in
                                vm.customWordInput = ""
                                if !useCustomWord { vm.refreshWord() }
                                appSettings.haptic(.light)
                            }
                    }
                    .padding(.horizontal, 20).padding(.vertical, 8)
                    .background(Color.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 28)
                }
                .padding(.top, 16).padding(.bottom, 16)

                // ── Content area (switches on toggle) ──
                if useCustomWord {
                    customWordPage
                } else {
                    appPicksPage
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    appSettings.haptic(.light)
                    vm.navPath = [.teamReady]
                    vm.phase = .teamReady
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.25))
                            .frame(width: 34, height: 34)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Color.white)
                    }
                }
            }
        }
        .alert(
            t("Are you sure?", "مطمئنی؟"),
            isPresented: $showWordConfirm
        ) {
            Button(t("Yes, Start!", "آره، شروع کن!")) {
                appSettings.hapticNotification(.success)
                vm.confirmWordAndStart(appSettings: appSettings)
            }
            Button(t("No, Edit it", "نه، ویرایش کن"), role: .cancel) {}
        } message: {
            let word = vm.customWordInput.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            Text(t("The word is: \"\(word)\"", "کلمه: «\(word)»"))
        }
        .onAppear {
            if vm.currentWord == nil { vm.refreshWord() }
        }
        .layoutDir(lang)
    }

    // MARK: - App picks mode (categories + difficulty + big GO button)

    var appPicksPage: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    categoryGrid.padding(.horizontal, 20)
                    difficultyButtons.padding(.horizontal, 20)
                    Spacer().frame(height: 100)  // room for the button
                }
                .padding(.top, 4)
            }

            // Big GO button pinned at bottom
            VStack(spacing: 0) {
                let canStart = selectedPoints > 0 && !vm.turnCategories.isEmpty
                Button {
                    guard canStart else { return }
                    appSettings.hapticNotification(.success)
                    vm.selectedPoints = selectedPoints
                    vm.refreshWord()
                    vm.confirmWordAndStart(appSettings: appSettings)
                } label: {
                    HStack(spacing: 10) {
                        if selectedPoints > 0 {
                            PointsBadge(points: selectedPoints)
                        } else {
                            Image(systemName: "arrow.up").font(
                                .system(size: 14, weight: .black)
                            )
                            .foregroundStyle(opponentTeam.color.opacity(0.6))
                        }
                        Text(
                            {
                                if canStart {
                                    return t("START TIMER →", "شروع تایمر →")
                                }
                                let noCat = vm.turnCategories.isEmpty
                                let noPts = selectedPoints == 0
                                if noCat && noPts {
                                    return t(
                                        "↑ Pick categories & difficulty",
                                        "↑ دسته‌بندی و سختی انتخاب کن"
                                    )
                                }
                                if noCat {
                                    return t(
                                        "↑ Pick at least one category",
                                        "↑ حداقل یه دسته انتخاب کن"
                                    )
                                }
                                return t(
                                    "↑ Pick a difficulty above",
                                    "↑ یه سختی انتخاب کن"
                                )
                            }()
                        )
                        .font(
                            .system(
                                size: selectedPoints == 0
                                    && vm.turnCategories.isEmpty ? 16 : 19,
                                weight: .black,
                                design: .rounded
                            )
                        ).tracking(0.5)
                    }
                    .foregroundStyle(
                        canStart
                            ? opponentTeam.color
                            : opponentTeam.color.opacity(0.45)
                    )
                    .frame(maxWidth: .infinity).padding(.vertical, 20)
                    .background(Color.white.opacity(canStart ? 1 : 0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(
                        color: .black.opacity(canStart ? 0.2 : 0),
                        radius: 14,
                        y: 7
                    )
                }
                .disabled(!canStart)
                .padding(.horizontal, 28).padding(.bottom, 48).padding(.top, 16)
            }
        }
    }

    // MARK: - Custom word mode

    var customWordPage: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil.circle.fill").font(
                        .system(size: 18, weight: .bold)
                    )
                    .foregroundStyle(AppColors.purple)
                    Text(t("Write a Custom Word", "کلمه سفارشی بنویس"))
                        .font(AppFonts.rounded(16, weight: .black))
                        .foregroundStyle(.white)
                    Spacer()
                    PointsBadge(points: 9)
                }
                Text(
                    t(
                        "Give the phone to the opponent — they write a harder word. Worth 9 points.",
                        "گوشی رو بده به تیم حریف — یه کلمه سخت‌تر می‌نویسند. ۹ امتیاز ارزش داره."
                    )
                )
                .font(AppFonts.rounded(12))
                .foregroundStyle(.white.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)

                TextField(
                    t("Type any word…", "هر کلمه‌ای بنویس…"),
                    text: Binding(
                        get: { vm.customWordInput },
                        set: { vm.customWordInput = $0 }
                    )
                )
                .font(AppFonts.rounded(17, weight: .medium))
                .foregroundStyle(AppColors.text)
                .submitLabel(.go)
                .onSubmit { confirmCustomWord() }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            }
            .padding(18)
            .background(Color.white.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 20)

            Spacer()

            // GO button — only active when text is filled
            let hasText = !vm.customWordInput.trimmingCharacters(
                in: .whitespaces
            ).isEmpty
            Button {
                confirmCustomWord()
            } label: {
                HStack(spacing: 10) {
                    PointsBadge(points: 9)
                    Text(t("START TIMER →", "شروع تایمر →"))
                        .font(
                            .system(size: 20, weight: .black, design: .rounded)
                        ).tracking(1)
                }
                .foregroundStyle(opponentTeam.color)
                .frame(maxWidth: .infinity).padding(.vertical, 20)
                .background(Color.white.opacity(hasText ? 1 : 0.35))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(
                    color: .black.opacity(hasText ? 0.2 : 0),
                    radius: 14,
                    y: 7
                )
            }
            .disabled(!hasText)
            .padding(.horizontal, 28).padding(.bottom, 48).padding(.top, 16)
        }
    }

    func confirmCustomWord() {
        let text = vm.customWordInput.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !text.isEmpty else { return }
        appSettings.haptic(.medium)
        showWordConfirm = true  // show confirmation alert with the typed word
    }

    // MARK: - Category grid

    var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(t("Categories", "دسته‌بندی‌ها"))
                    .font(AppFonts.rounded(13, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                let allSelected =
                    vm.turnCategories.count == WordCategory.allCases.count
                Button {
                    Haptics.impact(.light)
                    if allSelected {
                        vm.turnCategories = []
                    } else {
                        // Only select categories that aren't fully blocked
                        vm.turnCategories = Set(
                            WordCategory.allCases.filter {
                                !vm.isCategoryFullyBlocked($0)
                            }
                        )
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(
                            systemName: allSelected
                                ? "checkmark.square.fill" : "square.grid.2x2"
                        )
                        .font(.system(size: 13, weight: .bold))
                        Text(
                            allSelected
                                ? t("Deselect All", "حذف همه")
                                : t("Select All", "انتخاب همه")
                        )
                        .font(AppFonts.rounded(12, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.white.opacity(allSelected ? 0.3 : 0.18))
                    .clipShape(Capsule())
                }
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible()), GridItem(.flexible()),
                    GridItem(.flexible()), GridItem(.flexible()),
                ],
                spacing: 8
            ) {
                ForEach(WordCategory.allCases) { cat in
                    let isOn = vm.turnCategories.contains(cat)
                    let fullyBlocked = vm.isCategoryFullyBlocked(cat)
                    let usedPts = vm.usedPoints(for: cat)
                    let partiallyUsed = !usedPts.isEmpty && !fullyBlocked

                    Button {
                        guard !fullyBlocked else { return }
                        Haptics.impact(.light)
                        if isOn {
                            vm.turnCategories.remove(cat)
                        } else {
                            vm.turnCategories.insert(cat)
                        }
                    } label: {
                        ZStack {
                            VStack(spacing: 3) {
                                Text(cat.emoji).font(.system(size: 20))
                                Text(
                                    lang == .persian
                                        ? cat.persianName : cat.rawValue
                                )
                                .font(AppFonts.rounded(9, weight: .bold))
                                .multilineTextAlignment(.center).lineLimit(2)
                                // Show which difficulties are already used
                                if partiallyUsed {
                                    HStack(spacing: 2) {
                                        ForEach([3, 5, 7], id: \.self) { pts in
                                            Circle()
                                                .fill(
                                                    usedPts.contains(pts)
                                                        ? AppColors.forPoints(
                                                            pts
                                                        )
                                                        : Color.white.opacity(
                                                            0.2
                                                        )
                                                )
                                                .frame(width: 5, height: 5)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 8)
                            .foregroundStyle(
                                fullyBlocked
                                    ? Color.white.opacity(0.25)
                                    : (isOn
                                        ? AppColors.forCategory(cat)
                                        : Color.white.opacity(0.55))
                            )
                            .background(
                                fullyBlocked
                                    ? Color.white.opacity(0.06)
                                    : (isOn
                                        ? Color.white
                                        : Color.white.opacity(0.12))
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            // Lock icon overlay for fully blocked categories
                            if fullyBlocked {
                                VStack {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(
                                            Color.white.opacity(0.5)
                                        )
                                }
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                                .background(Color.black.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .disabled(fullyBlocked)
                }
            }
        }
    }

    // MARK: - Difficulty selector (3 toggle-style buttons, not confirm-triggering)

    var difficultyButtons: some View {
        // Compute which difficulties are blocked across ALL selected categories.
        // A difficulty is blocked for a category if it's been played.
        // We block a difficulty button if it is used in ALL currently selected categories.
        // (If even one selected category still allows that difficulty, the button stays active.)
        let blockedPts: Set<Int> = {
            guard !vm.turnCategories.isEmpty else { return [] }
            var blocked = Set<Int>()
            for pts in [3, 5, 7] {
                let blockedInAll = vm.turnCategories.allSatisfy { cat in
                    vm.usedPoints(for: cat).contains(pts)
                }
                if blockedInAll { blocked.insert(pts) }
            }
            return blocked
        }()

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(t("Difficulty", "سختی"))
                    .font(AppFonts.rounded(13, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.8))
                if !blockedPts.isEmpty {
                    Text(t("(some used)", "(بعضی استفاده شده)"))
                        .font(AppFonts.rounded(10))
                        .foregroundStyle(.white.opacity(0.55))
                }
            }

            HStack(spacing: 10) {
                ForEach([3, 5, 7], id: \.self) { pts in
                    let isBlocked = blockedPts.contains(pts)
                    let isSelected = selectedPoints == pts
                    Button {
                        guard !isBlocked else { return }
                        selectedPoints = pts
                        appSettings.haptic(.light)
                    } label: {
                        ZStack {
                            VStack(spacing: 3) {
                                Text(pts == 3 ? "😊" : pts == 5 ? "😤" : "🔥")
                                    .font(.system(size: 20))
                                    .opacity(isBlocked ? 0.3 : 1)
                                Text(
                                    lang == .persian
                                        ? "\(pts) امتیاز" : "\(pts) pts"
                                )
                                .font(AppFonts.rounded(12, weight: .black))
                                Text(
                                    pts == 3
                                        ? t("Easy", "آسون")
                                        : pts == 5
                                            ? t("Medium", "متوسط")
                                            : t("Hard", "سخت")
                                )
                                .font(AppFonts.rounded(10))
                            }
                            .foregroundStyle(
                                isBlocked
                                    ? Color.white.opacity(0.25)
                                    : (isSelected
                                        ? AppColors.forPoints(pts)
                                        : Color.white.opacity(0.65))
                            )
                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(
                                isBlocked
                                    ? Color.white.opacity(0.06)
                                    : (isSelected
                                        ? Color.white
                                        : Color.white.opacity(0.15))
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(
                                color: (!isBlocked && isSelected)
                                    ? AppColors.forPoints(pts).opacity(0.3)
                                    : .clear,
                                radius: 6,
                                y: 3
                            )

                            if isBlocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.4))
                                    .frame(
                                        maxWidth: .infinity,
                                        maxHeight: .infinity
                                    )
                                    .background(Color.black.opacity(0.12))
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 14)
                                    )
                            }
                        }
                    }
                    .disabled(isBlocked)
                }
            }
        }
    }
}

// MARK: - Playing View

struct PlayingView: View {
    var vm: GameViewModel
    var appSettings: AppSettings

    @State private var showExitConfirm = false
    @State private var sessionMusicMuted = false  // temp mute for this turn only

    var lang: AppLanguage { vm.language }
    func t(_ en: String, _ fa: String) -> String { lang == .persian ? fa : en }

    var timerColor: Color {
        if vm.timeRemaining > 20 { return AppColors.green }
        if vm.timeRemaining > 10 { return AppColors.yellow }
        return AppColors.red
    }

    var timerProgress: Double {
        Double(vm.timeRemaining) / Double(vm.settings.timePerTurn)
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                // Live score badge
                if let word = vm.currentWord {
                    HStack(spacing: 8) {
                        Text(t("Word value:", "ارزش کلمه:"))
                            .font(AppFonts.rounded(13)).foregroundStyle(
                                AppColors.textSecondary
                            )
                        PointsBadge(points: vm.currentWordPoints)
                        if word.points != vm.currentWordPoints {
                            Text(
                                lang == .persian
                                    ? "(بود \(word.points))"
                                    : "(was \(word.points))"
                            )
                            .font(AppFonts.rounded(12)).foregroundStyle(
                                AppColors.textSecondary
                            )
                        }
                    }.padding(.top, 6)
                }
                timerRing.padding(.vertical, 14)
                wordSection
                Spacer()
                if !vm.timerStarted { startButton } else { actionButtons }
            }
        }
        .navigationBarBackButtonHidden()
        .layoutDir(lang)
        .confirmationDialog(
            t("Exit game?", "خروج از بازی؟"),
            isPresented: $showExitConfirm,
            titleVisibility: .visible
        ) {
            Button(
                t("Exit to Main Menu", "خروج به منوی اصلی"),
                role: .destructive
            ) {
                appSettings.stopPartyMusic()
                vm.exitGame()
            }
            Button(t("Cancel", "انصراف"), role: .cancel) {}
        } message: {
            Text(t("Your progress will be lost.", "پیشرفت بازی از دست می‌رود."))
        }
    }

    var topBar: some View {
        HStack {
            // Exit
            Button {
                showExitConfirm = true
                appSettings.haptic(.light)
            } label: {
                ZStack {
                    Circle().fill(Color.black.opacity(0.12)).frame(
                        width: 34,
                        height: 34
                    )
                    Image(systemName: "xmark").font(
                        .system(size: 13, weight: .black)
                    ).foregroundStyle(AppColors.text)
                }
            }

            Spacer()
            HStack(spacing: 7) {
                Text(vm.currentTeam.icon)
                Text(vm.currentTeam.name).font(
                    AppFonts.rounded(15, weight: .bold)
                ).foregroundStyle(AppColors.text)
                Text("·").foregroundStyle(AppColors.textSecondary)
                Text(
                    lang == .persian
                        ? "\(vm.currentTeam.totalScore) امتیاز"
                        : "\(vm.currentTeam.totalScore) pts"
                ).font(AppFonts.rounded(15, weight: .heavy)).foregroundStyle(
                    vm.currentTeam.color
                )
            }
            Spacer()
            Button {
                vm.isPaused.toggle()
                if vm.isPaused {
                    appSettings.pausePartyMusic()
                } else {
                    appSettings.resumePartyMusic()
                }
                appSettings.haptic(.light)
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.12))
                        .frame(width: 34, height: 34)
                    Image(systemName: vm.isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(AppColors.text)
                }
            }
            .opacity(vm.timerStarted ? 1 : 0.3)
            .disabled(!vm.timerStarted)
        }
        .padding(.horizontal, 20).padding(.top, 8)
    }

    var timerRing: some View {
        ZStack {
            Circle().stroke(timerColor.opacity(0.14), lineWidth: 10).frame(
                width: 110
            )
            Circle().trim(from: 0, to: timerProgress)
                .stroke(
                    timerColor,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .frame(width: 110).rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timerProgress)
            VStack(spacing: 0) {
                Text("\(vm.timeRemaining)")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(timerColor)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.default, value: vm.timeRemaining)
                Text(t("sec", "ثانیه")).font(
                    AppFonts.rounded(11, weight: .bold)
                ).foregroundStyle(AppColors.textSecondary)
            }
        }
        .opacity(vm.timerStarted ? 1 : 0.4)
    }

    var wordSection: some View {
        VStack(spacing: 12) {
            Group {
                if vm.isPaused {
                    pausedCard
                } else if vm.wordRevealed {
                    revealedCard
                } else {
                    hiddenCard
                }
            }
            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200).padding(
                .horizontal,
                20
            )

            // Category chip — only for non-custom words
            if vm.wordRevealed && !vm.isPaused, let word = vm.currentWord,
                !word.isCustom
            {
                HStack(spacing: 5) {
                    Text(word.category.emoji)
                    Text(
                        lang == .persian
                            ? word.category.persianName : word.category.rawValue
                    )
                    .font(AppFonts.rounded(13, weight: .bold))
                }
                .padding(.horizontal, 13).padding(.vertical, 6)
                .foregroundStyle(AppColors.forCategory(word.category))
                .background(AppColors.forCategory(word.category).opacity(0.1))
                .clipShape(Capsule())
            }
        }
    }

    var hiddenCard: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                vm.toggleReveal()
            }
            appSettings.haptic(.medium)
            appSettings.playTap()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 28).fill(vm.currentTeam.color)
                    .shadow(
                        color: vm.currentTeam.color.opacity(0.4),
                        radius: 20,
                        y: 10
                    )
                VStack(spacing: 10) {
                    Image(systemName: "eye.slash.fill").font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(t("TAP TO SEE WORD", "برای دیدن کلمه بزن"))
                        .font(
                            .system(size: 16, weight: .black, design: .rounded)
                        ).foregroundStyle(.white).tracking(0.5)
                    Text(
                        t(
                            "Memorise, then hide before acting",
                            "حفظ کن، بعد پنهان کن"
                        )
                    )
                    .font(AppFonts.rounded(13)).foregroundStyle(
                        .white.opacity(0.72)
                    ).multilineTextAlignment(.center)
                }.padding(.horizontal, 28)
            }
        }.buttonStyle(.plain)
    }

    var revealedCard: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                vm.toggleReveal()
            }
            appSettings.haptic(.light)
        } label: {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 28).fill(Color.white)
                    .shadow(
                        color: AppColors.blue.opacity(0.14),
                        radius: 20,
                        y: 10
                    )
                HStack {
                    RoundedRectangle(cornerRadius: 8).fill(vm.currentTeam.color)
                        .frame(width: 6).padding(.vertical, 22)
                    Spacer()
                }.padding(.leading, 20)
                Text(t("tap again to hide", "برای پنهان کردن بزن"))
                    .font(AppFonts.rounded(11, weight: .bold)).foregroundStyle(
                        AppColors.textSecondary
                    )
                    .padding(.top, 14).padding(.trailing, 16)
                VStack(spacing: 6) {
                    if let word = vm.currentWord {
                        let disp = word.displayText(language: lang)
                        Text(disp).font(
                            .system(
                                size: disp.count > 14 ? 28 : 40,
                                weight: .black,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(AppColors.text).multilineTextAlignment(
                            .center
                        ).padding(.horizontal, 32)

                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.buttonStyle(.plain)
    }

    var pausedCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28).fill(AppColors.text).shadow(
                color: .black.opacity(0.18),
                radius: 20,
                y: 10
            )
            VStack(spacing: 10) {
                Image(systemName: "pause.circle.fill").font(.system(size: 52))
                    .foregroundStyle(.white.opacity(0.8))
                Text(t("Paused", "مکث")).font(
                    AppFonts.rounded(28, weight: .black)
                ).foregroundStyle(.white)
                Text(t("Tap ▶ to continue", "برای ادامه ▶ را بزنید")).font(
                    AppFonts.rounded(14)
                ).foregroundStyle(.white.opacity(0.55))
            }
        }
    }

    var startButton: some View {
        VStack(spacing: 10) {
            if let actor = vm.currentActorName {
                VStack(spacing: 4) {
                    Text(t("It's your turn to act!", "نوبت بازی کردن توئه!"))
                        .font(AppFonts.rounded(13, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                    HStack(spacing: 6) {
                        Image(systemName: "person.circle.fill").font(
                            .system(size: 22)
                        ).foregroundStyle(vm.currentTeam.color)
                        Text(actor).font(
                            .system(size: 24, weight: .black, design: .rounded)
                        ).foregroundStyle(vm.currentTeam.color)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(vm.currentTeam.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            } else {
                Text(
                    t(
                        "Actor: show the word to your team!",
                        "بازیکن: کلمه رو به تیمت نشون بده!"
                    )
                )
                .font(AppFonts.rounded(14, weight: .medium)).foregroundStyle(
                    AppColors.textSecondary
                )
                .multilineTextAlignment(.center).padding(.horizontal, 32)
            }

            // START TIMER
            Button {
                appSettings.hapticNotification(.success)
                sessionMusicMuted = false  // reset mute each fresh start
                if vm.wordRevealed { vm.wordRevealed = false }  // hide word when timer starts
                vm.startTimer(appSettings: appSettings)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "timer").font(
                        .system(size: 20, weight: .bold)
                    )
                    Text(t("START TIMER", "شروع تایمر")).font(
                        .system(size: 20, weight: .black, design: .rounded)
                    )
                }
                .foregroundStyle(.white).frame(maxWidth: .infinity).padding(
                    .vertical,
                    20
                )
                .background(AppColors.green).clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )
                .shadow(color: AppColors.green.opacity(0.45), radius: 12, y: 6)
            }
            .padding(.horizontal, 20)

            // CHANGE WORD — disabled for custom words or after 2 swaps
            let isCustomWord = vm.currentWord?.isCustom == true
            let swapsLeft = 2 - vm.wordChangedCount
            let canChange =
                !isCustomWord && vm.currentWordPoints > 1 && swapsLeft > 0
            Button {
                appSettings.haptic(.medium)
                vm.changeWordBeforeStart()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath").font(
                        .system(size: 14, weight: .bold)
                    )
                    if isCustomWord {
                        Text(
                            t(
                                "Custom word — can't change",
                                "کلمه سفارشی — قابل تغییر نیست"
                            )
                        )
                        .font(AppFonts.rounded(14, weight: .bold))
                    } else if swapsLeft <= 0 {
                        Text(
                            t(
                                "No more swaps (used 2/2)",
                                "عوض کردن ممکن نیست (۲/۲ استفاده شد)"
                            )
                        )
                        .font(AppFonts.rounded(14, weight: .bold))
                    } else {
                        Text(
                            t(
                                "Change Word (−1 pt) — \(swapsLeft) left",
                                "عوض کردن کلمه (−۱ امتیاز) — \(swapsLeft) بار مانده"
                            )
                        )
                        .font(AppFonts.rounded(14, weight: .bold))
                    }
                }
                .foregroundStyle(
                    canChange
                        ? AppColors.orange
                        : AppColors.textSecondary.opacity(0.35)
                )
                .frame(maxWidth: .infinity).padding(.vertical, 13)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(
                    color: .black.opacity(canChange ? 0.05 : 0),
                    radius: 5,
                    y: 3
                )
            }
            .disabled(!canChange)
            .padding(.horizontal, 20).padding(.bottom, 36)
        }
    }

    var actionButtons: some View {
        VStack(spacing: 10) {
            // Fault button (full width, no hint button)
            Button {
                vm.applyFault(appSettings: appSettings)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill").font(
                        .system(size: 20, weight: .bold)
                    )
                    Text(t("Fault (−1 pt)", "خطا (−۱ امتیاز)")).font(
                        AppFonts.rounded(15, weight: .bold)
                    )
                }
                .foregroundStyle(
                    vm.currentWordPoints > 1
                        ? Color.white : Color.white.opacity(0.4)
                )
                .frame(maxWidth: .infinity).padding(.vertical, 15)
                .background(
                    vm.currentWordPoints > 1
                        ? AppColors.orange
                        : AppColors.textSecondary.opacity(0.4)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: AppColors.orange.opacity(0.3), radius: 8, y: 4)
            }
            .disabled(vm.currentWordPoints <= 1 || vm.isPaused)
            .opacity(vm.isPaused ? 0.4 : 1)
            .padding(.horizontal, 20)

            // We Got It
            Button {
                vm.teamGuessedCorrectly(appSettings: appSettings)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill").font(
                        .system(size: 22, weight: .bold)
                    )
                    Text(
                        t(
                            "We Got It! +\(vm.currentWordPoints)",
                            "حدس زدیم! +\(vm.currentWordPoints)"
                        )
                    )
                    .font(.system(size: 20, weight: .black, design: .rounded))
                }
                .foregroundStyle(.white).frame(maxWidth: .infinity).padding(
                    .vertical,
                    18
                )
                .background(AppColors.green).clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )
                .shadow(color: AppColors.green.opacity(0.4), radius: 12, y: 6)
            }
            .disabled(vm.isPaused).opacity(vm.isPaused ? 0.4 : 1)
            .padding(.horizontal, 20)

            // End Turn
            Button {
                appSettings.haptic(.medium)
                appSettings.stopPartyMusic()
                vm.endTurnNoGuess(appSettings: appSettings)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "forward.end.fill").font(
                        .system(size: 14, weight: .bold)
                    )
                    Text(t("End Turn (0 pts)", "پایان نوبت (بدون امتیاز)"))
                        .font(AppFonts.rounded(15, weight: .bold))
                }
                .foregroundStyle(AppColors.textSecondary).frame(
                    maxWidth: .infinity
                ).padding(.vertical, 14)
                .background(Color.white).clipShape(
                    RoundedRectangle(cornerRadius: 15)
                )
                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
            }
            .disabled(vm.isPaused).opacity(vm.isPaused ? 0.4 : 1)
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 32)
    }
}

// MARK: - Turn Result View

struct TurnResultView: View {
    var vm: GameViewModel
    var appSettings: AppSettings
    var lang: AppLanguage { vm.language }
    func t(_ en: String, _ fa: String) -> String { lang == .persian ? fa : en }

    var body: some View {
        ZStack {
            (record?.guessed == true
                ? AppColors.green : AppColors.textSecondary).opacity(0.15)
                .ignoresSafeArea()
            AppColors.background.ignoresSafeArea().opacity(0.6)
            VStack(spacing: 28) {
                Spacer()
                Text(record?.guessed == true ? "🎉" : "😅").font(
                    .system(size: 80)
                )
                Text(
                    record?.guessed == true
                        ? t("Guessed!", "حدس زده شد!")
                        : t("Not this time!", "این دفعه نشد!")
                )
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.text)

                if let rec = record {
                    VStack(spacing: 0) {
                        HStack {
                            Text(t("Score Breakdown", "خلاصه امتیاز"))
                                .font(AppFonts.rounded(16, weight: .black))
                                .foregroundStyle(AppColors.text)
                            Spacer()
                        }.padding(.bottom, 14)
                        resultRow(
                            label: t("Word", "کلمه"),
                            value: rec.word,
                            color: AppColors.blue
                        )
                        if !rec.isCustom {
                            resultRow(
                                label: t("Category", "دسته"),
                                value:
                                    "\(rec.category.emoji) \(lang == .persian ? rec.category.persianName : rec.category.rawValue)",
                                color: AppColors.forCategory(rec.category)
                            )
                        }
                        resultRow(
                            label: t("Base score", "امتیاز پایه"),
                            value: lang == .persian
                                ? "\(rec.basePoints) امتیاز"
                                : "\(rec.basePoints) pts",
                            color: AppColors.forPoints(rec.basePoints)
                        )
                        if rec.faultCount > 0 {
                            resultRow(
                                label: t("Faults", "خطاها"),
                                value: lang == .persian
                                    ? "−\(rec.faultCount) امتیاز"
                                    : "−\(rec.faultCount) pts",
                                color: AppColors.orange
                            )
                        }
                        if rec.wordChangePenalty > 0 {
                            let swapLabel =
                                rec.wordChangePenalty == 1
                                ? t("Word swap ×1", "عوض کردن کلمه ×۱")
                                : t("Word swap ×2", "عوض کردن کلمه ×۲")
                            let swapValue =
                                lang == .persian
                                ? "−\(rec.wordChangePenalty) امتیاز"
                                : "−\(rec.wordChangePenalty) pts"
                            resultRow(
                                label: swapLabel,
                                value: swapValue,
                                color: AppColors.orange
                            )
                        }
                        if rec.bonusPoints > 0 {
                            resultRow(
                                label: rec.bonusPoints == 2
                                    ? t(
                                        "Speed bonus (< 30% time) ⚡",
                                        "جایزه سرعت (زیر ۳۰٪ وقت) ⚡"
                                    )
                                    : t(
                                        "Speed bonus (< 60% time) ⚡",
                                        "جایزه سرعت (زیر ۶۰٪ وقت) ⚡"
                                    ),
                                value: lang == .persian
                                    ? "+\(rec.bonusPoints) امتیاز"
                                    : "+\(rec.bonusPoints) pts",
                                color: AppColors.purple
                            )
                        }
                        Divider().padding(.vertical, 8)
                        HStack {
                            Text(t("Points earned", "امتیاز کسب‌شده"))
                                .font(AppFonts.rounded(16, weight: .heavy))
                                .foregroundStyle(AppColors.text)
                            Spacer()
                            Text(rec.guessed ? "+\(rec.finalPoints)" : "0")
                                .font(
                                    .system(
                                        size: 28,
                                        weight: .black,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(
                                    rec.guessed
                                        ? AppColors.green
                                        : AppColors.textSecondary
                                )
                        }
                    }
                    .padding(20).background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.08), radius: 14, y: 6)
                    .padding(.horizontal, 24)
                }
                Spacer()
                Button {
                    appSettings.hapticNotification(.success)
                    vm.proceedToNextTurn()
                } label: {
                    Text(t("Next Turn →", "نوبت بعدی →"))
                        .font(
                            .system(size: 19, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white).frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(
                                colors: [AppColors.blue, AppColors.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(
                            color: AppColors.blue.opacity(0.35),
                            radius: 14,
                            y: 7
                        )
                }
                .padding(.horizontal, 24).padding(.bottom, 44)
            }
        }
        .navigationBarBackButtonHidden()
        .layoutDir(lang)
    }

    var record: TurnRecord? { vm.lastTurnRecord }
    func resultRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label).font(AppFonts.rounded(14)).foregroundStyle(
                AppColors.textSecondary
            )
            Spacer()
            Text(value).font(AppFonts.rounded(14, weight: .bold))
                .foregroundStyle(color)
        }.padding(.vertical, 6)
    }
}

// MARK: - Game Over

struct GameOverView: View {
    var vm: GameViewModel
    var appSettings: AppSettings
    var lang: AppLanguage { vm.language }
    func t(_ en: String, _ fa: String) -> String { lang == .persian ? fa : en }
    @State private var appeared = false
    @State private var showFullSheet = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#1A1A2E"), Color(hex: "#16213E")],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            starsBackground
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("🏆").font(.system(size: 80))
                        .scaleEffect(appeared ? 1 : 0.4)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.5).delay(
                                0.2
                            ),
                            value: appeared
                        )
                    Text(t("Game Over!", "بازی تموم شد!"))
                        .font(
                            .system(size: 34, weight: .black, design: .rounded)
                        ).foregroundStyle(.white)
                    let topScore = vm.sortedTeams.first?.totalScore ?? 0
                    let leaders = vm.sortedTeams.filter {
                        $0.totalScore == topScore
                    }
                    if leaders.count == 1, let winner = leaders.first {
                        HStack(spacing: 6) {
                            Text(winner.icon)
                            Text(
                                t(
                                    "\(winner.name) Wins! 🎉",
                                    "\(winner.name) برنده شد! 🎉"
                                )
                            )
                        }.font(AppFonts.rounded(19, weight: .bold))
                            .foregroundStyle(winner.color)
                    } else {
                        HStack(spacing: 6) {
                            ForEach(leaders) { team in Text(team.icon) }
                            Text(t("It's a Draw! 🤝", "مساوی! 🤝"))
                        }.font(AppFonts.rounded(19, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }.padding(.top, 60).padding(.bottom, 28)

                VStack(spacing: 10) {
                    ForEach(
                        Array(vm.sortedTeams.enumerated()),
                        id: \.element.id
                    ) { rank, team in
                        HStack(spacing: 12) {
                            Text(
                                rankEmoji(
                                    rank,
                                    topScore: vm.sortedTeams.first?.totalScore
                                        ?? 0,
                                    score: team.totalScore
                                )
                            )
                            .font(.system(size: 24)).frame(width: 32)
                            Text(team.icon).font(.system(size: 20))
                            Text(team.name).font(
                                AppFonts.rounded(16, weight: .bold)
                            ).foregroundStyle(.white)
                            Spacer()
                            Text("\(team.totalScore)").font(
                                .system(
                                    size: 28,
                                    weight: .black,
                                    design: .rounded
                                )
                            ).foregroundStyle(team.color)
                            Text(lang == .persian ? "امتیاز" : "pts").font(
                                AppFonts.rounded(13, weight: .bold)
                            ).foregroundStyle(.white.opacity(0.45))
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(
                            Color.white.opacity(rank == 0 ? 0.12 : 0.06)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .offset(x: appeared ? 0 : 50).opacity(appeared ? 1 : 0)
                        .animation(
                            .spring(response: 0.5).delay(
                                Double(rank) * 0.1 + 0.35
                            ),
                            value: appeared
                        )
                    }
                }.padding(.horizontal, 20)

                Spacer()
                VStack(spacing: 10) {
                    Button {
                        showFullSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "list.clipboard.fill").font(
                                .system(size: 16, weight: .bold)
                            )
                            Text(t("Full Scoresheet", "کارنامه کامل")).font(
                                AppFonts.rounded(17, weight: .heavy)
                            )
                        }
                        .foregroundStyle(AppColors.text).frame(
                            maxWidth: .infinity
                        ).padding(.vertical, 17)
                        .background(Color.white).clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )
                    }
                    Button {
                        appSettings.hapticNotification(.success)
                        vm.startGame()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise").font(
                                .system(size: 15, weight: .bold)
                            )
                            Text(t("Play Again", "دوباره بازی")).font(
                                AppFonts.rounded(17, weight: .heavy)
                            )
                        }
                        .foregroundStyle(.white).frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(Color.white.opacity(0.18)).clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )
                    }
                    Button {
                        vm.exitGame()
                    } label: {
                        Text(t("Main Menu", "منوی اصلی")).font(
                            AppFonts.rounded(15, weight: .bold)
                        )
                        .foregroundStyle(.white.opacity(0.6)).frame(
                            maxWidth: .infinity
                        ).padding(.vertical, 15)
                        .background(Color.white.opacity(0.08)).clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )
                    }
                }.padding(.horizontal, 20).padding(.bottom, 44)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear { withAnimation { appeared = true } }
        .layoutDir(lang)
        .sheet(isPresented: $showFullSheet) {
            ScoresheetView(
                records: vm.turnRecords,
                teams: vm.settings.teams,
                language: lang
            )
        }
    }

    var starsBackground: some View {
        GeometryReader { geo in
            ForEach(0..<28, id: \.self) { i in
                Circle().fill(
                    Color.white.opacity(Double.random(in: 0.1...0.45))
                ).frame(width: CGFloat.random(in: 2...5))
                    .position(
                        x: CGFloat(i * 37 % Int(geo.size.width)),
                        y: CGFloat(i * 53 % Int(geo.size.height))
                    )
            }
        }.ignoresSafeArea()
    }

    func rankEmoji(_ rank: Int, topScore: Int, score: Int) -> String {
        let leaders = vm.sortedTeams.filter { $0.totalScore == topScore }
        if score == topScore && leaders.count > 1 { return "🥇" }
        switch rank {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "\(rank+1)."
        }
    }
}

// MARK: - Scoresheet

struct ScoresheetView: View {
    let records: [TurnRecord]
    let teams: [Team]
    let language: AppLanguage
    @Environment(\.dismiss) var dismiss
    func t(_ en: String, _ fa: String) -> String {
        language == .persian ? fa : en
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Team totals
                        HStack(spacing: 12) {
                            ForEach(
                                teams.sorted { $0.totalScore > $1.totalScore }
                            ) { team in
                                VStack(spacing: 4) {
                                    Text(team.icon).font(.system(size: 28))
                                    Text(team.name).font(
                                        AppFonts.rounded(13, weight: .bold)
                                    ).foregroundStyle(AppColors.text).lineLimit(
                                        1
                                    )
                                    Text("\(team.totalScore)").font(
                                        .system(
                                            size: 26,
                                            weight: .black,
                                            design: .rounded
                                        )
                                    ).foregroundStyle(team.color)
                                    Text(
                                        language == .persian ? "امتیاز" : "pts"
                                    ).font(AppFonts.rounded(11))
                                        .foregroundStyle(
                                            AppColors.textSecondary
                                        )
                                }
                                .frame(maxWidth: .infinity).padding(12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(
                                    color: team.color.opacity(0.15),
                                    radius: 8,
                                    y: 4
                                )
                            }
                        }.padding(.horizontal, 20).padding(.top, 8)

                        // Stats
                        let totalFaults = records.map { $0.faultCount }.reduce(
                            0,
                            +
                        )
                        let guessed = records.filter { $0.guessed }.count
                        HStack(spacing: 10) {
                            statBadge(
                                icon: "checkmark.circle.fill",
                                value: "\(guessed)/\(records.count)",
                                label: t("Guessed", "حدس زده"),
                                color: AppColors.green
                            )
                            statBadge(
                                icon: "exclamationmark.circle.fill",
                                value: "\(totalFaults)",
                                label: t("Faults", "خطاها"),
                                color: AppColors.orange
                            )
                        }.padding(.horizontal, 20)

                        // Per-team turns
                        ForEach(teams) { team in
                            let teamIdx =
                                teams.firstIndex(where: { $0.id == team.id })
                                ?? -1
                            let teamRecs = records.filter {
                                $0.teamIndex == teamIdx
                            }
                            if !teamRecs.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 8) {
                                        Text(team.icon).font(.system(size: 18))
                                        Text(team.name).font(
                                            AppFonts.rounded(16, weight: .black)
                                        ).foregroundStyle(AppColors.text)
                                        Spacer()
                                        Text(
                                            language == .persian
                                                ? "\(team.totalScore) امتیاز"
                                                : "\(team.totalScore) pts"
                                        ).font(
                                            AppFonts.rounded(14, weight: .heavy)
                                        ).foregroundStyle(team.color)
                                    }.padding(.horizontal, 20)
                                    ForEach(teamRecs) { rec in turnRow(rec: rec)
                                    }
                                }
                            }
                        }
                    }.padding(.bottom, 40)
                }
            }
            .navigationTitle(t("Scoresheet", "کارنامه"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(t("Done", "تأیید")) { dismiss() }
                        .font(AppFonts.rounded(16, weight: .bold))
                        .foregroundStyle(AppColors.blue)
                }
            }
        }.layoutDir(language)
    }

    func turnRow(rec: TurnRecord) -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(rec.guessed ? "+\(rec.finalPoints)" : "0")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(
                        rec.guessed
                            ? AppColors.forPoints(rec.basePoints)
                            : AppColors.textSecondary
                    )
                Text(
                    language == .persian
                        ? "\(rec.basePoints)★" : "\(rec.basePoints)★"
                ).font(AppFonts.rounded(10)).foregroundStyle(
                    AppColors.textSecondary
                )
            }.frame(width: 44)
            VStack(alignment: .leading, spacing: 3) {
                Text(rec.word).font(AppFonts.rounded(15, weight: .bold))
                    .foregroundStyle(AppColors.text)
                HStack(spacing: 6) {
                    if !rec.isCustom {
                        Text(rec.category.emoji).font(.system(size: 12))
                    }
                    if let actor = rec.actorName {
                        Text(actor).font(AppFonts.rounded(11)).foregroundStyle(
                            AppColors.textSecondary
                        )
                    }
                    if rec.faultCount > 0 {
                        Text("⚠️ \(rec.faultCount)").font(AppFonts.rounded(11))
                            .foregroundStyle(AppColors.orange)
                    }
                    if rec.bonusPoints > 0 {
                        Text("⚡+\(rec.bonusPoints)").font(AppFonts.rounded(11))
                            .foregroundStyle(AppColors.purple)
                    }
                }
            }
            Spacer()
            Image(
                systemName: rec.guessed
                    ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            .foregroundStyle(
                rec.guessed
                    ? AppColors.green : AppColors.textSecondary.opacity(0.5)
            )
            .font(.system(size: 20))
        }
        .padding(.horizontal, 20).padding(.vertical, 10).background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        .padding(.horizontal, 20)
    }

    func statBadge(icon: String, value: String, label: String, color: Color)
        -> some View
    {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 20, weight: .bold))
                .foregroundStyle(color)
            Text(value).font(
                .system(size: 20, weight: .black, design: .rounded)
            ).foregroundStyle(AppColors.text)
            Text(label).font(AppFonts.rounded(11)).foregroundStyle(
                AppColors.textSecondary
            )
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14).background(
            Color.white
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: color.opacity(0.12), radius: 8, y: 4)
    }
}
