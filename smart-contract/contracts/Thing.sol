pragma solidity >=0.4.21 <0.6.0;

contract Thing {

  struct BrokerStatus {
      uint expiry;
      uint votes;
      uint status;
      mapping (address => uint) voted;
  }

  struct PaymentStatus {
      uint expiry;
      uint votes;
      uint status;
      uint amount;
      string toPhone;
      address toAddress;
      uint paymentType;
      mapping (address => uint) voted;
  }

  uint PAYMENT_STATUS_PAID = 1;
  uint PAYMENT_STATUS_PENDING = 2;

  uint PAYMENT_TYPE_PHONE = 1;
  uint PAYMENT_TYPE_ADDRESS = 2;

  address public owner;

  uint walletBalance = 0;
  uint brokerStake = 0;

  mapping (string => uint) phoneNumberToBalance;
  mapping (string => PaymentStatus) pendingPayment;
  
  uint STAKE = 15;
  uint NEW_BROKER_VOTES_REQUIRE = 4;
  uint TRANSACTION_VOTES_REQUIRE = 3;
  uint TRANSACTION_TIMEOUT = 100;

  mapping (address => BrokerStatus) brokerStatus;

  uint brokerStatus_Banned = 1;
  uint brokerStatus_BannedPending = 2;

  uint brokerStatus_Active = 3;
  uint brokerStatus_ActivePendingVote = 4;
  uint brokerStatus_ActivePendingStake = 5;

  constructor() public {
    owner = msg.sender;
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
  public 
  {
    require(msg.sender == owner);
    brokerStatus[_newBroker].status = brokerStatus_ActivePendingStake;
  }

  function addBrokerStake()
  public payable
  {
    require(msg.value == STAKE);
    require(brokerStatus[msg.sender].status == brokerStatus_ActivePendingStake);

    brokerStake += msg.value;
    brokerStatus[msg.sender].status = brokerStatus_ActivePendingVote;
  }

  function voteBrokerIn(address _broker)
  public
  {
    require(brokerStatus[_broker].status == brokerStatus_ActivePendingVote);
    require(brokerStatus[_broker].votes < NEW_BROKER_VOTES_REQUIRE);
    require(brokerStatus[_broker].voted[msg.sender] != brokerStatus_ActivePendingVote);

    brokerStatus[msg.sender].votes += 1;
    brokerStatus[_broker].voted[msg.sender] = brokerStatus_ActivePendingVote;

    if(brokerStatus[_broker].votes >= NEW_BROKER_VOTES_REQUIRE) {
        brokerStatus[_broker].status = brokerStatus_Active;
    }
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

  function sendFundsToPhone(string memory _from, string memory _to, uint _amount)
  public
  {
    require(phoneNumberToBalance[_from] >= _amount);
    require(brokerStatus[msg.sender].status == brokerStatus_Active);

    pendingPayment[_from].votes = 1;
    pendingPayment[_from].status = PAYMENT_STATUS_PENDING;
    pendingPayment[_from].amount = _amount;
    pendingPayment[_from].toPhone = _to;
    pendingPayment[_from].paymentType = PAYMENT_TYPE_PHONE;
    pendingPayment[_from].voted[msg.sender] = 1;

  }

  function sendFundsToAddr(string memory _from, address _to, uint _amount)
  public
  {
    require(phoneNumberToBalance[_from] >= _amount);
    require(brokerStatus[msg.sender].status == brokerStatus_Active);

    pendingPayment[_from].votes = 1;
    pendingPayment[_from].status = PAYMENT_STATUS_PENDING;
    pendingPayment[_from].amount = _amount;
    pendingPayment[_from].toAddress = _to;
    pendingPayment[_from].paymentType = PAYMENT_TYPE_ADDRESS;
    pendingPayment[_from].voted[msg.sender] = 1;
  }
  

    
  function voteForTransaction(string memory _from)
  public
  {
    require(brokerStatus[msg.sender].status == brokerStatus_Active);
    require(pendingPayment[_from].status == PAYMENT_STATUS_PENDING);
    require(pendingPayment[_from].voted[msg.sender] != 1);

    pendingPayment[_from].votes += 1;

    if(pendingPayment[_from].votes >= TRANSACTION_VOTES_REQUIRE) {
        pendingPayment[_from].status = PAYMENT_STATUS_PAID;

        if(pendingPayment[_from].paymentType == PAYMENT_TYPE_PHONE) {
            phoneNumberToBalance[_from] -= pendingPayment[_from].amount; 
            phoneNumberToBalance[pendingPayment[_from].toPhone] += pendingPayment[_from].amount; 
        } else {
            walletBalance -= pendingPayment[_from].amount;          
            phoneNumberToBalance[_from] -= pendingPayment[_from].amount; 

            address payable to = address(uint160(pendingPayment[_from].toAddress)); 
            to.transfer(pendingPayment[_from].amount);
        }
    }

  }
}
