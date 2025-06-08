use starknet::{ContractAddress, contract_address_const};
use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, get_class_hash, start_cheat_caller_address,
    stop_cheat_caller_address,
};
use openzeppelin::upgrades::interface::{IUpgradeableDispatcherTrait, IUpgradeableDispatcher};

#[starknet::interface]
trait NFT<NContractState> {
    fn mint(ref self: NContractState, recipient: ContractAddress, token_id: u256);
    fn balance_of(self: @NContractState, account: ContractAddress) -> u256;
    fn owner_of(self: @NContractState, token_id: u256) -> ContractAddress;
    fn transfer(
        ref self: NContractState, from: ContractAddress, recipient: ContractAddress, token_id: u256,
    );
    fn name(self: @NContractState) -> ByteArray;
    fn symbol(self: @NContractState) -> ByteArray;
    fn token_uri(self: @NContractState, token_id: u256) -> ByteArray;
}

#[cfg(test)]
mod tests {
    use super::*;

    /////////////////////
    //===> Helpers <===//
    /////////////////////

    //== Owner Role ==//
    fn OWNER() -> ContractAddress {
        let owner: ContractAddress = contract_address_const::<'owner'>();

        owner
    }

    //== NFT Name ==//
    fn NAME() -> ByteArray {
        "Poker"
    }

    //== NFT Symbol ==//
    fn SYMBOL() -> ByteArray {
        "PKR"
    }

    //== NFT URI ==//
    fn URI() -> ByteArray {
        "https://poker.com/mock-uri"
    }

    //== User Role ==//
    fn USER() -> ContractAddress {
        let user: ContractAddress = contract_address_const::<'USER'>();

        user
    }
    fn NEWUSER() -> ContractAddress {
        let new_user: ContractAddress = contract_address_const::<'NEW_USER'>();

        new_user
    }

    //////////////////////////////////
    //===> Setup & Initializing <===//
    //////////////////////////////////

    fn deploy_contract() -> ContractAddress {
        // Step 1: Declare the contract
        let contract = declare("ERC721").unwrap().contract_class();

        // Step 2: Prepare constructor calldata
        let mut constructor_calldata: Array::<felt252> = array![];
        Serde::serialize(@OWNER(), ref constructor_calldata);
        Serde::serialize(@NAME(), ref constructor_calldata);
        Serde::serialize(@SYMBOL(), ref constructor_calldata);
        Serde::serialize(@URI(), ref constructor_calldata);

        // Step 3: Deploy the contract with constructor calldata
        let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();

        // Step 4: Return contract address
        contract_address
    }

    // Helper function to declare and deploy the receiver mock
    fn setup_receiver() -> ContractAddress {
        let receiver_class = declare("DualCaseERC721ReceiverMock").unwrap().contract_class();
        let (contract_address, _) = receiver_class.deploy(@array![]).unwrap();
        contract_address
    }

    /////////////////////////////
    //===> Ownership Tests <===//
    /////////////////////////////

    #[test]
    fn test_constructor_initial_state() {
        // Step 1: Deploy the contract
        let contract_address = deploy_contract();
        let dispatcher = NFTDispatcher { contract_address };

        // Step 2: Check initial state
        assert(dispatcher.name() == NAME(), 'Wrong name');
        assert(dispatcher.symbol() == SYMBOL(), 'Wrong symbol');
        assert(dispatcher.balance_of(OWNER()) == 0, 'Wrong initial balance');
    }

    //== Should allow the owner to mint tokens ==//
    #[test]
    fn test_owner_can_mint() {
        // Step 1: Initializing
        let contract_address = deploy_contract();
        let dispatcher = NFTDispatcher { contract_address };

        // Step 2: Setting up mint data
        let recipient: ContractAddress = USER();
        let token_id: u256 = 1;

        // Step 3: Call as owner to mint a token
        start_cheat_caller_address(contract_address, OWNER());
        dispatcher.mint(recipient, token_id);
        stop_cheat_caller_address(contract_address);

        // Step 4: Check ownership and balance
        assert(dispatcher.owner_of(token_id) == recipient, 'Wrong owner');
        assert(dispatcher.balance_of(recipient) == 1, 'Wrong balance');

        // Step 5: Check token URI
        let expected = format!("{}{}", URI(), token_id);
        assert(dispatcher.token_uri(token_id) == expected, 'Owner token URI mismatch');
    }

    #[test]
    fn test_owner_can_mint_to_receiver() {
        // Step 1: Initializing
        let contract_address = deploy_contract();
        let dispatcher = NFTDispatcher { contract_address };

        // Step 2: Setting up mint data
        let recipient: ContractAddress = setup_receiver();
        let token_id: u256 = 1;

        // Step 3: Call as owner to mint a token
        start_cheat_caller_address(contract_address, OWNER());
        dispatcher.mint(recipient, token_id);
        stop_cheat_caller_address(contract_address);

        // Step 4: Verify ownership and balance
        assert(dispatcher.owner_of(token_id) == recipient, 'Wrong owner');
        assert(dispatcher.balance_of(recipient) == 1, 'Wrong balance');
    }

