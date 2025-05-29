import { useEffect, useState, type PropsWithChildren } from "react";
import { mainnet } from "@starknet-react/chains";
import {
  jsonRpcProvider,
  StarknetConfig,
  voyager,
  argent,
  braavos,
  useInjectedConnectors,
  Connector,
} from "@starknet-react/core";
import { dojoConfig } from "../dojoConfig";
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
  const [connectors, setConnectors] = useState<Connector[] | null>(null);

  const { connectors: injected } = useInjectedConnectors({
    recommended: [argent(), braavos()],
    includeRecommended: "always",
  });

  useEffect(() => {
    const loadConnector = async () => {
      const instance = await import("./lib/controller").then((mod) =>
        mod.getCartridgeInstance()
      );
      setConnectors([instance, ...injected]);
    };
    loadConnector();
  }, []);

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
