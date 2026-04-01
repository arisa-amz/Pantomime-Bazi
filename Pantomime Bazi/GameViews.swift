//
//  TeamReadyView.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//


import SwiftUI

// MARK: - Team Ready (opponent picks word)

struct TeamReadyView: View {
    var vm: GameViewModel
    var appSettings: AppSettings

    var lang: AppLanguage { vm.language }
    func t(_ en: String, _ fa: String) -> String { lang == .persian ? fa : en }

    var actingTeam: Team { vm.settings.teams[vm.currentTeamIndex] }
    var opponentTeam: Team { vm.opponentTeam }

    @State private var appeared = false
    @State private var showCategorySheet = false

    var body: some View {
        ZStack {
            opponentTeam.color.ignoresSafeArea()
            Text("\(vm.currentRound)")
                .font(.system(size: 280, weight: .black, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.07)).offset(y: -80)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Spacer().frame(height: 8)

                    // Round badge
                    Text(t("Round \(vm.currentRound) of \(vm.settings.rounds)",
                           "راند \(vm.currentRound) از \(vm.settings.rounds)"))
                        .font(AppFonts.rounded(14, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.8))
                        .padding(.horizontal, 16).padding(.vertical, 6)
                        .background(Color.white.opacity(0.15)).clipShape(Capsule())

                    // Opponent team picks for acting team
                    VStack(spacing: 10) {
                        // Actor spotlight — shown prominently when team uses named members
                        if let actorName = vm.currentActorName {
                            VStack(spacing: 6) {
                                Text(t("🎭 It\'s your turn!", "🎭 نوبت توئه!"))
                                    .font(AppFonts.rounded(14, weight: .bold))
                                    .foregroundStyle(Color.white.opacity(0.75))
                                Text(actorName)
                                    .font(.system(size: 38, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.white)
                                Text(t("get ready to act for", "آماده شو برای تیم"))
                                    .font(AppFonts.rounded(13)).foregroundStyle(Color.white.opacity(0.7))
                                HStack(spacing: 6) {
                                    Text(actingTeam.icon).font(.system(size: 18))
                                    Text(actingTeam.name).font(AppFonts.rounded(16, weight: .heavy)).foregroundStyle(Color.white)
                                }
                            }
                            .padding(.vertical, 14).padding(.horizontal, 24)
                            .background(Color.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal, 28)
                        } else {
                            // No named members — just show which team is acting
                            HStack(spacing: 6) {
                                Text(actingTeam.icon).font(.system(size: 28))
                                Text(actingTeam.name)
                                    .font(.system(size: 26, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.white)
                                Text(t("acts!", "بازی می‌کنه!"))
                                    .font(AppFonts.rounded(18)).foregroundStyle(Color.white.opacity(0.8))
                            }
                        }

                        // Opponent label
                        HStack(spacing: 5) {
                            Text(opponentTeam.icon).font(.system(size: 14))
                            Text(opponentTeam.name).font(AppFonts.rounded(13, weight: .bold)).foregroundStyle(Color.white.opacity(0.7))
                            Text(t("picks the word below ↓", "کلمه رو انتخاب می‌کنه ↓"))
                                .font(AppFonts.rounded(13)).foregroundStyle(Color.white.opacity(0.6))
                        }
                    }

                    // ── Compact scoreboard above word panel ──
                    scoreBoard

                    // ── Word selection panel ──
                    wordSelectionPanel

                    // Start button
                    Button {
                        appSettings.hapticNotification(.success)
                        vm.confirmWordAndStart(appSettings: appSettings)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                            Text(t("START TURN!", "شروع نوبت!"))
                                .font(.system(size: 19, weight: .black, design: .rounded)).tracking(1)
                        }
                        .foregroundStyle(opponentTeam.color).frame(maxWidth: .infinity).padding(.vertical, 20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.2), radius: 14, y: 7)
                    }
                    .disabled(vm.currentWord == nil && vm.customWordInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal, 28).padding(.bottom, 44)
                }
            }
            .scaleEffect(appeared ? 1 : 0.88).opacity(appeared ? 1 : 0)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { appSettings.haptic(.medium); vm.exitGame() } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 22))
                        .foregroundStyle(Color.white.opacity(0.75))
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { appeared = true }
            // Auto-draw a word when this view appears
            vm.refreshWord()
        }
        .sheet(isPresented: $showCategorySheet) {
            CategorySheet(selectedCategories: Binding(
                get: { vm.turnCategories }, set: { vm.turnCategories = $0 }
            ), language: lang, onDone: { vm.refreshWord() })
        }
        .layoutDir(lang)
    }

    // MARK: - Football Scoreboard

    var scoreBoard: some View {
        HStack(spacing: 0) {
            ForEach(Array(vm.settings.teams.enumerated()), id: \.element.id) { i, team in
                HStack(spacing: 0) {
                    VStack(spacing: 4) {
                        Text(team.icon).font(.system(size: 16))
                        Text(team.name).font(AppFonts.rounded(10, weight: .heavy))
                            .foregroundStyle(Color.white).lineLimit(1)
                        Text("\(team.totalScore)")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(i == vm.currentTeamIndex ? Color.yellow : Color.white)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 8)
                    .background(i == vm.currentTeamIndex ? Color.white.opacity(0.2) : Color.white.opacity(0.08))

                    if i < vm.settings.teams.count - 1 {
                        Text("VS").font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5)).padding(.horizontal, 4)
                    }
                }
            }
        }
        .background(Color.black.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 28)
    }

    // MARK: - Word Selection Panel

    var wordSelectionPanel: some View {
        VStack(spacing: 12) {
            // ── Difficulty selector ──
            VStack(alignment: .leading, spacing: 8) {
                Text(t("Difficulty (score)", "سختی (امتیاز)"))
                    .font(AppFonts.rounded(13, weight: .heavy)).foregroundStyle(.white.opacity(0.8))
                    .padding(.leading, 4)
                HStack(spacing: 10) {
                    ForEach([3, 5, 7], id: \.self) { pts in
                        Button {
                            vm.selectedPoints = pts
                            vm.customWordInput = ""
                            vm.refreshWord()
                            appSettings.haptic(.light)
                        } label: {
                            VStack(spacing: 4) {
                                Text(pts == 3 ? "😊" : pts == 5 ? "😤" : "🔥").font(.system(size: 22))
                                Text("\(pts) pts").font(AppFonts.rounded(13, weight: .black))
                                Text(pts == 3 ? t("Easy","آسون") : pts == 5 ? t("Medium","متوسط") : t("Hard","سخت"))
                                    .font(AppFonts.rounded(11))
                            }
                            .foregroundStyle(vm.selectedPoints == pts ? AppColors.forPoints(pts) : Color.white.opacity(0.7))
                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(vm.selectedPoints == pts ? Color.white : Color.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
            }
            .padding(.horizontal, 28)

            // ── Category filter ──
            Button { showCategorySheet = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "tag.fill").font(.system(size: 13, weight: .bold))
                    Text(categoryLabel).font(AppFonts.rounded(13, weight: .bold)).lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 11))
                }
                .foregroundStyle(.white).padding(.horizontal, 16).padding(.vertical, 10)
                .background(Color.white.opacity(0.18)).clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 28)

            // ── Current word card ──
            if let word = vm.currentWord, vm.customWordInput.trimmingCharacters(in: .whitespaces).isEmpty {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(word.displayText(language: lang))
                            .font(AppFonts.rounded(20, weight: .black)).foregroundStyle(AppColors.text)
                        HStack(spacing: 6) {
                            if !word.isCustom {
                                Text(word.category.emoji)
                                Text(lang == .persian ? word.category.persianName : word.category.rawValue)
                                    .font(AppFonts.rounded(12)).foregroundStyle(AppColors.textSecondary)
                            }
                            PointsBadge(points: word.points)
                        }
                    }
                    Spacer()
                    Button {
                        vm.refreshWord()
                        appSettings.haptic(.light)
                    } label: {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 32)).foregroundStyle(opponentTeam.color)
                    }
                }
                .padding(16).background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
                .padding(.horizontal, 28)
            }

            // ── Custom word box ──
            VStack(alignment: .leading, spacing: 6) {
                Text(t("Or type a custom word (7 pts):", "یا یه کلمه سفارشی بنویس (۷ امتیاز):"))
                    .font(AppFonts.rounded(12, weight: .bold)).foregroundStyle(.white.opacity(0.8))
                TextField(t("Type any word…", "هر کلمه‌ای بنویس…"), text: Binding(
                    get: { vm.customWordInput },
                    set: { vm.customWordInput = $0 }
                ))
                .font(AppFonts.rounded(16, weight: .medium)).foregroundStyle(AppColors.text)
                .submitLabel(.done).padding(14)
                .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
            }
            .padding(.horizontal, 28)
        }
    }

    var categoryLabel: String {
        let cats = vm.turnCategories
        if cats.count == WordCategory.allCases.count { return t("All Categories", "همه دسته‌بندی‌ها") }
        if cats.count == 1, let c = cats.first { return "\(c.emoji) \(lang == .persian ? c.persianName : c.rawValue)" }
        return t("\(cats.count) Categories", "\(cats.count) دسته")
    }
}

