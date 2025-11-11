import UIKit

class AddNoteController: UIViewController, UITextViewDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var reminderText: UITextView!
    @IBOutlet weak var textShowSticker: UILabel!

    // MARK: - Placeholder text
    let placeholderText = "Mời nhập những lời nhắc nhở dành cho bản thân..."

    override func viewDidLoad() {
        super.viewDidLoad()

        // Gán delegate cho TextView
        reminderText.delegate = self

        // Thiết lập placeholder ban đầu
        reminderText.text = placeholderText
        reminderText.textColor = UIColor.lightGray
    }

    // Khi người dùng bắt đầu gõ
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.label 
        }
    }

    // Khi người dùng dừng gõ và để trống
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        }
    }

    // MARK: - Actions
    @IBAction func addSticker(_ sender: UIButton) {
        print("chuyen den mh nhan dan")
    }

    @IBAction func addNote(_ sender: UIButton) {
        // Nếu người dùng vẫn để placeholder, coi như trống
        if reminderText.text == placeholderText || reminderText.text.isEmpty {
            print("Vui lòng nhập nội dung ghi chú!")
            return
        }

        print("Thêm note thành công: \(reminderText.text ?? "")")
    }
}
