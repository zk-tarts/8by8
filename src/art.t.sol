pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./pixelArt.sol";

contract ArtTest is DSTest {
    Art art;

    function setUp() public {
        art = new Art();
    }

    // tests if `svg()` function produces correct output
    function test_svg() public {
        (uint64 a, uint64  b, uint96 c) = art.split(0xff81bdbdbdbd81ff007e667a624e7e00ffffff1b1b1be2e2e2919191);
        art.svg(a,b,c);          
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