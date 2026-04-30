//
//  LocationDataModel.swift
//  LibraryResearchAssist
//
//  Created by Brandon Williams on 4/29/26.
//

import Foundation
import simd

// MARK: - Location Categories

enum LibraryLocationCategory: String, Codable {
    case studySpace
    case archives
    case serviceDesk
    case technology
    case researchZone
    case classroom
    case general
}

// MARK: - Main Location Model

struct LocationDataModel: Identifiable, Codable {
    
    // MARK: - Core Identity
    
    let id: UUID
    
    let name: String
    
    let description: String
    
    // MARK: - AR Placement
    
    let floor: Int
    
    let position: SIMD3<Float>
    
    // MARK: - Educational Media
    
    let videoFileName: String
    
    let audioFileName: String?
    
    // MARK: - Visual / Classification
    
    let category: LibraryLocationCategory
    
    let iconName: String?
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        floor: Int,
        position: SIMD3<Float>,
        videoFileName: String,
        audioFileName: String? = nil,
        category: LibraryLocationCategory = .general,
        iconName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.floor = floor
        self.position = position
        self.videoFileName = videoFileName
        self.audioFileName = audioFileName
        self.category = category
        self.iconName = iconName
    }
}
