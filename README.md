# Overwatch

Overwatch is a Garry's Mod framework for creating roleplaying servers. It is designed to be lightweight, modular, and easy to use.

### Installation

To install Overwatch, simply clone the repository into your `garrysmod/gamemodes` directory. You can do this by installing GitHub Desktop and cloning the repository.

### Usage

To use Overwatch, you must first create a new schema. A schema is a collection of entities, weapons, and other elements that define the rules of your new gamemode. You can create a new schema by creating a new folder in the same directory where the framework is installed.

### Contributing

If you would like to contribute to Overwatch, please fork the repository and submit a pull request. We are always looking for new contributors to help improve the framework.

### Credits

Overwatch was created by [Riggs](https://github.com/riggs9162) and [bloodycop](https://github.com/bloodycop6385).

# TODO List

### User Interface

- **Character Creation Screen**  
Design an interface allowing players to create and customize characters, including name, description, and model selection.

- **Character Selection Screen**  
Implement a UI for players to select from existing characters, displaying relevant details for each.

- **Inventory Interface**  
Develop a grid-based inventory system that displays items with their respective weights and quantities. 

- **Death Screen**  
Create a UI that appears upon player death, offering options such as respawn or spectate.

- **Tooltip System**  
Integrate dynamic tooltips that provide information when hovering over items, players, or objects.

### Inventory System

- **Weight-Based Mechanics**  
Implement a system where item weight affects player movement and inventory capacity.

### Item System

- **Item Actions**  
Develop functionalities for items, including:
    - Pickup
    - Drop
    - Use
    - Inspect

- **Item Categorization**  
Organize items into categories for better management and accessibility.

### Character System

- **Creation**  
Handle the creation of new characters, ensuring data is stored correctly.

- **Selection**  
Allow players to select from their created characters upon joining.

- **Deletion**  
Provide a secure method for players to delete unwanted characters.

- **Saving and Loading**  
Ensure character data, including stats and inventory, is saved and loaded accurately.

### Player System (Completed)

- **Data Management**  
Handle player-specific data such as settings and preferences.

- **Saving and Loading**  
Implement systems to save and retrieve player data upon joining or leaving the server.

### Animation System

- **Model Animations**  
Develop and integrate animations for various models:
    - citizen_male
    - citizen_female
    - metrocop
    - overwatch
    - player