// MARK: - Category Sheet (from TeamReady)

struct CategorySheet: View {
    @Binding var selectedCategories: Set<WordCategory>
    let language: AppLanguage
    let onDone: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            Button {
                                selectedCategories = Set(WordCategory.allCases); Haptics.impact(.light)
                            } label: {
                                Text(language == .persian ? "همه" : "Select All")
                                    .font(AppFonts.rounded(14, weight: .bold)).foregroundStyle(AppColors.blue)
                                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                                    .background(AppColors.blue.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            Button {
                                if selectedCategories.count > 1 { selectedCategories = [WordCategory.allCases.first!]; Haptics.impact(.light) }
                            } label: {
                                Text(language == .persian ? "حذف همه" : "Clear All")
                                    .font(AppFonts.rounded(14, weight: .bold)).foregroundStyle(AppColors.red)
                                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                                    .background(AppColors.red.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }.padding(.horizontal, 18).padding(.top, 10)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(WordCategory.allCases) { cat in
                                let isOn = selectedCategories.contains(cat)
                                Button {
                                    Haptics.impact(.light)
                                    if isOn { if selectedCategories.count > 1 { selectedCategories.remove(cat) } }
                                    else { selectedCategories.insert(cat) }
                                } label: {
                                    VStack(spacing: 7) {
                                        Text(cat.emoji).font(.system(size: 28))
                                        Text(language == .persian ? cat.persianName : cat.rawValue)
                                            .font(AppFonts.rounded(12, weight: .bold)).multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                                    .foregroundStyle(isOn ? Color.white : AppColors.text)
                                    .background {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(isOn ? AppColors.forCategory(cat) : Color.white)
                                            .shadow(color: isOn ? AppColors.forCategory(cat).opacity(0.28) : .black.opacity(0.06), radius: 6, y: 3)
                                    }
                                }
                            }
                        }.padding(.horizontal, 18).padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle(language == .persian ? "دسته‌بندی‌ها" : "Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(language == .persian ? "تأیید" : "Done") { onDone(); dismiss() }
                        .font(AppFonts.rounded(16, weight: .bold)).foregroundStyle(AppColors.blue)
                }
            }
        }
        .layoutDir(language)
    }
}

