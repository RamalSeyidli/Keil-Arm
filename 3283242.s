;*******************************************************************************
;@file				 Main.s
;@project		     Microprocessor Systems Term Project
;@date				 31.01.2021
;
;@PROJECT GROUP
;@groupno	32
;@member1	150180116 Ömür Fatmanur Erzurumluoglu
;@member2	150180053 Mehmet Karaaslan
;@member3	150180734 Sinan Sar
;@member4	150180901 Ramal Seyidli
;@member5	150170016 Ümit Basak
;*******************************************************************************
;*******************************************************************************
;@section 		INPUT_DATASET
;*******************************************************************************

;@brief 	This data will be used for insertion and deletion operation.
;@note		The input dataset will be changed at the grading. 
;			Therefore, you shouldn't use the constant number size for this dataset in your code. 
				AREA     IN_DATA_AREA, DATA, READONLY
IN_DATA			DCD		0x10, 0x20, 0x15, 0x65, 0x25, 0x01, 0x01, 0x12, 0x65, 0x25, 0x85, 0x46, 0x10, 0x00
END_IN_DATA

;@brief 	This data contains operation flags of input dataset. 
;@note		0 -> Deletion operation, 1 -> Insertion 
				AREA     IN_DATA_FLAG_AREA, DATA, READONLY
IN_DATA_FLAG	DCD		0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x02
END_IN_DATA_FLAG


;*******************************************************************************
;@endsection 	INPUT_DATASET
;*******************************************************************************

;*******************************************************************************
;@section 		DATA_DECLARATION
;*******************************************************************************

;@brief 	This part will be used for constant numbers definition.
NUMBER_OF_AT	EQU		20									; Number of Allocation Table
AT_SIZE			EQU		NUMBER_OF_AT*4						; Allocation Table Size


DATA_AREA_SIZE	EQU		AT_SIZE*32*2						; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 2 word (Value + Address)
															; Each word has 4 byte
ARRAY_SIZE		EQU		AT_SIZE*32							; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 1 word (Value)
															; Each word has 4 byte
LOG_ARRAY_SIZE	EQU     AT_SIZE*32*3						; Log Array Size
															; Each log contains 3 word
															; 16 bit for index
															; 8 bit for error_code
															; 8 bit for operation
															; 32 bit for data
															; 32 bit for timestamp in us

;//-------- <<< USER CODE BEGIN Constant Numbers Definitions >>> ----------------------															
							


;//-------- <<< USER CODE END Constant Numbers Definitions >>> ------------------------	

;*******************************************************************************
;@brief 	This area will be used for global variables.
				AREA     GLOBAL_VARIABLES, DATA, READWRITE		
				ALIGN	
TICK_COUNT		SPACE	 4									; Allocate #4 byte area to store tick count of the system tick timer.
FIRST_ELEMENT  	SPACE    4									; Allocate #4 byte area to store the first element pointer of the linked list.
INDEX_INPUT_DS  SPACE    4									; Allocate #4 byte area to store the index of input dataset.
INDEX_ERROR_LOG SPACE	 4									; Allocate #4 byte aret to store the index of the error log array.
PROGRAM_STATUS  SPACE    4									; Allocate #4 byte to store program status.
															; 0-> Program started, 1->Timer started, 2-> All data operation finished.
;//-------- <<< USER CODE BEGIN Global Variables >>> ----------------------											


;//-------- <<< USER CODE END Global Variables >>> ------------------------															

;*******************************************************************************

;@brief 	This area will be used for the allocation table
				AREA     ALLOCATION_TABLE, DATA, READWRITE		
				ALIGN	
__AT_Start
AT_MEM       	SPACE    AT_SIZE							; Allocate #AT_SIZE byte area from memory.
__AT_END

;@brief 	This area will be used for the linked list.
				AREA     DATA_AREA, DATA, READWRITE		
				ALIGN	
__DATA_Start
DATA_MEM        SPACE    DATA_AREA_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__DATA_END

