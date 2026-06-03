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
    @State private var showLocationPrompt = false
    @State private var pendingQuickOpenArchiveID: UUID?

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
                focusCoordinate: focusCoordinate,
                showsUserLocation: liveLocationEnabled
            ) { archive in
                selectedArchiveID = archive.id
                focusCoordinate = archive.currentLocation.coordinate
                liveLocationEnabled = false
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
                            showLocationPrompt = true
                        }
                    }
                    .padding(.horizontal, 34)
                    .padding(.bottom, selectedArchive == nil ? 72 : 0)
                    .transition(.scale.combined(with: .opacity))
                }

                if let selectedArchive {
                    ArchiveMapCard(
                        archive: selectedArchive,
                        canManage: store.selectedRole == .stallOwner && selectedArchive.isUserCreated,
                        liveLocationEnabled: liveLocationEnabled,
                        onHistory: {
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
                            let coordinate = locationManager.currentCoordinate ?? selectedArchive.currentLocation.coordinate
                            store.openArchive(selectedArchive, at: coordinate)
                            focusCoordinate = coordinate
                        },
                        onClose: {
                            store.closeArchive(selectedArchive)
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
        .alert("需要获取位置信息", isPresented: $showLocationPrompt) {
            Button("取消", role: .cancel) {
                pendingQuickOpenArchiveID = nil
            }
            Button("允许并出摊") {
                openPendingArchiveWithLocation()
            }
        } message: {
            Text("一键出摊会使用当前位置，把摊位实时显示在地图上，并记录到上次出摊路线。")
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
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.tanPrimary)
                        .clipShape(Circle())
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
                        .frame(height: 44)
                        .background(Color.tanInk)
                        .clipShape(Capsule())
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
        liveLocationEnabled = false
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
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.22), radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }
}

private struct ArchiveMapCard: View {
    let archive: CityArchive
    let canManage: Bool
    let liveLocationEnabled: Bool
    let onHistory: () -> Void
    let onLive: () -> Void
    let onOpen: () -> Void
    let onClose: () -> Void

    var body: some View {
        Surface {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(archive.status.tint.opacity(0.16))
                    Image(systemName: archive.category.icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(archive.status.tint)
                }
                .frame(width: 68, height: 68)

                VStack(alignment: .leading, spacing: 8) {
                    Text("摊户名片")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                    Text(archive.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.tanInk)
                    Text("\(archive.ownerName) · \(archive.yearsActive) 年 · \(archive.priceOrService)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                    HStack {
                        TagPill(text: archive.category.title)
                        StatusBadge(status: archive.status)
                    }
                }
                Spacer()
                NavigationLink(value: archive.id) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .frame(width: 34, height: 34)
                        .background(Color.tanPaper)
                        .clipShape(Circle())
                }
            }

            Text(archive.summary)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .lineLimit(3)

            VStack(alignment: .leading, spacing: 8) {
                Label("常驻区域与上次出摊路线", systemImage: "map.fill")
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
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                }
            }

            HStack(spacing: 10) {
                Button(action: onHistory) {
                    Label("上次路线", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                }
                .buttonStyle(.bordered)

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
            VStack(alignment: .leading, spacing: 12) {
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
                .foregroundStyle(.secondary)
            TextField("搜索糖画、补鞋、蜀绣、豆瓣酱...", text: $query)
                .textInputAutocapitalization(.never)
        }
        .padding(12)
        .background(Color.tanPaper)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
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
                .padding(.horizontal, 12)
                .frame(height: 32)
                .background(isSelected ? Color.tanPrimary : Color.white)
                .clipShape(Capsule())
        }
    }
}

private struct ArchiveMapRepresentable: UIViewRepresentable {
    let archives: [CityArchive]
    let selectedID: UUID?
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
            if coordinates.count > 1 {
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
