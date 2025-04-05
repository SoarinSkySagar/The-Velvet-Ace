what happens when a player runs out of chips in a poker game

1. Cash Game
Buying Back In:
If a player runs out of chips, they can buy more chips (re-buy) if they wish to continue playing.
The player may leave the game if they choose not to rebuy.
All-In Situations:
If a player runs out of chips during a hand, they can go "all-in" for the amount of chips they have left. A side pot is created for the remaining players who still have chips to bet.
The all-in player can only win the main pot (the chips they contributed to and any matching bets).

2. Tournament
Elimination:
In tournaments, when a player runs out of chips, they are eliminated from the game unless:
It’s a rebuy tournament, where players can purchase more chips within a certain time frame.
It’s a freeroll tournament, and there’s an option for add-ons.
All-In Situations:
Similar to cash games, if a player goes all-in, a side pot is created for other players who continue betting.
The all-in player can only win the main pot, as they have no chips left to match further bets.


// Make Deck have it's own id
// store only references of models in models, and refactor the whole code


// Add banning options from games, and creators.

// remove 279
## after_play Function Notes
Original pseudocode from the implementation:
- check if player has more chips, prompt 'OUT OF CHIPS'
- resolve players -- set the next player in game
- but before setting the next player, check the player you wish to set, if the player is still in round.
- This after play has more to do -- it keeps close track of each round, and when it should call the `resolve_round()` function
- Keep track of Gmae's current bet, and pot
- This function deals the community cards.
- match each player's current bet with the game's current bet, and act accordingly.
- only works for the "next player". When matched, check the number of community cards.
- deal card if len() < 5, else call resolve_round().// Test for highest straight
// e.g
player's hand = 1, 2
community card = 3, 4, 5, 6, 7

then the hand rank should return 3, 4, 5, 6, 7


// fn extract_kicker(hands: Array<Hand>, hand_rank: u16) -> (Array<Hand>,
// Array<Card>)
// implement kicker. Only works for the current_winner variable
// retrieve the former current_winner already stored and the current player,
// and compare both hands. This should be done in another internal function and be
                // called here.
                // The function should take in both `hand` and `current_winning_hand`, should return
                // the winning hand Implementation would be left to you
                // compare the player's CA in the returned hand to the current `winning_hand`
                // If not equal, update both `current_winner` and `winning_hand`

                // TODO: Check for a straight. The kicker is different for a straight. The person
                // with the highest straight wins (compare only the last straight.) The function
                // called here might take in a `hand_rank` u16 variable to check for this.

                // in rare case scenarios, a pot can be split based on the game params
                // here, an array shall be used. check kicker_split, if true, add two same hands in
                // the array Add the kicker hand first into the array, before the other...that's if
                // `game_params.kicker_split`
                // is true, if not, add only the kicker hand to the Array. For more than two
                // kickers, arrange the array accordingly. might be implemented by someone else.
                // here, hands have been changed, right?
