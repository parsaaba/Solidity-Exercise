pragma solidity  ^0.8.4; 

import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/math/SafeMath.sol";

contract ReneumTaskv2 {
    using Safemath for uint256;
    
    bool public claimed;
    uint public playerID;
    uint public bossID;

    mapping (uint256 => Boss) public Bosses;
    mapping (address=> Character) public Character;  

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    } 

    modifier oneChar () {

        require (Character[msg.sender].created != Character[msg.sender].created, "only 1 character per user!");
        _;
    } 

    modifier gainedXP () {
        require (Character[msg.sender].xp>0, "This character hasn't gained any xp");
        _;
    } 

    modifier notSelf () {
        require (Character[msg.sender] != Character[msg.sender], "You cannot perform this action on yourself");
        _;
    } 



    modifier bossDead () {
        require (Bosses[0].hp<=0 , "The boss is not dead");
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

   //only 1 boss at a time if, bosses[0].hp >> 0 a new boss may not be created

    //if bosses[0].hp <= 0 - we must extend the bosses reward to the players in the form of xp

    struct Character {
        uint hp2;
        uint dmg2;
        uint xp;
        bool claimed;
    }


     constructor() {
        // Set the transaction sender as the owner of the contract.
        owner = msg.sender;
    }

    function createBoss (uint _bossHP, uint _bossDMG, uint _bossREWARD) public  {
        require(Bosses[0].hp<=0, "boss isnt dead, kill the boss before making another");
        uint hp=_bossHP;
        uint dmg=_bossDMG;
        uint reward=_bossREWARD;
        bosses.push(
            Boss(            
                hp,
                dmg,
                reward
            ));
    }
        

        


    function createCharacter () public oneChar returns(uint, uint, uint, uint, bool)  {
        playerID++;
        uint hp2=100;
        uint dmg2=10;
        uint xp=0;
        claimed=false;
        Character.push(
                User(
                    hp2,
                    dmg2,
                    xp,
                    claimed
                )
                );
                return (playerID, Character[msg.sender].hp2, Character[msg.sender].dmg2, Character[msg.sender].xp, Character[msg.sender].claimed);
    //characters start with static values for hp/dmg/exp
    } 

    function checkStats() public view returns(uint, uint, uint,bool) {
        return (Character[msg.sender].hp2, Character[msg.sender].dmg2, Character[msg.sender].xp,Character[msg.sender].claimed);
    }

    function Attack() public  notDead returns (uint, uint) {

        Bosses[0].hp = Bosses[0].hp - Character[msg.sender].dmg2;    
        Character[msg.sender].hp2 = Character[msg.sender].hp2 - Bosses[0].dmg; 
        
        if (Bosses[0].hp<0) {
            
            
            Bosses[0].hp=0;
            return (Bosses[0].hp, Character[msg.sender].hp2);

        } else {
            return (Bosses[0].hp, characters[bossID].hp2);
        }


        return (Bosses[0].hp, Character[msg.sender].hp2);
    } 

    function Heal () public  gainedXP notDead returns (uint) {
        Character[msg.sender].hp2 = Character[msg.sender].hp2+5;
        return Character[msg.sender].hp2;
    ///maybe an emit event? also might need to be able to select # in array
    }



    function ClaimReward () public hasClaimed bossDead notDead  returns (uint, bool) {
        Character[msg.sender].xp = Character[msg.sender].xp + Bosses[0].reward;
        Character[msg.sender].claimed=!Character[msg.sender].claimed;   ////always returns true?!?!?!?!? wtf
        return (Character[msg.sender].xp,  Character[msg.sender].claimed);
    } 

}

 