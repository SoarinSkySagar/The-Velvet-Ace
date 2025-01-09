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

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Deck {
    #[key]
    game_id: felt252,
    cards: Array<Option<Card>>,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Hand {
    #[key]
    player: ContractAddress,
    cards: Array<Card>
}