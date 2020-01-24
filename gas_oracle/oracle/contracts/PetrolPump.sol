pragma solidity ^0.5.12;

import "./Ownable.sol";
import "./DateLib.sol";

/// @title petrolPump
/// @author John R. Kosinski modified by Marc Weimer for a proof of concept
/// @notice Collects and provides information on a hypethetical petrol prices and interacts with an IoT device 
contract petrolPump is Ownable {
    petrolGrade[] petrolGrades; 
    mapping(bytes32 => uint) petrolGradeIdToIndex; 

    using DateLib for DateLib.DateTime;


    //defines a petrol grade along with its price for the day
    struct petrolGrade {
        bytes32 id;
        string name;
        uint price;
        uint date; 
    }

    /// @notice returns the array index of the petrolGrade with the given id 
    /// @dev if the petrolGrade id is invalid, then the return value will be incorrect and may cause error; you must call petrolGradeExists(_petrolGradeId) first!
    /// @param _petrolGradeId the petrolGrade id to get
    /// @return an array index 
    function _getpetrolGradeIndex(bytes32 _petrolGradeId) private view returns (uint) {
        return petrolGradeIdToIndex[_petrolGradeId]-1; 
    }


    /// @notice determines whether a petrolGrade exists with the given id 
    /// @param _petrolGradeId the petrolGrade id to test
    /// @return true if petrolGrade exists and id is valid
    function petrolGradeExists(bytes32 _petrolGradeId) public view returns (bool) {
        if (petrolGrades.length == 0)
            return false;
        uint index = petrolGradeIdToIndex[_petrolGradeId]; 
        return (index > 0); 
    }

    /// @notice puts a new pending petrolGrade into the blockchain 
    /// @param _name descriptive name for the petrolGrade (e.g. Pac vs. Mayweather 2016)
    /// @param _price | uint price per gallon for the current time
    /// @param _date date set for the petrolGrade price
    /// @return the unique id of the newly created petrolGrade for that specific transaction
    function addpetrolGrade(string memory _name, string memory _price, uint _date) onlyOwner public returns (bytes32) {

        //hash the crucial info to get a unique id 
        bytes32 id = keccak256(abi.encodePacked(_name, _price, _date)); 

        //require that the petrolGrade be unique (not already added) 
        require(!petrolGradeExists(id));
        
        //add the petrolGrade 
        uint newIndex = petrolGrades.push(petrolGrade(id, _name, _price, _date))-1; 
        petrolGradeIdToIndex[id] = newIndex+1;
        
        //return the unique id of the new petrolGrade for that specific transaction
        return id;
    }

    /// @notice gets the unique ids of petrolGrades, in reverse chronological order
    /// @return an array of unique petrolGrade ids
    function getAllpetrolGrades() public view returns (bytes32[] memory) {
        bytes32[] memory output = new bytes32[](petrolGrades.length); 

        //get all ids 
        if (petrolGrades.length > 0) {
            uint index = 0;
            for (uint n = petrolGrades.length; n > 0; n--) {
                output[index++] = petrolGrades[n-1].id;
            }
        }
        
        return output; 
    }

    /// @notice gets the specified petrolGrade in a format that can help track sales for the day using unique IDs
    /// @param _petrolGradeId the unique id of the desired petrolGrade for that specific date
    /// @return petrolGrade data of the specified petrolGrade 
    function getpetrolGrade(bytes32 _petrolGradeId) public view returns (
        bytes32 id,
        string memory name, 
        uint price,
        uint date
        ) {
        
        //get the petrolGrade 
        if (petrolGradeExists(_petrolGradeId)) {
            petrolGrade storage thepetrolGrade = petrolGrades[_getpetrolGradeIndex(_petrolGradeId)];
            return (thepetrolGrade.id, thepetrolGrade.name, thepetrolGrade.price); 
        }
        else {
            return (msg.sender == address, "Transaction not Authorized"); 
        }
    }

    /// @notice can be used by a client contract to ensure that they've connected to this contract interface successfully
    /// @return true, unconditionally 
    function testConnection() public pure returns (bool) {
        return true; 
    }

    /// @notice gets the address of this contract 
    /// @return address 
    function getAddress() public view returns (address) {
        return address(this);
    }

    /// @notice for testing, this is essentially the purpose of the oracle contract
    /// provides a list of the petrol options and their price
    /// ideally, you would develope Web3 front end to inject pricing into the contract based on market demand
    function addTestData() external onlyOwner {
        addpetrolGrade("Basic Unleaded", 2.1, DateLib.DateTime(now).toUnixTimestamp());
        addpetrolGrade("Plus", 2.3, DateLib.DateTime(now).toUnixTimestamp());
        addpetrolGrade("Premium", 2.6, DateLib.DateTime(now).toUnixTimestamp());
    }
}