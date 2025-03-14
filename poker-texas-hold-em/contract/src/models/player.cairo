use starknet::ContractAddress;

// the locked variable takes in a tuple of (is_locked, game_id) if the player is already
// locked to a session.
// Hand should be a reference.

// FOR NOW, NO PLAYER CAN HAVE MORE THAN ONE HAND.
// Go to all funcrtions that use player as a parameter, and remove the snapshot
#[derive(Drop, Serde, Clone, Copy, Debug)]
#[dojo::model]
pub struct Player {
    #[key]
    id: ContractAddress,
    // #[key]
    // alias: ByteArray,
    chips: u256,
    current_bet: u256,
    total_rounds: u64,
    locked: (bool, u64),
    is_dealer: bool,
    in_round: bool,
}
/// Write struct for player stats
/// Include an alias, if necessary, and add it as key.


