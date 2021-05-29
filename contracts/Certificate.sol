// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./SetGrade.sol";
import "./Model.sol";
import "./User.sol";

contract Certificate {
    User private user;

    constructor(User _user) {
        user = _user;
    }

    Model.certificate[] certificateList;
    mapping(string => uint256[]) studentCerts;
    mapping(string => uint256) studentCertCount;
    mapping(uint256 => string) idToStudentId;
    mapping(uint256 => mapping(uint256 => bool)) companyInvisibleCert;
    mapping(uint256 => mapping(uint256 => bool)) idTocompanyInvisible;
    uint256 signedCertCount;
    uint256 visibleCertCount;

    using SetGrade for string;

    modifier onlyAADepartmentUser() {
        require(user.getAADepartmentUser(msg.sender).isActive == true);
        _;
    }

    modifier onlyCurrentRector() {
        require(msg.sender == user.currentRectorAddress());
        _;
    }

    modifier onlyStudent() {
        require(user.getStudentByAddr(msg.sender).isActive == true);
        _;
    }

    modifier isCertOwner(uint256 _id) {
        require(
            keccak256(abi.encodePacked(user.getStudentByAddr(msg.sender).id)) ==
                keccak256(abi.encodePacked(idToStudentId[_id]))
        );
        _;
    }

    modifier onlyRectorOrAAD() {
        require(
            msg.sender == user.currentRectorAddress() ||
                user.getAADepartmentUser(msg.sender).isActive == true
        );
        _;
    }

    //tao bang chinh thuc cho student
    function createCertificate(string memory _studentId)
        public
        onlyAADepartmentUser
    {
        //require(studentCertCount[_studentId] == 0); // chỉ tạo được bằng cho những sinh viên chưa được tạoo
        Model.certificate memory temp;
        temp.id = certificateList.length;
        temp.name = user.getStudentById(_studentId).major;
        temp.cpa = user.getStudentById(_studentId).cpa;
        temp.grade = SetGrade.setGrade(temp.cpa);
        temp.timestamp = block.timestamp;
        temp.NumOfExports = 0;
        temp.visible = false;

        certificateList.push(temp);
        studentCerts[_studentId].push(certificateList.length - 1);
        idToStudentId[certificateList.length - 1] = _studentId;
        studentCertCount[_studentId] += 1;
    }

    //tao bang kep cho student
    function createDoubleCertificate(
        string memory _studentId,
        string memory _name,
        string memory _cpa
    ) public onlyAADepartmentUser {
        Model.certificate memory temp;
        temp.id = certificateList.length;
        temp.name = _name;
        temp.cpa = _cpa;
        temp.grade = SetGrade.setGrade(_cpa);
        temp.timestamp = block.timestamp;
        temp.NumOfExports = 0;
        temp.visible = false;

        certificateList.push(temp);
        studentCerts[_studentId].push(certificateList.length - 1);
        idToStudentId[certificateList.length - 1] = _studentId;
        studentCertCount[_studentId] += 1;
    }

    function getStudentByCert(uint256 _id)
        public
        view
        returns (Model.student memory)
    {
        Model.student memory temp = user.getStudentById(idToStudentId[_id]);
        return temp;
    }

    function getStudentCertCount(string memory _studentId)
        public
        view
        returns (uint256)
    {
        return studentCertCount[_studentId];
    }

    function signCertificate(uint256 _index) public onlyCurrentRector {
        //require(certificateList[_index-1].siged == false); // chỉ ký được những chứng chỉ nào chưa ký
        require(certificateList[_index].signed == false);
        certificateList[_index].issuer = msg.sender;
        certificateList[_index].signed = true;
        certificateList[_index].visible = true;

        for (uint256 i = 0; i < user.getAllCompany().length; i++) {
            idTocompanyInvisible[_index][i] = false;
            companyInvisibleCert[i][_index] = false;
        }
        signedCertCount++;
        visibleCertCount++;
    }

    function signMultipleCert(uint256[] memory _ids) public onlyCurrentRector {
        for (uint256 i = 0; i < _ids.length; i++) {
            signCertificate(_ids[i]);
        }
    }

    // hàm này chạy lúc thằng student xem cer cuả nó
    function seeMyCertificate()
        public
        view
        onlyStudent
        returns (Model.certificate[] memory)
    {
        string memory studentId = user.getStudentByAddr(msg.sender).id;
        Model.certificate[] memory studentCertificates =
            new Model.certificate[](studentCertCount[studentId]);
        for (uint256 i = 0; i < studentCertCount[studentId]; i++) {
            studentCertificates[i] = certificateList[
                studentCerts[studentId][i]
            ];
        }
        return studentCertificates;
    }

    function changeCertVisibility(uint256 _index)
        public
        onlyStudent
        isCertOwner(_index)
    {
        certificateList[_index].visible = !certificateList[_index].visible;
        if (certificateList[_index].visible) {
            visibleCertCount++;
            for (uint i = 0; i < user.getAllCompany().length; i++) {
                companyInvisibleCert[i][_index] = false;
                idTocompanyInvisible[_index][i] = false;
            }
        } else {
            visibleCertCount--;
            for (uint i = 0; i < user.getAllCompany().length; i++) {
                companyInvisibleCert[i][_index] = true;
                idTocompanyInvisible[_index][i] = true;
            }
        }
    }

    // công ty check các bằng của 1 sinh viên
    function seeStudentCerts(string memory _studentId)
        public
        view
        returns (Model.certificate[] memory)
    {
        require(user.getCompanyByAddress(msg.sender).isActive == true);
        uint256 count = studentCerts[_studentId].length;
        Model.certificate[] memory studentCertificates =
            new Model.certificate[](count);
        for (uint256 i = 0; i < studentCerts[_studentId].length; i++) {
            if (certificateList[studentCerts[_studentId][i]].visible && !companyInvisibleCert[user.getCompanyByAddress(msg.sender).id][i])
                studentCertificates[i] = certificateList[
                    studentCerts[_studentId][i]
                ];
        }
        return studentCertificates;
    }

    // công ty xem cert công khai
    function seeVisibleCerts()
        public
        view
        returns (Model.certificate[] memory)
    {
        require(user.getCompanyByAddress(msg.sender).isActive == true);
        Model.certificate[] memory allVisibleCerts =
            new Model.certificate[](signedCertCount);
        uint256 count = 0;
        for (uint256 i = 0; i < certificateList.length; i++) {
            if (
                certificateList[i].visible &&
                !companyInvisibleCert[user.getCompanyByAddress(msg.sender).id][i]
            ) {
                allVisibleCerts[count] = certificateList[i];
                count++;
            }
        }
        return allVisibleCerts;
    }

    //nhà trường xem hết
    function seeAllCerts()
        public
        view
        onlyRectorOrAAD
        returns (Model.certificate[] memory)
    {
        return certificateList;
    }

    function getAADUser() public view returns (Model.AADUser memory) {
        return user.getAADepartmentUser(msg.sender);
    }

    function changeCompanyVisible(uint256 _companyId) public onlyStudent() {
        uint256 certId = studentCerts[user.getStudentByAddr(msg.sender).id][0];
        companyInvisibleCert[_companyId][certId] = !companyInvisibleCert[
            _companyId
        ][certId];
        idTocompanyInvisible[certId][_companyId] = !idTocompanyInvisible[
            certId
        ][_companyId];
    }

    function getCompanyVisibleById(uint256 _certId)
        public
        view
        isCertOwner(_certId)
        returns (bool, bool[] memory)
    {
        uint256 count = user.getAllCompany().length;
        bool[] memory result = new bool[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = !idTocompanyInvisible[_certId][i];
        }
        return (certificateList[_certId].visible, result);
    }
}
