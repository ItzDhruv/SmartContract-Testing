// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;



import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract Niqox is ERC20, Ownable{

        address public admin;
        uint256 private tokenPrizeUsdt = 100000000000000000; // 0.1 dollar 
        address[] public buyers;
        uint256 public soldTokens;
        uint256 public nextPriceIncreaseThreshold;

                  // fatch bnb prize from chainlink data feed 
                  AggregatorV3Interface public priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526); 

        
            struct VestingInfo {                   //  for locked token
                        uint256 totalAmount;
                        uint256 startTime;
                        uint256 claimedAmount;
            }

        mapping(address => VestingInfo) public vesting;    


            modifier onlyAdmin(){
                require(msg.sender == admin, "Only admin can perform this task");
                _;
            }

        event BuyTokenWithUsdt(address buyer, uint256 amount);
        event BuyTokenWithBnb(address buyer, uint256 amount);
        event ClaimedToken(address user, uint256 amount);
        event TimelineChanged(address user, uint256 newTime);
        event SellTokenForBnb(address user, uint256 tokenAmount, uint256 recievedBnb);
        event SellTokenForUsdt(address user, uint256 tokenAmount, uint256 recievedUsdt);


            constructor (address _owner, address _admin, uint256 _initialSupply)  ERC20("Niqox", "NQ") Ownable (_owner) {
                _mint(address(this), _initialSupply);
                admin = _admin;
                soldTokens = 0;
                nextPriceIncreaseThreshold = totalSupply() / 10; // 10% of total supply

            }
    
    IERC20 usdt = IERC20(0x221c5B1a293aAc1187ED3a7D7d2d9aD7fE1F3FB0);

    function buyTokenWithUsdt (uint256 amount) external {       // amount send in 18 decimal
       
        uint256 cost = amount * tokenPrizeUsdt / 1e18;
       
        require(usdt.allowance(msg.sender, address(this))>= cost,"Not enough token allownence");
        usdt.transferFrom(msg.sender, address(this), cost);
        
        vesting[msg.sender] = (VestingInfo(amount, block.timestamp , 0));
        buyers.push(msg.sender);
        _maybeUpdateTokenPricePlus(amount); 
        emit BuyTokenWithUsdt(msg.sender , amount);
    }

      function buyTokenWithBnb(uint256 amount) external payable {
            require(amount > 0, "Amount must be greater than 0");
            
            
            uint256 bnbPriceUsd = getLatestBNBPrice(); // e.g., 60000000000 for $600
            
         
            uint256 costUsd = (amount * tokenPrizeUsdt) / 1e18; // 0.1 USD per token
            
            
            uint256 costBnb = (costUsd * 1e8) / bnbPriceUsd; // 1e26 = 1e18 * 1e8
            
            require(msg.value >= costBnb, "Insufficient BNB sent");
            
            if (msg.value > costBnb) {
                payable(msg.sender).transfer(msg.value - costBnb);
                
            }else{
                 buyers.push(msg.sender);
            }
            
            vesting[msg.sender] = VestingInfo(amount, block.timestamp, 0);
           _maybeUpdateTokenPricePlus(amount);
            emit BuyTokenWithBnb(msg.sender, amount);
}       


           
      function claimTokens() external {

            VestingInfo storage info = vesting[msg.sender];
            require(info.totalAmount > 0, "No tokens vested");

            uint256 unlockStart = info.startTime + 365 days;
            require(block.timestamp >= unlockStart, "Tokens are still locked");

            uint256 monthsPassed = (block.timestamp - unlockStart) / 30 days;
            if (monthsPassed > 10) {
                monthsPassed = 10;
            }

            uint256 totalUnlocked = (info.totalAmount * monthsPassed) / 10;
            uint256 claimable = totalUnlocked - info.claimedAmount;
            require(claimable > 0, "Nothing to claim yet");

            info.claimedAmount += claimable;
            _transfer(address(this), msg.sender, claimable);
            emit ClaimedToken(msg.sender, claimable);
        }
      




            function changeTimeline(address user, uint256 newStartTime) external onlyAdmin {

                require(vesting[user].totalAmount > 0, "User has no vested tokens");
                vesting[user].startTime = newStartTime;
                emit TimelineChanged(user, newStartTime);
            }

            function withdrawAll() external onlyOwner{                  // bnb and usdt pacha leva
                payable(msg.sender).transfer(address(this).balance);
                usdt.transfer(msg.sender, usdt.balanceOf(address(this)));
            }      

            function changeOwner (address _newOwner) external onlyOwner{
                transferOwnership(_newOwner);
                    }

            function changeAdmin (address _newAdmin) external  onlyAdmin {
            admin = _newAdmin ;
                    }


            function getLatestBNBPrice() public view returns (uint256) {
                (, int256 price,,,) = priceFeed.latestRoundData();
                require(price > 0, "Invalid price feed");
                return uint256(price); // Price with 8 decimals
}

             function calculateClaimable(address user) external view returns (uint256) {
                    VestingInfo memory info = vesting[user];
                    if (info.totalAmount == 0) return 0;
                    
                    uint256 unlockStart = info.startTime + 365 days;
                    if (block.timestamp < unlockStart) return 0;
                    
                    uint256 monthsPassed = (block.timestamp - unlockStart) / 30 days;
                    if (monthsPassed > 10) monthsPassed = 10;
                    
                    uint256 totalUnlocked = (info.totalAmount * monthsPassed) / 10;
                    return totalUnlocked > info.claimedAmount ? totalUnlocked - info.claimedAmount : 0;
    }
    

    function getAllClaimableUsersDetails() external view returns (address[] memory, uint256[] memory) {
            uint256 length = buyers.length;
            address[] memory userAddresses = new address[](length);
            uint256[] memory claimables = new uint256[](length);

            for (uint256 i = 0; i < length; i++) {
                address user = buyers[i];
                VestingInfo memory info = vesting[user];
                
                uint256 unlockStart = info.startTime + 365 days;
                uint256 claimable = 0;

                if (info.totalAmount > 0 && block.timestamp >= unlockStart) {
                    uint256 monthsPassed = (block.timestamp - unlockStart) / 30 days;
                    if (monthsPassed > 10) monthsPassed = 10;
                    uint256 totalUnlocked = (info.totalAmount * monthsPassed) / 10;
                    claimable = totalUnlocked > info.claimedAmount ? totalUnlocked - info.claimedAmount : 0;
                }

                userAddresses[i] = user;
                claimables[i] = claimable;
            }

            return (userAddresses, claimables);
}



     function _maybeUpdateTokenPricePlus(uint256 newTokensSold) internal {           //  prize change
            soldTokens += newTokensSold;

            
            while (soldTokens >= nextPriceIncreaseThreshold) {
                tokenPrizeUsdt = tokenPrizeUsdt + (tokenPrizeUsdt * 2) / 100; // increase 2%
                nextPriceIncreaseThreshold += totalSupply() / 10; // set next threshold
            } 

        }

    

    function sellTokenForBnb (uint256 amount) external {

        require (amount > 0 , "amount must greater than 0");
        require (amount >= vesting[msg.sender].claimedAmount , "Not enough unlocked token to sell");
          require (amount * tokenPrizeUsdt / 1e10 / getLatestBNBPrice() <= address(this).balance , "Not enough BNB balnce in contract");
        transferFrom(msg.sender, address(this), amount);
        uint256 returnBnbToUser = amount * tokenPrizeUsdt / 1e10 / getLatestBNBPrice();
        payable(msg.sender).transfer(returnBnbToUser);
        vesting[msg.sender].claimedAmount -= amount;
        emit SellTokenForBnb(msg.sender,amount, returnBnbToUser);

    }

     function sellTokenForUsdt (uint256 amount) external {

            require (amount > 0 , "amount must greater than 0");
            require (amount >= vesting[msg.sender].claimedAmount , "Not enough unlocked token to sell");
            require (amount * tokenPrizeUsdt / 1e18 <= usdt.balanceOf(address(this)) , "Not enough Usdt balnce in contract");
            transferFrom(msg.sender, address(this), amount);
            uint256 returnUsdtToUser = amount * tokenPrizeUsdt / 1e18 ;
           usdt.transferFrom(msg.sender, address(this), returnUsdtToUser);
            vesting[msg.sender].claimedAmount -= amount;
            emit SellTokenForUsdt(msg.sender,amount, returnUsdtToUser);
    }
       
}