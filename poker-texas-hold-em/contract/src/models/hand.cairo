use starknet::ContractAddress;
use super::card::Card;
use poker::traits::handtrait::HandTrait;

/// Created once and for all for every available player.
#[derive(Serde, Drop, Clone, Debug)]
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

    pub fn to_bytearray(self: u16) -> ByteArray {
        match self {
            0 => "UNDEFINED",
            1 => "HIGH CARD",
            2 => "ONE PAIR",
            3 => "TWO PAIR",
            4 => "THREE OF A KIND",
            5 => "STRAIGHT",
            6 => "FLUSH",
            7 => "FULL HOUSE",
            8 => "FOUR OF A KIND",
            9 => "STRAIGHT FLUSH",
            10 => "ROYAL FLUSH",
            _ => "UNDEFINED",
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{Card, Hand, HandTrait, HandRank};
    use crate::models::card::Suits;
    use starknet::{contract_address_const, ContractAddress};

    /// For check.
    #[test]
    fn test_rank_straight() {
        let player_cards: Array<Card> = array![
            Card { suit: Suits::CLUBS, value: 2 }, Card { suit: Suits::SPADES, value: 4 },
        ];

        let player: ContractAddress = contract_address_const::<'PLAYER'>();
        let player_hand: Hand = Hand { player, cards: player_cards };

        let community_cards = array![
            Card { suit: Suits::HEARTS, value: 5 },
            Card { suit: Suits::SPADES, value: 3 },
            Card { suit: Suits::SPADES, value: 12 },
            Card { suit: Suits::CLUBS, value: 6 },
            Card { suit: Suits::DIAMONDS, value: 13 },
        ];

        let (hand, hand_rank): (Hand, u16) = player_hand.rank(community_cards.clone());
        println!("Player1 Hand rank is: {}", hand_rank);
        assert(hand_rank == HandRank::STRAIGHT, 'NOT A STRAIGHT');
        println!("Player1 new Hand to bytearray is:\n{}", hand.to_bytearray());

        // feign a two pair
        let player2: ContractAddress = contract_address_const::<'PLAYER2'>();
        let player2_cards: Array<Card> = array![
            Card { suit: Suits::CLUBS, value: 5 }, Card { suit: Suits::SPADES, value: 6 },
        ];

        let player2_hand: Hand = Hand { player: player2, cards: player2_cards };

        let (hand, hand_rank): (Hand, u16) = player2_hand.rank(community_cards.clone());
        println!("Player2 Hand rank is: {}", hand_rank);
        assert(hand_rank == HandRank::TWO_PAIR, 'NOT A TWO PAIR');
        println!("Player2 new Hand to byte array is:\n{}", hand.to_bytearray());

        // NOTE: THIS IS WHEN THE VALUE OF KICKER_SPLIT IS FALSE.
        let (hands, hand_rank, kickers): (Span<Hand>, u16, Span<Card>) = HandTrait::compare_hands(
            array![player2_hand, player_hand], community_cards, Default::default(),
        );

        assert(kickers.len() == 0, 'KICKERS FOUND');
        assert(hands.len() == 1, 'INVALID HAND COUNT');
        assert(hand_rank == HandRank::STRAIGHT, 'INVALID RANK');

        println!("Hand rank to bytearray: {}", HandRank::to_bytearray(hand_rank));

        let winning_hand: @Hand = hands.at(0);
        assert(*winning_hand.player == player, 'INCORRECT WINNER');
    }
}
