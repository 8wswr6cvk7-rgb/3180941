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

    private var selectedArchive: CityArchive? {
        guard let selectedArchiveID else {
            return nil
        }
        return store.archive(with: selectedArchiveID)
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
                archives: store.archives,
                selectedID: selectedArchiveID,
                routeArchiveID: visibleRouteArchiveID,
                focusCoordinate: focusCoordinate,
                showsUserLocation: liveLocationEnabled
            ) { archive in
                selectedArchiveID = archive.id
                focusCoordinate = archive.currentLocation.coordinate
                liveLocationEnabled = false
                visibleRouteArchiveID = nil
                isMapCardCollapsed = false
            }
            .ignoresSafeArea()

            VStack(spacing: 12) {
                topControls
                Spacer()

                if store.selectedRole == .stallOwner, let quickOpenArchive {
                    QuickOpenStallButton(archive: quickOpenArchive) {
                        if quickOpenArchive.status == .open {
                            store.closeArchive(quickOpenArchive)
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
                            visibleRouteArchiveID = selectedArchive.id
                            focusCoordinate = selectedArchive.currentLocation.coordinate
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
                        },
                        onDismiss: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedArchiveID = nil
                                visibleRouteArchiveID = nil
                                isMapCardCollapsed = false
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
        .navigationDestination(for: UUID.self) { id in
            if let archive = store.archive(with: id) {
                ArchiveDetailView(archive: archive)
            }
        }
        .onReceive(locationManager.$currentCoordinate) { coordinate in
            guard let coordinate else { return }
            focusCoordinate = coordinate
            if let id = pendingQuickOpenArchiveID, let archive = store.archive(with: id) {
                store.openArchive(archive, at: coordinate)
                selectedArchiveID = archive.id
                pendingQuickOpenArchiveID = nil
                liveLocationEnabled = false
                locationManager.stopUpdating()
            }
        }
        .onAppear {
            focusMapIfNeeded(store.mapFocusRequest)
        }
        .onChange(of: store.mapFocusRequest) { _, request in
            focusMapIfNeeded(request)
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
                    store.selectedTab = .build
                } label: {
                    Label("AI 建档", systemImage: "sparkles")
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
        liveLocationEnabled = false
        isMapCardCollapsed = false
        locationManager.stopUpdating()
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
                ZStack {
                    RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                        .fill(archive.status.tint.opacity(0.14))
                    Image(systemName: archive.category.icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(archive.status.tint)
                }
                .frame(width: 66, height: 66)

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
}

private struct ArchiveSearchSheet: View {
    @EnvironmentObject private var store: ArchiveStore
    @State private var query = ""
    @State private var category: ArchiveCategory?
    let onSelect: (CityArchive) -> Void

    private var results: [CityArchive] {
        store.searchArchives(query: query, category: category)
    }

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
        ForEach(results) { archive in
            ArchiveSearchResultRow(archive: archive) {
                onSelect(archive)
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
    let archives: [CityArchive]
    let selectedID: UUID?
    let routeArchiveID: UUID?
    let focusCoordinate: CLLocationCoordinate2D?
    let showsUserLocation: Bool
    let onSelect: (CityArchive) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
            mapView.setRegion(MKCoordinateRegion(center: MockArchiveData.chengduCenter.coordinate, latitudinalMeters: 4_200, longitudinalMeters: 4_200), animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        mapView.showsUserLocation = showsUserLocation

        let existingIDs = Set(mapView.annotations.compactMap { ($0 as? ArchiveAnnotation)?.archive.id })
        let currentIDs = Set(archives.map(\.id))
        mapView.removeAnnotations(mapView.annotations.compactMap { annotation in
            guard let archiveAnnotation = annotation as? ArchiveAnnotation else { return nil }
            return currentIDs.contains(archiveAnnotation.archive.id) ? nil : archiveAnnotation
        })

        let newAnnotations = archives.filter { !existingIDs.contains($0.id) }.map(ArchiveAnnotation.init)
        mapView.addAnnotations(newAnnotations)

        if let selected = archives.first(where: { $0.id == selectedID }) {
            let overlays = mapView.overlays
            mapView.removeOverlays(overlays)
            let coordinates = selected.historicalStops.map { $0.coordinate.coordinate }
            if let residentCenter = coordinates.residentCenter ?? Optional(selected.currentLocation.coordinate) {
                mapView.addOverlay(MKCircle(center: residentCenter, radius: 420))
            }
            if coordinates.count > 1 && routeArchiveID == selected.id {
                mapView.addOverlay(MKPolyline(coordinates: coordinates, count: coordinates.count))
            }
        } else if !mapView.overlays.isEmpty {
            mapView.removeOverlays(mapView.overlays)
        }

        if let focusCoordinate {
            mapView.setRegion(MKCoordinateRegion(center: focusCoordinate, latitudinalMeters: 1_400, longitudinalMeters: 1_400), animated: true)
        }
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ArchiveMapRepresentable

        init(parent: ArchiveMapRepresentable) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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

        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            guard let annotation = annotation as? ArchiveAnnotation else {
                return
            }
            parent.onSelect(annotation.archive)
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
            renderer.strokeColor = UIColor(Color.tanPrimary)
            renderer.lineWidth = 4
            renderer.lineDashPattern = [8, 8]
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
