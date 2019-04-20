pragma solidity >=0.4.21 <0.6.0;

contract Thing {

  struct BrokerStatus {
      uint expiry;
      uint votes;
      uint status;
  }

  address public owner;

  uint walletBalance = 0;
  uint brokerStake = 0;

  mapping (string => uint) phoneNumberToBalance;
  
  uint STAKE = 15;
  uint NEW_BROKER_VOTES_REQUIRE = 4;
  uint TRANSACTION_VOTES_REQUIRE = 3;
  uint TRANSACTION_TIMEOUT = 100;

  mapping (address => BrokerStatus) brokerStatus;

  uint brokerStatus_Banned = 0;
  uint brokerStatus_BannedPending = 2;

  uint brokerStatus_Active = 3;
  uint brokerStatus_ActivePendingVote = 1;
  uint brokerStatus_ActivePendingStake = 3;

  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }


  function getWalletBalance()
  public view  
  returns (uint)
  {
    return walletBalance;
  }

  function getBrokerStake()
  public view  
  returns (uint)
  {
    return brokerStake;
  }

// =====================================
// Broker
// =====================================

  function getBroker(address _newBroker)
  public view  
  returns (uint,uint, uint)
  {
    return (brokerStatus[_newBroker].status, brokerStatus[_newBroker].votes ,brokerStatus[_newBroker].expiry );
  }

  function addBroker(address _newBroker)
  restricted public 
  {
    brokerStatus[_newBroker].status = brokerStatus_ActivePendingStake;
  }


  // TODO: Add minimum staking
  // Must be voteable
  // Check for broker status pending stake
  function addBrokerStake()
  public payable
  {
    require(msg.value == STAKE);
    brokerStake += msg.value;
    brokerStatus[msg.sender].status = brokerStatus_ActivePendingVote;
  }

  // Once voted = broker active

// =====================================
// User
// =====================================

  function getUser (string memory _phoneNumber) 
  public view
  returns (uint)
  {
    return phoneNumberToBalance[_phoneNumber];
  }

  function fundUser (string memory _phoneNumber) 
  public payable
  {
    walletBalance += msg.value;
    phoneNumberToBalance[_phoneNumber] += msg.value;
  }

  //TODO: multisig 
  function sendFundsToPhone(string memory _from, string memory _to, uint _amount)
  public
  {
    require(phoneNumberToBalance[_from] >= _amount);
    require(brokerStatus[msg.sender].status == brokerStatus_Active);
    phoneNumberToBalance[_from] -= _amount;
    phoneNumberToBalance[_to] += _amount;
  }

  function sendFundsToAddr(string memory _from, address payable _to, uint _amount)
  public
  {
    require(phoneNumberToBalance[_from] >= _amount);
    require(brokerStatus[msg.sender].status == brokerStatus_Active);

    phoneNumberToBalance[_from] -= _amount; 
    _to.transfer(_amount);
    walletBalance -= _amount;
  }
  
}