    #[test]
    fn test_token_owner_can_tranfer() {
        // Step 1: Initializing
        let contract_address = deploy_contract();
        let dispatcher = NFTDispatcher { contract_address };

        // Step 2: Setting up mint data
        let recipient: ContractAddress = USER();
        let token_id: u256 = 1;

        // Step 3: Call as owner to mint a token
        start_cheat_caller_address(contract_address, OWNER());
        dispatcher.mint(recipient, token_id);
        stop_cheat_caller_address(contract_address);

        // Step 4: Transfer the token
        let new_owner: ContractAddress = NEWUSER();
        start_cheat_caller_address(contract_address, recipient);
        dispatcher.transfer(recipient, new_owner, token_id);
        stop_cheat_caller_address(contract_address);

        assert(dispatcher.owner_of(token_id) == new_owner, 'Wrong owner after transfer');
        assert(dispatcher.balance_of(new_owner) == 1, 'Wrong balance of new owner');
        assert(dispatcher.balance_of(recipient) == 0, 'Wrong balance of previous owner');
    }

    #[test]
    #[should_panic(expected: 'ERC721: invalid sender')]
    fn test_owner_cannot_transfer_non_owned_token() {
        // Step 1: Initializing
        let contract_address = deploy_contract();
        let dispatcher = NFTDispatcher { contract_address };

        // Step 2: Setting up mint data
        let recipient: ContractAddress = USER();
        let token_id: u256 = 1;

        // Step 3: Call as owner to mint a token
        start_cheat_caller_address(contract_address, OWNER());
        dispatcher.mint(recipient, token_id);
        stop_cheat_caller_address(contract_address);

        // Step 4: Attempt to transfer the token as non-owner
        let new_owner: ContractAddress = NEWUSER();
        start_cheat_caller_address(contract_address, OWNER());
        dispatcher.transfer(OWNER(), new_owner, token_id);
    }

    //== Should NOT allow users to mint tokens ==//
    #[test]
    #[should_panic(expected: 'Caller is not the owner')]
    fn test_users_cannot_mint() {
        // - Step 1: Initializing
        let contract_address = deploy_contract();
        let dispatcher = NFTDispatcher { contract_address };

        // - Step 2: Setting up mint data
        let recipient: ContractAddress = USER();
        let token_id: u256 = 1;

        // - Step 3: Not owner tries to mint token
        dispatcher.mint(recipient, token_id);
    }

    //== Should allow the owner to upgrade the contract ==//
    #[test]
    fn test_contract_upgrade() {
        // Step 1: Deploy the initial contract
        let contract_address = deploy_contract();
        let dispatcher = IUpgradeableDispatcher { contract_address };

        // Step 2: New contract setup
        let new_contract_class = declare("ERC721").unwrap().contract_class();

        let mut constructor_calldata: Array::<felt252> = array![];
        Serde::serialize(@OWNER(), ref constructor_calldata);
        Serde::serialize(@NAME(), ref constructor_calldata);
        Serde::serialize(@SYMBOL(), ref constructor_calldata);
        Serde::serialize(@URI(), ref constructor_calldata);

        let (new_contract_address, _) = new_contract_class.deploy(@constructor_calldata).unwrap();
        let new_class_hash = get_class_hash(new_contract_address);

        // Step 3: Set the caller to be the contract owner
        start_cheat_caller_address(contract_address, OWNER());

        // Step 4: Upgrade the contract using the upgrade function
        dispatcher.upgrade(new_class_hash);
    }

    //== Should prevent non-owners from upgrading the contract ==/
    #[test]
    #[should_panic(expected: 'Caller is not the owner')]
    fn test_users_cannot_upgrade() {
        // Step 1: Deploy the initial contract
        let contract_address = deploy_contract();
        let dispatcher = IUpgradeableDispatcher { contract_address };

        // Step 2: New contract setup
        let new_contract_class = declare("ERC721").unwrap().contract_class();

        let mut constructor_calldata: Array::<felt252> = array![];
        Serde::serialize(@OWNER(), ref constructor_calldata);
        Serde::serialize(@NAME(), ref constructor_calldata);
        Serde::serialize(@SYMBOL(), ref constructor_calldata);
        Serde::serialize(@URI(), ref constructor_calldata);

        let (new_contract_address, _) = new_contract_class.deploy(@constructor_calldata).unwrap();
        let new_class_hash = get_class_hash(new_contract_address);

        // Step 3: Upgrade the contract using the upgrade function (fails)
        dispatcher.upgrade(new_class_hash);
    }
}

