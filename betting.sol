{\rtf1\ansi\ansicpg1252\cocoartf2580
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 pragma solidity ^0.5.0;\
pragma experimental ABIEncoderV2;\
contract Betting\{\
    \
    Game public game;\
    \
    struct Game \{\
        uint id;\
        string Team1;\
        string Team2;\
        uint256 time;\
        uint BetCount;\
        uint WagerCount;\
        uint WaitlistCount;\
        mapping(uint => Bet) Bets;\
        mapping(uint => Wager) Wagers;\
        mapping(uint => Wager) Waitlist;\
    \}\
    \
    struct Bet \{\
        uint id;\
        Wager wager1;\
        Wager wager2;\
    \}\
    \
    struct Wager\{\
        uint id;\
        address Bettor;\
        string Team;\
        uint Amount;\
        address Preference;\
        bool foundMatch;\
    \}\
    \
    event NotEnoughBalance(string team, uint amount, address addr);\
    \
    function addGame (string memory team1, string memory team2, uint256 t) public\
    \{\
        game.Team1 = team1;\
        game.Team2 = team2;\
        game.time = t;\
    \}\
    function addWager (string memory team, uint amount, address preference) public\
    \{\
        if(amount > msg.sender.balance)\
        \{\
            emit NotEnoughBalance(team, amount, msg.sender);\
        \}\
        if(preference == address(0x0))\
        \{\
            game.WagerCount++;\
            game.Wagers[game.WagerCount] = Wager(game.WagerCount, msg.sender, team, amount, preference, false);\
            matchWager(game.Wagers[game.WagerCount]);\
        \}\
        else\
        \{\
            game.WaitlistCount++;\
            game.Waitlist[game.WaitlistCount] = Wager(game.WaitlistCount, msg.sender, team, amount, preference, false);\
        \}\
    \}\
    \
    function matchWager (Wager memory w) public returns (bool)\
    \{\
        //loop through waitlist to see if current wager is being waited on and match if so\
        for(uint i = 1; i < game.WaitlistCount; i++)\
        \{\
            if(!game.Waitlist[i].foundMatch && w.Bettor == game.Waitlist[i].Preference)\
            \{\
                if (w.Amount == game.Waitlist[i].Amount)\
                \{\
                    if(keccak256(abi.encodePacked(w.Team)) != keccak256(abi.encodePacked(game.Waitlist[i].Team)))\
                    \{\
                        w.foundMatch = true;\
                        game.Waitlist[i].foundMatch = true;\
                        game.BetCount++;\
                        game.Bets[game.BetCount] = Bet(game.BetCount, w, game.Waitlist[i]);\
                        return true;\
                    \}\
                \}\
            \}\
        \}\
\
       for(uint i = 1; i < game.WagerCount; i++)\
       \{\
           if (!game.Wagers[i].foundMatch && keccak256(abi.encodePacked(w.Team)) != keccak256(abi.encodePacked(game.Wagers[i].Team)))\
           \{\
               if(w.Amount == game.Wagers[i].Amount)\
               \{\
                   w.foundMatch = true;\
                   game.Wagers[i].foundMatch = true;\
                   game.BetCount++;\
                   game.Bets[game.BetCount] = Bet(game.BetCount, w, game.Wagers[i]);\
                   return true;\
               \}\
           \} \
       \}\
       return false;\
    \}\
    function updateWager(address bettor, uint old, uint new)\
    \
\}}