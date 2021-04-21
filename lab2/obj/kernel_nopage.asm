
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
  10005d:	e8 5b 64 00 00       	call   1064bd <memset>

    cons_init();                // init the console
  100062:	e8 80 15 00 00       	call   1015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 c0 6c 10 00 	movl   $0x106cc0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 dc 6c 10 00 	movl   $0x106cdc,(%esp)
  10007c:	e8 11 02 00 00       	call   100292 <cprintf>

    print_kerninfo();
  100081:	e8 b2 08 00 00       	call   100938 <print_kerninfo>

    grade_backtrace();
  100086:	e8 89 00 00 00       	call   100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 8b 30 00 00       	call   10311b <pmm_init>

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
  100162:	c7 04 24 e1 6c 10 00 	movl   $0x106ce1,(%esp)
  100169:	e8 24 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100172:	89 c2                	mov    %eax,%edx
  100174:	a1 00 d0 11 00       	mov    0x11d000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 ef 6c 10 00 	movl   $0x106cef,(%esp)
  100188:	e8 05 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	89 c2                	mov    %eax,%edx
  100193:	a1 00 d0 11 00       	mov    0x11d000,%eax
  100198:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a0:	c7 04 24 fd 6c 10 00 	movl   $0x106cfd,(%esp)
  1001a7:	e8 e6 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b0:	89 c2                	mov    %eax,%edx
  1001b2:	a1 00 d0 11 00       	mov    0x11d000,%eax
  1001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001bf:	c7 04 24 0b 6d 10 00 	movl   $0x106d0b,(%esp)
  1001c6:	e8 c7 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001cf:	89 c2                	mov    %eax,%edx
  1001d1:	a1 00 d0 11 00       	mov    0x11d000,%eax
  1001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001de:	c7 04 24 19 6d 10 00 	movl   $0x106d19,(%esp)
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
  10020f:	c7 04 24 28 6d 10 00 	movl   $0x106d28,(%esp)
  100216:	e8 77 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_user();
  10021b:	e8 d8 ff ff ff       	call   1001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
  100220:	e8 15 ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100225:	c7 04 24 48 6d 10 00 	movl   $0x106d48,(%esp)
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
  100288:	e8 83 65 00 00       	call   106810 <vprintfmt>
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
  100347:	c7 04 24 67 6d 10 00 	movl   $0x106d67,(%esp)
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
  100416:	c7 04 24 6a 6d 10 00 	movl   $0x106d6a,(%esp)
  10041d:	e8 70 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100425:	89 44 24 04          	mov    %eax,0x4(%esp)
  100429:	8b 45 10             	mov    0x10(%ebp),%eax
  10042c:	89 04 24             	mov    %eax,(%esp)
  10042f:	e8 2b fe ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  100434:	c7 04 24 86 6d 10 00 	movl   $0x106d86,(%esp)
  10043b:	e8 52 fe ff ff       	call   100292 <cprintf>
    
    cprintf("stack trackback:\n");
  100440:	c7 04 24 88 6d 10 00 	movl   $0x106d88,(%esp)
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
  100481:	c7 04 24 9a 6d 10 00 	movl   $0x106d9a,(%esp)
  100488:	e8 05 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  10048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100490:	89 44 24 04          	mov    %eax,0x4(%esp)
  100494:	8b 45 10             	mov    0x10(%ebp),%eax
  100497:	89 04 24             	mov    %eax,(%esp)
  10049a:	e8 c0 fd ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  10049f:	c7 04 24 86 6d 10 00 	movl   $0x106d86,(%esp)
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
  10060f:	c7 00 b8 6d 10 00    	movl   $0x106db8,(%eax)
    info->eip_line = 0;
  100615:	8b 45 0c             	mov    0xc(%ebp),%eax
  100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10061f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100622:	c7 40 08 b8 6d 10 00 	movl   $0x106db8,0x8(%eax)
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
  100646:	c7 45 f4 ac 82 10 00 	movl   $0x1082ac,-0xc(%ebp)
    stab_end = __STAB_END__;
  10064d:	c7 45 f0 20 4a 11 00 	movl   $0x114a20,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100654:	c7 45 ec 21 4a 11 00 	movl   $0x114a21,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10065b:	c7 45 e8 f4 76 11 00 	movl   $0x1176f4,-0x18(%ebp)

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
  1007b6:	e8 7e 5b 00 00       	call   106339 <strfind>
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
  10093e:	c7 04 24 c2 6d 10 00 	movl   $0x106dc2,(%esp)
  100945:	e8 48 f9 ff ff       	call   100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10094a:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100951:	00 
  100952:	c7 04 24 db 6d 10 00 	movl   $0x106ddb,(%esp)
  100959:	e8 34 f9 ff ff       	call   100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10095e:	c7 44 24 04 b7 6c 10 	movl   $0x106cb7,0x4(%esp)
  100965:	00 
  100966:	c7 04 24 f3 6d 10 00 	movl   $0x106df3,(%esp)
  10096d:	e8 20 f9 ff ff       	call   100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100972:	c7 44 24 04 36 aa 11 	movl   $0x11aa36,0x4(%esp)
  100979:	00 
  10097a:	c7 04 24 0b 6e 10 00 	movl   $0x106e0b,(%esp)
  100981:	e8 0c f9 ff ff       	call   100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100986:	c7 44 24 04 bc df 11 	movl   $0x11dfbc,0x4(%esp)
  10098d:	00 
  10098e:	c7 04 24 23 6e 10 00 	movl   $0x106e23,(%esp)
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
  1009c0:	c7 04 24 3c 6e 10 00 	movl   $0x106e3c,(%esp)
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
  1009f5:	c7 04 24 66 6e 10 00 	movl   $0x106e66,(%esp)
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
  100a63:	c7 04 24 82 6e 10 00 	movl   $0x106e82,(%esp)
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
  100ab6:	c7 04 24 94 6e 10 00 	movl   $0x106e94,(%esp)
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
  100ae9:	c7 04 24 b0 6e 10 00 	movl   $0x106eb0,(%esp)
  100af0:	e8 9d f7 ff ff       	call   100292 <cprintf>
		for(int i=0;i<4;i++){
  100af5:	ff 45 e8             	incl   -0x18(%ebp)
  100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100afc:	7e d6                	jle    100ad4 <print_stackframe+0x51>
		}
		cprintf("\n");
  100afe:	c7 04 24 b8 6e 10 00 	movl   $0x106eb8,(%esp)
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
  100b71:	c7 04 24 3c 6f 10 00 	movl   $0x106f3c,(%esp)
  100b78:	e8 8a 57 00 00       	call   106307 <strchr>
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
  100b99:	c7 04 24 41 6f 10 00 	movl   $0x106f41,(%esp)
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
  100bdb:	c7 04 24 3c 6f 10 00 	movl   $0x106f3c,(%esp)
  100be2:	e8 20 57 00 00       	call   106307 <strchr>
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
  100c48:	e8 1d 56 00 00       	call   10626a <strcmp>
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
  100c94:	c7 04 24 5f 6f 10 00 	movl   $0x106f5f,(%esp)
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
  100cb1:	c7 04 24 78 6f 10 00 	movl   $0x106f78,(%esp)
  100cb8:	e8 d5 f5 ff ff       	call   100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cbd:	c7 04 24 a0 6f 10 00 	movl   $0x106fa0,(%esp)
  100cc4:	e8 c9 f5 ff ff       	call   100292 <cprintf>

    if (tf != NULL) {
  100cc9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100ccd:	74 0b                	je     100cda <kmonitor+0x2f>
        print_trapframe(tf);
  100ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  100cd2:	89 04 24             	mov    %eax,(%esp)
  100cd5:	e8 10 0d 00 00       	call   1019ea <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cda:	c7 04 24 c5 6f 10 00 	movl   $0x106fc5,(%esp)
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
  100d48:	c7 04 24 c9 6f 10 00 	movl   $0x106fc9,(%esp)
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
  100dd3:	c7 04 24 d2 6f 10 00 	movl   $0x106fd2,(%esp)
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
  101215:	e8 e3 52 00 00       	call   1064fd <memmove>
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
  101595:	c7 04 24 ed 6f 10 00 	movl   $0x106fed,(%esp)
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
  101605:	c7 04 24 f9 6f 10 00 	movl   $0x106ff9,(%esp)
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
  1018a2:	c7 04 24 20 70 10 00 	movl   $0x107020,(%esp)
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
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	for(int i=0;i<256;i++){
  1018b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018be:	e9 c4 00 00 00       	jmp    101987 <idt_init+0xd6>
		SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL)
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
	for(int i=0;i<256;i++){
  101984:	ff 45 fc             	incl   -0x4(%ebp)
  101987:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  10198e:	0f 8e 2f ff ff ff    	jle    1018c3 <idt_init+0x12>
  101994:	c7 45 f8 60 a5 11 00 	movl   $0x11a560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  10199b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10199e:	0f 01 18             	lidtl  (%eax)
	}
	lidt(&idt_pd);
}
  1019a1:	90                   	nop
  1019a2:	c9                   	leave  
  1019a3:	c3                   	ret    

001019a4 <trapname>:

static const char *
trapname(int trapno) {
  1019a4:	55                   	push   %ebp
  1019a5:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  1019a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1019aa:	83 f8 13             	cmp    $0x13,%eax
  1019ad:	77 0c                	ja     1019bb <trapname+0x17>
        return excnames[trapno];
  1019af:	8b 45 08             	mov    0x8(%ebp),%eax
  1019b2:	8b 04 85 80 73 10 00 	mov    0x107380(,%eax,4),%eax
  1019b9:	eb 18                	jmp    1019d3 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  1019bb:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019bf:	7e 0d                	jle    1019ce <trapname+0x2a>
  1019c1:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019c5:	7f 07                	jg     1019ce <trapname+0x2a>
        return "Hardware Interrupt";
  1019c7:	b8 2a 70 10 00       	mov    $0x10702a,%eax
  1019cc:	eb 05                	jmp    1019d3 <trapname+0x2f>
    }
    return "(unknown trap)";
  1019ce:	b8 3d 70 10 00       	mov    $0x10703d,%eax
}
  1019d3:	5d                   	pop    %ebp
  1019d4:	c3                   	ret    

001019d5 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019d5:	55                   	push   %ebp
  1019d6:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1019db:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019df:	83 f8 08             	cmp    $0x8,%eax
  1019e2:	0f 94 c0             	sete   %al
  1019e5:	0f b6 c0             	movzbl %al,%eax
}
  1019e8:	5d                   	pop    %ebp
  1019e9:	c3                   	ret    

001019ea <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  1019ea:	55                   	push   %ebp
  1019eb:	89 e5                	mov    %esp,%ebp
  1019ed:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  1019f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1019f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019f7:	c7 04 24 7e 70 10 00 	movl   $0x10707e,(%esp)
  1019fe:	e8 8f e8 ff ff       	call   100292 <cprintf>
    print_regs(&tf->tf_regs);
  101a03:	8b 45 08             	mov    0x8(%ebp),%eax
  101a06:	89 04 24             	mov    %eax,(%esp)
  101a09:	e8 8f 01 00 00       	call   101b9d <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a11:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a19:	c7 04 24 8f 70 10 00 	movl   $0x10708f,(%esp)
  101a20:	e8 6d e8 ff ff       	call   100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a25:	8b 45 08             	mov    0x8(%ebp),%eax
  101a28:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a30:	c7 04 24 a2 70 10 00 	movl   $0x1070a2,(%esp)
  101a37:	e8 56 e8 ff ff       	call   100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a3f:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a43:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a47:	c7 04 24 b5 70 10 00 	movl   $0x1070b5,(%esp)
  101a4e:	e8 3f e8 ff ff       	call   100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a53:	8b 45 08             	mov    0x8(%ebp),%eax
  101a56:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a5e:	c7 04 24 c8 70 10 00 	movl   $0x1070c8,(%esp)
  101a65:	e8 28 e8 ff ff       	call   100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  101a6d:	8b 40 30             	mov    0x30(%eax),%eax
  101a70:	89 04 24             	mov    %eax,(%esp)
  101a73:	e8 2c ff ff ff       	call   1019a4 <trapname>
  101a78:	89 c2                	mov    %eax,%edx
  101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7d:	8b 40 30             	mov    0x30(%eax),%eax
  101a80:	89 54 24 08          	mov    %edx,0x8(%esp)
  101a84:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a88:	c7 04 24 db 70 10 00 	movl   $0x1070db,(%esp)
  101a8f:	e8 fe e7 ff ff       	call   100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101a94:	8b 45 08             	mov    0x8(%ebp),%eax
  101a97:	8b 40 34             	mov    0x34(%eax),%eax
  101a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a9e:	c7 04 24 ed 70 10 00 	movl   $0x1070ed,(%esp)
  101aa5:	e8 e8 e7 ff ff       	call   100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  101aad:	8b 40 38             	mov    0x38(%eax),%eax
  101ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ab4:	c7 04 24 fc 70 10 00 	movl   $0x1070fc,(%esp)
  101abb:	e8 d2 e7 ff ff       	call   100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101acb:	c7 04 24 0b 71 10 00 	movl   $0x10710b,(%esp)
  101ad2:	e8 bb e7 ff ff       	call   100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  101ada:	8b 40 40             	mov    0x40(%eax),%eax
  101add:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ae1:	c7 04 24 1e 71 10 00 	movl   $0x10711e,(%esp)
  101ae8:	e8 a5 e7 ff ff       	call   100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101aed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101af4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101afb:	eb 3d                	jmp    101b3a <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101afd:	8b 45 08             	mov    0x8(%ebp),%eax
  101b00:	8b 50 40             	mov    0x40(%eax),%edx
  101b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b06:	21 d0                	and    %edx,%eax
  101b08:	85 c0                	test   %eax,%eax
  101b0a:	74 28                	je     101b34 <print_trapframe+0x14a>
  101b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b0f:	8b 04 85 80 a5 11 00 	mov    0x11a580(,%eax,4),%eax
  101b16:	85 c0                	test   %eax,%eax
  101b18:	74 1a                	je     101b34 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b1d:	8b 04 85 80 a5 11 00 	mov    0x11a580(,%eax,4),%eax
  101b24:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b28:	c7 04 24 2d 71 10 00 	movl   $0x10712d,(%esp)
  101b2f:	e8 5e e7 ff ff       	call   100292 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b34:	ff 45 f4             	incl   -0xc(%ebp)
  101b37:	d1 65 f0             	shll   -0x10(%ebp)
  101b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b3d:	83 f8 17             	cmp    $0x17,%eax
  101b40:	76 bb                	jbe    101afd <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b42:	8b 45 08             	mov    0x8(%ebp),%eax
  101b45:	8b 40 40             	mov    0x40(%eax),%eax
  101b48:	c1 e8 0c             	shr    $0xc,%eax
  101b4b:	83 e0 03             	and    $0x3,%eax
  101b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b52:	c7 04 24 31 71 10 00 	movl   $0x107131,(%esp)
  101b59:	e8 34 e7 ff ff       	call   100292 <cprintf>

    if (!trap_in_kernel(tf)) {
  101b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b61:	89 04 24             	mov    %eax,(%esp)
  101b64:	e8 6c fe ff ff       	call   1019d5 <trap_in_kernel>
  101b69:	85 c0                	test   %eax,%eax
  101b6b:	75 2d                	jne    101b9a <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  101b70:	8b 40 44             	mov    0x44(%eax),%eax
  101b73:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b77:	c7 04 24 3a 71 10 00 	movl   $0x10713a,(%esp)
  101b7e:	e8 0f e7 ff ff       	call   100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101b83:	8b 45 08             	mov    0x8(%ebp),%eax
  101b86:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b8e:	c7 04 24 49 71 10 00 	movl   $0x107149,(%esp)
  101b95:	e8 f8 e6 ff ff       	call   100292 <cprintf>
    }
}
  101b9a:	90                   	nop
  101b9b:	c9                   	leave  
  101b9c:	c3                   	ret    

00101b9d <print_regs>:

void
print_regs(struct pushregs *regs) {
  101b9d:	55                   	push   %ebp
  101b9e:	89 e5                	mov    %esp,%ebp
  101ba0:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba6:	8b 00                	mov    (%eax),%eax
  101ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bac:	c7 04 24 5c 71 10 00 	movl   $0x10715c,(%esp)
  101bb3:	e8 da e6 ff ff       	call   100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  101bbb:	8b 40 04             	mov    0x4(%eax),%eax
  101bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bc2:	c7 04 24 6b 71 10 00 	movl   $0x10716b,(%esp)
  101bc9:	e8 c4 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101bce:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd1:	8b 40 08             	mov    0x8(%eax),%eax
  101bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd8:	c7 04 24 7a 71 10 00 	movl   $0x10717a,(%esp)
  101bdf:	e8 ae e6 ff ff       	call   100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101be4:	8b 45 08             	mov    0x8(%ebp),%eax
  101be7:	8b 40 0c             	mov    0xc(%eax),%eax
  101bea:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bee:	c7 04 24 89 71 10 00 	movl   $0x107189,(%esp)
  101bf5:	e8 98 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  101bfd:	8b 40 10             	mov    0x10(%eax),%eax
  101c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c04:	c7 04 24 98 71 10 00 	movl   $0x107198,(%esp)
  101c0b:	e8 82 e6 ff ff       	call   100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c10:	8b 45 08             	mov    0x8(%ebp),%eax
  101c13:	8b 40 14             	mov    0x14(%eax),%eax
  101c16:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c1a:	c7 04 24 a7 71 10 00 	movl   $0x1071a7,(%esp)
  101c21:	e8 6c e6 ff ff       	call   100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c26:	8b 45 08             	mov    0x8(%ebp),%eax
  101c29:	8b 40 18             	mov    0x18(%eax),%eax
  101c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c30:	c7 04 24 b6 71 10 00 	movl   $0x1071b6,(%esp)
  101c37:	e8 56 e6 ff ff       	call   100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c3f:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c42:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c46:	c7 04 24 c5 71 10 00 	movl   $0x1071c5,(%esp)
  101c4d:	e8 40 e6 ff ff       	call   100292 <cprintf>
}
  101c52:	90                   	nop
  101c53:	c9                   	leave  
  101c54:	c3                   	ret    

00101c55 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c55:	55                   	push   %ebp
  101c56:	89 e5                	mov    %esp,%ebp
  101c58:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5e:	8b 40 30             	mov    0x30(%eax),%eax
  101c61:	83 f8 2f             	cmp    $0x2f,%eax
  101c64:	77 21                	ja     101c87 <trap_dispatch+0x32>
  101c66:	83 f8 2e             	cmp    $0x2e,%eax
  101c69:	0f 83 0c 01 00 00    	jae    101d7b <trap_dispatch+0x126>
  101c6f:	83 f8 21             	cmp    $0x21,%eax
  101c72:	0f 84 8c 00 00 00    	je     101d04 <trap_dispatch+0xaf>
  101c78:	83 f8 24             	cmp    $0x24,%eax
  101c7b:	74 61                	je     101cde <trap_dispatch+0x89>
  101c7d:	83 f8 20             	cmp    $0x20,%eax
  101c80:	74 16                	je     101c98 <trap_dispatch+0x43>
  101c82:	e9 bf 00 00 00       	jmp    101d46 <trap_dispatch+0xf1>
  101c87:	83 e8 78             	sub    $0x78,%eax
  101c8a:	83 f8 01             	cmp    $0x1,%eax
  101c8d:	0f 87 b3 00 00 00    	ja     101d46 <trap_dispatch+0xf1>
  101c93:	e9 92 00 00 00       	jmp    101d2a <trap_dispatch+0xd5>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	ticks+=1;
  101c98:	a1 0c df 11 00       	mov    0x11df0c,%eax
  101c9d:	40                   	inc    %eax
  101c9e:	a3 0c df 11 00       	mov    %eax,0x11df0c
	if(ticks%TICK_NUM==0){
  101ca3:	8b 0d 0c df 11 00    	mov    0x11df0c,%ecx
  101ca9:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101cae:	89 c8                	mov    %ecx,%eax
  101cb0:	f7 e2                	mul    %edx
  101cb2:	c1 ea 05             	shr    $0x5,%edx
  101cb5:	89 d0                	mov    %edx,%eax
  101cb7:	c1 e0 02             	shl    $0x2,%eax
  101cba:	01 d0                	add    %edx,%eax
  101cbc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101cc3:	01 d0                	add    %edx,%eax
  101cc5:	c1 e0 02             	shl    $0x2,%eax
  101cc8:	29 c1                	sub    %eax,%ecx
  101cca:	89 ca                	mov    %ecx,%edx
  101ccc:	85 d2                	test   %edx,%edx
  101cce:	0f 85 aa 00 00 00    	jne    101d7e <trap_dispatch+0x129>
		print_ticks();	
  101cd4:	e8 bb fb ff ff       	call   101894 <print_ticks>
	}
        break;
  101cd9:	e9 a0 00 00 00       	jmp    101d7e <trap_dispatch+0x129>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101cde:	e8 6e f9 ff ff       	call   101651 <cons_getc>
  101ce3:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101ce6:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101cea:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101cee:	89 54 24 08          	mov    %edx,0x8(%esp)
  101cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf6:	c7 04 24 d4 71 10 00 	movl   $0x1071d4,(%esp)
  101cfd:	e8 90 e5 ff ff       	call   100292 <cprintf>
        break;
  101d02:	eb 7b                	jmp    101d7f <trap_dispatch+0x12a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d04:	e8 48 f9 ff ff       	call   101651 <cons_getc>
  101d09:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d0c:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d10:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d14:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d18:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d1c:	c7 04 24 e6 71 10 00 	movl   $0x1071e6,(%esp)
  101d23:	e8 6a e5 ff ff       	call   100292 <cprintf>
        break;
  101d28:	eb 55                	jmp    101d7f <trap_dispatch+0x12a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d2a:	c7 44 24 08 f5 71 10 	movl   $0x1071f5,0x8(%esp)
  101d31:	00 
  101d32:	c7 44 24 04 ab 00 00 	movl   $0xab,0x4(%esp)
  101d39:	00 
  101d3a:	c7 04 24 05 72 10 00 	movl   $0x107205,(%esp)
  101d41:	e8 a3 e6 ff ff       	call   1003e9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101d46:	8b 45 08             	mov    0x8(%ebp),%eax
  101d49:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d4d:	83 e0 03             	and    $0x3,%eax
  101d50:	85 c0                	test   %eax,%eax
  101d52:	75 2b                	jne    101d7f <trap_dispatch+0x12a>
            print_trapframe(tf);
  101d54:	8b 45 08             	mov    0x8(%ebp),%eax
  101d57:	89 04 24             	mov    %eax,(%esp)
  101d5a:	e8 8b fc ff ff       	call   1019ea <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101d5f:	c7 44 24 08 16 72 10 	movl   $0x107216,0x8(%esp)
  101d66:	00 
  101d67:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  101d6e:	00 
  101d6f:	c7 04 24 05 72 10 00 	movl   $0x107205,(%esp)
  101d76:	e8 6e e6 ff ff       	call   1003e9 <__panic>
        break;
  101d7b:	90                   	nop
  101d7c:	eb 01                	jmp    101d7f <trap_dispatch+0x12a>
        break;
  101d7e:	90                   	nop
        }
    }
}
  101d7f:	90                   	nop
  101d80:	c9                   	leave  
  101d81:	c3                   	ret    

00101d82 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101d82:	55                   	push   %ebp
  101d83:	89 e5                	mov    %esp,%ebp
  101d85:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101d88:	8b 45 08             	mov    0x8(%ebp),%eax
  101d8b:	89 04 24             	mov    %eax,(%esp)
  101d8e:	e8 c2 fe ff ff       	call   101c55 <trap_dispatch>
}
  101d93:	90                   	nop
  101d94:	c9                   	leave  
  101d95:	c3                   	ret    

00101d96 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101d96:	6a 00                	push   $0x0
  pushl $0
  101d98:	6a 00                	push   $0x0
  jmp __alltraps
  101d9a:	e9 69 0a 00 00       	jmp    102808 <__alltraps>

00101d9f <vector1>:
.globl vector1
vector1:
  pushl $0
  101d9f:	6a 00                	push   $0x0
  pushl $1
  101da1:	6a 01                	push   $0x1
  jmp __alltraps
  101da3:	e9 60 0a 00 00       	jmp    102808 <__alltraps>

00101da8 <vector2>:
.globl vector2
vector2:
  pushl $0
  101da8:	6a 00                	push   $0x0
  pushl $2
  101daa:	6a 02                	push   $0x2
  jmp __alltraps
  101dac:	e9 57 0a 00 00       	jmp    102808 <__alltraps>

00101db1 <vector3>:
.globl vector3
vector3:
  pushl $0
  101db1:	6a 00                	push   $0x0
  pushl $3
  101db3:	6a 03                	push   $0x3
  jmp __alltraps
  101db5:	e9 4e 0a 00 00       	jmp    102808 <__alltraps>

00101dba <vector4>:
.globl vector4
vector4:
  pushl $0
  101dba:	6a 00                	push   $0x0
  pushl $4
  101dbc:	6a 04                	push   $0x4
  jmp __alltraps
  101dbe:	e9 45 0a 00 00       	jmp    102808 <__alltraps>

00101dc3 <vector5>:
.globl vector5
vector5:
  pushl $0
  101dc3:	6a 00                	push   $0x0
  pushl $5
  101dc5:	6a 05                	push   $0x5
  jmp __alltraps
  101dc7:	e9 3c 0a 00 00       	jmp    102808 <__alltraps>

00101dcc <vector6>:
.globl vector6
vector6:
  pushl $0
  101dcc:	6a 00                	push   $0x0
  pushl $6
  101dce:	6a 06                	push   $0x6
  jmp __alltraps
  101dd0:	e9 33 0a 00 00       	jmp    102808 <__alltraps>

00101dd5 <vector7>:
.globl vector7
vector7:
  pushl $0
  101dd5:	6a 00                	push   $0x0
  pushl $7
  101dd7:	6a 07                	push   $0x7
  jmp __alltraps
  101dd9:	e9 2a 0a 00 00       	jmp    102808 <__alltraps>

00101dde <vector8>:
.globl vector8
vector8:
  pushl $8
  101dde:	6a 08                	push   $0x8
  jmp __alltraps
  101de0:	e9 23 0a 00 00       	jmp    102808 <__alltraps>

00101de5 <vector9>:
.globl vector9
vector9:
  pushl $0
  101de5:	6a 00                	push   $0x0
  pushl $9
  101de7:	6a 09                	push   $0x9
  jmp __alltraps
  101de9:	e9 1a 0a 00 00       	jmp    102808 <__alltraps>

00101dee <vector10>:
.globl vector10
vector10:
  pushl $10
  101dee:	6a 0a                	push   $0xa
  jmp __alltraps
  101df0:	e9 13 0a 00 00       	jmp    102808 <__alltraps>

00101df5 <vector11>:
.globl vector11
vector11:
  pushl $11
  101df5:	6a 0b                	push   $0xb
  jmp __alltraps
  101df7:	e9 0c 0a 00 00       	jmp    102808 <__alltraps>

00101dfc <vector12>:
.globl vector12
vector12:
  pushl $12
  101dfc:	6a 0c                	push   $0xc
  jmp __alltraps
  101dfe:	e9 05 0a 00 00       	jmp    102808 <__alltraps>

00101e03 <vector13>:
.globl vector13
vector13:
  pushl $13
  101e03:	6a 0d                	push   $0xd
  jmp __alltraps
  101e05:	e9 fe 09 00 00       	jmp    102808 <__alltraps>

00101e0a <vector14>:
.globl vector14
vector14:
  pushl $14
  101e0a:	6a 0e                	push   $0xe
  jmp __alltraps
  101e0c:	e9 f7 09 00 00       	jmp    102808 <__alltraps>

00101e11 <vector15>:
.globl vector15
vector15:
  pushl $0
  101e11:	6a 00                	push   $0x0
  pushl $15
  101e13:	6a 0f                	push   $0xf
  jmp __alltraps
  101e15:	e9 ee 09 00 00       	jmp    102808 <__alltraps>

00101e1a <vector16>:
.globl vector16
vector16:
  pushl $0
  101e1a:	6a 00                	push   $0x0
  pushl $16
  101e1c:	6a 10                	push   $0x10
  jmp __alltraps
  101e1e:	e9 e5 09 00 00       	jmp    102808 <__alltraps>

00101e23 <vector17>:
.globl vector17
vector17:
  pushl $17
  101e23:	6a 11                	push   $0x11
  jmp __alltraps
  101e25:	e9 de 09 00 00       	jmp    102808 <__alltraps>

00101e2a <vector18>:
.globl vector18
vector18:
  pushl $0
  101e2a:	6a 00                	push   $0x0
  pushl $18
  101e2c:	6a 12                	push   $0x12
  jmp __alltraps
  101e2e:	e9 d5 09 00 00       	jmp    102808 <__alltraps>

00101e33 <vector19>:
.globl vector19
vector19:
  pushl $0
  101e33:	6a 00                	push   $0x0
  pushl $19
  101e35:	6a 13                	push   $0x13
  jmp __alltraps
  101e37:	e9 cc 09 00 00       	jmp    102808 <__alltraps>

00101e3c <vector20>:
.globl vector20
vector20:
  pushl $0
  101e3c:	6a 00                	push   $0x0
  pushl $20
  101e3e:	6a 14                	push   $0x14
  jmp __alltraps
  101e40:	e9 c3 09 00 00       	jmp    102808 <__alltraps>

00101e45 <vector21>:
.globl vector21
vector21:
  pushl $0
  101e45:	6a 00                	push   $0x0
  pushl $21
  101e47:	6a 15                	push   $0x15
  jmp __alltraps
  101e49:	e9 ba 09 00 00       	jmp    102808 <__alltraps>

00101e4e <vector22>:
.globl vector22
vector22:
  pushl $0
  101e4e:	6a 00                	push   $0x0
  pushl $22
  101e50:	6a 16                	push   $0x16
  jmp __alltraps
  101e52:	e9 b1 09 00 00       	jmp    102808 <__alltraps>

00101e57 <vector23>:
.globl vector23
vector23:
  pushl $0
  101e57:	6a 00                	push   $0x0
  pushl $23
  101e59:	6a 17                	push   $0x17
  jmp __alltraps
  101e5b:	e9 a8 09 00 00       	jmp    102808 <__alltraps>

00101e60 <vector24>:
.globl vector24
vector24:
  pushl $0
  101e60:	6a 00                	push   $0x0
  pushl $24
  101e62:	6a 18                	push   $0x18
  jmp __alltraps
  101e64:	e9 9f 09 00 00       	jmp    102808 <__alltraps>

00101e69 <vector25>:
.globl vector25
vector25:
  pushl $0
  101e69:	6a 00                	push   $0x0
  pushl $25
  101e6b:	6a 19                	push   $0x19
  jmp __alltraps
  101e6d:	e9 96 09 00 00       	jmp    102808 <__alltraps>

00101e72 <vector26>:
.globl vector26
vector26:
  pushl $0
  101e72:	6a 00                	push   $0x0
  pushl $26
  101e74:	6a 1a                	push   $0x1a
  jmp __alltraps
  101e76:	e9 8d 09 00 00       	jmp    102808 <__alltraps>

00101e7b <vector27>:
.globl vector27
vector27:
  pushl $0
  101e7b:	6a 00                	push   $0x0
  pushl $27
  101e7d:	6a 1b                	push   $0x1b
  jmp __alltraps
  101e7f:	e9 84 09 00 00       	jmp    102808 <__alltraps>

00101e84 <vector28>:
.globl vector28
vector28:
  pushl $0
  101e84:	6a 00                	push   $0x0
  pushl $28
  101e86:	6a 1c                	push   $0x1c
  jmp __alltraps
  101e88:	e9 7b 09 00 00       	jmp    102808 <__alltraps>

00101e8d <vector29>:
.globl vector29
vector29:
  pushl $0
  101e8d:	6a 00                	push   $0x0
  pushl $29
  101e8f:	6a 1d                	push   $0x1d
  jmp __alltraps
  101e91:	e9 72 09 00 00       	jmp    102808 <__alltraps>

00101e96 <vector30>:
.globl vector30
vector30:
  pushl $0
  101e96:	6a 00                	push   $0x0
  pushl $30
  101e98:	6a 1e                	push   $0x1e
  jmp __alltraps
  101e9a:	e9 69 09 00 00       	jmp    102808 <__alltraps>

00101e9f <vector31>:
.globl vector31
vector31:
  pushl $0
  101e9f:	6a 00                	push   $0x0
  pushl $31
  101ea1:	6a 1f                	push   $0x1f
  jmp __alltraps
  101ea3:	e9 60 09 00 00       	jmp    102808 <__alltraps>

00101ea8 <vector32>:
.globl vector32
vector32:
  pushl $0
  101ea8:	6a 00                	push   $0x0
  pushl $32
  101eaa:	6a 20                	push   $0x20
  jmp __alltraps
  101eac:	e9 57 09 00 00       	jmp    102808 <__alltraps>

00101eb1 <vector33>:
.globl vector33
vector33:
  pushl $0
  101eb1:	6a 00                	push   $0x0
  pushl $33
  101eb3:	6a 21                	push   $0x21
  jmp __alltraps
  101eb5:	e9 4e 09 00 00       	jmp    102808 <__alltraps>

00101eba <vector34>:
.globl vector34
vector34:
  pushl $0
  101eba:	6a 00                	push   $0x0
  pushl $34
  101ebc:	6a 22                	push   $0x22
  jmp __alltraps
  101ebe:	e9 45 09 00 00       	jmp    102808 <__alltraps>

00101ec3 <vector35>:
.globl vector35
vector35:
  pushl $0
  101ec3:	6a 00                	push   $0x0
  pushl $35
  101ec5:	6a 23                	push   $0x23
  jmp __alltraps
  101ec7:	e9 3c 09 00 00       	jmp    102808 <__alltraps>

00101ecc <vector36>:
.globl vector36
vector36:
  pushl $0
  101ecc:	6a 00                	push   $0x0
  pushl $36
  101ece:	6a 24                	push   $0x24
  jmp __alltraps
  101ed0:	e9 33 09 00 00       	jmp    102808 <__alltraps>

00101ed5 <vector37>:
.globl vector37
vector37:
  pushl $0
  101ed5:	6a 00                	push   $0x0
  pushl $37
  101ed7:	6a 25                	push   $0x25
  jmp __alltraps
  101ed9:	e9 2a 09 00 00       	jmp    102808 <__alltraps>

00101ede <vector38>:
.globl vector38
vector38:
  pushl $0
  101ede:	6a 00                	push   $0x0
  pushl $38
  101ee0:	6a 26                	push   $0x26
  jmp __alltraps
  101ee2:	e9 21 09 00 00       	jmp    102808 <__alltraps>

00101ee7 <vector39>:
.globl vector39
vector39:
  pushl $0
  101ee7:	6a 00                	push   $0x0
  pushl $39
  101ee9:	6a 27                	push   $0x27
  jmp __alltraps
  101eeb:	e9 18 09 00 00       	jmp    102808 <__alltraps>

00101ef0 <vector40>:
.globl vector40
vector40:
  pushl $0
  101ef0:	6a 00                	push   $0x0
  pushl $40
  101ef2:	6a 28                	push   $0x28
  jmp __alltraps
  101ef4:	e9 0f 09 00 00       	jmp    102808 <__alltraps>

00101ef9 <vector41>:
.globl vector41
vector41:
  pushl $0
  101ef9:	6a 00                	push   $0x0
  pushl $41
  101efb:	6a 29                	push   $0x29
  jmp __alltraps
  101efd:	e9 06 09 00 00       	jmp    102808 <__alltraps>

00101f02 <vector42>:
.globl vector42
vector42:
  pushl $0
  101f02:	6a 00                	push   $0x0
  pushl $42
  101f04:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f06:	e9 fd 08 00 00       	jmp    102808 <__alltraps>

00101f0b <vector43>:
.globl vector43
vector43:
  pushl $0
  101f0b:	6a 00                	push   $0x0
  pushl $43
  101f0d:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f0f:	e9 f4 08 00 00       	jmp    102808 <__alltraps>

00101f14 <vector44>:
.globl vector44
vector44:
  pushl $0
  101f14:	6a 00                	push   $0x0
  pushl $44
  101f16:	6a 2c                	push   $0x2c
  jmp __alltraps
  101f18:	e9 eb 08 00 00       	jmp    102808 <__alltraps>

00101f1d <vector45>:
.globl vector45
vector45:
  pushl $0
  101f1d:	6a 00                	push   $0x0
  pushl $45
  101f1f:	6a 2d                	push   $0x2d
  jmp __alltraps
  101f21:	e9 e2 08 00 00       	jmp    102808 <__alltraps>

00101f26 <vector46>:
.globl vector46
vector46:
  pushl $0
  101f26:	6a 00                	push   $0x0
  pushl $46
  101f28:	6a 2e                	push   $0x2e
  jmp __alltraps
  101f2a:	e9 d9 08 00 00       	jmp    102808 <__alltraps>

00101f2f <vector47>:
.globl vector47
vector47:
  pushl $0
  101f2f:	6a 00                	push   $0x0
  pushl $47
  101f31:	6a 2f                	push   $0x2f
  jmp __alltraps
  101f33:	e9 d0 08 00 00       	jmp    102808 <__alltraps>

00101f38 <vector48>:
.globl vector48
vector48:
  pushl $0
  101f38:	6a 00                	push   $0x0
  pushl $48
  101f3a:	6a 30                	push   $0x30
  jmp __alltraps
  101f3c:	e9 c7 08 00 00       	jmp    102808 <__alltraps>

00101f41 <vector49>:
.globl vector49
vector49:
  pushl $0
  101f41:	6a 00                	push   $0x0
  pushl $49
  101f43:	6a 31                	push   $0x31
  jmp __alltraps
  101f45:	e9 be 08 00 00       	jmp    102808 <__alltraps>

00101f4a <vector50>:
.globl vector50
vector50:
  pushl $0
  101f4a:	6a 00                	push   $0x0
  pushl $50
  101f4c:	6a 32                	push   $0x32
  jmp __alltraps
  101f4e:	e9 b5 08 00 00       	jmp    102808 <__alltraps>

00101f53 <vector51>:
.globl vector51
vector51:
  pushl $0
  101f53:	6a 00                	push   $0x0
  pushl $51
  101f55:	6a 33                	push   $0x33
  jmp __alltraps
  101f57:	e9 ac 08 00 00       	jmp    102808 <__alltraps>

00101f5c <vector52>:
.globl vector52
vector52:
  pushl $0
  101f5c:	6a 00                	push   $0x0
  pushl $52
  101f5e:	6a 34                	push   $0x34
  jmp __alltraps
  101f60:	e9 a3 08 00 00       	jmp    102808 <__alltraps>

00101f65 <vector53>:
.globl vector53
vector53:
  pushl $0
  101f65:	6a 00                	push   $0x0
  pushl $53
  101f67:	6a 35                	push   $0x35
  jmp __alltraps
  101f69:	e9 9a 08 00 00       	jmp    102808 <__alltraps>

00101f6e <vector54>:
.globl vector54
vector54:
  pushl $0
  101f6e:	6a 00                	push   $0x0
  pushl $54
  101f70:	6a 36                	push   $0x36
  jmp __alltraps
  101f72:	e9 91 08 00 00       	jmp    102808 <__alltraps>

00101f77 <vector55>:
.globl vector55
vector55:
  pushl $0
  101f77:	6a 00                	push   $0x0
  pushl $55
  101f79:	6a 37                	push   $0x37
  jmp __alltraps
  101f7b:	e9 88 08 00 00       	jmp    102808 <__alltraps>

00101f80 <vector56>:
.globl vector56
vector56:
  pushl $0
  101f80:	6a 00                	push   $0x0
  pushl $56
  101f82:	6a 38                	push   $0x38
  jmp __alltraps
  101f84:	e9 7f 08 00 00       	jmp    102808 <__alltraps>

00101f89 <vector57>:
.globl vector57
vector57:
  pushl $0
  101f89:	6a 00                	push   $0x0
  pushl $57
  101f8b:	6a 39                	push   $0x39
  jmp __alltraps
  101f8d:	e9 76 08 00 00       	jmp    102808 <__alltraps>

00101f92 <vector58>:
.globl vector58
vector58:
  pushl $0
  101f92:	6a 00                	push   $0x0
  pushl $58
  101f94:	6a 3a                	push   $0x3a
  jmp __alltraps
  101f96:	e9 6d 08 00 00       	jmp    102808 <__alltraps>

00101f9b <vector59>:
.globl vector59
vector59:
  pushl $0
  101f9b:	6a 00                	push   $0x0
  pushl $59
  101f9d:	6a 3b                	push   $0x3b
  jmp __alltraps
  101f9f:	e9 64 08 00 00       	jmp    102808 <__alltraps>

00101fa4 <vector60>:
.globl vector60
vector60:
  pushl $0
  101fa4:	6a 00                	push   $0x0
  pushl $60
  101fa6:	6a 3c                	push   $0x3c
  jmp __alltraps
  101fa8:	e9 5b 08 00 00       	jmp    102808 <__alltraps>

00101fad <vector61>:
.globl vector61
vector61:
  pushl $0
  101fad:	6a 00                	push   $0x0
  pushl $61
  101faf:	6a 3d                	push   $0x3d
  jmp __alltraps
  101fb1:	e9 52 08 00 00       	jmp    102808 <__alltraps>

00101fb6 <vector62>:
.globl vector62
vector62:
  pushl $0
  101fb6:	6a 00                	push   $0x0
  pushl $62
  101fb8:	6a 3e                	push   $0x3e
  jmp __alltraps
  101fba:	e9 49 08 00 00       	jmp    102808 <__alltraps>

00101fbf <vector63>:
.globl vector63
vector63:
  pushl $0
  101fbf:	6a 00                	push   $0x0
  pushl $63
  101fc1:	6a 3f                	push   $0x3f
  jmp __alltraps
  101fc3:	e9 40 08 00 00       	jmp    102808 <__alltraps>

00101fc8 <vector64>:
.globl vector64
vector64:
  pushl $0
  101fc8:	6a 00                	push   $0x0
  pushl $64
  101fca:	6a 40                	push   $0x40
  jmp __alltraps
  101fcc:	e9 37 08 00 00       	jmp    102808 <__alltraps>

00101fd1 <vector65>:
.globl vector65
vector65:
  pushl $0
  101fd1:	6a 00                	push   $0x0
  pushl $65
  101fd3:	6a 41                	push   $0x41
  jmp __alltraps
  101fd5:	e9 2e 08 00 00       	jmp    102808 <__alltraps>

00101fda <vector66>:
.globl vector66
vector66:
  pushl $0
  101fda:	6a 00                	push   $0x0
  pushl $66
  101fdc:	6a 42                	push   $0x42
  jmp __alltraps
  101fde:	e9 25 08 00 00       	jmp    102808 <__alltraps>

00101fe3 <vector67>:
.globl vector67
vector67:
  pushl $0
  101fe3:	6a 00                	push   $0x0
  pushl $67
  101fe5:	6a 43                	push   $0x43
  jmp __alltraps
  101fe7:	e9 1c 08 00 00       	jmp    102808 <__alltraps>

00101fec <vector68>:
.globl vector68
vector68:
  pushl $0
  101fec:	6a 00                	push   $0x0
  pushl $68
  101fee:	6a 44                	push   $0x44
  jmp __alltraps
  101ff0:	e9 13 08 00 00       	jmp    102808 <__alltraps>

00101ff5 <vector69>:
.globl vector69
vector69:
  pushl $0
  101ff5:	6a 00                	push   $0x0
  pushl $69
  101ff7:	6a 45                	push   $0x45
  jmp __alltraps
  101ff9:	e9 0a 08 00 00       	jmp    102808 <__alltraps>

00101ffe <vector70>:
.globl vector70
vector70:
  pushl $0
  101ffe:	6a 00                	push   $0x0
  pushl $70
  102000:	6a 46                	push   $0x46
  jmp __alltraps
  102002:	e9 01 08 00 00       	jmp    102808 <__alltraps>

00102007 <vector71>:
.globl vector71
vector71:
  pushl $0
  102007:	6a 00                	push   $0x0
  pushl $71
  102009:	6a 47                	push   $0x47
  jmp __alltraps
  10200b:	e9 f8 07 00 00       	jmp    102808 <__alltraps>

00102010 <vector72>:
.globl vector72
vector72:
  pushl $0
  102010:	6a 00                	push   $0x0
  pushl $72
  102012:	6a 48                	push   $0x48
  jmp __alltraps
  102014:	e9 ef 07 00 00       	jmp    102808 <__alltraps>

00102019 <vector73>:
.globl vector73
vector73:
  pushl $0
  102019:	6a 00                	push   $0x0
  pushl $73
  10201b:	6a 49                	push   $0x49
  jmp __alltraps
  10201d:	e9 e6 07 00 00       	jmp    102808 <__alltraps>

00102022 <vector74>:
.globl vector74
vector74:
  pushl $0
  102022:	6a 00                	push   $0x0
  pushl $74
  102024:	6a 4a                	push   $0x4a
  jmp __alltraps
  102026:	e9 dd 07 00 00       	jmp    102808 <__alltraps>

0010202b <vector75>:
.globl vector75
vector75:
  pushl $0
  10202b:	6a 00                	push   $0x0
  pushl $75
  10202d:	6a 4b                	push   $0x4b
  jmp __alltraps
  10202f:	e9 d4 07 00 00       	jmp    102808 <__alltraps>

00102034 <vector76>:
.globl vector76
vector76:
  pushl $0
  102034:	6a 00                	push   $0x0
  pushl $76
  102036:	6a 4c                	push   $0x4c
  jmp __alltraps
  102038:	e9 cb 07 00 00       	jmp    102808 <__alltraps>

0010203d <vector77>:
.globl vector77
vector77:
  pushl $0
  10203d:	6a 00                	push   $0x0
  pushl $77
  10203f:	6a 4d                	push   $0x4d
  jmp __alltraps
  102041:	e9 c2 07 00 00       	jmp    102808 <__alltraps>

00102046 <vector78>:
.globl vector78
vector78:
  pushl $0
  102046:	6a 00                	push   $0x0
  pushl $78
  102048:	6a 4e                	push   $0x4e
  jmp __alltraps
  10204a:	e9 b9 07 00 00       	jmp    102808 <__alltraps>

0010204f <vector79>:
.globl vector79
vector79:
  pushl $0
  10204f:	6a 00                	push   $0x0
  pushl $79
  102051:	6a 4f                	push   $0x4f
  jmp __alltraps
  102053:	e9 b0 07 00 00       	jmp    102808 <__alltraps>

00102058 <vector80>:
.globl vector80
vector80:
  pushl $0
  102058:	6a 00                	push   $0x0
  pushl $80
  10205a:	6a 50                	push   $0x50
  jmp __alltraps
  10205c:	e9 a7 07 00 00       	jmp    102808 <__alltraps>

00102061 <vector81>:
.globl vector81
vector81:
  pushl $0
  102061:	6a 00                	push   $0x0
  pushl $81
  102063:	6a 51                	push   $0x51
  jmp __alltraps
  102065:	e9 9e 07 00 00       	jmp    102808 <__alltraps>

0010206a <vector82>:
.globl vector82
vector82:
  pushl $0
  10206a:	6a 00                	push   $0x0
  pushl $82
  10206c:	6a 52                	push   $0x52
  jmp __alltraps
  10206e:	e9 95 07 00 00       	jmp    102808 <__alltraps>

00102073 <vector83>:
.globl vector83
vector83:
  pushl $0
  102073:	6a 00                	push   $0x0
  pushl $83
  102075:	6a 53                	push   $0x53
  jmp __alltraps
  102077:	e9 8c 07 00 00       	jmp    102808 <__alltraps>

0010207c <vector84>:
.globl vector84
vector84:
  pushl $0
  10207c:	6a 00                	push   $0x0
  pushl $84
  10207e:	6a 54                	push   $0x54
  jmp __alltraps
  102080:	e9 83 07 00 00       	jmp    102808 <__alltraps>

00102085 <vector85>:
.globl vector85
vector85:
  pushl $0
  102085:	6a 00                	push   $0x0
  pushl $85
  102087:	6a 55                	push   $0x55
  jmp __alltraps
  102089:	e9 7a 07 00 00       	jmp    102808 <__alltraps>

0010208e <vector86>:
.globl vector86
vector86:
  pushl $0
  10208e:	6a 00                	push   $0x0
  pushl $86
  102090:	6a 56                	push   $0x56
  jmp __alltraps
  102092:	e9 71 07 00 00       	jmp    102808 <__alltraps>

00102097 <vector87>:
.globl vector87
vector87:
  pushl $0
  102097:	6a 00                	push   $0x0
  pushl $87
  102099:	6a 57                	push   $0x57
  jmp __alltraps
  10209b:	e9 68 07 00 00       	jmp    102808 <__alltraps>

001020a0 <vector88>:
.globl vector88
vector88:
  pushl $0
  1020a0:	6a 00                	push   $0x0
  pushl $88
  1020a2:	6a 58                	push   $0x58
  jmp __alltraps
  1020a4:	e9 5f 07 00 00       	jmp    102808 <__alltraps>

001020a9 <vector89>:
.globl vector89
vector89:
  pushl $0
  1020a9:	6a 00                	push   $0x0
  pushl $89
  1020ab:	6a 59                	push   $0x59
  jmp __alltraps
  1020ad:	e9 56 07 00 00       	jmp    102808 <__alltraps>

001020b2 <vector90>:
.globl vector90
vector90:
  pushl $0
  1020b2:	6a 00                	push   $0x0
  pushl $90
  1020b4:	6a 5a                	push   $0x5a
  jmp __alltraps
  1020b6:	e9 4d 07 00 00       	jmp    102808 <__alltraps>

001020bb <vector91>:
.globl vector91
vector91:
  pushl $0
  1020bb:	6a 00                	push   $0x0
  pushl $91
  1020bd:	6a 5b                	push   $0x5b
  jmp __alltraps
  1020bf:	e9 44 07 00 00       	jmp    102808 <__alltraps>

001020c4 <vector92>:
.globl vector92
vector92:
  pushl $0
  1020c4:	6a 00                	push   $0x0
  pushl $92
  1020c6:	6a 5c                	push   $0x5c
  jmp __alltraps
  1020c8:	e9 3b 07 00 00       	jmp    102808 <__alltraps>

001020cd <vector93>:
.globl vector93
vector93:
  pushl $0
  1020cd:	6a 00                	push   $0x0
  pushl $93
  1020cf:	6a 5d                	push   $0x5d
  jmp __alltraps
  1020d1:	e9 32 07 00 00       	jmp    102808 <__alltraps>

001020d6 <vector94>:
.globl vector94
vector94:
  pushl $0
  1020d6:	6a 00                	push   $0x0
  pushl $94
  1020d8:	6a 5e                	push   $0x5e
  jmp __alltraps
  1020da:	e9 29 07 00 00       	jmp    102808 <__alltraps>

001020df <vector95>:
.globl vector95
vector95:
  pushl $0
  1020df:	6a 00                	push   $0x0
  pushl $95
  1020e1:	6a 5f                	push   $0x5f
  jmp __alltraps
  1020e3:	e9 20 07 00 00       	jmp    102808 <__alltraps>

001020e8 <vector96>:
.globl vector96
vector96:
  pushl $0
  1020e8:	6a 00                	push   $0x0
  pushl $96
  1020ea:	6a 60                	push   $0x60
  jmp __alltraps
  1020ec:	e9 17 07 00 00       	jmp    102808 <__alltraps>

001020f1 <vector97>:
.globl vector97
vector97:
  pushl $0
  1020f1:	6a 00                	push   $0x0
  pushl $97
  1020f3:	6a 61                	push   $0x61
  jmp __alltraps
  1020f5:	e9 0e 07 00 00       	jmp    102808 <__alltraps>

001020fa <vector98>:
.globl vector98
vector98:
  pushl $0
  1020fa:	6a 00                	push   $0x0
  pushl $98
  1020fc:	6a 62                	push   $0x62
  jmp __alltraps
  1020fe:	e9 05 07 00 00       	jmp    102808 <__alltraps>

00102103 <vector99>:
.globl vector99
vector99:
  pushl $0
  102103:	6a 00                	push   $0x0
  pushl $99
  102105:	6a 63                	push   $0x63
  jmp __alltraps
  102107:	e9 fc 06 00 00       	jmp    102808 <__alltraps>

0010210c <vector100>:
.globl vector100
vector100:
  pushl $0
  10210c:	6a 00                	push   $0x0
  pushl $100
  10210e:	6a 64                	push   $0x64
  jmp __alltraps
  102110:	e9 f3 06 00 00       	jmp    102808 <__alltraps>

00102115 <vector101>:
.globl vector101
vector101:
  pushl $0
  102115:	6a 00                	push   $0x0
  pushl $101
  102117:	6a 65                	push   $0x65
  jmp __alltraps
  102119:	e9 ea 06 00 00       	jmp    102808 <__alltraps>

0010211e <vector102>:
.globl vector102
vector102:
  pushl $0
  10211e:	6a 00                	push   $0x0
  pushl $102
  102120:	6a 66                	push   $0x66
  jmp __alltraps
  102122:	e9 e1 06 00 00       	jmp    102808 <__alltraps>

00102127 <vector103>:
.globl vector103
vector103:
  pushl $0
  102127:	6a 00                	push   $0x0
  pushl $103
  102129:	6a 67                	push   $0x67
  jmp __alltraps
  10212b:	e9 d8 06 00 00       	jmp    102808 <__alltraps>

00102130 <vector104>:
.globl vector104
vector104:
  pushl $0
  102130:	6a 00                	push   $0x0
  pushl $104
  102132:	6a 68                	push   $0x68
  jmp __alltraps
  102134:	e9 cf 06 00 00       	jmp    102808 <__alltraps>

00102139 <vector105>:
.globl vector105
vector105:
  pushl $0
  102139:	6a 00                	push   $0x0
  pushl $105
  10213b:	6a 69                	push   $0x69
  jmp __alltraps
  10213d:	e9 c6 06 00 00       	jmp    102808 <__alltraps>

00102142 <vector106>:
.globl vector106
vector106:
  pushl $0
  102142:	6a 00                	push   $0x0
  pushl $106
  102144:	6a 6a                	push   $0x6a
  jmp __alltraps
  102146:	e9 bd 06 00 00       	jmp    102808 <__alltraps>

0010214b <vector107>:
.globl vector107
vector107:
  pushl $0
  10214b:	6a 00                	push   $0x0
  pushl $107
  10214d:	6a 6b                	push   $0x6b
  jmp __alltraps
  10214f:	e9 b4 06 00 00       	jmp    102808 <__alltraps>

00102154 <vector108>:
.globl vector108
vector108:
  pushl $0
  102154:	6a 00                	push   $0x0
  pushl $108
  102156:	6a 6c                	push   $0x6c
  jmp __alltraps
  102158:	e9 ab 06 00 00       	jmp    102808 <__alltraps>

0010215d <vector109>:
.globl vector109
vector109:
  pushl $0
  10215d:	6a 00                	push   $0x0
  pushl $109
  10215f:	6a 6d                	push   $0x6d
  jmp __alltraps
  102161:	e9 a2 06 00 00       	jmp    102808 <__alltraps>

00102166 <vector110>:
.globl vector110
vector110:
  pushl $0
  102166:	6a 00                	push   $0x0
  pushl $110
  102168:	6a 6e                	push   $0x6e
  jmp __alltraps
  10216a:	e9 99 06 00 00       	jmp    102808 <__alltraps>

0010216f <vector111>:
.globl vector111
vector111:
  pushl $0
  10216f:	6a 00                	push   $0x0
  pushl $111
  102171:	6a 6f                	push   $0x6f
  jmp __alltraps
  102173:	e9 90 06 00 00       	jmp    102808 <__alltraps>

00102178 <vector112>:
.globl vector112
vector112:
  pushl $0
  102178:	6a 00                	push   $0x0
  pushl $112
  10217a:	6a 70                	push   $0x70
  jmp __alltraps
  10217c:	e9 87 06 00 00       	jmp    102808 <__alltraps>

00102181 <vector113>:
.globl vector113
vector113:
  pushl $0
  102181:	6a 00                	push   $0x0
  pushl $113
  102183:	6a 71                	push   $0x71
  jmp __alltraps
  102185:	e9 7e 06 00 00       	jmp    102808 <__alltraps>

0010218a <vector114>:
.globl vector114
vector114:
  pushl $0
  10218a:	6a 00                	push   $0x0
  pushl $114
  10218c:	6a 72                	push   $0x72
  jmp __alltraps
  10218e:	e9 75 06 00 00       	jmp    102808 <__alltraps>

00102193 <vector115>:
.globl vector115
vector115:
  pushl $0
  102193:	6a 00                	push   $0x0
  pushl $115
  102195:	6a 73                	push   $0x73
  jmp __alltraps
  102197:	e9 6c 06 00 00       	jmp    102808 <__alltraps>

0010219c <vector116>:
.globl vector116
vector116:
  pushl $0
  10219c:	6a 00                	push   $0x0
  pushl $116
  10219e:	6a 74                	push   $0x74
  jmp __alltraps
  1021a0:	e9 63 06 00 00       	jmp    102808 <__alltraps>

001021a5 <vector117>:
.globl vector117
vector117:
  pushl $0
  1021a5:	6a 00                	push   $0x0
  pushl $117
  1021a7:	6a 75                	push   $0x75
  jmp __alltraps
  1021a9:	e9 5a 06 00 00       	jmp    102808 <__alltraps>

001021ae <vector118>:
.globl vector118
vector118:
  pushl $0
  1021ae:	6a 00                	push   $0x0
  pushl $118
  1021b0:	6a 76                	push   $0x76
  jmp __alltraps
  1021b2:	e9 51 06 00 00       	jmp    102808 <__alltraps>

001021b7 <vector119>:
.globl vector119
vector119:
  pushl $0
  1021b7:	6a 00                	push   $0x0
  pushl $119
  1021b9:	6a 77                	push   $0x77
  jmp __alltraps
  1021bb:	e9 48 06 00 00       	jmp    102808 <__alltraps>

001021c0 <vector120>:
.globl vector120
vector120:
  pushl $0
  1021c0:	6a 00                	push   $0x0
  pushl $120
  1021c2:	6a 78                	push   $0x78
  jmp __alltraps
  1021c4:	e9 3f 06 00 00       	jmp    102808 <__alltraps>

001021c9 <vector121>:
.globl vector121
vector121:
  pushl $0
  1021c9:	6a 00                	push   $0x0
  pushl $121
  1021cb:	6a 79                	push   $0x79
  jmp __alltraps
  1021cd:	e9 36 06 00 00       	jmp    102808 <__alltraps>

001021d2 <vector122>:
.globl vector122
vector122:
  pushl $0
  1021d2:	6a 00                	push   $0x0
  pushl $122
  1021d4:	6a 7a                	push   $0x7a
  jmp __alltraps
  1021d6:	e9 2d 06 00 00       	jmp    102808 <__alltraps>

001021db <vector123>:
.globl vector123
vector123:
  pushl $0
  1021db:	6a 00                	push   $0x0
  pushl $123
  1021dd:	6a 7b                	push   $0x7b
  jmp __alltraps
  1021df:	e9 24 06 00 00       	jmp    102808 <__alltraps>

001021e4 <vector124>:
.globl vector124
vector124:
  pushl $0
  1021e4:	6a 00                	push   $0x0
  pushl $124
  1021e6:	6a 7c                	push   $0x7c
  jmp __alltraps
  1021e8:	e9 1b 06 00 00       	jmp    102808 <__alltraps>

001021ed <vector125>:
.globl vector125
vector125:
  pushl $0
  1021ed:	6a 00                	push   $0x0
  pushl $125
  1021ef:	6a 7d                	push   $0x7d
  jmp __alltraps
  1021f1:	e9 12 06 00 00       	jmp    102808 <__alltraps>

001021f6 <vector126>:
.globl vector126
vector126:
  pushl $0
  1021f6:	6a 00                	push   $0x0
  pushl $126
  1021f8:	6a 7e                	push   $0x7e
  jmp __alltraps
  1021fa:	e9 09 06 00 00       	jmp    102808 <__alltraps>

001021ff <vector127>:
.globl vector127
vector127:
  pushl $0
  1021ff:	6a 00                	push   $0x0
  pushl $127
  102201:	6a 7f                	push   $0x7f
  jmp __alltraps
  102203:	e9 00 06 00 00       	jmp    102808 <__alltraps>

00102208 <vector128>:
.globl vector128
vector128:
  pushl $0
  102208:	6a 00                	push   $0x0
  pushl $128
  10220a:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  10220f:	e9 f4 05 00 00       	jmp    102808 <__alltraps>

00102214 <vector129>:
.globl vector129
vector129:
  pushl $0
  102214:	6a 00                	push   $0x0
  pushl $129
  102216:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  10221b:	e9 e8 05 00 00       	jmp    102808 <__alltraps>

00102220 <vector130>:
.globl vector130
vector130:
  pushl $0
  102220:	6a 00                	push   $0x0
  pushl $130
  102222:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102227:	e9 dc 05 00 00       	jmp    102808 <__alltraps>

0010222c <vector131>:
.globl vector131
vector131:
  pushl $0
  10222c:	6a 00                	push   $0x0
  pushl $131
  10222e:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102233:	e9 d0 05 00 00       	jmp    102808 <__alltraps>

00102238 <vector132>:
.globl vector132
vector132:
  pushl $0
  102238:	6a 00                	push   $0x0
  pushl $132
  10223a:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  10223f:	e9 c4 05 00 00       	jmp    102808 <__alltraps>

00102244 <vector133>:
.globl vector133
vector133:
  pushl $0
  102244:	6a 00                	push   $0x0
  pushl $133
  102246:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10224b:	e9 b8 05 00 00       	jmp    102808 <__alltraps>

00102250 <vector134>:
.globl vector134
vector134:
  pushl $0
  102250:	6a 00                	push   $0x0
  pushl $134
  102252:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102257:	e9 ac 05 00 00       	jmp    102808 <__alltraps>

0010225c <vector135>:
.globl vector135
vector135:
  pushl $0
  10225c:	6a 00                	push   $0x0
  pushl $135
  10225e:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102263:	e9 a0 05 00 00       	jmp    102808 <__alltraps>

00102268 <vector136>:
.globl vector136
vector136:
  pushl $0
  102268:	6a 00                	push   $0x0
  pushl $136
  10226a:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  10226f:	e9 94 05 00 00       	jmp    102808 <__alltraps>

00102274 <vector137>:
.globl vector137
vector137:
  pushl $0
  102274:	6a 00                	push   $0x0
  pushl $137
  102276:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  10227b:	e9 88 05 00 00       	jmp    102808 <__alltraps>

00102280 <vector138>:
.globl vector138
vector138:
  pushl $0
  102280:	6a 00                	push   $0x0
  pushl $138
  102282:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102287:	e9 7c 05 00 00       	jmp    102808 <__alltraps>

0010228c <vector139>:
.globl vector139
vector139:
  pushl $0
  10228c:	6a 00                	push   $0x0
  pushl $139
  10228e:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102293:	e9 70 05 00 00       	jmp    102808 <__alltraps>

00102298 <vector140>:
.globl vector140
vector140:
  pushl $0
  102298:	6a 00                	push   $0x0
  pushl $140
  10229a:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  10229f:	e9 64 05 00 00       	jmp    102808 <__alltraps>

001022a4 <vector141>:
.globl vector141
vector141:
  pushl $0
  1022a4:	6a 00                	push   $0x0
  pushl $141
  1022a6:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1022ab:	e9 58 05 00 00       	jmp    102808 <__alltraps>

001022b0 <vector142>:
.globl vector142
vector142:
  pushl $0
  1022b0:	6a 00                	push   $0x0
  pushl $142
  1022b2:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1022b7:	e9 4c 05 00 00       	jmp    102808 <__alltraps>

001022bc <vector143>:
.globl vector143
vector143:
  pushl $0
  1022bc:	6a 00                	push   $0x0
  pushl $143
  1022be:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1022c3:	e9 40 05 00 00       	jmp    102808 <__alltraps>

001022c8 <vector144>:
.globl vector144
vector144:
  pushl $0
  1022c8:	6a 00                	push   $0x0
  pushl $144
  1022ca:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1022cf:	e9 34 05 00 00       	jmp    102808 <__alltraps>

001022d4 <vector145>:
.globl vector145
vector145:
  pushl $0
  1022d4:	6a 00                	push   $0x0
  pushl $145
  1022d6:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1022db:	e9 28 05 00 00       	jmp    102808 <__alltraps>

001022e0 <vector146>:
.globl vector146
vector146:
  pushl $0
  1022e0:	6a 00                	push   $0x0
  pushl $146
  1022e2:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1022e7:	e9 1c 05 00 00       	jmp    102808 <__alltraps>

001022ec <vector147>:
.globl vector147
vector147:
  pushl $0
  1022ec:	6a 00                	push   $0x0
  pushl $147
  1022ee:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1022f3:	e9 10 05 00 00       	jmp    102808 <__alltraps>

001022f8 <vector148>:
.globl vector148
vector148:
  pushl $0
  1022f8:	6a 00                	push   $0x0
  pushl $148
  1022fa:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1022ff:	e9 04 05 00 00       	jmp    102808 <__alltraps>

00102304 <vector149>:
.globl vector149
vector149:
  pushl $0
  102304:	6a 00                	push   $0x0
  pushl $149
  102306:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  10230b:	e9 f8 04 00 00       	jmp    102808 <__alltraps>

00102310 <vector150>:
.globl vector150
vector150:
  pushl $0
  102310:	6a 00                	push   $0x0
  pushl $150
  102312:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102317:	e9 ec 04 00 00       	jmp    102808 <__alltraps>

0010231c <vector151>:
.globl vector151
vector151:
  pushl $0
  10231c:	6a 00                	push   $0x0
  pushl $151
  10231e:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102323:	e9 e0 04 00 00       	jmp    102808 <__alltraps>

00102328 <vector152>:
.globl vector152
vector152:
  pushl $0
  102328:	6a 00                	push   $0x0
  pushl $152
  10232a:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  10232f:	e9 d4 04 00 00       	jmp    102808 <__alltraps>

00102334 <vector153>:
.globl vector153
vector153:
  pushl $0
  102334:	6a 00                	push   $0x0
  pushl $153
  102336:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10233b:	e9 c8 04 00 00       	jmp    102808 <__alltraps>

00102340 <vector154>:
.globl vector154
vector154:
  pushl $0
  102340:	6a 00                	push   $0x0
  pushl $154
  102342:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102347:	e9 bc 04 00 00       	jmp    102808 <__alltraps>

0010234c <vector155>:
.globl vector155
vector155:
  pushl $0
  10234c:	6a 00                	push   $0x0
  pushl $155
  10234e:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102353:	e9 b0 04 00 00       	jmp    102808 <__alltraps>

00102358 <vector156>:
.globl vector156
vector156:
  pushl $0
  102358:	6a 00                	push   $0x0
  pushl $156
  10235a:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  10235f:	e9 a4 04 00 00       	jmp    102808 <__alltraps>

00102364 <vector157>:
.globl vector157
vector157:
  pushl $0
  102364:	6a 00                	push   $0x0
  pushl $157
  102366:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10236b:	e9 98 04 00 00       	jmp    102808 <__alltraps>

00102370 <vector158>:
.globl vector158
vector158:
  pushl $0
  102370:	6a 00                	push   $0x0
  pushl $158
  102372:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102377:	e9 8c 04 00 00       	jmp    102808 <__alltraps>

0010237c <vector159>:
.globl vector159
vector159:
  pushl $0
  10237c:	6a 00                	push   $0x0
  pushl $159
  10237e:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102383:	e9 80 04 00 00       	jmp    102808 <__alltraps>

00102388 <vector160>:
.globl vector160
vector160:
  pushl $0
  102388:	6a 00                	push   $0x0
  pushl $160
  10238a:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  10238f:	e9 74 04 00 00       	jmp    102808 <__alltraps>

00102394 <vector161>:
.globl vector161
vector161:
  pushl $0
  102394:	6a 00                	push   $0x0
  pushl $161
  102396:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10239b:	e9 68 04 00 00       	jmp    102808 <__alltraps>

001023a0 <vector162>:
.globl vector162
vector162:
  pushl $0
  1023a0:	6a 00                	push   $0x0
  pushl $162
  1023a2:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1023a7:	e9 5c 04 00 00       	jmp    102808 <__alltraps>

001023ac <vector163>:
.globl vector163
vector163:
  pushl $0
  1023ac:	6a 00                	push   $0x0
  pushl $163
  1023ae:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1023b3:	e9 50 04 00 00       	jmp    102808 <__alltraps>

001023b8 <vector164>:
.globl vector164
vector164:
  pushl $0
  1023b8:	6a 00                	push   $0x0
  pushl $164
  1023ba:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1023bf:	e9 44 04 00 00       	jmp    102808 <__alltraps>

001023c4 <vector165>:
.globl vector165
vector165:
  pushl $0
  1023c4:	6a 00                	push   $0x0
  pushl $165
  1023c6:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1023cb:	e9 38 04 00 00       	jmp    102808 <__alltraps>

001023d0 <vector166>:
.globl vector166
vector166:
  pushl $0
  1023d0:	6a 00                	push   $0x0
  pushl $166
  1023d2:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1023d7:	e9 2c 04 00 00       	jmp    102808 <__alltraps>

001023dc <vector167>:
.globl vector167
vector167:
  pushl $0
  1023dc:	6a 00                	push   $0x0
  pushl $167
  1023de:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1023e3:	e9 20 04 00 00       	jmp    102808 <__alltraps>

001023e8 <vector168>:
.globl vector168
vector168:
  pushl $0
  1023e8:	6a 00                	push   $0x0
  pushl $168
  1023ea:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1023ef:	e9 14 04 00 00       	jmp    102808 <__alltraps>

001023f4 <vector169>:
.globl vector169
vector169:
  pushl $0
  1023f4:	6a 00                	push   $0x0
  pushl $169
  1023f6:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1023fb:	e9 08 04 00 00       	jmp    102808 <__alltraps>

00102400 <vector170>:
.globl vector170
vector170:
  pushl $0
  102400:	6a 00                	push   $0x0
  pushl $170
  102402:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102407:	e9 fc 03 00 00       	jmp    102808 <__alltraps>

0010240c <vector171>:
.globl vector171
vector171:
  pushl $0
  10240c:	6a 00                	push   $0x0
  pushl $171
  10240e:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102413:	e9 f0 03 00 00       	jmp    102808 <__alltraps>

00102418 <vector172>:
.globl vector172
vector172:
  pushl $0
  102418:	6a 00                	push   $0x0
  pushl $172
  10241a:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  10241f:	e9 e4 03 00 00       	jmp    102808 <__alltraps>

00102424 <vector173>:
.globl vector173
vector173:
  pushl $0
  102424:	6a 00                	push   $0x0
  pushl $173
  102426:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10242b:	e9 d8 03 00 00       	jmp    102808 <__alltraps>

00102430 <vector174>:
.globl vector174
vector174:
  pushl $0
  102430:	6a 00                	push   $0x0
  pushl $174
  102432:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102437:	e9 cc 03 00 00       	jmp    102808 <__alltraps>

0010243c <vector175>:
.globl vector175
vector175:
  pushl $0
  10243c:	6a 00                	push   $0x0
  pushl $175
  10243e:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102443:	e9 c0 03 00 00       	jmp    102808 <__alltraps>

00102448 <vector176>:
.globl vector176
vector176:
  pushl $0
  102448:	6a 00                	push   $0x0
  pushl $176
  10244a:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  10244f:	e9 b4 03 00 00       	jmp    102808 <__alltraps>

00102454 <vector177>:
.globl vector177
vector177:
  pushl $0
  102454:	6a 00                	push   $0x0
  pushl $177
  102456:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10245b:	e9 a8 03 00 00       	jmp    102808 <__alltraps>

00102460 <vector178>:
.globl vector178
vector178:
  pushl $0
  102460:	6a 00                	push   $0x0
  pushl $178
  102462:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102467:	e9 9c 03 00 00       	jmp    102808 <__alltraps>

0010246c <vector179>:
.globl vector179
vector179:
  pushl $0
  10246c:	6a 00                	push   $0x0
  pushl $179
  10246e:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102473:	e9 90 03 00 00       	jmp    102808 <__alltraps>

00102478 <vector180>:
.globl vector180
vector180:
  pushl $0
  102478:	6a 00                	push   $0x0
  pushl $180
  10247a:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  10247f:	e9 84 03 00 00       	jmp    102808 <__alltraps>

00102484 <vector181>:
.globl vector181
vector181:
  pushl $0
  102484:	6a 00                	push   $0x0
  pushl $181
  102486:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10248b:	e9 78 03 00 00       	jmp    102808 <__alltraps>

00102490 <vector182>:
.globl vector182
vector182:
  pushl $0
  102490:	6a 00                	push   $0x0
  pushl $182
  102492:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102497:	e9 6c 03 00 00       	jmp    102808 <__alltraps>

0010249c <vector183>:
.globl vector183
vector183:
  pushl $0
  10249c:	6a 00                	push   $0x0
  pushl $183
  10249e:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1024a3:	e9 60 03 00 00       	jmp    102808 <__alltraps>

001024a8 <vector184>:
.globl vector184
vector184:
  pushl $0
  1024a8:	6a 00                	push   $0x0
  pushl $184
  1024aa:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1024af:	e9 54 03 00 00       	jmp    102808 <__alltraps>

001024b4 <vector185>:
.globl vector185
vector185:
  pushl $0
  1024b4:	6a 00                	push   $0x0
  pushl $185
  1024b6:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1024bb:	e9 48 03 00 00       	jmp    102808 <__alltraps>

001024c0 <vector186>:
.globl vector186
vector186:
  pushl $0
  1024c0:	6a 00                	push   $0x0
  pushl $186
  1024c2:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1024c7:	e9 3c 03 00 00       	jmp    102808 <__alltraps>

001024cc <vector187>:
.globl vector187
vector187:
  pushl $0
  1024cc:	6a 00                	push   $0x0
  pushl $187
  1024ce:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1024d3:	e9 30 03 00 00       	jmp    102808 <__alltraps>

001024d8 <vector188>:
.globl vector188
vector188:
  pushl $0
  1024d8:	6a 00                	push   $0x0
  pushl $188
  1024da:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1024df:	e9 24 03 00 00       	jmp    102808 <__alltraps>

001024e4 <vector189>:
.globl vector189
vector189:
  pushl $0
  1024e4:	6a 00                	push   $0x0
  pushl $189
  1024e6:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1024eb:	e9 18 03 00 00       	jmp    102808 <__alltraps>

001024f0 <vector190>:
.globl vector190
vector190:
  pushl $0
  1024f0:	6a 00                	push   $0x0
  pushl $190
  1024f2:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1024f7:	e9 0c 03 00 00       	jmp    102808 <__alltraps>

001024fc <vector191>:
.globl vector191
vector191:
  pushl $0
  1024fc:	6a 00                	push   $0x0
  pushl $191
  1024fe:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102503:	e9 00 03 00 00       	jmp    102808 <__alltraps>

00102508 <vector192>:
.globl vector192
vector192:
  pushl $0
  102508:	6a 00                	push   $0x0
  pushl $192
  10250a:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  10250f:	e9 f4 02 00 00       	jmp    102808 <__alltraps>

00102514 <vector193>:
.globl vector193
vector193:
  pushl $0
  102514:	6a 00                	push   $0x0
  pushl $193
  102516:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  10251b:	e9 e8 02 00 00       	jmp    102808 <__alltraps>

00102520 <vector194>:
.globl vector194
vector194:
  pushl $0
  102520:	6a 00                	push   $0x0
  pushl $194
  102522:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102527:	e9 dc 02 00 00       	jmp    102808 <__alltraps>

0010252c <vector195>:
.globl vector195
vector195:
  pushl $0
  10252c:	6a 00                	push   $0x0
  pushl $195
  10252e:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102533:	e9 d0 02 00 00       	jmp    102808 <__alltraps>

00102538 <vector196>:
.globl vector196
vector196:
  pushl $0
  102538:	6a 00                	push   $0x0
  pushl $196
  10253a:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10253f:	e9 c4 02 00 00       	jmp    102808 <__alltraps>

00102544 <vector197>:
.globl vector197
vector197:
  pushl $0
  102544:	6a 00                	push   $0x0
  pushl $197
  102546:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10254b:	e9 b8 02 00 00       	jmp    102808 <__alltraps>

00102550 <vector198>:
.globl vector198
vector198:
  pushl $0
  102550:	6a 00                	push   $0x0
  pushl $198
  102552:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102557:	e9 ac 02 00 00       	jmp    102808 <__alltraps>

0010255c <vector199>:
.globl vector199
vector199:
  pushl $0
  10255c:	6a 00                	push   $0x0
  pushl $199
  10255e:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102563:	e9 a0 02 00 00       	jmp    102808 <__alltraps>

00102568 <vector200>:
.globl vector200
vector200:
  pushl $0
  102568:	6a 00                	push   $0x0
  pushl $200
  10256a:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  10256f:	e9 94 02 00 00       	jmp    102808 <__alltraps>

00102574 <vector201>:
.globl vector201
vector201:
  pushl $0
  102574:	6a 00                	push   $0x0
  pushl $201
  102576:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  10257b:	e9 88 02 00 00       	jmp    102808 <__alltraps>

00102580 <vector202>:
.globl vector202
vector202:
  pushl $0
  102580:	6a 00                	push   $0x0
  pushl $202
  102582:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102587:	e9 7c 02 00 00       	jmp    102808 <__alltraps>

0010258c <vector203>:
.globl vector203
vector203:
  pushl $0
  10258c:	6a 00                	push   $0x0
  pushl $203
  10258e:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102593:	e9 70 02 00 00       	jmp    102808 <__alltraps>

00102598 <vector204>:
.globl vector204
vector204:
  pushl $0
  102598:	6a 00                	push   $0x0
  pushl $204
  10259a:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  10259f:	e9 64 02 00 00       	jmp    102808 <__alltraps>

001025a4 <vector205>:
.globl vector205
vector205:
  pushl $0
  1025a4:	6a 00                	push   $0x0
  pushl $205
  1025a6:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1025ab:	e9 58 02 00 00       	jmp    102808 <__alltraps>

001025b0 <vector206>:
.globl vector206
vector206:
  pushl $0
  1025b0:	6a 00                	push   $0x0
  pushl $206
  1025b2:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1025b7:	e9 4c 02 00 00       	jmp    102808 <__alltraps>

001025bc <vector207>:
.globl vector207
vector207:
  pushl $0
  1025bc:	6a 00                	push   $0x0
  pushl $207
  1025be:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1025c3:	e9 40 02 00 00       	jmp    102808 <__alltraps>

001025c8 <vector208>:
.globl vector208
vector208:
  pushl $0
  1025c8:	6a 00                	push   $0x0
  pushl $208
  1025ca:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1025cf:	e9 34 02 00 00       	jmp    102808 <__alltraps>

001025d4 <vector209>:
.globl vector209
vector209:
  pushl $0
  1025d4:	6a 00                	push   $0x0
  pushl $209
  1025d6:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1025db:	e9 28 02 00 00       	jmp    102808 <__alltraps>

001025e0 <vector210>:
.globl vector210
vector210:
  pushl $0
  1025e0:	6a 00                	push   $0x0
  pushl $210
  1025e2:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1025e7:	e9 1c 02 00 00       	jmp    102808 <__alltraps>

001025ec <vector211>:
.globl vector211
vector211:
  pushl $0
  1025ec:	6a 00                	push   $0x0
  pushl $211
  1025ee:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1025f3:	e9 10 02 00 00       	jmp    102808 <__alltraps>

001025f8 <vector212>:
.globl vector212
vector212:
  pushl $0
  1025f8:	6a 00                	push   $0x0
  pushl $212
  1025fa:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1025ff:	e9 04 02 00 00       	jmp    102808 <__alltraps>

00102604 <vector213>:
.globl vector213
vector213:
  pushl $0
  102604:	6a 00                	push   $0x0
  pushl $213
  102606:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  10260b:	e9 f8 01 00 00       	jmp    102808 <__alltraps>

00102610 <vector214>:
.globl vector214
vector214:
  pushl $0
  102610:	6a 00                	push   $0x0
  pushl $214
  102612:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102617:	e9 ec 01 00 00       	jmp    102808 <__alltraps>

0010261c <vector215>:
.globl vector215
vector215:
  pushl $0
  10261c:	6a 00                	push   $0x0
  pushl $215
  10261e:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102623:	e9 e0 01 00 00       	jmp    102808 <__alltraps>

00102628 <vector216>:
.globl vector216
vector216:
  pushl $0
  102628:	6a 00                	push   $0x0
  pushl $216
  10262a:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  10262f:	e9 d4 01 00 00       	jmp    102808 <__alltraps>

00102634 <vector217>:
.globl vector217
vector217:
  pushl $0
  102634:	6a 00                	push   $0x0
  pushl $217
  102636:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  10263b:	e9 c8 01 00 00       	jmp    102808 <__alltraps>

00102640 <vector218>:
.globl vector218
vector218:
  pushl $0
  102640:	6a 00                	push   $0x0
  pushl $218
  102642:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102647:	e9 bc 01 00 00       	jmp    102808 <__alltraps>

0010264c <vector219>:
.globl vector219
vector219:
  pushl $0
  10264c:	6a 00                	push   $0x0
  pushl $219
  10264e:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102653:	e9 b0 01 00 00       	jmp    102808 <__alltraps>

00102658 <vector220>:
.globl vector220
vector220:
  pushl $0
  102658:	6a 00                	push   $0x0
  pushl $220
  10265a:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  10265f:	e9 a4 01 00 00       	jmp    102808 <__alltraps>

00102664 <vector221>:
.globl vector221
vector221:
  pushl $0
  102664:	6a 00                	push   $0x0
  pushl $221
  102666:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  10266b:	e9 98 01 00 00       	jmp    102808 <__alltraps>

00102670 <vector222>:
.globl vector222
vector222:
  pushl $0
  102670:	6a 00                	push   $0x0
  pushl $222
  102672:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102677:	e9 8c 01 00 00       	jmp    102808 <__alltraps>

0010267c <vector223>:
.globl vector223
vector223:
  pushl $0
  10267c:	6a 00                	push   $0x0
  pushl $223
  10267e:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102683:	e9 80 01 00 00       	jmp    102808 <__alltraps>

00102688 <vector224>:
.globl vector224
vector224:
  pushl $0
  102688:	6a 00                	push   $0x0
  pushl $224
  10268a:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  10268f:	e9 74 01 00 00       	jmp    102808 <__alltraps>

00102694 <vector225>:
.globl vector225
vector225:
  pushl $0
  102694:	6a 00                	push   $0x0
  pushl $225
  102696:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10269b:	e9 68 01 00 00       	jmp    102808 <__alltraps>

001026a0 <vector226>:
.globl vector226
vector226:
  pushl $0
  1026a0:	6a 00                	push   $0x0
  pushl $226
  1026a2:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1026a7:	e9 5c 01 00 00       	jmp    102808 <__alltraps>

001026ac <vector227>:
.globl vector227
vector227:
  pushl $0
  1026ac:	6a 00                	push   $0x0
  pushl $227
  1026ae:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1026b3:	e9 50 01 00 00       	jmp    102808 <__alltraps>

001026b8 <vector228>:
.globl vector228
vector228:
  pushl $0
  1026b8:	6a 00                	push   $0x0
  pushl $228
  1026ba:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1026bf:	e9 44 01 00 00       	jmp    102808 <__alltraps>

001026c4 <vector229>:
.globl vector229
vector229:
  pushl $0
  1026c4:	6a 00                	push   $0x0
  pushl $229
  1026c6:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1026cb:	e9 38 01 00 00       	jmp    102808 <__alltraps>

001026d0 <vector230>:
.globl vector230
vector230:
  pushl $0
  1026d0:	6a 00                	push   $0x0
  pushl $230
  1026d2:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1026d7:	e9 2c 01 00 00       	jmp    102808 <__alltraps>

001026dc <vector231>:
.globl vector231
vector231:
  pushl $0
  1026dc:	6a 00                	push   $0x0
  pushl $231
  1026de:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1026e3:	e9 20 01 00 00       	jmp    102808 <__alltraps>

001026e8 <vector232>:
.globl vector232
vector232:
  pushl $0
  1026e8:	6a 00                	push   $0x0
  pushl $232
  1026ea:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1026ef:	e9 14 01 00 00       	jmp    102808 <__alltraps>

001026f4 <vector233>:
.globl vector233
vector233:
  pushl $0
  1026f4:	6a 00                	push   $0x0
  pushl $233
  1026f6:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1026fb:	e9 08 01 00 00       	jmp    102808 <__alltraps>

00102700 <vector234>:
.globl vector234
vector234:
  pushl $0
  102700:	6a 00                	push   $0x0
  pushl $234
  102702:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102707:	e9 fc 00 00 00       	jmp    102808 <__alltraps>

0010270c <vector235>:
.globl vector235
vector235:
  pushl $0
  10270c:	6a 00                	push   $0x0
  pushl $235
  10270e:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102713:	e9 f0 00 00 00       	jmp    102808 <__alltraps>

00102718 <vector236>:
.globl vector236
vector236:
  pushl $0
  102718:	6a 00                	push   $0x0
  pushl $236
  10271a:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  10271f:	e9 e4 00 00 00       	jmp    102808 <__alltraps>

00102724 <vector237>:
.globl vector237
vector237:
  pushl $0
  102724:	6a 00                	push   $0x0
  pushl $237
  102726:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10272b:	e9 d8 00 00 00       	jmp    102808 <__alltraps>

00102730 <vector238>:
.globl vector238
vector238:
  pushl $0
  102730:	6a 00                	push   $0x0
  pushl $238
  102732:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102737:	e9 cc 00 00 00       	jmp    102808 <__alltraps>

0010273c <vector239>:
.globl vector239
vector239:
  pushl $0
  10273c:	6a 00                	push   $0x0
  pushl $239
  10273e:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102743:	e9 c0 00 00 00       	jmp    102808 <__alltraps>

00102748 <vector240>:
.globl vector240
vector240:
  pushl $0
  102748:	6a 00                	push   $0x0
  pushl $240
  10274a:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  10274f:	e9 b4 00 00 00       	jmp    102808 <__alltraps>

00102754 <vector241>:
.globl vector241
vector241:
  pushl $0
  102754:	6a 00                	push   $0x0
  pushl $241
  102756:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10275b:	e9 a8 00 00 00       	jmp    102808 <__alltraps>

00102760 <vector242>:
.globl vector242
vector242:
  pushl $0
  102760:	6a 00                	push   $0x0
  pushl $242
  102762:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102767:	e9 9c 00 00 00       	jmp    102808 <__alltraps>

0010276c <vector243>:
.globl vector243
vector243:
  pushl $0
  10276c:	6a 00                	push   $0x0
  pushl $243
  10276e:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102773:	e9 90 00 00 00       	jmp    102808 <__alltraps>

00102778 <vector244>:
.globl vector244
vector244:
  pushl $0
  102778:	6a 00                	push   $0x0
  pushl $244
  10277a:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  10277f:	e9 84 00 00 00       	jmp    102808 <__alltraps>

00102784 <vector245>:
.globl vector245
vector245:
  pushl $0
  102784:	6a 00                	push   $0x0
  pushl $245
  102786:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  10278b:	e9 78 00 00 00       	jmp    102808 <__alltraps>

00102790 <vector246>:
.globl vector246
vector246:
  pushl $0
  102790:	6a 00                	push   $0x0
  pushl $246
  102792:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102797:	e9 6c 00 00 00       	jmp    102808 <__alltraps>

0010279c <vector247>:
.globl vector247
vector247:
  pushl $0
  10279c:	6a 00                	push   $0x0
  pushl $247
  10279e:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1027a3:	e9 60 00 00 00       	jmp    102808 <__alltraps>

001027a8 <vector248>:
.globl vector248
vector248:
  pushl $0
  1027a8:	6a 00                	push   $0x0
  pushl $248
  1027aa:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1027af:	e9 54 00 00 00       	jmp    102808 <__alltraps>

001027b4 <vector249>:
.globl vector249
vector249:
  pushl $0
  1027b4:	6a 00                	push   $0x0
  pushl $249
  1027b6:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1027bb:	e9 48 00 00 00       	jmp    102808 <__alltraps>

001027c0 <vector250>:
.globl vector250
vector250:
  pushl $0
  1027c0:	6a 00                	push   $0x0
  pushl $250
  1027c2:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1027c7:	e9 3c 00 00 00       	jmp    102808 <__alltraps>

001027cc <vector251>:
.globl vector251
vector251:
  pushl $0
  1027cc:	6a 00                	push   $0x0
  pushl $251
  1027ce:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1027d3:	e9 30 00 00 00       	jmp    102808 <__alltraps>

001027d8 <vector252>:
.globl vector252
vector252:
  pushl $0
  1027d8:	6a 00                	push   $0x0
  pushl $252
  1027da:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1027df:	e9 24 00 00 00       	jmp    102808 <__alltraps>

001027e4 <vector253>:
.globl vector253
vector253:
  pushl $0
  1027e4:	6a 00                	push   $0x0
  pushl $253
  1027e6:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1027eb:	e9 18 00 00 00       	jmp    102808 <__alltraps>

001027f0 <vector254>:
.globl vector254
vector254:
  pushl $0
  1027f0:	6a 00                	push   $0x0
  pushl $254
  1027f2:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1027f7:	e9 0c 00 00 00       	jmp    102808 <__alltraps>

001027fc <vector255>:
.globl vector255
vector255:
  pushl $0
  1027fc:	6a 00                	push   $0x0
  pushl $255
  1027fe:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102803:	e9 00 00 00 00       	jmp    102808 <__alltraps>

00102808 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102808:	1e                   	push   %ds
    pushl %es
  102809:	06                   	push   %es
    pushl %fs
  10280a:	0f a0                	push   %fs
    pushl %gs
  10280c:	0f a8                	push   %gs
    pushal
  10280e:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  10280f:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102814:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102816:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102818:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102819:	e8 64 f5 ff ff       	call   101d82 <trap>

    # pop the pushed stack pointer
    popl %esp
  10281e:	5c                   	pop    %esp

0010281f <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  10281f:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102820:	0f a9                	pop    %gs
    popl %fs
  102822:	0f a1                	pop    %fs
    popl %es
  102824:	07                   	pop    %es
    popl %ds
  102825:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102826:	83 c4 08             	add    $0x8,%esp
    iret
  102829:	cf                   	iret   

0010282a <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  10282a:	55                   	push   %ebp
  10282b:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10282d:	8b 45 08             	mov    0x8(%ebp),%eax
  102830:	8b 15 18 df 11 00    	mov    0x11df18,%edx
  102836:	29 d0                	sub    %edx,%eax
  102838:	c1 f8 02             	sar    $0x2,%eax
  10283b:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102841:	5d                   	pop    %ebp
  102842:	c3                   	ret    

00102843 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102843:	55                   	push   %ebp
  102844:	89 e5                	mov    %esp,%ebp
  102846:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102849:	8b 45 08             	mov    0x8(%ebp),%eax
  10284c:	89 04 24             	mov    %eax,(%esp)
  10284f:	e8 d6 ff ff ff       	call   10282a <page2ppn>
  102854:	c1 e0 0c             	shl    $0xc,%eax
}
  102857:	c9                   	leave  
  102858:	c3                   	ret    

00102859 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  102859:	55                   	push   %ebp
  10285a:	89 e5                	mov    %esp,%ebp
  10285c:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  10285f:	8b 45 08             	mov    0x8(%ebp),%eax
  102862:	c1 e8 0c             	shr    $0xc,%eax
  102865:	89 c2                	mov    %eax,%edx
  102867:	a1 80 de 11 00       	mov    0x11de80,%eax
  10286c:	39 c2                	cmp    %eax,%edx
  10286e:	72 1c                	jb     10288c <pa2page+0x33>
        panic("pa2page called with invalid pa");
  102870:	c7 44 24 08 d0 73 10 	movl   $0x1073d0,0x8(%esp)
  102877:	00 
  102878:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  10287f:	00 
  102880:	c7 04 24 ef 73 10 00 	movl   $0x1073ef,(%esp)
  102887:	e8 5d db ff ff       	call   1003e9 <__panic>
    }
    return &pages[PPN(pa)];
  10288c:	8b 0d 18 df 11 00    	mov    0x11df18,%ecx
  102892:	8b 45 08             	mov    0x8(%ebp),%eax
  102895:	c1 e8 0c             	shr    $0xc,%eax
  102898:	89 c2                	mov    %eax,%edx
  10289a:	89 d0                	mov    %edx,%eax
  10289c:	c1 e0 02             	shl    $0x2,%eax
  10289f:	01 d0                	add    %edx,%eax
  1028a1:	c1 e0 02             	shl    $0x2,%eax
  1028a4:	01 c8                	add    %ecx,%eax
}
  1028a6:	c9                   	leave  
  1028a7:	c3                   	ret    

001028a8 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  1028a8:	55                   	push   %ebp
  1028a9:	89 e5                	mov    %esp,%ebp
  1028ab:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  1028ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1028b1:	89 04 24             	mov    %eax,(%esp)
  1028b4:	e8 8a ff ff ff       	call   102843 <page2pa>
  1028b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1028bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028bf:	c1 e8 0c             	shr    $0xc,%eax
  1028c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1028c5:	a1 80 de 11 00       	mov    0x11de80,%eax
  1028ca:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  1028cd:	72 23                	jb     1028f2 <page2kva+0x4a>
  1028cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1028d6:	c7 44 24 08 00 74 10 	movl   $0x107400,0x8(%esp)
  1028dd:	00 
  1028de:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  1028e5:	00 
  1028e6:	c7 04 24 ef 73 10 00 	movl   $0x1073ef,(%esp)
  1028ed:	e8 f7 da ff ff       	call   1003e9 <__panic>
  1028f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028f5:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  1028fa:	c9                   	leave  
  1028fb:	c3                   	ret    

001028fc <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  1028fc:	55                   	push   %ebp
  1028fd:	89 e5                	mov    %esp,%ebp
  1028ff:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  102902:	8b 45 08             	mov    0x8(%ebp),%eax
  102905:	83 e0 01             	and    $0x1,%eax
  102908:	85 c0                	test   %eax,%eax
  10290a:	75 1c                	jne    102928 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  10290c:	c7 44 24 08 24 74 10 	movl   $0x107424,0x8(%esp)
  102913:	00 
  102914:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  10291b:	00 
  10291c:	c7 04 24 ef 73 10 00 	movl   $0x1073ef,(%esp)
  102923:	e8 c1 da ff ff       	call   1003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  102928:	8b 45 08             	mov    0x8(%ebp),%eax
  10292b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102930:	89 04 24             	mov    %eax,(%esp)
  102933:	e8 21 ff ff ff       	call   102859 <pa2page>
}
  102938:	c9                   	leave  
  102939:	c3                   	ret    

0010293a <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  10293a:	55                   	push   %ebp
  10293b:	89 e5                	mov    %esp,%ebp
  10293d:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  102940:	8b 45 08             	mov    0x8(%ebp),%eax
  102943:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102948:	89 04 24             	mov    %eax,(%esp)
  10294b:	e8 09 ff ff ff       	call   102859 <pa2page>
}
  102950:	c9                   	leave  
  102951:	c3                   	ret    

00102952 <page_ref>:

static inline int
page_ref(struct Page *page) {
  102952:	55                   	push   %ebp
  102953:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102955:	8b 45 08             	mov    0x8(%ebp),%eax
  102958:	8b 00                	mov    (%eax),%eax
}
  10295a:	5d                   	pop    %ebp
  10295b:	c3                   	ret    

0010295c <page_ref_inc>:
set_page_ref(struct Page *page, int val) {
    page->ref = val;
}

static inline int
page_ref_inc(struct Page *page) {
  10295c:	55                   	push   %ebp
  10295d:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  10295f:	8b 45 08             	mov    0x8(%ebp),%eax
  102962:	8b 00                	mov    (%eax),%eax
  102964:	8d 50 01             	lea    0x1(%eax),%edx
  102967:	8b 45 08             	mov    0x8(%ebp),%eax
  10296a:	89 10                	mov    %edx,(%eax)
    return page->ref;
  10296c:	8b 45 08             	mov    0x8(%ebp),%eax
  10296f:	8b 00                	mov    (%eax),%eax
}
  102971:	5d                   	pop    %ebp
  102972:	c3                   	ret    

00102973 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  102973:	55                   	push   %ebp
  102974:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  102976:	8b 45 08             	mov    0x8(%ebp),%eax
  102979:	8b 00                	mov    (%eax),%eax
  10297b:	8d 50 ff             	lea    -0x1(%eax),%edx
  10297e:	8b 45 08             	mov    0x8(%ebp),%eax
  102981:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102983:	8b 45 08             	mov    0x8(%ebp),%eax
  102986:	8b 00                	mov    (%eax),%eax
}
  102988:	5d                   	pop    %ebp
  102989:	c3                   	ret    

0010298a <__intr_save>:
__intr_save(void) {
  10298a:	55                   	push   %ebp
  10298b:	89 e5                	mov    %esp,%ebp
  10298d:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102990:	9c                   	pushf  
  102991:	58                   	pop    %eax
  102992:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102995:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102998:	25 00 02 00 00       	and    $0x200,%eax
  10299d:	85 c0                	test   %eax,%eax
  10299f:	74 0c                	je     1029ad <__intr_save+0x23>
        intr_disable();
  1029a1:	e8 e7 ee ff ff       	call   10188d <intr_disable>
        return 1;
  1029a6:	b8 01 00 00 00       	mov    $0x1,%eax
  1029ab:	eb 05                	jmp    1029b2 <__intr_save+0x28>
    return 0;
  1029ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1029b2:	c9                   	leave  
  1029b3:	c3                   	ret    

001029b4 <__intr_restore>:
__intr_restore(bool flag) {
  1029b4:	55                   	push   %ebp
  1029b5:	89 e5                	mov    %esp,%ebp
  1029b7:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  1029ba:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1029be:	74 05                	je     1029c5 <__intr_restore+0x11>
        intr_enable();
  1029c0:	e8 c1 ee ff ff       	call   101886 <intr_enable>
}
  1029c5:	90                   	nop
  1029c6:	c9                   	leave  
  1029c7:	c3                   	ret    

001029c8 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  1029c8:	55                   	push   %ebp
  1029c9:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  1029cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1029ce:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  1029d1:	b8 23 00 00 00       	mov    $0x23,%eax
  1029d6:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  1029d8:	b8 23 00 00 00       	mov    $0x23,%eax
  1029dd:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  1029df:	b8 10 00 00 00       	mov    $0x10,%eax
  1029e4:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  1029e6:	b8 10 00 00 00       	mov    $0x10,%eax
  1029eb:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  1029ed:	b8 10 00 00 00       	mov    $0x10,%eax
  1029f2:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  1029f4:	ea fb 29 10 00 08 00 	ljmp   $0x8,$0x1029fb
}
  1029fb:	90                   	nop
  1029fc:	5d                   	pop    %ebp
  1029fd:	c3                   	ret    

001029fe <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  1029fe:	55                   	push   %ebp
  1029ff:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102a01:	8b 45 08             	mov    0x8(%ebp),%eax
  102a04:	a3 a4 de 11 00       	mov    %eax,0x11dea4
}
  102a09:	90                   	nop
  102a0a:	5d                   	pop    %ebp
  102a0b:	c3                   	ret    

00102a0c <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102a0c:	55                   	push   %ebp
  102a0d:	89 e5                	mov    %esp,%ebp
  102a0f:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102a12:	b8 00 a0 11 00       	mov    $0x11a000,%eax
  102a17:	89 04 24             	mov    %eax,(%esp)
  102a1a:	e8 df ff ff ff       	call   1029fe <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102a1f:	66 c7 05 a8 de 11 00 	movw   $0x10,0x11dea8
  102a26:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102a28:	66 c7 05 28 aa 11 00 	movw   $0x68,0x11aa28
  102a2f:	68 00 
  102a31:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102a36:	0f b7 c0             	movzwl %ax,%eax
  102a39:	66 a3 2a aa 11 00    	mov    %ax,0x11aa2a
  102a3f:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102a44:	c1 e8 10             	shr    $0x10,%eax
  102a47:	a2 2c aa 11 00       	mov    %al,0x11aa2c
  102a4c:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102a53:	24 f0                	and    $0xf0,%al
  102a55:	0c 09                	or     $0x9,%al
  102a57:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102a5c:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102a63:	24 ef                	and    $0xef,%al
  102a65:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102a6a:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102a71:	24 9f                	and    $0x9f,%al
  102a73:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102a78:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102a7f:	0c 80                	or     $0x80,%al
  102a81:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102a86:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102a8d:	24 f0                	and    $0xf0,%al
  102a8f:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102a94:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102a9b:	24 ef                	and    $0xef,%al
  102a9d:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102aa2:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102aa9:	24 df                	and    $0xdf,%al
  102aab:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102ab0:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102ab7:	0c 40                	or     $0x40,%al
  102ab9:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102abe:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102ac5:	24 7f                	and    $0x7f,%al
  102ac7:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102acc:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102ad1:	c1 e8 18             	shr    $0x18,%eax
  102ad4:	a2 2f aa 11 00       	mov    %al,0x11aa2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102ad9:	c7 04 24 30 aa 11 00 	movl   $0x11aa30,(%esp)
  102ae0:	e8 e3 fe ff ff       	call   1029c8 <lgdt>
  102ae5:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102aeb:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102aef:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102af2:	90                   	nop
  102af3:	c9                   	leave  
  102af4:	c3                   	ret    

00102af5 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102af5:	55                   	push   %ebp
  102af6:	89 e5                	mov    %esp,%ebp
  102af8:	83 ec 18             	sub    $0x18,%esp
    //pmm_manager = &default_pmm_manager;
    pmm_manager = &buddy_system;
  102afb:	c7 05 10 df 11 00 94 	movl   $0x108094,0x11df10
  102b02:	80 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102b05:	a1 10 df 11 00       	mov    0x11df10,%eax
  102b0a:	8b 00                	mov    (%eax),%eax
  102b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b10:	c7 04 24 50 74 10 00 	movl   $0x107450,(%esp)
  102b17:	e8 76 d7 ff ff       	call   100292 <cprintf>
    pmm_manager->init();
  102b1c:	a1 10 df 11 00       	mov    0x11df10,%eax
  102b21:	8b 40 04             	mov    0x4(%eax),%eax
  102b24:	ff d0                	call   *%eax
}
  102b26:	90                   	nop
  102b27:	c9                   	leave  
  102b28:	c3                   	ret    

00102b29 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102b29:	55                   	push   %ebp
  102b2a:	89 e5                	mov    %esp,%ebp
  102b2c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102b2f:	a1 10 df 11 00       	mov    0x11df10,%eax
  102b34:	8b 40 08             	mov    0x8(%eax),%eax
  102b37:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b3a:	89 54 24 04          	mov    %edx,0x4(%esp)
  102b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  102b41:	89 14 24             	mov    %edx,(%esp)
  102b44:	ff d0                	call   *%eax
}
  102b46:	90                   	nop
  102b47:	c9                   	leave  
  102b48:	c3                   	ret    

00102b49 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102b49:	55                   	push   %ebp
  102b4a:	89 e5                	mov    %esp,%ebp
  102b4c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102b4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102b56:	e8 2f fe ff ff       	call   10298a <__intr_save>
  102b5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102b5e:	a1 10 df 11 00       	mov    0x11df10,%eax
  102b63:	8b 40 0c             	mov    0xc(%eax),%eax
  102b66:	8b 55 08             	mov    0x8(%ebp),%edx
  102b69:	89 14 24             	mov    %edx,(%esp)
  102b6c:	ff d0                	call   *%eax
  102b6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b74:	89 04 24             	mov    %eax,(%esp)
  102b77:	e8 38 fe ff ff       	call   1029b4 <__intr_restore>
    return page;
  102b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102b7f:	c9                   	leave  
  102b80:	c3                   	ret    

00102b81 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102b81:	55                   	push   %ebp
  102b82:	89 e5                	mov    %esp,%ebp
  102b84:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102b87:	e8 fe fd ff ff       	call   10298a <__intr_save>
  102b8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102b8f:	a1 10 df 11 00       	mov    0x11df10,%eax
  102b94:	8b 40 10             	mov    0x10(%eax),%eax
  102b97:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b9a:	89 54 24 04          	mov    %edx,0x4(%esp)
  102b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  102ba1:	89 14 24             	mov    %edx,(%esp)
  102ba4:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ba9:	89 04 24             	mov    %eax,(%esp)
  102bac:	e8 03 fe ff ff       	call   1029b4 <__intr_restore>
}
  102bb1:	90                   	nop
  102bb2:	c9                   	leave  
  102bb3:	c3                   	ret    

00102bb4 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102bb4:	55                   	push   %ebp
  102bb5:	89 e5                	mov    %esp,%ebp
  102bb7:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102bba:	e8 cb fd ff ff       	call   10298a <__intr_save>
  102bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102bc2:	a1 10 df 11 00       	mov    0x11df10,%eax
  102bc7:	8b 40 14             	mov    0x14(%eax),%eax
  102bca:	ff d0                	call   *%eax
  102bcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bd2:	89 04 24             	mov    %eax,(%esp)
  102bd5:	e8 da fd ff ff       	call   1029b4 <__intr_restore>
    return ret;
  102bda:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102bdd:	c9                   	leave  
  102bde:	c3                   	ret    

00102bdf <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102bdf:	55                   	push   %ebp
  102be0:	89 e5                	mov    %esp,%ebp
  102be2:	57                   	push   %edi
  102be3:	56                   	push   %esi
  102be4:	53                   	push   %ebx
  102be5:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102beb:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102bf2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102bf9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102c00:	c7 04 24 67 74 10 00 	movl   $0x107467,(%esp)
  102c07:	e8 86 d6 ff ff       	call   100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102c0c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102c13:	e9 22 01 00 00       	jmp    102d3a <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102c18:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c1b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c1e:	89 d0                	mov    %edx,%eax
  102c20:	c1 e0 02             	shl    $0x2,%eax
  102c23:	01 d0                	add    %edx,%eax
  102c25:	c1 e0 02             	shl    $0x2,%eax
  102c28:	01 c8                	add    %ecx,%eax
  102c2a:	8b 50 08             	mov    0x8(%eax),%edx
  102c2d:	8b 40 04             	mov    0x4(%eax),%eax
  102c30:	89 45 a0             	mov    %eax,-0x60(%ebp)
  102c33:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102c36:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c39:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c3c:	89 d0                	mov    %edx,%eax
  102c3e:	c1 e0 02             	shl    $0x2,%eax
  102c41:	01 d0                	add    %edx,%eax
  102c43:	c1 e0 02             	shl    $0x2,%eax
  102c46:	01 c8                	add    %ecx,%eax
  102c48:	8b 48 0c             	mov    0xc(%eax),%ecx
  102c4b:	8b 58 10             	mov    0x10(%eax),%ebx
  102c4e:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102c51:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102c54:	01 c8                	add    %ecx,%eax
  102c56:	11 da                	adc    %ebx,%edx
  102c58:	89 45 98             	mov    %eax,-0x68(%ebp)
  102c5b:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102c5e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c61:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c64:	89 d0                	mov    %edx,%eax
  102c66:	c1 e0 02             	shl    $0x2,%eax
  102c69:	01 d0                	add    %edx,%eax
  102c6b:	c1 e0 02             	shl    $0x2,%eax
  102c6e:	01 c8                	add    %ecx,%eax
  102c70:	83 c0 14             	add    $0x14,%eax
  102c73:	8b 00                	mov    (%eax),%eax
  102c75:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102c78:	8b 45 98             	mov    -0x68(%ebp),%eax
  102c7b:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102c7e:	83 c0 ff             	add    $0xffffffff,%eax
  102c81:	83 d2 ff             	adc    $0xffffffff,%edx
  102c84:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102c8a:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102c90:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c93:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c96:	89 d0                	mov    %edx,%eax
  102c98:	c1 e0 02             	shl    $0x2,%eax
  102c9b:	01 d0                	add    %edx,%eax
  102c9d:	c1 e0 02             	shl    $0x2,%eax
  102ca0:	01 c8                	add    %ecx,%eax
  102ca2:	8b 48 0c             	mov    0xc(%eax),%ecx
  102ca5:	8b 58 10             	mov    0x10(%eax),%ebx
  102ca8:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102cab:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102caf:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102cb5:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102cbb:	89 44 24 14          	mov    %eax,0x14(%esp)
  102cbf:	89 54 24 18          	mov    %edx,0x18(%esp)
  102cc3:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102cc6:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102cc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102ccd:	89 54 24 10          	mov    %edx,0x10(%esp)
  102cd1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102cd5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102cd9:	c7 04 24 74 74 10 00 	movl   $0x107474,(%esp)
  102ce0:	e8 ad d5 ff ff       	call   100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102ce5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ce8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ceb:	89 d0                	mov    %edx,%eax
  102ced:	c1 e0 02             	shl    $0x2,%eax
  102cf0:	01 d0                	add    %edx,%eax
  102cf2:	c1 e0 02             	shl    $0x2,%eax
  102cf5:	01 c8                	add    %ecx,%eax
  102cf7:	83 c0 14             	add    $0x14,%eax
  102cfa:	8b 00                	mov    (%eax),%eax
  102cfc:	83 f8 01             	cmp    $0x1,%eax
  102cff:	75 36                	jne    102d37 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
  102d01:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d04:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d07:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102d0a:	77 2b                	ja     102d37 <page_init+0x158>
  102d0c:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102d0f:	72 05                	jb     102d16 <page_init+0x137>
  102d11:	3b 45 98             	cmp    -0x68(%ebp),%eax
  102d14:	73 21                	jae    102d37 <page_init+0x158>
  102d16:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102d1a:	77 1b                	ja     102d37 <page_init+0x158>
  102d1c:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102d20:	72 09                	jb     102d2b <page_init+0x14c>
  102d22:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
  102d29:	77 0c                	ja     102d37 <page_init+0x158>
                maxpa = end;
  102d2b:	8b 45 98             	mov    -0x68(%ebp),%eax
  102d2e:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102d31:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102d34:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102d37:	ff 45 dc             	incl   -0x24(%ebp)
  102d3a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102d3d:	8b 00                	mov    (%eax),%eax
  102d3f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102d42:	0f 8c d0 fe ff ff    	jl     102c18 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102d48:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102d4c:	72 1d                	jb     102d6b <page_init+0x18c>
  102d4e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102d52:	77 09                	ja     102d5d <page_init+0x17e>
  102d54:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102d5b:	76 0e                	jbe    102d6b <page_init+0x18c>
        maxpa = KMEMSIZE;
  102d5d:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102d64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d71:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102d75:	c1 ea 0c             	shr    $0xc,%edx
  102d78:	89 c1                	mov    %eax,%ecx
  102d7a:	89 d3                	mov    %edx,%ebx
  102d7c:	89 c8                	mov    %ecx,%eax
  102d7e:	a3 80 de 11 00       	mov    %eax,0x11de80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102d83:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  102d8a:	b8 bc df 11 00       	mov    $0x11dfbc,%eax
  102d8f:	8d 50 ff             	lea    -0x1(%eax),%edx
  102d92:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102d95:	01 d0                	add    %edx,%eax
  102d97:	89 45 bc             	mov    %eax,-0x44(%ebp)
  102d9a:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102d9d:	ba 00 00 00 00       	mov    $0x0,%edx
  102da2:	f7 75 c0             	divl   -0x40(%ebp)
  102da5:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102da8:	29 d0                	sub    %edx,%eax
  102daa:	a3 18 df 11 00       	mov    %eax,0x11df18

    for (i = 0; i < npage; i ++) {
  102daf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102db6:	eb 2e                	jmp    102de6 <page_init+0x207>
        SetPageReserved(pages + i);
  102db8:	8b 0d 18 df 11 00    	mov    0x11df18,%ecx
  102dbe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102dc1:	89 d0                	mov    %edx,%eax
  102dc3:	c1 e0 02             	shl    $0x2,%eax
  102dc6:	01 d0                	add    %edx,%eax
  102dc8:	c1 e0 02             	shl    $0x2,%eax
  102dcb:	01 c8                	add    %ecx,%eax
  102dcd:	83 c0 04             	add    $0x4,%eax
  102dd0:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  102dd7:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102dda:	8b 45 90             	mov    -0x70(%ebp),%eax
  102ddd:	8b 55 94             	mov    -0x6c(%ebp),%edx
  102de0:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
  102de3:	ff 45 dc             	incl   -0x24(%ebp)
  102de6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102de9:	a1 80 de 11 00       	mov    0x11de80,%eax
  102dee:	39 c2                	cmp    %eax,%edx
  102df0:	72 c6                	jb     102db8 <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102df2:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  102df8:	89 d0                	mov    %edx,%eax
  102dfa:	c1 e0 02             	shl    $0x2,%eax
  102dfd:	01 d0                	add    %edx,%eax
  102dff:	c1 e0 02             	shl    $0x2,%eax
  102e02:	89 c2                	mov    %eax,%edx
  102e04:	a1 18 df 11 00       	mov    0x11df18,%eax
  102e09:	01 d0                	add    %edx,%eax
  102e0b:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102e0e:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  102e15:	77 23                	ja     102e3a <page_init+0x25b>
  102e17:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102e1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102e1e:	c7 44 24 08 a4 74 10 	movl   $0x1074a4,0x8(%esp)
  102e25:	00 
  102e26:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
  102e2d:	00 
  102e2e:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  102e35:	e8 af d5 ff ff       	call   1003e9 <__panic>
  102e3a:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102e3d:	05 00 00 00 40       	add    $0x40000000,%eax
  102e42:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  102e45:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e4c:	e9 69 01 00 00       	jmp    102fba <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102e51:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e54:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e57:	89 d0                	mov    %edx,%eax
  102e59:	c1 e0 02             	shl    $0x2,%eax
  102e5c:	01 d0                	add    %edx,%eax
  102e5e:	c1 e0 02             	shl    $0x2,%eax
  102e61:	01 c8                	add    %ecx,%eax
  102e63:	8b 50 08             	mov    0x8(%eax),%edx
  102e66:	8b 40 04             	mov    0x4(%eax),%eax
  102e69:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102e6c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102e6f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e72:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e75:	89 d0                	mov    %edx,%eax
  102e77:	c1 e0 02             	shl    $0x2,%eax
  102e7a:	01 d0                	add    %edx,%eax
  102e7c:	c1 e0 02             	shl    $0x2,%eax
  102e7f:	01 c8                	add    %ecx,%eax
  102e81:	8b 48 0c             	mov    0xc(%eax),%ecx
  102e84:	8b 58 10             	mov    0x10(%eax),%ebx
  102e87:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102e8a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102e8d:	01 c8                	add    %ecx,%eax
  102e8f:	11 da                	adc    %ebx,%edx
  102e91:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102e94:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  102e97:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e9a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e9d:	89 d0                	mov    %edx,%eax
  102e9f:	c1 e0 02             	shl    $0x2,%eax
  102ea2:	01 d0                	add    %edx,%eax
  102ea4:	c1 e0 02             	shl    $0x2,%eax
  102ea7:	01 c8                	add    %ecx,%eax
  102ea9:	83 c0 14             	add    $0x14,%eax
  102eac:	8b 00                	mov    (%eax),%eax
  102eae:	83 f8 01             	cmp    $0x1,%eax
  102eb1:	0f 85 00 01 00 00    	jne    102fb7 <page_init+0x3d8>
            if (begin < freemem) {
  102eb7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102eba:	ba 00 00 00 00       	mov    $0x0,%edx
  102ebf:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102ec2:	77 17                	ja     102edb <page_init+0x2fc>
  102ec4:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102ec7:	72 05                	jb     102ece <page_init+0x2ef>
  102ec9:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  102ecc:	73 0d                	jae    102edb <page_init+0x2fc>
                begin = freemem;
  102ece:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102ed1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ed4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  102edb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102edf:	72 1d                	jb     102efe <page_init+0x31f>
  102ee1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102ee5:	77 09                	ja     102ef0 <page_init+0x311>
  102ee7:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  102eee:	76 0e                	jbe    102efe <page_init+0x31f>
                end = KMEMSIZE;
  102ef0:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  102ef7:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  102efe:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f01:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f04:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f07:	0f 87 aa 00 00 00    	ja     102fb7 <page_init+0x3d8>
  102f0d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f10:	72 09                	jb     102f1b <page_init+0x33c>
  102f12:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102f15:	0f 83 9c 00 00 00    	jae    102fb7 <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
  102f1b:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  102f22:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102f25:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102f28:	01 d0                	add    %edx,%eax
  102f2a:	48                   	dec    %eax
  102f2b:	89 45 ac             	mov    %eax,-0x54(%ebp)
  102f2e:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102f31:	ba 00 00 00 00       	mov    $0x0,%edx
  102f36:	f7 75 b0             	divl   -0x50(%ebp)
  102f39:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102f3c:	29 d0                	sub    %edx,%eax
  102f3e:	ba 00 00 00 00       	mov    $0x0,%edx
  102f43:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f46:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  102f49:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102f4c:	89 45 a8             	mov    %eax,-0x58(%ebp)
  102f4f:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102f52:	ba 00 00 00 00       	mov    $0x0,%edx
  102f57:	89 c3                	mov    %eax,%ebx
  102f59:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  102f5f:	89 de                	mov    %ebx,%esi
  102f61:	89 d0                	mov    %edx,%eax
  102f63:	83 e0 00             	and    $0x0,%eax
  102f66:	89 c7                	mov    %eax,%edi
  102f68:	89 75 c8             	mov    %esi,-0x38(%ebp)
  102f6b:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  102f6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f71:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f74:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f77:	77 3e                	ja     102fb7 <page_init+0x3d8>
  102f79:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f7c:	72 05                	jb     102f83 <page_init+0x3a4>
  102f7e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102f81:	73 34                	jae    102fb7 <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  102f83:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102f86:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102f89:	2b 45 d0             	sub    -0x30(%ebp),%eax
  102f8c:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  102f8f:	89 c1                	mov    %eax,%ecx
  102f91:	89 d3                	mov    %edx,%ebx
  102f93:	89 c8                	mov    %ecx,%eax
  102f95:	89 da                	mov    %ebx,%edx
  102f97:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102f9b:	c1 ea 0c             	shr    $0xc,%edx
  102f9e:	89 c3                	mov    %eax,%ebx
  102fa0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102fa3:	89 04 24             	mov    %eax,(%esp)
  102fa6:	e8 ae f8 ff ff       	call   102859 <pa2page>
  102fab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102faf:	89 04 24             	mov    %eax,(%esp)
  102fb2:	e8 72 fb ff ff       	call   102b29 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  102fb7:	ff 45 dc             	incl   -0x24(%ebp)
  102fba:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102fbd:	8b 00                	mov    (%eax),%eax
  102fbf:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102fc2:	0f 8c 89 fe ff ff    	jl     102e51 <page_init+0x272>
                }
            }
        }
    }
}
  102fc8:	90                   	nop
  102fc9:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  102fcf:	5b                   	pop    %ebx
  102fd0:	5e                   	pop    %esi
  102fd1:	5f                   	pop    %edi
  102fd2:	5d                   	pop    %ebp
  102fd3:	c3                   	ret    

00102fd4 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  102fd4:	55                   	push   %ebp
  102fd5:	89 e5                	mov    %esp,%ebp
  102fd7:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  102fda:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fdd:	33 45 14             	xor    0x14(%ebp),%eax
  102fe0:	25 ff 0f 00 00       	and    $0xfff,%eax
  102fe5:	85 c0                	test   %eax,%eax
  102fe7:	74 24                	je     10300d <boot_map_segment+0x39>
  102fe9:	c7 44 24 0c d6 74 10 	movl   $0x1074d6,0xc(%esp)
  102ff0:	00 
  102ff1:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  102ff8:	00 
  102ff9:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  103000:	00 
  103001:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103008:	e8 dc d3 ff ff       	call   1003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  10300d:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  103014:	8b 45 0c             	mov    0xc(%ebp),%eax
  103017:	25 ff 0f 00 00       	and    $0xfff,%eax
  10301c:	89 c2                	mov    %eax,%edx
  10301e:	8b 45 10             	mov    0x10(%ebp),%eax
  103021:	01 c2                	add    %eax,%edx
  103023:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103026:	01 d0                	add    %edx,%eax
  103028:	48                   	dec    %eax
  103029:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10302c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10302f:	ba 00 00 00 00       	mov    $0x0,%edx
  103034:	f7 75 f0             	divl   -0x10(%ebp)
  103037:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10303a:	29 d0                	sub    %edx,%eax
  10303c:	c1 e8 0c             	shr    $0xc,%eax
  10303f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  103042:	8b 45 0c             	mov    0xc(%ebp),%eax
  103045:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103048:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10304b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103050:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  103053:	8b 45 14             	mov    0x14(%ebp),%eax
  103056:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103059:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10305c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103061:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103064:	eb 68                	jmp    1030ce <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  103066:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10306d:	00 
  10306e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103071:	89 44 24 04          	mov    %eax,0x4(%esp)
  103075:	8b 45 08             	mov    0x8(%ebp),%eax
  103078:	89 04 24             	mov    %eax,(%esp)
  10307b:	e8 81 01 00 00       	call   103201 <get_pte>
  103080:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  103083:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  103087:	75 24                	jne    1030ad <boot_map_segment+0xd9>
  103089:	c7 44 24 0c 02 75 10 	movl   $0x107502,0xc(%esp)
  103090:	00 
  103091:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103098:	00 
  103099:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  1030a0:	00 
  1030a1:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  1030a8:	e8 3c d3 ff ff       	call   1003e9 <__panic>
        *ptep = pa | PTE_P | perm;
  1030ad:	8b 45 14             	mov    0x14(%ebp),%eax
  1030b0:	0b 45 18             	or     0x18(%ebp),%eax
  1030b3:	83 c8 01             	or     $0x1,%eax
  1030b6:	89 c2                	mov    %eax,%edx
  1030b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030bb:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1030bd:	ff 4d f4             	decl   -0xc(%ebp)
  1030c0:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1030c7:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1030ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1030d2:	75 92                	jne    103066 <boot_map_segment+0x92>
    }
}
  1030d4:	90                   	nop
  1030d5:	c9                   	leave  
  1030d6:	c3                   	ret    

001030d7 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1030d7:	55                   	push   %ebp
  1030d8:	89 e5                	mov    %esp,%ebp
  1030da:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1030dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1030e4:	e8 60 fa ff ff       	call   102b49 <alloc_pages>
  1030e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1030ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1030f0:	75 1c                	jne    10310e <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  1030f2:	c7 44 24 08 0f 75 10 	movl   $0x10750f,0x8(%esp)
  1030f9:	00 
  1030fa:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
  103101:	00 
  103102:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103109:	e8 db d2 ff ff       	call   1003e9 <__panic>
    }
    return page2kva(p);
  10310e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103111:	89 04 24             	mov    %eax,(%esp)
  103114:	e8 8f f7 ff ff       	call   1028a8 <page2kva>
}
  103119:	c9                   	leave  
  10311a:	c3                   	ret    

0010311b <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  10311b:	55                   	push   %ebp
  10311c:	89 e5                	mov    %esp,%ebp
  10311e:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  103121:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103126:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103129:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  103130:	77 23                	ja     103155 <pmm_init+0x3a>
  103132:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103135:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103139:	c7 44 24 08 a4 74 10 	movl   $0x1074a4,0x8(%esp)
  103140:	00 
  103141:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  103148:	00 
  103149:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103150:	e8 94 d2 ff ff       	call   1003e9 <__panic>
  103155:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103158:	05 00 00 00 40       	add    $0x40000000,%eax
  10315d:	a3 14 df 11 00       	mov    %eax,0x11df14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  103162:	e8 8e f9 ff ff       	call   102af5 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  103167:	e8 73 fa ff ff       	call   102bdf <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  10316c:	e8 4f 02 00 00       	call   1033c0 <check_alloc_page>

    check_pgdir();
  103171:	e8 69 02 00 00       	call   1033df <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  103176:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10317b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10317e:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103185:	77 23                	ja     1031aa <pmm_init+0x8f>
  103187:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10318a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10318e:	c7 44 24 08 a4 74 10 	movl   $0x1074a4,0x8(%esp)
  103195:	00 
  103196:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
  10319d:	00 
  10319e:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  1031a5:	e8 3f d2 ff ff       	call   1003e9 <__panic>
  1031aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031ad:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  1031b3:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1031b8:	05 ac 0f 00 00       	add    $0xfac,%eax
  1031bd:	83 ca 03             	or     $0x3,%edx
  1031c0:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1031c2:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1031c7:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1031ce:	00 
  1031cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1031d6:	00 
  1031d7:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1031de:	38 
  1031df:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1031e6:	c0 
  1031e7:	89 04 24             	mov    %eax,(%esp)
  1031ea:	e8 e5 fd ff ff       	call   102fd4 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1031ef:	e8 18 f8 ff ff       	call   102a0c <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1031f4:	e8 82 08 00 00       	call   103a7b <check_boot_pgdir>

    print_pgdir();
  1031f9:	e8 fb 0c 00 00       	call   103ef9 <print_pgdir>

}
  1031fe:	90                   	nop
  1031ff:	c9                   	leave  
  103200:	c3                   	ret    

00103201 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  103201:	55                   	push   %ebp
  103202:	89 e5                	mov    %esp,%ebp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
  103204:	90                   	nop
  103205:	5d                   	pop    %ebp
  103206:	c3                   	ret    

00103207 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  103207:	55                   	push   %ebp
  103208:	89 e5                	mov    %esp,%ebp
  10320a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10320d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103214:	00 
  103215:	8b 45 0c             	mov    0xc(%ebp),%eax
  103218:	89 44 24 04          	mov    %eax,0x4(%esp)
  10321c:	8b 45 08             	mov    0x8(%ebp),%eax
  10321f:	89 04 24             	mov    %eax,(%esp)
  103222:	e8 da ff ff ff       	call   103201 <get_pte>
  103227:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  10322a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10322e:	74 08                	je     103238 <get_page+0x31>
        *ptep_store = ptep;
  103230:	8b 45 10             	mov    0x10(%ebp),%eax
  103233:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103236:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  103238:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10323c:	74 1b                	je     103259 <get_page+0x52>
  10323e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103241:	8b 00                	mov    (%eax),%eax
  103243:	83 e0 01             	and    $0x1,%eax
  103246:	85 c0                	test   %eax,%eax
  103248:	74 0f                	je     103259 <get_page+0x52>
        return pte2page(*ptep);
  10324a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10324d:	8b 00                	mov    (%eax),%eax
  10324f:	89 04 24             	mov    %eax,(%esp)
  103252:	e8 a5 f6 ff ff       	call   1028fc <pte2page>
  103257:	eb 05                	jmp    10325e <get_page+0x57>
    }
    return NULL;
  103259:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10325e:	c9                   	leave  
  10325f:	c3                   	ret    

00103260 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  103260:	55                   	push   %ebp
  103261:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
  103263:	90                   	nop
  103264:	5d                   	pop    %ebp
  103265:	c3                   	ret    

00103266 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  103266:	55                   	push   %ebp
  103267:	89 e5                	mov    %esp,%ebp
  103269:	83 ec 1c             	sub    $0x1c,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10326c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103273:	00 
  103274:	8b 45 0c             	mov    0xc(%ebp),%eax
  103277:	89 44 24 04          	mov    %eax,0x4(%esp)
  10327b:	8b 45 08             	mov    0x8(%ebp),%eax
  10327e:	89 04 24             	mov    %eax,(%esp)
  103281:	e8 7b ff ff ff       	call   103201 <get_pte>
  103286:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (ptep != NULL) {
  103289:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  10328d:	74 19                	je     1032a8 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  10328f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103292:	89 44 24 08          	mov    %eax,0x8(%esp)
  103296:	8b 45 0c             	mov    0xc(%ebp),%eax
  103299:	89 44 24 04          	mov    %eax,0x4(%esp)
  10329d:	8b 45 08             	mov    0x8(%ebp),%eax
  1032a0:	89 04 24             	mov    %eax,(%esp)
  1032a3:	e8 b8 ff ff ff       	call   103260 <page_remove_pte>
    }
}
  1032a8:	90                   	nop
  1032a9:	c9                   	leave  
  1032aa:	c3                   	ret    

001032ab <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  1032ab:	55                   	push   %ebp
  1032ac:	89 e5                	mov    %esp,%ebp
  1032ae:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  1032b1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1032b8:	00 
  1032b9:	8b 45 10             	mov    0x10(%ebp),%eax
  1032bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1032c3:	89 04 24             	mov    %eax,(%esp)
  1032c6:	e8 36 ff ff ff       	call   103201 <get_pte>
  1032cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1032ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1032d2:	75 0a                	jne    1032de <page_insert+0x33>
        return -E_NO_MEM;
  1032d4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1032d9:	e9 84 00 00 00       	jmp    103362 <page_insert+0xb7>
    }
    page_ref_inc(page);
  1032de:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032e1:	89 04 24             	mov    %eax,(%esp)
  1032e4:	e8 73 f6 ff ff       	call   10295c <page_ref_inc>
    if (*ptep & PTE_P) {
  1032e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032ec:	8b 00                	mov    (%eax),%eax
  1032ee:	83 e0 01             	and    $0x1,%eax
  1032f1:	85 c0                	test   %eax,%eax
  1032f3:	74 3e                	je     103333 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  1032f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032f8:	8b 00                	mov    (%eax),%eax
  1032fa:	89 04 24             	mov    %eax,(%esp)
  1032fd:	e8 fa f5 ff ff       	call   1028fc <pte2page>
  103302:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  103305:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103308:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10330b:	75 0d                	jne    10331a <page_insert+0x6f>
            page_ref_dec(page);
  10330d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103310:	89 04 24             	mov    %eax,(%esp)
  103313:	e8 5b f6 ff ff       	call   102973 <page_ref_dec>
  103318:	eb 19                	jmp    103333 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  10331a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10331d:	89 44 24 08          	mov    %eax,0x8(%esp)
  103321:	8b 45 10             	mov    0x10(%ebp),%eax
  103324:	89 44 24 04          	mov    %eax,0x4(%esp)
  103328:	8b 45 08             	mov    0x8(%ebp),%eax
  10332b:	89 04 24             	mov    %eax,(%esp)
  10332e:	e8 2d ff ff ff       	call   103260 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  103333:	8b 45 0c             	mov    0xc(%ebp),%eax
  103336:	89 04 24             	mov    %eax,(%esp)
  103339:	e8 05 f5 ff ff       	call   102843 <page2pa>
  10333e:	0b 45 14             	or     0x14(%ebp),%eax
  103341:	83 c8 01             	or     $0x1,%eax
  103344:	89 c2                	mov    %eax,%edx
  103346:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103349:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  10334b:	8b 45 10             	mov    0x10(%ebp),%eax
  10334e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103352:	8b 45 08             	mov    0x8(%ebp),%eax
  103355:	89 04 24             	mov    %eax,(%esp)
  103358:	e8 07 00 00 00       	call   103364 <tlb_invalidate>
    return 0;
  10335d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103362:	c9                   	leave  
  103363:	c3                   	ret    

00103364 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  103364:	55                   	push   %ebp
  103365:	89 e5                	mov    %esp,%ebp
  103367:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  10336a:	0f 20 d8             	mov    %cr3,%eax
  10336d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  103370:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  103373:	8b 45 08             	mov    0x8(%ebp),%eax
  103376:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103379:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  103380:	77 23                	ja     1033a5 <tlb_invalidate+0x41>
  103382:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103385:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103389:	c7 44 24 08 a4 74 10 	movl   $0x1074a4,0x8(%esp)
  103390:	00 
  103391:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
  103398:	00 
  103399:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  1033a0:	e8 44 d0 ff ff       	call   1003e9 <__panic>
  1033a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033a8:	05 00 00 00 40       	add    $0x40000000,%eax
  1033ad:	39 d0                	cmp    %edx,%eax
  1033af:	75 0c                	jne    1033bd <tlb_invalidate+0x59>
        invlpg((void *)la);
  1033b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  1033b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1033ba:	0f 01 38             	invlpg (%eax)
    }
}
  1033bd:	90                   	nop
  1033be:	c9                   	leave  
  1033bf:	c3                   	ret    

001033c0 <check_alloc_page>:

static void
check_alloc_page(void) {
  1033c0:	55                   	push   %ebp
  1033c1:	89 e5                	mov    %esp,%ebp
  1033c3:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1033c6:	a1 10 df 11 00       	mov    0x11df10,%eax
  1033cb:	8b 40 18             	mov    0x18(%eax),%eax
  1033ce:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1033d0:	c7 04 24 28 75 10 00 	movl   $0x107528,(%esp)
  1033d7:	e8 b6 ce ff ff       	call   100292 <cprintf>
}
  1033dc:	90                   	nop
  1033dd:	c9                   	leave  
  1033de:	c3                   	ret    

001033df <check_pgdir>:

static void
check_pgdir(void) {
  1033df:	55                   	push   %ebp
  1033e0:	89 e5                	mov    %esp,%ebp
  1033e2:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1033e5:	a1 80 de 11 00       	mov    0x11de80,%eax
  1033ea:	3d 00 80 03 00       	cmp    $0x38000,%eax
  1033ef:	76 24                	jbe    103415 <check_pgdir+0x36>
  1033f1:	c7 44 24 0c 47 75 10 	movl   $0x107547,0xc(%esp)
  1033f8:	00 
  1033f9:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103400:	00 
  103401:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
  103408:	00 
  103409:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103410:	e8 d4 cf ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  103415:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10341a:	85 c0                	test   %eax,%eax
  10341c:	74 0e                	je     10342c <check_pgdir+0x4d>
  10341e:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103423:	25 ff 0f 00 00       	and    $0xfff,%eax
  103428:	85 c0                	test   %eax,%eax
  10342a:	74 24                	je     103450 <check_pgdir+0x71>
  10342c:	c7 44 24 0c 64 75 10 	movl   $0x107564,0xc(%esp)
  103433:	00 
  103434:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  10343b:	00 
  10343c:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
  103443:	00 
  103444:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  10344b:	e8 99 cf ff ff       	call   1003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  103450:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103455:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10345c:	00 
  10345d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103464:	00 
  103465:	89 04 24             	mov    %eax,(%esp)
  103468:	e8 9a fd ff ff       	call   103207 <get_page>
  10346d:	85 c0                	test   %eax,%eax
  10346f:	74 24                	je     103495 <check_pgdir+0xb6>
  103471:	c7 44 24 0c 9c 75 10 	movl   $0x10759c,0xc(%esp)
  103478:	00 
  103479:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103480:	00 
  103481:	c7 44 24 04 d4 01 00 	movl   $0x1d4,0x4(%esp)
  103488:	00 
  103489:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103490:	e8 54 cf ff ff       	call   1003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  103495:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10349c:	e8 a8 f6 ff ff       	call   102b49 <alloc_pages>
  1034a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1034a4:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1034a9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1034b0:	00 
  1034b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1034b8:	00 
  1034b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1034bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  1034c0:	89 04 24             	mov    %eax,(%esp)
  1034c3:	e8 e3 fd ff ff       	call   1032ab <page_insert>
  1034c8:	85 c0                	test   %eax,%eax
  1034ca:	74 24                	je     1034f0 <check_pgdir+0x111>
  1034cc:	c7 44 24 0c c4 75 10 	movl   $0x1075c4,0xc(%esp)
  1034d3:	00 
  1034d4:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  1034db:	00 
  1034dc:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
  1034e3:	00 
  1034e4:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  1034eb:	e8 f9 ce ff ff       	call   1003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  1034f0:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1034f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1034fc:	00 
  1034fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103504:	00 
  103505:	89 04 24             	mov    %eax,(%esp)
  103508:	e8 f4 fc ff ff       	call   103201 <get_pte>
  10350d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103510:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103514:	75 24                	jne    10353a <check_pgdir+0x15b>
  103516:	c7 44 24 0c f0 75 10 	movl   $0x1075f0,0xc(%esp)
  10351d:	00 
  10351e:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103525:	00 
  103526:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  10352d:	00 
  10352e:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103535:	e8 af ce ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  10353a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10353d:	8b 00                	mov    (%eax),%eax
  10353f:	89 04 24             	mov    %eax,(%esp)
  103542:	e8 b5 f3 ff ff       	call   1028fc <pte2page>
  103547:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10354a:	74 24                	je     103570 <check_pgdir+0x191>
  10354c:	c7 44 24 0c 1d 76 10 	movl   $0x10761d,0xc(%esp)
  103553:	00 
  103554:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  10355b:	00 
  10355c:	c7 44 24 04 dc 01 00 	movl   $0x1dc,0x4(%esp)
  103563:	00 
  103564:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  10356b:	e8 79 ce ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 1);
  103570:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103573:	89 04 24             	mov    %eax,(%esp)
  103576:	e8 d7 f3 ff ff       	call   102952 <page_ref>
  10357b:	83 f8 01             	cmp    $0x1,%eax
  10357e:	74 24                	je     1035a4 <check_pgdir+0x1c5>
  103580:	c7 44 24 0c 33 76 10 	movl   $0x107633,0xc(%esp)
  103587:	00 
  103588:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  10358f:	00 
  103590:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
  103597:	00 
  103598:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  10359f:	e8 45 ce ff ff       	call   1003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1035a4:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1035a9:	8b 00                	mov    (%eax),%eax
  1035ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1035b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1035b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1035b6:	c1 e8 0c             	shr    $0xc,%eax
  1035b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1035bc:	a1 80 de 11 00       	mov    0x11de80,%eax
  1035c1:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1035c4:	72 23                	jb     1035e9 <check_pgdir+0x20a>
  1035c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1035c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1035cd:	c7 44 24 08 00 74 10 	movl   $0x107400,0x8(%esp)
  1035d4:	00 
  1035d5:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
  1035dc:	00 
  1035dd:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  1035e4:	e8 00 ce ff ff       	call   1003e9 <__panic>
  1035e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1035ec:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1035f1:	83 c0 04             	add    $0x4,%eax
  1035f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1035f7:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1035fc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103603:	00 
  103604:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10360b:	00 
  10360c:	89 04 24             	mov    %eax,(%esp)
  10360f:	e8 ed fb ff ff       	call   103201 <get_pte>
  103614:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103617:	74 24                	je     10363d <check_pgdir+0x25e>
  103619:	c7 44 24 0c 48 76 10 	movl   $0x107648,0xc(%esp)
  103620:	00 
  103621:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103628:	00 
  103629:	c7 44 24 04 e0 01 00 	movl   $0x1e0,0x4(%esp)
  103630:	00 
  103631:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103638:	e8 ac cd ff ff       	call   1003e9 <__panic>

    p2 = alloc_page();
  10363d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103644:	e8 00 f5 ff ff       	call   102b49 <alloc_pages>
  103649:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  10364c:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103651:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  103658:	00 
  103659:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103660:	00 
  103661:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103664:	89 54 24 04          	mov    %edx,0x4(%esp)
  103668:	89 04 24             	mov    %eax,(%esp)
  10366b:	e8 3b fc ff ff       	call   1032ab <page_insert>
  103670:	85 c0                	test   %eax,%eax
  103672:	74 24                	je     103698 <check_pgdir+0x2b9>
  103674:	c7 44 24 0c 70 76 10 	movl   $0x107670,0xc(%esp)
  10367b:	00 
  10367c:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103683:	00 
  103684:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
  10368b:	00 
  10368c:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103693:	e8 51 cd ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103698:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10369d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1036a4:	00 
  1036a5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1036ac:	00 
  1036ad:	89 04 24             	mov    %eax,(%esp)
  1036b0:	e8 4c fb ff ff       	call   103201 <get_pte>
  1036b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1036bc:	75 24                	jne    1036e2 <check_pgdir+0x303>
  1036be:	c7 44 24 0c a8 76 10 	movl   $0x1076a8,0xc(%esp)
  1036c5:	00 
  1036c6:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  1036cd:	00 
  1036ce:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
  1036d5:	00 
  1036d6:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  1036dd:	e8 07 cd ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_U);
  1036e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1036e5:	8b 00                	mov    (%eax),%eax
  1036e7:	83 e0 04             	and    $0x4,%eax
  1036ea:	85 c0                	test   %eax,%eax
  1036ec:	75 24                	jne    103712 <check_pgdir+0x333>
  1036ee:	c7 44 24 0c d8 76 10 	movl   $0x1076d8,0xc(%esp)
  1036f5:	00 
  1036f6:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  1036fd:	00 
  1036fe:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  103705:	00 
  103706:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  10370d:	e8 d7 cc ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_W);
  103712:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103715:	8b 00                	mov    (%eax),%eax
  103717:	83 e0 02             	and    $0x2,%eax
  10371a:	85 c0                	test   %eax,%eax
  10371c:	75 24                	jne    103742 <check_pgdir+0x363>
  10371e:	c7 44 24 0c e6 76 10 	movl   $0x1076e6,0xc(%esp)
  103725:	00 
  103726:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  10372d:	00 
  10372e:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  103735:	00 
  103736:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  10373d:	e8 a7 cc ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  103742:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103747:	8b 00                	mov    (%eax),%eax
  103749:	83 e0 04             	and    $0x4,%eax
  10374c:	85 c0                	test   %eax,%eax
  10374e:	75 24                	jne    103774 <check_pgdir+0x395>
  103750:	c7 44 24 0c f4 76 10 	movl   $0x1076f4,0xc(%esp)
  103757:	00 
  103758:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  10375f:	00 
  103760:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
  103767:	00 
  103768:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  10376f:	e8 75 cc ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 1);
  103774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103777:	89 04 24             	mov    %eax,(%esp)
  10377a:	e8 d3 f1 ff ff       	call   102952 <page_ref>
  10377f:	83 f8 01             	cmp    $0x1,%eax
  103782:	74 24                	je     1037a8 <check_pgdir+0x3c9>
  103784:	c7 44 24 0c 0a 77 10 	movl   $0x10770a,0xc(%esp)
  10378b:	00 
  10378c:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103793:	00 
  103794:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
  10379b:	00 
  10379c:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  1037a3:	e8 41 cc ff ff       	call   1003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  1037a8:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1037ad:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1037b4:	00 
  1037b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1037bc:	00 
  1037bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1037c0:	89 54 24 04          	mov    %edx,0x4(%esp)
  1037c4:	89 04 24             	mov    %eax,(%esp)
  1037c7:	e8 df fa ff ff       	call   1032ab <page_insert>
  1037cc:	85 c0                	test   %eax,%eax
  1037ce:	74 24                	je     1037f4 <check_pgdir+0x415>
  1037d0:	c7 44 24 0c 1c 77 10 	movl   $0x10771c,0xc(%esp)
  1037d7:	00 
  1037d8:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  1037df:	00 
  1037e0:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  1037e7:	00 
  1037e8:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  1037ef:	e8 f5 cb ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 2);
  1037f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1037f7:	89 04 24             	mov    %eax,(%esp)
  1037fa:	e8 53 f1 ff ff       	call   102952 <page_ref>
  1037ff:	83 f8 02             	cmp    $0x2,%eax
  103802:	74 24                	je     103828 <check_pgdir+0x449>
  103804:	c7 44 24 0c 48 77 10 	movl   $0x107748,0xc(%esp)
  10380b:	00 
  10380c:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103813:	00 
  103814:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  10381b:	00 
  10381c:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103823:	e8 c1 cb ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103828:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10382b:	89 04 24             	mov    %eax,(%esp)
  10382e:	e8 1f f1 ff ff       	call   102952 <page_ref>
  103833:	85 c0                	test   %eax,%eax
  103835:	74 24                	je     10385b <check_pgdir+0x47c>
  103837:	c7 44 24 0c 5a 77 10 	movl   $0x10775a,0xc(%esp)
  10383e:	00 
  10383f:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103846:	00 
  103847:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  10384e:	00 
  10384f:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103856:	e8 8e cb ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  10385b:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103860:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103867:	00 
  103868:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10386f:	00 
  103870:	89 04 24             	mov    %eax,(%esp)
  103873:	e8 89 f9 ff ff       	call   103201 <get_pte>
  103878:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10387b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10387f:	75 24                	jne    1038a5 <check_pgdir+0x4c6>
  103881:	c7 44 24 0c a8 76 10 	movl   $0x1076a8,0xc(%esp)
  103888:	00 
  103889:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103890:	00 
  103891:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  103898:	00 
  103899:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  1038a0:	e8 44 cb ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  1038a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038a8:	8b 00                	mov    (%eax),%eax
  1038aa:	89 04 24             	mov    %eax,(%esp)
  1038ad:	e8 4a f0 ff ff       	call   1028fc <pte2page>
  1038b2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1038b5:	74 24                	je     1038db <check_pgdir+0x4fc>
  1038b7:	c7 44 24 0c 1d 76 10 	movl   $0x10761d,0xc(%esp)
  1038be:	00 
  1038bf:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  1038c6:	00 
  1038c7:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  1038ce:	00 
  1038cf:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  1038d6:	e8 0e cb ff ff       	call   1003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
  1038db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038de:	8b 00                	mov    (%eax),%eax
  1038e0:	83 e0 04             	and    $0x4,%eax
  1038e3:	85 c0                	test   %eax,%eax
  1038e5:	74 24                	je     10390b <check_pgdir+0x52c>
  1038e7:	c7 44 24 0c 6c 77 10 	movl   $0x10776c,0xc(%esp)
  1038ee:	00 
  1038ef:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  1038f6:	00 
  1038f7:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  1038fe:	00 
  1038ff:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103906:	e8 de ca ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
  10390b:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103910:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103917:	00 
  103918:	89 04 24             	mov    %eax,(%esp)
  10391b:	e8 46 f9 ff ff       	call   103266 <page_remove>
    assert(page_ref(p1) == 1);
  103920:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103923:	89 04 24             	mov    %eax,(%esp)
  103926:	e8 27 f0 ff ff       	call   102952 <page_ref>
  10392b:	83 f8 01             	cmp    $0x1,%eax
  10392e:	74 24                	je     103954 <check_pgdir+0x575>
  103930:	c7 44 24 0c 33 76 10 	movl   $0x107633,0xc(%esp)
  103937:	00 
  103938:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  10393f:	00 
  103940:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  103947:	00 
  103948:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  10394f:	e8 95 ca ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103954:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103957:	89 04 24             	mov    %eax,(%esp)
  10395a:	e8 f3 ef ff ff       	call   102952 <page_ref>
  10395f:	85 c0                	test   %eax,%eax
  103961:	74 24                	je     103987 <check_pgdir+0x5a8>
  103963:	c7 44 24 0c 5a 77 10 	movl   $0x10775a,0xc(%esp)
  10396a:	00 
  10396b:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103972:	00 
  103973:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
  10397a:	00 
  10397b:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103982:	e8 62 ca ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103987:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10398c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103993:	00 
  103994:	89 04 24             	mov    %eax,(%esp)
  103997:	e8 ca f8 ff ff       	call   103266 <page_remove>
    assert(page_ref(p1) == 0);
  10399c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10399f:	89 04 24             	mov    %eax,(%esp)
  1039a2:	e8 ab ef ff ff       	call   102952 <page_ref>
  1039a7:	85 c0                	test   %eax,%eax
  1039a9:	74 24                	je     1039cf <check_pgdir+0x5f0>
  1039ab:	c7 44 24 0c 81 77 10 	movl   $0x107781,0xc(%esp)
  1039b2:	00 
  1039b3:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  1039ba:	00 
  1039bb:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  1039c2:	00 
  1039c3:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  1039ca:	e8 1a ca ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  1039cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1039d2:	89 04 24             	mov    %eax,(%esp)
  1039d5:	e8 78 ef ff ff       	call   102952 <page_ref>
  1039da:	85 c0                	test   %eax,%eax
  1039dc:	74 24                	je     103a02 <check_pgdir+0x623>
  1039de:	c7 44 24 0c 5a 77 10 	movl   $0x10775a,0xc(%esp)
  1039e5:	00 
  1039e6:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  1039ed:	00 
  1039ee:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  1039f5:	00 
  1039f6:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  1039fd:	e8 e7 c9 ff ff       	call   1003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103a02:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103a07:	8b 00                	mov    (%eax),%eax
  103a09:	89 04 24             	mov    %eax,(%esp)
  103a0c:	e8 29 ef ff ff       	call   10293a <pde2page>
  103a11:	89 04 24             	mov    %eax,(%esp)
  103a14:	e8 39 ef ff ff       	call   102952 <page_ref>
  103a19:	83 f8 01             	cmp    $0x1,%eax
  103a1c:	74 24                	je     103a42 <check_pgdir+0x663>
  103a1e:	c7 44 24 0c 94 77 10 	movl   $0x107794,0xc(%esp)
  103a25:	00 
  103a26:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103a2d:	00 
  103a2e:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  103a35:	00 
  103a36:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103a3d:	e8 a7 c9 ff ff       	call   1003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103a42:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103a47:	8b 00                	mov    (%eax),%eax
  103a49:	89 04 24             	mov    %eax,(%esp)
  103a4c:	e8 e9 ee ff ff       	call   10293a <pde2page>
  103a51:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103a58:	00 
  103a59:	89 04 24             	mov    %eax,(%esp)
  103a5c:	e8 20 f1 ff ff       	call   102b81 <free_pages>
    boot_pgdir[0] = 0;
  103a61:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103a66:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103a6c:	c7 04 24 bb 77 10 00 	movl   $0x1077bb,(%esp)
  103a73:	e8 1a c8 ff ff       	call   100292 <cprintf>
}
  103a78:	90                   	nop
  103a79:	c9                   	leave  
  103a7a:	c3                   	ret    

00103a7b <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103a7b:	55                   	push   %ebp
  103a7c:	89 e5                	mov    %esp,%ebp
  103a7e:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103a81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103a88:	e9 ca 00 00 00       	jmp    103b57 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103a93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a96:	c1 e8 0c             	shr    $0xc,%eax
  103a99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103a9c:	a1 80 de 11 00       	mov    0x11de80,%eax
  103aa1:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103aa4:	72 23                	jb     103ac9 <check_boot_pgdir+0x4e>
  103aa6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103aa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103aad:	c7 44 24 08 00 74 10 	movl   $0x107400,0x8(%esp)
  103ab4:	00 
  103ab5:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  103abc:	00 
  103abd:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103ac4:	e8 20 c9 ff ff       	call   1003e9 <__panic>
  103ac9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103acc:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103ad1:	89 c2                	mov    %eax,%edx
  103ad3:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103ad8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103adf:	00 
  103ae0:	89 54 24 04          	mov    %edx,0x4(%esp)
  103ae4:	89 04 24             	mov    %eax,(%esp)
  103ae7:	e8 15 f7 ff ff       	call   103201 <get_pte>
  103aec:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103aef:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103af3:	75 24                	jne    103b19 <check_boot_pgdir+0x9e>
  103af5:	c7 44 24 0c d8 77 10 	movl   $0x1077d8,0xc(%esp)
  103afc:	00 
  103afd:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103b04:	00 
  103b05:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  103b0c:	00 
  103b0d:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103b14:	e8 d0 c8 ff ff       	call   1003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103b19:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103b1c:	8b 00                	mov    (%eax),%eax
  103b1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b23:	89 c2                	mov    %eax,%edx
  103b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b28:	39 c2                	cmp    %eax,%edx
  103b2a:	74 24                	je     103b50 <check_boot_pgdir+0xd5>
  103b2c:	c7 44 24 0c 15 78 10 	movl   $0x107815,0xc(%esp)
  103b33:	00 
  103b34:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103b3b:	00 
  103b3c:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  103b43:	00 
  103b44:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103b4b:	e8 99 c8 ff ff       	call   1003e9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  103b50:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103b57:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103b5a:	a1 80 de 11 00       	mov    0x11de80,%eax
  103b5f:	39 c2                	cmp    %eax,%edx
  103b61:	0f 82 26 ff ff ff    	jb     103a8d <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103b67:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103b6c:	05 ac 0f 00 00       	add    $0xfac,%eax
  103b71:	8b 00                	mov    (%eax),%eax
  103b73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b78:	89 c2                	mov    %eax,%edx
  103b7a:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103b7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103b82:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103b89:	77 23                	ja     103bae <check_boot_pgdir+0x133>
  103b8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103b8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103b92:	c7 44 24 08 a4 74 10 	movl   $0x1074a4,0x8(%esp)
  103b99:	00 
  103b9a:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  103ba1:	00 
  103ba2:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103ba9:	e8 3b c8 ff ff       	call   1003e9 <__panic>
  103bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103bb1:	05 00 00 00 40       	add    $0x40000000,%eax
  103bb6:	39 d0                	cmp    %edx,%eax
  103bb8:	74 24                	je     103bde <check_boot_pgdir+0x163>
  103bba:	c7 44 24 0c 2c 78 10 	movl   $0x10782c,0xc(%esp)
  103bc1:	00 
  103bc2:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103bc9:	00 
  103bca:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  103bd1:	00 
  103bd2:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103bd9:	e8 0b c8 ff ff       	call   1003e9 <__panic>

    assert(boot_pgdir[0] == 0);
  103bde:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103be3:	8b 00                	mov    (%eax),%eax
  103be5:	85 c0                	test   %eax,%eax
  103be7:	74 24                	je     103c0d <check_boot_pgdir+0x192>
  103be9:	c7 44 24 0c 60 78 10 	movl   $0x107860,0xc(%esp)
  103bf0:	00 
  103bf1:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103bf8:	00 
  103bf9:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  103c00:	00 
  103c01:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103c08:	e8 dc c7 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    p = alloc_page();
  103c0d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103c14:	e8 30 ef ff ff       	call   102b49 <alloc_pages>
  103c19:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103c1c:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103c21:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103c28:	00 
  103c29:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103c30:	00 
  103c31:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103c34:	89 54 24 04          	mov    %edx,0x4(%esp)
  103c38:	89 04 24             	mov    %eax,(%esp)
  103c3b:	e8 6b f6 ff ff       	call   1032ab <page_insert>
  103c40:	85 c0                	test   %eax,%eax
  103c42:	74 24                	je     103c68 <check_boot_pgdir+0x1ed>
  103c44:	c7 44 24 0c 74 78 10 	movl   $0x107874,0xc(%esp)
  103c4b:	00 
  103c4c:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103c53:	00 
  103c54:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  103c5b:	00 
  103c5c:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103c63:	e8 81 c7 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 1);
  103c68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c6b:	89 04 24             	mov    %eax,(%esp)
  103c6e:	e8 df ec ff ff       	call   102952 <page_ref>
  103c73:	83 f8 01             	cmp    $0x1,%eax
  103c76:	74 24                	je     103c9c <check_boot_pgdir+0x221>
  103c78:	c7 44 24 0c a2 78 10 	movl   $0x1078a2,0xc(%esp)
  103c7f:	00 
  103c80:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103c87:	00 
  103c88:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  103c8f:	00 
  103c90:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103c97:	e8 4d c7 ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103c9c:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103ca1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103ca8:	00 
  103ca9:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  103cb0:	00 
  103cb1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103cb4:	89 54 24 04          	mov    %edx,0x4(%esp)
  103cb8:	89 04 24             	mov    %eax,(%esp)
  103cbb:	e8 eb f5 ff ff       	call   1032ab <page_insert>
  103cc0:	85 c0                	test   %eax,%eax
  103cc2:	74 24                	je     103ce8 <check_boot_pgdir+0x26d>
  103cc4:	c7 44 24 0c b4 78 10 	movl   $0x1078b4,0xc(%esp)
  103ccb:	00 
  103ccc:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103cd3:	00 
  103cd4:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
  103cdb:	00 
  103cdc:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103ce3:	e8 01 c7 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 2);
  103ce8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103ceb:	89 04 24             	mov    %eax,(%esp)
  103cee:	e8 5f ec ff ff       	call   102952 <page_ref>
  103cf3:	83 f8 02             	cmp    $0x2,%eax
  103cf6:	74 24                	je     103d1c <check_boot_pgdir+0x2a1>
  103cf8:	c7 44 24 0c eb 78 10 	movl   $0x1078eb,0xc(%esp)
  103cff:	00 
  103d00:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103d07:	00 
  103d08:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
  103d0f:	00 
  103d10:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103d17:	e8 cd c6 ff ff       	call   1003e9 <__panic>

    const char *str = "ucore: Hello world!!";
  103d1c:	c7 45 e8 fc 78 10 00 	movl   $0x1078fc,-0x18(%ebp)
    strcpy((void *)0x100, str);
  103d23:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103d26:	89 44 24 04          	mov    %eax,0x4(%esp)
  103d2a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103d31:	e8 bd 24 00 00       	call   1061f3 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103d36:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  103d3d:	00 
  103d3e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103d45:	e8 20 25 00 00       	call   10626a <strcmp>
  103d4a:	85 c0                	test   %eax,%eax
  103d4c:	74 24                	je     103d72 <check_boot_pgdir+0x2f7>
  103d4e:	c7 44 24 0c 14 79 10 	movl   $0x107914,0xc(%esp)
  103d55:	00 
  103d56:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103d5d:	00 
  103d5e:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
  103d65:	00 
  103d66:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103d6d:	e8 77 c6 ff ff       	call   1003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  103d72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103d75:	89 04 24             	mov    %eax,(%esp)
  103d78:	e8 2b eb ff ff       	call   1028a8 <page2kva>
  103d7d:	05 00 01 00 00       	add    $0x100,%eax
  103d82:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  103d85:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103d8c:	e8 0c 24 00 00       	call   10619d <strlen>
  103d91:	85 c0                	test   %eax,%eax
  103d93:	74 24                	je     103db9 <check_boot_pgdir+0x33e>
  103d95:	c7 44 24 0c 4c 79 10 	movl   $0x10794c,0xc(%esp)
  103d9c:	00 
  103d9d:	c7 44 24 08 ed 74 10 	movl   $0x1074ed,0x8(%esp)
  103da4:	00 
  103da5:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  103dac:	00 
  103dad:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  103db4:	e8 30 c6 ff ff       	call   1003e9 <__panic>

    free_page(p);
  103db9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103dc0:	00 
  103dc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103dc4:	89 04 24             	mov    %eax,(%esp)
  103dc7:	e8 b5 ed ff ff       	call   102b81 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  103dcc:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103dd1:	8b 00                	mov    (%eax),%eax
  103dd3:	89 04 24             	mov    %eax,(%esp)
  103dd6:	e8 5f eb ff ff       	call   10293a <pde2page>
  103ddb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103de2:	00 
  103de3:	89 04 24             	mov    %eax,(%esp)
  103de6:	e8 96 ed ff ff       	call   102b81 <free_pages>
    boot_pgdir[0] = 0;
  103deb:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103df0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  103df6:	c7 04 24 70 79 10 00 	movl   $0x107970,(%esp)
  103dfd:	e8 90 c4 ff ff       	call   100292 <cprintf>
}
  103e02:	90                   	nop
  103e03:	c9                   	leave  
  103e04:	c3                   	ret    

00103e05 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  103e05:	55                   	push   %ebp
  103e06:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  103e08:	8b 45 08             	mov    0x8(%ebp),%eax
  103e0b:	83 e0 04             	and    $0x4,%eax
  103e0e:	85 c0                	test   %eax,%eax
  103e10:	74 04                	je     103e16 <perm2str+0x11>
  103e12:	b0 75                	mov    $0x75,%al
  103e14:	eb 02                	jmp    103e18 <perm2str+0x13>
  103e16:	b0 2d                	mov    $0x2d,%al
  103e18:	a2 08 df 11 00       	mov    %al,0x11df08
    str[1] = 'r';
  103e1d:	c6 05 09 df 11 00 72 	movb   $0x72,0x11df09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  103e24:	8b 45 08             	mov    0x8(%ebp),%eax
  103e27:	83 e0 02             	and    $0x2,%eax
  103e2a:	85 c0                	test   %eax,%eax
  103e2c:	74 04                	je     103e32 <perm2str+0x2d>
  103e2e:	b0 77                	mov    $0x77,%al
  103e30:	eb 02                	jmp    103e34 <perm2str+0x2f>
  103e32:	b0 2d                	mov    $0x2d,%al
  103e34:	a2 0a df 11 00       	mov    %al,0x11df0a
    str[3] = '\0';
  103e39:	c6 05 0b df 11 00 00 	movb   $0x0,0x11df0b
    return str;
  103e40:	b8 08 df 11 00       	mov    $0x11df08,%eax
}
  103e45:	5d                   	pop    %ebp
  103e46:	c3                   	ret    

00103e47 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  103e47:	55                   	push   %ebp
  103e48:	89 e5                	mov    %esp,%ebp
  103e4a:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  103e4d:	8b 45 10             	mov    0x10(%ebp),%eax
  103e50:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103e53:	72 0d                	jb     103e62 <get_pgtable_items+0x1b>
        return 0;
  103e55:	b8 00 00 00 00       	mov    $0x0,%eax
  103e5a:	e9 98 00 00 00       	jmp    103ef7 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  103e5f:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  103e62:	8b 45 10             	mov    0x10(%ebp),%eax
  103e65:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103e68:	73 18                	jae    103e82 <get_pgtable_items+0x3b>
  103e6a:	8b 45 10             	mov    0x10(%ebp),%eax
  103e6d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103e74:	8b 45 14             	mov    0x14(%ebp),%eax
  103e77:	01 d0                	add    %edx,%eax
  103e79:	8b 00                	mov    (%eax),%eax
  103e7b:	83 e0 01             	and    $0x1,%eax
  103e7e:	85 c0                	test   %eax,%eax
  103e80:	74 dd                	je     103e5f <get_pgtable_items+0x18>
    }
    if (start < right) {
  103e82:	8b 45 10             	mov    0x10(%ebp),%eax
  103e85:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103e88:	73 68                	jae    103ef2 <get_pgtable_items+0xab>
        if (left_store != NULL) {
  103e8a:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  103e8e:	74 08                	je     103e98 <get_pgtable_items+0x51>
            *left_store = start;
  103e90:	8b 45 18             	mov    0x18(%ebp),%eax
  103e93:	8b 55 10             	mov    0x10(%ebp),%edx
  103e96:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  103e98:	8b 45 10             	mov    0x10(%ebp),%eax
  103e9b:	8d 50 01             	lea    0x1(%eax),%edx
  103e9e:	89 55 10             	mov    %edx,0x10(%ebp)
  103ea1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103ea8:	8b 45 14             	mov    0x14(%ebp),%eax
  103eab:	01 d0                	add    %edx,%eax
  103ead:	8b 00                	mov    (%eax),%eax
  103eaf:	83 e0 07             	and    $0x7,%eax
  103eb2:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  103eb5:	eb 03                	jmp    103eba <get_pgtable_items+0x73>
            start ++;
  103eb7:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  103eba:	8b 45 10             	mov    0x10(%ebp),%eax
  103ebd:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103ec0:	73 1d                	jae    103edf <get_pgtable_items+0x98>
  103ec2:	8b 45 10             	mov    0x10(%ebp),%eax
  103ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103ecc:	8b 45 14             	mov    0x14(%ebp),%eax
  103ecf:	01 d0                	add    %edx,%eax
  103ed1:	8b 00                	mov    (%eax),%eax
  103ed3:	83 e0 07             	and    $0x7,%eax
  103ed6:	89 c2                	mov    %eax,%edx
  103ed8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103edb:	39 c2                	cmp    %eax,%edx
  103edd:	74 d8                	je     103eb7 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  103edf:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  103ee3:	74 08                	je     103eed <get_pgtable_items+0xa6>
            *right_store = start;
  103ee5:	8b 45 1c             	mov    0x1c(%ebp),%eax
  103ee8:	8b 55 10             	mov    0x10(%ebp),%edx
  103eeb:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  103eed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103ef0:	eb 05                	jmp    103ef7 <get_pgtable_items+0xb0>
    }
    return 0;
  103ef2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103ef7:	c9                   	leave  
  103ef8:	c3                   	ret    

00103ef9 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  103ef9:	55                   	push   %ebp
  103efa:	89 e5                	mov    %esp,%ebp
  103efc:	57                   	push   %edi
  103efd:	56                   	push   %esi
  103efe:	53                   	push   %ebx
  103eff:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  103f02:	c7 04 24 90 79 10 00 	movl   $0x107990,(%esp)
  103f09:	e8 84 c3 ff ff       	call   100292 <cprintf>
    size_t left, right = 0, perm;
  103f0e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  103f15:	e9 fa 00 00 00       	jmp    104014 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  103f1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103f1d:	89 04 24             	mov    %eax,(%esp)
  103f20:	e8 e0 fe ff ff       	call   103e05 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  103f25:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  103f28:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103f2b:	29 d1                	sub    %edx,%ecx
  103f2d:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  103f2f:	89 d6                	mov    %edx,%esi
  103f31:	c1 e6 16             	shl    $0x16,%esi
  103f34:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f37:	89 d3                	mov    %edx,%ebx
  103f39:	c1 e3 16             	shl    $0x16,%ebx
  103f3c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103f3f:	89 d1                	mov    %edx,%ecx
  103f41:	c1 e1 16             	shl    $0x16,%ecx
  103f44:	8b 7d dc             	mov    -0x24(%ebp),%edi
  103f47:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103f4a:	29 d7                	sub    %edx,%edi
  103f4c:	89 fa                	mov    %edi,%edx
  103f4e:	89 44 24 14          	mov    %eax,0x14(%esp)
  103f52:	89 74 24 10          	mov    %esi,0x10(%esp)
  103f56:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  103f5a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  103f5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  103f62:	c7 04 24 c1 79 10 00 	movl   $0x1079c1,(%esp)
  103f69:	e8 24 c3 ff ff       	call   100292 <cprintf>
        size_t l, r = left * NPTEENTRY;
  103f6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f71:	c1 e0 0a             	shl    $0xa,%eax
  103f74:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  103f77:	eb 54                	jmp    103fcd <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  103f79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103f7c:	89 04 24             	mov    %eax,(%esp)
  103f7f:	e8 81 fe ff ff       	call   103e05 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  103f84:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  103f87:	8b 55 d8             	mov    -0x28(%ebp),%edx
  103f8a:	29 d1                	sub    %edx,%ecx
  103f8c:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  103f8e:	89 d6                	mov    %edx,%esi
  103f90:	c1 e6 0c             	shl    $0xc,%esi
  103f93:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103f96:	89 d3                	mov    %edx,%ebx
  103f98:	c1 e3 0c             	shl    $0xc,%ebx
  103f9b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  103f9e:	89 d1                	mov    %edx,%ecx
  103fa0:	c1 e1 0c             	shl    $0xc,%ecx
  103fa3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  103fa6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  103fa9:	29 d7                	sub    %edx,%edi
  103fab:	89 fa                	mov    %edi,%edx
  103fad:	89 44 24 14          	mov    %eax,0x14(%esp)
  103fb1:	89 74 24 10          	mov    %esi,0x10(%esp)
  103fb5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  103fb9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  103fbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  103fc1:	c7 04 24 e0 79 10 00 	movl   $0x1079e0,(%esp)
  103fc8:	e8 c5 c2 ff ff       	call   100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  103fcd:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  103fd2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103fd5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fd8:	89 d3                	mov    %edx,%ebx
  103fda:	c1 e3 0a             	shl    $0xa,%ebx
  103fdd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103fe0:	89 d1                	mov    %edx,%ecx
  103fe2:	c1 e1 0a             	shl    $0xa,%ecx
  103fe5:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  103fe8:	89 54 24 14          	mov    %edx,0x14(%esp)
  103fec:	8d 55 d8             	lea    -0x28(%ebp),%edx
  103fef:	89 54 24 10          	mov    %edx,0x10(%esp)
  103ff3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  103ff7:	89 44 24 08          	mov    %eax,0x8(%esp)
  103ffb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  103fff:	89 0c 24             	mov    %ecx,(%esp)
  104002:	e8 40 fe ff ff       	call   103e47 <get_pgtable_items>
  104007:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10400a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10400e:	0f 85 65 ff ff ff    	jne    103f79 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104014:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  104019:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10401c:	8d 55 dc             	lea    -0x24(%ebp),%edx
  10401f:	89 54 24 14          	mov    %edx,0x14(%esp)
  104023:	8d 55 e0             	lea    -0x20(%ebp),%edx
  104026:	89 54 24 10          	mov    %edx,0x10(%esp)
  10402a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10402e:	89 44 24 08          	mov    %eax,0x8(%esp)
  104032:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  104039:	00 
  10403a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104041:	e8 01 fe ff ff       	call   103e47 <get_pgtable_items>
  104046:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104049:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10404d:	0f 85 c7 fe ff ff    	jne    103f1a <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  104053:	c7 04 24 04 7a 10 00 	movl   $0x107a04,(%esp)
  10405a:	e8 33 c2 ff ff       	call   100292 <cprintf>
}
  10405f:	90                   	nop
  104060:	83 c4 4c             	add    $0x4c,%esp
  104063:	5b                   	pop    %ebx
  104064:	5e                   	pop    %esi
  104065:	5f                   	pop    %edi
  104066:	5d                   	pop    %ebp
  104067:	c3                   	ret    

00104068 <page2ppn>:
page2ppn(struct Page *page) {
  104068:	55                   	push   %ebp
  104069:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10406b:	8b 45 08             	mov    0x8(%ebp),%eax
  10406e:	8b 15 18 df 11 00    	mov    0x11df18,%edx
  104074:	29 d0                	sub    %edx,%eax
  104076:	c1 f8 02             	sar    $0x2,%eax
  104079:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  10407f:	5d                   	pop    %ebp
  104080:	c3                   	ret    

00104081 <page2pa>:
page2pa(struct Page *page) {
  104081:	55                   	push   %ebp
  104082:	89 e5                	mov    %esp,%ebp
  104084:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104087:	8b 45 08             	mov    0x8(%ebp),%eax
  10408a:	89 04 24             	mov    %eax,(%esp)
  10408d:	e8 d6 ff ff ff       	call   104068 <page2ppn>
  104092:	c1 e0 0c             	shl    $0xc,%eax
}
  104095:	c9                   	leave  
  104096:	c3                   	ret    

00104097 <page_ref>:
page_ref(struct Page *page) {
  104097:	55                   	push   %ebp
  104098:	89 e5                	mov    %esp,%ebp
    return page->ref;
  10409a:	8b 45 08             	mov    0x8(%ebp),%eax
  10409d:	8b 00                	mov    (%eax),%eax
}
  10409f:	5d                   	pop    %ebp
  1040a0:	c3                   	ret    

001040a1 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  1040a1:	55                   	push   %ebp
  1040a2:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1040a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1040a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  1040aa:	89 10                	mov    %edx,(%eax)
}
  1040ac:	90                   	nop
  1040ad:	5d                   	pop    %ebp
  1040ae:	c3                   	ret    

001040af <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  1040af:	55                   	push   %ebp
  1040b0:	89 e5                	mov    %esp,%ebp
  1040b2:	83 ec 10             	sub    $0x10,%esp
  1040b5:	c7 45 fc 20 df 11 00 	movl   $0x11df20,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1040bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1040bf:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1040c2:	89 50 04             	mov    %edx,0x4(%eax)
  1040c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1040c8:	8b 50 04             	mov    0x4(%eax),%edx
  1040cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1040ce:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  1040d0:	c7 05 28 df 11 00 00 	movl   $0x0,0x11df28
  1040d7:	00 00 00 
}
  1040da:	90                   	nop
  1040db:	c9                   	leave  
  1040dc:	c3                   	ret    

001040dd <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  1040dd:	55                   	push   %ebp
  1040de:	89 e5                	mov    %esp,%ebp
  1040e0:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  1040e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1040e7:	75 24                	jne    10410d <default_init_memmap+0x30>
  1040e9:	c7 44 24 0c 38 7a 10 	movl   $0x107a38,0xc(%esp)
  1040f0:	00 
  1040f1:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  1040f8:	00 
  1040f9:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  104100:	00 
  104101:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104108:	e8 dc c2 ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  10410d:	8b 45 08             	mov    0x8(%ebp),%eax
  104110:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  104113:	eb 7d                	jmp    104192 <default_init_memmap+0xb5>
        assert(PageReserved(p));
  104115:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104118:	83 c0 04             	add    $0x4,%eax
  10411b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  104122:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104125:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104128:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10412b:	0f a3 10             	bt     %edx,(%eax)
  10412e:	19 c0                	sbb    %eax,%eax
  104130:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  104133:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104137:	0f 95 c0             	setne  %al
  10413a:	0f b6 c0             	movzbl %al,%eax
  10413d:	85 c0                	test   %eax,%eax
  10413f:	75 24                	jne    104165 <default_init_memmap+0x88>
  104141:	c7 44 24 0c 69 7a 10 	movl   $0x107a69,0xc(%esp)
  104148:	00 
  104149:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104150:	00 
  104151:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  104158:	00 
  104159:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104160:	e8 84 c2 ff ff       	call   1003e9 <__panic>
        p->flags = p->property = 0;
  104165:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104168:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  10416f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104172:	8b 50 08             	mov    0x8(%eax),%edx
  104175:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104178:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  10417b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104182:	00 
  104183:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104186:	89 04 24             	mov    %eax,(%esp)
  104189:	e8 13 ff ff ff       	call   1040a1 <set_page_ref>
    for (; p != base + n; p ++) {
  10418e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104192:	8b 55 0c             	mov    0xc(%ebp),%edx
  104195:	89 d0                	mov    %edx,%eax
  104197:	c1 e0 02             	shl    $0x2,%eax
  10419a:	01 d0                	add    %edx,%eax
  10419c:	c1 e0 02             	shl    $0x2,%eax
  10419f:	89 c2                	mov    %eax,%edx
  1041a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1041a4:	01 d0                	add    %edx,%eax
  1041a6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1041a9:	0f 85 66 ff ff ff    	jne    104115 <default_init_memmap+0x38>
	
    }
    base->property = n;
  1041af:	8b 45 08             	mov    0x8(%ebp),%eax
  1041b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  1041b5:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  1041b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1041bb:	83 c0 04             	add    $0x4,%eax
  1041be:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1041c5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1041c8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1041cb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1041ce:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  1041d1:	8b 15 28 df 11 00    	mov    0x11df28,%edx
  1041d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1041da:	01 d0                	add    %edx,%eax
  1041dc:	a3 28 df 11 00       	mov    %eax,0x11df28
    list_add_before(&free_list,&(base->page_link));
  1041e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1041e4:	83 c0 0c             	add    $0xc,%eax
  1041e7:	c7 45 e4 20 df 11 00 	movl   $0x11df20,-0x1c(%ebp)
  1041ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1041f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1041f4:	8b 00                	mov    (%eax),%eax
  1041f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1041f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1041fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1041ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104202:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  104205:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104208:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10420b:	89 10                	mov    %edx,(%eax)
  10420d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104210:	8b 10                	mov    (%eax),%edx
  104212:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104215:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104218:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10421b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10421e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104221:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104224:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104227:	89 10                	mov    %edx,(%eax)
}
  104229:	90                   	nop
  10422a:	c9                   	leave  
  10422b:	c3                   	ret    

0010422c <default_alloc_pages>:
 *              return `p`.
 *      (4.2)
 *          If we can not find a free block with its size >=n, then return NULL.
*/
static struct Page *
default_alloc_pages(size_t n) {
  10422c:	55                   	push   %ebp
  10422d:	89 e5                	mov    %esp,%ebp
  10422f:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  104232:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  104236:	75 24                	jne    10425c <default_alloc_pages+0x30>
  104238:	c7 44 24 0c 38 7a 10 	movl   $0x107a38,0xc(%esp)
  10423f:	00 
  104240:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104247:	00 
  104248:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  10424f:	00 
  104250:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104257:	e8 8d c1 ff ff       	call   1003e9 <__panic>
    if (n > nr_free) {
  10425c:	a1 28 df 11 00       	mov    0x11df28,%eax
  104261:	39 45 08             	cmp    %eax,0x8(%ebp)
  104264:	76 0a                	jbe    104270 <default_alloc_pages+0x44>
        return NULL;
  104266:	b8 00 00 00 00       	mov    $0x0,%eax
  10426b:	e9 49 01 00 00       	jmp    1043b9 <default_alloc_pages+0x18d>
    }
    struct Page *page=NULL;
  104270:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  104277:	c7 45 f0 20 df 11 00 	movl   $0x11df20,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10427e:	eb 1c                	jmp    10429c <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  104280:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104283:	83 e8 0c             	sub    $0xc,%eax
  104286:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  104289:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10428c:	8b 40 08             	mov    0x8(%eax),%eax
  10428f:	39 45 08             	cmp    %eax,0x8(%ebp)
  104292:	77 08                	ja     10429c <default_alloc_pages+0x70>
	   page=p;
  104294:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104297:	89 45 f4             	mov    %eax,-0xc(%ebp)
	   break;
  10429a:	eb 18                	jmp    1042b4 <default_alloc_pages+0x88>
  10429c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10429f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  1042a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1042a5:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  1042a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1042ab:	81 7d f0 20 df 11 00 	cmpl   $0x11df20,-0x10(%ebp)
  1042b2:	75 cc                	jne    104280 <default_alloc_pages+0x54>
        }
    }
    if(page!=NULL){
  1042b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1042b8:	0f 84 f8 00 00 00    	je     1043b6 <default_alloc_pages+0x18a>
	if(page->property>n){
  1042be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042c1:	8b 40 08             	mov    0x8(%eax),%eax
  1042c4:	39 45 08             	cmp    %eax,0x8(%ebp)
  1042c7:	0f 83 98 00 00 00    	jae    104365 <default_alloc_pages+0x139>
	   struct Page*p=page+n;
  1042cd:	8b 55 08             	mov    0x8(%ebp),%edx
  1042d0:	89 d0                	mov    %edx,%eax
  1042d2:	c1 e0 02             	shl    $0x2,%eax
  1042d5:	01 d0                	add    %edx,%eax
  1042d7:	c1 e0 02             	shl    $0x2,%eax
  1042da:	89 c2                	mov    %eax,%edx
  1042dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042df:	01 d0                	add    %edx,%eax
  1042e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
	   p->property=page->property-n;
  1042e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042e7:	8b 40 08             	mov    0x8(%eax),%eax
  1042ea:	2b 45 08             	sub    0x8(%ebp),%eax
  1042ed:	89 c2                	mov    %eax,%edx
  1042ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1042f2:	89 50 08             	mov    %edx,0x8(%eax)
	   SetPageProperty(p);
  1042f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1042f8:	83 c0 04             	add    $0x4,%eax
  1042fb:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  104302:	89 45 c0             	mov    %eax,-0x40(%ebp)
  104305:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104308:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  10430b:	0f ab 10             	bts    %edx,(%eax)
	   list_add(&(page->page_link),&(p->page_link));
  10430e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104311:	83 c0 0c             	add    $0xc,%eax
  104314:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104317:	83 c2 0c             	add    $0xc,%edx
  10431a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  10431d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104320:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104323:	89 45 d8             	mov    %eax,-0x28(%ebp)
  104326:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104329:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
  10432c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10432f:	8b 40 04             	mov    0x4(%eax),%eax
  104332:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104335:	89 55 d0             	mov    %edx,-0x30(%ebp)
  104338:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10433b:	89 55 cc             	mov    %edx,-0x34(%ebp)
  10433e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
  104341:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104344:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104347:	89 10                	mov    %edx,(%eax)
  104349:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10434c:	8b 10                	mov    (%eax),%edx
  10434e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104351:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104354:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104357:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10435a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10435d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104360:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104363:	89 10                	mov    %edx,(%eax)
	}
	
	list_del(&(page->page_link));
  104365:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104368:	83 c0 0c             	add    $0xc,%eax
  10436b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
  10436e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104371:	8b 40 04             	mov    0x4(%eax),%eax
  104374:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104377:	8b 12                	mov    (%edx),%edx
  104379:	89 55 b0             	mov    %edx,-0x50(%ebp)
  10437c:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  10437f:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104382:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104385:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104388:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10438b:	8b 55 b0             	mov    -0x50(%ebp),%edx
  10438e:	89 10                	mov    %edx,(%eax)
	nr_free-=n;
  104390:	a1 28 df 11 00       	mov    0x11df28,%eax
  104395:	2b 45 08             	sub    0x8(%ebp),%eax
  104398:	a3 28 df 11 00       	mov    %eax,0x11df28
	ClearPageProperty(page);
  10439d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043a0:	83 c0 04             	add    $0x4,%eax
  1043a3:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  1043aa:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1043ad:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1043b0:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1043b3:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  1043b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1043b9:	c9                   	leave  
  1043ba:	c3                   	ret    

001043bb <default_free_pages>:
 *  (5.3)
 *      Try to merge blocks at lower or higher addresses. Notice: This should
 *  change some pages' `p->property` correctly.
 */
static void
default_free_pages(struct Page *base, size_t n) {
  1043bb:	55                   	push   %ebp
  1043bc:	89 e5                	mov    %esp,%ebp
  1043be:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  1043c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1043c8:	75 24                	jne    1043ee <default_free_pages+0x33>
  1043ca:	c7 44 24 0c 38 7a 10 	movl   $0x107a38,0xc(%esp)
  1043d1:	00 
  1043d2:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  1043d9:	00 
  1043da:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  1043e1:	00 
  1043e2:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  1043e9:	e8 fb bf ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  1043ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1043f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1043f4:	e9 9d 00 00 00       	jmp    104496 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  1043f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043fc:	83 c0 04             	add    $0x4,%eax
  1043ff:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  104406:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104409:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10440c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10440f:	0f a3 10             	bt     %edx,(%eax)
  104412:	19 c0                	sbb    %eax,%eax
  104414:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  104417:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10441b:	0f 95 c0             	setne  %al
  10441e:	0f b6 c0             	movzbl %al,%eax
  104421:	85 c0                	test   %eax,%eax
  104423:	75 2c                	jne    104451 <default_free_pages+0x96>
  104425:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104428:	83 c0 04             	add    $0x4,%eax
  10442b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  104432:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104435:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104438:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10443b:	0f a3 10             	bt     %edx,(%eax)
  10443e:	19 c0                	sbb    %eax,%eax
  104440:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  104443:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  104447:	0f 95 c0             	setne  %al
  10444a:	0f b6 c0             	movzbl %al,%eax
  10444d:	85 c0                	test   %eax,%eax
  10444f:	74 24                	je     104475 <default_free_pages+0xba>
  104451:	c7 44 24 0c 7c 7a 10 	movl   $0x107a7c,0xc(%esp)
  104458:	00 
  104459:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104460:	00 
  104461:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  104468:	00 
  104469:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104470:	e8 74 bf ff ff       	call   1003e9 <__panic>
        p->flags = 0;
  104475:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104478:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  10447f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104486:	00 
  104487:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10448a:	89 04 24             	mov    %eax,(%esp)
  10448d:	e8 0f fc ff ff       	call   1040a1 <set_page_ref>
    for (; p != base + n; p ++) {
  104492:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104496:	8b 55 0c             	mov    0xc(%ebp),%edx
  104499:	89 d0                	mov    %edx,%eax
  10449b:	c1 e0 02             	shl    $0x2,%eax
  10449e:	01 d0                	add    %edx,%eax
  1044a0:	c1 e0 02             	shl    $0x2,%eax
  1044a3:	89 c2                	mov    %eax,%edx
  1044a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1044a8:	01 d0                	add    %edx,%eax
  1044aa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1044ad:	0f 85 46 ff ff ff    	jne    1043f9 <default_free_pages+0x3e>
    }
    base->property = n;
  1044b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1044b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  1044b9:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  1044bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1044bf:	83 c0 04             	add    $0x4,%eax
  1044c2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1044c9:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1044cc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1044cf:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1044d2:	0f ab 10             	bts    %edx,(%eax)
  1044d5:	c7 45 d4 20 df 11 00 	movl   $0x11df20,-0x2c(%ebp)
    return listelm->next;
  1044dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1044df:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  1044e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  1044e5:	e9 08 01 00 00       	jmp    1045f2 <default_free_pages+0x237>
        p = le2page(le, page_link);
  1044ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044ed:	83 e8 0c             	sub    $0xc,%eax
  1044f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1044f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044f6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1044f9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1044fc:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  1044ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  104502:	8b 45 08             	mov    0x8(%ebp),%eax
  104505:	8b 50 08             	mov    0x8(%eax),%edx
  104508:	89 d0                	mov    %edx,%eax
  10450a:	c1 e0 02             	shl    $0x2,%eax
  10450d:	01 d0                	add    %edx,%eax
  10450f:	c1 e0 02             	shl    $0x2,%eax
  104512:	89 c2                	mov    %eax,%edx
  104514:	8b 45 08             	mov    0x8(%ebp),%eax
  104517:	01 d0                	add    %edx,%eax
  104519:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10451c:	75 5a                	jne    104578 <default_free_pages+0x1bd>
            base->property += p->property;
  10451e:	8b 45 08             	mov    0x8(%ebp),%eax
  104521:	8b 50 08             	mov    0x8(%eax),%edx
  104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104527:	8b 40 08             	mov    0x8(%eax),%eax
  10452a:	01 c2                	add    %eax,%edx
  10452c:	8b 45 08             	mov    0x8(%ebp),%eax
  10452f:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  104532:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104535:	83 c0 04             	add    $0x4,%eax
  104538:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  10453f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104542:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104545:	8b 55 b8             	mov    -0x48(%ebp),%edx
  104548:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  10454b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10454e:	83 c0 0c             	add    $0xc,%eax
  104551:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  104554:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104557:	8b 40 04             	mov    0x4(%eax),%eax
  10455a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  10455d:	8b 12                	mov    (%edx),%edx
  10455f:	89 55 c0             	mov    %edx,-0x40(%ebp)
  104562:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  104565:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104568:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10456b:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  10456e:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104571:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104574:	89 10                	mov    %edx,(%eax)
  104576:	eb 7a                	jmp    1045f2 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  104578:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10457b:	8b 50 08             	mov    0x8(%eax),%edx
  10457e:	89 d0                	mov    %edx,%eax
  104580:	c1 e0 02             	shl    $0x2,%eax
  104583:	01 d0                	add    %edx,%eax
  104585:	c1 e0 02             	shl    $0x2,%eax
  104588:	89 c2                	mov    %eax,%edx
  10458a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10458d:	01 d0                	add    %edx,%eax
  10458f:	39 45 08             	cmp    %eax,0x8(%ebp)
  104592:	75 5e                	jne    1045f2 <default_free_pages+0x237>
            p->property += base->property;
  104594:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104597:	8b 50 08             	mov    0x8(%eax),%edx
  10459a:	8b 45 08             	mov    0x8(%ebp),%eax
  10459d:	8b 40 08             	mov    0x8(%eax),%eax
  1045a0:	01 c2                	add    %eax,%edx
  1045a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045a5:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  1045a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1045ab:	83 c0 04             	add    $0x4,%eax
  1045ae:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  1045b5:	89 45 a0             	mov    %eax,-0x60(%ebp)
  1045b8:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1045bb:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  1045be:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  1045c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045c4:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  1045c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045ca:	83 c0 0c             	add    $0xc,%eax
  1045cd:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  1045d0:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1045d3:	8b 40 04             	mov    0x4(%eax),%eax
  1045d6:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1045d9:	8b 12                	mov    (%edx),%edx
  1045db:	89 55 ac             	mov    %edx,-0x54(%ebp)
  1045de:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  1045e1:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1045e4:	8b 55 a8             	mov    -0x58(%ebp),%edx
  1045e7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1045ea:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1045ed:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1045f0:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
  1045f2:	81 7d f0 20 df 11 00 	cmpl   $0x11df20,-0x10(%ebp)
  1045f9:	0f 85 eb fe ff ff    	jne    1044ea <default_free_pages+0x12f>
        }
    }
    SetPageProperty(base);
  1045ff:	8b 45 08             	mov    0x8(%ebp),%eax
  104602:	83 c0 04             	add    $0x4,%eax
  104605:	c7 45 98 01 00 00 00 	movl   $0x1,-0x68(%ebp)
  10460c:	89 45 94             	mov    %eax,-0x6c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10460f:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104612:	8b 55 98             	mov    -0x68(%ebp),%edx
  104615:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  104618:	8b 15 28 df 11 00    	mov    0x11df28,%edx
  10461e:	8b 45 0c             	mov    0xc(%ebp),%eax
  104621:	01 d0                	add    %edx,%eax
  104623:	a3 28 df 11 00       	mov    %eax,0x11df28
  104628:	c7 45 9c 20 df 11 00 	movl   $0x11df20,-0x64(%ebp)
    return listelm->next;
  10462f:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104632:	8b 40 04             	mov    0x4(%eax),%eax
    le=list_next(&free_list);
  104635:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
  104638:	eb 0f                	jmp    104649 <default_free_pages+0x28e>
  10463a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10463d:	89 45 90             	mov    %eax,-0x70(%ebp)
  104640:	8b 45 90             	mov    -0x70(%ebp),%eax
  104643:	8b 40 04             	mov    0x4(%eax),%eax
	le=list_next(le);
  104646:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
  104649:	81 7d f0 20 df 11 00 	cmpl   $0x11df20,-0x10(%ebp)
  104650:	74 0b                	je     10465d <default_free_pages+0x2a2>
  104652:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104655:	83 e8 0c             	sub    $0xc,%eax
  104658:	39 45 08             	cmp    %eax,0x8(%ebp)
  10465b:	77 dd                	ja     10463a <default_free_pages+0x27f>
    }
    list_add_before(le, &(base->page_link));
  10465d:	8b 45 08             	mov    0x8(%ebp),%eax
  104660:	8d 50 0c             	lea    0xc(%eax),%edx
  104663:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104666:	89 45 8c             	mov    %eax,-0x74(%ebp)
  104669:	89 55 88             	mov    %edx,-0x78(%ebp)
    __list_add(elm, listelm->prev, listelm);
  10466c:	8b 45 8c             	mov    -0x74(%ebp),%eax
  10466f:	8b 00                	mov    (%eax),%eax
  104671:	8b 55 88             	mov    -0x78(%ebp),%edx
  104674:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104677:	89 45 80             	mov    %eax,-0x80(%ebp)
  10467a:	8b 45 8c             	mov    -0x74(%ebp),%eax
  10467d:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
    prev->next = next->prev = elm;
  104683:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  104689:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10468c:	89 10                	mov    %edx,(%eax)
  10468e:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  104694:	8b 10                	mov    (%eax),%edx
  104696:	8b 45 80             	mov    -0x80(%ebp),%eax
  104699:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10469c:	8b 45 84             	mov    -0x7c(%ebp),%eax
  10469f:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  1046a5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1046a8:	8b 45 84             	mov    -0x7c(%ebp),%eax
  1046ab:	8b 55 80             	mov    -0x80(%ebp),%edx
  1046ae:	89 10                	mov    %edx,(%eax)
}
  1046b0:	90                   	nop
  1046b1:	c9                   	leave  
  1046b2:	c3                   	ret    

001046b3 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  1046b3:	55                   	push   %ebp
  1046b4:	89 e5                	mov    %esp,%ebp
    return nr_free;
  1046b6:	a1 28 df 11 00       	mov    0x11df28,%eax
}
  1046bb:	5d                   	pop    %ebp
  1046bc:	c3                   	ret    

001046bd <basic_check>:

static void
basic_check(void) {
  1046bd:	55                   	push   %ebp
  1046be:	89 e5                	mov    %esp,%ebp
  1046c0:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  1046c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1046ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1046d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  1046d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1046dd:	e8 67 e4 ff ff       	call   102b49 <alloc_pages>
  1046e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1046e5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1046e9:	75 24                	jne    10470f <basic_check+0x52>
  1046eb:	c7 44 24 0c a1 7a 10 	movl   $0x107aa1,0xc(%esp)
  1046f2:	00 
  1046f3:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  1046fa:	00 
  1046fb:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
  104702:	00 
  104703:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  10470a:	e8 da bc ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  10470f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104716:	e8 2e e4 ff ff       	call   102b49 <alloc_pages>
  10471b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10471e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104722:	75 24                	jne    104748 <basic_check+0x8b>
  104724:	c7 44 24 0c bd 7a 10 	movl   $0x107abd,0xc(%esp)
  10472b:	00 
  10472c:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104733:	00 
  104734:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
  10473b:	00 
  10473c:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104743:	e8 a1 bc ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104748:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10474f:	e8 f5 e3 ff ff       	call   102b49 <alloc_pages>
  104754:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104757:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10475b:	75 24                	jne    104781 <basic_check+0xc4>
  10475d:	c7 44 24 0c d9 7a 10 	movl   $0x107ad9,0xc(%esp)
  104764:	00 
  104765:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  10476c:	00 
  10476d:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  104774:	00 
  104775:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  10477c:	e8 68 bc ff ff       	call   1003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104781:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104784:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104787:	74 10                	je     104799 <basic_check+0xdc>
  104789:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10478c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10478f:	74 08                	je     104799 <basic_check+0xdc>
  104791:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104794:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104797:	75 24                	jne    1047bd <basic_check+0x100>
  104799:	c7 44 24 0c f8 7a 10 	movl   $0x107af8,0xc(%esp)
  1047a0:	00 
  1047a1:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  1047a8:	00 
  1047a9:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
  1047b0:	00 
  1047b1:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  1047b8:	e8 2c bc ff ff       	call   1003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  1047bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1047c0:	89 04 24             	mov    %eax,(%esp)
  1047c3:	e8 cf f8 ff ff       	call   104097 <page_ref>
  1047c8:	85 c0                	test   %eax,%eax
  1047ca:	75 1e                	jne    1047ea <basic_check+0x12d>
  1047cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1047cf:	89 04 24             	mov    %eax,(%esp)
  1047d2:	e8 c0 f8 ff ff       	call   104097 <page_ref>
  1047d7:	85 c0                	test   %eax,%eax
  1047d9:	75 0f                	jne    1047ea <basic_check+0x12d>
  1047db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047de:	89 04 24             	mov    %eax,(%esp)
  1047e1:	e8 b1 f8 ff ff       	call   104097 <page_ref>
  1047e6:	85 c0                	test   %eax,%eax
  1047e8:	74 24                	je     10480e <basic_check+0x151>
  1047ea:	c7 44 24 0c 1c 7b 10 	movl   $0x107b1c,0xc(%esp)
  1047f1:	00 
  1047f2:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  1047f9:	00 
  1047fa:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
  104801:	00 
  104802:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104809:	e8 db bb ff ff       	call   1003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  10480e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104811:	89 04 24             	mov    %eax,(%esp)
  104814:	e8 68 f8 ff ff       	call   104081 <page2pa>
  104819:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  10481f:	c1 e2 0c             	shl    $0xc,%edx
  104822:	39 d0                	cmp    %edx,%eax
  104824:	72 24                	jb     10484a <basic_check+0x18d>
  104826:	c7 44 24 0c 58 7b 10 	movl   $0x107b58,0xc(%esp)
  10482d:	00 
  10482e:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104835:	00 
  104836:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  10483d:	00 
  10483e:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104845:	e8 9f bb ff ff       	call   1003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  10484a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10484d:	89 04 24             	mov    %eax,(%esp)
  104850:	e8 2c f8 ff ff       	call   104081 <page2pa>
  104855:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  10485b:	c1 e2 0c             	shl    $0xc,%edx
  10485e:	39 d0                	cmp    %edx,%eax
  104860:	72 24                	jb     104886 <basic_check+0x1c9>
  104862:	c7 44 24 0c 75 7b 10 	movl   $0x107b75,0xc(%esp)
  104869:	00 
  10486a:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104871:	00 
  104872:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
  104879:	00 
  10487a:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104881:	e8 63 bb ff ff       	call   1003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104889:	89 04 24             	mov    %eax,(%esp)
  10488c:	e8 f0 f7 ff ff       	call   104081 <page2pa>
  104891:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  104897:	c1 e2 0c             	shl    $0xc,%edx
  10489a:	39 d0                	cmp    %edx,%eax
  10489c:	72 24                	jb     1048c2 <basic_check+0x205>
  10489e:	c7 44 24 0c 92 7b 10 	movl   $0x107b92,0xc(%esp)
  1048a5:	00 
  1048a6:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  1048ad:	00 
  1048ae:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  1048b5:	00 
  1048b6:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  1048bd:	e8 27 bb ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  1048c2:	a1 20 df 11 00       	mov    0x11df20,%eax
  1048c7:	8b 15 24 df 11 00    	mov    0x11df24,%edx
  1048cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1048d0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1048d3:	c7 45 dc 20 df 11 00 	movl   $0x11df20,-0x24(%ebp)
    elm->prev = elm->next = elm;
  1048da:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1048dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1048e0:	89 50 04             	mov    %edx,0x4(%eax)
  1048e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1048e6:	8b 50 04             	mov    0x4(%eax),%edx
  1048e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1048ec:	89 10                	mov    %edx,(%eax)
  1048ee:	c7 45 e0 20 df 11 00 	movl   $0x11df20,-0x20(%ebp)
    return list->next == list;
  1048f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1048f8:	8b 40 04             	mov    0x4(%eax),%eax
  1048fb:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  1048fe:	0f 94 c0             	sete   %al
  104901:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104904:	85 c0                	test   %eax,%eax
  104906:	75 24                	jne    10492c <basic_check+0x26f>
  104908:	c7 44 24 0c af 7b 10 	movl   $0x107baf,0xc(%esp)
  10490f:	00 
  104910:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104917:	00 
  104918:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  10491f:	00 
  104920:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104927:	e8 bd ba ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  10492c:	a1 28 df 11 00       	mov    0x11df28,%eax
  104931:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104934:	c7 05 28 df 11 00 00 	movl   $0x0,0x11df28
  10493b:	00 00 00 

    assert(alloc_page() == NULL);
  10493e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104945:	e8 ff e1 ff ff       	call   102b49 <alloc_pages>
  10494a:	85 c0                	test   %eax,%eax
  10494c:	74 24                	je     104972 <basic_check+0x2b5>
  10494e:	c7 44 24 0c c6 7b 10 	movl   $0x107bc6,0xc(%esp)
  104955:	00 
  104956:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  10495d:	00 
  10495e:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  104965:	00 
  104966:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  10496d:	e8 77 ba ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104972:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104979:	00 
  10497a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10497d:	89 04 24             	mov    %eax,(%esp)
  104980:	e8 fc e1 ff ff       	call   102b81 <free_pages>
    free_page(p1);
  104985:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10498c:	00 
  10498d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104990:	89 04 24             	mov    %eax,(%esp)
  104993:	e8 e9 e1 ff ff       	call   102b81 <free_pages>
    free_page(p2);
  104998:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10499f:	00 
  1049a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049a3:	89 04 24             	mov    %eax,(%esp)
  1049a6:	e8 d6 e1 ff ff       	call   102b81 <free_pages>
    assert(nr_free == 3);
  1049ab:	a1 28 df 11 00       	mov    0x11df28,%eax
  1049b0:	83 f8 03             	cmp    $0x3,%eax
  1049b3:	74 24                	je     1049d9 <basic_check+0x31c>
  1049b5:	c7 44 24 0c db 7b 10 	movl   $0x107bdb,0xc(%esp)
  1049bc:	00 
  1049bd:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  1049c4:	00 
  1049c5:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  1049cc:	00 
  1049cd:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  1049d4:	e8 10 ba ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  1049d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1049e0:	e8 64 e1 ff ff       	call   102b49 <alloc_pages>
  1049e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1049e8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1049ec:	75 24                	jne    104a12 <basic_check+0x355>
  1049ee:	c7 44 24 0c a1 7a 10 	movl   $0x107aa1,0xc(%esp)
  1049f5:	00 
  1049f6:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  1049fd:	00 
  1049fe:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  104a05:	00 
  104a06:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104a0d:	e8 d7 b9 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104a12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a19:	e8 2b e1 ff ff       	call   102b49 <alloc_pages>
  104a1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a21:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104a25:	75 24                	jne    104a4b <basic_check+0x38e>
  104a27:	c7 44 24 0c bd 7a 10 	movl   $0x107abd,0xc(%esp)
  104a2e:	00 
  104a2f:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104a36:	00 
  104a37:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  104a3e:	00 
  104a3f:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104a46:	e8 9e b9 ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104a4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a52:	e8 f2 e0 ff ff       	call   102b49 <alloc_pages>
  104a57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104a5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104a5e:	75 24                	jne    104a84 <basic_check+0x3c7>
  104a60:	c7 44 24 0c d9 7a 10 	movl   $0x107ad9,0xc(%esp)
  104a67:	00 
  104a68:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104a6f:	00 
  104a70:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  104a77:	00 
  104a78:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104a7f:	e8 65 b9 ff ff       	call   1003e9 <__panic>

    assert(alloc_page() == NULL);
  104a84:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a8b:	e8 b9 e0 ff ff       	call   102b49 <alloc_pages>
  104a90:	85 c0                	test   %eax,%eax
  104a92:	74 24                	je     104ab8 <basic_check+0x3fb>
  104a94:	c7 44 24 0c c6 7b 10 	movl   $0x107bc6,0xc(%esp)
  104a9b:	00 
  104a9c:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104aa3:	00 
  104aa4:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  104aab:	00 
  104aac:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104ab3:	e8 31 b9 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104ab8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104abf:	00 
  104ac0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104ac3:	89 04 24             	mov    %eax,(%esp)
  104ac6:	e8 b6 e0 ff ff       	call   102b81 <free_pages>
  104acb:	c7 45 d8 20 df 11 00 	movl   $0x11df20,-0x28(%ebp)
  104ad2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104ad5:	8b 40 04             	mov    0x4(%eax),%eax
  104ad8:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104adb:	0f 94 c0             	sete   %al
  104ade:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104ae1:	85 c0                	test   %eax,%eax
  104ae3:	74 24                	je     104b09 <basic_check+0x44c>
  104ae5:	c7 44 24 0c e8 7b 10 	movl   $0x107be8,0xc(%esp)
  104aec:	00 
  104aed:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104af4:	00 
  104af5:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  104afc:	00 
  104afd:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104b04:	e8 e0 b8 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104b09:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b10:	e8 34 e0 ff ff       	call   102b49 <alloc_pages>
  104b15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104b18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104b1b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104b1e:	74 24                	je     104b44 <basic_check+0x487>
  104b20:	c7 44 24 0c 00 7c 10 	movl   $0x107c00,0xc(%esp)
  104b27:	00 
  104b28:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104b2f:	00 
  104b30:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  104b37:	00 
  104b38:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104b3f:	e8 a5 b8 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104b44:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b4b:	e8 f9 df ff ff       	call   102b49 <alloc_pages>
  104b50:	85 c0                	test   %eax,%eax
  104b52:	74 24                	je     104b78 <basic_check+0x4bb>
  104b54:	c7 44 24 0c c6 7b 10 	movl   $0x107bc6,0xc(%esp)
  104b5b:	00 
  104b5c:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104b63:	00 
  104b64:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  104b6b:	00 
  104b6c:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104b73:	e8 71 b8 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  104b78:	a1 28 df 11 00       	mov    0x11df28,%eax
  104b7d:	85 c0                	test   %eax,%eax
  104b7f:	74 24                	je     104ba5 <basic_check+0x4e8>
  104b81:	c7 44 24 0c 19 7c 10 	movl   $0x107c19,0xc(%esp)
  104b88:	00 
  104b89:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104b90:	00 
  104b91:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  104b98:	00 
  104b99:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104ba0:	e8 44 b8 ff ff       	call   1003e9 <__panic>
    free_list = free_list_store;
  104ba5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104ba8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104bab:	a3 20 df 11 00       	mov    %eax,0x11df20
  104bb0:	89 15 24 df 11 00    	mov    %edx,0x11df24
    nr_free = nr_free_store;
  104bb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104bb9:	a3 28 df 11 00       	mov    %eax,0x11df28

    free_page(p);
  104bbe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104bc5:	00 
  104bc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104bc9:	89 04 24             	mov    %eax,(%esp)
  104bcc:	e8 b0 df ff ff       	call   102b81 <free_pages>
    free_page(p1);
  104bd1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104bd8:	00 
  104bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104bdc:	89 04 24             	mov    %eax,(%esp)
  104bdf:	e8 9d df ff ff       	call   102b81 <free_pages>
    free_page(p2);
  104be4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104beb:	00 
  104bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bef:	89 04 24             	mov    %eax,(%esp)
  104bf2:	e8 8a df ff ff       	call   102b81 <free_pages>
}
  104bf7:	90                   	nop
  104bf8:	c9                   	leave  
  104bf9:	c3                   	ret    

00104bfa <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104bfa:	55                   	push   %ebp
  104bfb:	89 e5                	mov    %esp,%ebp
  104bfd:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  104c03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104c0a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104c11:	c7 45 ec 20 df 11 00 	movl   $0x11df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104c18:	eb 6a                	jmp    104c84 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  104c1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c1d:	83 e8 0c             	sub    $0xc,%eax
  104c20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  104c23:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104c26:	83 c0 04             	add    $0x4,%eax
  104c29:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104c30:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104c33:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104c36:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104c39:	0f a3 10             	bt     %edx,(%eax)
  104c3c:	19 c0                	sbb    %eax,%eax
  104c3e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104c41:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  104c45:	0f 95 c0             	setne  %al
  104c48:	0f b6 c0             	movzbl %al,%eax
  104c4b:	85 c0                	test   %eax,%eax
  104c4d:	75 24                	jne    104c73 <default_check+0x79>
  104c4f:	c7 44 24 0c 26 7c 10 	movl   $0x107c26,0xc(%esp)
  104c56:	00 
  104c57:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104c5e:	00 
  104c5f:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  104c66:	00 
  104c67:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104c6e:	e8 76 b7 ff ff       	call   1003e9 <__panic>
        count ++, total += p->property;
  104c73:	ff 45 f4             	incl   -0xc(%ebp)
  104c76:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104c79:	8b 50 08             	mov    0x8(%eax),%edx
  104c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c7f:	01 d0                	add    %edx,%eax
  104c81:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104c84:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c87:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  104c8a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104c8d:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104c90:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104c93:	81 7d ec 20 df 11 00 	cmpl   $0x11df20,-0x14(%ebp)
  104c9a:	0f 85 7a ff ff ff    	jne    104c1a <default_check+0x20>
    }
    assert(total == nr_free_pages());
  104ca0:	e8 0f df ff ff       	call   102bb4 <nr_free_pages>
  104ca5:	89 c2                	mov    %eax,%edx
  104ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104caa:	39 c2                	cmp    %eax,%edx
  104cac:	74 24                	je     104cd2 <default_check+0xd8>
  104cae:	c7 44 24 0c 36 7c 10 	movl   $0x107c36,0xc(%esp)
  104cb5:	00 
  104cb6:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104cbd:	00 
  104cbe:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  104cc5:	00 
  104cc6:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104ccd:	e8 17 b7 ff ff       	call   1003e9 <__panic>

    basic_check();
  104cd2:	e8 e6 f9 ff ff       	call   1046bd <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104cd7:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104cde:	e8 66 de ff ff       	call   102b49 <alloc_pages>
  104ce3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  104ce6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104cea:	75 24                	jne    104d10 <default_check+0x116>
  104cec:	c7 44 24 0c 4f 7c 10 	movl   $0x107c4f,0xc(%esp)
  104cf3:	00 
  104cf4:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104cfb:	00 
  104cfc:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
  104d03:	00 
  104d04:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104d0b:	e8 d9 b6 ff ff       	call   1003e9 <__panic>
    assert(!PageProperty(p0));
  104d10:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104d13:	83 c0 04             	add    $0x4,%eax
  104d16:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104d1d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104d20:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104d23:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104d26:	0f a3 10             	bt     %edx,(%eax)
  104d29:	19 c0                	sbb    %eax,%eax
  104d2b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104d2e:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  104d32:	0f 95 c0             	setne  %al
  104d35:	0f b6 c0             	movzbl %al,%eax
  104d38:	85 c0                	test   %eax,%eax
  104d3a:	74 24                	je     104d60 <default_check+0x166>
  104d3c:	c7 44 24 0c 5a 7c 10 	movl   $0x107c5a,0xc(%esp)
  104d43:	00 
  104d44:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104d4b:	00 
  104d4c:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  104d53:	00 
  104d54:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104d5b:	e8 89 b6 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104d60:	a1 20 df 11 00       	mov    0x11df20,%eax
  104d65:	8b 15 24 df 11 00    	mov    0x11df24,%edx
  104d6b:	89 45 80             	mov    %eax,-0x80(%ebp)
  104d6e:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104d71:	c7 45 b0 20 df 11 00 	movl   $0x11df20,-0x50(%ebp)
    elm->prev = elm->next = elm;
  104d78:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104d7b:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104d7e:	89 50 04             	mov    %edx,0x4(%eax)
  104d81:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104d84:	8b 50 04             	mov    0x4(%eax),%edx
  104d87:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104d8a:	89 10                	mov    %edx,(%eax)
  104d8c:	c7 45 b4 20 df 11 00 	movl   $0x11df20,-0x4c(%ebp)
    return list->next == list;
  104d93:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104d96:	8b 40 04             	mov    0x4(%eax),%eax
  104d99:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  104d9c:	0f 94 c0             	sete   %al
  104d9f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104da2:	85 c0                	test   %eax,%eax
  104da4:	75 24                	jne    104dca <default_check+0x1d0>
  104da6:	c7 44 24 0c af 7b 10 	movl   $0x107baf,0xc(%esp)
  104dad:	00 
  104dae:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104db5:	00 
  104db6:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
  104dbd:	00 
  104dbe:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104dc5:	e8 1f b6 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104dca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104dd1:	e8 73 dd ff ff       	call   102b49 <alloc_pages>
  104dd6:	85 c0                	test   %eax,%eax
  104dd8:	74 24                	je     104dfe <default_check+0x204>
  104dda:	c7 44 24 0c c6 7b 10 	movl   $0x107bc6,0xc(%esp)
  104de1:	00 
  104de2:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104de9:	00 
  104dea:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
  104df1:	00 
  104df2:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104df9:	e8 eb b5 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104dfe:	a1 28 df 11 00       	mov    0x11df28,%eax
  104e03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  104e06:	c7 05 28 df 11 00 00 	movl   $0x0,0x11df28
  104e0d:	00 00 00 

    free_pages(p0 + 2, 3);
  104e10:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104e13:	83 c0 28             	add    $0x28,%eax
  104e16:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104e1d:	00 
  104e1e:	89 04 24             	mov    %eax,(%esp)
  104e21:	e8 5b dd ff ff       	call   102b81 <free_pages>
    assert(alloc_pages(4) == NULL);
  104e26:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  104e2d:	e8 17 dd ff ff       	call   102b49 <alloc_pages>
  104e32:	85 c0                	test   %eax,%eax
  104e34:	74 24                	je     104e5a <default_check+0x260>
  104e36:	c7 44 24 0c 6c 7c 10 	movl   $0x107c6c,0xc(%esp)
  104e3d:	00 
  104e3e:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104e45:	00 
  104e46:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  104e4d:	00 
  104e4e:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104e55:	e8 8f b5 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  104e5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104e5d:	83 c0 28             	add    $0x28,%eax
  104e60:	83 c0 04             	add    $0x4,%eax
  104e63:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  104e6a:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104e6d:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104e70:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104e73:	0f a3 10             	bt     %edx,(%eax)
  104e76:	19 c0                	sbb    %eax,%eax
  104e78:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  104e7b:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  104e7f:	0f 95 c0             	setne  %al
  104e82:	0f b6 c0             	movzbl %al,%eax
  104e85:	85 c0                	test   %eax,%eax
  104e87:	74 0e                	je     104e97 <default_check+0x29d>
  104e89:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104e8c:	83 c0 28             	add    $0x28,%eax
  104e8f:	8b 40 08             	mov    0x8(%eax),%eax
  104e92:	83 f8 03             	cmp    $0x3,%eax
  104e95:	74 24                	je     104ebb <default_check+0x2c1>
  104e97:	c7 44 24 0c 84 7c 10 	movl   $0x107c84,0xc(%esp)
  104e9e:	00 
  104e9f:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104ea6:	00 
  104ea7:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
  104eae:	00 
  104eaf:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104eb6:	e8 2e b5 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  104ebb:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  104ec2:	e8 82 dc ff ff       	call   102b49 <alloc_pages>
  104ec7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104eca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  104ece:	75 24                	jne    104ef4 <default_check+0x2fa>
  104ed0:	c7 44 24 0c b0 7c 10 	movl   $0x107cb0,0xc(%esp)
  104ed7:	00 
  104ed8:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104edf:	00 
  104ee0:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  104ee7:	00 
  104ee8:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104eef:	e8 f5 b4 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104ef4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104efb:	e8 49 dc ff ff       	call   102b49 <alloc_pages>
  104f00:	85 c0                	test   %eax,%eax
  104f02:	74 24                	je     104f28 <default_check+0x32e>
  104f04:	c7 44 24 0c c6 7b 10 	movl   $0x107bc6,0xc(%esp)
  104f0b:	00 
  104f0c:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104f13:	00 
  104f14:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
  104f1b:	00 
  104f1c:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104f23:	e8 c1 b4 ff ff       	call   1003e9 <__panic>
    assert(p0 + 2 == p1);
  104f28:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f2b:	83 c0 28             	add    $0x28,%eax
  104f2e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104f31:	74 24                	je     104f57 <default_check+0x35d>
  104f33:	c7 44 24 0c ce 7c 10 	movl   $0x107cce,0xc(%esp)
  104f3a:	00 
  104f3b:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104f42:	00 
  104f43:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
  104f4a:	00 
  104f4b:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104f52:	e8 92 b4 ff ff       	call   1003e9 <__panic>

    p2 = p0 + 1;
  104f57:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f5a:	83 c0 14             	add    $0x14,%eax
  104f5d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  104f60:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f67:	00 
  104f68:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f6b:	89 04 24             	mov    %eax,(%esp)
  104f6e:	e8 0e dc ff ff       	call   102b81 <free_pages>
    free_pages(p1, 3);
  104f73:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104f7a:	00 
  104f7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104f7e:	89 04 24             	mov    %eax,(%esp)
  104f81:	e8 fb db ff ff       	call   102b81 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  104f86:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f89:	83 c0 04             	add    $0x4,%eax
  104f8c:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  104f93:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104f96:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104f99:	8b 55 a0             	mov    -0x60(%ebp),%edx
  104f9c:	0f a3 10             	bt     %edx,(%eax)
  104f9f:	19 c0                	sbb    %eax,%eax
  104fa1:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  104fa4:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  104fa8:	0f 95 c0             	setne  %al
  104fab:	0f b6 c0             	movzbl %al,%eax
  104fae:	85 c0                	test   %eax,%eax
  104fb0:	74 0b                	je     104fbd <default_check+0x3c3>
  104fb2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104fb5:	8b 40 08             	mov    0x8(%eax),%eax
  104fb8:	83 f8 01             	cmp    $0x1,%eax
  104fbb:	74 24                	je     104fe1 <default_check+0x3e7>
  104fbd:	c7 44 24 0c dc 7c 10 	movl   $0x107cdc,0xc(%esp)
  104fc4:	00 
  104fc5:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  104fcc:	00 
  104fcd:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
  104fd4:	00 
  104fd5:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  104fdc:	e8 08 b4 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  104fe1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104fe4:	83 c0 04             	add    $0x4,%eax
  104fe7:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  104fee:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104ff1:	8b 45 90             	mov    -0x70(%ebp),%eax
  104ff4:	8b 55 94             	mov    -0x6c(%ebp),%edx
  104ff7:	0f a3 10             	bt     %edx,(%eax)
  104ffa:	19 c0                	sbb    %eax,%eax
  104ffc:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  104fff:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  105003:	0f 95 c0             	setne  %al
  105006:	0f b6 c0             	movzbl %al,%eax
  105009:	85 c0                	test   %eax,%eax
  10500b:	74 0b                	je     105018 <default_check+0x41e>
  10500d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105010:	8b 40 08             	mov    0x8(%eax),%eax
  105013:	83 f8 03             	cmp    $0x3,%eax
  105016:	74 24                	je     10503c <default_check+0x442>
  105018:	c7 44 24 0c 04 7d 10 	movl   $0x107d04,0xc(%esp)
  10501f:	00 
  105020:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  105027:	00 
  105028:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
  10502f:	00 
  105030:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  105037:	e8 ad b3 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  10503c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105043:	e8 01 db ff ff       	call   102b49 <alloc_pages>
  105048:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10504b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10504e:	83 e8 14             	sub    $0x14,%eax
  105051:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105054:	74 24                	je     10507a <default_check+0x480>
  105056:	c7 44 24 0c 2a 7d 10 	movl   $0x107d2a,0xc(%esp)
  10505d:	00 
  10505e:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  105065:	00 
  105066:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
  10506d:	00 
  10506e:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  105075:	e8 6f b3 ff ff       	call   1003e9 <__panic>
    free_page(p0);
  10507a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105081:	00 
  105082:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105085:	89 04 24             	mov    %eax,(%esp)
  105088:	e8 f4 da ff ff       	call   102b81 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  10508d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  105094:	e8 b0 da ff ff       	call   102b49 <alloc_pages>
  105099:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10509c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10509f:	83 c0 14             	add    $0x14,%eax
  1050a2:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1050a5:	74 24                	je     1050cb <default_check+0x4d1>
  1050a7:	c7 44 24 0c 48 7d 10 	movl   $0x107d48,0xc(%esp)
  1050ae:	00 
  1050af:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  1050b6:	00 
  1050b7:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
  1050be:	00 
  1050bf:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  1050c6:	e8 1e b3 ff ff       	call   1003e9 <__panic>

    free_pages(p0, 2);
  1050cb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  1050d2:	00 
  1050d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1050d6:	89 04 24             	mov    %eax,(%esp)
  1050d9:	e8 a3 da ff ff       	call   102b81 <free_pages>
    free_page(p2);
  1050de:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1050e5:	00 
  1050e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1050e9:	89 04 24             	mov    %eax,(%esp)
  1050ec:	e8 90 da ff ff       	call   102b81 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  1050f1:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1050f8:	e8 4c da ff ff       	call   102b49 <alloc_pages>
  1050fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105100:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105104:	75 24                	jne    10512a <default_check+0x530>
  105106:	c7 44 24 0c 68 7d 10 	movl   $0x107d68,0xc(%esp)
  10510d:	00 
  10510e:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  105115:	00 
  105116:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
  10511d:	00 
  10511e:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  105125:	e8 bf b2 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  10512a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105131:	e8 13 da ff ff       	call   102b49 <alloc_pages>
  105136:	85 c0                	test   %eax,%eax
  105138:	74 24                	je     10515e <default_check+0x564>
  10513a:	c7 44 24 0c c6 7b 10 	movl   $0x107bc6,0xc(%esp)
  105141:	00 
  105142:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  105149:	00 
  10514a:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
  105151:	00 
  105152:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  105159:	e8 8b b2 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  10515e:	a1 28 df 11 00       	mov    0x11df28,%eax
  105163:	85 c0                	test   %eax,%eax
  105165:	74 24                	je     10518b <default_check+0x591>
  105167:	c7 44 24 0c 19 7c 10 	movl   $0x107c19,0xc(%esp)
  10516e:	00 
  10516f:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  105176:	00 
  105177:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
  10517e:	00 
  10517f:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  105186:	e8 5e b2 ff ff       	call   1003e9 <__panic>
    nr_free = nr_free_store;
  10518b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10518e:	a3 28 df 11 00       	mov    %eax,0x11df28

    free_list = free_list_store;
  105193:	8b 45 80             	mov    -0x80(%ebp),%eax
  105196:	8b 55 84             	mov    -0x7c(%ebp),%edx
  105199:	a3 20 df 11 00       	mov    %eax,0x11df20
  10519e:	89 15 24 df 11 00    	mov    %edx,0x11df24
    free_pages(p0, 5);
  1051a4:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  1051ab:	00 
  1051ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051af:	89 04 24             	mov    %eax,(%esp)
  1051b2:	e8 ca d9 ff ff       	call   102b81 <free_pages>

    le = &free_list;
  1051b7:	c7 45 ec 20 df 11 00 	movl   $0x11df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1051be:	eb 5a                	jmp    10521a <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
  1051c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1051c3:	8b 40 04             	mov    0x4(%eax),%eax
  1051c6:	8b 00                	mov    (%eax),%eax
  1051c8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  1051cb:	75 0d                	jne    1051da <default_check+0x5e0>
  1051cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1051d0:	8b 00                	mov    (%eax),%eax
  1051d2:	8b 40 04             	mov    0x4(%eax),%eax
  1051d5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  1051d8:	74 24                	je     1051fe <default_check+0x604>
  1051da:	c7 44 24 0c 88 7d 10 	movl   $0x107d88,0xc(%esp)
  1051e1:	00 
  1051e2:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  1051e9:	00 
  1051ea:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
  1051f1:	00 
  1051f2:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  1051f9:	e8 eb b1 ff ff       	call   1003e9 <__panic>
        struct Page *p = le2page(le, page_link);
  1051fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105201:	83 e8 0c             	sub    $0xc,%eax
  105204:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  105207:	ff 4d f4             	decl   -0xc(%ebp)
  10520a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10520d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105210:	8b 40 08             	mov    0x8(%eax),%eax
  105213:	29 c2                	sub    %eax,%edx
  105215:	89 d0                	mov    %edx,%eax
  105217:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10521a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10521d:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  105220:	8b 45 88             	mov    -0x78(%ebp),%eax
  105223:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  105226:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105229:	81 7d ec 20 df 11 00 	cmpl   $0x11df20,-0x14(%ebp)
  105230:	75 8e                	jne    1051c0 <default_check+0x5c6>
    }
    assert(count == 0);
  105232:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105236:	74 24                	je     10525c <default_check+0x662>
  105238:	c7 44 24 0c b5 7d 10 	movl   $0x107db5,0xc(%esp)
  10523f:	00 
  105240:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  105247:	00 
  105248:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
  10524f:	00 
  105250:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  105257:	e8 8d b1 ff ff       	call   1003e9 <__panic>
    assert(total == 0);
  10525c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105260:	74 24                	je     105286 <default_check+0x68c>
  105262:	c7 44 24 0c c0 7d 10 	movl   $0x107dc0,0xc(%esp)
  105269:	00 
  10526a:	c7 44 24 08 3e 7a 10 	movl   $0x107a3e,0x8(%esp)
  105271:	00 
  105272:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
  105279:	00 
  10527a:	c7 04 24 53 7a 10 00 	movl   $0x107a53,(%esp)
  105281:	e8 63 b1 ff ff       	call   1003e9 <__panic>
}
  105286:	90                   	nop
  105287:	c9                   	leave  
  105288:	c3                   	ret    

00105289 <page2ppn>:
page2ppn(struct Page *page) {
  105289:	55                   	push   %ebp
  10528a:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10528c:	8b 45 08             	mov    0x8(%ebp),%eax
  10528f:	8b 15 18 df 11 00    	mov    0x11df18,%edx
  105295:	29 d0                	sub    %edx,%eax
  105297:	c1 f8 02             	sar    $0x2,%eax
  10529a:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1052a0:	5d                   	pop    %ebp
  1052a1:	c3                   	ret    

001052a2 <page2pa>:
page2pa(struct Page *page) {
  1052a2:	55                   	push   %ebp
  1052a3:	89 e5                	mov    %esp,%ebp
  1052a5:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1052a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1052ab:	89 04 24             	mov    %eax,(%esp)
  1052ae:	e8 d6 ff ff ff       	call   105289 <page2ppn>
  1052b3:	c1 e0 0c             	shl    $0xc,%eax
}
  1052b6:	c9                   	leave  
  1052b7:	c3                   	ret    

001052b8 <page_ref>:
page_ref(struct Page *page) {
  1052b8:	55                   	push   %ebp
  1052b9:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1052bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1052be:	8b 00                	mov    (%eax),%eax
}
  1052c0:	5d                   	pop    %ebp
  1052c1:	c3                   	ret    

001052c2 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  1052c2:	55                   	push   %ebp
  1052c3:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1052c5:	8b 45 08             	mov    0x8(%ebp),%eax
  1052c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  1052cb:	89 10                	mov    %edx,(%eax)
}
  1052cd:	90                   	nop
  1052ce:	5d                   	pop    %ebp
  1052cf:	c3                   	ret    

001052d0 <buddy_init>:

#define MAXLEVEL 12
free_area_t free_area[MAXLEVEL+1];

static void 
buddy_init(void){
  1052d0:	55                   	push   %ebp
  1052d1:	89 e5                	mov    %esp,%ebp
  1052d3:	83 ec 10             	sub    $0x10,%esp
     for(int i=0;i<=MAXLEVEL;i++){
  1052d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1052dd:	eb 42                	jmp    105321 <buddy_init+0x51>
	list_init(&free_area[i].free_list);
  1052df:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1052e2:	89 d0                	mov    %edx,%eax
  1052e4:	01 c0                	add    %eax,%eax
  1052e6:	01 d0                	add    %edx,%eax
  1052e8:	c1 e0 02             	shl    $0x2,%eax
  1052eb:	05 20 df 11 00       	add    $0x11df20,%eax
  1052f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
    elm->prev = elm->next = elm;
  1052f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1052f6:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1052f9:	89 50 04             	mov    %edx,0x4(%eax)
  1052fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1052ff:	8b 50 04             	mov    0x4(%eax),%edx
  105302:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105305:	89 10                	mov    %edx,(%eax)
	free_area[i].nr_free=0;
  105307:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10530a:	89 d0                	mov    %edx,%eax
  10530c:	01 c0                	add    %eax,%eax
  10530e:	01 d0                	add    %edx,%eax
  105310:	c1 e0 02             	shl    $0x2,%eax
  105313:	05 28 df 11 00       	add    $0x11df28,%eax
  105318:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     for(int i=0;i<=MAXLEVEL;i++){
  10531e:	ff 45 fc             	incl   -0x4(%ebp)
  105321:	83 7d fc 0c          	cmpl   $0xc,-0x4(%ebp)
  105325:	7e b8                	jle    1052df <buddy_init+0xf>
     }
}
  105327:	90                   	nop
  105328:	c9                   	leave  
  105329:	c3                   	ret    

0010532a <buddy_nr_free_page>:

static size_t
buddy_nr_free_page(void){
  10532a:	55                   	push   %ebp
  10532b:	89 e5                	mov    %esp,%ebp
  10532d:	83 ec 10             	sub    $0x10,%esp
    size_t nr=0;
  105330:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
  105337:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  10533e:	eb 1c                	jmp    10535c <buddy_nr_free_page+0x32>
	nr+=free_area[i].nr_free*(1<<MAXLEVEL);
  105340:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105343:	89 d0                	mov    %edx,%eax
  105345:	01 c0                	add    %eax,%eax
  105347:	01 d0                	add    %edx,%eax
  105349:	c1 e0 02             	shl    $0x2,%eax
  10534c:	05 28 df 11 00       	add    $0x11df28,%eax
  105351:	8b 00                	mov    (%eax),%eax
  105353:	c1 e0 0c             	shl    $0xc,%eax
  105356:	01 45 fc             	add    %eax,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
  105359:	ff 45 f8             	incl   -0x8(%ebp)
  10535c:	83 7d f8 0c          	cmpl   $0xc,-0x8(%ebp)
  105360:	7e de                	jle    105340 <buddy_nr_free_page+0x16>
    }
    return nr; 
  105362:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105365:	c9                   	leave  
  105366:	c3                   	ret    

00105367 <buddy_init_memmap>:

static void
buddy_init_memmap(struct Page* base,size_t n){
  105367:	55                   	push   %ebp
  105368:	89 e5                	mov    %esp,%ebp
  10536a:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
  10536d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105371:	75 24                	jne    105397 <buddy_init_memmap+0x30>
  105373:	c7 44 24 0c fc 7d 10 	movl   $0x107dfc,0xc(%esp)
  10537a:	00 
  10537b:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  105382:	00 
  105383:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  10538a:	00 
  10538b:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  105392:	e8 52 b0 ff ff       	call   1003e9 <__panic>
     struct Page* p=base;
  105397:	8b 45 08             	mov    0x8(%ebp),%eax
  10539a:	89 45 f4             	mov    %eax,-0xc(%ebp)
     for(;p!=base+n;p++){
  10539d:	eb 7d                	jmp    10541c <buddy_init_memmap+0xb5>
	assert(PageReserved(p));
  10539f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053a2:	83 c0 04             	add    $0x4,%eax
  1053a5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  1053ac:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1053af:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1053b2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1053b5:	0f a3 10             	bt     %edx,(%eax)
  1053b8:	19 c0                	sbb    %eax,%eax
  1053ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  1053bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  1053c1:	0f 95 c0             	setne  %al
  1053c4:	0f b6 c0             	movzbl %al,%eax
  1053c7:	85 c0                	test   %eax,%eax
  1053c9:	75 24                	jne    1053ef <buddy_init_memmap+0x88>
  1053cb:	c7 44 24 0c 2c 7e 10 	movl   $0x107e2c,0xc(%esp)
  1053d2:	00 
  1053d3:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  1053da:	00 
  1053db:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  1053e2:	00 
  1053e3:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  1053ea:	e8 fa af ff ff       	call   1003e9 <__panic>
	p->flags=p->property=0;
  1053ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053f2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  1053f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053fc:	8b 50 08             	mov    0x8(%eax),%edx
  1053ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105402:	89 50 04             	mov    %edx,0x4(%eax)
	set_page_ref(p,0);
  105405:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10540c:	00 
  10540d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105410:	89 04 24             	mov    %eax,(%esp)
  105413:	e8 aa fe ff ff       	call   1052c2 <set_page_ref>
     for(;p!=base+n;p++){
  105418:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  10541c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10541f:	89 d0                	mov    %edx,%eax
  105421:	c1 e0 02             	shl    $0x2,%eax
  105424:	01 d0                	add    %edx,%eax
  105426:	c1 e0 02             	shl    $0x2,%eax
  105429:	89 c2                	mov    %eax,%edx
  10542b:	8b 45 08             	mov    0x8(%ebp),%eax
  10542e:	01 d0                	add    %edx,%eax
  105430:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  105433:	0f 85 66 ff ff ff    	jne    10539f <buddy_init_memmap+0x38>
     }
     p=base;
  105439:	8b 45 08             	mov    0x8(%ebp),%eax
  10543c:	89 45 f4             	mov    %eax,-0xc(%ebp)
     size_t temp=n;
  10543f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105442:	89 45 f0             	mov    %eax,-0x10(%ebp)
     int level=MAXLEVEL;
  105445:	c7 45 ec 0c 00 00 00 	movl   $0xc,-0x14(%ebp)
     while(level>=0){
  10544c:	e9 fd 00 00 00       	jmp    10554e <buddy_init_memmap+0x1e7>
	for(int i=0;i<temp/(1<<level);i++){
  105451:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  105458:	e9 c7 00 00 00       	jmp    105524 <buddy_init_memmap+0x1bd>
	    struct Page* page=p;
  10545d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105460:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	    page->property=1<<level;
  105463:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105466:	ba 01 00 00 00       	mov    $0x1,%edx
  10546b:	88 c1                	mov    %al,%cl
  10546d:	d3 e2                	shl    %cl,%edx
  10546f:	89 d0                	mov    %edx,%eax
  105471:	89 c2                	mov    %eax,%edx
  105473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105476:	89 50 08             	mov    %edx,0x8(%eax)
	    SetPageProperty(p);
  105479:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10547c:	83 c0 04             	add    $0x4,%eax
  10547f:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  105486:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105489:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10548c:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10548f:	0f ab 10             	bts    %edx,(%eax)
	    list_add_before(&free_area[level].free_list,&(page->page_link));
  105492:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105495:	8d 48 0c             	lea    0xc(%eax),%ecx
  105498:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10549b:	89 d0                	mov    %edx,%eax
  10549d:	01 c0                	add    %eax,%eax
  10549f:	01 d0                	add    %edx,%eax
  1054a1:	c1 e0 02             	shl    $0x2,%eax
  1054a4:	05 20 df 11 00       	add    $0x11df20,%eax
  1054a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1054ac:	89 4d d0             	mov    %ecx,-0x30(%ebp)
    __list_add(elm, listelm->prev, listelm);
  1054af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1054b2:	8b 00                	mov    (%eax),%eax
  1054b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1054b7:	89 55 cc             	mov    %edx,-0x34(%ebp)
  1054ba:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1054bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1054c0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
  1054c3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1054c6:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1054c9:	89 10                	mov    %edx,(%eax)
  1054cb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1054ce:	8b 10                	mov    (%eax),%edx
  1054d0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1054d3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1054d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1054d9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1054dc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1054df:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1054e2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1054e5:	89 10                	mov    %edx,(%eax)
	    p+=(1<<level);
  1054e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1054ea:	ba 14 00 00 00       	mov    $0x14,%edx
  1054ef:	88 c1                	mov    %al,%cl
  1054f1:	d3 e2                	shl    %cl,%edx
  1054f3:	89 d0                	mov    %edx,%eax
  1054f5:	01 45 f4             	add    %eax,-0xc(%ebp)
	    free_area[level].nr_free++;
  1054f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1054fb:	89 d0                	mov    %edx,%eax
  1054fd:	01 c0                	add    %eax,%eax
  1054ff:	01 d0                	add    %edx,%eax
  105501:	c1 e0 02             	shl    $0x2,%eax
  105504:	05 28 df 11 00       	add    $0x11df28,%eax
  105509:	8b 00                	mov    (%eax),%eax
  10550b:	8d 48 01             	lea    0x1(%eax),%ecx
  10550e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105511:	89 d0                	mov    %edx,%eax
  105513:	01 c0                	add    %eax,%eax
  105515:	01 d0                	add    %edx,%eax
  105517:	c1 e0 02             	shl    $0x2,%eax
  10551a:	05 28 df 11 00       	add    $0x11df28,%eax
  10551f:	89 08                	mov    %ecx,(%eax)
	for(int i=0;i<temp/(1<<level);i++){
  105521:	ff 45 e8             	incl   -0x18(%ebp)
  105524:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105527:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10552a:	88 c1                	mov    %al,%cl
  10552c:	d3 ea                	shr    %cl,%edx
  10552e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105531:	39 c2                	cmp    %eax,%edx
  105533:	0f 87 24 ff ff ff    	ja     10545d <buddy_init_memmap+0xf6>
	}
	temp = temp % (1 << level);
  105539:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10553c:	ba 01 00 00 00       	mov    $0x1,%edx
  105541:	88 c1                	mov    %al,%cl
  105543:	d3 e2                	shl    %cl,%edx
  105545:	89 d0                	mov    %edx,%eax
  105547:	48                   	dec    %eax
  105548:	21 45 f0             	and    %eax,-0x10(%ebp)
	level--;
  10554b:	ff 4d ec             	decl   -0x14(%ebp)
     while(level>=0){
  10554e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  105552:	0f 89 f9 fe ff ff    	jns    105451 <buddy_init_memmap+0xea>
     }
}
  105558:	90                   	nop
  105559:	c9                   	leave  
  10555a:	c3                   	ret    

0010555b <buddy_my_partial>:

static void
buddy_my_partial(struct Page *base, size_t n, int level) {
  10555b:	55                   	push   %ebp
  10555c:	89 e5                	mov    %esp,%ebp
  10555e:	83 ec 78             	sub    $0x78,%esp
    if (level < 0) return;
  105561:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105565:	0f 88 20 02 00 00    	js     10578b <buddy_my_partial+0x230>
    size_t temp = n;
  10556b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10556e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (level >= 0) {
  105571:	e9 7a 01 00 00       	jmp    1056f0 <buddy_my_partial+0x195>
        for (int i = 0; i < temp / (1 << level); i++) {
  105576:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  10557d:	e9 44 01 00 00       	jmp    1056c6 <buddy_my_partial+0x16b>
            base->property = (1 << level);
  105582:	8b 45 10             	mov    0x10(%ebp),%eax
  105585:	ba 01 00 00 00       	mov    $0x1,%edx
  10558a:	88 c1                	mov    %al,%cl
  10558c:	d3 e2                	shl    %cl,%edx
  10558e:	89 d0                	mov    %edx,%eax
  105590:	89 c2                	mov    %eax,%edx
  105592:	8b 45 08             	mov    0x8(%ebp),%eax
  105595:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(base);
  105598:	8b 45 08             	mov    0x8(%ebp),%eax
  10559b:	83 c0 04             	add    $0x4,%eax
  10559e:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  1055a5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1055a8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1055ab:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1055ae:	0f ab 10             	bts    %edx,(%eax)
            // add pages in order
            struct Page* p = NULL;
  1055b1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
            list_entry_t* le = list_next(&(free_area[level].free_list));
  1055b8:	8b 55 10             	mov    0x10(%ebp),%edx
  1055bb:	89 d0                	mov    %edx,%eax
  1055bd:	01 c0                	add    %eax,%eax
  1055bf:	01 d0                	add    %edx,%eax
  1055c1:	c1 e0 02             	shl    $0x2,%eax
  1055c4:	05 20 df 11 00       	add    $0x11df20,%eax
  1055c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return listelm->next;
  1055cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1055cf:	8b 40 04             	mov    0x4(%eax),%eax
  1055d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1055d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1055d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return listelm->prev;
  1055db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1055de:	8b 00                	mov    (%eax),%eax
            list_entry_t* bfle = list_prev(le);
  1055e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
            while (le != &(free_area[level].free_list)) {
  1055e3:	eb 37                	jmp    10561c <buddy_my_partial+0xc1>
                p = le2page(le, page_link);
  1055e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1055e8:	83 e8 0c             	sub    $0xc,%eax
  1055eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
                if (base + base->property < le) break;
  1055ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1055f1:	8b 50 08             	mov    0x8(%eax),%edx
  1055f4:	89 d0                	mov    %edx,%eax
  1055f6:	c1 e0 02             	shl    $0x2,%eax
  1055f9:	01 d0                	add    %edx,%eax
  1055fb:	c1 e0 02             	shl    $0x2,%eax
  1055fe:	89 c2                	mov    %eax,%edx
  105600:	8b 45 08             	mov    0x8(%ebp),%eax
  105603:	01 d0                	add    %edx,%eax
  105605:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  105608:	77 2a                	ja     105634 <buddy_my_partial+0xd9>
                bfle = bfle->next;
  10560a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10560d:	8b 40 04             	mov    0x4(%eax),%eax
  105610:	89 45 e8             	mov    %eax,-0x18(%ebp)
                le = le->next;
  105613:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105616:	8b 40 04             	mov    0x4(%eax),%eax
  105619:	89 45 ec             	mov    %eax,-0x14(%ebp)
            while (le != &(free_area[level].free_list)) {
  10561c:	8b 55 10             	mov    0x10(%ebp),%edx
  10561f:	89 d0                	mov    %edx,%eax
  105621:	01 c0                	add    %eax,%eax
  105623:	01 d0                	add    %edx,%eax
  105625:	c1 e0 02             	shl    $0x2,%eax
  105628:	05 20 df 11 00       	add    $0x11df20,%eax
  10562d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  105630:	75 b3                	jne    1055e5 <buddy_my_partial+0x8a>
  105632:	eb 01                	jmp    105635 <buddy_my_partial+0xda>
                if (base + base->property < le) break;
  105634:	90                   	nop
            }
            list_add(bfle, &(base->page_link));
  105635:	8b 45 08             	mov    0x8(%ebp),%eax
  105638:	8d 50 0c             	lea    0xc(%eax),%edx
  10563b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10563e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  105641:	89 55 c0             	mov    %edx,-0x40(%ebp)
  105644:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105647:	89 45 bc             	mov    %eax,-0x44(%ebp)
  10564a:	8b 45 c0             	mov    -0x40(%ebp),%eax
  10564d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    __list_add(elm, listelm, listelm->next);
  105650:	8b 45 bc             	mov    -0x44(%ebp),%eax
  105653:	8b 40 04             	mov    0x4(%eax),%eax
  105656:	8b 55 b8             	mov    -0x48(%ebp),%edx
  105659:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  10565c:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10565f:	89 55 b0             	mov    %edx,-0x50(%ebp)
  105662:	89 45 ac             	mov    %eax,-0x54(%ebp)
    prev->next = next->prev = elm;
  105665:	8b 45 ac             	mov    -0x54(%ebp),%eax
  105668:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  10566b:	89 10                	mov    %edx,(%eax)
  10566d:	8b 45 ac             	mov    -0x54(%ebp),%eax
  105670:	8b 10                	mov    (%eax),%edx
  105672:	8b 45 b0             	mov    -0x50(%ebp),%eax
  105675:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  105678:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10567b:	8b 55 ac             	mov    -0x54(%ebp),%edx
  10567e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  105681:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  105684:	8b 55 b0             	mov    -0x50(%ebp),%edx
  105687:	89 10                	mov    %edx,(%eax)
            base += (1 << level);
  105689:	8b 45 10             	mov    0x10(%ebp),%eax
  10568c:	ba 14 00 00 00       	mov    $0x14,%edx
  105691:	88 c1                	mov    %al,%cl
  105693:	d3 e2                	shl    %cl,%edx
  105695:	89 d0                	mov    %edx,%eax
  105697:	01 45 08             	add    %eax,0x8(%ebp)
            free_area[level].nr_free++;
  10569a:	8b 55 10             	mov    0x10(%ebp),%edx
  10569d:	89 d0                	mov    %edx,%eax
  10569f:	01 c0                	add    %eax,%eax
  1056a1:	01 d0                	add    %edx,%eax
  1056a3:	c1 e0 02             	shl    $0x2,%eax
  1056a6:	05 28 df 11 00       	add    $0x11df28,%eax
  1056ab:	8b 00                	mov    (%eax),%eax
  1056ad:	8d 48 01             	lea    0x1(%eax),%ecx
  1056b0:	8b 55 10             	mov    0x10(%ebp),%edx
  1056b3:	89 d0                	mov    %edx,%eax
  1056b5:	01 c0                	add    %eax,%eax
  1056b7:	01 d0                	add    %edx,%eax
  1056b9:	c1 e0 02             	shl    $0x2,%eax
  1056bc:	05 28 df 11 00       	add    $0x11df28,%eax
  1056c1:	89 08                	mov    %ecx,(%eax)
        for (int i = 0; i < temp / (1 << level); i++) {
  1056c3:	ff 45 f0             	incl   -0x10(%ebp)
  1056c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1056c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1056cc:	88 c1                	mov    %al,%cl
  1056ce:	d3 ea                	shr    %cl,%edx
  1056d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056d3:	39 c2                	cmp    %eax,%edx
  1056d5:	0f 87 a7 fe ff ff    	ja     105582 <buddy_my_partial+0x27>
        }
        temp = temp % (1 << level);
  1056db:	8b 45 10             	mov    0x10(%ebp),%eax
  1056de:	ba 01 00 00 00       	mov    $0x1,%edx
  1056e3:	88 c1                	mov    %al,%cl
  1056e5:	d3 e2                	shl    %cl,%edx
  1056e7:	89 d0                	mov    %edx,%eax
  1056e9:	48                   	dec    %eax
  1056ea:	21 45 f4             	and    %eax,-0xc(%ebp)
        level--;
  1056ed:	ff 4d 10             	decl   0x10(%ebp)
    while (level >= 0) {
  1056f0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1056f4:	0f 89 7c fe ff ff    	jns    105576 <buddy_my_partial+0x1b>
    }
    cprintf("alloc_page check: \n");
  1056fa:	c7 04 24 3c 7e 10 00 	movl   $0x107e3c,(%esp)
  105701:	e8 8c ab ff ff       	call   100292 <cprintf>
    for (int i = MAXLEVEL; i >= 0; i--) {
  105706:	c7 45 e4 0c 00 00 00 	movl   $0xc,-0x1c(%ebp)
  10570d:	eb 74                	jmp    105783 <buddy_my_partial+0x228>
        list_entry_t* le = list_next(&(free_area[i].free_list));
  10570f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105712:	89 d0                	mov    %edx,%eax
  105714:	01 c0                	add    %eax,%eax
  105716:	01 d0                	add    %edx,%eax
  105718:	c1 e0 02             	shl    $0x2,%eax
  10571b:	05 20 df 11 00       	add    $0x11df20,%eax
  105720:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return listelm->next;
  105723:	8b 45 a8             	mov    -0x58(%ebp),%eax
  105726:	8b 40 04             	mov    0x4(%eax),%eax
  105729:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
  10572c:	eb 3c                	jmp    10576a <buddy_my_partial+0x20f>
            struct Page* page = le2page(le, page_link);
  10572e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105731:	83 e8 0c             	sub    $0xc,%eax
  105734:	89 45 dc             	mov    %eax,-0x24(%ebp)
            cprintf("%d - %llx\n", i, page->page_link);
  105737:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10573a:	8b 50 10             	mov    0x10(%eax),%edx
  10573d:	8b 40 0c             	mov    0xc(%eax),%eax
  105740:	89 44 24 08          	mov    %eax,0x8(%esp)
  105744:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105748:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10574b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10574f:	c7 04 24 50 7e 10 00 	movl   $0x107e50,(%esp)
  105756:	e8 37 ab ff ff       	call   100292 <cprintf>
  10575b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10575e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  105761:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  105764:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
  105767:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
  10576a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10576d:	89 d0                	mov    %edx,%eax
  10576f:	01 c0                	add    %eax,%eax
  105771:	01 d0                	add    %edx,%eax
  105773:	c1 e0 02             	shl    $0x2,%eax
  105776:	05 20 df 11 00       	add    $0x11df20,%eax
  10577b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  10577e:	75 ae                	jne    10572e <buddy_my_partial+0x1d3>
    for (int i = MAXLEVEL; i >= 0; i--) {
  105780:	ff 4d e4             	decl   -0x1c(%ebp)
  105783:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105787:	79 86                	jns    10570f <buddy_my_partial+0x1b4>
  105789:	eb 01                	jmp    10578c <buddy_my_partial+0x231>
    if (level < 0) return;
  10578b:	90                   	nop
        }
    }
}
  10578c:	c9                   	leave  
  10578d:	c3                   	ret    

0010578e <buddy_my_merge>:

static void
buddy_my_merge(int level) {
  10578e:	55                   	push   %ebp
  10578f:	89 e5                	mov    %esp,%ebp
  105791:	83 ec 68             	sub    $0x68,%esp
    cprintf("before merge.\n");
  105794:	c7 04 24 5b 7e 10 00 	movl   $0x107e5b,(%esp)
  10579b:	e8 f2 aa ff ff       	call   100292 <cprintf>
    //bds_selfcheck();
    while (level < MAXLEVEL) {
  1057a0:	e9 dc 01 00 00       	jmp    105981 <buddy_my_merge+0x1f3>
        if (free_area[level].nr_free <= 1) {
  1057a5:	8b 55 08             	mov    0x8(%ebp),%edx
  1057a8:	89 d0                	mov    %edx,%eax
  1057aa:	01 c0                	add    %eax,%eax
  1057ac:	01 d0                	add    %edx,%eax
  1057ae:	c1 e0 02             	shl    $0x2,%eax
  1057b1:	05 28 df 11 00       	add    $0x11df28,%eax
  1057b6:	8b 00                	mov    (%eax),%eax
  1057b8:	83 f8 01             	cmp    $0x1,%eax
  1057bb:	77 08                	ja     1057c5 <buddy_my_merge+0x37>
            level++;
  1057bd:	ff 45 08             	incl   0x8(%ebp)
            continue;
  1057c0:	e9 bc 01 00 00       	jmp    105981 <buddy_my_merge+0x1f3>
        }
        list_entry_t* le = list_next(&(free_area[level].free_list));
  1057c5:	8b 55 08             	mov    0x8(%ebp),%edx
  1057c8:	89 d0                	mov    %edx,%eax
  1057ca:	01 c0                	add    %eax,%eax
  1057cc:	01 d0                	add    %edx,%eax
  1057ce:	c1 e0 02             	shl    $0x2,%eax
  1057d1:	05 20 df 11 00       	add    $0x11df20,%eax
  1057d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1057d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1057dc:	8b 40 04             	mov    0x4(%eax),%eax
  1057df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1057e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1057e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->prev;
  1057e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1057eb:	8b 00                	mov    (%eax),%eax
        list_entry_t* bfle = list_prev(le);
  1057ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while (le != &(free_area[level].free_list)) {
  1057f0:	e9 6f 01 00 00       	jmp    105964 <buddy_my_merge+0x1d6>
  1057f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return listelm->next;
  1057fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1057fe:	8b 40 04             	mov    0x4(%eax),%eax
            bfle = list_next(bfle);
  105801:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105804:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105807:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10580a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10580d:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
  105810:	89 45 f4             	mov    %eax,-0xc(%ebp)
            struct Page* ple = le2page(le, page_link);
  105813:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105816:	83 e8 0c             	sub    $0xc,%eax
  105819:	89 45 ec             	mov    %eax,-0x14(%ebp)
            struct Page* pbf = le2page(bfle, page_link); 
  10581c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10581f:	83 e8 0c             	sub    $0xc,%eax
  105822:	89 45 e8             	mov    %eax,-0x18(%ebp)
            cprintf("bfle addr is: %llx\n", pbf->page_link);
  105825:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105828:	8b 50 10             	mov    0x10(%eax),%edx
  10582b:	8b 40 0c             	mov    0xc(%eax),%eax
  10582e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105832:	89 54 24 08          	mov    %edx,0x8(%esp)
  105836:	c7 04 24 6a 7e 10 00 	movl   $0x107e6a,(%esp)
  10583d:	e8 50 aa ff ff       	call   100292 <cprintf>
            cprintf("le addr is: %llx\n", ple->page_link);
  105842:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105845:	8b 50 10             	mov    0x10(%eax),%edx
  105848:	8b 40 0c             	mov    0xc(%eax),%eax
  10584b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10584f:	89 54 24 08          	mov    %edx,0x8(%esp)
  105853:	c7 04 24 7e 7e 10 00 	movl   $0x107e7e,(%esp)
  10585a:	e8 33 aa ff ff       	call   100292 <cprintf>
            if (pbf + pbf->property == ple) {            
  10585f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105862:	8b 50 08             	mov    0x8(%eax),%edx
  105865:	89 d0                	mov    %edx,%eax
  105867:	c1 e0 02             	shl    $0x2,%eax
  10586a:	01 d0                	add    %edx,%eax
  10586c:	c1 e0 02             	shl    $0x2,%eax
  10586f:	89 c2                	mov    %eax,%edx
  105871:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105874:	01 d0                	add    %edx,%eax
  105876:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  105879:	0f 85 e5 00 00 00    	jne    105964 <buddy_my_merge+0x1d6>
  10587f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105882:	89 45 b0             	mov    %eax,-0x50(%ebp)
  105885:	8b 45 b0             	mov    -0x50(%ebp),%eax
  105888:	8b 40 04             	mov    0x4(%eax),%eax
                bfle = list_next(bfle);
  10588b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10588e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105891:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  105894:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  105897:	8b 40 04             	mov    0x4(%eax),%eax
                le = list_next(le);
  10589a:	89 45 f4             	mov    %eax,-0xc(%ebp)
                pbf->property = pbf->property << 1;
  10589d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1058a0:	8b 40 08             	mov    0x8(%eax),%eax
  1058a3:	8d 14 00             	lea    (%eax,%eax,1),%edx
  1058a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1058a9:	89 50 08             	mov    %edx,0x8(%eax)
                ClearPageProperty(ple);
  1058ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1058af:	83 c0 04             	add    $0x4,%eax
  1058b2:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  1058b9:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1058bc:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1058bf:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1058c2:	0f b3 10             	btr    %edx,(%eax)
                list_del(&(pbf->page_link));
  1058c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1058c8:	83 c0 0c             	add    $0xc,%eax
  1058cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_del(listelm->prev, listelm->next);
  1058ce:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1058d1:	8b 40 04             	mov    0x4(%eax),%eax
  1058d4:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1058d7:	8b 12                	mov    (%edx),%edx
  1058d9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  1058dc:	89 45 c0             	mov    %eax,-0x40(%ebp)
    prev->next = next;
  1058df:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1058e2:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1058e5:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1058e8:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1058eb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1058ee:	89 10                	mov    %edx,(%eax)
                list_del(&(ple->page_link));
  1058f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1058f3:	83 c0 0c             	add    $0xc,%eax
  1058f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_del(listelm->prev, listelm->next);
  1058f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1058fc:	8b 40 04             	mov    0x4(%eax),%eax
  1058ff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105902:	8b 12                	mov    (%edx),%edx
  105904:	89 55 d0             	mov    %edx,-0x30(%ebp)
  105907:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next;
  10590a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10590d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  105910:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  105913:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105916:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105919:	89 10                	mov    %edx,(%eax)
                buddy_my_partial(pbf, pbf->property, level + 1);             
  10591b:	8b 45 08             	mov    0x8(%ebp),%eax
  10591e:	8d 50 01             	lea    0x1(%eax),%edx
  105921:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105924:	8b 40 08             	mov    0x8(%eax),%eax
  105927:	89 54 24 08          	mov    %edx,0x8(%esp)
  10592b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10592f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105932:	89 04 24             	mov    %eax,(%esp)
  105935:	e8 21 fc ff ff       	call   10555b <buddy_my_partial>
                free_area[level].nr_free -= 2;              
  10593a:	8b 55 08             	mov    0x8(%ebp),%edx
  10593d:	89 d0                	mov    %edx,%eax
  10593f:	01 c0                	add    %eax,%eax
  105941:	01 d0                	add    %edx,%eax
  105943:	c1 e0 02             	shl    $0x2,%eax
  105946:	05 28 df 11 00       	add    $0x11df28,%eax
  10594b:	8b 00                	mov    (%eax),%eax
  10594d:	8d 48 fe             	lea    -0x2(%eax),%ecx
  105950:	8b 55 08             	mov    0x8(%ebp),%edx
  105953:	89 d0                	mov    %edx,%eax
  105955:	01 c0                	add    %eax,%eax
  105957:	01 d0                	add    %edx,%eax
  105959:	c1 e0 02             	shl    $0x2,%eax
  10595c:	05 28 df 11 00       	add    $0x11df28,%eax
  105961:	89 08                	mov    %ecx,(%eax)
                continue;
  105963:	90                   	nop
        while (le != &(free_area[level].free_list)) {
  105964:	8b 55 08             	mov    0x8(%ebp),%edx
  105967:	89 d0                	mov    %edx,%eax
  105969:	01 c0                	add    %eax,%eax
  10596b:	01 d0                	add    %edx,%eax
  10596d:	c1 e0 02             	shl    $0x2,%eax
  105970:	05 20 df 11 00       	add    $0x11df20,%eax
  105975:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  105978:	0f 85 77 fe ff ff    	jne    1057f5 <buddy_my_merge+0x67>
            } 
        }
        level++;
  10597e:	ff 45 08             	incl   0x8(%ebp)
    while (level < MAXLEVEL) {
  105981:	83 7d 08 0b          	cmpl   $0xb,0x8(%ebp)
  105985:	0f 8e 1a fe ff ff    	jle    1057a5 <buddy_my_merge+0x17>
    }
    //bds_selfcheck();
}
  10598b:	90                   	nop
  10598c:	c9                   	leave  
  10598d:	c3                   	ret    

0010598e <buddy_alloc_page>:

static struct Page*
buddy_alloc_page(size_t n){
  10598e:	55                   	push   %ebp
  10598f:	89 e5                	mov    %esp,%ebp
  105991:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
  105994:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105998:	75 24                	jne    1059be <buddy_alloc_page+0x30>
  10599a:	c7 44 24 0c fc 7d 10 	movl   $0x107dfc,0xc(%esp)
  1059a1:	00 
  1059a2:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  1059a9:	00 
  1059aa:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  1059b1:	00 
  1059b2:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  1059b9:	e8 2b aa ff ff       	call   1003e9 <__panic>
     if(n>buddy_nr_free_page()){
  1059be:	e8 67 f9 ff ff       	call   10532a <buddy_nr_free_page>
  1059c3:	39 45 08             	cmp    %eax,0x8(%ebp)
  1059c6:	76 0a                	jbe    1059d2 <buddy_alloc_page+0x44>
	return NULL;
  1059c8:	b8 00 00 00 00       	mov    $0x0,%eax
  1059cd:	e9 62 01 00 00       	jmp    105b34 <buddy_alloc_page+0x1a6>
     }
     int level=0;
  1059d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     while((1<<level)<n){
  1059d9:	eb 03                	jmp    1059de <buddy_alloc_page+0x50>
	level++;
  1059db:	ff 45 f4             	incl   -0xc(%ebp)
     while((1<<level)<n){
  1059de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1059e1:	ba 01 00 00 00       	mov    $0x1,%edx
  1059e6:	88 c1                	mov    %al,%cl
  1059e8:	d3 e2                	shl    %cl,%edx
  1059ea:	89 d0                	mov    %edx,%eax
  1059ec:	39 45 08             	cmp    %eax,0x8(%ebp)
  1059ef:	77 ea                	ja     1059db <buddy_alloc_page+0x4d>
     }
     //n=1<<level;
     for(int i=level;i<=MAXLEVEL;i++){
  1059f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1059f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059f7:	eb 22                	jmp    105a1b <buddy_alloc_page+0x8d>
	if(free_area[i].nr_free!=0){
  1059f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1059fc:	89 d0                	mov    %edx,%eax
  1059fe:	01 c0                	add    %eax,%eax
  105a00:	01 d0                	add    %edx,%eax
  105a02:	c1 e0 02             	shl    $0x2,%eax
  105a05:	05 28 df 11 00       	add    $0x11df28,%eax
  105a0a:	8b 00                	mov    (%eax),%eax
  105a0c:	85 c0                	test   %eax,%eax
  105a0e:	74 08                	je     105a18 <buddy_alloc_page+0x8a>
	   level=i;
  105a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    break;
  105a16:	eb 09                	jmp    105a21 <buddy_alloc_page+0x93>
     for(int i=level;i<=MAXLEVEL;i++){
  105a18:	ff 45 f0             	incl   -0x10(%ebp)
  105a1b:	83 7d f0 0c          	cmpl   $0xc,-0x10(%ebp)
  105a1f:	7e d8                	jle    1059f9 <buddy_alloc_page+0x6b>
	}
     }
     if(level>MAXLEVEL){return NULL;}
  105a21:	83 7d f4 0c          	cmpl   $0xc,-0xc(%ebp)
  105a25:	7e 0a                	jle    105a31 <buddy_alloc_page+0xa3>
  105a27:	b8 00 00 00 00       	mov    $0x0,%eax
  105a2c:	e9 03 01 00 00       	jmp    105b34 <buddy_alloc_page+0x1a6>
     list_entry_t *le=&free_area[level].free_list;
  105a31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105a34:	89 d0                	mov    %edx,%eax
  105a36:	01 c0                	add    %eax,%eax
  105a38:	01 d0                	add    %edx,%eax
  105a3a:	c1 e0 02             	shl    $0x2,%eax
  105a3d:	05 20 df 11 00       	add    $0x11df20,%eax
  105a42:	89 45 ec             	mov    %eax,-0x14(%ebp)
     struct Page* page=le2page(le,page_link);
  105a45:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a48:	83 e8 0c             	sub    $0xc,%eax
  105a4b:	89 45 e8             	mov    %eax,-0x18(%ebp)
     if (page != NULL) {
  105a4e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105a52:	0f 84 cd 00 00 00    	je     105b25 <buddy_alloc_page+0x197>
        SetPageReserved(page);
  105a58:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a5b:	83 c0 04             	add    $0x4,%eax
  105a5e:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  105a65:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105a68:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105a6b:	8b 55 c8             	mov    -0x38(%ebp),%edx
  105a6e:	0f ab 10             	bts    %edx,(%eax)
        // deal with partial work
        buddy_my_partial(page, page->property - n, level - 1);
  105a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105a74:	8d 50 ff             	lea    -0x1(%eax),%edx
  105a77:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a7a:	8b 40 08             	mov    0x8(%eax),%eax
  105a7d:	2b 45 08             	sub    0x8(%ebp),%eax
  105a80:	89 54 24 08          	mov    %edx,0x8(%esp)
  105a84:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a88:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a8b:	89 04 24             	mov    %eax,(%esp)
  105a8e:	e8 c8 fa ff ff       	call   10555b <buddy_my_partial>
        ClearPageReserved(page);
  105a93:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a96:	83 c0 04             	add    $0x4,%eax
  105a99:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  105aa0:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105aa3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105aa6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105aa9:	0f b3 10             	btr    %edx,(%eax)
        ClearPageProperty(page);
  105aac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105aaf:	83 c0 04             	add    $0x4,%eax
  105ab2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
  105ab9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  105abc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105abf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105ac2:	0f b3 10             	btr    %edx,(%eax)
        list_del(&(page->page_link));
  105ac5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ac8:	83 c0 0c             	add    $0xc,%eax
  105acb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
  105ace:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105ad1:	8b 40 04             	mov    0x4(%eax),%eax
  105ad4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105ad7:	8b 12                	mov    (%edx),%edx
  105ad9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  105adc:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
  105adf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ae2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105ae5:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  105ae8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105aeb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105aee:	89 10                	mov    %edx,(%eax)
        free_area[level].nr_free--;
  105af0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105af3:	89 d0                	mov    %edx,%eax
  105af5:	01 c0                	add    %eax,%eax
  105af7:	01 d0                	add    %edx,%eax
  105af9:	c1 e0 02             	shl    $0x2,%eax
  105afc:	05 28 df 11 00       	add    $0x11df28,%eax
  105b01:	8b 00                	mov    (%eax),%eax
  105b03:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105b06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105b09:	89 d0                	mov    %edx,%eax
  105b0b:	01 c0                	add    %eax,%eax
  105b0d:	01 d0                	add    %edx,%eax
  105b0f:	c1 e0 02             	shl    $0x2,%eax
  105b12:	05 28 df 11 00       	add    $0x11df28,%eax
  105b17:	89 08                	mov    %ecx,(%eax)
        buddy_my_merge(0);
  105b19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  105b20:	e8 69 fc ff ff       	call   10578e <buddy_my_merge>
    }
    cprintf("after allocate & merge\n");
  105b25:	c7 04 24 90 7e 10 00 	movl   $0x107e90,(%esp)
  105b2c:	e8 61 a7 ff ff       	call   100292 <cprintf>
    //bds_selfcheck();
    return page;
  105b31:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
  105b34:	c9                   	leave  
  105b35:	c3                   	ret    

00105b36 <buddy_free_page>:

static void 
buddy_free_page(struct Page* base, size_t n){
  105b36:	55                   	push   %ebp
  105b37:	89 e5                	mov    %esp,%ebp
  105b39:	83 ec 48             	sub    $0x48,%esp
     assert(n > 0);
  105b3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105b40:	75 24                	jne    105b66 <buddy_free_page+0x30>
  105b42:	c7 44 24 0c a8 7e 10 	movl   $0x107ea8,0xc(%esp)
  105b49:	00 
  105b4a:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  105b51:	00 
  105b52:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
  105b59:	00 
  105b5a:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  105b61:	e8 83 a8 ff ff       	call   1003e9 <__panic>
    struct Page* p = base;
  105b66:	8b 45 08             	mov    0x8(%ebp),%eax
  105b69:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++) {
  105b6c:	e9 9d 00 00 00       	jmp    105c0e <buddy_free_page+0xd8>
        assert(!PageReserved(p) && !PageProperty(p));
  105b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105b74:	83 c0 04             	add    $0x4,%eax
  105b77:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  105b7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105b81:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105b84:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105b87:	0f a3 10             	bt     %edx,(%eax)
  105b8a:	19 c0                	sbb    %eax,%eax
  105b8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  105b8f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105b93:	0f 95 c0             	setne  %al
  105b96:	0f b6 c0             	movzbl %al,%eax
  105b99:	85 c0                	test   %eax,%eax
  105b9b:	75 2c                	jne    105bc9 <buddy_free_page+0x93>
  105b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105ba0:	83 c0 04             	add    $0x4,%eax
  105ba3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  105baa:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105bad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105bb0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105bb3:	0f a3 10             	bt     %edx,(%eax)
  105bb6:	19 c0                	sbb    %eax,%eax
  105bb8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  105bbb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  105bbf:	0f 95 c0             	setne  %al
  105bc2:	0f b6 c0             	movzbl %al,%eax
  105bc5:	85 c0                	test   %eax,%eax
  105bc7:	74 24                	je     105bed <buddy_free_page+0xb7>
  105bc9:	c7 44 24 0c b0 7e 10 	movl   $0x107eb0,0xc(%esp)
  105bd0:	00 
  105bd1:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  105bd8:	00 
  105bd9:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  105be0:	00 
  105be1:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  105be8:	e8 fc a7 ff ff       	call   1003e9 <__panic>
        p->flags = 0;
  105bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105bf0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  105bf7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105bfe:	00 
  105bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105c02:	89 04 24             	mov    %eax,(%esp)
  105c05:	e8 b8 f6 ff ff       	call   1052c2 <set_page_ref>
    for (; p != base + n; p++) {
  105c0a:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  105c0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  105c11:	89 d0                	mov    %edx,%eax
  105c13:	c1 e0 02             	shl    $0x2,%eax
  105c16:	01 d0                	add    %edx,%eax
  105c18:	c1 e0 02             	shl    $0x2,%eax
  105c1b:	89 c2                	mov    %eax,%edx
  105c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  105c20:	01 d0                	add    %edx,%eax
  105c22:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  105c25:	0f 85 46 ff ff ff    	jne    105b71 <buddy_free_page+0x3b>
    }
    // free pages
    base->property = n;
  105c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  105c2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  105c31:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  105c34:	8b 45 08             	mov    0x8(%ebp),%eax
  105c37:	83 c0 04             	add    $0x4,%eax
  105c3a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  105c41:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105c44:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105c47:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105c4a:	0f ab 10             	bts    %edx,(%eax)
    int level = 0;
  105c4d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    while ((1 << level) != n) { level++; }
  105c54:	eb 03                	jmp    105c59 <buddy_free_page+0x123>
  105c56:	ff 45 f0             	incl   -0x10(%ebp)
  105c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c5c:	ba 01 00 00 00       	mov    $0x1,%edx
  105c61:	88 c1                	mov    %al,%cl
  105c63:	d3 e2                	shl    %cl,%edx
  105c65:	89 d0                	mov    %edx,%eax
  105c67:	39 45 0c             	cmp    %eax,0xc(%ebp)
  105c6a:	75 ea                	jne    105c56 <buddy_free_page+0x120>
    buddy_my_partial(base, n, level);
  105c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  105c73:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c76:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  105c7d:	89 04 24             	mov    %eax,(%esp)
  105c80:	e8 d6 f8 ff ff       	call   10555b <buddy_my_partial>
    //bds_selfcheck();
    free_area[level].nr_free++;
  105c85:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105c88:	89 d0                	mov    %edx,%eax
  105c8a:	01 c0                	add    %eax,%eax
  105c8c:	01 d0                	add    %edx,%eax
  105c8e:	c1 e0 02             	shl    $0x2,%eax
  105c91:	05 28 df 11 00       	add    $0x11df28,%eax
  105c96:	8b 00                	mov    (%eax),%eax
  105c98:	8d 48 01             	lea    0x1(%eax),%ecx
  105c9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105c9e:	89 d0                	mov    %edx,%eax
  105ca0:	01 c0                	add    %eax,%eax
  105ca2:	01 d0                	add    %edx,%eax
  105ca4:	c1 e0 02             	shl    $0x2,%eax
  105ca7:	05 28 df 11 00       	add    $0x11df28,%eax
  105cac:	89 08                	mov    %ecx,(%eax)
    buddy_my_merge(level); 
  105cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105cb1:	89 04 24             	mov    %eax,(%esp)
  105cb4:	e8 d5 fa ff ff       	call   10578e <buddy_my_merge>
    //buddy_selfcheck();
}
  105cb9:	90                   	nop
  105cba:	c9                   	leave  
  105cbb:	c3                   	ret    

00105cbc <buddy_check>:

static void
buddy_check(void) {
  105cbc:	55                   	push   %ebp
  105cbd:	89 e5                	mov    %esp,%ebp
  105cbf:	81 ec f8 00 00 00    	sub    $0xf8,%esp
    int count = 0, total = 0;
  105cc5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  105ccc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) {
  105cd3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  105cda:	e9 a4 00 00 00       	jmp    105d83 <buddy_check+0xc7>
        list_entry_t* free_list = &(free_area[i].free_list);
  105cdf:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105ce2:	89 d0                	mov    %edx,%eax
  105ce4:	01 c0                	add    %eax,%eax
  105ce6:	01 d0                	add    %edx,%eax
  105ce8:	c1 e0 02             	shl    $0x2,%eax
  105ceb:	05 20 df 11 00       	add    $0x11df20,%eax
  105cf0:	89 45 d0             	mov    %eax,-0x30(%ebp)
        list_entry_t* le = free_list;
  105cf3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105cf6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        while ((le = list_next(le)) != free_list) {
  105cf9:	eb 6a                	jmp    105d65 <buddy_check+0xa9>
            struct Page* p = le2page(le, page_link);
  105cfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105cfe:	83 e8 0c             	sub    $0xc,%eax
  105d01:	89 45 cc             	mov    %eax,-0x34(%ebp)
            assert(PageProperty(p));
  105d04:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105d07:	83 c0 04             	add    $0x4,%eax
  105d0a:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  105d11:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105d14:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105d17:	8b 55 c8             	mov    -0x38(%ebp),%edx
  105d1a:	0f a3 10             	bt     %edx,(%eax)
  105d1d:	19 c0                	sbb    %eax,%eax
  105d1f:	89 45 c0             	mov    %eax,-0x40(%ebp)
    return oldbit != 0;
  105d22:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  105d26:	0f 95 c0             	setne  %al
  105d29:	0f b6 c0             	movzbl %al,%eax
  105d2c:	85 c0                	test   %eax,%eax
  105d2e:	75 24                	jne    105d54 <buddy_check+0x98>
  105d30:	c7 44 24 0c d5 7e 10 	movl   $0x107ed5,0xc(%esp)
  105d37:	00 
  105d38:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  105d3f:	00 
  105d40:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  105d47:	00 
  105d48:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  105d4f:	e8 95 a6 ff ff       	call   1003e9 <__panic>
            count++;
  105d54:	ff 45 f4             	incl   -0xc(%ebp)
            total += p->property;
  105d57:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105d5a:	8b 50 08             	mov    0x8(%eax),%edx
  105d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d60:	01 d0                	add    %edx,%eax
  105d62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d65:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105d68:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return listelm->next;
  105d6b:	8b 45 bc             	mov    -0x44(%ebp),%eax
  105d6e:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != free_list) {
  105d71:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105d74:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105d77:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  105d7a:	0f 85 7b ff ff ff    	jne    105cfb <buddy_check+0x3f>
    for (int i = 0; i <= MAXLEVEL; i++) {
  105d80:	ff 45 ec             	incl   -0x14(%ebp)
  105d83:	83 7d ec 0c          	cmpl   $0xc,-0x14(%ebp)
  105d87:	0f 8e 52 ff ff ff    	jle    105cdf <buddy_check+0x23>
        }
    }
    assert(total == buddy_nr_free_page());
  105d8d:	e8 98 f5 ff ff       	call   10532a <buddy_nr_free_page>
  105d92:	89 c2                	mov    %eax,%edx
  105d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d97:	39 c2                	cmp    %eax,%edx
  105d99:	74 24                	je     105dbf <buddy_check+0x103>
  105d9b:	c7 44 24 0c e5 7e 10 	movl   $0x107ee5,0xc(%esp)
  105da2:	00 
  105da3:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  105daa:	00 
  105dab:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
  105db2:	00 
  105db3:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  105dba:	e8 2a a6 ff ff       	call   1003e9 <__panic>

    // basic check
    struct Page *p0, *p1, *p2;
    p0 = p1 =p2 = NULL;
  105dbf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105dc6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105dc9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  105dcc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105dcf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("p0\n");
  105dd2:	c7 04 24 03 7f 10 00 	movl   $0x107f03,(%esp)
  105dd9:	e8 b4 a4 ff ff       	call   100292 <cprintf>
    assert((p0 = alloc_page()) != NULL);
  105dde:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105de5:	e8 5f cd ff ff       	call   102b49 <alloc_pages>
  105dea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  105ded:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  105df1:	75 24                	jne    105e17 <buddy_check+0x15b>
  105df3:	c7 44 24 0c 07 7f 10 	movl   $0x107f07,0xc(%esp)
  105dfa:	00 
  105dfb:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  105e02:	00 
  105e03:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  105e0a:	00 
  105e0b:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  105e12:	e8 d2 a5 ff ff       	call   1003e9 <__panic>
    cprintf("p1\n");
  105e17:	c7 04 24 23 7f 10 00 	movl   $0x107f23,(%esp)
  105e1e:	e8 6f a4 ff ff       	call   100292 <cprintf>
    assert((p1 = alloc_page()) != NULL);
  105e23:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105e2a:	e8 1a cd ff ff       	call   102b49 <alloc_pages>
  105e2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  105e32:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  105e36:	75 24                	jne    105e5c <buddy_check+0x1a0>
  105e38:	c7 44 24 0c 27 7f 10 	movl   $0x107f27,0xc(%esp)
  105e3f:	00 
  105e40:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  105e47:	00 
  105e48:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  105e4f:	00 
  105e50:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  105e57:	e8 8d a5 ff ff       	call   1003e9 <__panic>
    cprintf("p2\n");
  105e5c:	c7 04 24 43 7f 10 00 	movl   $0x107f43,(%esp)
  105e63:	e8 2a a4 ff ff       	call   100292 <cprintf>
    assert((p2 = alloc_page()) != NULL);
  105e68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105e6f:	e8 d5 cc ff ff       	call   102b49 <alloc_pages>
  105e74:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105e77:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105e7b:	75 24                	jne    105ea1 <buddy_check+0x1e5>
  105e7d:	c7 44 24 0c 47 7f 10 	movl   $0x107f47,0xc(%esp)
  105e84:	00 
  105e85:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  105e8c:	00 
  105e8d:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
  105e94:	00 
  105e95:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  105e9c:	e8 48 a5 ff ff       	call   1003e9 <__panic>

    assert(p0 != p1 && p1 != p2 && p2 != p0);
  105ea1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105ea4:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  105ea7:	74 10                	je     105eb9 <buddy_check+0x1fd>
  105ea9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105eac:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  105eaf:	74 08                	je     105eb9 <buddy_check+0x1fd>
  105eb1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105eb4:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  105eb7:	75 24                	jne    105edd <buddy_check+0x221>
  105eb9:	c7 44 24 0c 64 7f 10 	movl   $0x107f64,0xc(%esp)
  105ec0:	00 
  105ec1:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  105ec8:	00 
  105ec9:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  105ed0:	00 
  105ed1:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  105ed8:	e8 0c a5 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  105edd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105ee0:	89 04 24             	mov    %eax,(%esp)
  105ee3:	e8 d0 f3 ff ff       	call   1052b8 <page_ref>
  105ee8:	85 c0                	test   %eax,%eax
  105eea:	75 1e                	jne    105f0a <buddy_check+0x24e>
  105eec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105eef:	89 04 24             	mov    %eax,(%esp)
  105ef2:	e8 c1 f3 ff ff       	call   1052b8 <page_ref>
  105ef7:	85 c0                	test   %eax,%eax
  105ef9:	75 0f                	jne    105f0a <buddy_check+0x24e>
  105efb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105efe:	89 04 24             	mov    %eax,(%esp)
  105f01:	e8 b2 f3 ff ff       	call   1052b8 <page_ref>
  105f06:	85 c0                	test   %eax,%eax
  105f08:	74 24                	je     105f2e <buddy_check+0x272>
  105f0a:	c7 44 24 0c 88 7f 10 	movl   $0x107f88,0xc(%esp)
  105f11:	00 
  105f12:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  105f19:	00 
  105f1a:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
  105f21:	00 
  105f22:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  105f29:	e8 bb a4 ff ff       	call   1003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  105f2e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105f31:	89 04 24             	mov    %eax,(%esp)
  105f34:	e8 69 f3 ff ff       	call   1052a2 <page2pa>
  105f39:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  105f3f:	c1 e2 0c             	shl    $0xc,%edx
  105f42:	39 d0                	cmp    %edx,%eax
  105f44:	72 24                	jb     105f6a <buddy_check+0x2ae>
  105f46:	c7 44 24 0c c4 7f 10 	movl   $0x107fc4,0xc(%esp)
  105f4d:	00 
  105f4e:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  105f55:	00 
  105f56:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  105f5d:	00 
  105f5e:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  105f65:	e8 7f a4 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  105f6a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105f6d:	89 04 24             	mov    %eax,(%esp)
  105f70:	e8 2d f3 ff ff       	call   1052a2 <page2pa>
  105f75:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  105f7b:	c1 e2 0c             	shl    $0xc,%edx
  105f7e:	39 d0                	cmp    %edx,%eax
  105f80:	72 24                	jb     105fa6 <buddy_check+0x2ea>
  105f82:	c7 44 24 0c e1 7f 10 	movl   $0x107fe1,0xc(%esp)
  105f89:	00 
  105f8a:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  105f91:	00 
  105f92:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  105f99:	00 
  105f9a:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  105fa1:	e8 43 a4 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  105fa6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105fa9:	89 04 24             	mov    %eax,(%esp)
  105fac:	e8 f1 f2 ff ff       	call   1052a2 <page2pa>
  105fb1:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  105fb7:	c1 e2 0c             	shl    $0xc,%edx
  105fba:	39 d0                	cmp    %edx,%eax
  105fbc:	72 24                	jb     105fe2 <buddy_check+0x326>
  105fbe:	c7 44 24 0c fe 7f 10 	movl   $0x107ffe,0xc(%esp)
  105fc5:	00 
  105fc6:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  105fcd:	00 
  105fce:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  105fd5:	00 
  105fd6:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  105fdd:	e8 07 a4 ff ff       	call   1003e9 <__panic>
    cprintf("first part of check successfully.\n");
  105fe2:	c7 04 24 1c 80 10 00 	movl   $0x10801c,(%esp)
  105fe9:	e8 a4 a2 ff ff       	call   100292 <cprintf>

    free_area_t temp_list[MAXLEVEL + 1];
    for (int i = 0; i <= MAXLEVEL; i++) {
  105fee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  105ff5:	e9 c5 00 00 00       	jmp    1060bf <buddy_check+0x403>
        temp_list[i] = free_area[i];
  105ffa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105ffd:	89 d0                	mov    %edx,%eax
  105fff:	01 c0                	add    %eax,%eax
  106001:	01 d0                	add    %edx,%eax
  106003:	c1 e0 02             	shl    $0x2,%eax
  106006:	8d 4d f8             	lea    -0x8(%ebp),%ecx
  106009:	01 c8                	add    %ecx,%eax
  10600b:	8d 90 20 ff ff ff    	lea    -0xe0(%eax),%edx
  106011:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  106014:	89 c8                	mov    %ecx,%eax
  106016:	01 c0                	add    %eax,%eax
  106018:	01 c8                	add    %ecx,%eax
  10601a:	c1 e0 02             	shl    $0x2,%eax
  10601d:	05 20 df 11 00       	add    $0x11df20,%eax
  106022:	8b 08                	mov    (%eax),%ecx
  106024:	89 0a                	mov    %ecx,(%edx)
  106026:	8b 48 04             	mov    0x4(%eax),%ecx
  106029:	89 4a 04             	mov    %ecx,0x4(%edx)
  10602c:	8b 40 08             	mov    0x8(%eax),%eax
  10602f:	89 42 08             	mov    %eax,0x8(%edx)
        list_init(&(free_area[i].free_list));
  106032:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106035:	89 d0                	mov    %edx,%eax
  106037:	01 c0                	add    %eax,%eax
  106039:	01 d0                	add    %edx,%eax
  10603b:	c1 e0 02             	shl    $0x2,%eax
  10603e:	05 20 df 11 00       	add    $0x11df20,%eax
  106043:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    elm->prev = elm->next = elm;
  106046:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  106049:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  10604c:	89 50 04             	mov    %edx,0x4(%eax)
  10604f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  106052:	8b 50 04             	mov    0x4(%eax),%edx
  106055:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  106058:	89 10                	mov    %edx,(%eax)
        assert(list_empty(&(free_area[i])));
  10605a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10605d:	89 d0                	mov    %edx,%eax
  10605f:	01 c0                	add    %eax,%eax
  106061:	01 d0                	add    %edx,%eax
  106063:	c1 e0 02             	shl    $0x2,%eax
  106066:	05 20 df 11 00       	add    $0x11df20,%eax
  10606b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return list->next == list;
  10606e:	8b 45 b8             	mov    -0x48(%ebp),%eax
  106071:	8b 40 04             	mov    0x4(%eax),%eax
  106074:	39 45 b8             	cmp    %eax,-0x48(%ebp)
  106077:	0f 94 c0             	sete   %al
  10607a:	0f b6 c0             	movzbl %al,%eax
  10607d:	85 c0                	test   %eax,%eax
  10607f:	75 24                	jne    1060a5 <buddy_check+0x3e9>
  106081:	c7 44 24 0c 3f 80 10 	movl   $0x10803f,0xc(%esp)
  106088:	00 
  106089:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  106090:	00 
  106091:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  106098:	00 
  106099:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  1060a0:	e8 44 a3 ff ff       	call   1003e9 <__panic>
        free_area[i].nr_free = 0;
  1060a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1060a8:	89 d0                	mov    %edx,%eax
  1060aa:	01 c0                	add    %eax,%eax
  1060ac:	01 d0                	add    %edx,%eax
  1060ae:	c1 e0 02             	shl    $0x2,%eax
  1060b1:	05 28 df 11 00       	add    $0x11df28,%eax
  1060b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    for (int i = 0; i <= MAXLEVEL; i++) {
  1060bc:	ff 45 e4             	incl   -0x1c(%ebp)
  1060bf:	83 7d e4 0c          	cmpl   $0xc,-0x1c(%ebp)
  1060c3:	0f 8e 31 ff ff ff    	jle    105ffa <buddy_check+0x33e>
    }
    assert(alloc_page() == NULL);
  1060c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1060d0:	e8 74 ca ff ff       	call   102b49 <alloc_pages>
  1060d5:	85 c0                	test   %eax,%eax
  1060d7:	74 24                	je     1060fd <buddy_check+0x441>
  1060d9:	c7 44 24 0c 5b 80 10 	movl   $0x10805b,0xc(%esp)
  1060e0:	00 
  1060e1:	c7 44 24 08 00 7e 10 	movl   $0x107e00,0x8(%esp)
  1060e8:	00 
  1060e9:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  1060f0:	00 
  1060f1:	c7 04 24 15 7e 10 00 	movl   $0x107e15,(%esp)
  1060f8:	e8 ec a2 ff ff       	call   1003e9 <__panic>
    cprintf("clean successfully.\n");
  1060fd:	c7 04 24 70 80 10 00 	movl   $0x108070,(%esp)
  106104:	e8 89 a1 ff ff       	call   100292 <cprintf>
    cprintf("p0\n");
  106109:	c7 04 24 03 7f 10 00 	movl   $0x107f03,(%esp)
  106110:	e8 7d a1 ff ff       	call   100292 <cprintf>
    free_page(p0);
  106115:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10611c:	00 
  10611d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  106120:	89 04 24             	mov    %eax,(%esp)
  106123:	e8 59 ca ff ff       	call   102b81 <free_pages>
    cprintf("p1\n");
  106128:	c7 04 24 23 7f 10 00 	movl   $0x107f23,(%esp)
  10612f:	e8 5e a1 ff ff       	call   100292 <cprintf>
    free_page(p1);
  106134:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10613b:	00 
  10613c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10613f:	89 04 24             	mov    %eax,(%esp)
  106142:	e8 3a ca ff ff       	call   102b81 <free_pages>
    cprintf("p2\n");
  106147:	c7 04 24 43 7f 10 00 	movl   $0x107f43,(%esp)
  10614e:	e8 3f a1 ff ff       	call   100292 <cprintf>
    free_page(p2);
  106153:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10615a:	00 
  10615b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10615e:	89 04 24             	mov    %eax,(%esp)
  106161:	e8 1b ca ff ff       	call   102b81 <free_pages>
    total = 0;
  106166:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
  10616d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  106174:	eb 1e                	jmp    106194 <buddy_check+0x4d8>
        total += free_area[i].nr_free;
  106176:	8b 55 e0             	mov    -0x20(%ebp),%edx
  106179:	89 d0                	mov    %edx,%eax
  10617b:	01 c0                	add    %eax,%eax
  10617d:	01 d0                	add    %edx,%eax
  10617f:	c1 e0 02             	shl    $0x2,%eax
  106182:	05 28 df 11 00       	add    $0x11df28,%eax
  106187:	8b 10                	mov    (%eax),%edx
  106189:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10618c:	01 d0                	add    %edx,%eax
  10618e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
  106191:	ff 45 e0             	incl   -0x20(%ebp)
  106194:	83 7d e0 0c          	cmpl   $0xc,-0x20(%ebp)
  106198:	7e dc                	jle    106176 <buddy_check+0x4ba>

    //assert((p0 = alloc_page()) != NULL);
    //assert((p1 = alloc_page()) != NULL);
    //assert((p2 = alloc_page()) != NULL);
    //assert(alloc_page() == NULL);
}
  10619a:	90                   	nop
  10619b:	c9                   	leave  
  10619c:	c3                   	ret    

0010619d <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  10619d:	55                   	push   %ebp
  10619e:	89 e5                	mov    %esp,%ebp
  1061a0:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1061a3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  1061aa:	eb 03                	jmp    1061af <strlen+0x12>
        cnt ++;
  1061ac:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  1061af:	8b 45 08             	mov    0x8(%ebp),%eax
  1061b2:	8d 50 01             	lea    0x1(%eax),%edx
  1061b5:	89 55 08             	mov    %edx,0x8(%ebp)
  1061b8:	0f b6 00             	movzbl (%eax),%eax
  1061bb:	84 c0                	test   %al,%al
  1061bd:	75 ed                	jne    1061ac <strlen+0xf>
    }
    return cnt;
  1061bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1061c2:	c9                   	leave  
  1061c3:	c3                   	ret    

001061c4 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  1061c4:	55                   	push   %ebp
  1061c5:	89 e5                	mov    %esp,%ebp
  1061c7:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1061ca:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1061d1:	eb 03                	jmp    1061d6 <strnlen+0x12>
        cnt ++;
  1061d3:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1061d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1061d9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1061dc:	73 10                	jae    1061ee <strnlen+0x2a>
  1061de:	8b 45 08             	mov    0x8(%ebp),%eax
  1061e1:	8d 50 01             	lea    0x1(%eax),%edx
  1061e4:	89 55 08             	mov    %edx,0x8(%ebp)
  1061e7:	0f b6 00             	movzbl (%eax),%eax
  1061ea:	84 c0                	test   %al,%al
  1061ec:	75 e5                	jne    1061d3 <strnlen+0xf>
    }
    return cnt;
  1061ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1061f1:	c9                   	leave  
  1061f2:	c3                   	ret    

001061f3 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1061f3:	55                   	push   %ebp
  1061f4:	89 e5                	mov    %esp,%ebp
  1061f6:	57                   	push   %edi
  1061f7:	56                   	push   %esi
  1061f8:	83 ec 20             	sub    $0x20,%esp
  1061fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1061fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106201:	8b 45 0c             	mov    0xc(%ebp),%eax
  106204:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  106207:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10620a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10620d:	89 d1                	mov    %edx,%ecx
  10620f:	89 c2                	mov    %eax,%edx
  106211:	89 ce                	mov    %ecx,%esi
  106213:	89 d7                	mov    %edx,%edi
  106215:	ac                   	lods   %ds:(%esi),%al
  106216:	aa                   	stos   %al,%es:(%edi)
  106217:	84 c0                	test   %al,%al
  106219:	75 fa                	jne    106215 <strcpy+0x22>
  10621b:	89 fa                	mov    %edi,%edx
  10621d:	89 f1                	mov    %esi,%ecx
  10621f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  106222:	89 55 e8             	mov    %edx,-0x18(%ebp)
  106225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  106228:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  10622b:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  10622c:	83 c4 20             	add    $0x20,%esp
  10622f:	5e                   	pop    %esi
  106230:	5f                   	pop    %edi
  106231:	5d                   	pop    %ebp
  106232:	c3                   	ret    

00106233 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  106233:	55                   	push   %ebp
  106234:	89 e5                	mov    %esp,%ebp
  106236:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  106239:	8b 45 08             	mov    0x8(%ebp),%eax
  10623c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  10623f:	eb 1e                	jmp    10625f <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  106241:	8b 45 0c             	mov    0xc(%ebp),%eax
  106244:	0f b6 10             	movzbl (%eax),%edx
  106247:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10624a:	88 10                	mov    %dl,(%eax)
  10624c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10624f:	0f b6 00             	movzbl (%eax),%eax
  106252:	84 c0                	test   %al,%al
  106254:	74 03                	je     106259 <strncpy+0x26>
            src ++;
  106256:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  106259:	ff 45 fc             	incl   -0x4(%ebp)
  10625c:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  10625f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106263:	75 dc                	jne    106241 <strncpy+0xe>
    }
    return dst;
  106265:	8b 45 08             	mov    0x8(%ebp),%eax
}
  106268:	c9                   	leave  
  106269:	c3                   	ret    

0010626a <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  10626a:	55                   	push   %ebp
  10626b:	89 e5                	mov    %esp,%ebp
  10626d:	57                   	push   %edi
  10626e:	56                   	push   %esi
  10626f:	83 ec 20             	sub    $0x20,%esp
  106272:	8b 45 08             	mov    0x8(%ebp),%eax
  106275:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106278:	8b 45 0c             	mov    0xc(%ebp),%eax
  10627b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  10627e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106281:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106284:	89 d1                	mov    %edx,%ecx
  106286:	89 c2                	mov    %eax,%edx
  106288:	89 ce                	mov    %ecx,%esi
  10628a:	89 d7                	mov    %edx,%edi
  10628c:	ac                   	lods   %ds:(%esi),%al
  10628d:	ae                   	scas   %es:(%edi),%al
  10628e:	75 08                	jne    106298 <strcmp+0x2e>
  106290:	84 c0                	test   %al,%al
  106292:	75 f8                	jne    10628c <strcmp+0x22>
  106294:	31 c0                	xor    %eax,%eax
  106296:	eb 04                	jmp    10629c <strcmp+0x32>
  106298:	19 c0                	sbb    %eax,%eax
  10629a:	0c 01                	or     $0x1,%al
  10629c:	89 fa                	mov    %edi,%edx
  10629e:	89 f1                	mov    %esi,%ecx
  1062a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1062a3:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1062a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  1062a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  1062ac:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1062ad:	83 c4 20             	add    $0x20,%esp
  1062b0:	5e                   	pop    %esi
  1062b1:	5f                   	pop    %edi
  1062b2:	5d                   	pop    %ebp
  1062b3:	c3                   	ret    

001062b4 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1062b4:	55                   	push   %ebp
  1062b5:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1062b7:	eb 09                	jmp    1062c2 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  1062b9:	ff 4d 10             	decl   0x10(%ebp)
  1062bc:	ff 45 08             	incl   0x8(%ebp)
  1062bf:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1062c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1062c6:	74 1a                	je     1062e2 <strncmp+0x2e>
  1062c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1062cb:	0f b6 00             	movzbl (%eax),%eax
  1062ce:	84 c0                	test   %al,%al
  1062d0:	74 10                	je     1062e2 <strncmp+0x2e>
  1062d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1062d5:	0f b6 10             	movzbl (%eax),%edx
  1062d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1062db:	0f b6 00             	movzbl (%eax),%eax
  1062de:	38 c2                	cmp    %al,%dl
  1062e0:	74 d7                	je     1062b9 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  1062e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1062e6:	74 18                	je     106300 <strncmp+0x4c>
  1062e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1062eb:	0f b6 00             	movzbl (%eax),%eax
  1062ee:	0f b6 d0             	movzbl %al,%edx
  1062f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1062f4:	0f b6 00             	movzbl (%eax),%eax
  1062f7:	0f b6 c0             	movzbl %al,%eax
  1062fa:	29 c2                	sub    %eax,%edx
  1062fc:	89 d0                	mov    %edx,%eax
  1062fe:	eb 05                	jmp    106305 <strncmp+0x51>
  106300:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106305:	5d                   	pop    %ebp
  106306:	c3                   	ret    

00106307 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  106307:	55                   	push   %ebp
  106308:	89 e5                	mov    %esp,%ebp
  10630a:	83 ec 04             	sub    $0x4,%esp
  10630d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106310:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  106313:	eb 13                	jmp    106328 <strchr+0x21>
        if (*s == c) {
  106315:	8b 45 08             	mov    0x8(%ebp),%eax
  106318:	0f b6 00             	movzbl (%eax),%eax
  10631b:	38 45 fc             	cmp    %al,-0x4(%ebp)
  10631e:	75 05                	jne    106325 <strchr+0x1e>
            return (char *)s;
  106320:	8b 45 08             	mov    0x8(%ebp),%eax
  106323:	eb 12                	jmp    106337 <strchr+0x30>
        }
        s ++;
  106325:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  106328:	8b 45 08             	mov    0x8(%ebp),%eax
  10632b:	0f b6 00             	movzbl (%eax),%eax
  10632e:	84 c0                	test   %al,%al
  106330:	75 e3                	jne    106315 <strchr+0xe>
    }
    return NULL;
  106332:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106337:	c9                   	leave  
  106338:	c3                   	ret    

00106339 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  106339:	55                   	push   %ebp
  10633a:	89 e5                	mov    %esp,%ebp
  10633c:	83 ec 04             	sub    $0x4,%esp
  10633f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106342:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  106345:	eb 0e                	jmp    106355 <strfind+0x1c>
        if (*s == c) {
  106347:	8b 45 08             	mov    0x8(%ebp),%eax
  10634a:	0f b6 00             	movzbl (%eax),%eax
  10634d:	38 45 fc             	cmp    %al,-0x4(%ebp)
  106350:	74 0f                	je     106361 <strfind+0x28>
            break;
        }
        s ++;
  106352:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  106355:	8b 45 08             	mov    0x8(%ebp),%eax
  106358:	0f b6 00             	movzbl (%eax),%eax
  10635b:	84 c0                	test   %al,%al
  10635d:	75 e8                	jne    106347 <strfind+0xe>
  10635f:	eb 01                	jmp    106362 <strfind+0x29>
            break;
  106361:	90                   	nop
    }
    return (char *)s;
  106362:	8b 45 08             	mov    0x8(%ebp),%eax
}
  106365:	c9                   	leave  
  106366:	c3                   	ret    

00106367 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  106367:	55                   	push   %ebp
  106368:	89 e5                	mov    %esp,%ebp
  10636a:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  10636d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  106374:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  10637b:	eb 03                	jmp    106380 <strtol+0x19>
        s ++;
  10637d:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  106380:	8b 45 08             	mov    0x8(%ebp),%eax
  106383:	0f b6 00             	movzbl (%eax),%eax
  106386:	3c 20                	cmp    $0x20,%al
  106388:	74 f3                	je     10637d <strtol+0x16>
  10638a:	8b 45 08             	mov    0x8(%ebp),%eax
  10638d:	0f b6 00             	movzbl (%eax),%eax
  106390:	3c 09                	cmp    $0x9,%al
  106392:	74 e9                	je     10637d <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  106394:	8b 45 08             	mov    0x8(%ebp),%eax
  106397:	0f b6 00             	movzbl (%eax),%eax
  10639a:	3c 2b                	cmp    $0x2b,%al
  10639c:	75 05                	jne    1063a3 <strtol+0x3c>
        s ++;
  10639e:	ff 45 08             	incl   0x8(%ebp)
  1063a1:	eb 14                	jmp    1063b7 <strtol+0x50>
    }
    else if (*s == '-') {
  1063a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1063a6:	0f b6 00             	movzbl (%eax),%eax
  1063a9:	3c 2d                	cmp    $0x2d,%al
  1063ab:	75 0a                	jne    1063b7 <strtol+0x50>
        s ++, neg = 1;
  1063ad:	ff 45 08             	incl   0x8(%ebp)
  1063b0:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  1063b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1063bb:	74 06                	je     1063c3 <strtol+0x5c>
  1063bd:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  1063c1:	75 22                	jne    1063e5 <strtol+0x7e>
  1063c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1063c6:	0f b6 00             	movzbl (%eax),%eax
  1063c9:	3c 30                	cmp    $0x30,%al
  1063cb:	75 18                	jne    1063e5 <strtol+0x7e>
  1063cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1063d0:	40                   	inc    %eax
  1063d1:	0f b6 00             	movzbl (%eax),%eax
  1063d4:	3c 78                	cmp    $0x78,%al
  1063d6:	75 0d                	jne    1063e5 <strtol+0x7e>
        s += 2, base = 16;
  1063d8:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  1063dc:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  1063e3:	eb 29                	jmp    10640e <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  1063e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1063e9:	75 16                	jne    106401 <strtol+0x9a>
  1063eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1063ee:	0f b6 00             	movzbl (%eax),%eax
  1063f1:	3c 30                	cmp    $0x30,%al
  1063f3:	75 0c                	jne    106401 <strtol+0x9a>
        s ++, base = 8;
  1063f5:	ff 45 08             	incl   0x8(%ebp)
  1063f8:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  1063ff:	eb 0d                	jmp    10640e <strtol+0xa7>
    }
    else if (base == 0) {
  106401:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106405:	75 07                	jne    10640e <strtol+0xa7>
        base = 10;
  106407:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  10640e:	8b 45 08             	mov    0x8(%ebp),%eax
  106411:	0f b6 00             	movzbl (%eax),%eax
  106414:	3c 2f                	cmp    $0x2f,%al
  106416:	7e 1b                	jle    106433 <strtol+0xcc>
  106418:	8b 45 08             	mov    0x8(%ebp),%eax
  10641b:	0f b6 00             	movzbl (%eax),%eax
  10641e:	3c 39                	cmp    $0x39,%al
  106420:	7f 11                	jg     106433 <strtol+0xcc>
            dig = *s - '0';
  106422:	8b 45 08             	mov    0x8(%ebp),%eax
  106425:	0f b6 00             	movzbl (%eax),%eax
  106428:	0f be c0             	movsbl %al,%eax
  10642b:	83 e8 30             	sub    $0x30,%eax
  10642e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106431:	eb 48                	jmp    10647b <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  106433:	8b 45 08             	mov    0x8(%ebp),%eax
  106436:	0f b6 00             	movzbl (%eax),%eax
  106439:	3c 60                	cmp    $0x60,%al
  10643b:	7e 1b                	jle    106458 <strtol+0xf1>
  10643d:	8b 45 08             	mov    0x8(%ebp),%eax
  106440:	0f b6 00             	movzbl (%eax),%eax
  106443:	3c 7a                	cmp    $0x7a,%al
  106445:	7f 11                	jg     106458 <strtol+0xf1>
            dig = *s - 'a' + 10;
  106447:	8b 45 08             	mov    0x8(%ebp),%eax
  10644a:	0f b6 00             	movzbl (%eax),%eax
  10644d:	0f be c0             	movsbl %al,%eax
  106450:	83 e8 57             	sub    $0x57,%eax
  106453:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106456:	eb 23                	jmp    10647b <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  106458:	8b 45 08             	mov    0x8(%ebp),%eax
  10645b:	0f b6 00             	movzbl (%eax),%eax
  10645e:	3c 40                	cmp    $0x40,%al
  106460:	7e 3b                	jle    10649d <strtol+0x136>
  106462:	8b 45 08             	mov    0x8(%ebp),%eax
  106465:	0f b6 00             	movzbl (%eax),%eax
  106468:	3c 5a                	cmp    $0x5a,%al
  10646a:	7f 31                	jg     10649d <strtol+0x136>
            dig = *s - 'A' + 10;
  10646c:	8b 45 08             	mov    0x8(%ebp),%eax
  10646f:	0f b6 00             	movzbl (%eax),%eax
  106472:	0f be c0             	movsbl %al,%eax
  106475:	83 e8 37             	sub    $0x37,%eax
  106478:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  10647b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10647e:	3b 45 10             	cmp    0x10(%ebp),%eax
  106481:	7d 19                	jge    10649c <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  106483:	ff 45 08             	incl   0x8(%ebp)
  106486:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106489:	0f af 45 10          	imul   0x10(%ebp),%eax
  10648d:	89 c2                	mov    %eax,%edx
  10648f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106492:	01 d0                	add    %edx,%eax
  106494:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  106497:	e9 72 ff ff ff       	jmp    10640e <strtol+0xa7>
            break;
  10649c:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  10649d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1064a1:	74 08                	je     1064ab <strtol+0x144>
        *endptr = (char *) s;
  1064a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1064a6:	8b 55 08             	mov    0x8(%ebp),%edx
  1064a9:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  1064ab:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  1064af:	74 07                	je     1064b8 <strtol+0x151>
  1064b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1064b4:	f7 d8                	neg    %eax
  1064b6:	eb 03                	jmp    1064bb <strtol+0x154>
  1064b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1064bb:	c9                   	leave  
  1064bc:	c3                   	ret    

001064bd <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  1064bd:	55                   	push   %ebp
  1064be:	89 e5                	mov    %esp,%ebp
  1064c0:	57                   	push   %edi
  1064c1:	83 ec 24             	sub    $0x24,%esp
  1064c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1064c7:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  1064ca:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  1064ce:	8b 55 08             	mov    0x8(%ebp),%edx
  1064d1:	89 55 f8             	mov    %edx,-0x8(%ebp)
  1064d4:	88 45 f7             	mov    %al,-0x9(%ebp)
  1064d7:	8b 45 10             	mov    0x10(%ebp),%eax
  1064da:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  1064dd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1064e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1064e4:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1064e7:	89 d7                	mov    %edx,%edi
  1064e9:	f3 aa                	rep stos %al,%es:(%edi)
  1064eb:	89 fa                	mov    %edi,%edx
  1064ed:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1064f0:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  1064f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1064f6:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  1064f7:	83 c4 24             	add    $0x24,%esp
  1064fa:	5f                   	pop    %edi
  1064fb:	5d                   	pop    %ebp
  1064fc:	c3                   	ret    

001064fd <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  1064fd:	55                   	push   %ebp
  1064fe:	89 e5                	mov    %esp,%ebp
  106500:	57                   	push   %edi
  106501:	56                   	push   %esi
  106502:	53                   	push   %ebx
  106503:	83 ec 30             	sub    $0x30,%esp
  106506:	8b 45 08             	mov    0x8(%ebp),%eax
  106509:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10650c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10650f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106512:	8b 45 10             	mov    0x10(%ebp),%eax
  106515:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  106518:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10651b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10651e:	73 42                	jae    106562 <memmove+0x65>
  106520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106523:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106526:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106529:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10652c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10652f:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106532:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106535:	c1 e8 02             	shr    $0x2,%eax
  106538:	89 c1                	mov    %eax,%ecx
    asm volatile (
  10653a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10653d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106540:	89 d7                	mov    %edx,%edi
  106542:	89 c6                	mov    %eax,%esi
  106544:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  106546:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  106549:	83 e1 03             	and    $0x3,%ecx
  10654c:	74 02                	je     106550 <memmove+0x53>
  10654e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106550:	89 f0                	mov    %esi,%eax
  106552:	89 fa                	mov    %edi,%edx
  106554:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  106557:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10655a:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  10655d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  106560:	eb 36                	jmp    106598 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  106562:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106565:	8d 50 ff             	lea    -0x1(%eax),%edx
  106568:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10656b:	01 c2                	add    %eax,%edx
  10656d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106570:	8d 48 ff             	lea    -0x1(%eax),%ecx
  106573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106576:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  106579:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10657c:	89 c1                	mov    %eax,%ecx
  10657e:	89 d8                	mov    %ebx,%eax
  106580:	89 d6                	mov    %edx,%esi
  106582:	89 c7                	mov    %eax,%edi
  106584:	fd                   	std    
  106585:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106587:	fc                   	cld    
  106588:	89 f8                	mov    %edi,%eax
  10658a:	89 f2                	mov    %esi,%edx
  10658c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  10658f:	89 55 c8             	mov    %edx,-0x38(%ebp)
  106592:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  106595:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  106598:	83 c4 30             	add    $0x30,%esp
  10659b:	5b                   	pop    %ebx
  10659c:	5e                   	pop    %esi
  10659d:	5f                   	pop    %edi
  10659e:	5d                   	pop    %ebp
  10659f:	c3                   	ret    

001065a0 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  1065a0:	55                   	push   %ebp
  1065a1:	89 e5                	mov    %esp,%ebp
  1065a3:	57                   	push   %edi
  1065a4:	56                   	push   %esi
  1065a5:	83 ec 20             	sub    $0x20,%esp
  1065a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1065ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1065ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  1065b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1065b4:	8b 45 10             	mov    0x10(%ebp),%eax
  1065b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1065ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1065bd:	c1 e8 02             	shr    $0x2,%eax
  1065c0:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1065c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1065c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1065c8:	89 d7                	mov    %edx,%edi
  1065ca:	89 c6                	mov    %eax,%esi
  1065cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1065ce:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1065d1:	83 e1 03             	and    $0x3,%ecx
  1065d4:	74 02                	je     1065d8 <memcpy+0x38>
  1065d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1065d8:	89 f0                	mov    %esi,%eax
  1065da:	89 fa                	mov    %edi,%edx
  1065dc:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1065df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1065e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  1065e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  1065e8:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  1065e9:	83 c4 20             	add    $0x20,%esp
  1065ec:	5e                   	pop    %esi
  1065ed:	5f                   	pop    %edi
  1065ee:	5d                   	pop    %ebp
  1065ef:	c3                   	ret    

001065f0 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  1065f0:	55                   	push   %ebp
  1065f1:	89 e5                	mov    %esp,%ebp
  1065f3:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  1065f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1065f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1065fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1065ff:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  106602:	eb 2e                	jmp    106632 <memcmp+0x42>
        if (*s1 != *s2) {
  106604:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106607:	0f b6 10             	movzbl (%eax),%edx
  10660a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10660d:	0f b6 00             	movzbl (%eax),%eax
  106610:	38 c2                	cmp    %al,%dl
  106612:	74 18                	je     10662c <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  106614:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106617:	0f b6 00             	movzbl (%eax),%eax
  10661a:	0f b6 d0             	movzbl %al,%edx
  10661d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106620:	0f b6 00             	movzbl (%eax),%eax
  106623:	0f b6 c0             	movzbl %al,%eax
  106626:	29 c2                	sub    %eax,%edx
  106628:	89 d0                	mov    %edx,%eax
  10662a:	eb 18                	jmp    106644 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  10662c:	ff 45 fc             	incl   -0x4(%ebp)
  10662f:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  106632:	8b 45 10             	mov    0x10(%ebp),%eax
  106635:	8d 50 ff             	lea    -0x1(%eax),%edx
  106638:	89 55 10             	mov    %edx,0x10(%ebp)
  10663b:	85 c0                	test   %eax,%eax
  10663d:	75 c5                	jne    106604 <memcmp+0x14>
    }
    return 0;
  10663f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106644:	c9                   	leave  
  106645:	c3                   	ret    

00106646 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  106646:	55                   	push   %ebp
  106647:	89 e5                	mov    %esp,%ebp
  106649:	83 ec 58             	sub    $0x58,%esp
  10664c:	8b 45 10             	mov    0x10(%ebp),%eax
  10664f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  106652:	8b 45 14             	mov    0x14(%ebp),%eax
  106655:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  106658:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10665b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10665e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106661:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  106664:	8b 45 18             	mov    0x18(%ebp),%eax
  106667:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10666a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10666d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106670:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106673:	89 55 f0             	mov    %edx,-0x10(%ebp)
  106676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106679:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10667c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  106680:	74 1c                	je     10669e <printnum+0x58>
  106682:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106685:	ba 00 00 00 00       	mov    $0x0,%edx
  10668a:	f7 75 e4             	divl   -0x1c(%ebp)
  10668d:	89 55 f4             	mov    %edx,-0xc(%ebp)
  106690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106693:	ba 00 00 00 00       	mov    $0x0,%edx
  106698:	f7 75 e4             	divl   -0x1c(%ebp)
  10669b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10669e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1066a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1066a4:	f7 75 e4             	divl   -0x1c(%ebp)
  1066a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1066aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1066ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1066b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1066b3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1066b6:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1066b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1066bc:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1066bf:	8b 45 18             	mov    0x18(%ebp),%eax
  1066c2:	ba 00 00 00 00       	mov    $0x0,%edx
  1066c7:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  1066ca:	72 56                	jb     106722 <printnum+0xdc>
  1066cc:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  1066cf:	77 05                	ja     1066d6 <printnum+0x90>
  1066d1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  1066d4:	72 4c                	jb     106722 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  1066d6:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1066d9:	8d 50 ff             	lea    -0x1(%eax),%edx
  1066dc:	8b 45 20             	mov    0x20(%ebp),%eax
  1066df:	89 44 24 18          	mov    %eax,0x18(%esp)
  1066e3:	89 54 24 14          	mov    %edx,0x14(%esp)
  1066e7:	8b 45 18             	mov    0x18(%ebp),%eax
  1066ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  1066ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1066f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1066f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1066f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1066fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1066ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  106703:	8b 45 08             	mov    0x8(%ebp),%eax
  106706:	89 04 24             	mov    %eax,(%esp)
  106709:	e8 38 ff ff ff       	call   106646 <printnum>
  10670e:	eb 1b                	jmp    10672b <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  106710:	8b 45 0c             	mov    0xc(%ebp),%eax
  106713:	89 44 24 04          	mov    %eax,0x4(%esp)
  106717:	8b 45 20             	mov    0x20(%ebp),%eax
  10671a:	89 04 24             	mov    %eax,(%esp)
  10671d:	8b 45 08             	mov    0x8(%ebp),%eax
  106720:	ff d0                	call   *%eax
        while (-- width > 0)
  106722:	ff 4d 1c             	decl   0x1c(%ebp)
  106725:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  106729:	7f e5                	jg     106710 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  10672b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10672e:	05 30 81 10 00       	add    $0x108130,%eax
  106733:	0f b6 00             	movzbl (%eax),%eax
  106736:	0f be c0             	movsbl %al,%eax
  106739:	8b 55 0c             	mov    0xc(%ebp),%edx
  10673c:	89 54 24 04          	mov    %edx,0x4(%esp)
  106740:	89 04 24             	mov    %eax,(%esp)
  106743:	8b 45 08             	mov    0x8(%ebp),%eax
  106746:	ff d0                	call   *%eax
}
  106748:	90                   	nop
  106749:	c9                   	leave  
  10674a:	c3                   	ret    

0010674b <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  10674b:	55                   	push   %ebp
  10674c:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10674e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  106752:	7e 14                	jle    106768 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  106754:	8b 45 08             	mov    0x8(%ebp),%eax
  106757:	8b 00                	mov    (%eax),%eax
  106759:	8d 48 08             	lea    0x8(%eax),%ecx
  10675c:	8b 55 08             	mov    0x8(%ebp),%edx
  10675f:	89 0a                	mov    %ecx,(%edx)
  106761:	8b 50 04             	mov    0x4(%eax),%edx
  106764:	8b 00                	mov    (%eax),%eax
  106766:	eb 30                	jmp    106798 <getuint+0x4d>
    }
    else if (lflag) {
  106768:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10676c:	74 16                	je     106784 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  10676e:	8b 45 08             	mov    0x8(%ebp),%eax
  106771:	8b 00                	mov    (%eax),%eax
  106773:	8d 48 04             	lea    0x4(%eax),%ecx
  106776:	8b 55 08             	mov    0x8(%ebp),%edx
  106779:	89 0a                	mov    %ecx,(%edx)
  10677b:	8b 00                	mov    (%eax),%eax
  10677d:	ba 00 00 00 00       	mov    $0x0,%edx
  106782:	eb 14                	jmp    106798 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  106784:	8b 45 08             	mov    0x8(%ebp),%eax
  106787:	8b 00                	mov    (%eax),%eax
  106789:	8d 48 04             	lea    0x4(%eax),%ecx
  10678c:	8b 55 08             	mov    0x8(%ebp),%edx
  10678f:	89 0a                	mov    %ecx,(%edx)
  106791:	8b 00                	mov    (%eax),%eax
  106793:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  106798:	5d                   	pop    %ebp
  106799:	c3                   	ret    

0010679a <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  10679a:	55                   	push   %ebp
  10679b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10679d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1067a1:	7e 14                	jle    1067b7 <getint+0x1d>
        return va_arg(*ap, long long);
  1067a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1067a6:	8b 00                	mov    (%eax),%eax
  1067a8:	8d 48 08             	lea    0x8(%eax),%ecx
  1067ab:	8b 55 08             	mov    0x8(%ebp),%edx
  1067ae:	89 0a                	mov    %ecx,(%edx)
  1067b0:	8b 50 04             	mov    0x4(%eax),%edx
  1067b3:	8b 00                	mov    (%eax),%eax
  1067b5:	eb 28                	jmp    1067df <getint+0x45>
    }
    else if (lflag) {
  1067b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1067bb:	74 12                	je     1067cf <getint+0x35>
        return va_arg(*ap, long);
  1067bd:	8b 45 08             	mov    0x8(%ebp),%eax
  1067c0:	8b 00                	mov    (%eax),%eax
  1067c2:	8d 48 04             	lea    0x4(%eax),%ecx
  1067c5:	8b 55 08             	mov    0x8(%ebp),%edx
  1067c8:	89 0a                	mov    %ecx,(%edx)
  1067ca:	8b 00                	mov    (%eax),%eax
  1067cc:	99                   	cltd   
  1067cd:	eb 10                	jmp    1067df <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1067cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1067d2:	8b 00                	mov    (%eax),%eax
  1067d4:	8d 48 04             	lea    0x4(%eax),%ecx
  1067d7:	8b 55 08             	mov    0x8(%ebp),%edx
  1067da:	89 0a                	mov    %ecx,(%edx)
  1067dc:	8b 00                	mov    (%eax),%eax
  1067de:	99                   	cltd   
    }
}
  1067df:	5d                   	pop    %ebp
  1067e0:	c3                   	ret    

001067e1 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1067e1:	55                   	push   %ebp
  1067e2:	89 e5                	mov    %esp,%ebp
  1067e4:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  1067e7:	8d 45 14             	lea    0x14(%ebp),%eax
  1067ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1067ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1067f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1067f4:	8b 45 10             	mov    0x10(%ebp),%eax
  1067f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  1067fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1067fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  106802:	8b 45 08             	mov    0x8(%ebp),%eax
  106805:	89 04 24             	mov    %eax,(%esp)
  106808:	e8 03 00 00 00       	call   106810 <vprintfmt>
    va_end(ap);
}
  10680d:	90                   	nop
  10680e:	c9                   	leave  
  10680f:	c3                   	ret    

00106810 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  106810:	55                   	push   %ebp
  106811:	89 e5                	mov    %esp,%ebp
  106813:	56                   	push   %esi
  106814:	53                   	push   %ebx
  106815:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  106818:	eb 17                	jmp    106831 <vprintfmt+0x21>
            if (ch == '\0') {
  10681a:	85 db                	test   %ebx,%ebx
  10681c:	0f 84 bf 03 00 00    	je     106be1 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  106822:	8b 45 0c             	mov    0xc(%ebp),%eax
  106825:	89 44 24 04          	mov    %eax,0x4(%esp)
  106829:	89 1c 24             	mov    %ebx,(%esp)
  10682c:	8b 45 08             	mov    0x8(%ebp),%eax
  10682f:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  106831:	8b 45 10             	mov    0x10(%ebp),%eax
  106834:	8d 50 01             	lea    0x1(%eax),%edx
  106837:	89 55 10             	mov    %edx,0x10(%ebp)
  10683a:	0f b6 00             	movzbl (%eax),%eax
  10683d:	0f b6 d8             	movzbl %al,%ebx
  106840:	83 fb 25             	cmp    $0x25,%ebx
  106843:	75 d5                	jne    10681a <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  106845:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  106849:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  106850:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106853:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  106856:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10685d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106860:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  106863:	8b 45 10             	mov    0x10(%ebp),%eax
  106866:	8d 50 01             	lea    0x1(%eax),%edx
  106869:	89 55 10             	mov    %edx,0x10(%ebp)
  10686c:	0f b6 00             	movzbl (%eax),%eax
  10686f:	0f b6 d8             	movzbl %al,%ebx
  106872:	8d 43 dd             	lea    -0x23(%ebx),%eax
  106875:	83 f8 55             	cmp    $0x55,%eax
  106878:	0f 87 37 03 00 00    	ja     106bb5 <vprintfmt+0x3a5>
  10687e:	8b 04 85 54 81 10 00 	mov    0x108154(,%eax,4),%eax
  106885:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  106887:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  10688b:	eb d6                	jmp    106863 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  10688d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  106891:	eb d0                	jmp    106863 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  106893:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  10689a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10689d:	89 d0                	mov    %edx,%eax
  10689f:	c1 e0 02             	shl    $0x2,%eax
  1068a2:	01 d0                	add    %edx,%eax
  1068a4:	01 c0                	add    %eax,%eax
  1068a6:	01 d8                	add    %ebx,%eax
  1068a8:	83 e8 30             	sub    $0x30,%eax
  1068ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  1068ae:	8b 45 10             	mov    0x10(%ebp),%eax
  1068b1:	0f b6 00             	movzbl (%eax),%eax
  1068b4:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1068b7:	83 fb 2f             	cmp    $0x2f,%ebx
  1068ba:	7e 38                	jle    1068f4 <vprintfmt+0xe4>
  1068bc:	83 fb 39             	cmp    $0x39,%ebx
  1068bf:	7f 33                	jg     1068f4 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  1068c1:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  1068c4:	eb d4                	jmp    10689a <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  1068c6:	8b 45 14             	mov    0x14(%ebp),%eax
  1068c9:	8d 50 04             	lea    0x4(%eax),%edx
  1068cc:	89 55 14             	mov    %edx,0x14(%ebp)
  1068cf:	8b 00                	mov    (%eax),%eax
  1068d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1068d4:	eb 1f                	jmp    1068f5 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  1068d6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1068da:	79 87                	jns    106863 <vprintfmt+0x53>
                width = 0;
  1068dc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1068e3:	e9 7b ff ff ff       	jmp    106863 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  1068e8:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1068ef:	e9 6f ff ff ff       	jmp    106863 <vprintfmt+0x53>
            goto process_precision;
  1068f4:	90                   	nop

        process_precision:
            if (width < 0)
  1068f5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1068f9:	0f 89 64 ff ff ff    	jns    106863 <vprintfmt+0x53>
                width = precision, precision = -1;
  1068ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106902:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106905:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  10690c:	e9 52 ff ff ff       	jmp    106863 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  106911:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  106914:	e9 4a ff ff ff       	jmp    106863 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  106919:	8b 45 14             	mov    0x14(%ebp),%eax
  10691c:	8d 50 04             	lea    0x4(%eax),%edx
  10691f:	89 55 14             	mov    %edx,0x14(%ebp)
  106922:	8b 00                	mov    (%eax),%eax
  106924:	8b 55 0c             	mov    0xc(%ebp),%edx
  106927:	89 54 24 04          	mov    %edx,0x4(%esp)
  10692b:	89 04 24             	mov    %eax,(%esp)
  10692e:	8b 45 08             	mov    0x8(%ebp),%eax
  106931:	ff d0                	call   *%eax
            break;
  106933:	e9 a4 02 00 00       	jmp    106bdc <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  106938:	8b 45 14             	mov    0x14(%ebp),%eax
  10693b:	8d 50 04             	lea    0x4(%eax),%edx
  10693e:	89 55 14             	mov    %edx,0x14(%ebp)
  106941:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  106943:	85 db                	test   %ebx,%ebx
  106945:	79 02                	jns    106949 <vprintfmt+0x139>
                err = -err;
  106947:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  106949:	83 fb 06             	cmp    $0x6,%ebx
  10694c:	7f 0b                	jg     106959 <vprintfmt+0x149>
  10694e:	8b 34 9d 14 81 10 00 	mov    0x108114(,%ebx,4),%esi
  106955:	85 f6                	test   %esi,%esi
  106957:	75 23                	jne    10697c <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  106959:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10695d:	c7 44 24 08 41 81 10 	movl   $0x108141,0x8(%esp)
  106964:	00 
  106965:	8b 45 0c             	mov    0xc(%ebp),%eax
  106968:	89 44 24 04          	mov    %eax,0x4(%esp)
  10696c:	8b 45 08             	mov    0x8(%ebp),%eax
  10696f:	89 04 24             	mov    %eax,(%esp)
  106972:	e8 6a fe ff ff       	call   1067e1 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  106977:	e9 60 02 00 00       	jmp    106bdc <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  10697c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  106980:	c7 44 24 08 4a 81 10 	movl   $0x10814a,0x8(%esp)
  106987:	00 
  106988:	8b 45 0c             	mov    0xc(%ebp),%eax
  10698b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10698f:	8b 45 08             	mov    0x8(%ebp),%eax
  106992:	89 04 24             	mov    %eax,(%esp)
  106995:	e8 47 fe ff ff       	call   1067e1 <printfmt>
            break;
  10699a:	e9 3d 02 00 00       	jmp    106bdc <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  10699f:	8b 45 14             	mov    0x14(%ebp),%eax
  1069a2:	8d 50 04             	lea    0x4(%eax),%edx
  1069a5:	89 55 14             	mov    %edx,0x14(%ebp)
  1069a8:	8b 30                	mov    (%eax),%esi
  1069aa:	85 f6                	test   %esi,%esi
  1069ac:	75 05                	jne    1069b3 <vprintfmt+0x1a3>
                p = "(null)";
  1069ae:	be 4d 81 10 00       	mov    $0x10814d,%esi
            }
            if (width > 0 && padc != '-') {
  1069b3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1069b7:	7e 76                	jle    106a2f <vprintfmt+0x21f>
  1069b9:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1069bd:	74 70                	je     106a2f <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1069bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1069c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1069c6:	89 34 24             	mov    %esi,(%esp)
  1069c9:	e8 f6 f7 ff ff       	call   1061c4 <strnlen>
  1069ce:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1069d1:	29 c2                	sub    %eax,%edx
  1069d3:	89 d0                	mov    %edx,%eax
  1069d5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1069d8:	eb 16                	jmp    1069f0 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  1069da:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1069de:	8b 55 0c             	mov    0xc(%ebp),%edx
  1069e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  1069e5:	89 04 24             	mov    %eax,(%esp)
  1069e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1069eb:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  1069ed:	ff 4d e8             	decl   -0x18(%ebp)
  1069f0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1069f4:	7f e4                	jg     1069da <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1069f6:	eb 37                	jmp    106a2f <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  1069f8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1069fc:	74 1f                	je     106a1d <vprintfmt+0x20d>
  1069fe:	83 fb 1f             	cmp    $0x1f,%ebx
  106a01:	7e 05                	jle    106a08 <vprintfmt+0x1f8>
  106a03:	83 fb 7e             	cmp    $0x7e,%ebx
  106a06:	7e 15                	jle    106a1d <vprintfmt+0x20d>
                    putch('?', putdat);
  106a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a0f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  106a16:	8b 45 08             	mov    0x8(%ebp),%eax
  106a19:	ff d0                	call   *%eax
  106a1b:	eb 0f                	jmp    106a2c <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  106a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a20:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a24:	89 1c 24             	mov    %ebx,(%esp)
  106a27:	8b 45 08             	mov    0x8(%ebp),%eax
  106a2a:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  106a2c:	ff 4d e8             	decl   -0x18(%ebp)
  106a2f:	89 f0                	mov    %esi,%eax
  106a31:	8d 70 01             	lea    0x1(%eax),%esi
  106a34:	0f b6 00             	movzbl (%eax),%eax
  106a37:	0f be d8             	movsbl %al,%ebx
  106a3a:	85 db                	test   %ebx,%ebx
  106a3c:	74 27                	je     106a65 <vprintfmt+0x255>
  106a3e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106a42:	78 b4                	js     1069f8 <vprintfmt+0x1e8>
  106a44:	ff 4d e4             	decl   -0x1c(%ebp)
  106a47:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106a4b:	79 ab                	jns    1069f8 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  106a4d:	eb 16                	jmp    106a65 <vprintfmt+0x255>
                putch(' ', putdat);
  106a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a52:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a56:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  106a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  106a60:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  106a62:	ff 4d e8             	decl   -0x18(%ebp)
  106a65:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106a69:	7f e4                	jg     106a4f <vprintfmt+0x23f>
            }
            break;
  106a6b:	e9 6c 01 00 00       	jmp    106bdc <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  106a70:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106a73:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a77:	8d 45 14             	lea    0x14(%ebp),%eax
  106a7a:	89 04 24             	mov    %eax,(%esp)
  106a7d:	e8 18 fd ff ff       	call   10679a <getint>
  106a82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106a85:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  106a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106a8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106a8e:	85 d2                	test   %edx,%edx
  106a90:	79 26                	jns    106ab8 <vprintfmt+0x2a8>
                putch('-', putdat);
  106a92:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a95:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a99:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  106aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  106aa3:	ff d0                	call   *%eax
                num = -(long long)num;
  106aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106aa8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106aab:	f7 d8                	neg    %eax
  106aad:	83 d2 00             	adc    $0x0,%edx
  106ab0:	f7 da                	neg    %edx
  106ab2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106ab5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  106ab8:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106abf:	e9 a8 00 00 00       	jmp    106b6c <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  106ac4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  106acb:	8d 45 14             	lea    0x14(%ebp),%eax
  106ace:	89 04 24             	mov    %eax,(%esp)
  106ad1:	e8 75 fc ff ff       	call   10674b <getuint>
  106ad6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106ad9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  106adc:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106ae3:	e9 84 00 00 00       	jmp    106b6c <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  106ae8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  106aef:	8d 45 14             	lea    0x14(%ebp),%eax
  106af2:	89 04 24             	mov    %eax,(%esp)
  106af5:	e8 51 fc ff ff       	call   10674b <getuint>
  106afa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106afd:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  106b00:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  106b07:	eb 63                	jmp    106b6c <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  106b09:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b10:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  106b17:	8b 45 08             	mov    0x8(%ebp),%eax
  106b1a:	ff d0                	call   *%eax
            putch('x', putdat);
  106b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b23:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  106b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  106b2d:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  106b2f:	8b 45 14             	mov    0x14(%ebp),%eax
  106b32:	8d 50 04             	lea    0x4(%eax),%edx
  106b35:	89 55 14             	mov    %edx,0x14(%ebp)
  106b38:	8b 00                	mov    (%eax),%eax
  106b3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106b3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  106b44:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  106b4b:	eb 1f                	jmp    106b6c <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  106b4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106b50:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b54:	8d 45 14             	lea    0x14(%ebp),%eax
  106b57:	89 04 24             	mov    %eax,(%esp)
  106b5a:	e8 ec fb ff ff       	call   10674b <getuint>
  106b5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106b62:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  106b65:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  106b6c:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  106b70:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106b73:	89 54 24 18          	mov    %edx,0x18(%esp)
  106b77:	8b 55 e8             	mov    -0x18(%ebp),%edx
  106b7a:	89 54 24 14          	mov    %edx,0x14(%esp)
  106b7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  106b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106b85:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106b88:	89 44 24 08          	mov    %eax,0x8(%esp)
  106b8c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106b90:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b93:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b97:	8b 45 08             	mov    0x8(%ebp),%eax
  106b9a:	89 04 24             	mov    %eax,(%esp)
  106b9d:	e8 a4 fa ff ff       	call   106646 <printnum>
            break;
  106ba2:	eb 38                	jmp    106bdc <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  106ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  106ba7:	89 44 24 04          	mov    %eax,0x4(%esp)
  106bab:	89 1c 24             	mov    %ebx,(%esp)
  106bae:	8b 45 08             	mov    0x8(%ebp),%eax
  106bb1:	ff d0                	call   *%eax
            break;
  106bb3:	eb 27                	jmp    106bdc <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  106bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  106bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  106bbc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  106bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  106bc6:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  106bc8:	ff 4d 10             	decl   0x10(%ebp)
  106bcb:	eb 03                	jmp    106bd0 <vprintfmt+0x3c0>
  106bcd:	ff 4d 10             	decl   0x10(%ebp)
  106bd0:	8b 45 10             	mov    0x10(%ebp),%eax
  106bd3:	48                   	dec    %eax
  106bd4:	0f b6 00             	movzbl (%eax),%eax
  106bd7:	3c 25                	cmp    $0x25,%al
  106bd9:	75 f2                	jne    106bcd <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  106bdb:	90                   	nop
    while (1) {
  106bdc:	e9 37 fc ff ff       	jmp    106818 <vprintfmt+0x8>
                return;
  106be1:	90                   	nop
        }
    }
}
  106be2:	83 c4 40             	add    $0x40,%esp
  106be5:	5b                   	pop    %ebx
  106be6:	5e                   	pop    %esi
  106be7:	5d                   	pop    %ebp
  106be8:	c3                   	ret    

00106be9 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  106be9:	55                   	push   %ebp
  106bea:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  106bec:	8b 45 0c             	mov    0xc(%ebp),%eax
  106bef:	8b 40 08             	mov    0x8(%eax),%eax
  106bf2:	8d 50 01             	lea    0x1(%eax),%edx
  106bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  106bf8:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  106bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  106bfe:	8b 10                	mov    (%eax),%edx
  106c00:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c03:	8b 40 04             	mov    0x4(%eax),%eax
  106c06:	39 c2                	cmp    %eax,%edx
  106c08:	73 12                	jae    106c1c <sprintputch+0x33>
        *b->buf ++ = ch;
  106c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c0d:	8b 00                	mov    (%eax),%eax
  106c0f:	8d 48 01             	lea    0x1(%eax),%ecx
  106c12:	8b 55 0c             	mov    0xc(%ebp),%edx
  106c15:	89 0a                	mov    %ecx,(%edx)
  106c17:	8b 55 08             	mov    0x8(%ebp),%edx
  106c1a:	88 10                	mov    %dl,(%eax)
    }
}
  106c1c:	90                   	nop
  106c1d:	5d                   	pop    %ebp
  106c1e:	c3                   	ret    

00106c1f <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  106c1f:	55                   	push   %ebp
  106c20:	89 e5                	mov    %esp,%ebp
  106c22:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  106c25:	8d 45 14             	lea    0x14(%ebp),%eax
  106c28:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  106c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106c2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106c32:	8b 45 10             	mov    0x10(%ebp),%eax
  106c35:	89 44 24 08          	mov    %eax,0x8(%esp)
  106c39:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  106c40:	8b 45 08             	mov    0x8(%ebp),%eax
  106c43:	89 04 24             	mov    %eax,(%esp)
  106c46:	e8 08 00 00 00       	call   106c53 <vsnprintf>
  106c4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  106c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106c51:	c9                   	leave  
  106c52:	c3                   	ret    

00106c53 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  106c53:	55                   	push   %ebp
  106c54:	89 e5                	mov    %esp,%ebp
  106c56:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  106c59:	8b 45 08             	mov    0x8(%ebp),%eax
  106c5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c62:	8d 50 ff             	lea    -0x1(%eax),%edx
  106c65:	8b 45 08             	mov    0x8(%ebp),%eax
  106c68:	01 d0                	add    %edx,%eax
  106c6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106c6d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  106c74:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  106c78:	74 0a                	je     106c84 <vsnprintf+0x31>
  106c7a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106c7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106c80:	39 c2                	cmp    %eax,%edx
  106c82:	76 07                	jbe    106c8b <vsnprintf+0x38>
        return -E_INVAL;
  106c84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  106c89:	eb 2a                	jmp    106cb5 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  106c8b:	8b 45 14             	mov    0x14(%ebp),%eax
  106c8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106c92:	8b 45 10             	mov    0x10(%ebp),%eax
  106c95:	89 44 24 08          	mov    %eax,0x8(%esp)
  106c99:	8d 45 ec             	lea    -0x14(%ebp),%eax
  106c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  106ca0:	c7 04 24 e9 6b 10 00 	movl   $0x106be9,(%esp)
  106ca7:	e8 64 fb ff ff       	call   106810 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  106cac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106caf:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  106cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106cb5:	c9                   	leave  
  106cb6:	c3                   	ret    