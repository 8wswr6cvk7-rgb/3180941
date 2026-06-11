//
//  ArchiveMapView.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI
import MapKit

struct ArchiveMapView: View {
    @EnvironmentObject private var store: ArchiveStore
    @StateObject private var locationManager = StallLocationManager()

    @State private var selectedArchiveID: UUID?
    @State private var showSearch = false
    @State private var liveLocationEnabled = false
    @State private var focusCoordinate: CLLocationCoordinate2D?
    @State private var pendingQuickOpenArchiveID: UUID?
    @State private var visibleRouteArchiveID: UUID?
    @State private var isMapCardCollapsed = false
    @State private var showMapHint = true
    @State private var toastMessage: String?
    @State private var navigationArchiveID: UUID?
    @State private var hasCenteredOnUser = false
    @State private var archiveToEdit: CityArchive?
    @State private var showXilian = false

    private var displayedArchives: [CityArchive] {
        store.selectedRole == .stallOwner ? store.currentUserArchives : store.archives
    }

    private var selectedArchive: CityArchive? {
        guard let selectedArchiveID else {
            return nil
        }
        return displayedArchives.first(where: { $0.id == selectedArchiveID })
    }

    private var quickOpenArchive: CityArchive? {
        if let selectedArchive, selectedArchive.isUserCreated {
            return selectedArchive
        }
        return store.currentUserArchives.first
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ArchiveMapRepresentable(
                archives: displayedArchives,
                selectedID: selectedArchiveID,
                routeArchiveID: visibleRouteArchiveID,
                navigationArchiveID: navigationArchiveID,
                userCoordinate: locationManager.currentCoordinate,
                focusCoordinate: focusCoordinate,
                showsUserLocation: liveLocationEnabled
            ) { archive in
                if visibleRouteArchiveID == archive.id && isMapCardCollapsed {
                    return
                }
                selectedArchiveID = archive.id
                focusCoordinate = archive.currentLocation.coordinate
                liveLocationEnabled = false
                visibleRouteArchiveID = nil
                navigationArchiveID = nil
                isMapCardCollapsed = false
            } onRouteResult: { routeKind, succeeded in
                guard routeKind == .history else { return }
                showToast(
                    succeeded ? "上次路线已按真实道路显示" : "Apple 地图暂时无法规划这段历史路线",
                    binding: $toastMessage
                )
            }
            .ignoresSafeArea()

            VStack(spacing: 12) {
                topControls
                if showMapHint && selectedArchive == nil {
                    MapHintCard {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showMapHint = false
                        }
                    }
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()

                if store.selectedRole == .visitor {
                    HStack {
                        Spacer()
                        XilianFloatingButton(
                            state: selectedArchive?.status == .atRisk ? .worried : .idle
                        ) {
                            showXilian = true
                        }
                    }
                    .padding(.horizontal, 16)
                    .transition(.scale.combined(with: .opacity))
                }

                if store.selectedRole == .stallOwner, let quickOpenArchive {
                    QuickOpenStallButton(archive: quickOpenArchive) {
                        if quickOpenArchive.status == .open {
                            store.closeArchive(quickOpenArchive)
                            showToast("已收摊，地图会保留你的档案", binding: $toastMessage)
                        } else {
                            pendingQuickOpenArchiveID = quickOpenArchive.id
                            openPendingArchiveWithLocation()
                        }
                    }
                    .padding(.horizontal, 34)
                    .padding(.bottom, selectedArchive == nil ? 72 : 0)
                    .transition(.scale.combined(with: .opacity))
                }

                if let selectedArchive {
                    ArchiveMapCard(
                        archive: selectedArchive,
                        isCollapsed: $isMapCardCollapsed,
                        canManage: store.selectedRole == .stallOwner && selectedArchive.isUserCreated,
                        liveLocationEnabled: liveLocationEnabled,
                        routeVisible: visibleRouteArchiveID == selectedArchive.id,
                        onHistory: {
                            navigationArchiveID = nil
                            visibleRouteArchiveID = selectedArchive.id
                            focusCoordinate = nil
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                                isMapCardCollapsed = true
                            }
                            showToast("正在沿实际道路还原上次路线", binding: $toastMessage)
                        },
                        onNavigate: {
                            visibleRouteArchiveID = nil
                            navigationArchiveID = selectedArchive.id
                            liveLocationEnabled = true
                            locationManager.requestAndStartUpdating()
                            showToast("正在使用 Apple 地图规划步行路线", binding: $toastMessage)
                        },
                        onVisited: {
                            showToast("感谢补档，已记录你的到访", binding: $toastMessage)
                        },
                        onEdit: {
                            archiveToEdit = selectedArchive
                        },
                        onPrevious: {
                            selectAdjacentArchive(offset: -1)
                        },
                        onNext: {
                            selectAdjacentArchive(offset: 1)
                        },
                        onLive: {
                            liveLocationEnabled.toggle()
                            if liveLocationEnabled {
                                locationManager.requestAndStartUpdating()
                            } else {
                                locationManager.stopUpdating()
                            }
                        },
                        onOpen: {
                            pendingQuickOpenArchiveID = selectedArchive.id
                            openPendingArchiveWithLocation()
                        },
                        onClose: {
                            store.closeArchive(selectedArchive)
                            showToast("已收摊，街坊还能看到历史档案", binding: $toastMessage)
                        },
                        onDismiss: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                                isMapCardCollapsed = true
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .background(Color.tanPaper)
        .toastOverlay(toastMessage)
        .navigationTitle("市井地图")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSearch) {
            ArchiveSearchSheet { archive in
                selectedArchiveID = archive.id
                focusCoordinate = archive.currentLocation.coordinate
                visibleRouteArchiveID = nil
                isMapCardCollapsed = false
                showSearch = false
            }
            .environmentObject(store)
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $archiveToEdit) { archive in
            NavigationStack {
                AIArchiveBuilderView(editingArchive: archive)
                    .environmentObject(store)
            }
        }
        .sheet(isPresented: $showXilian) {
            XilianChatView(
                selectedArchive: selectedArchive,
                nearbyArchives: displayedArchives,
                onOpenArchive: { archive in
                    selectedArchiveID = archive.id
                    focusCoordinate = archive.currentLocation.coordinate
                    visibleRouteArchiveID = nil
                    navigationArchiveID = nil
                    isMapCardCollapsed = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .navigationDestination(for: UUID.self) { id in
            if let archive = store.archive(with: id) {
                ArchiveDetailView(archive: archive)
            }
        }
        .onReceive(locationManager.$currentCoordinate) { coordinate in
            guard let coordinate else { return }
            if !hasCenteredOnUser && selectedArchiveID == nil {
                focusCoordinate = coordinate
                hasCenteredOnUser = true
            }
            if let id = pendingQuickOpenArchiveID, let archive = store.archive(with: id) {
                store.openArchive(archive, at: coordinate)
                selectedArchiveID = archive.id
                pendingQuickOpenArchiveID = nil
                liveLocationEnabled = false
                isMapCardCollapsed = false
                locationManager.stopUpdating()
                showToast("已开摊，当前位置会显示在地图上", binding: $toastMessage)
            }
        }
        .onAppear {
            focusMapIfNeeded(store.mapFocusRequest)
            liveLocationEnabled = true
            locationManager.requestAndStartUpdating()
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                withAnimation(.easeInOut(duration: 0.2)) {
                    showMapHint = false
                }
            }
        }
        .onChange(of: store.mapFocusRequest) { _, request in
            focusMapIfNeeded(request)
        }
        .onChange(of: store.selectedRole) { _, role in
            selectedArchiveID = nil
            visibleRouteArchiveID = nil
            navigationArchiveID = nil
            isMapCardCollapsed = false
            store.selectedTab = .map
            if role == .visitor {
                liveLocationEnabled = true
                hasCenteredOnUser = false
                locationManager.requestAndStartUpdating()
            }
        }
    }

    private var topControls: some View {
        HStack {
            if store.selectedRole == .visitor {
                Button {
                    showSearch = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.tanPrimary)
                        Text("搜索小吃、手艺、摊位")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.tanInk.opacity(0.72))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 46)
                    .background(.white)
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .stroke(Color.tanLine)
                    }
                    .shadow(color: Color.tanInk.opacity(0.1), radius: 14, x: 0, y: 8)
                }
            }

            Spacer()

            if store.selectedRole == .stallOwner {
                Button {
                    if let archive = store.currentUserArchives.first {
                        archiveToEdit = archive
                    } else {
                        store.selectedTab = .build
                    }
                } label: {
                    Label(store.currentUserArchives.isEmpty ? "AI 建档" : "修改名片", systemImage: store.currentUserArchives.isEmpty ? "sparkles" : "pencil")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .background(Color.tanInk)
                        .clipShape(Capsule())
                        .shadow(color: Color.tanInk.opacity(0.18), radius: 12, x: 0, y: 8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    private func openPendingArchiveWithLocation() {
        guard let id = pendingQuickOpenArchiveID, let archive = store.archive(with: id) else {
            pendingQuickOpenArchiveID = nil
            return
        }

        if let coordinate = locationManager.currentCoordinate {
            store.openArchive(archive, at: coordinate)
            focusCoordinate = coordinate
            selectedArchiveID = archive.id
            pendingQuickOpenArchiveID = nil
            isMapCardCollapsed = false
            showToast("已开摊，当前位置会显示在地图上", binding: $toastMessage)
        } else {
            liveLocationEnabled = true
            locationManager.requestAndStartUpdating()
        }
    }

    private func focusMapIfNeeded(_ request: MapFocusRequest?) {
        guard let request, let archive = store.archive(with: request.archiveID) else {
            return
        }
        selectedArchiveID = archive.id
        focusCoordinate = archive.currentLocation.coordinate
        visibleRouteArchiveID = nil
        navigationArchiveID = nil
        liveLocationEnabled = false
        isMapCardCollapsed = false
        locationManager.stopUpdating()
    }

    private func selectAdjacentArchive(offset: Int) {
        guard !displayedArchives.isEmpty,
              let selectedArchiveID,
              let currentIndex = displayedArchives.firstIndex(where: { $0.id == selectedArchiveID }) else {
            return
        }
        let nextIndex = (currentIndex + offset + displayedArchives.count) % displayedArchives.count
        let archive = displayedArchives[nextIndex]
        withAnimation(.easeInOut(duration: 0.2)) {
            self.selectedArchiveID = archive.id
            focusCoordinate = archive.currentLocation.coordinate
            visibleRouteArchiveID = nil
            navigationArchiveID = nil
            isMapCardCollapsed = false
        }
    }
}

private struct MapHintCard: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.tanPrimary)
                .frame(width: 34, height: 34)
                .background(Color.mutedOrange.opacity(0.72))
                .clipShape(Circle())
            Text("点一点地图上的摊位，查看故事和路线")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.tanInk)
                .lineLimit(2)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Color.tanInk.opacity(0.55))
                    .frame(width: 28, height: 28)
                    .background(Color.tanPaper.opacity(0.9))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                .stroke(Color.tanLine)
        }
        .shadow(color: Color.tanInk.opacity(0.1), radius: 14, x: 0, y: 8)
    }
}

