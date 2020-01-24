pragma solidity ^0.5.12;

contract OracleInterface {

    function getAllPetroGrades() public view returns (bytes32[] memory);

    function petrolGradeExists(bytes32 _petrolGradeId) public view returns (bool);

    function getPetroGrade(bytes32 _petrolGradeId) public view returns (
        bytes32 id,
        string memory name,
        uint price,
        uint date);

    function testConnection() public pure returns (bool);

    function addTestData() public;
}