;@brief 	This area will be used for the array. 
;			Array will be used at the end of the program to transform linked list to array.
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__ARRAY_Start
ARRAY_MEM       SPACE    ARRAY_SIZE						; Allocate #ARRAY_SIZE byte area from memory.
__ARRAY_END

;@brief 	This area will be used for the error log array. 
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__LOG_Start
LOG_MEM       	SPACE    LOG_ARRAY_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__LOG_END

;//-------- <<< USER CODE BEGIN Data Allocation >>> ----------------------															
							


;//-------- <<< USER CODE END Data Allocation >>> ------------------------															

;*******************************************************************************
;@endsection 	DATA_DECLARATION
;*******************************************************************************

;*******************************************************************************
;@section 		MAIN_FUNCTION
;*******************************************************************************

			
;@brief 	This area contains project codes. 
;@note		You shouldn't change the main function. 				
				AREA MAINFUNCTION, CODE, READONLY
				ENTRY
				THUMB
				ALIGN 
__main			FUNCTION
				EXPORT __main
				BL	Clear_Alloc					; Call Clear Allocation Function.
				BL  Clear_ErrorLogs				; Call Clear ErrorLogs Function.
				BL	Init_GlobVars				; Call Initiate Global Variable Function.
				BL	SysTick_Init				; Call Initialize System Tick Timer Function.
				LDR R0, =PROGRAM_STATUS			; Load Program Status Variable Addresses.
LOOP			LDR R1, [R0]					; Load Program Status Variable.
				CMP	R1, #2						; Check If Program finished.
				BNE LOOP						; Go to loop If program do not finish.
STOP			B	STOP						; Infinite loop.
				
				ENDFUNC
			
;*******************************************************************************
;@endsection 		MAIN_FUNCTION
;*******************************************************************************				

;*******************************************************************************
;@section 			USER_FUNCTIONS
;*******************************************************************************
				ALIGN
;@brief 	This function will be used for System Tick Handler
SysTick_Handler	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------																	
				EXPORT SysTick_Handler
					
				PUSH	{LR}					;pushes LR to stack
				
				LDR 	R7, =TICK_COUNT			;loads address of TICK_COUNT to r7
				LDR		R1, [R7]				;loads the value of TICK_COUNT to r1
				MOVS	R6, #4					;assigns 4 to R6
				MULS	R6, R1, R6				;multiplies TICK_COUNT value and 4
				LDR		R5, =IN_DATA_FLAG		;loads start address of flags of input dataset to r5
				LDR		R2, [R5, R6]			;R2 stores the flag (operation)
				LDR		R5, =IN_DATA			;loads start address of input dataset to r5
				LDR		R3, [R5, R6]			;R3 stores the input data
				MOVS	R0, R3					;R0 also stores the input data
				PUSH	{R7,R1,R2,R3}			;pushes the registers to stack 
				
				CMP		R2, #0					;if the flag is 0
				BEQ		remove					;branches to remove
				CMP		R2, #1					;if operation flag is 1, call insert.
				BEQ		call_insert				;branches to call_insert
				CMP		R2, #2					;if operation flag is 2
				BEQ		transform				;branches to transform
				BNE		error					;if not equal, branches to error
call_insert		BL		Insert					;branches with link to Insert function
				B		pp						;after insert operation, branches to pp
remove			BL		Remove					;branches with link to Remove function
				B		pp						;after remove operation, branches to pp
transform		BL		LinkedList2Arr			;branches with link to LinkedList2Arr function
				B		pp						;after transform operation, branches to pp
				
error			MOVS	R0, #6					;R0 stores the error code as 6
						
