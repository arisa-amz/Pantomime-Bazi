//
//  TeamReadyView.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//
import SwiftUI

// MARK: - Team Ready (with category + custom word selection)

struct TeamReadyView: View {
    var vm: GameViewModel
    var appSettings: AppSettings

    var team: Team {
        guard vm.currentTeamIndex < vm.settings.teams.count
        else { return vm.settings.teams[0] }
        return vm.settings.teams[vm.currentTeamIndex]
    }

    var lang: AppLanguage { vm.language }
    func t(_ en: String, _ fa: String) -> String { lang == .persian ? fa : en }

    // Local state for category + custom word — applied when user taps "We're Ready"
    @State private var selectedCategories: Set<WordCategory> = Set(WordCategory.allCases)
    @State private var showCategoryPicker = false
    @State private var showCustomWordInput = false
    @State private var customWordEN = ""
    @State private var customWordFA = ""
    @State private var appeared = false

    var body: some View {
        ZStack {
            team.color.ignoresSafeArea()

            // Round number watermark
            Text("\(vm.currentRound)")
                .font(.system(size: 280, weight: .black, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.07))
                .offset(y: -80)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    Spacer().frame(height: 20)

                    // Round badge
                    Text(t("Round \(vm.currentRound) of \(vm.settings.rounds)",
                           "راند \(vm.currentRound) از \(vm.settings.rounds)"))
                        .font(AppFonts.rounded(16, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.8))
                        .padding(.horizontal, 18).padding(.vertical, 7)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())

                    // Team name
                    VStack(spacing: 8) {
                        Text("🎭").font(.system(size: 64))
                        Text(team.name)
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(Color.white).multilineTextAlignment(.center)
                        Text(t("Get Ready!", "آماده باشید!"))
                            .font(AppFonts.rounded(20, weight: .heavy))
                            .foregroundStyle(Color.white.opacity(0.85))
                    }

                    // Player avatars
                    HStack(spacing: 8) {
                        ForEach(0..<min(team.playerCount, 8), id: \.self) { _ in
                            Image(systemName: "person.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.white.opacity(0.9))
                                .frame(width: 34, height: 34)
                                .background(Color.white.opacity(0.18))
                                .clipShape(Circle())
                        }
                    }

                    // ── Word setup panel ──
                    wordSetupPanel

                    // Scores
                    if vm.settings.teams.count > 1 { scoreRow }

                    // Instructions
                    VStack(spacing: 3) {
                        Text(t("The actor sees the word, memorises it,",
                               "بازیکن کلمه را می‌بیند، حفظ می‌کند،"))
                        Text(t("then hides the screen before acting.",
                               "سپس صفحه را پنهان می‌کند و بازی می‌کند."))
                    }
                    .font(AppFonts.rounded(13, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                    // Start button
                    Button {
                        appSettings.hapticNotification(.success)
                        vm.pickWord(categories: selectedCategories)
                        vm.startTurn(appSettings: appSettings)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                            Text(t("WE'RE READY!", "آماده‌ایم!"))
                                .font(.system(size: 19, weight: .black, design: .rounded)).tracking(1)
                        }
                        .foregroundStyle(team.color)
                        .frame(maxWidth: .infinity).padding(.vertical, 20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Color.black.opacity(0.2), radius: 14, y: 7)
                    }
                    .disabled(selectedCategories.isEmpty)
                    .padding(.horizontal, 28).padding(.bottom, 44)
                }
            }
            .scaleEffect(appeared ? 1 : 0.88).opacity(appeared ? 1 : 0)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    appSettings.haptic(.medium)
                    vm.exitGame()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.white.opacity(0.75))
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { appeared = true }
            // Inherit whatever categories were active last turn
            selectedCategories = vm.turnCategories
        }
        .sheet(isPresented: $showCategoryPicker) {
            InlineCategoryPicker(selected: $selectedCategories, language: lang)
        }
        .sheet(isPresented: $showCustomWordInput) {
            CustomWordSheet(
                vm: vm, language: lang,
                englishText: $customWordEN, persianText: $customWordFA
            )
        }
        .layoutDir(lang)
    }

    // MARK: - Word Setup Panel

    var wordSetupPanel: some View {
        VStack(spacing: 10) {
            // Category selector row
            Button { showCategoryPicker = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(team.color)
                    Text(categoryLabel)
                        .font(AppFonts.rounded(14, weight: .bold))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(Color.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            // Custom word row
            Button { showCustomWordInput = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(team.color)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(t("Add a Custom Word", "افزودن کلمه دلخواه"))
                            .font(AppFonts.rounded(14, weight: .bold))
                            .foregroundStyle(Color.white)
                        if !vm.customWords.isEmpty {
                            Text(t("\(vm.customWords.count) custom word(s) added",
                                   "\(vm.customWords.count) کلمه اضافه شده"))
                                .font(AppFonts.rounded(11))
                                .foregroundStyle(Color.white.opacity(0.7))
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(Color.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(.horizontal, 28)
    }

    var categoryLabel: String {
        if selectedCategories.count == WordCategory.allCases.count {
            return t("All Categories", "همه دسته‌بندی‌ها")
        } else if selectedCategories.isEmpty {
            return t("No Categories Selected", "هیچ دسته‌ای انتخاب نشده")
        } else if selectedCategories.count == 1, let cat = selectedCategories.first {
            return "\(cat.emoji) \(lang == .persian ? cat.persianName : cat.rawValue)"
        } else {
            return t("\(selectedCategories.count) Categories", "\(selectedCategories.count) دسته")
        }
    }

    var scoreRow: some View {
        HStack(spacing: 14) {
            ForEach(vm.settings.teams) { t in
                VStack(spacing: 3) {
                    Text("\(t.score)")
                        .font(AppFonts.rounded(20, weight: .black)).foregroundStyle(Color.white)
                    Text(t.name)
                        .font(AppFonts.rounded(11, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.65)).lineLimit(1)
                }
                .frame(minWidth: 52)
            }
        }
        .padding(.horizontal, 22).padding(.vertical, 12)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 28)
    }
}

// MARK: - Inline Category Picker (sheet from TeamReady)

struct InlineCategoryPicker: View {
    @Binding var selected: Set<WordCategory>
    let language: AppLanguage
    @Environment(\.dismiss) var dismiss

    func t(_ en: String, _ fa: String) -> String { language == .persian ? fa : en }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 12) {
                        // All / None quick buttons
                        HStack(spacing: 10) {
                            Button {
                                selected = Set(WordCategory.allCases)
                                Haptics.impact(.light)
                            } label: {
                                Text(t("Select All", "همه")).font(AppFonts.rounded(14, weight: .bold))
                                    .foregroundStyle(AppColors.blue).frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(AppColors.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            Button {
                                if selected.count > 1 { selected = [WordCategory.allCases.first!] }
                                Haptics.impact(.light)
                            } label: {
                                Text(t("Clear All", "حذف همه")).font(AppFonts.rounded(14, weight: .bold))
                                    .foregroundStyle(AppColors.red).frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(AppColors.red.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal, 18).padding(.top, 8)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(WordCategory.allCases) { cat in
                                let isOn = selected.contains(cat)
                                Button {
                                    Haptics.impact(.light)
                                    if isOn { if selected.count > 1 { selected.remove(cat) } }
                                    else { selected.insert(cat) }
                                } label: {
                                    VStack(spacing: 8) {
                                        Text(cat.emoji).font(.system(size: 30))
                                        Text(language == .persian ? cat.persianName : cat.rawValue)
                                            .font(AppFonts.rounded(12, weight: .bold))
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                                    .foregroundStyle(isOn ? Color.white : AppColors.text)
                                    .background {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(isOn ? AppColors.forCategory(cat) : Color.white)
                                            .shadow(color: isOn ? AppColors.forCategory(cat).opacity(0.28) : .black.opacity(0.06),
                                                    radius: 6, y: 3)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 18).padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle(language == .persian ? "دسته‌بندی‌ها" : "Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(language == .persian ? "تأیید" : "Done") { dismiss() }
                        .font(AppFonts.rounded(16, weight: .bold)).foregroundStyle(AppColors.blue)
                }
            }
        }
        .layoutDir(language)
    }
}

// MARK: - Custom Word Sheet

struct CustomWordSheet: View {
    var vm: GameViewModel
    let language: AppLanguage
    @Binding var englishText: String
    @Binding var persianText: String
    @Environment(\.dismiss) var dismiss
    @State private var errorMessage: String? = nil

    func t(_ en: String, _ fa: String) -> String { language == .persian ? fa : en }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Instructions
                            Text(t("Add a word in both languages so it can be used in any language mode.",
                                   "کلمه را هم به انگلیسی هم فارسی وارد کنید تا در هر دو حالت زبان کار کنه."))
                                .font(AppFonts.rounded(13))
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24).padding(.top, 16)

                            // Input fields
                            VStack(spacing: 12) {
                                wordField(
                                    placeholder: t("English word", "کلمه انگلیسی"),
                                    text: $englishText,
                                    flag: "🇺🇸",
                                    isRTL: false
                                )
                                wordField(
                                    placeholder: t("Persian word", "کلمه فارسی"),
                                    text: $persianText,
                                    flag: "🇮🇷",
                                    isRTL: true
                                )
                            }
                            .padding(.horizontal, 20)

                            if let err = errorMessage {
                                Text(err)
                                    .font(AppFonts.rounded(13, weight: .medium))
                                    .foregroundStyle(AppColors.red)
                            }

                            // Existing custom words
                            if !vm.customWords.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(t("Added Words", "کلمات اضافه‌شده"))
                                        .font(AppFonts.rounded(14, weight: .heavy))
                                        .foregroundStyle(AppColors.textSecondary)
                                        .padding(.horizontal, 20)

                                    ForEach(vm.customWords) { word in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(word.english)
                                                    .font(AppFonts.rounded(15, weight: .bold))
                                                    .foregroundStyle(AppColors.text)
                                                Text(word.persian)
                                                    .font(AppFonts.rounded(13))
                                                    .foregroundStyle(AppColors.textSecondary)
                                            }
                                            Spacer()
                                            Button {
                                                vm.customWords.removeAll { $0.id == word.id }
                                                Haptics.impact(.light)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 22))
                                                    .foregroundStyle(AppColors.red.opacity(0.7))
                                            }
                                        }
                                        .padding(.horizontal, 20).padding(.vertical, 10)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 120)
                    }

                    // Add button pinned to bottom
                    VStack(spacing: 0) {
                        Divider()
                        Button {
                            addWord()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill").font(.system(size: 18, weight: .bold))
                                Text(t("Add Word", "افزودن کلمه"))
                                    .font(AppFonts.rounded(17, weight: .heavy))
                            }
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(AppColors.green)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(16)
                        .background(Color.white)
                    }
                }
            }
            .navigationTitle(t("Custom Words", "کلمات دلخواه"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(t("Done", "تأیید")) { dismiss() }
                        .font(AppFonts.rounded(16, weight: .bold)).foregroundStyle(AppColors.blue)
                }
            }
        }
        .layoutDir(language)
    }

    func wordField(placeholder: String, text: Binding<String>, flag: String, isRTL: Bool) -> some View {
        HStack(spacing: 10) {
            Text(flag).font(.system(size: 22))
            TextField(placeholder, text: text)
                .font(AppFonts.rounded(16, weight: .medium))
                .foregroundStyle(AppColors.text)
                .multilineTextAlignment(isRTL ? .trailing : .leading)
                .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
    }

    func addWord() {
        let en = englishText.trimmingCharacters(in: .whitespacesAndNewlines)
        let fa = persianText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !en.isEmpty else { errorMessage = t("Please enter an English word.", "لطفاً کلمه انگلیسی را وارد کنید."); return }
        guard !fa.isEmpty else { errorMessage = t("Please enter a Persian word.", "لطفاً کلمه فارسی را وارد کنید."); return }
        errorMessage = nil
        vm.customWords.append(WordEntry(english: en, persian: fa, category: .everyday))
        englishText = ""
        persianText = ""
        Haptics.notification(.success)
    }
}

