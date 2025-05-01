use starknet::ContractAddress;
use super::card::{Card, Royals};
use poker::traits::handtrait::HandTrait;
use poker::utils::hand::evaluate_cards;

/// Created once and for all for every available player.
#[derive(Serde, Drop, Clone, Debug, PartialEq)]
#[dojo::model]
pub struct Hand {
    #[key]
    player: ContractAddress,
    cards: Array<Card>,
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
/// UNDEFINED: No card is present.
#[derive(Drop, Copy, Serde, PartialEq)]
pub enum HandRank {
    ROYAL_FLUSH,
    STRAIGHT_FLUSH,
    FOUR_OF_A_KIND,
    FULL_HOUSE,
    FLUSH,
    STRAIGHT,
    THREE_OF_A_KIND,
    TWO_PAIR,
    ONE_PAIR,
    HIGH_CARD,
    UNDEFINED,
}

impl HandRankU16 of Into<HandRank, u16> {
    #[inline(always)]
    fn into(self: HandRank) -> u16 {
        match self {
            HandRank::UNDEFINED => 0,
            HandRank::HIGH_CARD => 1,
            HandRank::ONE_PAIR => 2,
            HandRank::TWO_PAIR => 3,
            HandRank::THREE_OF_A_KIND => 4,
            HandRank::STRAIGHT => 5,
            HandRank::FLUSH => 6,
            HandRank::FULL_HOUSE => 7,
            HandRank::FOUR_OF_A_KIND => 8,
            HandRank::STRAIGHT_FLUSH => 9,
            HandRank::ROYAL_FLUSH => 10,
        }
    }
}

impl HandRankByteArray of Into<HandRank, ByteArray> {
    #[inline(always)]
    fn into(self: HandRank) -> ByteArray {
        match self {
            HandRank::UNDEFINED => "UNDEFINED",
            HandRank::HIGH_CARD => "HIGH CARD",
            HandRank::ONE_PAIR => "ONE PAIR",
            HandRank::TWO_PAIR => "TWO PAIR",
            HandRank::THREE_OF_A_KIND => "THREE OF A KIND",
            HandRank::STRAIGHT => "STRAIGHT",
            HandRank::FLUSH => "FLUSH",
            HandRank::FULL_HOUSE => "FULL HOUSE",
            HandRank::FOUR_OF_A_KIND => "FOUR OF A KIND",
            HandRank::STRAIGHT_FLUSH => "STRAIGHT FLUSH",
            HandRank::ROYAL_FLUSH => "ROYAL FLUSH",
        }
    }
}

impl U16HandRank of Into<u16, HandRank> {
    #[inline(always)]
    fn into(self: u16) -> HandRank {
        match self {
            0 => HandRank::UNDEFINED,
            1 => HandRank::HIGH_CARD,
            2 => HandRank::ONE_PAIR,
            3 => HandRank::TWO_PAIR,
            4 => HandRank::THREE_OF_A_KIND,
            5 => HandRank::STRAIGHT,
            6 => HandRank::FLUSH,
            7 => HandRank::FULL_HOUSE,
            8 => HandRank::FOUR_OF_A_KIND,
            9 => HandRank::STRAIGHT_FLUSH,
            10 => HandRank::ROYAL_FLUSH,
            _ => HandRank::UNDEFINED,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{Hand, HandRank, Card, ContractAddress, Royals};
    use starknet::contract_address_const;
    use poker::utils::hand::{extract_kicker};
    // use crate::models::card::Suits;

    // convenience constructor for cards
    fn c(value: u16, suit: u8) -> Card {
        Card { value, suit }
    }

    // build a 5‐card Hand
    fn mk_hand(player: ContractAddress, cards: Array<Card>) -> Hand {
        assert(cards.len() == 5, 'Cards must be exactly 5');
        Hand { player, cards }
    }

    #[test]
    fn test_high_card_single_winner() {
        let player1 = contract_address_const::<'PLAYER1'>();
        let player2 = contract_address_const::<'PLAYER2'>();

        // h1: A♠,K♠,Q♠,J♠,10♠  (ace high)
        let card1 = array![c(14, 0), c(13, 0), c(12, 0), c(11, 0), c(10, 0)];
        // h2: K♥,Q♥,J♥,10♥,9♥  (king high)
        let card2 = array![c(13, 1), c(12, 1), c(11, 1), c(10, 1), c(9, 1)];

        let h1 = mk_hand(player1, card1);
        let h2 = mk_hand(player2, card2);

        let (winners, kicker) = extract_kicker(array![h1.clone(), h2], HandRank::HIGH_CARD.into());
        assert(winners.len() == 1, 'There should be only 1 winner');
        assert(winners.at(0).player == @h1.player, 'Wrong winner');
        // kicker must be the winner’s full 5 cards
        assert(kicker == h1.cards, 'kicker must be winner cards');
    }
}