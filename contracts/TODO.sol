/*

Farmers Contract

1. Write in Logic to increase the price when certain amount of NFTs have been purchased
2. set timer to start mint
3. Create Royalty that keeps % to be added to treasury upon any sales

Governance

1. Create Gov contract
2. anyone with an nft can create a vote choice
2. allows each NFT to get one vote
3. LP pools and one sided staking options
4. top 4 get chosen

Farmtroller

1. Send funds to 4 contracts chose by vote
2. takes balance of the account 
3. Ability to farm and claim rewards
4. upon call from Farmers it pulls single NFT value in AVAx and send it to Farmers contract
    -- keeps 2% for the treasury upon any burn() call
5. Recalls all invested funds to re-deploy or rebalance after each vote
6. Sends funds to pool contract that can be continously deployed for new pools voted in or reused
    - all pool contracts should have same interface for farmtroller to interact with but specifically designed for a LP pool/ staking etc

Pool contract

1. create basic framework to comnicate with farmtroller

*/