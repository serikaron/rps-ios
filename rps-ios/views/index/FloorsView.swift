//
//  FloorsView.swift
//  rps-ios
//
//  Created by serika on 2023/11/12.
//

import SwiftUI

struct FloorsView: View {
    @EnvironmentObject var estateService: EstateService
    
    private var floors: Floors {
        estateService.floors
    }
    
    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            VStack(alignment: .leading, spacing: 0) {
                header
                content
            }
            .border(Color.border)
        }
        .frame(width: 250, height: 270)
        .padding(.init(top: 26, leading: 26, bottom: 15, trailing: 40))
        .background(Color.white)
        .cornerRadius(8)
        .overlay (
            Image.index.close
                .padding(.top, 10)
                .padding(.trailing, 10)
            , alignment: .topTrailing
        )
    }
    
    private var header: some View {
        HStack(spacing: 0) {
            RoomText(text: "楼层", width: 50, height: 75)
            VStack(spacing: 0) {
                RoomText(text: floors.buildingName, width: 200, height: 35)
                    .frame(height: 35)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 0) {
                    ForEach(floors.unitTitles, id: \.self) { title in
                        (floors.unitTitles.count >= 4) 
                        ? RoomText(text: title, width: 50, height: 40)
                        : RoomText(text: title,
                                 height: 40,
                                 maxWidth: 200, minWidth: 50
                        )
                    }
                }
            }
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(zip(floors.floors.indices, floors.floors)), id: \.0) { _, floor in
                view(for: floor)
            }
        }
    }
    
    private func view(for floor: Floor) -> some View {
        HStack(spacing: 0) {
            RoomText(text: floor.name, width: 50, height: 40)
            ForEach(Array(zip(floor.rooms.indices, floor.rooms)), id: \.0) { _, room in
                NavigationLink {
                    RoomDetailView(
                        familyRoomName: room.familyRoomName,
                        areaCode: room.areaCode,
                        estateType: room.estateType,
                        buildingId: room.buildingId,
                        area: "",
                        dataOrgId: nil,
                        floor: room.floor
                    )
                        .environmentObject(estateService)
                } label: {
                    Group {
                        floor.rooms.count >= 4
                        ? RoomText(text: room.name, width: 50, height: 40)
                        : RoomText(text: room.name,
                                   height: 40,
                                   maxWidth: 200, minWidth: 50
                        )
                    }
                    .background(Color.white)
                }
            }
        }
    }
}

private struct RoomText: View {
    let text: String
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var maxWidth: CGFloat? = nil
    var minWidth: CGFloat? = nil
    
    var body: some View {
        Text(text)
            .lineLimit(1)
            .customText(size: 14, color: .text.gray6)
            .frame(width: width, height: height)
            .frame(minWidth: minWidth, maxWidth: maxWidth)
            .border(Color.border, width: 1)
    }
}

private extension Color {
    static var border: Color {
        .hex("#F3F3F3")
    }
}

#Preview {
    Group {
        PreviewView(unitCount: 1)
        PreviewView(unitCount: 5)
    }
}

#Preview("online") {
    Box.setToken("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsb2dpblR5cGUiOiJsb2dpbiIsImxvZ2luSWQiOiJycHNfdXNlcjo0MCIsInJuU3RyIjoibmZKT1dHcVYwNXFQd01qQXpSVjAyZTN5WDZGYXNsblQiLCJ1c2VySWQiOjQwfQ.qXqGFyWUOdhkUIE4AhjB5wB1zwOxQ0sG7v4XQahdpEQ")
    return FloorsView()
        .environmentObject( EstateService().loadFloors() )
        .previewLayout(.sizeThatFits)
}

fileprivate extension EstateService {
    func setPreview(data: Floors) -> EstateService {
        self.floors = data
        return self
    }
    
    func loadFloors() -> EstateService {
        Task {
            await getFloors(
                buildingName: "黎明东路65号",
                buildingId: 1,
                estateType: "singleApartment",
                areaCode: 330106
            )
        }
        return self
    }
}

fileprivate struct PreviewView: View {
    let floorCount = 6
    let unitCount: Int
    
    var body: some View {
        ZStack {
            Color.black
            FloorsView()
                .environmentObject(
                    EstateService.preview
                        .setPreview(data: .mock(floorCount: floorCount, unitCount: unitCount))
                )
                .previewLayout(.sizeThatFits)
        }
    }
}
