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

    // Tạo bảng nếu chưa có
    private func createTableIfNeeded() {
        guard let db = database, db.open() else { return }
        let createTableSQL = """
        CREATE TABLE IF NOT EXISTS notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            date TEXT,
            isCompleted INTEGER DEFAULT 0,
            isGhim INTEGER DEFAULT 0
        )
        """
        do {
            try db.executeUpdate(createTableSQL, values: nil)
        } catch {
            print(" Lỗi tạo bảng:", error.localizedDescription)
        }
        db.close()
    }

    // Thêm ghi chú
    func insertNote(title: String, content: String, date: String) {
        guard let db = database, db.open() else { return }
        let sql = "INSERT INTO notes (title, content, date) VALUES (?, ?, ?)"
        do {
            try db.executeUpdate(sql, values: [title, content, date])
        } catch {
            print("Lỗi thêm note:", error.localizedDescription)
        }
        db.close()
    }

    // Lấy tất cả ghi chú
    func fetchAllNotes() -> [NoteData] {
        var notes: [NoteData] = []
        guard let db = database, db.open() else { return [] }

        let sql = "SELECT * FROM notes ORDER BY isGhim DESC, date DESC, isCompleted DESC"
        do {
            let results = try db.executeQuery(sql, values: nil)
            while results.next() {
                //xu ly du lieu cho ghim
                let isGhimValue = results.object(forColumn: "isGhim")
                let isGhim = (isGhimValue as? NSNumber)?.intValue ?? 0
                let note = NoteData(
                    id: Int(results.int(forColumn: "id")),
                    title: results.string(forColumn: "title") ?? "",
                    content: results.string(forColumn: "content") ?? "",
                    date: ISO8601DateFormatter().date(from: results.string(forColumn: "date") ?? "") ?? Date(),
                    isCompleted: Int(results.int(forColumn: "isCompleted")),
                    isGhim: isGhim
                    
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
    
//    //xoa tat ca
//    func deleteAll(){
//        guard let db = database, db.open() else { return }
//        let sql = "DELETE FROM notes"
//        do {
//            try db.executeUpdate()
//            print("xoá thành công")
//        } catch {
//            print(" Lỗi xoá:", error.localizedDescription)
//        }
//        db.close()
//    }
    
    // Cập nhật ghi chú
    func updateNote(note:NoteData) {
        guard let db = database, db.open() else { return }
        let sql = """
            UPDATE notes
            SET title = ?, content = ?, date = ?, isCompleted = ?
            WHERE id = ?
        """
        do {
            try db.executeUpdate(sql, values: [note.title, note.content, note.date, note.isCompleted, note.id])
            print("Cập nhật note id=\(note.id) thành công")
        } catch {
            print(" Lỗi khi cập nhật note:", error.localizedDescription)
        }
        db.close()
    }
    
    // Cập nhật trạng thái ghim / bỏ ghim
    func togglePinNote(id: Int, isGhim: Int) {
        guard let db = database, db.open() else { return }
        let newValue = (isGhim == 1) ? 0 : 1  // nếu đang ghim thì bỏ ghim, ngược lại ghim
        let sql = "UPDATE notes SET isGhim = ? WHERE id = ?"
        do {
            try db.executeUpdate(sql, values: [newValue, id])
            print("Đã cập nhật isGhim = \(newValue) cho note id \(id)")
        } catch {
            print("Lỗi khi cập nhật ghim:", error.localizedDescription)
        }
        db.close()
    }
    
    func insertTag(tag: Tag) {
            guard let db = database, db.open() else { return }
            let sql = "INSERT INTO tags (name, color) VALUES (?, ?)"
            
            var newTagId: Int = 0
            
            do {
                try db.executeUpdate(sql, values: [tag.name, tag.color])
                
                // Lấy ID tự động vừa được SQLite gán cho hàng mới
                newTagId = Int(db.lastInsertRowId)
                
                // Cập nhật thông báo print
                print(" DB SUCCESS: Thêm nhãn dán '\(tag.name)' thành công. ID mới: \(newTagId)")
                
            } catch {
                print(" DB ERROR: Lỗi thêm tag '\(tag.name)':", error.localizedDescription)
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
