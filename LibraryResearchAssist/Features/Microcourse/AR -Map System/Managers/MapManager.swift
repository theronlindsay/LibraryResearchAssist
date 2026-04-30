//
//  MapManager.swift
//  LibraryResearchAssist
//
//  Created by Brandon Williams on 4/29/26.
//

import Foundation
import RealityKit
import ARKit
import UIKit

class MapManager {
    
    // MARK: - Current Active Entities
    
    var currentAnchor: AnchorEntity?
    var currentMap: ModelEntity?
    
    // MARK: - Map Configuration
    
    let mapWidth: Float = 0.6      // Approx tabletop size
    let mapDepth: Float = 0.6
    private(set) var currentFloor: Int = 1
    
    // MARK: - Public Placement Function
    
    func placeMap(
        on arView: ARView,
        raycastResult: ARRaycastResult,
        floor: Int
    ) {
        removeCurrentMap()
        
        currentFloor = floor
        
        // Create anchor from detected plane
        let anchor = AnchorEntity(world: raycastResult.worldTransform)
        
        // Generate plane mesh
        let mesh = MeshResource.generatePlane(
            width: mapWidth,
            depth: mapDepth
        )
        
        // Load map material
        let material = loadFloorMaterial(for: floor)
        
        // Create map entity
        let mapEntity = ModelEntity(
            mesh: mesh,
            materials: [material]
        )
        
        // Optional slight elevation to prevent z-fighting
        mapEntity.position.y += 0.001
        
        // Name for easier debugging
        mapEntity.name = "LibraryMap_Floor_\(floor)"
        
        // Build hierarchy
        anchor.addChild(mapEntity)
        arView.scene.addAnchor(anchor)
        
        // Store references
        currentAnchor = anchor
        currentMap = mapEntity
    }
    
    // MARK: - Floor Updating
    
    func updateFloor(
        to newFloor: Int,
        locations: [LocationDataModel]
    ) {
        guard let mapEntity = currentMap else { return }
        
        currentFloor = newFloor
        
        let updatedMaterial = loadFloorMaterial(for: newFloor)
        
        mapEntity.model?.materials = [updatedMaterial]
        mapEntity.name = "LibraryMap_Floor_\(newFloor)"
        
        // Hotspot regeneration handled externally
    }
    
    // MARK: - Remove Current Map
    
    func removeCurrentMap() {
        currentAnchor?.removeFromParent()
        currentAnchor = nil
        currentMap = nil
    }
    
    // MARK: - Material Loader
    
    private func loadFloorMaterial(for floor: Int) -> Material {
        
        let textureName: String
        
        switch floor {
        case 1:
            textureName = "library_floor_1"
        case 2:
            textureName = "library_floor_2"
        default:
            textureName = "library_floor_1"
        }
        
        guard let uiImage = UIImage(named: textureName),
              let cgImage = uiImage.cgImage else {
            
            print("⚠️ Failed to load floor texture: \(textureName)")
            
            return SimpleMaterial(
                color: .blue,
                isMetallic: false
            )
        }
        
        do {
            let textureResource = try TextureResource.generate(
                from: cgImage,
                options: .init(semantic: .color)
            )
            
            var material = UnlitMaterial()
            material.color = .init(texture: .init(textureResource))
            
            return material
            
        } catch {
            print("⚠️ Texture generation failed: \(error.localizedDescription)")
            
            return SimpleMaterial(
                color: .gray,
                isMetallic: false
            )
        }
    }
}
