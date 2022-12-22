pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract Betting{
    
    Game public game;
    address payable cont_addr = payable(address(this));
    struct Game {
        string Team1;
        string Team2;
        uint time;
        uint BetCount;
        uint WagerCount;
        mapping(address => uint) pending;
        mapping(uint => Bet) Bets;
        mapping(uint => Wager) Wagers;
        mapping(address => Wager[]) Waitlist;
    }
    
    struct Bet {
        uint id;
        Wager wager1;
        Wager wager2;
        bool closed;
    }
    
    struct Wager{
        uint id;
        address payable Bettor;
        string Team;
        uint Amount;
        address Preference;
        bool foundMatch;
    }
    
    function addGame (string memory team1, string memory team2, uint256 t) public
    {
        //check if time is valid
        require(t > 0, "Invalid Start Time");
        
        //add game according to values
        game.Team1 = team1;
        game.Team2 = team2;
        game.time = block.timestamp + t;
    }
    function addWager (string memory team, address preference) public payable
    {
        //check if game has started and if bettor has sufficient balance
        //require(block.timestamp < game.time, "Unable to place bid; the game has already started");
        require(msg.value < msg.sender.balance, "Insufficient Balance");
        //update the return value of unmatched wager for every wager being placed
        game.pending[msg.sender] += msg.value;
        //if preference address supplied, add wager to waitlist array and try to find a wager from there
        if(preference == address(0x0))
        {
            game.WagerCount++;
            game.Wagers[game.WagerCount] = Wager(game.WagerCount, msg.sender, team, msg.value, preference, false);
            matchWager(game.Wagers[game.WagerCount]);
        }
        //if preference address not specified add wager to wager array and try to find a match from there
        else
        {
            game.Waitlist[preference].push(Wager(0, msg.sender, team, msg.value, preference, false));
            matchWager(game.Waitlist[preference][game.Waitlist[preference].length-1]);
        }
        
    }
    
    function matchWager (Wager memory w) private returns (bool)
    {
        /*check waitlist data structure to see if current wager is being waited on; 
        if so match them by creating a Bet and updating the bets array with the matched Wagers*/
        if (game.Waitlist[w.Bettor].length != 0)
        {
            for(uint i = 0; i < game.Waitlist[w.Bettor].length; i++)
            {
                if(!game.Waitlist[w.Bettor][i].foundMatch && keccak256(abi.encode(w.Team)) != keccak256(abi.encode(game.Waitlist[w.Bettor][i].Team)))
                {
                    if(w.Amount == game.Waitlist[w.Bettor][i].Amount && (w.Preference == address(0x0) || w.Preference == game.Waitlist[w.Bettor][i].Bettor))
                    {
                        game.pending[w.Bettor] -= w.Amount;
                        game.pending[game.Waitlist[w.Bettor][i].Bettor] -= w.Amount;
                        w.foundMatch = true;
                        game.Waitlist[w.Bettor][i].foundMatch = true;
                        game.BetCount++;
                        game.Bets[game.BetCount] = Bet(game.BetCount, w, game.Waitlist[w.Bettor][i], false);
                        return true;
                    }
                }
            }
        }
        if (w.Preference != address(0x0))
        {
            return false;
        }

        //loop through available wagers to find a match by creating a Bet and updating the bets array with the matched wagers
       for(uint i = 1; i <= game.WagerCount; i++)
       {
           if (!game.Wagers[i].foundMatch && keccak256(abi.encode(w.Team)) != keccak256(abi.encode(game.Wagers[i].Team)))
           {
               if(w.Amount == game.Wagers[i].Amount)
               {
                   game.pending[w.Bettor] -= w.Amount;
                   game.pending[game.Wagers[i].Bettor] -= w.Amount;
                   w.foundMatch = true;
                   game.Wagers[i].foundMatch = true;
                   game.BetCount++;
                   game.Bets[game.BetCount] = Bet(game.BetCount, w, game.Wagers[i], false);
                   return true;
               }
           } 
       }
       return false;
    }

    function closeBets(string memory winner) public 
    {
        //check if updater has already placed a wager before to update the game status
        //require(game.pending[msg.sender] > 0, "Cannot update game if wager hasn't been placed");
        for(uint i = 1; i <= game.BetCount; i++)
        {
            //check if bet has already been closed
            if(game.Bets[i].closed) continue;
            
            if (keccak256(abi.encodePacked(game.Bets[i].wager1.Team)) == keccak256(abi.encodePacked(winner))){
                if(!game.Bets[i].wager1.Bettor.send(game.Bets[i].wager1.Amount * 2))
                    revert("Transaction Unsuccessful WAGER1");
            }
            else
                if(!game.Bets[i].wager2.Bettor.send(game.Bets[i].wager1.Amount * 2))
                    revert("Transaction Unsuccessful WAGER2");
            game.Bets[i].closed = true;
        }
    }
    function withdraw() public
    {
        uint amount = game.pending[msg.sender];
        
        if(amount > 0) { 
            game.pending[msg.sender] = 0; 
             
            if(!payable(msg.sender).send(amount)) { 
                game.pending[msg.sender] = amount; 
            } 
        }
    }
    
}