// MARK: - Playing View

struct PlayingView: View {
    var vm: GameViewModel
    var appSettings: AppSettings

    @State private var showExitConfirm = false

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
                timerRing.padding(.vertical, 20)
                wordSection
                Spacer()
                bottomButtons
            }
        }
        .navigationBarBackButtonHidden()
        .layoutDir(lang)
        .confirmationDialog(
            t("Exit game?", "خروج از بازی؟"),
            isPresented: $showExitConfirm,
            titleVisibility: .visible
        ) {
            Button(t("Exit to Main Menu", "خروج به منوی اصلی"), role: .destructive) {
                appSettings.stopPartyMusic()
                vm.exitGame()
            }
            Button(t("Cancel", "انصراف"), role: .cancel) {}
        } message: {
            Text(t("Your current game progress will be lost.", "پیشرفت بازی فعلی از دست می‌رود."))
        }
    }

    var topBar: some View {
        HStack {
            Button {
                showExitConfirm = true; appSettings.haptic(.light)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.55))
            }
            Spacer()
            HStack(spacing: 7) {
                Circle().fill(vm.currentTeam.color).frame(width: 9, height: 9)
                Text(vm.currentTeam.name)
                    .font(AppFonts.rounded(15, weight: .bold)).foregroundStyle(AppColors.text)
                Text("·").foregroundStyle(AppColors.textSecondary)
                Text("\(vm.currentTeam.score) pts")
                    .font(AppFonts.rounded(15, weight: .heavy)).foregroundStyle(vm.currentTeam.color)
            }
            Spacer()
            Button {
                vm.isPaused.toggle()
                if vm.isPaused { appSettings.stopPartyMusic() }
                else { appSettings.startPartyMusic() }
                appSettings.haptic(.light)
            } label: {
                Image(systemName: vm.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 15, weight: .bold)).foregroundStyle(AppColors.text)
                    .frame(width: 34, height: 34).background(Color.white).clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            }
        }
        .padding(.horizontal, 20).padding(.top, 8)
    }

    var timerRing: some View {
        ZStack {
            Circle().stroke(timerColor.opacity(0.14), lineWidth: 10).frame(width: 110)
            Circle()
                .trim(from: 0, to: timerProgress)
                .stroke(timerColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 110).rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timerProgress)
            VStack(spacing: 0) {
                Text("\(vm.timeRemaining)")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(timerColor)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.default, value: vm.timeRemaining)
                Text(t("sec", "ثانیه"))
                    .font(AppFonts.rounded(11, weight: .bold)).foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    var wordSection: some View {
        VStack(spacing: 14) {
            Group {
                if vm.isPaused         { pausedCard }
                else if vm.wordRevealed { revealedWordCard }
                else                   { hiddenWordCard }
            }
            .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 220)
            .padding(.horizontal, 20)

            if vm.wordRevealed && !vm.isPaused, let word = vm.currentWord {
                HStack(spacing: 5) {
                    Text(word.category.emoji)
                    Text(lang == .persian ? word.category.persianName : word.category.rawValue)
                        .font(AppFonts.rounded(13, weight: .bold))
                }
                .padding(.horizontal, 13).padding(.vertical, 6)
                .foregroundStyle(AppColors.forCategory(word.category))
                .background(AppColors.forCategory(word.category).opacity(0.1))
                .clipShape(Capsule())
            }
        }
    }

    var hiddenWordCard: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { vm.toggleReveal() }
            appSettings.haptic(.medium); appSettings.playTap()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(vm.currentTeam.color)
                    .shadow(color: vm.currentTeam.color.opacity(0.4), radius: 20, y: 10)
                VStack(spacing: 12) {
                    Image(systemName: "eye.slash.fill").font(.system(size: 44))
                        .foregroundStyle(Color.white.opacity(0.9))
                    Text(t("TAP TO SEE WORD", "برای دیدن کلمه بزن"))
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white).tracking(0.5)
                    Text(t("Memorise, then hide before acting", "حفظ کن، بعد پنهان کن"))
                        .font(AppFonts.rounded(13, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 28)
            }
        }
        .buttonStyle(.plain)
    }

    var revealedWordCard: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { vm.toggleReveal() }
            appSettings.haptic(.light)
        } label: {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: AppColors.blue.opacity(0.14), radius: 20, y: 10)
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(vm.currentTeam.color)
                        .frame(width: 6).padding(.vertical, 24)
                    Spacer()
                }
                .padding(.leading, 20)

                // "tap again to hide" — text only, top right
                Text(t("tap again to hide", "برای پنهان کردن بزن"))
                    .font(AppFonts.rounded(12, weight: .bold))
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.top, 16).padding(.trailing, 18)

                VStack(spacing: 8) {
                    if let word = vm.currentWord {
                        let display = lang == .persian ? word.persian : word.english
                        Text(display)
                            .font(.system(size: display.count > 14 ? 30 : 42,
                                          weight: .black, design: .rounded))
                            .foregroundStyle(AppColors.text)
                            .multilineTextAlignment(.center).padding(.horizontal, 32)
                        if appSettings.showWordTranslation {
                            Text(lang == .persian ? word.english : word.persian)
                                .font(AppFonts.rounded(16, weight: .medium))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .buttonStyle(.plain)
    }

    var pausedCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppColors.text).shadow(color: .black.opacity(0.18), radius: 20, y: 10)
            VStack(spacing: 10) {
                Image(systemName: "pause.circle.fill").font(.system(size: 52))
                    .foregroundStyle(Color.white.opacity(0.8))
                Text(t("Paused", "مکث"))
                    .font(AppFonts.rounded(28, weight: .black)).foregroundStyle(Color.white)
                Text(t("Tap ▶ to continue", "برای ادامه ▶ را بزنید"))
                    .font(AppFonts.rounded(14, weight: .medium)).foregroundStyle(Color.white.opacity(0.55))
            }
        }
    }

    var bottomButtons: some View {
        VStack(spacing: 12) {
            Button {
                vm.teamGuessedCorrectly(appSettings: appSettings)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 22, weight: .bold))
                    Text(t("We Got It! ✓", "حدس زدیم! ✓"))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                }
                .foregroundStyle(Color.white).frame(maxWidth: .infinity).padding(.vertical, 20)
                .background(AppColors.green)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: AppColors.green.opacity(0.4), radius: 12, y: 6)
            }
            .disabled(vm.isPaused).opacity(vm.isPaused ? 0.4 : 1)

            Button {
                appSettings.haptic(.medium)
                appSettings.stopPartyMusic()
                vm.endTurn()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "forward.end.fill").font(.system(size: 15, weight: .bold))
                    Text(t("End Turn", "پایان نوبت")).font(AppFonts.rounded(16, weight: .bold))
                }
                .foregroundStyle(AppColors.textSecondary).frame(maxWidth: .infinity).padding(.vertical, 15)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
            }
            .disabled(vm.isPaused).opacity(vm.isPaused ? 0.4 : 1)
        }
        .padding(.horizontal, 20).padding(.bottom, 36)
    }
}

