const Thing = artifacts.require("Thing");

const brokerStatus_Banned = 0;
const brokerStatus_BannedPending = 2;
const brokerStatus_Active = 3;
const brokerStatus_ActivePendingVote = 1;
const brokerStatus_ActivePendingStake = 3;


contract('Thing', async (accounts) => {

    // Create a blank bio, such that there will never be a valid address 
    // at any index 0;
    it("should add a broker", async () => {
        let instance = await Thing.deployed();

        await instance.addBroker(accounts[1], { from: accounts[0] });
        let broker = await instance.getBroker.call(accounts[1], { from: accounts[0] });
        assert.equal(broker.valueOf()[0], brokerStatus_ActivePendingStake);

    })

    it("should add a broker stake", async () => {
        let instance = await Thing.deployed();

        const oldStake = await instance.getBrokerStake.call({ from: accounts[1] }).valueOf();
        await instance.addBrokerStake({ from: accounts[1], value: 15 });
        const newStake = await instance.getBrokerStake.call({ from: accounts[1] }).valueOf();
        let broker = await instance.getBroker.call(accounts[1], { from: accounts[0] });

        assert.equal(broker.valueOf()[0], brokerStatus_ActivePendingVote);
        assert.equal(newStake - oldStake, 15);

    })

    it("should break if stake not match", async () => {
        let instance = await Thing.deployed();

        try {
            await instance.addBrokerStake({ from: accounts[1], value: 1 });
            assert.equal(true, false);
        } catch (error) {
            assert.equal(true, true);
        }

    })

    it("shoudl be able to fund user", async () => {
        let instance = await Thing.deployed();
        await instance.fundUser('0723327800', { from: accounts[1], value: 10 });
        const userBalance = await instance.getUser.call('0723327800', { from: accounts[1] }).valueOf();

        assert.equal(userBalance, 10);

    })

    it("should be able to send funds to phone", async () => {
        let instance = await Thing.deployed();

        await instance.fundUser('0723327800', { from: accounts[1], value: 10 });

        await instance.sendFundsToPhone('0723327800', '0723327801', 5, { from: accounts[1] });
        const userBalance = await instance.getUser.call('0723327801', { from: accounts[1] }).valueOf();
        assert.equal(userBalance, 5);
    })

    it("should be able to send funds to address", async () => {
        let instance = await Thing.deployed();

        await instance.fundUser('0723327800', { from: accounts[1], value: 10 });

        await instance.sendFundsToAddr('0723327800', accounts[2], 5, { from: accounts[1] });
        let balance = await web3.eth.getBalance(accounts[2]).valueOf()
        assert.equal(balance, 5);
    })



})