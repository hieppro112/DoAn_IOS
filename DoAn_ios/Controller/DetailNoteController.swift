//
//  DetailNoteController.swift
//  DoAn_ios
//
//  Created by  User on 10.11.2025.
//

import UIKit

class DetailNoteController: UIViewController {
    //database
    let dbNote = DatabaseManager.shared
    
    var note:NoteData?
    
    //tao cac su kien
    //khi nhan save
    var onSave: ((NoteData) -> Void)?
    //su kien nhan delete
    var onDelete:((NoteData) -> Void)?
    //su kien nhan chua hoan thanh
    var onNotComplete:((NoteData) -> Void)?
    //su kien nhan hoan thanh
    var onComplete:((NoteData) -> Void)?
    
    
    @IBAction func noteDone(_ sender: Any) {
        print("chua hoan thanh")
        var newValue = note
        newValue = NoteData(id: note!.id, title: note!.title, content: note!.content, date: note!.date, isCompleted: 0)
        dbNote.updateNote(note: newValue!)
        print("cap nhat thanh cong")
        onNotComplete?(newValue!)
        
        navigationController?.popViewController(animated: true)
    }
    
    //nut edit
    @IBAction func btnEdit(_ sender: Any) {
        //tao dl moi
        var newValue = note
        newValue = NoteData(id: note!.id, title: txtTitle!.text!, content: txtcontent.text, date: note!.date,isCompleted: note!.isCompleted)
        dbNote.updateNote(note: newValue!)
        print("cap nhat thanh cong \(newValue!.isCompleted)")
        onSave?(newValue!)
        
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnDone(_ sender: Any) {
        print("cong viec hoan thanh")
        var newValue = note
        newValue = NoteData(id: note!.id, title: note!.title, content: note!.content, date: note!.date, isCompleted: 1)
        dbNote.updateNote(note: newValue!)
        print("cap nhat thanh cong")
        onComplete?(newValue!)
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDeleteNote(_ sender: Any) {
        print("xoa cong viec")
        dbNote.deleteNote(id: note!.id)
            onDelete?(note!)
        navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var txtdate:UILabel!
    @IBOutlet weak var txtTitle:UITextField!
    @IBOutlet weak var txtcontent:UITextView!
    @IBOutlet weak var btnEdit:UIButton!
    @IBOutlet weak var btnDelete:UIButton!
    @IBOutlet weak var btnFeature: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let note = note else {return}
        print("note: \(note)")
        
        print("content: \(note.title)")
        
            txtTitle.text = note.title
            txtdate.text = note.formattedDate
            txtdate.text = note.formattedDate
            txtcontent.text = note.content
    }
    

}
