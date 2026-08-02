//
//  ArchiveDetailView.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI
import UIKit
import AVKit

enum MetricIconOption: String, CaseIterable, Identifiable {
    case friendly
    case tools
    case family
    case camera
    case star

    var id: String { rawValue }

    var title: String {
        switch self {
        case .friendly:
            return "入门友好"
        case .tools:
            return "工具与难度"
        case .family:
            return "亲子与年龄"
        case .camera:
            return "拍照记录"
        case .star:
            return "综合评价"
        }
    }

    var symbol: String {
        switch self {
        case .friendly:
            return "hand.thumbsup.fill"
        case .tools:
            return "hammer.fill"
        case .family:
            return "figure.2.and.child.holdinghands"
        case .camera:
            return "camera.fill"
        case .star:
            return "star.fill"
        }
    }

    static func option(for symbol: String) -> MetricIconOption? {
        allCases.first { $0.symbol == symbol }
    }
}

private struct DetailBookingDay: Identifiable, Codable, Hashable {
    var id = UUID()
    var weekday: String
    var date: String
}

private struct DetailBookingSlot: Identifiable, Codable, Hashable {
    var id = UUID()
    var time: String
    var remaining: String
    var teacher: String
}

private struct DetailMetric: Identifiable, Codable, Hashable {
    var id = UUID()
    var icon: String
    var title: String
    var value: String
    var level: Double
}

private struct ArchiveDetailContent: Codable, Hashable {
    var introduction: String
    var history: String
    var region: String
    var handmadeValue: String
    var lineage: String
    var representativeWork: String
    var videoTitle: String
    var videoDuration: String
    var certificationLevel: String
    var verificationStatus: String
    var certificationNote: String
    var experiences: [HeritageExperience]
    var products: [HeritageProduct]
    var bookingDays: [DetailBookingDay]
    var bookingSlots: [DetailBookingSlot]
    var metrics: [DetailMetric]
    var cultureFacts: [CultureFact]
    var reviewTags: [String]

    static func defaults(for archive: CityArchive) -> ArchiveDetailContent {
        let introduction: String
        let history: String
        let representativeWork: String
        let certificationLevel: String
        let experiences: [HeritageExperience]

        switch archive.category {
        case .heritageCraft:
            introduction = "这是一门把材料、地方审美与手上经验结合起来的传统技艺。作品不只讲究好看，更记录着成都街巷里的生活方式和代代相传的做法。"
            history = "由本地作坊与家庭传承延续，技法随庙会、集市和社区生活传播。"
            representativeWork = "代表纹样作品"
            certificationLevel = "市级非遗\n档案示例"
            experiences = [
                HeritageExperience(title: "基础手作体验", duration: "60 分钟", price: "68 元/人", audience: "8 岁以上", takeaway: "作品可带走"),
                HeritageExperience(title: "匠人深度小班", duration: "120 分钟", price: "168 元/人", audience: "成人/亲子", takeaway: "含材料与讲解")
            ]
        case .oldTrade:
            introduction = "老行当解决的是社区里最具体的生活难题。修、补、磨、配看似普通，却依赖多年形成的手感，也保存着人与街坊之间的信任。"
            history = "伴随老社区形成，为街坊提供长期、低成本的修补服务。"
            representativeWork = "经典修补案例"
            certificationLevel = "老行当\n保护档案"
            experiences = [
                HeritageExperience(title: "修补工具认识", duration: "40 分钟", price: "39 元/人", audience: "亲子友好", takeaway: "带走练习样片"),
                HeritageExperience(title: "旧物修复体验", duration: "90 分钟", price: "98 元/人", audience: "12 岁以上", takeaway: "修好旧物可带走")
            ]
        case .snack:
            introduction = "成都小吃的味道来自火候、手法与时令。看似简单的一份街边吃食，背后往往有一套只靠口传心授留下来的工序。"
            history = "从成都街头食俗发展而来，配方与手法多由家人、师傅口授。"
            representativeWork = "招牌手工小吃"
            certificationLevel = "成都市井\n活态档案"
            experiences = [
                HeritageExperience(title: "招牌小吃制作", duration: "50 分钟", price: "58 元/人", audience: "游客/亲子", takeaway: "现做现吃"),
                HeritageExperience(title: "成都味道讲解", duration: "30 分钟", price: "29 元/人", audience: "全年龄", takeaway: "含一份品尝")
            ]
        default:
            introduction = "这份档案记录了一种仍在街头发生的生活技艺。它可能没有标准展柜，却有稳定的顾客、熟悉的路线和值得留下来的社区故事。"
            history = "源自社区日常需要，在长期流动与固定经营中形成自己的做法。"
            representativeWork = archive.category == .produce ? "当季精选" : "社区代表作品"
            certificationLevel = archive.category == .cultureExperience ? "传统文化\n体验点" : "成都市井\n活态档案"
            experiences = [
                HeritageExperience(title: "街巷文化体验", duration: "60 分钟", price: "49 元/人", audience: "游客/亲子", takeaway: "完成品可带走"),
                HeritageExperience(title: "档案故事小班", duration: "45 分钟", price: "免费预约", audience: "全年龄", takeaway: "含匠人讲解")
            ]
        }

        return ArchiveDetailContent(
            introduction: introduction,
            history: history,
            region: "成都的慢生活、茶馆文化和街坊关系，让这门手艺更重视实用、亲切与面对面的讲解。",
            handmadeValue: "每一步都依赖经验判断，无法完全由流水线替代。",
            lineage: archive.yearsActive >= 20 ? "家传与老师傅口授" : "本地师傅带教",
            representativeWork: representativeWork,
            videoTitle: "听匠人亲口讲这门手艺",
            videoDuration: "短视频访谈 · 2 分 18 秒",
            certificationLevel: certificationLevel,
            verificationStatus: "社区核验中",
            certificationNote: "认证证书、口述史和代表作品可继续由摊主或社区补档者补充。",
            experiences: experiences,
            products: [
                HeritageProduct(title: representativeWork, price: archive.priceOrService, badge: "手工制作", cycle: "现货少量"),
                HeritageProduct(title: "街巷纪念小件", price: "39 元起", badge: "限量", cycle: "每周补货"),
                HeritageProduct(title: "专属定制作品", price: "168 元起", badge: "可定制", cycle: "7-15 天")
            ],
            bookingDays: [
                DetailBookingDay(weekday: "今天", date: "11"),
                DetailBookingDay(weekday: "周五", date: "12"),
                DetailBookingDay(weekday: "周六", date: "13"),
                DetailBookingDay(weekday: "周日", date: "14"),
                DetailBookingDay(weekday: "周一", date: "15")
            ],
            bookingSlots: [
                DetailBookingSlot(time: "10:00", remaining: "余 4 位", teacher: "匠人亲授"),
                DetailBookingSlot(time: "14:30", remaining: "余 2 位", teacher: "助教带领")
            ],
            metrics: [
                DetailMetric(icon: "hand.thumbsup.fill", title: "入门友好度", value: "很友好", level: 0.9),
                DetailMetric(icon: "hammer.fill", title: "完成难度", value: "适中", level: 0.58),
                DetailMetric(icon: "figure.2.and.child.holdinghands", title: "适合年龄", value: "8 岁以上", level: 0.78),
                DetailMetric(icon: "camera.fill", title: "拍照出片度", value: "很出片", level: 0.94)
            ],
            cultureFacts: [
                CultureFact(symbol: "纹", title: "纹样寓意", detail: "常见纹样寄托平安、团圆和丰收，也会根据节气更换。"),
                CultureFact(symbol: "材", title: "材料来源", detail: "优先使用本地可得材料，材料状态会直接影响成品手感。"),
                CultureFact(symbol: "节", title: "节日习俗", detail: "春节、端午和中秋前后往往有特别作品，也是出摊最热闹的时候。")
            ],
            reviewTags: ["体验感强", "讲解专业", "作品有质感", "适合亲子", "情侣约会", "游客友好"]
        )
    }
}

