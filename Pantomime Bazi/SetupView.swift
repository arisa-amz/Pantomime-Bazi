//
//  SetupView.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//
//


import SwiftUI

// MARK: - Setup View

struct SetupView: View {
    @Bindable var vm: GameViewModel
    @Bindable var appSettings: AppSettings
    @State private var showSettings = false
    @State private var showGuide = false

    var lang: AppLanguage { vm.settings.language }
    func t(_ en: String, _ fa: String) -> String { lang == .persian ? fa : en }

    var body: some View {
        NavigationStack(path: $vm.navPath) {
            ZStack {
                AppColors.background.ignoresSafeArea()
                blobs

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        teamsSection
                        gameSettingsSection
                        startButton.padding(.bottom, 52)
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .teamReady:  TeamReadyView(vm: vm, appSettings: appSettings)
                case .wordPick:   WordPickView(vm: vm, appSettings: appSettings)
                case .playing:    PlayingView(vm: vm, appSettings: appSettings)
                case .turnResult: TurnResultView(vm: vm, appSettings: appSettings)
                case .gameOver:   GameOverView(vm: vm, appSettings: appSettings)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet(
                    appSettings: appSettings,
                    language: lang,
                    showGuide: $showGuide
                )
            }
            .sheet(isPresented: $showGuide) {
                OnboardingView(onDone: { showGuide = false })
            }
        }
        .layoutDir(lang)
    }

    // MARK: Header

