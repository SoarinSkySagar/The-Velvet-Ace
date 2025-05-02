#[cfg(test)]
mod tests {
    use dojo::event::EventStorageTest;
    use dojo_cairo_test::WorldStorageTestTrait;
    use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
    use dojo::world::{WorldStorage, WorldStorageTrait};
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef,
    };
    use poker::models::game::{Game, GameTrait};
    use poker::models::player::{Player, PlayerTrait};
    use poker::traits::game::get_default_game_params;
    use poker::systems::interface::{IActionsDispatcher, IActionsDispatcherTrait};
    use poker::tests::setup::setup::{CoreContract, deploy_contracts};
    use starknet::ContractAddress;
    use starknet::testing::{set_account_contract_address, set_contract_address};

    fn PLAYER_1() -> ContractAddress {
        starknet::contract_address_const::<'PLAYER_1'>()
    }

    fn PLAYER_2() -> ContractAddress {
        starknet::contract_address_const::<'PLAYER_2'>()
    }

    // [Actions] - check() tests
    #[test]
    fn test_check_when_current_bet_zero_succeeds() {
        // [Setup]
        let contracts = array![CoreContract::Actions];
        let (mut world, systems) = deploy_contracts(contracts);
        mock_poker_game(ref world);

        // [Execute]
        // dub_zn turn's (PLAYER_1)
        // Set `current_bet` to zero
        let mut player_1: Player = world.read_model(PLAYER_1());
        player_1.current_bet = 0;
        world.write_model(@player_1);

        set_contract_address(player_1.id);
        systems.actions.check();

        // [Assert]
        let game: Game = world.read_model(1);
        assert!(game.current_bet == 1000, "check() - game.current_bet should be 1000");
        assert!(
            game.next_player == Option::Some(PLAYER_2()),
            "check() - game.next_player should be PLAYER_2()",
        );
    }

    #[test]
    #[should_panic(expected: ("You can't check while having an active bet.", 'ENTRYPOINT_FAILED'))]
    fn test_check_fails_when_current_bet_non_zero() {
        // [Setup]
        let contracts = array![CoreContract::Actions];
        let (mut world, systems) = deploy_contracts(contracts);
        mock_poker_game(ref world);

        // [Execute]
        // dub_zn turn's (PLAYER_1)
        set_contract_address(PLAYER_1());
        systems.actions.check();
    }

    #[test]
    #[should_panic(expected: ('Not player turn', 'ENTRYPOINT_FAILED'))]
    fn test_check_fails_when_not_players_turn() {
        // [Setup]
        let contracts = array![CoreContract::Actions];
        let (mut world, systems) = deploy_contracts(contracts);
        mock_poker_game(ref world);

        // [Execute]
        // Set Birdmannn turn's (PLAYER_2)
        set_contract_address(PLAYER_2());
        systems.actions.check();
    }

    // [Mocks]
    fn mock_poker_game(ref world: WorldStorage) {
        let game = Game {
            id: 1,
            in_progress: true,
            has_ended: false,
            current_round: 1,
            round_in_progress: true,
            current_player_count: 2,
            players: array![PLAYER_1(), PLAYER_2()],
            deck: array![],
            next_player: Option::Some(PLAYER_1()),
            community_cards: array![],
            pot: 500,
            current_bet: 1000,
            params: get_default_game_params(),
            reshuffled: 0,
        };

        let player_1 = Player {
            id: PLAYER_1(),
            alias: 'dub_zn',
            chips: 2000,
            current_bet: 1000,
            total_rounds: 1,
            locked: (true, 1),
            is_dealer: false,
            in_round: true,
            out: (0, 0),
        };

        let player_2 = Player {
            id: PLAYER_2(),
            alias: 'Birdmannn',
            chips: 5000,
            current_bet: 500,
            total_rounds: 1,
            locked: (true, 1),
            is_dealer: false,
            in_round: true,
            out: (0, 0),
        };

        world.write_model(@game);
        world.write_models(array![@player_1, @player_2].span());
    }
}
