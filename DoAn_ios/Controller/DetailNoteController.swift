//
//  DetailNoteController.swift
//  DoAn_ios
//
//  Created by  User on 10.11.2025.
//

import UIKit

class DetailNoteController: UIViewController {
    
    var note:NoteData?
    var onSave: ((NoteData) -> Void)?//1. tao closure
    
    @IBAction func noteDone(_ sender: Any) {
        print("chua hoan thanh")
    }
    @IBAction func btnEdit(_ sender: Any) {
        print("luu lai chinh sua ")
        note?.title = txtTitle.text ?? ""
        note?.content = txtcontent.text ?? ""
        onSave?(note!)
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnDone(_ sender: Any) {
        print("cong viec hoan thanh")
    }
    
    @IBAction func btnDeleteNote(_ sender: Any) {
        print("xoa cong viec")
    }
    //    @IBOutlet weak var itemTitle:UINavigationBar!
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
