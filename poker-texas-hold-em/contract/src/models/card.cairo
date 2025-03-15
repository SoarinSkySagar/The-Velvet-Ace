use core::num::traits::Zero;

#[derive(Copy, Drop, Serde, Default, Debug, Introspect, PartialEq)]
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
        ""
    }

    fn get_value_byte_array(self: @Card) -> ByteArray {
        ""
    }

    fn resolve_card(ref self: Card) {}

    fn is_valid_card(self: @Card) -> bool {
        self.suit.is_non_zero() && self.value.is_non_zero()
    }
}
// Should implement into?

// SHOULD BE ADJUSTED BASED ON CARD IMAGE
// H, C, S, D
pub mod Suits {
    pub const SPADES: u8 = 0;
    pub const CLUBS: u8 = 1;
    pub const DIAMONDS: u8 = 2;
    pub const HEARTS: u8 = 3;
}

