//
//  Models.swift
//  DoAn_ios
//
//  Created by  User on 08.11.2025.
//

import Foundation
import SwiftUI

// 1. Tag Model (Từ bảng 'tags')
struct Tag: Identifiable {
    let id: Int           // tagID
    let name: String      // name
    let color: Color      // color (Sử dụng Color của SwiftUI)
}

// 2. Task Model (Từ bảng 'notes' + liên kết 'tags')
struct Task: Identifiable {
    let id: Int           // notesID
    let title: String     // title
    let description: String // descripsion
    let deadline: Date?   // deadline
    let createAt: Date    // create_at
    let isComplete: Bool  // is_Complete
    let tags: [Tag]       // Danh sách Tags đã được JOIN
}
