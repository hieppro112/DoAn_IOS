import UIKit

class AddNoteController: UIViewController, UITextViewDelegate {
   
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var reminderText: UITextView!
    @IBOutlet weak var stickerText: UILabel! // THANG: Hiển thị sticker đã chọn
    
    var onNoteAdded: ((NoteData) -> Void)?
    var selectedTag: Tag? // THANG: Lưu Tag đã chọn
    
    private let placeholder = "Mời nhập những lời nhắc nhở dành cho bản thân..."
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        updateStickerDisplay()
    }
   
    private func setupTextView() {
        reminderText.delegate = self
        reminderText.isEditable = true
        reminderText.isUserInteractionEnabled = true
        reminderText.text = placeholder
        reminderText.textColor = .lightGray
        reminderText.layer.borderWidth = 1
        reminderText.layer.borderColor = UIColor.systemGray4.cgColor
        reminderText.layer.cornerRadius = 8
        reminderText.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
    }
    
    // THANG: Cập nhật hiển thị sticker
    private func updateStickerDisplay() {
        if let tag = selectedTag {
            stickerText.text = tag.name
            stickerText.textColor = UIColor(hex: tag.color) ?? .label
            stickerText.backgroundColor = UIColor(hex: tag.color)?.withAlphaComponent(0.1)
            stickerText.layer.cornerRadius = 6
            stickerText.layer.masksToBounds = true
            stickerText.textAlignment = .center
        } else {
            stickerText.text = "Gán nhãn vào"
            stickerText.textColor = .lightGray
            stickerText.backgroundColor = .clear
            stickerText.layer.borderWidth = 0
        }
    }
   
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .label
        }
    }
   
    func textViewDidEndEditing(_ textView: UITextView) {
        let trimmed = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed.isEmpty {
            textView.text = placeholder
            textView.textColor = .lightGray
        }
    }
    
    // THÊM FUNCTION NÀY - "BỨC TƯỜNG" CHẶN UNWIND SEGUE
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Chặn unwind segue nếu dữ liệu chưa đủ
        if identifier == "unwindToHome" {
            return isDataValid()
        }
        return true
    }
    
    // THÊM FUNCTION NÀY - KIỂM TRA DỮ LIỆU
    private func isDataValid() -> Bool {
        // 1. Kiểm tra tiêu đề
        guard let rawTitle = titleText.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !rawTitle.isEmpty else {
            showErrorAlertAndStay(message: "Vui lòng nhập tiêu đề!")
            return false
        }
        
        // 2. Kiểm tra nội dung reminderText
        let contentText = reminderText.text ?? ""
        let trimmedContent = contentText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Nếu đang là placeholder (màu xám) hoặc rỗng
        if reminderText.textColor == .lightGray || trimmedContent.isEmpty {
            showErrorAlertAndStay(message: "Vui lòng nhập nội dung nhắc nhở!")
            return false
        }
        
        return true
    }
    
    // THANG: Prepare for segue để chuyển sang màn hình chọn tag
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTags" {
            if let tagsVC = segue.destination as? TagController {
                tagsVC.currentSelectedTag = selectedTag
                
                // Sử dụng closure để nhận tag đã chọn
                tagsVC.onTagSelected = { [weak self] selectedTag in
                    self?.handleTagSelection(selectedTag)
                }
            }
        }
    }
    
    // THANG: Xử lý khi chọn tag
    private func handleTagSelection(_ tag: Tag?) {
        self.selectedTag = tag
        updateStickerDisplay()
    }
   
    @IBAction func addNoteNew(_ sender: UIButton) {
        // Kiểm tra dữ liệu trước
        if !isDataValid() {
            return // Dừng lại, không gọi unwind
        }
        
        let finalTitle = titleText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalContent = reminderText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let dateString = ISO8601DateFormatter().string(from: date.date)
        
        // THANG: Lưu note vào database (KHÔNG truyền tagId)
        DatabaseManager.shared.insertNote(title: finalTitle, content: finalContent, date: dateString)
        
        // Lấy danh sách mới và tìm note vừa thêm
        let allNotes = DatabaseManager.shared.fetchAllNotes()
        if let newNote = allNotes.first(where: {
            $0.title == finalTitle &&
            $0.content == finalContent &&
            Calendar.current.isDate($0.date, inSameDayAs: date.date)
        }) {
            // THANG: Thêm liên kết sticker vào bảng link_tags nếu có
            if let selectedTag = selectedTag {
                DatabaseManager.shared.insertLinkTag(notesID: newNote.id, tagID: selectedTag.id)
                print("✅ Đã liên kết sticker '\(selectedTag.name)' với note ID: \(newNote.id)")
            }
            
            onNoteAdded?(newNote)
        }
        
        // CHỈ CHẠY KHI THÀNH CÔNG → chuyển về Home
        performSegue(withIdentifier: "unwindToHome", sender: self)
    }
   
    private func showErrorAlertAndStay(message: String) {
        let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
