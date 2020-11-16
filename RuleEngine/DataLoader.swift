//
//  DataSyncer.swift
//  RuleEngine
//
//  Created by Afzal Hossain on 11/1/20.
//  Copyright © 2020 Afzal Hossain. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import UIKit
import Alamofire

class Loader:NSObject{
    
    static let sharedInstance = Loader()
    var context: NSManagedObjectContext!
    
    override init() {
        super.init()
        context = (UIApplication.shared.delegate as! AppDelegate).managedContext
    }
    
    func saveContext(){
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func loadStudies(email:String){
//        let email:String = Utils.getDataFromUserDefaults(key: "email") as! String
        let serviceUrl = Utils.getBaseUrl() + "study/list/enrolled/active?email=\(email)&uuid=\(Utils.getDeviceIdentifier())"
        Alamofire.request(serviceUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                let json = JSON(response.result.value as Any)
                print("response my studies list : \(json)")
                
                var studyDict = Dictionary<Int32, Study>()
                
                for item in json.arrayValue{
                    print("id : \(item["id"].intValue)")
                    let studyId = Int16(item["id"].intValue)
                    let name = item["name"].stringValue
                    let modificationTime = item["modificationTime"].stringValue
                    
                    
                    //insert study
                    print("insert study")
                    let newStudy:Study = NSEntityDescription.insertNewObject(forEntityName: "Study", into: self.context) as! Study
                    newStudy.studyId = studyId
                    newStudy.name = name
                    newStudy.studyDescription = item["description"].stringValue
                    newStudy.modificationTime = modificationTime
                    newStudy.state = Int16(item["state"].intValue)
                    newStudy.instruction = item["instruction"].stringValue
                    newStudy.iconUrl = item["iconUrl"].stringValue
                    self.saveContext()
                    
                    self.loadSensorConfigs(studyId: studyId)
                }
                
                print("total study in before delete db \(self.getAllStudies().count)")
                
                self.printStudies(studies: self.getAllStudies())
            case .failure(let error):
                print(error)
            // TODO: show error label - service not available
            }
        }
        
    }
    
    func insertStudy(studyStruct:StudyStruct){
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let newStudy:Study = NSEntityDescription.insertNewObject(forEntityName: "Study", into: self.context) as! Study
        newStudy.studyId = studyStruct.studyId
        newStudy.name = studyStruct.name
        newStudy.studyDescription = studyStruct.studyDescription
        newStudy.modificationTime = studyStruct.modificationTime
        newStudy.state = studyStruct.state
        newStudy.instruction = studyStruct.studyDescription
        newStudy.iconUrl = studyStruct.iconUrl
        self.saveContext()
        
    }
    
    func deleteStudies(){
        var studies:[Study] = self.getAllStudies()
        for study in studies{
            self.context.delete(study)
            self.saveContext()
        }
    }
    
//    func getStudy(studyId:Int32)->Study!{
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Study")
//        fetchRequest.predicate = NSPredicate(format: "studyId = %d", studyId)
//        do{
//            let studyData = try context.fetch(fetchRequest) as! [Study]
//            if studyData.count == 0{
//                return nil
//            } else {
//                return studyData[0]
//            }
//        } catch let error as NSError{
//            print("error:\(error)")
//            return nil
//        }
//    }
    
    func getAllStudies()->[Study]!{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Study")
        do{
            return try context.fetch(fetchRequest) as! [Study]
        } catch let error as NSError{
            print("error:\(error)")
            return nil
        }
    }
    
//    func getAllStudyStructs()->[StudyStruct]!{
//        var studyStructs:[StudyStruct] = [StudyStruct]()
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Study")
//        do{
//            let studies = try context.fetch(fetchRequest) as! [Study]
//            //printStudies(studies: studies)
//            for study in studies{
//                studyStructs.append(StudyStruct(studyId: study.studyId, name: study.name!, studyDescription: "", instruction:"", modificationTime: "", state: study.state, iconUrl: ""))
//            }
//        } catch let error as NSError{
//            print("error:\(error)")
//        }
//        return studyStructs
//    }

