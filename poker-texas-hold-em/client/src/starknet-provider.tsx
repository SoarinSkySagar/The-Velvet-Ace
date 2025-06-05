import type { PropsWithChildren } from "react";
import { mainnet } from "@starknet-react/chains";
import {
  jsonRpcProvider,
  StarknetConfig,
  voyager,
  argent,
  braavos,
  useInjectedConnectors,
} from "@starknet-react/core";
import { dojoConfig } from "../dojoConfig";
import instance from "./lib/controller";
import {
  predeployedAccounts,
  PredeployedAccountsConnector,
} from "@dojoengine/predeployed-connector";

let pa: PredeployedAccountsConnector[] = [];
predeployedAccounts({
  rpc: dojoConfig.rpcUrl as string,
  id: "katana",
  name: "Katana",
}).then((p) => (pa = p));

export default function StarknetProvider({ children }: PropsWithChildren) {
  const { connectors: injected } = useInjectedConnectors({
    recommended: [argent(), braavos()],
    includeRecommended: "always",
  });

  const connectors = [instance, ...injected, ...pa];

  const provider = jsonRpcProvider({
    rpc: () => ({ nodeUrl: dojoConfig.rpcUrl as string }),
  });

  return (
    <StarknetConfig
      chains={[mainnet]}
      provider={provider}
      connectors={connectors || pa}
      explorer={voyager}
      autoConnect
    >
      {children}
    </StarknetConfig>
  );
}
