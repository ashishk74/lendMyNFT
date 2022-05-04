pragma solidity 0.8.4;


import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/lendMyNFT.sol";

contract TestNFT {
  function testUSDCUsingDeployedContract() {
    LendMyNFT lend = LendMyNFT(DeployedAddresses.LendMyNFT());

    address expected = 0xeb8f08a975Ab53E34D8a0330E0D34de942C95926;

    Assert.equal(lend.usdc, expected, "Address should be same");
  }

//   function testInitialBalanceWithNewMetaCoin() {
//     MetaCoin meta = new MetaCoin();

//     uint expected = 10000;

//     Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
//   }
}
