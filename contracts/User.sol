// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./SetGrade.sol";
import "./Model.sol";

contract User {
    constructor() {
        setRole();
        setRector();
        setAADepartmentAcc();
        Model.student memory student0 = Model.student("0","", "" , "", "", "", "", "", false, false, 0);
        studentList.push(student0);
    }

    Model.role[4] roleList;
    mapping(address => Model.role) userRole;

    function getCurrentUserRole() public view returns (Model.role memory) {
        return userRole[msg.sender];
    }

    function getCurrentUserRoleByAddr(address _addr)
        public
        view
        returns (Model.role memory)
    {
        Model.role memory roleTemp = userRole[_addr];
        return roleTemp;
    }

    function getCurrentUser()
        public
        view
        returns (
            Model.rector memory,
            Model.AADUser memory,
            Model.student memory,
            Model.company memory
        )
    {
        if (
            keccak256(abi.encodePacked(userRole[msg.sender].id)) ==
            keccak256(abi.encodePacked("0"))
        ) {
            return (
                rectorDetail[msg.sender],
                getAADepartmentUser(msg.sender),
                getStudentByAddr(msg.sender),
                getCompanyByAddress(msg.sender)
            );
        } else if (
            keccak256(abi.encodePacked(userRole[msg.sender].id)) ==
            keccak256(abi.encodePacked("1"))
        ) {
            return (
                rectorDetail[msg.sender],
                getAADepartmentUser(msg.sender),
                getStudentByAddr(msg.sender),
                getCompanyByAddress(msg.sender)
            );
        } else if (
            keccak256(abi.encodePacked(userRole[msg.sender].id)) ==
            keccak256(abi.encodePacked("2"))
        ) {
            return (
                rectorDetail[msg.sender],
                getAADepartmentUser(msg.sender),
                getStudentByAddr(msg.sender),
                getCompanyByAddress(msg.sender)
            );
        } else if (
            keccak256(abi.encodePacked(userRole[msg.sender].id)) ==
            keccak256(abi.encodePacked("3"))
        ) {
            return (
                rectorDetail[msg.sender],
                getAADepartmentUser(msg.sender),
                getStudentByAddr(msg.sender),
                getCompanyByAddress(msg.sender)
            );
        }
    }

    // modifier onlyUser(address _address) {
    //     require(msg.sender == _address || msg.sender == currentRectorAddress);
    //     _;
    // }

    modifier onlyNoRole(address _address) {
        require(
            keccak256(abi.encodePacked(userRole[_address].id)) ==
                keccak256(abi.encodePacked(""))
        );
        _;
    }

    function setRole() private {
        roleList[0] = (Model.role("0", "rector"));
        roleList[1] = (Model.role("1", "AADepartment"));
        roleList[2] = (Model.role("2", "student"));
        roleList[3] = (Model.role("3", "company"));
    }

    address public currentRectorAddress;

    mapping(address => Model.rector) rectorDetail;

    modifier onlyCurrentRector() {
        require(msg.sender == currentRectorAddress);
        _;
    }

    function setRector() private {
        Model.rector memory rectorTemp;
        rectorTemp.name = "PGS TS Nguyen Viet Ha";
        rectorTemp.date = "1974";
        rectorTemp.phone = "0989152252";
        rectorTemp.term = "from 2014";
        rectorDetail[msg.sender] = rectorTemp;
        userRole[msg.sender] = roleList[0];

        currentRectorAddress = msg.sender;
    }

    function getCurrentRector() public view returns (Model.rector memory) {
        Model.rector memory currentRector = rectorDetail[currentRectorAddress];
        return currentRector;
    }

    function createNewRector(
        address _newRectorAddr,
        string memory _name,
        string memory _date,
        string memory _phone,
        string memory _term
    ) public onlyCurrentRector onlyNoRole(_newRectorAddr) {
        Model.rector memory newRector =
            Model.rector(_name, _date, _phone, _term);

        rectorDetail[_newRectorAddr] = newRector;
        userRole[_newRectorAddr] = roleList[0];

        currentRectorAddress = _newRectorAddr;
    }

    function updateCurrentRector(
        string memory _name,
        string memory _date,
        string memory _phone,
        string memory _term
    ) public onlyCurrentRector {
        rectorDetail[msg.sender].name = _name;
        rectorDetail[msg.sender].date = _date;
        rectorDetail[msg.sender].phone = _phone;
        rectorDetail[msg.sender].term = _term;
    }

    Model.AADepartment AADepartmentAcc;

    Model.AADUser[] AADUserList;
    mapping(address => Model.AADUser) AADUsers;
    mapping(uint256 => address) ADDUserIdToAddr;

    modifier onlyAADepartmentUser() {
        require(AADUsers[msg.sender].isActive == true);
        _;
    }

    modifier onlyRectorOrAAD() {
        require(
            msg.sender == currentRectorAddress ||
                AADUsers[msg.sender].isActive == true
        );
        _;
    }

    function setAADepartmentAcc() private {
        AADepartmentAcc.realAddress = "E3 144 Xuan Thuy - Cau Giay - Ha Noi";
        AADepartmentAcc
            .description = " tham muu giup viec Hieu truong thuc hien cong tac ve xay dung, quan ly cac chuong trinh dao tao";
    }

    function getAADepartmentAcc()
        public
        view
        returns (Model.AADepartment memory)
    {
        return AADepartmentAcc;
    }

    function createAADepartmentUser(
        address _address,
        string memory _name,
        string memory _date,
        string memory _phone
    ) public onlyRectorOrAAD onlyNoRole(_address) {
        Model.AADUser memory temp = Model.AADUser(_name, _date, _phone, true);
        AADUserList.push(temp);
        ADDUserIdToAddr[AADUserList.length - 1] = _address;
        AADUsers[_address] = temp;

        userRole[_address] = roleList[1];
    }

    function updateAADepartmentUser(
        string memory _name,
        string memory _date,
        string memory _phone
    ) public {
        require(AADUsers[msg.sender].isActive == true);
        AADUsers[msg.sender].name = _name;
        AADUsers[msg.sender].date = _date;
        AADUsers[msg.sender].phone = _phone;
    }

    function deactiveAADepartmentUser(uint256 _AADUserId)
        public
        onlyRectorOrAAD
    {
        AADUserList[_AADUserId].isActive = false;
        AADUsers[ADDUserIdToAddr[_AADUserId]].isActive = false;
    }

    function getAADepartmentUser(address _userAddress)
        public
        view
        returns (Model.AADUser memory)
    {
        return AADUsers[_userAddress];
    }

    function getAllAADepartmentUsers()
        public
        view
        returns (Model.AADUser[] memory)
    {
        return AADUserList;
    }

    Model.student[] studentList;
    mapping(address => uint256) addressToStudent;
    mapping(string => uint256) idToStudent;

    uint256 qualifiedStudentNumber;

    modifier onlyStudent() {
        require(studentList[addressToStudent[msg.sender]].isActive == true);
        _;
    }

    function createStudent(
        string memory _id,
        string memory _name,
        string memory _email,
        string memory _date,
        string memory _phone,
        string memory _class,
        string memory _major,
        string memory _cpa,
        bool _qualifiedForGraduation
    ) public onlyAADepartmentUser {
        require(
            keccak256(abi.encodePacked(studentList[idToStudent[_id]].id)) !=
                keccak256(abi.encodePacked(_id)),
            string(abi.encodePacked("Student ", _id, " already exists"))
        );
        Model.student memory studentTemp =
            Model.student(
                _id,
                _name,
                _email,
                _date,
                _phone,
                _class,
                _major,
                _cpa,
                _qualifiedForGraduation,
                false,
                uint256(
                    keccak256(
                        abi.encodePacked(_id, block.timestamp, block.difficulty)
                    )
                )
            );
        studentList.push(studentTemp);
        idToStudent[_id] = studentList.length - 1;
        if (studentList[studentList.length - 1].qualifiedForGraduation) {
            qualifiedStudentNumber++;
        }
    }

    function importStudent(Model.student[] memory students)
        public
        onlyAADepartmentUser
    {
        for (uint256 i = 0; i < students.length; i++) {
            createStudent(
                students[i].id,
                students[i].name,
                students[i].email,
                students[i].date,
                students[i].phone,
                students[i].class,
                students[i].major,
                students[i].cpa,
                students[i].qualifiedForGraduation
            );
        }
    }

    function activeStudent(string memory _id, uint256 _nonce)
        public
        onlyNoRole(msg.sender)
    {
        require(_nonce == studentList[idToStudent[_id]].nonce);
        addressToStudent[msg.sender] = idToStudent[_id];
        studentList[idToStudent[_id]].isActive = true;
        userRole[msg.sender] = roleList[2];
    }

    function getAllStudent()
        public
        view
        onlyRectorOrAAD
        returns (Model.student[] memory)
    {
        return studentList;
    }

    function getStudentById(string memory _id)
        public
        view
        returns (Model.student memory)
    {
        Model.student memory studentTemp = studentList[idToStudent[_id]];
        studentTemp.nonce = 0;
        return studentTemp;
    }

    function getStudentByAddr(address _studentAddr)
        public
        view
        returns (Model.student memory)
    {
        Model.student memory studentTemp =
            studentList[addressToStudent[_studentAddr]];
        studentTemp.nonce = 0;
        return studentTemp;
    }

    function getStudentNonce(string memory _id)
        public
        view
        onlyRectorOrAAD
        returns (uint256)
    {
        return studentList[idToStudent[_id]].nonce;
    }

    function updateStudentbyAAD(
        string memory _currentId,
        string memory _id,
        string memory _name,
        string memory _email,
        string memory _date,
        string memory _phone,
        string memory _class,
        string memory _major,
        string memory _cpa,
        bool _qualifiedForGraduation
    ) public onlyRectorOrAAD {
        Model.student storage temp = studentList[idToStudent[_currentId]];
        if (
            keccak256(abi.encodePacked(_currentId)) !=
            keccak256(abi.encodePacked(_id))
        ) {
            require(
                keccak256(abi.encodePacked(studentList[idToStudent[_id]].id)) !=
                    keccak256(abi.encodePacked(_id)),
                string(abi.encodePacked("Student ", _id, " already exists"))
            );
            idToStudent[_id] = idToStudent[_currentId];
            idToStudent[_currentId] = idToStudent["0"];
            temp.id = _id;
        }
        temp.name = _name;
        temp.email = _email;
        temp.date = _date;
        temp.phone = _phone;
        temp.class = _class;
        temp.major = _major;
        temp.cpa = _cpa;
        if (temp.qualifiedForGraduation && !_qualifiedForGraduation) {
            qualifiedStudentNumber--;
        }
        if (!temp.qualifiedForGraduation && _qualifiedForGraduation) {
            qualifiedStudentNumber++;
        }
        temp.qualifiedForGraduation = _qualifiedForGraduation;
    }

    function updateStudentInfo(string memory _email, string memory _phone)
        public
    {
        require(studentList[addressToStudent[msg.sender]].isActive == true);
        studentList[addressToStudent[msg.sender]].email = _email;
        studentList[addressToStudent[msg.sender]].phone = _phone;
    }

    function getQualifiedStudents()
        public
        view
        returns (Model.student[] memory)
    {
        Model.student[] memory qualifiedStudent =
            new Model.student[](qualifiedStudentNumber);
        uint256 count = 0;
        for (uint256 i = 0; i < studentList.length; i++) {
            if (studentList[i].qualifiedForGraduation) {
                qualifiedStudent[count] = studentList[i];
                count++;
            }
        }
        return qualifiedStudent;
    }

    Model.company[] companyList;
    mapping(address => Model.company) companyDetails;
    mapping(uint256 => address) companyIdToAddr;

    function createCompany(string memory _name, string memory _description)
        public
        onlyNoRole(msg.sender)
    {
        Model.company memory companyTemp =
            Model.company(companyList.length, _name, _description, "", false);

        companyList.push(companyTemp);
        companyIdToAddr[companyList.length - 1] = msg.sender;
        companyDetails[msg.sender] = companyTemp;
        userRole[msg.sender] = roleList[3];
    }

    function approveCompany(uint256 _companyId) public onlyAADepartmentUser {
        companyList[_companyId].isActive = true;
        companyDetails[companyIdToAddr[_companyId]].isActive = true;
    }

    function updateCompany(
        string memory _name,
        string memory _description,
        string memory _jobInfo
    ) public {
        companyDetails[msg.sender].name = _name;
        companyDetails[msg.sender].description = _description;
        companyDetails[msg.sender].jobInfo = _jobInfo;
    }

    function getCompanyByAddress(address _companyAddr)
        public
        view
        returns (Model.company memory)
    {
        Model.company memory companyTemp = companyDetails[_companyAddr];
        return companyTemp;
    }

    function getCompanybyId(uint256 _companyId)
        public
        view
        returns (Model.company memory)
    {
        Model.company memory companyTemp =
            companyDetails[companyIdToAddr[_companyId]];
        return companyTemp;
    }

    function getAllCompany() public view returns (Model.company[] memory) {
        return companyList;
    }
}
