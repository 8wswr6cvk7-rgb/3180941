//
//  MapView.swift
//  3180941
//
//  Created by Codex on 2026/5/30.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject private var appModel: TanAppModel
    @StateObject private var locationManager = StallLocationManager()

    @State private var selectedStall: Stall?
    @State private var warningStall: Stall?
    @State private var detailStall: Stall?
    @State private var showSearchSheet = false
    @State private var focusCoordinate: CLLocationCoordinate2D?

    private var referenceCoordinate: CLLocationCoordinate2D {
        locationManager.currentCoordinate ?? appModel.registeredStall?.location ?? MockData.chengduCenter
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            StallMapRepresentable(
                stalls: appModel.stalls,
                center: MockData.chengduCenter,
                focusCoordinate: focusCoordinate,
                highlightedStallID: appModel.registeredStallID,
                showsUserLocation: appModel.isRegisteredStallOpen
            ) { stall in
                if stall.status == .gone {
                    warningStall = stall
                    selectedStall = nil
                } else {
                    selectedStall = appModel.makeSelectedStall(stall.id)
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 12) {
                HStack {
                    Spacer()

                    HStack(spacing: 10) {
                        Button {
                            showSearchSheet = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.tanPrimary)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
                        }

                        if appModel.hasRegisteredStall {
                            Button {
                                toggleRegisteredStall()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: appModel.isRegisteredStallOpen ? "pause.fill" : "storefront.fill")
                                        .font(.system(size: 15, weight: .bold))
                                    Text(appModel.isRegisteredStallOpen ? "收摊" : "一键开摊")
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .foregroundStyle(appModel.isRegisteredStallOpen ? Color.tanSecondary : .white)
                                .padding(.horizontal, 14)
                                .frame(height: 44)
                                .background(appModel.isRegisteredStallOpen ? Color.white : Color.tanSecondary)
                                .clipShape(Capsule())
                                    .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                if let selectedStall {
                    Button {
                        detailStall = selectedStall
                    } label: {
                        StallSummaryCard(
                            stall: selectedStall,
                            distanceText: appModel.distanceText(from: referenceCoordinate, to: selectedStall.location)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                }

                SectionCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("附近\(appModel.activeNearbyCount(center: referenceCoordinate))个摊位正在营业")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.tanSecondary)
                            Text(appModel.isRegisteredStallOpen ? "你的摊位位置正在随定位更新" : "从天府广场出发，步行就能遇见成都的烟火气")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "flame.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.tanPrimary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .background(Color.tanBackground.ignoresSafeArea())
        .navigationTitle("地图")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $warningStall) { stall in
            DisappearWarningView(
                stall: stall,
                inactiveDays: appModel.inactiveDays(for: stall),
                onStillHere: {
                    appModel.reportStillHere(for: stall)
                },
                onConfirmGone: {
                    appModel.confirmGone(for: stall)
                }
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
        .navigationDestination(item: $detailStall) { stall in
            StallDetailView(stall: stall)
        }
        .sheet(isPresented: $showSearchSheet) {
            MapSearchView { stall in
                handleSelectedStall(stall)
            }
            .environmentObject(appModel)
            .presentationDetents([.medium, .large])
        }
        .onReceive(locationManager.$currentCoordinate) { coordinate in
            guard let coordinate, appModel.isRegisteredStallOpen else {
                return
            }

            appModel.updateRegisteredStallLocation(coordinate)
            focusCoordinate = coordinate

            if selectedStall?.id == appModel.registeredStallID {
                selectedStall = appModel.registeredStall
            }
        }
    }

    private func toggleRegisteredStall() {
        if appModel.isRegisteredStallOpen {
            appModel.closeRegisteredStall()
            locationManager.stopUpdating()
            selectedStall = appModel.registeredStall
            focusCoordinate = appModel.registeredStall?.location
        } else {
            let coordinate = locationManager.currentCoordinate ?? MockData.chengduCenter
            appModel.openRegisteredStall(at: coordinate)
            locationManager.requestAndStartUpdating()
            selectedStall = appModel.registeredStall
            focusCoordinate = coordinate
        }
    }

    private func handleSelectedStall(_ stall: Stall) {
        focusCoordinate = stall.location

        if stall.status == .gone {
            warningStall = stall
            selectedStall = nil
        } else {
            selectedStall = appModel.makeSelectedStall(stall.id)
        }
    }
}

private struct StallSummaryCard: View {
    let stall: Stall
    let distanceText: String

    var body: some View {
        SectionCard {
            HStack(alignment: .top, spacing: 14) {
                Circle()
                    .fill(stall.status.tintColor)
                    .frame(width: 14, height: 14)
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: 8) {
                    Text(stall.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.tanSecondary)

                    HStack(spacing: 8) {
                        StatusBadge(status: stall.status)
                        Text(distanceText)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct StallMapRepresentable: UIViewRepresentable {
    let stalls: [Stall]
    let center: CLLocationCoordinate2D
    let focusCoordinate: CLLocationCoordinate2D?
    let highlightedStallID: UUID?
    let showsUserLocation: Bool
    let onSelect: (Stall) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsUserLocation = showsUserLocation

        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
        )
        mapView.setRegion(region, animated: false)
        mapView.addAnnotations(stalls.map { StallAnnotation(stall: $0, highlightedID: highlightedStallID) })
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let existing = uiView.annotations.compactMap { $0 as? StallAnnotation }
        uiView.removeAnnotations(existing)
        uiView.addAnnotations(stalls.map { StallAnnotation(stall: $0, highlightedID: highlightedStallID) })
        uiView.showsUserLocation = showsUserLocation

        if let focusCoordinate {
            let region = MKCoordinateRegion(
                center: focusCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.018, longitudeDelta: 0.018)
            )
            uiView.setRegion(region, animated: true)
        }
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        let onSelect: (Stall) -> Void

        init(onSelect: @escaping (Stall) -> Void) {
            self.onSelect = onSelect
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let stallAnnotation = annotation as? StallAnnotation else {
                return nil
            }

            let identifier = "stall-dot"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.annotation = stallAnnotation
            let isHighlighted = stallAnnotation.stall.id == stallAnnotation.highlightedID
            let size: CGFloat = isHighlighted ? 28 : 22
            view.frame = CGRect(x: 0, y: 0, width: size, height: size)
            view.layer.cornerRadius = size / 2
            view.layer.borderWidth = 3
            view.layer.borderColor = UIColor.white.cgColor
            view.backgroundColor = stallAnnotation.stall.status.mapUIColor
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let stall = (view.annotation as? StallAnnotation)?.stall else {
                return
            }

            onSelect(stall)
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
}

private final class StallAnnotation: NSObject, MKAnnotation {
    let stall: Stall
    let highlightedID: UUID?

    var coordinate: CLLocationCoordinate2D {
        stall.location
    }

    init(stall: Stall, highlightedID: UUID? = nil) {
        self.stall = stall
        self.highlightedID = highlightedID
    }
}

private struct MapSearchView: View {
    @EnvironmentObject private var appModel: TanAppModel
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""

    let onSelect: (Stall) -> Void

    private var results: [Stall] {
        appModel.searchStalls(query: query)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    searchBar

                    if results.isEmpty {
                        SectionCard {
                            Text("没有搜到相关摊位，试试摊位名、摊主、品类或价格。")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ForEach(results) { stall in
                            Button {
                                onSelect(stall)
                                dismiss()
                            } label: {
                                SearchResultRow(stall: stall)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.tanBackground.ignoresSafeArea())
            .navigationTitle("搜索摊位")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("搜索假数据里的摊位、摊主、品类、故事", text: $query)
                .font(.system(size: 15))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct SearchResultRow: View {
    let stall: Stall

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(stall.status.tintColor.opacity(0.18))
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: "storefront.fill")
                        .foregroundStyle(stall.status.tintColor)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(stall.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.tanSecondary)
                Text("\(stall.ownerName) · \(stall.category) · \(stall.price)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusBadge(status: stall.status)
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MapView()
                .environmentObject(TanAppModel())
        }
    }
}
