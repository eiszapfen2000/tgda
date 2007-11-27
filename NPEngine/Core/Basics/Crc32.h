/* ===========================================================================
    MANUAL:

    DESCRIPTION
        Calculates the 32-bit CRC using a table of 256 precomputed CRC
        values.  The CRC-32 can be used as a hash value for arbitrary data.

    NOTE
        This code is based on a version of crc32 found in gzip by
        Jean-loup Gailly.

    IMPLEMENTATION
        First, the polynomial itself and its table of feedback terms.  The
        polynomial is
    
        x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x^1+x^0
    
        Note that we take it "backwards" and put the highest-order term in
        the lowest-order bit.  The X^32 term is "implied"; the LSB is the
        X^31 term, etc.  The X^0 term (usually shown as "+1") results in the
        MSB being 1.
    
        Note that the usual hardware shift register implementation, which is
        what we're using (we're merely optimizing it by doing eight-bit
        chunks at a time) shifts bits into the lowest-order term.  In our
        implementation, that means shifting towards the right.  Why do we do
        it this way?  Because the calculated CRC must be transmitted in order
        from highest-order term to lowest-order term.  UARTs transmit
        characters in order from LSB to MSB.  By storing the CRC this way, we
        hand it to the UART in the order low-byte to high-byte; the UART
        sends each low-bit to hight-bit; and the result is transmission bit
        by bit from highest- to lowest-order term without requiring any bit
        shuffling on our part.  Reception works similarly.
    
        The feedback terms table consists of 256, 32-bit entries.  The table
        can be generated at runtime if desired; code to do so is shown later.
        It might not be obvious, but the feedback terms simply represent the
        results of eight shift/xor operations for all combinations of data
        and CRC register values.
    
        The values must be right-shifted by eight bits by the "updcrc" logic;
        the shift must be unsigned (bring in zeroes).  On some hardware you
        could probably optimize the shift in assembler by using byte-swap
        instructions.

        polynomial 0xedb88320
=========================================================================== */
#ifndef _NP_BASICS_CRC32_H_
#define _NP_BASICS_CRC32_H_

#include "Types.h"

void crc32_initialise();

extern const UInt32 crc32_2bit_table[];
extern const UInt32 crc32_4bit_table[];
extern const UInt32 crc32_8bit_table[];

#define CRC32_INITIAL_VALUE     NP_UINT32_MAX

#define CRC32_POLY              0xedb88320

#define CRC32_VALUE(_crc)       ((_crc) ^ CRC32_INITIAL_VALUE)

/* ---------------------------------------------------------------------------
    'crc32_verify_tables'
	Verify all crc tables.  If this fails, something serious is amiss.
--------------------------------------------------------------------------- */
void crc32_verify_tables();

/* ---------------------------------------------------------------------------
    'crc32_update_with_...'
	Update a crc32 value with various different sizes of data.
--------------------------------------------------------------------------- */
void crc32_update_with_1bit( UInt32 * crc, unsigned int data )
{
    *crc = ((*crc ^ data) & 1) ? (*crc >> 1) ^ CRC32_POLY : (*crc >> 1);
}

void crc32_update_with_2bits( UInt32 * crc, unsigned int data )
{
    *crc = crc32_2bit_table[(*crc ^ data) & 0x3] ^ (*crc >> 2);
}

void crc32_update_with_4bits( UInt32 * crc, unsigned int data )
{
    *crc = crc32_4bit_table[(*crc ^ data) & 0xf] ^ (*crc >> 4);
}

void crc32_update_with_8bits( UInt32 * crc, unsigned int data )
{
    *crc = crc32_8bit_table[(*crc ^ data) & 0xff] ^ (*crc >> 8);
}

void crc32_update_with_16bits( UInt32 * crc, unsigned int data )
{
    crc32_update_with_8bits(crc, data);
    crc32_update_with_8bits(crc, data >> 8);
}

