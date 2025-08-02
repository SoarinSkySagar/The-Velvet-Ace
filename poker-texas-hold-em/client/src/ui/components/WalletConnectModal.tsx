import { useState } from "react";
import Modal from "./Modal";
import Button from "./LandingPage/Button";
import { Connector, useAccount, useConnect } from "@starknet-react/core";

type Props = {
  isOpen: boolean;
  onClose: () => void;
};

type WalletIcon = string | { dark: string; light: string };
type Wallet = {
  name: string;
  icon: WalletIcon;
};

const WalletConnectModal = ({ isOpen, onClose }: Props) => {
  const [searchTerm, setSearchTerm] = useState<string>("");
  const [isWalletLoading, setIsWalletLoading] = useState(false);
  const [selectedWallet, setSelectedWallet] = useState<Wallet | null>(null);
  const { connect, connectors } = useConnect();
  const { account } = useAccount();
  const wallets: Connector[] = connectors;

  const filteredWallets = wallets.filter((wallet) =>
    wallet.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleWalletConnect = (wallet: Connector) => {
    try {
      if (!account) {
        if (connectors.length) {
          setSelectedWallet({
            name: wallet.name,
            icon: wallet.icon,
          });
          setIsWalletLoading(true);
          onClose();
          connect({ connector: wallet });
          setIsWalletLoading(false);
        } else {
          console.log("No connectors available");
        }
      }
    } catch (error) {
      console.error("Error connecting wallet:", error);
      return;
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} width="max-w-lg">
      <div className="grid py-4 gap-y-6">
        <h3 className="text-xl font-semibold text-center text-white font-orbitron">
          Connect Wallet
        </h3>

        {isWalletLoading ? (
          <div className="grid py-4 text-center text-white gap-y-4">
            <div className="flex items-center justify-between mb-4 bg-[#0A1128] rounded-full py-[17px] px-[20px]">
              <span className="font-bold text-[#9DA0A9]">
                {selectedWallet?.name}
              </span>
              <span className="animate-pulse">...</span>
            </div>
            <div className="flex flex-col items-center justify-center gap-y-6">
              {selectedWallet?.icon && (
                <img
                  src={
                    typeof selectedWallet.icon === "object"
                      ? selectedWallet.icon.dark
                      : selectedWallet.icon
                  }
                  className="rounded-full h-[74px] w-[74px]"
                  alt={`${selectedWallet.name} icon`}
                />
              )}
              <span className="animate-pulse">Connecting...</span>
            </div>
          </div>
        ) : (
          <>
            <div className="relative">
              <input
                type="search"
                placeholder="Search "
                className="w-full rounded-2xl bg-[#0A1128] p-3 pl-10 text-white placeholder-[#9DA0A9]"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>

            <div className="grid gap-y-2">
              {filteredWallets.map((wallet) =>
                wallet.available() ? (
                  <button
                    key={wallet.name}
                    className="flex w-full cursor-pointer items-center justify-between rounded-lg bg-[hsla(227,44%,19%,0.8)] py-2 px-3 transition-all duration-200 hover:bg-[hsla(227,44%,25%,0.9)] border border-[hsla(227,44%,25%,0.3)] hover:border-[hsla(227,44%,35%,0.5)]"
                    onClick={() => handleWalletConnect(wallet)}
                  >
                    <div className="flex items-center gap-x-3">
                      {wallet.icon && (
                        <img
                          src={
                            typeof wallet.icon === "object"
                              ? wallet.icon.dark
                              : wallet.icon
                          }
                          alt={wallet.name}
                          className="w-8 h-8"
                        />
                      )}
                      <span className="font-medium text-white">
                        {wallet.name}
                      </span>
                    </div>
                    <div className="w-[7px] h-[7px] rounded-full bg-[#B7860F]"></div>
                  </button>
                ) : null
              )}
            </div>
          </>
        )}

        <Button variant="gradient" fullWidth radius="full" onClick={onClose}>
          Cancel
        </Button>
      </div>
    </Modal>
  );
};

export default WalletConnectModal;
