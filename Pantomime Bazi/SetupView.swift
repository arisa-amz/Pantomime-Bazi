//
//  SetupView.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//
import SwiftUI

struct SetupView: View {
    @State private var vm = GameViewModel()
    @State private var appSettings = AppSettings()
    @State private var showSettings = false

    var lang: AppLanguage { vm.settings.language }
    func t(_ en: String, _ fa: String) -> String { lang == .persian ? fa : en }

    var body: some View {
        NavigationStack(path: $vm.navPath) {
            ZStack {
                AppColors.background.ignoresSafeArea()
                decorativeBlobs

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        teamsSection
                        gameSettingsSection
                        startButton.padding(.bottom, 48)
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .teamReady: TeamReadyView(vm: vm, appSettings: appSettings)
                case .playing:   PlayingView(vm: vm, appSettings: appSettings)
                case .gameOver:  GameOverView(vm: vm, appSettings: appSettings)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet(appSettings: appSettings, language: lang)
            }
        }
        .layoutDir(lang)
    }

    // MARK: - Header

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
                    LanguageToggle(language: Binding(
                        get: { vm.settings.language },
                        set: { vm.settings.language = $0 }
                    ))
                    Spacer()
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.purple)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.07), radius: 6, y: 3)
                    }
                }
                .padding(.horizontal, 20).padding(.top, 14)

                VStack(spacing: 4) {
                    Text(t("PANTOMIME", "پانتومیم"))
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.text).tracking(-1)
                    HStack(spacing: 0) {
                        Capsule().fill(AppColors.red).frame(height: 5)
                        Capsule().fill(AppColors.blue).frame(height: 5)
                    }.frame(width: 160)
                    Text(t("the CHALLENGE", "چالش بزرگ"))
                        .font(AppFonts.rounded(15, weight: .heavy))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 16).padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(AppColors.text).rotationEffect(.degrees(-2))
                        )
                        .offset(x: 18, y: -2)
                }
                .padding(.top, 10).padding(.bottom, 24)
            }
        }
    }

    // MARK: - Teams
    // FIX: canDelete is computed as a plain Bool from vm.settings.teams.count
    // and passed directly to each TeamCard. Because it's read fresh on every
    // body evaluation (not captured in a closure), it updates correctly when
    // teams are added or removed.

    var teamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(t("Teams", "تیم‌ها"), icon: "person.3.fill", color: AppColors.blue)

            VStack(spacing: 10) {
                let canDelete = vm.settings.teams.count > 2

                ForEach(Array(vm.settings.teams.enumerated()), id: \.element.id) { i, _ in
                    TeamCard(
                        team: Binding(
                            get: {
                                guard i < vm.settings.teams.count else { return vm.settings.teams[0] }
                                return vm.settings.teams[i]
                            },
                            set: {
                                guard i < vm.settings.teams.count else { return }
                                vm.settings.teams[i] = $0
                            }
                        ),
                        index: i,
                        language: lang,
                        canDelete: canDelete,           // ← plain Bool, not a closure condition
                        onDelete: { deleteTeam(at: i) } // ← always provided; card shows it only when canDelete
                    )
                }

                if vm.settings.teams.count < 6 {
                    Button { addTeam() } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill").font(.system(size: 20))
                            Text(t("Add Team", "افزودن تیم")).font(AppFonts.rounded(16, weight: .bold))
                        }
                        .foregroundStyle(AppColors.blue)
                        .frame(maxWidth: .infinity).padding(.vertical, 15)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(AppColors.blue.opacity(0.4),
                                              style: StrokeStyle(lineWidth: 2, dash: [8]))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 6)
    }

    // MARK: - Game Settings (rounds + time only — category moved to TeamReady)

    var gameSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(t("Game Settings", "تنظیمات بازی"), icon: "gearshape.fill", color: AppColors.purple)

            FatCard(color: AppColors.purple) {
                VStack(spacing: 18) {
                    StepperRow(
                        label: t("Rounds", "تعداد راند"),
                        value: Binding(get: { vm.settings.rounds }, set: { vm.settings.rounds = $0 }),
                        range: 1...10, color: AppColors.purple
                    )
                    Divider()
                    timeRow
                }
                .padding(18)
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 18)
    }

    var timeRow: some View {
        let times = [30, 45, 60, 90, 120]
        let idx = times.firstIndex(of: vm.settings.timePerTurn) ?? 2
        return HStack {
            Text(t("Time per turn", "زمان هر نوبت"))
                .font(AppFonts.rounded(15, weight: .medium)).foregroundStyle(AppColors.text)
            Spacer()
            HStack(spacing: 12) {
                Button {
                    if idx > 0 { vm.settings.timePerTurn = times[idx - 1]; Haptics.impact(.light) }
                } label: {
                    Image(systemName: "minus.circle.fill").font(.system(size: 26))
                        .foregroundStyle(idx > 0 ? AppColors.purple : AppColors.textSecondary.opacity(0.3))
                }
                Text("\(vm.settings.timePerTurn)s")
                    .font(AppFonts.rounded(18, weight: .bold)).foregroundStyle(AppColors.text)
                    .frame(minWidth: 44, alignment: .center)
                Button {
                    if idx < times.count-1 { vm.settings.timePerTurn = times[idx+1]; Haptics.impact(.light) }
                } label: {
                    Image(systemName: "plus.circle.fill").font(.system(size: 26))
                        .foregroundStyle(idx < times.count-1 ? AppColors.purple : AppColors.textSecondary.opacity(0.3))
                }
            }
        }
    }

    // MARK: - Start

    var startButton: some View {
        Button {
            appSettings.hapticNotification(.success)
            vm.startGame()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.fill").font(.system(size: 17, weight: .black))
                Text(t("START GAME", "شروع بازی"))
                    .font(.system(size: 19, weight: .black, design: .rounded)).tracking(1)
            }
            .foregroundStyle(Color.white).frame(maxWidth: .infinity).padding(.vertical, 20)
            .background(LinearGradient(colors: [AppColors.red, AppColors.blue],
                                       startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: AppColors.red.opacity(0.35), radius: 16, y: 8)
        }
        .padding(.horizontal, 20).padding(.top, 28)
    }

    // MARK: - Decorative

    var decorativeBlobs: some View {
        ZStack {
            Circle().fill(AppColors.blue.opacity(0.07)).frame(width: 300).offset(x: -120, y: -200)
            Circle().fill(AppColors.red.opacity(0.07)).frame(width: 250).offset(x: 160, y: 100)
        }
        .ignoresSafeArea()
    }

    func sectionHeader(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 15, weight: .bold)).foregroundStyle(color)
            Text(title).font(AppFonts.rounded(19, weight: .black)).foregroundStyle(AppColors.text)
        }
        .padding(.horizontal, 20)
    }

    func addTeam() {
        Haptics.impact(.medium)
        let i = vm.settings.teams.count
        vm.settings.teams.append(Team(
            name: Team.defaultName(index: i, language: lang),
            playerCount: 2,
            color: Team.defaultColors[i % Team.defaultColors.count]
        ))
    }

    func deleteTeam(at index: Int) {
        Haptics.impact(.light)
        guard index < vm.settings.teams.count else { return }
        vm.settings.teams.remove(at: index)
    }
}

