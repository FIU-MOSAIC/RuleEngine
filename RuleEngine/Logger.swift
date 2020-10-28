//
//  Logger.swift
//  prosthesis
//
//  Created by Afzal Hossain on 4/29/20.
//  Copyright © 2020 Shirley Ryan AbilityLab. All rights reserved.
// Used static methods from Dalton Cherry
//////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Log.swift
//
//  Created by Dalton Cherry on 12/23/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
//  Simple logging class.
//////////////////////////////////////////////////////////////////////////////////////////////////


import Foundation
//import ZipArchive


class Logger{
    ///The max size a log file can be in Kilobytes. Default is 5*1024 (5 MB)
    private var maxFileSize:Int
    
    ///The max number of log file that will be stored. Once this point is reached, the oldest file is deleted.
    private var maxFileCount:Int
    
    ///The directory in which the log files will be written
    private var directory:String
    
    
    //The name of the log files.
    private var fileName = "logfile.log"
    private var filePath:String
    
    private var checkCounter: Int
    private var index = 0
    
    private var compressionRequired:Bool
    
    //Background Queue
    //public var logBackgroundQueue:DispatchQueue? = dispatch_queue_create("cimon.logqueue", DISPATCH_QUEUE_SERIAL)
    private var logBackgroundQueue:DispatchQueue// = DispatchQueue(label: "koios.logqueue")

    init(maxSizeInKB:Int, maxCount:Int, directoryName:String, compression:Bool) {
        self.maxFileSize = maxSizeInKB * 1024
        if maxSizeInKB < 10  {
            maxFileSize = 10 * 1024
        }
        self.maxFileCount = maxCount
        if maxFileCount < 1 {
            maxFileCount = 1
        }
        self.checkCounter = maxSizeInKB/20
        if self.checkCounter < 1 {
            self.checkCounter = 1
        }
        self.logBackgroundQueue = DispatchQueue(label: "logq.\(directoryName)")
        self.directory = Logger.createDirectoryIfNotExist(name: directoryName)
        self.filePath = "\(self.directory)/\(self.fileName)"
        self.compressionRequired = compression
    }
    
    func getDirectory()-> String{
        return self.directory
    }
    
    static func createDirectoryIfNotExist(name:String) -> String {
        var path = ""
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        path = "\(paths[0])/\(name)"
        if !fileManager.fileExists(atPath: path) && path != ""  {
            do{
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError{
                print("An error occured..\(error)")
            }
            
        }
        return path
    }
    
    func write(text:String){
        self.logBackgroundQueue.sync {
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: filePath) {
                do{
                    try "".write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
                } catch let error as NSError{
                    print("An error occured..\(error)")
                }
                
            }
            if let fileHandle = FileHandle(forWritingAtPath: filePath) {
                let textToWrite = "\(text)\n"

                fileHandle.seekToEndOfFile()
                fileHandle.write(textToWrite.data(using: String.Encoding.utf8)!)
                fileHandle.closeFile()

                if index%checkCounter == 0{
//                    print("\(Utils.currentLocalTimeWithMillisAndZoneInfo())file name:\(directory)/\(fileName), resetting check counter, index:\(index),checkcounter:\(checkCounter)")
                    self.cleanup()
                    index = 0
                }
                index += 1
            }
        }

    }
    
    ///do the checks and cleanup
    func cleanup() {
        let size = fileSize(path: filePath)
//        print("size:\(size), max file size:\(maxFileSize)")
        if size >= maxFileSize{

            compressRollingFile()
            print("going to move file to new location....\(Date())")
            
            //delete the oldest file
            /*let deletePath = "\(directory)/\(logName(maxFileCount))"
             let fileManager = NSFileManager.defaultManager()
             fileManager.removeItemAtPath(deletePath, error: nil)*/
        }
    }

    public func isCompressionRequired()->Bool{
        return self.compressionRequired
    }
    
    ///check the size of a file
    func fileSize(path: String) -> UInt64 {
        let fileManager = FileManager.default
        let attrs: NSDictionary? = try! fileManager.attributesOfItem(atPath: path) as NSDictionary?
        if let dict = attrs {
            return dict.fileSize()
        }
        return 0
    }

    
    func compressRollingFile(){
        let fileManager = FileManager.default
        
        let newFileName = "\(Utils.getDeviceIdentifier())_\(Utils.datetimefilename(date: Date()))"
        let uncompressedExtension = ".csv"
        let compressedExtension = ".zip"
        
        let newPath = "\(directory)/\(newFileName)\(uncompressedExtension)"
        let zippath = "\(newPath)\(compressedExtension)"
        
//        print("Going to zip file.....\(Date()), \(newPath)")
        
        do{
            try fileManager.moveItem(atPath: filePath, toPath: newPath)
            if self.compressionRequired {
//                let status = SSZipArchive.createZipFile(atPath: zippath, withFilesAtPaths: [newPath])
                let status = true
                if status{
                    try fileManager.removeItem(atPath: newPath)
                }else{
//                    systemLogger.write(text: "\(Utils.currentLocalTimeWithMillisAndZoneInfo()),error,file_compression,faile to compress-delete \(newFileName)")

                }
                //
                print("zip done, \(Date()), \(zippath)")
            }
            
        } catch let error as NSError{
            print("An error occured..\(error)")
//            systemLogger.write(text: "\(Utils.currentLocalTimeWithMillisAndZoneInfo()),error,file_compression,faile to move-compress-delete \(newFileName)")

        }

    }

    
}


let dataLogger1:Logger = Logger(maxSizeInKB: (250 * 1024), maxCount: 10, directoryName: "study1", compression: true)

let dataLogger10:Logger = Logger(maxSizeInKB: (250 * 1024), maxCount: 10, directoryName: "study10", compression: true)

let dataLogger50:Logger = Logger(maxSizeInKB: (250 * 1024), maxCount: 10, directoryName: "study50", compression: true)

let dataLogger100:Logger = Logger(maxSizeInKB: (250 * 1024), maxCount: 10, directoryName: "study100", compression: true)
//let systemLogger:Logger = Logger(maxSizeInKB: 100, maxCount: 50, directoryName: "koios", compression: false)
