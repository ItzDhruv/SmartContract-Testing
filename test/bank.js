const { expect } = require("chai");

describe("Bank Contract", function () {
    let Token, token, owner, addr1;
  
    beforeEach(async function () {
      Token = await ethers.getContractFactory("Bank");
      [owner, addr1] = await ethers.getSigners();
      token = await Token.deploy();
    });


    it("should be allow deposite", async function(){

        await token.deposit({value :100})
        expect(await token.getBalance()).to.equal(100)
    
    })

    it("deposit value must be greater than 0", async function(){
        expect(token.deposit({ value : 0})).to.be.revertedWith("Deposit amount must be greater than zero")   
        
    })

    it("should alowed to withdraw", async function(){
        await token.deposit({value : 100});
        await token.withdraw(30);
        await token.withdraw(20);
        expect(await token.getBalance()).to.equal(50)

    })

    it("Insufficent balance", async function(){

        await token.deposit({value : 100});
        expect(token.withdraw(200)).to.be.revertedWith("Insufficient balance")
    })

  

})


