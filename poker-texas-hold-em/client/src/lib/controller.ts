export async function getCartridgeInstance() {
  const [{ default: ControllerConnector }, { Connector }, { constants }] =
    await Promise.all([
      import("@cartridge/connector/controller"),
      import("@starknet-react/core"),
      import("starknet"),
    ]);

  const instance = new ControllerConnector({
    chains: [{ rpcUrl: "https://api.cartridge.gg/x/starknet/mainnet" }],
    defaultChainId: constants.StarknetChainId.SN_MAIN,
  }) as unknown as InstanceType<typeof Connector>;

  return instance;
}
