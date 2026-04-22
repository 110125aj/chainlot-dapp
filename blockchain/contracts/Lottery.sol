// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Lottery {
    address public owner;
    address payable[] public players;
    address[] public winners;
    uint256 public lotteryId;

    event PlayerEntered(address indexed player, uint256 amount);
    event WinnerPicked(address indexed winner, uint256 amount);

    constructor() {
        owner = msg.sender;
        lotteryId = 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    function enter() public payable {
        require(msg.value >= 0.01 ether, "Ticket costs 0.01 ether");
        players.push(payable(msg.sender));
        emit PlayerEntered(msg.sender, msg.value);
    }

    function pickWinner() public onlyOwner {
        require(players.length > 0, "No players yet");
        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.difficulty, players)
            )
        ) % players.length;
        address payable winner = players[randomIndex];
        uint256 pot = address(this).balance;
        winners.push(winner);
        lotteryId++;
        players = new address payable[](0);
        payable(winner).transfer(pot);
        emit WinnerPicked(winner, pot);
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getLotteryId() public view returns (uint256) {
        return lotteryId;
    }

    function getWinners() public view returns (address[] memory) {
        return winners;
    }

    receive() external payable {}
}