    var headerSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                AppColors.red.frame(height: 5)
                AppColors.blue.frame(height: 5)
                AppColors.green.frame(height: 5)
                AppColors.yellow.frame(height: 5)
            }
            VStack(spacing: 0) {
                HStack {
                    LanguageToggle(
                        language: Binding(
                            get: { vm.settings.language },
                            set: { vm.updateLanguage($0) }
                        )
                    )
                    Spacer()
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill").font(
                            .system(size: 20)
                        )
                        .foregroundStyle(AppColors.purple).padding(10)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.07), radius: 6, y: 3)
                    }
                }
                .padding(.horizontal, 20).padding(.top, 14)

                VStack(spacing: 4) {
                    Text(t("PANTOMIME", "پانتومیم"))
                        .font(
                            .system(size: 44, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(AppColors.text).tracking(-1)
                    HStack(spacing: 0) {
                        Capsule().fill(AppColors.red).frame(height: 5)
                        Capsule().fill(AppColors.blue).frame(height: 5)
                    }.frame(width: 160)
                    Text(t("the CHALLENGE", "چالش بزرگ"))
                        .font(AppFonts.rounded(15, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16).padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10).fill(
                                AppColors.text
                            ).rotationEffect(.degrees(-2))
                        )
                        .offset(x: 18, y: -2)
                }
                .padding(.top, 10).padding(.bottom, 24)
            }
        }
    }

    // MARK: Teams

    var teamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.3.fill").font(
                    .system(size: 15, weight: .bold)
                ).foregroundStyle(AppColors.blue)
                Text(t("Teams", "تیم‌ها")).font(
                    AppFonts.rounded(19, weight: .black)
                ).foregroundStyle(AppColors.text)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 10) {
                let canDelete = vm.settings.teams.count > 2
                ForEach(Array(vm.settings.teams.enumerated()), id: \.element.id)
                { i, _ in
                    TeamCard(
                        team: Binding(
                            get: {
                                i < vm.settings.teams.count
                                    ? vm.settings.teams[i]
                                    : vm.settings.teams[0]
                            },
                            set: {
                                if i < vm.settings.teams.count {
                                    vm.settings.teams[i] = $0
                                }
                            }
                        ),
                        index: i,
                        language: lang,
                        canDelete: canDelete,
                        onDelete: {
                            if i < vm.settings.teams.count {
                                vm.settings.teams.remove(at: i)
                            }
                        }
                    )
                }
                if vm.settings.teams.count < 6 {
                    Button {
                        let i = vm.settings.teams.count
                        vm.settings.teams.append(
                            Team(
                                name: Team.defaultName(
                                    index: i,
                                    language: lang
                                ),
                                color: Team.defaultColors[
                                    i % Team.defaultColors.count
                                ]
                            )
                        )
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill").font(
                                .system(size: 20)
                            )
                            Text(t("Add Team", "افزودن تیم")).font(
                                AppFonts.rounded(16, weight: .bold)
                            )
                        }
                        .foregroundStyle(AppColors.blue).frame(
                            maxWidth: .infinity
                        ).padding(.vertical, 15)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    AppColors.blue.opacity(0.4),
                                    style: StrokeStyle(lineWidth: 2, dash: [8])
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 6)
    }

    // MARK: Game Settings

    var gameSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "gearshape.fill").font(
                    .system(size: 15, weight: .bold)
                ).foregroundStyle(AppColors.purple)
                Text(t("Game Settings", "تنظیمات بازی")).font(
                    AppFonts.rounded(19, weight: .black)
                ).foregroundStyle(AppColors.text)
            }
            .padding(.horizontal, 20)

            FatCard(color: AppColors.purple) {
                VStack(spacing: 18) {
                    StepperRow(
                        label: t("Rounds", "تعداد راند"),
                        value: Binding(
                            get: { vm.settings.rounds },
                            set: { vm.settings.rounds = $0 }
                        ),
                        range: 1...10,
                        color: AppColors.purple
                    )
                    Divider()
                    // Time stepper
                    let times = [30, 45, 60, 90, 120]
                    let idx = times.firstIndex(of: vm.settings.timePerTurn) ?? 2
                    HStack {
                        Text(t("Time per turn", "زمان هر نوبت"))
                            .font(AppFonts.rounded(15, weight: .medium))
                            .foregroundStyle(AppColors.text)
                        Spacer()
                        HStack(spacing: 12) {
                            Button {
                                if idx > 0 {
                                    vm.settings.timePerTurn = times[idx - 1]
                                    Haptics.impact(.light)
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill").font(
                                    .system(size: 26)
                                )
                                .foregroundStyle(
                                    idx > 0
                                        ? AppColors.purple
                                        : AppColors.textSecondary.opacity(0.3)
                                )
                            }
                            Text("\(vm.settings.timePerTurn)s")
                                .font(AppFonts.rounded(18, weight: .bold))
                                .foregroundStyle(AppColors.text)
                                .frame(minWidth: 44, alignment: .center)
                            Button {
                                if idx < times.count - 1 {
                                    vm.settings.timePerTurn = times[idx + 1]
                                    Haptics.impact(.light)
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill").font(
                                    .system(size: 26)
                                )
                                .foregroundStyle(
                                    idx < times.count - 1
                                        ? AppColors.purple
                                        : AppColors.textSecondary.opacity(0.3)
                                )
                            }
                        }
                    }
                }
                .padding(18)
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 18)
    }

    var startButton: some View {
        Button {
            appSettings.hapticNotification(.success)
            vm.startGame()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.fill").font(
                    .system(size: 17, weight: .black)
                )
                Text(t("START GAME", "شروع بازی")).font(
                    .system(size: 19, weight: .black, design: .rounded)
                ).tracking(1)
            }
            .foregroundStyle(.white).frame(maxWidth: .infinity).padding(
                .vertical,
                20
            )
            .background(
                LinearGradient(
                    colors: [AppColors.red, AppColors.blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20)).shadow(
                color: AppColors.red.opacity(0.35),
                radius: 16,
                y: 8
            )
        }
        .padding(.horizontal, 20).padding(.top, 28)
    }

    var blobs: some View {
        ZStack {
            Circle().fill(AppColors.blue.opacity(0.07)).frame(width: 300)
                .offset(x: -120, y: -200)
            Circle().fill(AppColors.red.opacity(0.07)).frame(width: 250).offset(
                x: 160,
                y: 100
            )
        }.ignoresSafeArea()
    }
}

// MARK: - Team Card

struct TeamCard: View {
    @Binding var team: Team
    let index: Int
    let language: AppLanguage
    let canDelete: Bool
    let onDelete: () -> Void
    @State private var showIconPicker = false
    @State private var showMembersEditor = false

