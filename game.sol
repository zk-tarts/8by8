pragma solidity ^0.8.10;

contract Game is ERC721{
    IERC721 constant RARITY  = IERC721(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    uint256 constant EXP_PER_CLAIM = 1000;
    uint256 constant COOLDOWN = 7 days;
    uint256 constant MAX_ASCENDED = 2000;
    uint256 public playerCount; // how many tokens have been bound to create a player in this game.
    mapping (uint256=>uint256) tokenCounts; // updates when a new token is minted
    mapping (uint256=>uint256) ascendedCount; // how many ascended tokens there can be
    mapping (uint256=>uint256) playerGuild; // which guild a player is in.
    mapping (uint256=>uint256) trinketExp; // guild => how much exp bonus from trinkets.
    mapping (uint256=>uint256) exp; // how much exp a player has.
    mapping (uint256=>uint256) expBonus; // how much bonus exp a player gets per grind.
    mapping (uint256=>uint256) rank; // what rank the player is.
    mapping (uint256=>uint256) playerLuck; // how much luck a player has from gear/buffs.
    mapping (uint256=>uint256) cooldownReduction; // how much cooldown is reduced by
    mapping (uint256=>uint256) lastGrind; // how long has it been since a player played. 
    string[] public names = [
        "",
        "Alchemist",   // potions / alchemy(transform things) 
        "Brewer",      // strong buffs with downside
        "Blacksmith",  // weapons / armour / enhance gear
        "Herbalist",   // buffs / poisons
        "Jeweler",     // trinkets
        "Painter",     // art
        "Tinker"       // gadgets
        ];

/**
 * Drops:
 * Drops are gained from grinding. Drop rate is psuedo-random based on the exp of some other player.
 * There is a supply cap of higher tier drops to guaruntee rarity because this "randomness" can be predicted ahead of time and exploited.
 * Consuming a higher tier drop will allow another one to be minted.
 * Ascended Paintings can't be consumed so there will only ever be a set amount.
 *
 **
 * Alchemist's Potion: transform 50/15/9/8/7/6 drops (no tinker trinkets) 
 * with max rank Novice/Apprentice/Apprentice/Expert/Master/Ascended into one of a higher tier from another class
 * Ascended items get changed but obviously cannot upgrade further
 * Weighting: (Alchemist or Painter)->Brewer->Blacksmith->Herbalist->Jeweler->Tinker
 * they don't have to be from the same class
 * Tinker trinkets cannot be transformed because it causes a volaitile reaction!
 *
 **
 * Brewer's Draught: consume to spend all/80%/70%/50%/45%/30% of your exp bonus.
 * Gain 2/2/2/3/3/3 times your exp bonus instantly capped at 1 below next rank.
 * cannot rank up
 * Breaks gear.
 * luck +0/0/0/0/1/2
 * 
 **
 * Blacksmith's toolkit: exp bonus +20/200/1000/6000/20000/40000. Can be worn by at least rank 0/0/1/3/4/4
 * Ascended toolkit: +5 luck.
 * Equip: you can only have one toolkit equipped at a time. 
 *
 ** 
 * Herbalist's tincture: consume for + 1/3/12/50/160/800 exp bonus stat
 * Ascended tincture: consume for +1 luck
 * 
 *
 **
 * Jeweler's Trinket: members of your guild with a rank higher than recruit gain +1/+20/+100/+1000/+10000 exp bonus.
 * You gain +5/100/400/800/1600/4000 exp bonus
 * Ascended trinket: gain +1 luck for every 100000 guild exp bonus from trinkets
 * Equip: you can only have one trinket equipped at a time.  
 *
 **
 * Painting: A piece of art.
 * Ascended Painting: only set amount of Ascended Paintings will exist
 * Ascended Paintings have actual art
 **
 * Tinker's Gadget: minus 0.5/1/1.5/2/3/4 days cooldown between grind() 
 * Ascended Gadget: minus 1 hour cooldown per 2 luck from gear/buffs
 * Equip: you can only have one gadget equipped at a time.
 */

    /*constructor ("Guild Drops", "GDROP"){
    }*/
    function _reward(uint256 id, uint256 luck, uint256 level, bytes32 data) internal{
        luck >50 ? luck=50 : luck=luck;  // luck cap stops the game from breaking because too many loops is too much gas
        uint256 numPlayers = playerCount;
        uint256 playerXP = exp[id];
        
        /**
         * low tier items always drop
         * every 5 luck drops 1 more low tier item
         */
        if (level <3){
            _safeMint(address(0),id);
            tokenCounts[id] +=1;
            uint256 extraMints = (luck-(luck%5))/5;
            for(uint256 i =0; i<extraMints;i++){
                _safeMint(address(0),id);
            }
        }
        
        /**
         * Formula used for 'high tier' drops
         * 
         * Item only drops if your exp is less than ( 3^(4 - your level)*10000 plus the exp of some other player )
         * roll again for every luck stat if roll failed
         * example:
         * level 3: your exp must be less than 270000 plus the other players exp
         * level 4: your exp must be less than 810000 plus the other players exp
         */
        else if (level <5){ 
            for(uint256 i =0; i<=luck; i++){
                if (playerXP < ((3**(4-level))*10000 + exp[(i*playerXP)%numPlayers])){
                    _safeMint(address(0)/*_msgSender()*/,id); // mint a token at their rank and from their guild
                    tokenCounts[id] +=1;
                    return;
                }
            }
        }
        
        /**
         * Ascended drops are special, instead of using some onchain rng, they require some commit-reveal stuff
         */
        else{
            if (data ==0){
                _safeMint(address(0/*_msgSender()*/),id); // mint  a master rank item if u don't have the 
                tokenCounts[id] +=1;
            }
            bytes32 key = 0 ; // something something cruptography merkle tree idk
            require(data==key,"Ascended drops only occur if you enter the correct data");
        }
        
        
        
    }
    
    // Bind your rarity character to a guild.
    function join(uint256 id, uint256 guildNo) external{
        require(playerGuild[id]==0);           // cannot join more than 1 guild per rarity player
        require((guildNo > 0 && guildNo <8));  // must be correct guild number
        require(RARITY.ownerOf(id)==msg.sender);
        playerCount+=1;
    }
    
     
    // Equipping gear will unequip any old gear you have on.
    function use(uint256 player, uint256 id, uint256[] calldata data) external{
        require(RARITY.ownerOf(player)==msg.sender);
        require(ownerOf(id)==msg.sender,"must own the consumables being spent");
        uint256 lvl = rank[player];
        if (id ==0){ // Alchemist
            _burn(id);
            uint256 tokens;
            if (lvl == 0){
                tokens = 50;
            }
            else if (lvl == 1){
                tokens = 15;
            }
            else if (lvl == 2){
                tokens = 9;
            }
            else if (lvl == 3){
                tokens = 8;
            }
            else if (lvl == 4){
                tokens = 7;
            }
            else if (lvl == 5){
                tokens = 6;
            }
            for (uint256 i = 0; i<=tokens; i++){
                //require(data.level ==lvl, "all tokens must be the correct level");
                require(ownerOf(data[i]) == msg.sender,"must own all the ingredients");
                _burn(data[i]);
            }
            _mint(msg.sender,0);
        }
        else if (id ==1){ // Brewer
            _burn(id);
        } 
        else if (id ==2){ // Blacksmith
            expBonus[player]+= id;
            transferFrom(msg.sender,address(this),id);
        } 
        else if (id ==3){ // Herbalist
            expBonus[player]+= id;
            _burn(id);
        } 
        else if (id ==4){ // Jeweler
            expBonus[player] += id;
            trinketExp[1/*playerGuild[player]*/]+= id;
            transferFrom(msg.sender,address(this),id);
        } 
        else if (id ==5){ // Painter
            revert("paintings have no in-game effect");
        } 
        else if (id ==6){ // Tinker
            cooldownReduction[player] += id;
            transferFrom(msg.sender,address(this),id);
        }
    }
    function unequip(uint256 player, uint256 id) public{ // useful if u wanna drink a brew and save your gear
        require (1==1); // sender owns the player
        expBonus[player] -= id; //id. expBonus
        trinketExp[playerGuild[player]] -= 1; //id. trinketExp
    }
    
    // useful function that lets you know if you are ready to grind
    function canGrind(uint256 id) public view returns (bool){
        return (block.timestamp - COOLDOWN) > (lastGrind[id] - cooldownReduction[id]);
    }
    
    function grind(uint256 id) external{  // grind your skills
        require(canGrind(id), "on cooldown");
        uint256 bonus = expBonus[id] + trinketExp[id];
        uint256 luck = playerLuck[id]; // chance for lucky rolls
        bonus = (bonus *3)/2;  //  
        luck +=5;   // 
        exp[id] += (EXP_PER_CLAIM + bonus); 
        _reward(id,luck,1,0);
        
    }
    
    function rankUp(uint256 id) external{
        uint256 xp = exp[id];
        if(xp>=2430000){
            rank[id] = 5;   
        }
        else if(xp>=810000){
            rank[id] = 4;
        }
        else if(xp>=270000){
            rank[id] = 3;
        }
        else if(xp>=90000){
            rank[id] = 2;
        }
        else if(xp>=30000){
            rank[id] = 1;
        }
    }
    
}
    
    //string(abi.encodePacked(rank, names[])
    //string(abi.encodePacked(names[], "s Guild"));

//    function beginElection() external{} // governance :D
// if someone is rank master you can run for election
