import sys, subprocess, re
from itertools import chain
string = sys.argv[1]

# 'M' marks the next 2 numbers as the starting x and y coordinates 
# 'h' marks the next number as the distance to go horizontally
# but the way this actually works is unimportant, I can skip every character thats not a number and just rely on the pattern of cycling around x then y then horizontal distance

colours = re.findall("(?<=#)((?:[0-9]|[a-f]){6})",string) # gets all the colours
paths = re.findall('(?<=d=")([^/]*)(?= ")',string) # gets all the paths


left_plane = [[0 for i in range(8)] for i in range(8)]
right_plane = [[0 for i in range(8)] for i in range(8)]
for n,path in enumerate(paths):
    stage = 0
    coords = [0,0]
    for char in path:
        if char not in [str(i) for i in range(9)]:
            continue
        else:
            match stage:
                case 0 | 1:
                    # x or y coordinate being read
                    coords[stage] = int(char)
                case 2:
                    # distance being read
                    x,y = coords
                    for i in range(int(char)):
                        left_plane[y][x+i] = n&1
                        right_plane[y][x+i] = (n&2)>>1
            
            stage = (stage+1)%3
    
# flatten the lists
left_plane = list(chain.from_iterable(left_plane))
right_plane = list(chain.from_iterable(right_plane))

res ="0x"
for plane in [left_plane,right_plane]:
    tmp = []
    for i,bit in enumerate(plane,1):
        tmp.append(str(bit))
        if i%4==0:
            binary_string= "".join(tmp)
            res+=hex(int(binary_string,2))[2:]
            tmp=[]
res+="".join(colours)
res= str(int(res,16))
subprocess.run(["cast","abi-encode","f(uint)",res])