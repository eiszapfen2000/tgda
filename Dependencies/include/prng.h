/*
 * Copyright (c) 1996 Otmar Lendl (lendl@cosy.sbg.ac.at)
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted without a fee provided that the following
 * conditions are met:
 *
 * 1. This software is only used for private, research, or academic 
 *    purposes.
 *    
 * 2. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 3. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * 4. Any changes made to this package must be submitted to the author.
 *    The legal status of the submitted changes must allow their inclusion
 *    into this package under this license.
 *
 * 5. Publications in the field of pseudorandom number generation, which
 *    made use of this package must include a reference to this package.
 *      
 * Any use of this software in a commercial environment requires a
 * written licence from the author. Contact Otmar Lendl 
 * (lendl@cosy.sbg.ac.at) to negotiate the terms.
 *
 * THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 * 
 * IN NO EVENT SHALL OTMAR LENDL BE LIABLE FOR ANY SPECIAL, INCIDENTAL,
 * INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND, OR ANY DAMAGES 
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER OR
 * NOT ADVISED OF THE POSSIBILITY OF DAMAGE, AND ON ANY THEORY OF 
 * LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE 
 * OF THIS SOFTWARE.
 *
 */
/*
 *
 *  prng.h	Definitions for the PRN generator library. Version 2.2
 *
 *  Author:	Otmar Lendl (lendl@cosy.sbg.ac.at)
 *
 *  Last Modification: Fri Jan 10 18:57:35 MET 1997
 *
 */

/* Modification History:

96/07/08: New interface
96/09/29: support for sub and con
96/10/07: support for dicg
96/11/21: support for tt800
96/12/28: external made more genereric
97/01/10: inverse handling simplified
00/10/17: use GNU automake and autoconf
00/10/18: added Mersenne Twister
00/10/18: added Antithetic sequence
*/

#ifndef __PRNG_H__
#define __PRNG_H__ 1

#include <limits.h> 
#include <stdio.h>

typedef unsigned long	prng_num;	/* Basic Numeric data type for all
					   congruential generators. */
typedef signed   long	s_prng_num;	/* Signed version */

#define PRNG_NUM_MAX ULONG_MAX		/* must match the type of prng_num */

/* For the modular multiplication I need to know how many bits a 
   prng_num is. If run on a 32 or 64 bit computer, the following clauses
   should suffice. If you get an error message, add an #elif command
   to test for your LONG_MAX and define PRNG_SAFE_MAX to be 
   2^(bits in int/2 -1). For 32 bit systems, this is 2^15 = 32768.

   PRNG_MAX_MODULUS is the larges allowed modulus, it should be set to
   LONG_MAX + 1.
*/
#if LONG_MAX == 2147483647    		/* 32 bit integers */
#define PRNG_SAFE_MAX 32768
#define PRNG_MAX_MODULUS 2147483648UL
#define PRNG_NUM_BITS 32
#else
#if LONG_MAX == 9223372036854775807	/* 64 bit integers */
#define PRNG_SAFE_MAX 2147483648
#define PRNG_MAX_MODULUS 9223372036854775808UL
#define PRNG_NUM_BITS 64
#endif
#endif

#ifndef PRNG_SAFE_MAX
#error "I don't know the size of your basic integer type. \
	Please augment prng.h."
#endif


#define EUCLID_TABLE_SIZE 256
/*
 * The values in the euclid table will be in the range
 * -(EUCLID_TABLE_SIZE/2 - 1) to EUCLID_TABLE_SIZE/2 - 1
 *
 * Thus for EUCLID_TABLE_SIZE <= 256, a (signed) char will be able to hold
 * all posibilities, for larger EUCLID_TABLE_SIZE you *MUST* change
 * the following define to a larger type.
 */
#define EUCLID_TABLE_TYPE signed char

/*
 * The default (256/char) will allocate 64Kbyte for the table.
 */

/*
 * This algorithm is the fastest on all tested platforms.
 */
#define prng_inverse(x,p) prng_inverse_own(x,p)

/*
 * How big can the various strings get ?
 */
#define PRNG_MAX_NAME 200	/* short name of prng */
#define PRNG_MAX_TYPE_LEN 32
#define PRNG_MAX_NUMBER_LEN 32	/* how long can numerals get */
#define PRNG_MAX_FILE_LEN 128	/* max. filename for file prng */

#define PRNG_MAX_PRNG_PARAMETERS 20
#define PRNG_MAX_COMPOUNDS 32	/* # generators in a compound prng */

/*
 * Can we use long long ints ?  With GCC, we can.
 *
 * But if sizeof(long) > sizeof(int), long long == long  :(
 *
 */
