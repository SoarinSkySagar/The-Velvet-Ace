/// A logic that verifies that all cards are shuffled and distinct from one another

use crate::models::card::{Card, CardTrait};
use crate::models::deck::{Deck, DeckTrait};
use crate::models::hand::Hand;
use super::game::MerkleTrait;

/// @Birdmannn
/// Verifies the deck in sync with the whole game.
///
/// Implements lazy verification
/// This function ensures that the whole gameplay was indeed performed accurately, after the game
/// round has been concluded.
///
/// # Arguments
/// * `community_cards` - An array of community cards dealt in the round
/// * `hands` - An array of player hands submitted during showdown
/// * `proofs` - Merkle proofs of player hands for verification
/// * `deck` - The current deck used in playing the game
/// * `game_root` - The merkle root of the deck in the game.
/// * `dealt_cards_root` - The merkle root of the dealt cards in the game
/// * `salt` - The salt used for cards commitment
///
/// # Returns
/// bool - if the game was valid.
/// no panic
/// TODO: IN THE FUTURE, PLEASE USE OPENZEPPELIN FOR MERKLE TREE VERIFICATION
pub fn verify_game(
    community_cards: Array<Card>,
    hands: Array<Hand>,
    mut game_proofs: Array<Array<felt252>>,
    mut dealt_cards_proofs: Array<Array<felt252>>,
    mut deck: Deck,
    game_root: felt252,
    dealt_cards_root: felt252,
    game_salt: Array<felt252>,
    dealt_card_salt: Array<felt252>,
) -> bool {
    assert(community_cards.len() == 5, 'COMMUNITY CARDS != 5');
    assert(hands.len() == game_proofs.len() / 2, 'PROOFS AND HANDS LEN MISMATCH');
    assert(hands.len() == dealt_cards_proofs.len() / 2, 'PROOFS AND HANDS LEN MISMATCH.');
    // rebuild deck, and compute the root.
    let deck_cards = deck.cards;
    deck.cards = array![];
    // append dealt hands first.
    for i in 0..hands.len() {
        let hand = hands.get(i).unwrap();
        for j in 0..hand.cards.len() {
            deck.append(*hand.cards.at(j));
        };
    };

    // append community cards next.
    for i in 0..community_cards.len() {
        deck.append(*community_cards.at(i));
    };

    // then append the remaining deck cards
    for card in deck_cards {
        deck.append(card);
    };

    if !deck.is_shuffled() || !deck.is_cards_distinct() {
        return false;
    }

    // SWITCH TO OPENZEPPELIN IN THE FUTURE
    let mut merkle_state = MerkleTrait::new(deck.cards, game_salt.clone());
    if merkle_state.get_root() != game_root {
        return false;
    }

    // verify these hands were in the deck
    let mut card_index = 0;
    let mut deck_verified = false;
    let mut card_verified = false;
    for i in 0..hands.len() {
        let hand = hands.get(i).unwrap();
        for mut card in hand.cards.clone() {
            // it should take two at a time for the array of proofs
            deck_verified =
                verify(ref game_proofs, game_root, ref card, game_salt.clone(), card_index);
            card_verified =
                verify(
                    ref dealt_cards_proofs,
                    dealt_cards_root,
                    ref card,
                    dealt_card_salt.clone(),
                    card_index,
                );
            if !deck_verified || card_verified {
                break;
            }
        };
        card_index += 1;
    };

    deck_verified && card_verified
}

fn verify(
    ref proofs: Array<Array<felt252>>,
    root: felt252,
    ref card: Card,
    salt: Array<felt252>,
    index: usize,
) -> bool {
    MerkleTrait::verify_v2(proofs.pop_front().unwrap(), root, card.hash(salt), index)
}

#[cfg(test)]
mod Tests {
    use super::verify_game;
    use crate::models::game::Game;
    use crate::models::deck::{Deck, DeckTrait};
    use crate::models::card::Card;

    #[test]
    fn test_verify_game_success() {}

    #[test]
    fn test_verify_game_on_wrong_proof() {}

    #[test]
    fn test_verify_game_on_wrong_data() { // this should be a fuzz test, by the way... if necessary.
    }
}

