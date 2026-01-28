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
    
    let client = SupabaseClient(
      supabaseURL: URL(string: "https://itiaamztvjznrxonspvb.supabase.co")!,
      supabaseKey: "sb_secret_ECxS_tdi7XjikFnkK9KemA_IiMbpXT1"
    )

    func fetchAll<T: Codable & Identifiable>(
        from table: String
    ) async throws -> [T] {
        try await client
            .from(table)
            .select()
            .execute()
            .value
    }

    func fetchById<T: Codable & Identifiable>(
        from table: String,
        id: T.ID
    ) async throws -> T? {
        try await client
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
        try await client
            .from(table)
            .insert(value)
            .execute()
    }

    func update<T: Codable & Identifiable>(
        _ value: T,
        in table: String
    ) async throws {
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
        try await client
            .from(table)
            .delete()
            .eq("id", value: "\(id)")
            .execute()
    }
}
