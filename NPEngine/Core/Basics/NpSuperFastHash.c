#include <stdint.h>
#include <stdlib.h>

#include "NpHashFunctions.h"
 
#define get16bits(d) (*((const uint16_t *) (d)))

UInt32 SuperFastHash (const char * data, UInt32 length)
{
    UInt32 hash = length, tmp;
    int remaining;

    if (length == 0 || data == NULL)
    {
        return 0;
    }

    remaining = length & 3;
    length >>= 2;

    /* Main loop */
    for (;length > 0; length--)
    {
        hash  += get16bits (data);
        tmp    = (get16bits (data+2) << 11) ^ hash;
        hash   = (hash << 16) ^ tmp;
        data  += 2 * sizeof(uint16_t);
        hash  += hash >> 11;
    }

    /* Handle end cases */
    switch (remaining)
    {
        case 3: hash += get16bits (data);
                hash ^= hash << 16;
                hash ^= data[sizeof (uint16_t)] << 18;
                hash += hash >> 11;
                break;

        case 2: hash += get16bits (data);
                hash ^= hash << 11;
                hash += hash >> 17;
                break;

        case 1: hash += *data;
                hash ^= hash << 10;
                hash += hash >> 1;
    }

    /* Force "avalanching" of final 127 bits */
    hash ^= hash << 3;
    hash += hash >> 5;
    hash ^= hash << 4;
    hash += hash >> 17;
    hash ^= hash << 25;
    hash += hash >> 6;

    return hash;
}

#undef get16bits