private enum ArchiveDetailContentStore {
    private static let keyPrefix = "tan.archive.detail."

    static func load(for archive: CityArchive) -> ArchiveDetailContent {
        guard let data = UserDefaults.standard.data(forKey: keyPrefix + archive.id.uuidString),
              let content = try? JSONDecoder().decode(ArchiveDetailContent.self, from: data) else {
            return .defaults(for: archive)
        }
        return content
    }

    static func save(_ content: ArchiveDetailContent, for archive: CityArchive) {
        guard let data = try? JSONEncoder().encode(content) else { return }
        UserDefaults.standard.set(data, forKey: keyPrefix + archive.id.uuidString)
    }

    static func clearAll() {
        UserDefaults.standard.dictionaryRepresentation().keys
            .filter { $0.hasPrefix(keyPrefix) }
            .forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
}

func clearArchiveDetailContentCache() {
    ArchiveDetailContentStore.clearAll()
}

private enum CommunityDeletionTarget {
    case photo(PhotoEntry)
    case comment(CommentEntry)
    case status(StallStatusConfirmation)

    var title: String {
        switch self {
        case .photo:
            return "删除这张档案影像？"
        case .comment:
            return "删除这条社区补档？"
        case .status:
            return "删除这条状态线索？"
        }
    }

    var actionTitle: String {
        switch self {
        case .photo:
            return "删除影像"
        case .comment:
            return "删除补档"
        case .status:
            return "删除线索"
        }
    }

    var message: String {
        switch self {
        case .photo:
            return "影像及其本地文件将被清理，删除后无法恢复。"
        case .comment:
            return "补档正文和所附影像将被清理，删除后无法恢复。"
        case .status:
            return "状态线索和所附现场影像将被清理，删除后无法恢复。"
        }
    }
}

struct ArchiveDetailView: View {
    @EnvironmentObject private var store: ArchiveStore
    let archive: CityArchive
    let initialSection: ArchiveDetailSection

    private static let commentDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter
    }()

    @State private var commentText = ""
    @State private var showEditor = false
    @State private var contributionImages: [PendingImage] = []
    @State private var showStatusConfirmation = false
    @State private var isPublishingContribution = false
    @State private var pendingDeletion: CommunityDeletionTarget?
    @State private var toastMessage: String?
    @State private var selectedBookingDay = 0
    @State private var detailContent: ArchiveDetailContent
    @State private var selectedArchivePhoto: PhotoEntry?

    init(archive: CityArchive, initialSection: ArchiveDetailSection = .top) {
        self.archive = archive
        self.initialSection = initialSection
        _detailContent = State(initialValue: ArchiveDetailContentStore.load(for: archive))
    }

    private var latestArchive: CityArchive {
        store.archive(with: archive.id) ?? archive
    }

    private var canUploadPhoto: Bool {
        store.selectedRole == .visitor
    }

