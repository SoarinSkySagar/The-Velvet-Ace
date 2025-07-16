use poker::models::player::{Player, PlayerTrait};
use poker::models::deck::{Deck, DeckTrait};
use poker::models::game::{Game, GameParams, GameMode};
use poker::models::base::GameErrors;
use poker::models::card::Card;
use starknet::ContractAddress;

#[generate_trait]
pub impl GameImpl of GameTrait {
    /// @Birdmannn
    fn init(ref self: Game, game_params: Option<GameParams>, id: u64) {
        // Set game parameters (either custom or default)
        // check the number of decks in game.
        let params = match game_params {
            Option::Some(params) => {
                // Validate custom params
                assert(params.max_no_of_players > 1, GameErrors::MIN_PLAYER);
                assert(params.big_blind > params.small_blind, GameErrors::INVALID_BLIND_PLAYER);
                params
            },
            Option::None => get_default_game_params(),
        };

        self.params = params;
    }

    fn is_initialized(self: @Game) -> bool {
        self.players.len() > 0
    }

    fn is_allowable(self: @Game) -> bool {
        *self.in_progress
            // check for cash game, only if round is not in progress
            && !*self.round_in_progress
            && *self.params.game_mode == GameMode::CashGame
            // Then check if game has a free spot. Crosscheck this len
            && *self.current_player_count < self.players.len()
    }

    fn append() {}
}


fn get_default_game_params() -> GameParams {
    GameParams {
        game_mode: Default::default(),
        ownable: Option::None,
        max_no_of_players: 5,
        small_blind: 10,
        big_blind: 20,
        no_of_decks: 1,
        kicker_split: true,
        min_amount_of_chips: 100,
        blind_spacing: 10,
        showdown_type: Default::default(),
    }
}
