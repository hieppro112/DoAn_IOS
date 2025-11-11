import UIKit

class TagController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var fakeTags: [(String, UIColor)] = [
        ("Công việc", .systemBlue),
        ("Học tập", .systemGreen),
        ("Gia đình", .systemOrange),
        ("Bạn bè", .systemPurple),
        ("Sức khỏe", .systemRed),
        ("Giải trí", .systemYellow),
        ("Mua sắm", .systemPink),
        ("Dự án", .systemTeal),
        ("Du lịch", .systemIndigo),
        ("Coding", .systemGray)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Danh sách Tag"
        view.backgroundColor = .systemGroupedBackground
        setupCollectionView()
        loadSavedTags()
        enableLongPressToDelete() 
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
        addVC.onSave = { [weak self] newTag, color in
            self?.fakeTags.append((newTag, color))
            self?.collectionView.reloadData()
            self?.saveTags()
        }
        
        present(addVC, animated: true)
    }
    
    private func saveTags() {
        let data = fakeTags.map { [$0.0, $0.1.toHex()] }
        UserDefaults.standard.set(data, forKey: "savedTags")
    }
    
    private func loadSavedTags() {
        if let data = UserDefaults.standard.array(forKey: "savedTags") as? [[String]] {
            fakeTags = data.compactMap { item in
                guard item.count == 2, let color = UIColor(hex: item[1]) else { return nil }
                return (item[0], color)
            }
            collectionView.reloadData()
        }
    }
}

// MARK: - DataSource & Delegate
extension TagController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fakeTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCollectionViewCell
        cell.configure(with: fakeTags[indexPath.item])
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
                    let tagName = fakeTags[indexPath.item].0
                    
                    let alert = UIAlertController(
                        title: "Xóa nhãn",
                        message: "Bạn có chắc muốn xóa nhãn “\(tagName)” không?",
                        preferredStyle: .actionSheet
                    )
                    
                    alert.addAction(UIAlertAction(title: "Xóa", style: .destructive, handler: { [weak self] _ in
                        guard let self = self else { return }
                        self.fakeTags.remove(at: indexPath.item)
                        self.collectionView.deleteItems(at: [indexPath])
                        self.saveTags()
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

// MARK: - UIColor Extension
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


