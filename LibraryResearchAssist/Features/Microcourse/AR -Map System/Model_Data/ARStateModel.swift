//
//  ARStateModel.swift
//  LibraryResearchAssist
//
//  Created by Brandon Williams on 4/29/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - AR Interaction Modes

enum ARInteractionState {
    case placingMap
    case mapPlaced
    case selectingPortalLocation
    case viewingPortal
}

// MARK: - Main State Model

class ARStateModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var interactionState: ARInteractionState = .placingMap
    
    @Published var selectedLocation: LocationDataModel? = nil
    
    @Published var currentFloor: Int = 1
    
    @Published var showPlacementPrompt: Bool = true
    
    @Published var showPortalPlacementPrompt: Bool = false
    
    @Published var showFloorSelector: Bool = true
    
    @Published var mapPlacedSuccessfully: Bool = false
    
    // MARK: - UI Support
    
    @Published var statusMessage: String = "Scan a flat surface and tap to place the library map."
    
    // MARK: - Reset State
    
    func resetARSessionState() {
        interactionState = .placingMap
        selectedLocation = nil
        currentFloor = 1
        showPlacementPrompt = true
        showPortalPlacementPrompt = false
        mapPlacedSuccessfully = false
        statusMessage = "Scan a flat surface and tap to place the library map."
    }
    
    // MARK: - Map Placement Updates
    
    func didPlaceMap() {
        interactionState = .mapPlaced
        mapPlacedSuccessfully = true
        showPlacementPrompt = false
        statusMessage = "Tap a hotspot to explore a library location."
    }
    
    // MARK: - Hotspot Selection
    
    func didSelectHotspot(_ location: LocationDataModel) {
        selectedLocation = location
        interactionState = .selectingPortalLocation
        showPortalPlacementPrompt = true
        statusMessage = "Tap nearby floor space to place your portal."
    }
    
    // MARK: - Portal Placement
    
    func didPlacePortal() {
        interactionState = .viewingPortal
        showPortalPlacementPrompt = false
        selectedLocation = nil
        statusMessage = "Portal active. Tap the portal to close it."
    }
    
    // MARK: - Floor Switching
    
    func switchFloor(to floor: Int) {
        currentFloor = floor
        statusMessage = "Viewing Floor \(floor)."
    }
    
    // MARK: - Close Portal
    func didClosePortal() {
        interactionState = .mapPlaced
        statusMessage = "Portal closed. Tap a hotspot to continue exploring."
    }
}
