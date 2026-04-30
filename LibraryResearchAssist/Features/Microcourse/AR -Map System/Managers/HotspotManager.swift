//
//  HotspotManager.swift
//  LibraryResearchAssist
//
//  Created by Brandon Williams on 4/29/26.
//

import Foundation
import RealityKit
import UIKit
import SwiftUI

class HotspotManager {
    
    // MARK: - Tracking
    
    private var hotspotEntities: [ModelEntity] = []
    
    // MARK: - Configuration
    
    let hotspotRadius: Float = 0.025
    let hotspotHeightOffset: Float = 0.005
    
    // MARK: - Generate Hotspots
    
    func generateHotspots(
        for mapEntity: ModelEntity?,
        locations: [LocationDataModel]
    ) {
        guard let mapEntity = mapEntity else { return }
        
        removeExistingHotspots(from: mapEntity)
        
        for location in locations {
            let hotspot = createHotspot(for: location)
            
            hotspot.position = location.position
            hotspot.position.y += hotspotHeightOffset
            
            mapEntity.addChild(hotspot)
            hotspotEntities.append(hotspot)
        }
    }
    
    // MARK: - Create Individual Hotspot
    
    private func createHotspot(
        for location: LocationDataModel
    ) -> ModelEntity {
        
        let mesh = MeshResource.generateSphere(
            radius: hotspotRadius
        )
        
        let material = SimpleMaterial(
            color: colorForLocation(location),
            isMetallic: false
        )
        
        let hotspot = ModelEntity(
            mesh: mesh,
            materials: [material]
        )
        
        hotspot.name = location.name
        
        hotspot.generateCollisionShapes(recursive: true)
        
        return hotspot
    }
    
    // MARK: - Tap Detection
    
    func detectHotspotTap(
        in arView: ARView,
        at point: CGPoint,
        locations: [LocationDataModel]
    ) -> LocationDataModel? {
        
        if let entity = arView.entity(
            at: point
        ) as? ModelEntity {
            
            return locations.first {
                $0.name == entity.name
            }
        }
        
        return nil
    }
    
    // MARK: - Cleanup
    
    private func removeExistingHotspots(
        from mapEntity: ModelEntity
    ) {
        for hotspot in hotspotEntities {
            hotspot.removeFromParent()
        }
        
        hotspotEntities.removeAll()
    }
    
    // MARK: - Visual Styling
    
    private func colorForLocation(
        _ location: LocationDataModel
    ) -> UIColor {
        
        let lowerName = location.name.lowercased()
        
        if lowerName.contains("study") {
            return .systemBlue
        } else if lowerName.contains("archive") {
            return .systemOrange
        } else if lowerName.contains("service") {
            return .systemGreen
        } else if lowerName.contains("technology") {
            return .systemPurple
        } else {
            return .systemRed
        }
    }
}
