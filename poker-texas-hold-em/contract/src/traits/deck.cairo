use core::ops::IndexView;
use starknet::{ContractAddress, contract_address_const};
use core::poseidon::{PoseidonTrait};
use core::hash::{HashStateTrait, HashStateExTrait};
use poker::models::deck::Deck;
use poker::models::card::Card;

// pub const DEFAULT_DECK_LENGTH: u32 = 52; // move this up up

fn generate_random(span: u32) -> u32 {
    let seed = starknet::get_block_timestamp();
    let hash: u256 = PoseidonTrait::new().update_with(seed).finalize().into();

    (hash % span.into()).try_into().unwrap()
}

#[generate_trait]
pub impl DeckImpl of DeckTrait {
    fn new_deck(ref self: Deck) {
        let mut cards: Array<Card> = array![];
        for suit in 0_u8..4_u8 {
            for value in 1_u16..14_u16 {
                let card: Card = Card { suit, value };
                cards.append(card);
            };
        };

        self.cards = cards;
    }

    fn shuffle(ref self: Deck) {
        // Clone the cards
        let original_cards: Array<Card> = self.cards.clone();
        let length = original_cards.len();

        // Handle edge case
        if length <= 1 {
            return;
        }

        // Create a new array for shuffled cards
        let mut shuffled_cards: Array<Card> = array![];

        // Create an array of available indices
        let mut remaining_indices: Array<u32> = array![];
        let mut i: u32 = 0;
        while i < length {
            remaining_indices.append(i);
            i += 1;
        };

        // Select random cards until we've used all indices
        while remaining_indices.len() > 0 {
            // Get random position within remaining indices
            let random_pos = generate_random(remaining_indices.len());
            let card_index = *remaining_indices.at(random_pos);

            // Add the selected card to our shuffled deck
            shuffled_cards.append(*original_cards.at(card_index));

            // Remove the used index by rebuilding the array without it
            let mut new_remaining = array![];
            let mut j: u32 = 0;
            while j < remaining_indices.len() {
                if j != random_pos {
                    new_remaining.append(*remaining_indices.at(j));
                }
                j += 1;
            };
            remaining_indices = new_remaining;
        };

        // Update the deck
        self.cards = shuffled_cards;
    }

    fn append(ref self: Deck, card: Card) {
        self.cards.append(card);
    }

    fn deal_card(ref self: Deck) -> Card {
        self.cards.pop_front().unwrap()
    }

    fn is_shuffled(ref self: Deck) -> bool {
        let length = self.cards.len();
        if length <= 1 {
            return false;
        }

        // Create reference ordered deck
        let mut ordered_deck: Array<Card> = array![];
        for suit in 0_u8..4_u8 {
            for value in 1_u16..14_u16 {
                let card: Card = Card { suit, value };
                ordered_deck.append(card);
            };
        };

        // Compare positions
        let mut diff_count: u32 = 0;
        let mut i: u32 = 0;
        while i != length {
            if *self.cards.at(i) != *ordered_deck.at(i) {
                diff_count += 1;
            }
            i += 1;
        };

        // If at least half of the cards moved → shuffled
        diff_count * 2 >= length
    }

    fn is_cards_distinct(ref self: Deck) -> bool {
        let length = self.cards.len();
        if length != 52 {
            return false;
        }

        // Use an array to track seen cards
        let mut seen_cards: Array<u64> = array![];
        let mut i: u32 = 0;
        let mut distinct = true;

        while i != length {
            let card: Card = *self.cards.at(i);
            let key: u64 = (card.suit.into() * 100) + card.value.into();

            // Check if key already exists
            let mut j: u32 = 0;
            while j != seen_cards.len() {
                if *seen_cards.at(j) == key {
                    // Cannot return here, so we break logic by setting flag
                    distinct = false;
                    break;
                }
                j += 1;
            };

            seen_cards.append(key);
            i += 1;
        };

        distinct
    }
}
// assert after shuffling, that all cards remain distinct, and the deck is still 52 cards
// #[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug)]


