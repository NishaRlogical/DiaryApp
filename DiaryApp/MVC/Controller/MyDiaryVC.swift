//
//  ViewController.swift
//  DiaryApp
//
//  Created by rlogical-dev-11 on 18/11/20.
//

import UIKit
import Closures
import MaterialActivityIndicator
import RxSwift

class MyDiaryVC: UIViewController {

    //MARK:- -- Outlets & Variable Declaration --
    var objModel:[DairyModel] = [DairyModel]()
    private var dictData: [String: [DairyModel]] = [:]
    private var arrKeys = [String]()
    private var isAPICallFirstTime: Bool = true
    private let indicator = MaterialActivityIndicatorView()
    private(set) var disposeBag: DisposeBag = DisposeBag()
    @IBOutlet weak var tblDiaryData: UITableView!
    
    
    //MARK:- -- View LifeCycle --
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "isFirstTime") == false
        {
            if Reachability.isConnectedToNetwork() {
                self.getResponse()
            }
            else
            {
                self.showAlertMessage(vc: self, titleStr: "Networkerror", messageStr: "Unable to contact the server")
            }
            
        }
        else
        {
            self.getDairyDataFromDataBase()
        }
        self.tblDiaryData.reloadData()
        
    }

    //MARK:- -- Custom Functions --
    func setUI()
    {
        self.tblDiaryData.estimatedRowHeight = 250
        self.tblDiaryData.rowHeight = UITableView.automaticDimension
        self.tblDiaryData.contentInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 0, right: 0)
        self.setIndicator()
    }
    
    func setIndicator()
    {

        indicator.frame = CGRect(x: UIScreen.main.bounds.height / 2 - 15, y: UIScreen.main.bounds.width / 2 - 15, width: 50, height: 50)
        indicator.center = self.view.center
        indicator.color = UIColor.purple
        self.view.addSubview(indicator)
        
    }
    
    private func makeSectionedData() {
    
        let formatter = DateFormatter()
        var dictData: [String: [DairyModel]] = [:]
                        
        for obj in objModel {
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let strDt = obj.date ?? ""
            if let dt = formatter.date(from: strDt) {
                
                
            
                formatter.dateFormat = "MMM"
                var date = formatter.string(from: dt)
                
                if Calendar.current.isDate(dt, equalTo: Date(), toGranularity: .day) {
                    date = "TODAY"
                }
                else if Calendar.current.isDate(dt, equalTo: Calendar.current.date(byAdding: .day, value: -1, to: Date())!    , toGranularity: .day) {
                    date = "YESTERDAY"
                }
                
                if var arrMsgs = dictData[date], !arrMsgs.isEmpty {
                    arrMsgs.append(obj)
                    dictData[date] = arrMsgs
                } else {
                    dictData[date] = [obj]
                }
            }
        }
        
        self.dictData = dictData
        let keys = Array(dictData.keys)
        
        let sortedDic = keys.sorted { (aDic, bDic) -> Bool in
            formatter.dateFormat = "MMM"
            let dt = formatter.date(from: aDic)
            let dt1 = formatter.date(from: bDic)
            return dt! < dt1!
        }
        arrKeys = sortedDic
        print(arrKeys)
    }
    
    
}
//MARK:- -- API Calling --

extension MyDiaryVC {
    
    //MARK:- --Get API Response--
    //Use RXSwift
    func getResponse(){
        self.indicator.startAnimating()
        ServiceManager.shared.getDairyData(withParams: [:]).subscribe({ [weak self] response in
            guard let self = self else {
                return
            }
             switch response {
             case let .next((status, error, dairyData)):
                guard let response = dairyData else { return }
                self.indicator.stopAnimating()
                DBManager.shared().insertRecord(modelData: response)
                UserDefaults.standard.setValue(self.isAPICallFirstTime, forKey: "isFirstTime")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.getDairyDataFromDataBase()
                    self.tblDiaryData.reloadData()
                })
                debugPrint(error as Any)
                debugPrint(status)
                break
                // data
             case let .error(error):
                debugPrint(error)
                break
               // error
            case .completed:
                break
            }
        }).disposed(by: disposeBag)
    }

    //MARK:- --Get Data From DataBase--
    func getDairyDataFromDataBase(){
        objModel = DBManager.shared().loadDairyData()
        self.makeSectionedData()
    }
    
    //MARK:- --Show Alert Message--
     func showAlertMessage(vc: UIViewController, titleStr:String, messageStr:String) -> Void {
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertController.Style.alert);
        vc.present(alert, animated: true, completion: nil)
    }
    
}

//MARK:- -- TableView Delegate DataSource --
extension MyDiaryVC: UITableViewDelegate, UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dictData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = arrKeys[section]
        return (dictData[key] ?? []).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiaryCell") as! MyDiaryTableViewCell
        
        let key = arrKeys[indexPath.section]
        let arr = dictData[key] ?? []
        let obj = arr[indexPath.row]
        
        cell.lblDiaryTitle.text = obj.title.uppercased()
        cell.lblDiaryData.text = obj.content

        
        let date = objModel[indexPath.row].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        let getdate = dateFormatter.date(from:date!)
        let convertedDate =  timeConvertFromDate(date: getdate ?? Date())
        cell.lblHours.text =  convertedDate
        
        

        //For Edit Diary Data
        cell.btnEdit.onTap { [weak self] in
            if self == nil {
                return
            }
            let editVC = self?.storyboard?.instantiateViewController(identifier: "DiaryEditVC") as! DiaryEditVC
            editVC.dataTitle = obj.title
            editVC.dataContent = obj.content
            editVC.model = obj
            self?.navigationController?.pushViewController(editVC, animated: true)
        }
        
        //For Delete Diary Data
        cell.btnClose.onTap { [weak self] in
            if self == nil {
                return
            }
            let selectedDiary:DairyModel = (self!.dictData[key]?[indexPath.row])!
            self!.dictData[key]?.remove(at: indexPath.row)
            if  let count: Int  =  self!.dictData[key]?.count, count == 0 {
                self!.arrKeys.remove(at: indexPath.section)
                self!.dictData.removeValue(forKey: key)
            }
            if DBManager.shared().deleteDairy(withID: selectedDiary.id ?? "0"){
                print("Delete success")
            }
            self!.tblDiaryData.reloadData()
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
        let obj = arrKeys[section]
        headerCell.lblDays.text = obj
        return headerCell
    }
        
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
}

