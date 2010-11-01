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

#include "NpTypes.h"

void crc32_initialise();

extern const uint32_t crc32_2bit_table[];
extern const uint32_t crc32_4bit_table[];
extern const uint32_t crc32_8bit_table[];

#define CRC32_INITIAL_VALUE     UINT32_MAX
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
void crc32_update_with_1bit( uint32_t * crc, const uint32_t data );
void crc32_update_with_2bits( uint32_t * crc, const uint32_t data );
void crc32_update_with_4bits( uint32_t * crc, const uint32_t data );
void crc32_update_with_8bits( uint32_t * crc, const uint32_t data );
void crc32_update_with_16bits( uint32_t * crc, const uint32_t data );
void crc32_update_with_32bits( uint32_t * crc, const uint32_t data );
void crc32_update_with_64bits( uint32_t * crc, const uint64_t data );
void crc32_update_with_pointer( uint32_t * crc, const void const * pointer );
void crc32_update_with_data( uint32_t * crc, const void const * pointer, const size_t length );
void crc32_update_with_string( uint32_t * crc, const char * string );

/* ---------------------------------------------------------------------------
    'crc32_of_...'
	Calculate the crc32 value of various different sizes of data.
--------------------------------------------------------------------------- */
void crc32_write_to_data( const uint32_t crc, void * pointer );
uint32_t crc32_of_uint64( const uint64_t value );
uint32_t crc32_of_pointer( const void const * pointer );
uint32_t crc32_of_data( const void const * pointer, const size_t length );
uint32_t crc32_of_string( const char * string );

#endif /* _NP_BASICS_CRC32_H_ */

