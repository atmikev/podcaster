//
//  TMDownloadManager.swift
//  Podcaster
//
//  Created by Tyler Mikev on 3/23/15.
//  Copyright (c) 2015 Tyler Mikev. All rights reserved.
//

import Foundation

class TMDownloadManager : NSObject, NSURLSessionDownloadDelegate {
    
    var fileName : String?
    var fileDownloadTask : NSURLSessionDownloadTask?
    var session : NSURLSession?
    var updateBlock : ((percentage : Float) -> ())?
    var successBlock : ((filePath : String) -> ())?
    var failureBlock : ((error : NSError) -> ())?
    
    func downloadPodcastAtURL(downloadURL: NSURL, fileName: String, updateBlock: ((percentage : Float) -> ())?, successBlock: ((filePath : String) -> ())?, failureBlock: ((error : NSError) -> ())?) -> () {
        
        self.updateBlock = updateBlock
        self.successBlock = successBlock
        self.failureBlock = failureBlock
        
        //get the default session config
        var sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        sessionConfig.allowsCellularAccess = true
        //30 sec timeout
        sessionConfig.timeoutIntervalForRequest = 30
        //15 min max time for download
        sessionConfig.timeoutIntervalForResource = 60.0 * 15
        sessionConfig.HTTPMaximumConnectionsPerHost = 1
        
        self.session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        
        self.fileDownloadTask = self.session?.downloadTaskWithURL(downloadURL)
    }
    
    func callFailureBlockWithError(error: NSError?) {
        if let error = error {
            if let failureBlock = self.failureBlock {
                failureBlock(error: error)
            }
        }
    }
    
    func saveData(fileData: NSData, fileName: String, fileWritingError: NSErrorPointer) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let filePath = documentsPath.stringByAppendingString(fileName)
        
        fileData.writeToFile(fileName, options: .DataWritingAtomic, error: fileWritingError)
        
        return filePath
    }
    
//MARK: NSURLSessionDownloadDelegate Methods
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if let updateBlock = self.updateBlock {
            var percentage = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            updateBlock(percentage: percentage)
        }
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        self.callFailureBlockWithError(error)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        self.callFailureBlockWithError(error)
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        var fileReadingError : NSError?
        var options =  NSDataReadingOptions.DataReadingMappedIfSafe
        let fileData = NSData(contentsOfURL: location, options: options, error: &fileReadingError)
        
        if let fileReadingError = fileReadingError {
            self.callFailureBlockWithError(fileReadingError)
        } else if let fileData = fileData {
            if let fileName = self.fileName {
                
                var fileWritingError : NSError?
                let savedFileLocation = self.saveData(fileData, fileName: fileName, fileWritingError: &fileWritingError)
                
                if let fileWritingError = fileWritingError {
                    //if we've failed, call the fail block
                    self.callFailureBlockWithError(fileWritingError)
                } else {
                    //otherwise pass back the file location
                    if let successBlock = self.successBlock {
                        successBlock(filePath: savedFileLocation)
                    }
                }
            }
        }
    }
    
    
}