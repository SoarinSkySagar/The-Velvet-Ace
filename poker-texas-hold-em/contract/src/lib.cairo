mod systems {
    mod actions;
    mod interface;
}

mod models {
    mod base;
    mod card;
    mod deck;
    mod game;
    mod hand;
    mod player;
}

mod traits {
    mod deck;
    mod game;
    mod handimpl;
    mod handtrait;
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
