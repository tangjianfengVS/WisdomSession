//
//  Safer.swift
//  iOS-BasicLibs
//
//  Created by ztgame on 2026/3/10.
//

import Foundation


// 封装 Any 为 Sendable 合规类型
final public class WisdomSessionSafer: @unchecked Sendable {

    private var _value: Any
    
    public var value: Any {
        get { return _value }
        set { _value = newValue }
    }
    
    // 初始化：直接传入任意类型
    public init(value: Any) {
        self._value = value
    }
}
