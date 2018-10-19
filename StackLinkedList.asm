format PE console 6.0
entry main
include 'win32ax.inc'

struct Node
	value	dd	?
	pNext	dd	?
ends

struct Stack
	pTop	dd	?	; ptr to Node
ends

section '.code' code readable executable
main:
	
	ccall Main
	invoke ExitProcess,eax
	
	proc Main c
	local stack:Stack
	local adrStack:DWORD
	
		lea eax,[stack]
		mov dword[eax + Stack.pTop],0
		mov [adrStack],eax
		
		cinvoke printf,<'is there some data on the stack...',13,10,0>
		ccall printData,[adrStack]
		
		cinvoke printf,<'push some data on the stack...',13,10,0>
		ccall pushData,[adrStack],1
		ccall pushData,[adrStack],2
		ccall pushData,[adrStack],3
		ccall pushData,[adrStack],4
		ccall pushData,[adrStack],5
		
		cinvoke printf,<'printing from the top...',13,10,0>
		ccall printData,[adrStack]
		
		cinvoke printf,<'push some more data...',13,10,0>
		ccall pushData,[adrStack],6
		ccall pushData,[adrStack],7
		
		ccall peekData,[adrStack]
		cinvoke printf,<'and the current top value is %d ...',13,10,0>,eax
		
		cinvoke printf,<'push some more data...',13,10,0>
		ccall pushData,[adrStack],8
		ccall pushData,[adrStack],9
		ccall pushData,[adrStack],10
		
		cinvoke printf,<'printing from the top...',13,10,0>
		ccall printData,[adrStack]
		
		cinvoke printf,<'pop some data...',13,10,0>
		ccall popData,[adrStack]
		ccall popData,[adrStack]
		ccall popData,[adrStack]
		ccall popData,[adrStack]
		ccall popData,[adrStack]
		
		cinvoke printf,<'what is left on the stack then...',13,10,0>
		ccall printData,[adrStack]
		
		cinvoke printf,<'delete all...',13,10,0>
		ccall deleteStack,[adrStack]
		
		cinvoke printf,<'exit...',13,10,0>
		
		xor eax,eax
		ret
	endp
	
	proc pushData c uses ebx,adrStack,value
		cinvoke malloc,sizeof.Node
		; yea , yea , I know
		mov edx,[value]
		mov [eax + Node.value],edx
		mov [eax + Node.pNext],0
		
		mov ebx,[adrStack]
		
		.if dword[ebx + Stack.pTop] = 0
			mov [ebx + Stack.pTop],eax
		.else
			mov edx,[ebx + Stack.pTop]
			mov [eax + Node.pNext],edx
			mov [ebx + Stack.pTop],eax
		.endif
		
		xor eax,eax
		ret
	endp
	
	proc popData c uses ebx esi edi,adrStack
		ccall isEmpty,[adrStack]
		.if eax = 1
			cinvoke printf,<'The Stack is Empty, no data to pop...',13,10,0>
			jmp .out
		.endif
		
		mov ebx,[adrStack]
		mov esi,[ebx + Stack.pTop]
		mov edi,[ebx + Stack.pTop]
		mov edi,[edi + Node.value]
		
		mov edx,[esi + Node.pNext]
		mov [ebx + Stack.pTop],edx 
		
		cinvoke free,esi
		
		cinvoke printf,<'%d is out...',13,10,0>,edi
		
		xor eax,eax
	.out:
		ret
	endp
	
	proc peekData c uses ebx,adrStack
		mov ebx,[adrStack]
		mov eax,[ebx + Stack.pTop]
		mov eax,[eax + Node.value]
		
		ret
	endp
	
	proc deleteStack c uses ebx esi esi,adrStack
		ccall isEmpty,[adrStack]
		.if eax = 1
			cinvoke printf,<'The Stack is Empty, no data to delete...',13,10,0>
			jmp .out
		.endif
		
		mov ebx,[adrStack]
		mov esi,[ebx + Stack.pTop]
		
		.repeat
			mov edi,[esi + Node.pNext]
			cinvoke printf,<'Deleting %d...',13,10,0>,dword[esi + Node.value]
			cinvoke free,esi
			mov esi,edi
		.until esi = 0
		
		mov dword[ebx + Stack.pTop],0
		
		xor eax,eax
	.out:
		ret
	endp
	
	proc isEmpty c uses ebx,adrStack
		mov ebx,[adrStack]
		.if dword[ebx + Stack.pTop] = 0
			mov eax,1
			jmp .out
		.endif
		
		xor eax,eax
	.out:	
		ret
	endp
	
	proc printData c uses ebx esi,adrStack
		ccall isEmpty,[adrStack]
		.if eax = 1
			cinvoke printf,<'The Stack is Empty, no data to print...',13,10,0>
			jmp .out
		.endif
		
		mov ebx,[adrStack]
		mov esi,[ebx + Stack.pTop]
		
		.repeat
			cinvoke printf,<'Value %d',13,10,0>,dword[esi + Node.value]
			mov esi,[esi + Node.pNext]
		.until esi = 0
		cinvoke printf,<'',13,10,0>
		
	.out:
		ret
	endp
	
section '.data' data readable writeable
	nop

section '.idata' data import readable
	library kernel32,'kernel32.dll',\
			msvcrt,'msvcrt.dll'

	import kernel32,\
			ExitProcess,'ExitProcess'

	import msvcrt,\	
			malloc,'malloc',\		
			free,'free',\
			printf,'printf'
			
