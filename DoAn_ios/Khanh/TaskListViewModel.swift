import Foundation
import SwiftUI
import Combine // Cần thiết cho @Published và Binding

// Định nghĩa các loại bộ lọc
enum TaskFilter {
    case all
    case completed // Đã hoàn thành
    case pending   // Chưa hoàn thành
}

class TaskListViewModel: ObservableObject {
    
    @Published var tasks: [Task] = []
    @Published var searchText: String = ""
    @Published private var currentFilter: TaskFilter = .all

    // --- LOGIC LỌC KẾT HỢP TÌM KIẾM VÀ TRẠNG THÁI ---
    var filteredTasks: [Task] {
        // 1. Lọc theo thanh tìm kiếm
        let searchedTasks = tasks.filter { task in
            searchText.isEmpty || task.title.localizedCaseInsensitiveContains(searchText)
        }
        
        // 2. Lọc theo trạng thái đã chọn
        switch currentFilter {
        case .all:
            return searchedTasks
        case .completed:
            return searchedTasks.filter { $0.isComplete }
        case .pending:
            return searchedTasks.filter { !$0.isComplete }
        }
    }

    // Hàm gọi từ View để thay đổi bộ lọc
    func setFilter(_ filter: TaskFilter) {
        self.currentFilter = filter
    }
    
    // Hàm gọi từ View để thay đổi trạng thái hoàn thành
    func toggleCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            // Tạo bản sao với trạng thái đảo ngược
            let updatedTask = Task(
                id: task.id,
                title: task.title,
                description: task.description,
                deadline: task.deadline,
                createAt: task.createAt,
                isComplete: !task.isComplete,
                tags: task.tags
            )
            tasks[index] = updatedTask
        }
    }
    
    // Giả lập tải dữ liệu ban đầu
    func loadTasks() {
        let sampleTags: [Tag] = [
            Tag(id: 1, name: "Học tập", color: .purple),
            Tag(id: 2, name: "Công việc", color: .blue),
            Tag(id: 3, name: "Cá nhân", color: .green)
        ]
        
        self.tasks = [
            Task(id: 101, title: "Công việc ngày mai", description: "Ôn tập SwiftUI", deadline: Calendar.current.date(byAdding: .day, value: 1, to: Date()), createAt: Date(), isComplete: false, tags: [sampleTags[0]]),
            Task(id: 102, title: "Hạn nộp báo cáo", description: "Báo cáo cuối kỳ", deadline: Calendar.current.date(byAdding: .day, value: 2, to: Date()), createAt: Date(), isComplete: true, tags: [sampleTags[1]]), // Đã hoàn thành
            Task(id: 103, title: "Đi siêu thị", description: "Mua đồ ăn", deadline: nil, createAt: Date(), isComplete: false, tags: [sampleTags[2]])
        ]
    }
}
