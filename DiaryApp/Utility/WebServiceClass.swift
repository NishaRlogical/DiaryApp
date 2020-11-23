//
//  ViewController.swift
//  DiaryApp
//
//  Created by rlogical-dev-11 on 18/11/20.
//


import UIKit
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import RxSwift

let getDairyData_URL = "https://private-ba0842-gary23.apiary-mock.com/notes"

class ServiceManager: NSObject {
    
    var lastRequst: DataRequest? = nil
    var device_type: String = "IOS"
    var isAppUpdateShow:Bool = false
    var checkBuyingOrSelling : Int = 0
    var notificationCount : Int = 0
    var chatNotificationCount : Int = 0
    var settingNotificationCount : Int = 0
    var checkActiveUserOrNot:Bool = true
    var checkRefreshMyListing:Bool = false
    
    
    //MARK:- SHAREDMANAGER
    static let shared : ServiceManager = {
        let instance = ServiceManager()
        return instance
    }()
    

    func callGETApi(url: String, parameters: [String : AnyObject], showLoader shouldShow: Bool = true, hideLoader shouldHide: Bool = true, isHeader : Bool = false, completionHandler: (( Bool, NSArray?, String?) -> Void)?){

        print("===== URL ===== \(url) ")

        //For print parameters
        let jsonData = try! JSONSerialization.data(withJSONObject: parameters as Parameters, options: .prettyPrinted)
        let jsonString =  String(data: jsonData, encoding: .utf8)
        print("===== PARAMS ===== \(jsonString!)")

        let Url = URL(string: url)!
        var urlRequest = URLRequest(url: Url)
        urlRequest.httpMethod = "GET"
        let urlreq = try! JSONEncoding.default.encode(urlRequest, with: nil)

        self.lastRequst = AF.request(urlreq)

        self.lastRequst?.responseJSON(completionHandler: { (response) in

            switch response.result {
            case .success(let data):
                let dictResponse = data as! NSArray
                if let jsonString = String(data: response.data!, encoding: .utf8) {
                    print("===== dictResponse ===== \( jsonString)")
                }
                if response.response?.statusCode == 200 {
                    let message : String = "success"
                    if let validHandler = completionHandler {
                        validHandler(true, dictResponse, message)
                    }
                }
                else{
                    if let validHandler = completionHandler {
                        validHandler(true, dictResponse, "Server error" )
                    }
                }
            case .failure(let error):
                print(response)
                if let validHandler = completionHandler {
                    validHandler(false, nil, error.errorDescription! )
                }
            }
        })
    }
}


//RXSwift
extension ServiceManager
{
 func getDairyData(withParams param : [String: AnyObject?]) -> Observable<(Bool,String?,[DairyModel]?)> {
        return Observable.create { (observer) -> Disposable in

            ServiceManager.shared.callGETApi(url: getDairyData_URL, parameters: param as [String : AnyObject],showLoader: true, hideLoader:true,isHeader:true) { (status, dictResponse, errorMessage) in
                if status{
                    let responselist = Mapper<DairyModel>().mapArray(JSONArray: dictResponse as! [[String : Any]])
                    observer.onNext((status,errorMessage,responselist))
                    observer.onCompleted()
                }else{
                    print("getDairyData - \(errorMessage!)")
                    observer.onNext((status,errorMessage,nil))
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
        
    }
}


