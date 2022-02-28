// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

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

    function split(uint data) public pure returns (uint64 bitplane_0,uint64 bitplane_1, uint96 colours) {
        bitplane_0 = uint64(data>>160);
        bitplane_1 = uint64(data>>96);
        colours = uint96(data);
    }

    /* Turns 8by8 pixel art into an svg.
    ** some
    ** more
    ** docs
    ** here
    */
    function svg(uint64 bitplane_0,uint64 bitplane_1, uint96 colours) public pure returns (string memory) {
        bytes[4] memory paths = [path(uint24(colours)),path(uint24(colours>>24)),path(uint24(colours>>48)),path(uint24(colours>>72))];
        // Since this is an 8 by 8 image, the position of any pixel will never be a number with more than one digit.
        // This simplifies the changing from a number to a character because the ASCII codes for numbers zero through nine is '0x30' to '0x39'
        uint n = 0x30;     // n:  the current paths length
        uint pn = 0x30;    // pn: the previous paths length
        uint n_sum = 0x30; // The paths x start coordinate
        uint y = 0x30;     // The y coordinate
        uint value;        // The colour of the current pixel. This gets calculated by adding the 
        uint prev = 64;    // the colour of the previous pixel. Initialized to some number that is more than 3 (the highest colour)
        unchecked {
            for (uint i = 64; i > 0;) {
                i-=1;
                // Get the current colour by adding the 'i'th bit of bitplane 0 and bitplane 1
                // The second bitplane is represents the most significant bit first represents least significant bit
                // I use OR to add because  the bits will never overlap so its the same as adding plus it's cooler
                value =((bitplane_0 >> i)&1) | (((bitplane_1 >> i)&1)<<1); 
                
                // This check passes at numbers 63, 55, 47, 39, 31, 23, 15, 7
                // At each of these positions, a new row has just begun
                if (i&7==7) { // i&7 is equivalent to 1%8 
                    n=0x30;
                }

                // while the value stays the same, we continue incrementing the current path length
                if (value != prev) {
                    n=0x31;
                }
                else {
                    n+=1;
                }

                // This branch is reached when a path has ended
                if (n != pn+1) {
                    // 0x4d = "M"
                    // 0x20 = " "
                    // 0x68 = "h"
                    paths[prev] = bytes.concat(paths[prev],bytes6(uint48(0x4d0020006800|(n_sum<<32)|(y<<16)|pn)));
                    
                    // the path starting x coordinate has to be reset after each 
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

