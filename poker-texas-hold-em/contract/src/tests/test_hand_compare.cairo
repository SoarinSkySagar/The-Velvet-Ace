/// TODO

/// CHECK VALUES FOR KICKER_SPLIT EQUALS FALSE, ONLY WHEN `extract_kicker` HAS BEEN
/// IMPLEMENTED FOR KICKER_SPLIT EQUALS FALSE, winning_hands.len() == 1. USE TWO HANDS OF THE
/// SAME RANK
///
/// TODO: TEST COMPARE HANDS OF VARIOUS NUMBER OF HANDS.
/// // for the test
// assert that the array of kicking cards are present in the winning hands
// .. or make
//
#[cfg(test)]
mod tests {
    use crate::models::hand::{Hand, HandTrait, HandRank};
    use crate::models::card::{Suits, Royals, Card};
    use starknet::{contract_address_const, ContractAddress};
    use core::num::traits::Zero;
}
