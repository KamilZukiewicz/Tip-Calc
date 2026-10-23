//
//  SupabaseService.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 21/01/2026.
//

import Foundation
import Supabase

public protocol SupabaseServiceProtocol {
    func fetchAll<T: Codable & Identifiable>(
        from table: String
    ) async throws -> [T]
    
    func fetchById<T: Codable & Identifiable>(
        from table: String,
        id: T.ID
    ) async throws -> T?
    
    func insert<T: Codable & Identifiable>(
        _ value: T,
        into table: String
    ) async throws
    
    func update<T: Codable & Identifiable>(
        _ value: T,
        in table: String
    ) async throws
    
    func delete<T: Codable & Identifiable>(
        value: T,
        from table: String,
        id: T.ID
    ) async throws
}

final class SupabaseService: SupabaseServiceProtocol {
    
    private let limitKey = "limitKey"
    private let dateKey = "dateKey"
    private let requestsLimit = 100
    private var currentRequetNumber = 0
    private var requestDate: Date?
    
    let client = SupabaseClient(
      supabaseURL: URL(string: "https://itiaamztvjznrxonspvb.supabase.co")!,
      supabaseKey: "sb_secret_Suparbase_Key"
    )
    
    init() {
        self.currentRequetNumber = UserDefaults.standard.integer(forKey: limitKey)
        if let oldDate = UserDefaults.standard.string(forKey: dateKey)?.date {
            let current = Date.now
            let shouldResetLimit = current.timeIntervalSince(oldDate) > 60 * 60 * 24
            print("Should reset?: \(shouldResetLimit)")
            if shouldResetLimit {
                UserDefaults.standard.removeObject(forKey: limitKey)
                UserDefaults.standard.removeObject(forKey: dateKey)
                self.currentRequetNumber = 0
                self.requestDate = nil
            } else {
                requestDate = oldDate
            }
        }
    }

    func fetchAll<T: Codable & Identifiable>(
        from table: String
    ) async throws -> [T] {
        guard currentRequetNumber <= requestsLimit else {
            if requestDate == nil {
                requestDate = Date.now
                UserDefaults.standard.set(requestDate?.formattedDate, forKey: dateKey)
            }
            throw NetworkError.limitError
        }
        incrementRequestCounter()
        return try await client
            .from(table)
            .select()
            .execute()
            .value
    }

    func fetchById<T: Codable & Identifiable>(
        from table: String,
        id: T.ID
    ) async throws -> T? {
        guard currentRequetNumber <= requestsLimit else {
            throw NetworkError.limitError
        }
        incrementRequestCounter()
        return try await client
            .from(table)
            .select()
            .eq("id", value: "\(id)")
            .single()
            .execute()
            .value
    }

    func insert<T: Codable & Identifiable>(
        _ value: T,
        into table: String
    ) async throws {
        guard currentRequetNumber <= requestsLimit else {
            throw NetworkError.limitError
        }
        incrementRequestCounter()
        try await client
            .from(table)
            .insert(value)
            .execute()
    }

    func update<T: Codable & Identifiable>(
        _ value: T,
        in table: String
    ) async throws {
        guard currentRequetNumber <= requestsLimit else {
            throw NetworkError.limitError
        }
        incrementRequestCounter()
        try await client
            .from(table)
            .update(value)
            .eq("id", value: "\(value.id)")
            .execute()
    }

    func delete<T: Codable & Identifiable>(
        value: T,
        from table: String,
        id: T.ID
    ) async throws {
        guard currentRequetNumber <= requestsLimit else {
            throw NetworkError.limitError
        }
        incrementRequestCounter()
        try await client
            .from(table)
            .delete()
            .eq("id", value: "\(id)")
            .execute()
    }
    
    private func incrementRequestCounter() {
        currentRequetNumber += 1
        UserDefaults.standard.set(currentRequetNumber, forKey: limitKey)
    }
}
