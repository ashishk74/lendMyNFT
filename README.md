# lendMyNFT

contract deployed on Rinkeby network.

Herein , a borrower with a NFT can run the borrow() and get 70% of the price of NFT as a loan , in USDC, for a time period desirable.

Price of NFT can be called as an oracle, but for this contract, it can be declared manually by borrower.

If the borrower can repay the loan within the end time committed, then he can run repay() and pay the amount with interest to get the NFT back into his possesion.

If the borrower cannot repay within the time frame, then the loan can be assigned as NPA (non performing asset). For this , anybody can run the function assignAllNPA() to assign all those assets whose end time has crossed , as NPA.

If anybody wishes to liquidate the loan asset by paying the principal + interest accrued , then function liquidateNPA() to be run, which will transfer USDC from liquidators wallet and send NFT collateralized to liquidator.

To view list of NPA's, view function viewNPA() van be run, specifying how many NPA assets to view.


