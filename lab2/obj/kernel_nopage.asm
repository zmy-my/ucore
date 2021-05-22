
bin/kernel_nopage:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 b0 11 40       	mov    $0x4011b000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 b0 11 00       	mov    %eax,0x11b000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 a0 11 00       	mov    $0x11a000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba bc df 11 00       	mov    $0x11dfbc,%edx
  100041:	b8 36 aa 11 00       	mov    $0x11aa36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 aa 11 00 	movl   $0x11aa36,(%esp)
  10005d:	e8 f9 65 00 00       	call   10665b <memset>

    cons_init();                // init the console
  100062:	e8 80 15 00 00       	call   1015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 60 6e 10 00 	movl   $0x106e60,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 7c 6e 10 00 	movl   $0x106e7c,(%esp)
  10007c:	e8 11 02 00 00       	call   100292 <cprintf>

    print_kerninfo();
  100081:	e8 b2 08 00 00       	call   100938 <print_kerninfo>

    grade_backtrace();
  100086:	e8 89 00 00 00       	call   100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 9a 30 00 00       	call   10312a <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 b7 16 00 00       	call   10174c <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 17 18 00 00       	call   1018b1 <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 eb 0c 00 00       	call   100d8a <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 e2 17 00 00       	call   101886 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a4:	eb fe                	jmp    1000a4 <kern_init+0x6e>

001000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a6:	55                   	push   %ebp
  1000a7:	89 e5                	mov    %esp,%ebp
  1000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b3:	00 
  1000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bb:	00 
  1000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c3:	e8 b0 0c 00 00       	call   100d78 <mon_backtrace>
}
  1000c8:	90                   	nop
  1000c9:	c9                   	leave  
  1000ca:	c3                   	ret    

001000cb <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000cb:	55                   	push   %ebp
  1000cc:	89 e5                	mov    %esp,%ebp
  1000ce:	53                   	push   %ebx
  1000cf:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000db:	8b 45 08             	mov    0x8(%ebp),%eax
  1000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ea:	89 04 24             	mov    %eax,(%esp)
  1000ed:	e8 b4 ff ff ff       	call   1000a6 <grade_backtrace2>
}
  1000f2:	90                   	nop
  1000f3:	83 c4 14             	add    $0x14,%esp
  1000f6:	5b                   	pop    %ebx
  1000f7:	5d                   	pop    %ebp
  1000f8:	c3                   	ret    

001000f9 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000f9:	55                   	push   %ebp
  1000fa:	89 e5                	mov    %esp,%ebp
  1000fc:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000ff:	8b 45 10             	mov    0x10(%ebp),%eax
  100102:	89 44 24 04          	mov    %eax,0x4(%esp)
  100106:	8b 45 08             	mov    0x8(%ebp),%eax
  100109:	89 04 24             	mov    %eax,(%esp)
  10010c:	e8 ba ff ff ff       	call   1000cb <grade_backtrace1>
}
  100111:	90                   	nop
  100112:	c9                   	leave  
  100113:	c3                   	ret    

00100114 <grade_backtrace>:

void
grade_backtrace(void) {
  100114:	55                   	push   %ebp
  100115:	89 e5                	mov    %esp,%ebp
  100117:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011a:	b8 36 00 10 00       	mov    $0x100036,%eax
  10011f:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100126:	ff 
  100127:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100132:	e8 c2 ff ff ff       	call   1000f9 <grade_backtrace0>
}
  100137:	90                   	nop
  100138:	c9                   	leave  
  100139:	c3                   	ret    

0010013a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013a:	55                   	push   %ebp
  10013b:	89 e5                	mov    %esp,%ebp
  10013d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100140:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100143:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100146:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100149:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10014c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100150:	83 e0 03             	and    $0x3,%eax
  100153:	89 c2                	mov    %eax,%edx
  100155:	a1 00 d0 11 00       	mov    0x11d000,%eax
  10015a:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100162:	c7 04 24 81 6e 10 00 	movl   $0x106e81,(%esp)
  100169:	e8 24 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100172:	89 c2                	mov    %eax,%edx
  100174:	a1 00 d0 11 00       	mov    0x11d000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 8f 6e 10 00 	movl   $0x106e8f,(%esp)
  100188:	e8 05 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	89 c2                	mov    %eax,%edx
  100193:	a1 00 d0 11 00       	mov    0x11d000,%eax
  100198:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a0:	c7 04 24 9d 6e 10 00 	movl   $0x106e9d,(%esp)
  1001a7:	e8 e6 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b0:	89 c2                	mov    %eax,%edx
  1001b2:	a1 00 d0 11 00       	mov    0x11d000,%eax
  1001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001bf:	c7 04 24 ab 6e 10 00 	movl   $0x106eab,(%esp)
  1001c6:	e8 c7 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001cf:	89 c2                	mov    %eax,%edx
  1001d1:	a1 00 d0 11 00       	mov    0x11d000,%eax
  1001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001de:	c7 04 24 b9 6e 10 00 	movl   $0x106eb9,(%esp)
  1001e5:	e8 a8 00 00 00       	call   100292 <cprintf>
    round ++;
  1001ea:	a1 00 d0 11 00       	mov    0x11d000,%eax
  1001ef:	40                   	inc    %eax
  1001f0:	a3 00 d0 11 00       	mov    %eax,0x11d000
}
  1001f5:	90                   	nop
  1001f6:	c9                   	leave  
  1001f7:	c3                   	ret    

001001f8 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001f8:	55                   	push   %ebp
  1001f9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001fb:	90                   	nop
  1001fc:	5d                   	pop    %ebp
  1001fd:	c3                   	ret    

001001fe <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001fe:	55                   	push   %ebp
  1001ff:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100201:	90                   	nop
  100202:	5d                   	pop    %ebp
  100203:	c3                   	ret    

00100204 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100204:	55                   	push   %ebp
  100205:	89 e5                	mov    %esp,%ebp
  100207:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10020a:	e8 2b ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  10020f:	c7 04 24 c8 6e 10 00 	movl   $0x106ec8,(%esp)
  100216:	e8 77 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_user();
  10021b:	e8 d8 ff ff ff       	call   1001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
  100220:	e8 15 ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100225:	c7 04 24 e8 6e 10 00 	movl   $0x106ee8,(%esp)
  10022c:	e8 61 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_kernel();
  100231:	e8 c8 ff ff ff       	call   1001fe <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100236:	e8 ff fe ff ff       	call   10013a <lab1_print_cur_status>
}
  10023b:	90                   	nop
  10023c:	c9                   	leave  
  10023d:	c3                   	ret    

0010023e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  10023e:	55                   	push   %ebp
  10023f:	89 e5                	mov    %esp,%ebp
  100241:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100244:	8b 45 08             	mov    0x8(%ebp),%eax
  100247:	89 04 24             	mov    %eax,(%esp)
  10024a:	e8 c5 13 00 00       	call   101614 <cons_putc>
    (*cnt) ++;
  10024f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100252:	8b 00                	mov    (%eax),%eax
  100254:	8d 50 01             	lea    0x1(%eax),%edx
  100257:	8b 45 0c             	mov    0xc(%ebp),%eax
  10025a:	89 10                	mov    %edx,(%eax)
}
  10025c:	90                   	nop
  10025d:	c9                   	leave  
  10025e:	c3                   	ret    

0010025f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  10025f:	55                   	push   %ebp
  100260:	89 e5                	mov    %esp,%ebp
  100262:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100265:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10026c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100273:	8b 45 08             	mov    0x8(%ebp),%eax
  100276:	89 44 24 08          	mov    %eax,0x8(%esp)
  10027a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10027d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100281:	c7 04 24 3e 02 10 00 	movl   $0x10023e,(%esp)
  100288:	e8 21 67 00 00       	call   1069ae <vprintfmt>
    return cnt;
  10028d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100290:	c9                   	leave  
  100291:	c3                   	ret    

00100292 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100292:	55                   	push   %ebp
  100293:	89 e5                	mov    %esp,%ebp
  100295:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100298:	8d 45 0c             	lea    0xc(%ebp),%eax
  10029b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10029e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002a8:	89 04 24             	mov    %eax,(%esp)
  1002ab:	e8 af ff ff ff       	call   10025f <vcprintf>
  1002b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002b6:	c9                   	leave  
  1002b7:	c3                   	ret    

001002b8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002b8:	55                   	push   %ebp
  1002b9:	89 e5                	mov    %esp,%ebp
  1002bb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002be:	8b 45 08             	mov    0x8(%ebp),%eax
  1002c1:	89 04 24             	mov    %eax,(%esp)
  1002c4:	e8 4b 13 00 00       	call   101614 <cons_putc>
}
  1002c9:	90                   	nop
  1002ca:	c9                   	leave  
  1002cb:	c3                   	ret    

001002cc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002cc:	55                   	push   %ebp
  1002cd:	89 e5                	mov    %esp,%ebp
  1002cf:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002d9:	eb 13                	jmp    1002ee <cputs+0x22>
        cputch(c, &cnt);
  1002db:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002df:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002e6:	89 04 24             	mov    %eax,(%esp)
  1002e9:	e8 50 ff ff ff       	call   10023e <cputch>
    while ((c = *str ++) != '\0') {
  1002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1002f1:	8d 50 01             	lea    0x1(%eax),%edx
  1002f4:	89 55 08             	mov    %edx,0x8(%ebp)
  1002f7:	0f b6 00             	movzbl (%eax),%eax
  1002fa:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002fd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100301:	75 d8                	jne    1002db <cputs+0xf>
    }
    cputch('\n', &cnt);
  100303:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100306:	89 44 24 04          	mov    %eax,0x4(%esp)
  10030a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  100311:	e8 28 ff ff ff       	call   10023e <cputch>
    return cnt;
  100316:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  100319:	c9                   	leave  
  10031a:	c3                   	ret    

0010031b <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  10031b:	55                   	push   %ebp
  10031c:	89 e5                	mov    %esp,%ebp
  10031e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100321:	e8 2b 13 00 00       	call   101651 <cons_getc>
  100326:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100329:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10032d:	74 f2                	je     100321 <getchar+0x6>
        /* do nothing */;
    return c;
  10032f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100332:	c9                   	leave  
  100333:	c3                   	ret    

00100334 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100334:	55                   	push   %ebp
  100335:	89 e5                	mov    %esp,%ebp
  100337:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10033a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10033e:	74 13                	je     100353 <readline+0x1f>
        cprintf("%s", prompt);
  100340:	8b 45 08             	mov    0x8(%ebp),%eax
  100343:	89 44 24 04          	mov    %eax,0x4(%esp)
  100347:	c7 04 24 07 6f 10 00 	movl   $0x106f07,(%esp)
  10034e:	e8 3f ff ff ff       	call   100292 <cprintf>
    }
    int i = 0, c;
  100353:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10035a:	e8 bc ff ff ff       	call   10031b <getchar>
  10035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100362:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100366:	79 07                	jns    10036f <readline+0x3b>
            return NULL;
  100368:	b8 00 00 00 00       	mov    $0x0,%eax
  10036d:	eb 78                	jmp    1003e7 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10036f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100373:	7e 28                	jle    10039d <readline+0x69>
  100375:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10037c:	7f 1f                	jg     10039d <readline+0x69>
            cputchar(c);
  10037e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100381:	89 04 24             	mov    %eax,(%esp)
  100384:	e8 2f ff ff ff       	call   1002b8 <cputchar>
            buf[i ++] = c;
  100389:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10038c:	8d 50 01             	lea    0x1(%eax),%edx
  10038f:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100392:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100395:	88 90 20 d0 11 00    	mov    %dl,0x11d020(%eax)
  10039b:	eb 45                	jmp    1003e2 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  10039d:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1003a1:	75 16                	jne    1003b9 <readline+0x85>
  1003a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003a7:	7e 10                	jle    1003b9 <readline+0x85>
            cputchar(c);
  1003a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003ac:	89 04 24             	mov    %eax,(%esp)
  1003af:	e8 04 ff ff ff       	call   1002b8 <cputchar>
            i --;
  1003b4:	ff 4d f4             	decl   -0xc(%ebp)
  1003b7:	eb 29                	jmp    1003e2 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1003b9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1003bd:	74 06                	je     1003c5 <readline+0x91>
  1003bf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1003c3:	75 95                	jne    10035a <readline+0x26>
            cputchar(c);
  1003c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003c8:	89 04 24             	mov    %eax,(%esp)
  1003cb:	e8 e8 fe ff ff       	call   1002b8 <cputchar>
            buf[i] = '\0';
  1003d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003d3:	05 20 d0 11 00       	add    $0x11d020,%eax
  1003d8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003db:	b8 20 d0 11 00       	mov    $0x11d020,%eax
  1003e0:	eb 05                	jmp    1003e7 <readline+0xb3>
        c = getchar();
  1003e2:	e9 73 ff ff ff       	jmp    10035a <readline+0x26>
        }
    }
}
  1003e7:	c9                   	leave  
  1003e8:	c3                   	ret    

001003e9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003e9:	55                   	push   %ebp
  1003ea:	89 e5                	mov    %esp,%ebp
  1003ec:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003ef:	a1 20 d4 11 00       	mov    0x11d420,%eax
  1003f4:	85 c0                	test   %eax,%eax
  1003f6:	75 5b                	jne    100453 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  1003f8:	c7 05 20 d4 11 00 01 	movl   $0x1,0x11d420
  1003ff:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100402:	8d 45 14             	lea    0x14(%ebp),%eax
  100405:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100408:	8b 45 0c             	mov    0xc(%ebp),%eax
  10040b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10040f:	8b 45 08             	mov    0x8(%ebp),%eax
  100412:	89 44 24 04          	mov    %eax,0x4(%esp)
  100416:	c7 04 24 0a 6f 10 00 	movl   $0x106f0a,(%esp)
  10041d:	e8 70 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100425:	89 44 24 04          	mov    %eax,0x4(%esp)
  100429:	8b 45 10             	mov    0x10(%ebp),%eax
  10042c:	89 04 24             	mov    %eax,(%esp)
  10042f:	e8 2b fe ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  100434:	c7 04 24 26 6f 10 00 	movl   $0x106f26,(%esp)
  10043b:	e8 52 fe ff ff       	call   100292 <cprintf>
    
    cprintf("stack trackback:\n");
  100440:	c7 04 24 28 6f 10 00 	movl   $0x106f28,(%esp)
  100447:	e8 46 fe ff ff       	call   100292 <cprintf>
    print_stackframe();
  10044c:	e8 32 06 00 00       	call   100a83 <print_stackframe>
  100451:	eb 01                	jmp    100454 <__panic+0x6b>
        goto panic_dead;
  100453:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100454:	e8 34 14 00 00       	call   10188d <intr_disable>
    while (1) {
        kmonitor(NULL);
  100459:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100460:	e8 46 08 00 00       	call   100cab <kmonitor>
  100465:	eb f2                	jmp    100459 <__panic+0x70>

00100467 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100467:	55                   	push   %ebp
  100468:	89 e5                	mov    %esp,%ebp
  10046a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  10046d:	8d 45 14             	lea    0x14(%ebp),%eax
  100470:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100473:	8b 45 0c             	mov    0xc(%ebp),%eax
  100476:	89 44 24 08          	mov    %eax,0x8(%esp)
  10047a:	8b 45 08             	mov    0x8(%ebp),%eax
  10047d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100481:	c7 04 24 3a 6f 10 00 	movl   $0x106f3a,(%esp)
  100488:	e8 05 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  10048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100490:	89 44 24 04          	mov    %eax,0x4(%esp)
  100494:	8b 45 10             	mov    0x10(%ebp),%eax
  100497:	89 04 24             	mov    %eax,(%esp)
  10049a:	e8 c0 fd ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  10049f:	c7 04 24 26 6f 10 00 	movl   $0x106f26,(%esp)
  1004a6:	e8 e7 fd ff ff       	call   100292 <cprintf>
    va_end(ap);
}
  1004ab:	90                   	nop
  1004ac:	c9                   	leave  
  1004ad:	c3                   	ret    

001004ae <is_kernel_panic>:

bool
is_kernel_panic(void) {
  1004ae:	55                   	push   %ebp
  1004af:	89 e5                	mov    %esp,%ebp
    return is_panic;
  1004b1:	a1 20 d4 11 00       	mov    0x11d420,%eax
}
  1004b6:	5d                   	pop    %ebp
  1004b7:	c3                   	ret    

001004b8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1004b8:	55                   	push   %ebp
  1004b9:	89 e5                	mov    %esp,%ebp
  1004bb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1004be:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004c1:	8b 00                	mov    (%eax),%eax
  1004c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1004c9:	8b 00                	mov    (%eax),%eax
  1004cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004d5:	e9 ca 00 00 00       	jmp    1005a4 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  1004da:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004e0:	01 d0                	add    %edx,%eax
  1004e2:	89 c2                	mov    %eax,%edx
  1004e4:	c1 ea 1f             	shr    $0x1f,%edx
  1004e7:	01 d0                	add    %edx,%eax
  1004e9:	d1 f8                	sar    %eax
  1004eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004f4:	eb 03                	jmp    1004f9 <stab_binsearch+0x41>
            m --;
  1004f6:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  1004f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004ff:	7c 1f                	jl     100520 <stab_binsearch+0x68>
  100501:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100504:	89 d0                	mov    %edx,%eax
  100506:	01 c0                	add    %eax,%eax
  100508:	01 d0                	add    %edx,%eax
  10050a:	c1 e0 02             	shl    $0x2,%eax
  10050d:	89 c2                	mov    %eax,%edx
  10050f:	8b 45 08             	mov    0x8(%ebp),%eax
  100512:	01 d0                	add    %edx,%eax
  100514:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100518:	0f b6 c0             	movzbl %al,%eax
  10051b:	39 45 14             	cmp    %eax,0x14(%ebp)
  10051e:	75 d6                	jne    1004f6 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  100520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100523:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100526:	7d 09                	jge    100531 <stab_binsearch+0x79>
            l = true_m + 1;
  100528:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10052b:	40                   	inc    %eax
  10052c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10052f:	eb 73                	jmp    1005a4 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  100531:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100538:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10053b:	89 d0                	mov    %edx,%eax
  10053d:	01 c0                	add    %eax,%eax
  10053f:	01 d0                	add    %edx,%eax
  100541:	c1 e0 02             	shl    $0x2,%eax
  100544:	89 c2                	mov    %eax,%edx
  100546:	8b 45 08             	mov    0x8(%ebp),%eax
  100549:	01 d0                	add    %edx,%eax
  10054b:	8b 40 08             	mov    0x8(%eax),%eax
  10054e:	39 45 18             	cmp    %eax,0x18(%ebp)
  100551:	76 11                	jbe    100564 <stab_binsearch+0xac>
            *region_left = m;
  100553:	8b 45 0c             	mov    0xc(%ebp),%eax
  100556:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100559:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10055b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10055e:	40                   	inc    %eax
  10055f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100562:	eb 40                	jmp    1005a4 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  100564:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100567:	89 d0                	mov    %edx,%eax
  100569:	01 c0                	add    %eax,%eax
  10056b:	01 d0                	add    %edx,%eax
  10056d:	c1 e0 02             	shl    $0x2,%eax
  100570:	89 c2                	mov    %eax,%edx
  100572:	8b 45 08             	mov    0x8(%ebp),%eax
  100575:	01 d0                	add    %edx,%eax
  100577:	8b 40 08             	mov    0x8(%eax),%eax
  10057a:	39 45 18             	cmp    %eax,0x18(%ebp)
  10057d:	73 14                	jae    100593 <stab_binsearch+0xdb>
            *region_right = m - 1;
  10057f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100582:	8d 50 ff             	lea    -0x1(%eax),%edx
  100585:	8b 45 10             	mov    0x10(%ebp),%eax
  100588:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10058a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10058d:	48                   	dec    %eax
  10058e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100591:	eb 11                	jmp    1005a4 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  100593:	8b 45 0c             	mov    0xc(%ebp),%eax
  100596:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100599:	89 10                	mov    %edx,(%eax)
            l = m;
  10059b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10059e:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1005a1:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  1005a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1005a7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1005aa:	0f 8e 2a ff ff ff    	jle    1004da <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  1005b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1005b4:	75 0f                	jne    1005c5 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1005b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005b9:	8b 00                	mov    (%eax),%eax
  1005bb:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005be:	8b 45 10             	mov    0x10(%ebp),%eax
  1005c1:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  1005c3:	eb 3e                	jmp    100603 <stab_binsearch+0x14b>
        l = *region_right;
  1005c5:	8b 45 10             	mov    0x10(%ebp),%eax
  1005c8:	8b 00                	mov    (%eax),%eax
  1005ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005cd:	eb 03                	jmp    1005d2 <stab_binsearch+0x11a>
  1005cf:	ff 4d fc             	decl   -0x4(%ebp)
  1005d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005d5:	8b 00                	mov    (%eax),%eax
  1005d7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  1005da:	7e 1f                	jle    1005fb <stab_binsearch+0x143>
  1005dc:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005df:	89 d0                	mov    %edx,%eax
  1005e1:	01 c0                	add    %eax,%eax
  1005e3:	01 d0                	add    %edx,%eax
  1005e5:	c1 e0 02             	shl    $0x2,%eax
  1005e8:	89 c2                	mov    %eax,%edx
  1005ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1005ed:	01 d0                	add    %edx,%eax
  1005ef:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005f3:	0f b6 c0             	movzbl %al,%eax
  1005f6:	39 45 14             	cmp    %eax,0x14(%ebp)
  1005f9:	75 d4                	jne    1005cf <stab_binsearch+0x117>
        *region_left = l;
  1005fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100601:	89 10                	mov    %edx,(%eax)
}
  100603:	90                   	nop
  100604:	c9                   	leave  
  100605:	c3                   	ret    

00100606 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100606:	55                   	push   %ebp
  100607:	89 e5                	mov    %esp,%ebp
  100609:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10060c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10060f:	c7 00 58 6f 10 00    	movl   $0x106f58,(%eax)
    info->eip_line = 0;
  100615:	8b 45 0c             	mov    0xc(%ebp),%eax
  100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10061f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100622:	c7 40 08 58 6f 10 00 	movl   $0x106f58,0x8(%eax)
    info->eip_fn_namelen = 9;
  100629:	8b 45 0c             	mov    0xc(%ebp),%eax
  10062c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100633:	8b 45 0c             	mov    0xc(%ebp),%eax
  100636:	8b 55 08             	mov    0x8(%ebp),%edx
  100639:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10063c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10063f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100646:	c7 45 f4 4c 84 10 00 	movl   $0x10844c,-0xc(%ebp)
    stab_end = __STAB_END__;
  10064d:	c7 45 f0 d0 4d 11 00 	movl   $0x114dd0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100654:	c7 45 ec d1 4d 11 00 	movl   $0x114dd1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10065b:	c7 45 e8 ba 7a 11 00 	movl   $0x117aba,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100662:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100665:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100668:	76 0b                	jbe    100675 <debuginfo_eip+0x6f>
  10066a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10066d:	48                   	dec    %eax
  10066e:	0f b6 00             	movzbl (%eax),%eax
  100671:	84 c0                	test   %al,%al
  100673:	74 0a                	je     10067f <debuginfo_eip+0x79>
        return -1;
  100675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10067a:	e9 b7 02 00 00       	jmp    100936 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  10067f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100686:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10068c:	29 c2                	sub    %eax,%edx
  10068e:	89 d0                	mov    %edx,%eax
  100690:	c1 f8 02             	sar    $0x2,%eax
  100693:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  100699:	48                   	dec    %eax
  10069a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  10069d:	8b 45 08             	mov    0x8(%ebp),%eax
  1006a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006a4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1006ab:	00 
  1006ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1006af:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1006b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006bd:	89 04 24             	mov    %eax,(%esp)
  1006c0:	e8 f3 fd ff ff       	call   1004b8 <stab_binsearch>
    if (lfile == 0)
  1006c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006c8:	85 c0                	test   %eax,%eax
  1006ca:	75 0a                	jne    1006d6 <debuginfo_eip+0xd0>
        return -1;
  1006cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006d1:	e9 60 02 00 00       	jmp    100936 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1006e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006e9:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1006f0:	00 
  1006f1:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006f8:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100702:	89 04 24             	mov    %eax,(%esp)
  100705:	e8 ae fd ff ff       	call   1004b8 <stab_binsearch>

    if (lfun <= rfun) {
  10070a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10070d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100710:	39 c2                	cmp    %eax,%edx
  100712:	7f 7c                	jg     100790 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100714:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100717:	89 c2                	mov    %eax,%edx
  100719:	89 d0                	mov    %edx,%eax
  10071b:	01 c0                	add    %eax,%eax
  10071d:	01 d0                	add    %edx,%eax
  10071f:	c1 e0 02             	shl    $0x2,%eax
  100722:	89 c2                	mov    %eax,%edx
  100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100727:	01 d0                	add    %edx,%eax
  100729:	8b 00                	mov    (%eax),%eax
  10072b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10072e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100731:	29 d1                	sub    %edx,%ecx
  100733:	89 ca                	mov    %ecx,%edx
  100735:	39 d0                	cmp    %edx,%eax
  100737:	73 22                	jae    10075b <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100739:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10073c:	89 c2                	mov    %eax,%edx
  10073e:	89 d0                	mov    %edx,%eax
  100740:	01 c0                	add    %eax,%eax
  100742:	01 d0                	add    %edx,%eax
  100744:	c1 e0 02             	shl    $0x2,%eax
  100747:	89 c2                	mov    %eax,%edx
  100749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10074c:	01 d0                	add    %edx,%eax
  10074e:	8b 10                	mov    (%eax),%edx
  100750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100753:	01 c2                	add    %eax,%edx
  100755:	8b 45 0c             	mov    0xc(%ebp),%eax
  100758:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10075b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10075e:	89 c2                	mov    %eax,%edx
  100760:	89 d0                	mov    %edx,%eax
  100762:	01 c0                	add    %eax,%eax
  100764:	01 d0                	add    %edx,%eax
  100766:	c1 e0 02             	shl    $0x2,%eax
  100769:	89 c2                	mov    %eax,%edx
  10076b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10076e:	01 d0                	add    %edx,%eax
  100770:	8b 50 08             	mov    0x8(%eax),%edx
  100773:	8b 45 0c             	mov    0xc(%ebp),%eax
  100776:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100779:	8b 45 0c             	mov    0xc(%ebp),%eax
  10077c:	8b 40 10             	mov    0x10(%eax),%eax
  10077f:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100782:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100785:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100788:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10078b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10078e:	eb 15                	jmp    1007a5 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  100790:	8b 45 0c             	mov    0xc(%ebp),%eax
  100793:	8b 55 08             	mov    0x8(%ebp),%edx
  100796:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  100799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10079c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  10079f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007a8:	8b 40 08             	mov    0x8(%eax),%eax
  1007ab:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1007b2:	00 
  1007b3:	89 04 24             	mov    %eax,(%esp)
  1007b6:	e8 1c 5d 00 00       	call   1064d7 <strfind>
  1007bb:	89 c2                	mov    %eax,%edx
  1007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007c0:	8b 40 08             	mov    0x8(%eax),%eax
  1007c3:	29 c2                	sub    %eax,%edx
  1007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007c8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1007ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007d2:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007d9:	00 
  1007da:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007e1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007eb:	89 04 24             	mov    %eax,(%esp)
  1007ee:	e8 c5 fc ff ff       	call   1004b8 <stab_binsearch>
    if (lline <= rline) {
  1007f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007f9:	39 c2                	cmp    %eax,%edx
  1007fb:	7f 23                	jg     100820 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
  1007fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100800:	89 c2                	mov    %eax,%edx
  100802:	89 d0                	mov    %edx,%eax
  100804:	01 c0                	add    %eax,%eax
  100806:	01 d0                	add    %edx,%eax
  100808:	c1 e0 02             	shl    $0x2,%eax
  10080b:	89 c2                	mov    %eax,%edx
  10080d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100810:	01 d0                	add    %edx,%eax
  100812:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100816:	89 c2                	mov    %eax,%edx
  100818:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10081e:	eb 11                	jmp    100831 <debuginfo_eip+0x22b>
        return -1;
  100820:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100825:	e9 0c 01 00 00       	jmp    100936 <debuginfo_eip+0x330>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10082a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10082d:	48                   	dec    %eax
  10082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100831:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100837:	39 c2                	cmp    %eax,%edx
  100839:	7c 56                	jl     100891 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
  10083b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10083e:	89 c2                	mov    %eax,%edx
  100840:	89 d0                	mov    %edx,%eax
  100842:	01 c0                	add    %eax,%eax
  100844:	01 d0                	add    %edx,%eax
  100846:	c1 e0 02             	shl    $0x2,%eax
  100849:	89 c2                	mov    %eax,%edx
  10084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10084e:	01 d0                	add    %edx,%eax
  100850:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100854:	3c 84                	cmp    $0x84,%al
  100856:	74 39                	je     100891 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10085b:	89 c2                	mov    %eax,%edx
  10085d:	89 d0                	mov    %edx,%eax
  10085f:	01 c0                	add    %eax,%eax
  100861:	01 d0                	add    %edx,%eax
  100863:	c1 e0 02             	shl    $0x2,%eax
  100866:	89 c2                	mov    %eax,%edx
  100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10086b:	01 d0                	add    %edx,%eax
  10086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100871:	3c 64                	cmp    $0x64,%al
  100873:	75 b5                	jne    10082a <debuginfo_eip+0x224>
  100875:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100878:	89 c2                	mov    %eax,%edx
  10087a:	89 d0                	mov    %edx,%eax
  10087c:	01 c0                	add    %eax,%eax
  10087e:	01 d0                	add    %edx,%eax
  100880:	c1 e0 02             	shl    $0x2,%eax
  100883:	89 c2                	mov    %eax,%edx
  100885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100888:	01 d0                	add    %edx,%eax
  10088a:	8b 40 08             	mov    0x8(%eax),%eax
  10088d:	85 c0                	test   %eax,%eax
  10088f:	74 99                	je     10082a <debuginfo_eip+0x224>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  100891:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100897:	39 c2                	cmp    %eax,%edx
  100899:	7c 46                	jl     1008e1 <debuginfo_eip+0x2db>
  10089b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10089e:	89 c2                	mov    %eax,%edx
  1008a0:	89 d0                	mov    %edx,%eax
  1008a2:	01 c0                	add    %eax,%eax
  1008a4:	01 d0                	add    %edx,%eax
  1008a6:	c1 e0 02             	shl    $0x2,%eax
  1008a9:	89 c2                	mov    %eax,%edx
  1008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008ae:	01 d0                	add    %edx,%eax
  1008b0:	8b 00                	mov    (%eax),%eax
  1008b2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1008b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008b8:	29 d1                	sub    %edx,%ecx
  1008ba:	89 ca                	mov    %ecx,%edx
  1008bc:	39 d0                	cmp    %edx,%eax
  1008be:	73 21                	jae    1008e1 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1008c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008c3:	89 c2                	mov    %eax,%edx
  1008c5:	89 d0                	mov    %edx,%eax
  1008c7:	01 c0                	add    %eax,%eax
  1008c9:	01 d0                	add    %edx,%eax
  1008cb:	c1 e0 02             	shl    $0x2,%eax
  1008ce:	89 c2                	mov    %eax,%edx
  1008d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008d3:	01 d0                	add    %edx,%eax
  1008d5:	8b 10                	mov    (%eax),%edx
  1008d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008da:	01 c2                	add    %eax,%edx
  1008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008df:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008e7:	39 c2                	cmp    %eax,%edx
  1008e9:	7d 46                	jge    100931 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
  1008eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008ee:	40                   	inc    %eax
  1008ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008f2:	eb 16                	jmp    10090a <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008f7:	8b 40 14             	mov    0x14(%eax),%eax
  1008fa:	8d 50 01             	lea    0x1(%eax),%edx
  1008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  100900:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100903:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100906:	40                   	inc    %eax
  100907:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10090a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10090d:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  100910:	39 c2                	cmp    %eax,%edx
  100912:	7d 1d                	jge    100931 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100914:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100917:	89 c2                	mov    %eax,%edx
  100919:	89 d0                	mov    %edx,%eax
  10091b:	01 c0                	add    %eax,%eax
  10091d:	01 d0                	add    %edx,%eax
  10091f:	c1 e0 02             	shl    $0x2,%eax
  100922:	89 c2                	mov    %eax,%edx
  100924:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100927:	01 d0                	add    %edx,%eax
  100929:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10092d:	3c a0                	cmp    $0xa0,%al
  10092f:	74 c3                	je     1008f4 <debuginfo_eip+0x2ee>
        }
    }
    return 0;
  100931:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100936:	c9                   	leave  
  100937:	c3                   	ret    

00100938 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100938:	55                   	push   %ebp
  100939:	89 e5                	mov    %esp,%ebp
  10093b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10093e:	c7 04 24 62 6f 10 00 	movl   $0x106f62,(%esp)
  100945:	e8 48 f9 ff ff       	call   100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10094a:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100951:	00 
  100952:	c7 04 24 7b 6f 10 00 	movl   $0x106f7b,(%esp)
  100959:	e8 34 f9 ff ff       	call   100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10095e:	c7 44 24 04 55 6e 10 	movl   $0x106e55,0x4(%esp)
  100965:	00 
  100966:	c7 04 24 93 6f 10 00 	movl   $0x106f93,(%esp)
  10096d:	e8 20 f9 ff ff       	call   100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100972:	c7 44 24 04 36 aa 11 	movl   $0x11aa36,0x4(%esp)
  100979:	00 
  10097a:	c7 04 24 ab 6f 10 00 	movl   $0x106fab,(%esp)
  100981:	e8 0c f9 ff ff       	call   100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100986:	c7 44 24 04 bc df 11 	movl   $0x11dfbc,0x4(%esp)
  10098d:	00 
  10098e:	c7 04 24 c3 6f 10 00 	movl   $0x106fc3,(%esp)
  100995:	e8 f8 f8 ff ff       	call   100292 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  10099a:	b8 bc df 11 00       	mov    $0x11dfbc,%eax
  10099f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009a5:	b8 36 00 10 00       	mov    $0x100036,%eax
  1009aa:	29 c2                	sub    %eax,%edx
  1009ac:	89 d0                	mov    %edx,%eax
  1009ae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009b4:	85 c0                	test   %eax,%eax
  1009b6:	0f 48 c2             	cmovs  %edx,%eax
  1009b9:	c1 f8 0a             	sar    $0xa,%eax
  1009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009c0:	c7 04 24 dc 6f 10 00 	movl   $0x106fdc,(%esp)
  1009c7:	e8 c6 f8 ff ff       	call   100292 <cprintf>
}
  1009cc:	90                   	nop
  1009cd:	c9                   	leave  
  1009ce:	c3                   	ret    

001009cf <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009cf:	55                   	push   %ebp
  1009d0:	89 e5                	mov    %esp,%ebp
  1009d2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009d8:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009db:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009df:	8b 45 08             	mov    0x8(%ebp),%eax
  1009e2:	89 04 24             	mov    %eax,(%esp)
  1009e5:	e8 1c fc ff ff       	call   100606 <debuginfo_eip>
  1009ea:	85 c0                	test   %eax,%eax
  1009ec:	74 15                	je     100a03 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1009f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009f5:	c7 04 24 06 70 10 00 	movl   $0x107006,(%esp)
  1009fc:	e8 91 f8 ff ff       	call   100292 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100a01:	eb 6c                	jmp    100a6f <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100a0a:	eb 1b                	jmp    100a27 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  100a0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a12:	01 d0                	add    %edx,%eax
  100a14:	0f b6 00             	movzbl (%eax),%eax
  100a17:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100a20:	01 ca                	add    %ecx,%edx
  100a22:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a24:	ff 45 f4             	incl   -0xc(%ebp)
  100a27:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a2a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  100a2d:	7c dd                	jl     100a0c <print_debuginfo+0x3d>
        fnname[j] = '\0';
  100a2f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a38:	01 d0                	add    %edx,%eax
  100a3a:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  100a3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a40:	8b 55 08             	mov    0x8(%ebp),%edx
  100a43:	89 d1                	mov    %edx,%ecx
  100a45:	29 c1                	sub    %eax,%ecx
  100a47:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a4d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a51:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a57:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a63:	c7 04 24 22 70 10 00 	movl   $0x107022,(%esp)
  100a6a:	e8 23 f8 ff ff       	call   100292 <cprintf>
}
  100a6f:	90                   	nop
  100a70:	c9                   	leave  
  100a71:	c3                   	ret    

00100a72 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a72:	55                   	push   %ebp
  100a73:	89 e5                	mov    %esp,%ebp
  100a75:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a78:	8b 45 04             	mov    0x4(%ebp),%eax
  100a7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a81:	c9                   	leave  
  100a82:	c3                   	ret    

00100a83 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a83:	55                   	push   %ebp
  100a84:	89 e5                	mov    %esp,%ebp
  100a86:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a89:	89 e8                	mov    %ebp,%eax
  100a8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100a8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp=read_ebp();
  100a91:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip=read_eip();
  100a94:	e8 d9 ff ff ff       	call   100a72 <read_eip>
  100a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for(int i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++){
  100a9c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100aa3:	e9 84 00 00 00       	jmp    100b2c <print_stackframe+0xa9>
		cprintf("epb:0x%08x eip:0x%08x args:",ebp,eip);
  100aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100aab:	89 44 24 08          	mov    %eax,0x8(%esp)
  100aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ab6:	c7 04 24 34 70 10 00 	movl   $0x107034,(%esp)
  100abd:	e8 d0 f7 ff ff       	call   100292 <cprintf>
		uint32_t* calling_arguments = (uint32_t*)ebp+2; 
  100ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ac5:	83 c0 08             	add    $0x8,%eax
  100ac8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for(int i=0;i<4;i++){
  100acb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100ad2:	eb 24                	jmp    100af8 <print_stackframe+0x75>
			cprintf("0x%08x ", calling_arguments[i]);
  100ad4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ad7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ade:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100ae1:	01 d0                	add    %edx,%eax
  100ae3:	8b 00                	mov    (%eax),%eax
  100ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ae9:	c7 04 24 50 70 10 00 	movl   $0x107050,(%esp)
  100af0:	e8 9d f7 ff ff       	call   100292 <cprintf>
		for(int i=0;i<4;i++){
  100af5:	ff 45 e8             	incl   -0x18(%ebp)
  100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100afc:	7e d6                	jle    100ad4 <print_stackframe+0x51>
		}
		cprintf("\n");
  100afe:	c7 04 24 58 70 10 00 	movl   $0x107058,(%esp)
  100b05:	e8 88 f7 ff ff       	call   100292 <cprintf>
		print_debuginfo(eip-1);
  100b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b0d:	48                   	dec    %eax
  100b0e:	89 04 24             	mov    %eax,(%esp)
  100b11:	e8 b9 fe ff ff       	call   1009cf <print_debuginfo>
		eip=((uint32_t*)ebp)[1];
  100b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b19:	83 c0 04             	add    $0x4,%eax
  100b1c:	8b 00                	mov    (%eax),%eax
  100b1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp=((uint32_t*)ebp)[0];
  100b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b24:	8b 00                	mov    (%eax),%eax
  100b26:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(int i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++){
  100b29:	ff 45 ec             	incl   -0x14(%ebp)
  100b2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b30:	74 0a                	je     100b3c <print_stackframe+0xb9>
  100b32:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b36:	0f 8e 6c ff ff ff    	jle    100aa8 <print_stackframe+0x25>
	}
}
  100b3c:	90                   	nop
  100b3d:	c9                   	leave  
  100b3e:	c3                   	ret    

00100b3f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b3f:	55                   	push   %ebp
  100b40:	89 e5                	mov    %esp,%ebp
  100b42:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b4c:	eb 0c                	jmp    100b5a <parse+0x1b>
            *buf ++ = '\0';
  100b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b51:	8d 50 01             	lea    0x1(%eax),%edx
  100b54:	89 55 08             	mov    %edx,0x8(%ebp)
  100b57:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b5d:	0f b6 00             	movzbl (%eax),%eax
  100b60:	84 c0                	test   %al,%al
  100b62:	74 1d                	je     100b81 <parse+0x42>
  100b64:	8b 45 08             	mov    0x8(%ebp),%eax
  100b67:	0f b6 00             	movzbl (%eax),%eax
  100b6a:	0f be c0             	movsbl %al,%eax
  100b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b71:	c7 04 24 dc 70 10 00 	movl   $0x1070dc,(%esp)
  100b78:	e8 28 59 00 00       	call   1064a5 <strchr>
  100b7d:	85 c0                	test   %eax,%eax
  100b7f:	75 cd                	jne    100b4e <parse+0xf>
        }
        if (*buf == '\0') {
  100b81:	8b 45 08             	mov    0x8(%ebp),%eax
  100b84:	0f b6 00             	movzbl (%eax),%eax
  100b87:	84 c0                	test   %al,%al
  100b89:	74 65                	je     100bf0 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b8b:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b8f:	75 14                	jne    100ba5 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b91:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100b98:	00 
  100b99:	c7 04 24 e1 70 10 00 	movl   $0x1070e1,(%esp)
  100ba0:	e8 ed f6 ff ff       	call   100292 <cprintf>
        }
        argv[argc ++] = buf;
  100ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ba8:	8d 50 01             	lea    0x1(%eax),%edx
  100bab:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100bae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  100bb8:	01 c2                	add    %eax,%edx
  100bba:	8b 45 08             	mov    0x8(%ebp),%eax
  100bbd:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bbf:	eb 03                	jmp    100bc4 <parse+0x85>
            buf ++;
  100bc1:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  100bc7:	0f b6 00             	movzbl (%eax),%eax
  100bca:	84 c0                	test   %al,%al
  100bcc:	74 8c                	je     100b5a <parse+0x1b>
  100bce:	8b 45 08             	mov    0x8(%ebp),%eax
  100bd1:	0f b6 00             	movzbl (%eax),%eax
  100bd4:	0f be c0             	movsbl %al,%eax
  100bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bdb:	c7 04 24 dc 70 10 00 	movl   $0x1070dc,(%esp)
  100be2:	e8 be 58 00 00       	call   1064a5 <strchr>
  100be7:	85 c0                	test   %eax,%eax
  100be9:	74 d6                	je     100bc1 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100beb:	e9 6a ff ff ff       	jmp    100b5a <parse+0x1b>
            break;
  100bf0:	90                   	nop
        }
    }
    return argc;
  100bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100bf4:	c9                   	leave  
  100bf5:	c3                   	ret    

00100bf6 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100bf6:	55                   	push   %ebp
  100bf7:	89 e5                	mov    %esp,%ebp
  100bf9:	53                   	push   %ebx
  100bfa:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100bfd:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c04:	8b 45 08             	mov    0x8(%ebp),%eax
  100c07:	89 04 24             	mov    %eax,(%esp)
  100c0a:	e8 30 ff ff ff       	call   100b3f <parse>
  100c0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c16:	75 0a                	jne    100c22 <runcmd+0x2c>
        return 0;
  100c18:	b8 00 00 00 00       	mov    $0x0,%eax
  100c1d:	e9 83 00 00 00       	jmp    100ca5 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c29:	eb 5a                	jmp    100c85 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c2b:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c31:	89 d0                	mov    %edx,%eax
  100c33:	01 c0                	add    %eax,%eax
  100c35:	01 d0                	add    %edx,%eax
  100c37:	c1 e0 02             	shl    $0x2,%eax
  100c3a:	05 00 a0 11 00       	add    $0x11a000,%eax
  100c3f:	8b 00                	mov    (%eax),%eax
  100c41:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c45:	89 04 24             	mov    %eax,(%esp)
  100c48:	e8 bb 57 00 00       	call   106408 <strcmp>
  100c4d:	85 c0                	test   %eax,%eax
  100c4f:	75 31                	jne    100c82 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c54:	89 d0                	mov    %edx,%eax
  100c56:	01 c0                	add    %eax,%eax
  100c58:	01 d0                	add    %edx,%eax
  100c5a:	c1 e0 02             	shl    $0x2,%eax
  100c5d:	05 08 a0 11 00       	add    $0x11a008,%eax
  100c62:	8b 10                	mov    (%eax),%edx
  100c64:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c67:	83 c0 04             	add    $0x4,%eax
  100c6a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c6d:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100c73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c77:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c7b:	89 1c 24             	mov    %ebx,(%esp)
  100c7e:	ff d2                	call   *%edx
  100c80:	eb 23                	jmp    100ca5 <runcmd+0xaf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c82:	ff 45 f4             	incl   -0xc(%ebp)
  100c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c88:	83 f8 02             	cmp    $0x2,%eax
  100c8b:	76 9e                	jbe    100c2b <runcmd+0x35>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c8d:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c90:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c94:	c7 04 24 ff 70 10 00 	movl   $0x1070ff,(%esp)
  100c9b:	e8 f2 f5 ff ff       	call   100292 <cprintf>
    return 0;
  100ca0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ca5:	83 c4 64             	add    $0x64,%esp
  100ca8:	5b                   	pop    %ebx
  100ca9:	5d                   	pop    %ebp
  100caa:	c3                   	ret    

00100cab <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100cab:	55                   	push   %ebp
  100cac:	89 e5                	mov    %esp,%ebp
  100cae:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100cb1:	c7 04 24 18 71 10 00 	movl   $0x107118,(%esp)
  100cb8:	e8 d5 f5 ff ff       	call   100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cbd:	c7 04 24 40 71 10 00 	movl   $0x107140,(%esp)
  100cc4:	e8 c9 f5 ff ff       	call   100292 <cprintf>

    if (tf != NULL) {
  100cc9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100ccd:	74 0b                	je     100cda <kmonitor+0x2f>
        print_trapframe(tf);
  100ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  100cd2:	89 04 24             	mov    %eax,(%esp)
  100cd5:	e8 11 0d 00 00       	call   1019eb <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cda:	c7 04 24 65 71 10 00 	movl   $0x107165,(%esp)
  100ce1:	e8 4e f6 ff ff       	call   100334 <readline>
  100ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100ce9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100ced:	74 eb                	je     100cda <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100cef:	8b 45 08             	mov    0x8(%ebp),%eax
  100cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cf9:	89 04 24             	mov    %eax,(%esp)
  100cfc:	e8 f5 fe ff ff       	call   100bf6 <runcmd>
  100d01:	85 c0                	test   %eax,%eax
  100d03:	78 02                	js     100d07 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100d05:	eb d3                	jmp    100cda <kmonitor+0x2f>
                break;
  100d07:	90                   	nop
            }
        }
    }
}
  100d08:	90                   	nop
  100d09:	c9                   	leave  
  100d0a:	c3                   	ret    

00100d0b <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d0b:	55                   	push   %ebp
  100d0c:	89 e5                	mov    %esp,%ebp
  100d0e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d18:	eb 3d                	jmp    100d57 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d1d:	89 d0                	mov    %edx,%eax
  100d1f:	01 c0                	add    %eax,%eax
  100d21:	01 d0                	add    %edx,%eax
  100d23:	c1 e0 02             	shl    $0x2,%eax
  100d26:	05 04 a0 11 00       	add    $0x11a004,%eax
  100d2b:	8b 08                	mov    (%eax),%ecx
  100d2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d30:	89 d0                	mov    %edx,%eax
  100d32:	01 c0                	add    %eax,%eax
  100d34:	01 d0                	add    %edx,%eax
  100d36:	c1 e0 02             	shl    $0x2,%eax
  100d39:	05 00 a0 11 00       	add    $0x11a000,%eax
  100d3e:	8b 00                	mov    (%eax),%eax
  100d40:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d44:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d48:	c7 04 24 69 71 10 00 	movl   $0x107169,(%esp)
  100d4f:	e8 3e f5 ff ff       	call   100292 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100d54:	ff 45 f4             	incl   -0xc(%ebp)
  100d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d5a:	83 f8 02             	cmp    $0x2,%eax
  100d5d:	76 bb                	jbe    100d1a <mon_help+0xf>
    }
    return 0;
  100d5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d64:	c9                   	leave  
  100d65:	c3                   	ret    

00100d66 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d66:	55                   	push   %ebp
  100d67:	89 e5                	mov    %esp,%ebp
  100d69:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d6c:	e8 c7 fb ff ff       	call   100938 <print_kerninfo>
    return 0;
  100d71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d76:	c9                   	leave  
  100d77:	c3                   	ret    

00100d78 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d78:	55                   	push   %ebp
  100d79:	89 e5                	mov    %esp,%ebp
  100d7b:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d7e:	e8 00 fd ff ff       	call   100a83 <print_stackframe>
    return 0;
  100d83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d88:	c9                   	leave  
  100d89:	c3                   	ret    

00100d8a <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d8a:	55                   	push   %ebp
  100d8b:	89 e5                	mov    %esp,%ebp
  100d8d:	83 ec 28             	sub    $0x28,%esp
  100d90:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100d96:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100d9a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100d9e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100da2:	ee                   	out    %al,(%dx)
  100da3:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100da9:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100dad:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100db1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100db5:	ee                   	out    %al,(%dx)
  100db6:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100dbc:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
  100dc0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100dc4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100dc8:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dc9:	c7 05 0c df 11 00 00 	movl   $0x0,0x11df0c
  100dd0:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dd3:	c7 04 24 72 71 10 00 	movl   $0x107172,(%esp)
  100dda:	e8 b3 f4 ff ff       	call   100292 <cprintf>
    pic_enable(IRQ_TIMER);
  100ddf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100de6:	e8 2e 09 00 00       	call   101719 <pic_enable>
}
  100deb:	90                   	nop
  100dec:	c9                   	leave  
  100ded:	c3                   	ret    

00100dee <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100dee:	55                   	push   %ebp
  100def:	89 e5                	mov    %esp,%ebp
  100df1:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100df4:	9c                   	pushf  
  100df5:	58                   	pop    %eax
  100df6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100dfc:	25 00 02 00 00       	and    $0x200,%eax
  100e01:	85 c0                	test   %eax,%eax
  100e03:	74 0c                	je     100e11 <__intr_save+0x23>
        intr_disable();
  100e05:	e8 83 0a 00 00       	call   10188d <intr_disable>
        return 1;
  100e0a:	b8 01 00 00 00       	mov    $0x1,%eax
  100e0f:	eb 05                	jmp    100e16 <__intr_save+0x28>
    }
    return 0;
  100e11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e16:	c9                   	leave  
  100e17:	c3                   	ret    

00100e18 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e18:	55                   	push   %ebp
  100e19:	89 e5                	mov    %esp,%ebp
  100e1b:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e1e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e22:	74 05                	je     100e29 <__intr_restore+0x11>
        intr_enable();
  100e24:	e8 5d 0a 00 00       	call   101886 <intr_enable>
    }
}
  100e29:	90                   	nop
  100e2a:	c9                   	leave  
  100e2b:	c3                   	ret    

00100e2c <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e2c:	55                   	push   %ebp
  100e2d:	89 e5                	mov    %esp,%ebp
  100e2f:	83 ec 10             	sub    $0x10,%esp
  100e32:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e38:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e3c:	89 c2                	mov    %eax,%edx
  100e3e:	ec                   	in     (%dx),%al
  100e3f:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e42:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e48:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e4c:	89 c2                	mov    %eax,%edx
  100e4e:	ec                   	in     (%dx),%al
  100e4f:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e52:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e58:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e5c:	89 c2                	mov    %eax,%edx
  100e5e:	ec                   	in     (%dx),%al
  100e5f:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e62:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e68:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e6c:	89 c2                	mov    %eax,%edx
  100e6e:	ec                   	in     (%dx),%al
  100e6f:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e72:	90                   	nop
  100e73:	c9                   	leave  
  100e74:	c3                   	ret    

00100e75 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e75:	55                   	push   %ebp
  100e76:	89 e5                	mov    %esp,%ebp
  100e78:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e7b:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e82:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e85:	0f b7 00             	movzwl (%eax),%eax
  100e88:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e8f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e97:	0f b7 00             	movzwl (%eax),%eax
  100e9a:	0f b7 c0             	movzwl %ax,%eax
  100e9d:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100ea2:	74 12                	je     100eb6 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ea4:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100eab:	66 c7 05 46 d4 11 00 	movw   $0x3b4,0x11d446
  100eb2:	b4 03 
  100eb4:	eb 13                	jmp    100ec9 <cga_init+0x54>
    } else {
        *cp = was;
  100eb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ebd:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ec0:	66 c7 05 46 d4 11 00 	movw   $0x3d4,0x11d446
  100ec7:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ec9:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  100ed0:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100ed4:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ed8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100edc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100ee0:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ee1:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  100ee8:	40                   	inc    %eax
  100ee9:	0f b7 c0             	movzwl %ax,%eax
  100eec:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ef0:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100ef4:	89 c2                	mov    %eax,%edx
  100ef6:	ec                   	in     (%dx),%al
  100ef7:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100efa:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100efe:	0f b6 c0             	movzbl %al,%eax
  100f01:	c1 e0 08             	shl    $0x8,%eax
  100f04:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f07:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  100f0e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f12:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f16:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f1a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f1e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f1f:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  100f26:	40                   	inc    %eax
  100f27:	0f b7 c0             	movzwl %ax,%eax
  100f2a:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f2e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f32:	89 c2                	mov    %eax,%edx
  100f34:	ec                   	in     (%dx),%al
  100f35:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f38:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f3c:	0f b6 c0             	movzbl %al,%eax
  100f3f:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f42:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f45:	a3 40 d4 11 00       	mov    %eax,0x11d440
    crt_pos = pos;
  100f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f4d:	0f b7 c0             	movzwl %ax,%eax
  100f50:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
}
  100f56:	90                   	nop
  100f57:	c9                   	leave  
  100f58:	c3                   	ret    

00100f59 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f59:	55                   	push   %ebp
  100f5a:	89 e5                	mov    %esp,%ebp
  100f5c:	83 ec 48             	sub    $0x48,%esp
  100f5f:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f65:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f69:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f6d:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100f71:	ee                   	out    %al,(%dx)
  100f72:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100f78:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
  100f7c:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100f80:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100f84:	ee                   	out    %al,(%dx)
  100f85:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100f8b:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
  100f8f:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100f93:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100f97:	ee                   	out    %al,(%dx)
  100f98:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f9e:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100fa2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fa6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100faa:	ee                   	out    %al,(%dx)
  100fab:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100fb1:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
  100fb5:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fb9:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fbd:	ee                   	out    %al,(%dx)
  100fbe:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100fc4:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
  100fc8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fcc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fd0:	ee                   	out    %al,(%dx)
  100fd1:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fd7:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
  100fdb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fdf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fe3:	ee                   	out    %al,(%dx)
  100fe4:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100fea:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100fee:	89 c2                	mov    %eax,%edx
  100ff0:	ec                   	in     (%dx),%al
  100ff1:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100ff4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100ff8:	3c ff                	cmp    $0xff,%al
  100ffa:	0f 95 c0             	setne  %al
  100ffd:	0f b6 c0             	movzbl %al,%eax
  101000:	a3 48 d4 11 00       	mov    %eax,0x11d448
  101005:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10100b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10100f:	89 c2                	mov    %eax,%edx
  101011:	ec                   	in     (%dx),%al
  101012:	88 45 f1             	mov    %al,-0xf(%ebp)
  101015:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10101b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10101f:	89 c2                	mov    %eax,%edx
  101021:	ec                   	in     (%dx),%al
  101022:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101025:	a1 48 d4 11 00       	mov    0x11d448,%eax
  10102a:	85 c0                	test   %eax,%eax
  10102c:	74 0c                	je     10103a <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  10102e:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101035:	e8 df 06 00 00       	call   101719 <pic_enable>
    }
}
  10103a:	90                   	nop
  10103b:	c9                   	leave  
  10103c:	c3                   	ret    

0010103d <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  10103d:	55                   	push   %ebp
  10103e:	89 e5                	mov    %esp,%ebp
  101040:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101043:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10104a:	eb 08                	jmp    101054 <lpt_putc_sub+0x17>
        delay();
  10104c:	e8 db fd ff ff       	call   100e2c <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101051:	ff 45 fc             	incl   -0x4(%ebp)
  101054:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  10105a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10105e:	89 c2                	mov    %eax,%edx
  101060:	ec                   	in     (%dx),%al
  101061:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101064:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101068:	84 c0                	test   %al,%al
  10106a:	78 09                	js     101075 <lpt_putc_sub+0x38>
  10106c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101073:	7e d7                	jle    10104c <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  101075:	8b 45 08             	mov    0x8(%ebp),%eax
  101078:	0f b6 c0             	movzbl %al,%eax
  10107b:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  101081:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101084:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101088:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10108c:	ee                   	out    %al,(%dx)
  10108d:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  101093:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101097:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10109b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10109f:	ee                   	out    %al,(%dx)
  1010a0:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  1010a6:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
  1010aa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010ae:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010b2:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010b3:	90                   	nop
  1010b4:	c9                   	leave  
  1010b5:	c3                   	ret    

001010b6 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010b6:	55                   	push   %ebp
  1010b7:	89 e5                	mov    %esp,%ebp
  1010b9:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010bc:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010c0:	74 0d                	je     1010cf <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1010c5:	89 04 24             	mov    %eax,(%esp)
  1010c8:	e8 70 ff ff ff       	call   10103d <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  1010cd:	eb 24                	jmp    1010f3 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  1010cf:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010d6:	e8 62 ff ff ff       	call   10103d <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010db:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010e2:	e8 56 ff ff ff       	call   10103d <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010e7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010ee:	e8 4a ff ff ff       	call   10103d <lpt_putc_sub>
}
  1010f3:	90                   	nop
  1010f4:	c9                   	leave  
  1010f5:	c3                   	ret    

001010f6 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010f6:	55                   	push   %ebp
  1010f7:	89 e5                	mov    %esp,%ebp
  1010f9:	53                   	push   %ebx
  1010fa:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  101100:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101105:	85 c0                	test   %eax,%eax
  101107:	75 07                	jne    101110 <cga_putc+0x1a>
        c |= 0x0700;
  101109:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101110:	8b 45 08             	mov    0x8(%ebp),%eax
  101113:	0f b6 c0             	movzbl %al,%eax
  101116:	83 f8 0a             	cmp    $0xa,%eax
  101119:	74 55                	je     101170 <cga_putc+0x7a>
  10111b:	83 f8 0d             	cmp    $0xd,%eax
  10111e:	74 63                	je     101183 <cga_putc+0x8d>
  101120:	83 f8 08             	cmp    $0x8,%eax
  101123:	0f 85 94 00 00 00    	jne    1011bd <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
  101129:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  101130:	85 c0                	test   %eax,%eax
  101132:	0f 84 af 00 00 00    	je     1011e7 <cga_putc+0xf1>
            crt_pos --;
  101138:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  10113f:	48                   	dec    %eax
  101140:	0f b7 c0             	movzwl %ax,%eax
  101143:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101149:	8b 45 08             	mov    0x8(%ebp),%eax
  10114c:	98                   	cwtl   
  10114d:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101152:	98                   	cwtl   
  101153:	83 c8 20             	or     $0x20,%eax
  101156:	98                   	cwtl   
  101157:	8b 15 40 d4 11 00    	mov    0x11d440,%edx
  10115d:	0f b7 0d 44 d4 11 00 	movzwl 0x11d444,%ecx
  101164:	01 c9                	add    %ecx,%ecx
  101166:	01 ca                	add    %ecx,%edx
  101168:	0f b7 c0             	movzwl %ax,%eax
  10116b:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  10116e:	eb 77                	jmp    1011e7 <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
  101170:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  101177:	83 c0 50             	add    $0x50,%eax
  10117a:	0f b7 c0             	movzwl %ax,%eax
  10117d:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101183:	0f b7 1d 44 d4 11 00 	movzwl 0x11d444,%ebx
  10118a:	0f b7 0d 44 d4 11 00 	movzwl 0x11d444,%ecx
  101191:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  101196:	89 c8                	mov    %ecx,%eax
  101198:	f7 e2                	mul    %edx
  10119a:	c1 ea 06             	shr    $0x6,%edx
  10119d:	89 d0                	mov    %edx,%eax
  10119f:	c1 e0 02             	shl    $0x2,%eax
  1011a2:	01 d0                	add    %edx,%eax
  1011a4:	c1 e0 04             	shl    $0x4,%eax
  1011a7:	29 c1                	sub    %eax,%ecx
  1011a9:	89 c8                	mov    %ecx,%eax
  1011ab:	0f b7 c0             	movzwl %ax,%eax
  1011ae:	29 c3                	sub    %eax,%ebx
  1011b0:	89 d8                	mov    %ebx,%eax
  1011b2:	0f b7 c0             	movzwl %ax,%eax
  1011b5:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
        break;
  1011bb:	eb 2b                	jmp    1011e8 <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011bd:	8b 0d 40 d4 11 00    	mov    0x11d440,%ecx
  1011c3:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  1011ca:	8d 50 01             	lea    0x1(%eax),%edx
  1011cd:	0f b7 d2             	movzwl %dx,%edx
  1011d0:	66 89 15 44 d4 11 00 	mov    %dx,0x11d444
  1011d7:	01 c0                	add    %eax,%eax
  1011d9:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1011df:	0f b7 c0             	movzwl %ax,%eax
  1011e2:	66 89 02             	mov    %ax,(%edx)
        break;
  1011e5:	eb 01                	jmp    1011e8 <cga_putc+0xf2>
        break;
  1011e7:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011e8:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  1011ef:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  1011f4:	76 5d                	jbe    101253 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011f6:	a1 40 d4 11 00       	mov    0x11d440,%eax
  1011fb:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101201:	a1 40 d4 11 00       	mov    0x11d440,%eax
  101206:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10120d:	00 
  10120e:	89 54 24 04          	mov    %edx,0x4(%esp)
  101212:	89 04 24             	mov    %eax,(%esp)
  101215:	e8 81 54 00 00       	call   10669b <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10121a:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101221:	eb 14                	jmp    101237 <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
  101223:	a1 40 d4 11 00       	mov    0x11d440,%eax
  101228:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10122b:	01 d2                	add    %edx,%edx
  10122d:	01 d0                	add    %edx,%eax
  10122f:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101234:	ff 45 f4             	incl   -0xc(%ebp)
  101237:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10123e:	7e e3                	jle    101223 <cga_putc+0x12d>
        }
        crt_pos -= CRT_COLS;
  101240:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  101247:	83 e8 50             	sub    $0x50,%eax
  10124a:	0f b7 c0             	movzwl %ax,%eax
  10124d:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101253:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  10125a:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  10125e:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
  101262:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101266:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10126a:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  10126b:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  101272:	c1 e8 08             	shr    $0x8,%eax
  101275:	0f b7 c0             	movzwl %ax,%eax
  101278:	0f b6 c0             	movzbl %al,%eax
  10127b:	0f b7 15 46 d4 11 00 	movzwl 0x11d446,%edx
  101282:	42                   	inc    %edx
  101283:	0f b7 d2             	movzwl %dx,%edx
  101286:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  10128a:	88 45 e9             	mov    %al,-0x17(%ebp)
  10128d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101291:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101295:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101296:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  10129d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012a1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
  1012a5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012a9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012ad:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012ae:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  1012b5:	0f b6 c0             	movzbl %al,%eax
  1012b8:	0f b7 15 46 d4 11 00 	movzwl 0x11d446,%edx
  1012bf:	42                   	inc    %edx
  1012c0:	0f b7 d2             	movzwl %dx,%edx
  1012c3:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  1012c7:	88 45 f1             	mov    %al,-0xf(%ebp)
  1012ca:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1012ce:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1012d2:	ee                   	out    %al,(%dx)
}
  1012d3:	90                   	nop
  1012d4:	83 c4 34             	add    $0x34,%esp
  1012d7:	5b                   	pop    %ebx
  1012d8:	5d                   	pop    %ebp
  1012d9:	c3                   	ret    

001012da <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012da:	55                   	push   %ebp
  1012db:	89 e5                	mov    %esp,%ebp
  1012dd:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012e7:	eb 08                	jmp    1012f1 <serial_putc_sub+0x17>
        delay();
  1012e9:	e8 3e fb ff ff       	call   100e2c <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012ee:	ff 45 fc             	incl   -0x4(%ebp)
  1012f1:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1012f7:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012fb:	89 c2                	mov    %eax,%edx
  1012fd:	ec                   	in     (%dx),%al
  1012fe:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101301:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101305:	0f b6 c0             	movzbl %al,%eax
  101308:	83 e0 20             	and    $0x20,%eax
  10130b:	85 c0                	test   %eax,%eax
  10130d:	75 09                	jne    101318 <serial_putc_sub+0x3e>
  10130f:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101316:	7e d1                	jle    1012e9 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  101318:	8b 45 08             	mov    0x8(%ebp),%eax
  10131b:	0f b6 c0             	movzbl %al,%eax
  10131e:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101324:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101327:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10132b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10132f:	ee                   	out    %al,(%dx)
}
  101330:	90                   	nop
  101331:	c9                   	leave  
  101332:	c3                   	ret    

00101333 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101333:	55                   	push   %ebp
  101334:	89 e5                	mov    %esp,%ebp
  101336:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101339:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10133d:	74 0d                	je     10134c <serial_putc+0x19>
        serial_putc_sub(c);
  10133f:	8b 45 08             	mov    0x8(%ebp),%eax
  101342:	89 04 24             	mov    %eax,(%esp)
  101345:	e8 90 ff ff ff       	call   1012da <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  10134a:	eb 24                	jmp    101370 <serial_putc+0x3d>
        serial_putc_sub('\b');
  10134c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101353:	e8 82 ff ff ff       	call   1012da <serial_putc_sub>
        serial_putc_sub(' ');
  101358:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10135f:	e8 76 ff ff ff       	call   1012da <serial_putc_sub>
        serial_putc_sub('\b');
  101364:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10136b:	e8 6a ff ff ff       	call   1012da <serial_putc_sub>
}
  101370:	90                   	nop
  101371:	c9                   	leave  
  101372:	c3                   	ret    

00101373 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101373:	55                   	push   %ebp
  101374:	89 e5                	mov    %esp,%ebp
  101376:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101379:	eb 33                	jmp    1013ae <cons_intr+0x3b>
        if (c != 0) {
  10137b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10137f:	74 2d                	je     1013ae <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101381:	a1 64 d6 11 00       	mov    0x11d664,%eax
  101386:	8d 50 01             	lea    0x1(%eax),%edx
  101389:	89 15 64 d6 11 00    	mov    %edx,0x11d664
  10138f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101392:	88 90 60 d4 11 00    	mov    %dl,0x11d460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101398:	a1 64 d6 11 00       	mov    0x11d664,%eax
  10139d:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013a2:	75 0a                	jne    1013ae <cons_intr+0x3b>
                cons.wpos = 0;
  1013a4:	c7 05 64 d6 11 00 00 	movl   $0x0,0x11d664
  1013ab:	00 00 00 
    while ((c = (*proc)()) != -1) {
  1013ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1013b1:	ff d0                	call   *%eax
  1013b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013b6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013ba:	75 bf                	jne    10137b <cons_intr+0x8>
            }
        }
    }
}
  1013bc:	90                   	nop
  1013bd:	c9                   	leave  
  1013be:	c3                   	ret    

001013bf <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013bf:	55                   	push   %ebp
  1013c0:	89 e5                	mov    %esp,%ebp
  1013c2:	83 ec 10             	sub    $0x10,%esp
  1013c5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013cb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013cf:	89 c2                	mov    %eax,%edx
  1013d1:	ec                   	in     (%dx),%al
  1013d2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013d5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013d9:	0f b6 c0             	movzbl %al,%eax
  1013dc:	83 e0 01             	and    $0x1,%eax
  1013df:	85 c0                	test   %eax,%eax
  1013e1:	75 07                	jne    1013ea <serial_proc_data+0x2b>
        return -1;
  1013e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013e8:	eb 2a                	jmp    101414 <serial_proc_data+0x55>
  1013ea:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013f0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1013f4:	89 c2                	mov    %eax,%edx
  1013f6:	ec                   	in     (%dx),%al
  1013f7:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  1013fa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013fe:	0f b6 c0             	movzbl %al,%eax
  101401:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101404:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101408:	75 07                	jne    101411 <serial_proc_data+0x52>
        c = '\b';
  10140a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101414:	c9                   	leave  
  101415:	c3                   	ret    

00101416 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101416:	55                   	push   %ebp
  101417:	89 e5                	mov    %esp,%ebp
  101419:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10141c:	a1 48 d4 11 00       	mov    0x11d448,%eax
  101421:	85 c0                	test   %eax,%eax
  101423:	74 0c                	je     101431 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101425:	c7 04 24 bf 13 10 00 	movl   $0x1013bf,(%esp)
  10142c:	e8 42 ff ff ff       	call   101373 <cons_intr>
    }
}
  101431:	90                   	nop
  101432:	c9                   	leave  
  101433:	c3                   	ret    

00101434 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101434:	55                   	push   %ebp
  101435:	89 e5                	mov    %esp,%ebp
  101437:	83 ec 38             	sub    $0x38,%esp
  10143a:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101440:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101443:	89 c2                	mov    %eax,%edx
  101445:	ec                   	in     (%dx),%al
  101446:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101449:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  10144d:	0f b6 c0             	movzbl %al,%eax
  101450:	83 e0 01             	and    $0x1,%eax
  101453:	85 c0                	test   %eax,%eax
  101455:	75 0a                	jne    101461 <kbd_proc_data+0x2d>
        return -1;
  101457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10145c:	e9 55 01 00 00       	jmp    1015b6 <kbd_proc_data+0x182>
  101461:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101467:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10146a:	89 c2                	mov    %eax,%edx
  10146c:	ec                   	in     (%dx),%al
  10146d:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101470:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101474:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101477:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10147b:	75 17                	jne    101494 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  10147d:	a1 68 d6 11 00       	mov    0x11d668,%eax
  101482:	83 c8 40             	or     $0x40,%eax
  101485:	a3 68 d6 11 00       	mov    %eax,0x11d668
        return 0;
  10148a:	b8 00 00 00 00       	mov    $0x0,%eax
  10148f:	e9 22 01 00 00       	jmp    1015b6 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
  101494:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101498:	84 c0                	test   %al,%al
  10149a:	79 45                	jns    1014e1 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10149c:	a1 68 d6 11 00       	mov    0x11d668,%eax
  1014a1:	83 e0 40             	and    $0x40,%eax
  1014a4:	85 c0                	test   %eax,%eax
  1014a6:	75 08                	jne    1014b0 <kbd_proc_data+0x7c>
  1014a8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ac:	24 7f                	and    $0x7f,%al
  1014ae:	eb 04                	jmp    1014b4 <kbd_proc_data+0x80>
  1014b0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b4:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014b7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014bb:	0f b6 80 40 a0 11 00 	movzbl 0x11a040(%eax),%eax
  1014c2:	0c 40                	or     $0x40,%al
  1014c4:	0f b6 c0             	movzbl %al,%eax
  1014c7:	f7 d0                	not    %eax
  1014c9:	89 c2                	mov    %eax,%edx
  1014cb:	a1 68 d6 11 00       	mov    0x11d668,%eax
  1014d0:	21 d0                	and    %edx,%eax
  1014d2:	a3 68 d6 11 00       	mov    %eax,0x11d668
        return 0;
  1014d7:	b8 00 00 00 00       	mov    $0x0,%eax
  1014dc:	e9 d5 00 00 00       	jmp    1015b6 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
  1014e1:	a1 68 d6 11 00       	mov    0x11d668,%eax
  1014e6:	83 e0 40             	and    $0x40,%eax
  1014e9:	85 c0                	test   %eax,%eax
  1014eb:	74 11                	je     1014fe <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014ed:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014f1:	a1 68 d6 11 00       	mov    0x11d668,%eax
  1014f6:	83 e0 bf             	and    $0xffffffbf,%eax
  1014f9:	a3 68 d6 11 00       	mov    %eax,0x11d668
    }

    shift |= shiftcode[data];
  1014fe:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101502:	0f b6 80 40 a0 11 00 	movzbl 0x11a040(%eax),%eax
  101509:	0f b6 d0             	movzbl %al,%edx
  10150c:	a1 68 d6 11 00       	mov    0x11d668,%eax
  101511:	09 d0                	or     %edx,%eax
  101513:	a3 68 d6 11 00       	mov    %eax,0x11d668
    shift ^= togglecode[data];
  101518:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151c:	0f b6 80 40 a1 11 00 	movzbl 0x11a140(%eax),%eax
  101523:	0f b6 d0             	movzbl %al,%edx
  101526:	a1 68 d6 11 00       	mov    0x11d668,%eax
  10152b:	31 d0                	xor    %edx,%eax
  10152d:	a3 68 d6 11 00       	mov    %eax,0x11d668

    c = charcode[shift & (CTL | SHIFT)][data];
  101532:	a1 68 d6 11 00       	mov    0x11d668,%eax
  101537:	83 e0 03             	and    $0x3,%eax
  10153a:	8b 14 85 40 a5 11 00 	mov    0x11a540(,%eax,4),%edx
  101541:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101545:	01 d0                	add    %edx,%eax
  101547:	0f b6 00             	movzbl (%eax),%eax
  10154a:	0f b6 c0             	movzbl %al,%eax
  10154d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101550:	a1 68 d6 11 00       	mov    0x11d668,%eax
  101555:	83 e0 08             	and    $0x8,%eax
  101558:	85 c0                	test   %eax,%eax
  10155a:	74 22                	je     10157e <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  10155c:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101560:	7e 0c                	jle    10156e <kbd_proc_data+0x13a>
  101562:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101566:	7f 06                	jg     10156e <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  101568:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10156c:	eb 10                	jmp    10157e <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  10156e:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101572:	7e 0a                	jle    10157e <kbd_proc_data+0x14a>
  101574:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101578:	7f 04                	jg     10157e <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  10157a:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10157e:	a1 68 d6 11 00       	mov    0x11d668,%eax
  101583:	f7 d0                	not    %eax
  101585:	83 e0 06             	and    $0x6,%eax
  101588:	85 c0                	test   %eax,%eax
  10158a:	75 27                	jne    1015b3 <kbd_proc_data+0x17f>
  10158c:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101593:	75 1e                	jne    1015b3 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
  101595:	c7 04 24 8d 71 10 00 	movl   $0x10718d,(%esp)
  10159c:	e8 f1 ec ff ff       	call   100292 <cprintf>
  1015a1:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015a7:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015ab:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015af:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1015b2:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015b6:	c9                   	leave  
  1015b7:	c3                   	ret    

001015b8 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015b8:	55                   	push   %ebp
  1015b9:	89 e5                	mov    %esp,%ebp
  1015bb:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015be:	c7 04 24 34 14 10 00 	movl   $0x101434,(%esp)
  1015c5:	e8 a9 fd ff ff       	call   101373 <cons_intr>
}
  1015ca:	90                   	nop
  1015cb:	c9                   	leave  
  1015cc:	c3                   	ret    

001015cd <kbd_init>:

static void
kbd_init(void) {
  1015cd:	55                   	push   %ebp
  1015ce:	89 e5                	mov    %esp,%ebp
  1015d0:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015d3:	e8 e0 ff ff ff       	call   1015b8 <kbd_intr>
    pic_enable(IRQ_KBD);
  1015d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015df:	e8 35 01 00 00       	call   101719 <pic_enable>
}
  1015e4:	90                   	nop
  1015e5:	c9                   	leave  
  1015e6:	c3                   	ret    

001015e7 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015e7:	55                   	push   %ebp
  1015e8:	89 e5                	mov    %esp,%ebp
  1015ea:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015ed:	e8 83 f8 ff ff       	call   100e75 <cga_init>
    serial_init();
  1015f2:	e8 62 f9 ff ff       	call   100f59 <serial_init>
    kbd_init();
  1015f7:	e8 d1 ff ff ff       	call   1015cd <kbd_init>
    if (!serial_exists) {
  1015fc:	a1 48 d4 11 00       	mov    0x11d448,%eax
  101601:	85 c0                	test   %eax,%eax
  101603:	75 0c                	jne    101611 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101605:	c7 04 24 99 71 10 00 	movl   $0x107199,(%esp)
  10160c:	e8 81 ec ff ff       	call   100292 <cprintf>
    }
}
  101611:	90                   	nop
  101612:	c9                   	leave  
  101613:	c3                   	ret    

00101614 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101614:	55                   	push   %ebp
  101615:	89 e5                	mov    %esp,%ebp
  101617:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10161a:	e8 cf f7 ff ff       	call   100dee <__intr_save>
  10161f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101622:	8b 45 08             	mov    0x8(%ebp),%eax
  101625:	89 04 24             	mov    %eax,(%esp)
  101628:	e8 89 fa ff ff       	call   1010b6 <lpt_putc>
        cga_putc(c);
  10162d:	8b 45 08             	mov    0x8(%ebp),%eax
  101630:	89 04 24             	mov    %eax,(%esp)
  101633:	e8 be fa ff ff       	call   1010f6 <cga_putc>
        serial_putc(c);
  101638:	8b 45 08             	mov    0x8(%ebp),%eax
  10163b:	89 04 24             	mov    %eax,(%esp)
  10163e:	e8 f0 fc ff ff       	call   101333 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101643:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101646:	89 04 24             	mov    %eax,(%esp)
  101649:	e8 ca f7 ff ff       	call   100e18 <__intr_restore>
}
  10164e:	90                   	nop
  10164f:	c9                   	leave  
  101650:	c3                   	ret    

00101651 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101651:	55                   	push   %ebp
  101652:	89 e5                	mov    %esp,%ebp
  101654:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  10165e:	e8 8b f7 ff ff       	call   100dee <__intr_save>
  101663:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101666:	e8 ab fd ff ff       	call   101416 <serial_intr>
        kbd_intr();
  10166b:	e8 48 ff ff ff       	call   1015b8 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  101670:	8b 15 60 d6 11 00    	mov    0x11d660,%edx
  101676:	a1 64 d6 11 00       	mov    0x11d664,%eax
  10167b:	39 c2                	cmp    %eax,%edx
  10167d:	74 31                	je     1016b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10167f:	a1 60 d6 11 00       	mov    0x11d660,%eax
  101684:	8d 50 01             	lea    0x1(%eax),%edx
  101687:	89 15 60 d6 11 00    	mov    %edx,0x11d660
  10168d:	0f b6 80 60 d4 11 00 	movzbl 0x11d460(%eax),%eax
  101694:	0f b6 c0             	movzbl %al,%eax
  101697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  10169a:	a1 60 d6 11 00       	mov    0x11d660,%eax
  10169f:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016a4:	75 0a                	jne    1016b0 <cons_getc+0x5f>
                cons.rpos = 0;
  1016a6:	c7 05 60 d6 11 00 00 	movl   $0x0,0x11d660
  1016ad:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016b3:	89 04 24             	mov    %eax,(%esp)
  1016b6:	e8 5d f7 ff ff       	call   100e18 <__intr_restore>
    return c;
  1016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016be:	c9                   	leave  
  1016bf:	c3                   	ret    

001016c0 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016c0:	55                   	push   %ebp
  1016c1:	89 e5                	mov    %esp,%ebp
  1016c3:	83 ec 14             	sub    $0x14,%esp
  1016c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1016c9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016d0:	66 a3 50 a5 11 00    	mov    %ax,0x11a550
    if (did_init) {
  1016d6:	a1 6c d6 11 00       	mov    0x11d66c,%eax
  1016db:	85 c0                	test   %eax,%eax
  1016dd:	74 37                	je     101716 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  1016df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016e2:	0f b6 c0             	movzbl %al,%eax
  1016e5:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  1016eb:	88 45 f9             	mov    %al,-0x7(%ebp)
  1016ee:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1016f2:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1016f6:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  1016f7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016fb:	c1 e8 08             	shr    $0x8,%eax
  1016fe:	0f b7 c0             	movzwl %ax,%eax
  101701:	0f b6 c0             	movzbl %al,%eax
  101704:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  10170a:	88 45 fd             	mov    %al,-0x3(%ebp)
  10170d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101711:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101715:	ee                   	out    %al,(%dx)
    }
}
  101716:	90                   	nop
  101717:	c9                   	leave  
  101718:	c3                   	ret    

00101719 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101719:	55                   	push   %ebp
  10171a:	89 e5                	mov    %esp,%ebp
  10171c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10171f:	8b 45 08             	mov    0x8(%ebp),%eax
  101722:	ba 01 00 00 00       	mov    $0x1,%edx
  101727:	88 c1                	mov    %al,%cl
  101729:	d3 e2                	shl    %cl,%edx
  10172b:	89 d0                	mov    %edx,%eax
  10172d:	98                   	cwtl   
  10172e:	f7 d0                	not    %eax
  101730:	0f bf d0             	movswl %ax,%edx
  101733:	0f b7 05 50 a5 11 00 	movzwl 0x11a550,%eax
  10173a:	98                   	cwtl   
  10173b:	21 d0                	and    %edx,%eax
  10173d:	98                   	cwtl   
  10173e:	0f b7 c0             	movzwl %ax,%eax
  101741:	89 04 24             	mov    %eax,(%esp)
  101744:	e8 77 ff ff ff       	call   1016c0 <pic_setmask>
}
  101749:	90                   	nop
  10174a:	c9                   	leave  
  10174b:	c3                   	ret    

0010174c <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  10174c:	55                   	push   %ebp
  10174d:	89 e5                	mov    %esp,%ebp
  10174f:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101752:	c7 05 6c d6 11 00 01 	movl   $0x1,0x11d66c
  101759:	00 00 00 
  10175c:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  101762:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
  101766:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  10176a:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  10176e:	ee                   	out    %al,(%dx)
  10176f:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  101775:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
  101779:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  10177d:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101781:	ee                   	out    %al,(%dx)
  101782:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101788:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
  10178c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101790:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101794:	ee                   	out    %al,(%dx)
  101795:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  10179b:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
  10179f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  1017a3:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  1017a7:	ee                   	out    %al,(%dx)
  1017a8:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  1017ae:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
  1017b2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  1017b6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  1017ba:	ee                   	out    %al,(%dx)
  1017bb:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  1017c1:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
  1017c5:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1017c9:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  1017cd:	ee                   	out    %al,(%dx)
  1017ce:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  1017d4:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
  1017d8:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017dc:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1017e0:	ee                   	out    %al,(%dx)
  1017e1:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  1017e7:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
  1017eb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017ef:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017f3:	ee                   	out    %al,(%dx)
  1017f4:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  1017fa:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
  1017fe:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101802:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101806:	ee                   	out    %al,(%dx)
  101807:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  10180d:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
  101811:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101815:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101819:	ee                   	out    %al,(%dx)
  10181a:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101820:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
  101824:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101828:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10182c:	ee                   	out    %al,(%dx)
  10182d:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  101833:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
  101837:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10183b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10183f:	ee                   	out    %al,(%dx)
  101840:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  101846:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
  10184a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10184e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101852:	ee                   	out    %al,(%dx)
  101853:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  101859:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
  10185d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101861:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101865:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101866:	0f b7 05 50 a5 11 00 	movzwl 0x11a550,%eax
  10186d:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101872:	74 0f                	je     101883 <pic_init+0x137>
        pic_setmask(irq_mask);
  101874:	0f b7 05 50 a5 11 00 	movzwl 0x11a550,%eax
  10187b:	89 04 24             	mov    %eax,(%esp)
  10187e:	e8 3d fe ff ff       	call   1016c0 <pic_setmask>
    }
}
  101883:	90                   	nop
  101884:	c9                   	leave  
  101885:	c3                   	ret    

00101886 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101886:	55                   	push   %ebp
  101887:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  101889:	fb                   	sti    
    sti();
}
  10188a:	90                   	nop
  10188b:	5d                   	pop    %ebp
  10188c:	c3                   	ret    

0010188d <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  10188d:	55                   	push   %ebp
  10188e:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  101890:	fa                   	cli    
    cli();
}
  101891:	90                   	nop
  101892:	5d                   	pop    %ebp
  101893:	c3                   	ret    

00101894 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  101894:	55                   	push   %ebp
  101895:	89 e5                	mov    %esp,%ebp
  101897:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  10189a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1018a1:	00 
  1018a2:	c7 04 24 c0 71 10 00 	movl   $0x1071c0,(%esp)
  1018a9:	e8 e4 e9 ff ff       	call   100292 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1018ae:	90                   	nop
  1018af:	c9                   	leave  
  1018b0:	c3                   	ret    

001018b1 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018b1:	55                   	push   %ebp
  1018b2:	89 e5                	mov    %esp,%ebp
  1018b4:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  1018b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018be:	e9 c4 00 00 00       	jmp    101987 <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018c6:	8b 04 85 e0 a5 11 00 	mov    0x11a5e0(,%eax,4),%eax
  1018cd:	0f b7 d0             	movzwl %ax,%edx
  1018d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d3:	66 89 14 c5 80 d6 11 	mov    %dx,0x11d680(,%eax,8)
  1018da:	00 
  1018db:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018de:	66 c7 04 c5 82 d6 11 	movw   $0x8,0x11d682(,%eax,8)
  1018e5:	00 08 00 
  1018e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018eb:	0f b6 14 c5 84 d6 11 	movzbl 0x11d684(,%eax,8),%edx
  1018f2:	00 
  1018f3:	80 e2 e0             	and    $0xe0,%dl
  1018f6:	88 14 c5 84 d6 11 00 	mov    %dl,0x11d684(,%eax,8)
  1018fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101900:	0f b6 14 c5 84 d6 11 	movzbl 0x11d684(,%eax,8),%edx
  101907:	00 
  101908:	80 e2 1f             	and    $0x1f,%dl
  10190b:	88 14 c5 84 d6 11 00 	mov    %dl,0x11d684(,%eax,8)
  101912:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101915:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  10191c:	00 
  10191d:	80 e2 f0             	and    $0xf0,%dl
  101920:	80 ca 0e             	or     $0xe,%dl
  101923:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  10192a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10192d:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  101934:	00 
  101935:	80 e2 ef             	and    $0xef,%dl
  101938:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  10193f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101942:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  101949:	00 
  10194a:	80 e2 9f             	and    $0x9f,%dl
  10194d:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  101954:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101957:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  10195e:	00 
  10195f:	80 ca 80             	or     $0x80,%dl
  101962:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  101969:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10196c:	8b 04 85 e0 a5 11 00 	mov    0x11a5e0(,%eax,4),%eax
  101973:	c1 e8 10             	shr    $0x10,%eax
  101976:	0f b7 d0             	movzwl %ax,%edx
  101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197c:	66 89 14 c5 86 d6 11 	mov    %dx,0x11d686(,%eax,8)
  101983:	00 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  101984:	ff 45 fc             	incl   -0x4(%ebp)
  101987:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10198a:	3d ff 00 00 00       	cmp    $0xff,%eax
  10198f:	0f 86 2e ff ff ff    	jbe    1018c3 <idt_init+0x12>
  101995:	c7 45 f8 60 a5 11 00 	movl   $0x11a560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  10199c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10199f:	0f 01 18             	lidtl  (%eax)
    }
    lidt(&idt_pd);
}
  1019a2:	90                   	nop
  1019a3:	c9                   	leave  
  1019a4:	c3                   	ret    

001019a5 <trapname>:

static const char *
trapname(int trapno) {
  1019a5:	55                   	push   %ebp
  1019a6:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  1019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1019ab:	83 f8 13             	cmp    $0x13,%eax
  1019ae:	77 0c                	ja     1019bc <trapname+0x17>
        return excnames[trapno];
  1019b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1019b3:	8b 04 85 20 75 10 00 	mov    0x107520(,%eax,4),%eax
  1019ba:	eb 18                	jmp    1019d4 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  1019bc:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019c0:	7e 0d                	jle    1019cf <trapname+0x2a>
  1019c2:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019c6:	7f 07                	jg     1019cf <trapname+0x2a>
        return "Hardware Interrupt";
  1019c8:	b8 ca 71 10 00       	mov    $0x1071ca,%eax
  1019cd:	eb 05                	jmp    1019d4 <trapname+0x2f>
    }
    return "(unknown trap)";
  1019cf:	b8 dd 71 10 00       	mov    $0x1071dd,%eax
}
  1019d4:	5d                   	pop    %ebp
  1019d5:	c3                   	ret    

001019d6 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019d6:	55                   	push   %ebp
  1019d7:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1019dc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019e0:	83 f8 08             	cmp    $0x8,%eax
  1019e3:	0f 94 c0             	sete   %al
  1019e6:	0f b6 c0             	movzbl %al,%eax
}
  1019e9:	5d                   	pop    %ebp
  1019ea:	c3                   	ret    

001019eb <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  1019eb:	55                   	push   %ebp
  1019ec:	89 e5                	mov    %esp,%ebp
  1019ee:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  1019f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1019f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019f8:	c7 04 24 1e 72 10 00 	movl   $0x10721e,(%esp)
  1019ff:	e8 8e e8 ff ff       	call   100292 <cprintf>
    print_regs(&tf->tf_regs);
  101a04:	8b 45 08             	mov    0x8(%ebp),%eax
  101a07:	89 04 24             	mov    %eax,(%esp)
  101a0a:	e8 8f 01 00 00       	call   101b9e <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  101a12:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a16:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a1a:	c7 04 24 2f 72 10 00 	movl   $0x10722f,(%esp)
  101a21:	e8 6c e8 ff ff       	call   100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a26:	8b 45 08             	mov    0x8(%ebp),%eax
  101a29:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a31:	c7 04 24 42 72 10 00 	movl   $0x107242,(%esp)
  101a38:	e8 55 e8 ff ff       	call   100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a40:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a48:	c7 04 24 55 72 10 00 	movl   $0x107255,(%esp)
  101a4f:	e8 3e e8 ff ff       	call   100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a54:	8b 45 08             	mov    0x8(%ebp),%eax
  101a57:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a5f:	c7 04 24 68 72 10 00 	movl   $0x107268,(%esp)
  101a66:	e8 27 e8 ff ff       	call   100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a6e:	8b 40 30             	mov    0x30(%eax),%eax
  101a71:	89 04 24             	mov    %eax,(%esp)
  101a74:	e8 2c ff ff ff       	call   1019a5 <trapname>
  101a79:	89 c2                	mov    %eax,%edx
  101a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7e:	8b 40 30             	mov    0x30(%eax),%eax
  101a81:	89 54 24 08          	mov    %edx,0x8(%esp)
  101a85:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a89:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  101a90:	e8 fd e7 ff ff       	call   100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101a95:	8b 45 08             	mov    0x8(%ebp),%eax
  101a98:	8b 40 34             	mov    0x34(%eax),%eax
  101a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a9f:	c7 04 24 8d 72 10 00 	movl   $0x10728d,(%esp)
  101aa6:	e8 e7 e7 ff ff       	call   100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101aab:	8b 45 08             	mov    0x8(%ebp),%eax
  101aae:	8b 40 38             	mov    0x38(%eax),%eax
  101ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ab5:	c7 04 24 9c 72 10 00 	movl   $0x10729c,(%esp)
  101abc:	e8 d1 e7 ff ff       	call   100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101acc:	c7 04 24 ab 72 10 00 	movl   $0x1072ab,(%esp)
  101ad3:	e8 ba e7 ff ff       	call   100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  101adb:	8b 40 40             	mov    0x40(%eax),%eax
  101ade:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ae2:	c7 04 24 be 72 10 00 	movl   $0x1072be,(%esp)
  101ae9:	e8 a4 e7 ff ff       	call   100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101aee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101af5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101afc:	eb 3d                	jmp    101b3b <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101afe:	8b 45 08             	mov    0x8(%ebp),%eax
  101b01:	8b 50 40             	mov    0x40(%eax),%edx
  101b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b07:	21 d0                	and    %edx,%eax
  101b09:	85 c0                	test   %eax,%eax
  101b0b:	74 28                	je     101b35 <print_trapframe+0x14a>
  101b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b10:	8b 04 85 80 a5 11 00 	mov    0x11a580(,%eax,4),%eax
  101b17:	85 c0                	test   %eax,%eax
  101b19:	74 1a                	je     101b35 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b1e:	8b 04 85 80 a5 11 00 	mov    0x11a580(,%eax,4),%eax
  101b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b29:	c7 04 24 cd 72 10 00 	movl   $0x1072cd,(%esp)
  101b30:	e8 5d e7 ff ff       	call   100292 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b35:	ff 45 f4             	incl   -0xc(%ebp)
  101b38:	d1 65 f0             	shll   -0x10(%ebp)
  101b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b3e:	83 f8 17             	cmp    $0x17,%eax
  101b41:	76 bb                	jbe    101afe <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b43:	8b 45 08             	mov    0x8(%ebp),%eax
  101b46:	8b 40 40             	mov    0x40(%eax),%eax
  101b49:	c1 e8 0c             	shr    $0xc,%eax
  101b4c:	83 e0 03             	and    $0x3,%eax
  101b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b53:	c7 04 24 d1 72 10 00 	movl   $0x1072d1,(%esp)
  101b5a:	e8 33 e7 ff ff       	call   100292 <cprintf>

    if (!trap_in_kernel(tf)) {
  101b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  101b62:	89 04 24             	mov    %eax,(%esp)
  101b65:	e8 6c fe ff ff       	call   1019d6 <trap_in_kernel>
  101b6a:	85 c0                	test   %eax,%eax
  101b6c:	75 2d                	jne    101b9b <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b71:	8b 40 44             	mov    0x44(%eax),%eax
  101b74:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b78:	c7 04 24 da 72 10 00 	movl   $0x1072da,(%esp)
  101b7f:	e8 0e e7 ff ff       	call   100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101b84:	8b 45 08             	mov    0x8(%ebp),%eax
  101b87:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b8f:	c7 04 24 e9 72 10 00 	movl   $0x1072e9,(%esp)
  101b96:	e8 f7 e6 ff ff       	call   100292 <cprintf>
    }
}
  101b9b:	90                   	nop
  101b9c:	c9                   	leave  
  101b9d:	c3                   	ret    

00101b9e <print_regs>:

void
print_regs(struct pushregs *regs) {
  101b9e:	55                   	push   %ebp
  101b9f:	89 e5                	mov    %esp,%ebp
  101ba1:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba7:	8b 00                	mov    (%eax),%eax
  101ba9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bad:	c7 04 24 fc 72 10 00 	movl   $0x1072fc,(%esp)
  101bb4:	e8 d9 e6 ff ff       	call   100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  101bbc:	8b 40 04             	mov    0x4(%eax),%eax
  101bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bc3:	c7 04 24 0b 73 10 00 	movl   $0x10730b,(%esp)
  101bca:	e8 c3 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd2:	8b 40 08             	mov    0x8(%eax),%eax
  101bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd9:	c7 04 24 1a 73 10 00 	movl   $0x10731a,(%esp)
  101be0:	e8 ad e6 ff ff       	call   100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101be5:	8b 45 08             	mov    0x8(%ebp),%eax
  101be8:	8b 40 0c             	mov    0xc(%eax),%eax
  101beb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bef:	c7 04 24 29 73 10 00 	movl   $0x107329,(%esp)
  101bf6:	e8 97 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  101bfe:	8b 40 10             	mov    0x10(%eax),%eax
  101c01:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c05:	c7 04 24 38 73 10 00 	movl   $0x107338,(%esp)
  101c0c:	e8 81 e6 ff ff       	call   100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c11:	8b 45 08             	mov    0x8(%ebp),%eax
  101c14:	8b 40 14             	mov    0x14(%eax),%eax
  101c17:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c1b:	c7 04 24 47 73 10 00 	movl   $0x107347,(%esp)
  101c22:	e8 6b e6 ff ff       	call   100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c27:	8b 45 08             	mov    0x8(%ebp),%eax
  101c2a:	8b 40 18             	mov    0x18(%eax),%eax
  101c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c31:	c7 04 24 56 73 10 00 	movl   $0x107356,(%esp)
  101c38:	e8 55 e6 ff ff       	call   100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  101c40:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c43:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c47:	c7 04 24 65 73 10 00 	movl   $0x107365,(%esp)
  101c4e:	e8 3f e6 ff ff       	call   100292 <cprintf>
}
  101c53:	90                   	nop
  101c54:	c9                   	leave  
  101c55:	c3                   	ret    

00101c56 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c56:	55                   	push   %ebp
  101c57:	89 e5                	mov    %esp,%ebp
  101c59:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5f:	8b 40 30             	mov    0x30(%eax),%eax
  101c62:	83 f8 2f             	cmp    $0x2f,%eax
  101c65:	77 21                	ja     101c88 <trap_dispatch+0x32>
  101c67:	83 f8 2e             	cmp    $0x2e,%eax
  101c6a:	0f 83 0c 01 00 00    	jae    101d7c <trap_dispatch+0x126>
  101c70:	83 f8 21             	cmp    $0x21,%eax
  101c73:	0f 84 8c 00 00 00    	je     101d05 <trap_dispatch+0xaf>
  101c79:	83 f8 24             	cmp    $0x24,%eax
  101c7c:	74 61                	je     101cdf <trap_dispatch+0x89>
  101c7e:	83 f8 20             	cmp    $0x20,%eax
  101c81:	74 16                	je     101c99 <trap_dispatch+0x43>
  101c83:	e9 bf 00 00 00       	jmp    101d47 <trap_dispatch+0xf1>
  101c88:	83 e8 78             	sub    $0x78,%eax
  101c8b:	83 f8 01             	cmp    $0x1,%eax
  101c8e:	0f 87 b3 00 00 00    	ja     101d47 <trap_dispatch+0xf1>
  101c94:	e9 92 00 00 00       	jmp    101d2b <trap_dispatch+0xd5>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101c99:	a1 0c df 11 00       	mov    0x11df0c,%eax
  101c9e:	40                   	inc    %eax
  101c9f:	a3 0c df 11 00       	mov    %eax,0x11df0c
        if (ticks % TICK_NUM == 0) {
  101ca4:	8b 0d 0c df 11 00    	mov    0x11df0c,%ecx
  101caa:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101caf:	89 c8                	mov    %ecx,%eax
  101cb1:	f7 e2                	mul    %edx
  101cb3:	c1 ea 05             	shr    $0x5,%edx
  101cb6:	89 d0                	mov    %edx,%eax
  101cb8:	c1 e0 02             	shl    $0x2,%eax
  101cbb:	01 d0                	add    %edx,%eax
  101cbd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101cc4:	01 d0                	add    %edx,%eax
  101cc6:	c1 e0 02             	shl    $0x2,%eax
  101cc9:	29 c1                	sub    %eax,%ecx
  101ccb:	89 ca                	mov    %ecx,%edx
  101ccd:	85 d2                	test   %edx,%edx
  101ccf:	0f 85 aa 00 00 00    	jne    101d7f <trap_dispatch+0x129>
            print_ticks();
  101cd5:	e8 ba fb ff ff       	call   101894 <print_ticks>
        }
        break;
  101cda:	e9 a0 00 00 00       	jmp    101d7f <trap_dispatch+0x129>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101cdf:	e8 6d f9 ff ff       	call   101651 <cons_getc>
  101ce4:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101ce7:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101ceb:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101cef:	89 54 24 08          	mov    %edx,0x8(%esp)
  101cf3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf7:	c7 04 24 74 73 10 00 	movl   $0x107374,(%esp)
  101cfe:	e8 8f e5 ff ff       	call   100292 <cprintf>
        break;
  101d03:	eb 7b                	jmp    101d80 <trap_dispatch+0x12a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d05:	e8 47 f9 ff ff       	call   101651 <cons_getc>
  101d0a:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d0d:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d11:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d15:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d19:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d1d:	c7 04 24 86 73 10 00 	movl   $0x107386,(%esp)
  101d24:	e8 69 e5 ff ff       	call   100292 <cprintf>
        break;
  101d29:	eb 55                	jmp    101d80 <trap_dispatch+0x12a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d2b:	c7 44 24 08 95 73 10 	movl   $0x107395,0x8(%esp)
  101d32:	00 
  101d33:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  101d3a:	00 
  101d3b:	c7 04 24 a5 73 10 00 	movl   $0x1073a5,(%esp)
  101d42:	e8 a2 e6 ff ff       	call   1003e9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101d47:	8b 45 08             	mov    0x8(%ebp),%eax
  101d4a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d4e:	83 e0 03             	and    $0x3,%eax
  101d51:	85 c0                	test   %eax,%eax
  101d53:	75 2b                	jne    101d80 <trap_dispatch+0x12a>
            print_trapframe(tf);
  101d55:	8b 45 08             	mov    0x8(%ebp),%eax
  101d58:	89 04 24             	mov    %eax,(%esp)
  101d5b:	e8 8b fc ff ff       	call   1019eb <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101d60:	c7 44 24 08 b6 73 10 	movl   $0x1073b6,0x8(%esp)
  101d67:	00 
  101d68:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  101d6f:	00 
  101d70:	c7 04 24 a5 73 10 00 	movl   $0x1073a5,(%esp)
  101d77:	e8 6d e6 ff ff       	call   1003e9 <__panic>
        break;
  101d7c:	90                   	nop
  101d7d:	eb 01                	jmp    101d80 <trap_dispatch+0x12a>
        break;
  101d7f:	90                   	nop
        }
    }
}
  101d80:	90                   	nop
  101d81:	c9                   	leave  
  101d82:	c3                   	ret    

00101d83 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101d83:	55                   	push   %ebp
  101d84:	89 e5                	mov    %esp,%ebp
  101d86:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101d89:	8b 45 08             	mov    0x8(%ebp),%eax
  101d8c:	89 04 24             	mov    %eax,(%esp)
  101d8f:	e8 c2 fe ff ff       	call   101c56 <trap_dispatch>
}
  101d94:	90                   	nop
  101d95:	c9                   	leave  
  101d96:	c3                   	ret    

00101d97 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101d97:	6a 00                	push   $0x0
  pushl $0
  101d99:	6a 00                	push   $0x0
  jmp __alltraps
  101d9b:	e9 69 0a 00 00       	jmp    102809 <__alltraps>

00101da0 <vector1>:
.globl vector1
vector1:
  pushl $0
  101da0:	6a 00                	push   $0x0
  pushl $1
  101da2:	6a 01                	push   $0x1
  jmp __alltraps
  101da4:	e9 60 0a 00 00       	jmp    102809 <__alltraps>

00101da9 <vector2>:
.globl vector2
vector2:
  pushl $0
  101da9:	6a 00                	push   $0x0
  pushl $2
  101dab:	6a 02                	push   $0x2
  jmp __alltraps
  101dad:	e9 57 0a 00 00       	jmp    102809 <__alltraps>

00101db2 <vector3>:
.globl vector3
vector3:
  pushl $0
  101db2:	6a 00                	push   $0x0
  pushl $3
  101db4:	6a 03                	push   $0x3
  jmp __alltraps
  101db6:	e9 4e 0a 00 00       	jmp    102809 <__alltraps>

00101dbb <vector4>:
.globl vector4
vector4:
  pushl $0
  101dbb:	6a 00                	push   $0x0
  pushl $4
  101dbd:	6a 04                	push   $0x4
  jmp __alltraps
  101dbf:	e9 45 0a 00 00       	jmp    102809 <__alltraps>

00101dc4 <vector5>:
.globl vector5
vector5:
  pushl $0
  101dc4:	6a 00                	push   $0x0
  pushl $5
  101dc6:	6a 05                	push   $0x5
  jmp __alltraps
  101dc8:	e9 3c 0a 00 00       	jmp    102809 <__alltraps>

00101dcd <vector6>:
.globl vector6
vector6:
  pushl $0
  101dcd:	6a 00                	push   $0x0
  pushl $6
  101dcf:	6a 06                	push   $0x6
  jmp __alltraps
  101dd1:	e9 33 0a 00 00       	jmp    102809 <__alltraps>

00101dd6 <vector7>:
.globl vector7
vector7:
  pushl $0
  101dd6:	6a 00                	push   $0x0
  pushl $7
  101dd8:	6a 07                	push   $0x7
  jmp __alltraps
  101dda:	e9 2a 0a 00 00       	jmp    102809 <__alltraps>

00101ddf <vector8>:
.globl vector8
vector8:
  pushl $8
  101ddf:	6a 08                	push   $0x8
  jmp __alltraps
  101de1:	e9 23 0a 00 00       	jmp    102809 <__alltraps>

00101de6 <vector9>:
.globl vector9
vector9:
  pushl $0
  101de6:	6a 00                	push   $0x0
  pushl $9
  101de8:	6a 09                	push   $0x9
  jmp __alltraps
  101dea:	e9 1a 0a 00 00       	jmp    102809 <__alltraps>

00101def <vector10>:
.globl vector10
vector10:
  pushl $10
  101def:	6a 0a                	push   $0xa
  jmp __alltraps
  101df1:	e9 13 0a 00 00       	jmp    102809 <__alltraps>

00101df6 <vector11>:
.globl vector11
vector11:
  pushl $11
  101df6:	6a 0b                	push   $0xb
  jmp __alltraps
  101df8:	e9 0c 0a 00 00       	jmp    102809 <__alltraps>

00101dfd <vector12>:
.globl vector12
vector12:
  pushl $12
  101dfd:	6a 0c                	push   $0xc
  jmp __alltraps
  101dff:	e9 05 0a 00 00       	jmp    102809 <__alltraps>

00101e04 <vector13>:
.globl vector13
vector13:
  pushl $13
  101e04:	6a 0d                	push   $0xd
  jmp __alltraps
  101e06:	e9 fe 09 00 00       	jmp    102809 <__alltraps>

00101e0b <vector14>:
.globl vector14
vector14:
  pushl $14
  101e0b:	6a 0e                	push   $0xe
  jmp __alltraps
  101e0d:	e9 f7 09 00 00       	jmp    102809 <__alltraps>

00101e12 <vector15>:
.globl vector15
vector15:
  pushl $0
  101e12:	6a 00                	push   $0x0
  pushl $15
  101e14:	6a 0f                	push   $0xf
  jmp __alltraps
  101e16:	e9 ee 09 00 00       	jmp    102809 <__alltraps>

00101e1b <vector16>:
.globl vector16
vector16:
  pushl $0
  101e1b:	6a 00                	push   $0x0
  pushl $16
  101e1d:	6a 10                	push   $0x10
  jmp __alltraps
  101e1f:	e9 e5 09 00 00       	jmp    102809 <__alltraps>

00101e24 <vector17>:
.globl vector17
vector17:
  pushl $17
  101e24:	6a 11                	push   $0x11
  jmp __alltraps
  101e26:	e9 de 09 00 00       	jmp    102809 <__alltraps>

00101e2b <vector18>:
.globl vector18
vector18:
  pushl $0
  101e2b:	6a 00                	push   $0x0
  pushl $18
  101e2d:	6a 12                	push   $0x12
  jmp __alltraps
  101e2f:	e9 d5 09 00 00       	jmp    102809 <__alltraps>

00101e34 <vector19>:
.globl vector19
vector19:
  pushl $0
  101e34:	6a 00                	push   $0x0
  pushl $19
  101e36:	6a 13                	push   $0x13
  jmp __alltraps
  101e38:	e9 cc 09 00 00       	jmp    102809 <__alltraps>

00101e3d <vector20>:
.globl vector20
vector20:
  pushl $0
  101e3d:	6a 00                	push   $0x0
  pushl $20
  101e3f:	6a 14                	push   $0x14
  jmp __alltraps
  101e41:	e9 c3 09 00 00       	jmp    102809 <__alltraps>

00101e46 <vector21>:
.globl vector21
vector21:
  pushl $0
  101e46:	6a 00                	push   $0x0
  pushl $21
  101e48:	6a 15                	push   $0x15
  jmp __alltraps
  101e4a:	e9 ba 09 00 00       	jmp    102809 <__alltraps>

00101e4f <vector22>:
.globl vector22
vector22:
  pushl $0
  101e4f:	6a 00                	push   $0x0
  pushl $22
  101e51:	6a 16                	push   $0x16
  jmp __alltraps
  101e53:	e9 b1 09 00 00       	jmp    102809 <__alltraps>

00101e58 <vector23>:
.globl vector23
vector23:
  pushl $0
  101e58:	6a 00                	push   $0x0
  pushl $23
  101e5a:	6a 17                	push   $0x17
  jmp __alltraps
  101e5c:	e9 a8 09 00 00       	jmp    102809 <__alltraps>

00101e61 <vector24>:
.globl vector24
vector24:
  pushl $0
  101e61:	6a 00                	push   $0x0
  pushl $24
  101e63:	6a 18                	push   $0x18
  jmp __alltraps
  101e65:	e9 9f 09 00 00       	jmp    102809 <__alltraps>

00101e6a <vector25>:
.globl vector25
vector25:
  pushl $0
  101e6a:	6a 00                	push   $0x0
  pushl $25
  101e6c:	6a 19                	push   $0x19
  jmp __alltraps
  101e6e:	e9 96 09 00 00       	jmp    102809 <__alltraps>

00101e73 <vector26>:
.globl vector26
vector26:
  pushl $0
  101e73:	6a 00                	push   $0x0
  pushl $26
  101e75:	6a 1a                	push   $0x1a
  jmp __alltraps
  101e77:	e9 8d 09 00 00       	jmp    102809 <__alltraps>

00101e7c <vector27>:
.globl vector27
vector27:
  pushl $0
  101e7c:	6a 00                	push   $0x0
  pushl $27
  101e7e:	6a 1b                	push   $0x1b
  jmp __alltraps
  101e80:	e9 84 09 00 00       	jmp    102809 <__alltraps>

00101e85 <vector28>:
.globl vector28
vector28:
  pushl $0
  101e85:	6a 00                	push   $0x0
  pushl $28
  101e87:	6a 1c                	push   $0x1c
  jmp __alltraps
  101e89:	e9 7b 09 00 00       	jmp    102809 <__alltraps>

00101e8e <vector29>:
.globl vector29
vector29:
  pushl $0
  101e8e:	6a 00                	push   $0x0
  pushl $29
  101e90:	6a 1d                	push   $0x1d
  jmp __alltraps
  101e92:	e9 72 09 00 00       	jmp    102809 <__alltraps>

00101e97 <vector30>:
.globl vector30
vector30:
  pushl $0
  101e97:	6a 00                	push   $0x0
  pushl $30
  101e99:	6a 1e                	push   $0x1e
  jmp __alltraps
  101e9b:	e9 69 09 00 00       	jmp    102809 <__alltraps>

00101ea0 <vector31>:
.globl vector31
vector31:
  pushl $0
  101ea0:	6a 00                	push   $0x0
  pushl $31
  101ea2:	6a 1f                	push   $0x1f
  jmp __alltraps
  101ea4:	e9 60 09 00 00       	jmp    102809 <__alltraps>

00101ea9 <vector32>:
.globl vector32
vector32:
  pushl $0
  101ea9:	6a 00                	push   $0x0
  pushl $32
  101eab:	6a 20                	push   $0x20
  jmp __alltraps
  101ead:	e9 57 09 00 00       	jmp    102809 <__alltraps>

00101eb2 <vector33>:
.globl vector33
vector33:
  pushl $0
  101eb2:	6a 00                	push   $0x0
  pushl $33
  101eb4:	6a 21                	push   $0x21
  jmp __alltraps
  101eb6:	e9 4e 09 00 00       	jmp    102809 <__alltraps>

00101ebb <vector34>:
.globl vector34
vector34:
  pushl $0
  101ebb:	6a 00                	push   $0x0
  pushl $34
  101ebd:	6a 22                	push   $0x22
  jmp __alltraps
  101ebf:	e9 45 09 00 00       	jmp    102809 <__alltraps>

00101ec4 <vector35>:
.globl vector35
vector35:
  pushl $0
  101ec4:	6a 00                	push   $0x0
  pushl $35
  101ec6:	6a 23                	push   $0x23
  jmp __alltraps
  101ec8:	e9 3c 09 00 00       	jmp    102809 <__alltraps>

00101ecd <vector36>:
.globl vector36
vector36:
  pushl $0
  101ecd:	6a 00                	push   $0x0
  pushl $36
  101ecf:	6a 24                	push   $0x24
  jmp __alltraps
  101ed1:	e9 33 09 00 00       	jmp    102809 <__alltraps>

00101ed6 <vector37>:
.globl vector37
vector37:
  pushl $0
  101ed6:	6a 00                	push   $0x0
  pushl $37
  101ed8:	6a 25                	push   $0x25
  jmp __alltraps
  101eda:	e9 2a 09 00 00       	jmp    102809 <__alltraps>

00101edf <vector38>:
.globl vector38
vector38:
  pushl $0
  101edf:	6a 00                	push   $0x0
  pushl $38
  101ee1:	6a 26                	push   $0x26
  jmp __alltraps
  101ee3:	e9 21 09 00 00       	jmp    102809 <__alltraps>

00101ee8 <vector39>:
.globl vector39
vector39:
  pushl $0
  101ee8:	6a 00                	push   $0x0
  pushl $39
  101eea:	6a 27                	push   $0x27
  jmp __alltraps
  101eec:	e9 18 09 00 00       	jmp    102809 <__alltraps>

00101ef1 <vector40>:
.globl vector40
vector40:
  pushl $0
  101ef1:	6a 00                	push   $0x0
  pushl $40
  101ef3:	6a 28                	push   $0x28
  jmp __alltraps
  101ef5:	e9 0f 09 00 00       	jmp    102809 <__alltraps>

00101efa <vector41>:
.globl vector41
vector41:
  pushl $0
  101efa:	6a 00                	push   $0x0
  pushl $41
  101efc:	6a 29                	push   $0x29
  jmp __alltraps
  101efe:	e9 06 09 00 00       	jmp    102809 <__alltraps>

00101f03 <vector42>:
.globl vector42
vector42:
  pushl $0
  101f03:	6a 00                	push   $0x0
  pushl $42
  101f05:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f07:	e9 fd 08 00 00       	jmp    102809 <__alltraps>

00101f0c <vector43>:
.globl vector43
vector43:
  pushl $0
  101f0c:	6a 00                	push   $0x0
  pushl $43
  101f0e:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f10:	e9 f4 08 00 00       	jmp    102809 <__alltraps>

00101f15 <vector44>:
.globl vector44
vector44:
  pushl $0
  101f15:	6a 00                	push   $0x0
  pushl $44
  101f17:	6a 2c                	push   $0x2c
  jmp __alltraps
  101f19:	e9 eb 08 00 00       	jmp    102809 <__alltraps>

00101f1e <vector45>:
.globl vector45
vector45:
  pushl $0
  101f1e:	6a 00                	push   $0x0
  pushl $45
  101f20:	6a 2d                	push   $0x2d
  jmp __alltraps
  101f22:	e9 e2 08 00 00       	jmp    102809 <__alltraps>

00101f27 <vector46>:
.globl vector46
vector46:
  pushl $0
  101f27:	6a 00                	push   $0x0
  pushl $46
  101f29:	6a 2e                	push   $0x2e
  jmp __alltraps
  101f2b:	e9 d9 08 00 00       	jmp    102809 <__alltraps>

00101f30 <vector47>:
.globl vector47
vector47:
  pushl $0
  101f30:	6a 00                	push   $0x0
  pushl $47
  101f32:	6a 2f                	push   $0x2f
  jmp __alltraps
  101f34:	e9 d0 08 00 00       	jmp    102809 <__alltraps>

00101f39 <vector48>:
.globl vector48
vector48:
  pushl $0
  101f39:	6a 00                	push   $0x0
  pushl $48
  101f3b:	6a 30                	push   $0x30
  jmp __alltraps
  101f3d:	e9 c7 08 00 00       	jmp    102809 <__alltraps>

00101f42 <vector49>:
.globl vector49
vector49:
  pushl $0
  101f42:	6a 00                	push   $0x0
  pushl $49
  101f44:	6a 31                	push   $0x31
  jmp __alltraps
  101f46:	e9 be 08 00 00       	jmp    102809 <__alltraps>

00101f4b <vector50>:
.globl vector50
vector50:
  pushl $0
  101f4b:	6a 00                	push   $0x0
  pushl $50
  101f4d:	6a 32                	push   $0x32
  jmp __alltraps
  101f4f:	e9 b5 08 00 00       	jmp    102809 <__alltraps>

00101f54 <vector51>:
.globl vector51
vector51:
  pushl $0
  101f54:	6a 00                	push   $0x0
  pushl $51
  101f56:	6a 33                	push   $0x33
  jmp __alltraps
  101f58:	e9 ac 08 00 00       	jmp    102809 <__alltraps>

00101f5d <vector52>:
.globl vector52
vector52:
  pushl $0
  101f5d:	6a 00                	push   $0x0
  pushl $52
  101f5f:	6a 34                	push   $0x34
  jmp __alltraps
  101f61:	e9 a3 08 00 00       	jmp    102809 <__alltraps>

00101f66 <vector53>:
.globl vector53
vector53:
  pushl $0
  101f66:	6a 00                	push   $0x0
  pushl $53
  101f68:	6a 35                	push   $0x35
  jmp __alltraps
  101f6a:	e9 9a 08 00 00       	jmp    102809 <__alltraps>

00101f6f <vector54>:
.globl vector54
vector54:
  pushl $0
  101f6f:	6a 00                	push   $0x0
  pushl $54
  101f71:	6a 36                	push   $0x36
  jmp __alltraps
  101f73:	e9 91 08 00 00       	jmp    102809 <__alltraps>

00101f78 <vector55>:
.globl vector55
vector55:
  pushl $0
  101f78:	6a 00                	push   $0x0
  pushl $55
  101f7a:	6a 37                	push   $0x37
  jmp __alltraps
  101f7c:	e9 88 08 00 00       	jmp    102809 <__alltraps>

00101f81 <vector56>:
.globl vector56
vector56:
  pushl $0
  101f81:	6a 00                	push   $0x0
  pushl $56
  101f83:	6a 38                	push   $0x38
  jmp __alltraps
  101f85:	e9 7f 08 00 00       	jmp    102809 <__alltraps>

00101f8a <vector57>:
.globl vector57
vector57:
  pushl $0
  101f8a:	6a 00                	push   $0x0
  pushl $57
  101f8c:	6a 39                	push   $0x39
  jmp __alltraps
  101f8e:	e9 76 08 00 00       	jmp    102809 <__alltraps>

00101f93 <vector58>:
.globl vector58
vector58:
  pushl $0
  101f93:	6a 00                	push   $0x0
  pushl $58
  101f95:	6a 3a                	push   $0x3a
  jmp __alltraps
  101f97:	e9 6d 08 00 00       	jmp    102809 <__alltraps>

00101f9c <vector59>:
.globl vector59
vector59:
  pushl $0
  101f9c:	6a 00                	push   $0x0
  pushl $59
  101f9e:	6a 3b                	push   $0x3b
  jmp __alltraps
  101fa0:	e9 64 08 00 00       	jmp    102809 <__alltraps>

00101fa5 <vector60>:
.globl vector60
vector60:
  pushl $0
  101fa5:	6a 00                	push   $0x0
  pushl $60
  101fa7:	6a 3c                	push   $0x3c
  jmp __alltraps
  101fa9:	e9 5b 08 00 00       	jmp    102809 <__alltraps>

00101fae <vector61>:
.globl vector61
vector61:
  pushl $0
  101fae:	6a 00                	push   $0x0
  pushl $61
  101fb0:	6a 3d                	push   $0x3d
  jmp __alltraps
  101fb2:	e9 52 08 00 00       	jmp    102809 <__alltraps>

00101fb7 <vector62>:
.globl vector62
vector62:
  pushl $0
  101fb7:	6a 00                	push   $0x0
  pushl $62
  101fb9:	6a 3e                	push   $0x3e
  jmp __alltraps
  101fbb:	e9 49 08 00 00       	jmp    102809 <__alltraps>

00101fc0 <vector63>:
.globl vector63
vector63:
  pushl $0
  101fc0:	6a 00                	push   $0x0
  pushl $63
  101fc2:	6a 3f                	push   $0x3f
  jmp __alltraps
  101fc4:	e9 40 08 00 00       	jmp    102809 <__alltraps>

00101fc9 <vector64>:
.globl vector64
vector64:
  pushl $0
  101fc9:	6a 00                	push   $0x0
  pushl $64
  101fcb:	6a 40                	push   $0x40
  jmp __alltraps
  101fcd:	e9 37 08 00 00       	jmp    102809 <__alltraps>

00101fd2 <vector65>:
.globl vector65
vector65:
  pushl $0
  101fd2:	6a 00                	push   $0x0
  pushl $65
  101fd4:	6a 41                	push   $0x41
  jmp __alltraps
  101fd6:	e9 2e 08 00 00       	jmp    102809 <__alltraps>

00101fdb <vector66>:
.globl vector66
vector66:
  pushl $0
  101fdb:	6a 00                	push   $0x0
  pushl $66
  101fdd:	6a 42                	push   $0x42
  jmp __alltraps
  101fdf:	e9 25 08 00 00       	jmp    102809 <__alltraps>

00101fe4 <vector67>:
.globl vector67
vector67:
  pushl $0
  101fe4:	6a 00                	push   $0x0
  pushl $67
  101fe6:	6a 43                	push   $0x43
  jmp __alltraps
  101fe8:	e9 1c 08 00 00       	jmp    102809 <__alltraps>

00101fed <vector68>:
.globl vector68
vector68:
  pushl $0
  101fed:	6a 00                	push   $0x0
  pushl $68
  101fef:	6a 44                	push   $0x44
  jmp __alltraps
  101ff1:	e9 13 08 00 00       	jmp    102809 <__alltraps>

00101ff6 <vector69>:
.globl vector69
vector69:
  pushl $0
  101ff6:	6a 00                	push   $0x0
  pushl $69
  101ff8:	6a 45                	push   $0x45
  jmp __alltraps
  101ffa:	e9 0a 08 00 00       	jmp    102809 <__alltraps>

00101fff <vector70>:
.globl vector70
vector70:
  pushl $0
  101fff:	6a 00                	push   $0x0
  pushl $70
  102001:	6a 46                	push   $0x46
  jmp __alltraps
  102003:	e9 01 08 00 00       	jmp    102809 <__alltraps>

00102008 <vector71>:
.globl vector71
vector71:
  pushl $0
  102008:	6a 00                	push   $0x0
  pushl $71
  10200a:	6a 47                	push   $0x47
  jmp __alltraps
  10200c:	e9 f8 07 00 00       	jmp    102809 <__alltraps>

00102011 <vector72>:
.globl vector72
vector72:
  pushl $0
  102011:	6a 00                	push   $0x0
  pushl $72
  102013:	6a 48                	push   $0x48
  jmp __alltraps
  102015:	e9 ef 07 00 00       	jmp    102809 <__alltraps>

0010201a <vector73>:
.globl vector73
vector73:
  pushl $0
  10201a:	6a 00                	push   $0x0
  pushl $73
  10201c:	6a 49                	push   $0x49
  jmp __alltraps
  10201e:	e9 e6 07 00 00       	jmp    102809 <__alltraps>

00102023 <vector74>:
.globl vector74
vector74:
  pushl $0
  102023:	6a 00                	push   $0x0
  pushl $74
  102025:	6a 4a                	push   $0x4a
  jmp __alltraps
  102027:	e9 dd 07 00 00       	jmp    102809 <__alltraps>

0010202c <vector75>:
.globl vector75
vector75:
  pushl $0
  10202c:	6a 00                	push   $0x0
  pushl $75
  10202e:	6a 4b                	push   $0x4b
  jmp __alltraps
  102030:	e9 d4 07 00 00       	jmp    102809 <__alltraps>

00102035 <vector76>:
.globl vector76
vector76:
  pushl $0
  102035:	6a 00                	push   $0x0
  pushl $76
  102037:	6a 4c                	push   $0x4c
  jmp __alltraps
  102039:	e9 cb 07 00 00       	jmp    102809 <__alltraps>

0010203e <vector77>:
.globl vector77
vector77:
  pushl $0
  10203e:	6a 00                	push   $0x0
  pushl $77
  102040:	6a 4d                	push   $0x4d
  jmp __alltraps
  102042:	e9 c2 07 00 00       	jmp    102809 <__alltraps>

00102047 <vector78>:
.globl vector78
vector78:
  pushl $0
  102047:	6a 00                	push   $0x0
  pushl $78
  102049:	6a 4e                	push   $0x4e
  jmp __alltraps
  10204b:	e9 b9 07 00 00       	jmp    102809 <__alltraps>

00102050 <vector79>:
.globl vector79
vector79:
  pushl $0
  102050:	6a 00                	push   $0x0
  pushl $79
  102052:	6a 4f                	push   $0x4f
  jmp __alltraps
  102054:	e9 b0 07 00 00       	jmp    102809 <__alltraps>

00102059 <vector80>:
.globl vector80
vector80:
  pushl $0
  102059:	6a 00                	push   $0x0
  pushl $80
  10205b:	6a 50                	push   $0x50
  jmp __alltraps
  10205d:	e9 a7 07 00 00       	jmp    102809 <__alltraps>

00102062 <vector81>:
.globl vector81
vector81:
  pushl $0
  102062:	6a 00                	push   $0x0
  pushl $81
  102064:	6a 51                	push   $0x51
  jmp __alltraps
  102066:	e9 9e 07 00 00       	jmp    102809 <__alltraps>

0010206b <vector82>:
.globl vector82
vector82:
  pushl $0
  10206b:	6a 00                	push   $0x0
  pushl $82
  10206d:	6a 52                	push   $0x52
  jmp __alltraps
  10206f:	e9 95 07 00 00       	jmp    102809 <__alltraps>

00102074 <vector83>:
.globl vector83
vector83:
  pushl $0
  102074:	6a 00                	push   $0x0
  pushl $83
  102076:	6a 53                	push   $0x53
  jmp __alltraps
  102078:	e9 8c 07 00 00       	jmp    102809 <__alltraps>

0010207d <vector84>:
.globl vector84
vector84:
  pushl $0
  10207d:	6a 00                	push   $0x0
  pushl $84
  10207f:	6a 54                	push   $0x54
  jmp __alltraps
  102081:	e9 83 07 00 00       	jmp    102809 <__alltraps>

00102086 <vector85>:
.globl vector85
vector85:
  pushl $0
  102086:	6a 00                	push   $0x0
  pushl $85
  102088:	6a 55                	push   $0x55
  jmp __alltraps
  10208a:	e9 7a 07 00 00       	jmp    102809 <__alltraps>

0010208f <vector86>:
.globl vector86
vector86:
  pushl $0
  10208f:	6a 00                	push   $0x0
  pushl $86
  102091:	6a 56                	push   $0x56
  jmp __alltraps
  102093:	e9 71 07 00 00       	jmp    102809 <__alltraps>

00102098 <vector87>:
.globl vector87
vector87:
  pushl $0
  102098:	6a 00                	push   $0x0
  pushl $87
  10209a:	6a 57                	push   $0x57
  jmp __alltraps
  10209c:	e9 68 07 00 00       	jmp    102809 <__alltraps>

001020a1 <vector88>:
.globl vector88
vector88:
  pushl $0
  1020a1:	6a 00                	push   $0x0
  pushl $88
  1020a3:	6a 58                	push   $0x58
  jmp __alltraps
  1020a5:	e9 5f 07 00 00       	jmp    102809 <__alltraps>

001020aa <vector89>:
.globl vector89
vector89:
  pushl $0
  1020aa:	6a 00                	push   $0x0
  pushl $89
  1020ac:	6a 59                	push   $0x59
  jmp __alltraps
  1020ae:	e9 56 07 00 00       	jmp    102809 <__alltraps>

001020b3 <vector90>:
.globl vector90
vector90:
  pushl $0
  1020b3:	6a 00                	push   $0x0
  pushl $90
  1020b5:	6a 5a                	push   $0x5a
  jmp __alltraps
  1020b7:	e9 4d 07 00 00       	jmp    102809 <__alltraps>

001020bc <vector91>:
.globl vector91
vector91:
  pushl $0
  1020bc:	6a 00                	push   $0x0
  pushl $91
  1020be:	6a 5b                	push   $0x5b
  jmp __alltraps
  1020c0:	e9 44 07 00 00       	jmp    102809 <__alltraps>

001020c5 <vector92>:
.globl vector92
vector92:
  pushl $0
  1020c5:	6a 00                	push   $0x0
  pushl $92
  1020c7:	6a 5c                	push   $0x5c
  jmp __alltraps
  1020c9:	e9 3b 07 00 00       	jmp    102809 <__alltraps>

001020ce <vector93>:
.globl vector93
vector93:
  pushl $0
  1020ce:	6a 00                	push   $0x0
  pushl $93
  1020d0:	6a 5d                	push   $0x5d
  jmp __alltraps
  1020d2:	e9 32 07 00 00       	jmp    102809 <__alltraps>

001020d7 <vector94>:
.globl vector94
vector94:
  pushl $0
  1020d7:	6a 00                	push   $0x0
  pushl $94
  1020d9:	6a 5e                	push   $0x5e
  jmp __alltraps
  1020db:	e9 29 07 00 00       	jmp    102809 <__alltraps>

001020e0 <vector95>:
.globl vector95
vector95:
  pushl $0
  1020e0:	6a 00                	push   $0x0
  pushl $95
  1020e2:	6a 5f                	push   $0x5f
  jmp __alltraps
  1020e4:	e9 20 07 00 00       	jmp    102809 <__alltraps>

001020e9 <vector96>:
.globl vector96
vector96:
  pushl $0
  1020e9:	6a 00                	push   $0x0
  pushl $96
  1020eb:	6a 60                	push   $0x60
  jmp __alltraps
  1020ed:	e9 17 07 00 00       	jmp    102809 <__alltraps>

001020f2 <vector97>:
.globl vector97
vector97:
  pushl $0
  1020f2:	6a 00                	push   $0x0
  pushl $97
  1020f4:	6a 61                	push   $0x61
  jmp __alltraps
  1020f6:	e9 0e 07 00 00       	jmp    102809 <__alltraps>

001020fb <vector98>:
.globl vector98
vector98:
  pushl $0
  1020fb:	6a 00                	push   $0x0
  pushl $98
  1020fd:	6a 62                	push   $0x62
  jmp __alltraps
  1020ff:	e9 05 07 00 00       	jmp    102809 <__alltraps>

00102104 <vector99>:
.globl vector99
vector99:
  pushl $0
  102104:	6a 00                	push   $0x0
  pushl $99
  102106:	6a 63                	push   $0x63
  jmp __alltraps
  102108:	e9 fc 06 00 00       	jmp    102809 <__alltraps>

0010210d <vector100>:
.globl vector100
vector100:
  pushl $0
  10210d:	6a 00                	push   $0x0
  pushl $100
  10210f:	6a 64                	push   $0x64
  jmp __alltraps
  102111:	e9 f3 06 00 00       	jmp    102809 <__alltraps>

00102116 <vector101>:
.globl vector101
vector101:
  pushl $0
  102116:	6a 00                	push   $0x0
  pushl $101
  102118:	6a 65                	push   $0x65
  jmp __alltraps
  10211a:	e9 ea 06 00 00       	jmp    102809 <__alltraps>

0010211f <vector102>:
.globl vector102
vector102:
  pushl $0
  10211f:	6a 00                	push   $0x0
  pushl $102
  102121:	6a 66                	push   $0x66
  jmp __alltraps
  102123:	e9 e1 06 00 00       	jmp    102809 <__alltraps>

00102128 <vector103>:
.globl vector103
vector103:
  pushl $0
  102128:	6a 00                	push   $0x0
  pushl $103
  10212a:	6a 67                	push   $0x67
  jmp __alltraps
  10212c:	e9 d8 06 00 00       	jmp    102809 <__alltraps>

00102131 <vector104>:
.globl vector104
vector104:
  pushl $0
  102131:	6a 00                	push   $0x0
  pushl $104
  102133:	6a 68                	push   $0x68
  jmp __alltraps
  102135:	e9 cf 06 00 00       	jmp    102809 <__alltraps>

0010213a <vector105>:
.globl vector105
vector105:
  pushl $0
  10213a:	6a 00                	push   $0x0
  pushl $105
  10213c:	6a 69                	push   $0x69
  jmp __alltraps
  10213e:	e9 c6 06 00 00       	jmp    102809 <__alltraps>

00102143 <vector106>:
.globl vector106
vector106:
  pushl $0
  102143:	6a 00                	push   $0x0
  pushl $106
  102145:	6a 6a                	push   $0x6a
  jmp __alltraps
  102147:	e9 bd 06 00 00       	jmp    102809 <__alltraps>

0010214c <vector107>:
.globl vector107
vector107:
  pushl $0
  10214c:	6a 00                	push   $0x0
  pushl $107
  10214e:	6a 6b                	push   $0x6b
  jmp __alltraps
  102150:	e9 b4 06 00 00       	jmp    102809 <__alltraps>

00102155 <vector108>:
.globl vector108
vector108:
  pushl $0
  102155:	6a 00                	push   $0x0
  pushl $108
  102157:	6a 6c                	push   $0x6c
  jmp __alltraps
  102159:	e9 ab 06 00 00       	jmp    102809 <__alltraps>

0010215e <vector109>:
.globl vector109
vector109:
  pushl $0
  10215e:	6a 00                	push   $0x0
  pushl $109
  102160:	6a 6d                	push   $0x6d
  jmp __alltraps
  102162:	e9 a2 06 00 00       	jmp    102809 <__alltraps>

00102167 <vector110>:
.globl vector110
vector110:
  pushl $0
  102167:	6a 00                	push   $0x0
  pushl $110
  102169:	6a 6e                	push   $0x6e
  jmp __alltraps
  10216b:	e9 99 06 00 00       	jmp    102809 <__alltraps>

00102170 <vector111>:
.globl vector111
vector111:
  pushl $0
  102170:	6a 00                	push   $0x0
  pushl $111
  102172:	6a 6f                	push   $0x6f
  jmp __alltraps
  102174:	e9 90 06 00 00       	jmp    102809 <__alltraps>

00102179 <vector112>:
.globl vector112
vector112:
  pushl $0
  102179:	6a 00                	push   $0x0
  pushl $112
  10217b:	6a 70                	push   $0x70
  jmp __alltraps
  10217d:	e9 87 06 00 00       	jmp    102809 <__alltraps>

00102182 <vector113>:
.globl vector113
vector113:
  pushl $0
  102182:	6a 00                	push   $0x0
  pushl $113
  102184:	6a 71                	push   $0x71
  jmp __alltraps
  102186:	e9 7e 06 00 00       	jmp    102809 <__alltraps>

0010218b <vector114>:
.globl vector114
vector114:
  pushl $0
  10218b:	6a 00                	push   $0x0
  pushl $114
  10218d:	6a 72                	push   $0x72
  jmp __alltraps
  10218f:	e9 75 06 00 00       	jmp    102809 <__alltraps>

00102194 <vector115>:
.globl vector115
vector115:
  pushl $0
  102194:	6a 00                	push   $0x0
  pushl $115
  102196:	6a 73                	push   $0x73
  jmp __alltraps
  102198:	e9 6c 06 00 00       	jmp    102809 <__alltraps>

0010219d <vector116>:
.globl vector116
vector116:
  pushl $0
  10219d:	6a 00                	push   $0x0
  pushl $116
  10219f:	6a 74                	push   $0x74
  jmp __alltraps
  1021a1:	e9 63 06 00 00       	jmp    102809 <__alltraps>

001021a6 <vector117>:
.globl vector117
vector117:
  pushl $0
  1021a6:	6a 00                	push   $0x0
  pushl $117
  1021a8:	6a 75                	push   $0x75
  jmp __alltraps
  1021aa:	e9 5a 06 00 00       	jmp    102809 <__alltraps>

001021af <vector118>:
.globl vector118
vector118:
  pushl $0
  1021af:	6a 00                	push   $0x0
  pushl $118
  1021b1:	6a 76                	push   $0x76
  jmp __alltraps
  1021b3:	e9 51 06 00 00       	jmp    102809 <__alltraps>

001021b8 <vector119>:
.globl vector119
vector119:
  pushl $0
  1021b8:	6a 00                	push   $0x0
  pushl $119
  1021ba:	6a 77                	push   $0x77
  jmp __alltraps
  1021bc:	e9 48 06 00 00       	jmp    102809 <__alltraps>

001021c1 <vector120>:
.globl vector120
vector120:
  pushl $0
  1021c1:	6a 00                	push   $0x0
  pushl $120
  1021c3:	6a 78                	push   $0x78
  jmp __alltraps
  1021c5:	e9 3f 06 00 00       	jmp    102809 <__alltraps>

001021ca <vector121>:
.globl vector121
vector121:
  pushl $0
  1021ca:	6a 00                	push   $0x0
  pushl $121
  1021cc:	6a 79                	push   $0x79
  jmp __alltraps
  1021ce:	e9 36 06 00 00       	jmp    102809 <__alltraps>

001021d3 <vector122>:
.globl vector122
vector122:
  pushl $0
  1021d3:	6a 00                	push   $0x0
  pushl $122
  1021d5:	6a 7a                	push   $0x7a
  jmp __alltraps
  1021d7:	e9 2d 06 00 00       	jmp    102809 <__alltraps>

001021dc <vector123>:
.globl vector123
vector123:
  pushl $0
  1021dc:	6a 00                	push   $0x0
  pushl $123
  1021de:	6a 7b                	push   $0x7b
  jmp __alltraps
  1021e0:	e9 24 06 00 00       	jmp    102809 <__alltraps>

001021e5 <vector124>:
.globl vector124
vector124:
  pushl $0
  1021e5:	6a 00                	push   $0x0
  pushl $124
  1021e7:	6a 7c                	push   $0x7c
  jmp __alltraps
  1021e9:	e9 1b 06 00 00       	jmp    102809 <__alltraps>

001021ee <vector125>:
.globl vector125
vector125:
  pushl $0
  1021ee:	6a 00                	push   $0x0
  pushl $125
  1021f0:	6a 7d                	push   $0x7d
  jmp __alltraps
  1021f2:	e9 12 06 00 00       	jmp    102809 <__alltraps>

001021f7 <vector126>:
.globl vector126
vector126:
  pushl $0
  1021f7:	6a 00                	push   $0x0
  pushl $126
  1021f9:	6a 7e                	push   $0x7e
  jmp __alltraps
  1021fb:	e9 09 06 00 00       	jmp    102809 <__alltraps>

00102200 <vector127>:
.globl vector127
vector127:
  pushl $0
  102200:	6a 00                	push   $0x0
  pushl $127
  102202:	6a 7f                	push   $0x7f
  jmp __alltraps
  102204:	e9 00 06 00 00       	jmp    102809 <__alltraps>

00102209 <vector128>:
.globl vector128
vector128:
  pushl $0
  102209:	6a 00                	push   $0x0
  pushl $128
  10220b:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102210:	e9 f4 05 00 00       	jmp    102809 <__alltraps>

00102215 <vector129>:
.globl vector129
vector129:
  pushl $0
  102215:	6a 00                	push   $0x0
  pushl $129
  102217:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  10221c:	e9 e8 05 00 00       	jmp    102809 <__alltraps>

00102221 <vector130>:
.globl vector130
vector130:
  pushl $0
  102221:	6a 00                	push   $0x0
  pushl $130
  102223:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102228:	e9 dc 05 00 00       	jmp    102809 <__alltraps>

0010222d <vector131>:
.globl vector131
vector131:
  pushl $0
  10222d:	6a 00                	push   $0x0
  pushl $131
  10222f:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102234:	e9 d0 05 00 00       	jmp    102809 <__alltraps>

00102239 <vector132>:
.globl vector132
vector132:
  pushl $0
  102239:	6a 00                	push   $0x0
  pushl $132
  10223b:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102240:	e9 c4 05 00 00       	jmp    102809 <__alltraps>

00102245 <vector133>:
.globl vector133
vector133:
  pushl $0
  102245:	6a 00                	push   $0x0
  pushl $133
  102247:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10224c:	e9 b8 05 00 00       	jmp    102809 <__alltraps>

00102251 <vector134>:
.globl vector134
vector134:
  pushl $0
  102251:	6a 00                	push   $0x0
  pushl $134
  102253:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102258:	e9 ac 05 00 00       	jmp    102809 <__alltraps>

0010225d <vector135>:
.globl vector135
vector135:
  pushl $0
  10225d:	6a 00                	push   $0x0
  pushl $135
  10225f:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102264:	e9 a0 05 00 00       	jmp    102809 <__alltraps>

00102269 <vector136>:
.globl vector136
vector136:
  pushl $0
  102269:	6a 00                	push   $0x0
  pushl $136
  10226b:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102270:	e9 94 05 00 00       	jmp    102809 <__alltraps>

00102275 <vector137>:
.globl vector137
vector137:
  pushl $0
  102275:	6a 00                	push   $0x0
  pushl $137
  102277:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  10227c:	e9 88 05 00 00       	jmp    102809 <__alltraps>

00102281 <vector138>:
.globl vector138
vector138:
  pushl $0
  102281:	6a 00                	push   $0x0
  pushl $138
  102283:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102288:	e9 7c 05 00 00       	jmp    102809 <__alltraps>

0010228d <vector139>:
.globl vector139
vector139:
  pushl $0
  10228d:	6a 00                	push   $0x0
  pushl $139
  10228f:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102294:	e9 70 05 00 00       	jmp    102809 <__alltraps>

00102299 <vector140>:
.globl vector140
vector140:
  pushl $0
  102299:	6a 00                	push   $0x0
  pushl $140
  10229b:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1022a0:	e9 64 05 00 00       	jmp    102809 <__alltraps>

001022a5 <vector141>:
.globl vector141
vector141:
  pushl $0
  1022a5:	6a 00                	push   $0x0
  pushl $141
  1022a7:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1022ac:	e9 58 05 00 00       	jmp    102809 <__alltraps>

001022b1 <vector142>:
.globl vector142
vector142:
  pushl $0
  1022b1:	6a 00                	push   $0x0
  pushl $142
  1022b3:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1022b8:	e9 4c 05 00 00       	jmp    102809 <__alltraps>

001022bd <vector143>:
.globl vector143
vector143:
  pushl $0
  1022bd:	6a 00                	push   $0x0
  pushl $143
  1022bf:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1022c4:	e9 40 05 00 00       	jmp    102809 <__alltraps>

001022c9 <vector144>:
.globl vector144
vector144:
  pushl $0
  1022c9:	6a 00                	push   $0x0
  pushl $144
  1022cb:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1022d0:	e9 34 05 00 00       	jmp    102809 <__alltraps>

001022d5 <vector145>:
.globl vector145
vector145:
  pushl $0
  1022d5:	6a 00                	push   $0x0
  pushl $145
  1022d7:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1022dc:	e9 28 05 00 00       	jmp    102809 <__alltraps>

001022e1 <vector146>:
.globl vector146
vector146:
  pushl $0
  1022e1:	6a 00                	push   $0x0
  pushl $146
  1022e3:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1022e8:	e9 1c 05 00 00       	jmp    102809 <__alltraps>

001022ed <vector147>:
.globl vector147
vector147:
  pushl $0
  1022ed:	6a 00                	push   $0x0
  pushl $147
  1022ef:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1022f4:	e9 10 05 00 00       	jmp    102809 <__alltraps>

001022f9 <vector148>:
.globl vector148
vector148:
  pushl $0
  1022f9:	6a 00                	push   $0x0
  pushl $148
  1022fb:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102300:	e9 04 05 00 00       	jmp    102809 <__alltraps>

00102305 <vector149>:
.globl vector149
vector149:
  pushl $0
  102305:	6a 00                	push   $0x0
  pushl $149
  102307:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  10230c:	e9 f8 04 00 00       	jmp    102809 <__alltraps>

00102311 <vector150>:
.globl vector150
vector150:
  pushl $0
  102311:	6a 00                	push   $0x0
  pushl $150
  102313:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102318:	e9 ec 04 00 00       	jmp    102809 <__alltraps>

0010231d <vector151>:
.globl vector151
vector151:
  pushl $0
  10231d:	6a 00                	push   $0x0
  pushl $151
  10231f:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102324:	e9 e0 04 00 00       	jmp    102809 <__alltraps>

00102329 <vector152>:
.globl vector152
vector152:
  pushl $0
  102329:	6a 00                	push   $0x0
  pushl $152
  10232b:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102330:	e9 d4 04 00 00       	jmp    102809 <__alltraps>

00102335 <vector153>:
.globl vector153
vector153:
  pushl $0
  102335:	6a 00                	push   $0x0
  pushl $153
  102337:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10233c:	e9 c8 04 00 00       	jmp    102809 <__alltraps>

00102341 <vector154>:
.globl vector154
vector154:
  pushl $0
  102341:	6a 00                	push   $0x0
  pushl $154
  102343:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102348:	e9 bc 04 00 00       	jmp    102809 <__alltraps>

0010234d <vector155>:
.globl vector155
vector155:
  pushl $0
  10234d:	6a 00                	push   $0x0
  pushl $155
  10234f:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102354:	e9 b0 04 00 00       	jmp    102809 <__alltraps>

00102359 <vector156>:
.globl vector156
vector156:
  pushl $0
  102359:	6a 00                	push   $0x0
  pushl $156
  10235b:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102360:	e9 a4 04 00 00       	jmp    102809 <__alltraps>

00102365 <vector157>:
.globl vector157
vector157:
  pushl $0
  102365:	6a 00                	push   $0x0
  pushl $157
  102367:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10236c:	e9 98 04 00 00       	jmp    102809 <__alltraps>

00102371 <vector158>:
.globl vector158
vector158:
  pushl $0
  102371:	6a 00                	push   $0x0
  pushl $158
  102373:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102378:	e9 8c 04 00 00       	jmp    102809 <__alltraps>

0010237d <vector159>:
.globl vector159
vector159:
  pushl $0
  10237d:	6a 00                	push   $0x0
  pushl $159
  10237f:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102384:	e9 80 04 00 00       	jmp    102809 <__alltraps>

00102389 <vector160>:
.globl vector160
vector160:
  pushl $0
  102389:	6a 00                	push   $0x0
  pushl $160
  10238b:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102390:	e9 74 04 00 00       	jmp    102809 <__alltraps>

00102395 <vector161>:
.globl vector161
vector161:
  pushl $0
  102395:	6a 00                	push   $0x0
  pushl $161
  102397:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10239c:	e9 68 04 00 00       	jmp    102809 <__alltraps>

001023a1 <vector162>:
.globl vector162
vector162:
  pushl $0
  1023a1:	6a 00                	push   $0x0
  pushl $162
  1023a3:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1023a8:	e9 5c 04 00 00       	jmp    102809 <__alltraps>

001023ad <vector163>:
.globl vector163
vector163:
  pushl $0
  1023ad:	6a 00                	push   $0x0
  pushl $163
  1023af:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1023b4:	e9 50 04 00 00       	jmp    102809 <__alltraps>

001023b9 <vector164>:
.globl vector164
vector164:
  pushl $0
  1023b9:	6a 00                	push   $0x0
  pushl $164
  1023bb:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1023c0:	e9 44 04 00 00       	jmp    102809 <__alltraps>

001023c5 <vector165>:
.globl vector165
vector165:
  pushl $0
  1023c5:	6a 00                	push   $0x0
  pushl $165
  1023c7:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1023cc:	e9 38 04 00 00       	jmp    102809 <__alltraps>

001023d1 <vector166>:
.globl vector166
vector166:
  pushl $0
  1023d1:	6a 00                	push   $0x0
  pushl $166
  1023d3:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1023d8:	e9 2c 04 00 00       	jmp    102809 <__alltraps>

001023dd <vector167>:
.globl vector167
vector167:
  pushl $0
  1023dd:	6a 00                	push   $0x0
  pushl $167
  1023df:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1023e4:	e9 20 04 00 00       	jmp    102809 <__alltraps>

001023e9 <vector168>:
.globl vector168
vector168:
  pushl $0
  1023e9:	6a 00                	push   $0x0
  pushl $168
  1023eb:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1023f0:	e9 14 04 00 00       	jmp    102809 <__alltraps>

001023f5 <vector169>:
.globl vector169
vector169:
  pushl $0
  1023f5:	6a 00                	push   $0x0
  pushl $169
  1023f7:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1023fc:	e9 08 04 00 00       	jmp    102809 <__alltraps>

00102401 <vector170>:
.globl vector170
vector170:
  pushl $0
  102401:	6a 00                	push   $0x0
  pushl $170
  102403:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102408:	e9 fc 03 00 00       	jmp    102809 <__alltraps>

0010240d <vector171>:
.globl vector171
vector171:
  pushl $0
  10240d:	6a 00                	push   $0x0
  pushl $171
  10240f:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102414:	e9 f0 03 00 00       	jmp    102809 <__alltraps>

00102419 <vector172>:
.globl vector172
vector172:
  pushl $0
  102419:	6a 00                	push   $0x0
  pushl $172
  10241b:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102420:	e9 e4 03 00 00       	jmp    102809 <__alltraps>

00102425 <vector173>:
.globl vector173
vector173:
  pushl $0
  102425:	6a 00                	push   $0x0
  pushl $173
  102427:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10242c:	e9 d8 03 00 00       	jmp    102809 <__alltraps>

00102431 <vector174>:
.globl vector174
vector174:
  pushl $0
  102431:	6a 00                	push   $0x0
  pushl $174
  102433:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102438:	e9 cc 03 00 00       	jmp    102809 <__alltraps>

0010243d <vector175>:
.globl vector175
vector175:
  pushl $0
  10243d:	6a 00                	push   $0x0
  pushl $175
  10243f:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102444:	e9 c0 03 00 00       	jmp    102809 <__alltraps>

00102449 <vector176>:
.globl vector176
vector176:
  pushl $0
  102449:	6a 00                	push   $0x0
  pushl $176
  10244b:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102450:	e9 b4 03 00 00       	jmp    102809 <__alltraps>

00102455 <vector177>:
.globl vector177
vector177:
  pushl $0
  102455:	6a 00                	push   $0x0
  pushl $177
  102457:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10245c:	e9 a8 03 00 00       	jmp    102809 <__alltraps>

00102461 <vector178>:
.globl vector178
vector178:
  pushl $0
  102461:	6a 00                	push   $0x0
  pushl $178
  102463:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102468:	e9 9c 03 00 00       	jmp    102809 <__alltraps>

0010246d <vector179>:
.globl vector179
vector179:
  pushl $0
  10246d:	6a 00                	push   $0x0
  pushl $179
  10246f:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102474:	e9 90 03 00 00       	jmp    102809 <__alltraps>

00102479 <vector180>:
.globl vector180
vector180:
  pushl $0
  102479:	6a 00                	push   $0x0
  pushl $180
  10247b:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102480:	e9 84 03 00 00       	jmp    102809 <__alltraps>

00102485 <vector181>:
.globl vector181
vector181:
  pushl $0
  102485:	6a 00                	push   $0x0
  pushl $181
  102487:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10248c:	e9 78 03 00 00       	jmp    102809 <__alltraps>

00102491 <vector182>:
.globl vector182
vector182:
  pushl $0
  102491:	6a 00                	push   $0x0
  pushl $182
  102493:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102498:	e9 6c 03 00 00       	jmp    102809 <__alltraps>

0010249d <vector183>:
.globl vector183
vector183:
  pushl $0
  10249d:	6a 00                	push   $0x0
  pushl $183
  10249f:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1024a4:	e9 60 03 00 00       	jmp    102809 <__alltraps>

001024a9 <vector184>:
.globl vector184
vector184:
  pushl $0
  1024a9:	6a 00                	push   $0x0
  pushl $184
  1024ab:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1024b0:	e9 54 03 00 00       	jmp    102809 <__alltraps>

001024b5 <vector185>:
.globl vector185
vector185:
  pushl $0
  1024b5:	6a 00                	push   $0x0
  pushl $185
  1024b7:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1024bc:	e9 48 03 00 00       	jmp    102809 <__alltraps>

001024c1 <vector186>:
.globl vector186
vector186:
  pushl $0
  1024c1:	6a 00                	push   $0x0
  pushl $186
  1024c3:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1024c8:	e9 3c 03 00 00       	jmp    102809 <__alltraps>

001024cd <vector187>:
.globl vector187
vector187:
  pushl $0
  1024cd:	6a 00                	push   $0x0
  pushl $187
  1024cf:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1024d4:	e9 30 03 00 00       	jmp    102809 <__alltraps>

001024d9 <vector188>:
.globl vector188
vector188:
  pushl $0
  1024d9:	6a 00                	push   $0x0
  pushl $188
  1024db:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1024e0:	e9 24 03 00 00       	jmp    102809 <__alltraps>

001024e5 <vector189>:
.globl vector189
vector189:
  pushl $0
  1024e5:	6a 00                	push   $0x0
  pushl $189
  1024e7:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1024ec:	e9 18 03 00 00       	jmp    102809 <__alltraps>

001024f1 <vector190>:
.globl vector190
vector190:
  pushl $0
  1024f1:	6a 00                	push   $0x0
  pushl $190
  1024f3:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1024f8:	e9 0c 03 00 00       	jmp    102809 <__alltraps>

001024fd <vector191>:
.globl vector191
vector191:
  pushl $0
  1024fd:	6a 00                	push   $0x0
  pushl $191
  1024ff:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102504:	e9 00 03 00 00       	jmp    102809 <__alltraps>

00102509 <vector192>:
.globl vector192
vector192:
  pushl $0
  102509:	6a 00                	push   $0x0
  pushl $192
  10250b:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102510:	e9 f4 02 00 00       	jmp    102809 <__alltraps>

00102515 <vector193>:
.globl vector193
vector193:
  pushl $0
  102515:	6a 00                	push   $0x0
  pushl $193
  102517:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  10251c:	e9 e8 02 00 00       	jmp    102809 <__alltraps>

00102521 <vector194>:
.globl vector194
vector194:
  pushl $0
  102521:	6a 00                	push   $0x0
  pushl $194
  102523:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102528:	e9 dc 02 00 00       	jmp    102809 <__alltraps>

0010252d <vector195>:
.globl vector195
vector195:
  pushl $0
  10252d:	6a 00                	push   $0x0
  pushl $195
  10252f:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102534:	e9 d0 02 00 00       	jmp    102809 <__alltraps>

00102539 <vector196>:
.globl vector196
vector196:
  pushl $0
  102539:	6a 00                	push   $0x0
  pushl $196
  10253b:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102540:	e9 c4 02 00 00       	jmp    102809 <__alltraps>

00102545 <vector197>:
.globl vector197
vector197:
  pushl $0
  102545:	6a 00                	push   $0x0
  pushl $197
  102547:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10254c:	e9 b8 02 00 00       	jmp    102809 <__alltraps>

00102551 <vector198>:
.globl vector198
vector198:
  pushl $0
  102551:	6a 00                	push   $0x0
  pushl $198
  102553:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102558:	e9 ac 02 00 00       	jmp    102809 <__alltraps>

0010255d <vector199>:
.globl vector199
vector199:
  pushl $0
  10255d:	6a 00                	push   $0x0
  pushl $199
  10255f:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102564:	e9 a0 02 00 00       	jmp    102809 <__alltraps>

00102569 <vector200>:
.globl vector200
vector200:
  pushl $0
  102569:	6a 00                	push   $0x0
  pushl $200
  10256b:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102570:	e9 94 02 00 00       	jmp    102809 <__alltraps>

00102575 <vector201>:
.globl vector201
vector201:
  pushl $0
  102575:	6a 00                	push   $0x0
  pushl $201
  102577:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  10257c:	e9 88 02 00 00       	jmp    102809 <__alltraps>

00102581 <vector202>:
.globl vector202
vector202:
  pushl $0
  102581:	6a 00                	push   $0x0
  pushl $202
  102583:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102588:	e9 7c 02 00 00       	jmp    102809 <__alltraps>

0010258d <vector203>:
.globl vector203
vector203:
  pushl $0
  10258d:	6a 00                	push   $0x0
  pushl $203
  10258f:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102594:	e9 70 02 00 00       	jmp    102809 <__alltraps>

00102599 <vector204>:
.globl vector204
vector204:
  pushl $0
  102599:	6a 00                	push   $0x0
  pushl $204
  10259b:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1025a0:	e9 64 02 00 00       	jmp    102809 <__alltraps>

001025a5 <vector205>:
.globl vector205
vector205:
  pushl $0
  1025a5:	6a 00                	push   $0x0
  pushl $205
  1025a7:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1025ac:	e9 58 02 00 00       	jmp    102809 <__alltraps>

001025b1 <vector206>:
.globl vector206
vector206:
  pushl $0
  1025b1:	6a 00                	push   $0x0
  pushl $206
  1025b3:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1025b8:	e9 4c 02 00 00       	jmp    102809 <__alltraps>

001025bd <vector207>:
.globl vector207
vector207:
  pushl $0
  1025bd:	6a 00                	push   $0x0
  pushl $207
  1025bf:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1025c4:	e9 40 02 00 00       	jmp    102809 <__alltraps>

001025c9 <vector208>:
.globl vector208
vector208:
  pushl $0
  1025c9:	6a 00                	push   $0x0
  pushl $208
  1025cb:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1025d0:	e9 34 02 00 00       	jmp    102809 <__alltraps>

001025d5 <vector209>:
.globl vector209
vector209:
  pushl $0
  1025d5:	6a 00                	push   $0x0
  pushl $209
  1025d7:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1025dc:	e9 28 02 00 00       	jmp    102809 <__alltraps>

001025e1 <vector210>:
.globl vector210
vector210:
  pushl $0
  1025e1:	6a 00                	push   $0x0
  pushl $210
  1025e3:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1025e8:	e9 1c 02 00 00       	jmp    102809 <__alltraps>

001025ed <vector211>:
.globl vector211
vector211:
  pushl $0
  1025ed:	6a 00                	push   $0x0
  pushl $211
  1025ef:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1025f4:	e9 10 02 00 00       	jmp    102809 <__alltraps>

001025f9 <vector212>:
.globl vector212
vector212:
  pushl $0
  1025f9:	6a 00                	push   $0x0
  pushl $212
  1025fb:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102600:	e9 04 02 00 00       	jmp    102809 <__alltraps>

00102605 <vector213>:
.globl vector213
vector213:
  pushl $0
  102605:	6a 00                	push   $0x0
  pushl $213
  102607:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  10260c:	e9 f8 01 00 00       	jmp    102809 <__alltraps>

00102611 <vector214>:
.globl vector214
vector214:
  pushl $0
  102611:	6a 00                	push   $0x0
  pushl $214
  102613:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102618:	e9 ec 01 00 00       	jmp    102809 <__alltraps>

0010261d <vector215>:
.globl vector215
vector215:
  pushl $0
  10261d:	6a 00                	push   $0x0
  pushl $215
  10261f:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102624:	e9 e0 01 00 00       	jmp    102809 <__alltraps>

00102629 <vector216>:
.globl vector216
vector216:
  pushl $0
  102629:	6a 00                	push   $0x0
  pushl $216
  10262b:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102630:	e9 d4 01 00 00       	jmp    102809 <__alltraps>

00102635 <vector217>:
.globl vector217
vector217:
  pushl $0
  102635:	6a 00                	push   $0x0
  pushl $217
  102637:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  10263c:	e9 c8 01 00 00       	jmp    102809 <__alltraps>

00102641 <vector218>:
.globl vector218
vector218:
  pushl $0
  102641:	6a 00                	push   $0x0
  pushl $218
  102643:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102648:	e9 bc 01 00 00       	jmp    102809 <__alltraps>

0010264d <vector219>:
.globl vector219
vector219:
  pushl $0
  10264d:	6a 00                	push   $0x0
  pushl $219
  10264f:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102654:	e9 b0 01 00 00       	jmp    102809 <__alltraps>

00102659 <vector220>:
.globl vector220
vector220:
  pushl $0
  102659:	6a 00                	push   $0x0
  pushl $220
  10265b:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102660:	e9 a4 01 00 00       	jmp    102809 <__alltraps>

00102665 <vector221>:
.globl vector221
vector221:
  pushl $0
  102665:	6a 00                	push   $0x0
  pushl $221
  102667:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  10266c:	e9 98 01 00 00       	jmp    102809 <__alltraps>

00102671 <vector222>:
.globl vector222
vector222:
  pushl $0
  102671:	6a 00                	push   $0x0
  pushl $222
  102673:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102678:	e9 8c 01 00 00       	jmp    102809 <__alltraps>

0010267d <vector223>:
.globl vector223
vector223:
  pushl $0
  10267d:	6a 00                	push   $0x0
  pushl $223
  10267f:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102684:	e9 80 01 00 00       	jmp    102809 <__alltraps>

00102689 <vector224>:
.globl vector224
vector224:
  pushl $0
  102689:	6a 00                	push   $0x0
  pushl $224
  10268b:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102690:	e9 74 01 00 00       	jmp    102809 <__alltraps>

00102695 <vector225>:
.globl vector225
vector225:
  pushl $0
  102695:	6a 00                	push   $0x0
  pushl $225
  102697:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10269c:	e9 68 01 00 00       	jmp    102809 <__alltraps>

001026a1 <vector226>:
.globl vector226
vector226:
  pushl $0
  1026a1:	6a 00                	push   $0x0
  pushl $226
  1026a3:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1026a8:	e9 5c 01 00 00       	jmp    102809 <__alltraps>

001026ad <vector227>:
.globl vector227
vector227:
  pushl $0
  1026ad:	6a 00                	push   $0x0
  pushl $227
  1026af:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1026b4:	e9 50 01 00 00       	jmp    102809 <__alltraps>

001026b9 <vector228>:
.globl vector228
vector228:
  pushl $0
  1026b9:	6a 00                	push   $0x0
  pushl $228
  1026bb:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1026c0:	e9 44 01 00 00       	jmp    102809 <__alltraps>

001026c5 <vector229>:
.globl vector229
vector229:
  pushl $0
  1026c5:	6a 00                	push   $0x0
  pushl $229
  1026c7:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1026cc:	e9 38 01 00 00       	jmp    102809 <__alltraps>

001026d1 <vector230>:
.globl vector230
vector230:
  pushl $0
  1026d1:	6a 00                	push   $0x0
  pushl $230
  1026d3:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1026d8:	e9 2c 01 00 00       	jmp    102809 <__alltraps>

001026dd <vector231>:
.globl vector231
vector231:
  pushl $0
  1026dd:	6a 00                	push   $0x0
  pushl $231
  1026df:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1026e4:	e9 20 01 00 00       	jmp    102809 <__alltraps>

001026e9 <vector232>:
.globl vector232
vector232:
  pushl $0
  1026e9:	6a 00                	push   $0x0
  pushl $232
  1026eb:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1026f0:	e9 14 01 00 00       	jmp    102809 <__alltraps>

001026f5 <vector233>:
.globl vector233
vector233:
  pushl $0
  1026f5:	6a 00                	push   $0x0
  pushl $233
  1026f7:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1026fc:	e9 08 01 00 00       	jmp    102809 <__alltraps>

00102701 <vector234>:
.globl vector234
vector234:
  pushl $0
  102701:	6a 00                	push   $0x0
  pushl $234
  102703:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102708:	e9 fc 00 00 00       	jmp    102809 <__alltraps>

0010270d <vector235>:
.globl vector235
vector235:
  pushl $0
  10270d:	6a 00                	push   $0x0
  pushl $235
  10270f:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102714:	e9 f0 00 00 00       	jmp    102809 <__alltraps>

00102719 <vector236>:
.globl vector236
vector236:
  pushl $0
  102719:	6a 00                	push   $0x0
  pushl $236
  10271b:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102720:	e9 e4 00 00 00       	jmp    102809 <__alltraps>

00102725 <vector237>:
.globl vector237
vector237:
  pushl $0
  102725:	6a 00                	push   $0x0
  pushl $237
  102727:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10272c:	e9 d8 00 00 00       	jmp    102809 <__alltraps>

00102731 <vector238>:
.globl vector238
vector238:
  pushl $0
  102731:	6a 00                	push   $0x0
  pushl $238
  102733:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102738:	e9 cc 00 00 00       	jmp    102809 <__alltraps>

0010273d <vector239>:
.globl vector239
vector239:
  pushl $0
  10273d:	6a 00                	push   $0x0
  pushl $239
  10273f:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102744:	e9 c0 00 00 00       	jmp    102809 <__alltraps>

00102749 <vector240>:
.globl vector240
vector240:
  pushl $0
  102749:	6a 00                	push   $0x0
  pushl $240
  10274b:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102750:	e9 b4 00 00 00       	jmp    102809 <__alltraps>

00102755 <vector241>:
.globl vector241
vector241:
  pushl $0
  102755:	6a 00                	push   $0x0
  pushl $241
  102757:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10275c:	e9 a8 00 00 00       	jmp    102809 <__alltraps>

00102761 <vector242>:
.globl vector242
vector242:
  pushl $0
  102761:	6a 00                	push   $0x0
  pushl $242
  102763:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102768:	e9 9c 00 00 00       	jmp    102809 <__alltraps>

0010276d <vector243>:
.globl vector243
vector243:
  pushl $0
  10276d:	6a 00                	push   $0x0
  pushl $243
  10276f:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102774:	e9 90 00 00 00       	jmp    102809 <__alltraps>

00102779 <vector244>:
.globl vector244
vector244:
  pushl $0
  102779:	6a 00                	push   $0x0
  pushl $244
  10277b:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102780:	e9 84 00 00 00       	jmp    102809 <__alltraps>

00102785 <vector245>:
.globl vector245
vector245:
  pushl $0
  102785:	6a 00                	push   $0x0
  pushl $245
  102787:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  10278c:	e9 78 00 00 00       	jmp    102809 <__alltraps>

00102791 <vector246>:
.globl vector246
vector246:
  pushl $0
  102791:	6a 00                	push   $0x0
  pushl $246
  102793:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102798:	e9 6c 00 00 00       	jmp    102809 <__alltraps>

0010279d <vector247>:
.globl vector247
vector247:
  pushl $0
  10279d:	6a 00                	push   $0x0
  pushl $247
  10279f:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1027a4:	e9 60 00 00 00       	jmp    102809 <__alltraps>

001027a9 <vector248>:
.globl vector248
vector248:
  pushl $0
  1027a9:	6a 00                	push   $0x0
  pushl $248
  1027ab:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1027b0:	e9 54 00 00 00       	jmp    102809 <__alltraps>

001027b5 <vector249>:
.globl vector249
vector249:
  pushl $0
  1027b5:	6a 00                	push   $0x0
  pushl $249
  1027b7:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1027bc:	e9 48 00 00 00       	jmp    102809 <__alltraps>

001027c1 <vector250>:
.globl vector250
vector250:
  pushl $0
  1027c1:	6a 00                	push   $0x0
  pushl $250
  1027c3:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1027c8:	e9 3c 00 00 00       	jmp    102809 <__alltraps>

001027cd <vector251>:
.globl vector251
vector251:
  pushl $0
  1027cd:	6a 00                	push   $0x0
  pushl $251
  1027cf:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1027d4:	e9 30 00 00 00       	jmp    102809 <__alltraps>

001027d9 <vector252>:
.globl vector252
vector252:
  pushl $0
  1027d9:	6a 00                	push   $0x0
  pushl $252
  1027db:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1027e0:	e9 24 00 00 00       	jmp    102809 <__alltraps>

001027e5 <vector253>:
.globl vector253
vector253:
  pushl $0
  1027e5:	6a 00                	push   $0x0
  pushl $253
  1027e7:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1027ec:	e9 18 00 00 00       	jmp    102809 <__alltraps>

001027f1 <vector254>:
.globl vector254
vector254:
  pushl $0
  1027f1:	6a 00                	push   $0x0
  pushl $254
  1027f3:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1027f8:	e9 0c 00 00 00       	jmp    102809 <__alltraps>

001027fd <vector255>:
.globl vector255
vector255:
  pushl $0
  1027fd:	6a 00                	push   $0x0
  pushl $255
  1027ff:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102804:	e9 00 00 00 00       	jmp    102809 <__alltraps>

00102809 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102809:	1e                   	push   %ds
    pushl %es
  10280a:	06                   	push   %es
    pushl %fs
  10280b:	0f a0                	push   %fs
    pushl %gs
  10280d:	0f a8                	push   %gs
    pushal
  10280f:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102810:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102815:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102817:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102819:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  10281a:	e8 64 f5 ff ff       	call   101d83 <trap>

    # pop the pushed stack pointer
    popl %esp
  10281f:	5c                   	pop    %esp

00102820 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102820:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102821:	0f a9                	pop    %gs
    popl %fs
  102823:	0f a1                	pop    %fs
    popl %es
  102825:	07                   	pop    %es
    popl %ds
  102826:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102827:	83 c4 08             	add    $0x8,%esp
    iret
  10282a:	cf                   	iret   

0010282b <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  10282b:	55                   	push   %ebp
  10282c:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10282e:	8b 45 08             	mov    0x8(%ebp),%eax
  102831:	8b 15 18 df 11 00    	mov    0x11df18,%edx
  102837:	29 d0                	sub    %edx,%eax
  102839:	c1 f8 02             	sar    $0x2,%eax
  10283c:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102842:	5d                   	pop    %ebp
  102843:	c3                   	ret    

00102844 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102844:	55                   	push   %ebp
  102845:	89 e5                	mov    %esp,%ebp
  102847:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  10284a:	8b 45 08             	mov    0x8(%ebp),%eax
  10284d:	89 04 24             	mov    %eax,(%esp)
  102850:	e8 d6 ff ff ff       	call   10282b <page2ppn>
  102855:	c1 e0 0c             	shl    $0xc,%eax
}
  102858:	c9                   	leave  
  102859:	c3                   	ret    

0010285a <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  10285a:	55                   	push   %ebp
  10285b:	89 e5                	mov    %esp,%ebp
  10285d:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  102860:	8b 45 08             	mov    0x8(%ebp),%eax
  102863:	c1 e8 0c             	shr    $0xc,%eax
  102866:	89 c2                	mov    %eax,%edx
  102868:	a1 80 de 11 00       	mov    0x11de80,%eax
  10286d:	39 c2                	cmp    %eax,%edx
  10286f:	72 1c                	jb     10288d <pa2page+0x33>
        panic("pa2page called with invalid pa");
  102871:	c7 44 24 08 70 75 10 	movl   $0x107570,0x8(%esp)
  102878:	00 
  102879:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  102880:	00 
  102881:	c7 04 24 8f 75 10 00 	movl   $0x10758f,(%esp)
  102888:	e8 5c db ff ff       	call   1003e9 <__panic>
    }
    return &pages[PPN(pa)];
  10288d:	8b 0d 18 df 11 00    	mov    0x11df18,%ecx
  102893:	8b 45 08             	mov    0x8(%ebp),%eax
  102896:	c1 e8 0c             	shr    $0xc,%eax
  102899:	89 c2                	mov    %eax,%edx
  10289b:	89 d0                	mov    %edx,%eax
  10289d:	c1 e0 02             	shl    $0x2,%eax
  1028a0:	01 d0                	add    %edx,%eax
  1028a2:	c1 e0 02             	shl    $0x2,%eax
  1028a5:	01 c8                	add    %ecx,%eax
}
  1028a7:	c9                   	leave  
  1028a8:	c3                   	ret    

001028a9 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  1028a9:	55                   	push   %ebp
  1028aa:	89 e5                	mov    %esp,%ebp
  1028ac:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  1028af:	8b 45 08             	mov    0x8(%ebp),%eax
  1028b2:	89 04 24             	mov    %eax,(%esp)
  1028b5:	e8 8a ff ff ff       	call   102844 <page2pa>
  1028ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1028bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028c0:	c1 e8 0c             	shr    $0xc,%eax
  1028c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1028c6:	a1 80 de 11 00       	mov    0x11de80,%eax
  1028cb:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  1028ce:	72 23                	jb     1028f3 <page2kva+0x4a>
  1028d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1028d7:	c7 44 24 08 a0 75 10 	movl   $0x1075a0,0x8(%esp)
  1028de:	00 
  1028df:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  1028e6:	00 
  1028e7:	c7 04 24 8f 75 10 00 	movl   $0x10758f,(%esp)
  1028ee:	e8 f6 da ff ff       	call   1003e9 <__panic>
  1028f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028f6:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  1028fb:	c9                   	leave  
  1028fc:	c3                   	ret    

001028fd <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  1028fd:	55                   	push   %ebp
  1028fe:	89 e5                	mov    %esp,%ebp
  102900:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  102903:	8b 45 08             	mov    0x8(%ebp),%eax
  102906:	83 e0 01             	and    $0x1,%eax
  102909:	85 c0                	test   %eax,%eax
  10290b:	75 1c                	jne    102929 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  10290d:	c7 44 24 08 c4 75 10 	movl   $0x1075c4,0x8(%esp)
  102914:	00 
  102915:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  10291c:	00 
  10291d:	c7 04 24 8f 75 10 00 	movl   $0x10758f,(%esp)
  102924:	e8 c0 da ff ff       	call   1003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  102929:	8b 45 08             	mov    0x8(%ebp),%eax
  10292c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102931:	89 04 24             	mov    %eax,(%esp)
  102934:	e8 21 ff ff ff       	call   10285a <pa2page>
}
  102939:	c9                   	leave  
  10293a:	c3                   	ret    

0010293b <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  10293b:	55                   	push   %ebp
  10293c:	89 e5                	mov    %esp,%ebp
  10293e:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  102941:	8b 45 08             	mov    0x8(%ebp),%eax
  102944:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102949:	89 04 24             	mov    %eax,(%esp)
  10294c:	e8 09 ff ff ff       	call   10285a <pa2page>
}
  102951:	c9                   	leave  
  102952:	c3                   	ret    

00102953 <page_ref>:

static inline int
page_ref(struct Page *page) {
  102953:	55                   	push   %ebp
  102954:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102956:	8b 45 08             	mov    0x8(%ebp),%eax
  102959:	8b 00                	mov    (%eax),%eax
}
  10295b:	5d                   	pop    %ebp
  10295c:	c3                   	ret    

0010295d <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  10295d:	55                   	push   %ebp
  10295e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102960:	8b 45 08             	mov    0x8(%ebp),%eax
  102963:	8b 55 0c             	mov    0xc(%ebp),%edx
  102966:	89 10                	mov    %edx,(%eax)
}
  102968:	90                   	nop
  102969:	5d                   	pop    %ebp
  10296a:	c3                   	ret    

0010296b <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  10296b:	55                   	push   %ebp
  10296c:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  10296e:	8b 45 08             	mov    0x8(%ebp),%eax
  102971:	8b 00                	mov    (%eax),%eax
  102973:	8d 50 01             	lea    0x1(%eax),%edx
  102976:	8b 45 08             	mov    0x8(%ebp),%eax
  102979:	89 10                	mov    %edx,(%eax)
    return page->ref;
  10297b:	8b 45 08             	mov    0x8(%ebp),%eax
  10297e:	8b 00                	mov    (%eax),%eax
}
  102980:	5d                   	pop    %ebp
  102981:	c3                   	ret    

00102982 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  102982:	55                   	push   %ebp
  102983:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  102985:	8b 45 08             	mov    0x8(%ebp),%eax
  102988:	8b 00                	mov    (%eax),%eax
  10298a:	8d 50 ff             	lea    -0x1(%eax),%edx
  10298d:	8b 45 08             	mov    0x8(%ebp),%eax
  102990:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102992:	8b 45 08             	mov    0x8(%ebp),%eax
  102995:	8b 00                	mov    (%eax),%eax
}
  102997:	5d                   	pop    %ebp
  102998:	c3                   	ret    

00102999 <__intr_save>:
__intr_save(void) {
  102999:	55                   	push   %ebp
  10299a:	89 e5                	mov    %esp,%ebp
  10299c:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  10299f:	9c                   	pushf  
  1029a0:	58                   	pop    %eax
  1029a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  1029a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  1029a7:	25 00 02 00 00       	and    $0x200,%eax
  1029ac:	85 c0                	test   %eax,%eax
  1029ae:	74 0c                	je     1029bc <__intr_save+0x23>
        intr_disable();
  1029b0:	e8 d8 ee ff ff       	call   10188d <intr_disable>
        return 1;
  1029b5:	b8 01 00 00 00       	mov    $0x1,%eax
  1029ba:	eb 05                	jmp    1029c1 <__intr_save+0x28>
    return 0;
  1029bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1029c1:	c9                   	leave  
  1029c2:	c3                   	ret    

001029c3 <__intr_restore>:
__intr_restore(bool flag) {
  1029c3:	55                   	push   %ebp
  1029c4:	89 e5                	mov    %esp,%ebp
  1029c6:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  1029c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1029cd:	74 05                	je     1029d4 <__intr_restore+0x11>
        intr_enable();
  1029cf:	e8 b2 ee ff ff       	call   101886 <intr_enable>
}
  1029d4:	90                   	nop
  1029d5:	c9                   	leave  
  1029d6:	c3                   	ret    

001029d7 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  1029d7:	55                   	push   %ebp
  1029d8:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  1029da:	8b 45 08             	mov    0x8(%ebp),%eax
  1029dd:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  1029e0:	b8 23 00 00 00       	mov    $0x23,%eax
  1029e5:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  1029e7:	b8 23 00 00 00       	mov    $0x23,%eax
  1029ec:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  1029ee:	b8 10 00 00 00       	mov    $0x10,%eax
  1029f3:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  1029f5:	b8 10 00 00 00       	mov    $0x10,%eax
  1029fa:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  1029fc:	b8 10 00 00 00       	mov    $0x10,%eax
  102a01:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102a03:	ea 0a 2a 10 00 08 00 	ljmp   $0x8,$0x102a0a
}
  102a0a:	90                   	nop
  102a0b:	5d                   	pop    %ebp
  102a0c:	c3                   	ret    

00102a0d <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102a0d:	55                   	push   %ebp
  102a0e:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102a10:	8b 45 08             	mov    0x8(%ebp),%eax
  102a13:	a3 a4 de 11 00       	mov    %eax,0x11dea4
}
  102a18:	90                   	nop
  102a19:	5d                   	pop    %ebp
  102a1a:	c3                   	ret    

00102a1b <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102a1b:	55                   	push   %ebp
  102a1c:	89 e5                	mov    %esp,%ebp
  102a1e:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102a21:	b8 00 a0 11 00       	mov    $0x11a000,%eax
  102a26:	89 04 24             	mov    %eax,(%esp)
  102a29:	e8 df ff ff ff       	call   102a0d <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102a2e:	66 c7 05 a8 de 11 00 	movw   $0x10,0x11dea8
  102a35:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102a37:	66 c7 05 28 aa 11 00 	movw   $0x68,0x11aa28
  102a3e:	68 00 
  102a40:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102a45:	0f b7 c0             	movzwl %ax,%eax
  102a48:	66 a3 2a aa 11 00    	mov    %ax,0x11aa2a
  102a4e:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102a53:	c1 e8 10             	shr    $0x10,%eax
  102a56:	a2 2c aa 11 00       	mov    %al,0x11aa2c
  102a5b:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102a62:	24 f0                	and    $0xf0,%al
  102a64:	0c 09                	or     $0x9,%al
  102a66:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102a6b:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102a72:	24 ef                	and    $0xef,%al
  102a74:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102a79:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102a80:	24 9f                	and    $0x9f,%al
  102a82:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102a87:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102a8e:	0c 80                	or     $0x80,%al
  102a90:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102a95:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102a9c:	24 f0                	and    $0xf0,%al
  102a9e:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102aa3:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102aaa:	24 ef                	and    $0xef,%al
  102aac:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102ab1:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102ab8:	24 df                	and    $0xdf,%al
  102aba:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102abf:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102ac6:	0c 40                	or     $0x40,%al
  102ac8:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102acd:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102ad4:	24 7f                	and    $0x7f,%al
  102ad6:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102adb:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102ae0:	c1 e8 18             	shr    $0x18,%eax
  102ae3:	a2 2f aa 11 00       	mov    %al,0x11aa2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102ae8:	c7 04 24 30 aa 11 00 	movl   $0x11aa30,(%esp)
  102aef:	e8 e3 fe ff ff       	call   1029d7 <lgdt>
  102af4:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102afa:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102afe:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102b01:	90                   	nop
  102b02:	c9                   	leave  
  102b03:	c3                   	ret    

00102b04 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102b04:	55                   	push   %ebp
  102b05:	89 e5                	mov    %esp,%ebp
  102b07:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102b0a:	c7 05 10 df 11 00 80 	movl   $0x107f80,0x11df10
  102b11:	7f 10 00 
    //pmm_manager = &buddy_system;
    cprintf("memory management: %s\n", pmm_manager->name);
  102b14:	a1 10 df 11 00       	mov    0x11df10,%eax
  102b19:	8b 00                	mov    (%eax),%eax
  102b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b1f:	c7 04 24 f0 75 10 00 	movl   $0x1075f0,(%esp)
  102b26:	e8 67 d7 ff ff       	call   100292 <cprintf>
    pmm_manager->init();
  102b2b:	a1 10 df 11 00       	mov    0x11df10,%eax
  102b30:	8b 40 04             	mov    0x4(%eax),%eax
  102b33:	ff d0                	call   *%eax
}
  102b35:	90                   	nop
  102b36:	c9                   	leave  
  102b37:	c3                   	ret    

00102b38 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102b38:	55                   	push   %ebp
  102b39:	89 e5                	mov    %esp,%ebp
  102b3b:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102b3e:	a1 10 df 11 00       	mov    0x11df10,%eax
  102b43:	8b 40 08             	mov    0x8(%eax),%eax
  102b46:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b49:	89 54 24 04          	mov    %edx,0x4(%esp)
  102b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  102b50:	89 14 24             	mov    %edx,(%esp)
  102b53:	ff d0                	call   *%eax
}
  102b55:	90                   	nop
  102b56:	c9                   	leave  
  102b57:	c3                   	ret    

00102b58 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102b58:	55                   	push   %ebp
  102b59:	89 e5                	mov    %esp,%ebp
  102b5b:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102b5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102b65:	e8 2f fe ff ff       	call   102999 <__intr_save>
  102b6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102b6d:	a1 10 df 11 00       	mov    0x11df10,%eax
  102b72:	8b 40 0c             	mov    0xc(%eax),%eax
  102b75:	8b 55 08             	mov    0x8(%ebp),%edx
  102b78:	89 14 24             	mov    %edx,(%esp)
  102b7b:	ff d0                	call   *%eax
  102b7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b83:	89 04 24             	mov    %eax,(%esp)
  102b86:	e8 38 fe ff ff       	call   1029c3 <__intr_restore>
    return page;
  102b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102b8e:	c9                   	leave  
  102b8f:	c3                   	ret    

00102b90 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102b90:	55                   	push   %ebp
  102b91:	89 e5                	mov    %esp,%ebp
  102b93:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102b96:	e8 fe fd ff ff       	call   102999 <__intr_save>
  102b9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102b9e:	a1 10 df 11 00       	mov    0x11df10,%eax
  102ba3:	8b 40 10             	mov    0x10(%eax),%eax
  102ba6:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ba9:	89 54 24 04          	mov    %edx,0x4(%esp)
  102bad:	8b 55 08             	mov    0x8(%ebp),%edx
  102bb0:	89 14 24             	mov    %edx,(%esp)
  102bb3:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bb8:	89 04 24             	mov    %eax,(%esp)
  102bbb:	e8 03 fe ff ff       	call   1029c3 <__intr_restore>
}
  102bc0:	90                   	nop
  102bc1:	c9                   	leave  
  102bc2:	c3                   	ret    

00102bc3 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102bc3:	55                   	push   %ebp
  102bc4:	89 e5                	mov    %esp,%ebp
  102bc6:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102bc9:	e8 cb fd ff ff       	call   102999 <__intr_save>
  102bce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102bd1:	a1 10 df 11 00       	mov    0x11df10,%eax
  102bd6:	8b 40 14             	mov    0x14(%eax),%eax
  102bd9:	ff d0                	call   *%eax
  102bdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102be1:	89 04 24             	mov    %eax,(%esp)
  102be4:	e8 da fd ff ff       	call   1029c3 <__intr_restore>
    return ret;
  102be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102bec:	c9                   	leave  
  102bed:	c3                   	ret    

00102bee <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102bee:	55                   	push   %ebp
  102bef:	89 e5                	mov    %esp,%ebp
  102bf1:	57                   	push   %edi
  102bf2:	56                   	push   %esi
  102bf3:	53                   	push   %ebx
  102bf4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102bfa:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102c01:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102c08:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102c0f:	c7 04 24 07 76 10 00 	movl   $0x107607,(%esp)
  102c16:	e8 77 d6 ff ff       	call   100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102c1b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102c22:	e9 22 01 00 00       	jmp    102d49 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102c27:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c2a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c2d:	89 d0                	mov    %edx,%eax
  102c2f:	c1 e0 02             	shl    $0x2,%eax
  102c32:	01 d0                	add    %edx,%eax
  102c34:	c1 e0 02             	shl    $0x2,%eax
  102c37:	01 c8                	add    %ecx,%eax
  102c39:	8b 50 08             	mov    0x8(%eax),%edx
  102c3c:	8b 40 04             	mov    0x4(%eax),%eax
  102c3f:	89 45 a0             	mov    %eax,-0x60(%ebp)
  102c42:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102c45:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c48:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c4b:	89 d0                	mov    %edx,%eax
  102c4d:	c1 e0 02             	shl    $0x2,%eax
  102c50:	01 d0                	add    %edx,%eax
  102c52:	c1 e0 02             	shl    $0x2,%eax
  102c55:	01 c8                	add    %ecx,%eax
  102c57:	8b 48 0c             	mov    0xc(%eax),%ecx
  102c5a:	8b 58 10             	mov    0x10(%eax),%ebx
  102c5d:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102c60:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102c63:	01 c8                	add    %ecx,%eax
  102c65:	11 da                	adc    %ebx,%edx
  102c67:	89 45 98             	mov    %eax,-0x68(%ebp)
  102c6a:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102c6d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c70:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c73:	89 d0                	mov    %edx,%eax
  102c75:	c1 e0 02             	shl    $0x2,%eax
  102c78:	01 d0                	add    %edx,%eax
  102c7a:	c1 e0 02             	shl    $0x2,%eax
  102c7d:	01 c8                	add    %ecx,%eax
  102c7f:	83 c0 14             	add    $0x14,%eax
  102c82:	8b 00                	mov    (%eax),%eax
  102c84:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102c87:	8b 45 98             	mov    -0x68(%ebp),%eax
  102c8a:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102c8d:	83 c0 ff             	add    $0xffffffff,%eax
  102c90:	83 d2 ff             	adc    $0xffffffff,%edx
  102c93:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102c99:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102c9f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ca2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ca5:	89 d0                	mov    %edx,%eax
  102ca7:	c1 e0 02             	shl    $0x2,%eax
  102caa:	01 d0                	add    %edx,%eax
  102cac:	c1 e0 02             	shl    $0x2,%eax
  102caf:	01 c8                	add    %ecx,%eax
  102cb1:	8b 48 0c             	mov    0xc(%eax),%ecx
  102cb4:	8b 58 10             	mov    0x10(%eax),%ebx
  102cb7:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102cba:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102cbe:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102cc4:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102cca:	89 44 24 14          	mov    %eax,0x14(%esp)
  102cce:	89 54 24 18          	mov    %edx,0x18(%esp)
  102cd2:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102cd5:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102cd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102cdc:	89 54 24 10          	mov    %edx,0x10(%esp)
  102ce0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102ce4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102ce8:	c7 04 24 14 76 10 00 	movl   $0x107614,(%esp)
  102cef:	e8 9e d5 ff ff       	call   100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102cf4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cf7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cfa:	89 d0                	mov    %edx,%eax
  102cfc:	c1 e0 02             	shl    $0x2,%eax
  102cff:	01 d0                	add    %edx,%eax
  102d01:	c1 e0 02             	shl    $0x2,%eax
  102d04:	01 c8                	add    %ecx,%eax
  102d06:	83 c0 14             	add    $0x14,%eax
  102d09:	8b 00                	mov    (%eax),%eax
  102d0b:	83 f8 01             	cmp    $0x1,%eax
  102d0e:	75 36                	jne    102d46 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
  102d10:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d13:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d16:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102d19:	77 2b                	ja     102d46 <page_init+0x158>
  102d1b:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102d1e:	72 05                	jb     102d25 <page_init+0x137>
  102d20:	3b 45 98             	cmp    -0x68(%ebp),%eax
  102d23:	73 21                	jae    102d46 <page_init+0x158>
  102d25:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102d29:	77 1b                	ja     102d46 <page_init+0x158>
  102d2b:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102d2f:	72 09                	jb     102d3a <page_init+0x14c>
  102d31:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
  102d38:	77 0c                	ja     102d46 <page_init+0x158>
                maxpa = end;
  102d3a:	8b 45 98             	mov    -0x68(%ebp),%eax
  102d3d:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102d40:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102d43:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102d46:	ff 45 dc             	incl   -0x24(%ebp)
  102d49:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102d4c:	8b 00                	mov    (%eax),%eax
  102d4e:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102d51:	0f 8c d0 fe ff ff    	jl     102c27 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102d57:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102d5b:	72 1d                	jb     102d7a <page_init+0x18c>
  102d5d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102d61:	77 09                	ja     102d6c <page_init+0x17e>
  102d63:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102d6a:	76 0e                	jbe    102d7a <page_init+0x18c>
        maxpa = KMEMSIZE;
  102d6c:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102d73:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102d7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d7d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d80:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102d84:	c1 ea 0c             	shr    $0xc,%edx
  102d87:	89 c1                	mov    %eax,%ecx
  102d89:	89 d3                	mov    %edx,%ebx
  102d8b:	89 c8                	mov    %ecx,%eax
  102d8d:	a3 80 de 11 00       	mov    %eax,0x11de80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102d92:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  102d99:	b8 bc df 11 00       	mov    $0x11dfbc,%eax
  102d9e:	8d 50 ff             	lea    -0x1(%eax),%edx
  102da1:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102da4:	01 d0                	add    %edx,%eax
  102da6:	89 45 bc             	mov    %eax,-0x44(%ebp)
  102da9:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102dac:	ba 00 00 00 00       	mov    $0x0,%edx
  102db1:	f7 75 c0             	divl   -0x40(%ebp)
  102db4:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102db7:	29 d0                	sub    %edx,%eax
  102db9:	a3 18 df 11 00       	mov    %eax,0x11df18

    for (i = 0; i < npage; i ++) {
  102dbe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102dc5:	eb 2e                	jmp    102df5 <page_init+0x207>
        SetPageReserved(pages + i);
  102dc7:	8b 0d 18 df 11 00    	mov    0x11df18,%ecx
  102dcd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102dd0:	89 d0                	mov    %edx,%eax
  102dd2:	c1 e0 02             	shl    $0x2,%eax
  102dd5:	01 d0                	add    %edx,%eax
  102dd7:	c1 e0 02             	shl    $0x2,%eax
  102dda:	01 c8                	add    %ecx,%eax
  102ddc:	83 c0 04             	add    $0x4,%eax
  102ddf:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  102de6:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102de9:	8b 45 90             	mov    -0x70(%ebp),%eax
  102dec:	8b 55 94             	mov    -0x6c(%ebp),%edx
  102def:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
  102df2:	ff 45 dc             	incl   -0x24(%ebp)
  102df5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102df8:	a1 80 de 11 00       	mov    0x11de80,%eax
  102dfd:	39 c2                	cmp    %eax,%edx
  102dff:	72 c6                	jb     102dc7 <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102e01:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  102e07:	89 d0                	mov    %edx,%eax
  102e09:	c1 e0 02             	shl    $0x2,%eax
  102e0c:	01 d0                	add    %edx,%eax
  102e0e:	c1 e0 02             	shl    $0x2,%eax
  102e11:	89 c2                	mov    %eax,%edx
  102e13:	a1 18 df 11 00       	mov    0x11df18,%eax
  102e18:	01 d0                	add    %edx,%eax
  102e1a:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102e1d:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  102e24:	77 23                	ja     102e49 <page_init+0x25b>
  102e26:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102e29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102e2d:	c7 44 24 08 44 76 10 	movl   $0x107644,0x8(%esp)
  102e34:	00 
  102e35:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
  102e3c:	00 
  102e3d:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  102e44:	e8 a0 d5 ff ff       	call   1003e9 <__panic>
  102e49:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102e4c:	05 00 00 00 40       	add    $0x40000000,%eax
  102e51:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  102e54:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e5b:	e9 69 01 00 00       	jmp    102fc9 <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102e60:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e63:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e66:	89 d0                	mov    %edx,%eax
  102e68:	c1 e0 02             	shl    $0x2,%eax
  102e6b:	01 d0                	add    %edx,%eax
  102e6d:	c1 e0 02             	shl    $0x2,%eax
  102e70:	01 c8                	add    %ecx,%eax
  102e72:	8b 50 08             	mov    0x8(%eax),%edx
  102e75:	8b 40 04             	mov    0x4(%eax),%eax
  102e78:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102e7b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102e7e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e81:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e84:	89 d0                	mov    %edx,%eax
  102e86:	c1 e0 02             	shl    $0x2,%eax
  102e89:	01 d0                	add    %edx,%eax
  102e8b:	c1 e0 02             	shl    $0x2,%eax
  102e8e:	01 c8                	add    %ecx,%eax
  102e90:	8b 48 0c             	mov    0xc(%eax),%ecx
  102e93:	8b 58 10             	mov    0x10(%eax),%ebx
  102e96:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102e99:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102e9c:	01 c8                	add    %ecx,%eax
  102e9e:	11 da                	adc    %ebx,%edx
  102ea0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102ea3:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  102ea6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ea9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102eac:	89 d0                	mov    %edx,%eax
  102eae:	c1 e0 02             	shl    $0x2,%eax
  102eb1:	01 d0                	add    %edx,%eax
  102eb3:	c1 e0 02             	shl    $0x2,%eax
  102eb6:	01 c8                	add    %ecx,%eax
  102eb8:	83 c0 14             	add    $0x14,%eax
  102ebb:	8b 00                	mov    (%eax),%eax
  102ebd:	83 f8 01             	cmp    $0x1,%eax
  102ec0:	0f 85 00 01 00 00    	jne    102fc6 <page_init+0x3d8>
            if (begin < freemem) {
  102ec6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102ec9:	ba 00 00 00 00       	mov    $0x0,%edx
  102ece:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102ed1:	77 17                	ja     102eea <page_init+0x2fc>
  102ed3:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102ed6:	72 05                	jb     102edd <page_init+0x2ef>
  102ed8:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  102edb:	73 0d                	jae    102eea <page_init+0x2fc>
                begin = freemem;
  102edd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102ee0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ee3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  102eea:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102eee:	72 1d                	jb     102f0d <page_init+0x31f>
  102ef0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102ef4:	77 09                	ja     102eff <page_init+0x311>
  102ef6:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  102efd:	76 0e                	jbe    102f0d <page_init+0x31f>
                end = KMEMSIZE;
  102eff:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  102f06:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  102f0d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f10:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f13:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f16:	0f 87 aa 00 00 00    	ja     102fc6 <page_init+0x3d8>
  102f1c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f1f:	72 09                	jb     102f2a <page_init+0x33c>
  102f21:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102f24:	0f 83 9c 00 00 00    	jae    102fc6 <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
  102f2a:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  102f31:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102f34:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102f37:	01 d0                	add    %edx,%eax
  102f39:	48                   	dec    %eax
  102f3a:	89 45 ac             	mov    %eax,-0x54(%ebp)
  102f3d:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102f40:	ba 00 00 00 00       	mov    $0x0,%edx
  102f45:	f7 75 b0             	divl   -0x50(%ebp)
  102f48:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102f4b:	29 d0                	sub    %edx,%eax
  102f4d:	ba 00 00 00 00       	mov    $0x0,%edx
  102f52:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f55:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  102f58:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102f5b:	89 45 a8             	mov    %eax,-0x58(%ebp)
  102f5e:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102f61:	ba 00 00 00 00       	mov    $0x0,%edx
  102f66:	89 c3                	mov    %eax,%ebx
  102f68:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  102f6e:	89 de                	mov    %ebx,%esi
  102f70:	89 d0                	mov    %edx,%eax
  102f72:	83 e0 00             	and    $0x0,%eax
  102f75:	89 c7                	mov    %eax,%edi
  102f77:	89 75 c8             	mov    %esi,-0x38(%ebp)
  102f7a:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  102f7d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f80:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f83:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f86:	77 3e                	ja     102fc6 <page_init+0x3d8>
  102f88:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f8b:	72 05                	jb     102f92 <page_init+0x3a4>
  102f8d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102f90:	73 34                	jae    102fc6 <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  102f92:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102f95:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102f98:	2b 45 d0             	sub    -0x30(%ebp),%eax
  102f9b:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  102f9e:	89 c1                	mov    %eax,%ecx
  102fa0:	89 d3                	mov    %edx,%ebx
  102fa2:	89 c8                	mov    %ecx,%eax
  102fa4:	89 da                	mov    %ebx,%edx
  102fa6:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102faa:	c1 ea 0c             	shr    $0xc,%edx
  102fad:	89 c3                	mov    %eax,%ebx
  102faf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102fb2:	89 04 24             	mov    %eax,(%esp)
  102fb5:	e8 a0 f8 ff ff       	call   10285a <pa2page>
  102fba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102fbe:	89 04 24             	mov    %eax,(%esp)
  102fc1:	e8 72 fb ff ff       	call   102b38 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  102fc6:	ff 45 dc             	incl   -0x24(%ebp)
  102fc9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102fcc:	8b 00                	mov    (%eax),%eax
  102fce:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102fd1:	0f 8c 89 fe ff ff    	jl     102e60 <page_init+0x272>
                }
            }
        }
    }
}
  102fd7:	90                   	nop
  102fd8:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  102fde:	5b                   	pop    %ebx
  102fdf:	5e                   	pop    %esi
  102fe0:	5f                   	pop    %edi
  102fe1:	5d                   	pop    %ebp
  102fe2:	c3                   	ret    

00102fe3 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  102fe3:	55                   	push   %ebp
  102fe4:	89 e5                	mov    %esp,%ebp
  102fe6:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  102fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fec:	33 45 14             	xor    0x14(%ebp),%eax
  102fef:	25 ff 0f 00 00       	and    $0xfff,%eax
  102ff4:	85 c0                	test   %eax,%eax
  102ff6:	74 24                	je     10301c <boot_map_segment+0x39>
  102ff8:	c7 44 24 0c 76 76 10 	movl   $0x107676,0xc(%esp)
  102fff:	00 
  103000:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103007:	00 
  103008:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  10300f:	00 
  103010:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103017:	e8 cd d3 ff ff       	call   1003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  10301c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  103023:	8b 45 0c             	mov    0xc(%ebp),%eax
  103026:	25 ff 0f 00 00       	and    $0xfff,%eax
  10302b:	89 c2                	mov    %eax,%edx
  10302d:	8b 45 10             	mov    0x10(%ebp),%eax
  103030:	01 c2                	add    %eax,%edx
  103032:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103035:	01 d0                	add    %edx,%eax
  103037:	48                   	dec    %eax
  103038:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10303b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10303e:	ba 00 00 00 00       	mov    $0x0,%edx
  103043:	f7 75 f0             	divl   -0x10(%ebp)
  103046:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103049:	29 d0                	sub    %edx,%eax
  10304b:	c1 e8 0c             	shr    $0xc,%eax
  10304e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  103051:	8b 45 0c             	mov    0xc(%ebp),%eax
  103054:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103057:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10305a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10305f:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  103062:	8b 45 14             	mov    0x14(%ebp),%eax
  103065:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103068:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10306b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103070:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103073:	eb 68                	jmp    1030dd <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  103075:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10307c:	00 
  10307d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103080:	89 44 24 04          	mov    %eax,0x4(%esp)
  103084:	8b 45 08             	mov    0x8(%ebp),%eax
  103087:	89 04 24             	mov    %eax,(%esp)
  10308a:	e8 81 01 00 00       	call   103210 <get_pte>
  10308f:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  103092:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  103096:	75 24                	jne    1030bc <boot_map_segment+0xd9>
  103098:	c7 44 24 0c a2 76 10 	movl   $0x1076a2,0xc(%esp)
  10309f:	00 
  1030a0:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  1030a7:	00 
  1030a8:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  1030af:	00 
  1030b0:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  1030b7:	e8 2d d3 ff ff       	call   1003e9 <__panic>
        *ptep = pa | PTE_P | perm;
  1030bc:	8b 45 14             	mov    0x14(%ebp),%eax
  1030bf:	0b 45 18             	or     0x18(%ebp),%eax
  1030c2:	83 c8 01             	or     $0x1,%eax
  1030c5:	89 c2                	mov    %eax,%edx
  1030c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030ca:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1030cc:	ff 4d f4             	decl   -0xc(%ebp)
  1030cf:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1030d6:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1030dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1030e1:	75 92                	jne    103075 <boot_map_segment+0x92>
    }
}
  1030e3:	90                   	nop
  1030e4:	c9                   	leave  
  1030e5:	c3                   	ret    

001030e6 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1030e6:	55                   	push   %ebp
  1030e7:	89 e5                	mov    %esp,%ebp
  1030e9:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1030ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1030f3:	e8 60 fa ff ff       	call   102b58 <alloc_pages>
  1030f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1030fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1030ff:	75 1c                	jne    10311d <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  103101:	c7 44 24 08 af 76 10 	movl   $0x1076af,0x8(%esp)
  103108:	00 
  103109:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
  103110:	00 
  103111:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103118:	e8 cc d2 ff ff       	call   1003e9 <__panic>
    }
    return page2kva(p);
  10311d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103120:	89 04 24             	mov    %eax,(%esp)
  103123:	e8 81 f7 ff ff       	call   1028a9 <page2kva>
}
  103128:	c9                   	leave  
  103129:	c3                   	ret    

0010312a <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  10312a:	55                   	push   %ebp
  10312b:	89 e5                	mov    %esp,%ebp
  10312d:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  103130:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103135:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103138:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10313f:	77 23                	ja     103164 <pmm_init+0x3a>
  103141:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103144:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103148:	c7 44 24 08 44 76 10 	movl   $0x107644,0x8(%esp)
  10314f:	00 
  103150:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  103157:	00 
  103158:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  10315f:	e8 85 d2 ff ff       	call   1003e9 <__panic>
  103164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103167:	05 00 00 00 40       	add    $0x40000000,%eax
  10316c:	a3 14 df 11 00       	mov    %eax,0x11df14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  103171:	e8 8e f9 ff ff       	call   102b04 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  103176:	e8 73 fa ff ff       	call   102bee <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  10317b:	e8 de 03 00 00       	call   10355e <check_alloc_page>

    check_pgdir();
  103180:	e8 f8 03 00 00       	call   10357d <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  103185:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10318a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10318d:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103194:	77 23                	ja     1031b9 <pmm_init+0x8f>
  103196:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103199:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10319d:	c7 44 24 08 44 76 10 	movl   $0x107644,0x8(%esp)
  1031a4:	00 
  1031a5:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
  1031ac:	00 
  1031ad:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  1031b4:	e8 30 d2 ff ff       	call   1003e9 <__panic>
  1031b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031bc:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  1031c2:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1031c7:	05 ac 0f 00 00       	add    $0xfac,%eax
  1031cc:	83 ca 03             	or     $0x3,%edx
  1031cf:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1031d1:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1031d6:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1031dd:	00 
  1031de:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1031e5:	00 
  1031e6:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1031ed:	38 
  1031ee:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1031f5:	c0 
  1031f6:	89 04 24             	mov    %eax,(%esp)
  1031f9:	e8 e5 fd ff ff       	call   102fe3 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1031fe:	e8 18 f8 ff ff       	call   102a1b <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  103203:	e8 11 0a 00 00       	call   103c19 <check_boot_pgdir>

    print_pgdir();
  103208:	e8 8a 0e 00 00       	call   104097 <print_pgdir>

}
  10320d:	90                   	nop
  10320e:	c9                   	leave  
  10320f:	c3                   	ret    

00103210 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  103210:	55                   	push   %ebp
  103211:	89 e5                	mov    %esp,%ebp
  103213:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];                      // (1) find page directory entry
  103216:	8b 45 0c             	mov    0xc(%ebp),%eax
  103219:	c1 e8 16             	shr    $0x16,%eax
  10321c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103223:	8b 45 08             	mov    0x8(%ebp),%eax
  103226:	01 d0                	add    %edx,%eax
  103228:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)){                              // (2) check if entry is not present 
        struct Page *page;
  10322b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10322e:	8b 00                	mov    (%eax),%eax
  103230:	83 e0 01             	and    $0x1,%eax
  103233:	85 c0                	test   %eax,%eax
  103235:	0f 85 af 00 00 00    	jne    1032ea <get_pte+0xda>
        if (create){                                    // (3) check if creating is needed, then alloc page for page table
            if((page = alloc_page())==NULL)
                return NULL;
        }else
            return NULL;
  10323b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10323f:	74 15                	je     103256 <get_pte+0x46>
  103241:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103248:	e8 0b f9 ff ff       	call   102b58 <alloc_pages>
  10324d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103250:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103254:	75 0a                	jne    103260 <get_pte+0x50>
        set_page_ref(page, 1);                          // (4) set page reference
  103256:	b8 00 00 00 00       	mov    $0x0,%eax
  10325b:	e9 e7 00 00 00       	jmp    103347 <get_pte+0x137>
        uintptr_t addr = page2pa(page);                 // (5) get linear address of page
        memset(KADDR(addr), 0, PGSIZE);                  // (6) clear page content using memset
        *pdep = addr | PTE_U | PTE_W | PTE_P;             // (7) set page directory entry's permission
  103260:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103267:	00 
  103268:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10326b:	89 04 24             	mov    %eax,(%esp)
  10326e:	e8 ea f6 ff ff       	call   10295d <set_page_ref>
    }
  103273:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103276:	89 04 24             	mov    %eax,(%esp)
  103279:	e8 c6 f5 ff ff       	call   102844 <page2pa>
  10327e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];// (8) return page table entry
  103281:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103284:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103287:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10328a:	c1 e8 0c             	shr    $0xc,%eax
  10328d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103290:	a1 80 de 11 00       	mov    0x11de80,%eax
  103295:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103298:	72 23                	jb     1032bd <get_pte+0xad>
  10329a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10329d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1032a1:	c7 44 24 08 a0 75 10 	movl   $0x1075a0,0x8(%esp)
  1032a8:	00 
  1032a9:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
  1032b0:	00 
  1032b1:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  1032b8:	e8 2c d1 ff ff       	call   1003e9 <__panic>
  1032bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032c0:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1032c5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1032cc:	00 
  1032cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1032d4:	00 
  1032d5:	89 04 24             	mov    %eax,(%esp)
  1032d8:	e8 7e 33 00 00       	call   10665b <memset>
}
  1032dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032e0:	83 c8 07             	or     $0x7,%eax
  1032e3:	89 c2                	mov    %eax,%edx
  1032e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032e8:	89 10                	mov    %edx,(%eax)

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
  1032ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032ed:	8b 00                	mov    (%eax),%eax
  1032ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1032f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1032f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1032fa:	c1 e8 0c             	shr    $0xc,%eax
  1032fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103300:	a1 80 de 11 00       	mov    0x11de80,%eax
  103305:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103308:	72 23                	jb     10332d <get_pte+0x11d>
  10330a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10330d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103311:	c7 44 24 08 a0 75 10 	movl   $0x1075a0,0x8(%esp)
  103318:	00 
  103319:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
  103320:	00 
  103321:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103328:	e8 bc d0 ff ff       	call   1003e9 <__panic>
  10332d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103330:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103335:	89 c2                	mov    %eax,%edx
  103337:	8b 45 0c             	mov    0xc(%ebp),%eax
  10333a:	c1 e8 0c             	shr    $0xc,%eax
  10333d:	25 ff 03 00 00       	and    $0x3ff,%eax
  103342:	c1 e0 02             	shl    $0x2,%eax
  103345:	01 d0                	add    %edx,%eax
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
    pte_t *ptep = get_pte(pgdir, la, 0);
  103347:	c9                   	leave  
  103348:	c3                   	ret    

00103349 <get_page>:
    if (ptep_store != NULL) {
        *ptep_store = ptep;
    }
    if (ptep != NULL && *ptep & PTE_P) {
  103349:	55                   	push   %ebp
  10334a:	89 e5                	mov    %esp,%ebp
  10334c:	83 ec 28             	sub    $0x28,%esp
        return pte2page(*ptep);
  10334f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103356:	00 
  103357:	8b 45 0c             	mov    0xc(%ebp),%eax
  10335a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10335e:	8b 45 08             	mov    0x8(%ebp),%eax
  103361:	89 04 24             	mov    %eax,(%esp)
  103364:	e8 a7 fe ff ff       	call   103210 <get_pte>
  103369:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
  10336c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103370:	74 08                	je     10337a <get_page+0x31>
    return NULL;
  103372:	8b 45 10             	mov    0x10(%ebp),%eax
  103375:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103378:	89 10                	mov    %edx,(%eax)
}

  10337a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10337e:	74 1b                	je     10339b <get_page+0x52>
  103380:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103383:	8b 00                	mov    (%eax),%eax
  103385:	83 e0 01             	and    $0x1,%eax
  103388:	85 c0                	test   %eax,%eax
  10338a:	74 0f                	je     10339b <get_page+0x52>
//page_remove_pte - free an Page sturct which is related linear address la
  10338c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10338f:	8b 00                	mov    (%eax),%eax
  103391:	89 04 24             	mov    %eax,(%esp)
  103394:	e8 64 f5 ff ff       	call   1028fd <pte2page>
  103399:	eb 05                	jmp    1033a0 <get_page+0x57>
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
  10339b:	b8 00 00 00 00       	mov    $0x0,%eax
static inline void
  1033a0:	c9                   	leave  
  1033a1:	c3                   	ret    

001033a2 <page_remove_pte>:
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
    /* LAB2 EXERCISE 3: YOUR CODE
     *
     * Please check if ptep is valid, and tlb must be manually updated if mapping is updated
     *
     * Maybe you want help comment, BELOW comments can help you finish the code
  1033a2:	55                   	push   %ebp
  1033a3:	89 e5                	mov    %esp,%ebp
  1033a5:	83 ec 28             	sub    $0x28,%esp
    if (*ptep & PTE_P) {   //PTE_P代表页存在
        struct Page *page = pte2page(*ptep); //这个函数用于获取二级页表对应的物理页
        if (page_ref_dec(page) == 0) { //page_ref_dec(page)将ref减1，判断是否只使用了一次（只被二级页表引用一次）
            free_page(page); //则可以释放这个页
        }
        *ptep = 0;//如果还有更多的页表应用了它，不能释放，要取消二级映射，把二级页表ixang清零
  1033a8:	8b 45 10             	mov    0x10(%ebp),%eax
  1033ab:	8b 00                	mov    (%eax),%eax
  1033ad:	83 e0 01             	and    $0x1,%eax
  1033b0:	85 c0                	test   %eax,%eax
  1033b2:	74 4d                	je     103401 <page_remove_pte+0x5f>
        tlb_invalidate(pgdir, la);//更新TLB，使TLB中的项无效（除非这个页表正在被使用）
  1033b4:	8b 45 10             	mov    0x10(%ebp),%eax
  1033b7:	8b 00                	mov    (%eax),%eax
  1033b9:	89 04 24             	mov    %eax,(%esp)
  1033bc:	e8 3c f5 ff ff       	call   1028fd <pte2page>
  1033c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
  1033c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033c7:	89 04 24             	mov    %eax,(%esp)
  1033ca:	e8 b3 f5 ff ff       	call   102982 <page_ref_dec>
  1033cf:	85 c0                	test   %eax,%eax
  1033d1:	75 13                	jne    1033e6 <page_remove_pte+0x44>
}
  1033d3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033da:	00 
  1033db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033de:	89 04 24             	mov    %eax,(%esp)
  1033e1:	e8 aa f7 ff ff       	call   102b90 <free_pages>

//page_remove - free an Page which is related linear address la and has an validated pte
  1033e6:	8b 45 10             	mov    0x10(%ebp),%eax
  1033e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
void
  1033ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1033f9:	89 04 24             	mov    %eax,(%esp)
  1033fc:	e8 01 01 00 00       	call   103502 <tlb_invalidate>
page_remove(pde_t *pgdir, uintptr_t la) {
    pte_t *ptep = get_pte(pgdir, la, 0);
  103401:	90                   	nop
  103402:	c9                   	leave  
  103403:	c3                   	ret    

00103404 <page_remove>:
    if (ptep != NULL) {
        page_remove_pte(pgdir, la, ptep);
    }
}
  103404:	55                   	push   %ebp
  103405:	89 e5                	mov    %esp,%ebp
  103407:	83 ec 28             	sub    $0x28,%esp

  10340a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103411:	00 
  103412:	8b 45 0c             	mov    0xc(%ebp),%eax
  103415:	89 44 24 04          	mov    %eax,0x4(%esp)
  103419:	8b 45 08             	mov    0x8(%ebp),%eax
  10341c:	89 04 24             	mov    %eax,(%esp)
  10341f:	e8 ec fd ff ff       	call   103210 <get_pte>
  103424:	89 45 f4             	mov    %eax,-0xc(%ebp)
//page_insert - build the map of phy addr of an Page with the linear addr la
  103427:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10342b:	74 19                	je     103446 <page_remove+0x42>
// paramemters:
  10342d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103430:	89 44 24 08          	mov    %eax,0x8(%esp)
  103434:	8b 45 0c             	mov    0xc(%ebp),%eax
  103437:	89 44 24 04          	mov    %eax,0x4(%esp)
  10343b:	8b 45 08             	mov    0x8(%ebp),%eax
  10343e:	89 04 24             	mov    %eax,(%esp)
  103441:	e8 5c ff ff ff       	call   1033a2 <page_remove_pte>
//  pgdir: the kernel virtual base address of PDT
//  page:  the Page which need to map
  103446:	90                   	nop
  103447:	c9                   	leave  
  103448:	c3                   	ret    

00103449 <page_insert>:
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL) {
        return -E_NO_MEM;
    }
    page_ref_inc(page);
  103449:	55                   	push   %ebp
  10344a:	89 e5                	mov    %esp,%ebp
  10344c:	83 ec 28             	sub    $0x28,%esp
    if (*ptep & PTE_P) {
  10344f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103456:	00 
  103457:	8b 45 10             	mov    0x10(%ebp),%eax
  10345a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10345e:	8b 45 08             	mov    0x8(%ebp),%eax
  103461:	89 04 24             	mov    %eax,(%esp)
  103464:	e8 a7 fd ff ff       	call   103210 <get_pte>
  103469:	89 45 f4             	mov    %eax,-0xc(%ebp)
        struct Page *p = pte2page(*ptep);
  10346c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103470:	75 0a                	jne    10347c <page_insert+0x33>
        if (p == page) {
  103472:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  103477:	e9 84 00 00 00       	jmp    103500 <page_insert+0xb7>
            page_ref_dec(page);
        }
  10347c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10347f:	89 04 24             	mov    %eax,(%esp)
  103482:	e8 e4 f4 ff ff       	call   10296b <page_ref_inc>
        else {
  103487:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10348a:	8b 00                	mov    (%eax),%eax
  10348c:	83 e0 01             	and    $0x1,%eax
  10348f:	85 c0                	test   %eax,%eax
  103491:	74 3e                	je     1034d1 <page_insert+0x88>
            page_remove_pte(pgdir, la, ptep);
  103493:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103496:	8b 00                	mov    (%eax),%eax
  103498:	89 04 24             	mov    %eax,(%esp)
  10349b:	e8 5d f4 ff ff       	call   1028fd <pte2page>
  1034a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
  1034a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034a6:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1034a9:	75 0d                	jne    1034b8 <page_insert+0x6f>
    }
  1034ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034ae:	89 04 24             	mov    %eax,(%esp)
  1034b1:	e8 cc f4 ff ff       	call   102982 <page_ref_dec>
  1034b6:	eb 19                	jmp    1034d1 <page_insert+0x88>
    *ptep = page2pa(page) | PTE_P | perm;
    tlb_invalidate(pgdir, la);
    return 0;
  1034b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  1034bf:	8b 45 10             	mov    0x10(%ebp),%eax
  1034c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1034c9:	89 04 24             	mov    %eax,(%esp)
  1034cc:	e8 d1 fe ff ff       	call   1033a2 <page_remove_pte>
}

// invalidate a TLB entry, but only if the page tables being
  1034d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034d4:	89 04 24             	mov    %eax,(%esp)
  1034d7:	e8 68 f3 ff ff       	call   102844 <page2pa>
  1034dc:	0b 45 14             	or     0x14(%ebp),%eax
  1034df:	83 c8 01             	or     $0x1,%eax
  1034e2:	89 c2                	mov    %eax,%edx
  1034e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034e7:	89 10                	mov    %edx,(%eax)
// edited are the ones currently in use by the processor.
  1034e9:	8b 45 10             	mov    0x10(%ebp),%eax
  1034ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1034f3:	89 04 24             	mov    %eax,(%esp)
  1034f6:	e8 07 00 00 00       	call   103502 <tlb_invalidate>
void
  1034fb:	b8 00 00 00 00       	mov    $0x0,%eax
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  103500:	c9                   	leave  
  103501:	c3                   	ret    

00103502 <tlb_invalidate>:
    if (rcr3() == PADDR(pgdir)) {
        invlpg((void *)la);
    }
}

  103502:	55                   	push   %ebp
  103503:	89 e5                	mov    %esp,%ebp
  103505:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  103508:	0f 20 d8             	mov    %cr3,%eax
  10350b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  10350e:	8b 55 f0             	mov    -0x10(%ebp),%edx
static void
  103511:	8b 45 08             	mov    0x8(%ebp),%eax
  103514:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103517:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10351e:	77 23                	ja     103543 <tlb_invalidate+0x41>
  103520:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103523:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103527:	c7 44 24 08 44 76 10 	movl   $0x107644,0x8(%esp)
  10352e:	00 
  10352f:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
  103536:	00 
  103537:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  10353e:	e8 a6 ce ff ff       	call   1003e9 <__panic>
  103543:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103546:	05 00 00 00 40       	add    $0x40000000,%eax
  10354b:	39 d0                	cmp    %edx,%eax
  10354d:	75 0c                	jne    10355b <tlb_invalidate+0x59>
check_alloc_page(void) {
  10354f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103552:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  103555:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103558:	0f 01 38             	invlpg (%eax)
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
  10355b:	90                   	nop
  10355c:	c9                   	leave  
  10355d:	c3                   	ret    

0010355e <check_alloc_page>:
}

static void
  10355e:	55                   	push   %ebp
  10355f:	89 e5                	mov    %esp,%ebp
  103561:	83 ec 18             	sub    $0x18,%esp
check_pgdir(void) {
  103564:	a1 10 df 11 00       	mov    0x11df10,%eax
  103569:	8b 40 18             	mov    0x18(%eax),%eax
  10356c:	ff d0                	call   *%eax
    assert(npage <= KMEMSIZE / PGSIZE);
  10356e:	c7 04 24 c8 76 10 00 	movl   $0x1076c8,(%esp)
  103575:	e8 18 cd ff ff       	call   100292 <cprintf>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  10357a:	90                   	nop
  10357b:	c9                   	leave  
  10357c:	c3                   	ret    

0010357d <check_pgdir>:
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);

    struct Page *p1, *p2;
  10357d:	55                   	push   %ebp
  10357e:	89 e5                	mov    %esp,%ebp
  103580:	83 ec 38             	sub    $0x38,%esp
    p1 = alloc_page();
  103583:	a1 80 de 11 00       	mov    0x11de80,%eax
  103588:	3d 00 80 03 00       	cmp    $0x38000,%eax
  10358d:	76 24                	jbe    1035b3 <check_pgdir+0x36>
  10358f:	c7 44 24 0c e7 76 10 	movl   $0x1076e7,0xc(%esp)
  103596:	00 
  103597:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  10359e:	00 
  10359f:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  1035a6:	00 
  1035a7:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  1035ae:	e8 36 ce ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1035b3:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1035b8:	85 c0                	test   %eax,%eax
  1035ba:	74 0e                	je     1035ca <check_pgdir+0x4d>
  1035bc:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1035c1:	25 ff 0f 00 00       	and    $0xfff,%eax
  1035c6:	85 c0                	test   %eax,%eax
  1035c8:	74 24                	je     1035ee <check_pgdir+0x71>
  1035ca:	c7 44 24 0c 04 77 10 	movl   $0x107704,0xc(%esp)
  1035d1:	00 
  1035d2:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  1035d9:	00 
  1035da:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  1035e1:	00 
  1035e2:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  1035e9:	e8 fb cd ff ff       	call   1003e9 <__panic>

  1035ee:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1035f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1035fa:	00 
  1035fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103602:	00 
  103603:	89 04 24             	mov    %eax,(%esp)
  103606:	e8 3e fd ff ff       	call   103349 <get_page>
  10360b:	85 c0                	test   %eax,%eax
  10360d:	74 24                	je     103633 <check_pgdir+0xb6>
  10360f:	c7 44 24 0c 3c 77 10 	movl   $0x10773c,0xc(%esp)
  103616:	00 
  103617:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  10361e:	00 
  10361f:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  103626:	00 
  103627:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  10362e:	e8 b6 cd ff ff       	call   1003e9 <__panic>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
  103633:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10363a:	e8 19 f5 ff ff       	call   102b58 <alloc_pages>
  10363f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_ref(p1) == 1);
  103642:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103647:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10364e:	00 
  10364f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103656:	00 
  103657:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10365a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10365e:	89 04 24             	mov    %eax,(%esp)
  103661:	e8 e3 fd ff ff       	call   103449 <page_insert>
  103666:	85 c0                	test   %eax,%eax
  103668:	74 24                	je     10368e <check_pgdir+0x111>
  10366a:	c7 44 24 0c 64 77 10 	movl   $0x107764,0xc(%esp)
  103671:	00 
  103672:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103679:	00 
  10367a:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  103681:	00 
  103682:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103689:	e8 5b cd ff ff       	call   1003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  10368e:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103693:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10369a:	00 
  10369b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1036a2:	00 
  1036a3:	89 04 24             	mov    %eax,(%esp)
  1036a6:	e8 65 fb ff ff       	call   103210 <get_pte>
  1036ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1036b2:	75 24                	jne    1036d8 <check_pgdir+0x15b>
  1036b4:	c7 44 24 0c 90 77 10 	movl   $0x107790,0xc(%esp)
  1036bb:	00 
  1036bc:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  1036c3:	00 
  1036c4:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  1036cb:	00 
  1036cc:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  1036d3:	e8 11 cd ff ff       	call   1003e9 <__panic>

  1036d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1036db:	8b 00                	mov    (%eax),%eax
  1036dd:	89 04 24             	mov    %eax,(%esp)
  1036e0:	e8 18 f2 ff ff       	call   1028fd <pte2page>
  1036e5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1036e8:	74 24                	je     10370e <check_pgdir+0x191>
  1036ea:	c7 44 24 0c bd 77 10 	movl   $0x1077bd,0xc(%esp)
  1036f1:	00 
  1036f2:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  1036f9:	00 
  1036fa:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
  103701:	00 
  103702:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103709:	e8 db cc ff ff       	call   1003e9 <__panic>
    p2 = alloc_page();
  10370e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103711:	89 04 24             	mov    %eax,(%esp)
  103714:	e8 3a f2 ff ff       	call   102953 <page_ref>
  103719:	83 f8 01             	cmp    $0x1,%eax
  10371c:	74 24                	je     103742 <check_pgdir+0x1c5>
  10371e:	c7 44 24 0c d3 77 10 	movl   $0x1077d3,0xc(%esp)
  103725:	00 
  103726:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  10372d:	00 
  10372e:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  103735:	00 
  103736:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  10373d:	e8 a7 cc ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103742:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103747:	8b 00                	mov    (%eax),%eax
  103749:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10374e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103751:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103754:	c1 e8 0c             	shr    $0xc,%eax
  103757:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10375a:	a1 80 de 11 00       	mov    0x11de80,%eax
  10375f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103762:	72 23                	jb     103787 <check_pgdir+0x20a>
  103764:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103767:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10376b:	c7 44 24 08 a0 75 10 	movl   $0x1075a0,0x8(%esp)
  103772:	00 
  103773:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  10377a:	00 
  10377b:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103782:	e8 62 cc ff ff       	call   1003e9 <__panic>
  103787:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10378a:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10378f:	83 c0 04             	add    $0x4,%eax
  103792:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(*ptep & PTE_U);
  103795:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10379a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1037a1:	00 
  1037a2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1037a9:	00 
  1037aa:	89 04 24             	mov    %eax,(%esp)
  1037ad:	e8 5e fa ff ff       	call   103210 <get_pte>
  1037b2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  1037b5:	74 24                	je     1037db <check_pgdir+0x25e>
  1037b7:	c7 44 24 0c e8 77 10 	movl   $0x1077e8,0xc(%esp)
  1037be:	00 
  1037bf:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  1037c6:	00 
  1037c7:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
  1037ce:	00 
  1037cf:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  1037d6:	e8 0e cc ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_W);
    assert(boot_pgdir[0] & PTE_U);
  1037db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1037e2:	e8 71 f3 ff ff       	call   102b58 <alloc_pages>
  1037e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_ref(p2) == 1);
  1037ea:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1037ef:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  1037f6:	00 
  1037f7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1037fe:	00 
  1037ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103802:	89 54 24 04          	mov    %edx,0x4(%esp)
  103806:	89 04 24             	mov    %eax,(%esp)
  103809:	e8 3b fc ff ff       	call   103449 <page_insert>
  10380e:	85 c0                	test   %eax,%eax
  103810:	74 24                	je     103836 <check_pgdir+0x2b9>
  103812:	c7 44 24 0c 10 78 10 	movl   $0x107810,0xc(%esp)
  103819:	00 
  10381a:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103821:	00 
  103822:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  103829:	00 
  10382a:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103831:	e8 b3 cb ff ff       	call   1003e9 <__panic>

  103836:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10383b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103842:	00 
  103843:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10384a:	00 
  10384b:	89 04 24             	mov    %eax,(%esp)
  10384e:	e8 bd f9 ff ff       	call   103210 <get_pte>
  103853:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103856:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10385a:	75 24                	jne    103880 <check_pgdir+0x303>
  10385c:	c7 44 24 0c 48 78 10 	movl   $0x107848,0xc(%esp)
  103863:	00 
  103864:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  10386b:	00 
  10386c:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  103873:	00 
  103874:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  10387b:	e8 69 cb ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103880:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103883:	8b 00                	mov    (%eax),%eax
  103885:	83 e0 04             	and    $0x4,%eax
  103888:	85 c0                	test   %eax,%eax
  10388a:	75 24                	jne    1038b0 <check_pgdir+0x333>
  10388c:	c7 44 24 0c 78 78 10 	movl   $0x107878,0xc(%esp)
  103893:	00 
  103894:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  10389b:	00 
  10389c:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  1038a3:	00 
  1038a4:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  1038ab:	e8 39 cb ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 2);
  1038b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038b3:	8b 00                	mov    (%eax),%eax
  1038b5:	83 e0 02             	and    $0x2,%eax
  1038b8:	85 c0                	test   %eax,%eax
  1038ba:	75 24                	jne    1038e0 <check_pgdir+0x363>
  1038bc:	c7 44 24 0c 86 78 10 	movl   $0x107886,0xc(%esp)
  1038c3:	00 
  1038c4:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  1038cb:	00 
  1038cc:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  1038d3:	00 
  1038d4:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  1038db:	e8 09 cb ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  1038e0:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1038e5:	8b 00                	mov    (%eax),%eax
  1038e7:	83 e0 04             	and    $0x4,%eax
  1038ea:	85 c0                	test   %eax,%eax
  1038ec:	75 24                	jne    103912 <check_pgdir+0x395>
  1038ee:	c7 44 24 0c 94 78 10 	movl   $0x107894,0xc(%esp)
  1038f5:	00 
  1038f6:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  1038fd:	00 
  1038fe:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  103905:	00 
  103906:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  10390d:	e8 d7 ca ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103912:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103915:	89 04 24             	mov    %eax,(%esp)
  103918:	e8 36 f0 ff ff       	call   102953 <page_ref>
  10391d:	83 f8 01             	cmp    $0x1,%eax
  103920:	74 24                	je     103946 <check_pgdir+0x3c9>
  103922:	c7 44 24 0c aa 78 10 	movl   $0x1078aa,0xc(%esp)
  103929:	00 
  10392a:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103931:	00 
  103932:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  103939:	00 
  10393a:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103941:	e8 a3 ca ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
    assert((*ptep & PTE_U) == 0);
  103946:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10394b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103952:	00 
  103953:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10395a:	00 
  10395b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10395e:	89 54 24 04          	mov    %edx,0x4(%esp)
  103962:	89 04 24             	mov    %eax,(%esp)
  103965:	e8 df fa ff ff       	call   103449 <page_insert>
  10396a:	85 c0                	test   %eax,%eax
  10396c:	74 24                	je     103992 <check_pgdir+0x415>
  10396e:	c7 44 24 0c bc 78 10 	movl   $0x1078bc,0xc(%esp)
  103975:	00 
  103976:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  10397d:	00 
  10397e:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  103985:	00 
  103986:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  10398d:	e8 57 ca ff ff       	call   1003e9 <__panic>

  103992:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103995:	89 04 24             	mov    %eax,(%esp)
  103998:	e8 b6 ef ff ff       	call   102953 <page_ref>
  10399d:	83 f8 02             	cmp    $0x2,%eax
  1039a0:	74 24                	je     1039c6 <check_pgdir+0x449>
  1039a2:	c7 44 24 0c e8 78 10 	movl   $0x1078e8,0xc(%esp)
  1039a9:	00 
  1039aa:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  1039b1:	00 
  1039b2:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  1039b9:	00 
  1039ba:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  1039c1:	e8 23 ca ff ff       	call   1003e9 <__panic>
    page_remove(boot_pgdir, 0x0);
  1039c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1039c9:	89 04 24             	mov    %eax,(%esp)
  1039cc:	e8 82 ef ff ff       	call   102953 <page_ref>
  1039d1:	85 c0                	test   %eax,%eax
  1039d3:	74 24                	je     1039f9 <check_pgdir+0x47c>
  1039d5:	c7 44 24 0c fa 78 10 	movl   $0x1078fa,0xc(%esp)
  1039dc:	00 
  1039dd:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  1039e4:	00 
  1039e5:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
  1039ec:	00 
  1039ed:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  1039f4:	e8 f0 c9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 1);
  1039f9:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1039fe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103a05:	00 
  103a06:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a0d:	00 
  103a0e:	89 04 24             	mov    %eax,(%esp)
  103a11:	e8 fa f7 ff ff       	call   103210 <get_pte>
  103a16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a1d:	75 24                	jne    103a43 <check_pgdir+0x4c6>
  103a1f:	c7 44 24 0c 48 78 10 	movl   $0x107848,0xc(%esp)
  103a26:	00 
  103a27:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103a2e:	00 
  103a2f:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  103a36:	00 
  103a37:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103a3e:	e8 a6 c9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a46:	8b 00                	mov    (%eax),%eax
  103a48:	89 04 24             	mov    %eax,(%esp)
  103a4b:	e8 ad ee ff ff       	call   1028fd <pte2page>
  103a50:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103a53:	74 24                	je     103a79 <check_pgdir+0x4fc>
  103a55:	c7 44 24 0c bd 77 10 	movl   $0x1077bd,0xc(%esp)
  103a5c:	00 
  103a5d:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103a64:	00 
  103a65:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
  103a6c:	00 
  103a6d:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103a74:	e8 70 c9 ff ff       	call   1003e9 <__panic>

  103a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a7c:	8b 00                	mov    (%eax),%eax
  103a7e:	83 e0 04             	and    $0x4,%eax
  103a81:	85 c0                	test   %eax,%eax
  103a83:	74 24                	je     103aa9 <check_pgdir+0x52c>
  103a85:	c7 44 24 0c 0c 79 10 	movl   $0x10790c,0xc(%esp)
  103a8c:	00 
  103a8d:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103a94:	00 
  103a95:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  103a9c:	00 
  103a9d:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103aa4:	e8 40 c9 ff ff       	call   1003e9 <__panic>
    page_remove(boot_pgdir, PGSIZE);
    assert(page_ref(p1) == 0);
  103aa9:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103aae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103ab5:	00 
  103ab6:	89 04 24             	mov    %eax,(%esp)
  103ab9:	e8 46 f9 ff ff       	call   103404 <page_remove>
    assert(page_ref(p2) == 0);
  103abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ac1:	89 04 24             	mov    %eax,(%esp)
  103ac4:	e8 8a ee ff ff       	call   102953 <page_ref>
  103ac9:	83 f8 01             	cmp    $0x1,%eax
  103acc:	74 24                	je     103af2 <check_pgdir+0x575>
  103ace:	c7 44 24 0c d3 77 10 	movl   $0x1077d3,0xc(%esp)
  103ad5:	00 
  103ad6:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103add:	00 
  103ade:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  103ae5:	00 
  103ae6:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103aed:	e8 f7 c8 ff ff       	call   1003e9 <__panic>

  103af2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103af5:	89 04 24             	mov    %eax,(%esp)
  103af8:	e8 56 ee ff ff       	call   102953 <page_ref>
  103afd:	85 c0                	test   %eax,%eax
  103aff:	74 24                	je     103b25 <check_pgdir+0x5a8>
  103b01:	c7 44 24 0c fa 78 10 	movl   $0x1078fa,0xc(%esp)
  103b08:	00 
  103b09:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103b10:	00 
  103b11:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  103b18:	00 
  103b19:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103b20:	e8 c4 c8 ff ff       	call   1003e9 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
    free_page(pde2page(boot_pgdir[0]));
  103b25:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103b2a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103b31:	00 
  103b32:	89 04 24             	mov    %eax,(%esp)
  103b35:	e8 ca f8 ff ff       	call   103404 <page_remove>
    boot_pgdir[0] = 0;
  103b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b3d:	89 04 24             	mov    %eax,(%esp)
  103b40:	e8 0e ee ff ff       	call   102953 <page_ref>
  103b45:	85 c0                	test   %eax,%eax
  103b47:	74 24                	je     103b6d <check_pgdir+0x5f0>
  103b49:	c7 44 24 0c 21 79 10 	movl   $0x107921,0xc(%esp)
  103b50:	00 
  103b51:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103b58:	00 
  103b59:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
  103b60:	00 
  103b61:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103b68:	e8 7c c8 ff ff       	call   1003e9 <__panic>

  103b6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b70:	89 04 24             	mov    %eax,(%esp)
  103b73:	e8 db ed ff ff       	call   102953 <page_ref>
  103b78:	85 c0                	test   %eax,%eax
  103b7a:	74 24                	je     103ba0 <check_pgdir+0x623>
  103b7c:	c7 44 24 0c fa 78 10 	movl   $0x1078fa,0xc(%esp)
  103b83:	00 
  103b84:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103b8b:	00 
  103b8c:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  103b93:	00 
  103b94:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103b9b:	e8 49 c8 ff ff       	call   1003e9 <__panic>
    cprintf("check_pgdir() succeeded!\n");
}
  103ba0:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103ba5:	8b 00                	mov    (%eax),%eax
  103ba7:	89 04 24             	mov    %eax,(%esp)
  103baa:	e8 8c ed ff ff       	call   10293b <pde2page>
  103baf:	89 04 24             	mov    %eax,(%esp)
  103bb2:	e8 9c ed ff ff       	call   102953 <page_ref>
  103bb7:	83 f8 01             	cmp    $0x1,%eax
  103bba:	74 24                	je     103be0 <check_pgdir+0x663>
  103bbc:	c7 44 24 0c 34 79 10 	movl   $0x107934,0xc(%esp)
  103bc3:	00 
  103bc4:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103bcb:	00 
  103bcc:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
  103bd3:	00 
  103bd4:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103bdb:	e8 09 c8 ff ff       	call   1003e9 <__panic>

  103be0:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103be5:	8b 00                	mov    (%eax),%eax
  103be7:	89 04 24             	mov    %eax,(%esp)
  103bea:	e8 4c ed ff ff       	call   10293b <pde2page>
  103bef:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103bf6:	00 
  103bf7:	89 04 24             	mov    %eax,(%esp)
  103bfa:	e8 91 ef ff ff       	call   102b90 <free_pages>
static void
  103bff:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103c04:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
check_boot_pgdir(void) {
    pte_t *ptep;
  103c0a:	c7 04 24 5b 79 10 00 	movl   $0x10795b,(%esp)
  103c11:	e8 7c c6 ff ff       	call   100292 <cprintf>
    int i;
  103c16:	90                   	nop
  103c17:	c9                   	leave  
  103c18:	c3                   	ret    

00103c19 <check_boot_pgdir>:
    for (i = 0; i < npage; i += PGSIZE) {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
  103c19:	55                   	push   %ebp
  103c1a:	89 e5                	mov    %esp,%ebp
  103c1c:	83 ec 38             	sub    $0x38,%esp
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103c1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103c26:	e9 ca 00 00 00       	jmp    103cf5 <check_boot_pgdir+0xdc>

  103c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103c31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c34:	c1 e8 0c             	shr    $0xc,%eax
  103c37:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103c3a:	a1 80 de 11 00       	mov    0x11de80,%eax
  103c3f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103c42:	72 23                	jb     103c67 <check_boot_pgdir+0x4e>
  103c44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103c4b:	c7 44 24 08 a0 75 10 	movl   $0x1075a0,0x8(%esp)
  103c52:	00 
  103c53:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
  103c5a:	00 
  103c5b:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103c62:	e8 82 c7 ff ff       	call   1003e9 <__panic>
  103c67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c6a:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103c6f:	89 c2                	mov    %eax,%edx
  103c71:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103c76:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103c7d:	00 
  103c7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  103c82:	89 04 24             	mov    %eax,(%esp)
  103c85:	e8 86 f5 ff ff       	call   103210 <get_pte>
  103c8a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103c8d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103c91:	75 24                	jne    103cb7 <check_boot_pgdir+0x9e>
  103c93:	c7 44 24 0c 78 79 10 	movl   $0x107978,0xc(%esp)
  103c9a:	00 
  103c9b:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103ca2:	00 
  103ca3:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
  103caa:	00 
  103cab:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103cb2:	e8 32 c7 ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir[0] == 0);
  103cb7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103cba:	8b 00                	mov    (%eax),%eax
  103cbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103cc1:	89 c2                	mov    %eax,%edx
  103cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103cc6:	39 c2                	cmp    %eax,%edx
  103cc8:	74 24                	je     103cee <check_boot_pgdir+0xd5>
  103cca:	c7 44 24 0c b5 79 10 	movl   $0x1079b5,0xc(%esp)
  103cd1:	00 
  103cd2:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103cd9:	00 
  103cda:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  103ce1:	00 
  103ce2:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103ce9:	e8 fb c6 ff ff       	call   1003e9 <__panic>
    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103cee:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103cf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103cf8:	a1 80 de 11 00       	mov    0x11de80,%eax
  103cfd:	39 c2                	cmp    %eax,%edx
  103cff:	0f 82 26 ff ff ff    	jb     103c2b <check_boot_pgdir+0x12>

    struct Page *p;
    p = alloc_page();
  103d05:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103d0a:	05 ac 0f 00 00       	add    $0xfac,%eax
  103d0f:	8b 00                	mov    (%eax),%eax
  103d11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103d16:	89 c2                	mov    %eax,%edx
  103d18:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103d1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103d20:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103d27:	77 23                	ja     103d4c <check_boot_pgdir+0x133>
  103d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103d30:	c7 44 24 08 44 76 10 	movl   $0x107644,0x8(%esp)
  103d37:	00 
  103d38:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  103d3f:	00 
  103d40:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103d47:	e8 9d c6 ff ff       	call   1003e9 <__panic>
  103d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d4f:	05 00 00 00 40       	add    $0x40000000,%eax
  103d54:	39 d0                	cmp    %edx,%eax
  103d56:	74 24                	je     103d7c <check_boot_pgdir+0x163>
  103d58:	c7 44 24 0c cc 79 10 	movl   $0x1079cc,0xc(%esp)
  103d5f:	00 
  103d60:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103d67:	00 
  103d68:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  103d6f:	00 
  103d70:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103d77:	e8 6d c6 ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
    assert(page_ref(p) == 1);
  103d7c:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103d81:	8b 00                	mov    (%eax),%eax
  103d83:	85 c0                	test   %eax,%eax
  103d85:	74 24                	je     103dab <check_boot_pgdir+0x192>
  103d87:	c7 44 24 0c 00 7a 10 	movl   $0x107a00,0xc(%esp)
  103d8e:	00 
  103d8f:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103d96:	00 
  103d97:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
  103d9e:	00 
  103d9f:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103da6:	e8 3e c6 ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
    assert(page_ref(p) == 2);

  103dab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103db2:	e8 a1 ed ff ff       	call   102b58 <alloc_pages>
  103db7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    const char *str = "ucore: Hello world!!";
  103dba:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103dbf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103dc6:	00 
  103dc7:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103dce:	00 
  103dcf:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103dd2:	89 54 24 04          	mov    %edx,0x4(%esp)
  103dd6:	89 04 24             	mov    %eax,(%esp)
  103dd9:	e8 6b f6 ff ff       	call   103449 <page_insert>
  103dde:	85 c0                	test   %eax,%eax
  103de0:	74 24                	je     103e06 <check_boot_pgdir+0x1ed>
  103de2:	c7 44 24 0c 14 7a 10 	movl   $0x107a14,0xc(%esp)
  103de9:	00 
  103dea:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103df1:	00 
  103df2:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
  103df9:	00 
  103dfa:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103e01:	e8 e3 c5 ff ff       	call   1003e9 <__panic>
    strcpy((void *)0x100, str);
  103e06:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103e09:	89 04 24             	mov    %eax,(%esp)
  103e0c:	e8 42 eb ff ff       	call   102953 <page_ref>
  103e11:	83 f8 01             	cmp    $0x1,%eax
  103e14:	74 24                	je     103e3a <check_boot_pgdir+0x221>
  103e16:	c7 44 24 0c 42 7a 10 	movl   $0x107a42,0xc(%esp)
  103e1d:	00 
  103e1e:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103e25:	00 
  103e26:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
  103e2d:	00 
  103e2e:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103e35:	e8 af c5 ff ff       	call   1003e9 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103e3a:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103e3f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103e46:	00 
  103e47:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  103e4e:	00 
  103e4f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103e52:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e56:	89 04 24             	mov    %eax,(%esp)
  103e59:	e8 eb f5 ff ff       	call   103449 <page_insert>
  103e5e:	85 c0                	test   %eax,%eax
  103e60:	74 24                	je     103e86 <check_boot_pgdir+0x26d>
  103e62:	c7 44 24 0c 54 7a 10 	movl   $0x107a54,0xc(%esp)
  103e69:	00 
  103e6a:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103e71:	00 
  103e72:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
  103e79:	00 
  103e7a:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103e81:	e8 63 c5 ff ff       	call   1003e9 <__panic>

  103e86:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103e89:	89 04 24             	mov    %eax,(%esp)
  103e8c:	e8 c2 ea ff ff       	call   102953 <page_ref>
  103e91:	83 f8 02             	cmp    $0x2,%eax
  103e94:	74 24                	je     103eba <check_boot_pgdir+0x2a1>
  103e96:	c7 44 24 0c 8b 7a 10 	movl   $0x107a8b,0xc(%esp)
  103e9d:	00 
  103e9e:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103ea5:	00 
  103ea6:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
  103ead:	00 
  103eae:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103eb5:	e8 2f c5 ff ff       	call   1003e9 <__panic>
    *(char *)(page2kva(p) + 0x100) = '\0';
    assert(strlen((const char *)0x100) == 0);
  103eba:	c7 45 e8 9c 7a 10 00 	movl   $0x107a9c,-0x18(%ebp)

  103ec1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103ec4:	89 44 24 04          	mov    %eax,0x4(%esp)
  103ec8:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103ecf:	e8 bd 24 00 00       	call   106391 <strcpy>
    free_page(p);
  103ed4:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  103edb:	00 
  103edc:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103ee3:	e8 20 25 00 00       	call   106408 <strcmp>
  103ee8:	85 c0                	test   %eax,%eax
  103eea:	74 24                	je     103f10 <check_boot_pgdir+0x2f7>
  103eec:	c7 44 24 0c b4 7a 10 	movl   $0x107ab4,0xc(%esp)
  103ef3:	00 
  103ef4:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103efb:	00 
  103efc:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
  103f03:	00 
  103f04:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103f0b:	e8 d9 c4 ff ff       	call   1003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
    boot_pgdir[0] = 0;
  103f10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103f13:	89 04 24             	mov    %eax,(%esp)
  103f16:	e8 8e e9 ff ff       	call   1028a9 <page2kva>
  103f1b:	05 00 01 00 00       	add    $0x100,%eax
  103f20:	c6 00 00             	movb   $0x0,(%eax)

  103f23:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f2a:	e8 0c 24 00 00       	call   10633b <strlen>
  103f2f:	85 c0                	test   %eax,%eax
  103f31:	74 24                	je     103f57 <check_boot_pgdir+0x33e>
  103f33:	c7 44 24 0c ec 7a 10 	movl   $0x107aec,0xc(%esp)
  103f3a:	00 
  103f3b:	c7 44 24 08 8d 76 10 	movl   $0x10768d,0x8(%esp)
  103f42:	00 
  103f43:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
  103f4a:	00 
  103f4b:	c7 04 24 68 76 10 00 	movl   $0x107668,(%esp)
  103f52:	e8 92 c4 ff ff       	call   1003e9 <__panic>
    cprintf("check_boot_pgdir() succeeded!\n");
}
  103f57:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103f5e:	00 
  103f5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103f62:	89 04 24             	mov    %eax,(%esp)
  103f65:	e8 26 ec ff ff       	call   102b90 <free_pages>

  103f6a:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103f6f:	8b 00                	mov    (%eax),%eax
  103f71:	89 04 24             	mov    %eax,(%esp)
  103f74:	e8 c2 e9 ff ff       	call   10293b <pde2page>
  103f79:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103f80:	00 
  103f81:	89 04 24             	mov    %eax,(%esp)
  103f84:	e8 07 ec ff ff       	call   102b90 <free_pages>
//perm2str - use string 'u,r,w,-' to present the permission
  103f89:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103f8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
static const char *
perm2str(int perm) {
  103f94:	c7 04 24 10 7b 10 00 	movl   $0x107b10,(%esp)
  103f9b:	e8 f2 c2 ff ff       	call   100292 <cprintf>
    static char str[4];
  103fa0:	90                   	nop
  103fa1:	c9                   	leave  
  103fa2:	c3                   	ret    

00103fa3 <perm2str>:
    str[0] = (perm & PTE_U) ? 'u' : '-';
    str[1] = 'r';
    str[2] = (perm & PTE_W) ? 'w' : '-';
    str[3] = '\0';
  103fa3:	55                   	push   %ebp
  103fa4:	89 e5                	mov    %esp,%ebp
    return str;
}
  103fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  103fa9:	83 e0 04             	and    $0x4,%eax
  103fac:	85 c0                	test   %eax,%eax
  103fae:	74 04                	je     103fb4 <perm2str+0x11>
  103fb0:	b0 75                	mov    $0x75,%al
  103fb2:	eb 02                	jmp    103fb6 <perm2str+0x13>
  103fb4:	b0 2d                	mov    $0x2d,%al
  103fb6:	a2 08 df 11 00       	mov    %al,0x11df08

  103fbb:	c6 05 09 df 11 00 72 	movb   $0x72,0x11df09
//get_pgtable_items - In [left, right] range of PDT or PT, find a continuous linear addr space
  103fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  103fc5:	83 e0 02             	and    $0x2,%eax
  103fc8:	85 c0                	test   %eax,%eax
  103fca:	74 04                	je     103fd0 <perm2str+0x2d>
  103fcc:	b0 77                	mov    $0x77,%al
  103fce:	eb 02                	jmp    103fd2 <perm2str+0x2f>
  103fd0:	b0 2d                	mov    $0x2d,%al
  103fd2:	a2 0a df 11 00       	mov    %al,0x11df0a
//                  - (left_store*X_SIZE~right_store*X_SIZE) for PDT or PT
  103fd7:	c6 05 0b df 11 00 00 	movb   $0x0,0x11df0b
//                  - X_SIZE=PTSIZE=4M, if PDT; X_SIZE=PGSIZE=4K, if PT
  103fde:	b8 08 df 11 00       	mov    $0x11df08,%eax
// paramemters:
  103fe3:	5d                   	pop    %ebp
  103fe4:	c3                   	ret    

00103fe5 <get_pgtable_items>:
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  103fe5:	55                   	push   %ebp
  103fe6:	89 e5                	mov    %esp,%ebp
  103fe8:	83 ec 10             	sub    $0x10,%esp
    }
  103feb:	8b 45 10             	mov    0x10(%ebp),%eax
  103fee:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103ff1:	72 0d                	jb     104000 <get_pgtable_items+0x1b>
    if (start < right) {
  103ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  103ff8:	e9 98 00 00 00       	jmp    104095 <get_pgtable_items+0xb0>
        if (left_store != NULL) {
            *left_store = start;
        }
  103ffd:	ff 45 10             	incl   0x10(%ebp)
            *left_store = start;
  104000:	8b 45 10             	mov    0x10(%ebp),%eax
  104003:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104006:	73 18                	jae    104020 <get_pgtable_items+0x3b>
  104008:	8b 45 10             	mov    0x10(%ebp),%eax
  10400b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104012:	8b 45 14             	mov    0x14(%ebp),%eax
  104015:	01 d0                	add    %edx,%eax
  104017:	8b 00                	mov    (%eax),%eax
  104019:	83 e0 01             	and    $0x1,%eax
  10401c:	85 c0                	test   %eax,%eax
  10401e:	74 dd                	je     103ffd <get_pgtable_items+0x18>
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  104020:	8b 45 10             	mov    0x10(%ebp),%eax
  104023:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104026:	73 68                	jae    104090 <get_pgtable_items+0xab>
            start ++;
  104028:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  10402c:	74 08                	je     104036 <get_pgtable_items+0x51>
        }
  10402e:	8b 45 18             	mov    0x18(%ebp),%eax
  104031:	8b 55 10             	mov    0x10(%ebp),%edx
  104034:	89 10                	mov    %edx,(%eax)
        if (right_store != NULL) {
            *right_store = start;
  104036:	8b 45 10             	mov    0x10(%ebp),%eax
  104039:	8d 50 01             	lea    0x1(%eax),%edx
  10403c:	89 55 10             	mov    %edx,0x10(%ebp)
  10403f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104046:	8b 45 14             	mov    0x14(%ebp),%eax
  104049:	01 d0                	add    %edx,%eax
  10404b:	8b 00                	mov    (%eax),%eax
  10404d:	83 e0 07             	and    $0x7,%eax
  104050:	89 45 fc             	mov    %eax,-0x4(%ebp)
        }
  104053:	eb 03                	jmp    104058 <get_pgtable_items+0x73>
        return perm;
  104055:	ff 45 10             	incl   0x10(%ebp)
        }
  104058:	8b 45 10             	mov    0x10(%ebp),%eax
  10405b:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10405e:	73 1d                	jae    10407d <get_pgtable_items+0x98>
  104060:	8b 45 10             	mov    0x10(%ebp),%eax
  104063:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10406a:	8b 45 14             	mov    0x14(%ebp),%eax
  10406d:	01 d0                	add    %edx,%eax
  10406f:	8b 00                	mov    (%eax),%eax
  104071:	83 e0 07             	and    $0x7,%eax
  104074:	89 c2                	mov    %eax,%edx
  104076:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104079:	39 c2                	cmp    %eax,%edx
  10407b:	74 d8                	je     104055 <get_pgtable_items+0x70>
    }
    return 0;
  10407d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  104081:	74 08                	je     10408b <get_pgtable_items+0xa6>
}
  104083:	8b 45 1c             	mov    0x1c(%ebp),%eax
  104086:	8b 55 10             	mov    0x10(%ebp),%edx
  104089:	89 10                	mov    %edx,(%eax)

//print_pgdir - print the PDT&PT
  10408b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10408e:	eb 05                	jmp    104095 <get_pgtable_items+0xb0>
void
print_pgdir(void) {
  104090:	b8 00 00 00 00       	mov    $0x0,%eax
    cprintf("-------------------- BEGIN --------------------\n");
  104095:	c9                   	leave  
  104096:	c3                   	ret    

00104097 <print_pgdir>:
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  104097:	55                   	push   %ebp
  104098:	89 e5                	mov    %esp,%ebp
  10409a:	57                   	push   %edi
  10409b:	56                   	push   %esi
  10409c:	53                   	push   %ebx
  10409d:	83 ec 4c             	sub    $0x4c,%esp
        size_t l, r = left * NPTEENTRY;
  1040a0:	c7 04 24 30 7b 10 00 	movl   $0x107b30,(%esp)
  1040a7:	e8 e6 c1 ff ff       	call   100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1040ac:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1040b3:	e9 fa 00 00 00       	jmp    1041b2 <print_pgdir+0x11b>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1040b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1040bb:	89 04 24             	mov    %eax,(%esp)
  1040be:	e8 e0 fe ff ff       	call   103fa3 <perm2str>
        }
  1040c3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1040c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1040c9:	29 d1                	sub    %edx,%ecx
  1040cb:	89 ca                	mov    %ecx,%edx
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1040cd:	89 d6                	mov    %edx,%esi
  1040cf:	c1 e6 16             	shl    $0x16,%esi
  1040d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040d5:	89 d3                	mov    %edx,%ebx
  1040d7:	c1 e3 16             	shl    $0x16,%ebx
  1040da:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1040dd:	89 d1                	mov    %edx,%ecx
  1040df:	c1 e1 16             	shl    $0x16,%ecx
  1040e2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  1040e5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1040e8:	29 d7                	sub    %edx,%edi
  1040ea:	89 fa                	mov    %edi,%edx
  1040ec:	89 44 24 14          	mov    %eax,0x14(%esp)
  1040f0:	89 74 24 10          	mov    %esi,0x10(%esp)
  1040f4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1040f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1040fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  104100:	c7 04 24 61 7b 10 00 	movl   $0x107b61,(%esp)
  104107:	e8 86 c1 ff ff       	call   100292 <cprintf>
    }
  10410c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10410f:	c1 e0 0a             	shl    $0xa,%eax
  104112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("--------------------- END ---------------------\n");
  104115:	eb 54                	jmp    10416b <print_pgdir+0xd4>
}
  104117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10411a:	89 04 24             	mov    %eax,(%esp)
  10411d:	e8 81 fe ff ff       	call   103fa3 <perm2str>

  104122:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  104125:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104128:	29 d1                	sub    %edx,%ecx
  10412a:	89 ca                	mov    %ecx,%edx
}
  10412c:	89 d6                	mov    %edx,%esi
  10412e:	c1 e6 0c             	shl    $0xc,%esi
  104131:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104134:	89 d3                	mov    %edx,%ebx
  104136:	c1 e3 0c             	shl    $0xc,%ebx
  104139:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10413c:	89 d1                	mov    %edx,%ecx
  10413e:	c1 e1 0c             	shl    $0xc,%ecx
  104141:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  104144:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104147:	29 d7                	sub    %edx,%edi
  104149:	89 fa                	mov    %edi,%edx
  10414b:	89 44 24 14          	mov    %eax,0x14(%esp)
  10414f:	89 74 24 10          	mov    %esi,0x10(%esp)
  104153:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104157:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10415b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10415f:	c7 04 24 80 7b 10 00 	movl   $0x107b80,(%esp)
  104166:	e8 27 c1 ff ff       	call   100292 <cprintf>
    cprintf("--------------------- END ---------------------\n");
  10416b:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  104170:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104173:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104176:	89 d3                	mov    %edx,%ebx
  104178:	c1 e3 0a             	shl    $0xa,%ebx
  10417b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10417e:	89 d1                	mov    %edx,%ecx
  104180:	c1 e1 0a             	shl    $0xa,%ecx
  104183:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  104186:	89 54 24 14          	mov    %edx,0x14(%esp)
  10418a:	8d 55 d8             	lea    -0x28(%ebp),%edx
  10418d:	89 54 24 10          	mov    %edx,0x10(%esp)
  104191:	89 74 24 0c          	mov    %esi,0xc(%esp)
  104195:	89 44 24 08          	mov    %eax,0x8(%esp)
  104199:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10419d:	89 0c 24             	mov    %ecx,(%esp)
  1041a0:	e8 40 fe ff ff       	call   103fe5 <get_pgtable_items>
  1041a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1041a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1041ac:	0f 85 65 ff ff ff    	jne    104117 <print_pgdir+0x80>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1041b2:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  1041b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1041ba:	8d 55 dc             	lea    -0x24(%ebp),%edx
  1041bd:	89 54 24 14          	mov    %edx,0x14(%esp)
  1041c1:	8d 55 e0             	lea    -0x20(%ebp),%edx
  1041c4:	89 54 24 10          	mov    %edx,0x10(%esp)
  1041c8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1041cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  1041d0:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1041d7:	00 
  1041d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1041df:	e8 01 fe ff ff       	call   103fe5 <get_pgtable_items>
  1041e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1041e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1041eb:	0f 85 c7 fe ff ff    	jne    1040b8 <print_pgdir+0x21>
  1041f1:	c7 04 24 a4 7b 10 00 	movl   $0x107ba4,(%esp)
  1041f8:	e8 95 c0 ff ff       	call   100292 <cprintf>
  1041fd:	90                   	nop
  1041fe:	83 c4 4c             	add    $0x4c,%esp
  104201:	5b                   	pop    %ebx
  104202:	5e                   	pop    %esi
  104203:	5f                   	pop    %edi
  104204:	5d                   	pop    %ebp
  104205:	c3                   	ret    

00104206 <page2ppn>:
page2ppn(struct Page *page) {
  104206:	55                   	push   %ebp
  104207:	89 e5                	mov    %esp,%ebp
    return page - pages;
  104209:	8b 45 08             	mov    0x8(%ebp),%eax
  10420c:	8b 15 18 df 11 00    	mov    0x11df18,%edx
  104212:	29 d0                	sub    %edx,%eax
  104214:	c1 f8 02             	sar    $0x2,%eax
  104217:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  10421d:	5d                   	pop    %ebp
  10421e:	c3                   	ret    

0010421f <page2pa>:
page2pa(struct Page *page) {
  10421f:	55                   	push   %ebp
  104220:	89 e5                	mov    %esp,%ebp
  104222:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104225:	8b 45 08             	mov    0x8(%ebp),%eax
  104228:	89 04 24             	mov    %eax,(%esp)
  10422b:	e8 d6 ff ff ff       	call   104206 <page2ppn>
  104230:	c1 e0 0c             	shl    $0xc,%eax
}
  104233:	c9                   	leave  
  104234:	c3                   	ret    

00104235 <page_ref>:
page_ref(struct Page *page) {
  104235:	55                   	push   %ebp
  104236:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104238:	8b 45 08             	mov    0x8(%ebp),%eax
  10423b:	8b 00                	mov    (%eax),%eax
}
  10423d:	5d                   	pop    %ebp
  10423e:	c3                   	ret    

0010423f <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  10423f:	55                   	push   %ebp
  104240:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  104242:	8b 45 08             	mov    0x8(%ebp),%eax
  104245:	8b 55 0c             	mov    0xc(%ebp),%edx
  104248:	89 10                	mov    %edx,(%eax)
}
  10424a:	90                   	nop
  10424b:	5d                   	pop    %ebp
  10424c:	c3                   	ret    

0010424d <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  10424d:	55                   	push   %ebp
  10424e:	89 e5                	mov    %esp,%ebp
  104250:	83 ec 10             	sub    $0x10,%esp
  104253:	c7 45 fc 20 df 11 00 	movl   $0x11df20,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10425a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10425d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  104260:	89 50 04             	mov    %edx,0x4(%eax)
  104263:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104266:	8b 50 04             	mov    0x4(%eax),%edx
  104269:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10426c:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  10426e:	c7 05 28 df 11 00 00 	movl   $0x0,0x11df28
  104275:	00 00 00 
}
  104278:	90                   	nop
  104279:	c9                   	leave  
  10427a:	c3                   	ret    

0010427b <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  10427b:	55                   	push   %ebp
  10427c:	89 e5                	mov    %esp,%ebp
  10427e:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  104281:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104285:	75 24                	jne    1042ab <default_init_memmap+0x30>
  104287:	c7 44 24 0c d8 7b 10 	movl   $0x107bd8,0xc(%esp)
  10428e:	00 
  10428f:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104296:	00 
  104297:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  10429e:	00 
  10429f:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  1042a6:	e8 3e c1 ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  1042ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1042ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1042b1:	eb 7d                	jmp    104330 <default_init_memmap+0xb5>
        assert(PageReserved(p));
  1042b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042b6:	83 c0 04             	add    $0x4,%eax
  1042b9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1042c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1042c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1042c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1042c9:	0f a3 10             	bt     %edx,(%eax)
  1042cc:	19 c0                	sbb    %eax,%eax
  1042ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  1042d1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1042d5:	0f 95 c0             	setne  %al
  1042d8:	0f b6 c0             	movzbl %al,%eax
  1042db:	85 c0                	test   %eax,%eax
  1042dd:	75 24                	jne    104303 <default_init_memmap+0x88>
  1042df:	c7 44 24 0c 09 7c 10 	movl   $0x107c09,0xc(%esp)
  1042e6:	00 
  1042e7:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  1042ee:	00 
  1042ef:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  1042f6:	00 
  1042f7:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  1042fe:	e8 e6 c0 ff ff       	call   1003e9 <__panic>
        p->flags = p->property = 0;
  104303:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104306:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  10430d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104310:	8b 50 08             	mov    0x8(%eax),%edx
  104313:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104316:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  104319:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104320:	00 
  104321:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104324:	89 04 24             	mov    %eax,(%esp)
  104327:	e8 13 ff ff ff       	call   10423f <set_page_ref>
    for (; p != base + n; p ++) {
  10432c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104330:	8b 55 0c             	mov    0xc(%ebp),%edx
  104333:	89 d0                	mov    %edx,%eax
  104335:	c1 e0 02             	shl    $0x2,%eax
  104338:	01 d0                	add    %edx,%eax
  10433a:	c1 e0 02             	shl    $0x2,%eax
  10433d:	89 c2                	mov    %eax,%edx
  10433f:	8b 45 08             	mov    0x8(%ebp),%eax
  104342:	01 d0                	add    %edx,%eax
  104344:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104347:	0f 85 66 ff ff ff    	jne    1042b3 <default_init_memmap+0x38>
	
    }
    base->property = n;
  10434d:	8b 45 08             	mov    0x8(%ebp),%eax
  104350:	8b 55 0c             	mov    0xc(%ebp),%edx
  104353:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104356:	8b 45 08             	mov    0x8(%ebp),%eax
  104359:	83 c0 04             	add    $0x4,%eax
  10435c:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104363:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104366:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104369:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10436c:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  10436f:	8b 15 28 df 11 00    	mov    0x11df28,%edx
  104375:	8b 45 0c             	mov    0xc(%ebp),%eax
  104378:	01 d0                	add    %edx,%eax
  10437a:	a3 28 df 11 00       	mov    %eax,0x11df28
    list_add_before(&free_list,&(base->page_link));
  10437f:	8b 45 08             	mov    0x8(%ebp),%eax
  104382:	83 c0 0c             	add    $0xc,%eax
  104385:	c7 45 e4 20 df 11 00 	movl   $0x11df20,-0x1c(%ebp)
  10438c:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  10438f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104392:	8b 00                	mov    (%eax),%eax
  104394:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104397:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10439a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  10439d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1043a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1043a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1043a9:	89 10                	mov    %edx,(%eax)
  1043ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1043ae:	8b 10                	mov    (%eax),%edx
  1043b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1043b3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1043b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1043bc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1043bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1043c5:	89 10                	mov    %edx,(%eax)
}
  1043c7:	90                   	nop
  1043c8:	c9                   	leave  
  1043c9:	c3                   	ret    

001043ca <default_alloc_pages>:
 *              return `p`.
 *      (4.2)
 *          If we can not find a free block with its size >=n, then return NULL.
*/
static struct Page *
default_alloc_pages(size_t n) {
  1043ca:	55                   	push   %ebp
  1043cb:	89 e5                	mov    %esp,%ebp
  1043cd:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  1043d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1043d4:	75 24                	jne    1043fa <default_alloc_pages+0x30>
  1043d6:	c7 44 24 0c d8 7b 10 	movl   $0x107bd8,0xc(%esp)
  1043dd:	00 
  1043de:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  1043e5:	00 
  1043e6:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  1043ed:	00 
  1043ee:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  1043f5:	e8 ef bf ff ff       	call   1003e9 <__panic>
    if (n > nr_free) {
  1043fa:	a1 28 df 11 00       	mov    0x11df28,%eax
  1043ff:	39 45 08             	cmp    %eax,0x8(%ebp)
  104402:	76 0a                	jbe    10440e <default_alloc_pages+0x44>
        return NULL;
  104404:	b8 00 00 00 00       	mov    $0x0,%eax
  104409:	e9 49 01 00 00       	jmp    104557 <default_alloc_pages+0x18d>
    }
    struct Page *page=NULL;
  10440e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  104415:	c7 45 f0 20 df 11 00 	movl   $0x11df20,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10441c:	eb 1c                	jmp    10443a <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  10441e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104421:	83 e8 0c             	sub    $0xc,%eax
  104424:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  104427:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10442a:	8b 40 08             	mov    0x8(%eax),%eax
  10442d:	39 45 08             	cmp    %eax,0x8(%ebp)
  104430:	77 08                	ja     10443a <default_alloc_pages+0x70>
	   page=p;
  104432:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104435:	89 45 f4             	mov    %eax,-0xc(%ebp)
	   break;
  104438:	eb 18                	jmp    104452 <default_alloc_pages+0x88>
  10443a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10443d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  104440:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104443:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104446:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104449:	81 7d f0 20 df 11 00 	cmpl   $0x11df20,-0x10(%ebp)
  104450:	75 cc                	jne    10441e <default_alloc_pages+0x54>
        }
    }
    if(page!=NULL){
  104452:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104456:	0f 84 f8 00 00 00    	je     104554 <default_alloc_pages+0x18a>
	if(page->property>n){
  10445c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10445f:	8b 40 08             	mov    0x8(%eax),%eax
  104462:	39 45 08             	cmp    %eax,0x8(%ebp)
  104465:	0f 83 98 00 00 00    	jae    104503 <default_alloc_pages+0x139>
	   struct Page*p=page+n;
  10446b:	8b 55 08             	mov    0x8(%ebp),%edx
  10446e:	89 d0                	mov    %edx,%eax
  104470:	c1 e0 02             	shl    $0x2,%eax
  104473:	01 d0                	add    %edx,%eax
  104475:	c1 e0 02             	shl    $0x2,%eax
  104478:	89 c2                	mov    %eax,%edx
  10447a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10447d:	01 d0                	add    %edx,%eax
  10447f:	89 45 e8             	mov    %eax,-0x18(%ebp)
	   p->property=page->property-n;
  104482:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104485:	8b 40 08             	mov    0x8(%eax),%eax
  104488:	2b 45 08             	sub    0x8(%ebp),%eax
  10448b:	89 c2                	mov    %eax,%edx
  10448d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104490:	89 50 08             	mov    %edx,0x8(%eax)
	   SetPageProperty(p);
  104493:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104496:	83 c0 04             	add    $0x4,%eax
  104499:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  1044a0:	89 45 c0             	mov    %eax,-0x40(%ebp)
  1044a3:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1044a6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1044a9:	0f ab 10             	bts    %edx,(%eax)
	   list_add(&(page->page_link),&(p->page_link));
  1044ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044af:	83 c0 0c             	add    $0xc,%eax
  1044b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1044b5:	83 c2 0c             	add    $0xc,%edx
  1044b8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  1044bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1044be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1044c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1044c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1044c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
  1044ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1044cd:	8b 40 04             	mov    0x4(%eax),%eax
  1044d0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1044d3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  1044d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1044d9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  1044dc:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
  1044df:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1044e2:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1044e5:	89 10                	mov    %edx,(%eax)
  1044e7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1044ea:	8b 10                	mov    (%eax),%edx
  1044ec:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1044ef:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1044f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1044f5:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1044f8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1044fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1044fe:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104501:	89 10                	mov    %edx,(%eax)
	}
	
	list_del(&(page->page_link));
  104503:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104506:	83 c0 0c             	add    $0xc,%eax
  104509:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
  10450c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10450f:	8b 40 04             	mov    0x4(%eax),%eax
  104512:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104515:	8b 12                	mov    (%edx),%edx
  104517:	89 55 b0             	mov    %edx,-0x50(%ebp)
  10451a:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  10451d:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104520:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104523:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104526:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104529:	8b 55 b0             	mov    -0x50(%ebp),%edx
  10452c:	89 10                	mov    %edx,(%eax)
	nr_free-=n;
  10452e:	a1 28 df 11 00       	mov    0x11df28,%eax
  104533:	2b 45 08             	sub    0x8(%ebp),%eax
  104536:	a3 28 df 11 00       	mov    %eax,0x11df28
	ClearPageProperty(page);
  10453b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10453e:	83 c0 04             	add    $0x4,%eax
  104541:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  104548:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10454b:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10454e:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104551:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  104554:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104557:	c9                   	leave  
  104558:	c3                   	ret    

00104559 <default_free_pages>:
 *  (5.3)
 *      Try to merge blocks at lower or higher addresses. Notice: This should
 *  change some pages' `p->property` correctly.
 */
static void
default_free_pages(struct Page *base, size_t n) {
  104559:	55                   	push   %ebp
  10455a:	89 e5                	mov    %esp,%ebp
  10455c:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  104562:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104566:	75 24                	jne    10458c <default_free_pages+0x33>
  104568:	c7 44 24 0c d8 7b 10 	movl   $0x107bd8,0xc(%esp)
  10456f:	00 
  104570:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104577:	00 
  104578:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  10457f:	00 
  104580:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104587:	e8 5d be ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  10458c:	8b 45 08             	mov    0x8(%ebp),%eax
  10458f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  104592:	e9 9d 00 00 00       	jmp    104634 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  104597:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10459a:	83 c0 04             	add    $0x4,%eax
  10459d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1045a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1045a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1045aa:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1045ad:	0f a3 10             	bt     %edx,(%eax)
  1045b0:	19 c0                	sbb    %eax,%eax
  1045b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  1045b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1045b9:	0f 95 c0             	setne  %al
  1045bc:	0f b6 c0             	movzbl %al,%eax
  1045bf:	85 c0                	test   %eax,%eax
  1045c1:	75 2c                	jne    1045ef <default_free_pages+0x96>
  1045c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045c6:	83 c0 04             	add    $0x4,%eax
  1045c9:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  1045d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1045d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1045d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1045d9:	0f a3 10             	bt     %edx,(%eax)
  1045dc:	19 c0                	sbb    %eax,%eax
  1045de:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  1045e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  1045e5:	0f 95 c0             	setne  %al
  1045e8:	0f b6 c0             	movzbl %al,%eax
  1045eb:	85 c0                	test   %eax,%eax
  1045ed:	74 24                	je     104613 <default_free_pages+0xba>
  1045ef:	c7 44 24 0c 1c 7c 10 	movl   $0x107c1c,0xc(%esp)
  1045f6:	00 
  1045f7:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  1045fe:	00 
  1045ff:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  104606:	00 
  104607:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  10460e:	e8 d6 bd ff ff       	call   1003e9 <__panic>
        p->flags = 0;
  104613:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104616:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  10461d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104624:	00 
  104625:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104628:	89 04 24             	mov    %eax,(%esp)
  10462b:	e8 0f fc ff ff       	call   10423f <set_page_ref>
    for (; p != base + n; p ++) {
  104630:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104634:	8b 55 0c             	mov    0xc(%ebp),%edx
  104637:	89 d0                	mov    %edx,%eax
  104639:	c1 e0 02             	shl    $0x2,%eax
  10463c:	01 d0                	add    %edx,%eax
  10463e:	c1 e0 02             	shl    $0x2,%eax
  104641:	89 c2                	mov    %eax,%edx
  104643:	8b 45 08             	mov    0x8(%ebp),%eax
  104646:	01 d0                	add    %edx,%eax
  104648:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10464b:	0f 85 46 ff ff ff    	jne    104597 <default_free_pages+0x3e>
    }
    base->property = n;
  104651:	8b 45 08             	mov    0x8(%ebp),%eax
  104654:	8b 55 0c             	mov    0xc(%ebp),%edx
  104657:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  10465a:	8b 45 08             	mov    0x8(%ebp),%eax
  10465d:	83 c0 04             	add    $0x4,%eax
  104660:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104667:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10466a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10466d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104670:	0f ab 10             	bts    %edx,(%eax)
  104673:	c7 45 d4 20 df 11 00 	movl   $0x11df20,-0x2c(%ebp)
    return listelm->next;
  10467a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10467d:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  104680:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  104683:	e9 08 01 00 00       	jmp    104790 <default_free_pages+0x237>
        p = le2page(le, page_link);
  104688:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10468b:	83 e8 0c             	sub    $0xc,%eax
  10468e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104694:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104697:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10469a:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  10469d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  1046a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1046a3:	8b 50 08             	mov    0x8(%eax),%edx
  1046a6:	89 d0                	mov    %edx,%eax
  1046a8:	c1 e0 02             	shl    $0x2,%eax
  1046ab:	01 d0                	add    %edx,%eax
  1046ad:	c1 e0 02             	shl    $0x2,%eax
  1046b0:	89 c2                	mov    %eax,%edx
  1046b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1046b5:	01 d0                	add    %edx,%eax
  1046b7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1046ba:	75 5a                	jne    104716 <default_free_pages+0x1bd>
            base->property += p->property;
  1046bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1046bf:	8b 50 08             	mov    0x8(%eax),%edx
  1046c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046c5:	8b 40 08             	mov    0x8(%eax),%eax
  1046c8:	01 c2                	add    %eax,%edx
  1046ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1046cd:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  1046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046d3:	83 c0 04             	add    $0x4,%eax
  1046d6:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  1046dd:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1046e0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1046e3:	8b 55 b8             	mov    -0x48(%ebp),%edx
  1046e6:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  1046e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046ec:	83 c0 0c             	add    $0xc,%eax
  1046ef:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  1046f2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1046f5:	8b 40 04             	mov    0x4(%eax),%eax
  1046f8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1046fb:	8b 12                	mov    (%edx),%edx
  1046fd:	89 55 c0             	mov    %edx,-0x40(%ebp)
  104700:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  104703:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104706:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104709:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  10470c:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10470f:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104712:	89 10                	mov    %edx,(%eax)
  104714:	eb 7a                	jmp    104790 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  104716:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104719:	8b 50 08             	mov    0x8(%eax),%edx
  10471c:	89 d0                	mov    %edx,%eax
  10471e:	c1 e0 02             	shl    $0x2,%eax
  104721:	01 d0                	add    %edx,%eax
  104723:	c1 e0 02             	shl    $0x2,%eax
  104726:	89 c2                	mov    %eax,%edx
  104728:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10472b:	01 d0                	add    %edx,%eax
  10472d:	39 45 08             	cmp    %eax,0x8(%ebp)
  104730:	75 5e                	jne    104790 <default_free_pages+0x237>
            p->property += base->property;
  104732:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104735:	8b 50 08             	mov    0x8(%eax),%edx
  104738:	8b 45 08             	mov    0x8(%ebp),%eax
  10473b:	8b 40 08             	mov    0x8(%eax),%eax
  10473e:	01 c2                	add    %eax,%edx
  104740:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104743:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  104746:	8b 45 08             	mov    0x8(%ebp),%eax
  104749:	83 c0 04             	add    $0x4,%eax
  10474c:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  104753:	89 45 a0             	mov    %eax,-0x60(%ebp)
  104756:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104759:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  10475c:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  10475f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104762:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  104765:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104768:	83 c0 0c             	add    $0xc,%eax
  10476b:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  10476e:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104771:	8b 40 04             	mov    0x4(%eax),%eax
  104774:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104777:	8b 12                	mov    (%edx),%edx
  104779:	89 55 ac             	mov    %edx,-0x54(%ebp)
  10477c:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  10477f:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104782:	8b 55 a8             	mov    -0x58(%ebp),%edx
  104785:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104788:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10478b:	8b 55 ac             	mov    -0x54(%ebp),%edx
  10478e:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
  104790:	81 7d f0 20 df 11 00 	cmpl   $0x11df20,-0x10(%ebp)
  104797:	0f 85 eb fe ff ff    	jne    104688 <default_free_pages+0x12f>
        }
    }
    SetPageProperty(base);
  10479d:	8b 45 08             	mov    0x8(%ebp),%eax
  1047a0:	83 c0 04             	add    $0x4,%eax
  1047a3:	c7 45 98 01 00 00 00 	movl   $0x1,-0x68(%ebp)
  1047aa:	89 45 94             	mov    %eax,-0x6c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1047ad:	8b 45 94             	mov    -0x6c(%ebp),%eax
  1047b0:	8b 55 98             	mov    -0x68(%ebp),%edx
  1047b3:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  1047b6:	8b 15 28 df 11 00    	mov    0x11df28,%edx
  1047bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047bf:	01 d0                	add    %edx,%eax
  1047c1:	a3 28 df 11 00       	mov    %eax,0x11df28
  1047c6:	c7 45 9c 20 df 11 00 	movl   $0x11df20,-0x64(%ebp)
    return listelm->next;
  1047cd:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1047d0:	8b 40 04             	mov    0x4(%eax),%eax
    le=list_next(&free_list);
  1047d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
  1047d6:	eb 0f                	jmp    1047e7 <default_free_pages+0x28e>
  1047d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1047db:	89 45 90             	mov    %eax,-0x70(%ebp)
  1047de:	8b 45 90             	mov    -0x70(%ebp),%eax
  1047e1:	8b 40 04             	mov    0x4(%eax),%eax
	le=list_next(le);
  1047e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
  1047e7:	81 7d f0 20 df 11 00 	cmpl   $0x11df20,-0x10(%ebp)
  1047ee:	74 0b                	je     1047fb <default_free_pages+0x2a2>
  1047f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1047f3:	83 e8 0c             	sub    $0xc,%eax
  1047f6:	39 45 08             	cmp    %eax,0x8(%ebp)
  1047f9:	77 dd                	ja     1047d8 <default_free_pages+0x27f>
    }
    list_add_before(le, &(base->page_link));
  1047fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1047fe:	8d 50 0c             	lea    0xc(%eax),%edx
  104801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104804:	89 45 8c             	mov    %eax,-0x74(%ebp)
  104807:	89 55 88             	mov    %edx,-0x78(%ebp)
    __list_add(elm, listelm->prev, listelm);
  10480a:	8b 45 8c             	mov    -0x74(%ebp),%eax
  10480d:	8b 00                	mov    (%eax),%eax
  10480f:	8b 55 88             	mov    -0x78(%ebp),%edx
  104812:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104815:	89 45 80             	mov    %eax,-0x80(%ebp)
  104818:	8b 45 8c             	mov    -0x74(%ebp),%eax
  10481b:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
    prev->next = next->prev = elm;
  104821:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  104827:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10482a:	89 10                	mov    %edx,(%eax)
  10482c:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  104832:	8b 10                	mov    (%eax),%edx
  104834:	8b 45 80             	mov    -0x80(%ebp),%eax
  104837:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10483a:	8b 45 84             	mov    -0x7c(%ebp),%eax
  10483d:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  104843:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104846:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104849:	8b 55 80             	mov    -0x80(%ebp),%edx
  10484c:	89 10                	mov    %edx,(%eax)
}
  10484e:	90                   	nop
  10484f:	c9                   	leave  
  104850:	c3                   	ret    

00104851 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  104851:	55                   	push   %ebp
  104852:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104854:	a1 28 df 11 00       	mov    0x11df28,%eax
}
  104859:	5d                   	pop    %ebp
  10485a:	c3                   	ret    

0010485b <basic_check>:

static void
basic_check(void) {
  10485b:	55                   	push   %ebp
  10485c:	89 e5                	mov    %esp,%ebp
  10485e:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  104861:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10486b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10486e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104871:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  104874:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10487b:	e8 d8 e2 ff ff       	call   102b58 <alloc_pages>
  104880:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104883:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104887:	75 24                	jne    1048ad <basic_check+0x52>
  104889:	c7 44 24 0c 41 7c 10 	movl   $0x107c41,0xc(%esp)
  104890:	00 
  104891:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104898:	00 
  104899:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
  1048a0:	00 
  1048a1:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  1048a8:	e8 3c bb ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  1048ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1048b4:	e8 9f e2 ff ff       	call   102b58 <alloc_pages>
  1048b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1048bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1048c0:	75 24                	jne    1048e6 <basic_check+0x8b>
  1048c2:	c7 44 24 0c 5d 7c 10 	movl   $0x107c5d,0xc(%esp)
  1048c9:	00 
  1048ca:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  1048d1:	00 
  1048d2:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
  1048d9:	00 
  1048da:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  1048e1:	e8 03 bb ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1048e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1048ed:	e8 66 e2 ff ff       	call   102b58 <alloc_pages>
  1048f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1048f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1048f9:	75 24                	jne    10491f <basic_check+0xc4>
  1048fb:	c7 44 24 0c 79 7c 10 	movl   $0x107c79,0xc(%esp)
  104902:	00 
  104903:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  10490a:	00 
  10490b:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  104912:	00 
  104913:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  10491a:	e8 ca ba ff ff       	call   1003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  10491f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104922:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104925:	74 10                	je     104937 <basic_check+0xdc>
  104927:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10492a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10492d:	74 08                	je     104937 <basic_check+0xdc>
  10492f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104932:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104935:	75 24                	jne    10495b <basic_check+0x100>
  104937:	c7 44 24 0c 98 7c 10 	movl   $0x107c98,0xc(%esp)
  10493e:	00 
  10493f:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104946:	00 
  104947:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
  10494e:	00 
  10494f:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104956:	e8 8e ba ff ff       	call   1003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  10495b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10495e:	89 04 24             	mov    %eax,(%esp)
  104961:	e8 cf f8 ff ff       	call   104235 <page_ref>
  104966:	85 c0                	test   %eax,%eax
  104968:	75 1e                	jne    104988 <basic_check+0x12d>
  10496a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10496d:	89 04 24             	mov    %eax,(%esp)
  104970:	e8 c0 f8 ff ff       	call   104235 <page_ref>
  104975:	85 c0                	test   %eax,%eax
  104977:	75 0f                	jne    104988 <basic_check+0x12d>
  104979:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10497c:	89 04 24             	mov    %eax,(%esp)
  10497f:	e8 b1 f8 ff ff       	call   104235 <page_ref>
  104984:	85 c0                	test   %eax,%eax
  104986:	74 24                	je     1049ac <basic_check+0x151>
  104988:	c7 44 24 0c bc 7c 10 	movl   $0x107cbc,0xc(%esp)
  10498f:	00 
  104990:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104997:	00 
  104998:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
  10499f:	00 
  1049a0:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  1049a7:	e8 3d ba ff ff       	call   1003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  1049ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049af:	89 04 24             	mov    %eax,(%esp)
  1049b2:	e8 68 f8 ff ff       	call   10421f <page2pa>
  1049b7:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  1049bd:	c1 e2 0c             	shl    $0xc,%edx
  1049c0:	39 d0                	cmp    %edx,%eax
  1049c2:	72 24                	jb     1049e8 <basic_check+0x18d>
  1049c4:	c7 44 24 0c f8 7c 10 	movl   $0x107cf8,0xc(%esp)
  1049cb:	00 
  1049cc:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  1049d3:	00 
  1049d4:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  1049db:	00 
  1049dc:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  1049e3:	e8 01 ba ff ff       	call   1003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  1049e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049eb:	89 04 24             	mov    %eax,(%esp)
  1049ee:	e8 2c f8 ff ff       	call   10421f <page2pa>
  1049f3:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  1049f9:	c1 e2 0c             	shl    $0xc,%edx
  1049fc:	39 d0                	cmp    %edx,%eax
  1049fe:	72 24                	jb     104a24 <basic_check+0x1c9>
  104a00:	c7 44 24 0c 15 7d 10 	movl   $0x107d15,0xc(%esp)
  104a07:	00 
  104a08:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104a0f:	00 
  104a10:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
  104a17:	00 
  104a18:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104a1f:	e8 c5 b9 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a27:	89 04 24             	mov    %eax,(%esp)
  104a2a:	e8 f0 f7 ff ff       	call   10421f <page2pa>
  104a2f:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  104a35:	c1 e2 0c             	shl    $0xc,%edx
  104a38:	39 d0                	cmp    %edx,%eax
  104a3a:	72 24                	jb     104a60 <basic_check+0x205>
  104a3c:	c7 44 24 0c 32 7d 10 	movl   $0x107d32,0xc(%esp)
  104a43:	00 
  104a44:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104a4b:	00 
  104a4c:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  104a53:	00 
  104a54:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104a5b:	e8 89 b9 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104a60:	a1 20 df 11 00       	mov    0x11df20,%eax
  104a65:	8b 15 24 df 11 00    	mov    0x11df24,%edx
  104a6b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104a6e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104a71:	c7 45 dc 20 df 11 00 	movl   $0x11df20,-0x24(%ebp)
    elm->prev = elm->next = elm;
  104a78:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104a7b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104a7e:	89 50 04             	mov    %edx,0x4(%eax)
  104a81:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104a84:	8b 50 04             	mov    0x4(%eax),%edx
  104a87:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104a8a:	89 10                	mov    %edx,(%eax)
  104a8c:	c7 45 e0 20 df 11 00 	movl   $0x11df20,-0x20(%ebp)
    return list->next == list;
  104a93:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104a96:	8b 40 04             	mov    0x4(%eax),%eax
  104a99:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104a9c:	0f 94 c0             	sete   %al
  104a9f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104aa2:	85 c0                	test   %eax,%eax
  104aa4:	75 24                	jne    104aca <basic_check+0x26f>
  104aa6:	c7 44 24 0c 4f 7d 10 	movl   $0x107d4f,0xc(%esp)
  104aad:	00 
  104aae:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104ab5:	00 
  104ab6:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  104abd:	00 
  104abe:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104ac5:	e8 1f b9 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104aca:	a1 28 df 11 00       	mov    0x11df28,%eax
  104acf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104ad2:	c7 05 28 df 11 00 00 	movl   $0x0,0x11df28
  104ad9:	00 00 00 

    assert(alloc_page() == NULL);
  104adc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ae3:	e8 70 e0 ff ff       	call   102b58 <alloc_pages>
  104ae8:	85 c0                	test   %eax,%eax
  104aea:	74 24                	je     104b10 <basic_check+0x2b5>
  104aec:	c7 44 24 0c 66 7d 10 	movl   $0x107d66,0xc(%esp)
  104af3:	00 
  104af4:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104afb:	00 
  104afc:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  104b03:	00 
  104b04:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104b0b:	e8 d9 b8 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104b10:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b17:	00 
  104b18:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b1b:	89 04 24             	mov    %eax,(%esp)
  104b1e:	e8 6d e0 ff ff       	call   102b90 <free_pages>
    free_page(p1);
  104b23:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b2a:	00 
  104b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b2e:	89 04 24             	mov    %eax,(%esp)
  104b31:	e8 5a e0 ff ff       	call   102b90 <free_pages>
    free_page(p2);
  104b36:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b3d:	00 
  104b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b41:	89 04 24             	mov    %eax,(%esp)
  104b44:	e8 47 e0 ff ff       	call   102b90 <free_pages>
    assert(nr_free == 3);
  104b49:	a1 28 df 11 00       	mov    0x11df28,%eax
  104b4e:	83 f8 03             	cmp    $0x3,%eax
  104b51:	74 24                	je     104b77 <basic_check+0x31c>
  104b53:	c7 44 24 0c 7b 7d 10 	movl   $0x107d7b,0xc(%esp)
  104b5a:	00 
  104b5b:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104b62:	00 
  104b63:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  104b6a:	00 
  104b6b:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104b72:	e8 72 b8 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  104b77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b7e:	e8 d5 df ff ff       	call   102b58 <alloc_pages>
  104b83:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104b86:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104b8a:	75 24                	jne    104bb0 <basic_check+0x355>
  104b8c:	c7 44 24 0c 41 7c 10 	movl   $0x107c41,0xc(%esp)
  104b93:	00 
  104b94:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104b9b:	00 
  104b9c:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  104ba3:	00 
  104ba4:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104bab:	e8 39 b8 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104bb0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104bb7:	e8 9c df ff ff       	call   102b58 <alloc_pages>
  104bbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104bbf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104bc3:	75 24                	jne    104be9 <basic_check+0x38e>
  104bc5:	c7 44 24 0c 5d 7c 10 	movl   $0x107c5d,0xc(%esp)
  104bcc:	00 
  104bcd:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104bd4:	00 
  104bd5:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  104bdc:	00 
  104bdd:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104be4:	e8 00 b8 ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104be9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104bf0:	e8 63 df ff ff       	call   102b58 <alloc_pages>
  104bf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104bf8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104bfc:	75 24                	jne    104c22 <basic_check+0x3c7>
  104bfe:	c7 44 24 0c 79 7c 10 	movl   $0x107c79,0xc(%esp)
  104c05:	00 
  104c06:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104c0d:	00 
  104c0e:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  104c15:	00 
  104c16:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104c1d:	e8 c7 b7 ff ff       	call   1003e9 <__panic>

    assert(alloc_page() == NULL);
  104c22:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c29:	e8 2a df ff ff       	call   102b58 <alloc_pages>
  104c2e:	85 c0                	test   %eax,%eax
  104c30:	74 24                	je     104c56 <basic_check+0x3fb>
  104c32:	c7 44 24 0c 66 7d 10 	movl   $0x107d66,0xc(%esp)
  104c39:	00 
  104c3a:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104c41:	00 
  104c42:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  104c49:	00 
  104c4a:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104c51:	e8 93 b7 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104c56:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104c5d:	00 
  104c5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c61:	89 04 24             	mov    %eax,(%esp)
  104c64:	e8 27 df ff ff       	call   102b90 <free_pages>
  104c69:	c7 45 d8 20 df 11 00 	movl   $0x11df20,-0x28(%ebp)
  104c70:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104c73:	8b 40 04             	mov    0x4(%eax),%eax
  104c76:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104c79:	0f 94 c0             	sete   %al
  104c7c:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104c7f:	85 c0                	test   %eax,%eax
  104c81:	74 24                	je     104ca7 <basic_check+0x44c>
  104c83:	c7 44 24 0c 88 7d 10 	movl   $0x107d88,0xc(%esp)
  104c8a:	00 
  104c8b:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104c92:	00 
  104c93:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  104c9a:	00 
  104c9b:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104ca2:	e8 42 b7 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104ca7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104cae:	e8 a5 de ff ff       	call   102b58 <alloc_pages>
  104cb3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104cb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104cb9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104cbc:	74 24                	je     104ce2 <basic_check+0x487>
  104cbe:	c7 44 24 0c a0 7d 10 	movl   $0x107da0,0xc(%esp)
  104cc5:	00 
  104cc6:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104ccd:	00 
  104cce:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  104cd5:	00 
  104cd6:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104cdd:	e8 07 b7 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104ce2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ce9:	e8 6a de ff ff       	call   102b58 <alloc_pages>
  104cee:	85 c0                	test   %eax,%eax
  104cf0:	74 24                	je     104d16 <basic_check+0x4bb>
  104cf2:	c7 44 24 0c 66 7d 10 	movl   $0x107d66,0xc(%esp)
  104cf9:	00 
  104cfa:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104d01:	00 
  104d02:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  104d09:	00 
  104d0a:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104d11:	e8 d3 b6 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  104d16:	a1 28 df 11 00       	mov    0x11df28,%eax
  104d1b:	85 c0                	test   %eax,%eax
  104d1d:	74 24                	je     104d43 <basic_check+0x4e8>
  104d1f:	c7 44 24 0c b9 7d 10 	movl   $0x107db9,0xc(%esp)
  104d26:	00 
  104d27:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104d2e:	00 
  104d2f:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  104d36:	00 
  104d37:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104d3e:	e8 a6 b6 ff ff       	call   1003e9 <__panic>
    free_list = free_list_store;
  104d43:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104d46:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104d49:	a3 20 df 11 00       	mov    %eax,0x11df20
  104d4e:	89 15 24 df 11 00    	mov    %edx,0x11df24
    nr_free = nr_free_store;
  104d54:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104d57:	a3 28 df 11 00       	mov    %eax,0x11df28

    free_page(p);
  104d5c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d63:	00 
  104d64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d67:	89 04 24             	mov    %eax,(%esp)
  104d6a:	e8 21 de ff ff       	call   102b90 <free_pages>
    free_page(p1);
  104d6f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d76:	00 
  104d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d7a:	89 04 24             	mov    %eax,(%esp)
  104d7d:	e8 0e de ff ff       	call   102b90 <free_pages>
    free_page(p2);
  104d82:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d89:	00 
  104d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d8d:	89 04 24             	mov    %eax,(%esp)
  104d90:	e8 fb dd ff ff       	call   102b90 <free_pages>
}
  104d95:	90                   	nop
  104d96:	c9                   	leave  
  104d97:	c3                   	ret    

00104d98 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104d98:	55                   	push   %ebp
  104d99:	89 e5                	mov    %esp,%ebp
  104d9b:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  104da1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104da8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104daf:	c7 45 ec 20 df 11 00 	movl   $0x11df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104db6:	eb 6a                	jmp    104e22 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  104db8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104dbb:	83 e8 0c             	sub    $0xc,%eax
  104dbe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  104dc1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104dc4:	83 c0 04             	add    $0x4,%eax
  104dc7:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104dce:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104dd1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104dd4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104dd7:	0f a3 10             	bt     %edx,(%eax)
  104dda:	19 c0                	sbb    %eax,%eax
  104ddc:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104ddf:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  104de3:	0f 95 c0             	setne  %al
  104de6:	0f b6 c0             	movzbl %al,%eax
  104de9:	85 c0                	test   %eax,%eax
  104deb:	75 24                	jne    104e11 <default_check+0x79>
  104ded:	c7 44 24 0c c6 7d 10 	movl   $0x107dc6,0xc(%esp)
  104df4:	00 
  104df5:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104dfc:	00 
  104dfd:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  104e04:	00 
  104e05:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104e0c:	e8 d8 b5 ff ff       	call   1003e9 <__panic>
        count ++, total += p->property;
  104e11:	ff 45 f4             	incl   -0xc(%ebp)
  104e14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104e17:	8b 50 08             	mov    0x8(%eax),%edx
  104e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e1d:	01 d0                	add    %edx,%eax
  104e1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104e22:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e25:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  104e28:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104e2b:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104e2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104e31:	81 7d ec 20 df 11 00 	cmpl   $0x11df20,-0x14(%ebp)
  104e38:	0f 85 7a ff ff ff    	jne    104db8 <default_check+0x20>
    }
    assert(total == nr_free_pages());
  104e3e:	e8 80 dd ff ff       	call   102bc3 <nr_free_pages>
  104e43:	89 c2                	mov    %eax,%edx
  104e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e48:	39 c2                	cmp    %eax,%edx
  104e4a:	74 24                	je     104e70 <default_check+0xd8>
  104e4c:	c7 44 24 0c d6 7d 10 	movl   $0x107dd6,0xc(%esp)
  104e53:	00 
  104e54:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104e5b:	00 
  104e5c:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  104e63:	00 
  104e64:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104e6b:	e8 79 b5 ff ff       	call   1003e9 <__panic>

    basic_check();
  104e70:	e8 e6 f9 ff ff       	call   10485b <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104e75:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104e7c:	e8 d7 dc ff ff       	call   102b58 <alloc_pages>
  104e81:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  104e84:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104e88:	75 24                	jne    104eae <default_check+0x116>
  104e8a:	c7 44 24 0c ef 7d 10 	movl   $0x107def,0xc(%esp)
  104e91:	00 
  104e92:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104e99:	00 
  104e9a:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
  104ea1:	00 
  104ea2:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104ea9:	e8 3b b5 ff ff       	call   1003e9 <__panic>
    assert(!PageProperty(p0));
  104eae:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104eb1:	83 c0 04             	add    $0x4,%eax
  104eb4:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104ebb:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104ebe:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104ec1:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104ec4:	0f a3 10             	bt     %edx,(%eax)
  104ec7:	19 c0                	sbb    %eax,%eax
  104ec9:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104ecc:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  104ed0:	0f 95 c0             	setne  %al
  104ed3:	0f b6 c0             	movzbl %al,%eax
  104ed6:	85 c0                	test   %eax,%eax
  104ed8:	74 24                	je     104efe <default_check+0x166>
  104eda:	c7 44 24 0c fa 7d 10 	movl   $0x107dfa,0xc(%esp)
  104ee1:	00 
  104ee2:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104ee9:	00 
  104eea:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  104ef1:	00 
  104ef2:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104ef9:	e8 eb b4 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104efe:	a1 20 df 11 00       	mov    0x11df20,%eax
  104f03:	8b 15 24 df 11 00    	mov    0x11df24,%edx
  104f09:	89 45 80             	mov    %eax,-0x80(%ebp)
  104f0c:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104f0f:	c7 45 b0 20 df 11 00 	movl   $0x11df20,-0x50(%ebp)
    elm->prev = elm->next = elm;
  104f16:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104f19:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104f1c:	89 50 04             	mov    %edx,0x4(%eax)
  104f1f:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104f22:	8b 50 04             	mov    0x4(%eax),%edx
  104f25:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104f28:	89 10                	mov    %edx,(%eax)
  104f2a:	c7 45 b4 20 df 11 00 	movl   $0x11df20,-0x4c(%ebp)
    return list->next == list;
  104f31:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104f34:	8b 40 04             	mov    0x4(%eax),%eax
  104f37:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  104f3a:	0f 94 c0             	sete   %al
  104f3d:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104f40:	85 c0                	test   %eax,%eax
  104f42:	75 24                	jne    104f68 <default_check+0x1d0>
  104f44:	c7 44 24 0c 4f 7d 10 	movl   $0x107d4f,0xc(%esp)
  104f4b:	00 
  104f4c:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104f53:	00 
  104f54:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
  104f5b:	00 
  104f5c:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104f63:	e8 81 b4 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104f68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104f6f:	e8 e4 db ff ff       	call   102b58 <alloc_pages>
  104f74:	85 c0                	test   %eax,%eax
  104f76:	74 24                	je     104f9c <default_check+0x204>
  104f78:	c7 44 24 0c 66 7d 10 	movl   $0x107d66,0xc(%esp)
  104f7f:	00 
  104f80:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104f87:	00 
  104f88:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
  104f8f:	00 
  104f90:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104f97:	e8 4d b4 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104f9c:	a1 28 df 11 00       	mov    0x11df28,%eax
  104fa1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  104fa4:	c7 05 28 df 11 00 00 	movl   $0x0,0x11df28
  104fab:	00 00 00 

    free_pages(p0 + 2, 3);
  104fae:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104fb1:	83 c0 28             	add    $0x28,%eax
  104fb4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104fbb:	00 
  104fbc:	89 04 24             	mov    %eax,(%esp)
  104fbf:	e8 cc db ff ff       	call   102b90 <free_pages>
    assert(alloc_pages(4) == NULL);
  104fc4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  104fcb:	e8 88 db ff ff       	call   102b58 <alloc_pages>
  104fd0:	85 c0                	test   %eax,%eax
  104fd2:	74 24                	je     104ff8 <default_check+0x260>
  104fd4:	c7 44 24 0c 0c 7e 10 	movl   $0x107e0c,0xc(%esp)
  104fdb:	00 
  104fdc:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  104fe3:	00 
  104fe4:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  104feb:	00 
  104fec:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  104ff3:	e8 f1 b3 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  104ff8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104ffb:	83 c0 28             	add    $0x28,%eax
  104ffe:	83 c0 04             	add    $0x4,%eax
  105001:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  105008:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10500b:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10500e:	8b 55 ac             	mov    -0x54(%ebp),%edx
  105011:	0f a3 10             	bt     %edx,(%eax)
  105014:	19 c0                	sbb    %eax,%eax
  105016:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  105019:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  10501d:	0f 95 c0             	setne  %al
  105020:	0f b6 c0             	movzbl %al,%eax
  105023:	85 c0                	test   %eax,%eax
  105025:	74 0e                	je     105035 <default_check+0x29d>
  105027:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10502a:	83 c0 28             	add    $0x28,%eax
  10502d:	8b 40 08             	mov    0x8(%eax),%eax
  105030:	83 f8 03             	cmp    $0x3,%eax
  105033:	74 24                	je     105059 <default_check+0x2c1>
  105035:	c7 44 24 0c 24 7e 10 	movl   $0x107e24,0xc(%esp)
  10503c:	00 
  10503d:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  105044:	00 
  105045:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
  10504c:	00 
  10504d:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  105054:	e8 90 b3 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  105059:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  105060:	e8 f3 da ff ff       	call   102b58 <alloc_pages>
  105065:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105068:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10506c:	75 24                	jne    105092 <default_check+0x2fa>
  10506e:	c7 44 24 0c 50 7e 10 	movl   $0x107e50,0xc(%esp)
  105075:	00 
  105076:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  10507d:	00 
  10507e:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  105085:	00 
  105086:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  10508d:	e8 57 b3 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  105092:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105099:	e8 ba da ff ff       	call   102b58 <alloc_pages>
  10509e:	85 c0                	test   %eax,%eax
  1050a0:	74 24                	je     1050c6 <default_check+0x32e>
  1050a2:	c7 44 24 0c 66 7d 10 	movl   $0x107d66,0xc(%esp)
  1050a9:	00 
  1050aa:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  1050b1:	00 
  1050b2:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
  1050b9:	00 
  1050ba:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  1050c1:	e8 23 b3 ff ff       	call   1003e9 <__panic>
    assert(p0 + 2 == p1);
  1050c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1050c9:	83 c0 28             	add    $0x28,%eax
  1050cc:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  1050cf:	74 24                	je     1050f5 <default_check+0x35d>
  1050d1:	c7 44 24 0c 6e 7e 10 	movl   $0x107e6e,0xc(%esp)
  1050d8:	00 
  1050d9:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  1050e0:	00 
  1050e1:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
  1050e8:	00 
  1050e9:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  1050f0:	e8 f4 b2 ff ff       	call   1003e9 <__panic>

    p2 = p0 + 1;
  1050f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1050f8:	83 c0 14             	add    $0x14,%eax
  1050fb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  1050fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105105:	00 
  105106:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105109:	89 04 24             	mov    %eax,(%esp)
  10510c:	e8 7f da ff ff       	call   102b90 <free_pages>
    free_pages(p1, 3);
  105111:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  105118:	00 
  105119:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10511c:	89 04 24             	mov    %eax,(%esp)
  10511f:	e8 6c da ff ff       	call   102b90 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  105124:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105127:	83 c0 04             	add    $0x4,%eax
  10512a:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  105131:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105134:	8b 45 9c             	mov    -0x64(%ebp),%eax
  105137:	8b 55 a0             	mov    -0x60(%ebp),%edx
  10513a:	0f a3 10             	bt     %edx,(%eax)
  10513d:	19 c0                	sbb    %eax,%eax
  10513f:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  105142:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  105146:	0f 95 c0             	setne  %al
  105149:	0f b6 c0             	movzbl %al,%eax
  10514c:	85 c0                	test   %eax,%eax
  10514e:	74 0b                	je     10515b <default_check+0x3c3>
  105150:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105153:	8b 40 08             	mov    0x8(%eax),%eax
  105156:	83 f8 01             	cmp    $0x1,%eax
  105159:	74 24                	je     10517f <default_check+0x3e7>
  10515b:	c7 44 24 0c 7c 7e 10 	movl   $0x107e7c,0xc(%esp)
  105162:	00 
  105163:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  10516a:	00 
  10516b:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
  105172:	00 
  105173:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  10517a:	e8 6a b2 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  10517f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105182:	83 c0 04             	add    $0x4,%eax
  105185:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  10518c:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10518f:	8b 45 90             	mov    -0x70(%ebp),%eax
  105192:	8b 55 94             	mov    -0x6c(%ebp),%edx
  105195:	0f a3 10             	bt     %edx,(%eax)
  105198:	19 c0                	sbb    %eax,%eax
  10519a:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  10519d:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  1051a1:	0f 95 c0             	setne  %al
  1051a4:	0f b6 c0             	movzbl %al,%eax
  1051a7:	85 c0                	test   %eax,%eax
  1051a9:	74 0b                	je     1051b6 <default_check+0x41e>
  1051ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051ae:	8b 40 08             	mov    0x8(%eax),%eax
  1051b1:	83 f8 03             	cmp    $0x3,%eax
  1051b4:	74 24                	je     1051da <default_check+0x442>
  1051b6:	c7 44 24 0c a4 7e 10 	movl   $0x107ea4,0xc(%esp)
  1051bd:	00 
  1051be:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  1051c5:	00 
  1051c6:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
  1051cd:	00 
  1051ce:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  1051d5:	e8 0f b2 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1051da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1051e1:	e8 72 d9 ff ff       	call   102b58 <alloc_pages>
  1051e6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1051e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1051ec:	83 e8 14             	sub    $0x14,%eax
  1051ef:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1051f2:	74 24                	je     105218 <default_check+0x480>
  1051f4:	c7 44 24 0c ca 7e 10 	movl   $0x107eca,0xc(%esp)
  1051fb:	00 
  1051fc:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  105203:	00 
  105204:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
  10520b:	00 
  10520c:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  105213:	e8 d1 b1 ff ff       	call   1003e9 <__panic>
    free_page(p0);
  105218:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10521f:	00 
  105220:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105223:	89 04 24             	mov    %eax,(%esp)
  105226:	e8 65 d9 ff ff       	call   102b90 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  10522b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  105232:	e8 21 d9 ff ff       	call   102b58 <alloc_pages>
  105237:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10523a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10523d:	83 c0 14             	add    $0x14,%eax
  105240:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105243:	74 24                	je     105269 <default_check+0x4d1>
  105245:	c7 44 24 0c e8 7e 10 	movl   $0x107ee8,0xc(%esp)
  10524c:	00 
  10524d:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  105254:	00 
  105255:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
  10525c:	00 
  10525d:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  105264:	e8 80 b1 ff ff       	call   1003e9 <__panic>

    free_pages(p0, 2);
  105269:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  105270:	00 
  105271:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105274:	89 04 24             	mov    %eax,(%esp)
  105277:	e8 14 d9 ff ff       	call   102b90 <free_pages>
    free_page(p2);
  10527c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105283:	00 
  105284:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105287:	89 04 24             	mov    %eax,(%esp)
  10528a:	e8 01 d9 ff ff       	call   102b90 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  10528f:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  105296:	e8 bd d8 ff ff       	call   102b58 <alloc_pages>
  10529b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10529e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1052a2:	75 24                	jne    1052c8 <default_check+0x530>
  1052a4:	c7 44 24 0c 08 7f 10 	movl   $0x107f08,0xc(%esp)
  1052ab:	00 
  1052ac:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  1052b3:	00 
  1052b4:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
  1052bb:	00 
  1052bc:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  1052c3:	e8 21 b1 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  1052c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1052cf:	e8 84 d8 ff ff       	call   102b58 <alloc_pages>
  1052d4:	85 c0                	test   %eax,%eax
  1052d6:	74 24                	je     1052fc <default_check+0x564>
  1052d8:	c7 44 24 0c 66 7d 10 	movl   $0x107d66,0xc(%esp)
  1052df:	00 
  1052e0:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  1052e7:	00 
  1052e8:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
  1052ef:	00 
  1052f0:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  1052f7:	e8 ed b0 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  1052fc:	a1 28 df 11 00       	mov    0x11df28,%eax
  105301:	85 c0                	test   %eax,%eax
  105303:	74 24                	je     105329 <default_check+0x591>
  105305:	c7 44 24 0c b9 7d 10 	movl   $0x107db9,0xc(%esp)
  10530c:	00 
  10530d:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  105314:	00 
  105315:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
  10531c:	00 
  10531d:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  105324:	e8 c0 b0 ff ff       	call   1003e9 <__panic>
    nr_free = nr_free_store;
  105329:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10532c:	a3 28 df 11 00       	mov    %eax,0x11df28

    free_list = free_list_store;
  105331:	8b 45 80             	mov    -0x80(%ebp),%eax
  105334:	8b 55 84             	mov    -0x7c(%ebp),%edx
  105337:	a3 20 df 11 00       	mov    %eax,0x11df20
  10533c:	89 15 24 df 11 00    	mov    %edx,0x11df24
    free_pages(p0, 5);
  105342:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  105349:	00 
  10534a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10534d:	89 04 24             	mov    %eax,(%esp)
  105350:	e8 3b d8 ff ff       	call   102b90 <free_pages>

    le = &free_list;
  105355:	c7 45 ec 20 df 11 00 	movl   $0x11df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10535c:	eb 5a                	jmp    1053b8 <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
  10535e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105361:	8b 40 04             	mov    0x4(%eax),%eax
  105364:	8b 00                	mov    (%eax),%eax
  105366:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  105369:	75 0d                	jne    105378 <default_check+0x5e0>
  10536b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10536e:	8b 00                	mov    (%eax),%eax
  105370:	8b 40 04             	mov    0x4(%eax),%eax
  105373:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  105376:	74 24                	je     10539c <default_check+0x604>
  105378:	c7 44 24 0c 28 7f 10 	movl   $0x107f28,0xc(%esp)
  10537f:	00 
  105380:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  105387:	00 
  105388:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
  10538f:	00 
  105390:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  105397:	e8 4d b0 ff ff       	call   1003e9 <__panic>
        struct Page *p = le2page(le, page_link);
  10539c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10539f:	83 e8 0c             	sub    $0xc,%eax
  1053a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  1053a5:	ff 4d f4             	decl   -0xc(%ebp)
  1053a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1053ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1053ae:	8b 40 08             	mov    0x8(%eax),%eax
  1053b1:	29 c2                	sub    %eax,%edx
  1053b3:	89 d0                	mov    %edx,%eax
  1053b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1053b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1053bb:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  1053be:	8b 45 88             	mov    -0x78(%ebp),%eax
  1053c1:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  1053c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1053c7:	81 7d ec 20 df 11 00 	cmpl   $0x11df20,-0x14(%ebp)
  1053ce:	75 8e                	jne    10535e <default_check+0x5c6>
    }
    assert(count == 0);
  1053d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1053d4:	74 24                	je     1053fa <default_check+0x662>
  1053d6:	c7 44 24 0c 55 7f 10 	movl   $0x107f55,0xc(%esp)
  1053dd:	00 
  1053de:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  1053e5:	00 
  1053e6:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
  1053ed:	00 
  1053ee:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  1053f5:	e8 ef af ff ff       	call   1003e9 <__panic>
    assert(total == 0);
  1053fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1053fe:	74 24                	je     105424 <default_check+0x68c>
  105400:	c7 44 24 0c 60 7f 10 	movl   $0x107f60,0xc(%esp)
  105407:	00 
  105408:	c7 44 24 08 de 7b 10 	movl   $0x107bde,0x8(%esp)
  10540f:	00 
  105410:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
  105417:	00 
  105418:	c7 04 24 f3 7b 10 00 	movl   $0x107bf3,(%esp)
  10541f:	e8 c5 af ff ff       	call   1003e9 <__panic>
}
  105424:	90                   	nop
  105425:	c9                   	leave  
  105426:	c3                   	ret    

00105427 <page2ppn>:
page2ppn(struct Page *page) {
  105427:	55                   	push   %ebp
  105428:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10542a:	8b 45 08             	mov    0x8(%ebp),%eax
  10542d:	8b 15 18 df 11 00    	mov    0x11df18,%edx
  105433:	29 d0                	sub    %edx,%eax
  105435:	c1 f8 02             	sar    $0x2,%eax
  105438:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  10543e:	5d                   	pop    %ebp
  10543f:	c3                   	ret    

00105440 <page2pa>:
page2pa(struct Page *page) {
  105440:	55                   	push   %ebp
  105441:	89 e5                	mov    %esp,%ebp
  105443:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  105446:	8b 45 08             	mov    0x8(%ebp),%eax
  105449:	89 04 24             	mov    %eax,(%esp)
  10544c:	e8 d6 ff ff ff       	call   105427 <page2ppn>
  105451:	c1 e0 0c             	shl    $0xc,%eax
}
  105454:	c9                   	leave  
  105455:	c3                   	ret    

00105456 <page_ref>:
page_ref(struct Page *page) {
  105456:	55                   	push   %ebp
  105457:	89 e5                	mov    %esp,%ebp
    return page->ref;
  105459:	8b 45 08             	mov    0x8(%ebp),%eax
  10545c:	8b 00                	mov    (%eax),%eax
}
  10545e:	5d                   	pop    %ebp
  10545f:	c3                   	ret    

00105460 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  105460:	55                   	push   %ebp
  105461:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  105463:	8b 45 08             	mov    0x8(%ebp),%eax
  105466:	8b 55 0c             	mov    0xc(%ebp),%edx
  105469:	89 10                	mov    %edx,(%eax)
}
  10546b:	90                   	nop
  10546c:	5d                   	pop    %ebp
  10546d:	c3                   	ret    

0010546e <buddy_init>:

#define MAXLEVEL 12
free_area_t free_area[MAXLEVEL+1];

static void 
buddy_init(void){
  10546e:	55                   	push   %ebp
  10546f:	89 e5                	mov    %esp,%ebp
  105471:	83 ec 10             	sub    $0x10,%esp
     for(int i=0;i<=MAXLEVEL;i++){
  105474:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10547b:	eb 42                	jmp    1054bf <buddy_init+0x51>
	list_init(&free_area[i].free_list);
  10547d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  105480:	89 d0                	mov    %edx,%eax
  105482:	01 c0                	add    %eax,%eax
  105484:	01 d0                	add    %edx,%eax
  105486:	c1 e0 02             	shl    $0x2,%eax
  105489:	05 20 df 11 00       	add    $0x11df20,%eax
  10548e:	89 45 f8             	mov    %eax,-0x8(%ebp)
    elm->prev = elm->next = elm;
  105491:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105494:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105497:	89 50 04             	mov    %edx,0x4(%eax)
  10549a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10549d:	8b 50 04             	mov    0x4(%eax),%edx
  1054a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1054a3:	89 10                	mov    %edx,(%eax)
	free_area[i].nr_free=0;
  1054a5:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1054a8:	89 d0                	mov    %edx,%eax
  1054aa:	01 c0                	add    %eax,%eax
  1054ac:	01 d0                	add    %edx,%eax
  1054ae:	c1 e0 02             	shl    $0x2,%eax
  1054b1:	05 28 df 11 00       	add    $0x11df28,%eax
  1054b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     for(int i=0;i<=MAXLEVEL;i++){
  1054bc:	ff 45 fc             	incl   -0x4(%ebp)
  1054bf:	83 7d fc 0c          	cmpl   $0xc,-0x4(%ebp)
  1054c3:	7e b8                	jle    10547d <buddy_init+0xf>
     }
}
  1054c5:	90                   	nop
  1054c6:	c9                   	leave  
  1054c7:	c3                   	ret    

001054c8 <buddy_nr_free_page>:

static size_t
buddy_nr_free_page(void){
  1054c8:	55                   	push   %ebp
  1054c9:	89 e5                	mov    %esp,%ebp
  1054cb:	83 ec 10             	sub    $0x10,%esp
    size_t nr=0;
  1054ce:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
  1054d5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  1054dc:	eb 1c                	jmp    1054fa <buddy_nr_free_page+0x32>
	nr+=free_area[i].nr_free*(1<<MAXLEVEL);
  1054de:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1054e1:	89 d0                	mov    %edx,%eax
  1054e3:	01 c0                	add    %eax,%eax
  1054e5:	01 d0                	add    %edx,%eax
  1054e7:	c1 e0 02             	shl    $0x2,%eax
  1054ea:	05 28 df 11 00       	add    $0x11df28,%eax
  1054ef:	8b 00                	mov    (%eax),%eax
  1054f1:	c1 e0 0c             	shl    $0xc,%eax
  1054f4:	01 45 fc             	add    %eax,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
  1054f7:	ff 45 f8             	incl   -0x8(%ebp)
  1054fa:	83 7d f8 0c          	cmpl   $0xc,-0x8(%ebp)
  1054fe:	7e de                	jle    1054de <buddy_nr_free_page+0x16>
    }
    return nr; 
  105500:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105503:	c9                   	leave  
  105504:	c3                   	ret    

00105505 <buddy_init_memmap>:

static void
buddy_init_memmap(struct Page* base,size_t n){
  105505:	55                   	push   %ebp
  105506:	89 e5                	mov    %esp,%ebp
  105508:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
  10550b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10550f:	75 24                	jne    105535 <buddy_init_memmap+0x30>
  105511:	c7 44 24 0c 9c 7f 10 	movl   $0x107f9c,0xc(%esp)
  105518:	00 
  105519:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  105520:	00 
  105521:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  105528:	00 
  105529:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  105530:	e8 b4 ae ff ff       	call   1003e9 <__panic>
     struct Page* p=base;
  105535:	8b 45 08             	mov    0x8(%ebp),%eax
  105538:	89 45 f4             	mov    %eax,-0xc(%ebp)
     for(;p!=base+n;p++){
  10553b:	eb 7d                	jmp    1055ba <buddy_init_memmap+0xb5>
	assert(PageReserved(p));
  10553d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105540:	83 c0 04             	add    $0x4,%eax
  105543:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  10554a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10554d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105550:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105553:	0f a3 10             	bt     %edx,(%eax)
  105556:	19 c0                	sbb    %eax,%eax
  105558:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  10555b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  10555f:	0f 95 c0             	setne  %al
  105562:	0f b6 c0             	movzbl %al,%eax
  105565:	85 c0                	test   %eax,%eax
  105567:	75 24                	jne    10558d <buddy_init_memmap+0x88>
  105569:	c7 44 24 0c cc 7f 10 	movl   $0x107fcc,0xc(%esp)
  105570:	00 
  105571:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  105578:	00 
  105579:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  105580:	00 
  105581:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  105588:	e8 5c ae ff ff       	call   1003e9 <__panic>
	p->flags=p->property=0;
  10558d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105590:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  105597:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10559a:	8b 50 08             	mov    0x8(%eax),%edx
  10559d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055a0:	89 50 04             	mov    %edx,0x4(%eax)
	set_page_ref(p,0);
  1055a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1055aa:	00 
  1055ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055ae:	89 04 24             	mov    %eax,(%esp)
  1055b1:	e8 aa fe ff ff       	call   105460 <set_page_ref>
     for(;p!=base+n;p++){
  1055b6:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1055ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  1055bd:	89 d0                	mov    %edx,%eax
  1055bf:	c1 e0 02             	shl    $0x2,%eax
  1055c2:	01 d0                	add    %edx,%eax
  1055c4:	c1 e0 02             	shl    $0x2,%eax
  1055c7:	89 c2                	mov    %eax,%edx
  1055c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1055cc:	01 d0                	add    %edx,%eax
  1055ce:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1055d1:	0f 85 66 ff ff ff    	jne    10553d <buddy_init_memmap+0x38>
     }
     p=base;
  1055d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1055da:	89 45 f4             	mov    %eax,-0xc(%ebp)
     size_t temp=n;
  1055dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
     int level=MAXLEVEL;
  1055e3:	c7 45 ec 0c 00 00 00 	movl   $0xc,-0x14(%ebp)
     while(level>=0){
  1055ea:	e9 fd 00 00 00       	jmp    1056ec <buddy_init_memmap+0x1e7>
	for(int i=0;i<temp/(1<<level);i++){
  1055ef:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  1055f6:	e9 c7 00 00 00       	jmp    1056c2 <buddy_init_memmap+0x1bd>
	    struct Page* page=p;
  1055fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	    page->property=1<<level;
  105601:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105604:	ba 01 00 00 00       	mov    $0x1,%edx
  105609:	88 c1                	mov    %al,%cl
  10560b:	d3 e2                	shl    %cl,%edx
  10560d:	89 d0                	mov    %edx,%eax
  10560f:	89 c2                	mov    %eax,%edx
  105611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105614:	89 50 08             	mov    %edx,0x8(%eax)
	    SetPageProperty(p);
  105617:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10561a:	83 c0 04             	add    $0x4,%eax
  10561d:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  105624:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105627:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10562a:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10562d:	0f ab 10             	bts    %edx,(%eax)
	    list_add_before(&free_area[level].free_list,&(page->page_link));
  105630:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105633:	8d 48 0c             	lea    0xc(%eax),%ecx
  105636:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105639:	89 d0                	mov    %edx,%eax
  10563b:	01 c0                	add    %eax,%eax
  10563d:	01 d0                	add    %edx,%eax
  10563f:	c1 e0 02             	shl    $0x2,%eax
  105642:	05 20 df 11 00       	add    $0x11df20,%eax
  105647:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  10564a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
    __list_add(elm, listelm->prev, listelm);
  10564d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105650:	8b 00                	mov    (%eax),%eax
  105652:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105655:	89 55 cc             	mov    %edx,-0x34(%ebp)
  105658:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10565b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10565e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
  105661:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105664:	8b 55 cc             	mov    -0x34(%ebp),%edx
  105667:	89 10                	mov    %edx,(%eax)
  105669:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10566c:	8b 10                	mov    (%eax),%edx
  10566e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  105671:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  105674:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105677:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  10567a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10567d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105680:	8b 55 c8             	mov    -0x38(%ebp),%edx
  105683:	89 10                	mov    %edx,(%eax)
	    p+=(1<<level);
  105685:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105688:	ba 14 00 00 00       	mov    $0x14,%edx
  10568d:	88 c1                	mov    %al,%cl
  10568f:	d3 e2                	shl    %cl,%edx
  105691:	89 d0                	mov    %edx,%eax
  105693:	01 45 f4             	add    %eax,-0xc(%ebp)
	    free_area[level].nr_free++;
  105696:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105699:	89 d0                	mov    %edx,%eax
  10569b:	01 c0                	add    %eax,%eax
  10569d:	01 d0                	add    %edx,%eax
  10569f:	c1 e0 02             	shl    $0x2,%eax
  1056a2:	05 28 df 11 00       	add    $0x11df28,%eax
  1056a7:	8b 00                	mov    (%eax),%eax
  1056a9:	8d 48 01             	lea    0x1(%eax),%ecx
  1056ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1056af:	89 d0                	mov    %edx,%eax
  1056b1:	01 c0                	add    %eax,%eax
  1056b3:	01 d0                	add    %edx,%eax
  1056b5:	c1 e0 02             	shl    $0x2,%eax
  1056b8:	05 28 df 11 00       	add    $0x11df28,%eax
  1056bd:	89 08                	mov    %ecx,(%eax)
	for(int i=0;i<temp/(1<<level);i++){
  1056bf:	ff 45 e8             	incl   -0x18(%ebp)
  1056c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1056c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1056c8:	88 c1                	mov    %al,%cl
  1056ca:	d3 ea                	shr    %cl,%edx
  1056cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1056cf:	39 c2                	cmp    %eax,%edx
  1056d1:	0f 87 24 ff ff ff    	ja     1055fb <buddy_init_memmap+0xf6>
	}
	temp = temp % (1 << level);
  1056d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1056da:	ba 01 00 00 00       	mov    $0x1,%edx
  1056df:	88 c1                	mov    %al,%cl
  1056e1:	d3 e2                	shl    %cl,%edx
  1056e3:	89 d0                	mov    %edx,%eax
  1056e5:	48                   	dec    %eax
  1056e6:	21 45 f0             	and    %eax,-0x10(%ebp)
	level--;
  1056e9:	ff 4d ec             	decl   -0x14(%ebp)
     while(level>=0){
  1056ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1056f0:	0f 89 f9 fe ff ff    	jns    1055ef <buddy_init_memmap+0xea>
     }
}
  1056f6:	90                   	nop
  1056f7:	c9                   	leave  
  1056f8:	c3                   	ret    

001056f9 <buddy_my_partial>:

static void
buddy_my_partial(struct Page *base, size_t n, int level) {
  1056f9:	55                   	push   %ebp
  1056fa:	89 e5                	mov    %esp,%ebp
  1056fc:	83 ec 78             	sub    $0x78,%esp
    if (level < 0) return;
  1056ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105703:	0f 88 20 02 00 00    	js     105929 <buddy_my_partial+0x230>
    size_t temp = n;
  105709:	8b 45 0c             	mov    0xc(%ebp),%eax
  10570c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (level >= 0) {
  10570f:	e9 7a 01 00 00       	jmp    10588e <buddy_my_partial+0x195>
        for (int i = 0; i < temp / (1 << level); i++) {
  105714:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  10571b:	e9 44 01 00 00       	jmp    105864 <buddy_my_partial+0x16b>
            base->property = (1 << level);
  105720:	8b 45 10             	mov    0x10(%ebp),%eax
  105723:	ba 01 00 00 00       	mov    $0x1,%edx
  105728:	88 c1                	mov    %al,%cl
  10572a:	d3 e2                	shl    %cl,%edx
  10572c:	89 d0                	mov    %edx,%eax
  10572e:	89 c2                	mov    %eax,%edx
  105730:	8b 45 08             	mov    0x8(%ebp),%eax
  105733:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(base);
  105736:	8b 45 08             	mov    0x8(%ebp),%eax
  105739:	83 c0 04             	add    $0x4,%eax
  10573c:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  105743:	89 45 c8             	mov    %eax,-0x38(%ebp)
  105746:	8b 45 c8             	mov    -0x38(%ebp),%eax
  105749:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10574c:	0f ab 10             	bts    %edx,(%eax)
            // add pages in order
            struct Page* p = NULL;
  10574f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
            list_entry_t* le = list_next(&(free_area[level].free_list));
  105756:	8b 55 10             	mov    0x10(%ebp),%edx
  105759:	89 d0                	mov    %edx,%eax
  10575b:	01 c0                	add    %eax,%eax
  10575d:	01 d0                	add    %edx,%eax
  10575f:	c1 e0 02             	shl    $0x2,%eax
  105762:	05 20 df 11 00       	add    $0x11df20,%eax
  105767:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return listelm->next;
  10576a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10576d:	8b 40 04             	mov    0x4(%eax),%eax
  105770:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105773:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105776:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return listelm->prev;
  105779:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10577c:	8b 00                	mov    (%eax),%eax
            list_entry_t* bfle = list_prev(le);
  10577e:	89 45 e8             	mov    %eax,-0x18(%ebp)
            while (le != &(free_area[level].free_list)) {
  105781:	eb 37                	jmp    1057ba <buddy_my_partial+0xc1>
                p = le2page(le, page_link);
  105783:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105786:	83 e8 0c             	sub    $0xc,%eax
  105789:	89 45 d8             	mov    %eax,-0x28(%ebp)
                if (base + base->property < le) break;
  10578c:	8b 45 08             	mov    0x8(%ebp),%eax
  10578f:	8b 50 08             	mov    0x8(%eax),%edx
  105792:	89 d0                	mov    %edx,%eax
  105794:	c1 e0 02             	shl    $0x2,%eax
  105797:	01 d0                	add    %edx,%eax
  105799:	c1 e0 02             	shl    $0x2,%eax
  10579c:	89 c2                	mov    %eax,%edx
  10579e:	8b 45 08             	mov    0x8(%ebp),%eax
  1057a1:	01 d0                	add    %edx,%eax
  1057a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  1057a6:	77 2a                	ja     1057d2 <buddy_my_partial+0xd9>
                bfle = bfle->next;
  1057a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1057ab:	8b 40 04             	mov    0x4(%eax),%eax
  1057ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
                le = le->next;
  1057b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1057b4:	8b 40 04             	mov    0x4(%eax),%eax
  1057b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
            while (le != &(free_area[level].free_list)) {
  1057ba:	8b 55 10             	mov    0x10(%ebp),%edx
  1057bd:	89 d0                	mov    %edx,%eax
  1057bf:	01 c0                	add    %eax,%eax
  1057c1:	01 d0                	add    %edx,%eax
  1057c3:	c1 e0 02             	shl    $0x2,%eax
  1057c6:	05 20 df 11 00       	add    $0x11df20,%eax
  1057cb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  1057ce:	75 b3                	jne    105783 <buddy_my_partial+0x8a>
  1057d0:	eb 01                	jmp    1057d3 <buddy_my_partial+0xda>
                if (base + base->property < le) break;
  1057d2:	90                   	nop
            }
            list_add(bfle, &(base->page_link));
  1057d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1057d6:	8d 50 0c             	lea    0xc(%eax),%edx
  1057d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1057dc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  1057df:	89 55 c0             	mov    %edx,-0x40(%ebp)
  1057e2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1057e5:	89 45 bc             	mov    %eax,-0x44(%ebp)
  1057e8:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1057eb:	89 45 b8             	mov    %eax,-0x48(%ebp)
    __list_add(elm, listelm, listelm->next);
  1057ee:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1057f1:	8b 40 04             	mov    0x4(%eax),%eax
  1057f4:	8b 55 b8             	mov    -0x48(%ebp),%edx
  1057f7:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  1057fa:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1057fd:	89 55 b0             	mov    %edx,-0x50(%ebp)
  105800:	89 45 ac             	mov    %eax,-0x54(%ebp)
    prev->next = next->prev = elm;
  105803:	8b 45 ac             	mov    -0x54(%ebp),%eax
  105806:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  105809:	89 10                	mov    %edx,(%eax)
  10580b:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10580e:	8b 10                	mov    (%eax),%edx
  105810:	8b 45 b0             	mov    -0x50(%ebp),%eax
  105813:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  105816:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  105819:	8b 55 ac             	mov    -0x54(%ebp),%edx
  10581c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10581f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  105822:	8b 55 b0             	mov    -0x50(%ebp),%edx
  105825:	89 10                	mov    %edx,(%eax)
            base += (1 << level);
  105827:	8b 45 10             	mov    0x10(%ebp),%eax
  10582a:	ba 14 00 00 00       	mov    $0x14,%edx
  10582f:	88 c1                	mov    %al,%cl
  105831:	d3 e2                	shl    %cl,%edx
  105833:	89 d0                	mov    %edx,%eax
  105835:	01 45 08             	add    %eax,0x8(%ebp)
            free_area[level].nr_free++;
  105838:	8b 55 10             	mov    0x10(%ebp),%edx
  10583b:	89 d0                	mov    %edx,%eax
  10583d:	01 c0                	add    %eax,%eax
  10583f:	01 d0                	add    %edx,%eax
  105841:	c1 e0 02             	shl    $0x2,%eax
  105844:	05 28 df 11 00       	add    $0x11df28,%eax
  105849:	8b 00                	mov    (%eax),%eax
  10584b:	8d 48 01             	lea    0x1(%eax),%ecx
  10584e:	8b 55 10             	mov    0x10(%ebp),%edx
  105851:	89 d0                	mov    %edx,%eax
  105853:	01 c0                	add    %eax,%eax
  105855:	01 d0                	add    %edx,%eax
  105857:	c1 e0 02             	shl    $0x2,%eax
  10585a:	05 28 df 11 00       	add    $0x11df28,%eax
  10585f:	89 08                	mov    %ecx,(%eax)
        for (int i = 0; i < temp / (1 << level); i++) {
  105861:	ff 45 f0             	incl   -0x10(%ebp)
  105864:	8b 45 10             	mov    0x10(%ebp),%eax
  105867:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10586a:	88 c1                	mov    %al,%cl
  10586c:	d3 ea                	shr    %cl,%edx
  10586e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105871:	39 c2                	cmp    %eax,%edx
  105873:	0f 87 a7 fe ff ff    	ja     105720 <buddy_my_partial+0x27>
        }
        temp = temp % (1 << level);
  105879:	8b 45 10             	mov    0x10(%ebp),%eax
  10587c:	ba 01 00 00 00       	mov    $0x1,%edx
  105881:	88 c1                	mov    %al,%cl
  105883:	d3 e2                	shl    %cl,%edx
  105885:	89 d0                	mov    %edx,%eax
  105887:	48                   	dec    %eax
  105888:	21 45 f4             	and    %eax,-0xc(%ebp)
        level--;
  10588b:	ff 4d 10             	decl   0x10(%ebp)
    while (level >= 0) {
  10588e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105892:	0f 89 7c fe ff ff    	jns    105714 <buddy_my_partial+0x1b>
    }
    cprintf("alloc_page check: \n");
  105898:	c7 04 24 dc 7f 10 00 	movl   $0x107fdc,(%esp)
  10589f:	e8 ee a9 ff ff       	call   100292 <cprintf>
    for (int i = MAXLEVEL; i >= 0; i--) {
  1058a4:	c7 45 e4 0c 00 00 00 	movl   $0xc,-0x1c(%ebp)
  1058ab:	eb 74                	jmp    105921 <buddy_my_partial+0x228>
        list_entry_t* le = list_next(&(free_area[i].free_list));
  1058ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1058b0:	89 d0                	mov    %edx,%eax
  1058b2:	01 c0                	add    %eax,%eax
  1058b4:	01 d0                	add    %edx,%eax
  1058b6:	c1 e0 02             	shl    $0x2,%eax
  1058b9:	05 20 df 11 00       	add    $0x11df20,%eax
  1058be:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return listelm->next;
  1058c1:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1058c4:	8b 40 04             	mov    0x4(%eax),%eax
  1058c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
  1058ca:	eb 3c                	jmp    105908 <buddy_my_partial+0x20f>
            struct Page* page = le2page(le, page_link);
  1058cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1058cf:	83 e8 0c             	sub    $0xc,%eax
  1058d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
            cprintf("%d - %llx\n", i, page->page_link);
  1058d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1058d8:	8b 50 10             	mov    0x10(%eax),%edx
  1058db:	8b 40 0c             	mov    0xc(%eax),%eax
  1058de:	89 44 24 08          	mov    %eax,0x8(%esp)
  1058e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1058e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1058e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058ed:	c7 04 24 f0 7f 10 00 	movl   $0x107ff0,(%esp)
  1058f4:	e8 99 a9 ff ff       	call   100292 <cprintf>
  1058f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1058fc:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  1058ff:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  105902:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
  105905:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
  105908:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10590b:	89 d0                	mov    %edx,%eax
  10590d:	01 c0                	add    %eax,%eax
  10590f:	01 d0                	add    %edx,%eax
  105911:	c1 e0 02             	shl    $0x2,%eax
  105914:	05 20 df 11 00       	add    $0x11df20,%eax
  105919:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  10591c:	75 ae                	jne    1058cc <buddy_my_partial+0x1d3>
    for (int i = MAXLEVEL; i >= 0; i--) {
  10591e:	ff 4d e4             	decl   -0x1c(%ebp)
  105921:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105925:	79 86                	jns    1058ad <buddy_my_partial+0x1b4>
  105927:	eb 01                	jmp    10592a <buddy_my_partial+0x231>
    if (level < 0) return;
  105929:	90                   	nop
        }
    }
}
  10592a:	c9                   	leave  
  10592b:	c3                   	ret    

0010592c <buddy_my_merge>:

static void
buddy_my_merge(int level) {
  10592c:	55                   	push   %ebp
  10592d:	89 e5                	mov    %esp,%ebp
  10592f:	83 ec 68             	sub    $0x68,%esp
    cprintf("before merge.\n");
  105932:	c7 04 24 fb 7f 10 00 	movl   $0x107ffb,(%esp)
  105939:	e8 54 a9 ff ff       	call   100292 <cprintf>
    //bds_selfcheck();
    while (level < MAXLEVEL) {
  10593e:	e9 dc 01 00 00       	jmp    105b1f <buddy_my_merge+0x1f3>
        if (free_area[level].nr_free <= 1) {
  105943:	8b 55 08             	mov    0x8(%ebp),%edx
  105946:	89 d0                	mov    %edx,%eax
  105948:	01 c0                	add    %eax,%eax
  10594a:	01 d0                	add    %edx,%eax
  10594c:	c1 e0 02             	shl    $0x2,%eax
  10594f:	05 28 df 11 00       	add    $0x11df28,%eax
  105954:	8b 00                	mov    (%eax),%eax
  105956:	83 f8 01             	cmp    $0x1,%eax
  105959:	77 08                	ja     105963 <buddy_my_merge+0x37>
            level++;
  10595b:	ff 45 08             	incl   0x8(%ebp)
            continue;
  10595e:	e9 bc 01 00 00       	jmp    105b1f <buddy_my_merge+0x1f3>
        }
        list_entry_t* le = list_next(&(free_area[level].free_list));
  105963:	8b 55 08             	mov    0x8(%ebp),%edx
  105966:	89 d0                	mov    %edx,%eax
  105968:	01 c0                	add    %eax,%eax
  10596a:	01 d0                	add    %edx,%eax
  10596c:	c1 e0 02             	shl    $0x2,%eax
  10596f:	05 20 df 11 00       	add    $0x11df20,%eax
  105974:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105977:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10597a:	8b 40 04             	mov    0x4(%eax),%eax
  10597d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105980:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105983:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->prev;
  105986:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105989:	8b 00                	mov    (%eax),%eax
        list_entry_t* bfle = list_prev(le);
  10598b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while (le != &(free_area[level].free_list)) {
  10598e:	e9 6f 01 00 00       	jmp    105b02 <buddy_my_merge+0x1d6>
  105993:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105996:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return listelm->next;
  105999:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10599c:	8b 40 04             	mov    0x4(%eax),%eax
            bfle = list_next(bfle);
  10599f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1059a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1059a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1059ab:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
  1059ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
            struct Page* ple = le2page(le, page_link);
  1059b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1059b4:	83 e8 0c             	sub    $0xc,%eax
  1059b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
            struct Page* pbf = le2page(bfle, page_link); 
  1059ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059bd:	83 e8 0c             	sub    $0xc,%eax
  1059c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
            cprintf("bfle addr is: %llx\n", pbf->page_link);
  1059c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1059c6:	8b 50 10             	mov    0x10(%eax),%edx
  1059c9:	8b 40 0c             	mov    0xc(%eax),%eax
  1059cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059d0:	89 54 24 08          	mov    %edx,0x8(%esp)
  1059d4:	c7 04 24 0a 80 10 00 	movl   $0x10800a,(%esp)
  1059db:	e8 b2 a8 ff ff       	call   100292 <cprintf>
            cprintf("le addr is: %llx\n", ple->page_link);
  1059e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1059e3:	8b 50 10             	mov    0x10(%eax),%edx
  1059e6:	8b 40 0c             	mov    0xc(%eax),%eax
  1059e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059ed:	89 54 24 08          	mov    %edx,0x8(%esp)
  1059f1:	c7 04 24 1e 80 10 00 	movl   $0x10801e,(%esp)
  1059f8:	e8 95 a8 ff ff       	call   100292 <cprintf>
            if (pbf + pbf->property == ple) {            
  1059fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a00:	8b 50 08             	mov    0x8(%eax),%edx
  105a03:	89 d0                	mov    %edx,%eax
  105a05:	c1 e0 02             	shl    $0x2,%eax
  105a08:	01 d0                	add    %edx,%eax
  105a0a:	c1 e0 02             	shl    $0x2,%eax
  105a0d:	89 c2                	mov    %eax,%edx
  105a0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a12:	01 d0                	add    %edx,%eax
  105a14:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  105a17:	0f 85 e5 00 00 00    	jne    105b02 <buddy_my_merge+0x1d6>
  105a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a20:	89 45 b0             	mov    %eax,-0x50(%ebp)
  105a23:	8b 45 b0             	mov    -0x50(%ebp),%eax
  105a26:	8b 40 04             	mov    0x4(%eax),%eax
                bfle = list_next(bfle);
  105a29:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105a2f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  105a32:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  105a35:	8b 40 04             	mov    0x4(%eax),%eax
                le = list_next(le);
  105a38:	89 45 f4             	mov    %eax,-0xc(%ebp)
                pbf->property = pbf->property << 1;
  105a3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a3e:	8b 40 08             	mov    0x8(%eax),%eax
  105a41:	8d 14 00             	lea    (%eax,%eax,1),%edx
  105a44:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a47:	89 50 08             	mov    %edx,0x8(%eax)
                ClearPageProperty(ple);
  105a4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a4d:	83 c0 04             	add    $0x4,%eax
  105a50:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  105a57:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105a5a:	8b 45 b8             	mov    -0x48(%ebp),%eax
  105a5d:	8b 55 bc             	mov    -0x44(%ebp),%edx
  105a60:	0f b3 10             	btr    %edx,(%eax)
                list_del(&(pbf->page_link));
  105a63:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a66:	83 c0 0c             	add    $0xc,%eax
  105a69:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_del(listelm->prev, listelm->next);
  105a6c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  105a6f:	8b 40 04             	mov    0x4(%eax),%eax
  105a72:	8b 55 c8             	mov    -0x38(%ebp),%edx
  105a75:	8b 12                	mov    (%edx),%edx
  105a77:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  105a7a:	89 45 c0             	mov    %eax,-0x40(%ebp)
    prev->next = next;
  105a7d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105a80:	8b 55 c0             	mov    -0x40(%ebp),%edx
  105a83:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  105a86:	8b 45 c0             	mov    -0x40(%ebp),%eax
  105a89:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  105a8c:	89 10                	mov    %edx,(%eax)
                list_del(&(ple->page_link));
  105a8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a91:	83 c0 0c             	add    $0xc,%eax
  105a94:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_del(listelm->prev, listelm->next);
  105a97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105a9a:	8b 40 04             	mov    0x4(%eax),%eax
  105a9d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105aa0:	8b 12                	mov    (%edx),%edx
  105aa2:	89 55 d0             	mov    %edx,-0x30(%ebp)
  105aa5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next;
  105aa8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105aab:	8b 55 cc             	mov    -0x34(%ebp),%edx
  105aae:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  105ab1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105ab4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105ab7:	89 10                	mov    %edx,(%eax)
                buddy_my_partial(pbf, pbf->property, level + 1);             
  105ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  105abc:	8d 50 01             	lea    0x1(%eax),%edx
  105abf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ac2:	8b 40 08             	mov    0x8(%eax),%eax
  105ac5:	89 54 24 08          	mov    %edx,0x8(%esp)
  105ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
  105acd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ad0:	89 04 24             	mov    %eax,(%esp)
  105ad3:	e8 21 fc ff ff       	call   1056f9 <buddy_my_partial>
                free_area[level].nr_free -= 2;              
  105ad8:	8b 55 08             	mov    0x8(%ebp),%edx
  105adb:	89 d0                	mov    %edx,%eax
  105add:	01 c0                	add    %eax,%eax
  105adf:	01 d0                	add    %edx,%eax
  105ae1:	c1 e0 02             	shl    $0x2,%eax
  105ae4:	05 28 df 11 00       	add    $0x11df28,%eax
  105ae9:	8b 00                	mov    (%eax),%eax
  105aeb:	8d 48 fe             	lea    -0x2(%eax),%ecx
  105aee:	8b 55 08             	mov    0x8(%ebp),%edx
  105af1:	89 d0                	mov    %edx,%eax
  105af3:	01 c0                	add    %eax,%eax
  105af5:	01 d0                	add    %edx,%eax
  105af7:	c1 e0 02             	shl    $0x2,%eax
  105afa:	05 28 df 11 00       	add    $0x11df28,%eax
  105aff:	89 08                	mov    %ecx,(%eax)
                continue;
  105b01:	90                   	nop
        while (le != &(free_area[level].free_list)) {
  105b02:	8b 55 08             	mov    0x8(%ebp),%edx
  105b05:	89 d0                	mov    %edx,%eax
  105b07:	01 c0                	add    %eax,%eax
  105b09:	01 d0                	add    %edx,%eax
  105b0b:	c1 e0 02             	shl    $0x2,%eax
  105b0e:	05 20 df 11 00       	add    $0x11df20,%eax
  105b13:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  105b16:	0f 85 77 fe ff ff    	jne    105993 <buddy_my_merge+0x67>
            } 
        }
        level++;
  105b1c:	ff 45 08             	incl   0x8(%ebp)
    while (level < MAXLEVEL) {
  105b1f:	83 7d 08 0b          	cmpl   $0xb,0x8(%ebp)
  105b23:	0f 8e 1a fe ff ff    	jle    105943 <buddy_my_merge+0x17>
    }
    //bds_selfcheck();
}
  105b29:	90                   	nop
  105b2a:	c9                   	leave  
  105b2b:	c3                   	ret    

00105b2c <buddy_alloc_page>:

static struct Page*
buddy_alloc_page(size_t n){
  105b2c:	55                   	push   %ebp
  105b2d:	89 e5                	mov    %esp,%ebp
  105b2f:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
  105b32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105b36:	75 24                	jne    105b5c <buddy_alloc_page+0x30>
  105b38:	c7 44 24 0c 9c 7f 10 	movl   $0x107f9c,0xc(%esp)
  105b3f:	00 
  105b40:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  105b47:	00 
  105b48:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  105b4f:	00 
  105b50:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  105b57:	e8 8d a8 ff ff       	call   1003e9 <__panic>
     if(n>buddy_nr_free_page()){
  105b5c:	e8 67 f9 ff ff       	call   1054c8 <buddy_nr_free_page>
  105b61:	39 45 08             	cmp    %eax,0x8(%ebp)
  105b64:	76 0a                	jbe    105b70 <buddy_alloc_page+0x44>
	return NULL;
  105b66:	b8 00 00 00 00       	mov    $0x0,%eax
  105b6b:	e9 62 01 00 00       	jmp    105cd2 <buddy_alloc_page+0x1a6>
     }
     int level=0;
  105b70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     while((1<<level)<n){
  105b77:	eb 03                	jmp    105b7c <buddy_alloc_page+0x50>
	level++;
  105b79:	ff 45 f4             	incl   -0xc(%ebp)
     while((1<<level)<n){
  105b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105b7f:	ba 01 00 00 00       	mov    $0x1,%edx
  105b84:	88 c1                	mov    %al,%cl
  105b86:	d3 e2                	shl    %cl,%edx
  105b88:	89 d0                	mov    %edx,%eax
  105b8a:	39 45 08             	cmp    %eax,0x8(%ebp)
  105b8d:	77 ea                	ja     105b79 <buddy_alloc_page+0x4d>
     }
     //n=1<<level;
     for(int i=level;i<=MAXLEVEL;i++){
  105b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b95:	eb 22                	jmp    105bb9 <buddy_alloc_page+0x8d>
	if(free_area[i].nr_free!=0){
  105b97:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105b9a:	89 d0                	mov    %edx,%eax
  105b9c:	01 c0                	add    %eax,%eax
  105b9e:	01 d0                	add    %edx,%eax
  105ba0:	c1 e0 02             	shl    $0x2,%eax
  105ba3:	05 28 df 11 00       	add    $0x11df28,%eax
  105ba8:	8b 00                	mov    (%eax),%eax
  105baa:	85 c0                	test   %eax,%eax
  105bac:	74 08                	je     105bb6 <buddy_alloc_page+0x8a>
	   level=i;
  105bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105bb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    break;
  105bb4:	eb 09                	jmp    105bbf <buddy_alloc_page+0x93>
     for(int i=level;i<=MAXLEVEL;i++){
  105bb6:	ff 45 f0             	incl   -0x10(%ebp)
  105bb9:	83 7d f0 0c          	cmpl   $0xc,-0x10(%ebp)
  105bbd:	7e d8                	jle    105b97 <buddy_alloc_page+0x6b>
	}
     }
     if(level>MAXLEVEL){return NULL;}
  105bbf:	83 7d f4 0c          	cmpl   $0xc,-0xc(%ebp)
  105bc3:	7e 0a                	jle    105bcf <buddy_alloc_page+0xa3>
  105bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  105bca:	e9 03 01 00 00       	jmp    105cd2 <buddy_alloc_page+0x1a6>
     list_entry_t *le=&free_area[level].free_list;
  105bcf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105bd2:	89 d0                	mov    %edx,%eax
  105bd4:	01 c0                	add    %eax,%eax
  105bd6:	01 d0                	add    %edx,%eax
  105bd8:	c1 e0 02             	shl    $0x2,%eax
  105bdb:	05 20 df 11 00       	add    $0x11df20,%eax
  105be0:	89 45 ec             	mov    %eax,-0x14(%ebp)
     struct Page* page=le2page(le,page_link);
  105be3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105be6:	83 e8 0c             	sub    $0xc,%eax
  105be9:	89 45 e8             	mov    %eax,-0x18(%ebp)
     if (page != NULL) {
  105bec:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105bf0:	0f 84 cd 00 00 00    	je     105cc3 <buddy_alloc_page+0x197>
        SetPageReserved(page);
  105bf6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105bf9:	83 c0 04             	add    $0x4,%eax
  105bfc:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  105c03:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105c06:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105c09:	8b 55 c8             	mov    -0x38(%ebp),%edx
  105c0c:	0f ab 10             	bts    %edx,(%eax)
        // deal with partial work
        buddy_my_partial(page, page->property - n, level - 1);
  105c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105c12:	8d 50 ff             	lea    -0x1(%eax),%edx
  105c15:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c18:	8b 40 08             	mov    0x8(%eax),%eax
  105c1b:	2b 45 08             	sub    0x8(%ebp),%eax
  105c1e:	89 54 24 08          	mov    %edx,0x8(%esp)
  105c22:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c26:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c29:	89 04 24             	mov    %eax,(%esp)
  105c2c:	e8 c8 fa ff ff       	call   1056f9 <buddy_my_partial>
        ClearPageReserved(page);
  105c31:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c34:	83 c0 04             	add    $0x4,%eax
  105c37:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  105c3e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105c41:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105c44:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105c47:	0f b3 10             	btr    %edx,(%eax)
        ClearPageProperty(page);
  105c4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c4d:	83 c0 04             	add    $0x4,%eax
  105c50:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
  105c57:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  105c5a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105c5d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105c60:	0f b3 10             	btr    %edx,(%eax)
        list_del(&(page->page_link));
  105c63:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c66:	83 c0 0c             	add    $0xc,%eax
  105c69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
  105c6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105c6f:	8b 40 04             	mov    0x4(%eax),%eax
  105c72:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105c75:	8b 12                	mov    (%edx),%edx
  105c77:	89 55 e0             	mov    %edx,-0x20(%ebp)
  105c7a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
  105c7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105c80:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105c83:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  105c86:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105c89:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105c8c:	89 10                	mov    %edx,(%eax)
        free_area[level].nr_free--;
  105c8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105c91:	89 d0                	mov    %edx,%eax
  105c93:	01 c0                	add    %eax,%eax
  105c95:	01 d0                	add    %edx,%eax
  105c97:	c1 e0 02             	shl    $0x2,%eax
  105c9a:	05 28 df 11 00       	add    $0x11df28,%eax
  105c9f:	8b 00                	mov    (%eax),%eax
  105ca1:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105ca4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ca7:	89 d0                	mov    %edx,%eax
  105ca9:	01 c0                	add    %eax,%eax
  105cab:	01 d0                	add    %edx,%eax
  105cad:	c1 e0 02             	shl    $0x2,%eax
  105cb0:	05 28 df 11 00       	add    $0x11df28,%eax
  105cb5:	89 08                	mov    %ecx,(%eax)
        buddy_my_merge(0);
  105cb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  105cbe:	e8 69 fc ff ff       	call   10592c <buddy_my_merge>
    }
    cprintf("after allocate & merge\n");
  105cc3:	c7 04 24 30 80 10 00 	movl   $0x108030,(%esp)
  105cca:	e8 c3 a5 ff ff       	call   100292 <cprintf>
    //bds_selfcheck();
    return page;
  105ccf:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
  105cd2:	c9                   	leave  
  105cd3:	c3                   	ret    

00105cd4 <buddy_free_page>:

static void 
buddy_free_page(struct Page* base, size_t n){
  105cd4:	55                   	push   %ebp
  105cd5:	89 e5                	mov    %esp,%ebp
  105cd7:	83 ec 48             	sub    $0x48,%esp
     assert(n > 0);
  105cda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105cde:	75 24                	jne    105d04 <buddy_free_page+0x30>
  105ce0:	c7 44 24 0c 48 80 10 	movl   $0x108048,0xc(%esp)
  105ce7:	00 
  105ce8:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  105cef:	00 
  105cf0:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
  105cf7:	00 
  105cf8:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  105cff:	e8 e5 a6 ff ff       	call   1003e9 <__panic>
    struct Page* p = base;
  105d04:	8b 45 08             	mov    0x8(%ebp),%eax
  105d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++) {
  105d0a:	e9 9d 00 00 00       	jmp    105dac <buddy_free_page+0xd8>
        assert(!PageReserved(p) && !PageProperty(p));
  105d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105d12:	83 c0 04             	add    $0x4,%eax
  105d15:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  105d1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105d1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105d22:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105d25:	0f a3 10             	bt     %edx,(%eax)
  105d28:	19 c0                	sbb    %eax,%eax
  105d2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  105d2d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105d31:	0f 95 c0             	setne  %al
  105d34:	0f b6 c0             	movzbl %al,%eax
  105d37:	85 c0                	test   %eax,%eax
  105d39:	75 2c                	jne    105d67 <buddy_free_page+0x93>
  105d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105d3e:	83 c0 04             	add    $0x4,%eax
  105d41:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  105d48:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105d4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105d4e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105d51:	0f a3 10             	bt     %edx,(%eax)
  105d54:	19 c0                	sbb    %eax,%eax
  105d56:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  105d59:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  105d5d:	0f 95 c0             	setne  %al
  105d60:	0f b6 c0             	movzbl %al,%eax
  105d63:	85 c0                	test   %eax,%eax
  105d65:	74 24                	je     105d8b <buddy_free_page+0xb7>
  105d67:	c7 44 24 0c 50 80 10 	movl   $0x108050,0xc(%esp)
  105d6e:	00 
  105d6f:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  105d76:	00 
  105d77:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  105d7e:	00 
  105d7f:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  105d86:	e8 5e a6 ff ff       	call   1003e9 <__panic>
        p->flags = 0;
  105d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105d8e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  105d95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105d9c:	00 
  105d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105da0:	89 04 24             	mov    %eax,(%esp)
  105da3:	e8 b8 f6 ff ff       	call   105460 <set_page_ref>
    for (; p != base + n; p++) {
  105da8:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  105dac:	8b 55 0c             	mov    0xc(%ebp),%edx
  105daf:	89 d0                	mov    %edx,%eax
  105db1:	c1 e0 02             	shl    $0x2,%eax
  105db4:	01 d0                	add    %edx,%eax
  105db6:	c1 e0 02             	shl    $0x2,%eax
  105db9:	89 c2                	mov    %eax,%edx
  105dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  105dbe:	01 d0                	add    %edx,%eax
  105dc0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  105dc3:	0f 85 46 ff ff ff    	jne    105d0f <buddy_free_page+0x3b>
    }
    // free pages
    base->property = n;
  105dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  105dcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  105dcf:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  105dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  105dd5:	83 c0 04             	add    $0x4,%eax
  105dd8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  105ddf:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105de2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105de5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105de8:	0f ab 10             	bts    %edx,(%eax)
    int level = 0;
  105deb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    while ((1 << level) != n) { level++; }
  105df2:	eb 03                	jmp    105df7 <buddy_free_page+0x123>
  105df4:	ff 45 f0             	incl   -0x10(%ebp)
  105df7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105dfa:	ba 01 00 00 00       	mov    $0x1,%edx
  105dff:	88 c1                	mov    %al,%cl
  105e01:	d3 e2                	shl    %cl,%edx
  105e03:	89 d0                	mov    %edx,%eax
  105e05:	39 45 0c             	cmp    %eax,0xc(%ebp)
  105e08:	75 ea                	jne    105df4 <buddy_free_page+0x120>
    buddy_my_partial(base, n, level);
  105e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  105e11:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e14:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e18:	8b 45 08             	mov    0x8(%ebp),%eax
  105e1b:	89 04 24             	mov    %eax,(%esp)
  105e1e:	e8 d6 f8 ff ff       	call   1056f9 <buddy_my_partial>
    //bds_selfcheck();
    free_area[level].nr_free++;
  105e23:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105e26:	89 d0                	mov    %edx,%eax
  105e28:	01 c0                	add    %eax,%eax
  105e2a:	01 d0                	add    %edx,%eax
  105e2c:	c1 e0 02             	shl    $0x2,%eax
  105e2f:	05 28 df 11 00       	add    $0x11df28,%eax
  105e34:	8b 00                	mov    (%eax),%eax
  105e36:	8d 48 01             	lea    0x1(%eax),%ecx
  105e39:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105e3c:	89 d0                	mov    %edx,%eax
  105e3e:	01 c0                	add    %eax,%eax
  105e40:	01 d0                	add    %edx,%eax
  105e42:	c1 e0 02             	shl    $0x2,%eax
  105e45:	05 28 df 11 00       	add    $0x11df28,%eax
  105e4a:	89 08                	mov    %ecx,(%eax)
    buddy_my_merge(level); 
  105e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e4f:	89 04 24             	mov    %eax,(%esp)
  105e52:	e8 d5 fa ff ff       	call   10592c <buddy_my_merge>
    //buddy_selfcheck();
}
  105e57:	90                   	nop
  105e58:	c9                   	leave  
  105e59:	c3                   	ret    

00105e5a <buddy_check>:

static void
buddy_check(void) {
  105e5a:	55                   	push   %ebp
  105e5b:	89 e5                	mov    %esp,%ebp
  105e5d:	81 ec f8 00 00 00    	sub    $0xf8,%esp
    int count = 0, total = 0;
  105e63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  105e6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) {
  105e71:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  105e78:	e9 a4 00 00 00       	jmp    105f21 <buddy_check+0xc7>
        list_entry_t* free_list = &(free_area[i].free_list);
  105e7d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105e80:	89 d0                	mov    %edx,%eax
  105e82:	01 c0                	add    %eax,%eax
  105e84:	01 d0                	add    %edx,%eax
  105e86:	c1 e0 02             	shl    $0x2,%eax
  105e89:	05 20 df 11 00       	add    $0x11df20,%eax
  105e8e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        list_entry_t* le = free_list;
  105e91:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105e94:	89 45 e8             	mov    %eax,-0x18(%ebp)
        while ((le = list_next(le)) != free_list) {
  105e97:	eb 6a                	jmp    105f03 <buddy_check+0xa9>
            struct Page* p = le2page(le, page_link);
  105e99:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105e9c:	83 e8 0c             	sub    $0xc,%eax
  105e9f:	89 45 cc             	mov    %eax,-0x34(%ebp)
            assert(PageProperty(p));
  105ea2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105ea5:	83 c0 04             	add    $0x4,%eax
  105ea8:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  105eaf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105eb2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105eb5:	8b 55 c8             	mov    -0x38(%ebp),%edx
  105eb8:	0f a3 10             	bt     %edx,(%eax)
  105ebb:	19 c0                	sbb    %eax,%eax
  105ebd:	89 45 c0             	mov    %eax,-0x40(%ebp)
    return oldbit != 0;
  105ec0:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  105ec4:	0f 95 c0             	setne  %al
  105ec7:	0f b6 c0             	movzbl %al,%eax
  105eca:	85 c0                	test   %eax,%eax
  105ecc:	75 24                	jne    105ef2 <buddy_check+0x98>
  105ece:	c7 44 24 0c 75 80 10 	movl   $0x108075,0xc(%esp)
  105ed5:	00 
  105ed6:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  105edd:	00 
  105ede:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  105ee5:	00 
  105ee6:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  105eed:	e8 f7 a4 ff ff       	call   1003e9 <__panic>
            count++;
  105ef2:	ff 45 f4             	incl   -0xc(%ebp)
            total += p->property;
  105ef5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105ef8:	8b 50 08             	mov    0x8(%eax),%edx
  105efb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105efe:	01 d0                	add    %edx,%eax
  105f00:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f03:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105f06:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return listelm->next;
  105f09:	8b 45 bc             	mov    -0x44(%ebp),%eax
  105f0c:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != free_list) {
  105f0f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105f12:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105f15:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  105f18:	0f 85 7b ff ff ff    	jne    105e99 <buddy_check+0x3f>
    for (int i = 0; i <= MAXLEVEL; i++) {
  105f1e:	ff 45 ec             	incl   -0x14(%ebp)
  105f21:	83 7d ec 0c          	cmpl   $0xc,-0x14(%ebp)
  105f25:	0f 8e 52 ff ff ff    	jle    105e7d <buddy_check+0x23>
        }
    }
    assert(total == buddy_nr_free_page());
  105f2b:	e8 98 f5 ff ff       	call   1054c8 <buddy_nr_free_page>
  105f30:	89 c2                	mov    %eax,%edx
  105f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f35:	39 c2                	cmp    %eax,%edx
  105f37:	74 24                	je     105f5d <buddy_check+0x103>
  105f39:	c7 44 24 0c 85 80 10 	movl   $0x108085,0xc(%esp)
  105f40:	00 
  105f41:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  105f48:	00 
  105f49:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
  105f50:	00 
  105f51:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  105f58:	e8 8c a4 ff ff       	call   1003e9 <__panic>

    // basic check
    struct Page *p0, *p1, *p2;
    p0 = p1 =p2 = NULL;
  105f5d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105f64:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105f67:	89 45 d8             	mov    %eax,-0x28(%ebp)
  105f6a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105f6d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("p0\n");
  105f70:	c7 04 24 a3 80 10 00 	movl   $0x1080a3,(%esp)
  105f77:	e8 16 a3 ff ff       	call   100292 <cprintf>
    assert((p0 = alloc_page()) != NULL);
  105f7c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105f83:	e8 d0 cb ff ff       	call   102b58 <alloc_pages>
  105f88:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  105f8b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  105f8f:	75 24                	jne    105fb5 <buddy_check+0x15b>
  105f91:	c7 44 24 0c a7 80 10 	movl   $0x1080a7,0xc(%esp)
  105f98:	00 
  105f99:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  105fa0:	00 
  105fa1:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  105fa8:	00 
  105fa9:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  105fb0:	e8 34 a4 ff ff       	call   1003e9 <__panic>
    cprintf("p1\n");
  105fb5:	c7 04 24 c3 80 10 00 	movl   $0x1080c3,(%esp)
  105fbc:	e8 d1 a2 ff ff       	call   100292 <cprintf>
    assert((p1 = alloc_page()) != NULL);
  105fc1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105fc8:	e8 8b cb ff ff       	call   102b58 <alloc_pages>
  105fcd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  105fd0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  105fd4:	75 24                	jne    105ffa <buddy_check+0x1a0>
  105fd6:	c7 44 24 0c c7 80 10 	movl   $0x1080c7,0xc(%esp)
  105fdd:	00 
  105fde:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  105fe5:	00 
  105fe6:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  105fed:	00 
  105fee:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  105ff5:	e8 ef a3 ff ff       	call   1003e9 <__panic>
    cprintf("p2\n");
  105ffa:	c7 04 24 e3 80 10 00 	movl   $0x1080e3,(%esp)
  106001:	e8 8c a2 ff ff       	call   100292 <cprintf>
    assert((p2 = alloc_page()) != NULL);
  106006:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10600d:	e8 46 cb ff ff       	call   102b58 <alloc_pages>
  106012:	89 45 dc             	mov    %eax,-0x24(%ebp)
  106015:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  106019:	75 24                	jne    10603f <buddy_check+0x1e5>
  10601b:	c7 44 24 0c e7 80 10 	movl   $0x1080e7,0xc(%esp)
  106022:	00 
  106023:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  10602a:	00 
  10602b:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
  106032:	00 
  106033:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  10603a:	e8 aa a3 ff ff       	call   1003e9 <__panic>

    assert(p0 != p1 && p1 != p2 && p2 != p0);
  10603f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  106042:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  106045:	74 10                	je     106057 <buddy_check+0x1fd>
  106047:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10604a:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  10604d:	74 08                	je     106057 <buddy_check+0x1fd>
  10604f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106052:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  106055:	75 24                	jne    10607b <buddy_check+0x221>
  106057:	c7 44 24 0c 04 81 10 	movl   $0x108104,0xc(%esp)
  10605e:	00 
  10605f:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  106066:	00 
  106067:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  10606e:	00 
  10606f:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  106076:	e8 6e a3 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  10607b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10607e:	89 04 24             	mov    %eax,(%esp)
  106081:	e8 d0 f3 ff ff       	call   105456 <page_ref>
  106086:	85 c0                	test   %eax,%eax
  106088:	75 1e                	jne    1060a8 <buddy_check+0x24e>
  10608a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10608d:	89 04 24             	mov    %eax,(%esp)
  106090:	e8 c1 f3 ff ff       	call   105456 <page_ref>
  106095:	85 c0                	test   %eax,%eax
  106097:	75 0f                	jne    1060a8 <buddy_check+0x24e>
  106099:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10609c:	89 04 24             	mov    %eax,(%esp)
  10609f:	e8 b2 f3 ff ff       	call   105456 <page_ref>
  1060a4:	85 c0                	test   %eax,%eax
  1060a6:	74 24                	je     1060cc <buddy_check+0x272>
  1060a8:	c7 44 24 0c 28 81 10 	movl   $0x108128,0xc(%esp)
  1060af:	00 
  1060b0:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  1060b7:	00 
  1060b8:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
  1060bf:	00 
  1060c0:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  1060c7:	e8 1d a3 ff ff       	call   1003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  1060cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1060cf:	89 04 24             	mov    %eax,(%esp)
  1060d2:	e8 69 f3 ff ff       	call   105440 <page2pa>
  1060d7:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  1060dd:	c1 e2 0c             	shl    $0xc,%edx
  1060e0:	39 d0                	cmp    %edx,%eax
  1060e2:	72 24                	jb     106108 <buddy_check+0x2ae>
  1060e4:	c7 44 24 0c 64 81 10 	movl   $0x108164,0xc(%esp)
  1060eb:	00 
  1060ec:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  1060f3:	00 
  1060f4:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  1060fb:	00 
  1060fc:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  106103:	e8 e1 a2 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  106108:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10610b:	89 04 24             	mov    %eax,(%esp)
  10610e:	e8 2d f3 ff ff       	call   105440 <page2pa>
  106113:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  106119:	c1 e2 0c             	shl    $0xc,%edx
  10611c:	39 d0                	cmp    %edx,%eax
  10611e:	72 24                	jb     106144 <buddy_check+0x2ea>
  106120:	c7 44 24 0c 81 81 10 	movl   $0x108181,0xc(%esp)
  106127:	00 
  106128:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  10612f:	00 
  106130:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  106137:	00 
  106138:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  10613f:	e8 a5 a2 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  106144:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106147:	89 04 24             	mov    %eax,(%esp)
  10614a:	e8 f1 f2 ff ff       	call   105440 <page2pa>
  10614f:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  106155:	c1 e2 0c             	shl    $0xc,%edx
  106158:	39 d0                	cmp    %edx,%eax
  10615a:	72 24                	jb     106180 <buddy_check+0x326>
  10615c:	c7 44 24 0c 9e 81 10 	movl   $0x10819e,0xc(%esp)
  106163:	00 
  106164:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  10616b:	00 
  10616c:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  106173:	00 
  106174:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  10617b:	e8 69 a2 ff ff       	call   1003e9 <__panic>
    cprintf("first part of check successfully.\n");
  106180:	c7 04 24 bc 81 10 00 	movl   $0x1081bc,(%esp)
  106187:	e8 06 a1 ff ff       	call   100292 <cprintf>

    free_area_t temp_list[MAXLEVEL + 1];
    for (int i = 0; i <= MAXLEVEL; i++) {
  10618c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  106193:	e9 c5 00 00 00       	jmp    10625d <buddy_check+0x403>
        temp_list[i] = free_area[i];
  106198:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10619b:	89 d0                	mov    %edx,%eax
  10619d:	01 c0                	add    %eax,%eax
  10619f:	01 d0                	add    %edx,%eax
  1061a1:	c1 e0 02             	shl    $0x2,%eax
  1061a4:	8d 4d f8             	lea    -0x8(%ebp),%ecx
  1061a7:	01 c8                	add    %ecx,%eax
  1061a9:	8d 90 20 ff ff ff    	lea    -0xe0(%eax),%edx
  1061af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  1061b2:	89 c8                	mov    %ecx,%eax
  1061b4:	01 c0                	add    %eax,%eax
  1061b6:	01 c8                	add    %ecx,%eax
  1061b8:	c1 e0 02             	shl    $0x2,%eax
  1061bb:	05 20 df 11 00       	add    $0x11df20,%eax
  1061c0:	8b 08                	mov    (%eax),%ecx
  1061c2:	89 0a                	mov    %ecx,(%edx)
  1061c4:	8b 48 04             	mov    0x4(%eax),%ecx
  1061c7:	89 4a 04             	mov    %ecx,0x4(%edx)
  1061ca:	8b 40 08             	mov    0x8(%eax),%eax
  1061cd:	89 42 08             	mov    %eax,0x8(%edx)
        list_init(&(free_area[i].free_list));
  1061d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1061d3:	89 d0                	mov    %edx,%eax
  1061d5:	01 c0                	add    %eax,%eax
  1061d7:	01 d0                	add    %edx,%eax
  1061d9:	c1 e0 02             	shl    $0x2,%eax
  1061dc:	05 20 df 11 00       	add    $0x11df20,%eax
  1061e1:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    elm->prev = elm->next = elm;
  1061e4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1061e7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  1061ea:	89 50 04             	mov    %edx,0x4(%eax)
  1061ed:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1061f0:	8b 50 04             	mov    0x4(%eax),%edx
  1061f3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1061f6:	89 10                	mov    %edx,(%eax)
        assert(list_empty(&(free_area[i])));
  1061f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1061fb:	89 d0                	mov    %edx,%eax
  1061fd:	01 c0                	add    %eax,%eax
  1061ff:	01 d0                	add    %edx,%eax
  106201:	c1 e0 02             	shl    $0x2,%eax
  106204:	05 20 df 11 00       	add    $0x11df20,%eax
  106209:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return list->next == list;
  10620c:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10620f:	8b 40 04             	mov    0x4(%eax),%eax
  106212:	39 45 b8             	cmp    %eax,-0x48(%ebp)
  106215:	0f 94 c0             	sete   %al
  106218:	0f b6 c0             	movzbl %al,%eax
  10621b:	85 c0                	test   %eax,%eax
  10621d:	75 24                	jne    106243 <buddy_check+0x3e9>
  10621f:	c7 44 24 0c df 81 10 	movl   $0x1081df,0xc(%esp)
  106226:	00 
  106227:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  10622e:	00 
  10622f:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  106236:	00 
  106237:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  10623e:	e8 a6 a1 ff ff       	call   1003e9 <__panic>
        free_area[i].nr_free = 0;
  106243:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106246:	89 d0                	mov    %edx,%eax
  106248:	01 c0                	add    %eax,%eax
  10624a:	01 d0                	add    %edx,%eax
  10624c:	c1 e0 02             	shl    $0x2,%eax
  10624f:	05 28 df 11 00       	add    $0x11df28,%eax
  106254:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    for (int i = 0; i <= MAXLEVEL; i++) {
  10625a:	ff 45 e4             	incl   -0x1c(%ebp)
  10625d:	83 7d e4 0c          	cmpl   $0xc,-0x1c(%ebp)
  106261:	0f 8e 31 ff ff ff    	jle    106198 <buddy_check+0x33e>
    }
    assert(alloc_page() == NULL);
  106267:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10626e:	e8 e5 c8 ff ff       	call   102b58 <alloc_pages>
  106273:	85 c0                	test   %eax,%eax
  106275:	74 24                	je     10629b <buddy_check+0x441>
  106277:	c7 44 24 0c fb 81 10 	movl   $0x1081fb,0xc(%esp)
  10627e:	00 
  10627f:	c7 44 24 08 a0 7f 10 	movl   $0x107fa0,0x8(%esp)
  106286:	00 
  106287:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  10628e:	00 
  10628f:	c7 04 24 b5 7f 10 00 	movl   $0x107fb5,(%esp)
  106296:	e8 4e a1 ff ff       	call   1003e9 <__panic>
    cprintf("clean successfully.\n");
  10629b:	c7 04 24 10 82 10 00 	movl   $0x108210,(%esp)
  1062a2:	e8 eb 9f ff ff       	call   100292 <cprintf>
    cprintf("p0\n");
  1062a7:	c7 04 24 a3 80 10 00 	movl   $0x1080a3,(%esp)
  1062ae:	e8 df 9f ff ff       	call   100292 <cprintf>
    free_page(p0);
  1062b3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1062ba:	00 
  1062bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1062be:	89 04 24             	mov    %eax,(%esp)
  1062c1:	e8 ca c8 ff ff       	call   102b90 <free_pages>
    cprintf("p1\n");
  1062c6:	c7 04 24 c3 80 10 00 	movl   $0x1080c3,(%esp)
  1062cd:	e8 c0 9f ff ff       	call   100292 <cprintf>
    free_page(p1);
  1062d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1062d9:	00 
  1062da:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1062dd:	89 04 24             	mov    %eax,(%esp)
  1062e0:	e8 ab c8 ff ff       	call   102b90 <free_pages>
    cprintf("p2\n");
  1062e5:	c7 04 24 e3 80 10 00 	movl   $0x1080e3,(%esp)
  1062ec:	e8 a1 9f ff ff       	call   100292 <cprintf>
    free_page(p2);
  1062f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1062f8:	00 
  1062f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1062fc:	89 04 24             	mov    %eax,(%esp)
  1062ff:	e8 8c c8 ff ff       	call   102b90 <free_pages>
    total = 0;
  106304:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
  10630b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  106312:	eb 1e                	jmp    106332 <buddy_check+0x4d8>
        total += free_area[i].nr_free;
  106314:	8b 55 e0             	mov    -0x20(%ebp),%edx
  106317:	89 d0                	mov    %edx,%eax
  106319:	01 c0                	add    %eax,%eax
  10631b:	01 d0                	add    %edx,%eax
  10631d:	c1 e0 02             	shl    $0x2,%eax
  106320:	05 28 df 11 00       	add    $0x11df28,%eax
  106325:	8b 10                	mov    (%eax),%edx
  106327:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10632a:	01 d0                	add    %edx,%eax
  10632c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
  10632f:	ff 45 e0             	incl   -0x20(%ebp)
  106332:	83 7d e0 0c          	cmpl   $0xc,-0x20(%ebp)
  106336:	7e dc                	jle    106314 <buddy_check+0x4ba>

    //assert((p0 = alloc_page()) != NULL);
    //assert((p1 = alloc_page()) != NULL);
    //assert((p2 = alloc_page()) != NULL);
    //assert(alloc_page() == NULL);
}
  106338:	90                   	nop
  106339:	c9                   	leave  
  10633a:	c3                   	ret    

0010633b <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  10633b:	55                   	push   %ebp
  10633c:	89 e5                	mov    %esp,%ebp
  10633e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  106341:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  106348:	eb 03                	jmp    10634d <strlen+0x12>
        cnt ++;
  10634a:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  10634d:	8b 45 08             	mov    0x8(%ebp),%eax
  106350:	8d 50 01             	lea    0x1(%eax),%edx
  106353:	89 55 08             	mov    %edx,0x8(%ebp)
  106356:	0f b6 00             	movzbl (%eax),%eax
  106359:	84 c0                	test   %al,%al
  10635b:	75 ed                	jne    10634a <strlen+0xf>
    }
    return cnt;
  10635d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  106360:	c9                   	leave  
  106361:	c3                   	ret    

00106362 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  106362:	55                   	push   %ebp
  106363:	89 e5                	mov    %esp,%ebp
  106365:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  106368:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  10636f:	eb 03                	jmp    106374 <strnlen+0x12>
        cnt ++;
  106371:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  106374:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106377:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10637a:	73 10                	jae    10638c <strnlen+0x2a>
  10637c:	8b 45 08             	mov    0x8(%ebp),%eax
  10637f:	8d 50 01             	lea    0x1(%eax),%edx
  106382:	89 55 08             	mov    %edx,0x8(%ebp)
  106385:	0f b6 00             	movzbl (%eax),%eax
  106388:	84 c0                	test   %al,%al
  10638a:	75 e5                	jne    106371 <strnlen+0xf>
    }
    return cnt;
  10638c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10638f:	c9                   	leave  
  106390:	c3                   	ret    

00106391 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  106391:	55                   	push   %ebp
  106392:	89 e5                	mov    %esp,%ebp
  106394:	57                   	push   %edi
  106395:	56                   	push   %esi
  106396:	83 ec 20             	sub    $0x20,%esp
  106399:	8b 45 08             	mov    0x8(%ebp),%eax
  10639c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10639f:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  1063a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1063a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1063ab:	89 d1                	mov    %edx,%ecx
  1063ad:	89 c2                	mov    %eax,%edx
  1063af:	89 ce                	mov    %ecx,%esi
  1063b1:	89 d7                	mov    %edx,%edi
  1063b3:	ac                   	lods   %ds:(%esi),%al
  1063b4:	aa                   	stos   %al,%es:(%edi)
  1063b5:	84 c0                	test   %al,%al
  1063b7:	75 fa                	jne    1063b3 <strcpy+0x22>
  1063b9:	89 fa                	mov    %edi,%edx
  1063bb:	89 f1                	mov    %esi,%ecx
  1063bd:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1063c0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  1063c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  1063c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  1063c9:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1063ca:	83 c4 20             	add    $0x20,%esp
  1063cd:	5e                   	pop    %esi
  1063ce:	5f                   	pop    %edi
  1063cf:	5d                   	pop    %ebp
  1063d0:	c3                   	ret    

001063d1 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1063d1:	55                   	push   %ebp
  1063d2:	89 e5                	mov    %esp,%ebp
  1063d4:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  1063d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1063da:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  1063dd:	eb 1e                	jmp    1063fd <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  1063df:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063e2:	0f b6 10             	movzbl (%eax),%edx
  1063e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1063e8:	88 10                	mov    %dl,(%eax)
  1063ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1063ed:	0f b6 00             	movzbl (%eax),%eax
  1063f0:	84 c0                	test   %al,%al
  1063f2:	74 03                	je     1063f7 <strncpy+0x26>
            src ++;
  1063f4:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  1063f7:	ff 45 fc             	incl   -0x4(%ebp)
  1063fa:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  1063fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106401:	75 dc                	jne    1063df <strncpy+0xe>
    }
    return dst;
  106403:	8b 45 08             	mov    0x8(%ebp),%eax
}
  106406:	c9                   	leave  
  106407:	c3                   	ret    

00106408 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  106408:	55                   	push   %ebp
  106409:	89 e5                	mov    %esp,%ebp
  10640b:	57                   	push   %edi
  10640c:	56                   	push   %esi
  10640d:	83 ec 20             	sub    $0x20,%esp
  106410:	8b 45 08             	mov    0x8(%ebp),%eax
  106413:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106416:	8b 45 0c             	mov    0xc(%ebp),%eax
  106419:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  10641c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10641f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106422:	89 d1                	mov    %edx,%ecx
  106424:	89 c2                	mov    %eax,%edx
  106426:	89 ce                	mov    %ecx,%esi
  106428:	89 d7                	mov    %edx,%edi
  10642a:	ac                   	lods   %ds:(%esi),%al
  10642b:	ae                   	scas   %es:(%edi),%al
  10642c:	75 08                	jne    106436 <strcmp+0x2e>
  10642e:	84 c0                	test   %al,%al
  106430:	75 f8                	jne    10642a <strcmp+0x22>
  106432:	31 c0                	xor    %eax,%eax
  106434:	eb 04                	jmp    10643a <strcmp+0x32>
  106436:	19 c0                	sbb    %eax,%eax
  106438:	0c 01                	or     $0x1,%al
  10643a:	89 fa                	mov    %edi,%edx
  10643c:	89 f1                	mov    %esi,%ecx
  10643e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106441:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  106444:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  106447:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  10644a:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  10644b:	83 c4 20             	add    $0x20,%esp
  10644e:	5e                   	pop    %esi
  10644f:	5f                   	pop    %edi
  106450:	5d                   	pop    %ebp
  106451:	c3                   	ret    

00106452 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  106452:	55                   	push   %ebp
  106453:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  106455:	eb 09                	jmp    106460 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  106457:	ff 4d 10             	decl   0x10(%ebp)
  10645a:	ff 45 08             	incl   0x8(%ebp)
  10645d:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  106460:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106464:	74 1a                	je     106480 <strncmp+0x2e>
  106466:	8b 45 08             	mov    0x8(%ebp),%eax
  106469:	0f b6 00             	movzbl (%eax),%eax
  10646c:	84 c0                	test   %al,%al
  10646e:	74 10                	je     106480 <strncmp+0x2e>
  106470:	8b 45 08             	mov    0x8(%ebp),%eax
  106473:	0f b6 10             	movzbl (%eax),%edx
  106476:	8b 45 0c             	mov    0xc(%ebp),%eax
  106479:	0f b6 00             	movzbl (%eax),%eax
  10647c:	38 c2                	cmp    %al,%dl
  10647e:	74 d7                	je     106457 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  106480:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106484:	74 18                	je     10649e <strncmp+0x4c>
  106486:	8b 45 08             	mov    0x8(%ebp),%eax
  106489:	0f b6 00             	movzbl (%eax),%eax
  10648c:	0f b6 d0             	movzbl %al,%edx
  10648f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106492:	0f b6 00             	movzbl (%eax),%eax
  106495:	0f b6 c0             	movzbl %al,%eax
  106498:	29 c2                	sub    %eax,%edx
  10649a:	89 d0                	mov    %edx,%eax
  10649c:	eb 05                	jmp    1064a3 <strncmp+0x51>
  10649e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1064a3:	5d                   	pop    %ebp
  1064a4:	c3                   	ret    

001064a5 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  1064a5:	55                   	push   %ebp
  1064a6:	89 e5                	mov    %esp,%ebp
  1064a8:	83 ec 04             	sub    $0x4,%esp
  1064ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  1064ae:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1064b1:	eb 13                	jmp    1064c6 <strchr+0x21>
        if (*s == c) {
  1064b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1064b6:	0f b6 00             	movzbl (%eax),%eax
  1064b9:	38 45 fc             	cmp    %al,-0x4(%ebp)
  1064bc:	75 05                	jne    1064c3 <strchr+0x1e>
            return (char *)s;
  1064be:	8b 45 08             	mov    0x8(%ebp),%eax
  1064c1:	eb 12                	jmp    1064d5 <strchr+0x30>
        }
        s ++;
  1064c3:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  1064c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1064c9:	0f b6 00             	movzbl (%eax),%eax
  1064cc:	84 c0                	test   %al,%al
  1064ce:	75 e3                	jne    1064b3 <strchr+0xe>
    }
    return NULL;
  1064d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1064d5:	c9                   	leave  
  1064d6:	c3                   	ret    

001064d7 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  1064d7:	55                   	push   %ebp
  1064d8:	89 e5                	mov    %esp,%ebp
  1064da:	83 ec 04             	sub    $0x4,%esp
  1064dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1064e0:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1064e3:	eb 0e                	jmp    1064f3 <strfind+0x1c>
        if (*s == c) {
  1064e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1064e8:	0f b6 00             	movzbl (%eax),%eax
  1064eb:	38 45 fc             	cmp    %al,-0x4(%ebp)
  1064ee:	74 0f                	je     1064ff <strfind+0x28>
            break;
        }
        s ++;
  1064f0:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  1064f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1064f6:	0f b6 00             	movzbl (%eax),%eax
  1064f9:	84 c0                	test   %al,%al
  1064fb:	75 e8                	jne    1064e5 <strfind+0xe>
  1064fd:	eb 01                	jmp    106500 <strfind+0x29>
            break;
  1064ff:	90                   	nop
    }
    return (char *)s;
  106500:	8b 45 08             	mov    0x8(%ebp),%eax
}
  106503:	c9                   	leave  
  106504:	c3                   	ret    

00106505 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  106505:	55                   	push   %ebp
  106506:	89 e5                	mov    %esp,%ebp
  106508:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  10650b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  106512:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  106519:	eb 03                	jmp    10651e <strtol+0x19>
        s ++;
  10651b:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  10651e:	8b 45 08             	mov    0x8(%ebp),%eax
  106521:	0f b6 00             	movzbl (%eax),%eax
  106524:	3c 20                	cmp    $0x20,%al
  106526:	74 f3                	je     10651b <strtol+0x16>
  106528:	8b 45 08             	mov    0x8(%ebp),%eax
  10652b:	0f b6 00             	movzbl (%eax),%eax
  10652e:	3c 09                	cmp    $0x9,%al
  106530:	74 e9                	je     10651b <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  106532:	8b 45 08             	mov    0x8(%ebp),%eax
  106535:	0f b6 00             	movzbl (%eax),%eax
  106538:	3c 2b                	cmp    $0x2b,%al
  10653a:	75 05                	jne    106541 <strtol+0x3c>
        s ++;
  10653c:	ff 45 08             	incl   0x8(%ebp)
  10653f:	eb 14                	jmp    106555 <strtol+0x50>
    }
    else if (*s == '-') {
  106541:	8b 45 08             	mov    0x8(%ebp),%eax
  106544:	0f b6 00             	movzbl (%eax),%eax
  106547:	3c 2d                	cmp    $0x2d,%al
  106549:	75 0a                	jne    106555 <strtol+0x50>
        s ++, neg = 1;
  10654b:	ff 45 08             	incl   0x8(%ebp)
  10654e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  106555:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106559:	74 06                	je     106561 <strtol+0x5c>
  10655b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  10655f:	75 22                	jne    106583 <strtol+0x7e>
  106561:	8b 45 08             	mov    0x8(%ebp),%eax
  106564:	0f b6 00             	movzbl (%eax),%eax
  106567:	3c 30                	cmp    $0x30,%al
  106569:	75 18                	jne    106583 <strtol+0x7e>
  10656b:	8b 45 08             	mov    0x8(%ebp),%eax
  10656e:	40                   	inc    %eax
  10656f:	0f b6 00             	movzbl (%eax),%eax
  106572:	3c 78                	cmp    $0x78,%al
  106574:	75 0d                	jne    106583 <strtol+0x7e>
        s += 2, base = 16;
  106576:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  10657a:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  106581:	eb 29                	jmp    1065ac <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  106583:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106587:	75 16                	jne    10659f <strtol+0x9a>
  106589:	8b 45 08             	mov    0x8(%ebp),%eax
  10658c:	0f b6 00             	movzbl (%eax),%eax
  10658f:	3c 30                	cmp    $0x30,%al
  106591:	75 0c                	jne    10659f <strtol+0x9a>
        s ++, base = 8;
  106593:	ff 45 08             	incl   0x8(%ebp)
  106596:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  10659d:	eb 0d                	jmp    1065ac <strtol+0xa7>
    }
    else if (base == 0) {
  10659f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1065a3:	75 07                	jne    1065ac <strtol+0xa7>
        base = 10;
  1065a5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  1065ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1065af:	0f b6 00             	movzbl (%eax),%eax
  1065b2:	3c 2f                	cmp    $0x2f,%al
  1065b4:	7e 1b                	jle    1065d1 <strtol+0xcc>
  1065b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1065b9:	0f b6 00             	movzbl (%eax),%eax
  1065bc:	3c 39                	cmp    $0x39,%al
  1065be:	7f 11                	jg     1065d1 <strtol+0xcc>
            dig = *s - '0';
  1065c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1065c3:	0f b6 00             	movzbl (%eax),%eax
  1065c6:	0f be c0             	movsbl %al,%eax
  1065c9:	83 e8 30             	sub    $0x30,%eax
  1065cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1065cf:	eb 48                	jmp    106619 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  1065d1:	8b 45 08             	mov    0x8(%ebp),%eax
  1065d4:	0f b6 00             	movzbl (%eax),%eax
  1065d7:	3c 60                	cmp    $0x60,%al
  1065d9:	7e 1b                	jle    1065f6 <strtol+0xf1>
  1065db:	8b 45 08             	mov    0x8(%ebp),%eax
  1065de:	0f b6 00             	movzbl (%eax),%eax
  1065e1:	3c 7a                	cmp    $0x7a,%al
  1065e3:	7f 11                	jg     1065f6 <strtol+0xf1>
            dig = *s - 'a' + 10;
  1065e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1065e8:	0f b6 00             	movzbl (%eax),%eax
  1065eb:	0f be c0             	movsbl %al,%eax
  1065ee:	83 e8 57             	sub    $0x57,%eax
  1065f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1065f4:	eb 23                	jmp    106619 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  1065f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1065f9:	0f b6 00             	movzbl (%eax),%eax
  1065fc:	3c 40                	cmp    $0x40,%al
  1065fe:	7e 3b                	jle    10663b <strtol+0x136>
  106600:	8b 45 08             	mov    0x8(%ebp),%eax
  106603:	0f b6 00             	movzbl (%eax),%eax
  106606:	3c 5a                	cmp    $0x5a,%al
  106608:	7f 31                	jg     10663b <strtol+0x136>
            dig = *s - 'A' + 10;
  10660a:	8b 45 08             	mov    0x8(%ebp),%eax
  10660d:	0f b6 00             	movzbl (%eax),%eax
  106610:	0f be c0             	movsbl %al,%eax
  106613:	83 e8 37             	sub    $0x37,%eax
  106616:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  106619:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10661c:	3b 45 10             	cmp    0x10(%ebp),%eax
  10661f:	7d 19                	jge    10663a <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  106621:	ff 45 08             	incl   0x8(%ebp)
  106624:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106627:	0f af 45 10          	imul   0x10(%ebp),%eax
  10662b:	89 c2                	mov    %eax,%edx
  10662d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106630:	01 d0                	add    %edx,%eax
  106632:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  106635:	e9 72 ff ff ff       	jmp    1065ac <strtol+0xa7>
            break;
  10663a:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  10663b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10663f:	74 08                	je     106649 <strtol+0x144>
        *endptr = (char *) s;
  106641:	8b 45 0c             	mov    0xc(%ebp),%eax
  106644:	8b 55 08             	mov    0x8(%ebp),%edx
  106647:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  106649:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  10664d:	74 07                	je     106656 <strtol+0x151>
  10664f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106652:	f7 d8                	neg    %eax
  106654:	eb 03                	jmp    106659 <strtol+0x154>
  106656:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  106659:	c9                   	leave  
  10665a:	c3                   	ret    

0010665b <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  10665b:	55                   	push   %ebp
  10665c:	89 e5                	mov    %esp,%ebp
  10665e:	57                   	push   %edi
  10665f:	83 ec 24             	sub    $0x24,%esp
  106662:	8b 45 0c             	mov    0xc(%ebp),%eax
  106665:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  106668:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  10666c:	8b 55 08             	mov    0x8(%ebp),%edx
  10666f:	89 55 f8             	mov    %edx,-0x8(%ebp)
  106672:	88 45 f7             	mov    %al,-0x9(%ebp)
  106675:	8b 45 10             	mov    0x10(%ebp),%eax
  106678:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  10667b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  10667e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  106682:	8b 55 f8             	mov    -0x8(%ebp),%edx
  106685:	89 d7                	mov    %edx,%edi
  106687:	f3 aa                	rep stos %al,%es:(%edi)
  106689:	89 fa                	mov    %edi,%edx
  10668b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10668e:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  106691:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106694:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  106695:	83 c4 24             	add    $0x24,%esp
  106698:	5f                   	pop    %edi
  106699:	5d                   	pop    %ebp
  10669a:	c3                   	ret    

0010669b <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  10669b:	55                   	push   %ebp
  10669c:	89 e5                	mov    %esp,%ebp
  10669e:	57                   	push   %edi
  10669f:	56                   	push   %esi
  1066a0:	53                   	push   %ebx
  1066a1:	83 ec 30             	sub    $0x30,%esp
  1066a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1066a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1066aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1066ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1066b0:	8b 45 10             	mov    0x10(%ebp),%eax
  1066b3:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1066b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1066b9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1066bc:	73 42                	jae    106700 <memmove+0x65>
  1066be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1066c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1066c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1066c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1066ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1066cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1066d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1066d3:	c1 e8 02             	shr    $0x2,%eax
  1066d6:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1066d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1066db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1066de:	89 d7                	mov    %edx,%edi
  1066e0:	89 c6                	mov    %eax,%esi
  1066e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1066e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1066e7:	83 e1 03             	and    $0x3,%ecx
  1066ea:	74 02                	je     1066ee <memmove+0x53>
  1066ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1066ee:	89 f0                	mov    %esi,%eax
  1066f0:	89 fa                	mov    %edi,%edx
  1066f2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  1066f5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1066f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  1066fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  1066fe:	eb 36                	jmp    106736 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  106700:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106703:	8d 50 ff             	lea    -0x1(%eax),%edx
  106706:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106709:	01 c2                	add    %eax,%edx
  10670b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10670e:	8d 48 ff             	lea    -0x1(%eax),%ecx
  106711:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106714:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  106717:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10671a:	89 c1                	mov    %eax,%ecx
  10671c:	89 d8                	mov    %ebx,%eax
  10671e:	89 d6                	mov    %edx,%esi
  106720:	89 c7                	mov    %eax,%edi
  106722:	fd                   	std    
  106723:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106725:	fc                   	cld    
  106726:	89 f8                	mov    %edi,%eax
  106728:	89 f2                	mov    %esi,%edx
  10672a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  10672d:	89 55 c8             	mov    %edx,-0x38(%ebp)
  106730:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  106733:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  106736:	83 c4 30             	add    $0x30,%esp
  106739:	5b                   	pop    %ebx
  10673a:	5e                   	pop    %esi
  10673b:	5f                   	pop    %edi
  10673c:	5d                   	pop    %ebp
  10673d:	c3                   	ret    

0010673e <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  10673e:	55                   	push   %ebp
  10673f:	89 e5                	mov    %esp,%ebp
  106741:	57                   	push   %edi
  106742:	56                   	push   %esi
  106743:	83 ec 20             	sub    $0x20,%esp
  106746:	8b 45 08             	mov    0x8(%ebp),%eax
  106749:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10674c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10674f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106752:	8b 45 10             	mov    0x10(%ebp),%eax
  106755:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106758:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10675b:	c1 e8 02             	shr    $0x2,%eax
  10675e:	89 c1                	mov    %eax,%ecx
    asm volatile (
  106760:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106763:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106766:	89 d7                	mov    %edx,%edi
  106768:	89 c6                	mov    %eax,%esi
  10676a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10676c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  10676f:	83 e1 03             	and    $0x3,%ecx
  106772:	74 02                	je     106776 <memcpy+0x38>
  106774:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106776:	89 f0                	mov    %esi,%eax
  106778:	89 fa                	mov    %edi,%edx
  10677a:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  10677d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  106780:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  106783:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  106786:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  106787:	83 c4 20             	add    $0x20,%esp
  10678a:	5e                   	pop    %esi
  10678b:	5f                   	pop    %edi
  10678c:	5d                   	pop    %ebp
  10678d:	c3                   	ret    

0010678e <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  10678e:	55                   	push   %ebp
  10678f:	89 e5                	mov    %esp,%ebp
  106791:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  106794:	8b 45 08             	mov    0x8(%ebp),%eax
  106797:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  10679a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10679d:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1067a0:	eb 2e                	jmp    1067d0 <memcmp+0x42>
        if (*s1 != *s2) {
  1067a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1067a5:	0f b6 10             	movzbl (%eax),%edx
  1067a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1067ab:	0f b6 00             	movzbl (%eax),%eax
  1067ae:	38 c2                	cmp    %al,%dl
  1067b0:	74 18                	je     1067ca <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1067b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1067b5:	0f b6 00             	movzbl (%eax),%eax
  1067b8:	0f b6 d0             	movzbl %al,%edx
  1067bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1067be:	0f b6 00             	movzbl (%eax),%eax
  1067c1:	0f b6 c0             	movzbl %al,%eax
  1067c4:	29 c2                	sub    %eax,%edx
  1067c6:	89 d0                	mov    %edx,%eax
  1067c8:	eb 18                	jmp    1067e2 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  1067ca:	ff 45 fc             	incl   -0x4(%ebp)
  1067cd:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  1067d0:	8b 45 10             	mov    0x10(%ebp),%eax
  1067d3:	8d 50 ff             	lea    -0x1(%eax),%edx
  1067d6:	89 55 10             	mov    %edx,0x10(%ebp)
  1067d9:	85 c0                	test   %eax,%eax
  1067db:	75 c5                	jne    1067a2 <memcmp+0x14>
    }
    return 0;
  1067dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1067e2:	c9                   	leave  
  1067e3:	c3                   	ret    

001067e4 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1067e4:	55                   	push   %ebp
  1067e5:	89 e5                	mov    %esp,%ebp
  1067e7:	83 ec 58             	sub    $0x58,%esp
  1067ea:	8b 45 10             	mov    0x10(%ebp),%eax
  1067ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1067f0:	8b 45 14             	mov    0x14(%ebp),%eax
  1067f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1067f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1067f9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1067fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1067ff:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  106802:	8b 45 18             	mov    0x18(%ebp),%eax
  106805:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106808:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10680b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10680e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106811:	89 55 f0             	mov    %edx,-0x10(%ebp)
  106814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106817:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10681a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10681e:	74 1c                	je     10683c <printnum+0x58>
  106820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106823:	ba 00 00 00 00       	mov    $0x0,%edx
  106828:	f7 75 e4             	divl   -0x1c(%ebp)
  10682b:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10682e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106831:	ba 00 00 00 00       	mov    $0x0,%edx
  106836:	f7 75 e4             	divl   -0x1c(%ebp)
  106839:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10683c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10683f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106842:	f7 75 e4             	divl   -0x1c(%ebp)
  106845:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106848:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10684b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10684e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  106851:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106854:	89 55 ec             	mov    %edx,-0x14(%ebp)
  106857:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10685a:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  10685d:	8b 45 18             	mov    0x18(%ebp),%eax
  106860:	ba 00 00 00 00       	mov    $0x0,%edx
  106865:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  106868:	72 56                	jb     1068c0 <printnum+0xdc>
  10686a:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  10686d:	77 05                	ja     106874 <printnum+0x90>
  10686f:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  106872:	72 4c                	jb     1068c0 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  106874:	8b 45 1c             	mov    0x1c(%ebp),%eax
  106877:	8d 50 ff             	lea    -0x1(%eax),%edx
  10687a:	8b 45 20             	mov    0x20(%ebp),%eax
  10687d:	89 44 24 18          	mov    %eax,0x18(%esp)
  106881:	89 54 24 14          	mov    %edx,0x14(%esp)
  106885:	8b 45 18             	mov    0x18(%ebp),%eax
  106888:	89 44 24 10          	mov    %eax,0x10(%esp)
  10688c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10688f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106892:	89 44 24 08          	mov    %eax,0x8(%esp)
  106896:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10689a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10689d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1068a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1068a4:	89 04 24             	mov    %eax,(%esp)
  1068a7:	e8 38 ff ff ff       	call   1067e4 <printnum>
  1068ac:	eb 1b                	jmp    1068c9 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1068ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  1068b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1068b5:	8b 45 20             	mov    0x20(%ebp),%eax
  1068b8:	89 04 24             	mov    %eax,(%esp)
  1068bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1068be:	ff d0                	call   *%eax
        while (-- width > 0)
  1068c0:	ff 4d 1c             	decl   0x1c(%ebp)
  1068c3:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1068c7:	7f e5                	jg     1068ae <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1068c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1068cc:	05 d0 82 10 00       	add    $0x1082d0,%eax
  1068d1:	0f b6 00             	movzbl (%eax),%eax
  1068d4:	0f be c0             	movsbl %al,%eax
  1068d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  1068da:	89 54 24 04          	mov    %edx,0x4(%esp)
  1068de:	89 04 24             	mov    %eax,(%esp)
  1068e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1068e4:	ff d0                	call   *%eax
}
  1068e6:	90                   	nop
  1068e7:	c9                   	leave  
  1068e8:	c3                   	ret    

001068e9 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1068e9:	55                   	push   %ebp
  1068ea:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1068ec:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1068f0:	7e 14                	jle    106906 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1068f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1068f5:	8b 00                	mov    (%eax),%eax
  1068f7:	8d 48 08             	lea    0x8(%eax),%ecx
  1068fa:	8b 55 08             	mov    0x8(%ebp),%edx
  1068fd:	89 0a                	mov    %ecx,(%edx)
  1068ff:	8b 50 04             	mov    0x4(%eax),%edx
  106902:	8b 00                	mov    (%eax),%eax
  106904:	eb 30                	jmp    106936 <getuint+0x4d>
    }
    else if (lflag) {
  106906:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10690a:	74 16                	je     106922 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  10690c:	8b 45 08             	mov    0x8(%ebp),%eax
  10690f:	8b 00                	mov    (%eax),%eax
  106911:	8d 48 04             	lea    0x4(%eax),%ecx
  106914:	8b 55 08             	mov    0x8(%ebp),%edx
  106917:	89 0a                	mov    %ecx,(%edx)
  106919:	8b 00                	mov    (%eax),%eax
  10691b:	ba 00 00 00 00       	mov    $0x0,%edx
  106920:	eb 14                	jmp    106936 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  106922:	8b 45 08             	mov    0x8(%ebp),%eax
  106925:	8b 00                	mov    (%eax),%eax
  106927:	8d 48 04             	lea    0x4(%eax),%ecx
  10692a:	8b 55 08             	mov    0x8(%ebp),%edx
  10692d:	89 0a                	mov    %ecx,(%edx)
  10692f:	8b 00                	mov    (%eax),%eax
  106931:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  106936:	5d                   	pop    %ebp
  106937:	c3                   	ret    

00106938 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  106938:	55                   	push   %ebp
  106939:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10693b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10693f:	7e 14                	jle    106955 <getint+0x1d>
        return va_arg(*ap, long long);
  106941:	8b 45 08             	mov    0x8(%ebp),%eax
  106944:	8b 00                	mov    (%eax),%eax
  106946:	8d 48 08             	lea    0x8(%eax),%ecx
  106949:	8b 55 08             	mov    0x8(%ebp),%edx
  10694c:	89 0a                	mov    %ecx,(%edx)
  10694e:	8b 50 04             	mov    0x4(%eax),%edx
  106951:	8b 00                	mov    (%eax),%eax
  106953:	eb 28                	jmp    10697d <getint+0x45>
    }
    else if (lflag) {
  106955:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  106959:	74 12                	je     10696d <getint+0x35>
        return va_arg(*ap, long);
  10695b:	8b 45 08             	mov    0x8(%ebp),%eax
  10695e:	8b 00                	mov    (%eax),%eax
  106960:	8d 48 04             	lea    0x4(%eax),%ecx
  106963:	8b 55 08             	mov    0x8(%ebp),%edx
  106966:	89 0a                	mov    %ecx,(%edx)
  106968:	8b 00                	mov    (%eax),%eax
  10696a:	99                   	cltd   
  10696b:	eb 10                	jmp    10697d <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  10696d:	8b 45 08             	mov    0x8(%ebp),%eax
  106970:	8b 00                	mov    (%eax),%eax
  106972:	8d 48 04             	lea    0x4(%eax),%ecx
  106975:	8b 55 08             	mov    0x8(%ebp),%edx
  106978:	89 0a                	mov    %ecx,(%edx)
  10697a:	8b 00                	mov    (%eax),%eax
  10697c:	99                   	cltd   
    }
}
  10697d:	5d                   	pop    %ebp
  10697e:	c3                   	ret    

0010697f <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  10697f:	55                   	push   %ebp
  106980:	89 e5                	mov    %esp,%ebp
  106982:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  106985:	8d 45 14             	lea    0x14(%ebp),%eax
  106988:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  10698b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10698e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106992:	8b 45 10             	mov    0x10(%ebp),%eax
  106995:	89 44 24 08          	mov    %eax,0x8(%esp)
  106999:	8b 45 0c             	mov    0xc(%ebp),%eax
  10699c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1069a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1069a3:	89 04 24             	mov    %eax,(%esp)
  1069a6:	e8 03 00 00 00       	call   1069ae <vprintfmt>
    va_end(ap);
}
  1069ab:	90                   	nop
  1069ac:	c9                   	leave  
  1069ad:	c3                   	ret    

001069ae <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1069ae:	55                   	push   %ebp
  1069af:	89 e5                	mov    %esp,%ebp
  1069b1:	56                   	push   %esi
  1069b2:	53                   	push   %ebx
  1069b3:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1069b6:	eb 17                	jmp    1069cf <vprintfmt+0x21>
            if (ch == '\0') {
  1069b8:	85 db                	test   %ebx,%ebx
  1069ba:	0f 84 bf 03 00 00    	je     106d7f <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  1069c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1069c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1069c7:	89 1c 24             	mov    %ebx,(%esp)
  1069ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1069cd:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1069cf:	8b 45 10             	mov    0x10(%ebp),%eax
  1069d2:	8d 50 01             	lea    0x1(%eax),%edx
  1069d5:	89 55 10             	mov    %edx,0x10(%ebp)
  1069d8:	0f b6 00             	movzbl (%eax),%eax
  1069db:	0f b6 d8             	movzbl %al,%ebx
  1069de:	83 fb 25             	cmp    $0x25,%ebx
  1069e1:	75 d5                	jne    1069b8 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  1069e3:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  1069e7:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1069ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1069f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  1069f4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1069fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1069fe:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  106a01:	8b 45 10             	mov    0x10(%ebp),%eax
  106a04:	8d 50 01             	lea    0x1(%eax),%edx
  106a07:	89 55 10             	mov    %edx,0x10(%ebp)
  106a0a:	0f b6 00             	movzbl (%eax),%eax
  106a0d:	0f b6 d8             	movzbl %al,%ebx
  106a10:	8d 43 dd             	lea    -0x23(%ebx),%eax
  106a13:	83 f8 55             	cmp    $0x55,%eax
  106a16:	0f 87 37 03 00 00    	ja     106d53 <vprintfmt+0x3a5>
  106a1c:	8b 04 85 f4 82 10 00 	mov    0x1082f4(,%eax,4),%eax
  106a23:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  106a25:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  106a29:	eb d6                	jmp    106a01 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  106a2b:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  106a2f:	eb d0                	jmp    106a01 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  106a31:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  106a38:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106a3b:	89 d0                	mov    %edx,%eax
  106a3d:	c1 e0 02             	shl    $0x2,%eax
  106a40:	01 d0                	add    %edx,%eax
  106a42:	01 c0                	add    %eax,%eax
  106a44:	01 d8                	add    %ebx,%eax
  106a46:	83 e8 30             	sub    $0x30,%eax
  106a49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  106a4c:	8b 45 10             	mov    0x10(%ebp),%eax
  106a4f:	0f b6 00             	movzbl (%eax),%eax
  106a52:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  106a55:	83 fb 2f             	cmp    $0x2f,%ebx
  106a58:	7e 38                	jle    106a92 <vprintfmt+0xe4>
  106a5a:	83 fb 39             	cmp    $0x39,%ebx
  106a5d:	7f 33                	jg     106a92 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  106a5f:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  106a62:	eb d4                	jmp    106a38 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  106a64:	8b 45 14             	mov    0x14(%ebp),%eax
  106a67:	8d 50 04             	lea    0x4(%eax),%edx
  106a6a:	89 55 14             	mov    %edx,0x14(%ebp)
  106a6d:	8b 00                	mov    (%eax),%eax
  106a6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  106a72:	eb 1f                	jmp    106a93 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  106a74:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106a78:	79 87                	jns    106a01 <vprintfmt+0x53>
                width = 0;
  106a7a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  106a81:	e9 7b ff ff ff       	jmp    106a01 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  106a86:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  106a8d:	e9 6f ff ff ff       	jmp    106a01 <vprintfmt+0x53>
            goto process_precision;
  106a92:	90                   	nop

        process_precision:
            if (width < 0)
  106a93:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106a97:	0f 89 64 ff ff ff    	jns    106a01 <vprintfmt+0x53>
                width = precision, precision = -1;
  106a9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106aa0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106aa3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  106aaa:	e9 52 ff ff ff       	jmp    106a01 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  106aaf:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  106ab2:	e9 4a ff ff ff       	jmp    106a01 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  106ab7:	8b 45 14             	mov    0x14(%ebp),%eax
  106aba:	8d 50 04             	lea    0x4(%eax),%edx
  106abd:	89 55 14             	mov    %edx,0x14(%ebp)
  106ac0:	8b 00                	mov    (%eax),%eax
  106ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
  106ac5:	89 54 24 04          	mov    %edx,0x4(%esp)
  106ac9:	89 04 24             	mov    %eax,(%esp)
  106acc:	8b 45 08             	mov    0x8(%ebp),%eax
  106acf:	ff d0                	call   *%eax
            break;
  106ad1:	e9 a4 02 00 00       	jmp    106d7a <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  106ad6:	8b 45 14             	mov    0x14(%ebp),%eax
  106ad9:	8d 50 04             	lea    0x4(%eax),%edx
  106adc:	89 55 14             	mov    %edx,0x14(%ebp)
  106adf:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  106ae1:	85 db                	test   %ebx,%ebx
  106ae3:	79 02                	jns    106ae7 <vprintfmt+0x139>
                err = -err;
  106ae5:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  106ae7:	83 fb 06             	cmp    $0x6,%ebx
  106aea:	7f 0b                	jg     106af7 <vprintfmt+0x149>
  106aec:	8b 34 9d b4 82 10 00 	mov    0x1082b4(,%ebx,4),%esi
  106af3:	85 f6                	test   %esi,%esi
  106af5:	75 23                	jne    106b1a <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  106af7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  106afb:	c7 44 24 08 e1 82 10 	movl   $0x1082e1,0x8(%esp)
  106b02:	00 
  106b03:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b06:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  106b0d:	89 04 24             	mov    %eax,(%esp)
  106b10:	e8 6a fe ff ff       	call   10697f <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  106b15:	e9 60 02 00 00       	jmp    106d7a <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  106b1a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  106b1e:	c7 44 24 08 ea 82 10 	movl   $0x1082ea,0x8(%esp)
  106b25:	00 
  106b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b29:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  106b30:	89 04 24             	mov    %eax,(%esp)
  106b33:	e8 47 fe ff ff       	call   10697f <printfmt>
            break;
  106b38:	e9 3d 02 00 00       	jmp    106d7a <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  106b3d:	8b 45 14             	mov    0x14(%ebp),%eax
  106b40:	8d 50 04             	lea    0x4(%eax),%edx
  106b43:	89 55 14             	mov    %edx,0x14(%ebp)
  106b46:	8b 30                	mov    (%eax),%esi
  106b48:	85 f6                	test   %esi,%esi
  106b4a:	75 05                	jne    106b51 <vprintfmt+0x1a3>
                p = "(null)";
  106b4c:	be ed 82 10 00       	mov    $0x1082ed,%esi
            }
            if (width > 0 && padc != '-') {
  106b51:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106b55:	7e 76                	jle    106bcd <vprintfmt+0x21f>
  106b57:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  106b5b:	74 70                	je     106bcd <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  106b5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106b60:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b64:	89 34 24             	mov    %esi,(%esp)
  106b67:	e8 f6 f7 ff ff       	call   106362 <strnlen>
  106b6c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  106b6f:	29 c2                	sub    %eax,%edx
  106b71:	89 d0                	mov    %edx,%eax
  106b73:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106b76:	eb 16                	jmp    106b8e <vprintfmt+0x1e0>
                    putch(padc, putdat);
  106b78:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  106b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  106b7f:	89 54 24 04          	mov    %edx,0x4(%esp)
  106b83:	89 04 24             	mov    %eax,(%esp)
  106b86:	8b 45 08             	mov    0x8(%ebp),%eax
  106b89:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  106b8b:	ff 4d e8             	decl   -0x18(%ebp)
  106b8e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106b92:	7f e4                	jg     106b78 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  106b94:	eb 37                	jmp    106bcd <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  106b96:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  106b9a:	74 1f                	je     106bbb <vprintfmt+0x20d>
  106b9c:	83 fb 1f             	cmp    $0x1f,%ebx
  106b9f:	7e 05                	jle    106ba6 <vprintfmt+0x1f8>
  106ba1:	83 fb 7e             	cmp    $0x7e,%ebx
  106ba4:	7e 15                	jle    106bbb <vprintfmt+0x20d>
                    putch('?', putdat);
  106ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
  106ba9:	89 44 24 04          	mov    %eax,0x4(%esp)
  106bad:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  106bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  106bb7:	ff d0                	call   *%eax
  106bb9:	eb 0f                	jmp    106bca <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  106bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  106bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  106bc2:	89 1c 24             	mov    %ebx,(%esp)
  106bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  106bc8:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  106bca:	ff 4d e8             	decl   -0x18(%ebp)
  106bcd:	89 f0                	mov    %esi,%eax
  106bcf:	8d 70 01             	lea    0x1(%eax),%esi
  106bd2:	0f b6 00             	movzbl (%eax),%eax
  106bd5:	0f be d8             	movsbl %al,%ebx
  106bd8:	85 db                	test   %ebx,%ebx
  106bda:	74 27                	je     106c03 <vprintfmt+0x255>
  106bdc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106be0:	78 b4                	js     106b96 <vprintfmt+0x1e8>
  106be2:	ff 4d e4             	decl   -0x1c(%ebp)
  106be5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106be9:	79 ab                	jns    106b96 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  106beb:	eb 16                	jmp    106c03 <vprintfmt+0x255>
                putch(' ', putdat);
  106bed:	8b 45 0c             	mov    0xc(%ebp),%eax
  106bf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  106bf4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  106bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  106bfe:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  106c00:	ff 4d e8             	decl   -0x18(%ebp)
  106c03:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106c07:	7f e4                	jg     106bed <vprintfmt+0x23f>
            }
            break;
  106c09:	e9 6c 01 00 00       	jmp    106d7a <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  106c0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106c11:	89 44 24 04          	mov    %eax,0x4(%esp)
  106c15:	8d 45 14             	lea    0x14(%ebp),%eax
  106c18:	89 04 24             	mov    %eax,(%esp)
  106c1b:	e8 18 fd ff ff       	call   106938 <getint>
  106c20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106c23:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  106c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106c29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106c2c:	85 d2                	test   %edx,%edx
  106c2e:	79 26                	jns    106c56 <vprintfmt+0x2a8>
                putch('-', putdat);
  106c30:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c33:	89 44 24 04          	mov    %eax,0x4(%esp)
  106c37:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  106c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  106c41:	ff d0                	call   *%eax
                num = -(long long)num;
  106c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106c46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106c49:	f7 d8                	neg    %eax
  106c4b:	83 d2 00             	adc    $0x0,%edx
  106c4e:	f7 da                	neg    %edx
  106c50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106c53:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  106c56:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106c5d:	e9 a8 00 00 00       	jmp    106d0a <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  106c62:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106c65:	89 44 24 04          	mov    %eax,0x4(%esp)
  106c69:	8d 45 14             	lea    0x14(%ebp),%eax
  106c6c:	89 04 24             	mov    %eax,(%esp)
  106c6f:	e8 75 fc ff ff       	call   1068e9 <getuint>
  106c74:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106c77:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  106c7a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106c81:	e9 84 00 00 00       	jmp    106d0a <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  106c86:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106c89:	89 44 24 04          	mov    %eax,0x4(%esp)
  106c8d:	8d 45 14             	lea    0x14(%ebp),%eax
  106c90:	89 04 24             	mov    %eax,(%esp)
  106c93:	e8 51 fc ff ff       	call   1068e9 <getuint>
  106c98:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106c9b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  106c9e:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  106ca5:	eb 63                	jmp    106d0a <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  106ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
  106caa:	89 44 24 04          	mov    %eax,0x4(%esp)
  106cae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  106cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  106cb8:	ff d0                	call   *%eax
            putch('x', putdat);
  106cba:	8b 45 0c             	mov    0xc(%ebp),%eax
  106cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  106cc1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  106cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  106ccb:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  106ccd:	8b 45 14             	mov    0x14(%ebp),%eax
  106cd0:	8d 50 04             	lea    0x4(%eax),%edx
  106cd3:	89 55 14             	mov    %edx,0x14(%ebp)
  106cd6:	8b 00                	mov    (%eax),%eax
  106cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106cdb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  106ce2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  106ce9:	eb 1f                	jmp    106d0a <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  106ceb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106cee:	89 44 24 04          	mov    %eax,0x4(%esp)
  106cf2:	8d 45 14             	lea    0x14(%ebp),%eax
  106cf5:	89 04 24             	mov    %eax,(%esp)
  106cf8:	e8 ec fb ff ff       	call   1068e9 <getuint>
  106cfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106d00:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  106d03:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  106d0a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  106d0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106d11:	89 54 24 18          	mov    %edx,0x18(%esp)
  106d15:	8b 55 e8             	mov    -0x18(%ebp),%edx
  106d18:	89 54 24 14          	mov    %edx,0x14(%esp)
  106d1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  106d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106d23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106d26:	89 44 24 08          	mov    %eax,0x8(%esp)
  106d2a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  106d31:	89 44 24 04          	mov    %eax,0x4(%esp)
  106d35:	8b 45 08             	mov    0x8(%ebp),%eax
  106d38:	89 04 24             	mov    %eax,(%esp)
  106d3b:	e8 a4 fa ff ff       	call   1067e4 <printnum>
            break;
  106d40:	eb 38                	jmp    106d7a <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  106d42:	8b 45 0c             	mov    0xc(%ebp),%eax
  106d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  106d49:	89 1c 24             	mov    %ebx,(%esp)
  106d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  106d4f:	ff d0                	call   *%eax
            break;
  106d51:	eb 27                	jmp    106d7a <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  106d53:	8b 45 0c             	mov    0xc(%ebp),%eax
  106d56:	89 44 24 04          	mov    %eax,0x4(%esp)
  106d5a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  106d61:	8b 45 08             	mov    0x8(%ebp),%eax
  106d64:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  106d66:	ff 4d 10             	decl   0x10(%ebp)
  106d69:	eb 03                	jmp    106d6e <vprintfmt+0x3c0>
  106d6b:	ff 4d 10             	decl   0x10(%ebp)
  106d6e:	8b 45 10             	mov    0x10(%ebp),%eax
  106d71:	48                   	dec    %eax
  106d72:	0f b6 00             	movzbl (%eax),%eax
  106d75:	3c 25                	cmp    $0x25,%al
  106d77:	75 f2                	jne    106d6b <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  106d79:	90                   	nop
    while (1) {
  106d7a:	e9 37 fc ff ff       	jmp    1069b6 <vprintfmt+0x8>
                return;
  106d7f:	90                   	nop
        }
    }
}
  106d80:	83 c4 40             	add    $0x40,%esp
  106d83:	5b                   	pop    %ebx
  106d84:	5e                   	pop    %esi
  106d85:	5d                   	pop    %ebp
  106d86:	c3                   	ret    

00106d87 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  106d87:	55                   	push   %ebp
  106d88:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  106d8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  106d8d:	8b 40 08             	mov    0x8(%eax),%eax
  106d90:	8d 50 01             	lea    0x1(%eax),%edx
  106d93:	8b 45 0c             	mov    0xc(%ebp),%eax
  106d96:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  106d99:	8b 45 0c             	mov    0xc(%ebp),%eax
  106d9c:	8b 10                	mov    (%eax),%edx
  106d9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  106da1:	8b 40 04             	mov    0x4(%eax),%eax
  106da4:	39 c2                	cmp    %eax,%edx
  106da6:	73 12                	jae    106dba <sprintputch+0x33>
        *b->buf ++ = ch;
  106da8:	8b 45 0c             	mov    0xc(%ebp),%eax
  106dab:	8b 00                	mov    (%eax),%eax
  106dad:	8d 48 01             	lea    0x1(%eax),%ecx
  106db0:	8b 55 0c             	mov    0xc(%ebp),%edx
  106db3:	89 0a                	mov    %ecx,(%edx)
  106db5:	8b 55 08             	mov    0x8(%ebp),%edx
  106db8:	88 10                	mov    %dl,(%eax)
    }
}
  106dba:	90                   	nop
  106dbb:	5d                   	pop    %ebp
  106dbc:	c3                   	ret    

00106dbd <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  106dbd:	55                   	push   %ebp
  106dbe:	89 e5                	mov    %esp,%ebp
  106dc0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  106dc3:	8d 45 14             	lea    0x14(%ebp),%eax
  106dc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  106dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106dcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106dd0:	8b 45 10             	mov    0x10(%ebp),%eax
  106dd3:	89 44 24 08          	mov    %eax,0x8(%esp)
  106dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  106dda:	89 44 24 04          	mov    %eax,0x4(%esp)
  106dde:	8b 45 08             	mov    0x8(%ebp),%eax
  106de1:	89 04 24             	mov    %eax,(%esp)
  106de4:	e8 08 00 00 00       	call   106df1 <vsnprintf>
  106de9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  106dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106def:	c9                   	leave  
  106df0:	c3                   	ret    

00106df1 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  106df1:	55                   	push   %ebp
  106df2:	89 e5                	mov    %esp,%ebp
  106df4:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  106df7:	8b 45 08             	mov    0x8(%ebp),%eax
  106dfa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  106e00:	8d 50 ff             	lea    -0x1(%eax),%edx
  106e03:	8b 45 08             	mov    0x8(%ebp),%eax
  106e06:	01 d0                	add    %edx,%eax
  106e08:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106e0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  106e12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  106e16:	74 0a                	je     106e22 <vsnprintf+0x31>
  106e18:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106e1e:	39 c2                	cmp    %eax,%edx
  106e20:	76 07                	jbe    106e29 <vsnprintf+0x38>
        return -E_INVAL;
  106e22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  106e27:	eb 2a                	jmp    106e53 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  106e29:	8b 45 14             	mov    0x14(%ebp),%eax
  106e2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106e30:	8b 45 10             	mov    0x10(%ebp),%eax
  106e33:	89 44 24 08          	mov    %eax,0x8(%esp)
  106e37:	8d 45 ec             	lea    -0x14(%ebp),%eax
  106e3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  106e3e:	c7 04 24 87 6d 10 00 	movl   $0x106d87,(%esp)
  106e45:	e8 64 fb ff ff       	call   1069ae <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  106e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106e4d:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  106e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106e53:	c9                   	leave  
  106e54:	c3                   	ret    