// MARK: - Team Card

struct TeamCard: View {
    @Binding var team: Team
    let index: Int
    let language: AppLanguage
    let canDelete: Bool        // ← plain Bool passed from parent, re-evaluated every render
    let onDelete: () -> Void
    @State private var editingName = false

    var body: some View {
        FatCard(color: team.color) {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(team.color).frame(width: 40, height: 40)
                        Text("\(index + 1)")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(Color.white)
                    }

                    if editingName {
                        TextField(language == .persian ? "نام تیم" : "Team name", text: $team.name)
                            .font(AppFonts.rounded(17, weight: .bold)).foregroundStyle(AppColors.text)
                            .submitLabel(.done).onSubmit { editingName = false }
                    } else {
                        Text(team.name)
                            .font(AppFonts.rounded(17, weight: .bold)).foregroundStyle(AppColors.text)
                    }

                    Spacer()

                    Button {
                        Haptics.impact(.light); editingName.toggle()
                    } label: {
                        Image(systemName: editingName ? "checkmark.circle.fill" : "pencil.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(editingName ? AppColors.green : team.color)
                    }

                    // Delete button shown/hidden by canDelete — no optional, always in layout
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppColors.red.opacity(0.7))
                    }
                    .opacity(canDelete ? 1 : 0)
                    .allowsHitTesting(canDelete)
                }

                Divider()

                StepperRow(
                    label: language == .persian ? "تعداد بازیکنان" : "Players",
                    value: $team.playerCount, range: 1...10, color: team.color
                )
            }
            .padding(15)
        }
    }
}

