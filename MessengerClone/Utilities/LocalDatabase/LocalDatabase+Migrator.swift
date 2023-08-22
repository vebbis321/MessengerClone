//
//  LocalDatabase+Migrator.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 19/05/2023.
//

import Foundation
import GRDB

extension LocalDatabase {
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
            migrator.eraseDatabaseOnSchemaChange = true
        #endif
        migrator.registerMigration("v1") { db in
            try createSuggestedUsersTable(db)
        }
        return migrator
    }

    private func createSuggestedUsersTable(_ db: GRDB.Database) throws {
        try db.create(table: "cachedUser") { table in
            table.primaryKey("uuid", .text).notNull()
            table.column("name", .text).notNull()
            table.column("profileImageUrl", .text)
        }
    }
}
