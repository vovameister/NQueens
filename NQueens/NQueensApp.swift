//
//  NQueensApp.swift
//  NQueens
//
//  Created by Vladimir Klevtsov on 19. 2. 2026..
//

import SwiftUI

@main
struct NQueensApp: App {
    var body: some Scene {
        WindowGroup {
            NQueensView()
                .preferredColorScheme(.light)
        }
    }
}
