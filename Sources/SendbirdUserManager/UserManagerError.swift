//
//  UserManagerError.swift
//
//
//  Created by 박종상 on 8/6/24.
//

import Foundation

public enum UserManagerError: Error {
    case createUsersFailed([SBUser])
    case emptyNickname
}