pp				POP		{R7,R1,R2,R3}			;pops from stack to the registers
				PUSH	{R7,R1}					;pushes the registers to stack 
				MOVS	R7, R1					;to interchange R1 and R0
				MOVS	R1, R0					;R1 stores the error code
				MOVS	R0, R7					;R0 stores the index
				BL		WriteErrorLog			;branches with link to WriteErrorLog function
				POP		{R7,R1}					;pops from stack to the registers
				ADDS	R1, #1					;increases R1 value by 1
				STR		R1, [R7]				;loads R1 to TICK_COUNT
				
				LDR		R5, =IN_DATA_FLAG		;loads start address of flags of input dataset to r5
				LDR		R3, =END_IN_DATA_FLAG 	;loads end address of flags of input dataset to R3
				MOVS	R6, #4					;assigns 4 to R6
				MULS	R6, R1, R6				;multiplies TICK_COUNT value and 4
				ADDS	R6, R5, R6				;sums the start adress of flags array and TICK_COUNT		
				CMP		R3, R6					;compares the sum and the end adress of the array
				BEQ		SysTick_Stop			;if equal, branches to SysTick_Stop		
				LDR 	R0, =PROGRAM_STATUS		;Load Program Status Variable Addresses.
				POP		{PC}					;returns to where the SysTick_Handler function was called				
				
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC

;*******************************************************************************				
				ALIGN
;@brief 	This function will be used to initiate System Tick Handler
SysTick_Init	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Initialize >>> ----------------------																			 				 
				LDR	 R0, =0xE000E014			;loads the address of SysTick Reload Value Register
				LDR	 R1, =15423					;assigns computed reload value (15423) to R1
				STR	 R1,[R0]					;assigns 15423 to SysTick Reload Value Register

				LDR  R0, =0xE000E018			;loads the address of SysTick Current Value Register
				MOVS R1, #0						;assigns 0 to R1
				STR  R1,[R0]					;assigns 0 to SysTick Current Value Register
				
				LDR	 R0, =0xE000E010			;loads the address of SysTick Control and Status Register
				MOVS R1, #7						;assigns 7 to R1
				STR	 R1, [R0]					;assigns 1 to CLKSOURCE, TICKINT and ENABLE
				
				LDR	 R0, =PROGRAM_STATUS		;loads the address of PROGRAM_STATUS global value
				MOVS R1, #1						;assigns 1 to R1
				STR	 R1, [R0]					;assigns 1 to PROGRAM_STATUS (Timer started)
				
				BX	 LR							;branches to main
;//-------- <<< USER CODE END System Tick Timer Initialize >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to stop the System Tick Timer
SysTick_Stop	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Stop >>> ----------------------	
				LDR	 R0, =0xE000E010			;loads the address of SysTick Control and Status Register
				MOVS R1, #0						;assigns 0 to R1
				STR	 R1, [R0]					;assigns 0 to CLKSOURCE, TICKINT and ENABLE
				
				LDR	 R0, =0xE000E014			;loads the address of SysTick Reload Value Register
				MOVS R1, #0						;assigns 0 to R1
				STR	 R1, [R0]					;assigns 0 to SysTick Reload Value Register
				
				LDR	 R0, =PROGRAM_STATUS		;loads the address of PROGRAM_STATUS global value
				MOVS R1, #2						;assigns 2 to R1
				STR	 R1, [R0]					;assigns 2 to PROGRAM_STATUS (All data operation finished)
				
				POP	 {PC}						;returns to where the SysTick_Handler function was called
;//-------- <<< USER CODE END System Tick Timer Stop >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to clear allocation table
Clear_Alloc		FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Allocation Table Function >>> ----------------------																			
				LDR 	R2, =AT_MEM			;loads start address of allocation table to r2
				LDR 	R0, =AT_SIZE		;loads size of allocation table to r0
				MOVS	R1, #0				;loads 0 to r1
Clear_loop		SUBS	R0, R0, #4			;decreases the index by 4 to clear from last element of allocation table to first element
				STR		R1, [R2,R0]			;assigns 0
				CMP		R0, R1				;compares 0 and R0 (index)
				BNE		Clear_loop			;if the first element is not reached, branches to Clear_loop
				BX 		LR					;branches to main				
;//-------- <<< USER CODE END Clear Allocation Table Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************		

