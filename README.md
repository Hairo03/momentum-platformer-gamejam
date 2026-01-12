# Momentum Platformer Prototype

A precision 2D platformer focusing on fluid movement and momentum preservation. Created for [Godot Wild Jam #88](https://itch.io/jam/godot-wild-jam-88).

## 🎮 About

This prototype explores tight platforming controls with a focus on:
*   **Momentum:** Physics-based acceleration and deceleration.
*   **Game Feel:** Implements "Coyote Time" and "Jump Buffering" for responsive input.
*   **Mechanics:** Wall jumping, sliding, and a fairy companion ability.

## 🕹️ Controls

| Action | Input |
| :--- | :--- |
| **Move** | `A` and `D` |
| **Jump** | `Space` |
| **Ability** | `Left Mouse Button` |

## 🛠️ Technical Details

Built with **Godot Engine 4**.

### Key Systems
*   **Finite State Machine:** The player controller (`scripts/player.gd`) uses a state machine architecture (`Idle`, `Run`, `Jump`, `Fall`) to manage complex movement logic.
*   **Room System:** The world is divided into individual scenes (`scenes/levels/level1/room*.tscn`) that transition smoothly using a custom shader.
*   **Physics:** Custom implementation of air acceleration, ground friction, and ice friction to create distinct movement feel.

### Project Structure
*   `assets/`: Sprites, fonts, tilesets, and shaders.
*   `scenes/`: split into `levels/` (rooms) and `player/`.
*   `scripts/`: Logic for the Player, UI, and Game Manager.

## 📥 How to Run

1.  Clone this repository.
2.  Open **Godot Engine** (Version 4.x).
3.  Click **Import** and navigate to the `project.godot` file in this folder.
4.  Press `F5` to play the main scene.

## 🎨 Credits

*   **Engine:** Godot Engine
*   **Font:** Pixel Operator
*   *// filepath: d:\dev\Godot Projects\momentum-platformer-prototype\README.md
# Momentum Platformer Prototype

A precision 2D platformer focusing on fluid movement and momentum preservation. Created for [Godot Wild Jam #88](https://itch.io/jam/godot-wild-jam-88).

## 🎮 About

This prototype explores tight platforming controls with a focus on:
*   **Momentum:** Physics-based acceleration and deceleration.
*   **Game Feel:** Implements "Coyote Time" and "Jump Buffering" for responsive input.
*   **Mechanics:** Wall jumping, sliding, and a fairy companion ability.

## 🕹️ Controls

| Action | Input |
| :--- | :--- |
| **Move** | `A` and `D` |
| **Jump** | `Space` |
| **Ability** | `Left Mouse Button` |

## 🛠️ Technical Details

Built with **Godot Engine 4**.

### Key Systems
*   **Room System:** The world is divided into individual scenes (`scenes/levels/level1/room*.tscn`) that transition smoothly.
*   **Physics:** Custom implementation of air acceleration, ground friction, and ice friction to create distinct movement feel.

### Project Structure
*   `assets/`: Sprites, fonts, tilesets, and shaders.
*   `scenes/`: split into `levels/` (rooms) and `player/`.
*   `scripts/`: Logic for the Player, UI, and Game Manager.

## 📥 How to Run

1.  Clone this repository.
2.  Open **Godot Engine** (Version 4.x).
3.  Click **Import** and navigate to the `project.godot` file in this folder.
4.  Press `F5` to play the main scene.

## 🎨 Credits

*   **Engine:** Godot Engine
*   **Font:** Pixel Operator
*   **Player Sprite and SFX:** Brackeys

---
*Created for Godot Wild Jam #88.*