#ifdef __GNUC__
#  if (LONG_MAX == INT_MAX)
#     define HAVE_LONGLONG
#  endif
#endif

/********* No editing should be needed below this line ***********/

#ifndef TRUE
#define TRUE (1)
#endif

#ifndef FALSE
#define FALSE (0)
#endif

#ifdef HAVE_LONGLONG
#define mult_mod_ll(a,s,m) \
	((prng_num)(((unsigned long long int) s * (unsigned long long int) a) \
	 % (unsigned long long int) m))
#endif

/* struct for mult_mod */

#define PRNG_MM_ZERO 0
#define PRNG_MM_ONE 1
#define PRNG_MM_SIMPLE 2
#define PRNG_MM_SCHRAGE 3
#define PRNG_MM_DECOMP 4
#define PRNG_MM_LL 5
#define PRNG_MM_POW2 6

struct mult_mod_struct
	{
	prng_num	a,p;	/*  (x a) mod (p) */
	prng_num	q,r;	/*  for Schrage's Method */
	int		algorithm;
	prng_num	mask;	/*  for power of 2 moduli */
	};

/* Define Generator structs */
struct eicg
	{
	prng_num	a,b,p,n0;
	double		inv_p;
	s_prng_num	next_lin;
	struct mult_mod_struct mm;
	};

struct meicg
	{
	prng_num	a,b,p,n0;
	double		inv_p;
	prng_num	next_n;
	struct mult_mod_struct mm;
	int 		simple_square;
	};

struct icg
        {
        prng_num	a,b,p,seed;
        double		inv_p;
        s_prng_num	next;
	struct mult_mod_struct mm;
        };

struct lcg
        {
        prng_num	a,b,p,seed;
        double		inv_p;
        s_prng_num	next;		/* must be signed ! (used in add_mod)*/
	struct mult_mod_struct mm;
        };

struct qcg
        {
        prng_num	a,b,c,p,seed;
        double		inv_p;
        s_prng_num	next;
	struct mult_mod_struct mm_a,mm_b;
	int 		simple_square;
        };

#define MT19937_N  624
struct mt19937
	{
	unsigned long   mt[MT19937_N];    /* the array for the state vector  */
	int             mti;
	prng_num	seed;
	};

struct compound
        {
        int	n;
        struct prng *comp[PRNG_MAX_COMPOUNDS];
        };

struct prng_file
        {
        FILE *file;
        char filename[PRNG_MAX_FILE_LEN];
        };

struct prng_sub
        {
        struct prng *prng;
        prng_num s,i;
        };

struct prng_anti
        {
        struct prng *prng;
        };

struct prng_con
        {
        struct prng *prng;
        prng_num l,i;
        };

struct dicg
	{
        prng_num	a,b,seed;
        double		inv_p;
        s_prng_num	next;
	int 		k;		/* no need for longs here */
	};

struct external
	{
	void *initial_state,*state;
	int  state_size;
	};


/* Union for all these structs to get a generic struct */

union prng_data
		{
		struct eicg      eicg_data;
		struct icg       icg_data;
		struct lcg       lcg_data;
		struct meicg     meicg_data;
		struct qcg       qcg_data;
		struct mt19937   mt19937_data;
		struct compound  compound_data;
		struct prng_file file_data;
		struct prng_anti anti_data;
		struct prng_sub  sub_data;
		struct prng_con  con_data;
		struct dicg      dicg_data;
		struct external  external_data;
		};

/* Main struct for all PRNG */

struct prng
        {
        char short_name[PRNG_MAX_NAME];	/* will hold abbreviations */
        char *long_name;	/* Full specification */
        void (*reset)(struct prng *gen);
        double (*get_next)(struct prng *gen);
        void (*get_array)(struct prng *gen,double *array,int count);
        void (*free)(struct prng *gen);
        int is_congruential;	/* is it a plain CG ? */
        	prng_num (*get_next_int)(struct prng *gen);
        	prng_num modulus;
	int can_seed;		/* can we use seed() ? */
        	void (*seed)(struct prng *gen,prng_num seed);
	int can_fast_sub;		/* can we use get_sub_def() ? */
        	char *(*get_sub_def)(struct prng *gen,prng_num s, prng_num i);
	int can_fast_con;		/* can we use get_con_def() ? */
        	char *((*get_con_def)(struct prng *gen,prng_num l, prng_num i));
	union prng_data data;
        };

/* function defines ... */

