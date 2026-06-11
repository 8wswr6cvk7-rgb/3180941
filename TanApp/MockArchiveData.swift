//
//  MockArchiveData.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import Foundation
import CoreLocation

enum MockArchiveData {
    static let chengduCenter = CoordinatePoint(latitude: 30.6586, longitude: 104.0648)

    static func roadHistoryRoute(for archive: CityArchive) -> [CLLocationCoordinate2D] {
        let points: [(Double, Double)]
        switch archive.name {
        case "张大爷糖油果子":
            points = [(30.660897,104.0672),(30.660735,104.058107),(30.656885,104.058195),(30.656887,104.057057),(30.657395,104.057141),(30.658016,104.057294),(30.656887,104.057057),(30.656883,104.058401),(30.658742,104.058422),(30.658853,104.064737),(30.659042,104.064987),(30.659232,104.065025),(30.6607,104.064977),(30.660801,104.068598),(30.664626,104.068329),(30.667669,104.068241),(30.667676,104.069025),(30.668072,104.069024),(30.668226,104.068876)]
        case "李爷爷三大炮":
            points = [(30.666194,104.059974),(30.669322,104.059786),(30.669426,104.063161),(30.669471,104.068224),(30.669457,104.068986),(30.66936,104.069285),(30.66914,104.069634),(30.668987,104.070009),(30.669171,104.069886),(30.669516,104.069899),(30.670631,104.070649),(30.670685,104.070538),(30.669782,104.069893),(30.669593,104.069449),(30.66956,104.069116),(30.669509,104.063032),(30.665951,104.063146),(30.665945,104.062496)]
        case "青羊宫糖画转盘":
            points = [(30.665567,104.049956),(30.665237,104.049764),(30.665757,104.048547),(30.664273,104.047744),(30.664057,104.047412),(30.664288,104.046828),(30.665992,104.04334),(30.66591,104.043288),(30.664111,104.046935),(30.663411,104.048934),(30.663279,104.049405),(30.662975,104.049307),(30.66259,104.049093),(30.662461,104.048887)]
        case "蜀绣小铺":
            points = [(30.652727,104.075145),(30.653041,104.074579),(30.653405,104.074939),(30.654658,104.075879),(30.653625,104.078054),(30.651479,104.082749),(30.651606,104.0828),(30.653233,104.0793),(30.653643,104.079535),(30.654561,104.080036),(30.655057,104.078949),(30.653625,104.078054),(30.652176,104.081225),(30.650171,104.079882),(30.650644,104.07891)]
        case "老赵补鞋换拉链":
            points = [(30.650293,104.063857),(30.653535,104.063761),(30.653777,104.063633),(30.654634,104.063607),(30.654961,104.064021),(30.654953,104.065843),(30.654847,104.066284),(30.65243,104.069346),(30.651352,104.070865),(30.651101,104.071432),(30.650748,104.072691),(30.650788,104.072914),(30.653148,104.074659),(30.653405,104.074939),(30.654788,104.075967),(30.655307,104.0762),(30.655945,104.076714),(30.656076,104.076675),(30.656038,104.076557),(30.65515,104.076012),(30.654806,104.075591),(30.652724,104.074175),(30.650633,104.072624),(30.650088,104.072451),(30.648632,104.072402),(30.648616,104.072559),(30.649809,104.072586),(30.649482,104.073725)]
        case "磨剪刀走街摊":
            points = [(30.671153,104.065905),(30.672077,104.066),(30.672154,104.06544),(30.672895,104.064081),(30.674594,104.065346),(30.67472,104.065945),(30.672063,104.071614),(30.674928,104.07366),(30.675904,104.074708),(30.676827,104.075384),(30.682941,104.079405),(30.684681,104.080709),(30.684213,104.081953),(30.682046,104.086345),(30.688207,104.090382),(30.686519,104.092886),(30.686283,104.092736),(30.683585,104.091012),(30.681881,104.094524),(30.679766,104.09282),(30.679339,104.092077),(30.678679,104.09194),(30.673288,104.087625),(30.66655,104.083377),(30.666453,104.083584),(30.66808,104.08454),(30.6666,104.0883)]
        case "刘嬢嬢扎染体验摊":
            points = [(30.664227,104.055556),(30.664536,104.054414),(30.665138,104.054451),(30.665212,104.05438),(30.665388,104.053954),(30.665493,104.053817),(30.665591,104.053782),(30.667499,104.053659),(30.667547,104.053547),(30.665497,104.053684),(30.665364,104.053773),(30.665243,104.054055),(30.665113,104.053985),(30.664217,104.053851),(30.66427,104.053436),(30.663445,104.053393),(30.663276,104.053505),(30.663312,104.053795),(30.663483,104.053966),(30.663968,104.053981),(30.664069,104.053835),(30.665113,104.053985),(30.665243,104.054055),(30.665125,104.054331),(30.664987,104.054351),(30.663731,104.05425),(30.66303,104.05384),(30.662707,104.053696),(30.66261,104.053809),(30.663003,104.053964),(30.663648,104.054333),(30.665124,104.054455),(30.665212,104.05438),(30.665434,104.053871),(30.665542,104.053793),(30.666722,104.053708),(30.666343,104.054998)]
        case "周嬢嬢龙泉枇杷":
            points = [(30.650644,104.07891),(30.653041,104.074579),(30.659458,104.079126),(30.663105,104.081425),(30.659907,104.088168),(30.659064,104.087644),(30.657569,104.086166),(30.653442,104.083609)]
        default:
            return []
        }
        return points.map { CLLocationCoordinate2D(latitude: $0.0, longitude: $0.1) }
    }

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
            RouteStop(title: a, appearedAt: "常驻点", coordinate: coordinate(for: a)),
            RouteStop(title: b, appearedAt: "周末下午", coordinate: coordinate(for: b)),
            RouteStop(title: c, appearedAt: "节庆流动", coordinate: coordinate(for: c))
        ]
    }

    private static func coordinate(for place: String) -> CoordinatePoint {
        let coordinates: [String: CoordinatePoint] = [
            "东华门街口": CoordinatePoint(latitude: 30.6609, longitude: 104.0672),
            "人民公园北门": CoordinatePoint(latitude: 30.6574, longitude: 104.0571),
            "文殊院巷口": CoordinatePoint(latitude: 30.6681, longitude: 104.0687),
            "文殊院外": CoordinatePoint(latitude: 30.6662, longitude: 104.0605),
            "草市街口": CoordinatePoint(latitude: 30.6691, longitude: 104.0696),
            "骡马市地铁口": CoordinatePoint(latitude: 30.6656, longitude: 104.0625),
            "青羊宫门口": CoordinatePoint(latitude: 30.6659, longitude: 104.0504),
            "文化公园": CoordinatePoint(latitude: 30.6644, longitude: 104.0469),
            "琴台路": CoordinatePoint(latitude: 30.6627, longitude: 104.0486),
            "镋钯街": CoordinatePoint(latitude: 30.6528, longitude: 104.0752),
            "太古里侧巷": CoordinatePoint(latitude: 30.6537, longitude: 104.0794),
            "合江亭": CoordinatePoint(latitude: 30.6509, longitude: 104.0791),
            "红星路小区口": CoordinatePoint(latitude: 30.6503, longitude: 104.0642),
            "春熙路背街": CoordinatePoint(latitude: 30.6552, longitude: 104.0764),
            "东大街菜市": CoordinatePoint(latitude: 30.6492, longitude: 104.0736),
            "曹家巷": CoordinatePoint(latitude: 30.6711, longitude: 104.0666),
            "府青路": CoordinatePoint(latitude: 30.6863, longitude: 104.0927),
            "猛追湾": CoordinatePoint(latitude: 30.6668, longitude: 104.0884),
            "宽窄巷子口": CoordinatePoint(latitude: 30.6638, longitude: 104.0554),
            "奎星楼街": CoordinatePoint(latitude: 30.6648, longitude: 104.0531),
            "小通巷": CoordinatePoint(latitude: 30.6666, longitude: 104.0551),
            "望平街": CoordinatePoint(latitude: 30.6589, longitude: 104.0880),
            "东门大桥": CoordinatePoint(latitude: 30.6534, longitude: 104.0837)
        ]
        return coordinates[place] ?? chengduCenter
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
