const { expect } = require("chai");

describe("SetNumber Contract", function () {
  let Token, token, owner, addr1;

  beforeEach(async function () {
    Token = await ethers.getContractFactory("Lock");
    [owner, addr1] = await ethers.getSigners();
    token = await Token.deploy();
  });

  it("set number", async function () {
    
    await token.setNumber(10);
    expect(await token.getNumber()).to.equal(10);
  });

  it ("should be not zero", async function (){


    expect(token.setNumber(0)).to.be.revertedWith("Number must be greater than zero");
    // revert function ma kyarey await na lakhvu
  })
});
