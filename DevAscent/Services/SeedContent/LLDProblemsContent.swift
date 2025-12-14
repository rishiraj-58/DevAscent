//
//  LLDProblemsContent.swift
//  DevAscent
//
//  Aggregates all LLD problem content from individual files
//

import Foundation

/// Provides all LLD problems from modular files
struct LLDProblemsContent {
    
    /// Returns all LLD problems for seeding
    static func all() -> [LLDProblem] {
        return [
            CarRentalLLD.create(),
            SnakeLadderLLD.create(),
            StockExchangeLLD.create(),
            ParkingLotLLD.create(),
            AirTrafficLLD.create(),
            TwitterFeedLLD.create(),
            ECommerceLLD.create(),
            URLShortenerLLD.create(),
            SplitwiseLLD.create(),
            QuickCommerceLLD.create()
        ]
    }
}
