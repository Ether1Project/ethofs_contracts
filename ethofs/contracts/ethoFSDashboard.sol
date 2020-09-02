pragma solidity ^0.4.21;

contract ethoFSDashboard {
    function deleteContract() public onlyOwner {
        selfdestruct(owner);
    }

    uint256 public hostingCost;
    uint32 public userCount;
    address internal owner; // owner of the contract
    address internal operator; // operator or control contract
    address accountCollectionAddress;
    mapping (address => userAccount) public userAccounts;
    address[] userAccountAddresses;
    struct userAccount {
        address userAddress;
        string accountName;
        uint32 activeContractCount;
        uint32 totalContractCount;
        address[] hostingContractAddresses;
    }
    function ethoFSDashboard () public {
        owner = msg.sender;
        operator = msg.sender;
        userCount = 0;
        hostingCost = 5000000000000000000;
    }
    function SetUserCount(uint32 set) public onlyOwnerOrOperator {
        userCount = set;
    }
    function SetAccountCollectionAddress(address set) public onlyOwnerOrOperator {
        accountCollectionAddress = set;
    }
    function CheckAccountExistence(address UserAddress) public view returns(bool) {
         if(userAccounts[UserAddress].userAddress == address(0x0)) {
             return false;
         } 
         return true;
    }
    function AddNewUser(address UserAddress, string AccountName) public onlyOwnerOrOperator {
        userAccount memory newUserAcccount = userAccount({userAddress:UserAddress, accountName:AccountName, activeContractCount:0, totalContractCount:0, hostingContractAddresses: new address[](0)});
        userAccounts[UserAddress] = newUserAcccount;
        userAccountAddresses.push(UserAddress);
        userCount++;
    }
    function RemoveUser(address UserAddress) public onlyOwnerOrOperator {
        delete userAccounts[UserAddress];
        RemoveUserByValue(UserAddress);
        userCount--;
    }
    function AddHostingContract(address newContractAddress, address UserAddress, string HostingContractName, uint32 HostingContractDuration, uint32 TotalContractSize) public onlyOwnerOrOperator returns(address NewContractAddress){
        userAccounts[UserAddress].hostingContractAddresses.push(newContractAddress);
        userAccounts[UserAddress].activeContractCount++;
        userAccounts[UserAddress].totalContractCount++;
        return newContractAddress;
    }
    function RemoveHostingContract(address UserAddress, address HostingContractAddress) public onlyOwnerOrOperator {
        uint i = FindArrayKey(UserAddress, HostingContractAddress);
        RemoveByIndex(UserAddress, i);
        userAccounts[UserAddress].activeContractCount--;
        userAccounts[UserAddress].totalContractCount--;
    }
    function GetUserAccountAddress(address UserAddress) public onlyOwnerOrOperator constant returns(address value) {
        return userAccounts[UserAddress].userAddress;
    }
    function GetUserAccountName(address UserAddress) public onlyOwnerOrOperator constant returns(string value) {
        return userAccounts[UserAddress].accountName;
    }
    function GetUserAccountActiveContractCount(address UserAddress) public onlyOwnerOrOperator constant returns(uint32 value) {
        return userAccounts[UserAddress].activeContractCount;
    }
    function GetUserAccountTotalContractCount(address UserAddress) public onlyOwnerOrOperator constant returns(uint32 value) {
        return userAccounts[UserAddress].totalContractCount;
    }
    function GetHostingContractAddress(address UserAddress, uint ArrayKey) public onlyOwnerOrOperator constant returns(address value) {
        address ArrayValue = FindArrayValue(UserAddress, ArrayKey);
        return ArrayValue;
    }   
    function FindArrayValue(address UserAddress, uint ArrayKey) private constant returns (address value) {
        return userAccounts[UserAddress].hostingContractAddresses[ArrayKey];
    }
    function FindArrayKey(address UserAddress, address HostingContactAddress) private constant returns (uint) {
        uint i = 0;
        while (keccak256(userAccounts[UserAddress].hostingContractAddresses[i]) != keccak256(HostingContactAddress)) {
            i++;
        }
        return i;
    }
    function FindUserAddressArrayKey(address UserAddress) private constant returns (uint) {
        uint i = 0;
        while (keccak256(userAccountAddresses[i]) != keccak256(UserAddress)) {
            i++;
        }
        return i;
    }
    function RemoveUserByValue(address UserAddress) private {
        uint i = FindUserAddressArrayKey(UserAddress);
        RemoveUserByIndex(i);
    }
    function RemoveUserByIndex(uint i) private {
        while (i < (userAccountAddresses.length - 1)) {
            userAccountAddresses[i] = userAccountAddresses[i+1];
            i++;
        }
        userAccountAddresses.length--;
    }
    function RemoveByValue(address UserAddress, address HostingContractAddress) private {
        uint i = FindArrayKey(UserAddress, HostingContractAddress);
        RemoveByIndex(UserAddress, i);
    }
    function RemoveByIndex(address UserAddress, uint i) private {
        while (i < (userAccounts[UserAddress].hostingContractAddresses.length - 1)) {
            userAccounts[UserAddress].hostingContractAddresses[i] = userAccounts[UserAddress].hostingContractAddresses[i+1];
            i++;
        }
        userAccounts[UserAddress].hostingContractAddresses.length--;
    }
    modifier onlyOwner()
    {
       if (msg.sender != owner) revert();
       _;
    }
    modifier onlyOwnerOrOperator()
    {
       if (msg.sender != owner && msg.sender != operator) revert();
       _;
    }
    function changeOperator(address newOperator) public onlyOwner
    {
       operator = newOperator;
    }
}
