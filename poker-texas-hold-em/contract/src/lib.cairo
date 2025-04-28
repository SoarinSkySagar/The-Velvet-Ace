mod systems {
    mod actions;
    mod interface;
}

mod models {
    mod deck;
    mod game;
    mod hand;
    mod player;
    mod card;
    mod base;
}

mod traits {
    mod handtrait;
    mod game;
    mod handimpl;
    mod deck;
    mod player;
}

mod utils {
    mod hand;
}

mod tests {
    mod test_hand_compare;
    mod test_hand_rank;
    mod test_world;
}
