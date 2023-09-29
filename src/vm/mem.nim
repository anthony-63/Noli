type NoliMEM* = object
    exec*: seq[uint64]
    
    heap*: seq[uint64]
    heap_size*: uint64
    
    registers*: seq[uint64]
    reigsters_size*: uint64

    stack*: seq[uint64]
    sp*: uint64
    