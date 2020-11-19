//
//  DiaryEditVC.swift
//  DiaryApp
//
//  Created by rlogical-dev-11 on 18/11/20.
//

import UIKit

class DiaryEditVC: UIViewController, UITextFieldDelegate {

    //MARK:- -- Outlets & Variable Declaration --
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var txtContent: UITextView!
    @IBOutlet weak var lblDiaryTitle: UILabel!
    
    var dataTitle: String = ""
    var dataContent: String = ""
    var objModel:[DairyModel] = [DairyModel]()
    var model: DairyModel!

    
    //MARK:- -- View LifeCycle --
    override func viewDidLoad() {
        super.viewDidLoad()
        txtTitle.delegate = self
        self.setUI()
       
    }
    
    //MARK:- -- Custom Functions --
    func setUI()
    {
        btnSave.layer.cornerRadius = 5
        btnSave.layer.masksToBounds = true
        txtTitle.text = dataTitle
        lblDiaryTitle.text = dataTitle
        txtContent.text = dataContent
    }

    //MARK:- -- Button Actions --
    @IBAction func saveClick(_ sender: UIButton) {
        objModel = DBManager.shared().loadDairyData()
        model.title =  txtTitle.text
        model.content = txtContent.text
        DBManager.shared().updateDairy(modelData: model)
        self.navigationController?.popViewController(animated: true)

    }
    
    @IBAction func backClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    //MARK:-   --TextField Delegate ----
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.txtTitle.endEditing(true)
        return true
    }

    
}
