// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

library SetGrade{
    function setGrade(string memory _cpa) public pure returns (string memory){
        uint temp = stringToUint(_cpa);
        string memory _grade;
        if (temp >= 360 && temp <= 400) {
            _grade = "Excellent";
        } else if ( temp >= 320 && temp < 360) {
            _grade = "Good";
        } else if (temp >= 250 && temp < 320){
            _grade = "Credit";
        }

        return _grade;
    }


    function stringToUint(string memory _amount) public pure returns (uint result) {
        bytes memory b = bytes(_amount);
        uint i;
        uint counterBeforeDot;
        uint counterAfterDot;
        result = 0;
        uint totNum = b.length;
        totNum--;
        bool hasDot = false;


        //trường hợp không có dấu
        if(b.length == 1){
            uint c = uint(uint8(b[0]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
                return result *100;
            }
        }

        for (i = 0; i < b.length; i++) {
            uint c = uint(uint8(b[i]));

            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
                counterBeforeDot ++;
                totNum--;
            }

            if(c == 46){
                hasDot = true;
                break;
            }
        }

        if(hasDot) {
            for (uint j = counterBeforeDot + 1; j < 18; j++) {
                uint m = uint(uint8(b[j]));

                if (m >= 48 && m <= 57) {
                    result = result * 10 + (m - 48);
                    counterAfterDot ++;
                    totNum--;
                }

                if(totNum == 0){
                    break;
                }
            }
            if(counterAfterDot < 2){
                uint addNum = 2 - counterAfterDot;
                uint multuply = 10 ** addNum;
                return result = result * multuply;
            }
        }

        return result;
    }
}
