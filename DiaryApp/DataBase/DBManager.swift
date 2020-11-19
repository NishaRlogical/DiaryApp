
//
//  ViewController.swift
//  DiaryApp
//
//  Created by rlogical-dev-11 on 18/11/20.
//

import UIKit

var sharedInstance:DBManager? = nil

class DBManager: NSObject {

    let databaseFileName = "dairydb.sqlite"
    var pathToDatabase: String?
    var database: FMDatabase!
    
    
    class func shared() -> DBManager{
        if sharedInstance == nil{
            sharedInstance = DBManager()
        }
        return sharedInstance!
    }
    
    func getFilePath(){
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
        copyDatabase()
    }
    
    func copyDatabase()
    {
        if !FileManager.default.fileExists(atPath: pathToDatabase ?? "")
        {
            let bundlePath = Bundle.main.path(forResource: "dairydb", ofType: ".sqlite")
            let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let fileManager = FileManager.default
            let fullDestPath = URL(fileURLWithPath: destPath).appendingPathComponent(databaseFileName)
            if fileManager.fileExists(atPath: fullDestPath.path){
                print("Database file is exist")
                print("Path :",database!)
                print(fileManager.fileExists(atPath: bundlePath!))
            }else{
                do{
                    try fileManager.copyItem(atPath: bundlePath!, toPath: fullDestPath.path)
                    database = FMDatabase(path: pathToDatabase!)
                    print("Path :",database!)
                }catch{
                    print("\n",error)
                }
            }
        }
    }
    
    func openDatabase() -> Bool {
        if database == nil {
            if FileManager.default.fileExists(atPath: pathToDatabase ?? "") {
                database = FMDatabase(path: pathToDatabase)
            }
        }

        if database != nil {
            if database.open() {
                return true
            }
        }
        return false
    }
    
    func insertRecord(modelData:[DairyModel]){
        
        if openDatabase() {
            
            for dairy in modelData{
                let content = dairy.content.replacingOccurrences(of: "'", with: "''")
                let quary = "INSERT INTO dairyData(id,title,date,content) VALUES('\(dairy.id!)','\(dairy.title!)','\(dairy.date!)','\(content)')"
                
                if !database.executeStatements(quary) {
                    print("Failed to insert initial data into the database.")
                    print(database.lastError(), database.lastErrorMessage())
                }
                
            }
            
            database.close()
        }
        
    }
    
    func loadDairyData() -> [DairyModel]{
        var dairyList: [DairyModel] = [DairyModel]()
        
        if openDatabase() {
            
            let query = "select * from dairyData"
            
            do {
                
                let results = try database.executeQuery(query, values: nil)
                
                while results.next() {
                    let dairy = DairyModel()
                    dairy.id = results.string(forColumn: "id")
                    dairy.content = results.string(forColumn: "content")
                    dairy.title = results.string(forColumn: "title")
                    dairy.date = results.string(forColumn: "date")
                    dairyList.append(dairy)
                }
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
        
        return dairyList
    }
    
    func updateDairy(modelData:DairyModel) {
        if openDatabase() {
            
            let query = "update dairyData set title=?, content=? where id=?"
            do {
                try database.executeUpdate(query, values: [modelData.title!, modelData.content!, modelData.id!])
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
    }
    
    func deleteDairy(withID ID: String) -> Bool {
        var deleted = false
        
        if openDatabase() {
            let query = "delete from dairyData where id=?"
            
            do {
                try database.executeUpdate(query, values: [Int(ID)!])
                deleted = true
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
        
        return deleted
    }
    
    func clearAll() {
        if openDatabase() {
            
            let query = "DELETE FROM dairyData"
            do {
                try database.executeUpdate(query, values: nil)
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
    }
    
}
