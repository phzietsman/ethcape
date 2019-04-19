pragma solidity >=0.4.21 <0.6.0;

contract Migrations {

  uint walletBalance = 0;
  uint brokerStake = 0;

  address public owner;
  uint public last_completed_migration;

  mapping (string => uint) phoneNumberToBalance;
  mapping (address => uint) brokerStatus;

  // uint brokerStatus_Banned = 0;
  uint brokerStatus_Active = 1;
  uint brokerStatus_PendingStake = 2;
  // uint brokerStatus_PendingBanned = 2;
  // uint brokerStatus_PendingActive = 3;

  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  function addBroker(address _newBroker) 
  public
  {
    brokerStatus[_newBroker] = brokerStatus_PendingStake;
  }

  // TODO: Add minimum staking
  // Must be voteable
  // Once staked + voted = broker active
  function addBrokerStake()
  public payable
  {
    brokerStake += msg.value;
    brokerStatus[msg.sender] = brokerStatus_Active;
  }

  // validate user exists
  function fundUser (string memory _phoneNumber) 
  public payable
  {
    walletBalance += msg.value;
    phoneNumberToBalance[_phoneNumber] += msg.value;
  }

  function sendFundsToPhone(string memory _from, string memory _to, uint _amount)
  public
  {
    if (phoneNumberToBalance[_from] >= _amount) {
      phoneNumberToBalance[_from] -= _amount;
      phoneNumberToBalance[_to] += _amount;
    }
  }

  function sendFundsToAddr(string memory _from, address payable _to, uint _amount)
  public
  {
    if (phoneNumberToBalance[_from] >= _amount) {
      phoneNumberToBalance[_from] -= _amount; 
      _to.transfer(_amount);
      walletBalance -= _amount;
    }
  }







  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
  
}
