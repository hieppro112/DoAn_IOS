import SwiftUI

// --- 1. Component Tag View (Giữ nguyên) ---
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
        .background(Color.purple.opacity(0.15))
        .foregroundColor(Color.purple)
        .cornerRadius(10)
    }
}

// --- 2. Component Task Row ---
struct TaskRow: View {
    @Environment(\.presentationMode) var presentationMode
    var note: NoteData

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: note.date)
    }

    private var backgroundColor: Color {
        note.isCompleteBool ? Color.green.opacity(0.1)
                            : Color(red: 1.0, green: 0.95, blue: 0.95)
    }

    private var buttonColor: Color {
        note.isCompleteBool ? Color.green : Color.orange
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(note.isCompleteBool ? .gray : .black)

                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                // CHỈ hiện Tag nếu có
                if let tag = note.tags.first {
                    TagView(tag: tag)
                }

                Button("Chi tiết") {
                    NotificationCenter.default.post(name: .didRequestNoteDetail, object: note)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(buttonColor)
                .foregroundColor(.white)
                .font(.subheadline)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(note.isCompleteBool ? 0.0 : 0.08), radius: 5, x: 0, y: 5)
    }
}


// --- 3. Component Search Bar (Giữ nguyên) ---
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

// MARK: - 4. Màn hình Chính (Task List View)
struct TaskListView: View {
    // ✅ THÊM để điều khiển việc quay lại màn hình
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = TaskListViewModel()
    @State private var selectedFilter = "Tất cả công việc"
    
    var body: some View {
        // ĐÃ XÓA NavigationStack
        ZStack(alignment: .bottomTrailing) {
            
            VStack(spacing: 8) {
                
                // BỔ SUNG: NÚT THỐNG KÊ (Nằm trên thanh tìm kiếm)
                HStack {
                    Spacer()
                    // NavigationLink sẽ sử dụng Navigation của UIKit Host
                    NavigationLink(destination: TaskStatsView(allTasks: viewModel.notes)) {
                         Image(systemName: "chart.pie.fill")
                             .foregroundColor(.orange)
                             .font(.title3) // Định dạng kích thước
                    }
                }
                .padding(.horizontal, 16)
                
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
                    ForEach(viewModel.filteredNotes) { note in
                        TaskRow(note: note)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .padding(.vertical, 4)
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.toggleCompletion(note: note)
                                } label: {
                                    Label(
                                        note.isCompleteBool ? "Hủy" : "Hoàn thành",
                                        systemImage: note.isCompleteBool
                                        ? "arrow.uturn.backward"
                                        : "checkmark.circle.fill"
                                    )
                                }
                                .tint(note.isCompleteBool ? .gray : .green)
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        
        .onAppear {
            viewModel.loadTasks()
        }
        // KHÔNG CÓ NAVIGATION MODIFIERS NÀO Ở ĐÂY
    }
}
