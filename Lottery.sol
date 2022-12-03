// SPDX-License-Identifier: GNU GPLv3

// Built By DevelopersUnited.org

pragma solidity >=0.7.0 <0.9.0;
contract POMQLottery {
    address public lottoAdmin;
    mapping(uint => address) lottoPlayers;
    mapping(uint => address) lottoWinners;
    uint256 public betAmount = 500 ether;
    uint256 public maxPlayers = 10;
    uint256 public winPercentage = 80;
    uint256 public totalWinnings;
    uint256 public currentRound = 1;
    uint256 public playerCount = 0;
    uint256 randomNumber;
    constructor() {lottoAdmin = msg.sender;}
    function configLotto(uint256 _betAmount, uint256 _maxPlayers, uint256 _winPercentage) public {
        require(msg.sender == lottoAdmin, "UNAUTHORIZED");
        require(playerCount == 0, "INCOMPLETE_ROUND");
        require(_winPercentage >= 60, "MINIMUM_60%_WIN");
        betAmount = _betAmount;
        maxPlayers = _maxPlayers;
        winPercentage = _winPercentage;
    }
    function buyTicket() public payable {
        require(msg.value == betAmount, "INSUFFICIENT_FUNDS");
        playerCount++;
        lottoPlayers[playerCount]=msg.sender;
        if(playerCount == maxPlayers) {
            randomNumber = uint(block.number) % maxPlayers + 1;
            lottoWinners[currentRound]=lottoPlayers[randomNumber];
            totalWinnings += address(this).balance;
            currentRound++;
            payable(lottoPlayers[randomNumber]).transfer(betAmount * maxPlayers * winPercentage / 100);
            payable(lottoAdmin).transfer(address(this).balance);
            playerCount = 0;
        }
    }
    function getWinner(uint256 _round) public view returns (address) {
        require(_round < currentRound, "INVALID_ROUND");
        return lottoWinners[_round];
    }
    function rescuePOM() public {
        require(msg.sender == lottoAdmin, "UNAUTHORIZED");
        require(address(this).balance > 0, "EMPTY_CONTRACT");
        payable(lottoAdmin).transfer(address(this).balance);
    }
    function setAdmin(address _newAdmin) public {
        require(msg.sender == lottoAdmin, "UNAUTHORIZED");
        lottoAdmin = _newAdmin;
    }
}