private struct QuickOpenStallButton: View {
    let archive: CityArchive
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: archive.status == .open ? "moon.zzz.fill" : "location.fill")
                    .font(.system(size: 22, weight: .black))
                VStack(alignment: .leading, spacing: 2) {
                    Text(archive.status == .open ? "一键收摊" : "一键出摊")
                        .font(.system(size: 22, weight: .black))
                    Text(archive.name)
                        .font(.system(size: 12, weight: .bold))
                        .lineLimit(1)
                }
                Spacer()
                Text(archive.status == .open ? "结束营业" : "实时上图")
                    .font(.system(size: 12, weight: .black))
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(archive.status == .open ? Color.tanInk : Color.tanPrimary)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous))
            .shadow(color: .black.opacity(0.22), radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }
}

private struct ArchiveMapCard: View {
    let archive: CityArchive
    @Binding var isCollapsed: Bool
    let canManage: Bool
    let liveLocationEnabled: Bool
    let routeVisible: Bool
    let onHistory: () -> Void
    let onNavigate: () -> Void
    let onVisited: () -> Void
    let onEdit: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onLive: () -> Void
    let onOpen: () -> Void
    let onClose: () -> Void
    let onDismiss: () -> Void
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: isCollapsed ? 8 : 14) {
            Capsule()
                .fill(Color.black.opacity(0.16))
                .frame(width: 38, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.bottom, isCollapsed ? 0 : 2)

            if isCollapsed {
                collapsedContent
            } else {
                expandedContent
            }
        }
        .padding(isCollapsed ? 14 : 18)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: isCollapsed ? TanRadius.medium : TanRadius.large, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: isCollapsed ? TanRadius.medium : TanRadius.large, style: .continuous)
                .stroke(Color.white.opacity(0.8), lineWidth: 1)
        }
        .shadow(color: Color.tanInk.opacity(isCollapsed ? 0.12 : 0.18), radius: isCollapsed ? 14 : 24, x: 0, y: isCollapsed ? 8 : 12)
        .offset(y: isCollapsed ? max(0, dragOffset * 0.25) : max(0, dragOffset))
        .simultaneousGesture(cardDragGesture)
        .simultaneousGesture(cardPagingGesture)
        .animation(.spring(response: 0.3, dampingFraction: 0.86), value: isCollapsed)
    }

    private var collapsedContent: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                isCollapsed = false
            }
        } label: {
            Text(archive.name)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.tanInk)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("展开 \(archive.name) 名片")
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                ArchiveAvatarView(archive: archive)

                VStack(alignment: .leading, spacing: 8) {
                    Text("摊户名片")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                    Text(archive.name)
                        .font(.system(size: 21, weight: .black))
                        .foregroundStyle(Color.tanInk)
                        .lineLimit(1)
                    Text("\(archive.ownerName) · \(archive.yearsActive) 年 · \(archive.priceOrService)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                    HStack {
                        TagPill(text: archive.category.title)
                        StatusBadge(status: archive.status)
                    }
                }
                Spacer()
                HStack(spacing: 8) {
                    NavigationLink(value: archive.id) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(Color.tanInk.opacity(0.7))
                            .frame(width: 38, height: 38)
                            .background(Color.tanPaper.opacity(0.92))
                            .clipShape(Circle())
                    }

                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Color.tanInk.opacity(0.68))
                            .frame(width: 38, height: 38)
                            .background(Color.tanPaper.opacity(0.92))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("关闭名片")
                }
            }

            Text(archive.summary)
                .font(.system(size: 14))
                .foregroundStyle(Color.tanInk.opacity(0.68))
                .lineSpacing(3)
                .lineLimit(3)

            HStack(spacing: 10) {
                NavigationLink(value: archive.id) {
                    Label("查看档案", systemImage: "doc.text.magnifyingglass")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.tanPrimary)

                if canManage {
                    Button(action: onEdit) {
                        Label("修改名片", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button(action: onVisited) {
                        Label("打卡", systemImage: "mappin.and.ellipse")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .font(.system(size: 14, weight: .bold))

            Button(action: onNavigate) {
                Label("Apple 地图步行导航", systemImage: "figure.walk.motion")
                    .font(.system(size: 14, weight: .black))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.heritageGreen)

            VStack(alignment: .leading, spacing: 8) {
                Label(routeVisible ? "活动范围与上次路线" : "活动范围", systemImage: "map.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.tanInk)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(archive.historicalStops) { stop in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(stop.title)
                                    .font(.system(size: 12, weight: .bold))
                                Text(stop.appearedAt)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(10)
                            .background(Color.tanPaper)
                            .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
                        }
                    }
                }
            }

            HStack(spacing: 10) {
                Button(action: onHistory) {
                    Label(routeVisible ? "路线已显示" : "上次路线", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.tanInk)

                if canManage {
                    Button(action: onLive) {
                        Label(liveLocationEnabled ? "定位中" : "获取定位", systemImage: "location.fill")
                    }
                    .buttonStyle(.bordered)

                    Button(action: archive.status == .open ? onClose : onOpen) {
                        Text(archive.status == .open ? "收摊" : "开摊")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.tanPrimary)
                }
            }
            .font(.system(size: 13, weight: .semibold))
        }
    }

    private var cardDragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                if value.translation.height > 46 {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                        isCollapsed = true
                    }
                } else if value.translation.height < -28 {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                        isCollapsed = false
                    }
                }
            }
    }

    private var cardPagingGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                guard !isCollapsed,
                      abs(value.translation.width) > abs(value.translation.height) * 1.35,
                      abs(value.translation.width) > 72 else {
                    return
                }
                if value.translation.width < 0 {
                    onNext()
                } else {
                    onPrevious()
                }
            }
    }
}

