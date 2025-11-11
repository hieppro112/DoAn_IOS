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
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // TextField
        nameTextField.borderStyle = .roundedRect
        nameTextField.placeholder = "Nhập tên nhãn dán..."
        nameTextField.font = .systemFont(ofSize: 17)
    }
    
    private func setupColorPicker() {
        // Cấu hình stackView
        colorStackView.axis = .horizontal
        colorStackView.spacing = 12
        colorStackView.alignment = .center
        colorStackView.distribution = .equalSpacing
        colorStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorStackView)
        
        // Tạo nút màu
        for (index, color) in colors.enumerated() {
            let button = UIButton()
            button.backgroundColor = color
            button.layer.cornerRadius = 20
            button.layer.borderWidth = 3
            button.layer.borderColor = color == selectedColor ? UIColor.black.cgColor : UIColor.white.cgColor
            button.tag = index
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
            colorStackView.addArrangedSubview(button)
        }
        
        // Auto Layout cho colorStackView
        NSLayoutConstraint.activate([
            colorStackView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 25),
            colorStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorStackView.heightAnchor.constraint(equalToConstant: 50),
            colorStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            colorStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupButtons() {
        // Style chung cho 2 nút
        let buttons = [saveButton, cancelButton]
        buttons.forEach {
            $0?.layer.cornerRadius = 12
            $0?.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            $0?.heightAnchor.constraint(equalToConstant: 45).isActive = true
        }
        
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        
        cancelButton.backgroundColor = .systemGray5
        cancelButton.setTitleColor(.white, for: .normal)
        
        // Auto Layout cho nút (nếu không có constraint sẵn trong storyboard)
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
    
    // MARK: - Chọn màu
    @objc private func colorSelected(_ sender: UIButton) {
        for case let button as UIButton in colorStackView.arrangedSubviews {
            button.layer.borderColor = UIColor.white.cgColor
        }
        sender.layer.borderColor = UIColor.black.cgColor
        selectedColor = colors[sender.tag]
    }
    
    // MARK: - Hành động nút
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
