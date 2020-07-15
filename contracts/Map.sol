pragma solidity ^0.6.8;


contract Map {

    mapping(uint256 => uint256) private s;

    uint256[] ss;

    function add(uint256 i, uint256 j) public {
        s[i] = j;
    }

    function getl(uint256 i) public view returns (uint256){
        return ss[s[i]];
    }

    function get(uint256 i) public view returns (uint256){
        return s[i];
    }

}