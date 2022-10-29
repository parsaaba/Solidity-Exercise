import { ethers } from "hardhat";
import { expect } from "chai";
import { Game } from "../typechain";
import { assert } from "console";
import { BigNumber, Contract } from "ethers";

describe("Game", function () {
  it("default test", async function () {
    // const [owner] = await ethers.getSigners();
    const factory = await ethers.getContractFactory("Game");
    const contract = await factory.deploy();

    const provided = "parsa";
   

    const greeting = await contract.createCharacter(provided);
    assert(await contract.getName() === 'parsa');

    const boss = await contract.createBoss(20,1,1);
    assert(await contract.getBoss() > ethers.BigNumber.from(0));

   

    const attack = await contract.Attack();
    assert(await contract.getBoss() > ethers.BigNumber.from(0));

    const attack2 = await contract.Attack();
    assert(await contract.getBoss() === ethers.BigNumber.from(0));

    const attack3 = await contract.Attack();

    const claim = await contract.ClaimReward();
    assert(await contract.getXP() > ethers.BigNumber.from(0));

    const HP1 = await contract.getHP();
    const heal = await contract.Heal();
    const HP2 = await contract.getHP();
    assert(HP2 > HP1);

  });

    
});
