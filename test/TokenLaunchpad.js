const {expect} = require('chai');
const {ethers} = require('hardhat');

describe("Token-Launchpad Contract", function () {
    let Token, token, owner, user1 ,buyer,user2
    beforeEach(async function () {
        Token = await ethers.getContractFactory("TokenLaunchpad");
        [owner, user1, user2, buyer] = await ethers.getSigners();
        token = await Token.deploy();
    });
    
    

    it("Should launch a new token successfully", async function () {
        await expect(token.connect(owner).launchToken("TestToken", "TTK", 1000, ethers.parseEther("0.01")))
            .to.emit(token, "TokenLaunched");

        let allTokens = await token.getAllTokens();
        expect(allTokens.length).to.equal(1);
        let tokenInfo = await token.launchedTokens(allTokens[0]);
        expect(tokenInfo.owner).to.equal(owner.address);
        expect(tokenInfo.totalSupply).to.equal(1000);

        await expect(token.connect(user1).launchToken("TestToken", "TTK", 1000,ethers.parseEther("0.01")))
        .to.emit(token, "TokenLaunched");

     allTokens = await token.getAllTokens();
    expect(allTokens.length).to.equal(2);
     tokenInfo = await token.launchedTokens(allTokens[1]);
    expect(tokenInfo.owner).to.equal(user1.address);
    expect(tokenInfo.totalSupply).to.equal(1000);
    });

    it("buy token", async function(){
       await expect(token.launchToken("dhruv","dd",10000000,ethers.parseEther("0.01"))).to.emit(token,"TokenLaunched");  
       let allToken2 = await token.getAllTokens();
       expect(allToken2.length).to.equal(1);
       const tokenAddress = allToken2[0];
       let boughtToken = 1001;
       let ethSenToBuyToken = (boughtToken * 0.01).toString();
       expect(token.connect(user1).buyTokens(tokenAddress, boughtToken, { value: ethers.parseEther(ethSenToBuyToken) })).to.emit(token, "TokensPurchased")

       const erc20 = await ethers.getContractAt("ERC20Token", tokenAddress);

       const user1TokenBalance = await erc20.balanceOf(user1.address);


       expect(user1TokenBalance).to.equal(boughtToken);

    })

    // it("should allow a user to buy tokens after approval", async function () {
    //     const tokenName = "DhruvToken";
    //     const tokenSymbol = "DT";
    //     const totalSupply = 1000000;
    //     const tokenPrice = ethers.parseEther("0.01"); // 0.01 ETH per token

    //     // Launch token
    //     await expect(token.launchToken(tokenName, tokenSymbol, totalSupply, tokenPrice))
    //         .to.emit(token, "TokenLaunched");

    //     // Get the token address
    //     const allTokens = await token.getAllTokens();
    //     expect(allTokens.length).to.equal(1);
    //     const tokenAddress = allTokens[0];

    //     // Get ERC20 token contract
    //     ERC20Token = await ethers.getContractAt("ERC20Token", tokenAddress);

    //     // Owner approves token contract to transfer tokens
    //     const buyAmount = 100;
    //     const totalCost = ethers.parseEther("1.0"); // 100 * 0.01 ETH

    //     await ERC20Token.connect(owner).approve(token.target, buyAmount);

    //     // Buyer purchases tokens
    //     await expect(
    //         token.connect(buyer).buyTokens(tokenAddress, buyAmount, { value: totalCost })
    //     ).to.emit(token, "TokensPurchased")
    //       .withArgs(buyer.address, tokenAddress, buyAmount, totalCost);

    //     // Check token balance of buyer
    //     const buyerBalance = await ERC20Token.balanceOf(buyer.address);
    //     expect(buyerBalance).to.equal(buyAmount);
    // });
    
})