//SPDX-License-Identifier: MIT

pragma solidity  ^0.8.4; 

import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ReneumTask{

    using SafeMath for uint256;
    address public owner;
    bool public claimed;
    bool public created;
    uint public bossCounter;
    uint public charCount;

    struct Characters {
        string name;
        uint hp2;
        uint dmg2;
        uint xp;
        bool claimed;
        bool created;
        bool attacked;
    }

    mapping (uint256 => Boss) public Bosses;
    mapping (address=> Characters) public Character;  

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    } 

    modifier oneChar () {

        require (!Character[msg.sender].created, "only 1 character per user!");
        _;
    } 

        modifier hasAttacked () {

        require (Character[msg.sender].attacked, "You must attack the boss atleast once to claim!");
   
        _;
    } 

    modifier gainedXP () {
        require (Character[msg.sender].xp>0, "This character hasn't gained any xp");
        _;
    } 

    modifier notSelf () {
        require (msg.sender == msg.sender, "You cannot perform this action on yourself");
        _;
    } 


    modifier bossDead () {
        require (Bosses[bossCounter].hp<=0 , "The boss is not dead");
        _;
    } 


    modifier notDead() {
        require (Character[msg.sender].hp2>0, "cannot perform while dead, ask for a heal!");
        _;
    }

    modifier hasClaimed() {
        require(!Character[msg.sender].claimed, "you've already claimed!");

        Character[msg.sender].claimed = false;
        _;
        
    }

    struct Boss {
        uint hp;
        uint dmg;
        uint reward;
    } 

   //only 1 boss at a time if, Bosses[0].hp >> 0 a new boss may not be created

    //if Bosses[0].hp <= 0 - we must extend the Bosses reward to the players in the form of xp


     constructor() {
        // Set the transaction sender as the owner of the contract.
        owner = msg.sender;
    }

    function createBoss (uint _bossHP, uint _bossDMG, uint _bossREWARD) public onlyOwner bossDead returns (string memory) {

        uint hp=_bossHP;
        uint dmg=_bossDMG;
        uint reward=_bossREWARD;
        
        Character[msg.sender].claimed = false;

    if (Bosses[bossCounter].hp<=0) {
        bossCounter++;
        Bosses[bossCounter].hp = hp;
        Bosses[bossCounter].dmg = dmg;
        Bosses[bossCounter].reward = reward;
    }

    else {
        Bosses[bossCounter].hp = hp;
        Bosses[bossCounter].dmg = dmg;
        Bosses[bossCounter].reward = reward;
    }

    return ("Boss Created!");

    }
        

    function createCharacter (string memory _name) public oneChar returns(string memory, uint, uint, uint, uint, bool)  {
        charCount++;

        uint hp2=100;
        uint dmg2=10;
        uint xp=0;
        claimed=false;
        created=true;

        Character[msg.sender].name = _name;

        Character[msg.sender].hp2 = hp2;
        Character[msg.sender].dmg2 = dmg2;
        Character[msg.sender].xp = xp;
        Character[msg.sender].claimed = false;
        Character[msg.sender].attacked = false;
        Character[msg.sender].created = true;

            return (Character[msg.sender].name, bossCounter, Character[msg.sender].hp2, Character[msg.sender].dmg2, Character[msg.sender].xp, Character[msg.sender].claimed);
    //characters start with static values for hp/dmg/exp
    } 

    function getName() public view returns (string memory) {
        return(Character[msg.sender].name);
    }

    function getBoss() public view returns (uint) {
        return(Bosses[bossCounter].hp);
    }

    function getXP() public view returns (uint) {
        return (Character[msg.sender].xp);
    }

    function getHP() public view returns (uint) {
        return (Character[msg.sender].hp2);
    }

    function numChars () public view returns (uint) {
        return (charCount);
    }

    function numBosses () public view returns (uint) {
        return (bossCounter);
    }

    function checkStats() public view returns(uint, uint, uint,bool, bool) {
        return (Character[msg.sender].hp2, Character[msg.sender].dmg2, Character[msg.sender].xp,Character[msg.sender].claimed, Character[msg.sender].attacked);
    }

    function Attack() public  notDead returns (uint, uint) {
    require (Bosses[bossCounter].hp > 0 , "Boss is dead claim a reward and stand by");

        if (Character[msg.sender].dmg2 > Bosses[bossCounter].hp) {
        Bosses[bossCounter].hp = 0;
        Character[msg.sender].hp2 - Bosses[bossCounter].dmg;
        Character[msg.sender].attacked=true;
        }

        else {

        Bosses[bossCounter].hp = Bosses[bossCounter].hp - Character[msg.sender].dmg2;    
        Character[msg.sender].hp2 = Character[msg.sender].hp2 - Bosses[bossCounter].dmg;  
        Character[msg.sender].attacked=true;
        }


        return (Bosses[bossCounter].hp, Character[msg.sender].hp2);
    } 

    function Heal () public  notSelf gainedXP notDead returns (uint) {
        Character[msg.sender].hp2 = Character[msg.sender].hp2+5;
        return Character[msg.sender].hp2;
    ///maybe an emit event? also might need to be able to select # in array
    }



    function ClaimReward () public hasAttacked hasClaimed bossDead notDead  returns (uint, bool) {
        Character[msg.sender].xp = Character[msg.sender].xp + Bosses[bossCounter].reward;
        Character[msg.sender].claimed=!Character[msg.sender].claimed;  

    

        return (Character[msg.sender].xp,  Character[msg.sender].claimed);
    } 

}