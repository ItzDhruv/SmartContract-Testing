const { expect } = require("chai");

describe("Advance Bank Contract", function () {
  let Token, token, owner, user1, user2;
 
  beforeEach(async function () {
    Token = await ethers.getContractFactory("AdvancedBank");
    [owner, user1 ,user2] = await ethers.getSigners();
    token = await Token.deploy();
  });

  it("Register user", async function () {
    await token.connect(user1).register();
    await token.connect(user2).register();
    await expect(token.connect(user1).register()).to.be.revertedWith("User already registered");
    await expect(token.connect(user2).register()).to.be.revertedWith("User already registered");
  });


  it("Depoosit", async function (){

    await token.connect(user1).register();
    await token.connect(user2).register();
    await token.connect(user1).deposit({value: 100});
    await token.connect(user1).deposit({value: 10});
    await token.connect(user2).deposit({value: 100});
    await token.connect(user2).deposit({value: 100});
    expect(await token.connect(user1).getBalance()).to.equal(110);
    expect(await token.connect(user2).getBalance()).to.equal(200);
  })


  it("Should not Depoosit/Withdaw without Register", async function (){
    await expect(token.connect(user1).deposit({value: 100})).to.be.revertedWith("User not registered");
    await expect(token.connect(user1).withdraw(100)).to.be.revertedWith("User not registered");

  })


  it("withdraw", async function(){
    await token.connect(user1).register();
    await token.connect(user1).deposit({value : 100});
    await token.connect(user1).withdraw(50);
    await token.connect(user2).register();
    await token.connect(user2).deposit({value : 200});
    await token.connect(user2).withdraw(100);
    await token.connect(user2).withdraw(50);
    expect(await token.connect(user1).getBalance()).equal(50);
    expect(await token.connect(user2).getBalance()).equal(50);
  })

  it("deposit/withdraw must be grter than 0", async function(){
    await token.connect(user1).register();
    await expect(token.connect(user1).deposit({value: 0})).to.be.revertedWith("Deposit amount must be greater than zero");
    await expect(token.connect(user1).withdraw(0)).to.be.revertedWith("Withdrawal amount must be greater than zero");
  })

  it("withdraw must be less than balance", async function(){

    await token.connect(user1).register();
    await token.connect(user1).deposit({value: 100});
    await expect(token.connect(user1).withdraw(200)).to.be.revertedWith("Insufficient balance");
    await token.connect(user2).register();
    await token.connect(user2).deposit({value: 100});
    await expect(token.connect(user2).withdraw(101)).to.be.revertedWith("Insufficient balance");
  })

  it("transfer balance", async function(){

    await token.connect(user1).register();
    await token.connect(user2).register();
    await token.connect(user1).deposit({value: 100});
   
    await token.connect(user1).transfer(user2.address, 50);
    expect(await token.connect(user2).getBalance()).to.equal(50);
    expect(await token.connect(user1).getBalance()).to.equal(50);
  })
  it("should set interest rate", async function () {
    expect(await token.interestRate()).to.equal(5); // Check contract ma apeli interest rate
    await token.setInterestRate(10); // Set new interest rate
    expect(await token.interestRate()).to.equal(10); // Check if updated
});
});