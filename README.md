# NFT-Marketplace
This Smart Contract allows us to create our own NFT Marketplace where we can buy and sell ERC-721 NFTs.

This marketplace will have the functions of list, cancel list, buy and sell the NFTS, in addition to having the inclusion of a commission that will allow to the owner of the marketplace to receive a commission (5%) each time a trade occurs. This market place will be based on:

-	An ERC-721 contract that I will deploy it in the blockchain, I will obtain its respective address and in the NFT Marketplace contract I will instantiate it through its address using the OppenZepelin interface. Thus, the NFT marketplace contract will be able to interact with the ERC-721 contract and implement NFTs.

-	An ERC-20 contract (I suppose I am going to use an ERC-20 stablecoin token as a means of payment), I will deploy it in the blocckhain, I will obtain its respective address and in the NFT Marketplace contract I will instantiate it through its address using the OppenZepelin interface. Thus, the NFT marketplace contract will be able to interact with the ERC-20 contract and be able to use the token as a means of exchange. 

-	A preventive measure to block "Front running" attacks or price manipulations.

The overall process can be seen below:

![image](https://user-images.githubusercontent.com/126001574/226315875-a488483a-150a-4eae-85e3-5a33bf02f381.png)
