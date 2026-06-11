//
//  RootView.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: ArchiveStore

    var body: some View {
        Group {
            if store.isLoggedIn {
                HomeView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: store.isLoggedIn)
    }
}

struct LoginView: View {
    @EnvironmentObject private var store: ArchiveStore
    @State private var selectedRole: AppRole = .visitor
    @State private var email = ""
    @State private var password = ""
    @State private var loginError: String?

    private var canLogin: Bool {
        email.contains("@") && email.contains(".") && password.count >= 6
    }

    var body: some View {
        ZStack {
            Color.tanPaper.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Spacer(minLength: 10)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("摊")
                            .font(.system(size: 70, weight: .black))
                            .foregroundStyle(Color.tanInk)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("记录成都街头的烟火气")
                                .font(.system(size: 25, weight: .black))
                                .foregroundStyle(Color.tanInk)
                            Text("用邮箱登录，继续查看摊位、手艺、故事和路线。")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.tanInk.opacity(0.68))
                                .lineSpacing(4)
                        }

                        HStack(spacing: 8) {
                            TagPill(text: "成都市井档案")
                            TagPill(text: "老手艺保护")
                            TagPill(text: "社区补档")
                        }
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        LinearGradient(
                            colors: [Color.tanPrimary.opacity(0.18), .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: TanRadius.xlarge, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: TanRadius.xlarge, style: .continuous)
                            .stroke(Color.white.opacity(0.75), lineWidth: 1)
                    }
                    .shadow(color: Color.tanInk.opacity(0.08), radius: 18, x: 0, y: 10)

                    loginFields

                    VStack(alignment: .leading, spacing: 12) {
                        Text("选择登录身份")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.tanInk)

                        HStack(spacing: 12) {
                            roleButton(.visitor, icon: "figure.walk", title: "用户端", subtitle: "附近摊位 · 老手艺 · 消失预警")
                            roleButton(.stallOwner, icon: "storefront.fill", title: "摊户端", subtitle: "AI 建档 · 我的档案 · 收到补档")
                        }
                    }

                    Button {
                        login()
                    } label: {
                        Text(selectedRole == .visitor ? "登录并进入地图" : "登录并进入摊户端")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!canLogin)
                    .opacity(canLogin ? 1 : 0.55)

                    Text("原型账号支持任意有效邮箱，密码不少于 6 位。")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text(store.cloudState)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(24)
            }
        }
    }

    private var loginFields: some View {
        Surface {
            Text("邮箱登录")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.tanInk)

            HStack(spacing: 10) {
                Image(systemName: "envelope.fill")
                    .foregroundStyle(Color.tanPrimary)
                TextField("name@example.com", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(Color.tanPaper)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))

            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(Color.tanPrimary)
                SecureField("请输入至少 6 位密码", text: $password)
                    .textContentType(.password)
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(Color.tanPaper)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))

            if let loginError {
                Label(loginError, systemImage: "exclamationmark.circle.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.warningRed)
            }
        }
    }

    private func login() {
        guard canLogin else {
            loginError = "请输入有效邮箱和至少 6 位密码"
            return
        }
        loginError = nil
        store.login(as: selectedRole)
    }

    private func roleButton(_ role: AppRole, icon: String, title: String, subtitle: String) -> some View {
        Button {
            selectedRole = role
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: 42, height: 42)
                    .background(selectedRole == role ? .white.opacity(0.18) : Color.tanPrimary.opacity(0.12))
                    .clipShape(Circle())
                Text(title)
                    .font(.system(size: 17, weight: .black))
                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(selectedRole == role ? .white.opacity(0.82) : Color.tanInk.opacity(0.58))
                    .lineLimit(2)
            }
            .foregroundStyle(selectedRole == role ? .white : Color.tanInk)
            .frame(maxWidth: .infinity)
            .frame(height: 136)
            .padding(14)
            .background(selectedRole == role ? Color.tanPrimary : .white)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous)
                    .stroke(selectedRole == role ? Color.tanPrimary.opacity(0.45) : Color.tanLine)
            }
            .shadow(color: selectedRole == role ? Color.tanPrimary.opacity(0.22) : Color.tanInk.opacity(0.05), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: selectedRole)
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: ArchiveStore
    @State private var appFlipAngle = 0.0
    @State private var isSwitchingRole = false

    var body: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                ArchiveMapView()
                    .roleSwitchToolbar(action: switchRole)
            }
            .tag(AppTab.map)
            .tabItem {
                Label("地图", systemImage: "map")
            }

            if store.selectedRole == .visitor {
                NavigationStack {
                    DiscoverView()
                        .roleSwitchToolbar(action: switchRole)
                }
                .tag(AppTab.discover)
                .tabItem {
                    Label("发现", systemImage: "square.grid.2x2")
                }
            }

            if store.selectedRole == .stallOwner {
                NavigationStack {
                    AIArchiveBuilderView()
                        .roleSwitchToolbar(action: switchRole)
                }
                .tag(AppTab.build)
                .tabItem {
                    Label("建档", systemImage: "sparkles")
                }
            }

            NavigationStack {
                ProfileView()
                    .roleSwitchToolbar(action: switchRole)
            }
            .tag(AppTab.profile)
            .tabItem {
                Label("我的", systemImage: "person.crop.circle")
            }
        }
        .tint(.tanPrimary)
        .fixedWhiteTabBar()
        .rotation3DEffect(
            .degrees(appFlipAngle),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.72
        )
        .scaleEffect(abs(appFlipAngle) > 45 ? 0.96 : 1)
    }

    private func switchRole() {
        guard !isSwitchingRole else { return }
        isSwitchingRole = true

        withAnimation(.easeIn(duration: 0.22)) {
            appFlipAngle = 90
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 220_000_000)
            let nextRole: AppRole = store.selectedRole == .visitor ? .stallOwner : .visitor
            store.switchRole(to: nextRole)
            store.selectedTab = .map
            appFlipAngle = -90
            withAnimation(.easeOut(duration: 0.24)) {
                appFlipAngle = 0
            }
            try? await Task.sleep(nanoseconds: 250_000_000)
            isSwitchingRole = false
        }
    }
}

private struct RoleSwitchToolbarModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    RoleFlipButton(action: action)
                }
            }
    }
}

private struct RoleFlipButton: View {
    @EnvironmentObject private var store: ArchiveStore
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: store.selectedRole == .visitor ? "person.fill" : "storefront.fill")
                Text(store.selectedRole == .visitor ? "用户端" : "摊户端")
            }
            .font(.system(size: 12, weight: .black))
            .foregroundStyle(Color.tanInk)
            .padding(.horizontal, 10)
            .frame(height: 34)
            .background(.white.opacity(0.94))
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(Color.tanLine)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("切换用户端和摊户端")
    }
}

private extension View {
    func roleSwitchToolbar(action: @escaping () -> Void) -> some View {
        modifier(RoleSwitchToolbarModifier(action: action))
    }
}
