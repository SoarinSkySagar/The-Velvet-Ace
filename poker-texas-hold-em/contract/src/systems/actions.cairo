use poker::models::{Card, Hand, Deck, Suits, GameMode, GameParams};

/// TODO: Read the GameREADME.md file to understand the rules of coding this game.
/// TODO: What should happen when everyone leaves the game? Well, the pot should be
/// transferred to the last player. May be reconsidered.

/// Interface functions for each action of the smart contract
#[starknet::interface]
trait IActions<TContractState> {
    /// Initializes the game with a game format. Returns a unique game id.
    fn initialize_default_game(ref self: TContractState) -> u64;
    fn initialize_game_with_params(ref self: TContractState, game_settings: GameParams) -> u64;
    fn join_game(ref self: TContractState);
    fn leave_game(ref self: TContractState, game_id: u64);

    /// These functions must require that the caller is already in a game.
    /// When calling all_in, for other raises, create a separate pot.
    fn call(ref self: TContractState);
    fn fold(ref self: TContractState);
    fn raise(ref self: TContractState, no_of_chips: u256);
    fn all_in(ref self: TContractState);
    fn check(ref self: TContractState);
}

// pub struct GameParams {
//     game_mode: GameMode,
//     max_no_of_players: u8,
//     small_blind: u64,
//     big_blind: u64,
//     no_of_decks: u8,
//     
// }



// dojo decorator
#[dojo::contract]
pub mod actions {
    use starknet::{ContractAddress, get_caller_address};
    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::event::EventStorage;
    use poker::models::{GameId, GameMode};
    use poker::models::{GameT}

    pub const ID: felt252 = 'id';
    pub const MAX_NO_OF_CHIPS: u128 = 100000; /// for test, 1 chip = 10 strk.

    // fn initialize_default_game(self: @TContractState) -> u64;
    // fn initialize_game_with_params(self: @TContractState, game_settings: GameParams) -> u64;
    // fn join_game(self: @TContractState);
    // fn leave_game(self: @TContractState, game_id: u64);
    // fn call(self: @TContractState);
    // fn fold(self: @TContractState);
    // fn raise(self: @TContractState, no_of_chips: u256);
    // fn all_in(self: @TContractState);

    #[abi(embed_v0)]
    impl ActionsImpl of super::IActions<ContractState> {
        fn initialize_default_game(self: @ContractState) -> u64 {
            // Check if the player exists, if not, create a new player.
            // If caller exists, call the player_in_game function.
            // Check the game mode. each format should have different rules
            0
        }

        fn initialize_game_with_params(self: @TContractState, game_settings: GameParams) -> u64 {
            0
        }

        fn join_game(self: @TContractState) {

        }

        fn leave_game(self: @ContractState, game_id: u64) {
            // assert if the player exists
            // assert if the game exists
            // assert player.locked == true
            // Check if the player is in the game
            // Check if the player has enough chips to leave the game
        }

        fn call(self: @TContractState,)
    }
        

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        /// Use the default namespace "poker". This function is handy since the ByteArray
        /// can't be const.
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"poker")
        }

        fn generate_game_id(self: @ContractState) -> u64 {
            let mut world = self.world_default();
            let mut game_id: GameId = world.read_model(ID);
            let mut id = game_id.nonce + 1;
            game_id.nonce = id;
            world.write_model(@game_id);
            id
        }

        /// This function makes all assertions on if player is meant to call this function.
        fn before_play(self: @ContractState, caller: ContractAddress) {
            // Check the chips available in the player model
            // check if player is locked
        }

        /// This function performs all default actions immediately a player joins the game.
        /// May call the previous function.
        fn player_in_game(self: @ContractState, caller: ContractAddress) {
            // Check if player is already in the game
            // Check if player is locked (already in a game)
            // The above two checks seems similar, but they differ in the error messages they return.
            // Check if player has enough chips to join the game
        }

        fn after_play(self: @ContractState, caller: ContractAddress) {
            // check if player has more chips, prompt
        }
    }
}