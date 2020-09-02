pragma solidity ^0.4.21; 

contract HostingContract {
  
    function deleteContract(address AccountCollectionAddress) public onlyOwnerOrOperator{
        if(block.number >= expirationBlockHeight) {
            AccountCollectionAddress.transfer(address(this).balance);
        }else{
            //uint256 collectAmount = ((block.number - deploymentBlockHeight) / (expirationBlockHeight - deploymentBlockHeight)) * (address(this).balance); 
            //AccountCollectionAddress.transfer(collectAmount);
            if(expirationBlockHeight > billedBlockHeight){
                AccountCollectionAddress.transfer((address(this).balance) * (block.number - billedBlockHeight) / (expirationBlockHeight - billedBlockHeight));
            }
            //customer.transfer(address(this).balance );
        }
        if (msg.sender == operator) selfdestruct(customer);
        if (msg.sender == owner) selfdestruct(customer);
    }

    string public hostingContractName;
    address public customer; // hosting contract customer
    address internal owner; // owner of the contract
    address internal operator; // operator or control contract
    uint256 public contractCost;
    uint256 contractBalance;
    uint256 deploymentBlockHeight;
    uint256 expirationBlockHeight;
    uint256 billedBlockHeight;

    function HostingContract (address OperatorAddress, string HostingContractName, address UserAddress, uint256 ContractCost, uint256 ExpirationBlockHeight) public payable{
        customer = UserAddress;
        owner = msg.sender;
        operator = OperatorAddress;
        hostingContractName = HostingContractName;
        contractCost = ContractCost;
        contractBalance = ContractCost;
        deploymentBlockHeight = block.number;
        billedBlockHeight = block.number;
        expirationBlockHeight = ExpirationBlockHeight;
    }
    function GetCustomerAddress() public returns(address){
        return customer;
    }
    function SetContractName(string NewContractName) public onlyOwnerOrOperator {
        hostingContractName = NewContractName;
    }
    function UpdateExpirationBlockHeight (uint256 ExpirationBlockHeight, address AccountCollectionAddress) public onlyOwnerOrOperator payable{
        CollectBalance(contractBalance, deploymentBlockHeight, expirationBlockHeight, AccountCollectionAddress);
        expirationBlockHeight = ExpirationBlockHeight;
        contractBalance += msg.value;
    }    
    function ContractPaymentCollection (address AccountCollectionAddress) public onlyOwnerOrOperator{
         CollectBalance(contractBalance, deploymentBlockHeight, expirationBlockHeight, AccountCollectionAddress);
    }
    function CollectBalance(uint256 ContractBalance, uint256 DeploymentBlockHeight, uint256 ExpirationBlockHeight, address AccountCollectionAddress) internal{
        //uint256 collectAmount = ((block.number - DeploymentBlockHeight) / (ExpirationBlockHeight - DeploymentBlockHeight)) * ContractBalance;
        if(expirationBlockHeight >  billedBlockHeight){
            AccountCollectionAddress.transfer((address(this).balance) * (block.number - billedBlockHeight) / (expirationBlockHeight - billedBlockHeight));
            billedBlockHeight = block.number;
        }
        //AccountCollectionAddress.transfer(collectAmount);
        //contractBalance -= collectAmount; 
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
}
contract ethoFSHostingContracts {
    function deleteHostingContracts() public onlyOwner {
        selfdestruct(owner);
    }

    address internal owner; // owner of the contract
    address internal operator; // operator or control contract
    uint256 scrubTracker;
    uint256 scrubLength;
    uint256 hostingCost;
    address accountCollectionAddress;
    uint32 hostingContractCount;
    address[] hostingContractArray;
    mapping (address => hostingContract) hostingContracts;

    struct hostingContract {
        string mainContentHash;
        string hostingContractName;
        uint256 deployedBlockHeight;
        uint256 expirationBlockHeight;
        uint32 contractStorageUsed;
        string contentHashString;
        string contentPathString;
    }
    function ethoFSHostingContracts () public {
        owner = msg.sender;
        operator = msg.sender;
        hostingCost = 5000000000000000000;
        scrubTracker = 0;
        scrubLength = 100;
    }

    function ScrubContractList() public {
        uint i = scrubTracker;
        uint upperBound = scrubTracker + scrubLength;
        while (i < (hostingContractArray.length) && i < (upperBound)) {
            if(block.number > (hostingContracts[hostingContractArray[i]].expirationBlockHeight)) {
                RemoveHostingContractByIndex(i, hostingContractArray[i], accountCollectionAddress);
            }else{
	        HostingContract contractToUpdate = HostingContract(hostingContractArray[i]); 
                contractToUpdate.ContractPaymentCollection(accountCollectionAddress);
            }
            i++;
        }
        if(i >= hostingContractArray.length){
            scrubTracker = 0;
        }else{
            scrubTracker = i;
        }
    }

    function SetAccountCollectionAddress(address set) public onlyOwnerOrOperator {
        accountCollectionAddress = set;
    }
    function SetHostingContractCost(uint256 set) public onlyOwnerOrOperator {
        hostingCost = set;
    }
    function SetScrubLength(uint256 set) public onlyOwnerOrOperator {
        scrubLength = set;
    }
    function CalculateHostingContractCost(uint32 ContractSize, uint32 ContractDuration) internal returns (uint256 value) {
        return (((ContractSize / 1048576) * hostingCost) * (ContractDuration / 46522));
    }
/*
    function CreateHostingContract (string HostingContractName, uint256 contractCost, uint256 ExpirationBlockHeight) private payable returns(address value){
        HostingContract newContractAddress = (new HostingContract).value(msg.value)(HostingContractName, msg.sender, contractCost, ExpirationBlockHeight);
        return newContractAddress;
    } 
*/ 
    function AddHostingContract(string MainContentHash, string HostingContractName, uint32 HostingContractDuration, uint32 TotalContractSize, string ContentHashString, string ContentPathString) public onlyOwnerOrOperator payable returns(address NewContractAddress){
        uint256 calculatedHostingCost = CalculateHostingContractCost(TotalContractSize, HostingContractDuration);
        if(msg.value >= calculatedHostingCost) {
            HostingContract newContractAddress = (new HostingContract).value(msg.value)(address(this), HostingContractName, tx.origin, calculatedHostingCost, (block.number + HostingContractDuration));
            //address newContractAddress = CreateHostingContract.value(msg.value)(address(this), HostingContractName, calculatedHostingCost, (block.number + HostingContractDuration));
            hostingContract memory newHostingContract = hostingContract({mainContentHash:MainContentHash, hostingContractName:HostingContractName, deployedBlockHeight:block.number, expirationBlockHeight:block.number + HostingContractDuration, contractStorageUsed:TotalContractSize, contentHashString: ContentHashString, contentPathString: ContentPathString});
            hostingContracts[newContractAddress] = newHostingContract;
            hostingContractCount++;
            hostingContractArray.push(newContractAddress);
            return newContractAddress;
        }else {
            msg.sender.transfer(msg.value);
            return address(0x0);
        }
    }
/*
    function AddContentHash(address HostingContractAddress, string newContentHash, string newContentPath) public onlyOwnerOrOperator {
        hostingContracts[HostingContractAddress].contentHashMap[newContentHash] = newContentPath;
        hostingContracts[HostingContractAddress].contentHashArray.push(newContentHash);
        hostingContracts[HostingContractAddress].ContentHashCount++;
    }
*/
    function RemoveHostingContractByIndex(uint i, address HostingContractAddress, address AccountCollectionAddress) internal {
        HostingContract contractToDelete = HostingContract(HostingContractAddress);
        contractToDelete.deleteContract(AccountCollectionAddress);
        delete hostingContracts[HostingContractAddress];
        RemoveByIndex(i);
        hostingContractCount--;
    }
    function RemoveHostingContract(address customerAddress, address HostingContractAddress, address AccountCollectionAddress) public onlyOwnerOrOperator returns(bool) {
        HostingContract contractToDelete = HostingContract(HostingContractAddress);
        address compareAddress = contractToDelete.GetCustomerAddress();
        if(customerAddress == compareAddress){
            contractToDelete.deleteContract(AccountCollectionAddress);
            delete hostingContracts[HostingContractAddress];
            uint i = FindArrayKey(HostingContractAddress);
            RemoveByIndex(i);
            hostingContractCount--;
            return true;
        }else{
            return false;
        }
    }
    function ExtendHostingContract(address HostingContractAddress, uint32 HostingContractExtensionDuration) public onlyOwnerOrOperator payable {
        uint256 calculatedHostingCost = CalculateHostingContractCost(hostingContracts[HostingContractAddress].contractStorageUsed, HostingContractExtensionDuration);
        if(msg.value >= calculatedHostingCost) {
            uint256 currentExpirationBlockHeight = hostingContracts[HostingContractAddress].expirationBlockHeight;
            hostingContracts[HostingContractAddress].expirationBlockHeight = hostingContracts[HostingContractAddress].expirationBlockHeight + HostingContractExtensionDuration;
            HostingContract contractToUpdate = HostingContract(HostingContractAddress); 
            contractToUpdate.UpdateExpirationBlockHeight.value(msg.value)(currentExpirationBlockHeight + HostingContractExtensionDuration, accountCollectionAddress);
        }
    }
    function ChangeHostingContractName(address HostingContractAddress, string NewContractName) public onlyOwnerOrOperator {
        HostingContract contractToUpdate = HostingContract(HostingContractAddress);
        contractToUpdate.SetContractName(NewContractName);
    }
    function GetMainContentHash(address HostingContractAddress) public onlyOwnerOrOperator constant returns(string MainContentHash) {
        return hostingContracts[HostingContractAddress].mainContentHash;
    }
    function GetContentHashString(address HostingContractAddress) public onlyOwnerOrOperator constant returns(string ContentHashString) {
        return hostingContracts[HostingContractAddress].contentHashString;
    }
    function GetContentPathString(address HostingContractAddress) public onlyOwnerOrOperator constant returns(string ContentPathString) {
        return hostingContracts[HostingContractAddress].contentPathString;
    }
    function GetHostingContractDeployedBlockHeight(address HostingContractAddress) public onlyOwnerOrOperator constant returns(uint256 value) {
        return hostingContracts[HostingContractAddress].deployedBlockHeight;
    } 
    function GetHostingContractExpirationBlockHeight(address HostingContractAddress) public onlyOwnerOrOperator constant returns(uint256 value) {
        return hostingContracts[HostingContractAddress].expirationBlockHeight;
    } 
    function GetHostingContractStorageUsed(address HostingContractAddress) public onlyOwnerOrOperator constant returns(uint32 value) {
        return hostingContracts[HostingContractAddress].contractStorageUsed;
    }
    function GetHostingContractName(address HostingContractAddress) public onlyOwnerOrOperator constant returns(string value) {
        return hostingContracts[HostingContractAddress].hostingContractName;
    }
    function FindArrayKey(address HostingContactAddress) private constant returns (uint) {
        uint i = 0;
        while (keccak256(hostingContractArray[i]) != keccak256(HostingContactAddress)) {
            i++;
        }
        return i;
    }
    function RemoveByIndex(uint i) private {
        while ((hostingContractArray.length - 1) > i) {
            hostingContractArray[i] = hostingContractArray[i+1];
            i++;
        }
        hostingContractArray.length--;
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
