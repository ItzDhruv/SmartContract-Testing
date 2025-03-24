// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


// In this token launchapad tooken are ownd buy creator not tokenlaunchpad hold that token if any buer wants to buy that token so they first take approval from buer.
// but if i pass write _approve(creator, msg.sender, initialSupply * 10 ** decimals()); then it take approval to token launchpad so token launchpad can transfer token to buyer

contract TokenLaunchpad {
    struct TokenInfo {
        address tokenAddress;
        address owner;
        uint256 pricePerToken;
        uint256 totalSupply;
    }

    mapping(address => TokenInfo) public launchedTokens;
    address[] public allTokens;

    event TokenLaunched(address indexed creator, address token, uint256 supply, uint256 price);
    event TokensPurchased(address indexed buyer, address token, uint256 amount, uint256 cost);

    function launchToken(string memory name, string memory symbol, uint256 supply, uint256 price) public {
        require(supply > 0, "Supply must be greater than zero");
        require(price > 0, "Price must be greater than zero");

        ERC20Token newToken = new ERC20Token(name, symbol, supply, msg.sender);
        launchedTokens[address(newToken)] = TokenInfo(address(newToken), msg.sender, price, supply);
        allTokens.push(address(newToken));

        emit TokenLaunched(msg.sender, address(newToken), supply, price);
    }

   function buyTokens(address token, uint256 amount) public payable {
    TokenInfo storage info = launchedTokens[token];
    require(info.tokenAddress != address(0), "Token not found");
    require(msg.value == amount * info.pricePerToken, "Incorrect ETH sent");

    ERC20Token erc20 = ERC20Token(token);
    require(erc20.allowance(info.owner, address(this)) >= amount, "Not enough allowance");

    // ✅ Fix: Use `transferFrom` instead of `transfer`
    erc20.transferFrom(info.owner, msg.sender, amount);

    // Transfer ETH to token owner
    payable(info.owner).transfer(msg.value);

    emit TokensPurchased(msg.sender, token, amount, msg.value);
}


    
    function getAllTokens() public view returns (address[] memory) {
        return allTokens;
    }
}

contract ERC20Token is ERC20, Ownable {
    constructor(string memory name, string memory symbol, uint256 initialSupply, address creator)
        ERC20(name, symbol)
        Ownable(creator)
    {
        _mint(creator, initialSupply * 10 ** decimals());
        _approve(creator, msg.sender, initialSupply * 10 ** decimals());
        //msg.sender means who call this contract like in this case our token launchapad call this contract so msg.sender is token launchapad


        //  _approve(creator, address(this), initialSupply * 10 ** decimals());
         // but if i write address(this) then it take Erc 20 to his approval so via token launchpad we cant transfer token to buyer
    }
}
