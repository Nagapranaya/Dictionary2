//
//  DictonaryModel.swift
//  Dictonary2
//
//  Created by Pranaya on 8/16/24.
//

import Foundation
struct Dictonary:Codable{
    let word: String
    let meanings: [Meaning]
}
struct Meaning: Codable {
    let definitions: [Definations]
}
struct Definations: Codable {
    let definition: String
}
