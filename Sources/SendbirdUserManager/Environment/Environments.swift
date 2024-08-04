//
//  Environments.swift
//
//
//  Created by 박종상 on 8/4/24.
//

import Foundation

enum Environment {
    // 앱 그룹으로 진행해야하나?
    @UserDefault(key: "com.sendbird.usermanager.appid", defaultValue: "", userDefaults: .standard)
    static var appId: String
}
