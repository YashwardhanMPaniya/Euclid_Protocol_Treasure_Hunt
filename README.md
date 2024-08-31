## Quickstart

```
Node version: node v20.11.1 (npm v10.2.4)
```

```
git clone https://github.com/YashwardhanMPaniya/Euclid_Protocol_Treasure_Hunt.git
cd Euclid_Protocol_Treasure_Hunt
yarn
```

## Usage

Compile:

```
yarn hardhat compile
```


Deploy:

```
yarn hardhat deploy
```


Test:

```
yarn hardhat test
```

## Design Choices Explanation

### Grid Design and Positioning
- **Grid Layout**: The game is played on a 10x10 grid (`GRID_SIZE = 10`), providing 100 possible positions for players to navigate.
- **Initial Treasure Positioning**: The treasure's initial position is determined by hashing the block number using the `keccak256` function. This ensures that the starting position is random and based on the blockchain's current state, making it unpredictable.

### Player Movements
- **Movement Mechanics**: Players can move to adjacent positions only, promoting strategic gameplay where each move must be carefully considered. This limitation makes the treasure hunt more interactive and challenging.
- **Tracking Player Positions**: Player positions are stored in the `playerPositions` mapping, and the `hasMoved` mapping is used to ensure that each player can only move once per turn, maintaining the integrity of each round.

### Randomness in Treasure Movement
- **Multiples of 5**: When a player moves to a position that is a multiple of 5, the treasure relocates to a random adjacent position. This mechanic keeps the treasure's movement within the player's vicinity, adding a dynamic element to the game.
- **Prime Numbers**: If a player moves to a prime number, the treasure is randomly repositioned anywhere on the grid. This introduces a level of unpredictability, making it more difficult for players to anticipate the treasure's location.
- **Randomness Generation**: The randomness involved in moving the treasure is generated using the `keccak256` hash function, which takes `block.timestamp` and `block.difficulty` as inputs. This method leverages the inherent unpredictability of blockchain attributes to create a pseudo-random outcome, enhancing the security and fairness of the game.

### Winner Reward Mechanism
- **Treasure Discovery**: If a player successfully lands on the treasure's position, they receive 90% of the `gameBalance` as a reward. This significant incentive motivates players to find the treasure.
- **Game State Reset**: After rewarding the winner, the contract resets all players' `hasMoved` statuses, preparing the game for the next round of gameplay and ensuring that each round starts fresh.

### Summary
This design effectively balances strategic player movement with random treasure repositioning, keeping the game both engaging and fair. By leveraging blockchain-based randomness, the contract ensures that each game is unique and that no player has an undue advantage.

