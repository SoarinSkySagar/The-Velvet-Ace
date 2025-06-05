import ControllerConnector from "@cartridge/connector/controller";
import { Connector } from "@starknet-react/core";
import { constants } from "starknet";

const cartridgeInstance = new ControllerConnector({
  chains: [{ rpcUrl: "https://api.cartridge.gg/x/starknet/mainnet" }],
  defaultChainId: constants.StarknetChainId.SN_MAIN,
}) as unknown as InstanceType<typeof Connector>;

export default cartridgeInstance;
