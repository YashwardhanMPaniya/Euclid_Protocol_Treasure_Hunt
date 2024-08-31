const { expect } = require("chai");
const { deployments, getNamedAccounts, ethers } = require("hardhat");

describe("TreasureHunt", function () {
  let treasureHunt, deployer, player1, player2;
  let treasureHuntAddress;

  beforeEach(async function () {
    // Deploy the contracts before each test
    let { deployer } = await getNamedAccounts();

    // Deploy the contract
    const TreasureHuntFactory = await ethers.getContractFactory("TreasureHunt");
    const treasureHuntInstance = await TreasureHuntFactory.deploy();

    // Retrieve the deployed contract address
    treasureHuntAddress = await treasureHuntInstance.address;
    console.log("Deployed TreasureHunt Address:", treasureHuntAddress);

    // Get the contract instance
    treasureHunt = await ethers.getContractAt(
      "TreasureHunt",
      treasureHuntAddress
    );

    // Get the signers
    [deployer, player1, player2] = await ethers.getSigners();
  });

  it("should deploy successfully", async function () {
    // Check if the contract address is valid
    console.log("Contract Address:", treasureHuntAddress);
    expect(treasureHuntAddress).to.properAddress;
  });

  it("should allow a player to join the game", async function () {
    await treasureHunt
      .connect(player1)
      .joinGame({ value: ethers.utils.parseEther("0.1") });

    // Check if player position exists for the player's address
    const playerPosition = await treasureHunt.playerPositions(player1.address);

    // Ensure player position is not zero (assuming zero indicates no position)
    expect(playerPosition).to.not.equal(0);
  });

  it("should prevent players from joining with insufficient funds", async function () {
    await expect(
      treasureHunt
        .connect(player1)
        .joinGame({ value: ethers.utils.parseEther("0") })
    ).to.be.revertedWith("Must send ETH to join");
  });

  it("should move the treasure when a player moves to a multiple of 5", async function () {
    const initialPlayerPosition = await treasureHunt.playerPositions(
      player1.address
    );

    // Calculate adjacent positions
    const gridSize = 10;
    const adjacentPositions = [];
    for (
      let i = initialPlayerPosition - gridSize;
      i <= initialPlayerPosition + gridSize;
      i += gridSize
    ) {
      if (i >= 0 && i < gridSize * gridSize && i !== initialPlayerPosition) {
        adjacentPositions.push(i);
      }
    }

    // Choose a random adjacent position
    const randomIndex = Math.floor(Math.random() * adjacentPositions.length);
    const validAdjacentPosition = adjacentPositions[randomIndex];

    // Perform the move
    const initialTreasurePosition = await treasureHunt.treasurePosition();
    await treasureHunt.connect(player1).move(validAdjacentPosition);
    const newTreasurePosition = await treasureHunt.treasurePosition();

    // Check if the treasure position has changed
    expect(newTreasurePosition).to.not.equal(initialTreasurePosition);
  });

  it("should prevent players from moving more than once per turn", async function () {
    const currentPosition = await treasureHunt.playerPositions(player1.address);
    const adjacentPosition = currentPosition + 1;
    await treasureHunt.connect(player1).move(adjacentPosition);
    await expect(
      treasureHunt.connect(player1).move(adjacentPosition + 1)
    ).to.be.revertedWith("Player can only move once per turn");
  });
});