    var body: some View {
        FatCard(color: team.color) {
            VStack(spacing: 12) {
                // Top row: tappable icon | always-editable name TextField | delete
                HStack(spacing: 10) {
                    // Icon — tap to pick a different one
                    Button { showIconPicker = true } label: {
                        // ZStack with default (centre) alignment so emoji fills the circle
                        ZStack {
                            Circle().fill(team.color).frame(width: 46, height: 46)
                            Text(team.icon)
                                .font(.system(size: 26))
                                .frame(width: 46, height: 46)  // constrain to circle size → centres it
                            // Small badge bottom-right to signal tappable
                            Circle().fill(Color.white).frame(width: 16, height: 16)
                                .overlay(
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 7, weight: .heavy))
                                        .foregroundStyle(team.color)
                                )
                                .frame(width: 46, height: 46, alignment: .bottomTrailing)
                                .offset(x: 2, y: 2)
                        }
                    }

                    // Name — TextField with subtle background to signal editability
                    TextField(
                        language == .persian ? "نام تیم" : "Team name",
                        text: $team.name
                    )
                    .font(AppFonts.rounded(17, weight: .bold))
                    .foregroundStyle(AppColors.text)
                    .submitLabel(.done)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(team.color.opacity(0.08))
                    )

                    // Delete — only rendered when allowed
                    if canDelete {
                        Button(action: onDelete) {
                            ZStack {
                                Circle().fill(AppColors.red).frame(width: 34, height: 34)
                                Image(systemName: "xmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.white)
                            }
                        }
                    }
                }

                Divider()

                // Players stepper — hidden when named members are defined
                if team.useNamedMembers && !team.members.isEmpty {
                    HStack {
                        Text(
                            language == .persian ? "تعداد بازیکنان" : "Players"
                        )
                        .font(AppFonts.rounded(15, weight: .medium))
                        .foregroundStyle(AppColors.text)
                        Spacer()
                        Text("\(team.members.count)")
                            .font(AppFonts.rounded(18, weight: .bold))
                            .foregroundStyle(team.color)
                    }
                } else {
                    StepperRow(
                        label: language == .persian
                            ? "تعداد بازیکنان" : "Players",
                        value: $team.playerCount_stub,
                        range: 1...10,
                        color: team.color
                    )
                }

                Divider()

                // Named members toggle
                HStack {
                    Image(systemName: "person.text.rectangle").font(
                        .system(size: 14)
                    ).foregroundStyle(AppColors.textSecondary)
                    Text(
                        language == .persian ? "نام بازیکنان" : "Named Members"
                    )
                    .font(AppFonts.rounded(14, weight: .medium))
                    .foregroundStyle(AppColors.text)
                    Spacer()
                    Toggle("", isOn: $team.useNamedMembers).labelsHidden().tint(
                        team.color
                    )
                }

                if team.useNamedMembers {
                    Button {
                        showMembersEditor = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "person.badge.plus").font(
                                .system(size: 13, weight: .bold)
                            )
                            Text(membersLabel).font(
                                AppFonts.rounded(13, weight: .bold)
                            )
                            Spacer()
                            Image(systemName: "chevron.right").font(
                                .system(size: 12)
                            )
                        }
                        .foregroundStyle(team.color).padding(10)
                        .background(team.color.opacity(0.1)).clipShape(
                            RoundedRectangle(cornerRadius: 10)
                        )
                    }
                }
            }
            .padding(15)
        }
        .sheet(isPresented: $showIconPicker) { IconPickerSheet(team: $team) }
        .sheet(isPresented: $showMembersEditor) {
            MembersEditorSheet(team: $team, language: language)
        }
    }

    var membersLabel: String {
        if team.members.isEmpty {
            return language == .persian
                ? "افزودن اسامی بازیکنان" : "Add player names"
        }
        return team.members.map { $0.name }.joined(separator: ", ")
    }
}

// Convenience: player count for display — delegates to real stored property
extension Team {
    var playerCount_stub: Int {
        get { playerCount }
        set { playerCount = newValue }
    }
}

// MARK: - Icon Picker Sheet

struct IconPickerSheet: View {
    @Binding var team: Team
    @Environment(\.dismiss) var dismiss

    let icons =
        Team.defaultIcons + [
            "😀", "😎", "🤩", "🥳", "🤖", "👻", "🐲", "🦅", "🌈", "💥",
            "🎵", "🎮", "⚽", "🏀", "🎯", "🚗", "✈️", "🏖", "🌙", "❤️",
        ]
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 6),
                    spacing: 14
                ) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            team.icon = icon
                            Haptics.impact(.light)
                            dismiss()
                        } label: {
                            Text(icon).font(.system(size: 34))
                                .frame(width: 54, height: 54)
                                .background(
                                    team.icon == icon
                                        ? team.color.opacity(0.2) : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Team Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.font(
                        AppFonts.rounded(16, weight: .bold)
                    ).foregroundStyle(AppColors.blue)
                }
            }
        }
    }
}