;@brief 	This function will be used to clear error log array
Clear_ErrorLogs	FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Error Logs Function >>> ----------------------																		
					LDR 	R2, =LOG_MEM			;loads start address of error log array to r2
					LDR 	R0, =LOG_ARRAY_SIZE		;loads size of error log array to r0
					MOVS	R1, #0					;loads 0 to r1
Clear_error_loop	SUBS	R0, R0, #4				;decreases the index by 4 to clear from last element of error log array to first element
					STR		R1, [R2,R0]				;assigns 0
					CMP		R0, R1					;compares 0 and R0 (index)
					BNE		Clear_error_loop		;if the first element is not reached, branches to Clear_error_loop
					BX 		LR						;branches to main				
;//-------- <<< USER CODE END Clear Error Logs Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************

;@brief 	This function will be used to initialize global variables
Init_GlobVars	FUNCTION			
;//-------- <<< USER CODE BEGIN Initialize Global Variables >>> ----------------------		
				MOVS	R1, #0						;assigns 0 to R1
				LDR 	R0, =TICK_COUNT				;loads the address of TICK_COUNT global value
				STR		R1, [R0]					;assigns 0 to TICK_COUNT
				LDR 	R0, =FIRST_ELEMENT			;loads the address of FIRST_ELEMENT global value
				STR		R1, [R0]					;assigns 0 to FIRST_ELEMENT
				LDR 	R0, =INDEX_INPUT_DS			;loads the address of INDEX_INPUT_DS global value
				STR		R1, [R0]					;assigns 0 to INDEX_INPUT_DS
				LDR 	R0, =INDEX_ERROR_LOG		;loads the address of INDEX_ERROR_LOG global value
				STR		R1, [R0]					;assigns 0 to INDEX_ERROR_LOG
				LDR 	R0, =PROGRAM_STATUS			;loads the address of PROGRAM_STATUS global value
				STR		R1, [R0]					;assigns 0 to PROGRAM_STATUS (Program started)
				BX		LR							;branches to main			
;//-------- <<< USER CODE END Initialize Global Variables >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************	

;@brief 	This function will be used to allocate the new cell 
;			from the memory using the allocation table.
;@return 	R0 <- The allocated area address
Malloc			FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------	
				LDR 	r1,=DATA_MEM		;load start address of linked list to r1
				LDR 	r2,=AT_MEM			;load start address of allocation table to r2
				LDR		r4,=(__AT_END-4)	;load end address of allocation table to r4
				LDR		r5,=0xFFFFFFFE		;mask for each line on allocation table.(32 bits 111...110)
				MOVS	r7,#0				;keep an index for iterations at r7
				LDR		r6,[r4]				;load 32 bits of allocation table to r6. The 32 bits will change as we iterate on the table.
iterate_mal		CMP		r7,#32				;check if we looked at all 32 bits in allocation table line, if true go to next line
				BEQ		new_line
				PUSH	{r7}				;push r7 to preserve its value
				MOVS	r7,r6				;move r6 to r7
				ORRS	r7,r5,r7			;mask r6 value to check if lsb is 0					
				CMP 	r7,r5				;if it is 0, we found a free memory space for a new node.
				BEQ		found
				POP		{r7}				;if not, pop r6 and keep iterating on the allocation table line.
				LSRS	r6,#1				;shift r6 value to right to check the next bit
				ADDS	r7,#1				;increment loop index by one
				ADDS	r1,#8				;increment linked list node address by 8.(4 for data,4 for next)
				B		iterate_mal			;return to start of the loop	
				

new_line		SUBS	r4,#4				;iterate to a new line in the allocation table
				CMP		r4,r2				;if we checked the whole table and there is no empty space
				BLT		mal_error			;go to error label
				MOVS	r7,#0				;keep an index for iterations at r7
				LDR		r6,[r4]				;load value at r4 to r6
				B		iterate_mal			;if not at the end of table, check a new line at the loop
	

