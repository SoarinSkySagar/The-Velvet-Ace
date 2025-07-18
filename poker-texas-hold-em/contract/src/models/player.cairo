use starknet::ContractAddress;
use core::num::traits::Zero;
use super::base::GameErrors;
use super::game::{Game, GameTrait, GameMode};
use poker::traits::player::PlayerTrait;

// the locked variable takes in a tuple of (is_locked, game_id) if the player is already
// locked to a session.
// Hand should be a reference.

// FOR NOW, NO PLAYER CAN HAVE MORE THAN ONE HAND.
// Go to all functions that use player as a parameter, and remove the snapshot
#[derive(Copy, Drop, Serde, Debug, Default, PartialEq, Hash)]
#[dojo::model]
pub struct Player {
    #[key]
    id: ContractAddress,
    alias: felt252,
    chips: u256,
    current_bet: u256,
    total_rounds: u64,
    locked: (bool, u64),
    is_dealer: bool,
    in_round: bool,
    out: (u64, u64),
    pub_key: felt252,
    locked_chips: u256,
    is_blacklisted: bool, // TODO: should be integrated in the future.
    eligible_pots: u8,
}

impl ContractAddressDefault of Default<ContractAddress> {
    #[inline(always)]
    fn default() -> ContractAddress {
        Zero::zero()
    }
}

/// TESTS ON PLAYER MODEL
#[cfg(test)]
mod tests {}
