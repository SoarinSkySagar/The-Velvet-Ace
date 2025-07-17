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
#[derive(Copy, Drop, Serde, Debug, PartialEq, Hash)]
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
}
/// Write struct for player stats
/// Include an alias, if necessary, and add it as key.
#[derive(Copy, Drop, Serde, Debug, PartialEq, Hash)]
#[dojo::model]
pub struct PlayerStats {
    #[key]
    alias: felt252,
    games_played: u64,
    games_won: u64,
    hands_played: u64,
    hands_won: u64,
    total_chips_won: u256,
    total_chips_lost: u256,
    biggest_win: u256,
}
impl PlayerDefault of Default<Player> {
    #[inline(always)]
    fn default() -> Player {
        Player {
            id: Zero::zero(),
            alias: '',
            chips: 0,
            current_bet: 0,
            total_rounds: 0,
            locked: (false, 0),
            is_dealer: false,
            in_round: false,
            out: (0, 0),
        }
    }
}

/// TESTS ON PLAYER MODEL
#[cfg(test)]
mod tests {}
