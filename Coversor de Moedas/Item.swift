//
//  Item.swift
//  Coversor de Moedas
//
//  Created by Bruno Maciel on 28/11/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
