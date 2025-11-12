//
//  HomeController.swift
//  DoAn_ios
//
//  Created by  User on 08.11.2025.
//

import UIKit

class HomeController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var txtSearch:UITextField!
    //tao format cho date
    let formatDate = DateFormatter()
    let formatter = DateFormatter()
    
    var notes:[NoteData] = []
    var notesSearch:[NoteData] = []
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        formatter.dateFormat = "yyyy-MM-dd"

        // Tạo các ngày tuỳ ý
//        let date1 = formatter.date(from: "2025-11-11")!
//        let date2 = formatter.date(from: "2025-11-15")!
//        let date3 = formatter.date(from: "2025-11-12")!
        
        //load du lieu
        loadNotes()
        //su kien tim kiem
        txtSearch.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        //xu ly long press de ghim
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ghimNote(_:)))
        tableView.addGestureRecognizer(longPress)
    }
    
    //MARK: GHIM NOTE
    //xuly long press de ghim note
    @objc func ghimNote(_ gesture: UILongPressGestureRecognizer){
        print("long press")
        if gesture.state == .began{
            let point = gesture.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: point){
                let note = notes[indexPath.row]
                
                DatabaseManager.shared.togglePinNote(id: note.id, isGhim: note.isGhim)
                
                notes = DatabaseManager.shared.fetchAllNotes()
                notesSearch = notes
                tableView.reloadData()
//                loadNotes()
                
                let message = (note.isGhim == 1) ? "Đã bỏ ghim" : "Đã ghim công việc"
                           let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                           present(alert, animated: true)
                           DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                               alert.dismiss(animated: true)
                           }
            }
        }
    }
    
    //MARK: CHINH SUA TIM KIEM
    //ham tim kiem
    @objc func searchTextChanged(_ textField: UITextField){
        let query = textField.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if query!.isEmpty{
            notesSearch = notes
        }
        else{
            notesSearch = notes.filter{ note in note.title.lowercased().contains(query!)||note.content.lowercased().contains(query!) }
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: lấy dữ liệu
    func loadNotes(){
        let today = Date()
    let dateString = ISO8601DateFormatter().string(from: today)
    //them du lieu
//        DatabaseManager.shared.insertNote(title: "ghi chu 1", content: "chao moij nguoi", date: dateString)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    
    //gan du lieu
    notes = DatabaseManager.shared.fetchAllNotes()

        notes = notes.filter { note in
            Calendar.current.isDate(note.date, inSameDayAs: today) ||
            Calendar.current.isDate(note.date, inSameDayAs: tomorrow)
        }
        

        // Cập nhật lại giao diện
        tableView.reloadData()
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesSearch.count
    }
    
    
    
    //MARK: hiển thị dữ liệu
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notesSearch[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCellHome", for: indexPath) as! cellHomeTableViewCell

            let today = Calendar.current.isDate(note.date, inSameDayAs: Date())
            let timetxt = today ? "Công việc hôm nay" : "Công việc ngày mai"

            cell.txtDeadLine.text = timetxt
            cell.txtTitle.text = note.title
            cell.datetimeDeadLine.text = note.formattedDate
        
        if note.isCompleted == 1 {
            cell.statusIcon.image = UIImage(systemName: "checkmark.circle.fill")

            cell.statusIcon.tintColor = .systemGreen
        }
        else {
            cell.statusIcon.image = UIImage(systemName: "xmark.circle.fill")
            cell.statusIcon.tintColor = .systemRed
        }
        
        if note.isGhim == 1 {
            cell.isGhimIcon.isHidden = false
            cell.isGhimIcon.image = UIImage(systemName: "pin.fill")
            cell.isGhimIcon.tintColor = .black
        }
        else{
            cell.isGhimIcon.isHidden = true
        }
        
        
        
//        if note.isCompleted == 1 {
//            cell.statusIcon.image = UIImage(systemName: "xmark.circle.fill")
//
//            cell.statusIcon.tintColor = .systemGreen
//        }
//        else {
//            cell.statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
//            cell.statusIcon.tintColor = .systemRed
//        }
        

            return cell
    }
    
    
    //MARK: XU LY PREPARE
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
            
            //xu ly khi ben chi tiet xoa
            desVC.onDelete = { [weak self] deletedNote in
                guard let self = self else { return }
                self.notes.removeAll { $0.id == deletedNote.id }
                self.tableView.reloadData()
            }
            
            // Callback khi SAVE
                desVC.onSave = { [weak self] updatedNote in
                    guard let self = self else { return }
                    self.notes[indexPath.row] = updatedNote
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            //khi nhan chua hoan thanh
                desVC.onNotComplete = { [weak self] updatedNote in
                    guard let self = self else { return }
                    self.notes[indexPath.row] = updatedNote
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            
            // khi nhan ha=oan thanh
                desVC.onComplete = { [weak self] updatedNote in
                    guard let self = self else { return }
                    self.notes[indexPath.row] = updatedNote
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
        }
    }
    
    
    //MARK: LOAD SCREEN
    //ham load lai khi tu man hinh detail tro ve
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notes = DatabaseManager.shared.fetchAllNotes()
        

        //print("note tra ve: \(notes[0].isCompleted)")
        searchTextChanged(txtSearch)

        tableView.reloadData()
    }
}
