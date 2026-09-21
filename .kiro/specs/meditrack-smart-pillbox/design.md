# Design Document: MediTrack Smart Pillbox

## Overview

MediTrack is an academic prototype Flutter application that pairs with an ESP32-powered mechanical pillbox dispenser to create an automated medication adherence system. The system enables patients to configure medication schedules, receive dose notifications, and track adherence through hardware-verified pickup confirmation. The ESP32 device communicates asynchronously with the Flutter app through Firebase Realtime Database, which serves as a message bus for configuration, dispensing control, tray state monitoring, and historical tracking.

The system enforces a single-medication-at-a-time model with a maximum hopper capacity of 15 pills. It supports flexible dosing schedules (1-3 alarms per day) with two distinct course types: ongoing courses with weekday selection and fixed-duration courses that run consecutively for N days. The architecture differentiates between two types of missed doses—hardware-verified "not_picked_up" (pill dispensed but left in tray) and app-detected "not_dispensed" (user never triggered dispense)—to provide accurate adherence insights. The dashboard implements a 7-state machine that reflects the current system status, from initial setup through active dispensing to dose resolution.

## Architecture

```mermaid
graph TB
    subgraph "Flutter Mobile App"
        UI[UI Layer<br/>Widgets & Screens]
        BL[Business Logic Layer<br/>State Management]
        DATA[Data Layer<br/>Services & Repositories]
        LOCAL[Local Storage<br/>SharedPreferences]
    end
    
    subgraph "Firebase Cloud"
        RTDB[Realtime Database<br/>Message Bus]
        AUTH[Firebase Auth<br/>Optional]
        FCM[Cloud Messaging<br/>Push Notifications]
    end
    
    subgraph "ESP32 Hardware"
        FW[Firmware Controller]
        SERVO[Servo Motor<br/>Singulator]
        LOAD[Load Cell<br/>Pickup Sensor]
    end
    
    UI --> BL
    BL --> DATA
    DATA --> LOCAL
    DATA <-->|Read/Write| RTDB
    RTDB <-->|Sync State| FW
    FW --> SERVO
    FW --> LOAD
    LOAD -->|Weight Change| FW
    FCM -->|Schedule Notifications| UI
    
    style UI fill:#e8f4f8
    style BL fill:#b8dce8
    style DATA fill:#88c4d8
    style RTDB fill:#ffd4a3
    style FW fill:#c8e6c9
