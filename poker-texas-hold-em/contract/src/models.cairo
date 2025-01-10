use starknet::{ContractAddress};

#[derive(Copy, Drop, Serde, Introspect)]
pub struct Card {
    suit: u8,
    value: u16
}

pub mod Suits {
    pub const SPADES: u8 = 0;
    pub const HEARTS: u8 = 1;
    pub const DIAMONDS: u8 = 2;
    pub const CLUBS: u8 = 3;
}

#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct Deck {
    #[key]
    game_id: felt252,
    cards: Array<Card>,

}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Hand {
    #[key]
    player: ContractAddress,
    cards: Array<Card>
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Player {
    #[key]
    id: ContractAddress,
    hand: Hand,
    chips: u16
}

pub mod Royals {
    pub const ACE: u16 = 1;
    pub const JACK: u16 = 11;
    pub const QUEEN: u16 = 12;
    pub const KING: u16 = 13;
}

/// This is the hand ranks of player hand cards plus part of the community cards to make it 5 in total
pub mod HandRank {
    pub const ROYAL_FLUSH: u16 = 10;        // Ace, King, Queen, Jack and 10, all of the samae suit.
    pub const STRAIGHT_FLUSH: u16 = 9;      // Five cards in a row, all of the same suit.
    pub const FOUR_OF_A_KIND: u16 = 8;      // Four cards of the same rank (or value as in the model)
    pub const FULL_HOUSE: u16 = 7;          // Three cards of one rank (value) and two cards of another rank (value)
    pub const FLUSH: u16 = 6;               // Five cards of the same suit
    pub const STRAIGHT: u16 = 5;            // Five cards in a row, but not of the same suit
    pub const THREE_OF_A_KIND: u16 = 4;     // Three cards of the same rank.
    pub const TWO_PAIR: u16 = 3;            // Two cards of one rank, and two cards of another rank.
    pub const ONE_PAIR: u16 = 2;            // Two cards of the same rank.
    pub const HIGH_CARD: u16 = 1;           // None of the above.
}

/// This function will return the hand rank of the player's hand
/// In texas hold 'em, 
fn get_player_hand_rank(hand: @Hand, community_cards: @Array<Card>, player: @Player) -> u16 {
    
}