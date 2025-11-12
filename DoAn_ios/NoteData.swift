//
//  NoteData.swift
//  DoAn_ios
//
//  Created by  User on 09.11.2025.
//

import Foundation

// Model dữ liệu cho 1 ghi chú
 struct NoteData: Codable, Identifiable {
    var id:Int
    var title: String
    var content: String
    var date: Date
    var isCompleted: Int = 0
    var isGhim: Int = 0

    // Hàm định dạng ngày hiển thị
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}
