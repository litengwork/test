//
//  Logger.swift
//  GolfApp
//
//  Created by ri on 2019/12/09.
//  Copyright © 2019 Sony Corporation. All rights reserved.
//

import UIKit

public enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case error = "ERROR"
    case warning = "WARNING"
    case critical = "CRITICAL"
}

class Logger: NSObject {

    static private let logFolderName: String = "Log"
    static private let logFileName: String = "log.txt"

    static public func registerLog() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logFolder: URL = path.appendingPathComponent(Logger.logFolderName)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: logFolder.path) && !fileManager.fileExists(atPath: Logger.getLogPath().path) {
            do {
                try fileManager.createDirectory(at: logFolder, withIntermediateDirectories: true, attributes: nil)
                fileManager.createFile(atPath: Logger.getLogPath().path, contents: nil, attributes: nil)
            } catch let error as NSError {
                // nop
                print("register failed: \(error)")
            }
        }
    }

    static public func Log<T>(logLevel: LogLevel = .debug, _ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let consoleStr = "\(fileName):\(line) \(function) | \(message)"
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let datestr = dformatter.string(from: Date())

        let emojiTxt = logLevel == .error ? "❗️" : ((logLevel == .warning) ? "⚠️" : "")
        let logTxt = "\(emojiTxt)[\(logLevel.rawValue)] \(datestr) \(consoleStr)"
        Logger.appendText(string: logTxt)
        print(logTxt)
    }

    static private func appendText(string: String) {
        do {
            let fileHandle = try FileHandle(forWritingTo: Logger.getLogPath())
            let stringToWrite = "\n" + string
            fileHandle.seekToEndOfFile()
            fileHandle.write(stringToWrite.data(using: String.Encoding.utf8)!)
        } catch let error as NSError {
            print("failed to append: \(error)")
        }
    }

    static private func getLogPath() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logFolder: URL = path.appendingPathComponent(Logger.logFolderName)
        let logUrl: URL = logFolder.appendingPathComponent(Logger.logFileName)
        return logUrl
    }
}
