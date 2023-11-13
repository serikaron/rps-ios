//
//  rps_iosTests.swift
//  rps-iosTests
//
//  Created by serika on 2023/11/11.
//

import XCTest
@testable import rps_ios

final class rps_iosTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testDictType() async throws {
        // Linkman+mock.swift 测试数据
        
        Linkman.shared.standalone = true
        
        func test(type: String, key: String, value: String) async {
            let v = await DictType.valueOf(type: type, key: key)
            assert(v == value, "testDictType, expect value (\(value)) not match actual value (\(v))")
        }
        
        await test(type: "fv_estate_type", key: "industrialFactory", value: "工业厂房")
        await test(type: "fv_estate_type", key: "industrialSmallGarden", value: "工业小微园")
        await test(type: "fv_estate_type", key: "shopStreet", value: "临街商业")
        await test(type: "fv_estate_type", key: "landingRoom", value: "落地房")
        await test(type: "fv_estate_type", key: "office", value: "写字楼")
        await test(type: "fv_estate_type", key: "villa", value: "排屋别墅")
        await test(type: "fv_estate_type", key: "singleApartment", value: "商住公寓")
        await test(type: "fv_estate_type", key: "commApartment", value: "普通公寓")
    }
    
    func testJsonDynamicKey() throws {
       let json = """
    {
        "unitInfoResponseList": [
            {
                "keys": "d1r2",
                "type": "(2R)1单元",
                "order": "01",
                "allselection": [],
                "allselectionOjb": []
            },
            {
                "keys": "d1r3",
                "type": "(3R)1单元",
                "order": "02",
                "allselection": [],
                "allselectionOjb": []
            }
        ],
        "floorData": [
            {
                "allselection": [],
                "d1r2": {
                    "items": [
                        {
                            "fiFloorNum": 18,
                            "fvRoomNum": "02",
                            "fvRoomName": null,
                        }
                    ]
                },
                "d1r3": {
                    "items": [
                        {
                            "fiFloorNum": 18,
                            "fvRoomNum": "03",
                            "fvRoomName": null,
                        }
                    ]
                },
                "key": 18,
                "louceng": "18F"
            },
        ],
        "baseRoomData": []
    }
"""
        
        let buildingFloor = try json.data(using: .utf8)!.decoded() as Linkman.BuildingFloors
//        print(buildingFloor)
        print("OK")
        XCTAssertEqual(buildingFloor.floorData.count, 1)
        XCTAssertEqual(buildingFloor.unitInfoResponseList.map { $0.type }, ["(2R)1单元", "(3R)1单元"])
        XCTAssertEqual(buildingFloor.floorData[0].units.keys.map { $0 }, ["d1r2", "d1r3"])
        XCTAssertEqual(buildingFloor.floorData[0].units.values.map { $0.items[0].fvRoomNum }, ["02", "03"])
    }
}
