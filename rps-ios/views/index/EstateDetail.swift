//
//  EstateDetail.swift
//  rps-ios
//
//  Created by serika on 2023/11/27.
//

import SwiftUI

struct EstateDetailView : View {
    @Binding var detail: RoomDetail
    
    var body: some View {
        ScrollView {
            detailView
        }
        .onAppear {
            print(detail.estateType?.dictKey)
        }
    }
    
    var detailView: some View {
        switch detail.estateType {
        case .commApartment: 
            return CommApartmentDetailView(detail: $detail).earseToAnyView()
        case .singleApartment:
            return SingleApartmentDetailView(detail: $detail).earseToAnyView()
        default: return EmptyView().earseToAnyView()
        }
    }
}

private struct CommApartmentDetailView: View {
    @Binding var detail: RoomDetail
    
    var body: some View {
        VStack(spacing: 20) {
            section("特殊情况说明") {
                itemView(title: "小区特殊情况说明", keypath: \.compoundSpecialCircumstances)
                itemView(title: "楼幢特殊情况说明", keypath: \.buildingSpecialCircumstances)
                itemView(title: "户特殊情况说明", keypath: \.specialCircumstances)
            }
            section("户室具体情况") {
                itemView(title: "层高", keypath: \.height)
                itemView(title: "户型", keypath: \.typeOfHouse)
                itemView(title: "采光", keypath: \.daylighting)
                itemView(title: "噪声", keypath: \.noise)
                itemView(title: "装修评分", keypath: \.decoration)
                itemView(title: "主要景观因素", keypath: \.landscape)
                itemView(title: "花园", keypath: \.garden)
                itemView(title: "露台", keypath: \.terrace)
                itemView(title: "阁楼", keypath: \.attic)
                itemView(title: "地下室", keypath: \.basement)
            }
            section("小区区划信息") {
                itemView(title: "地市", keypath: \.compoundCityName)
                itemView(title: "区县", keypath: \.compoundAreaName)
                itemView(title: "镇/街道", keypath: \.compoundSubdistrictName)
                itemView(title: "村/社区", keypath: \.compoundCompoundName)
                itemView(title: "小区名称", keypath: \.compoundCompoundName)
            }
            section("小区位置信息") {
                itemView(title: "东至", keypath: \.compoundToEast)
                itemView(title: "南至", keypath: \.compoundToSouth)
                itemView(title: "西至", keypath: \.compoundToWest)
                itemView(title: "北至", keypath: \.compoundToNorth)
                itemView(title: "路牌号", keypath: \.compoundStreetMark)
                itemView(title: "界址街牌", keypath: \.compoundAddrMark)
                itemView(title: "相邻小区", keypath: \.compoundAdjacentEstate)
                itemView(title: "图丘号", keypath: \.compoundLandNo)
                itemView(title: "所处商圈", keypath: \.compoundBusinessDistrict)
                itemView(title: "所处板块", keypath: \.compoundPlate)
            }
            section("小区概况信息") {
                itemView(title: "小区类型", keypath: \.estateTypeLabel)
                itemView(title: "房屋性质", keypath: \.compoundProperty)
                itemView(title: "建成年份", keypath: \.compoundCompletionDate)
                itemView(title: "开发商名称", keypath: \.compoundDeveloper)
                itemView(title: "施工方", keypath: \.compoundConstruction)
                itemView(title: "销售代理公司", keypath: \.compoundSaleCompany)
                itemView(title: "售楼地址", keypath: \.compoundSaleAddress)
                itemView(title: "售楼电话", keypath: \.compoundSalePhoneno)
                itemView(title: "销售时间", keypath: \.compoundSaleTime)
            }
            section("小区建筑信息") {
                itemView(title: "总建筑面积", content: "")
                itemView(title: "住宅面积", keypath: \.compoundResidentialArea)
                itemView(title: "总户数", content: "")
                itemView(title: "住宅幢数", keypath: \.compoundBuildingNumber)
                itemView(title: "幢数描述", keypath: \.compoundBuildingDesc)
                itemView(title: "建筑类型", keypath: \.compoundBuildingType)
                itemView(title: "建筑结构", keypath: \.compoundBuildingStructure)
                itemView(title: "建筑密度", keypath: \.compoundBuildingDensity)
                itemView(title: "绿化率", keypath: \.compoundGreeningRate)
                itemView(title: "容积率", keypath: \.compoundVolumeRate)
            }
            section("小区土地信息") {
                itemView(title: "土地面积", keypath: \.compoundLandAreaString)
                itemView(title: "使用权类型", keypath: \.compoundLandUserLabel)
                itemView(title: "土地级别", keypath: \.compoundLandLevelLabel)
            }
            section("小区交通配套") {
                itemView(title: "外围交通干道", keypath: \.compoundOutsideMainRoad)
                itemView(title: "内部道路交通", keypath: \.compoundInternalRoad)
                itemView(title: "公交站距离", keypath: \.compoundBusStopDistance)
                itemView(title: "公交线路条数", keypath: \.compoundBusLineNumber)
                itemView(title: "公交线路名称", keypath: \.compoundBusLine)
                itemView(title: "快速公交", keypath: \.compoundFastBus)
                itemView(title: "地铁站距离", keypath: \.compoundSubwayDistance)
                itemView(title: "地铁线路名称", keypath: \.compoundSubway)
            }
            section("小区外部配套") {
                itemView(title: "小区附近菜场", keypath: \.compoundVegeMarket)
                itemView(title: "社区商业配套", keypath: \.compoundBusinessMating)
                itemView(title: "社区商业配套", keypath: \.compoundBusinessMating)
                itemView(title: "小区附近金融机构", keypath: \.compoundFinaceOrg)
                itemView(title: "小区附近文体场馆", keypath: \.compoundStadium)
                itemView(title: "小区附近行政办公单位", keypath: \.compoundAdminOffice)
                itemView(title: "小区附近幼儿园", keypath: \.compoundKindergarten)
                itemView(title: "小区附近小学", keypath: \.compoundPrimarySchool)
                itemView(title: "小区附近中学", keypath: \.compoundMiddleSchool)
                itemView(title: "小区附近大学", keypath: \.compoundUniversity)
                itemView(title: "小区附近医院", keypath: \.compoundHospital)
            }
            section("小区内部配套") {
                itemView(title: "会所及会所提供的服务", keypath: \.compoundClubServise)
                itemView(title: "运动设施", keypath: \.compoundSportStructure)
                itemView(title: "休闲设施", keypath: \.compoundFallowStructure)
                itemView(title: "停车泊位数量", keypath: \.compoundParking)
                itemView(title: "停车泊位类型", keypath: \.compoundParkingType)
                itemView(title: "停车泊位配比", keypath: \.compoundParkingRate)
                itemView(title: "小区基础设施", keypath: \.compoundBaseFacility)
            }
        }
    }
    
