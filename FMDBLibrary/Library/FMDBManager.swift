//
//  FMDBManager.swift
//  FMDBLibrary
//
//  Created by monstar on 2018/7/18.
//  Copyright © 2018年 monstar. All rights reserved.
//

import Foundation
import FMDB

let cachePath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true).first
let SQL_TEXT = "TEXT"
let SQL_INTEGER = "INTEGER"
let SQL_INT = "INT"
let SQL_REAL = "REAL"
let SQL_BLOB = "BLOB"

class FMDBManager {
    private var dbQueue: FMDatabaseQueue?
    public var db: FMDatabase?
    private var path: String?

    var staticFMDB: FMDBManager?
    static let shared = FMDBManager()
    public func shareDataBase(dataBaseName: String = "Data.sqlite", _ dataBasePath: String = cachePath ?? "") -> FMDBManager? {
        if staticFMDB == nil {
            path = (dataBasePath as NSString).appendingPathComponent(dataBaseName)
            let fmdb = FMDatabase(path: path)
            if fmdb.open() {
                staticFMDB = FMDBManager()
                staticFMDB?.db = fmdb
                db = fmdb
                staticFMDB?.path = path
            }
        }
        if !(staticFMDB?.db?.open() ?? false) {
            return nil
        }
        return staticFMDB
    }

    public func createTableWithDictionary(tableName: String, params: [String: Any]) -> Bool {
        return createTableWithDictionaryAndExcludeName(tableName: tableName, params: params, excludeName: [])
    }

    private func createTableWithDictionaryAndExcludeName(tableName: String, params: [String: Any], excludeName: [String]) -> Bool {
        var fieldString: String = "CREATE TABLE \(tableName) (pkid  INTEGER PRIMARY KEY,"
        var keyCount: Int = 0
        for key in params {
            keyCount += 1
            if (excludeName.count != 0 && excludeName.contains(key.key)) || key.key == "pkid" {
                continue
            }
            if keyCount == params.count {
                fieldString.append(" \(key.key) \(key.value));")
                break
            }
            fieldString.append("\(key.key) \(key.value),")
        }
        return db?.executeUpdate(fieldString, withArgumentsIn: []) ?? false
    }

    public func getColumnArray(tableName: String, db: FMDatabase) -> [String] {
        var array: [String] = [String]()
        let resultSet = db.getTableSchema(tableName)
        while resultSet.next() {
            array.append(resultSet.string(forColumn: "name") ?? "")
        }
        return array
    }

    private func getColumnTypeArray(tableName: String, db: FMDatabase) -> [String] {
        var array: [String] = [String]()
        let resultSet = db.getTableSchema(tableName)
        while resultSet.next() {
            array.append(resultSet.string(forColumn: "type") ?? "")
        }
        return array
    }

    public func insertTable(tableName: String, params: [String: Any]) -> Bool {
        if let db = db {
            let array = getColumnArray(tableName: tableName, db: db)
            return insertTableWithParams(tableName: tableName, params: params, columnArray: array)
        }
        return false
    }

    private func insertTableWithParams(tableName: String, params: [String: Any], columnArray: [String]) -> Bool {
        var finalString = "INSERT INTO \(tableName) ("
        var tempString = ""
        var argumentsArray = [Any]()
        for key in params {
            if !columnArray.contains(key.key) || key.key == "pkid" {
                continue
            }
            finalString.append(contentsOf: "\(key.key),")
            tempString.append("?,")
            if let argumentKay = params["\(key.key)"] {
                argumentsArray.append(argumentKay)
            }
        }
        finalString.remove(at: finalString.index(before: finalString.endIndex))
        if tempString.count != 0 {
            tempString.remove(at: tempString.index(before: tempString.endIndex))
        }
        finalString.append(") values (\(tempString))")
        if let db = db {
            return db.executeUpdate(finalString, withArgumentsIn: argumentsArray)
        }
        return false
    }

