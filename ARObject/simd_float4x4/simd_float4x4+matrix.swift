//
//  simd_float4x4+matrix.swift
//  ARObject
//
//  Created by Bogdan Petkanych on 28.07.2024.
//

import Foundation
import simd

extension simd_float4 {
  static let zero = simd_float4(0, 0, 0, 0)
}

extension simd_float4x4 {
  
  static let identityMatrix = simd_float4x4(diagonal: simd_float4(1, 1, 1, 1))
  
  static func makeTranslation(tx: Float, ty: Float, tz: Float) -> Self {
    let translation = simd_float4(simd_float3(tx, ty, tz), 1)
    return self.identityMatrix + simd_float4x4(columns: (simd_float4.zero, simd_float4.zero, simd_float4.zero, translation))
  }
  
  static func translation(m: simd_float4x4, tx: Float, ty: Float, tz: Float) -> Self {
    let translation = m * simd_float4(simd_float3(tx, ty, tz), 0)
    return m + simd_float4x4(columns: (simd_float4.zero, simd_float4.zero, simd_float4.zero, translation))
  }
  
  static func makeScale(sx: Float, sy: Float, sz: Float) -> Self {
    simd_float4x4(diagonal: simd_float4(sx, sy, sz, 1))
  }
  
  static func sclale(m: simd_float4x4, sx: Float, sy: Float, sz: Float) -> Self {
    let nm = simd_float4x4(diagonal: simd_float4(sx, sy, sz, 1))
    return m * nm
  }
  
  static func makeRotate(radian: Float, axis: simd_float3) -> Self {
    let axis = normalize(axis)
    let c = cos(radian)
    let s = sin(radian)
    return simd_float4x4(
      simd_float4(simd_float3(x: c + axis.x * axis.x * (1 - c), y: axis.y * axis.x * (1 - c) + axis.z * s, z: axis.z * axis.x * (1 - c) - axis.y * s), 0),
      simd_float4(simd_float3(x: axis.x * axis.y * (1 - c) - axis.z * s, y: c + axis.y * axis.y * (1 - c), z: axis.z * axis.y * (1 - c) + axis.x * s), 0),
      simd_float4(simd_float3(x: axis.x * axis.z * (1 - c) + axis.y * s, y: axis.y * axis.z * (1 - c) - axis.x * s, z: c + axis.z * axis.z * (1 - c)), 0),
      simd_float4(simd_float3(x: 0, y: 0, z: 0), 1)
    )
  }
  
  var position: simd_float3 {
    let position = self * simd_float4(simd_float3(repeating: 0), 1)
    return simd_float3(x: position.x, y: position.y, z: position.z)
  }
  
  var scale: simd_float3 {
    simd_float3(x: length(columns.0), y: length(columns.1), z: length(columns.2))
  }
}
