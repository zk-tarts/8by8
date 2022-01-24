// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract Art {
    bytes16 constant hex_chars = "0123456789abcdef";
    function path(uint24 colour) internal pure returns (bytes memory) {
        bytes memory b = new bytes(6);
        unchecked{
        for (uint i = 6; i >= 1; --i) {
            b[i-1] = hex_chars[colour & 0xf];
            colour >>= 4;
        }}
        return bytes.concat('<path stroke="#',b,'" d="');
    }

    // TODO: make this work
    function split(uint data) public pure returns (uint64 bitplane_0,uint64 bitplane_1, uint96 colours) {
        bitplane_0 = uint64(data>>160);
        bitplane_1 = uint64(data>>96);
        colours = uint96(data);
    }

    // turns 8by8 pixel art into an svg
    // could maybe generalize to bigger pictures but decided to "start small"
    // after struggling so much with this maybe not, I think i'm literally 1 variable away from stack too deep
    function svg(uint64 bitplane_0,uint64 bitplane_1, uint96 colours) public pure returns (string memory) {
        bytes[4] memory paths = [path(uint24(colours)),path(uint24(colours>>24)),path(uint24(colours>>48)),path(uint24(colours>>72))];
        uint n = 0x30;
        uint pn = 0x30;
        uint n_sum = 0x30;
        uint y = 0x30;
        uint value;
        uint prev = 64; // some number higher than the max colour value (3)
        unchecked {
            for (uint i = 64; i > 0;) {
                i-=1;
                value =((bitplane_0 >> i)&1) | (((bitplane_1 >> i)&1)<<1);
                if (i&7==7) {
                    n=0x30;
                }
                if (value != prev) {
                    n=0x31;
                }
                else {
                    n+=1;
                }

                // 0x4d = "M"
                // 0x20 = " "
                // 0x68 = "h"
                if (n != pn+1) {
                    paths[prev] = bytes.concat(paths[prev],bytes6(uint48(0x4d0020006800|(n_sum<<32)|(y<<16)|pn)));
                    n_sum = 0x30 + ((n_sum+pn)&7);
                    if (n_sum == 0x30) {
                        y+=1;
                    }
                }
                prev = value; 
                pn=n;
            }
            paths[value] = bytes.concat(paths[value],bytes6(uint48(0x4d0020006800|(n_sum<<32)|(y<<16)|n)));
            
        }

        bytes memory end = ' "/>\n';
        bytes memory res = bytes.concat('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 -0.5 8 8" shape-rendering="crispEdges">\n',
         paths[0],end, paths[1],end, paths[2],end, paths[3],end, '</svg>');
        return string(res);
    }

}