void crc32_update_with_32bits( UInt32 * crc, UInt32 data )
{
    crc32_update_with_16bits(crc, data);
    crc32_update_with_16bits(crc, data >> 16);
}

void crc32_update_with_64bits( UInt32 * crc, UInt64 data )
{
    crc32_update_with_32bits(crc, (UInt32) data);
    crc32_update_with_32bits(crc, (UInt32)(data >> 32));
}

void crc32_update_with_pointer( UInt32 * crc, void * pointer )
{
#ifdef NP_32BIT_LONG
    crc32_update_with_32bits(crc, (UInt32) pointer);
#endif
#ifdef NP_64BIT_LONG
    crc32_update_with_64bits(crc, (UInt64) pointer);
#endif
}

#define crc32_update_with_uint		crc32_update_with_32bits
#define crc32_update_with_int		crc32_update_with_32bits

#ifdef NP_32BIT_LONG
#define crc32_update_with_ulong		crc32_update_with_32bits
#define crc32_update_with_long		crc32_update_with_32bits
#endif

#ifdef NP_64BIT_LONG
#define crc32_update_with_ulong		crc32_update_with_64bits
#define crc32_update_with_long		crc32_update_with_64bits
#endif

void crc32_update_with_data( UInt32 * crc, const void * pointer, unsigned long length )
{
    const Byte * byte_ptr = (const Byte *)pointer;
    const Byte * stop_ptr = byte_ptr + length;

    while (byte_ptr < stop_ptr)
    {
	    crc32_update_with_8bits(crc, *byte_ptr++);
    }
}

void crc32_update_with_string( UInt32 * crc, const char * string )
{
    const Byte * byte_ptr = (const Byte *)string;
    char ch;

    while ((ch = *byte_ptr++) != 0)
    {
	    crc32_update_with_8bits(crc, ch);
    }
}

void crc32_write_to_data( UInt32 crc, void * pointer )
{
    Byte * byte_ptr = (Byte *)pointer;
    *byte_ptr++ = (Byte)crc; crc >>= 8;
    *byte_ptr++ = (Byte)crc; crc >>= 8;
    *byte_ptr++ = (Byte)crc; crc >>= 8;
    *byte_ptr   = (Byte)crc;
}

/* ---------------------------------------------------------------------------
    'crc32_of_...'
	Calculate the crc32 value of various different sizes of data.
--------------------------------------------------------------------------- */
UInt32 crc32_of_uint32( UInt32 value )
{
    UInt32 crc = CRC32_INITIAL_VALUE;
    crc32_update_with_32bits(&crc, value);

    return CRC32_VALUE(crc);
}

UInt32 crc32_of_uint64( UInt64 value )
{
    UInt32 crc = CRC32_INITIAL_VALUE;
    crc32_update_with_64bits(&crc, value);

    return CRC32_VALUE(crc);
}

UInt32 crc32_of_pointer( const void * pointer )
{
#ifdef NP_32BIT_LONG
    return crc32_of_uint32((UInt32)pointer);
#endif

#ifdef NP_64BIT_LONG
    return crc32_of_uint64((UInt64)pointer);
#endif
}

#define crc32_of_uint			crc32_of_uint32

#ifdef NP_32BIT_LONG
#define crc32_of_ulong			crc32_of_uint32
#endif

#ifdef NP_64BIT_LONG
#define crc32_of_ulong			crc32_of_uint64
#endif


UInt32 crc32_of_data( const void * pointer,	unsigned long length )
{
    UInt32 crc = CRC32_INITIAL_VALUE;
    crc32_update_with_data(&crc, pointer, length);

    return CRC32_VALUE(crc);
}

UInt32 crc32_of_string( const char * string )
{
    UInt32 crc = CRC32_INITIAL_VALUE;
    crc32_update_with_string(&crc, string);

    return CRC32_VALUE(crc);
}

#endif /* _NP_BASICS_CRC32_H_ */

