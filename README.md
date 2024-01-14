# Japan Top 100 Castle Collection iOS App
Welcome to the Castle Collection iOS App, an ongoing project designed to help you explore and document Japan's top 100 famous castles. This Swift application embraces clean architecture and modularization, making it an efficient and reusable codebase.

## Project Overview
The Castle Collection app is built to offer a unique and interactive way to track visits to various castles in Japan. It's implemented using Swift and follows the principles of Clean Architecture and TDD (Test-Driven Development). The project is structured into separate iOS and shared libraries targets, ensuring reusability across different frameworks.

## Current Features
- Collection Tab (80% complete): A collection view displaying 100 famous castles. Each cell can be tapped to view castle details and log visits with photos/stamps.
- Map Tab (To be implemented): A map view to display all castle locations.
- Settings Tab (To be implemented): Options to backup and delete data, change language settings, and update configurations.

## Technology Stack
- Swift
- UIKit
- Core Data for local data storage
- MapKit for map functionalities
- SnapKit
- Kingfisher

## Project Structure: Targets and Modularization
The Castle Collection iOS App is designed with a focus on modularization and separation of concerns. The project is structured into two primary targets:

### 1. CastleBook (Business Logic)
- Purpose: This target encapsulates the core business logic of the application and is built as a multi-platform framework.
- Benefits:
    1. Reusability: The modular nature allows the business logic to be reused across different UI frameworks like SwiftUI or AppKit.
    2. Testability: By decoupling business logic from UI components, we ensure more efficient and focused unit testing.
    3. Platform Agnostic: The framework can be integrated into various Apple platforms, enhancing flexibility.
### 2. CastleBookiOS (User Interface)
- Technology: Utilizes UIKit for the user interface.
- Focus: Dedicated to UI and UX aspects of the application, leveraging the business logic from the CastleBook target.
- Advantages:
    1. Decoupling UI from Logic: This separation enhances maintainability and scalability. UI-specific changes do not affect the underlying business logic.
    2. Prepared for Future Updates: Ready for integration with SwiftUI or other Apple UI frameworks, making future transitions smoother.

### Modularized Architecture
The app's architecture is designed to ensure each component is independent and interchangeable.
This approach not only speeds up testing processes but also facilitates easier updates and enhancements.


## Development Status and To-Do List
While the project is still under development, significant progress has been made, especially in the Collection tab. Here's a breakdown of the progress and tasks ahead:

### Task List

#### CastleCollectionViewController
- [X] Implemented to display a list of castles.
- [X] Load all castles (name + images + hasVisited) when view is presented (offline)

#### CastleDetailViewController
- [X] Created for viewing details of each castle.
- [X] Load castle details (name, address, images) on info tab
- [ ] Load visit history on visit history tab

#### Collection Tab
- [ ] Implement functionality for adding visit logs.
- [ ] Add feature to upload and view photos/stamps.
#### Map Tab
- [ ] Develop a map view to show the locations of all castles.
- [ ] See all castles and visited status on map
- [ ] Integrate MapKit for effective mapping.
#### Settings Tab
- [ ] Implement backup and data deletion functionalities.
- [ ] Add language change options.
- [ ] Develop configuration settings for photo storage.
### General
- [ ] Enhance the app's UI/UX design.
- [ ] Optimize performance and conduct further testing.
### Future enhancement
- [ ] Expand the collection beyond Japan's top 100 castles (extra 100+)
- [ ] Integrate social sharing features.
- [ ] Backup data on iCloud; export to CSV or JSON.
- [ ] Offer more interactive and educational content about each castle.

