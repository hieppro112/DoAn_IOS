import Foundation
import FMDB

class DatabaseManager {
    static let shared = DatabaseManager()
    private let databaseFileName = "notes.sqlite"
    private var database: FMDatabase?

    private init() {
        openDatabase()
        createTableIfNeeded()
    }

    // Mở (hoặc tạo mới) database
    private func openDatabase() {
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(databaseFileName)
            
        database = FMDatabase(url: fileURL)
    }

    // Tạo các bảng nếu chưa có
    private func createTableIfNeeded() {
        guard let db = database, db.open() else { return }
        
        // Bảng NOTES (giữ nguyên)
        let createNotesTableSQL = """
        CREATE TABLE IF NOT EXISTS notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            date TEXT,
            isCompleted INTEGER DEFAULT 1
        )
        """
        
        // Bảng TAGS (Lưu danh sách nhãn dán)
        let createTagsTableSQL = """
        CREATE TABLE IF NOT EXISTS tags (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            color TEXT NOT NULL
        )
        """
        
        // Bảng LINK_TAGS (Liên kết Note (N:N) với Tag)
        let createLinkTagsTableSQL = """
        CREATE TABLE IF NOT EXISTS link_tags (
            tagID INTEGER,
            notesID INTEGER,
            PRIMARY KEY (tagID, notesID),
            FOREIGN KEY (tagID) REFERENCES tags(id) ON DELETE CASCADE,
            FOREIGN KEY (notesID) REFERENCES notes(id) ON DELETE CASCADE
        )
        """
        
        do {
            try db.executeUpdate(createNotesTableSQL, values: nil)
            try db.executeUpdate(createTagsTableSQL, values: nil)
            try db.executeUpdate(createLinkTagsTableSQL, values: nil)
        } catch {
            print(" Lỗi tạo bảng:", error.localizedDescription)
        }
        db.close()
    }

    // MARK: - Note Management (Đã bỏ các hàm cũ, chỉ giữ lại hàm mới dùng NoteData)
    
    // Thêm ghi chú
    func insertNote(note: NoteData) {
        guard let db = database, db.open() else { return }
        let dateStr = stringFromDate(note.date)
        let sql = "INSERT INTO notes (title, content, date, isCompleted) VALUES (?, ?, ?, ?)"
        
        var lastRowId: Int = 0
        
        do {
            try db.executeUpdate(sql, values: [note.title, note.content, dateStr, note.isCompleted])
            lastRowId = Int(db.lastInsertRowId) // Lấy ID của note vừa chèn
        } catch {
            print("Lỗi thêm note:", error.localizedDescription)
        }
        
        if lastRowId > 0 {
            // Chèn các liên kết (LinkTags) cho note vừa chèn
            for tag in note.tags {
                insertLinkTag(notesID: lastRowId, tagID: tag.id)
            }
        }
        
        db.close()
    }

    // Lấy tất cả ghi chú
    func fetchAllNotes() -> [NoteData] {
        var notes: [NoteData] = []
        guard let db = database, db.open() else { return [] }

        let sql = "SELECT * FROM notes ORDER BY date DESC, isCompleted DESC"
        do {
            let results = try db.executeQuery(sql, values: nil)
            while results.next() {
                let noteID = Int(results.int(forColumn: "id"))
                
                // Truy vấn các Tags liên kết với Note này
                let associatedTags = fetchTags(for: noteID)
                
                let note = NoteData(
                    id: noteID,
                    title: results.string(forColumn: "title") ?? "",
                    content: results.string(forColumn: "content") ?? "",
                    date: ISO8601DateFormatter().date(from: results.string(forColumn: "date") ?? "") ?? Date(),
                    isCompleted: Int(results.int(forColumn: "isCompleted")),
                    tags: associatedTags
                )
                notes.append(note)
            }
        } catch {
            print(" Lỗi truy vấn:", error.localizedDescription)
        }
        db.close()
        return notes
    }

    // Xoá ghi chú
    func deleteNote(id: Int) {
        guard let db = database, db.open() else { return }
        let sql = "DELETE FROM notes WHERE id = ?"
        do {
            try db.executeUpdate(sql, values: [id])
            print("xoá thành công item id : \(id)")
        } catch {
            print(" Lỗi xoá:", error.localizedDescription)
        }
    db.close()
    }
        
    // Cập nhật ghi chú
    func updateNote(note: NoteData) {
        guard let db = database, db.open() else { return }
        let dateStr = stringFromDate(note.date)
        
        // 1. Xóa toàn bộ liên kết Tag cũ của Note này
        deleteAllLinkTags(for: note.id)
        
        // 2. Chèn lại các liên kết Tag mới
        for tag in note.tags {
            insertLinkTag(notesID: note.id, tagID: tag.id)
        }
        
        // 3. Cập nhật các trường dữ liệu chính của Note
        let sql = """
            UPDATE notes
            SET title = ?, content = ?, date = ?, isCompleted = ?
            WHERE id = ?
        """
        do {
            try db.executeUpdate(sql, values: [note.title, note.content, dateStr, note.isCompleted, note.id])
            print("Cập nhật note id=\(note.id) thành công")
        } catch {
            print(" Lỗi khi cập nhật note:", error.localizedDescription)
        }
        db.close()
    }

