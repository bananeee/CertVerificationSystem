// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

library Model {
    struct role {
        string id;
        string name;
    }

    struct rector {
        string name;
        string date;
        string phone;
        string term;
    }

    // Academic Affairs Department
    struct AADepartment {
        string realAddress; // dia chi PDT
        string description;
    }

    struct AADUser {
        string name;
        string date;
        string phone;
        bool isActive;
    }
    struct student {
        string id;
        string name;
        string email;
        string date;
        string phone;
        string class;
        string major;
        string cpa;
        bool qualifiedForGraduation;
        bool isActive;
        uint256 nonce;
    }

    struct company {
        uint256 id;
        string name;
        string description;
        string jobInfo;
        bool isActive;
    }

    struct certificate {
        uint256 id;
        string name; //tên bằng, bằng CNTT hoặc ĐTVT
        string cpa;
        string grade;
        uint256 timestamp;
        uint256 exportTime;
        uint256 NumOfExports;
        address issuer;
        // address recipient; // có cần trường này không?
        bool signed;
        bool visible;
    }
}
