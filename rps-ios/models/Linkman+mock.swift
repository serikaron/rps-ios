//
//  Linkman+mock.swift
//  rps-ios
//
//  Created by serika on 2023/11/11.
//

import Foundation

extension Linkman.NoticeRecord {
    static var mock: Linkman.NoticeRecord {
        return Linkman.NoticeRecord(noticeTitle: "公告1")
    }
}

extension Linkman.NetworkSearchResult {
    static var mock: Linkman.NetworkSearchResult {
        return Linkman.NetworkSearchResult(
            id: "1722436582041812994",
            fvFamilyRoomName: "新世纪2幢1单元1002",
            fvEstateType: "commApartment",
//            fiProvinceCode: 330000,
//            fiCityCode: 330100,
            fiAreaCode: 330106,
//            fiSubdistrictId: 330106109,
//            fiCommunityId: 5,
            fiCompoundId: 1,
            fvCompoundName: "新世纪花苑",
            fvNameAlias: "新世纪花苑小区",
            fvStreetMark: "11浙江省杭州市西湖区古墩路1105号",
            fvToEast: "",
            fvToSouth: "",
            fvToWest: "",
            fvToNorth: "",
            fvAreaLocation: "7",
//            picUrls: "https://image.xuboren.com/image/2023/10/11/ef3ca15d388940e6b21dc46d848d3905.jpg",
            picUrls: "",
            fvCompletionDate: "2001",
            fvPois: nil,
//            fiOrgId: 294,
//            fvProvinceName: "浙江省",
//            fvCityName: "杭州市",
//            fvAreaName: "西湖区",
//            fvSubdistrictName: "三墩镇",
//            fvEstateState: "4"
            fiBuildingId: 0,
            fvInFloor: "1-1"
        )
    }
    
    static func mockResult(num: Int) -> Linkman.NetworkSearchResult {
        return Linkman.NetworkSearchResult(
            id: "\(num)",
            fvFamilyRoomName: "fvFamilyRoomName-\(num)",
            fvEstateType: "commApartment",
            fiAreaCode: 300106,
            fiCompoundId: num,
            fvCompoundName: "fvCompoundName-\(num)",
            fvNameAlias: "fvNameAlias-\(num)",
            fvStreetMark: "fvStreetMark-\(num)",
            fvToEast: "",
            fvToSouth: "",
            fvToWest: "",
            fvToNorth: "",
            fvAreaLocation: "7",
            picUrls: "https://image.xuboren.com/image/2023/10/11/ef3ca15d388940e6b21dc46d848d3905.jpg",
            fvCompletionDate: "\(num)",
            fvPois: nil,
            fiBuildingId: 0,
            fvInFloor: "1-1"
        )
    }
}

extension Linkman.DictResponse {
    static var mock: Linkman.DictResponse {
        [
            Linkman.NetworkDictType(
                dictType: "form_tree_state",
                sysDictDataList: [
                    Linkman.NetworkDictItem(dictTypeName: "表单树状态",
                                            dictLabel: "启用",
                                            dictValue: "0",
                                            dictSort: 0),
                    Linkman.NetworkDictItem(dictTypeName: "表单树状态",
                                            dictLabel: "禁用",
                                            dictValue: "1",
                                            dictSort: 0)
                ]),
            Linkman.NetworkDictType(
                dictType: "fv_estate_type",
                sysDictDataList: [
                    Linkman.NetworkDictItem(dictTypeName: "物业类型",
                                            dictLabel: "工业厂房",
                                            dictValue: "industrialFactory",
                                            dictSort: 0),
                    Linkman.NetworkDictItem(dictTypeName: "物业类型",
                                            dictLabel: "工业小微园",
                                            dictValue: "industrialSmallGarden",
                                            dictSort: 0),
                    Linkman.NetworkDictItem(dictTypeName: "物业类型",
                                            dictLabel: "临街商业",
                                            dictValue: "shopStreet",
                                            dictSort: 0),
                    Linkman.NetworkDictItem(dictTypeName: "物业类型",
                                            dictLabel: "落地房",
                                            dictValue: "landingRoom",
                                            dictSort: 0),
                    Linkman.NetworkDictItem(dictTypeName: "物业类型",
                                            dictLabel: "写字楼",
                                            dictValue: "office",
                                            dictSort: 0),
                    Linkman.NetworkDictItem(dictTypeName: "物业类型",
                                            dictLabel: "排屋别墅",
                                            dictValue: "villa",
                                            dictSort: 0),
                    Linkman.NetworkDictItem(dictTypeName: "物业类型",
                                            dictLabel: "商住公寓",
                                            dictValue: "singleApartment",
                                            dictSort: 0),
                    Linkman.NetworkDictItem(dictTypeName: "物业类型",
                                            dictLabel: "普通公寓",
                                            dictValue: "commApartment",
                                            dictSort: 0),
                ])
        ]
    }
}

