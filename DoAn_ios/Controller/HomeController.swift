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
        let date1 = formatter.date(from: "2025-11-09")!
        let date2 = formatter.date(from: "2025-11-30")!
        let date3 = formatter.date(from: "2025-12-01")!
        
        notes = [
            NoteData(id: 4, title: "di choi voi ban be", content: "o pho di bo nguyen hue", date: date1),
            NoteData(id: 4, title: "da banh 3 tran", content: "o pho di bo nguyen hue", date: date2),
            NoteData(id: 4, title: "di sinh nhat", content: "o pho di bo nguyen hue", date: date1),

                 ];

        // Do any additional setup after loading the view.
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        //lay dl hom nay
        let today = Calendar.current.isDate(note.date, inSameDayAs: Date())
        //cho ngay mai
        let tomorow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let isTomorow = Calendar.current.isDate(note.date, inSameDayAs: tomorow)
        
        ///khoi tao data
        let dataNote : NoteData? = (isTomorow||today) ? note : nil
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCellHome", for: indexPath) as! cellHomeTableViewCell
        
        if(dataNote != nil){
            //chuyen tu date sang txt
            var timetxt:String = (today==true) ? "Cong viec hom nay" : "cong viec ngay mai"
            
            cell.txtDeadLine.text = timetxt
            cell.txtTitle.text = dataNote!.title
            cell.datetimeDeadLine.text = dataNote!.formattedDate
            
            return cell
        }
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
