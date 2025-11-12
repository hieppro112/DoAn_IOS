import SwiftUI

// MARK: - Component Helpers (Phải đặt ở trên cùng)

// Component helper cho dòng chú thích
struct LegendRow: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)
            Text(label)
                .font(.body)
        }
    }
}

// Component helper cho dòng số liệu
struct StatsRow: View {
    let label: String
    let value: String
    let color: Color?
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                // Nếu có màu, áp dụng màu đó
                .foregroundColor(color ?? .primary)
        }
    }
}

// Bieu do quat (Dùng để vẽ các lát cắt)
struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.move(to: center)
        path.addArc(center: center,
                    radius: rect.width / 2,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}


// MARK: - TaskStatsView (View Chính)
struct TaskStatsView: View {
    
    @StateObject var viewModel = TaskStatsViewModel()
    var allTasks: [NoteData] // Nhận dữ liệu NoteData từ bên ngoài
    
    // Helper để định dạng tỷ lệ phần trăm
    private var percentageFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        return formatter
    }

    var body: some View {
        // Bọc toàn bộ nội dung trong ScrollView để tránh bị cắt
        ScrollView {
            VStack(spacing: 20) {
                
                // --- BIỂU ĐỒ ---
                Text("Tỷ lệ hoàn thành công việc")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // BIỂU ĐỒ QUẠT (PIE CHART)
                ZStack {
                    let rate = viewModel.stats.completionRate
                    // Tính góc cho phần đã hoàn thành
                    let completedAngle = Angle(degrees: rate * 360)
                    
                    // 1. Lát cắt "Chưa hoàn thành" (Pending) - Màu Đỏ (Lát cắt nền)
                    PieSlice(startAngle: .degrees(0), endAngle: .degrees(360))
                         .fill(Color.red.opacity(0.8))
                         .frame(width: 200, height: 200)

                    // 2. Lát cắt "Đã hoàn thành" (Completed) - Màu Xanh Lá
                    PieSlice(startAngle: .degrees(-90), endAngle: .degrees(-90) + completedAngle)
                         .fill(Color.green)
                         .frame(width: 200, height: 200)
                    
                    // Vòng ngoài màu đen (đường viền)
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 200, height: 200)
                    
                    // Hiển thị TỶ LỆ PHẦN TRĂM ở giữa
                    Text(percentageFormatter.string(from: NSNumber(value: rate)) ?? "0%")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(.primary)
                }
                .frame(width: 200, height: 200) // Khung chứa ZStack
                
                // ---  CHÚ THÍCH  ---
                VStack(alignment: .leading, spacing: 15) {
                    LegendRow(color: .green, label: "Hoàn thành")
                    LegendRow(color: .red, label: "Chưa hoàn thành")
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                // --- SỐ LIỆU THỐNG KÊ CHI TIẾT ---
                VStack(alignment: .leading, spacing: 15) {
                    // Tổng số công việc
                    StatsRow(label: "Tổng số công việc:", value: "\(viewModel.stats.totalTasks)", color: .primary)
                    // Đã hoàn thành
                    StatsRow(label: "Đã hoàn thành:", value: "\(viewModel.stats.completedTasks)", color: .green)
                    // Chưa hoàn thành
                    StatsRow(label: "Chưa hoàn thành:", value: "\(viewModel.stats.pendingTasks)", color: .red)

                    // Tỷ lệ hoàn thành (Dùng StatsRow đã sửa đổi)
                    StatsRow(label: "Tỷ lệ hoàn thành:",
                             value: percentageFormatter.string(from: NSNumber(value: viewModel.stats.completionRate)) ?? "0%",
                             color: viewModel.stats.completionRate == 1.0 ? .green : .red)
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
                
                Spacer()
            }
            .padding(.horizontal)
            .onAppear {
                viewModel.calculateStats(from: allTasks)
            }
        } // Hết ScrollView
        .navigationTitle("Thống kê") // **Bổ sung Tiêu đề Navigation Bar** (được hiển thị bởi UIKit)
        .navigationBarTitleDisplayMode(.inline)
    }
}
