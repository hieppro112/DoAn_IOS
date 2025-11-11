//
//  HomeController.swift
//  DoAn_ios
//
//  Created by  User on 08.11.2025.
//

import UIKit

class HomeController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView:UITableView!
    //tao format cho date
    let formatDate = DateFormatter()
    let formatter = DateFormatter()
    
    var notes:[NoteData] = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        formatter.dateFormat = "yyyy-MM-dd"

        // Tạo các ngày tuỳ ý
        let date1 = formatter.date(from: "2025-11-11")!
        let date2 = formatter.date(from: "2025-11-15")!
        let date3 = formatter.date(from: "2025-11-12")!
        
//        notes = [
//            NoteData(id: 4, title: "đi chơi với mấy ní", content: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.", date: date1),
//            NoteData(id: 4, title: "da banh 3 tran", content: "o pho di bo nguyen hue", date: date3),
//            NoteData(id: 4, title: "di sinh nhat", content: "o pho di bo nguyen hue", date: date1),
//
//            NoteData(id: 4, title: "di hoc bai nhom vao ngay 12/11", content: "o pho di bo nguyen hue", date: date3),
//
//                 ];
        
        //  Lọc chỉ giữ công việc hôm nay hoặc ngày mai
            let today = Date()
        let dateString = ISO8601DateFormatter().string(from: date2)
        //them du lieu
        DatabaseManager.shared.insertNote(title: "ghi chu 3", content: "chao moij nguoi", date: dateString)
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        
        //gan du lieu
        notes = DatabaseManager.shared.fetchAllNotes()

            notes = notes.filter { note in
                Calendar.current.isDate(note.date, inSameDayAs: today) ||
                Calendar.current.isDate(note.date, inSameDayAs: tomorrow)
            }

            // 🔁 Cập nhật lại giao diện
            tableView.reloadData()

        // Do any additional setup after loading the view.
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCellHome", for: indexPath) as! cellHomeTableViewCell

            let today = Calendar.current.isDate(note.date, inSameDayAs: Date())
            let timetxt = today ? "Công việc hôm nay" : "Công việc ngày mai"

            cell.txtDeadLine.text = timetxt
            cell.txtTitle.text = note.title
            cell.datetimeDeadLine.text = note.formattedDate

            return cell

    }
    
    //chuyen sang man hinh detail
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "chuyen_detailNotes",
                 let desVC = segue.destination as? DetailNoteController,
                 let indexPath = tableView.indexPathForSelectedRow else { return }

           let note = notes[indexPath.row]
           desVC.note = note

           // 4. gán closure để nhận lại data
           desVC.onSave = { [weak self] updatedNote in
               guard let self = self else { return }
               // 5. cập nhật vào mảng
               self.notes[indexPath.row] = updatedNote
               // 6. reload row để thấy thay đổi ngay
               self.tableView.reloadRows(at: [indexPath], with: .automatic)
           }
    }
    
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        let noteData = notes[indexPath]
//
//        if let detail = storyboard?.instantiateViewController(withIdentifier: "NoteDetailController") as? DetailNoteController(
//            detail.note = noteData
//        )
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
