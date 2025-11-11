import SwiftUI

// --- 1. Component Tag View ---
struct TagView: View {
    let tag: Tag

    var body: some View {
        HStack {
            Image(systemName: "tag.fill")
                .font(.caption)
            Text(tag.name)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tag.color.opacity(0.15))
        .foregroundColor(tag.color)
        .cornerRadius(10)
    }
}

// --- 2. Component Task Row (Box Thay Đổi Màu) ---
struct TaskRow: View {
    var task: Task
    
    private var formattedDate: String {
        guard let deadline = task.deadline else { return "Không có hạn" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: deadline)
    }
    
    private var backgroundColor: Color {
        // Xanh nhạt cho Đã hoàn thành, Hồng nhạt cho Chưa hoàn thành
        return task.isComplete ? Color.green.opacity(0.1) : Color(red: 1.0, green: 0.95, blue: 0.95)
    }
    
    private var buttonColor: Color {
        // Xanh lá cho Đã hoàn thành, Cam cho Chưa hoàn thành
        return task.isComplete ? Color.green : Color.orange
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    // Màu xám cho Đã hoàn thành, đen cho Chưa hoàn thành
                    .foregroundColor(task.isComplete ? .gray : .black)
                
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                if let firstTag = task.tags.first {
                    TagView(tag: firstTag)
                }
                
                // ✅ THAY THẾ NavigationLink BẰNG Button CHỈ IN RA THÔNG BÁO
                Button("Chi tiết") {
                    // In ra thông báo chi tiết của công việc này vào console
                    print("--- Đã nhấn nút Chi tiết ---")
                    print("ID Công việc: \(task.id)")
                    print("Tiêu đề: \(task.title)")
                    print("Trạng thái: \(task.isComplete ? "Đã hoàn thành" : "Chưa hoàn thành")")
                    print("---------------------------")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(buttonColor) // Màu nút (sử dụng biến đã định nghĩa)
                .foregroundColor(.white)
                .font(.subheadline)
                .cornerRadius(12)
                // ⚠️ Không cần .buttonStyle(PlainButtonStyle()) khi dùng Button đơn giản
            }
        }
        .padding()
        .background(backgroundColor) // Màu nền Box
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(task.isComplete ? 0.0 : 0.08), radius: 5, x: 0, y: 5)
    }
}

// --- 3. Component Search Bar Tùy chỉnh (Đặt dưới tiêu đề) ---
struct CustomSearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Tìm kiếm ghi chú...", text: $searchText)
                .foregroundColor(.primary)
                .disableAutocorrection(true)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// --- 4. Màn hình Chính (Task List View) ---
struct TaskListView: View {
    // ViewModel giữ logic và dữ liệu
    @StateObject var viewModel = TaskListViewModel()
    // State cho tiêu đề nút lọc
    @State private var selectedFilter = "Tất cả công việc"

    var body: some View {
        // NavigationStack đã được bọc bên ngoài trong file App.swift
        ZStack(alignment: .bottomTrailing) {
            
            VStack(spacing: 8) {
                
                // 1. THANH TÌM KIẾM CUSTOM
                CustomSearchBar(searchText: $viewModel.searchText)
                    .padding(.horizontal, 16)
                
                // 2. NÚT LỌC
                HStack {
                    Spacer()
                    Menu {
                        Button("Tất cả công việc") {
                            selectedFilter = "Tất cả công việc"
                            viewModel.setFilter(.all)
                        }
                        Button("Đã hoàn thành") {
                            selectedFilter = "Đã hoàn thành"
                            viewModel.setFilter(.completed)
                        }
                        Button("Chưa hoàn thành") {
                            selectedFilter = "Chưa hoàn thành"
                            viewModel.setFilter(.pending)
                        }
                    } label: {
                        HStack {
                            Text(selectedFilter)
                            Image(systemName: "chevron.down")
                        }
                        .font(.caption)
                        .padding(8)
                        .background(Color(white: 0.9))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                
                // 3. DANH SÁCH CÔNG VIỆC
                List {
                    ForEach(viewModel.filteredTasks) { task in
                        TaskRow(task: task)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .padding(.vertical, 4)
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.toggleCompletion(task: task)
                                } label: {
                                    Label(task.isComplete ? "Hủy hoàn thành" : "Hoàn thành", systemImage: task.isComplete ? "arrow.uturn.backward" : "checkmark.circle.fill")
                                }
                                .tint(task.isComplete ? .gray : .green)
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            
            // Nút Thêm Mới (+) (Floating Action Button)
            Button(action: {
                print("Tạo Task mới")
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.orange)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 5, x: 2, y: 2)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        
        // --- Cấu hình Navigation ---
        .navigationTitle("Danh sách các công việc")
        .navigationBarTitleDisplayMode(.large) // Tiêu đề lớn
        .navigationBarBackButtonHidden(true) // Ẩn nút quay lại trên Root View
        .onAppear {
            viewModel.loadTasks()
        }
    }
}