    private func itemView(title: String, content: String?) -> some View {
        _ItemView(title: title, content: content)
    }
    
    private func itemView(title: String, keypath: KeyPath<RoomDetail, String>) -> some View {
        _ItemView(title: title, content: detail[keyPath: keypath])
    }
    
    private func section(_ sectionTitle: String, @ViewBuilder _ builder: @escaping () -> some View) -> some View {
        _Section(sectionTitle) {
            builder()
        }
    }
}

private struct SingleApartmentDetailView: View {
    @Binding var detail: RoomDetail
    
    var body: some View {
        VStack(spacing: 20) {
            section("特殊情况说明") {
                itemView(title: "小区特殊情况说明", keypath: \.compoundSpecialCircumstances)
                itemView(title: "楼幢特殊情况说明", keypath: \.buildingSpecialCircumstances)
                itemView(title: "户特殊情况说明", keypath: \.specialCircumstances)
            }
            section("户室具体情况") {
                itemView(title: "层高", keypath: \.height)
                itemView(title: "户型", keypath: \.typeOfHouse)
                itemView(title: "采光", keypath: \.daylighting)
                itemView(title: "噪声", keypath: \.noise)
                itemView(title: "装修评分", keypath: \.decoration)
                itemView(title: "主要景观因素", keypath: \.landscape)
            }
            section("小区区划信息") {
                itemView(title: "地市", keypath: \.compoundCityName)
                itemView(title: "区县", keypath: \.compoundAreaName)
                itemView(title: "镇/街道", keypath: \.compoundSubdistrictName)
                itemView(title: "项目名称", keypath: \.compoundCompoundName)
                itemView(title: "项目别名", keypath: \.compoundNameAlias)
            }
            section("小区位置信息") {
                itemView(title: "东至", keypath: \.compoundToEast)
                itemView(title: "南至", keypath: \.compoundToSouth)
                itemView(title: "西至", keypath: \.compoundToWest)
                itemView(title: "北至", keypath: \.compoundToNorth)
                itemView(title: "路牌号", keypath: \.compoundStreetMark)
                itemView(title: "界址街牌", keypath: \.compoundAddrMark)
                itemView(title: "相邻小区", keypath: \.compoundAdjacentEstate)
                itemView(title: "图丘号", keypath: \.compoundLandNo)
                itemView(title: "所处商圈", keypath: \.compoundBusinessDistrict)
                itemView(title: "商圈级别", keypath: \.compoundBusinessLevel)
                itemView(title: "所处板块", keypath: \.compoundPlate)
            }
            section("项目概况信息") {
                itemView(title: "项目类型", keypath: \.estateTypeLabel)
                itemView(title: "房屋性质", keypath: \.compoundProperty)
                itemView(title: "建成年份", keypath: \.compoundCompletionDate)
                itemView(title: "开发商名称", keypath: \.compoundDeveloper)
                itemView(title: "施工方", keypath: \.compoundConstruction)
                itemView(title: "销售代理公司", keypath: \.compoundSaleCompany)
                itemView(title: "售楼地址", keypath: \.compoundSaleAddress)
                itemView(title: "售楼电话", keypath: \.compoundSalePhoneno)
                itemView(title: "销售时间", keypath: \.compoundSaleTime)
            }
            section("项目建筑信息") {
                itemView(title: "总建筑面积", content: "")
                itemView(title: "住宅面积", keypath: \.compoundResidentialArea)
                itemView(title: "总户数", content: "")
                itemView(title: "单身公寓柠数", keypath: \.compoundBuildingNumber)
                itemView(title: "幢数描述", keypath: \.compoundBuildingDesc)
                itemView(title: "建筑类型", keypath: \.compoundBuildingType)
                itemView(title: "建筑结构", keypath: \.compoundBuildingStructure)
                itemView(title: "建筑密度", keypath: \.compoundBuildingDensity)
                itemView(title: "绿化率", keypath: \.compoundGreeningRate)
                itemView(title: "容积率", keypath: \.compoundVolumeRate)
                itemView(title: "得房率", keypath: \.compoundGetHouseRate)
            }
            section("项目土地信息") {
                itemView(title: "土地面积", keypath: \.compoundLandAreaString)
                itemView(title: "使用权类型", keypath: \.compoundLandUserLabel)
                itemView(title: "土地级别", keypath: \.compoundLandLevelLabel)
            }
            section("项目交通配套") {
                itemView(title: "距离CBD距离", keypath: \.compoundCbdDistance)
                itemView(title: "距离城市景观距离", content: "")
                itemView(title: "沿路倩况", keypath: \.compoundRoadEnvi)
                itemView(title: "道路等级", keypath: \.compoundRoadLevel)
                itemView(title: "外围交通干道", keypath: \.compoundOutsideMainRoad)
                itemView(title: "内部道路交通", keypath: \.compoundInternalRoad)
                itemView(title: "公交站距离", keypath: \.compoundBusStopDistance)
                itemView(title: "公交线路条数", keypath: \.compoundBusLineNumber)
                itemView(title: "公交线路名称", keypath: \.compoundBusLine)
                itemView(title: "快速公交", keypath: \.compoundFastBus)
                itemView(title: "地铁站距离", keypath: \.compoundSubwayDistance)
                itemView(title: "地铁线路名称", keypath: \.compoundSubway)
            }
            section("项目外部配套") {
                itemView(title: "项目附近菜场", keypath: \.compoundVegeMarket)
                itemView(title: "项目附近大型超市商场", keypath: \.compoundBusinessSet)
                itemView(title: "项目附近金融机构", keypath: \.compoundFinaceOrg)
                itemView(title: "项目附近文体场馆", keypath: \.compoundStadium)
                itemView(title: "项目附近行政办公单位", keypath: \.compoundAdminOffice)
                itemView(title: "项目附近幼儿园", keypath: \.compoundKindergarten)
                itemView(title: "项目附近小学", keypath: \.compoundPrimarySchool)
                itemView(title: "项目附近中学", keypath: \.compoundMiddleSchool)
                itemView(title: "项目附近大学", keypath: \.compoundUniversity)
                itemView(title: "项目附近医院", keypath: \.compoundHospital)
            }
            section("项目内部配套") {
                itemView(title: "项目内商业配套", keypath: \.compoundBusinessMating)
                itemView(title: "会所及会所提供的服务", keypath: \.compoundClubServise)
                itemView(title: "运动设施", keypath: \.compoundSportStructure)
                itemView(title: "休闲设施", keypath: \.compoundFallowStructure)
                itemView(title: "停车泊位数量", keypath: \.compoundParking)
                itemView(title: "停车泊位类型", keypath: \.compoundParkingType)
                itemView(title: "停车泊位配比", keypath: \.compoundParkingRate)
                itemView(title: "项目基础设施", keypath: \.compoundBaseFacility)
            }
            section("项目环境信息") {
                itemView(title: "项目外环境", keypath: \.compoundOutEnvi)
                itemView(title: "项目内环境", keypath: \.compoundInEnvi)
                itemView(title: "空气污染", keypath: \.compoundPollution2)
                itemView(title: "噪音污染", keypath: \.compoundPollution)
                itemView(title: "其他污染", keypath: \.compoundOtherPolu)
                itemView(title: "其他影响因素", keypath: \.compoundOtherFactor)
            }
            section("项目物业信息") {
                itemView(title: "项目是香封闭", keypath: \.compoundIsClose)
                itemView(title: "物业管理种类", keypath: \.compoundPropertyManageType)
                itemView(title: "物业管理公司名称", keypath: \.compoundPropertyCompany)
                itemView(title: "物业费", keypath: \.compoundPropertyFee)
            }
        }
    }
    
