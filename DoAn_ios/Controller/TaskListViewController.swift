import UIKit
import SwiftUI
import Combine

class TaskListViewController: UIViewController {

    // MARK: - Outlets và Actions (Đã bị loại bỏ vì dùng SwiftUI View toàn màn hình)
    // Nếu bạn không dùng các đối tượng kéo thả của UIKit, bạn không cần các Outlet/Action này
    
    // MARK: - Properties
    // Chúng ta không cần giữ ViewModel ở đây, vì TaskListView (SwiftUI) đã tự quản lý nó.

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Khởi tạo SwiftUI View đã hoàn chỉnh
        let taskListView = TaskListView()

        // 2. Nhúng SwiftUI View vào UIHostingController
        let hostingController = UIHostingController(rootView: taskListView)
        
        // 3. Thiết lập HostingController làm View chính
        
        // Thêm nó làm View con của TaskListViewController
        addChild(hostingController)
        
        // Đặt kích thước của View SwiftUI bằng kích thước của màn hình UIKit
        hostingController.view.frame = view.bounds
        
        // Thêm View của HostingController vào View chính của màn hình
        view.addSubview(hostingController.view)
        
        // Hoàn tất quá trình nhúng
        hostingController.didMove(toParent: self)
        
        // 4. Cấu hình Navigation Bar (Thuộc về UIKit)
        
        // Thiết lập tiêu đề (để chắc chắn)
        self.navigationItem.title = "Danh sách các công việc"
        
        // Tùy chọn: Để tiêu đề lớn (giống thiết kế ban đầu)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Loại bỏ đường gạch ngang dưới Navigation Bar
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}
