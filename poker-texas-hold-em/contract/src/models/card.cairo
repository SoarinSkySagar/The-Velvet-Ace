use core::num::traits::Zero;
use core::poseidon::PoseidonTrait;
use core::hash::{HashStateTrait, HashStateExTrait};

#[derive(Copy, Drop, Serde, Default, Debug, Introspect, PartialEq, Hash)]
pub struct Card {
    suit: u8,
    value: u16,
}

pub const DEFAULT_NO_OF_CARDS: u8 = 52;

pub mod Royals {
    pub const ACE: u16 = 1;
    pub const JACK: u16 = 11;
    pub const QUEEN: u16 = 12;
    pub const KING: u16 = 13;
}
// IMPLEMENT A CARD TRAIT HERE, REMOVES A CARD BY SETTING THE SUIT AND VALUE TO ZERO OR SOMETHING

#[generate_trait]
pub impl CardImpl of CardTrait {
    fn get_suit(self: @Card) -> ByteArray {
        if *self.value == 0 {
            return "JOKER";
        }

        match *self.suit {
            0 => "UNKNOWN",
            1 => "SPADES",
            2 => "CLUBS",
            3 => "DIAMONDS",
            4 => "HEARTS",
            _ => "UNKNOWN",
        }
    }

    fn to_byte_array(self: @Card) -> ByteArray {
        let mut str: ByteArray = "";
        let value = *self.value;
        if value == 0 {
            return "JOKER";
        }

        if value > 1 && value < 11 {
            let val = @value;
            str.append(@format!("{val}"))
        } else if value == 1 {
            str.append(@"ACE");
        } else if (value >= 11 && value <= 13) {
            if value == 11 {
                str.append(@"JACK");
            } else if value == 12 {
                str.append(@"QUEEN");
            } else if value == 13 {
                str.append(@"KING");
            }
        } else {
            return "UNKNOWN";
        }

        str.append(@format!(" of {}", self.get_suit()));
        str
    }

    fn resolve(ref self: Card) {
        self.suit = 0;
        self.value = 0;
    }

    fn is_valid(self: @Card) -> bool {
        self.value.is_non_zero()
    }

    fn hash(ref self: Card, salt: Array<felt252>) -> felt252 {
        // static 3 for now. Might be dynamic later.
        assert(salt.len() == 3, 'SALT IS EMPTY');
        let mut serialized_data: Array<felt252> = array![];
        self.serialize(ref serialized_data);
        let hash = PoseidonTrait::new()
            .update_with(self)
            .update_with(*salt.at(1))
            .update_with(*salt.at(0))
            .update_with(*salt.at(2))
            .finalize();
        hash
    }
}
// Should implement into?

// SHOULD BE ADJUSTED BASED ON CARD IMAGE
// H, C, S, D
pub mod Suits {
    pub const SPADES: u8 = 1;
    pub const CLUBS: u8 = 2;
    pub const DIAMONDS: u8 = 3;
    pub const HEARTS: u8 = 4;
}

#[cfg(test)]
mod tests {
    use super::{Card, CardTrait, Suits, Royals};

    #[test]
    fn test_card_is_valid() {
        let card: Card = Default::default();
        assert(!card.is_valid(), 'CARD SHOULD NOT BE VALID');
    }

    #[test]
    fn test_card_trait() {
        let mut card = Card { suit: Suits::SPADES, value: Royals::ACE };

        let card_desc: ByteArray = card.to_byte_array();
        let desc_ref: ByteArray = "ACE of SPADES";
        assert(card.is_valid(), 'INVALID CARD');
        assert(card_desc == desc_ref, 'INVALID CARD CONVERSION');
        card.resolve();
        assert(!card.is_valid(), 'SHOULD NOT BE VALID');

        card.value = 0;
        let joker: ByteArray = card.to_byte_array();
        assert(joker == "JOKER", 'CARD NOT JOKER');

        card.suit = Suits::HEARTS;
        card.value = 5;
        let card_desc = card.to_byte_array();
        let desc_ref: ByteArray = "5 of HEARTS";
        assert(card_desc == desc_ref, 'NUMBER CONVERSION FAILED');
    }
}
