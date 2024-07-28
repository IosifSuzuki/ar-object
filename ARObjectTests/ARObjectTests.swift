//
//  ARObjectTests.swift
//  ARObjectTests
//
//  Created by Bogdan Petkanych on 28.07.2024.
//

import XCTest
import SceneKit
@testable import ARObject

final class ARObjectTests: XCTestCase {
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testSIMDTranslation() {
    var matrix = simd_float4x4.translation(m: .identityMatrix, tx: 10, ty: 0, tz: 0)
    matrix = simd_float4x4.translation(m: matrix, tx: 20, ty: -10, tz: 0)
    matrix = simd_float4x4.translation(m: matrix, tx: -10, ty: 5, tz: 100)
    XCTAssert(matrix.position == simd_float3(x: 20, y: -5, z: 100), "wrong position")
  }
  
  func testSIMDScale() {
    var matrix = simd_float4x4.sclale(m: .identityMatrix, sx: 2, sy: 2, sz: 2)
    matrix = simd_float4x4.sclale(m: matrix, sx: 2, sy: 2, sz: 2)
    XCTAssert(matrix.scale == simd_float3(x: 4, y: 4, z: 4), "wrong scaling")
  }
  
}