    private func itemView(title: String, content: String?) -> some View {
        _ItemView(title: title, content: content)
    }
    
    private func itemView(title: String, keypath: KeyPath<RoomDetail, String>) -> some View {
        _ItemView(title: title, content: detail[keyPath: keypath])
    }
    
    private func section(_ sectionTitle: String, @ViewBuilder _ builder: @escaping () -> some View) -> some View {
        _Section(sectionTitle) {
            builder()
        }
    }
}

private struct _ItemView: View {
    let title: String
    let content: String?
    
    var body: some View {
        HStack {
            titleText("\(title):")
            valueText(content ?? "")
            Spacer()
        }
    }
    
    private func titleText(_ text: String) -> some View {
        Text(text)
            .customText(size: 14, color: .text.gray6)
    }
    
    private func valueText(_ text: String) -> some View {
        Text(text)
            .customText(size: 14, color: .text.gray3)
    }
}

private struct _Section<Content: View>: View {
    let sectionTitle: String
    @ViewBuilder var builder: () -> Content
    
    init(_ sectionTitle: String, @ViewBuilder _ builder: @escaping () -> Content) {
        self.sectionTitle = sectionTitle
        self.builder = builder
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text(sectionTitle).headerText()
            builder()
        }
    }
}

#Preview {
    EstateDetailView(detail: .constant(.previewFor(estateType: .singleApartment)))
}

private extension RoomDetail {
    static func previewFor(estateType: DictType.EstateType) -> Self {
        var out = Self.mock
        out.estateType = estateType
        return out
    }
}