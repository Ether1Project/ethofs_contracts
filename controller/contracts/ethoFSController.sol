pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

interface ethoFSDashboard {
    function SetAccountCollectionAddress(address set) external;
    function AddNewUser(address UserAddress, string AccountName) external;
    function RemoveUser(address UserAddress) external;
    function AddHostingContract(address newContractAddress, address UserAddress, string HostingContractName, uint32 HostingContractDuration, uint32 TotalContractSize) external;
    function RemoveHostingContract(address UserAddress, address HostingContractAddress) external; 
    function GetUserAccountAddress(address UserAddress) external returns(address value);
    function GetUserAccountName(address UserAddress) external returns(string value);
    function GetUserAccountActiveContractCount(address UserAddress) external returns(uint32 value); 
    function GetUserAccountTotalContractCount(address UserAddress) external returns(uint32 value); 
    function GetHostingContractAddress(address UserAddress, uint ArrayKey) external returns(address value);
    function CheckAccountExistence(address UserAddress) external returns(bool);
}
interface ethoFSHostingContracts {
    function ScrubContractList() external;
    function SetHostingContractCost(uint256 set) external;
    //function AddContentHash(uint32 HostingContractAddress, string newContentHash, string newContentPath) external;
    function ExtendHostingContract(address HostingContractAddress, uint32 HostingContractExtensionDuration) external payable;
    function GetMainContentHash(address HostingContractAddress) external returns(string MainContentHash);
    function GetContentHashString(address HostingContractAddress) external returns(string ContentHashString);
    function GetContentPathString(address HostingContractAddress) external returns(string ContentPathString);
    //function GetContentHashCount(uint32 HostingContractAddress) external returns(uint32 value);
    function GetHostingContractDeployedBlockHeight(address HostingContractAddress) external returns(uint256 value);
    function GetHostingContractExpirationBlockHeight(address HostingContractAddress) external returns(uint256 value);
    function GetHostingContractStorageUsed(address HostingContractAddress) external returns(uint32 value);
    function GetHostingContractName(address HostingContractAddress) external returns(string value);
    function AddHostingContract(string MainContentHash, string HostingContractName, uint32 HostingContractDuration, uint32 TotalContractSize, string ContentHashString, string ContentPathString) external payable returns(address value);
    function RemoveHostingContract(address CustomerAddress, address HostingContractAddress, address AccountCollectionAddress) external returns(bool value);
    function SetAccountCollectionAddress(address AccountCollectionAddress) external;
}
interface PinStorage {
    function PinAdd(string pinToAdd, uint32 pinSize) external;
    function PinRemove(string pin) external;
}
contract ethoFSController {
    function deleteContract() public onlyOwner {
        selfdestruct(owner);
    }

    address internal owner; // owner of the contract
    address internal operator; // operator or control contract
    address AccountCollectionAddress;
    PinStorage internal PinStorageAddress;
    ethoFSDashboard internal EthoFSDashboardAddress;
    ethoFSHostingContracts internal EthoFSHostingContractsAddress;
    uint256 public HostingCost;

//    constructor (address pinStorageAddress, address ethoFSDashboardAddress, address ethoFSHostingContractsAddress) public {
    constructor () public {
        owner = msg.sender;
        operator = msg.sender;
        HostingCost = 10000000000000000000;    
        //PinStorageAddress = PinStorage(pinStorageAddress);
        //EthoFSDashboardAddress = ethoFSDashboard(ethoFSDashboardAddress);
        //EthoFSHostingContractsAddress = ethoFSHostingContracts(ethoFSHostingContractsAddress);
    }
    
    function SetAccountCollectionAddress(address set) public onlyOwner {
        EthoFSHostingContractsAddress.SetAccountCollectionAddress(set);
        EthoFSDashboardAddress.SetAccountCollectionAddress(set);
        AccountCollectionAddress = set;
    }
    function SetHostingCost(uint256 hostingCost) public onlyOwner {
        EthoFSHostingContractsAddress.SetHostingContractCost(hostingCost);
        HostingCost = hostingCost;
    }
    function SetPinStorageAddress(address pinStorageAddress) public onlyOwner {
        PinStorageAddress = PinStorage(pinStorageAddress);
    }
    function SetEthoFSDashboardAddress(address ethoFSDashboardAddress) public onlyOwner {
        EthoFSDashboardAddress = ethoFSDashboard(ethoFSDashboardAddress);
    }
    function SetEthoFSHostingContractsAddress(address ethoFSHostingContractsAddress) public onlyOwner {
        EthoFSHostingContractsAddress = ethoFSHostingContracts(ethoFSHostingContractsAddress);
    }
    function AddNewUserOwner(address UserAddress, string memory AccountName) public onlyOwner{
        EthoFSDashboardAddress.AddNewUser(UserAddress, AccountName);
    }
    function AddNewUserPublic(string memory AccountName) public {
        EthoFSDashboardAddress.AddNewUser(msg.sender, AccountName);
    }
    function RemoveUserOwner(address UserAddress) public onlyOwner {
        EthoFSDashboardAddress.RemoveUser(UserAddress);
    }
    function RemoveUserPublic() public {
        EthoFSDashboardAddress.RemoveUser(msg.sender);
    }
    function AddNewContract(string MainContentHash, string memory HostingContractName, uint32 HostingContractDuration, uint32 TotalContractSize, uint32 pinSize, string ContentHashString, string ContentPathString) public payable{
        address newContractAddress = EthoFSHostingContractsAddress.AddHostingContract.value(msg.value)(MainContentHash, HostingContractName, HostingContractDuration, TotalContractSize, ContentHashString, ContentPathString);
        if(newContractAddress != address(0x0)){
            EthoFSDashboardAddress.AddHostingContract(newContractAddress, msg.sender, HostingContractName, HostingContractDuration, TotalContractSize);
            PinStorageAddress.PinAdd(MainContentHash, pinSize);
        }
        ScrubHostingContracts();
    }
    function RemoveHostingContract(address HostingContractAddress, string MainContentHash) public{
        bool accountCheck = EthoFSHostingContractsAddress.RemoveHostingContract(msg.sender, HostingContractAddress, AccountCollectionAddress);
        if(accountCheck == true){
            EthoFSDashboardAddress.RemoveHostingContract(msg.sender, HostingContractAddress);
            PinStorageAddress.PinRemove(MainContentHash);
        }
        ScrubHostingContracts();
    }
    function ExtendContract(address HostingContractAddress, uint32 HostingContractExtensionDuration) public payable{
        EthoFSHostingContractsAddress.ExtendHostingContract.value(msg.value)(HostingContractAddress, HostingContractExtensionDuration);
        ScrubHostingContracts();
    }
    function ScrubHostingContracts() public {
        EthoFSHostingContractsAddress.ScrubContractList();
    }
    function GetUserAccountName(address UserAddress) public view returns(string value){
        return EthoFSDashboardAddress.GetUserAccountName(UserAddress);
    }
    function GetUserAccountActiveContractCount(address UserAddress) public view returns(uint32 value){
        return EthoFSDashboardAddress.GetUserAccountActiveContractCount(UserAddress);
    }
    function GetUserAccountTotalContractCount(address UserAddress) public view returns(uint32 value){
        return EthoFSDashboardAddress.GetUserAccountTotalContractCount(UserAddress);
    }
    function GetHostingContractAddress(address UserAddress, uint ArrayKey) public view returns(address value){
        return EthoFSDashboardAddress.GetHostingContractAddress(UserAddress, ArrayKey);
    }
    function CheckAccountExistence(address UserAddress) public view returns(bool){
        return EthoFSDashboardAddress.CheckAccountExistence(UserAddress);
    }
    function GetMainContentHash(address HostingContractAddress) public view returns(string MainContentHash){
        return EthoFSHostingContractsAddress.GetMainContentHash(HostingContractAddress);
    }
    function GetContentHashString(address HostingContractAddress) public view returns(string ContentHashString){
        return EthoFSHostingContractsAddress.GetContentHashString(HostingContractAddress);
    }
    function GetContentPathString(address HostingContractAddress) public view returns(string ContentPathString){
        return EthoFSHostingContractsAddress.GetContentPathString(HostingContractAddress);
    }
    function GetHostingContractDeployedBlockHeight(address HostingContractAddress) public view returns(uint256 value){
        return EthoFSHostingContractsAddress.GetHostingContractDeployedBlockHeight(HostingContractAddress);
    }
    function GetHostingContractExpirationBlockHeight(address HostingContractAddress) public view returns(uint256 value){
        return EthoFSHostingContractsAddress.GetHostingContractExpirationBlockHeight(HostingContractAddress);
    }
    function GetHostingContractStorageUsed(address HostingContractAddress) public view returns(uint32 value){
        return EthoFSHostingContractsAddress.GetHostingContractStorageUsed(HostingContractAddress);
    }
    function GetHostingContractName(address HostingContractAddress) public view returns(string value){
        return EthoFSHostingContractsAddress.GetHostingContractName(HostingContractAddress);
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
