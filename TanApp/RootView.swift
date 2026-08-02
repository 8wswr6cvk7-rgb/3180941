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
    private enum LoginField: Hashable {
        case email
        case password
    }

    @EnvironmentObject private var store: ArchiveStore
    @State private var selectedRole: AppRole = .visitor
    @State private var loginEmail = ""
    @State private var loginPassword = ""
    @State private var loginError: String?
    @FocusState private var focusedField: LoginField?

    private var canLogin: Bool {
        loginEmail.contains("@") && loginEmail.contains(".") && loginPassword.count >= 6
    }

    var body: some View {
        ZStack {
            Color.tanPaper.ignoresSafeArea()

            GeometryReader { proxy in
                let isCompact = proxy.size.height < 760

                VStack(alignment: .leading, spacing: isCompact ? 10 : 14) {
                    loginHero(compact: isCompact)
                    loginFields(compact: isCompact)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("选择登录身份")
                            .font(.system(size: isCompact ? 16 : 18, weight: .bold))
                            .foregroundStyle(Color.tanInk)

                        HStack(alignment: .top, spacing: 10) {
                            roleButton(
                                .visitor,
                                icon: "figure.walk",
                                title: "用户端",
                                subtitle: "发现摊位 · 街巷故事",
                                compact: isCompact
                            )
                            roleButton(
                                .stallOwner,
                                icon: "storefront.fill",
                                title: "摊户端",
                                subtitle: "AI 建档 · 档案维护",
                                compact: isCompact
                            )
                        }
                    }

                    Button {
                        login()
                    } label: {
                        Text("进入地图")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!canLogin)
                    .opacity(canLogin ? 1 : 0.55)
                    .accessibilityIdentifier("login.submit")

                    if !isCompact {
                        Text("邮箱用于区分本机身份，密码不少于 6 位。")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .frame(maxWidth: 620)
                .padding(.horizontal, 20)
                .padding(.vertical, isCompact ? 8 : 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }

    private func loginHero(compact: Bool) -> some View {
        HStack(alignment: .center, spacing: compact ? 12 : 18) {
            Text("摊")
                .font(.system(size: compact ? 42 : 56, weight: .black))
                .foregroundStyle(Color.tanInk)

            VStack(alignment: .leading, spacing: compact ? 2 : 5) {
                Text("记录成都街头的烟火气")
                    .font(.system(size: compact ? 18 : 23, weight: .black))
                    .foregroundStyle(Color.tanInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("记录摊位、手艺、人物与街巷故事")
                    .font(.system(size: compact ? 12 : 14, weight: .semibold))
                    .foregroundStyle(Color.tanInk.opacity(0.68))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)
        }
        .padding(compact ? 12 : 16)
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
    }

    private func loginFields(compact: Bool) -> some View {
        Surface {
            Text("邮箱登录")
                .font(.system(size: compact ? 15 : 18, weight: .black))
                .foregroundStyle(Color.tanInk)

            HStack(spacing: 10) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.tanPrimary)

                ZStack(alignment: .leading) {
                    TextField("", text: $loginEmail)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.black)
                        .tint(Color.tanPrimary)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .password
                        }
                        .accessibilityIdentifier("login.email")

                    if loginEmail.isEmpty {
                        Text(verbatim: "name@example.com")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.gray.opacity(0.65))
                            .allowsHitTesting(false)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 14)
            .frame(height: compact ? 44 : 48)
            .background(Color.tanPaper)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))

            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.tanPrimary)

                ZStack(alignment: .leading) {
                    SecureField("", text: $loginPassword)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.black)
                        .tint(Color.tanPrimary)
                        .textContentType(.password)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit {
                            login()
                        }
                        .accessibilityIdentifier("login.password")

                    if loginPassword.isEmpty {
                        Text(verbatim: "请输入至少 6 位密码")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.gray.opacity(0.65))
                            .allowsHitTesting(false)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 14)
            .frame(height: compact ? 44 : 48)
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

    private func roleButton(
        _ role: AppRole,
        icon: String,
        title: String,
        subtitle: String,
        compact: Bool
    ) -> some View {
        Button {
            selectedRole = role
        } label: {
            VStack(alignment: .leading, spacing: compact ? 6 : 8) {
                Image(systemName: icon)
                    .font(.system(size: compact ? 18 : 21, weight: .bold))
                    .frame(width: compact ? 34 : 38, height: compact ? 34 : 38)
                    .background(selectedRole == role ? .white.opacity(0.18) : Color.tanPrimary.opacity(0.12))
                    .clipShape(Circle())
                Text(title)
                    .font(.system(size: compact ? 15 : 17, weight: .black))
                Text(subtitle)
                    .font(.system(size: compact ? 11 : 12, weight: .semibold))
                    .foregroundStyle(selectedRole == role ? .white.opacity(0.82) : Color.tanInk.opacity(0.58))
                    .lineLimit(2)
            }
            .foregroundStyle(selectedRole == role ? .white : Color.tanInk)
            .frame(maxWidth: .infinity)
            .frame(height: compact ? 88 : 110)
            .padding(compact ? 10 : 12)
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
        .accessibilityIdentifier(role == .visitor ? "login.role.visitor" : "login.role.stallOwner")
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: ArchiveStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSwitchingRole = false
    @State private var appFlipAngle = 0.0
    @State private var mapViewRevision = 0

    var body: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                ArchiveMapView()
                    .id(mapViewRevision)
                    .roleSwitchToolbar(
                        isEnabled: !isSwitchingRole,
                        action: switchRole
                    )
            }
            .tag(AppTab.map)
            .tabItem {
                Label("地图", systemImage: "map")
            }

            if store.selectedRole == .visitor {
                NavigationStack {
                    DiscoverView()
                        .roleSwitchToolbar(
                            isEnabled: !isSwitchingRole,
                            action: switchRole
                        )
                }
                .tag(AppTab.discover)
                .tabItem {
                    Label("发现", systemImage: "square.grid.2x2")
                }
            }

            if store.selectedRole == .stallOwner {
                NavigationStack {
                    AIArchiveBuilderView()
                        .roleSwitchToolbar(
                            isEnabled: !isSwitchingRole,
                            action: switchRole
                        )
                }
                .tag(AppTab.build)
                .tabItem {
                    Label("建档", systemImage: "sparkles")
                }
            }

            NavigationStack {
                ProfileView()
                    .roleSwitchToolbar(
                        isEnabled: !isSwitchingRole,
                        action: switchRole
                    )
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
        .allowsHitTesting(!isSwitchingRole)
    }

    private func switchRole() {
        guard !isSwitchingRole else { return }
        isSwitchingRole = true

        if reduceMotion {
            let nextRole: AppRole = store.selectedRole == .visitor ? .stallOwner : .visitor
            store.switchRole(to: nextRole)
            mapViewRevision += 1
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 250_000_000)
                isSwitchingRole = false
            }
            return
        }

        withAnimation(.easeIn(duration: 0.22)) {
            appFlipAngle = 90
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 220_000_000)
            let nextRole: AppRole = store.selectedRole == .visitor ? .stallOwner : .visitor
            store.switchRole(to: nextRole)
            appFlipAngle = -90
            withAnimation(.easeOut(duration: 0.24)) {
                appFlipAngle = 0
            }
            try? await Task.sleep(nanoseconds: 250_000_000)
            // MKMapView 的署名图层可能保留父视图 3D 变换后的几何状态。
            // 页面恢复正面后重建地图层，避免 Legal 署名被反复拉伸。
            mapViewRevision += 1
            isSwitchingRole = false
        }
    }
}

private struct RoleSwitchToolbarModifier: ViewModifier {
    let isEnabled: Bool
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    RoleFlipButton(
                        isEnabled: isEnabled,
                        action: action
                    )
                }
            }
    }
}

private struct RoleFlipButton: View {
    @EnvironmentObject private var store: ArchiveStore
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: store.selectedRole == .visitor ? "person.fill" : "storefront.fill")
                Text(store.selectedRole == .visitor ? "用户端" : "摊户端")
            }
            .font(.system(size: 11.5, weight: .black))
            .foregroundStyle(Color.tanInk)
            .lineLimit(1)
            .minimumScaleFactor(0.9)
            .frame(width: 84, height: 34)
            .background(.white.opacity(0.94))
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(Color.tanLine)
            }
            .frame(width: 92, height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityIdentifier("home.role.switch")
        .accessibilityLabel("切换用户端和摊户端")
        .accessibilityHint(isEnabled ? "点按切换身份" : "正在切换身份")
    }
}

private extension View {
    func roleSwitchToolbar(
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        modifier(
            RoleSwitchToolbarModifier(
                isEnabled: isEnabled,
                action: action
            )
        )
    }
}