// MARK: - Playing View

struct PlayingView: View {
    var vm: GameViewModel
    var appSettings: AppSettings
    @State private var showExitConfirm = false
    @State private var showHint = false

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
                // Score badge
                if let word = vm.currentWord {
                    HStack(spacing: 8) {
                        Text(t("Current word value:", "ارزش کلمه:")).font(AppFonts.rounded(13)).foregroundStyle(AppColors.textSecondary)
                        PointsBadge(points: vm.currentWordPoints)
                        if word.points != vm.currentWordPoints {
                            Text("(was \(word.points))").font(AppFonts.rounded(12)).foregroundStyle(AppColors.textSecondary)
                        }
                    }.padding(.top, 6)
                }
                timerRing.padding(.vertical, 14)
                wordSection
                Spacer()
                if !vm.timerStarted {
                    startButton
                } else {
                    actionButtons
                }
            }
        }
        .navigationBarBackButtonHidden()
        .layoutDir(lang)
        .confirmationDialog(t("Exit game?","خروج از بازی؟"), isPresented: $showExitConfirm, titleVisibility: .visible) {
            Button(t("Exit to Main Menu","خروج به منوی اصلی"), role: .destructive) {
                appSettings.stopPartyMusic(); vm.exitGame()
            }
            Button(t("Cancel","انصراف"), role: .cancel) {}
        } message: { Text(t("Your progress will be lost.","پیشرفت بازی از دست می‌رود.")) }
        .sheet(isPresented: $showHint) {
            if let hint = vm.currentWord?.hint {
                HintSheet(hint: hint, language: lang)
            }
        }
    }

    var topBar: some View {
        HStack {
            Button { showExitConfirm = true; appSettings.haptic(.light) } label: {
                Image(systemName: "xmark.circle.fill").font(.system(size: 26))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.55))
            }
            Spacer()
            VStack(spacing: 2) {
                HStack(spacing: 7) {
                    Text(vm.currentTeam.icon)
                    Text(vm.currentTeam.name).font(AppFonts.rounded(15, weight: .bold)).foregroundStyle(AppColors.text)
                    Text("·").foregroundStyle(AppColors.textSecondary)
                    Text("\(vm.currentTeam.totalScore) pts").font(AppFonts.rounded(15, weight: .heavy)).foregroundStyle(vm.currentTeam.color)
                }
                if let actor = vm.currentActorName {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill").font(.system(size: 10, weight: .bold))
                        Text(t("Acting: \(actor)", "بازیکن: \(actor)"))
                            .font(AppFonts.rounded(12, weight: .heavy))
                    }
                    .foregroundStyle(vm.currentTeam.color)
                }
            }
            Spacer()
            Button {
                if vm.timerStarted { vm.isPaused.toggle() }
                if vm.isPaused { appSettings.stopPartyMusic() } else { appSettings.startPartyMusic() }
                appSettings.haptic(.light)
            } label: {
                Image(systemName: vm.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 15, weight: .bold)).foregroundStyle(AppColors.text)
                    .frame(width: 34, height: 34).background(Color.white).clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            }
            .opacity(vm.timerStarted ? 1 : 0.4)
        }
        .padding(.horizontal, 20).padding(.top, 8)
    }

    var timerRing: some View {
        ZStack {
            Circle().stroke(timerColor.opacity(0.14), lineWidth: 10).frame(width: 110)
            Circle().trim(from: 0, to: timerProgress)
                .stroke(timerColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 110).rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timerProgress)
            VStack(spacing: 0) {
                Text("\(vm.timeRemaining)")
                    .font(.system(size: 36, weight: .black, design: .rounded)).foregroundStyle(timerColor)
                    .contentTransition(.numericText(countsDown: true)).animation(.default, value: vm.timeRemaining)
                Text(t("sec","ثانیه")).font(AppFonts.rounded(11, weight: .bold)).foregroundStyle(AppColors.textSecondary)
            }
        }
        .opacity(vm.timerStarted ? 1 : 0.4)
    }

    var wordSection: some View {
        VStack(spacing: 12) {
            Group {
                if vm.isPaused { pausedCard }
                else if vm.wordRevealed { revealedCard }
                else { hiddenCard }
            }
            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200).padding(.horizontal, 20)

            if vm.wordRevealed && !vm.isPaused, let word = vm.currentWord, !word.isCustom {
                HStack(spacing: 6) {
                    Text(word.category.emoji)
                    Text(lang == .persian ? word.category.persianName : word.category.rawValue)
                        .font(AppFonts.rounded(13, weight: .bold))
                }
                .padding(.horizontal, 13).padding(.vertical, 6)
                .foregroundStyle(AppColors.forCategory(word.category))
                .background(AppColors.forCategory(word.category).opacity(0.1)).clipShape(Capsule())
            }
        }
    }

    var hiddenCard: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { vm.toggleReveal() }
            appSettings.haptic(.medium); appSettings.playTap()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 28).fill(vm.currentTeam.color)
                    .shadow(color: vm.currentTeam.color.opacity(0.4), radius: 20, y: 10)
                VStack(spacing: 10) {
                    Image(systemName: "eye.slash.fill").font(.system(size: 40)).foregroundStyle(.white.opacity(0.9))
                    Text(t("TAP TO SEE WORD","برای دیدن کلمه بزن"))
                        .font(.system(size: 16, weight: .black, design: .rounded)).foregroundStyle(.white).tracking(0.5)
                    Text(t("Memorise, then hide before acting","حفظ کن، بعد پنهان کن"))
                        .font(AppFonts.rounded(13)).foregroundStyle(.white.opacity(0.72)).multilineTextAlignment(.center)
                }.padding(.horizontal, 28)
            }
        }.buttonStyle(.plain)
    }

    var revealedCard: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { vm.toggleReveal() }
            appSettings.haptic(.light)
        } label: {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 28).fill(Color.white)
                    .shadow(color: AppColors.blue.opacity(0.14), radius: 20, y: 10)
                HStack {
                    RoundedRectangle(cornerRadius: 8).fill(vm.currentTeam.color)
                        .frame(width: 6).padding(.vertical, 22)
                    Spacer()
                }.padding(.leading, 20)
                Text(t("tap again to hide","برای پنهان کردن بزن"))
                    .font(AppFonts.rounded(11, weight: .bold)).foregroundStyle(AppColors.textSecondary)
                    .padding(.top, 14).padding(.trailing, 16)
                VStack(spacing: 6) {
                    if let word = vm.currentWord {
                        let disp = word.displayText(language: lang)
                        Text(disp).font(.system(size: disp.count > 14 ? 28 : 40, weight: .black, design: .rounded))
                            .foregroundStyle(AppColors.text).multilineTextAlignment(.center).padding(.horizontal, 32)
                        if appSettings.showWordTranslation && !word.isCustom {
                            Text(lang == .persian ? word._english : word._persian)
                                .font(AppFonts.rounded(15, weight: .medium)).foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.buttonStyle(.plain)
    }

    var pausedCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28).fill(AppColors.text).shadow(color: .black.opacity(0.18), radius: 20, y: 10)
            VStack(spacing: 10) {
                Image(systemName: "pause.circle.fill").font(.system(size: 52)).foregroundStyle(.white.opacity(0.8))
                Text(t("Paused","مکث")).font(AppFonts.rounded(28, weight: .black)).foregroundStyle(.white)
                Text(t("Tap ▶ to continue","برای ادامه ▶ را بزنید")).font(AppFonts.rounded(14)).foregroundStyle(.white.opacity(0.55))
            }
        }
    }

    // START button (before timer begins)
    var startButton: some View {
        VStack(spacing: 12) {
            // Show actor name prominently if team uses named members
            if let actor = vm.currentActorName {
                VStack(spacing: 4) {
                    Text(t("It\'s your turn to act!", "نوبت بازی کردن توئه!"))
                        .font(AppFonts.rounded(13, weight: .medium)).foregroundStyle(AppColors.textSecondary)
                    HStack(spacing: 6) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 22)).foregroundStyle(vm.currentTeam.color)
                        Text(actor)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(vm.currentTeam.color)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(vm.currentTeam.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            } else {
                Text(t("Actor: show the word to your team!","بازیکن: کلمه رو به تیمت نشون بده!"))
                    .font(AppFonts.rounded(14, weight: .medium)).foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 32)
            }
            Button {
                appSettings.hapticNotification(.success)
                vm.startTimer(appSettings: appSettings)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "timer").font(.system(size: 20, weight: .bold))
                    Text(t("START TIMER","شروع تایمر")).font(.system(size: 20, weight: .black, design: .rounded))
                }
                .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 20)
                .background(AppColors.green).clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: AppColors.green.opacity(0.45), radius: 12, y: 6)
            }
            .padding(.horizontal, 20).padding(.bottom, 36)
        }
    }

    // In-game buttons
    var actionButtons: some View {
        VStack(spacing: 10) {
            // Row 1: Fault | Hint
            HStack(spacing: 10) {
                // FAULT button
                Button {
                    vm.applyFault(appSettings: appSettings)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill").font(.system(size: 20, weight: .bold))
                        Text(t("Fault (-1)","خطا (-۱)")).font(AppFonts.rounded(13, weight: .bold))
                    }
                    .foregroundStyle(vm.currentWordPoints > 1 ? Color.white : Color.white.opacity(0.4))
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(vm.currentWordPoints > 1 ? AppColors.orange : AppColors.textSecondary.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: AppColors.orange.opacity(0.35), radius: 8, y: 4)
                }
                .disabled(vm.currentWordPoints <= 1 || vm.isPaused)

                // HINT button — only for 7-pt non-custom words with hints, only if not used
                if let word = vm.currentWord, word.points == 7 && !word.isCustom && word.hint != nil {
                    Button {
                        if !vm.hintUsed {
                            vm.useHint(appSettings: appSettings)
                        }
                        showHint = true
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: vm.hintUsed ? "lightbulb.fill" : "lightbulb").font(.system(size: 20, weight: .bold))
                            Text(vm.hintUsed ? t("Hint (-1 used)","راهنما (استفاده شد)") : t("Hint (-1 pt)","راهنما (-۱)"))
                                .font(AppFonts.rounded(12, weight: .bold))
                        }
                        .foregroundStyle(.white.opacity(vm.hintUsed ? 0.55 : 1))
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(AppColors.purple.opacity(vm.hintUsed ? 0.5 : 1))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(color: AppColors.purple.opacity(0.35), radius: 8, y: 4)
                    }
                    .disabled(vm.isPaused)
                }
            }
            .padding(.horizontal, 20)

            // Row 2: We Got It
            Button {
                vm.teamGuessedCorrectly(appSettings: appSettings)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 22, weight: .bold))
                    Text(t("We Got It! +\(vm.currentWordPoints)","حدس زدیم! +\(vm.currentWordPoints)"))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                }
                .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(AppColors.green).clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: AppColors.green.opacity(0.4), radius: 12, y: 6)
            }
            .disabled(vm.isPaused).opacity(vm.isPaused ? 0.4 : 1)
            .padding(.horizontal, 20)

            // Row 3: End turn
            Button {
                appSettings.haptic(.medium)
                appSettings.stopPartyMusic()
                vm.endTurnNoGuess(appSettings: appSettings)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "forward.end.fill").font(.system(size: 14, weight: .bold))
                    Text(t("End Turn (0 pts)","پایان نوبت (بدون امتیاز)")).font(AppFonts.rounded(15, weight: .bold))
                }
                .foregroundStyle(AppColors.textSecondary).frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
            }
            .disabled(vm.isPaused).opacity(vm.isPaused ? 0.4 : 1)
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 32)
    }
}

