import Foundation
// MARK: - 1. Cấu trúc TAG
// Lưu trữ thông tin chi tiết về từng thẻ/danh mục
struct Tag: Codable, Identifiable {
    var id: Int
    var name: String
    var color: String
}

// MARK: - 2. Cấu trúc
struct LinkTag: Codable {
    var tagID: Int
    var notesID: Int
}
