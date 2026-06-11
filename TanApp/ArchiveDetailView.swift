//
//  ArchiveDetailView.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI
import PhotosUI
import UIKit

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
            certificationNote: "认证证书、口述史和代表作品可继续由摊主或高积分市景侠补充。",
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
}

struct ArchiveDetailView: View {
    @EnvironmentObject private var store: ArchiveStore
    let archive: CityArchive

    @State private var commentText = ""
    @State private var showPhotoInput = false
    @State private var showEditor = false
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    @State private var toastMessage: String?
    @State private var selectedBookingDay = 0
    @State private var detailContent: ArchiveDetailContent

    init(archive: CityArchive) {
        self.archive = archive
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
                    experienceProjects
                    productShowcase
                    certificationAndLineage
                    activityRange
                    process
                    reservationCalendar
                    craftMetrics
                    cultureKnowledge
                    reviewHighlights
                    if !isOwnArchive {
                        contributionActions(proxy: proxy)
                    }
                    photoWall
                        .id("photos")
                    comments
                        .id("comments")
                }
                .padding(16)
                .padding(.bottom, 20)
            }
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
                    }

                    if !isOwnArchive {
                        Button {
                            let wasFavorite = store.favoriteIDs.contains(latestArchive.id)
                            store.toggleFavorite(latestArchive)
                            showToast(wasFavorite ? "已取消收藏" : "已收藏", binding: $toastMessage)
                        } label: {
                            Image(systemName: store.favoriteIDs.contains(latestArchive.id) ? "heart.fill" : "heart")
                                .foregroundStyle(Color.tanPrimary)
                        }
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
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                selectedPhotoData = image.jpegData(compressionQuality: 0.82)
                showPhotoInput = true
            }
        }
        .onChange(of: selectedPhotoItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        selectedPhotoData = data
                        showPhotoInput = true
                    }
                }
            }
        }
    }

    private func contributionActions(proxy: ScrollViewProxy) -> some View {
        Surface {
            VStack(alignment: .leading, spacing: 8) {
                Text("我来补档")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color.tanInk)
                Text("看到、听到、记得的线索，都能帮这份市井记忆更完整。")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
            }

            HStack(spacing: 10) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showPhotoInput = true
                        proxy.scrollTo("comments", anchor: .top)
                    }
                } label: {
                    Label("补一张照片", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.tanPrimary)

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if commentText.isEmpty {
                            commentText = "我记得："
                        }
                        proxy.scrollTo("comments", anchor: .top)
                    }
                } label: {
                    Label("补一句故事", systemImage: "text.bubble.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .font(.system(size: 13, weight: .bold))

            Button {
                showToast("昔涟：伙伴，谢谢确认，这条街的记忆又亮了一点。", binding: $toastMessage)
            } label: {
                Label("这个摊还在吗？", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                LinearGradient(
                    colors: [Color.tanPrimary.opacity(0.28), Color.heritageGreen.opacity(0.18), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 12) {
                    Image(systemName: latestArchive.category.icon)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                        .frame(width: 96, height: 96)
                        .background(.white.opacity(0.82))
                        .clipShape(RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous))
                        .shadow(color: Color.tanInk.opacity(0.08), radius: 14, x: 0, y: 8)
                    Text(latestArchive.category.title)
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Color.tanInk)
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .background(.white.opacity(0.78))
                        .clipShape(Capsule())
                }
            }
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
                StatusBadge(status: latestArchive.status)
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
                .accessibilityLabel("内置导航")
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

            Button {
                showToast("短视频访谈为原型演示内容", binding: $toastMessage)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(Color.tanPrimary)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 3) {
                        Text(detailContent.videoTitle)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.tanInk)
                        Text(detailContent.videoDuration)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.tanInk.opacity(0.35))
                }
                .padding(12)
                .background(Color.mutedOrange.opacity(0.38))
                .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
            }
            .buttonStyle(.plain)
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
                    Text("大家怎么评价")
                        .font(.system(size: 18, weight: .black))
                    Text("来自体验者的高频感受")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("4.8")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(Color.tanPrimary)
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.tanPrimary)
            }

            FlowTags(tags: detailContent.reviewTags)
        }
    }

    private var photoWall: some View {
        Surface {
            Text("街景照片")
                .font(.system(size: 18, weight: .bold))

            if latestArchive.photos.isEmpty {
                EmptyStateView(text: "还没有街景照片，成为第一个补档的人。")
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                    ForEach(latestArchive.photos) { photo in
                        VStack(alignment: .leading, spacing: 6) {
                            UploadedPhotoPreview(imageData: photo.imageData, caption: photo.caption)
                                .frame(height: 96)
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
                            }
                            .foregroundStyle(Color.tanPrimary)
                            .disabled(store.hasLikedPhoto(photo))
                        }
                    }
                }
            }
        }
    }

    private var comments: some View {
        Surface {
            VStack(alignment: .leading, spacing: 5) {
                Text("评论与照片补档")
                    .font(.system(size: 18, weight: .bold))
                Text(isOwnArchive ? "看看大家留下的故事、照片和建议。" : "一句话和一张照片，可以一起成为档案。")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            if canUploadPhoto {
                VStack(alignment: .leading, spacing: 10) {
                    if let selectedPhotoData {
                        ZStack(alignment: .topTrailing) {
                            UploadedPhotoPreview(
                                imageData: selectedPhotoData,
                                caption: commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "待发布现场照片" : commentText
                            )
                            .frame(height: 170)

                            Button {
                                self.selectedPhotoData = nil
                                selectedPhotoItem = nil
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(Color.tanInk)
                                    .frame(width: 30, height: 30)
                                    .background(.white.opacity(0.9))
                                    .clipShape(Circle())
                            }
                            .padding(8)
                        }
                    } else if showPhotoInput {
                        Text("选择一张现场照片，再写下当时看到的故事。")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.tanPrimary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.mutedOrange.opacity(0.45))
                            .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
                    }

                    ChineseFriendlyTextField(placeholder: "写下故事，也可以同时附一张照片", text: $commentText)
                        .padding(.horizontal, 12)
                        .frame(height: 42)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous)
                                .stroke(Color.tanLine)
                        }

                    HStack(spacing: 10) {
                        Button {
                            showPhotoInput = true
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                showCamera = true
                            } else {
                                selectedPhotoData = makeMockCameraPhotoData()
                            }
                        } label: {
                            Label("拍照", systemImage: "camera.fill")
                        }
                        .buttonStyle(.bordered)

                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label("相册", systemImage: "photo.fill.on.rectangle.fill")
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        Button("发布补档") {
                            publishContribution()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.tanPrimary)
                        .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedPhotoData == nil)
                    }
                    .font(.system(size: 13, weight: .bold))
                }
            }

            if latestArchive.comments.isEmpty {
                EmptyStateView(text: "还没有人留下故事，写下你的第一句记忆。", icon: "text.bubble")
            } else {
                ForEach(latestArchive.comments) { comment in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(Color.tanPrimary.opacity(0.16))
                            .frame(width: 38, height: 38)
                            .overlay {
                                Text(String(comment.contributorName.prefix(1)))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color.tanPrimary)
                            }
                        VStack(alignment: .leading, spacing: 5) {
                            Text(comment.contributorName)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.tanInk)
                            Text(comment.text)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .lineSpacing(3)
                        }
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
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                        .disabled(store.hasLikedComment(comment))
                    }
                    .padding(12)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                            .stroke(Color.tanLine)
                    }
                }
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
        guard !text.isEmpty || selectedPhotoData != nil else { return }

        if !text.isEmpty {
            store.addComment(to: latestArchive, text: text)
        }
        if let selectedPhotoData {
            store.addPhoto(
                to: latestArchive,
                caption: text.isEmpty ? "用户补充现场照片" : text,
                imageData: selectedPhotoData
            )
        }

        let feedback: String
        if selectedPhotoData == nil {
            feedback = "昔涟：伙伴，这句故事已经加入档案。"
        } else {
            feedback = "昔涟：伙伴，这张照片让档案更完整啦。"
        }
        showToast(feedback, binding: $toastMessage)
        commentText = ""
        selectedPhotoData = nil
        selectedPhotoItem = nil
        showPhotoInput = false
    }

    private func makeMockCameraPhotoData() -> Data? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 900, height: 650))
        let image = renderer.image { context in
            UIColor(Color.tanPrimary.opacity(0.22)).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 900, height: 650))

            UIColor(Color.tanPaper).setFill()
            UIBezierPath(roundedRect: CGRect(x: 70, y: 70, width: 760, height: 510), cornerRadius: 44).fill()

            UIColor(Color.tanPrimary).setFill()
            UIBezierPath(ovalIn: CGRect(x: 390, y: 225, width: 120, height: 120)).fill()

            let title = "现场拍照模拟"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48, weight: .black),
                .foregroundColor: UIColor(Color.tanInk)
            ]
            title.draw(at: CGPoint(x: 285, y: 375), withAttributes: attributes)
        }
        return image.jpegData(compressionQuality: 0.82)
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

                editSection("常驻范围与上次路线") {
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

                editSection("手艺难度与收获") {
                    ForEach(Array(detailContent.metrics.indices), id: \.self) { index in
                        editableItem(title: detailContent.metrics[index].title) {
                            editField("指标名称", text: $detailContent.metrics[index].title)
                            editField("展示结果", text: $detailContent.metrics[index].value)
                            editField("SF Symbol 图标", text: $detailContent.metrics[index].icon)
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
                Button("保存") { save() }
                    .fontWeight(.bold)
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
        store.updateArchive(
            archive,
            with: draft,
            status: status,
            historicalStops: historicalStops
        )
        ArchiveDetailContentStore.save(detailContent, for: archive)
        dismiss()
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

private struct UploadedPhotoPreview: View {
    let imageData: Data?
    let caption: String

    var body: some View {
        Group {
            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.18))
            }
        }
        .overlay(alignment: .bottomLeading) {
            Text(caption)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.tanInk)
                .lineLimit(2)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.72))
        }
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
    }
}

private struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker

        init(parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
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
