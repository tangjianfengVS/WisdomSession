//
//  Safer.swift
//  iOS-BasicLibs
//
//  Created by ztgame on 2026/3/10.
//

import Foundation


// 封装 Any 为 Sendable 合规类型
public struct WisdomSessionAny: @unchecked Sendable {

    public var anyValue: Any
    
    // 初始化：直接传入任意类型
    public init(anyValue: Any) {
        self.anyValue = anyValue
    }
}