    private var isOwnArchive: Bool {
        store.selectedRole == .stallOwner && latestArchive.isUserCreated
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    hero
                    story
                    XilianHintCard(archive: latestArchive)
                    heritageOverview
                    artisanStory
                    if FeatureFlags.commerceFeaturesEnabled {
                        experienceProjects
                        productShowcase
                        reservationCalendar
                    }
                    certificationAndLineage
                    activityRange
                    process
                    craftMetrics
                    cultureKnowledge
                    reviewHighlights
                    photoWall
                        .id("photos")
                    comments
                        .id(ArchiveDetailSection.community)
                        .accessibilityIdentifier("archive.community")
                }
                .padding(16)
            }
            .task {
                guard initialSection == .community else { return }
                await Task.yield()
                proxy.scrollTo(ArchiveDetailSection.community, anchor: .top)
            }
        }
        // The detail screen is hosted inside the app's TabView. Reserve a little
        // extra scrollable space above its bottom safe area so the final status
        // card never sits underneath the tab bar.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear
                .frame(height: 24)
                .allowsHitTesting(false)
        }
        .background(Color.tanPaper.ignoresSafeArea())
        .toastOverlay(toastMessage)
        .navigationTitle(latestArchive.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if store.selectedRole == .stallOwner && latestArchive.isUserCreated {
                        Button {
                            showEditor = true
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundStyle(Color.tanPrimary)
                        }
                        .accessibilityLabel("编辑档案")
                    }

                    if store.selectedRole == .visitor {
                        Button {
                            let wasFavorite = store.favoriteIDs.contains(latestArchive.id)
                            store.toggleFavorite(latestArchive)
                            showToast(
                                wasFavorite ? "已移出守护清单" : "已加入守护清单",
                                binding: $toastMessage
                            )
                        } label: {
                            Image(systemName: store.favoriteIDs.contains(latestArchive.id) ? "heart.fill" : "heart")
                                .foregroundStyle(Color.tanPrimary)
                        }
                        .accessibilityLabel(
                            store.favoriteIDs.contains(latestArchive.id)
                                ? "移出守护清单"
                                : "加入守护清单"
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showEditor, onDismiss: {
            detailContent = ArchiveDetailContentStore.load(for: latestArchive)
        }) {
            NavigationStack {
                ArchiveManualEditView(archive: latestArchive, detailContent: detailContent)
                    .environmentObject(store)
            }
        }
        .sheet(isPresented: $showStatusConfirmation) {
            StallStatusConfirmationSheet(archive: latestArchive)
                .environmentObject(store)
        }
        .fullScreenCover(item: $selectedArchivePhoto) { photo in
            ArchiveImageGallery(
                photos: latestArchive.photos,
                initialPhotoID: photo.id
            )
            .environmentObject(store)
        }
        .confirmationDialog(
            pendingDeletion?.title ?? "确认删除？",
            isPresented: Binding(
                get: { pendingDeletion != nil },
                set: { if !$0 { pendingDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            if let pendingDeletion {
                Button(pendingDeletion.actionTitle, role: .destructive) {
                    performDeletion(pendingDeletion)
                }
            }
            Button("取消", role: .cancel) {
                pendingDeletion = nil
            }
        } message: {
            Text(pendingDeletion?.message ?? "删除后无法恢复。")
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            ArchiveCoverView(archive: latestArchive, usesThumbnail: false)
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous)
                    .stroke(Color.white.opacity(0.75))
            }
            .shadow(color: Color.tanInk.opacity(0.08), radius: 16, x: 0, y: 9)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(latestArchive.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.tanInk)
                    Text("\(latestArchive.ownerName) · \(latestArchive.category.title) · \(latestArchive.yearsActive) 年")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                StatusBadge(status: latestArchive.presentationStatus)
            }

            FlowTags(tags: latestArchive.tags)
        }
    }

    private var story: some View {
        Surface {
            Text("档案故事")
                .font(.system(size: 18, weight: .bold))
            Text(latestArchive.summary)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .lineSpacing(6)

            HStack {
                Spacer()
                Button {
                    store.navigateToArchiveOnMap(latestArchive)
                } label: {
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(Color.tanPrimary)
                        .clipShape(Circle())
                        .shadow(color: Color.tanPrimary.opacity(0.24), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("在地图上查看档案位置")
            }
        }
    }

    private var heritageOverview: some View {
        Surface {
            HStack(spacing: 12) {
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Color.heritageGreen)
                    .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text("技艺介绍")
                        .font(.system(size: 19, weight: .black))
                        .foregroundStyle(Color.tanInk)
                    Text("从来处、地域和做法读懂这门手艺")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Text(detailContent.introduction)
                .font(.system(size: 15))
                .foregroundStyle(Color.tanInk.opacity(0.74))
                .lineSpacing(6)

            VStack(spacing: 10) {
                ArchiveKnowledgeRow(icon: "clock.arrow.circlepath", title: "历史来源", text: detailContent.history)
                ArchiveKnowledgeRow(icon: "mappin.and.ellipse", title: "地域特色", text: detailContent.region)
                ArchiveKnowledgeRow(icon: "hand.raised.fingers.spread.fill", title: "手工价值", text: detailContent.handmadeValue)
            }
        }
    }

    private var artisanStory: some View {
        Surface {
            HStack(alignment: .top, spacing: 14) {
                ArchiveAvatarView(archive: latestArchive, size: 72)
                VStack(alignment: .leading, spacing: 6) {
                    Text("匠人故事")
                        .font(.system(size: 19, weight: .black))
                        .foregroundStyle(Color.tanInk)
                    Text(latestArchive.ownerName)
                        .font(.system(size: 21, weight: .bold))
                    Text("从业 \(latestArchive.yearsActive) 年 · \(detailContent.lineage)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            HStack(spacing: 8) {
                HeritageFactPill(icon: "person.2.fill", text: detailContent.lineage)
                HeritageFactPill(icon: "star.fill", text: detailContent.representativeWork)
            }

            HStack(spacing: 12) {
                Image(systemName: "waveform")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.tanPrimary)
                    .frame(width: 42, height: 42)
                    .background(.white)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text("口述资料待补充")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.tanInk)
                    Text("可继续由摊主或社区补档者完善人物讲述")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(12)
            .background(Color.mutedOrange.opacity(0.38))
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
            .accessibilityElement(children: .combine)
        }
    }

    private var experienceProjects: some View {
        Surface {
            SectionTitle(icon: "hands.and.sparkles.fill", title: "到店体验", subtitle: "跟着老师傅做一件能带走的作品")

            ForEach(detailContent.experiences) { experience in
                HeritageExperienceCard(experience: experience)
            }
        }
    }

    private var productShowcase: some View {
        Surface {
            SectionTitle(icon: "bag.fill", title: "作品与商品橱窗", subtitle: "手工制作、限量供应，也支持提前定制")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(detailContent.products) { product in
                        HeritageProductCard(product: product, category: latestArchive.category)
                    }
                }
            }
        }
    }

    private var certificationAndLineage: some View {
        Surface {
            SectionTitle(icon: "checkmark.seal.fill", title: "传承谱系与认证", subtitle: "认证信息与师承线索共同构成可信档案")

            HStack(spacing: 12) {
                VStack(spacing: 7) {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.warningRed)
                    Text(detailContent.certificationLevel)
                        .font(.system(size: 12, weight: .black))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.tanInk)
                }
                .frame(width: 94, height: 92)
                .background(Color.warningRed.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    LineageRow(title: "传承人", value: latestArchive.ownerName)
                    LineageRow(title: "师承关系", value: detailContent.lineage)
                    LineageRow(title: "档案状态", value: detailContent.verificationStatus)
                }
                Spacer()
            }

            Text(detailContent.certificationNote)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
    }

    private var activityRange: some View {
        Surface {
            HStack {
                Label("常驻活动范围", systemImage: "map.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.tanInk)
                Spacer()
                Button {
                    store.navigateToArchiveOnMap(latestArchive)
                } label: {
                    Text("在地图看")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.tanPrimary)
            }

            Text("这些地点来自档案里的常驻点、周末点和节庆流动点。")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineSpacing(3)

            if latestArchive.historicalStops.isEmpty {
                EmptyStateView(text: "还没有活动范围记录，等待摊主开摊补充。")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(latestArchive.historicalStops) { stop in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(stop.title)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color.tanInk)
                                Text(stop.appearedAt)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .frame(minWidth: 118, alignment: .leading)
                            .background(Color.tanPaper)
                            .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
                        }
                    }
                }
            }
        }
    }

    private var process: some View {
        Surface {
            SectionTitle(icon: "point.topleft.down.curvedto.point.bottomright.up", title: "制作过程时间轴", subtitle: "慢工出细活，每一步都有它的理由")
            ForEach(Array(latestArchive.craftProcess.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 4) {
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.tanPrimary)
                            .clipShape(Circle())
                        if index < latestArchive.craftProcess.count - 1 {
                            Rectangle()
                                .fill(Color.tanLine)
                                .frame(width: 2, height: 24)
                        }
                    }
                    Text(step)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.tanInk.opacity(0.76))
                        .padding(.top, 4)
                    Spacer()
                }
            }
        }
    }

    private var reservationCalendar: some View {
        Surface {
            SectionTitle(icon: "calendar.badge.clock", title: "预约体验日历", subtitle: "选择适合的场次，现场有老师带教")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(detailContent.bookingDays.enumerated()), id: \.element.id) { index, day in
                        Button {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                selectedBookingDay = index
                            }
                        } label: {
                            VStack(spacing: 5) {
                                Text(day.weekday)
                                    .font(.system(size: 11, weight: .semibold))
                                Text(day.date)
                                    .font(.system(size: 16, weight: .black))
                            }
                            .foregroundStyle(selectedBookingDay == index ? .white : Color.tanInk)
                            .frame(width: 54, height: 58)
                            .background(selectedBookingDay == index ? Color.tanPrimary : Color.tanPaper)
                            .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(spacing: 8) {
                ForEach(detailContent.bookingSlots) { slot in
                    BookingSlotRow(time: slot.time, remaining: slot.remaining, teacher: slot.teacher)
                }
            }
        }
    }

    private var craftMetrics: some View {
        Surface {
            SectionTitle(icon: "slider.horizontal.3", title: "手艺难度与收获", subtitle: "第一次体验也能快速判断是否适合")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(detailContent.metrics) { metric in
                    CraftMetricCard(icon: metric.icon, title: metric.title, value: metric.value, level: metric.level)
                }
            }
        }
    }

    private var cultureKnowledge: some View {
        Surface {
            SectionTitle(icon: "lightbulb.fill", title: "文化小知识", subtitle: "看懂纹样、材料和节日里的讲究")

            ForEach(detailContent.cultureFacts) { fact in
                HStack(alignment: .top, spacing: 12) {
                    Text(fact.symbol)
                        .font(.system(size: 23))
                        .frame(width: 42, height: 42)
                        .background(Color.mutedOrange.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(fact.title)
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(Color.tanInk)
                        Text(fact.detail)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color.tanPaper)
                .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
            }
        }
    }

    private var reviewHighlights: some View {
        Surface {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("社区留下的印象")
                        .font(.system(size: 18, weight: .black))
                    Text("来自街坊与补档者的共同记录")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.tanPrimary)
            }

            FlowTags(tags: detailContent.reviewTags)
        }
    }

    private var photoWall: some View {
        Surface {
            VStack(alignment: .leading, spacing: 4) {
                Text("档案影像")
                    .font(.system(size: 18, weight: .bold))
                Text("这里展示已归入档案的街景、工序与摊位影像，均经授权收录。")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            if latestArchive.photos.isEmpty {
                EmptyStateView(text: "还没有档案影像，摊主可以在编辑档案时继续补充。")
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                    ForEach(latestArchive.photos) { photo in
                        VStack(alignment: .leading, spacing: 6) {
                            Button {
                                selectedArchivePhoto = photo
                            } label: {
                                LocalAttachmentPreview(
                                    attachment: photo.attachment,
                                    caption: photo.caption,
                                    style: .square
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("查看档案影像：\(photo.caption)")
                            Button {
                                guard !store.hasLikedPhoto(photo) else { return }
                                store.likePhoto(photo, in: latestArchive)
                                showToast("昔涟：伙伴，这份记忆被你点亮了。", binding: $toastMessage)
                            } label: {
                                Label("\(photo.likes)", systemImage: store.hasLikedPhoto(photo) ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .font(.system(size: 12, weight: .bold))
                                    .padding(.horizontal, 8)
                                    .frame(height: 26)
                                    .background(Color.tanPaper)
                                    .clipShape(Capsule())
                                    .frame(minHeight: 44, alignment: .leading)
                            }
                            .foregroundStyle(Color.tanPrimary)
                            .disabled(store.hasLikedPhoto(photo))
                            if photo.contributorName == store.user.name {
                                Button(role: .destructive) {
                                    pendingDeletion = .photo(photo)
                                } label: {
                                Label("删除", systemImage: "trash")
                                    .font(.system(size: 11, weight: .bold))
                                    .frame(minHeight: 44, alignment: .leading)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private var comments: some View {
        Surface {
            VStack(alignment: .leading, spacing: 5) {
                Text("社区共建")
                    .font(.system(size: 18, weight: .bold))
                Text(isOwnArchive ? "看看大家留下的故事、影像和状态线索。" : "写下故事、添加现场影像，或确认最近看到的状态。")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            if canUploadPhoto {
                VStack(alignment: .leading, spacing: 10) {
                    ChineseFriendlyTextField(placeholder: "写下故事，也可以同时附照片或视频", text: $commentText)
                        .padding(.horizontal, 12)
                        .frame(height: 42)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous)
                                .stroke(Color.tanLine)
                        }

                    ImageAttachmentPicker(
                        pendingImages: $contributionImages,
                        maximumSelectionCount: 3,
                        emptyPrompt: "可添加最多 3 项现场照片或视频",
                        allowsVideos: true
                    )

                    Button(isPublishingContribution ? "正在发布…" : "发布补档") {
                        publishContribution()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.tanPrimary)
                    .disabled(
                        isPublishingContribution ||
                        (commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && contributionImages.isEmpty)
                    )
                    .font(.system(size: 13, weight: .bold))
                }
            }

            if latestArchive.comments.isEmpty {
                EmptyStateView(text: "还没有人留下故事，写下你的第一句记忆。", icon: "text.bubble")
            } else {
                ForEach(latestArchive.comments) { comment in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(Color.tanPrimary.opacity(0.16))
                                .frame(width: 38, height: 38)
                                .overlay {
                                    Text(String(comment.contributorName.prefix(1)))
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(Color.tanPrimary)
                                }

                            Text(comment.contributorName)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.tanInk)

                            Spacer()

                            Button {
                                guard !store.hasLikedComment(comment) else { return }
                                store.likeComment(comment, in: latestArchive)
                                showToast("昔涟：伙伴，这份记忆被你点亮了。", binding: $toastMessage)
                            } label: {
                                Label("\(comment.likes)", systemImage: store.hasLikedComment(comment) ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .padding(.horizontal, 9)
                                    .frame(height: 30)
                                    .background(Color.tanPaper)
                                    .clipShape(Capsule())
                                    .frame(minHeight: 44, alignment: .trailing)
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.tanPrimary)
                            .disabled(store.hasLikedComment(comment))
                        }

                        if !comment.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(comment.text)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .lineSpacing(3)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if !comment.imageAttachments.isEmpty {
                            CommentAttachmentGallery(attachments: comment.imageAttachments)
                        }

                        Text(Self.commentDateFormatter.string(from: comment.createdAt))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)

                        if comment.contributorName == store.user.name {
                            Button(role: .destructive) {
                                pendingDeletion = .comment(comment)
                            } label: {
                                Label("删除我的补档", systemImage: "trash")
                                    .font(.system(size: 12, weight: .bold))
                                    .frame(minHeight: 44, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                            .stroke(Color.tanLine)
                    }
                }
            }

            Divider()
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 5) {
                Text("社区状态线索")
                    .font(.system(size: 18, weight: .bold))
                Text("信息来自社区线索，不代表摊主实时营业承诺。")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            if latestArchive.attentionAssessment.level == .atRisk {
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 7) {
                        ForEach(latestArchive.attentionAssessment.reasons, id: \.self) { reason in
                            Label(reason, systemImage: "circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.tanInk.opacity(0.72))
                        }
                        Text("预警根据社区线索生成，仅用于提示关注，不代表摊位已经消失。")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 8)
                } label: {
                    Label("查看消失预警依据", systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(Color.warningRed)
                }
                .padding(12)
                .background(Color.warningRed.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
            }

            if canUploadPhoto {
                Button {
                    showStatusConfirmation = true
                } label: {
                    Label("提交状态线索", systemImage: "checkmark.seal.fill")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.tanPrimary)
            }

            if latestArchive.statusConfirmations.isEmpty {
                EmptyStateView(text: "还没有状态线索，看到摊位时可以补充一条。", icon: "checkmark.seal")
            } else {
                ForEach(latestArchive.statusConfirmations) { confirmation in
                    VStack(alignment: .leading, spacing: 7) {
                        HStack {
                            Label(confirmation.result.title, systemImage: confirmation.result.symbol)
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(Color.tanPrimary)
                            Spacer()
                            Text(confirmation.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        if !confirmation.clue.isEmpty {
                            Text(confirmation.clue)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.tanInk.opacity(0.8))
                        }
                        if let attachment = confirmation.attachment {
                            Label(
                                attachment.resolvedMediaType == .video
                                    ? "附带现场视频"
                                    : "附带现场照片",
                                systemImage: attachment.resolvedMediaType == .video
                                    ? "video.fill"
                                    : "camera.fill"
                            )
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.heritageGreen)
                            LocalAttachmentPreview(
                                attachment: attachment,
                                caption: attachment.caption ?? "现场影像",
                                allowsFullScreen: true
                            )
                        }
                        if confirmation.contributorName == store.user.name {
                            Button(role: .destructive) {
                                pendingDeletion = .status(confirmation)
                            } label: {
                                Label("删除我的线索", systemImage: "trash")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                    .background(Color.tanPaper)
                    .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
                }
            }
        }
    }

    private func performDeletion(_ target: CommunityDeletionTarget) {
        pendingDeletion = nil
        Task {
            switch target {
            case .photo(let photo):
                await store.deletePhoto(photo, in: latestArchive)
            case .comment(let comment):
                await store.deleteComment(comment, in: latestArchive)
            case .status(let confirmation):
                await store.deleteStatusConfirmation(confirmation, in: latestArchive)
            }
        }
    }

    private var heritageIntroduction: String {
        switch latestArchive.category {
        case .heritageCraft:
            return "这是一门把材料、地方审美与手上经验结合起来的传统技艺。作品不只讲究好看，更记录着成都街巷里的生活方式和代代相传的做法。"
        case .oldTrade:
            return "老行当解决的是社区里最具体的生活难题。修、补、磨、配看似普通，却依赖多年形成的手感，也保存着人与街坊之间的信任。"
        case .snack:
            return "成都小吃的味道来自火候、手法与时令。看似简单的一份街边吃食，背后往往有一套只靠口传心授留下来的工序。"
        case .cultureExperience:
            return "这类文化体验把传统技艺变成可参与的城市记忆。游客不只是观看，也能跟着匠人完成一件作品，理解材料和纹样的意义。"
        case .produce:
            return "从田间到街角，季节、产地和挑选经验共同决定了摊位的特色。这里记录的不只是商品，也是成都人的时令生活。"
        case .other:
            return "这份档案记录了一种仍在街头发生的生活技艺。它可能没有标准展柜，却有稳定的顾客、熟悉的路线和值得留下来的社区故事。"
        }
    }

    private var heritageHistory: String {
        switch latestArchive.category {
        case .heritageCraft: return "由本地作坊与家庭传承延续，技法随庙会、集市和社区生活传播。"
        case .oldTrade: return "伴随老社区形成，为街坊提供长期、低成本的修补服务。"
        case .snack: return "从成都街头食俗发展而来，配方与手法多由家人、师傅口授。"
        case .cultureExperience: return "由传统节庆和民间手作演变为今天可参与的体验项目。"
        case .produce: return "连接城郊产地与城市早市，保留按季节买菜吃果的习惯。"
        case .other: return "源自社区日常需要，在长期流动与固定经营中形成自己的做法。"
        }
    }

    private var heritageRegion: String {
        "成都的慢生活、茶馆文化和街坊关系，让这门手艺更重视实用、亲切与面对面的讲解。"
    }

    private var lineageTitle: String {
        latestArchive.yearsActive >= 20 ? "家传与老师傅口授" : "本地师傅带教"
    }

    private var representativeWork: String {
        switch latestArchive.category {
        case .heritageCraft: return "代表纹样作品"
        case .oldTrade: return "经典修补案例"
        case .snack: return "招牌手工小吃"
        case .cultureExperience: return "体验教学作品"
        case .produce: return "当季精选"
        case .other: return "社区代表作品"
        }
    }

    private var certificationLevel: String {
        switch latestArchive.category {
        case .heritageCraft: return "市级非遗\n档案示例"
        case .cultureExperience: return "传统文化\n体验点"
        case .oldTrade: return "老行当\n保护档案"
        default: return "成都市井\n活态档案"
        }
    }

    private var heritageExperiences: [HeritageExperience] {
        switch latestArchive.category {
        case .heritageCraft:
            return [
                HeritageExperience(title: "基础手作体验", duration: "60 分钟", price: "68 元/人", audience: "8 岁以上", takeaway: "作品可带走"),
                HeritageExperience(title: "匠人深度小班", duration: "120 分钟", price: "168 元/人", audience: "成人/亲子", takeaway: "含材料与讲解")
            ]
        case .oldTrade:
            return [
                HeritageExperience(title: "修补工具认识", duration: "40 分钟", price: "39 元/人", audience: "亲子友好", takeaway: "带走练习样片"),
                HeritageExperience(title: "旧物修复体验", duration: "90 分钟", price: "98 元/人", audience: "12 岁以上", takeaway: "修好旧物可带走")
            ]
        case .snack:
            return [
                HeritageExperience(title: "招牌小吃制作", duration: "50 分钟", price: "58 元/人", audience: "游客/亲子", takeaway: "现做现吃"),
                HeritageExperience(title: "成都味道讲解", duration: "30 分钟", price: "29 元/人", audience: "全年龄", takeaway: "含一份品尝")
            ]
        default:
            return [
                HeritageExperience(title: "街巷文化体验", duration: "60 分钟", price: "49 元/人", audience: "游客/亲子", takeaway: "完成品可带走"),
                HeritageExperience(title: "档案故事小班", duration: "45 分钟", price: "免费预约", audience: "全年龄", takeaway: "含匠人讲解")
            ]
        }
    }

    private var heritageProducts: [HeritageProduct] {
        [
            HeritageProduct(title: representativeWork, price: latestArchive.priceOrService, badge: "手工制作", cycle: "现货少量"),
            HeritageProduct(title: "街巷纪念小件", price: "39 元起", badge: "限量", cycle: "每周补货"),
            HeritageProduct(title: "专属定制作品", price: "168 元起", badge: "可定制", cycle: "7-15 天")
        ]
    }

    private var bookingDays: [(weekday: String, date: String)] {
        [("今天", "11"), ("周五", "12"), ("周六", "13"), ("周日", "14"), ("周一", "15")]
    }

    private var cultureFacts: [CultureFact] {
        [
            CultureFact(symbol: "纹", title: "纹样寓意", detail: "常见纹样寄托平安、团圆和丰收，也会根据节气更换。"),
            CultureFact(symbol: "材", title: "材料来源", detail: "优先使用本地可得材料，材料状态会直接影响成品手感。"),
            CultureFact(symbol: "节", title: "节日习俗", detail: "春节、端午和中秋前后往往有特别作品，也是出摊最热闹的时候。")
        ]
    }

    private func publishContribution() {
        let text = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || !contributionImages.isEmpty else { return }
        isPublishingContribution = true
        Task {
            do {
                try await store.addComment(to: latestArchive, text: text, pendingImages: contributionImages)
                showToast(
                    contributionImages.isEmpty
                        ? "昔涟：伙伴，这句故事已经加入档案。"
                        : "昔涟：伙伴，现场影像和线索已经加入档案。",
                    binding: $toastMessage
                )
                commentText = ""
                contributionImages = []
            } catch {
                showToast("影像保存失败，文字仍保留，可以重试。", binding: $toastMessage)
            }
            isPublishingContribution = false
        }
    }

}

private struct ArchiveManualEditView: View {
    @EnvironmentObject private var store: ArchiveStore
    @Environment(\.dismiss) private var dismiss

    let archive: CityArchive
    @State private var draft: AIArchiveDraft
    @State private var tagsText: String
    @State private var processText: String
    @State private var status: ArchiveStatus
    @State private var historicalStops: [RouteStop]
    @State private var detailContent: ArchiveDetailContent
    @State private var reviewTagsText: String
    @State private var pendingImages: [PendingImage] = []
    @State private var isSaving = false
    @State private var saveError: String?

    init(archive: CityArchive, detailContent: ArchiveDetailContent) {
        self.archive = archive
        _draft = State(initialValue: AIArchiveDraft(archive: archive))
        _tagsText = State(initialValue: archive.tags.joined(separator: "、"))
        _processText = State(initialValue: archive.craftProcess.joined(separator: "\n"))
        _status = State(initialValue: archive.status)
        _historicalStops = State(initialValue: archive.historicalStops)
        _detailContent = State(initialValue: detailContent)
        _reviewTagsText = State(initialValue: detailContent.reviewTags.joined(separator: "、"))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                editorHeader
                editSection("档案现场影像") {
            Text("可一次选择最多 6 项照片或视频，保存后会加入档案影像。")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                    ImageAttachmentPicker(
                        pendingImages: $pendingImages,
                        maximumSelectionCount: 6,
                        emptyPrompt: "添加摊位、工具或作品的照片或视频",
                        allowsVideos: true
                    )
                    if let saveError {
                        Text(saveError)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.warningRed)
                    }
                }
                editSection("基本信息") {
                    editField("档案名称", text: $draft.name)
                    editField("摊主姓名", text: $draft.ownerName)
                    editField("价格或服务", text: $draft.priceOrService)

                    Picker("档案分类", selection: $draft.category) {
                        ForEach(ArchiveCategory.allCases, id: \.self) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    .tint(.tanPrimary)

                    Stepper("从业年限：\(draft.yearsActive) 年", value: $draft.yearsActive, in: 1...80)

                    Picker("营业状态", selection: $status) {
                        ForEach(ArchiveStatus.allCases, id: \.self) { item in
                            Text(item.title).tag(item)
                        }
                    }
                    .tint(.tanPrimary)
                }

                editSection("档案故事") {
                    TextEditor(text: $draft.summary)
                        .font(.system(size: 15))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 130)
                        .padding(10)
                        .background(Color.tanPaper)
                        .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
                }

                editSection("标签与工序") {
                    editField("标签，用顿号分隔", text: $tagsText)
                    Text("每行填写一道工序")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                    TextEditor(text: $processText)
                        .font(.system(size: 15))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 150)
                        .padding(10)
                        .background(Color.tanPaper)
                        .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
                }

                editSection("技艺介绍") {
                    multilineEdit("这项手艺是什么", text: $detailContent.introduction)
                    multilineEdit("历史来源", text: $detailContent.history)
                    multilineEdit("地域特色", text: $detailContent.region)
                    multilineEdit("手工价值", text: $detailContent.handmadeValue)
                }

                editSection("匠人故事与认证") {
                    editField("师承关系", text: $detailContent.lineage)
                    editField("代表作品", text: $detailContent.representativeWork)
                    editField("访谈标题", text: $detailContent.videoTitle)
                    editField("访谈时长", text: $detailContent.videoDuration)
                    editField("认证级别", text: $detailContent.certificationLevel)
                    editField("核验状态", text: $detailContent.verificationStatus)
                    multilineEdit("认证补充说明", text: $detailContent.certificationNote)
                }

                if FeatureFlags.commerceFeaturesEnabled {
                editSection("到店体验项目") {
                    ForEach(Array(detailContent.experiences.indices), id: \.self) { index in
                        editableItem(title: "体验 \(index + 1)") {
                            editField("项目名称", text: $detailContent.experiences[index].title)
                            editField("时长", text: $detailContent.experiences[index].duration)
                            editField("价格", text: $detailContent.experiences[index].price)
                            editField("适合人群", text: $detailContent.experiences[index].audience)
                            editField("作品能否带走", text: $detailContent.experiences[index].takeaway)
                        } onDelete: {
                            detailContent.experiences.remove(at: index)
                        }
                    }
                    addButton("增加体验项目", systemImage: "plus.circle.fill") {
                        detailContent.experiences.append(HeritageExperience(title: "新体验", duration: "60 分钟", price: "待定", audience: "全年龄", takeaway: "请补充"))
                    }
                }

                editSection("作品与商品橱窗") {
                    ForEach(Array(detailContent.products.indices), id: \.self) { index in
                        editableItem(title: "商品 \(index + 1)") {
                            editField("作品或商品名称", text: $detailContent.products[index].title)
                            editField("价格", text: $detailContent.products[index].price)
                            editField("标签", text: $detailContent.products[index].badge)
                            editField("库存或定制周期", text: $detailContent.products[index].cycle)
                        } onDelete: {
                            detailContent.products.remove(at: index)
                        }
                    }
                    addButton("增加商品", systemImage: "plus.circle.fill") {
                        detailContent.products.append(HeritageProduct(title: "新作品", price: "待定", badge: "手工制作", cycle: "请补充"))
                    }
                }

                }

                editSection("常驻范围与历史活动路线") {
                    Text("地点顺序就是地图上的历史路线顺序。经纬度保留原定位，名称和出现时间可直接修改。")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                    ForEach(Array(historicalStops.indices), id: \.self) { index in
                        editableItem(title: "路线点 \(index + 1)") {
                            editField("地点名称", text: $historicalStops[index].title)
                            editField("出现时间", text: $historicalStops[index].appearedAt)
                            Text(String(format: "%.5f, %.5f", historicalStops[index].coordinate.latitude, historicalStops[index].coordinate.longitude))
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.secondary)
                        } onDelete: {
                            historicalStops.remove(at: index)
                        }
                    }
                    addButton("增加当前摊位位置", systemImage: "mappin.and.ellipse") {
                        historicalStops.append(RouteStop(title: "新活动点", appearedAt: "待补充", coordinate: archive.currentLocation))
                    }
                }

                if FeatureFlags.commerceFeaturesEnabled {
                editSection("预约体验") {
                    Text("可预约日期")
                        .font(.system(size: 13, weight: .bold))
                    ForEach(Array(detailContent.bookingDays.indices), id: \.self) { index in
                        editableItem(title: "日期 \(index + 1)") {
                            editField("星期或说明", text: $detailContent.bookingDays[index].weekday)
                            editField("日期", text: $detailContent.bookingDays[index].date)
                        } onDelete: {
                            detailContent.bookingDays.remove(at: index)
                        }
                    }
                    addButton("增加日期", systemImage: "calendar.badge.plus") {
                        detailContent.bookingDays.append(DetailBookingDay(weekday: "待定", date: "--"))
                    }

                    Text("预约场次")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.top, 4)
                    ForEach(Array(detailContent.bookingSlots.indices), id: \.self) { index in
                        editableItem(title: "场次 \(index + 1)") {
                            editField("时间", text: $detailContent.bookingSlots[index].time)
                            editField("老师", text: $detailContent.bookingSlots[index].teacher)
                            editField("剩余名额", text: $detailContent.bookingSlots[index].remaining)
                        } onDelete: {
                            detailContent.bookingSlots.remove(at: index)
                        }
                    }
                    addButton("增加场次", systemImage: "clock.badge.plus") {
                        detailContent.bookingSlots.append(DetailBookingSlot(time: "10:00", remaining: "待确认", teacher: "老师带领"))
                    }
                }
                }

                editSection("手艺难度与收获") {
                    ForEach(Array(detailContent.metrics.indices), id: \.self) { index in
                        editableItem(title: detailContent.metrics[index].title) {
                            editField("指标名称", text: $detailContent.metrics[index].title)
                            editField("展示结果", text: $detailContent.metrics[index].value)
                            metricIconPicker(icon: $detailContent.metrics[index].icon)
                            Slider(value: $detailContent.metrics[index].level, in: 0...1)
                                .tint(.heritageGreen)
                        } onDelete: {
                            detailContent.metrics.remove(at: index)
                        }
                    }
                    addButton("增加指标", systemImage: "slider.horizontal.3") {
                        detailContent.metrics.append(DetailMetric(icon: "star.fill", title: "新指标", value: "待补充", level: 0.5))
                    }
                }

                editSection("文化小知识") {
                    ForEach(Array(detailContent.cultureFacts.indices), id: \.self) { index in
                        editableItem(title: "知识卡 \(index + 1)") {
                            editField("单字标识", text: $detailContent.cultureFacts[index].symbol)
                            editField("标题", text: $detailContent.cultureFacts[index].title)
                            multilineEdit("内容", text: $detailContent.cultureFacts[index].detail, minHeight: 90)
                        } onDelete: {
                            detailContent.cultureFacts.remove(at: index)
                        }
                    }
                    addButton("增加知识卡", systemImage: "lightbulb.fill") {
                        detailContent.cultureFacts.append(CultureFact(symbol: "新", title: "新知识", detail: "请补充内容"))
                    }
                }

                editSection("用户评价标签") {
                    editField("用顿号分隔评价标签", text: $reviewTagsText)
                }
            }
            .padding(16)
        }
        .background(Color.tanPaper.ignoresSafeArea())
        .navigationTitle("编辑我的名片")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(isSaving ? "保存中" : "保存") { save() }
                    .fontWeight(.bold)
                    .disabled(isSaving)
            }
        }
    }

    private var editorHeader: some View {
        HStack(spacing: 12) {
            ArchiveAvatarView(archive: archive, size: 64)
            VStack(alignment: .leading, spacing: 4) {
                Text("摊户自主编辑")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color.tanInk)
                Text("修改后会直接更新地图和档案详情。")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                .stroke(Color.tanLine)
        }
    }

    private func editSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(Color.tanInk)
            content()
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                .stroke(Color.tanLine)
        }
    }

    private func editField(_ placeholder: String, text: Binding<String>) -> some View {
        ChineseFriendlyTextField(placeholder: placeholder, text: text)
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Color.tanPaper)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
    }

    private func metricIconPicker(icon: Binding<String>) -> some View {
        Menu {
            ForEach(MetricIconOption.allCases) { option in
                Button {
                    icon.wrappedValue = option.symbol
                } label: {
                    Label(option.title, systemImage: option.symbol)
                }
            }
        } label: {
            HStack(spacing: 10) {
                let selected = MetricIconOption.option(for: icon.wrappedValue)
                Image(systemName: selected?.symbol ?? "ellipsis.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.tanPrimary)
                    .frame(width: 24)
                Text(selected?.title ?? "其他图标")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.tanInk)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Color.tanPaper)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("选择指标图标")
    }

    private func multilineEdit(_ title: String, text: Binding<String>, minHeight: CGFloat = 110) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
            TextEditor(text: text)
                .font(.system(size: 14))
                .scrollContentBackground(.hidden)
                .frame(minHeight: minHeight)
                .padding(8)
                .background(Color.tanPaper)
                .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
        }
    }

    private func editableItem<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content,
        onDelete: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .black))
                Spacer()
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
            }
            content()
        }
        .padding(12)
        .background(Color.tanPaper.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
    }

    private func addButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 13, weight: .bold))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(.tanPrimary)
    }

    private func save() {
        saveError = nil
        draft.tags = tagsText
            .components(separatedBy: CharacterSet(charactersIn: "、,，"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        draft.craftProcess = processText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        detailContent.reviewTags = reviewTagsText
            .components(separatedBy: CharacterSet(charactersIn: "、,，"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        isSaving = true
        Task {
            store.updateArchive(
                archive,
                with: draft,
                status: status,
                historicalStops: historicalStops
            )
            if !pendingImages.isEmpty {
                do {
                    try await store.addPhotos(
                        to: archive,
                        caption: "摊户更新现场影像",
                        pendingImages: pendingImages
                    )
                } catch {
                    saveError = "影像保存失败，请重试或移除附件后继续保存。"
                    isSaving = false
                    return
                }
            }
            ArchiveDetailContentStore.save(detailContent, for: archive)
            dismiss()
        }
    }
}

private struct SectionTitle: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.tanPrimary)
                .frame(width: 34, height: 34)
                .background(Color.mutedOrange.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color.tanInk)
                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }
            Spacer()
        }
    }
}

