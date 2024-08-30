// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TreasureHunt {
    uint8 public constant GRID_SIZE = 10;
    uint8 public treasurePosition;
    mapping(address => uint8) public playerPositions;
    mapping(address => bool) public hasMoved;

    uint256 public gameBalance;
    address[] public players;

    event PlayerMoved(address indexed player, uint8 newPosition);
    event TreasureMoved(uint8 newPosition);
    event TreasureFound(address indexed winner, uint8 position, uint256 reward);

    constructor() {
        // Initialize treasure position based on the block number
        treasurePosition = uint8(
            uint256(keccak256(abi.encodePacked(block.number))) %
                (GRID_SIZE * GRID_SIZE)
        );
    }

    modifier onlyOnce() {
        require(!hasMoved[msg.sender], "Player can only move once per turn");
        _;
    }

    function joinGame() external payable {
        require(msg.value > 0, "Must send ETH to join");
        if (playerPositions[msg.sender] == 0 && !hasMoved[msg.sender]) {
            players.push(msg.sender);
            playerPositions[msg.sender] = uint8(
                uint256(
                    keccak256(abi.encodePacked(block.timestamp, msg.sender))
                ) % (GRID_SIZE * GRID_SIZE)
            );
        }
        gameBalance += msg.value;
    }

    function move(uint8 newPosition) external onlyOnce {
        require(newPosition < GRID_SIZE * GRID_SIZE, "Invalid position");

        uint8 currentPosition = playerPositions[msg.sender];
        require(
            isAdjacent(currentPosition, newPosition),
            "Move must be to an adjacent position"
        );

        playerPositions[msg.sender] = newPosition;
        hasMoved[msg.sender] = true;

        emit PlayerMoved(msg.sender, newPosition);

        if (newPosition == treasurePosition) {
            _rewardWinner(msg.sender);
        } else {
            _moveTreasure(newPosition);
        }
    }

    function _moveTreasure(uint8 newPosition) internal {
        if (newPosition % 5 == 0) {
            uint8[] memory adjPositions = _getAdjacentPositions(
                treasurePosition
            );
            require(adjPositions.length > 0, "No adjacent positions available");

            uint8 randomIndex = uint8(
                uint256(
                    keccak256(
                        abi.encodePacked(block.timestamp, block.difficulty)
                    )
                ) % adjPositions.length
            );
            treasurePosition = adjPositions[randomIndex];
            emit TreasureMoved(treasurePosition);
        } else if (_isPrime(newPosition)) {
            uint8 randomPosition = uint8(
                uint256(
                    keccak256(
                        abi.encodePacked(block.timestamp, block.difficulty)
                    )
                ) % (GRID_SIZE * GRID_SIZE)
            );
            treasurePosition = randomPosition;
            emit TreasureMoved(treasurePosition);
        }
    }

    function _rewardWinner(address winner) internal {
        uint256 reward = (gameBalance * 90) / 100;
        gameBalance = gameBalance - reward;
        payable(winner).transfer(reward);
        emit TreasureFound(winner, treasurePosition, reward);

        for (uint256 i = 0; i < players.length; i++) {
            hasMoved[players[i]] = false;
        }
    }

    function isAdjacent(
        uint256 currentPosition,
        uint256 newPosition
    ) internal pure returns (bool) {
        uint256 currentRow = currentPosition / GRID_SIZE;
        uint256 currentCol = currentPosition % GRID_SIZE;
        uint256 newRow = newPosition / GRID_SIZE;
        uint256 newCol = newPosition % GRID_SIZE;

        return ((newRow == currentRow &&
            (newCol == currentCol + 1 || newCol == currentCol - 1)) ||
            (newCol == currentCol &&
                (newRow == currentRow + 1 || newRow == currentRow - 1)));
    }

    function _getAdjacentPositions(
        uint8 position
    ) internal pure returns (uint8[] memory) {
        uint8[] memory adjacentPositions = new uint8[](4);
        uint8 count = 0;

        if (position >= GRID_SIZE) {
            adjacentPositions[count++] = position - GRID_SIZE;
        }
        if (position % GRID_SIZE > 0) {
            adjacentPositions[count++] = position - 1;
        }
        if (position % GRID_SIZE < GRID_SIZE - 1) {
            adjacentPositions[count++] = position + 1;
        }
        if (position < GRID_SIZE * (GRID_SIZE - 1)) {
            adjacentPositions[count++] = position + GRID_SIZE;
        }

        uint8[] memory validAdjacentPositions = new uint8[](count);
        for (uint8 i = 0; i < count; i++) {
            validAdjacentPositions[i] = adjacentPositions[i];
        }

        return validAdjacentPositions;
    }

    function _isPrime(uint8 number) internal pure returns (bool) {
        if (number <= 1) return false;
        for (uint8 i = 2; i <= number / 2; i++) {
            if (number % i == 0) return false;
        }
        return true;
    }
}