mal_error		MOVS	r0,#0				;set r0 as allocation error flag
				BX		LR					;return to Insert
				
found			POP		{r7}				;if found, pop r7.
				MOVS 	r0,r1				;load found node address to r0
				MOVS	r3,#1				;set r3 as 1
				LSLS	r3,r7				;shift r3 left by amount of iterations in loop
				LDR		r6,[r4]				;load value at r4 to r6
				ORRS	r6,r3,r6			;set the used bit to 1
				STR		r6,[r4]				;store new allocation table value
				BX	 	LR					;return to Insert
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used for deallocate the existing area
;@param		R0 <- Address to deallocate
Free			FUNCTION			
;//-------- <<< USER CODE BEGIN Free Function >>> ----------------------				
                LDR        R1, =(__AT_END-4)    ;load end address of allocation table to R1
                LDR        R2, =DATA_MEM        ;load address of data memory to R2
                SUBS    R0, R0, R2            ;substract data memory address from remova element's address
                LSRS    R0, R0, #3            ;divide R0 by 8
                MOVS    R3, #32			;Assign 32 to R3
dec_loop        CMP        R0, R3		;Compare R0 with R3 (32)
                BLT        dec_end		;Branch to end loop if smaller
                SUBS    R1, R1, #4		;Substract R1 by 4
                SUBS    R0, R0, R3		;Substract R0 by 32
                B        dec_loop		;Branch to loop again
dec_end            LDR        R4, =0xFFFFFFFE	;Load 111...1110 (32 bits) to R4
                MOVS    R3, #1			;Assign 1 to R3
shift_loop        CMP        R0, #0		;Compare R0 with 0
                BEQ        shift_end		;Branch to end loop if equal
                LSLS    R4, R4, #1		;Shift left R4 one bits
                ORRS    R4, R4, R3		;Or operation R4 with R3 to set last bit 1 again, left shift makes last bit 0
                SUBS    R0, R0, #1		;Substract R0 by 1
                B        shift_loop		;Branch to loop again
shift_end        LDR        R5, [R1]		;Load value inside R1(allocation table) to R5
                ANDS    R5, R5, R4		;And operation to change value with new one
                STR        R5, [R1]		;Store new value in R1(allocation table)
                BX        LR            ;Branching back to Remove function					
;//-------- <<< USER CODE END Free Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to insert data to the linked list
;@param		R0 <- The data to insert
;@return    R0 <- Error Code
Insert			FUNCTION			
;//-------- <<< USER CODE BEGIN Insert Function >>> ----------------------															
				PUSH	{LR}				;Push LR, will pop pc in order to return to systick_handler
				LDR		r5,=FIRST_ELEMENT	;store head pointer at r5
				LDR 	r1,=DATA_MEM		;store value of head at r1
				LDR		r1,[r1]		;load r1 with first nodes data		
				LDR		r2,[r5]		;load r2 with heads address
				;LDR		r2,[r2]
			
			;THis should be done for R0 in handler ;;LDR		r2,=[IN_DATA,TICK_COUNT]	;;!!!!!input == 0 and list is empty, there will be some issues..
				
				CMP		r2,#0				;Check if list is empty
				BEQ		Empty_list			;if it is, branch to empty list case
				
				CMP 	r0,r1				;Check if input is smaller than head
				BLT		New_Head		;if it is, branch to add new head
				MOVS	r1,r5				;move head pointer to r1
				LDR		r1,[r1]			;load r1 with heads address
				B		Check			;branch to case checking loop

Empty_list		LDR		r1,=DATA_MEM		;set r1 as Data_MEM's start address
				STR		r1,[r5]
				STR		r0,[r1]				;Set head of the list as input		
				LDR		r4,=(__AT_END-4)	;load end address of allocation table to r4
				LDR		r5,=0x00000001		;prepare value to store in allocation table.(32 bits 000...001)
				STR 	r5, [r4]			;Set allocation table 
				MOVS	r5,#1				;Load 1 to r5
				MOVS	r0,#0				;Set r0 with success code
				;LDR		r2,=IS_EMPTY		;load  IS_EMPTY 's address to r2
				;STR		r5,[r2]				;Set IS_EMPTY variable as 1, since list is not empty anymore
				
				;;This doesn't require malloc, we don't think...
				POP		{PC}				;return to systick_handler