private struct ArchiveKnowledgeRow: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.heritageGreen)
                .frame(width: 30, height: 30)
                .background(Color.heritageGreen.opacity(0.12))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(Color.tanInk)
                Text(text)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
            }
            Spacer()
        }
        .padding(10)
        .background(Color.tanPaper)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
    }
}

private struct HeritageFactPill: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Color.tanInk.opacity(0.72))
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(Color.tanPaper)
            .clipShape(Capsule())
    }
}

private struct HeritageExperience: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var duration: String
    var price: String
    var audience: String
    var takeaway: String
}

private struct HeritageExperienceCard: View {
    let experience: HeritageExperience

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(experience.title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(Color.tanInk)
                Spacer()
                Text(experience.price)
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(Color.tanPrimary)
            }
            HStack(spacing: 12) {
                Label(experience.duration, systemImage: "clock.fill")
                Label(experience.audience, systemImage: "person.2.fill")
            }
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.secondary)
            Label(experience.takeaway, systemImage: "gift.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.heritageGreen)
        }
        .padding(13)
        .background(Color.tanPaper)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                .stroke(Color.tanLine)
        }
    }
}

private struct HeritageProduct: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var price: String
    var badge: String
    var cycle: String
}

private struct HeritageProductCard: View {
    let product: HeritageProduct
    let category: ArchiveCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            ZStack {
                LinearGradient(
                    colors: [Color.tanPrimary.opacity(0.18), Color.heritageGreen.opacity(0.14), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: category.icon)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color.tanPrimary)
            }
            .frame(height: 92)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))

            Text(product.badge)
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(Color.tanPrimary)
                .padding(.horizontal, 8)
                .frame(height: 22)
                .background(Color.mutedOrange.opacity(0.55))
                .clipShape(Capsule())
            Text(product.title)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(Color.tanInk)
                .lineLimit(1)
            Text(product.price)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.tanPrimary)
            Text(product.cycle)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(width: 154, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                .stroke(Color.tanLine)
        }
    }
}

