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
            isCompleted INTEGER DEFAULT 0
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

        let sql = "SELECT * FROM notes ORDER BY date DESC, isCompleted DESC"
        do {
            let results = try db.executeQuery(sql, values: nil)
            while results.next() {
                let note = NoteData(
                    id: Int(results.int(forColumn: "id")),
                    title: results.string(forColumn: "title") ?? "",
                    content: results.string(forColumn: "content") ?? "",
                    date: ISO8601DateFormatter().date(from: results.string(forColumn: "date") ?? "") ?? Date(),
                    isCompleted: Int(results.int(forColumn: "isCompleted"))
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
    
    
}
