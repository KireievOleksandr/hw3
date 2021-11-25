// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface GetStudents {
    function getStudentsList() external view returns (string[] memory students);
}

interface ERC20 {
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
}

contract SpellTokenICO {

    AggregatorV3Interface internal priceFeed;
    address studentContractAddress = 0x0E822C71e628b20a35F8bCAbe8c11F274246e64D;
    address chainLinkETHUSDRinkeby = 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e;
    address tokenAddress = 0x15B5B9CEDad6d2A5724392f4897EaB1e297a2838;

    constructor() {
        priceFeed = AggregatorV3Interface(chainLinkETHUSDRinkeby);
    }

    function getLatestETHUSDPrice() public view returns (uint) {
        ( uint80 roundID, int priceETHUSD, uint startedAt, uint timeStamp, uint80 answeredInRound ) = priceFeed.latestRoundData();
        return uint(priceETHUSD);
    }

    function getStudentsCount() public view returns(uint) {
        return GetStudents(studentContractAddress).getStudentsList().length;
    }

    function getTokenBalance() public view returns(uint) {
        return ERC20(tokenAddress).balanceOf(address(this));
    }

    function calcTokenAmount(uint _eth) public view returns(uint) {
        return _eth * getLatestETHUSDPrice() / getStudentsCount() / (10 ** priceFeed.decimals());
    }

    receive() external payable {
        if(getTokenBalance() >= calcTokenAmount(msg.value)) {
            ERC20(tokenAddress).transfer(msg.sender, calcTokenAmount(msg.value));
        } else {
            (bool sent, bytes memory data) = msg.sender.call{ value: msg.value }("Sorry, there is not enough tokens to buy");
        }
    }
}