    // Cập nhật chỉ trạng thái hoàn thành
    func updateNoteCompletion(id: Int, isCompleted: Int) {
        guard let db = database, db.open() else { return }
        let sql = "UPDATE notes SET isCompleted = ? WHERE id = ?"
        do {
            try db.executeUpdate(sql, values: [isCompleted, id])
            print("Cập nhật trạng thái thành công cho note id=\(id)")
        } catch {
            print(" Lỗi cập nhật trạng thái:", error.localizedDescription)
        }
        db.close()
    }

    // MARK: - Tag Management (CRUD)

    /// Thêm nhãn dán mới (sử dụng Tag struct)
    func insertTag(tag: Tag) {
        guard let db = database, db.open() else { return }
        let sql = "INSERT INTO tags (name, color) VALUES (?, ?)"
        
        var newTagId: Int = 0
        
        do {
            try db.executeUpdate(sql, values: [tag.name, tag.color])
            
            // Lấy ID tự động vừa được SQLite gán cho hàng mới
            newTagId = Int(db.lastInsertRowId)
            
            // Cập nhật thông báo print
            print("✅ DB SUCCESS: Thêm nhãn dán '\(tag.name)' thành công. ID mới: \(newTagId)")
            
        } catch {
            print("❌ DB ERROR: Lỗi thêm tag '\(tag.name)':", error.localizedDescription)
        }
        db.close()
    }

    /// Lấy tất cả nhãn dán đã lưu
    func fetchAllTags() -> [Tag] {
        var tags: [Tag] = []
        guard let db = database, db.open() else { return [] }

        let sql = "SELECT id, name, color FROM tags ORDER BY name ASC"
        do {
            let results = try db.executeQuery(sql, values: nil)
            while results.next() {
                let tag = Tag(
                    id: Int(results.int(forColumn: "id")),
                    name: results.string(forColumn: "name") ?? "",
                    color: results.string(forColumn: "color") ?? ""
                )
                tags.append(tag)
            }
        } catch {
            print("Lỗi truy vấn tags:", error.localizedDescription)
        }
        db.close()
        return tags
    }

    /// Xóa nhãn dán theo ID
    func deleteTag(id: Int) {
        guard let db = database, db.open() else { return }
        let sql = "DELETE FROM tags WHERE id = ?"
        do {
            try db.executeUpdate(sql, values: [id])
            print("Xóa nhãn dán id=\(id) thành công.")
        } catch {
            print("Lỗi xóa tag:", error.localizedDescription)
        }
        db.close()
    }

    // MARK: - LinkTag Management

    /// Thêm liên kết giữa một Ghi chú và một Tag
    func insertLinkTag(notesID: Int, tagID: Int) {
        guard let db = database, db.open() else { return }
        let sql = "INSERT OR IGNORE INTO link_tags (notesID, tagID) VALUES (?, ?)"
        do {
            try db.executeUpdate(sql, values: [notesID, tagID])
        } catch {
            print("Lỗi thêm LinkTag:", error.localizedDescription)
        }
        db.close()
    }

    /// Xóa tất cả liên kết cho một Ghi chú cụ thể
    func deleteAllLinkTags(for notesID: Int) {
        guard let db = database, db.open() else { return }
        let sql = "DELETE FROM link_tags WHERE notesID = ?"
        do {
            try db.executeUpdate(sql, values: [notesID])
        } catch {
            print("Lỗi xóa LinkTags:", error.localizedDescription)
        }
        db.close()
    }

    /// Lấy tất cả Tags của một Ghi chú cụ thể
    func fetchTags(for notesID: Int) -> [Tag] {
        var tags: [Tag] = []
        guard let db = database, db.open() else { return [] }

        let sql = """
        SELECT t.id, t.name, t.color
        FROM tags t
        JOIN link_tags lt ON t.id = lt.tagID
        WHERE lt.notesID = ?
        ORDER BY t.name ASC
        """
        do {
            let results = try db.executeQuery(sql, values: [notesID])
            while results.next() {
                let tag = Tag(
                    id: Int(results.int(forColumn: "id")),
                    name: results.string(forColumn: "name") ?? "",
                    color: results.string(forColumn: "color") ?? ""
                )
                tags.append(tag)
            }
        } catch {
            print("Lỗi truy vấn Tags của Note:", error.localizedDescription)
        }
        db.close()
        return tags
    }
    
    // MARK: - Date Helpers
    
    /// Chuyển từ Date → String (để lưu vào DB)
    func stringFromDate(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date)
    }
}