// MARK: - Members Editor Sheet

struct MembersEditorSheet: View {
    @Binding var team: Team
    let language: AppLanguage
    @Environment(\.dismiss) var dismiss
    @State private var newName = ""

    func t(_ en: String, _ fa: String) -> String {
        language == .persian ? fa : en
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Member cards
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            if team.members.isEmpty {
                                // Empty state
                                VStack(spacing: 12) {
                                    Text("👥").font(.system(size: 48))
                                    Text(t("No members yet", "هنوز عضوی نیست"))
                                        .font(AppFonts.rounded(16, weight: .bold))
                                        .foregroundStyle(AppColors.text)
                                    Text(t("Add player names below so the game knows who's turn it is to act.",
                                           "اسامی بازیکنان رو اضافه کن تا بازی بدونه نوبت کیه."))
                                        .font(AppFonts.rounded(13))
                                        .foregroundStyle(AppColors.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                }
                                .padding(.top, 48)
                            } else {
                                ForEach(Array(team.members.enumerated()), id: \.element.id) { i, member in
                                    // Member card
                                    HStack(spacing: 14) {
                                        // Number circle
                                        ZStack {
                                            Circle().fill(team.color).frame(width: 38, height: 38)
                                            Text("\(i + 1)")
                                                .font(.system(size: 16, weight: .black, design: .rounded))
                                                .foregroundStyle(.white)
                                        }
                                        Text(member.name)
                                            .font(AppFonts.rounded(16, weight: .bold))
                                            .foregroundStyle(AppColors.text)
                                        Spacer()
                                        // Delete button
                                        Button {
                                            _ = withAnimation(.spring(response: 0.3)) {
                                                team.members.remove(at: i)
                                            }
                                            Haptics.impact(.light)
                                        } label: {
                                            ZStack {
                                                Circle().fill(AppColors.red.opacity(0.1)).frame(width: 30, height: 30)
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundStyle(AppColors.red)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16).padding(.vertical, 12)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: team.color.opacity(0.08), radius: 6, y: 3)
                                }
                            }
                        }
                        .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 120)
                    }

                    // Add member input — pinned at bottom
                    VStack(spacing: 0) {
                        Divider()
                        HStack(spacing: 12) {
                            // Avatar placeholder
                            ZStack {
                                Circle().fill(team.color.opacity(0.15)).frame(width: 42, height: 42)
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(team.color)
                            }
                            TextField(t("Player name…", "نام بازیکن…"), text: $newName)
                                .font(AppFonts.rounded(16, weight: .medium))
                                .foregroundStyle(AppColors.text)
                                .submitLabel(.done)
                                .onSubmit { addMember() }
                                .padding(.horizontal, 14).padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(team.color.opacity(0.06))
                                )
                            // Add button — active only when text filled
                            Button { addMember() } label: {
                                ZStack {
                                    Circle()
                                        .fill(newName.trimmingCharacters(in: .whitespaces).isEmpty
                                              ? AppColors.textSecondary.opacity(0.2) : team.color)
                                        .frame(width: 42, height: 42)
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .black))
                                        .foregroundStyle(.white)
                                }
                            }
                            .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .padding(.horizontal, 20).padding(.vertical, 14)
                        .background(Color.white.shadow(color: .black.opacity(0.06), radius: 8, y: -4))
                    }
                }
            }
            .navigationTitle(t("Team Members", "اعضای تیم"))
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

    func addMember() {
        let n = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty else { return }
        withAnimation(.spring(response: 0.35)) {
            team.members.append(TeamMember(name: n))
        }
        newName = ""
        Haptics.notification(.success)
    }
}

// MARK: - Settings Sheet

struct SettingsSheet: View {
    var appSettings: AppSettings
    let language: AppLanguage
    @Binding var showGuide: Bool
    @Environment(\.dismiss) var dismiss
    @State private var showAbout = false