// MARK: - Game Over

struct GameOverView: View {
    var vm: GameViewModel
    var appSettings: AppSettings

    var lang: AppLanguage { vm.language }
    func t(_ en: String, _ fa: String) -> String { lang == .persian ? fa : en }

    @State private var appeared = false

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
                    Text(t("Game Over!", "بازی تموم شد!"))
                        .font(.system(size: 34, weight: .black, design: .rounded)).foregroundStyle(Color.white)
                    if let winner = vm.sortedTeams.first {
                        Text(t("\(winner.name) Wins! 🎉", "\(winner.name) برنده شد! 🎉"))
                            .font(AppFonts.rounded(19, weight: .bold)).foregroundStyle(winner.color)
                    }
                }
                .padding(.top, 60).padding(.bottom, 32)

                VStack(spacing: 10) {
                    ForEach(Array(vm.sortedTeams.enumerated()), id: \.element.id) { rank, team in
                        HStack(spacing: 12) {
                            Text(rankEmoji(rank)).font(.system(size: 26)).frame(width: 34)
                            Circle().fill(team.color).frame(width: 10, height: 10)
                            Text(team.name).font(AppFonts.rounded(17, weight: .bold)).foregroundStyle(Color.white)
                            Spacer()
                            Text("\(team.score)").font(.system(size: 30, weight: .black, design: .rounded)).foregroundStyle(team.color)
                            Text(t("pts", "امتیاز")).font(AppFonts.rounded(13, weight: .bold)).foregroundStyle(Color.white.opacity(0.45))
                        }
                        .padding(.horizontal, 18).padding(.vertical, 13)
                        .background(Color.white.opacity(rank == 0 ? 0.12 : 0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .offset(x: appeared ? 0 : 50).opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.5).delay(Double(rank) * 0.1 + 0.35), value: appeared)
                    }
                }
                .padding(.horizontal, 20)
                Spacer()
                VStack(spacing: 10) {
                    Button {
                        appSettings.hapticNotification(.success)
                        vm.startGame()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise").font(.system(size: 15, weight: .bold))
                            Text(t("Play Again", "دوباره بازی")).font(AppFonts.rounded(17, weight: .heavy))
                        }
                        .foregroundStyle(AppColors.text).frame(maxWidth: .infinity).padding(.vertical, 17)
                        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    Button { vm.exitGame() } label: {
                        Text(t("Main Menu", "منوی اصلی"))
                            .font(AppFonts.rounded(15, weight: .bold)).foregroundStyle(Color.white.opacity(0.65))
                            .frame(maxWidth: .infinity).padding(.vertical, 15)
                            .background(Color.white.opacity(0.09))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 44)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear { withAnimation { appeared = true } }
        .layoutDir(lang)
    }

    var starsBackground: some View {
        GeometryReader { geo in
            ForEach(0..<28, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.45)))
                    .frame(width: CGFloat.random(in: 2...5))
                    .position(x: CGFloat(i * 37 % Int(geo.size.width)),
                              y: CGFloat(i * 53 % Int(geo.size.height)))
            }
        }
        .ignoresSafeArea()
    }

    func rankEmoji(_ rank: Int) -> String {
        switch rank { case 0: "🥇"; case 1: "🥈"; case 2: "🥉"; default: "\(rank+1)." }
    }
}
