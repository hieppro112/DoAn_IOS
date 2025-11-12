//
//  HomeController.swift
//  DoAn_ios
//
//  Created by  User on 08.11.2025.
//

import UIKit
import SwiftUI

class HomeController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var txtSearch:UITextField!
    //tao format cho date
    let formatDate = DateFormatter()
    let formatter = DateFormatter()
    
    var notes:[NoteData] = []
    var notesSearch:[NoteData] = []
    
    
    
    @IBAction func btnList(_ sender: UIButton) {
        let taskListView = TaskListView()
        let hostingController = UIHostingController(rootView: taskListView)
        
        guard let navigationController = self.navigationController else { return }

        // Đảm bảo thanh Navigation Bar HIỂN THỊ (sẽ được khôi phục khi push)
        navigationController.setNavigationBarHidden(false, animated: true)

        // ĐẶT TIÊU ĐỀ cho thanh Navigation Bar của UIKit
        hostingController.title = "Danh sách các công việc"
        
        // (Nếu bạn muốn nút Thống kê UIBarButton, bạn sẽ đặt nó ở đây)
        
        navigationController.pushViewController(hostingController, animated: true)
    }
    @IBAction func addNote(_ sender: UIButton) {
    }
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        // Hàm này để nhận unwind segue từ AddNote
        print("Đã quay về Home từ AddNote")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        formatter.dateFormat = "yyyy-MM-dd"

        //load du lieu
        loadNotes()
        //su kien tim kiem
        txtSearch.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        //xu ly long press de ghim
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ghimNote(_:)))
        tableView.addGestureRecognizer(longPress)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDetailRequest(notification:)), name: .didRequestNoteDetail, object: nil)
    }
    //Bo xung de chuyen trang file (Khanh)
    @objc func handleDetailRequest(notification: Notification) {
        guard let note = notification.object as? NoteData else { return }
        
        // Gọi segue, truyền NoteData làm sender
        performSegue(withIdentifier: "chuyen_detailNotes", sender: note)
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
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        // Lấy tất cả ghi chú
        let allNotes = DatabaseManager.shared.fetchAllNotes()

        // Lọc chỉ giữ hôm nay và ngày mai
        notes = allNotes.filter { note in
            Calendar.current.isDate(note.date, inSameDayAs: today) ||
            Calendar.current.isDate(note.date, inSameDayAs: tomorrow)
        }

        // Cập nhật notesSearch để TableView hiển thị đúng
        notesSearch = notes

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
        // XỬ LÝ SEGUE TỪ SWIFTUI/NOTIFICATION CENTER
        if segue.identifier == "chuyen_detailNotes",
            let desVC = segue.destination as? DetailNoteController,
            let noteFromSender = sender as? NoteData {
            
            // 1. Gán NoteData được truyền từ SwiftUI
            desVC.note = noteFromSender
            
            // 2. TÌM LẠI INDEX và GÁN CALLBACKS
            if let index = notes.firstIndex(where: { $0.id == noteFromSender.id }) {
                
                // Hàm cập nhật (dùng cho onSave, onComplete, onNotComplete)
                let updateNoteInArray: (NoteData) -> Void = { [weak self] updatedNote in
                    guard let self = self else { return }
                    
                    if let newIndex = self.notes.firstIndex(where: { $0.id == updatedNote.id }) {
                        let newIndexPath = IndexPath(row: newIndex, section: 0)
                        self.notes[newIndex] = updatedNote
                        self.tableView.reloadRows(at: [newIndexPath], with: .automatic)
                    } else {
                        // Nếu note không còn trong mảng, reload toàn bộ
                        self.tableView.reloadData()
                    }
                }
                
                // Gán tất cả các closure cập nhật
                desVC.onSave = updateNoteInArray
                desVC.onNotComplete = updateNoteInArray
                desVC.onComplete = updateNoteInArray

                // Gán closure xóa
                desVC.onDelete = { [weak self] deletedNote in
                    guard let self = self else { return }
                    self.notes.removeAll { $0.id == deletedNote.id }
                    self.tableView.reloadData()
                }
            }
            
            return
        }
        // XỬ LÝ SEGUE GỐC TỪ UIKIT (CLICK VÀO HÀNG TRONG TABLEVIEW)
        guard segue.identifier == "chuyen_detailNotes",
            let desVC = segue.destination as? DetailNoteController,
            let indexPath = tableView.indexPathForSelectedRow else {
            
            // THÊM MỚI – GIỐNG HỆT DETAIL thang
            if segue.identifier == "chuyen_addNote",
                let addVC = segue.destination as? AddNoteController {
                
                addVC.onNoteAdded = { [weak self] newNote in
                    guard let self = self else { return }
                    self.notes.append(newNote)
                    self.notes.sort { $0.date < $1.date }
                    self.tableView.reloadData()
                }
            }
            return
        }

        let note = notes[indexPath.row]
        desVC.note = note

        // 4. gán closure để nhận lại data (Chỉ cần định nghĩa một lần cho các trường hợp Update/Save/Complete/NotComplete)
        
        let updateLogic: (NoteData) -> Void = { [weak self] updatedNote in
            guard let self = self else { return }
            self.notes[indexPath.row] = updatedNote
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        desVC.onSave = updateLogic
        desVC.onNotComplete = updateLogic
        desVC.onComplete = updateLogic

        // xu ly khi ben chi tiet xoa
        desVC.onDelete = { [weak self] deletedNote in
            guard let self = self else { return }
            self.notes.removeAll { $0.id == deletedNote.id }
            self.tableView.reloadData()
        }
    }
    
    
    //MARK: LOAD SCREEN
    //ham load lai khi tu man hinh detail tro ve
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Đảm bảo thanh Navigation Bar HIỂN THỊ khi Home là màn hình Top
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        notes = DatabaseManager.shared.fetchAllNotes()
        
        //print("note tra ve: \(notes[0].isCompleted)")
        searchTextChanged(txtSearch)
        loadNotes()
        tableView.reloadData()
    }
}