    func t(_ en: String, _ fa: String) -> String {
        language == .persian ? fa : en
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // How to play button
                        Button {
                            dismiss()
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 0.35
                            ) { showGuide = true }
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10).fill(
                                        AppColors.blue
                                    ).frame(width: 40, height: 40)
                                    Image(systemName: "book.fill").font(
                                        .system(size: 18, weight: .bold)
                                    ).foregroundStyle(.white)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(t("How to Play", "آموزش بازی")).font(
                                        AppFonts.rounded(15, weight: .bold)
                                    ).foregroundStyle(AppColors.text)
                                    Text(
                                        t(
                                            "Rules, scoring and tips",
                                            "قوانین، امتیازدهی و راهنما"
                                        )
                                    ).font(AppFonts.rounded(12))
                                        .foregroundStyle(
                                            AppColors.textSecondary
                                        )
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            .padding(16).background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(
                                color: .black.opacity(0.06),
                                radius: 8,
                                y: 4
                            )
                        }
                        .padding(.horizontal, 20).padding(.top, 8)

                        settingsCard(
                            title: t("Sound & Music", "صدا و موسیقی"),
                            icon: "speaker.wave.2.fill",
                            color: AppColors.purple
                        ) {
                            SettingsToggleRow(
                                icon: "speaker.wave.2.fill",
                                iconColor: AppColors.purple,
                                title: t("Sound Effects", "افکت‌های صوتی"),
                                subtitle: t(
                                    "Tap, correct and fault sounds",
                                    "صداهای لمس، صحیح و خطا"
                                ),
                                isOn: Binding(
                                    get: { appSettings.soundEnabled },
                                    set: { appSettings.soundEnabled = $0 }
                                )
                            )
                            Divider()
                            SettingsToggleRow(
                                icon: "music.note",
                                iconColor: AppColors.pink,
                                title: t("Party Music", "موسیقی پارتی"),
                                subtitle: t(
                                    "Enjoy the music, but be careful!",
                                    "از موزیک لذت ببرید ولی مراقب باشید!"
                                ),
                                isOn: Binding(
                                    get: { appSettings.partyMusicEnabled },
                                    set: { appSettings.partyMusicEnabled = $0 }
                                )
                            )
                            Divider()
                            SettingsToggleRow(
                                icon: "timer",
                                iconColor: AppColors.red,
                                title: t("Countdown Beep", "صدای شمارش معکوس"),
                                subtitle: t(
                                    "Beep at 10 seconds remaining",
                                    "صدا در ۱۰ ثانیه پایانی"
                                ),
                                isOn: Binding(
                                    get: { appSettings.countdownBeepEnabled },
                                    set: {
                                        appSettings.countdownBeepEnabled = $0
                                    }
                                )
                            )
                        }

                        settingsCard(
                            title: t("Feel", "لرزش"),
                            icon: "iphone.radiowaves.left.and.right",
                            color: AppColors.orange
                        ) {
                            SettingsToggleRow(
                                icon: "iphone.radiowaves.left.and.right",
                                iconColor: AppColors.orange,
                                title: t("Vibration", "لرزش"),
                                subtitle: t(
                                    "Haptic feedback on taps and events",
                                    "لرزش هنگام لمس و رویدادها"
                                ),
                                isOn: Binding(
                                    get: { appSettings.hapticsEnabled },
                                    set: { appSettings.hapticsEnabled = $0 }
                                )
                            )
                        }

                        settingsCard(
                            title: t("Gameplay", "بازی"),
                            icon: "gamecontroller.fill",
                            color: AppColors.blue
                        ) {
                            SettingsToggleRow(
                                icon: "globe",
                                iconColor: AppColors.blue,
                                title: t("Show Translation", "نمایش ترجمه"),
                                subtitle: t(
                                    "Show word in other language as hint",
                                    "نمایش ترجمه کلمه به عنوان راهنما"
                                ),
                                isOn: Binding(
                                    get: { appSettings.showWordTranslation },
                                    set: {
                                        appSettings.showWordTranslation = $0
                                    }
                                )
                            )
                        }

                        // About Us card
                        Button { showAbout = true } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10).fill(AppColors.purple)
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "theatermasks.fill")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(t("About Us", "درباره ما"))
                                        .font(AppFonts.rounded(15, weight: .bold))
                                        .foregroundStyle(AppColors.text)
                                    Text(t("Team, story and credits", "تیم، داستان و سازندگان"))
                                        .font(AppFonts.rounded(12))
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            .padding(16).background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                        }
                        .padding(.horizontal, 20).padding(.top, 4)
                    }
                    .padding(.top, 8).padding(.bottom, 40)
                }
            }
            .navigationTitle(t("Settings", "تنظیمات"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(t("Done", "تأیید")) { dismiss() }.font(
                        AppFonts.rounded(16, weight: .bold)
                    ).foregroundStyle(AppColors.blue)
                }
            }
        }
        .sheet(isPresented: $showAbout) {
            AboutView(language: language)
        }
        .layoutDir(language)
    }

    func settingsCard(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 7) {
                Image(systemName: icon).font(.system(size: 13, weight: .bold))
                    .foregroundStyle(color)
                Text(title).font(AppFonts.rounded(13, weight: .heavy))
                    .foregroundStyle(AppColors.textSecondary)
            }.padding(.horizontal, 20)
            VStack(spacing: 12) { content() }.padding(16).background(
                Color.white
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: color.opacity(0.1), radius: 10, y: 4).padding(
                .horizontal,
                20
            )
        }
    }
}