extension Building {
    static var mock: Building {
        Building(
            id: 0,
            fdCompletionDate: "2010",
            fvBuildingName: "宝石1幢",
            fvNameAlias: "宝石1幢",
            fvFloorHeight: "5",
            fvEstateType: "singleApartment",
            fiAreaCode: 330106
        )
    }
}

extension Floors {
    static func mock(floorCount: Int, unitCount: Int) -> Floors {
        Floors(
            buildingName: "宝石1幢",
            unitTitles: (1...unitCount).map { "\($0)单元" },
            floors: (1...floorCount).map { floor in
                Floor(
                    name: "楼层\(floor)",
                    rooms: (1...unitCount).map { room in
                        Room(
                            name: "1801",
                            familyRoomName: "宝石1幢1单元RF301",
                            areaCode: 300106,
                            estateType: "singleApartment",
                            buildingId: 0,
                            floor: "1-1"
                        )
                    }
                )
            }
        )
    }
}

extension RoomDetail {
    static var mock: RoomDetail {
        RoomDetail(
            networkRoomDetail: .mock,
            roomCount: 0
        )
    }
}

extension Linkman.NetworkRoomDetail {
    static var mock: Linkman.NetworkRoomDetail {
        Linkman.NetworkRoomDetail (
            fvFamilyRoomName: "",
            fvProvinceName: "",
            fvCityName: "",
            fvAreaName: "",
            fvSubdistrictName: "",
            fvEstateType: "",
            estateTypeLabel: "",
            fvLandUser: "",
            fdCompletionDate: "",
            fvBuildingStructure: "",
            fvOrientation: "",
            fvFloorHeight: "",
            fvInFloor: "",
            fvHouseProperty: "",
            fvHousingUse: "",
            fvPosition: "",
            fvLandingroomPosition: "",
            fvShopPosition: "",
            wuYeFenLei: "",
            fiLandUpperCount: 0,
            fvLandingroomLandSe: "",
            buildingImageList: [],
            compoundImageList: [],
            dcBuilding: .mock,
            dcCompound: .mock
        )
    }
}

extension Linkman.DCBuilding {
    static var mock: Linkman.DCBuilding {
        Linkman.DCBuilding (
            fvHouseProperty: "",
            fvBuildingStructure: "",
            fiLandUpperCount: 0,
            fvHousingUse: "",
            fvLandingroomLandSe: "",
            fvLandUser: "",
            fdCompletionDate: "",
            fvEstateType: "",
            fvBuildDirection: ""
        )
    }
}

extension Linkman.DCCompound {
    static var mock: Linkman.DCCompound {
        Linkman.DCCompound(
            fvLandUser: "",
            fvCompletionDate: "",
            fvLandLevel: ""
        )
    }
}

extension ReferenceCase {
    static func mock(num: Int) -> ReferenceCase {
        ReferenceCase(
            tradeType: "tradeType\(num)",
            date: "2001",
            caseAddress: "caseAddress\(num)",
            decorate: "decorate\(num)",
            floor: "floor\(num)",
            price: "\(num * 10000)",
            totalPrice: "\(num * 10000)",
            area: "\(num * 100)",
            compoundAddress: "compoundAddress\(num)",
            totalFloor: "\(num)",
            compoundName: "compoundName\(num)"
        )
    }
    
