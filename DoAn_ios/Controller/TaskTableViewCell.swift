//
//  TaskTableViewCell.swift
//  DoAn_ios
//
//  Created by  User on 11.11.2025.
//

import UIKit
import Combine
class TaskTableViewCell: UITableViewCell {

    // ✅ Thêm @IBOutlet cho Container View (đã sắp xếp lại thứ tự)
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    // Bạn có thể giữ hoặc xóa IBAction detailButton nếu không dùng

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Thiết lập bo tròn và bóng đổ cho Container View
        containerView.layer.cornerRadius = 15 // Bo tròn
        containerView.layer.masksToBounds = false // Cần thiết để hiển thị shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        
        // Thiết lập bo tròn cho nút chi tiết
        // Lưu ý: detailButton phải được kết nối IBOutlet trước
        // detailButton.layer.cornerRadius = 10
        
        // Loại bỏ màu nền mặc định của Cell để Container View nổi bật
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    // ✅ Hàm cấu hình dữ liệu và màu sắc
    func configure(with task: Task) {
        
        // 1. Gán Dữ liệu
        titleLabel.text = task.title
        tagLabel.text = task.tags.first?.name ?? "Chung" // Lấy Tag đầu tiên
        
        // Định dạng Ngày tháng
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateLabel.text = task.deadline != nil ? dateFormatter.string(from: task.deadline!) : "Không có hạn"
        
        // 2. Xử lý Giao diện (Màu sắc)
        if task.isComplete {
            // Đã hoàn thành (Xanh lá)
            containerView.backgroundColor = UIColor(red: 0.8, green: 0.95, blue: 0.8, alpha: 1.0) // Xanh nhạt
            //detailButton.backgroundColor = UIColor.systemGreen
            titleLabel.textColor = .gray // Tiêu đề mờ
        } else {
            // Chưa hoàn thành (Hồng/Cam)
            containerView.backgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.95, alpha: 1.0) // Hồng nhạt
            //detailButton.backgroundColor = UIColor.systemOrange
            titleLabel.textColor = .black
        }
        
        // Đảm bảo nút chi tiết hiển thị đúng tên
        // detailButton.setTitle("Chi tiết", for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
