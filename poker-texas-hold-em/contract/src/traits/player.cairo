use poker::models::player::Player;
use poker::models::game::{Game, ShowdownType};
use poker::models::base::GameErrors;
use super::game::GameTrait;

#[generate_trait]
pub impl PlayerImpl of PlayerTrait {
    fn exit(ref self: Player, ref game: Game, out: bool) {
        let (is_locked, id) = self.locked;
        assert(is_locked, 'CANNOT EXIT, PLAYER NOT LOCKED');
        assert(game.current_player_count != 0, 'GAME PLAYER COUNT SUB'); // sub overflow guard
        if out {
            // check game id
            assert(id == game.id, 'BAD REQUEST');
            self.out = (game.id, game.reshuffled);
        } else {
            self.out = (0, 0);
        }

        self.current_bet = 0;
        self.is_dealer = false;
        self.in_round = false;
        self.locked = (false, 0);

        game.current_player_count -= 1;
    }

    fn enter(ref self: Player, ref game: Game) -> bool {
        let (is_locked, _) = self.locked;
        assert(!is_locked, GameErrors::PLAYER_ALREADY_LOCKED);
        // Ensure player has enough chips for the game
        assert(game.is_initialized(), GameErrors::GAME_NOT_INITIALIZED);
        assert(!game.has_ended, GameErrors::GAME_ALREADY_ENDED);
        assert(game.is_allowable(), GameErrors::ENTRY_DISALLOWED);
        assert(self.refresh_stake(ref game), GameErrors::INSUFFICIENT_CHIP);

        if (game.id, game.reshuffled) != self.out {
            // append. Player doesn't exist in the game
            game.players.append(self.id);
        } // should work.
        self.locked = (true, game.id);
        self.in_round = true;
        game.current_player_count += 1;

        game.current_player_count == game.params.max_no_of_players
    }

    fn refresh_stake(ref self: Player, ref game: Game) -> bool {
        if let ShowdownType::Splitted(stake) = game.params.showdown_type {
            if stake >= self.chips {
                return false;
            }
            let amt = self.chips - stake;
            if game.params.min_amount_of_chips >= amt {
                return false;
            }
            self.chips -= stake;
            self.locked_chips += stake;
            return true;
        }
        true
    }

    fn extract_current_game_id(self: @Player) -> @u64 {
        let (is_locked, game_id) = self.locked;
        assert(*is_locked, GameErrors::PLAYER_NOT_IN_GAME);
        assert(*game_id != 0, GameErrors::PLAYER_NOT_IN_GAME);

        game_id
    }

    fn is_in_game(self: @Player, game_id: u64) -> bool {
        let (is_locked, id) = self.locked;
        *is_locked && id == @game_id
    }
}
