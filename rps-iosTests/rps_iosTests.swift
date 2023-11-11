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
}
