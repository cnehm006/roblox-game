# Tycoon Tycoon

A GUI-only incremental game built in Roblox Luau where players write code to earn Robux and purchase upgrades to increase their income.

## Features

### Core Gameplay
- **Write Code Button**: Click to earn Robux (starts at +1 per click)
- **Robux Counter**: Real-time display of total Robux earned
- **Upgrades System**: 4 different upgrades to enhance your income

### Upgrades
1. **Faster Typing** (+1 per click)
   - Increases Robux earned per click
   - Base cost: 10 Robux
   - Max level: 10

2. **Interns** (Auto-click)
   - Automatically clicks for you every second
   - Base cost: 50 Robux
   - Max level: 5

3. **Laptop Upgrade** (Doubles income)
   - Doubles your click income
   - Base cost: 100 Robux
   - Max level: 3

4. **Studio HQ** (Passive income)
   - Generates passive income every 5 seconds
   - Base cost: 500 Robux
   - Max level: 5

### UI Features
- **Modern Design**: Clean, rounded corners with gradients
- **Smooth Animations**: Tween animations for button clicks and panel transitions
- **Real-time Updates**: Live cost and level displays
- **Sound Effects**: Audio feedback for clicks and upgrades

### Technical Features
- **Modular Architecture**: Clean, organized code structure
- **Data Persistence**: Mock DataStore implementation (easily replaceable with real DataStore)
- **Auto-save**: Saves progress every 30 seconds
- **Performance Optimized**: Efficient game loop using RunService

## Project Structure

```
src/
├── shared/
│   ├── Types.luau          # Type definitions
│   ├── GameConfig.luau     # Game constants and configuration
│   ├── DataManager.luau    # Data handling and persistence
│   └── UIUtils.luau        # UI utility functions
├── client/
│   ├── Gui/
│   │   ├── MainGui.luau    # Main game interface
│   │   └── UpgradesPanel.luau # Upgrades panel
│   ├── GameLoop.luau       # Game loop and passive income
│   ├── GameController.luau # Main game controller
│   └── init.client.luau    # Client initialization
└── server/
    └── init.server.luau    # Server initialization
```

## How to Play

1. **Start the Game**: The game automatically loads when you join
2. **Click "Write Code"**: Earn Robux by clicking the main button
3. **Buy Upgrades**: Click "Upgrades" to open the upgrade panel
4. **Progress**: Purchase upgrades to increase your income rate
5. **Automation**: Unlock auto-clicking and passive income for idle progression

## Debug Commands

For testing purposes, the following debug commands are available in the console:

```lua
-- Add Robux
_G.TycoonTycoon.debugAddRobux(1000)

-- Max all upgrades
_G.TycoonTycoon.debugMaxUpgrades()

-- Save game manually
_G.TycoonTycoon.saveGame()

-- Load game manually
_G.TycoonTycoon.loadGame()
```

## Installation

1. Clone or download this project
2. Open in Roblox Studio
3. Use Rojo to sync the files (if using Rojo)
4. Test the game in Studio or publish to Roblox

## Customization

### Adding New Upgrades
1. Add the upgrade type to `Types.luau`
2. Define the upgrade in `GameConfig.luau`
3. Update the upgrade grid in `UpgradesPanel.luau`

### Modifying Costs and Effects
Edit the values in `GameConfig.luau`:
- `baseCost`: Starting cost of the upgrade
- `costMultiplier`: How much the cost increases per level
- `maxLevel`: Maximum level for the upgrade

### Changing UI Colors
Modify the color values in `GameConfig.UI.COLORS` to match your theme.

## Technical Notes

### Data Persistence
The game uses a mock DataStore implementation. To use real DataStore:
1. Replace the mock functions in `DataManager.luau`
2. Uncomment the real DataStore code
3. Add proper error handling

### Performance
- Game loop runs at 60 FPS using RunService.Heartbeat
- UI updates are throttled to prevent excessive redraws
- Efficient data structures minimize memory usage

### Scalability
The modular architecture makes it easy to:
- Add new upgrade types
- Modify game mechanics
- Extend the UI
- Add multiplayer features

## Future Enhancements

Potential features to add:
- **Achievements**: Milestone rewards
- **Prestige System**: Reset with bonuses
- **Multiplayer**: Leaderboards and competition
- **More Upgrades**: Additional income sources
- **Animations**: Particle effects and visual feedback
- **Sound Design**: Custom sound effects and music

## License

This project is open source and available under the MIT License.

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve the game!