// MARK: - Onboarding View

struct OnboardingView: View {
    let onDone: () -> Void
    @State private var page = 0

    let pages:
        [(
            emoji: String, title: String, titleFA: String, body: String,
            bodyFA: String, color: Color
        )] = [
            (
                "🎭", "Welcome to Pantomime!", "به پانتومیم خوش آمدید!",
                "A party game where you act out words — no talking, only moving!",
                "یه بازی پارتی که باید کلمات رو با حرکت بدن نشون بدی — بدون حرف زدن!",
                AppColors.blue
            ),
            (
                "⚔️", "How it works", "چطور بازی می‌کنی",
                "Two or more teams take turns. The OPPONENT team picks a word for your team's actor. The actor must make their team guess it without speaking.",
                "دو تیم یا بیشتر به نوبت بازی می‌کنن. تیم حریف یه کلمه برای تیم شما انتخاب می‌کنه. بازیکن باید بدون حرف زدن کلمه رو نشون بده.",
                AppColors.purple
            ),
            (
                "⭐", "Scoring", "امتیازدهی",
                "Words have 3, 5 or 7 points based on difficulty. Each fault by the actor costs 1 point. Custom words written by the opponent are always 9 points.",
                "کلمات ۳، ۵ یا ۷ امتیاز دارن. هر خطای بازیکن ۱ امتیاز کم می‌کنه. کلمات سفارشی که تیم حریف می‌نویسه همیشه ۹ امتیازن.",
                AppColors.yellow
            ),
            (
                "🏆", "Winning", "برنده شدن",
                "At the end of all rounds, the team with the most points wins. Check the full scoresheet to see every word played and all the results!",
                "در پایان همه راندها، تیمی که بیشترین امتیاز رو داره برنده میشه. کارنامه کامل بازی رو ببین!",
                AppColors.green
            ),
            (
                "🚀", "Ready to play?", "آماده‌ای؟",
                "Set up your teams, pick rounds and time, then let the opponent team choose the first word. Have fun!",
                "تیم‌هات رو بساز، راندها و زمان رو انتخاب کن، بعد بذار تیم حریف کلمه اول رو انتخاب کنه. خوش بگذره!",
                AppColors.red
            ),
        ]

    var body: some View {
        ZStack {
            pages[page].color.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 24) {
                    Text(pages[page].emoji).font(.system(size: 80))
                    Text(pages[page].title)
                        .font(
                            .system(size: 30, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                    Text(pages[page].body)
                        .font(AppFonts.rounded(17, weight: .medium))
                        .foregroundStyle(.white.opacity(0.88))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Text(pages[page].bodyFA)
                        .font(AppFonts.rounded(15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .environment(\.layoutDirection, .rightToLeft)
                }
                Spacer()
                // Dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule().fill(
                            i == page ? Color.white : Color.white.opacity(0.35)
                        )
                        .frame(width: i == page ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.35), value: page)
                    }
                }
                .padding(.bottom, 32)
                // Button
                Button {
                    Haptics.impact(.medium)
                    if page < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) { page += 1 }
                    } else {
                        onDone()
                    }
                } label: {
                    Text(page < pages.count - 1 ? "Next →" : "Let's Play! 🎭")
                        .font(
                            .system(size: 19, weight: .black, design: .rounded)
                        ).tracking(0.5)
                        .foregroundStyle(pages[page].color)
                        .frame(maxWidth: .infinity).padding(.vertical, 20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.2), radius: 14, y: 7)
                }
                .padding(.horizontal, 28).padding(.bottom, 48)
            }
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        )
    }
}