private struct LineageRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 54, alignment: .leading)
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.tanInk)
            Spacer()
        }
    }
}

private struct BookingSlotRow: View {
    let time: String
    let remaining: String
    let teacher: String

    var body: some View {
        HStack(spacing: 12) {
            Text(time)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(Color.tanInk)
            Text(teacher)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
            Spacer()
            Text(remaining)
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(Color.heritageGreen)
                .padding(.horizontal, 9)
                .frame(height: 26)
                .background(Color.heritageGreen.opacity(0.11))
                .clipShape(Capsule())
        }
        .padding(12)
        .background(Color.tanPaper)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
    }
}

private struct CraftMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let level: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.tanPrimary)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(Color.tanInk)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.tanLine)
                    Capsule()
                        .fill(Color.heritageGreen)
                        .frame(width: proxy.size.width * level)
                }
            }
            .frame(height: 5)
        }
        .padding(12)
        .background(Color.tanPaper)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
    }
}

private struct CultureFact: Identifiable, Codable, Hashable {
    var id = UUID()
    var symbol: String
    var title: String
    var detail: String
}

private struct CommentAttachmentGallery: View {
    let attachments: [PhotoAttachment]

    private var columns: [GridItem] {
        if attachments.count == 1 {
            return [GridItem(.flexible())]
        }
        return [GridItem(.flexible(), spacing: 8), GridItem(.flexible())]
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(attachments) { attachment in
                VStack(alignment: .leading, spacing: 6) {
                    LocalAttachmentImage(attachment: attachment)

                    if let caption = attachment.caption,
                       !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(caption)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

private struct ArchiveImageGallery: View {
    @Environment(\.dismiss) private var dismiss
    let photos: [PhotoEntry]
    let initialPhotoID: UUID
    @State private var selectedPhotoID: UUID

    init(photos: [PhotoEntry], initialPhotoID: UUID) {
        self.photos = photos
        self.initialPhotoID = initialPhotoID
        _selectedPhotoID = State(initialValue: initialPhotoID)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            if photos.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.system(size: 34, weight: .bold))
                    Text("这张档案影像暂时无法加载")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white.opacity(0.78))
            } else {
                TabView(selection: $selectedPhotoID) {
                    ForEach(photos) { photo in
                        VStack(spacing: 16) {
                            Spacer(minLength: 70)
                            FullResolutionAttachmentImage(attachment: photo.attachment)
                                .padding(.horizontal, 12)
                            Text(photo.caption)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.88))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            Spacer(minLength: 50)
                        }
                        .tag(photo.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: photos.count > 1 ? .automatic : .never))
            }

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.black.opacity(0.62))
                    .clipShape(Circle())
            }
            .padding(.top, 14)
            .padding(.trailing, 16)
            .accessibilityLabel("关闭影像浏览")
        }
    }
}

