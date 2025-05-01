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

    #[test]
    fn test_high_card_tie() {
        let player1 = contract_address_const::<'PLAYER1'>();
        let player2 = contract_address_const::<'PLAYER2'>();

        // both hands identical → tie, no kicker
        let cards = array![c(14,0), c(10,1), c(8,2), c(4,3), c(2,0)];
        let h1 = mk_hand(player1, cards.clone());
        let h2 = mk_hand(player2, cards);
        let (winners, kicker) =
            extract_kicker(array![h1.clone(), h2.clone()], HandRank::HIGH_CARD.into());

        assert(winners.len() == 2, 'Both hands should tie');
        assert(kicker.len() == 0, 'Tie means no kicker returned');
    }

    #[test]
    fn test_one_pair_kicker_ordering() {
        let player1 = contract_address_const::<'PLAYER1'>();
        let player2 = contract_address_const::<'PLAYER2'>();

        // Both have pair of 9s:
        // h1 kickers = [A, K, 3]
        let h1 = mk_hand(player1, array![
            c(9,0), c(9,1), c(14,0), c(13,1), c(3,2),
        ]);
        // h2 kickers = [A, Q, 5] → Q < K, so h1 should win
        let h2 = mk_hand(player2, array![
            c(9,2), c(9,3), c(14,1), c(12,0), c(5,1),
        ]);

        let (winners, kicker) =
            extract_kicker(array![h1.clone(), h2.clone()], HandRank::ONE_PAIR.into());

        assert(winners.len() == 1, 'Only one hand should win');
        assert(winners.at(0).player == @h1.player, 'Wrong hand won the tie');
        assert(kicker == h1.cards, 'Winner cards must be returned');
    }

    #[test]
    fn test_straight_always_tie() {
        let player1 = contract_address_const::<'PLAYER1'>();
        let player2 = contract_address_const::<'PLAYER2'>();

        // h1: 10-J-Q-K-A, h2: 9-10-J-Q-K
        let h1 = mk_hand(player1, array![
            c(10,0), c(11,0), c(12,0), c(13,0), c(14,0),
        ]);
        let h2 = mk_hand(player2, array![
            c(9,1), c(10,1), c(11,1), c(12,1), c(13,1),
        ]);

        let (winners, kicker) =
            extract_kicker(array![h1.clone(), h2.clone()], HandRank::STRAIGHT.into());

        assert(winners.len() == 2, 'All straights should tie');
        assert(kicker.len() == 0, 'Straights tie, no kicker');
    }

    #[test]
    #[should_panic]
    fn test_empty_hands_panics() {
        // empty input should hit the first assert and panic
        let _: (Array<Hand>, Array<Card>) =
            extract_kicker(array![], HandRank::HIGH_CARD.into());
    }

    #[test]
    #[should_panic]
    fn test_undefined_rank_panics() {
        let player = contract_address_const::<'PLAYER1'>();
        let h = mk_hand(player, array![
            c(2,0), c(3,0), c(4,0), c(5,0), c(6,0),
        ]);
        // 0 maps to UNDEFINED → should panic
        let _: (Array<Hand>, Array<Card>) =
            extract_kicker(array![h], 0);
    }

    #[test]
    fn test_high_card_different_high() {
        let p1 = contract_address_const::<'P1'>();
        let p2 = contract_address_const::<'P2'>();

        // p1: K♣ Q♦ J♠ 10♣ 9♦  (King high)
        let h1 = mk_hand(p1, array![
            c(13, 0), c(12, 1), c(11, 2), c(10, 0), c(9,  1)
        ]);
        // p2: A♥ 5♣ 4♦ 3♠ 2♣   (Ace high)
        let h2 = mk_hand(p2, array![
            c(14, 3), c(5,  0), c(4,  1), c(3,  2), c(2,  0)
        ]);

        let (winners, kicker) =
            extract_kicker(array![h1.clone(), h2.clone()], HandRank::HIGH_CARD.into());
        assert(winners.len() == 1, 'Expected one winner');
        assert(winners.at(0).player == @h2.player, 'Ace-high should win');
        assert(kicker == h2.cards, 'Kicker must be winner cards');
    }

    #[test]
    fn test_high_card_same_high_different_second() {
        let p1 = contract_address_const::<'P1'>();
        let p2 = contract_address_const::<'P2'>();

        // both Ace high…
        // p1 second-highest = Q
        let h1 = mk_hand(p1, array![
            c(14, 0), c(12, 1), c(10, 2), c(8,  0), c(6,  1)
        ]);
        // p2 second-highest = K
        let h2 = mk_hand(p2, array![
            c(14, 3), c(13, 1), c(9,  0), c(7,  2), c(5,  3)
        ]);

        let (winners, kicker) =
            extract_kicker(array![h1.clone(), h2.clone()], HandRank::HIGH_CARD.into());
        assert(winners.len() == 1, 'Expected one winner');
        assert(winners.at(0).player == @h2.player, 'Higher second-card should win');
        assert(kicker == h2.cards, 'Kicker must be winner cards');
    }

    #[test]
    fn test_one_pair_different_pairs() {
        let p1 = contract_address_const::<'P1'>();
        let p2 = contract_address_const::<'P2'>();

        // p1: pair of Jacks
        let h1 = mk_hand(p1, array![
            c(11,0), c(11,1), c(9,0), c(8,1), c(7,2)
        ]);
        // p2: pair of Tens
        let h2 = mk_hand(p2, array![
            c(10,2), c(10,3), c(14,0), c(2,1), c(3,2)
        ]);

        let (winners, kicker) =
            extract_kicker(array![h1.clone(), h2.clone()], HandRank::ONE_PAIR.into());
        assert(winners.len() == 1, 'Higher pair wins');
        assert(winners.at(0).player == @h1.player, 'Wrong winner on different pairs');
        assert(kicker == h1.cards, 'Kicker must be winner cards');
    }
}