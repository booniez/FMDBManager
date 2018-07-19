//
//  ViewController.swift
//  FMDBLibrary
//
//  Created by monstar on 2018/7/18.
//  Copyright © 2018年 monstar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var addkid: UITextField!
    @IBOutlet weak var addname: UITextField!
    @IBOutlet weak var addage: UITextField!
    @IBOutlet weak var selectkid: UITextField!
    @IBOutlet weak var selectname: UITextField!
    @IBOutlet weak var selectage: UITextField!

    @IBAction func add(_ sender: Any) {
        var updateParmas = [String: Any]()
        if let pkid = addkid.text {
            if pkid != "" {
                updateParmas["pkid"] = Int(pkid)
            }
        }
        if let name = addname.text {
            if name != "" {
                updateParmas["name"] = name
            }
        }
        if let age = addage.text {
            if age != "" {
                updateParmas["age"] = Int(age)
            }
        }
        let insertFlag = FMDBManager.shared.insertTable(tableName: "tableone", params: updateParmas)
        print("插入结果\(insertFlag)")

    }
    @IBAction func del(_ sender: Any) {
        var parmas = [String: Any]()
        if let pkid = selectkid.text {
            if pkid != "" {
                parmas["pkid"] = Int(pkid)
            }
        }
        if let name = selectname.text {
            if name != "" {
                parmas["name"] = name
            }
        }
        if let age = selectage.text {
            if age != "" {
                parmas["age"] = Int(age)
            }
        }
        let deleteFlag = FMDBManager.shared.deleteTable(tableName: "tableone", whereDictionary: parmas)
        print("删除结果\(deleteFlag)")

    }
    @IBAction func sel(_ sender: Any) {
        var parmas = [String: Any]()
        if let pkid = selectkid.text {
            if pkid != "" {
                parmas["pkid"] = Int(pkid)
            }
        }
        if let name = selectname.text {
            if name != "" {
                parmas["name"] = name
            }
        }
        if let age = selectage.text {
            if age != "" {
                parmas["age"] = Int(age)
            }
        }

        if let selectArray = FMDBManager.shared.selectTable(tableName: "tableone", params: nil, whereDictionary: parmas) {
            print("查询结果\(selectArray)")
        }
    }

    @IBAction func upd(_ sender: Any) {
        var parmas = [String: Any]()
        var updateParmas = [String: Any]()
        if let pkid = selectkid.text {
            if pkid != "" {
                parmas["pkid"] = Int(pkid)
            }
        }
        if let name = selectname.text {
            if name != "" {
                parmas["name"] = name
            }
        }
        if let age = selectage.text {
            if age != "" {
                parmas["age"] = Int(age)
            }
        }

        if let pkid = addkid.text {
            if pkid != "" {
                updateParmas["pkid"] = Int(pkid)
            }
        }
        if let name = addname.text {
            if name != "" {
                updateParmas["name"] = name
            }
        }
        if let age = addage.text {
            if age != "" {
                updateParmas["age"] = Int(age)
            }
        }
        

        let updateFlag = FMDBManager.shared.updateTable(tableName: "tableone", params: updateParmas, whereDictionary: parmas)
        print("修改结果\(updateFlag)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = FMDBManager.shared.shareDataBase()
        let creatFlag = FMDBManager.shared.createTableWithDictionary(tableName: "tableone", params: ["name": "TEXT", "age": "INT"])
        print(creatFlag)

        let columnArray = FMDBManager.shared.getColumnArray(tableName: "tableone", db: FMDBManager.shared.db!)
        print(columnArray)



        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

