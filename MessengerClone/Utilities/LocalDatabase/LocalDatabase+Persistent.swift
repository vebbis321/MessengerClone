//
//  LocalDatabase+Persistent.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 19/05/2023.
//

import Foundation
import GRDB

extension LocalDatabase {
    /// The database for the application
    static let shared = makeShared()

    static func makeShared() -> LocalDatabase {
        do {
            let fileManager = FileManager()

            // use the applicationSupportDirectory so the user cant see the data
            let folder = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("database", isDirectory: true)
            try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)

            // Open or create the database
            let databaseUrl = folder.appendingPathComponent("db.sqlite")
            let writer = try DatabasePool(path: databaseUrl.path) // DatabasePool opens your SQLite database in the WAL mode. (FASTER!!!)
            let database = try LocalDatabase(writer)
            return database

        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //
            // Typical reasons for an error here include:
            // * The parent directory cannot be created, or disallows writing.
            // * The database is not accessible, due to permissions or data protection when the device is locked.
            // * The device is out of space.
            // * The database could not be migrated to its latest schema version.
            // Check the error message to determine what the actual problem was.
            fatalError("Unresolved error \(error)")
        }
    }
}