private struct ArchiveSearchSheet: View {
    @EnvironmentObject private var store: ArchiveStore
    @State private var query = ""
    @State private var category: ArchiveCategory?
    let onSelect: (CityArchive) -> Void

    private var results: [CityArchive] {
        store.searchArchives(query: query, category: category)
    }

    private let hotKeywords = ["小吃", "修补", "非遗", "消失预警", "玉林路"]

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("搜索档案")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                searchField
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    hotKeywordsView
                }
                categoryFilters
                resultsList
            }
            .padding(16)
        }
        .background(Color.tanPaper)
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.tanPrimary)
            ChineseFriendlyTextField(placeholder: "搜索糖画、补鞋、蜀绣、豆瓣酱...", text: $query)
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(.white)
        .clipShape(Capsule())
        .overlay {
            Capsule().stroke(Color.tanLine)
        }
        .shadow(color: Color.tanInk.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    private var hotKeywordsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("大家在找")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color.tanInk.opacity(0.62))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(hotKeywords, id: \.self) { keyword in
                        Button {
                            query = keyword
                        } label: {
                            TagPill(text: keyword)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryFilterButton(title: "全部", isSelected: category == nil) {
                    category = nil
                }
                ForEach(ArchiveCategory.allCases, id: \.self) { item in
                    CategoryFilterButton(title: item.title, isSelected: category == item) {
                        category = item
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.18), value: category)
    }

    private var resultsList: some View {
        Group {
            if results.isEmpty {
                EmptyStateView(text: "暂时没找到这个摊，换个关键词试试。", icon: "magnifyingglass")
            } else {
                ForEach(results) { archive in
                    ArchiveSearchResultRow(archive: archive) {
                        onSelect(archive)
                    }
                }
            }
        }
    }
}