private struct FullResolutionAttachmentImage: View {
    @EnvironmentObject private var store: ArchiveStore
    let attachment: PhotoAttachment?
    @State private var image: UIImage?
    @State private var player: AVPlayer?

    var body: some View {
        Group {
            if attachment?.resolvedMediaType == .video, let player {
                VideoPlayer(player: player)
                    .aspectRatio(4.0 / 3.0, contentMode: .fit)
                    .onAppear { player.play() }
                    .onDisappear { player.pause() }
            } else if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                    .fill(Color.white.opacity(0.12))
                    .aspectRatio(4.0 / 3.0, contentMode: .fit)
                    .overlay {
                        Image(
                            systemName: attachment?.resolvedMediaType == .video
                                ? "video.slash.fill"
                                : "photo.badge.exclamationmark"
                        )
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white.opacity(0.62))
                    }
            }
        }
        .task(id: attachment?.id) {
            guard let attachment else {
                image = nil
                player = nil
                return
            }
            if attachment.resolvedMediaType == .video {
                image = nil
                if let url = await store.videoURL(for: attachment) {
                    player = AVPlayer(url: url)
                } else {
                    player = nil
                }
            } else {
                player = nil
                image = await store.image(for: attachment, thumbnail: false)
            }
        }
    }
}

private struct LocalAttachmentImage: View {
    @EnvironmentObject private var store: ArchiveStore
    let attachment: PhotoAttachment?
    @State private var image: UIImage?
    @State private var showViewer = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.18))
                        .overlay {
                            Image(systemName: attachment == nil ? "photo" : "photo.badge.exclamationmark")
                                .foregroundStyle(Color.tanInk.opacity(0.4))
                        }
                }

                if attachment?.resolvedMediaType == .video {
                    Image(systemName: "play.fill")
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.black.opacity(0.58))
                        .clipShape(Circle())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(AttachmentPreviewStyle.photo4x3.aspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .onTapGesture {
            showViewer = attachment != nil
        }
        .fullScreenCover(isPresented: $showViewer) {
            AttachmentMediaViewer(attachment: attachment)
                .environmentObject(store)
        }
        .task(id: attachment?.id) {
            guard let attachment else {
                image = nil
                return
            }
            image = await store.image(for: attachment)
        }
    }
}

