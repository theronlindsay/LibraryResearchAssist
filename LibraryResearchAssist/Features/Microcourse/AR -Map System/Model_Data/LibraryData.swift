//
//  LibraryData.swift
//  LibraryResearchAssist
//
//  Created by Brandon Williams on 4/29/26.
//

import Foundation
import simd

struct LibraryData {
    
    static let sampleLocations: [LocationDataModel] = [
        
        LocationDataModel(
            name: "Podcast Studio",
            description: "Audio equipment set up for podcasts and recordings",
            floor: 1,
            position: SIMD3<Float>(0.1, 0, 0.1),
            videoFileName: "Podcast_Studio.mp4",
            audioFileName: "placeholder.mp3",
            category: .archives
        ),
        
        LocationDataModel(
            name: "Help Desk",
            description: "Library and Librarian assistance",
            floor: 1,
            position: SIMD3<Float>(-0.2, 0, 0.15),
            videoFileName: "Help_Desk_Video.mp4",
            audioFileName: nil,
            category: .studySpace
        ),
        
        LocationDataModel(
            name: "Technology Desk",
            description: "IT support and devices",
            floor: 2,
            position: SIMD3<Float>(0.0, 0, -0.2),
            videoFileName: "tech_video.mp4",
            audioFileName: nil,
            category: .technology
        )
    ]
}
