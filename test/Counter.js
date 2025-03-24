const { expect } = require("chai");

describe("Increase-Decrease Contract", function () {
  let Token, token, owner, addr1;

  beforeEach(async function () {
    Token = await ethers.getContractFactory("Counter");
    [owner, addr1] = await ethers.getSigners();
    token = await Token.deploy();
  });

  it("increment number", async function () {
    
      const temp = await token.getCount() ;
    await token.increment();
    expect(await token.getCount()).to.equal(temp + BigInt(1));
  });

  it("decrement number", async function () {
    await token.increment();
    await token.decrement();
    expect(await token.getCount()).to.equal(BigInt(0));
  })
  
  it("should not allowed decrement at 0", async function () {

     expect(await token.getCount()).to.equal(BigInt(0));
     expect(token.decrement()).to.be.revertedWith("Count cannot be negative")
 
  })

});