private struct LocalAttachmentPreview: View {
    @EnvironmentObject private var store: ArchiveStore
    let attachment: PhotoAttachment?
    let caption: String
    var style: AttachmentPreviewStyle = .photo4x3
    var allowsFullScreen = false
    @State private var image: UIImage?
    @State private var showViewer = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.18))
                        .overlay {
                            Image(systemName: attachment == nil ? "photo" : "photo.badge.exclamationmark")
                                .foregroundStyle(Color.tanInk.opacity(0.4))
                        }
                }

                if attachment?.resolvedMediaType == .video {
                    Image(systemName: "play.fill")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.black.opacity(0.58))
                        .clipShape(Circle())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(style.aspectRatio, contentMode: .fit)
        .overlay(alignment: .bottomLeading) {
            Text(caption)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.tanInk)
                .lineLimit(2)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.72))
        }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .overlay {
            if allowsFullScreen, attachment != nil {
                Button {
                    showViewer = true
                } label: {
                    Color.clear
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    attachment?.resolvedMediaType == .video ? "播放现场视频" : "查看现场照片"
                )
            }
        }
        .fullScreenCover(isPresented: $showViewer) {
            AttachmentMediaViewer(attachment: attachment)
                .environmentObject(store)
        }
        .task(id: attachment?.id) {
            guard let attachment else {
                image = nil
                return
            }
            image = await store.image(for: attachment)
        }
    }
}

