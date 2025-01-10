use poker::models::{Card, Hand, Deck, Suits, GameMode};

/// TODO: Read the GameREADME.md file to understand the rules of coding this game.

/// Interface functions for each action of the smart contract
#[starknet::interface]
trait IActions<TContractState> {
    /// Initializes the game with a game format. Returns a unique game id.
    fn initialize_game(self: @TContractState, game_mode: GameMode, no_of_decks: u8) -> u64;
    fn join_game(self: @TContractState);
    fn leave_game(self: @TContractState, game_id: u64);
    fn call(self: @TContractState);
    fn fold(self: @TContractState);
    fn raise(self: @TContractState);
    fn all_in(self: @TContractState);
}



// dojo decorator
#[dojo::contract]
pub mod actions {
    use starknet::{ContractAddress, get_caller_address};
    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::event::EventStorage;
    use poker::models::{GameId, GameFormat};

    pub const ID: felt252 = 'id';
    pub const MAX_NO_OF_CHIPS: u128 = 100000; /// for test, 1 chip = 10 strk.

    #[derive(Copy, Drop, Serde, Debug)]
    #[dojo::event]
    pub struct Moved {
        #[key]
        pub player: ContractAddress,
        pub direction: Direction,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of super::IActions<ContractState> {
        fn initialize_game(self: @ContractState, game_mode: GameMode, no_of_decks: u8) -> u64 {
            // Check if the player exists, if not, create a new player.
            // If caller exists, call the player_in_game function.
            // Check the game mode. each format should have different rules
        }

        fn leave_game(self: @ContractState, game_id: u64) {
            // assert if the player exists
            // assert if the game exists
            // assert player.locked == true
            // Check if the player is in the game
            // Check if the player has enough chips to leave the game
        }
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