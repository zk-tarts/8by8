pragma solidity ^0.8.11;

// solhint ignore
import "ds-test/test.sol";

import "./pixelArt.sol";

interface cheat_vm {
    function ffi(string[] calldata) external returns (bytes memory);
}


contract ArtTest is DSTest {
    Art art;
    cheat_vm Vm = cheat_vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        art = new Art();
    }

    // tests if `svg()` function produces correct output
    function test_svg() public {
        uint before = 0xff81bdbdbdbd81ff007e667a624e7e00ffffff1b1b1be2e2e2919191;
        //uint before = 0x7e424242427e002438200c0000ffffff1b1b1be2e2e2919191;
        (uint64 a, uint64  b, uint96 c) = art.split(before);
        string memory svg = art.svg(a,b,c);
        string[] memory command = new string[](3);
        /*
        command[0] ="./get_output.sh";
        command[1] ="src/test_encode.py";
         */
        command[0] ="python3.10";
        command[1] ="src/test_encode.py";
        command[2] = svg;
        bytes memory ret = Vm.ffi(command);
        uint result = abi.decode(ret, (uint));
        assertTrue(result==before);
        }

    // tests if `split()` function properly splits 
    function test_equiv() public {
        uint64 b0 = 0xff81bdbdbdbd81ff;
        uint64 b1 = 0x007e667a624e7e00;
        uint96 cols =0xffffff1b1b1be2e2e2919191;
        (uint64 a, uint64  b, uint96 c) = art.split(0xff81bdbdbdbd81ff007e667a624e7e00ffffff1b1b1be2e2e2919191);
        assertTrue(a==b0 && b==b1 && c==cols);
    }
}