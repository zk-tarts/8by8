pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./Game.sol";

contract GameTest is DSTest {
    Game game;

    function setUp() public {
        game = new Game();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