// MARK: - Hint Sheet

struct HintSheet: View {
    let hint: String; let language: AppLanguage
    @Environment(\.dismiss) var dismiss
    func t(_ en: String, _ fa: String) -> String { language == .persian ? fa : en }
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lightbulb.fill").font(.system(size: 52)).foregroundStyle(AppColors.yellow)
            Text(t("Hint","راهنما")).font(.system(size: 28, weight: .black, design: .rounded)).foregroundStyle(AppColors.text)
            Text(hint).font(AppFonts.rounded(18, weight: .medium)).foregroundStyle(AppColors.text)
                .multilineTextAlignment(.center).padding(.horizontal, 32)
            Text(t("This hint cost you 1 point.","این راهنما ۱ امتیاز کم کرد."))
                .font(AppFonts.rounded(13)).foregroundStyle(AppColors.textSecondary)
            Spacer()
            Button { dismiss() } label: {
                Text(t("Got it!","متوجه شدم!")).font(AppFonts.rounded(17, weight: .heavy)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 17)
                    .background(AppColors.yellow).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 28).padding(.bottom, 32)
        }
        .layoutDir(language)
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
            (record?.guessed == true ? AppColors.green : AppColors.textSecondary).opacity(0.15).ignoresSafeArea()
            AppColors.background.ignoresSafeArea().opacity(0.6)

            VStack(spacing: 28) {
                Spacer()
                // Result icon
                Text(record?.guessed == true ? "🎉" : "😅").font(.system(size: 80))
                Text(record?.guessed == true ? t("Guessed!","حدس زده شد!") : t("Not this time!","این دفعه نشد!"))
                    .font(.system(size: 32, weight: .black, design: .rounded)).foregroundStyle(AppColors.text)

                // Score breakdown card
                if let rec = record {
                    VStack(spacing: 0) {
                        HStack {
                            Text(t("Score Breakdown","خلاصه امتیاز"))
                                .font(AppFonts.rounded(16, weight: .black)).foregroundStyle(AppColors.text)
                            Spacer()
                        }
                        .padding(.bottom, 14)

                        resultRow(label: t("Word","کلمه"), value: rec.word, color: AppColors.blue)
                        if !rec.isCustom {
                            resultRow(label: t("Category","دسته"), value: "\(rec.category.emoji) \(lang == .persian ? rec.category.persianName : rec.category.rawValue)", color: AppColors.forCategory(rec.category))
                        }
                        resultRow(label: t("Base score","امتیاز پایه"), value: "\(rec.basePoints) pts", color: AppColors.forPoints(rec.basePoints))
                        if rec.faultCount > 0 {
                            resultRow(label: t("Faults","خطاها"), value: "-\(rec.faultCount) pts", color: AppColors.orange)
                        }
                        if rec.hintUsed {
                            resultRow(label: t("Hint used","راهنما استفاده شد"), value: "-1 pt", color: AppColors.purple)
                        }
                        Divider().padding(.vertical, 8)
                        HStack {
                            Text(t("Points earned","امتیاز کسب‌شده"))
                                .font(AppFonts.rounded(16, weight: .heavy)).foregroundStyle(AppColors.text)
                            Spacer()
                            Text(rec.guessed ? "+\(rec.finalPoints)" : "0")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(rec.guessed ? AppColors.green : AppColors.textSecondary)
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
                    Text(t("Next Turn →","نوبت بعدی →"))
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 20)
                        .background(LinearGradient(colors: [AppColors.blue, AppColors.purple], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: AppColors.blue.opacity(0.35), radius: 14, y: 7)
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
            Text(label).font(AppFonts.rounded(14)).foregroundStyle(AppColors.textSecondary)
            Spacer()
            Text(value).font(AppFonts.rounded(14, weight: .bold)).foregroundStyle(color)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Game Over / Final Scoresheet

struct GameOverView: View {
    var vm: GameViewModel
    var appSettings: AppSettings

    var lang: AppLanguage { vm.language }
    func t(_ en: String, _ fa: String) -> String { lang == .persian ? fa : en }

    @State private var appeared = false
    @State private var showFullSheet = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#1A1A2E"), Color(hex: "#16213E")],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            starsBackground
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("🏆").font(.system(size: 80))
                        .scaleEffect(appeared ? 1 : 0.4)
                        .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2), value: appeared)
                    Text(t("Game Over!","بازی تموم شد!"))
                        .font(.system(size: 34, weight: .black, design: .rounded)).foregroundStyle(.white)
                    // Show winner only if one team is ahead; otherwise declare a draw
                    let topScore = vm.sortedTeams.first?.totalScore ?? 0
                    let leaders = vm.sortedTeams.filter { $0.totalScore == topScore }
                    if leaders.count == 1, let winner = leaders.first {
                        HStack(spacing: 6) {
                            Text(winner.icon)
                            Text(t("\(winner.name) Wins! 🎉","\(winner.name) برنده شد! 🎉"))
                        }
                        .font(AppFonts.rounded(19, weight: .bold)).foregroundStyle(winner.color)
                    } else {
                        HStack(spacing: 6) {
                            ForEach(leaders) { team in Text(team.icon) }
                            Text(t("It's a Draw! 🤝","مساوی! 🤝"))
                        }
                        .font(AppFonts.rounded(19, weight: .bold)).foregroundStyle(Color.white)
                    }
                }
                .padding(.top, 60).padding(.bottom, 28)

                // Podium
                VStack(spacing: 10) {
                    ForEach(Array(vm.sortedTeams.enumerated()), id: \.element.id) { rank, team in
                        HStack(spacing: 12) {
                            Text(rankEmoji(rank)).font(.system(size: 24)).frame(width: 32)
                            Text(team.icon).font(.system(size: 20))
                            Text(team.name).font(AppFonts.rounded(16, weight: .bold)).foregroundStyle(.white)
                            Spacer()
                            Text("\(team.totalScore)").font(.system(size: 28, weight: .black, design: .rounded)).foregroundStyle(team.color)
                            Text(t("pts","امتیاز")).font(AppFonts.rounded(13, weight: .bold)).foregroundStyle(.white.opacity(0.45))
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(Color.white.opacity(rank == 0 ? 0.12 : 0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .offset(x: appeared ? 0 : 50).opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.5).delay(Double(rank)*0.1+0.35), value: appeared)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                VStack(spacing: 10) {
                    // View full scoresheet
                    Button { showFullSheet = true } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "list.clipboard.fill").font(.system(size: 16, weight: .bold))
                            Text(t("Full Scoresheet","کارنامه کامل")).font(AppFonts.rounded(17, weight: .heavy))
                        }
                        .foregroundStyle(AppColors.text).frame(maxWidth: .infinity).padding(.vertical, 17)
                        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button {
                        appSettings.hapticNotification(.success); vm.startGame()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise").font(.system(size: 15, weight: .bold))
                            Text(t("Play Again","دوباره بازی")).font(AppFonts.rounded(17, weight: .heavy))
                        }
                        .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 17)
                        .background(Color.white.opacity(0.18)).clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button { vm.exitGame() } label: {
                        Text(t("Main Menu","منوی اصلی")).font(AppFonts.rounded(15, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6)).frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 44)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear { withAnimation { appeared = true } }
        .layoutDir(lang)
        .sheet(isPresented: $showFullSheet) {
            ScoresheetView(records: vm.turnRecords, teams: vm.settings.teams, language: lang)
        }
    }

    var starsBackground: some View {
        GeometryReader { geo in
            ForEach(0..<28, id: \.self) { i in
                Circle().fill(Color.white.opacity(Double.random(in: 0.1...0.45))).frame(width: CGFloat.random(in: 2...5))
                    .position(x: CGFloat(i*37 % Int(geo.size.width)), y: CGFloat(i*53 % Int(geo.size.height)))
            }
        }.ignoresSafeArea()
    }

    func rankEmoji(_ rank: Int) -> String {
        let topScore = vm.sortedTeams.first?.totalScore ?? 0
        let sorted = vm.sortedTeams
        let teamScore = rank < sorted.count ? sorted[rank].totalScore : -1
        // If this team is tied at the top, everyone gets gold
        let leadersCount = sorted.filter { $0.totalScore == topScore }.count
        if teamScore == topScore && leadersCount > 1 { return "🥇" }
        switch rank { case 0: return "🥇"; case 1: return "🥈"; case 2: return "🥉"; default: return "\(rank+1)." }
    }
}

// MARK: - Full Scoresheet

struct ScoresheetView: View {
    let records: [TurnRecord]
    let teams: [Team]
    let language: AppLanguage
    @Environment(\.dismiss) var dismiss

    func t(_ en: String, _ fa: String) -> String { language == .persian ? fa : en }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Team totals
                        HStack(spacing: 12) {
                            ForEach(teams.sorted { $0.totalScore > $1.totalScore }) { team in
                                VStack(spacing: 4) {
                                    Text(team.icon).font(.system(size: 28))
                                    Text(team.name).font(AppFonts.rounded(13, weight: .bold)).foregroundStyle(AppColors.text).lineLimit(1)
                                    Text("\(team.totalScore)").font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(team.color)
                                    Text(t("pts","امتیاز")).font(AppFonts.rounded(11)).foregroundStyle(AppColors.textSecondary)
                                }
                                .frame(maxWidth: .infinity).padding(12)
                                .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: team.color.opacity(0.15), radius: 8, y: 4)
                            }
                        }
                        .padding(.horizontal, 20).padding(.top, 8)

                        // Stats summary
                        let totalHints = records.filter { $0.hintUsed }.count
                        let totalFaults = records.map { $0.faultCount }.reduce(0, +)
                        let guessed = records.filter { $0.guessed }.count
                        HStack(spacing: 10) {
                            statBadge(icon: "checkmark.circle.fill", value: "\(guessed)/\(records.count)", label: t("Guessed","حدس زده"), color: AppColors.green)
                            statBadge(icon: "exclamationmark.circle.fill", value: "\(totalFaults)", label: t("Faults","خطاها"), color: AppColors.orange)
                            statBadge(icon: "lightbulb.fill", value: "\(totalHints)", label: t("Hints","راهنماها"), color: AppColors.purple)
                        }
                        .padding(.horizontal, 20)

                        // Per-team turn records
                        ForEach(teams) { team in
                            let teamIdx = teams.firstIndex(where: { $0.id == team.id }) ?? -1
                            let teamRecs = records.filter { $0.teamIndex == teamIdx }
                            if !teamRecs.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 8) {
                                        Text(team.icon).font(.system(size: 18))
                                        Text(team.name).font(AppFonts.rounded(16, weight: .black)).foregroundStyle(AppColors.text)
                                        Spacer()
                                        Text("\(team.totalScore) pts").font(AppFonts.rounded(14, weight: .heavy)).foregroundStyle(team.color)
                                    }
                                    .padding(.horizontal, 20)

                                    ForEach(teamRecs) { rec in
                                        turnRow(rec: rec)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(t("Scoresheet","کارنامه"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(t("Done","تأیید")) { dismiss() }.font(AppFonts.rounded(16, weight: .bold)).foregroundStyle(AppColors.blue)
                }
            }
        }
        .layoutDir(language)
    }

    func turnRow(rec: TurnRecord) -> some View {
        HStack(spacing: 12) {
            // Points badge
            VStack(spacing: 2) {
                Text(rec.guessed ? "+\(rec.finalPoints)" : "0")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(rec.guessed ? AppColors.forPoints(rec.basePoints) : AppColors.textSecondary)
                Text("\(rec.basePoints)★").font(AppFonts.rounded(10)).foregroundStyle(AppColors.textSecondary)
            }
            .frame(width: 44)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(rec.word).font(AppFonts.rounded(15, weight: .bold)).foregroundStyle(AppColors.text)
                    if rec.hintUsed {
                        Image(systemName: "lightbulb.fill").font(.system(size: 10)).foregroundStyle(AppColors.purple)
                    }
                }
                HStack(spacing: 6) {
                    if !rec.isCustom { Text(rec.category.emoji).font(.system(size: 12)) }
                    if let actor = rec.actorName {
                        Text(actor).font(AppFonts.rounded(11)).foregroundStyle(AppColors.textSecondary)
                    }
                    if rec.faultCount > 0 {
                        Text("⚠️ \(rec.faultCount) fault\(rec.faultCount > 1 ? "s" : "")").font(AppFonts.rounded(11)).foregroundStyle(AppColors.orange)
                    }
                }
            }
            Spacer()
            Image(systemName: rec.guessed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(rec.guessed ? AppColors.green : AppColors.textSecondary.opacity(0.5))
                .font(.system(size: 20))
        }
        .padding(.horizontal, 20).padding(.vertical, 10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        .padding(.horizontal, 20)
    }

    func statBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 20, weight: .bold)).foregroundStyle(color)
            Text(value).font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(AppColors.text)
            Text(label).font(AppFonts.rounded(11)).foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: color.opacity(0.12), radius: 8, y: 4)
    }
}