    public func deleteTable(tableName: String, whereDictionary: [String: Any]) -> Bool {
        var finalString = "DELETE FROM \(tableName) WHERE "
        var argumentsArray = [Any]()
        var keyCount: Int = 0
        for key in whereDictionary {
            keyCount += 1
            if keyCount == whereDictionary.count {
                finalString.append(contentsOf: "\(key.key) = ?")
                argumentsArray.append(key.value)
                break
            }
            finalString.append(contentsOf: "\(key.key) = ? AND ")
            argumentsArray.append(key.value)
        }
        if let db = db {
            return db.executeUpdate(finalString, withArgumentsIn: argumentsArray)
        }
        return false
    }

    public func updateTable(tableName: String, params: [String: Any], whereDictionary: [String: Any]) -> Bool {
        var finalString = "UPDATE \(tableName) SET"
        var columnArray = [String]()
        var argumentsArray = [Any]()
        if let db = db {
            columnArray = getColumnArray(tableName: tableName, db: db)
            for key in params {
                if !columnArray.contains(key.key) || key.key == "pkid" {
                    continue
                }
                finalString.append(" \(key.key) = ?,")
                argumentsArray.append(key.value)
            }
            if finalString.hasSuffix(",") {
                finalString.remove(at: finalString.index(before: finalString.endIndex))
            }
            finalString.append(" WHERE ")
            var keyCount = 0
            for key in whereDictionary {
                keyCount += 1
                if keyCount == whereDictionary.count {
                    finalString.append(contentsOf: "\(key.key) = ?")
                    argumentsArray.append(key.value)
                    break
                }
                finalString.append(contentsOf: "\(key.key) = ? AND ")
                argumentsArray.append(key.value)
            }
            return db.executeUpdate(finalString, withArgumentsIn: argumentsArray)
        }
        return false
    }

    public func selectTable(tableName: String, params: [String: Any]?,  whereDictionary: [String: Any]?) -> [[String: Any]]? {
        if let db = db {
            let tableColumnArray = getColumnArray(tableName: tableName, db: db)
            var resultDictionary: [[String: Any]] = [[String: Any]]()
            var finalString = "SELECT * FROM \(tableName)"
            var argumentsArray = [Any]()
            var keyCount = 0
            var set: FMResultSet?
            if let whereDictionary = whereDictionary {
                finalString.append(" WHERE ")
                for key in whereDictionary {
                    keyCount += 1
                    if keyCount == whereDictionary.count {
                        finalString.append(contentsOf: "\(key.key) = ?")
                        argumentsArray.append(key.value)
                        break
                    }
                    finalString.append(contentsOf: "\(key.key) = ? AND ")
                    argumentsArray.append(key.value)
                }
                set = db.executeQuery(finalString, withArgumentsIn: argumentsArray)
            } else {
                set = db.executeQuery(finalString, withArgumentsIn: argumentsArray)
            }
            if let set = set {
                while set.next() {
                    var resultDic: [String: Any] = [String: Any]()
                    var columnDictionary: [String: Any] = [String: Any]()
                    if params == nil{
                        let columnTypeArray = getColumnTypeArray(tableName: tableName, db: db)
                        for (index,value) in tableColumnArray.enumerated() {
                            columnDictionary[value] = columnTypeArray[index]
                        }
                    }
                    for key in params ?? columnDictionary {
                        if let valueString = key.value as? String {
                            let keyString = key.key
                            if valueString == SQL_TEXT {
                                if let value = set.string(forColumn: keyString) {
                                    resultDic["\(keyString)"] = value
                                }
                            } else if valueString == SQL_INTEGER {
                                let value = set.longLongInt(forColumn: keyString)
                                resultDic["\(keyString)"] = value
                            } else if valueString == SQL_INT {
                                let value = set.longLongInt(forColumn: keyString)
                                resultDic["\(keyString)"] = value
                            } else if valueString == SQL_REAL {
                                let value = set.double(forColumn: keyString)
                                let number = NSNumber(value: value)
                                resultDic["\(keyString)"] = number
                            } else if valueString == SQL_BLOB {
                                let value = set.data(forColumn: keyString)
                                if let valueData = value {
                                    resultDic["\(keyString)"] = valueData
                                }
                            }
                        }
                    }
                    resultDictionary.append(resultDic)
                }
            }
            return resultDictionary
        }
        return nil
    }

}