private struct ArchiveSearchResultRow: View {
    let archive: CityArchive
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Circle()
                    .fill(archive.status.tint)
                    .frame(width: 14, height: 14)

                VStack(alignment: .leading, spacing: 4) {
                    Text(archive.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.tanInk)
                    Text("\(archive.category.title) · \(archive.priceOrService)")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()
                StatusBadge(status: archive.status)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                    .stroke(Color.tanLine)
            }
            .shadow(color: Color.tanInk.opacity(0.05), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

private struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? .white : Color.tanInk)
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(isSelected ? Color.tanPrimary : Color.tanPaper)
                .clipShape(Capsule())
                .overlay {
                    Capsule().stroke(isSelected ? Color.tanPrimary.opacity(0.55) : Color.tanLine)
                }
                .shadow(color: isSelected ? Color.tanPrimary.opacity(0.15) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

private struct ArchiveMapRepresentable: UIViewRepresentable {
    enum RouteKind {
        case history
        case navigation
    }

    let archives: [CityArchive]
    let selectedID: UUID?
    let routeArchiveID: UUID?
    let navigationArchiveID: UUID?
    let userCoordinate: CLLocationCoordinate2D?
    let focusCoordinate: CLLocationCoordinate2D?
    let showsUserLocation: Bool
    let onSelect: (CityArchive) -> Void
    let onRouteResult: (RouteKind, Bool) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic)
        mapView.showsCompass = false
        mapView.showsBuildings = true
        mapView.pointOfInterestFilter = .includingAll
        mapView.setRegion(MKCoordinateRegion(center: MockArchiveData.chengduCenter.coordinate, latitudinalMeters: 4_200, longitudinalMeters: 4_200), animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        mapView.showsUserLocation = false

        mapView.removeAnnotations(mapView.annotations.compactMap { annotation in
            annotation is CurrentUserAnnotation ? annotation : nil
        })
        if showsUserLocation, let userCoordinate {
            mapView.addAnnotation(CurrentUserAnnotation(coordinate: userCoordinate))
        }

        mapView.removeAnnotations(mapView.annotations.compactMap { annotation in
            guard let archiveAnnotation = annotation as? ArchiveAnnotation else { return nil }
            guard let latestArchive = archives.first(where: { $0.id == archiveAnnotation.archive.id }) else {
                return archiveAnnotation
            }
            return latestArchive == archiveAnnotation.archive ? nil : archiveAnnotation
        })

        let existingIDs = Set(mapView.annotations.compactMap { ($0 as? ArchiveAnnotation)?.archive.id })
        let newAnnotations = archives.filter { !existingIDs.contains($0.id) }.map(ArchiveAnnotation.init)
        mapView.addAnnotations(newAnnotations)

        mapView.removeAnnotations(mapView.annotations.compactMap { annotation in
            annotation is HistoryStopAnnotation ? annotation : nil
        })

        if let selected = archives.first(where: { $0.id == selectedID }) {
            let coordinates = selected.historicalStops.map { $0.coordinate.coordinate }
            if let residentCenter = coordinates.residentCenter ?? Optional(selected.currentLocation.coordinate) {
                context.coordinator.updateResidentCircle(on: mapView, center: residentCenter)
            }

            if navigationArchiveID == selected.id, let userCoordinate {
                context.coordinator.showWalkingRoute(
                    on: mapView,
                    key: "navigation-\(selected.id)-\(userCoordinate.latitude)-\(userCoordinate.longitude)",
                    waypoints: [userCoordinate, selected.currentLocation.coordinate],
                    fitsRoute: true
                )
            } else if routeArchiveID == selected.id, coordinates.count > 1 {
                let historyAnnotations = selected.historicalStops.enumerated().map { index, stop in
                    HistoryStopAnnotation(stop: stop, index: index + 1)
                }
                mapView.addAnnotations(historyAnnotations)
                let coordinateKey = coordinates.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
                context.coordinator.showWalkingRoute(
                    on: mapView,
                    key: "history-\(selected.id)-\(coordinateKey)",
                    waypoints: coordinates,
                    fitsRoute: true,
                    kind: .history,
                    fallbackWaypoints: MockArchiveData.roadHistoryRoute(for: selected)
                )
            } else {
                context.coordinator.clearWalkingRoutes(on: mapView)
            }
        } else {
            context.coordinator.clearResidentCircle(on: mapView)
            context.coordinator.clearWalkingRoutes(on: mapView)
        }

        if let focusCoordinate, navigationArchiveID == nil, routeArchiveID == nil {
            mapView.setRegion(MKCoordinateRegion(center: focusCoordinate, latitudinalMeters: 1_400, longitudinalMeters: 1_400), animated: true)
        }
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ArchiveMapRepresentable
        private var residentCircle: MKCircle?
        private var walkingOverlays: [MKPolyline] = []
        private var renderedRouteKey: String?
        private var routeTask: Task<Void, Never>?

        init(parent: ArchiveMapRepresentable) {
            self.parent = parent
        }

        func updateResidentCircle(on mapView: MKMapView, center: CLLocationCoordinate2D) {
            if let residentCircle {
                mapView.removeOverlay(residentCircle)
            }
            let circle = MKCircle(center: center, radius: 420)
            residentCircle = circle
            mapView.addOverlay(circle, level: .aboveRoads)
        }

        func clearResidentCircle(on mapView: MKMapView) {
            guard let residentCircle else { return }
            mapView.removeOverlay(residentCircle)
            self.residentCircle = nil
        }

        func clearWalkingRoutes(on mapView: MKMapView) {
            routeTask?.cancel()
            routeTask = nil
            if !walkingOverlays.isEmpty {
                mapView.removeOverlays(walkingOverlays)
            }
            walkingOverlays = []
            renderedRouteKey = nil
        }

        func showWalkingRoute(
            on mapView: MKMapView,
            key: String,
            waypoints: [CLLocationCoordinate2D],
            fitsRoute: Bool,
            kind: RouteKind = .navigation,
            fallbackWaypoints: [CLLocationCoordinate2D] = []
        ) {
            guard renderedRouteKey != key else { return }
            clearWalkingRoutes(on: mapView)
            renderedRouteKey = key

            let fallbackRoute: MKPolyline?
            if fallbackWaypoints.count > 1 {
                var coordinates = fallbackWaypoints
                let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
                fallbackRoute = polyline
                walkingOverlays = [polyline]
                mapView.addOverlay(polyline, level: .aboveLabels)
                if fitsRoute {
                    mapView.setVisibleMapRect(
                        polyline.boundingMapRect,
                        edgePadding: UIEdgeInsets(top: 120, left: 48, bottom: 280, right: 48),
                        animated: true
                    )
                }
            } else {
                fallbackRoute = nil
            }

            routeTask = Task { @MainActor in
                var routes: [MKPolyline] = []
                for index in 0..<(waypoints.count - 1) {
                    guard !Task.isCancelled else { return }
                    if let polyline = await roadPolyline(
                        from: waypoints[index],
                        to: waypoints[index + 1]
                    ) {
                        routes.append(polyline)
                    }
                }

                guard !Task.isCancelled, renderedRouteKey == key else { return }
                if routes.count != waypoints.count - 1 {
                    routes = fallbackRoute.map { [$0] } ?? []
                } else if let fallbackRoute {
                    mapView.removeOverlay(fallbackRoute)
                }
                walkingOverlays = routes
                if fallbackRoute == nil || routes.first !== fallbackRoute {
                    mapView.addOverlays(routes, level: .aboveLabels)
                }
                if fitsRoute, !routes.isEmpty {
                    let routeRect = routes.reduce(MKMapRect.null) { partialResult, route in
                        partialResult.union(route.boundingMapRect)
                    }
                    if !routeRect.isNull {
                        mapView.setVisibleMapRect(
                            routeRect,
                            edgePadding: UIEdgeInsets(top: 120, left: 48, bottom: 280, right: 48),
                            animated: true
                        )
                    }
                }
                parent.onRouteResult(kind, !routes.isEmpty)
            }
        }

        private func roadPolyline(
            from source: CLLocationCoordinate2D,
            to destination: CLLocationCoordinate2D
        ) async -> MKPolyline? {
            for transportType in [MKDirectionsTransportType.walking, .automobile] {
                guard !Task.isCancelled else { return nil }
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
                request.transportType = transportType
                request.requestsAlternateRoutes = false

                let directions = MKDirections(request: request)
                if let response = try? await directions.calculate(), let route = response.routes.first {
                    return route.polyline
                }
            }
            return nil
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is CurrentUserAnnotation || annotation is MKUserLocation {
                let identifier = "CurrentUserArrow"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.annotation = annotation
                view.image = Self.userLocationArrowImage
                view.backgroundColor = .clear
                view.layer.cornerRadius = 0
                view.layer.borderWidth = 0
                view.layer.shadowColor = UIColor.black.cgColor
                view.layer.shadowOpacity = 0.18
                view.layer.shadowRadius = 6
                view.layer.shadowOffset = CGSize(width: 0, height: 3)
                view.canShowCallout = false
                return view
            }

            if let annotation = annotation as? HistoryStopAnnotation {
                let identifier = "HistoryStop"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.annotation = annotation
                view.image = Self.historyStopImage(number: annotation.index)
                view.canShowCallout = true
                view.layer.shadowColor = UIColor.black.cgColor
                view.layer.shadowOpacity = 0.16
                view.layer.shadowRadius = 5
                view.layer.shadowOffset = CGSize(width: 0, height: 3)
                return view
            }

            guard let annotation = annotation as? ArchiveAnnotation else {
                return nil
            }

            let identifier = "ArchiveDot"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.annotation = annotation
            view.canShowCallout = false
            view.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
            view.layer.cornerRadius = 13
            view.layer.borderWidth = 3
            view.layer.borderColor = UIColor.white.cgColor
            view.backgroundColor = UIColor(annotation.archive.status.tint)
            return view
        }

        private static let userLocationArrowImage: UIImage = {
            let size = CGSize(width: 44, height: 44)
            return UIGraphicsImageRenderer(size: size).image { context in
                let bounds = CGRect(origin: .zero, size: size).insetBy(dx: 2, dy: 2)
                UIColor.white.setFill()
                context.cgContext.fillEllipse(in: bounds)

                UIColor(Color.tanPrimary).setFill()
                context.cgContext.fillEllipse(in: bounds.insetBy(dx: 4, dy: 4))

                let symbol = UIImage(
                    systemName: "location.north.fill",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .black)
                )?.withTintColor(.white, renderingMode: .alwaysOriginal)
                symbol?.draw(in: CGRect(x: 12, y: 9, width: 20, height: 25))
            }
        }()

        private static func historyStopImage(number: Int) -> UIImage {
            let size = CGSize(width: 36, height: 36)
            return UIGraphicsImageRenderer(size: size).image { context in
                let bounds = CGRect(origin: .zero, size: size).insetBy(dx: 2, dy: 2)
                UIColor.white.setFill()
                context.cgContext.fillEllipse(in: bounds)
                UIColor(Color.tanPrimary).setFill()
                context.cgContext.fillEllipse(in: bounds.insetBy(dx: 3, dy: 3))

                let text = "\(number)" as NSString
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .black),
                    .foregroundColor: UIColor.white
                ]
                let textSize = text.size(withAttributes: attributes)
                text.draw(
                    at: CGPoint(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2),
                    withAttributes: attributes
                )
            }
        }

        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            guard let annotation = annotation as? ArchiveAnnotation else {
                return
            }
            parent.onSelect(annotation.archive)
            mapView.deselectAnnotation(annotation, animated: false)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                if let circle = overlay as? MKCircle {
                    let renderer = MKCircleRenderer(circle: circle)
                    renderer.fillColor = UIColor(Color.tanPrimary.opacity(0.12))
                    renderer.strokeColor = UIColor(Color.tanPrimary.opacity(0.45))
                    renderer.lineWidth = 2
                    return renderer
                }
                return MKOverlayRenderer(overlay: overlay)
            }
            let renderer = MKPolylineRenderer(polyline: polyline)
            let isNavigation = renderedRouteKey?.hasPrefix("navigation-") == true
            renderer.strokeColor = UIColor(isNavigation ? Color.heritageGreen : Color.tanPrimary)
            renderer.lineWidth = isNavigation ? 7 : 6
            renderer.lineDashPattern = isNavigation ? nil : [10, 6]
            renderer.lineCap = .round
            renderer.lineJoin = .round
            return renderer
        }
    }
}

private extension Array where Element == CLLocationCoordinate2D {
    var residentCenter: CLLocationCoordinate2D? {
        guard !isEmpty else {
            return nil
        }
        let latitude = map(\.latitude).reduce(0, +) / Double(count)
        let longitude = map(\.longitude).reduce(0, +) / Double(count)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

private final class ArchiveAnnotation: NSObject, MKAnnotation {
    let archive: CityArchive
    var coordinate: CLLocationCoordinate2D { archive.currentLocation.coordinate }
    var title: String? { archive.name }

    init(archive: CityArchive) {
        self.archive = archive
    }
}

private final class CurrentUserAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

private final class HistoryStopAnnotation: NSObject, MKAnnotation {
    let stop: RouteStop
    let index: Int
    var coordinate: CLLocationCoordinate2D { stop.coordinate.coordinate }
    var title: String? { "第 \(index) 站 · \(stop.title)" }
    var subtitle: String? { stop.appearedAt }

    init(stop: RouteStop, index: Int) {
        self.stop = stop
        self.index = index
    }
}
