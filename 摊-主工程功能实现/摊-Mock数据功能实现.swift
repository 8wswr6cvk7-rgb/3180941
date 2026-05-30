//
//  MockData.swift
//  3180941
//
//  Created by Codex on 2026/5/30.
//

import Foundation
import CoreLocation

enum MockData {
    static let chengduCenter = CLLocationCoordinate2D(latitude: 30.6586, longitude: 104.0648)

    static let zhangDaYe = Stall(
        id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280A001")!,
        name: "张大爷糖油果子",
        ownerName: "张大爷",
        category: "小吃",
        price: "¥8/份",
        location: CLLocationCoordinate2D(latitude: 30.6609, longitude: 104.0672),
        status: .open,
        yearsActive: 18,
        photoURL: "",
        voiceStoryURL: "voice://zhangdaye-story",
        description: "张大爷每天清晨推着小车到东华门街口，现炸现裹糖浆，靠的是几十年不变的火候。"
    )

    static let wangPo = Stall(
        id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280A002")!,
        name: "王婆叶儿粑",
        ownerName: "王婆",
        category: "小吃",
        price: "¥6/个",
        location: CLLocationCoordinate2D(latitude: 30.6554, longitude: 104.0716),
        status: .closed,
        yearsActive: 22,
        photoURL: "",
        voiceStoryURL: "voice://wangpo-story",
        description: "王婆的叶儿粑包着芽菜和肉末，蒸笼一揭开，总能把巷口的香气拉满。"
    )

    static let liYeYe = Stall(
        id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280A003")!,
        name: "李爷爷三大炮",
        ownerName: "李爷爷",
        category: "小吃",
        price: "¥10/份",
        location: CLLocationCoordinate2D(latitude: 30.6662, longitude: 104.0605),
        status: .gone,
        yearsActive: 31,
        photoURL: "",
        voiceStoryURL: "voice://liye-story",
        description: "李爷爷的铜盘和糯米团子曾是文殊院外最响亮的声音，如今已经很久没人见到他出摊。"
    )

    static let chenJie = Stall(
        id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280A004")!,
        name: "陈姐军屯锅盔",
        ownerName: "陈姐",
        category: "小吃",
        price: "¥9/个",
        location: CLLocationCoordinate2D(latitude: 30.6522, longitude: 104.0601),
        status: .open,
        yearsActive: 9,
        photoURL: "",
        voiceStoryURL: "voice://chenjie-story",
        description: "陈姐把锅盔烙得外脆里酥，牛肉和锅魁的香气总在午后最先到达街角。"
    )

    static let zhouShu = Stall(
        id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280A005")!,
        name: "周叔冰粉凉糕",
        ownerName: "周叔",
        category: "小吃",
        price: "¥7/碗",
        location: CLLocationCoordinate2D(latitude: 30.6640, longitude: 104.0744),
        status: .open,
        yearsActive: 12,
        photoURL: "",
        voiceStoryURL: "voice://zhoushu-story",
        description: "周叔守着一辆蓝色三轮车，专卖冰粉凉糕，最忙的时候一下午能卖掉三大桶红糖水。"
    )

    static let heShu = Stall(
        id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280A006")!,
        name: "何叔麻辣兔头",
        ownerName: "何叔",
        category: "其他",
        price: "¥15/个",
        location: CLLocationCoordinate2D(latitude: 30.6491, longitude: 104.0692),
        status: .closed,
        yearsActive: 14,
        photoURL: "",
        voiceStoryURL: "voice://heshu-story",
        description: "何叔的老卤锅从不离火，街坊都说他家的麻辣味是晚上九点以后最有烟火气的招牌。"
    )

    static let liuNiangNiang = Stall(
        id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280A007")!,
        name: "刘嬢嬢凉面",
        ownerName: "刘嬢嬢",
        category: "小吃",
        price: "¥8/份",
        location: CLLocationCoordinate2D(latitude: 30.6703, longitude: 104.0669),
        status: .open,
        yearsActive: 16,
        photoURL: "",
        voiceStoryURL: "voice://liuniang-story",
        description: "刘嬢嬢的凉面靠一勺红油和一把芽菜提神，是附近学生放学后最熟悉的味道。"
    )

    static let zhaoShiFu = Stall(
        id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280A008")!,
        name: "赵师傅红糖糍粑",
        ownerName: "赵师傅",
        category: "小吃",
        price: "¥12/份",
        location: CLLocationCoordinate2D(latitude: 30.6452, longitude: 104.0578),
        status: .open,
        yearsActive: 11,
        photoURL: "",
        voiceStoryURL: "voice://zhaoshi-story",
        description: "赵师傅现场下锅炸糍粑，起锅后撒花生碎和红糖浆，甜香能飘过整条小街。"
    )

    static let tangShu = Stall(
        id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280A009")!,
        name: "唐叔现摘青笋",
        ownerName: "唐叔",
        category: "蔬菜",
        price: "¥5/斤",
        location: CLLocationCoordinate2D(latitude: 30.6618, longitude: 104.0526),
        status: .closed,
        yearsActive: 7,
        photoURL: "",
        voiceStoryURL: "voice://tangshu-story",
        description: "唐叔每天从郫都区赶来，把清晨摘的青笋和藤藤菜摆得整整齐齐。"
    )

    static let zhouNiangNiang = Stall(
        id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280A010")!,
        name: "周嬢嬢龙泉枇杷",
        ownerName: "周嬢嬢",
        category: "水果",
        price: "¥18/盒",
        location: CLLocationCoordinate2D(latitude: 30.6546, longitude: 104.0804),
        status: .open,
        yearsActive: 5,
        photoURL: "",
        voiceStoryURL: "voice://zhouniang-story",
        description: "周嬢嬢把龙泉山的枇杷装在藤篮里，常常一边卖一边教人怎么挑最甜的那一颗。"
    )

    static let stalls: [Stall] = [
        zhangDaYe,
        wangPo,
        liYeYe,
        chenJie,
        zhouShu,
        heShu,
        liuNiangNiang,
        zhaoShiFu,
        tangShu,
        zhouNiangNiang
    ]

    static let inactiveDays: [UUID: Int] = [
        liYeYe.id: 32
    ]

    static let currentUser = User(
        id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280B001")!,
        name: "阿棠",
        points: 1260
    )

    static let initialFavoriteIDs: Set<UUID> = [
        zhangDaYe.id,
        chenJie.id,
        zhouNiangNiang.id
    ]

    static let sampleOrders: [Order] = [
        Order(
            id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280C001")!,
            stallId: zhangDaYe.id,
            requesterName: "阿棠",
            item: "糖油果子两份",
            status: .accepted,
            bucket: .published
        ),
        Order(
            id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280C002")!,
            stallId: zhouNiangNiang.id,
            requesterName: "阿棠",
            item: "枇杷一盒",
            status: .pending,
            bucket: .published
        ),
        Order(
            id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280C003")!,
            stallId: chenJie.id,
            requesterName: "阿棠",
            item: "锅盔加辣",
            status: .completed,
            bucket: .published
        ),
        Order(
            id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280C004")!,
            stallId: wangPo.id,
            requesterName: "小周",
            item: "叶儿粑四个，少糖",
            status: .accepted,
            bucket: .received
        ),
        Order(
            id: UUID(uuidString: "9DDE8E32-FA0E-4E9C-9032-10272280C005")!,
            stallId: tangShu.id,
            requesterName: "老赵",
            item: "青笋两斤，顺路送到草市街口",
            status: .pending,
            bucket: .received
        )
    ]
}
