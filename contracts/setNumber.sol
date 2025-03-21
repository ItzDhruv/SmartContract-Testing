// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Lock {
    uint256 public number;
    function setNumber(uint256 _number) public {
        require(_number > 0, "Number must be greater than zero");
        number = _number;
    }

    function getNumber() public view returns (uint256) {
        return number;
    }
}
