fn move(ref self: ContractState, direction: Direction) {
    // Get the address of the current caller, possibly the player's address.

    let mut world = self.world_default();

    let player = get_caller_address();

    // Retrieve the player's current position and moves data from the world.
    let position: Position = world.read_model(player);
    let mut moves: Moves = world.read_model(player);
    // if player hasn't spawn, read returns model default values. This leads to sub overflow
    // afterwards.
    // Plus it's generally considered as a good pratice to fast-return on matching
    // conditions.
    if !moves.can_move {
        return;
    }

    // Deduct one from the player's remaining moves.
    moves.remaining -= 1;

    // Update the last direction the player moved in.
    moves.last_direction = Option::Some(direction);

    // Calculate the player's next position based on the provided direction.
    let next = next_position(position, moves.last_direction);

    // Write the new position to the world.
    world.write_model(@next);

    // Write the new moves to the world.
    world.write_model(@moves);

    // Emit an event to the world to notify about the player's move.
    world.emit_event(@Moved { player, direction });
}

fn spawn(ref self: ContractState) {
    // Get the default world.
    let mut world = self.world_default();

    // Get the address of the current caller, possibly the player's address.
    let player = get_caller_address();
    // Retrieve the player's current position from the world.
    let position: Position = world.read_model(player);

    // Update the world state with the new data.

    // 1. Move the player's position 10 units in both the x and y direction.
    let new_position = Position {
        player, vec: Vec2 { x: position.vec.x + 10, y: position.vec.y + 10 }
    };

    // Write the new position to the world.
    world.write_model(@new_position);

    // 2. Set the player's remaining moves to 100.
    let moves = Moves { player, remaining: 100, last_direction: Option::None, can_move: true };

    // Write the new moves to the world.
    world.write_model(@moves);
}
// Implementation of the move function for the ContractState struct.


