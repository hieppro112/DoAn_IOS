import UIKit

class AddTagController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // StackView chọn màu
    private let colorStackView = UIStackView()
    private let colors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemYellow,
        .systemPurple, .systemOrange, .systemPink, .systemTeal
    ]
    private var selectedColor: UIColor = .systemBlue
    
    // Callback khi lưu
    var onSave: ((String, UIColor) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupColorPicker()
        setupButtons()
    }
    
    // MARK: - SỬA ĐỔI GIAO DIỆN
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 1. Thêm tiêu đề
        let titleLabel = UILabel()
        titleLabel.text = "Thêm Nhãn Dán Mới"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // 2. Định hình TextField (ĐÃ CẬP NHẬT BORDER)
        nameTextField.borderStyle = .none
        nameTextField.placeholder = "Nhập tên nhãn dán..."
        nameTextField.font = .systemFont(ofSize: 17)
        nameTextField.backgroundColor = .secondarySystemGroupedBackground
        nameTextField.layer.cornerRadius = 10
        
        // THÊM BORDER CHO TEXTFIELD
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Thêm padding cho TextField
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: nameTextField.frame.height))
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always
        nameTextField.rightView = paddingView
        nameTextField.rightViewMode = .always
        
        // Auto Layout cho Tiêu đề
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Cần cập nhật constraint của nameTextField (giả sử nó đã được đặt top/leading/trailing)
        // Nếu nameTextField là Outlet có constraint sẵn, không cần thêm lại.
        nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30).isActive = true
    }
    
    private func setupColorPicker() {
        // Cấu hình stackView
        colorStackView.axis = .horizontal
        colorStackView.spacing = 10
        colorStackView.alignment = .center
        colorStackView.distribution = .equalSpacing
        colorStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorStackView)
        
        // Tạo nút màu
        let colorButtonSize: CGFloat = 35
        let selectedBorderWidth: CGFloat = 4
        
        for (index, color) in colors.enumerated() {
            let button = UIButton()
            button.backgroundColor = color
            button.layer.cornerRadius = colorButtonSize / 2
            
            // Sử dụng màu trắng để tạo hiệu ứng "nổi" cho border
            button.layer.borderWidth = selectedBorderWidth
            button.layer.borderColor = color == selectedColor ? UIColor.black.cgColor : UIColor.clear.cgColor
            
            // Thêm shadow để làm các nút nổi bật hơn
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.3
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 3
            
            button.tag = index
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: colorButtonSize).isActive = true
            button.heightAnchor.constraint(equalToConstant: colorButtonSize).isActive = true
            button.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
            colorStackView.addArrangedSubview(button)
        }
        
        // Auto Layout cho colorStackView
        NSLayoutConstraint.activate([
            colorStackView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 25),
            colorStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorStackView.heightAnchor.constraint(equalToConstant: colorButtonSize + selectedBorderWidth * 2),
            colorStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            colorStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupButtons() {
        // Style chung cho 2 nút
        let buttons = [saveButton, cancelButton]
        buttons.forEach {
            $0?.layer.cornerRadius = 12
            $0?.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            $0?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        
        // CẬP NHẬT NÚT HỦY
        cancelButton.backgroundColor = .clear
        cancelButton.layer.borderWidth = 1.5
        cancelButton.layer.borderColor = UIColor.systemGray3.cgColor
        cancelButton.setTitleColor(.systemRed, for: .normal) // ĐỔI MÀU CHỮ THÀNH ĐỎ
        
        // Auto Layout cho nút
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: colorStackView.bottomAnchor, constant: 40),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 15),
            cancelButton.leadingAnchor.constraint(equalTo: saveButton.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor)
        ])
    }
    
    // MARK: - Chọn màu (LOGIC KHÔNG THAY ĐỔI)
    @objc private func colorSelected(_ sender: UIButton) {
        let selectedBorderWidth: CGFloat = 4
        
        for case let button as UIButton in colorStackView.arrangedSubviews {
            button.layer.borderColor = UIColor.clear.cgColor
        }
        sender.layer.borderColor = UIColor.black.cgColor
        sender.layer.borderWidth = selectedBorderWidth
        selectedColor = colors[sender.tag]
    }
    
    // MARK: - Hành động nút (LOGIC KHÔNG THAY ĐỔI)
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let text = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            showAlert("Vui lòng nhập tên nhãn dán")
            return
        }
        onSave?(text, selectedColor)
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
