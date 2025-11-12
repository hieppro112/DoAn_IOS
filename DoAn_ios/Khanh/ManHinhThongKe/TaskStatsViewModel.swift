import Foundation
import SwiftUI

// Cấu trúc dữ liệu đơn giản để lưu kết quả tính toán thống kê
struct TaskStats {
    let totalTasks: Int
    let completedTasks: Int
    let pendingTasks: Int
    let completionRate: Double // Tỷ lệ hoàn thành (0.0 đến 1.0)
    
    // ✅ Hàm khởi tạo mặc định được giữ lại
    init(totalTasks: Int = 0, completedTasks: Int = 0, pendingTasks: Int = 0, completionRate: Double = 0.0) {
        self.totalTasks = totalTasks
        self.completedTasks = completedTasks
        self.pendingTasks = pendingTasks
        self.completionRate = completionRate
    }
}

class TaskStatsViewModel: ObservableObject {
    
    // Khởi tạo đúng cách
    @Published var stats: TaskStats = TaskStats()

    // Hàm tính toán chính (nhận mảng NoteData)
    func calculateStats(from allNotes: [NoteData]) {
        
        //  Giả định NoteData có trường isCompleted kiểu Int (0/1)
        let completed = allNotes.filter { $0.isCompleted == 1 }.count
        let total = allNotes.count
        let pending = total - completed
        
        // Tính tỷ lệ hoàn thành
        let rate = total > 0 ? Double(completed) / Double(total) : 0.0
        
        // Cập nhật stats
        self.stats = TaskStats(
            totalTasks: total,
            completedTasks: completed,
            pendingTasks: pending,
            completionRate: rate
        )
    }
}
