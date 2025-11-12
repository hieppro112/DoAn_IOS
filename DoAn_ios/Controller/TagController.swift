import UIKit

// Lưu ý: Đảm bảo Tag, DatabaseManager đã được định nghĩa trong Project của bạn
// Cần import Tag (nếu nó là file riêng)

class TagController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // 1. Dùng mảng [Tag] thay thế fakeTags: [(String, UIColor)]
    // Khởi tạo Tag với ID tạm thời 0, màu là String Hex.
    private var tags: [Tag] = [
        Tag(id: 0, name: "Công việc", color: UIColor.systemBlue.toHex()),
        Tag(id: 0, name: "Học tập", color: UIColor.systemGreen.toHex()),
        Tag(id: 0, name: "Gia đình", color: UIColor.systemOrange.toHex()),
        Tag(id: 0, name: "Bạn bè", color: UIColor.systemPurple.toHex()),
        Tag(id: 0, name: "Sức khỏe", color: UIColor.systemRed.toHex()),
        Tag(id: 0, name: "Giải trí", color: UIColor.systemYellow.toHex()),
        Tag(id: 0, name: "Mua sắm", color: UIColor.systemPink.toHex()),
        Tag(id: 0, name: "Dự án", color: UIColor.systemTeal.toHex()),
        Tag(id: 0, name: "Du lịch", color: UIColor.systemIndigo.toHex()),
        Tag(id: 0, name: "Coding", color: UIColor.systemGray.toHex())
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Danh sách Tag"
        view.backgroundColor = .systemGroupedBackground
        setupCollectionView()
        loadSavedTags() // ĐÃ SỬA: Tải từ Database
        enableLongPressToDelete()
        // Cần reloadData() sau khi loadSavedTags()
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewLayout()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        collectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "TagCell")
    }
    
    private func updateCollectionViewLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let spacing: CGFloat = 16
        let itemsPerRow: CGFloat = 2
        let totalSpacing = (itemsPerRow - 1) * spacing
        let width = (collectionView.frame.width - totalSpacing - 32) / itemsPerRow
        
        layout.itemSize = CGSize(width: width, height: 60)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.invalidateLayout()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addVC = storyboard.instantiateViewController(withIdentifier: "AddTagController") as? AddTagController else { return }
        
        addVC.modalPresentationStyle = .formSheet
        addVC.onSave = { [weak self] newTagName, color in
            guard let self = self else { return }
            
            // 1. Tạo Tag mới với ID tạm thời 0
            let newTag = Tag(id: 0, name: newTagName, color: color.toHex())
            
            // 2. Lưu vào Database
            DatabaseManager.shared.insertTag(tag: newTag)
            
            // 3. Tải lại toàn bộ danh sách để cập nhật ID và UI
            self.loadSavedTags()
            self.collectionView.reloadData()
        }
        
        present(addVC, animated: true)
    }
    
    // ĐÃ XÓA VÀ THAY THẾ bằng DatabaseManager.shared.insertTag
    private func saveTags() {
        // Hàm này không còn cần thiết vì việc lưu được thực hiện trong addButtonTapped và handleLongPress
    }
    
    // ĐÃ SỬA ĐỔI: Tải từ Database
    private func loadSavedTags() {
        let savedTags = DatabaseManager.shared.fetchAllTags()
        
        if !savedTags.isEmpty {
            self.tags = savedTags
        } else {
            // Nếu DB trống, chèn dữ liệu mặc định vào DB
            for tag in self.tags {
                DatabaseManager.shared.insertTag(tag: tag)
            }
            // Tải lại để lấy ID tự động
            self.tags = DatabaseManager.shared.fetchAllTags()
        }
        // KHÔNG CẦN collectionView.reloadData() ở đây vì đã gọi trong viewDidLoad
    }
}


// MARK: - DataSource & Delegate
extension TagController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count // SỬ DỤNG MẢNG MỚI (tags)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCollectionViewCell
        
        let tag = tags[indexPath.item]
        // Chuyển đổi màu từ String Hex sang UIColor
        let color = UIColor(hex: tag.color) ?? .lightGray
        
        // Cập nhật hàm configure (vẫn nhận (String, UIColor))
        cell.configure(with: (tag.name, color))
        
        return cell
    }
    
    func enableLongPressToDelete() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.6 // thời gian nhấn giữ 0.6s
        collectionView.addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: point) {
                
                let tagToDelete = self.tags[indexPath.item] // Lấy đối tượng Tag
                
                let alert = UIAlertController(
                    title: "Xóa nhãn",
                    message: "Bạn có chắc muốn xóa nhãn “\(tagToDelete.name)” không?",
                    preferredStyle: .actionSheet
                )
                
                alert.addAction(UIAlertAction(title: "Xóa", style: .destructive, handler: { [weak self] _ in
                    guard let self = self else { return }
                    
                    // 1. Xóa khỏi Database theo ID
                    DatabaseManager.shared.deleteTag(id: tagToDelete.id)
                    
                    // 2. Xóa khỏi mảng và UI
                    self.tags.remove(at: indexPath.item)
                    self.collectionView.deleteItems(at: [indexPath])
                    
                    // ĐÃ XÓA: self.saveTags()
                }))
                
                alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
                
                if let popoverController = alert.popoverPresentationController {
                    popoverController.sourceView = self.collectionView.cellForItem(at: indexPath)
                    popoverController.sourceRect = self.collectionView.cellForItem(at: indexPath)?.bounds ?? .zero
                }
                
                present(alert, animated: true)
            }
        }
    }
}

// MARK: - UIColor Extension (Không sửa đổi)
extension UIColor {
    func toHex() -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        guard hexSanitized.count == 6 else { return nil }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

