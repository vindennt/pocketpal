//
//  DataService.swift
//  pocketpal
//
//  Created by Dennis Truong on 2025-06-08.
//

import Foundation
import SwiftUI

struct DataService {
    @AppStorage("selectedId", store: UserDefaults(
        suiteName: "group.com.vindennt.pocketpal")) var selectedId = 25

    func getId() -> Int {
        return selectedId
    }
}
