//
//  MockArchiveData.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import Foundation

enum MockArchiveData {
    static let chengduCenter = CoordinatePoint(latitude: 30.6586, longitude: 104.0648)

    static let currentUser = AppUser(
        id: UUID(uuidString: "A0000000-0000-0000-0000-000000000001")!,
        name: "阿棠",
        role: .visitor,
        points: 1260,
        rank: "成都第 12 名"
    )

    static let archives: [CityArchive] = [
        CityArchive(
            name: "张大爷糖油果子",
            ownerName: "张大爷",
            category: .snack,
            tags: ["手工小吃", "高消失风险", "时段限定"],
            priceOrService: "¥8/份",
            currentLocation: CoordinatePoint(latitude: 30.6609, longitude: 104.0672),
            status: .open,
            yearsActive: 18,
            summary: "东华门街口的现炸糖油果子，张大爷每天清晨出摊，火候和糖浆比例都是街坊记忆。",
            craftProcess: ["糯米团醒发", "小锅现炸", "红糖浆挂亮", "撒芝麻出锅"],
            historicalStops: stops("东华门街口", "人民公园北门", "文殊院巷口"),
            photos: photos("刚出锅的一盘还冒热气", "糖浆颜色很漂亮"),
            comments: comments("早上八点最好吃，外壳还是脆的。", "这个档案应该保留，小时候就吃过。")
        ),
        CityArchive(
            name: "李爷爷三大炮",
            ownerName: "李爷爷",
            category: .snack,
            tags: ["巴蜀味档案", "高消失风险"],
            priceOrService: "¥10/份",
            currentLocation: CoordinatePoint(latitude: 30.6662, longitude: 104.0605),
            status: .atRisk,
            yearsActive: 31,
            summary: "铜盘和糯米团子的声音曾经是文殊院外的招牌，最近一个月出摊频率明显变少。",
            craftProcess: ["糯米捶打", "抛入铜盘", "裹黄豆粉", "淋红糖水"],
            historicalStops: stops("文殊院外", "草市街口", "骡马市地铁口"),
            photos: photos("铜盘声音很有辨识度", "摊车已经有些旧了"),
            comments: comments("上次见到是上个月周六下午。", "希望有人能补一段口述故事。")
        ),
        CityArchive(
            name: "青羊宫糖画转盘",
            ownerName: "唐师傅",
            category: .heritageCraft,
            tags: ["非遗档案", "可体验", "传承人"],
            priceOrService: "¥15/次",
            currentLocation: CoordinatePoint(latitude: 30.6659, longitude: 104.0504),
            status: .open,
            yearsActive: 26,
            summary: "转盘决定图案，铜勺画出龙凤花鸟。孩子参与体验，作品本身就是活档案。",
            craftProcess: ["熬糖", "转盘抽样", "铜勺勾线", "竹签定型"],
            historicalStops: stops("青羊宫门口", "文化公园", "琴台路"),
            photos: photos("今天画到了龙", "糖线很细"),
            comments: comments("特别适合做图案谱。", "师傅说春节会画生肖限定。")
        ),
        CityArchive(
            name: "蜀绣小铺",
            ownerName: "周嬢嬢",
            category: .heritageCraft,
            tags: ["非遗档案", "传承人", "可体验"],
            priceOrService: "绣片 ¥38 起",
            currentLocation: CoordinatePoint(latitude: 30.6528, longitude: 104.0752),
            status: .closed,
            yearsActive: 14,
            summary: "小铺现场绣熊猫、芙蓉和锦鲤，适合记录针法、纹样和带徒故事。",
            craftProcess: ["描样", "配线", "走针", "装框"],
            historicalStops: stops("镋钯街", "太古里侧巷", "合江亭"),
            photos: photos("熊猫绣片很细", "线色一整盒"),
            comments: comments("可以补拍一段针法视频。", "游客很多，但真正懂工序的人不多。")
        ),
        CityArchive(
            name: "老赵补鞋换拉链",
            ownerName: "赵师傅",
            category: .oldTrade,
            tags: ["老行当", "高消失风险", "服务清单"],
            priceOrService: "补鞋 ¥12 起",
            currentLocation: CoordinatePoint(latitude: 30.6503, longitude: 104.0642),
            status: .open,
            yearsActive: 23,
            summary: "补鞋、换拉链、缝包带都能做。老社区还需要这门手艺，但年轻人很少接班。",
            craftProcess: ["看磨损", "选胶和线", "压合定型", "边缘修整"],
            historicalStops: stops("红星路小区口", "春熙路背街", "东大街菜市"),
            photos: photos("修好了一双旧皮鞋", "工具箱很有年代感"),
            comments: comments("这个应该加入消失预警样板。", "修包带很快，价格也清楚。")
        ),
        CityArchive(
            name: "磨剪刀走街摊",
            ownerName: "魏叔",
            category: .oldTrade,
            tags: ["移动摊", "老行当", "开摊报平安"],
            priceOrService: "磨刀 ¥6/把",
            currentLocation: CoordinatePoint(latitude: 30.6711, longitude: 104.0666),
            status: .closed,
            yearsActive: 17,
            summary: "没有固定摊位，靠社区微信群和现场吆喝找到他。地图上的历史路线就是核心档案。",
            craftProcess: ["粗磨", "细磨", "试刃", "清洁上油"],
            historicalStops: stops("曹家巷", "府青路", "猛追湾"),
            photos: photos("磨刀石声音很明显", "车上挂着价目牌"),
            comments: comments("很适合实时定位开摊。", "希望能记录吆喝声。")
        ),
        CityArchive(
            name: "刘嬢嬢扎染体验摊",
            ownerName: "刘嬢嬢",
            category: .cultureExperience,
            tags: ["可体验", "非遗档案", "用户共创"],
            priceOrService: "方巾 ¥28/张",
            currentLocation: CoordinatePoint(latitude: 30.6482, longitude: 104.0713),
            status: .open,
            yearsActive: 8,
            summary: "游客可以现场扎结、染色、晾干，照片墙能自然沉淀用户参与档案。",
            craftProcess: ["折布", "扎结", "入染", "清洗晾干"],
            historicalStops: stops("宽窄巷子口", "奎星楼街", "小通巷"),
            photos: photos("蓝白纹样很好看", "小朋友做了一块方巾"),
            comments: comments("适合做周末体验专题。", "可以让用户上传成品图。")
        ),
        CityArchive(
            name: "周嬢嬢龙泉枇杷",
            ownerName: "周嬢嬢",
            category: .produce,
            tags: ["产地故事", "时令限定"],
            priceOrService: "¥18/盒",
            currentLocation: CoordinatePoint(latitude: 30.6546, longitude: 104.0804),
            status: .open,
            yearsActive: 5,
            summary: "从龙泉山带来的枇杷，只在季节里出现。适合连接采摘日、产地和街角销售。",
            craftProcess: ["清晨采摘", "分拣装篮", "午后出摊"],
            historicalStops: stops("合江亭", "望平街", "东门大桥"),
            photos: photos("枇杷很甜", "藤篮很好认"),
            comments: comments("季节档案很有意思。", "可以加采摘日期。")
        )
    ]

    private static func stops(_ a: String, _ b: String, _ c: String) -> [RouteStop] {
        [
            RouteStop(title: a, appearedAt: "常驻点", coordinate: CoordinatePoint(latitude: 30.6586, longitude: 104.0648)),
            RouteStop(title: b, appearedAt: "周末下午", coordinate: CoordinatePoint(latitude: 30.6621, longitude: 104.0583)),
            RouteStop(title: c, appearedAt: "节庆流动", coordinate: CoordinatePoint(latitude: 30.6534, longitude: 104.0732))
        ]
    }

    private static func photos(_ first: String, _ second: String) -> [PhotoEntry] {
        [
            PhotoEntry(contributorName: "阿棠", caption: first, likes: 18),
            PhotoEntry(contributorName: "小周", caption: second, likes: 11)
        ]
    }

    private static func comments(_ first: String, _ second: String) -> [CommentEntry] {
        [
            CommentEntry(contributorName: "市景侠", text: first, likes: 9),
            CommentEntry(contributorName: "老街坊", text: second, likes: 14)
        ]
    }
}
