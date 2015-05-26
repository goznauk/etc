	.section	__TEXT,__text,regular,pure_instructions
	.macosx_version_min 10, 10
	.globl	_main
	.align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## BB#0:
	pushq	%rbp
Ltmp0:
	.cfi_def_cfa_offset 16
Ltmp1:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Ltmp2:
	.cfi_def_cfa_register %rbp
	subq	$432, %rsp              ## imm = 0x1B0
	movl	$100, %esi
	leaq	-416(%rbp), %rdi
	movq	___stack_chk_guard@GOTPCREL(%rip), %rax
	movq	(%rax), %rax
	movq	%rax, -8(%rbp)
	callq	_generateArray
	movl	$100, %esi
	leaq	-420(%rbp), %rdx
	leaq	-424(%rbp), %rcx
	leaq	-416(%rbp), %rdi
	callq	_findMinMax
	leaq	L_.str(%rip), %rdi
	movl	-420(%rbp), %esi
	movl	-424(%rbp), %edx
	movb	$0, %al
	callq	_printf
	movq	___stack_chk_guard@GOTPCREL(%rip), %rcx
	movq	(%rcx), %rcx
	cmpq	-8(%rbp), %rcx
	movl	%eax, -428(%rbp)        ## 4-byte Spill
	jne	LBB0_2
## BB#1:                                ## %SP_return
	xorl	%eax, %eax
	addq	$432, %rsp              ## imm = 0x1B0
	popq	%rbp
	retq
LBB0_2:                                 ## %CallStackCheckFailBlk
	callq	___stack_chk_fail
	.cfi_endproc

	.globl	_generateArray
	.align	4, 0x90
_generateArray:                         ## @generateArray
	.cfi_startproc
## BB#0:
	pushq	%rbp
Ltmp3:
	.cfi_def_cfa_offset 16
Ltmp4:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Ltmp5:
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	xorl	%eax, %eax
	movl	%eax, %ecx
	movq	%rdi, -8(%rbp)
	movl	%esi, -12(%rbp)
	movq	%rcx, %rdi
	callq	_time
	movl	%eax, %esi
	movl	%esi, %edi
	callq	_srand
	movl	$0, -16(%rbp)
LBB1_1:                                 ## =>This Inner Loop Header: Depth=1
	movl	-16(%rbp), %eax
	cmpl	-12(%rbp), %eax
	jge	LBB1_4
## BB#2:                                ##   in Loop: Header=BB1_1 Depth=1
	callq	_rand
	leaq	L_.str1(%rip), %rdi
	movslq	-16(%rbp), %rcx
	movq	-8(%rbp), %rdx
	movl	%eax, (%rdx,%rcx,4)
	movslq	-16(%rbp), %rcx
	movq	-8(%rbp), %rdx
	movl	(%rdx,%rcx,4), %esi
	movb	$0, %al
	callq	_printf
	movl	%eax, -20(%rbp)         ## 4-byte Spill
## BB#3:                                ##   in Loop: Header=BB1_1 Depth=1
	movl	-16(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -16(%rbp)
	jmp	LBB1_1
LBB1_4:
	addq	$32, %rsp
	popq	%rbp
	retq
	.cfi_endproc

	.globl	_findMinMax
	.align	4, 0x90
_findMinMax:                            ## @findMinMax
	.cfi_startproc
## BB#0:
	pushq	%rbp
Ltmp6:
	.cfi_def_cfa_offset 16
Ltmp7:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Ltmp8:
	.cfi_def_cfa_register %rbp
	movq	%rdi, -8(%rbp)
	movl	%esi, -12(%rbp)
	movq	%rdx, -24(%rbp)
	movq	%rcx, -32(%rbp)
	movq	-8(%rbp), %rcx
	movl	(%rcx), %esi
	movl	%esi, -36(%rbp)
	movq	-8(%rbp), %rcx
	movl	(%rcx), %esi
	movl	%esi, -40(%rbp)
	movl	$1, -44(%rbp)
LBB2_1:                                 ## =>This Inner Loop Header: Depth=1
	movl	-44(%rbp), %eax
	cmpl	-12(%rbp), %eax
	jge	LBB2_8
## BB#2:                                ##   in Loop: Header=BB2_1 Depth=1
	movslq	-44(%rbp), %rax
	movq	-8(%rbp), %rcx
	movl	(%rcx,%rax,4), %edx
	cmpl	-36(%rbp), %edx
	jge	LBB2_4
## BB#3:                                ##   in Loop: Header=BB2_1 Depth=1
	movslq	-44(%rbp), %rax
	movq	-8(%rbp), %rcx
	movl	(%rcx,%rax,4), %edx
	movl	%edx, -36(%rbp)
LBB2_4:                                 ##   in Loop: Header=BB2_1 Depth=1
	movslq	-44(%rbp), %rax
	movq	-8(%rbp), %rcx
	movl	(%rcx,%rax,4), %edx
	cmpl	-40(%rbp), %edx
	jle	LBB2_6
## BB#5:                                ##   in Loop: Header=BB2_1 Depth=1
	movslq	-44(%rbp), %rax
	movq	-8(%rbp), %rcx
	movl	(%rcx,%rax,4), %edx
	movl	%edx, -40(%rbp)
LBB2_6:                                 ##   in Loop: Header=BB2_1 Depth=1
	jmp	LBB2_7
LBB2_7:                                 ##   in Loop: Header=BB2_1 Depth=1
	movl	-44(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -44(%rbp)
	jmp	LBB2_1
LBB2_8:
	movl	-36(%rbp), %eax
	movq	-24(%rbp), %rcx
	movl	%eax, (%rcx)
	movl	-40(%rbp), %eax
	movq	-32(%rbp), %rcx
	movl	%eax, (%rcx)
	popq	%rbp
	retq
	.cfi_endproc

	.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"(Min, Max) = (%d, %d)\n"

L_.str1:                                ## @.str1
	.asciz	"%d, "


.subsections_via_symbols
