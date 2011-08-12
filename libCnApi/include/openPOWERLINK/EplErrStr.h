/*----------------------------------------------------------------------------
 * EplErrStr.h
 *----------------------------------------------------------------------------
 * Utilities for converting openPOWERLINK error in human readable form
 *----------------------------------------------------------------------------
 *  Functions:
 *    EplErrStrGetMessage()
 *----------------------------------------------------------------------------
 *  History:
 * 16/06/2010 Original version ...................................... E. Dumas
 * 24/06/2010 Rename EplGetStrError as EplErrStrGetMessage .......... E. Dumas
 *----------------------------------------------------------------------------
 * $Revision$
 */


#ifndef _EPLERRSTR_H_
#define _EPLERRSTR_H_

/*----------------------------------------------------------------------------
 * Includes
 *----------------------------------------------------------------------------
 */


/* try to order includes in alphabetically order --------- */


/* openPOWERLINK  ( in alphabetically order) */
#include "EplErrDef.h"

/*----------------------------------------------------------------------------
 * Macros
 *----------------------------------------------------------------------------
 */


/*----------------------------------------------------------------------------
 * Types
 *----------------------------------------------------------------------------
 */

/*----------------------------------------------------------------------------
 * Globals
 *----------------------------------------------------------------------------
 */

/*----------------------------------------------------------------------------
 * Functions
 *----------------------------------------------------------------------------
 */

/* Convert error code into a human readable string
 * E. Dumas 16/06/2010
 */
const char* EplErrStrGetMessage(tEplKernel Error_p);

#endif /* _EPLERRSTR_ */

/* end of file */
