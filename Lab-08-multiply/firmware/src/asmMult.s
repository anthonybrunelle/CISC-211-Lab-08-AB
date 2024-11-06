/*** asmMult.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0  
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0  
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmMult
function description:
     output = asmMult ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmMult
.type asmMult,%function
asmMult:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
 
.if 0
    /* profs test code. */
    mov r0,r0
.endif
    
    /** note to profs: asmMult.s solution is in Canvas at:
     *    Canvas Files->
     *        Lab Files and Coding Examples->
     *            Lab 8 Multiply
     * Use it to test the C test code */
    
    /*** STUDENTS: Place your code BELOW this line!!! **************/
    
    /* Initialize all output variables to 0 */
    ldr r2, =rng_Error
    movs r3, 0
    str r3, [r2] /* Set rng_Error to 0 */
    
    ldr r2, =a_Sign
    str r3, [r2] /* Set a_Sign to 0 */
    ldr r2, =b_Sign
    str r3, [r2] /* Set b_Sign to 0 */
    
    ldr r2, =prod_Is_Neg
    str r3, [r2] /* Set prod_Is_Neg to 0 */
    
    ldr r2, =a_Abs
    str r3, [r2] /* Set a_Abs to 0 */
    ldr r2, =b_Abs
    str r3, [r2] /* Set b_Abs to 0 */
    
    ldr r2, =init_Product
    str r3, [r2] /* Set init_Product to 0 */
    
    ldr r2, =final_Product
    str r3, [r2] /* Set final_Product to 0 */

    /* Store initial multiplicand and multiplier */
    ldr r2, =a_Multiplicand
    str r0, [r2] /* Copy r0 (multiplicand) to a_Multiplicand */
    
    ldr r2, =b_Multiplier
    str r1, [r2] /* Copy r1 (multiplier) to b_Multiplier */

    /* Check range for 16-bit signed values */
    movs r3, 32768
    lsls r3, r3, 8 /* r3 = 0x00008000 */
    cmp r0, r3
    bge set_rng_error /* If r0 >= 32768, set range error */
    
    negs r3, r3 /* r3 = -32768 */
    cmp r0, r3
    ble set_rng_error /* If r0 <= -32768, set range error */
    
    cmp r1, 32768
    bge set_rng_error /* If r1 >= 32768, set range error */

    cmp r1, -32768
    ble set_rng_error /* If r1 <= -32768, set range error */

    /* Store sign bits and take absolute values */
    ldr r2, =a_Sign
    movs r3, 0
    cmp r0, 0
    bge store_a_abs /* If r0 >= 0, skip to absolute value */
    movs r3, 1
    str r3, [r2] /* Set a_Sign to 1 for negative */
    neg r0, r0 /* Take absolute value of r0 */

store_a_abs:
    ldr r2, =a_Abs
    str r0, [r2] /* Store absolute value of r0 in a_Abs */

    ldr r2, =b_Sign
    movs r3, 0
    cmp r1, 0
    bge store_b_abs /* If r1 >= 0, skip to absolute value */
    movs r3, 1
    str r3, [r2] /* Set b_Sign to 1 for negative */
    neg r1, r1 /* Take absolute value of r1 */

store_b_abs:
    ldr r2, =b_Abs
    str r1, [r2] /* Store absolute value of r1 in b_Abs */

    /* Determine if final product should be negative */
    ldr r2, =a_Sign
    ldr r3, [r2]
    ldr r2, =b_Sign
    ldr r4, [r2]
    eors r3, r3, r4 /* XOR a_Sign and b_Sign to determine prod_Is_Neg */
    ldr r2, =prod_Is_Neg
    str r3, [r2] /* Store prod_Is_Neg */

    /* Perform shift-and-add multiplication */
    movs r4, 0 /* Initialize r4 (product) to 0 */
    ldr r2, =a_Abs
    ldr r5, [r2] /* Load a_Abs (multiplicand) */
    ldr r2, =b_Abs
    ldr r6, [r2] /* Load b_Abs (multiplier) */

multiply_loop:
    cmp r6, 0 /* Check if multiplier is zero */
    beq store_product /* If multiplier is zero, exit loop */
    tst r6, 1 /* Check LSB of multiplier */
    beq shift_left /* Skip addition if LSB is 0 */
    adds r4, r4, r5 /* Add multiplicand to product if LSB is 1 */

shift_left:
    lsls r5, r5, 1 /* Left shift multiplicand */
    lsrs r6, r6, 1 /* Right shift multiplier */
    b multiply_loop /* Repeat loop */

store_product:
    ldr r2, =init_Product
    str r4, [r2] /* Store positive product in init_Product */

    /* Adjust sign of final product if necessary */
    ldr r2, =prod_Is_Neg
    ldr r3, [r2]
    cmp r3, 0
    beq store_final_result /* If positive, skip negation */
    neg r4, r4 /* Negate final product if needed */

store_final_result:
    ldr r2, =final_Product
    str r4, [r2] /* Store signed final product in final_Product */
    mov r0, r4 /* Move final product to r0 */
    b done /* Branch to done */

set_rng_error:
    ldr r2, =rng_Error
    movs r3, 1
    str r3, [r2] /* Set rng_Error to 1 */
    movs r0, 0 /* Set r0 to 0 */
    
    /*** STUDENTS: Place your code ABOVE this line!!! **************/

done:    
    /* restore the caller's registers, as required by the 
     * ARM calling convention 
     */
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 

screen_shot:    pop {r4-r11,LR}

    mov pc, lr	 /* asmMult return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