#define prng_reset(gen) gen->reset(gen)
#define prng_get_next(gen) gen->get_next(gen)
#define prng_get_array(gen,a,c) gen->get_array(gen,a,c)
#define prng_free(gen) do {if(gen) gen->free(gen);} while (0)
#define prng_get_next_int(gen) gen->get_next_int(gen)
#define prng_seed(gen,n) gen->seed(gen,n)
#define prng_get_sub_def(gen,s,i) gen->get_sub_def(gen,s,i)
#define prng_get_con_def(gen,l,i) gen->get_con_def(gen,l,i)

#define prng_short_name(gen) (gen->short_name)
#define prng_long_name(gen) (gen->long_name)
#define prng_is_congruential(gen) (gen->is_congruential)
#define prng_get_modulus(gen) (gen->modulus)
#define prng_can_seed(gen) (gen->can_seed)
#define prng_can_fast_sub(gen) (gen->can_fast_sub)
#define prng_can_fast_con(gen) (gen->can_fast_con)

/* Struct for parsing */

struct prng_definition
	{
	char type[PRNG_MAX_TYPE_LEN];
	int num_parameters;
	char *parameter[PRNG_MAX_PRNG_PARAMETERS];
	char *def;
	};

/******************************************************* Prototypes */


/* generic stuff */

struct prng *prng_new(char *definition);
struct prng *prng_allocate(void);
void prng_generic_free(struct prng *gen);
void prng_undefined(struct prng *gen);


/* Support stuff */
void rec_eeuclid(prng_num a,prng_num b,prng_num *d,
			s_prng_num *x,s_prng_num *y);

prng_num prng_inverse_iter(prng_num a,prng_num p);
prng_num prng_inverse_gordon(prng_num a,prng_num p);
prng_num prng_inverse_own(prng_num a,prng_num p);

void prng_init_euclid_table();

void mult_mod_setup(prng_num a,prng_num p,struct mult_mod_struct *mm);
prng_num mult_mod_generic(prng_num a,prng_num s,prng_num m);
prng_num prng_power_mod(prng_num a,prng_num e,prng_num m);

void check_modulus(char *fname,prng_num p);
int prng_split_def(char *in,struct prng_definition *def);
prng_num strtoprng_num(char *string);


/* Prototypes for the various generators: */

struct prng *prng_eicg_init(struct prng_definition *def);
struct prng *prng_meicg_init(struct prng_definition *def);
struct prng *prng_icg_init(struct prng_definition *def);
struct prng *prng_lcg_init(struct prng_definition *def);
struct prng *prng_qcg_init(struct prng_definition *def);
struct prng *prng_mt19937_init(struct prng_definition *def);
struct prng *prng_compound_init(struct prng_definition *def);
struct prng *prng_afile_init(struct prng_definition *def);
struct prng *prng_bfile_init(struct prng_definition *def);
struct prng *prng_anti_init(struct prng_definition *def);
struct prng *prng_sub_init(struct prng_definition *def);
struct prng *prng_con_init(struct prng_definition *def);
struct prng *prng_dicg_init(struct prng_definition *def);
struct prng *prng_external_init(struct prng_definition *def);

/**  Macros & Inline functions. **/

/* WARNING: res must be SIGNED ! */
#define add_mod(res,x,b,m) \
	res = x + b; \
	if ( (res < 0)  || ((prng_num) res >= m) ) res -= m;

/* INLINE fnk def. for mult_mod, I don't know if this works for non-GCC */

#ifdef __GNUC__
extern __inline__ prng_num mult_mod(prng_num s,struct mult_mod_struct *mm)
{
s_prng_num s_tmp;

switch(mm->algorithm)
        {
        case PRNG_MM_ZERO:   return(0);
                        break;
        case PRNG_MM_ONE:    return(s);
                        break;
        case PRNG_MM_SIMPLE: return((s * mm->a) % mm->p );
                        break;
        case PRNG_MM_SCHRAGE:
                        s_tmp = mm->a * ( s % mm->q ) - 
                                mm->r * ( s / mm->q );
                        if (s_tmp < 0) s_tmp += mm->p;
                        return(s_tmp);
                        break;
        case PRNG_MM_DECOMP: return(mult_mod_generic(s,mm->a,mm->p)); 
                        break;
#ifdef HAVE_LONGLONG
        case PRNG_MM_LL:     return(mult_mod_ll(s,mm->a,mm->p));
                        break;
#endif
        case PRNG_MM_POW2:   return((s*mm->a) & mm->mask);
			break;

        }
/* not reached */
return(0);
}
#else	/* rely on function in support.h */
prng_num mult_mod(prng_num s,struct mult_mod_struct *mm); 
#endif

#endif /* __PRNG_H__ */
