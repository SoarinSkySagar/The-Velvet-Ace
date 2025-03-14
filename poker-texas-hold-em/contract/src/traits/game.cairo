use poker::models::player::Player;
use poker::models::deck::{Deck, DeckTrait};
use poker::models::game::{Game, GameParams, GameMode};
use poker::models::base::GameErrors;
use poker::models::card::Card;
use starknet::ContractAddress;

#[generate_trait]
pub impl GameImpl of GameTrait {
    /// @Birdmannn
    fn initialize_game(
        ref player: Player, game_params: Option<GameParams>, id: u64, deck_ids: Array<u64>,
    ) -> (Game, Array<Deck>) {
        // Set game parameters (either custom or default)
        // check the number of decks in game.
        let params = match game_params {
            Option::Some(params) => {
                // Validate custom params
                assert(params.max_no_of_players > 1, GameErrors::MIN_PLAYER);
                assert(params.big_blind > params.small_blind, GameErrors::INVALID_BLIND_PLAYER);
                params
            },
            Option::None => Self::get_default_game_params(),
        };

        // Prepare decks for the game
        let mut decks: Array<Deck> = array![];
        for deck_id in deck_ids.clone() {
            let mut deck: Deck = Default::default();
            deck.id = deck_id;
            deck.new_deck();
            deck.shuffle();
            decks.append(deck);
        };

        let mut players: Array<ContractAddress> = array![];
        let mut community_cards: Array<Card> = array![];

        // Ensure player has enough chips for the game
        assert(player.chips >= (params.big_blind * 20).into(), GameErrors::INSUFFICIENT_CHIP);

        // Set initial player as dealer
        player.is_dealer = true;

        // Lock player to this game
        player.locked = (true, id);

        // Add player to players array
        players.append(player.id);

        // Create game instance
        let game = Game {
            id,
            in_progress: false,
            has_ended: false,
            current_round: 0,
            round_in_progress: false,
            players,
            deck: deck_ids,
            next_player: Option::None,
            community_cards,
            pot: 0,
            params,
        };

        (game, decks)
    }

    fn get_default_game_params() -> GameParams {
        GameParams {
            game_mode: GameMode::CashGame,
            max_no_of_players: 5,
            small_blind: 10,
            big_blind: 20,
            no_of_decks: 1,
            kicker_split: true,
            min_amount_of_chips: 10,
            blind_spacing: 10,
        }
    }

    fn leave_game(ref player: Player) { // here, all player params should be re-initialized
    }
}