// MARK: - About View

struct AboutView: View {
    let language: AppLanguage
    @Environment(\.dismiss) var dismiss

    func t(_ en: String, _ fa: String) -> String { language == .persian ? fa : en }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // App identity
                        VStack(spacing: 10) {
                            Text("🎭").font(.system(size: 64))
                            Text("پانتومیم")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundStyle(AppColors.text)
                            Text(t("the CHALLENGE", "چالش بزرگ"))
                                .font(AppFonts.rounded(15, weight: .heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14).padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(AppColors.text).rotationEffect(.degrees(-1))
                                )
                            Text(t("Version 1.0  •  Free forever",
                                   "نسخه ۱.۰  •  رایگان برای همیشه"))
                                .font(AppFonts.rounded(13))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding(.top, 16)

                        // About the app
                        aboutCard(
                            icon: "gamecontroller.fill",
                            color: AppColors.blue,
                            title: t("About the App", "درباره اپ")
                        ) {
                            Text(t(
                                "Pantomime is a free Persian & English party game built for friends and families. No accounts, no ads, no paywalls — just fun.",
                                "پانتومیم یه بازی پارتی رایگان به فارسی و انگلیسی برای دوستان و خانواده‌هاست. بدون اکانت، بدون تبلیغ، بدون پرداخت — فقط سرگرمی."
                            ))
                            .font(AppFonts.rounded(14))
                            .foregroundStyle(AppColors.text)
                            .fixedSize(horizontal: false, vertical: true)
                        }

                        // The team
                        aboutCard(
                            icon: "person.2.fill",
                            color: AppColors.purple,
                            title: t("Our Team", "تیم ما")
                        ) {
                            VStack(spacing: 14) {
                                teamMember(
                                    name: t("Erfan Yarahmadi", "عرفان یاراحمدی"),
                                    role: t("Design & Development", "طراحی و توسعه"),
                                    emoji: "👨‍💻"
                                )
                                Divider()
                                // ── Add your team members below ──
                                // teamMember(name: "...", role: "...", emoji: "...")
                                Text(t(
                                    "Built with ❤️ at Apple Developer Academy, Naples",
                                    "ساخته شده با ❤️ در Apple Developer Academy، ناپل"
                                ))
                                .font(AppFonts.rounded(12))
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            }
                        }

                        // Credits
                        aboutCard(
                            icon: "heart.fill",
                            color: AppColors.red,
                            title: t("Credits & Thanks", "تشکر و قدردانی")
                        ) {
                            Text(t(
                                "A love letter to Persian party culture. Dedicated to all Farsi-speaking people around the world. Special thanks to everyone who playtested and gave feedback.",
                                "یه هدیه عاشقانه به فرهنگ پارتی ایرانی. تقدیم به تمام فارسی‌زبانان دنیا. تشکر ویژه از همه کسانی که بازی رو تست کردند و بازخورد دادند."
                            ))
                            .font(AppFonts.rounded(14))
                            .foregroundStyle(AppColors.text)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle(t("About Us", "درباره ما"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(t("Done", "تأیید")) { dismiss() }
                        .font(AppFonts.rounded(16, weight: .bold))
                        .foregroundStyle(AppColors.blue)
                }
            }
        }
        .layoutDir(language)
    }

    func aboutCard(icon: String, color: Color, title: String,
                   @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(color)
                Text(title)
                    .font(AppFonts.rounded(13, weight: .heavy))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal, 20)
            VStack(alignment: .leading, spacing: 10) { content() }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: color.opacity(0.1), radius: 10, y: 4)
                .padding(.horizontal, 20)
        }
    }

    func teamMember(name: String, role: String, emoji: String) -> some View {
        HStack(spacing: 12) {
            Text(emoji).font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(AppFonts.rounded(15, weight: .bold))
                    .foregroundStyle(AppColors.text)
                Text(role)
                    .font(AppFonts.rounded(12))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
        }
    }
}

