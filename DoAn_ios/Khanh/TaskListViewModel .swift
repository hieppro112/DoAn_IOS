import Foundation
import SwiftUI
import Combine

enum TaskFilter {
    case all, completed, pending
}

class TaskListViewModel: ObservableObject {

    @Published var notes: [NoteData] = []
    @Published var searchText: String = ""
    @Published private var currentFilter: TaskFilter = .all
    @Published private var allTags: [Tag] = []

    // Chỉ lọc theo tìm kiếm và trạng thái, không bắt buộc có tag
    var filteredNotes: [NoteData] {
        let searched = notes.filter { note in
            // Không bắt buộc có tag
            let matchesSearch = searchText.isEmpty || note.title.localizedCaseInsensitiveContains(searchText)
            return matchesSearch
        }

        // Lọc theo trạng thái đã chọn (Completed/Pending)
        switch currentFilter {
        case .all:
            return searched
        case .completed:
            return searched.filter { $0.isCompleteBool }
        case .pending:
            return searched.filter { !$0.isCompleteBool }
        }
    }

    func setFilter(_ filter: TaskFilter) {
        currentFilter = filter
    }

    // Hàm tải dữ liệu (vẫn gán tag nếu có)
    func loadTasks() {
        self.allTags = DatabaseManager.shared.fetchAllTags()
        var loadedNotes = DatabaseManager.shared.fetchAllNotes()
        
        // Gán tag cho từng note nếu có tagID
        for i in 0..<loadedNotes.count {
            let note = loadedNotes[i]
            if let tagID = note.tagID,
               let matchedTag = allTags.first(where: { $0.id == tagID }) {
                
                loadedNotes[i].tags = [matchedTag]
            }
        }
        self.notes = loadedNotes
    }

    func toggleCompletion(note: NoteData) {
        let newStatus = note.isCompleted == 0 ? 1 : 0
        var updatedNote = note
        updatedNote.isCompleted = newStatus
        
        DatabaseManager.shared.updateNote(note: updatedNote)
        loadTasks() // Tải lại để View cập nhật
    }
}
