//
//  SettingsView.swift
//  Fugu15
//
//  Created by exerhythm on 02.04.2023.
//

import SwiftUI
import Fugu15KernelExploit

struct SettingsView: View {

    @AppStorage("totalJailbreaks", store: dopamineDefaults()) var totalJailbreaks: Int = 0
    @AppStorage("successfulJailbreaks", store: dopamineDefaults()) var successfulJailbreaks: Int = 0

    @AppStorage("verboseLogsEnabled", store: dopamineDefaults()) var verboseLogs: Bool = false
    @AppStorage("tweakInjectionEnabled", store: dopamineDefaults()) var tweakInjection: Bool = true
    @AppStorage("iDownloadEnabled", store: dopamineDefaults()) var enableiDownload: Bool = false
    @AppStorage("enableMount", store: dopamineDefaults()) var enableMount: Bool = true

    @State var rootPasswordChangeAlertShown = false
    @State var rootPasswordInput = "alpine"

    @State var removeJailbreakAlertShown = false
    @State var tweakInjectionToggledAlertShown = false

    @State var isEnvironmentHiddenState = isEnvironmentHidden()

    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .init(named: "AccentColor")
    }

    var body: some View {
        VStack {
            Text("Settings_Title")
            Divider()
                .background(.white)
                .padding(.horizontal, 32)
                .opacity(0.25)

            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Toggle("Options_Tweak_Injection", isOn: $tweakInjection)
                        .onChange(of: tweakInjection) { newValue in
                            if isJailbroken() {
                                jailbrokenUpdateTweakInjectionPreference()
                                tweakInjectionToggledAlertShown = true
                            }
                        }
                    if !isJailbroken() {
                        Toggle("Options_iDownload", isOn: $enableiDownload)
                        Toggle("Options_Verbose_Logs", isOn: $verboseLogs)
                        Toggle("Enable Path Mapping", isOn: $enableMount)
                    }
                }
                if isBootstrapped() {
                    VStack {
                        if isJailbroken() {
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                rootPasswordChangeAlertShown = true
                            }) {
                                HStack {
                                    Image(systemName: "key")
                                    Text("Button_Set_Root_Password")
                                        .lineLimit(1)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                                )
                            }
                            .padding(.bottom)
                        }
                        VStack {
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                isEnvironmentHiddenState.toggle()
                                changeEnvironmentVisibility(hidden: !isEnvironmentHidden())
                            }) {
                                HStack {
                                    Image(systemName: isEnvironmentHiddenState ? "eye" : "eye.slash")
                                    Text(isEnvironmentHiddenState ? "Button_Unhide_Jailbreak" : "Button_Hide_Jailbreak")
                                        .lineLimit(1)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                                )
                            }
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                removeJailbreakAlertShown = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Button_Remove_Jailbreak")
                                        .lineLimit(1)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                                )
                            }
                            Text("Hint_Hide_Jailbreak")
                                .font(.footnote)
                                .opacity(0.6)
                                .padding(.top, 2)
                        }
                    }
                }
            }
            .tint(.accentColor)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)

            Divider()
                .background(.white)
                .padding(.horizontal, 32)
                .opacity(0.25)
            VStack(spacing: 6) {
                Text(isBootstrapped() ? "Settings_Footer_Device_Bootstrapped" :  "Settings_Footer_Device_Not_Bootstrapped")
                    .font(.footnote)
                    .opacity(0.6)
                Text("Success_Rate \(successRate())% (\(successfulJailbreaks)/\(totalJailbreaks))")
                    .font(.footnote)
                    .opacity(0.6)
            }
            .padding(.top, 2)


            ZStack {}
                .textFieldAlert(isPresented: $rootPasswordChangeAlertShown) { () -> TextFieldAlert in
                    TextFieldAlert(title: NSLocalizedString("Popup_Change_Root_Password_Title", comment: ""), message: "", text: Binding<String?>($rootPasswordInput))
                }
                .alert("Settings_Remove_Jailbreak_Alert_Title", isPresented: $removeJailbreakAlertShown, actions: {
                    Button("Button_Cancel", role: .cancel) { }
                    Button("Alert_Button_Uninstall", role: .destructive) {
                        removeJailbreak()
                    }
                }, message: { Text("Settings_Remove_Jailbreak_Alert_Body") })
                .alert("Settings_Tweak_Injection_Toggled_Alert_Title", isPresented: $tweakInjectionToggledAlertShown, actions: {
                    Button("Button_Cancel", role: .cancel) { }
                    Button("Menu_Reboot_Userspace_Title") {
                        userspaceReboot()
                    }
                }, message: { Text("Alert_Tweak_Injection_Toggled_Body") })
                .frame(maxHeight: 0)

        }
        .foregroundColor(.white)
    }

    func successRate() -> String {
        if totalJailbreaks == 0 {
            return "-"
        } else {
            return String(format: "%.1f", Double(successfulJailbreaks) / Double(totalJailbreaks) * 100)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