private struct AttachmentMediaViewer: View {
    @Environment(\.dismiss) private var dismiss
    let attachment: PhotoAttachment?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            FullResolutionAttachmentImage(attachment: attachment)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.black.opacity(0.62))
                    .clipShape(Circle())
            }
            .padding(.top, 14)
            .padding(.trailing, 16)
            .accessibilityLabel("关闭影像浏览")
        }
    }
}

private struct StallStatusConfirmationSheet: View {
    @EnvironmentObject private var store: ArchiveStore
    @Environment(\.dismiss) private var dismiss
    let archive: CityArchive

    @State private var result: StallConfirmationResult = .stillThere
    @State private var clue = ""
    @State private var pendingImages: [PendingImage] = []
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("提交社区状态线索")
                        .font(.system(size: 22, weight: .black))
                    Text("线索仅用于补充档案，不代表实时营业承诺。")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Picker("你看到的情况", selection: $result) {
                        ForEach(StallConfirmationResult.allCases, id: \.self) { item in
                            Text(item.title).tag(item)
                        }
                    }
                    .pickerStyle(.menu)

                    TextField("写下时间、位置或你看到的细节（可选）", text: $clue, axis: .vertical)
                        .lineLimit(2...4)
                        .padding(12)
                        .background(Color.tanPaper)
                        .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))

                    ImageAttachmentPicker(
                        pendingImages: $pendingImages,
                        maximumSelectionCount: 1,
                        emptyPrompt: "可附 1 项现场照片或视频",
                        allowsVideos: true
                    )

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.warningRed)
                    }
                }
                .padding(16)
            }
            .background(Color.tanPaper.ignoresSafeArea())
            .navigationTitle("状态确认")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSubmitting ? "提交中" : "提交") { submit() }
                        .disabled(isSubmitting)
                }
            }
        }
    }

    private func submit() {
        isSubmitting = true
        Task {
            do {
                try await store.addStatusConfirmation(
                    to: archive,
                    result: result,
                    clue: clue.trimmingCharacters(in: .whitespacesAndNewlines),
                    pendingImage: pendingImages.first
                )
                dismiss()
            } catch {
                errorMessage = "影像保存失败，请重试或移除附件后继续提交。"
                isSubmitting = false
            }
        }
    }
}

private struct FlowTags: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags, id: \.self) { tag in
                    TagPill(text: tag)
                }
            }
        }
    }
}