    func printStudies(studies:[Study]){
        for study in studies{
            print("studyId:\(study.studyId), name:\(String(describing: study.name!)), description:\(String(describing: study.studyDescription!)), state:\(study.state), modification time:\(String(describing: study.modificationTime!)), instruction:\(String(describing: study.instruction)), iconUrl:\(String(describing: study.iconUrl))")
        }
    }
    
    
    func loadSensorConfigs(studyId:Int16){
//        let email:String = Utils.getDataFromUserDefaults(key: "email") as! String
        let serviceUrl = Utils.getBaseUrl() + "study/\(studyId)/sensorconfigs/published"
        print("load config url:\(serviceUrl)")
        Alamofire.request(serviceUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                let json = JSON(response.result.value as Any)
                print("response sensor config list : \(json)")
                
//                var studyDict = Dictionary<Int32, Study>()
                
                for item in json.arrayValue{
                    let newConfig:SensorConfig = NSEntityDescription.insertNewObject(forEntityName: "SensorConfig", into: self.context) as! SensorConfig
                    newConfig.id = Int16(item["id"].intValue)
                    newConfig.studyId = Int16(item["studyId"].intValue)
                    newConfig.version = Int16(item["publishedVersion"].intValue)
                    newConfig.state = Int16(item["state"].intValue)
                    newConfig.lifecycle = Int16(item["lifecycle"].intValue)
                    self.saveContext()
                    
                    self.loadMappings(studyId: studyId, configId: Int16(item["studyId"].intValue))
                }
                
                self.printConfigs(configs: self.getAllConfigs())
            case .failure(let error):
                print(error)
            // TODO: show error label - service not available
            }
        }
        
    }
    
    func loadMappings(studyId:Int16, configId:Int16){
        let serviceUrl = Utils.getBaseUrl() + "rules/mapping?study_id=\(studyId)&config_id=\(configId)"
        print("load mapping url:\(serviceUrl)")
        Alamofire.request(serviceUrl).validate().responseJSON { response in
            switch response.result {
            case .success:
                let json = JSON(response.result.value as Any)
                print("response sensor mapping list : \(json)")
                
                for item in json.arrayValue{
                    let newMapping:TriggerActionMapping = NSEntityDescription.insertNewObject(forEntityName: "TriggerActionMapping", into: self.context) as! TriggerActionMapping
                    newMapping.studyId = Int16(item["studyId"].intValue)
                    newMapping.sensorConfigId = Int16(item["sensorConfigId"].intValue)
                    newMapping.mappingId = Int16(item["mappingId"].intValue)
                    newMapping.sources = item["sources"].stringValue
                    newMapping.triggerType = item["type"].stringValue
                    newMapping.triggerJson = item["triggerString"].stringValue
                    newMapping.actions = item["actions"].stringValue
                    self.saveContext()
                    
                }
                
                self.printMappings(mappings: self.getAllMappings())
            case .failure(let error):
                print(error)
            // TODO: show error label - service not available
            }
        }
        
    }
    
    func insertSensorConfig(config:SensorConfigStruct){
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let newConfig:SensorConfig = NSEntityDescription.insertNewObject(forEntityName: "SensorConfig", into: self.context) as! SensorConfig
        newConfig.id = config.id
        newConfig.studyId = config.studyId
        newConfig.version = config.version
        newConfig.state = config.state
        newConfig.lifecycle = config.lifecycle
        self.saveContext()
        
    }
    
    func deleteAllConfigs(){
        var configs:[SensorConfig] = self.getAllConfigs()
        for config in configs{
            self.context.delete(config)
            self.saveContext()
        }
    }
    
    
    func getAllConfigs()->[SensorConfig]!{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SensorConfig")
        do{
            return try self.context.fetch(fetchRequest) as? [SensorConfig]
        } catch let error as NSError{
            print("error:\(error)")
            return nil
        }
    }
    
    func printConfigs(configs:[SensorConfig]){
        for config in configs{
            print("id:\(config.id), study Id:\(config.studyId), version:\(config.version), state:\(config.state), lifecycle:\(config.lifecycle)")
        }
    }

    
    func insertMapping(mapping:TriggerActionMappingStruct){
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let newMapping:TriggerActionMapping = NSEntityDescription.insertNewObject(forEntityName: "TriggerActionMapping", into: self.context) as! TriggerActionMapping
        newMapping.studyId = mapping.studyId
        newMapping.sensorConfigId = mapping.sensorConfigId
        newMapping.mappingId = mapping.mappingId
        newMapping.sources = mapping.sources
        newMapping.triggerType = mapping.triggerType
        newMapping.triggerJson = mapping.triggerJson
        newMapping.actions = mapping.actions
        self.saveContext()
        
    }
    
    func deleteAllMappings(){
        let mappings:[TriggerActionMapping] = self.getAllMappings()
        for mapping in mappings{
            self.context.delete(mapping)
            self.saveContext()
        }
    }
    
    func getAllMappings()->[TriggerActionMapping]!{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TriggerActionMapping")
        do{
            return try (self.context.fetch(fetchRequest) as? [TriggerActionMapping])
        } catch let error as NSError{
            print("error:\(error)")
            return nil
        }
    }
    
    func printMappings(mappings:[TriggerActionMapping]){
        for mapping in mappings{
            print("study id:\(mapping.studyId), config id:\(mapping.sensorConfigId), mapping is:\(mapping.mappingId), sources:\(mapping.sources), type:\(mapping.triggerType), json:\(mapping.triggerJson), actions:\(mapping.actions)")
        }
    }
    
}
