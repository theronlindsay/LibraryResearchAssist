//
//  ARCoordinator.swift
//  LibraryResearchAssist
//
//  Created by Brandon Williams on 4/29/26.
//

import Foundation
import RealityKit
import ARKit
import SwiftUI

class ARCoordinator: NSObject {
    
    // MARK: - Core References
    
    var arView: ARView?
    var arState: ARStateModel
    var locations: [LocationDataModel]
    
    // MARK: - Managers
    
    let mapManager = MapManager()
    let hotspotManager = HotspotManager()
    let portalManager = PortalManager()
    
    // MARK: - Tracking
    
    private var currentFloor: Int = 1
    
    // MARK: - Initialization
    
    init(
        arState: ARStateModel,
        locations: [LocationDataModel]
    ) {
        self.arState = arState
        self.locations = locations
    }
    
    // MARK: - Setup
    
    func setupARView(_ view: ARView) {
        self.arView = view
    }
    
    // MARK: - Main Tap Handler
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        
        let tapLocation = sender.location(in: arView)
        
        
        switch arState.interactionState {
            
        case .placingMap:
            attemptMapPlacement(at: tapLocation)
            
        case .mapPlaced:
            attemptHotspotSelection(at: tapLocation)
            
        case .selectingPortalLocation:
            attemptPortalPlacement(at: tapLocation)
            
        case .viewingPortal:
            handlePortalViewingTap(at: tapLocation)
        }
    }
    
    // MARK: - Map Placement
    
    private func attemptMapPlacement(at point: CGPoint) {
        guard let arView = arView else { return }
        
        let results = arView.raycast(
            from: point,
            allowing: .existingPlaneGeometry,
            alignment: .horizontal
        )
        
        guard let firstResult = results.first else { return }
        
        mapManager.placeMap(
            on: arView,
            raycastResult: firstResult,
            floor: arState.currentFloor
        )
        
        hotspotManager.generateHotspots(
            for: mapManager.currentMap,
            locations: filteredLocations(for: arState.currentFloor)
        )
        
        arState.interactionState = .mapPlaced
        arState.showPlacementPrompt = false
    }
    
    // MARK: - Hotspot Selection
    
    private func attemptHotspotSelection(at point: CGPoint) {
        guard let arView = arView else { return }
        
        if let selectedLocation = hotspotManager.detectHotspotTap(
            in: arView,
            at: point,
            locations: locations
        ) {
            arState.selectedLocation = selectedLocation
            arState.interactionState = .selectingPortalLocation
        }
    }
    
    // MARK: - Portal Placement
    
    private func attemptPortalPlacement(at point: CGPoint) {
        guard let arView = arView,
              let selectedLocation = arState.selectedLocation else { return }
        
        let results = arView.raycast(
            from: point,
            allowing: .existingPlaneGeometry,
            alignment: .horizontal
        )
        
        guard let firstResult = results.first else { return }
        
        portalManager.placePortal(
            in: arView,
            raycastResult: firstResult,
            locationData: selectedLocation
        )
        
        arState.didPlacePortal()
        arState.selectedLocation = nil
    }
    
    // MARK: - Floor Management
    
    func updateFloorIfNeeded(_ requestedFloor: Int) {
        guard requestedFloor != currentFloor,
              let arView = arView else { return }
        
        currentFloor = requestedFloor
        
        mapManager.updateFloor(
            to: requestedFloor,
            locations: filteredLocations(for: requestedFloor)
        )
        
        hotspotManager.generateHotspots(
            for: mapManager.currentMap,
            locations: filteredLocations(for: requestedFloor)
        )
    }
    
    // MARK: - Reset / Reposition
    
    func prepareForMapPlacement() {
        mapManager.removeCurrentMap()
        portalManager.removeAllPortals()
        
        arState.interactionState = .placingMap
        arState.showPlacementPrompt = true
    }
    
    // MARK: - Helpers
    
    private func filteredLocations(for floor: Int) -> [LocationDataModel] {
        locations.filter { $0.floor == floor }
    }
    func detectPortalTap(
        in arView: ARView,
        at point: CGPoint
    ) -> Bool {
        
        if let entity = arView.entity(at: point),
           entity.name.starts(with: "Portal_") {
            return true
        }
        
        return false
    }
    
    private func handlePortalViewingTap(at point: CGPoint) {
        guard let arView = arView else { return }
        
        if portalManager.detectPortalTap(in: arView, at: point) {
            portalManager.removeAllPortals()
            arState.didClosePortal()
        }
    }
}
