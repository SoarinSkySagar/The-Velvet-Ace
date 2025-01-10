use starknet::{ContractAddress};

#[derive(Copy, Drop, Serde, Introspect, PartialEq)]
pub struct Card {
    suit: u8,
    value: u16
}

pub const DEFAULT_NO_OF_CARDS: u8 = 52;

/// CashGame. same as the `true` value for the Tournament. 
/// Tournament. for Buying back-in after a certain period of time (can be removed),
/// false for Elimination when chips are out. 
#[derive(Copy, Drop, Serde, Introspect, PartialEq)]
pub enum GameMode {
    CashGame,
    Tournament: bool,
}

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Game {
    #[key]
    id: felt252,
    in_progress: bool,
    has_ended: bool,
    game_format: 
    players: Array<Player>,
    deck: Deck,
    next_player: Player,
    community_cards: Array<Card>,
    pot: u256
}

pub mod Suits {
    pub const SPADES: u8 = 0;
    pub const HEARTS: u8 = 1;
    pub const DIAMONDS: u8 = 2;
    pub const CLUBS: u8 = 3;
}

#[derive(Serde, Drop, Introspect, PartialEq)]
#[dojo::model]
pub struct Deck {
    #[key]
    game_id: felt252,
    cards: Array<Card>,
}

#[derive(Serde, Drop, Introspect)]
#[dojo::model]
pub struct Hand {
    #[key]
    player: ContractAddress,
    cards: Array<Card>
}

// the locked variable takes in a tuple of (is_locked, game_id) if the player is already
// locked to a session.
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Player {
    #[key]
    id: ContractAddress,
    hand: Option<Hand>,
    chips: u128,
    current_bet: u64,
    total_rounds: u64,
    locked: (bool, u64)
}

pub mod Royals {
    pub const ACE: u16 = 1;
    pub const JACK: u16 = 11;
    pub const QUEEN: u16 = 12;
    pub const KING: u16 = 13;
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
#[dojo::model]
pub struct GameId {
    #[key]
    pub id: felt252,
    pub nonce: u64,
}

/// This is the hand ranks of player hand cards plus part of the community cards to make it 5 in
/// total
/// ROYAL_FLUSH: Ace, King, Queen, Jack and 10, all of the same suit.
/// STRAIGHT_FLUSH: Five cards in a row, all of the same suit.
/// FOUR_OF_A_KIND: Four cards of the same rank (or value as in the model)
/// FULL_HOUSE: Three cards of one rank (value) and two cards of another rank (value)
/// FLUSH: Five cards of the same suit
/// STRAIGHT: Five cards in a row, but not of the same suit
/// THREE_OF_A_KIND: Three cards of the same rank.
/// TWO_PAIR: Two cards of one rank, and two cards of another rank.
/// ONE_PAIR: Two cards of the same rank.
/// HIGH_CARD: None of the above.
pub mod HandRank {
    pub const ROYAL_FLUSH: u16 = 10; 
    pub const STRAIGHT_FLUSH: u16 = 9;
    pub const FOUR_OF_A_KIND: u16 = 8;
    pub const FULL_HOUSE: u16 = 7;
    pub const FLUSH: u16 = 6; 
    pub const STRAIGHT: u16 = 5;
    pub const THREE_OF_A_KIND: u16 = 4; 
    pub const TWO_PAIR: u16 = 3; 
    pub const ONE_PAIR: u16 = 2; 
    pub const HIGH_CARD: u16 = 1;
}

#[generate_trait]
impl HandImpl of HandTrait {
    /// This function will return the hand rank of the player's hand
    /// this will compare the cards on the player's hand with the community cards
    fn hand_rank(player: @Player, community_cards: @Array<Card>) -> u16 {
        0
    }

    /// This function will compare the hands of all the players and return the winning hand.
    fn compare_hands(players: @Array<Player>, community_cards: @Array<Card>) -> Player {
        
    }
    
    fn new_hand(player: ContractAddress) -> Hand {
        Hand { player, cards: array![] }
    }

    fn remove_card(position: u8, ref hand: Hand) {
        // ensure card is removed.
    }

    fn add_card(card: Card, ref hand: Hand) {
        // ensure card is added.
    }
}

#[generate_trait]
impl GameImpl of GameTrait {
    fn initialize_game(player: Option<Player>) -> Game {
        assert!(player.is_some(), "Player is required to initialize the game");
    }

    fn leave_game(player)
}

#[generate_trait]
impl DeckImpl of DeckTrait {
    fn new_deck(game_id: felt252) -> Deck {
        let deck: Array<Card> = ArrayTrait::new(52); // init 52 cards
    }

    fn shuffle(ref deck: Deck) {

    }
}

pub mod GameErrors {
    pub const GAME_NOT_INITIALIZED: felt252 = 'GAME NOT INITIALIZED';
    pub const GAME_ALREADY_STARTED: felt252 = 'GAME ALREADY STARTED';
    pub const GAME_ALREADY_ENDED: felt252 = 'GAME ALREADY ENDED';
    pub const PLAYER_NOT_IN_GAME: felt252 = 'PLAYER NOT IN GAME';
    pub const PLAYER_ALREADY_IN_GAME: felt252 = 'PLAYER ALREADY IN GAME';
}

// assert after shuffling, that all cards remain distinct, and rhe deck is still 52 cards
// #[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug)]