    static var moclList: [ReferenceCase] {
        [
            ReferenceCase(
                tradeType: "法拍",
                date: "2023-02-11",
                caseAddress: "杭州市余杭区良渚街道博园西路8号",
                decorate: "毛坯",
                floor: "高层",
                price: "20000",
                totalPrice: "20000",
                area: "200",
                compoundAddress: "杭州市余杭区良渚街道博园西路8号",
                totalFloor: "100",
                compoundName: "博园"
            ),
            ReferenceCase(
                tradeType: "挂牌",
                date: "2023-02-11",
                caseAddress: "浙江省杭州市余杭区行宫塘新苑西区",
                decorate: "中层",
                floor: "精装",
                price: "20000",
                totalPrice: "20000",
                area: "200",
                compoundAddress: "杭州市余杭区良渚街道博园西路8号",
                totalFloor: "100",
                compoundName: "博园"
            ),
            ReferenceCase(
                tradeType: "成交",
                date: "2023-02-11",
                caseAddress: "杭州市拱墅区莫干山 路与广业街交汇处",
                decorate: "简装",
                floor: "底层",
                price: "20000",
                totalPrice: "20000",
                area: "200",
                compoundAddress: "杭州市余杭区良渚街道博园西路8号",
                totalFloor: "100",
                compoundName: "博园"
            )
        ]
    }
}

extension Curve {
    static var mock: Curve {
        Curve(name: "测试",
              values: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2656.25],
//              xAxisLabels: ["2022-12", "2023-01", "2023-02", "2023-03", "2023-04", "2023-05", "2023-06", "2023-07", "2023-08", "2023-09", "2023-10", "2023-11"]
//              values: (0..<12).map { _ in Double.random(in: 0...1) },
              xAxisLabels: (1...12).map { "23-\(String(format: "%02d", $0))" }
        )
    }
}

extension AreaTree {
    static var mock: AreaTree {
        AreaTree(code: "0", name: "", children: [
            AreaTree(code: "320000", name: "江苏省", children: [
                AreaTree(code: "320100", name: "南京市", children: [
                    AreaTree(code: "320106", name: "鼓楼区", children: [])
                ])
            ]),
            AreaTree(code: "330000", name: "浙江省", children: [
                AreaTree(code: "330100", name: "杭州市", children: [
                    AreaTree(code: "310005", name: "临平区", children: [])
                ])
            ])
        ])
    }
}

extension Record {
    static var mock: Record {
        Record(
            page: .inquiry(SearchFilter()),
            id: 0,
            imageURL: "",
            inquiryType: .manual,
            district: "滨江区",
            estateType: .commApartment,
            address: "杭州市壹号院9幢1001室",
            clientName: "郑为",
            valuationDate: "2023-02-02",
            inquiryState: ._0,
            reportState: ._0,
            downloadState: ._1,
            totalPrice: "3149400", price: "39311", area: "80",
            roomId: "",
            buildingId: 0,
            provinceCode: 0,
            cityCode: 0,
            areaCode: 0,
            floor: "",
            contact: "",
            contactPhone: "",
            buildingYear: "",
            structure: ._1
        )
    }
}

extension CSComp {
    static var mock: [CSComp] {
        (0..<10).map { i in
            CSComp(name: "浙江估价公司--\(i)", depts: (0..<10).map { j in
                CSDept(id: 1, name: "杭州分公司-\(i)-\(j)")
            })
        }
    }
}

extension CSUser {
    static var mock: [CSUser] {
        (0..<10).map { CSUser(name: "刘强北-\($0)", link: nil)}
    }
}

extension Message {
    static var mock: [Message] {
        (0..<10).map { 
            Message(
                id: $0,
                content: Bool.random() ? (0..<80).map { _ in "长长长文字" }.joined(separator: "-") : "短文字",
                read: Bool.random(), date: Date().toString(),
                sender: "27168"
            )
        }
    }
}

extension MapCompound {
    static var mock: Self {
        MapCompound(name: "宝石小区", alias: "宝石小区", streetMark: "233号", north: "金祝小区", south: "金祝小区", east: "金祝小区", west: "金祝小区", location: "胜利",
//                    coordinate: Coordinate(latitude: 30.25301, longitude: 120.167998),
                    coordinate: nil,
                    picUrl: "https://image.xuboren.com/image/2023/10/11/ef3ca15d388940e6b21dc46d848d3905.jpg", familyRoomName: "", areaCode: 0, estateType: "", buildingId: 0, floor: "", compoundId: 0)
    }
}
