import UIKit

class AddNoteController: UIViewController, UITextViewDelegate {
   
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var reminderText: UITextView!
    
    var onNoteAdded: ((NoteData) -> Void)?
    
    private let placeholder = "Mời nhập những lời nhắc nhở dành cho bản thân..."
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
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
   
    @IBAction func addNoteNew(_ sender: UIButton) {
        // Kiểm tra dữ liệu trước
        if !isDataValid() {
            return // Dừng lại, không gọi unwind
        }
        
        // 3. Nếu cả hai đều hợp lệ → tiến hành lưu
        let finalTitle = titleText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalContent = reminderText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let dateString = ISO8601DateFormatter().string(from: date.date)
        
        // Lưu vào database
        DatabaseManager.shared.insertNote(title: finalTitle, content: finalContent, date: dateString)
        
        // Lấy danh sách mới và tìm note vừa thêm
        let allNotes = DatabaseManager.shared.fetchAllNotes()
        if let newNote = allNotes.last(where: {
            $0.title == finalTitle &&
            $0.content == finalContent &&
            Calendar.current.isDate($0.date, inSameDayAs: date.date)
        }) {
            onNoteAdded?(newNote)
        }
        
        // 4. CHỈ CHẠY KHI THÀNH CÔNG → chuyển về Home
        performSegue(withIdentifier: "unwindToHome", sender: self)
    }
   
    private func showErrorAlertAndStay(message: String) {
        let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