New_Head		PUSH	{r0,r1,r5}			;push values before calling malloc
				BL		Malloc				;call malloc
				MOVS	r2,r0				;Save address coming from malloc to R2
				POP		{r5,r1,r0}			;pop
				CMP		r2,#0				;if malloc raised an error
				BEQ		Mal_Ins_Error			;branch to error label
				STR		r0,[r2]				;store input value at allocated memory address
				LDR		r1,[r5]				;load current heads address to r1
				;LDR	r1,[r1]
				STR		r1,[r2,#4]			;store next pointer at allocated memory address.
				STR 	r2, [r5]			;make the new head first_element
				MOVS	r0,#0				;Set r0 with success code
				POP		{PC}				;return to systick_handler
				


Check			
				MOVS	r3,r1				;Load r3 with current nodes next address
				LDR		r6,[r3,#4]			;Lad r6 with next nodes next value
				LDR		r4,[r3]				;load r4 with next nodes data
				CMP		r0,r4				;check if input is duplicate
				BEQ		Duplicate_Error			;branch to error table
				CMP		r0,r4				;compare input with next node,if its lesser then we found where to insert
				BLT		found_insert			;branch to insert new node
				CMP		r6,#0				;Check if we are at the tail
				BEQ		add_tail			;if we are, branch to add new tail
				;MOVS	r1,r4				;else, load r1 with next nodes data
				MOVS	r7,r1				;load r1 with current nodes data
				MOVS	r1,r6				;else, load r1 with next nodes next
				B		Check		

found_insert	PUSH	{r0,r1,r3,r5,r7}	;push values before calling malloc
				BL		Malloc				;call malloc
				MOVS	r2,r0				;Save address coming from malloc to R2
				POP		{r7,r5,r3,r1,r0}	;pop
				CMP		r2,#0				;if malloc raised an error
				BEQ		Mal_Ins_Error			;branch to error label
				STR		r0,[r2]				;store input value at allocated memory address
				STR		r3,[r2,#4]			;store next elements data address as next for new element
				STR		r2,[r7,#4]			;store new elements data address as current elements next.
				MOVS	r0,#0				;Set r0 with success code
				POP		{PC}				;return to systick_handler

add_tail		PUSH	{r0,r1,r3,r4}		;push values before calling malloc
				BL		Malloc				;call malloc
				MOVS	r2,r0				;Save address coming from malloc to R2
				POP		{r4,r3,r1,r0}		;pop
				CMP		r2,#0				;if malloc raised an error
				BEQ		Mal_Ins_Error			;branch to error label
				STR		r0,[r2]				;store input value at allocated memory address	
				STR		r2,[r3,#4]			;Load old tails next with new tails data address
				MOVS	r4,#0				;Load r4 with next nodes data
				STR		r4,[r2,#4]			;Set new tails next as null.
				MOVS	r0,#0				;Set r0 with success code
				POP		{PC}

Mal_Ins_Error	MOVS	r0,#1				;set r0 for malloc error
				POP		{PC}				;return to systick_handler

Duplicate_Error	MOVS	r0,#2				;set r0 to duplicated insertion error value
				POP		{PC}				;return to systick_handler	
;//-------- <<< USER CODE END Insert Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to remove data from the linked list
;@param		R0 <- the data to delete
;@return    R0 <- Error Code
Remove			FUNCTION			
;//-------- <<< USER CODE BEGIN Remove Function >>> ----------------------															
				PUSH	{LR}			;Preserves the address of the Sys_handler
				LDR 	R1,=DATA_MEM	;Load the address of Data memory in R1
				LDR 	R2,=FIRST_ELEMENT	;Load the address of the First_Element in R2
				LDR 	R3,[R2]		;Load the address of the first element of linked list
				CMP		R3, #0		;Compare R3 with 0
				BEQ		empty		;If linked list is empty returns error code 3
				MOVS 	R5, #0		;counter for loop (i)
iteration		LDR		R4, [R3]		;Load the data of the first element to R4
				CMP		R4, R0			;Compares R4 with input (R0)
				BEQ		delete		;If R4 is what user looks for program goes for delete
				MOVS 	R6, R3		;Copy the current element address to R6
				LDR		R3, [R3,#4]	;Assigns the address of the next element to R3
				CMP		R3, #0		;Looks if Array is finished yet or not
				BEQ		not_found	;If yes, program goes for not_found
				ADDS	R5, #4		;increasement of i
				B		iteration	;branching loop
				


delete			CMP 	R5, #0				;compare r5 with 0, program removes the asked element
				BEQ		delete_first		;if element asked for removal is the first one, goes for delete_first	
				
				LDR		R4, [R3, #4]		;Load address of the next of the removal element to R4
				STR 	R4, [R6, #4]		;Store R4 in previous element of linked list 
				MOVS	R4, #0			;Assings 0 to R4
				STR		R4, [R3]		;Assigns 0 to data of removal element, which means deletion
				STR 	R4, [R3,#4]		;Assigns 0 to address of removal element, which means deletion
				MOVS	R0, R3			;Copy R5(index of removal element) to R0
				BL		Free			;Branch Free
				MOVS	R0, #0		;success code
				POP		{PC}		;Back to Sys_Handler


delete_first	LDR		R4, [R3,#4]		;Load address of the next element to R4
				STR		R4, [R2]		;Change the address of the FIRST_ELEMENT
				
				MOVS	R4, #0			;Assings 0 to R4
				STR		R4, [R3]		;Assigns 0 to data of removal element, which means deletion
				STR 	R4, [R3,#4]		;Assigns 0 to address of removal element, which means deletion
				MOVS	R0, R3			;Copy R5(index of removal element) to R0
				BL		Free		;Branch Free
				MOVS	R0, #0		;success code
				POP		{PC}		;Back to Sys_Handler															
				

not_found		MOVS	R0, #4	;If linked list is empty returns error code 4	
				POP		{PC}		;Back to Sys_Handler


empty			MOVS	R0, #3	;If linked list is empty returns error code 3	
				POP		{PC}		;Back to Sys_Handler
;//-------- <<< USER CODE END Remove Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to clear the array and copy the linked list to the array
;@return	R0 <- Error Code
LinkedList2Arr	FUNCTION			
;//-------- <<< USER CODE BEGIN Linked List To Array >>> ----------------------			
				LDR 	R7, =ARRAY_MEM		;loads start address of array to r7
				LDR 	R5, =ARRAY_SIZE		;loads size of array to r5
				MOVS	R6, #0				;loads 0 to r6
clearll2a		SUBS	R5, R5, #4			;clears from last element of array to first element
				STR		R6, [R7,R5]			;assigns 0
				CMP		R5, R6				;compares 0 and R5
				BNE		clearll2a			;if the first element is not reached, branches to clearll2a
				
				LDR 	R3,=FIRST_ELEMENT	;loads the address of the FIRST_ELEMENT to R3
				LDR		R4, [R3]			;loads the value of first element to R4
				CMP		R4, #0				;compare R5 with 0
				BEQ		emptyll2a			;If linked list is empty, branch to emptyll2a
				LDR		R5, [R4]			;loads the value of first element to R5
				MOVS	R6, #0				;assisgns 0 to R6 to reach the first element of the array
loopll2a		STR		R5, [R7, R6]		;assigns the value of linked list to the array
				ADDS	R6, #4				;increases inex of the array (R6) by 4
				ADDS	R4, #4				;to reach the address value of linked list element
				LDR		R4, [R4]			;assigns the address value of linked list element to R3
				LDR		R5, [R4]			;assigns the value of the next element to R5
				CMP		R4, #0				;if the address value of linked list element is not empty
				BNE		loopll2a			;branch to loop
				MOVS	R0, #0				;success code
				BX		LR					;Back to Sys_Handler
				
emptyll2a		MOVS	R0, #5				;if linked list is empty returns error code 5	
				BX		LR				;Back to Sys_Handler
;//-------- <<< USER CODE END Linked List To Array >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to write errors to the error log array.
;@param		R0 -> Index of Input Dataset Array
;@param     R1 -> Error Code 
;@param     R2 -> Operation (Insertion / Deletion / LinkedList2Array)
;@param     R3 -> Data
WriteErrorLog	FUNCTION			
;//-------- <<< USER CODE BEGIN Write Error Log >>> ----------------------		
				PUSH	{LR}					;pushes LR
				
				LSLS	R4, R1, #8				;shifts left error code 8 times
				ADDS	R2, R2, R4				;sums operation value and shifted error code
				LSLS	R4, R0, #16				;shifts left index 16 times
				ADDS	R2, R2, R4				;sums shifted index, shifted error code and operation value
				LDR		R4, =INDEX_ERROR_LOG	;loads the address of the INDEX_ERROR_LOG to R4
				LDR		R5, [R4]				;loads the value of INDEX_ERROR_LOG to R5
				MOVS	R0, #12					
				MULS	R0, R5, R0
				LDR		R6, =LOG_MEM			;loads start address of error log array to R6
				STR		R2, [R6, R0]			;loads the first word to the array
				ADDS	R0, R0, #4				;increases index value by 4
				STR		R3, [R6, R0]			;loads the second word to the array (data)
				ADDS	R0, R0, #4				;increases index value by 4
				MOVS	R1, R0					;loads R0 value to R1
				BL		GetNow					;branch to GetNow function
				STR		R0, [R6, R1]			;loads the third word (timestamp)
				ADDS	R5, #1					;increases R5 value by 1
				STR		R5, [R4]				;loads R5 to INDEX_ERROR_LOG
				
				POP		{PC}					;returns to SysTick_Handler function
;//-------- <<< USER CODE END Write Error Log >>> ------------------------				
				ENDFUNC
				
;@brief 	This function will be used to get working time of the System Tick timer
;@return	R0 <- Working time of the System Tick Timer (in us).			
GetNow			FUNCTION			
;//-------- <<< USER CODE BEGIN Get Now >>> ----------------------																			
				LDR		R2, =TICK_COUNT			;loads the address of TICK_COUNT to R2
				LDR		R2, [R2]				;loads the value of TICK_COUNT to R2
				ADDS	R2, R2, #1				;increases TICK_COUNT value by one
				LDR		R0, =964				;assigns the period of the System Tick Timer Interrupt to R0
				MULS	R0, R2, R0				;multiplies TICK_COUNT value and 964 microseconds
				LDR  	R3, =0xE000E018			;loads the address of SysTick Current Value Register
				LDR		R3, [R3]				;loads the value of SysTick Current Value Register to R3
				LDR	 	R7, =15423				;assigns computed reload value (15423) to R7
				SUBS	R3, R7, R3				;subtracts the current value from the reload value
				LSRS	R7, R3, #4				;shifts right the result 4 times to divide by 16
				ADDS	R0, R0, R7				;calculates the final the working time
				
				BX		LR						;returns to WriteErrorLog function
;//-------- <<< USER CODE END Get Now >>> ------------------------
				ENDFUNC
				
;*******************************************************************************	

;//-------- <<< USER CODE BEGIN Functions >>> ----------------------															


;//-------- <<< USER CODE END Functions >>> ------------------------

;*******************************************************************************
;@endsection 		USER_FUNCTIONS
;*******************************************************************************
				ALIGN
				END		; Finish the assembly file
				
;*******************************************************************************
;@endfile 			main.s
;*******************************************************************************				

