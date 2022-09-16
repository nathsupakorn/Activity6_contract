// SPDX-License-Identifier: Non-License
pragma solidity 0.8.15;

contract D {
    uint256 public n;
    address public sender;

    function callSetN(address _e, uint256 _n)
        public
        returns (bool success, bytes memory returndata)
    {
        (success, returndata) = _e.call(
            abi.encodePacked(bytes4(keccak256("setN(uint256)")), _n)
        ); // E's storage is set, D is not modified
    }

    /*
   callcode is depreciated
   function callcodeSetN(address _e, uint _n) public {
     _e.callcode(abi.encode(bytes4(keccak256("setN(uint256)")), _n)); // D's storage is set, E is not modified 
   }
   */

    function delegatecallSetN(address _e, uint256 _n)
        public
        returns (bool success, bytes memory returndata)
    {
        (success, returndata) = _e.delegatecall(
            abi.encodePacked(bytes4(keccak256("setN(uint256)")), _n)
        ); // D's storage is set, E is not modified
    }
}

contract E {
    uint256 public n;
    address public sender;

    function setN(uint256 _n) public {
        n = _n;
        sender = msg.sender;
        // msg.sender is D if invoked by D's callcodeSetN. None of E's storage is updated
        // msg.sender is C if invoked by C.foo(). None of E's storage is updated

        // the value of "this" is D, when invoked by either D's callcodeSetN or C.foo()
    }
}

contract C {
    function foo(
        D _d,
        E _e,
        uint256 _n
    ) public {
        _d.delegatecallSetN(address(_e), _n);
    }
}
