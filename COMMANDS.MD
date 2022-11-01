## `lc$offset [pos|rot] [axes] [values]`
Adds given values to *all* keyframes at given axis.\
`lc$offset pos x,y,z 0,10,0` will move all Y keyframes on 10 blocks upper.\
`lc$offset pos y 10` is same as previous, but shorter.

## `lc$set [value]`
Sets value of selected keyframe.

## `lc$add [value]`
Adds value to value of selected keyframe.

## `lc$sub [value]`
Subtracts value from value of selected keyframe.

## `lc$load [path_name]`
Loads path with given name.\
Loads data from file `[path_name].lcm`

## `lc$save [path_name]`
Saves current path.\
It can be found in LCamera data folder with name `[path_name].lcm`\
Cant overwrite existing file.

## `lc$force_save [path_name]`
Saves current path.\
It can be found in LCamera data folder with name `[path_name].lcm`

## `lc$go_to [timecode]`
Moves your pointer to given timecode.\
Bugged, need to fix that pointer brings always to keyframes (i really have no idea why it acts like that)