// MARK: - Settings Sheet

struct SettingsSheet: View {
    var appSettings: AppSettings
    let language: AppLanguage
    @Environment(\.dismiss) var dismiss

    func t(_ en: String, _ fa: String) -> String { language == .persian ? fa : en }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        settingsCard(title: t("Sound & Music", "صدا و موسیقی"),
                                     icon: "speaker.wave.2.fill", color: AppColors.purple) {
                            SettingsToggleRow(
                                icon: "speaker.wave.2.fill", iconColor: AppColors.purple,
                                title: t("Sound Effects", "افکت‌های صوتی"),
                                subtitle: t("Tap sounds and feedback", "صدای لمس و بازخورد"),
                                isOn: Binding(get: { appSettings.soundEnabled },
                                             set: { appSettings.soundEnabled = $0 })
                            )
                            Divider()
                            SettingsToggleRow(
                                icon: "music.note", iconColor: AppColors.pink,
                                title: t("Party Music", "موسیقی پارتی"),
                                subtitle: t("Plays during each turn — add 'party.mp3' to your bundle",
                                           "حین بازی پخش می‌شه — فایل 'party.mp3' را به پروژه اضافه کنید"),
                                isOn: Binding(get: { appSettings.partyMusicEnabled },
                                             set: { appSettings.partyMusicEnabled = $0 })
                            )
                            Divider()
                            SettingsToggleRow(
                                icon: "timer", iconColor: AppColors.red,
                                title: t("Countdown Beep", "صدای شمارش معکوس"),
                                subtitle: t("Beep at 10 seconds remaining", "صدا در ۱۰ ثانیه پایانی"),
                                isOn: Binding(get: { appSettings.countdownBeepEnabled },
                                             set: { appSettings.countdownBeepEnabled = $0 })
                            )
                        }

                        settingsCard(title: t("Feel", "لرزش"),
                                     icon: "iphone.radiowaves.left.and.right", color: AppColors.orange) {
                            SettingsToggleRow(
                                icon: "iphone.radiowaves.left.and.right", iconColor: AppColors.orange,
                                title: t("Vibration", "لرزش"),
                                subtitle: t("Haptic feedback on taps and events", "لرزش هنگام لمس و رویدادها"),
                                isOn: Binding(get: { appSettings.hapticsEnabled },
                                             set: { appSettings.hapticsEnabled = $0 })
                            )
                        }

                        settingsCard(title: t("Gameplay", "بازی"),
                                     icon: "gamecontroller.fill", color: AppColors.blue) {
                            SettingsToggleRow(
                                icon: "globe", iconColor: AppColors.blue,
                                title: t("Show Translation", "نمایش ترجمه"),
                                subtitle: t("Shows word in the other language as a hint",
                                           "کلمه را به زبان دیگر نشان می‌دهد"),
                                isOn: Binding(get: { appSettings.showWordTranslation },
                                             set: { appSettings.showWordTranslation = $0 })
                            )
                        }

                        HStack(spacing: 10) {
                            Image(systemName: "theatermasks.fill")
                                .font(.system(size: 22)).foregroundStyle(AppColors.purple)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("پانتومیم")
                                    .font(AppFonts.rounded(15, weight: .black)).foregroundStyle(AppColors.text)
                                Text(t("Free party game for everyone", "بازی پارتی رایگان برای همه"))
                                    .font(AppFonts.rounded(12)).foregroundStyle(AppColors.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(16).background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                        .padding(.horizontal, 20).padding(.top, 4)
                    }
                    .padding(.top, 8).padding(.bottom, 40)
                }
            }
            .navigationTitle(t("Settings", "تنظیمات"))
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

    func settingsCard(title: String, icon: String, color: Color,
                      @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 7) {
                Image(systemName: icon).font(.system(size: 13, weight: .bold)).foregroundStyle(color)
                Text(title).font(AppFonts.rounded(13, weight: .heavy)).foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal, 20)
            VStack(spacing: 12) { content() }
                .padding(16).background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: color.opacity(0.1), radius: 10, y: 4)
                .padding(.horizontal, 20)
        }
    }
}
