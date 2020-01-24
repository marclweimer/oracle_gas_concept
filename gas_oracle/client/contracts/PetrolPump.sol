pragma solidity ^0.5.12;

import "./Ownable.sol";
import "./OracleInterface.sol";


/// @title PetrolPump
/// @author John R. Kosinski modified by Marc Weimer for a proof of concept
/// @notice Takes money and interacts with oracle to operate petrol pump payments
contract PetrolPump is Ownable {

    //mappings
    mapping(address => bytes32[]) private userToPetroGrades;
    mapping(bytes32 => PetroGrade[]) private pumpToPetroGrades;

    //petropump oracle
    address internal petroPumpOracleAddr = address(0);
        OracleInterface internal petroPumpOracle = OracleInterface(petroPumpOracleAddr);

    //constants - payment made to hold cash while fuel is dispensed
    uint internal minimumHold = 1000000000000;

    struct PetroGrade {
        address user;
        bytes32 petrolGradeId;
        uint amount;
        
    }

    /// @notice determines whether or not the user has already paid for gas today
    /// @param _user address of a user
    /// @param _petrolGradeId id which is created based on grade, price and date in the oracle contract
    /// @return true if the given user has already purchased gas today
    function _PetroGradeIsValid(address _user, bytes32 _petrolGradeId) private view returns (bool) {

        return true;
    }

    /// @notice determines whether or not this grade of petrol can be sold today
    /// @param _petrolGradeId id of a petrol being sold that day
    /// @return true if the specific grade is in stock and can be sold
    function _gradeOpenForSale(_petrolGradeId);(bytes32 _petrolGradeId) private view returns (bool) {

        return true;
    }


    /// @notice gets a list ids of all available petrol for sale
    /// @param _petrolGradeId the id of the fuel grade for sale that day
    /// @return array of fuel grades for sale
    function getMatch(bytes32 _petrolGradeId) public view returns (
        bytes32 id,
        string memory name,
        uint price,
        uint date,
        OracleInterface.getPetroGrade name,
        ) {

        return petroPumpOracle.getPetroGrade(_petrolGradeId);
    }

    /// @notice places a non-rescindable deposit at the pump for fuel to be dispensed
    /// @param _petrolGradeId the id of the grade chosen for that day
    function placePetroGrade(bytes32 _petrolGradeId) public payable {

        //Up front deposit must be above a certain minimum
        require(msg.value >= minimumHold, "Initial Payment amount must be >= minimum hold");

        //make sure that grade choice exists
        require(petroPumpOracle.matchExists(_petrolGradeId), "Specified fuel grade not found");

        //require that chosen fuel grade is an option and available
        require(_PetroGradeIsValid(msg.sender, _petrolGradeId), "PetroGrade is not available");

        //transfer the money into the account
        address(this).transfer(msg.value);

        //add the new PetroGrade
        PetroGrade[] storage PetroGrades = pumpToPetroGrades[_petrolGradeId];
        PetroGrades.push(PetroGrade(msg.sender, _petrolGradeId, msg.value))-1;

        //add the mapping
        bytes32[] storage userPetroGrades = userToPetroGrades[msg.sender];
        userPetroGrades.push(_petrolGradeId);
    }

    /// @notice for testing; tests that the petrolpump oracle is callable
    /// @return true if connection successful
    function testOracleConnection() public view returns (bool) {
        return petroPumpOracle.testConnection();
    }

    /// @notice sets the address of the petrolpump oracle contract to use
    /// @dev setting a wrong address may result in false return value, or error
    /// @param _oracleAddress the address of the petrolpump oracle
    /// @return true if connection to the new oracle address was successful
    function setOracleAddress(address _oracleAddress) external onlyOwner returns (bool) {
        petroPumpOracleAddr = _oracleAddress;
        petroPumpOracle = OracleInterface(petroPumpOracleAddr);
        return petroPumpOracle.testConnection();
    }

    /// @notice gets the address of the petrolpump oracle being used
    /// @return the address of the currently set oracle
    function getOracleAddress() external view returns (address) {
        return petroPumpOracleAddr;
    }
}