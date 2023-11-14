//
//  Linkman+mock.swift
//  rps-ios
//
//  Created by serika on 2023/11/11.
//

import Foundation

extension Linkman.GetInfoResponse {
    static var mock: Linkman.GetInfoResponse {
        return Linkman.GetInfoResponse(user: Linkman.NetworkUser(
            id: 0,
            fiOrgId: 0
        ))
    }
}

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
//            fvToEast: "",
//            fvToSouth: "",
//            fvToWest: "",
//            fvToNorth: "",
//            fvAreaLocation: "7",
//            picUrls: "https://image.xuboren.com/image/2023/10/11/ef3ca15d388940e6b21dc46d848d3905.jpg",
            picUrls: "",
            fvCompletionDate: "2001"
//            fvPois: null,
//            fiOrgId: 294,
//            fvProvinceName: "浙江省",
//            fvCityName: "杭州市",
//            fvAreaName: "西湖区",
//            fvSubdistrictName: "三墩镇",
//            fvEstateState: "4"
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
            picUrls: "https://image.xuboren.com/image/2023/10/11/ef3ca15d388940e6b21dc46d848d3905.jpg",
            fvCompletionDate: "\(num)"
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
                            estateType: "singleApartment"
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
            fvFamilyRoomName: "杭州市壹号院9幢1001室",
            fvProvinceName: "浙江省",
            fvCityName: "杭州市",
            fvAreaName: "西湖区",
            fvSubdistrictName: "翠苑街道",
            fvEstateType: "shopStreet",
            estateTypeLabel: "临街商铺",
            fvLandUser: nil,
            fvCompletionDate: "2001",
//            position: "无",
            fvBuildingStructure: "钢混结构",
            fvOrientation: "西北",
            fvFloorHeight: "12",
            fvInFloor: "1-1",
            fvHouseProperty: nil,
            fvHousingUse: nil
        )
    }
}
