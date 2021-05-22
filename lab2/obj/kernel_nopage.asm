
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
  10005d:	e8 1d 66 00 00       	call   10667f <memset>

    cons_init();                // init the console
  100062:	e8 80 15 00 00       	call   1015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 80 6e 10 00 	movl   $0x106e80,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 9c 6e 10 00 	movl   $0x106e9c,(%esp)
  10007c:	e8 11 02 00 00       	call   100292 <cprintf>

    print_kerninfo();
  100081:	e8 b2 08 00 00       	call   100938 <print_kerninfo>

    grade_backtrace();
  100086:	e8 89 00 00 00       	call   100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 be 30 00 00       	call   10314e <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 b7 16 00 00       	call   10174c <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 3c 18 00 00       	call   1018d6 <idt_init>

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
  100162:	c7 04 24 a1 6e 10 00 	movl   $0x106ea1,(%esp)
  100169:	e8 24 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100172:	89 c2                	mov    %eax,%edx
  100174:	a1 00 d0 11 00       	mov    0x11d000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 af 6e 10 00 	movl   $0x106eaf,(%esp)
  100188:	e8 05 01 00 00       	call   100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	89 c2                	mov    %eax,%edx
  100193:	a1 00 d0 11 00       	mov    0x11d000,%eax
  100198:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a0:	c7 04 24 bd 6e 10 00 	movl   $0x106ebd,(%esp)
  1001a7:	e8 e6 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b0:	89 c2                	mov    %eax,%edx
  1001b2:	a1 00 d0 11 00       	mov    0x11d000,%eax
  1001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001bf:	c7 04 24 cb 6e 10 00 	movl   $0x106ecb,(%esp)
  1001c6:	e8 c7 00 00 00       	call   100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001cf:	89 c2                	mov    %eax,%edx
  1001d1:	a1 00 d0 11 00       	mov    0x11d000,%eax
  1001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001de:	c7 04 24 d9 6e 10 00 	movl   $0x106ed9,(%esp)
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
  10020f:	c7 04 24 e8 6e 10 00 	movl   $0x106ee8,(%esp)
  100216:	e8 77 00 00 00       	call   100292 <cprintf>
    lab1_switch_to_user();
  10021b:	e8 d8 ff ff ff       	call   1001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
  100220:	e8 15 ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100225:	c7 04 24 08 6f 10 00 	movl   $0x106f08,(%esp)
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
  100288:	e8 45 67 00 00       	call   1069d2 <vprintfmt>
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
  100347:	c7 04 24 27 6f 10 00 	movl   $0x106f27,(%esp)
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
  100416:	c7 04 24 2a 6f 10 00 	movl   $0x106f2a,(%esp)
  10041d:	e8 70 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100425:	89 44 24 04          	mov    %eax,0x4(%esp)
  100429:	8b 45 10             	mov    0x10(%ebp),%eax
  10042c:	89 04 24             	mov    %eax,(%esp)
  10042f:	e8 2b fe ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  100434:	c7 04 24 46 6f 10 00 	movl   $0x106f46,(%esp)
  10043b:	e8 52 fe ff ff       	call   100292 <cprintf>
    
    cprintf("stack trackback:\n");
  100440:	c7 04 24 48 6f 10 00 	movl   $0x106f48,(%esp)
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
  100481:	c7 04 24 5a 6f 10 00 	movl   $0x106f5a,(%esp)
  100488:	e8 05 fe ff ff       	call   100292 <cprintf>
    vcprintf(fmt, ap);
  10048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100490:	89 44 24 04          	mov    %eax,0x4(%esp)
  100494:	8b 45 10             	mov    0x10(%ebp),%eax
  100497:	89 04 24             	mov    %eax,(%esp)
  10049a:	e8 c0 fd ff ff       	call   10025f <vcprintf>
    cprintf("\n");
  10049f:	c7 04 24 46 6f 10 00 	movl   $0x106f46,(%esp)
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
  10060f:	c7 00 78 6f 10 00    	movl   $0x106f78,(%eax)
    info->eip_line = 0;
  100615:	8b 45 0c             	mov    0xc(%ebp),%eax
  100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10061f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100622:	c7 40 08 78 6f 10 00 	movl   $0x106f78,0x8(%eax)
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
  100646:	c7 45 f4 8c 84 10 00 	movl   $0x10848c,-0xc(%ebp)
    stab_end = __STAB_END__;
  10064d:	c7 45 f0 1c 4e 11 00 	movl   $0x114e1c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100654:	c7 45 ec 1d 4e 11 00 	movl   $0x114e1d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10065b:	c7 45 e8 06 7b 11 00 	movl   $0x117b06,-0x18(%ebp)

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
  1007b6:	e8 40 5d 00 00       	call   1064fb <strfind>
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
  10093e:	c7 04 24 82 6f 10 00 	movl   $0x106f82,(%esp)
  100945:	e8 48 f9 ff ff       	call   100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10094a:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100951:	00 
  100952:	c7 04 24 9b 6f 10 00 	movl   $0x106f9b,(%esp)
  100959:	e8 34 f9 ff ff       	call   100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10095e:	c7 44 24 04 79 6e 10 	movl   $0x106e79,0x4(%esp)
  100965:	00 
  100966:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  10096d:	e8 20 f9 ff ff       	call   100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100972:	c7 44 24 04 36 aa 11 	movl   $0x11aa36,0x4(%esp)
  100979:	00 
  10097a:	c7 04 24 cb 6f 10 00 	movl   $0x106fcb,(%esp)
  100981:	e8 0c f9 ff ff       	call   100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100986:	c7 44 24 04 bc df 11 	movl   $0x11dfbc,0x4(%esp)
  10098d:	00 
  10098e:	c7 04 24 e3 6f 10 00 	movl   $0x106fe3,(%esp)
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
  1009c0:	c7 04 24 fc 6f 10 00 	movl   $0x106ffc,(%esp)
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
  1009f5:	c7 04 24 26 70 10 00 	movl   $0x107026,(%esp)
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
  100a63:	c7 04 24 42 70 10 00 	movl   $0x107042,(%esp)
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
  100ab6:	c7 04 24 54 70 10 00 	movl   $0x107054,(%esp)
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
  100ae9:	c7 04 24 70 70 10 00 	movl   $0x107070,(%esp)
  100af0:	e8 9d f7 ff ff       	call   100292 <cprintf>
		for(int i=0;i<4;i++){
  100af5:	ff 45 e8             	incl   -0x18(%ebp)
  100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100afc:	7e d6                	jle    100ad4 <print_stackframe+0x51>
		}
		cprintf("\n");
  100afe:	c7 04 24 78 70 10 00 	movl   $0x107078,(%esp)
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
  100b71:	c7 04 24 fc 70 10 00 	movl   $0x1070fc,(%esp)
  100b78:	e8 4c 59 00 00       	call   1064c9 <strchr>
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
  100b99:	c7 04 24 01 71 10 00 	movl   $0x107101,(%esp)
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
  100bdb:	c7 04 24 fc 70 10 00 	movl   $0x1070fc,(%esp)
  100be2:	e8 e2 58 00 00       	call   1064c9 <strchr>
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
  100c48:	e8 df 57 00 00       	call   10642c <strcmp>
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
  100c94:	c7 04 24 1f 71 10 00 	movl   $0x10711f,(%esp)
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
  100cb1:	c7 04 24 38 71 10 00 	movl   $0x107138,(%esp)
  100cb8:	e8 d5 f5 ff ff       	call   100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cbd:	c7 04 24 60 71 10 00 	movl   $0x107160,(%esp)
  100cc4:	e8 c9 f5 ff ff       	call   100292 <cprintf>

    if (tf != NULL) {
  100cc9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100ccd:	74 0b                	je     100cda <kmonitor+0x2f>
        print_trapframe(tf);
  100ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  100cd2:	89 04 24             	mov    %eax,(%esp)
  100cd5:	e8 35 0d 00 00       	call   101a0f <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cda:	c7 04 24 85 71 10 00 	movl   $0x107185,(%esp)
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
  100d48:	c7 04 24 89 71 10 00 	movl   $0x107189,(%esp)
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
  100dd3:	c7 04 24 92 71 10 00 	movl   $0x107192,(%esp)
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
  101215:	e8 a5 54 00 00       	call   1066bf <memmove>
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
  101595:	c7 04 24 ad 71 10 00 	movl   $0x1071ad,(%esp)
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
  101605:	c7 04 24 b9 71 10 00 	movl   $0x1071b9,(%esp)
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
  1018a2:	c7 04 24 e0 71 10 00 	movl   $0x1071e0,(%esp)
  1018a9:	e8 e4 e9 ff ff       	call   100292 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  1018ae:	c7 04 24 ea 71 10 00 	movl   $0x1071ea,(%esp)
  1018b5:	e8 d8 e9 ff ff       	call   100292 <cprintf>
    panic("EOT: kernel seems ok.");
  1018ba:	c7 44 24 08 f8 71 10 	movl   $0x1071f8,0x8(%esp)
  1018c1:	00 
  1018c2:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  1018c9:	00 
  1018ca:	c7 04 24 0e 72 10 00 	movl   $0x10720e,(%esp)
  1018d1:	e8 13 eb ff ff       	call   1003e9 <__panic>

001018d6 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018d6:	55                   	push   %ebp
  1018d7:	89 e5                	mov    %esp,%ebp
  1018d9:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	for(int i=0;i<256;i++){
  1018dc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018e3:	e9 c4 00 00 00       	jmp    1019ac <idt_init+0xd6>
		SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL)
  1018e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018eb:	8b 04 85 e0 a5 11 00 	mov    0x11a5e0(,%eax,4),%eax
  1018f2:	0f b7 d0             	movzwl %ax,%edx
  1018f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f8:	66 89 14 c5 80 d6 11 	mov    %dx,0x11d680(,%eax,8)
  1018ff:	00 
  101900:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101903:	66 c7 04 c5 82 d6 11 	movw   $0x8,0x11d682(,%eax,8)
  10190a:	00 08 00 
  10190d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101910:	0f b6 14 c5 84 d6 11 	movzbl 0x11d684(,%eax,8),%edx
  101917:	00 
  101918:	80 e2 e0             	and    $0xe0,%dl
  10191b:	88 14 c5 84 d6 11 00 	mov    %dl,0x11d684(,%eax,8)
  101922:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101925:	0f b6 14 c5 84 d6 11 	movzbl 0x11d684(,%eax,8),%edx
  10192c:	00 
  10192d:	80 e2 1f             	and    $0x1f,%dl
  101930:	88 14 c5 84 d6 11 00 	mov    %dl,0x11d684(,%eax,8)
  101937:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10193a:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  101941:	00 
  101942:	80 e2 f0             	and    $0xf0,%dl
  101945:	80 ca 0e             	or     $0xe,%dl
  101948:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  10194f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101952:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  101959:	00 
  10195a:	80 e2 ef             	and    $0xef,%dl
  10195d:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  101964:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101967:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  10196e:	00 
  10196f:	80 e2 9f             	and    $0x9f,%dl
  101972:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197c:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  101983:	00 
  101984:	80 ca 80             	or     $0x80,%dl
  101987:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  10198e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101991:	8b 04 85 e0 a5 11 00 	mov    0x11a5e0(,%eax,4),%eax
  101998:	c1 e8 10             	shr    $0x10,%eax
  10199b:	0f b7 d0             	movzwl %ax,%edx
  10199e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019a1:	66 89 14 c5 86 d6 11 	mov    %dx,0x11d686(,%eax,8)
  1019a8:	00 
	for(int i=0;i<256;i++){
  1019a9:	ff 45 fc             	incl   -0x4(%ebp)
  1019ac:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  1019b3:	0f 8e 2f ff ff ff    	jle    1018e8 <idt_init+0x12>
  1019b9:	c7 45 f8 60 a5 11 00 	movl   $0x11a560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  1019c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1019c3:	0f 01 18             	lidtl  (%eax)
	}
	lidt(&idt_pd);
}
  1019c6:	90                   	nop
  1019c7:	c9                   	leave  
  1019c8:	c3                   	ret    

001019c9 <trapname>:

static const char *
trapname(int trapno) {
  1019c9:	55                   	push   %ebp
  1019ca:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  1019cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1019cf:	83 f8 13             	cmp    $0x13,%eax
  1019d2:	77 0c                	ja     1019e0 <trapname+0x17>
        return excnames[trapno];
  1019d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1019d7:	8b 04 85 60 75 10 00 	mov    0x107560(,%eax,4),%eax
  1019de:	eb 18                	jmp    1019f8 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  1019e0:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019e4:	7e 0d                	jle    1019f3 <trapname+0x2a>
  1019e6:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019ea:	7f 07                	jg     1019f3 <trapname+0x2a>
        return "Hardware Interrupt";
  1019ec:	b8 1f 72 10 00       	mov    $0x10721f,%eax
  1019f1:	eb 05                	jmp    1019f8 <trapname+0x2f>
    }
    return "(unknown trap)";
  1019f3:	b8 32 72 10 00       	mov    $0x107232,%eax
}
  1019f8:	5d                   	pop    %ebp
  1019f9:	c3                   	ret    

001019fa <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019fa:	55                   	push   %ebp
  1019fb:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019fd:	8b 45 08             	mov    0x8(%ebp),%eax
  101a00:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a04:	83 f8 08             	cmp    $0x8,%eax
  101a07:	0f 94 c0             	sete   %al
  101a0a:	0f b6 c0             	movzbl %al,%eax
}
  101a0d:	5d                   	pop    %ebp
  101a0e:	c3                   	ret    

00101a0f <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a0f:	55                   	push   %ebp
  101a10:	89 e5                	mov    %esp,%ebp
  101a12:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a15:	8b 45 08             	mov    0x8(%ebp),%eax
  101a18:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a1c:	c7 04 24 73 72 10 00 	movl   $0x107273,(%esp)
  101a23:	e8 6a e8 ff ff       	call   100292 <cprintf>
    print_regs(&tf->tf_regs);
  101a28:	8b 45 08             	mov    0x8(%ebp),%eax
  101a2b:	89 04 24             	mov    %eax,(%esp)
  101a2e:	e8 8f 01 00 00       	call   101bc2 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a33:	8b 45 08             	mov    0x8(%ebp),%eax
  101a36:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a3e:	c7 04 24 84 72 10 00 	movl   $0x107284,(%esp)
  101a45:	e8 48 e8 ff ff       	call   100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  101a4d:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a51:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a55:	c7 04 24 97 72 10 00 	movl   $0x107297,(%esp)
  101a5c:	e8 31 e8 ff ff       	call   100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a61:	8b 45 08             	mov    0x8(%ebp),%eax
  101a64:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a68:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a6c:	c7 04 24 aa 72 10 00 	movl   $0x1072aa,(%esp)
  101a73:	e8 1a e8 ff ff       	call   100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a78:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7b:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a83:	c7 04 24 bd 72 10 00 	movl   $0x1072bd,(%esp)
  101a8a:	e8 03 e8 ff ff       	call   100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  101a92:	8b 40 30             	mov    0x30(%eax),%eax
  101a95:	89 04 24             	mov    %eax,(%esp)
  101a98:	e8 2c ff ff ff       	call   1019c9 <trapname>
  101a9d:	89 c2                	mov    %eax,%edx
  101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa2:	8b 40 30             	mov    0x30(%eax),%eax
  101aa5:	89 54 24 08          	mov    %edx,0x8(%esp)
  101aa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aad:	c7 04 24 d0 72 10 00 	movl   $0x1072d0,(%esp)
  101ab4:	e8 d9 e7 ff ff       	call   100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  101abc:	8b 40 34             	mov    0x34(%eax),%eax
  101abf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac3:	c7 04 24 e2 72 10 00 	movl   $0x1072e2,(%esp)
  101aca:	e8 c3 e7 ff ff       	call   100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101acf:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad2:	8b 40 38             	mov    0x38(%eax),%eax
  101ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad9:	c7 04 24 f1 72 10 00 	movl   $0x1072f1,(%esp)
  101ae0:	e8 ad e7 ff ff       	call   100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101aec:	89 44 24 04          	mov    %eax,0x4(%esp)
  101af0:	c7 04 24 00 73 10 00 	movl   $0x107300,(%esp)
  101af7:	e8 96 e7 ff ff       	call   100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101afc:	8b 45 08             	mov    0x8(%ebp),%eax
  101aff:	8b 40 40             	mov    0x40(%eax),%eax
  101b02:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b06:	c7 04 24 13 73 10 00 	movl   $0x107313,(%esp)
  101b0d:	e8 80 e7 ff ff       	call   100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b19:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b20:	eb 3d                	jmp    101b5f <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b22:	8b 45 08             	mov    0x8(%ebp),%eax
  101b25:	8b 50 40             	mov    0x40(%eax),%edx
  101b28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b2b:	21 d0                	and    %edx,%eax
  101b2d:	85 c0                	test   %eax,%eax
  101b2f:	74 28                	je     101b59 <print_trapframe+0x14a>
  101b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b34:	8b 04 85 80 a5 11 00 	mov    0x11a580(,%eax,4),%eax
  101b3b:	85 c0                	test   %eax,%eax
  101b3d:	74 1a                	je     101b59 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b42:	8b 04 85 80 a5 11 00 	mov    0x11a580(,%eax,4),%eax
  101b49:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4d:	c7 04 24 22 73 10 00 	movl   $0x107322,(%esp)
  101b54:	e8 39 e7 ff ff       	call   100292 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b59:	ff 45 f4             	incl   -0xc(%ebp)
  101b5c:	d1 65 f0             	shll   -0x10(%ebp)
  101b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b62:	83 f8 17             	cmp    $0x17,%eax
  101b65:	76 bb                	jbe    101b22 <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b67:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6a:	8b 40 40             	mov    0x40(%eax),%eax
  101b6d:	c1 e8 0c             	shr    $0xc,%eax
  101b70:	83 e0 03             	and    $0x3,%eax
  101b73:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b77:	c7 04 24 26 73 10 00 	movl   $0x107326,(%esp)
  101b7e:	e8 0f e7 ff ff       	call   100292 <cprintf>

    if (!trap_in_kernel(tf)) {
  101b83:	8b 45 08             	mov    0x8(%ebp),%eax
  101b86:	89 04 24             	mov    %eax,(%esp)
  101b89:	e8 6c fe ff ff       	call   1019fa <trap_in_kernel>
  101b8e:	85 c0                	test   %eax,%eax
  101b90:	75 2d                	jne    101bbf <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b92:	8b 45 08             	mov    0x8(%ebp),%eax
  101b95:	8b 40 44             	mov    0x44(%eax),%eax
  101b98:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b9c:	c7 04 24 2f 73 10 00 	movl   $0x10732f,(%esp)
  101ba3:	e8 ea e6 ff ff       	call   100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  101bab:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101baf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bb3:	c7 04 24 3e 73 10 00 	movl   $0x10733e,(%esp)
  101bba:	e8 d3 e6 ff ff       	call   100292 <cprintf>
    }
}
  101bbf:	90                   	nop
  101bc0:	c9                   	leave  
  101bc1:	c3                   	ret    

00101bc2 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101bc2:	55                   	push   %ebp
  101bc3:	89 e5                	mov    %esp,%ebp
  101bc5:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  101bcb:	8b 00                	mov    (%eax),%eax
  101bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd1:	c7 04 24 51 73 10 00 	movl   $0x107351,(%esp)
  101bd8:	e8 b5 e6 ff ff       	call   100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  101be0:	8b 40 04             	mov    0x4(%eax),%eax
  101be3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be7:	c7 04 24 60 73 10 00 	movl   $0x107360,(%esp)
  101bee:	e8 9f e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf6:	8b 40 08             	mov    0x8(%eax),%eax
  101bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bfd:	c7 04 24 6f 73 10 00 	movl   $0x10736f,(%esp)
  101c04:	e8 89 e6 ff ff       	call   100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c09:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0c:	8b 40 0c             	mov    0xc(%eax),%eax
  101c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c13:	c7 04 24 7e 73 10 00 	movl   $0x10737e,(%esp)
  101c1a:	e8 73 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c22:	8b 40 10             	mov    0x10(%eax),%eax
  101c25:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c29:	c7 04 24 8d 73 10 00 	movl   $0x10738d,(%esp)
  101c30:	e8 5d e6 ff ff       	call   100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c35:	8b 45 08             	mov    0x8(%ebp),%eax
  101c38:	8b 40 14             	mov    0x14(%eax),%eax
  101c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c3f:	c7 04 24 9c 73 10 00 	movl   $0x10739c,(%esp)
  101c46:	e8 47 e6 ff ff       	call   100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c4e:	8b 40 18             	mov    0x18(%eax),%eax
  101c51:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c55:	c7 04 24 ab 73 10 00 	movl   $0x1073ab,(%esp)
  101c5c:	e8 31 e6 ff ff       	call   100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c61:	8b 45 08             	mov    0x8(%ebp),%eax
  101c64:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c67:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c6b:	c7 04 24 ba 73 10 00 	movl   $0x1073ba,(%esp)
  101c72:	e8 1b e6 ff ff       	call   100292 <cprintf>
}
  101c77:	90                   	nop
  101c78:	c9                   	leave  
  101c79:	c3                   	ret    

00101c7a <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c7a:	55                   	push   %ebp
  101c7b:	89 e5                	mov    %esp,%ebp
  101c7d:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101c80:	8b 45 08             	mov    0x8(%ebp),%eax
  101c83:	8b 40 30             	mov    0x30(%eax),%eax
  101c86:	83 f8 2f             	cmp    $0x2f,%eax
  101c89:	77 21                	ja     101cac <trap_dispatch+0x32>
  101c8b:	83 f8 2e             	cmp    $0x2e,%eax
  101c8e:	0f 83 0c 01 00 00    	jae    101da0 <trap_dispatch+0x126>
  101c94:	83 f8 21             	cmp    $0x21,%eax
  101c97:	0f 84 8c 00 00 00    	je     101d29 <trap_dispatch+0xaf>
  101c9d:	83 f8 24             	cmp    $0x24,%eax
  101ca0:	74 61                	je     101d03 <trap_dispatch+0x89>
  101ca2:	83 f8 20             	cmp    $0x20,%eax
  101ca5:	74 16                	je     101cbd <trap_dispatch+0x43>
  101ca7:	e9 bf 00 00 00       	jmp    101d6b <trap_dispatch+0xf1>
  101cac:	83 e8 78             	sub    $0x78,%eax
  101caf:	83 f8 01             	cmp    $0x1,%eax
  101cb2:	0f 87 b3 00 00 00    	ja     101d6b <trap_dispatch+0xf1>
  101cb8:	e9 92 00 00 00       	jmp    101d4f <trap_dispatch+0xd5>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	ticks+=1;
  101cbd:	a1 0c df 11 00       	mov    0x11df0c,%eax
  101cc2:	40                   	inc    %eax
  101cc3:	a3 0c df 11 00       	mov    %eax,0x11df0c
	if(ticks%TICK_NUM==0){
  101cc8:	8b 0d 0c df 11 00    	mov    0x11df0c,%ecx
  101cce:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101cd3:	89 c8                	mov    %ecx,%eax
  101cd5:	f7 e2                	mul    %edx
  101cd7:	c1 ea 05             	shr    $0x5,%edx
  101cda:	89 d0                	mov    %edx,%eax
  101cdc:	c1 e0 02             	shl    $0x2,%eax
  101cdf:	01 d0                	add    %edx,%eax
  101ce1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101ce8:	01 d0                	add    %edx,%eax
  101cea:	c1 e0 02             	shl    $0x2,%eax
  101ced:	29 c1                	sub    %eax,%ecx
  101cef:	89 ca                	mov    %ecx,%edx
  101cf1:	85 d2                	test   %edx,%edx
  101cf3:	0f 85 aa 00 00 00    	jne    101da3 <trap_dispatch+0x129>
		print_ticks();	
  101cf9:	e8 96 fb ff ff       	call   101894 <print_ticks>
	}
        break;
  101cfe:	e9 a0 00 00 00       	jmp    101da3 <trap_dispatch+0x129>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d03:	e8 49 f9 ff ff       	call   101651 <cons_getc>
  101d08:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d0b:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d0f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d13:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d17:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d1b:	c7 04 24 c9 73 10 00 	movl   $0x1073c9,(%esp)
  101d22:	e8 6b e5 ff ff       	call   100292 <cprintf>
        break;
  101d27:	eb 7b                	jmp    101da4 <trap_dispatch+0x12a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d29:	e8 23 f9 ff ff       	call   101651 <cons_getc>
  101d2e:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d31:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d35:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d39:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d41:	c7 04 24 db 73 10 00 	movl   $0x1073db,(%esp)
  101d48:	e8 45 e5 ff ff       	call   100292 <cprintf>
        break;
  101d4d:	eb 55                	jmp    101da4 <trap_dispatch+0x12a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d4f:	c7 44 24 08 ea 73 10 	movl   $0x1073ea,0x8(%esp)
  101d56:	00 
  101d57:	c7 44 24 04 ab 00 00 	movl   $0xab,0x4(%esp)
  101d5e:	00 
  101d5f:	c7 04 24 0e 72 10 00 	movl   $0x10720e,(%esp)
  101d66:	e8 7e e6 ff ff       	call   1003e9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  101d6e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d72:	83 e0 03             	and    $0x3,%eax
  101d75:	85 c0                	test   %eax,%eax
  101d77:	75 2b                	jne    101da4 <trap_dispatch+0x12a>
            print_trapframe(tf);
  101d79:	8b 45 08             	mov    0x8(%ebp),%eax
  101d7c:	89 04 24             	mov    %eax,(%esp)
  101d7f:	e8 8b fc ff ff       	call   101a0f <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101d84:	c7 44 24 08 fa 73 10 	movl   $0x1073fa,0x8(%esp)
  101d8b:	00 
  101d8c:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  101d93:	00 
  101d94:	c7 04 24 0e 72 10 00 	movl   $0x10720e,(%esp)
  101d9b:	e8 49 e6 ff ff       	call   1003e9 <__panic>
        break;
  101da0:	90                   	nop
  101da1:	eb 01                	jmp    101da4 <trap_dispatch+0x12a>
        break;
  101da3:	90                   	nop
        }
    }
}
  101da4:	90                   	nop
  101da5:	c9                   	leave  
  101da6:	c3                   	ret    

00101da7 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101da7:	55                   	push   %ebp
  101da8:	89 e5                	mov    %esp,%ebp
  101daa:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101dad:	8b 45 08             	mov    0x8(%ebp),%eax
  101db0:	89 04 24             	mov    %eax,(%esp)
  101db3:	e8 c2 fe ff ff       	call   101c7a <trap_dispatch>
}
  101db8:	90                   	nop
  101db9:	c9                   	leave  
  101dba:	c3                   	ret    

00101dbb <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101dbb:	6a 00                	push   $0x0
  pushl $0
  101dbd:	6a 00                	push   $0x0
  jmp __alltraps
  101dbf:	e9 69 0a 00 00       	jmp    10282d <__alltraps>

00101dc4 <vector1>:
.globl vector1
vector1:
  pushl $0
  101dc4:	6a 00                	push   $0x0
  pushl $1
  101dc6:	6a 01                	push   $0x1
  jmp __alltraps
  101dc8:	e9 60 0a 00 00       	jmp    10282d <__alltraps>

00101dcd <vector2>:
.globl vector2
vector2:
  pushl $0
  101dcd:	6a 00                	push   $0x0
  pushl $2
  101dcf:	6a 02                	push   $0x2
  jmp __alltraps
  101dd1:	e9 57 0a 00 00       	jmp    10282d <__alltraps>

00101dd6 <vector3>:
.globl vector3
vector3:
  pushl $0
  101dd6:	6a 00                	push   $0x0
  pushl $3
  101dd8:	6a 03                	push   $0x3
  jmp __alltraps
  101dda:	e9 4e 0a 00 00       	jmp    10282d <__alltraps>

00101ddf <vector4>:
.globl vector4
vector4:
  pushl $0
  101ddf:	6a 00                	push   $0x0
  pushl $4
  101de1:	6a 04                	push   $0x4
  jmp __alltraps
  101de3:	e9 45 0a 00 00       	jmp    10282d <__alltraps>

00101de8 <vector5>:
.globl vector5
vector5:
  pushl $0
  101de8:	6a 00                	push   $0x0
  pushl $5
  101dea:	6a 05                	push   $0x5
  jmp __alltraps
  101dec:	e9 3c 0a 00 00       	jmp    10282d <__alltraps>

00101df1 <vector6>:
.globl vector6
vector6:
  pushl $0
  101df1:	6a 00                	push   $0x0
  pushl $6
  101df3:	6a 06                	push   $0x6
  jmp __alltraps
  101df5:	e9 33 0a 00 00       	jmp    10282d <__alltraps>

00101dfa <vector7>:
.globl vector7
vector7:
  pushl $0
  101dfa:	6a 00                	push   $0x0
  pushl $7
  101dfc:	6a 07                	push   $0x7
  jmp __alltraps
  101dfe:	e9 2a 0a 00 00       	jmp    10282d <__alltraps>

00101e03 <vector8>:
.globl vector8
vector8:
  pushl $8
  101e03:	6a 08                	push   $0x8
  jmp __alltraps
  101e05:	e9 23 0a 00 00       	jmp    10282d <__alltraps>

00101e0a <vector9>:
.globl vector9
vector9:
  pushl $0
  101e0a:	6a 00                	push   $0x0
  pushl $9
  101e0c:	6a 09                	push   $0x9
  jmp __alltraps
  101e0e:	e9 1a 0a 00 00       	jmp    10282d <__alltraps>

00101e13 <vector10>:
.globl vector10
vector10:
  pushl $10
  101e13:	6a 0a                	push   $0xa
  jmp __alltraps
  101e15:	e9 13 0a 00 00       	jmp    10282d <__alltraps>

00101e1a <vector11>:
.globl vector11
vector11:
  pushl $11
  101e1a:	6a 0b                	push   $0xb
  jmp __alltraps
  101e1c:	e9 0c 0a 00 00       	jmp    10282d <__alltraps>

00101e21 <vector12>:
.globl vector12
vector12:
  pushl $12
  101e21:	6a 0c                	push   $0xc
  jmp __alltraps
  101e23:	e9 05 0a 00 00       	jmp    10282d <__alltraps>

00101e28 <vector13>:
.globl vector13
vector13:
  pushl $13
  101e28:	6a 0d                	push   $0xd
  jmp __alltraps
  101e2a:	e9 fe 09 00 00       	jmp    10282d <__alltraps>

00101e2f <vector14>:
.globl vector14
vector14:
  pushl $14
  101e2f:	6a 0e                	push   $0xe
  jmp __alltraps
  101e31:	e9 f7 09 00 00       	jmp    10282d <__alltraps>

00101e36 <vector15>:
.globl vector15
vector15:
  pushl $0
  101e36:	6a 00                	push   $0x0
  pushl $15
  101e38:	6a 0f                	push   $0xf
  jmp __alltraps
  101e3a:	e9 ee 09 00 00       	jmp    10282d <__alltraps>

00101e3f <vector16>:
.globl vector16
vector16:
  pushl $0
  101e3f:	6a 00                	push   $0x0
  pushl $16
  101e41:	6a 10                	push   $0x10
  jmp __alltraps
  101e43:	e9 e5 09 00 00       	jmp    10282d <__alltraps>

00101e48 <vector17>:
.globl vector17
vector17:
  pushl $17
  101e48:	6a 11                	push   $0x11
  jmp __alltraps
  101e4a:	e9 de 09 00 00       	jmp    10282d <__alltraps>

00101e4f <vector18>:
.globl vector18
vector18:
  pushl $0
  101e4f:	6a 00                	push   $0x0
  pushl $18
  101e51:	6a 12                	push   $0x12
  jmp __alltraps
  101e53:	e9 d5 09 00 00       	jmp    10282d <__alltraps>

00101e58 <vector19>:
.globl vector19
vector19:
  pushl $0
  101e58:	6a 00                	push   $0x0
  pushl $19
  101e5a:	6a 13                	push   $0x13
  jmp __alltraps
  101e5c:	e9 cc 09 00 00       	jmp    10282d <__alltraps>

00101e61 <vector20>:
.globl vector20
vector20:
  pushl $0
  101e61:	6a 00                	push   $0x0
  pushl $20
  101e63:	6a 14                	push   $0x14
  jmp __alltraps
  101e65:	e9 c3 09 00 00       	jmp    10282d <__alltraps>

00101e6a <vector21>:
.globl vector21
vector21:
  pushl $0
  101e6a:	6a 00                	push   $0x0
  pushl $21
  101e6c:	6a 15                	push   $0x15
  jmp __alltraps
  101e6e:	e9 ba 09 00 00       	jmp    10282d <__alltraps>

00101e73 <vector22>:
.globl vector22
vector22:
  pushl $0
  101e73:	6a 00                	push   $0x0
  pushl $22
  101e75:	6a 16                	push   $0x16
  jmp __alltraps
  101e77:	e9 b1 09 00 00       	jmp    10282d <__alltraps>

00101e7c <vector23>:
.globl vector23
vector23:
  pushl $0
  101e7c:	6a 00                	push   $0x0
  pushl $23
  101e7e:	6a 17                	push   $0x17
  jmp __alltraps
  101e80:	e9 a8 09 00 00       	jmp    10282d <__alltraps>

00101e85 <vector24>:
.globl vector24
vector24:
  pushl $0
  101e85:	6a 00                	push   $0x0
  pushl $24
  101e87:	6a 18                	push   $0x18
  jmp __alltraps
  101e89:	e9 9f 09 00 00       	jmp    10282d <__alltraps>

00101e8e <vector25>:
.globl vector25
vector25:
  pushl $0
  101e8e:	6a 00                	push   $0x0
  pushl $25
  101e90:	6a 19                	push   $0x19
  jmp __alltraps
  101e92:	e9 96 09 00 00       	jmp    10282d <__alltraps>

00101e97 <vector26>:
.globl vector26
vector26:
  pushl $0
  101e97:	6a 00                	push   $0x0
  pushl $26
  101e99:	6a 1a                	push   $0x1a
  jmp __alltraps
  101e9b:	e9 8d 09 00 00       	jmp    10282d <__alltraps>

00101ea0 <vector27>:
.globl vector27
vector27:
  pushl $0
  101ea0:	6a 00                	push   $0x0
  pushl $27
  101ea2:	6a 1b                	push   $0x1b
  jmp __alltraps
  101ea4:	e9 84 09 00 00       	jmp    10282d <__alltraps>

00101ea9 <vector28>:
.globl vector28
vector28:
  pushl $0
  101ea9:	6a 00                	push   $0x0
  pushl $28
  101eab:	6a 1c                	push   $0x1c
  jmp __alltraps
  101ead:	e9 7b 09 00 00       	jmp    10282d <__alltraps>

00101eb2 <vector29>:
.globl vector29
vector29:
  pushl $0
  101eb2:	6a 00                	push   $0x0
  pushl $29
  101eb4:	6a 1d                	push   $0x1d
  jmp __alltraps
  101eb6:	e9 72 09 00 00       	jmp    10282d <__alltraps>

00101ebb <vector30>:
.globl vector30
vector30:
  pushl $0
  101ebb:	6a 00                	push   $0x0
  pushl $30
  101ebd:	6a 1e                	push   $0x1e
  jmp __alltraps
  101ebf:	e9 69 09 00 00       	jmp    10282d <__alltraps>

00101ec4 <vector31>:
.globl vector31
vector31:
  pushl $0
  101ec4:	6a 00                	push   $0x0
  pushl $31
  101ec6:	6a 1f                	push   $0x1f
  jmp __alltraps
  101ec8:	e9 60 09 00 00       	jmp    10282d <__alltraps>

00101ecd <vector32>:
.globl vector32
vector32:
  pushl $0
  101ecd:	6a 00                	push   $0x0
  pushl $32
  101ecf:	6a 20                	push   $0x20
  jmp __alltraps
  101ed1:	e9 57 09 00 00       	jmp    10282d <__alltraps>

00101ed6 <vector33>:
.globl vector33
vector33:
  pushl $0
  101ed6:	6a 00                	push   $0x0
  pushl $33
  101ed8:	6a 21                	push   $0x21
  jmp __alltraps
  101eda:	e9 4e 09 00 00       	jmp    10282d <__alltraps>

00101edf <vector34>:
.globl vector34
vector34:
  pushl $0
  101edf:	6a 00                	push   $0x0
  pushl $34
  101ee1:	6a 22                	push   $0x22
  jmp __alltraps
  101ee3:	e9 45 09 00 00       	jmp    10282d <__alltraps>

00101ee8 <vector35>:
.globl vector35
vector35:
  pushl $0
  101ee8:	6a 00                	push   $0x0
  pushl $35
  101eea:	6a 23                	push   $0x23
  jmp __alltraps
  101eec:	e9 3c 09 00 00       	jmp    10282d <__alltraps>

00101ef1 <vector36>:
.globl vector36
vector36:
  pushl $0
  101ef1:	6a 00                	push   $0x0
  pushl $36
  101ef3:	6a 24                	push   $0x24
  jmp __alltraps
  101ef5:	e9 33 09 00 00       	jmp    10282d <__alltraps>

00101efa <vector37>:
.globl vector37
vector37:
  pushl $0
  101efa:	6a 00                	push   $0x0
  pushl $37
  101efc:	6a 25                	push   $0x25
  jmp __alltraps
  101efe:	e9 2a 09 00 00       	jmp    10282d <__alltraps>

00101f03 <vector38>:
.globl vector38
vector38:
  pushl $0
  101f03:	6a 00                	push   $0x0
  pushl $38
  101f05:	6a 26                	push   $0x26
  jmp __alltraps
  101f07:	e9 21 09 00 00       	jmp    10282d <__alltraps>

00101f0c <vector39>:
.globl vector39
vector39:
  pushl $0
  101f0c:	6a 00                	push   $0x0
  pushl $39
  101f0e:	6a 27                	push   $0x27
  jmp __alltraps
  101f10:	e9 18 09 00 00       	jmp    10282d <__alltraps>

00101f15 <vector40>:
.globl vector40
vector40:
  pushl $0
  101f15:	6a 00                	push   $0x0
  pushl $40
  101f17:	6a 28                	push   $0x28
  jmp __alltraps
  101f19:	e9 0f 09 00 00       	jmp    10282d <__alltraps>

00101f1e <vector41>:
.globl vector41
vector41:
  pushl $0
  101f1e:	6a 00                	push   $0x0
  pushl $41
  101f20:	6a 29                	push   $0x29
  jmp __alltraps
  101f22:	e9 06 09 00 00       	jmp    10282d <__alltraps>

00101f27 <vector42>:
.globl vector42
vector42:
  pushl $0
  101f27:	6a 00                	push   $0x0
  pushl $42
  101f29:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f2b:	e9 fd 08 00 00       	jmp    10282d <__alltraps>

00101f30 <vector43>:
.globl vector43
vector43:
  pushl $0
  101f30:	6a 00                	push   $0x0
  pushl $43
  101f32:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f34:	e9 f4 08 00 00       	jmp    10282d <__alltraps>

00101f39 <vector44>:
.globl vector44
vector44:
  pushl $0
  101f39:	6a 00                	push   $0x0
  pushl $44
  101f3b:	6a 2c                	push   $0x2c
  jmp __alltraps
  101f3d:	e9 eb 08 00 00       	jmp    10282d <__alltraps>

00101f42 <vector45>:
.globl vector45
vector45:
  pushl $0
  101f42:	6a 00                	push   $0x0
  pushl $45
  101f44:	6a 2d                	push   $0x2d
  jmp __alltraps
  101f46:	e9 e2 08 00 00       	jmp    10282d <__alltraps>

00101f4b <vector46>:
.globl vector46
vector46:
  pushl $0
  101f4b:	6a 00                	push   $0x0
  pushl $46
  101f4d:	6a 2e                	push   $0x2e
  jmp __alltraps
  101f4f:	e9 d9 08 00 00       	jmp    10282d <__alltraps>

00101f54 <vector47>:
.globl vector47
vector47:
  pushl $0
  101f54:	6a 00                	push   $0x0
  pushl $47
  101f56:	6a 2f                	push   $0x2f
  jmp __alltraps
  101f58:	e9 d0 08 00 00       	jmp    10282d <__alltraps>

00101f5d <vector48>:
.globl vector48
vector48:
  pushl $0
  101f5d:	6a 00                	push   $0x0
  pushl $48
  101f5f:	6a 30                	push   $0x30
  jmp __alltraps
  101f61:	e9 c7 08 00 00       	jmp    10282d <__alltraps>

00101f66 <vector49>:
.globl vector49
vector49:
  pushl $0
  101f66:	6a 00                	push   $0x0
  pushl $49
  101f68:	6a 31                	push   $0x31
  jmp __alltraps
  101f6a:	e9 be 08 00 00       	jmp    10282d <__alltraps>

00101f6f <vector50>:
.globl vector50
vector50:
  pushl $0
  101f6f:	6a 00                	push   $0x0
  pushl $50
  101f71:	6a 32                	push   $0x32
  jmp __alltraps
  101f73:	e9 b5 08 00 00       	jmp    10282d <__alltraps>

00101f78 <vector51>:
.globl vector51
vector51:
  pushl $0
  101f78:	6a 00                	push   $0x0
  pushl $51
  101f7a:	6a 33                	push   $0x33
  jmp __alltraps
  101f7c:	e9 ac 08 00 00       	jmp    10282d <__alltraps>

00101f81 <vector52>:
.globl vector52
vector52:
  pushl $0
  101f81:	6a 00                	push   $0x0
  pushl $52
  101f83:	6a 34                	push   $0x34
  jmp __alltraps
  101f85:	e9 a3 08 00 00       	jmp    10282d <__alltraps>

00101f8a <vector53>:
.globl vector53
vector53:
  pushl $0
  101f8a:	6a 00                	push   $0x0
  pushl $53
  101f8c:	6a 35                	push   $0x35
  jmp __alltraps
  101f8e:	e9 9a 08 00 00       	jmp    10282d <__alltraps>

00101f93 <vector54>:
.globl vector54
vector54:
  pushl $0
  101f93:	6a 00                	push   $0x0
  pushl $54
  101f95:	6a 36                	push   $0x36
  jmp __alltraps
  101f97:	e9 91 08 00 00       	jmp    10282d <__alltraps>

00101f9c <vector55>:
.globl vector55
vector55:
  pushl $0
  101f9c:	6a 00                	push   $0x0
  pushl $55
  101f9e:	6a 37                	push   $0x37
  jmp __alltraps
  101fa0:	e9 88 08 00 00       	jmp    10282d <__alltraps>

00101fa5 <vector56>:
.globl vector56
vector56:
  pushl $0
  101fa5:	6a 00                	push   $0x0
  pushl $56
  101fa7:	6a 38                	push   $0x38
  jmp __alltraps
  101fa9:	e9 7f 08 00 00       	jmp    10282d <__alltraps>

00101fae <vector57>:
.globl vector57
vector57:
  pushl $0
  101fae:	6a 00                	push   $0x0
  pushl $57
  101fb0:	6a 39                	push   $0x39
  jmp __alltraps
  101fb2:	e9 76 08 00 00       	jmp    10282d <__alltraps>

00101fb7 <vector58>:
.globl vector58
vector58:
  pushl $0
  101fb7:	6a 00                	push   $0x0
  pushl $58
  101fb9:	6a 3a                	push   $0x3a
  jmp __alltraps
  101fbb:	e9 6d 08 00 00       	jmp    10282d <__alltraps>

00101fc0 <vector59>:
.globl vector59
vector59:
  pushl $0
  101fc0:	6a 00                	push   $0x0
  pushl $59
  101fc2:	6a 3b                	push   $0x3b
  jmp __alltraps
  101fc4:	e9 64 08 00 00       	jmp    10282d <__alltraps>

00101fc9 <vector60>:
.globl vector60
vector60:
  pushl $0
  101fc9:	6a 00                	push   $0x0
  pushl $60
  101fcb:	6a 3c                	push   $0x3c
  jmp __alltraps
  101fcd:	e9 5b 08 00 00       	jmp    10282d <__alltraps>

00101fd2 <vector61>:
.globl vector61
vector61:
  pushl $0
  101fd2:	6a 00                	push   $0x0
  pushl $61
  101fd4:	6a 3d                	push   $0x3d
  jmp __alltraps
  101fd6:	e9 52 08 00 00       	jmp    10282d <__alltraps>

00101fdb <vector62>:
.globl vector62
vector62:
  pushl $0
  101fdb:	6a 00                	push   $0x0
  pushl $62
  101fdd:	6a 3e                	push   $0x3e
  jmp __alltraps
  101fdf:	e9 49 08 00 00       	jmp    10282d <__alltraps>

00101fe4 <vector63>:
.globl vector63
vector63:
  pushl $0
  101fe4:	6a 00                	push   $0x0
  pushl $63
  101fe6:	6a 3f                	push   $0x3f
  jmp __alltraps
  101fe8:	e9 40 08 00 00       	jmp    10282d <__alltraps>

00101fed <vector64>:
.globl vector64
vector64:
  pushl $0
  101fed:	6a 00                	push   $0x0
  pushl $64
  101fef:	6a 40                	push   $0x40
  jmp __alltraps
  101ff1:	e9 37 08 00 00       	jmp    10282d <__alltraps>

00101ff6 <vector65>:
.globl vector65
vector65:
  pushl $0
  101ff6:	6a 00                	push   $0x0
  pushl $65
  101ff8:	6a 41                	push   $0x41
  jmp __alltraps
  101ffa:	e9 2e 08 00 00       	jmp    10282d <__alltraps>

00101fff <vector66>:
.globl vector66
vector66:
  pushl $0
  101fff:	6a 00                	push   $0x0
  pushl $66
  102001:	6a 42                	push   $0x42
  jmp __alltraps
  102003:	e9 25 08 00 00       	jmp    10282d <__alltraps>

00102008 <vector67>:
.globl vector67
vector67:
  pushl $0
  102008:	6a 00                	push   $0x0
  pushl $67
  10200a:	6a 43                	push   $0x43
  jmp __alltraps
  10200c:	e9 1c 08 00 00       	jmp    10282d <__alltraps>

00102011 <vector68>:
.globl vector68
vector68:
  pushl $0
  102011:	6a 00                	push   $0x0
  pushl $68
  102013:	6a 44                	push   $0x44
  jmp __alltraps
  102015:	e9 13 08 00 00       	jmp    10282d <__alltraps>

0010201a <vector69>:
.globl vector69
vector69:
  pushl $0
  10201a:	6a 00                	push   $0x0
  pushl $69
  10201c:	6a 45                	push   $0x45
  jmp __alltraps
  10201e:	e9 0a 08 00 00       	jmp    10282d <__alltraps>

00102023 <vector70>:
.globl vector70
vector70:
  pushl $0
  102023:	6a 00                	push   $0x0
  pushl $70
  102025:	6a 46                	push   $0x46
  jmp __alltraps
  102027:	e9 01 08 00 00       	jmp    10282d <__alltraps>

0010202c <vector71>:
.globl vector71
vector71:
  pushl $0
  10202c:	6a 00                	push   $0x0
  pushl $71
  10202e:	6a 47                	push   $0x47
  jmp __alltraps
  102030:	e9 f8 07 00 00       	jmp    10282d <__alltraps>

00102035 <vector72>:
.globl vector72
vector72:
  pushl $0
  102035:	6a 00                	push   $0x0
  pushl $72
  102037:	6a 48                	push   $0x48
  jmp __alltraps
  102039:	e9 ef 07 00 00       	jmp    10282d <__alltraps>

0010203e <vector73>:
.globl vector73
vector73:
  pushl $0
  10203e:	6a 00                	push   $0x0
  pushl $73
  102040:	6a 49                	push   $0x49
  jmp __alltraps
  102042:	e9 e6 07 00 00       	jmp    10282d <__alltraps>

00102047 <vector74>:
.globl vector74
vector74:
  pushl $0
  102047:	6a 00                	push   $0x0
  pushl $74
  102049:	6a 4a                	push   $0x4a
  jmp __alltraps
  10204b:	e9 dd 07 00 00       	jmp    10282d <__alltraps>

00102050 <vector75>:
.globl vector75
vector75:
  pushl $0
  102050:	6a 00                	push   $0x0
  pushl $75
  102052:	6a 4b                	push   $0x4b
  jmp __alltraps
  102054:	e9 d4 07 00 00       	jmp    10282d <__alltraps>

00102059 <vector76>:
.globl vector76
vector76:
  pushl $0
  102059:	6a 00                	push   $0x0
  pushl $76
  10205b:	6a 4c                	push   $0x4c
  jmp __alltraps
  10205d:	e9 cb 07 00 00       	jmp    10282d <__alltraps>

00102062 <vector77>:
.globl vector77
vector77:
  pushl $0
  102062:	6a 00                	push   $0x0
  pushl $77
  102064:	6a 4d                	push   $0x4d
  jmp __alltraps
  102066:	e9 c2 07 00 00       	jmp    10282d <__alltraps>

0010206b <vector78>:
.globl vector78
vector78:
  pushl $0
  10206b:	6a 00                	push   $0x0
  pushl $78
  10206d:	6a 4e                	push   $0x4e
  jmp __alltraps
  10206f:	e9 b9 07 00 00       	jmp    10282d <__alltraps>

00102074 <vector79>:
.globl vector79
vector79:
  pushl $0
  102074:	6a 00                	push   $0x0
  pushl $79
  102076:	6a 4f                	push   $0x4f
  jmp __alltraps
  102078:	e9 b0 07 00 00       	jmp    10282d <__alltraps>

0010207d <vector80>:
.globl vector80
vector80:
  pushl $0
  10207d:	6a 00                	push   $0x0
  pushl $80
  10207f:	6a 50                	push   $0x50
  jmp __alltraps
  102081:	e9 a7 07 00 00       	jmp    10282d <__alltraps>

00102086 <vector81>:
.globl vector81
vector81:
  pushl $0
  102086:	6a 00                	push   $0x0
  pushl $81
  102088:	6a 51                	push   $0x51
  jmp __alltraps
  10208a:	e9 9e 07 00 00       	jmp    10282d <__alltraps>

0010208f <vector82>:
.globl vector82
vector82:
  pushl $0
  10208f:	6a 00                	push   $0x0
  pushl $82
  102091:	6a 52                	push   $0x52
  jmp __alltraps
  102093:	e9 95 07 00 00       	jmp    10282d <__alltraps>

00102098 <vector83>:
.globl vector83
vector83:
  pushl $0
  102098:	6a 00                	push   $0x0
  pushl $83
  10209a:	6a 53                	push   $0x53
  jmp __alltraps
  10209c:	e9 8c 07 00 00       	jmp    10282d <__alltraps>

001020a1 <vector84>:
.globl vector84
vector84:
  pushl $0
  1020a1:	6a 00                	push   $0x0
  pushl $84
  1020a3:	6a 54                	push   $0x54
  jmp __alltraps
  1020a5:	e9 83 07 00 00       	jmp    10282d <__alltraps>

001020aa <vector85>:
.globl vector85
vector85:
  pushl $0
  1020aa:	6a 00                	push   $0x0
  pushl $85
  1020ac:	6a 55                	push   $0x55
  jmp __alltraps
  1020ae:	e9 7a 07 00 00       	jmp    10282d <__alltraps>

001020b3 <vector86>:
.globl vector86
vector86:
  pushl $0
  1020b3:	6a 00                	push   $0x0
  pushl $86
  1020b5:	6a 56                	push   $0x56
  jmp __alltraps
  1020b7:	e9 71 07 00 00       	jmp    10282d <__alltraps>

001020bc <vector87>:
.globl vector87
vector87:
  pushl $0
  1020bc:	6a 00                	push   $0x0
  pushl $87
  1020be:	6a 57                	push   $0x57
  jmp __alltraps
  1020c0:	e9 68 07 00 00       	jmp    10282d <__alltraps>

001020c5 <vector88>:
.globl vector88
vector88:
  pushl $0
  1020c5:	6a 00                	push   $0x0
  pushl $88
  1020c7:	6a 58                	push   $0x58
  jmp __alltraps
  1020c9:	e9 5f 07 00 00       	jmp    10282d <__alltraps>

001020ce <vector89>:
.globl vector89
vector89:
  pushl $0
  1020ce:	6a 00                	push   $0x0
  pushl $89
  1020d0:	6a 59                	push   $0x59
  jmp __alltraps
  1020d2:	e9 56 07 00 00       	jmp    10282d <__alltraps>

001020d7 <vector90>:
.globl vector90
vector90:
  pushl $0
  1020d7:	6a 00                	push   $0x0
  pushl $90
  1020d9:	6a 5a                	push   $0x5a
  jmp __alltraps
  1020db:	e9 4d 07 00 00       	jmp    10282d <__alltraps>

001020e0 <vector91>:
.globl vector91
vector91:
  pushl $0
  1020e0:	6a 00                	push   $0x0
  pushl $91
  1020e2:	6a 5b                	push   $0x5b
  jmp __alltraps
  1020e4:	e9 44 07 00 00       	jmp    10282d <__alltraps>

001020e9 <vector92>:
.globl vector92
vector92:
  pushl $0
  1020e9:	6a 00                	push   $0x0
  pushl $92
  1020eb:	6a 5c                	push   $0x5c
  jmp __alltraps
  1020ed:	e9 3b 07 00 00       	jmp    10282d <__alltraps>

001020f2 <vector93>:
.globl vector93
vector93:
  pushl $0
  1020f2:	6a 00                	push   $0x0
  pushl $93
  1020f4:	6a 5d                	push   $0x5d
  jmp __alltraps
  1020f6:	e9 32 07 00 00       	jmp    10282d <__alltraps>

001020fb <vector94>:
.globl vector94
vector94:
  pushl $0
  1020fb:	6a 00                	push   $0x0
  pushl $94
  1020fd:	6a 5e                	push   $0x5e
  jmp __alltraps
  1020ff:	e9 29 07 00 00       	jmp    10282d <__alltraps>

00102104 <vector95>:
.globl vector95
vector95:
  pushl $0
  102104:	6a 00                	push   $0x0
  pushl $95
  102106:	6a 5f                	push   $0x5f
  jmp __alltraps
  102108:	e9 20 07 00 00       	jmp    10282d <__alltraps>

0010210d <vector96>:
.globl vector96
vector96:
  pushl $0
  10210d:	6a 00                	push   $0x0
  pushl $96
  10210f:	6a 60                	push   $0x60
  jmp __alltraps
  102111:	e9 17 07 00 00       	jmp    10282d <__alltraps>

00102116 <vector97>:
.globl vector97
vector97:
  pushl $0
  102116:	6a 00                	push   $0x0
  pushl $97
  102118:	6a 61                	push   $0x61
  jmp __alltraps
  10211a:	e9 0e 07 00 00       	jmp    10282d <__alltraps>

0010211f <vector98>:
.globl vector98
vector98:
  pushl $0
  10211f:	6a 00                	push   $0x0
  pushl $98
  102121:	6a 62                	push   $0x62
  jmp __alltraps
  102123:	e9 05 07 00 00       	jmp    10282d <__alltraps>

00102128 <vector99>:
.globl vector99
vector99:
  pushl $0
  102128:	6a 00                	push   $0x0
  pushl $99
  10212a:	6a 63                	push   $0x63
  jmp __alltraps
  10212c:	e9 fc 06 00 00       	jmp    10282d <__alltraps>

00102131 <vector100>:
.globl vector100
vector100:
  pushl $0
  102131:	6a 00                	push   $0x0
  pushl $100
  102133:	6a 64                	push   $0x64
  jmp __alltraps
  102135:	e9 f3 06 00 00       	jmp    10282d <__alltraps>

0010213a <vector101>:
.globl vector101
vector101:
  pushl $0
  10213a:	6a 00                	push   $0x0
  pushl $101
  10213c:	6a 65                	push   $0x65
  jmp __alltraps
  10213e:	e9 ea 06 00 00       	jmp    10282d <__alltraps>

00102143 <vector102>:
.globl vector102
vector102:
  pushl $0
  102143:	6a 00                	push   $0x0
  pushl $102
  102145:	6a 66                	push   $0x66
  jmp __alltraps
  102147:	e9 e1 06 00 00       	jmp    10282d <__alltraps>

0010214c <vector103>:
.globl vector103
vector103:
  pushl $0
  10214c:	6a 00                	push   $0x0
  pushl $103
  10214e:	6a 67                	push   $0x67
  jmp __alltraps
  102150:	e9 d8 06 00 00       	jmp    10282d <__alltraps>

00102155 <vector104>:
.globl vector104
vector104:
  pushl $0
  102155:	6a 00                	push   $0x0
  pushl $104
  102157:	6a 68                	push   $0x68
  jmp __alltraps
  102159:	e9 cf 06 00 00       	jmp    10282d <__alltraps>

0010215e <vector105>:
.globl vector105
vector105:
  pushl $0
  10215e:	6a 00                	push   $0x0
  pushl $105
  102160:	6a 69                	push   $0x69
  jmp __alltraps
  102162:	e9 c6 06 00 00       	jmp    10282d <__alltraps>

00102167 <vector106>:
.globl vector106
vector106:
  pushl $0
  102167:	6a 00                	push   $0x0
  pushl $106
  102169:	6a 6a                	push   $0x6a
  jmp __alltraps
  10216b:	e9 bd 06 00 00       	jmp    10282d <__alltraps>

00102170 <vector107>:
.globl vector107
vector107:
  pushl $0
  102170:	6a 00                	push   $0x0
  pushl $107
  102172:	6a 6b                	push   $0x6b
  jmp __alltraps
  102174:	e9 b4 06 00 00       	jmp    10282d <__alltraps>

00102179 <vector108>:
.globl vector108
vector108:
  pushl $0
  102179:	6a 00                	push   $0x0
  pushl $108
  10217b:	6a 6c                	push   $0x6c
  jmp __alltraps
  10217d:	e9 ab 06 00 00       	jmp    10282d <__alltraps>

00102182 <vector109>:
.globl vector109
vector109:
  pushl $0
  102182:	6a 00                	push   $0x0
  pushl $109
  102184:	6a 6d                	push   $0x6d
  jmp __alltraps
  102186:	e9 a2 06 00 00       	jmp    10282d <__alltraps>

0010218b <vector110>:
.globl vector110
vector110:
  pushl $0
  10218b:	6a 00                	push   $0x0
  pushl $110
  10218d:	6a 6e                	push   $0x6e
  jmp __alltraps
  10218f:	e9 99 06 00 00       	jmp    10282d <__alltraps>

00102194 <vector111>:
.globl vector111
vector111:
  pushl $0
  102194:	6a 00                	push   $0x0
  pushl $111
  102196:	6a 6f                	push   $0x6f
  jmp __alltraps
  102198:	e9 90 06 00 00       	jmp    10282d <__alltraps>

0010219d <vector112>:
.globl vector112
vector112:
  pushl $0
  10219d:	6a 00                	push   $0x0
  pushl $112
  10219f:	6a 70                	push   $0x70
  jmp __alltraps
  1021a1:	e9 87 06 00 00       	jmp    10282d <__alltraps>

001021a6 <vector113>:
.globl vector113
vector113:
  pushl $0
  1021a6:	6a 00                	push   $0x0
  pushl $113
  1021a8:	6a 71                	push   $0x71
  jmp __alltraps
  1021aa:	e9 7e 06 00 00       	jmp    10282d <__alltraps>

001021af <vector114>:
.globl vector114
vector114:
  pushl $0
  1021af:	6a 00                	push   $0x0
  pushl $114
  1021b1:	6a 72                	push   $0x72
  jmp __alltraps
  1021b3:	e9 75 06 00 00       	jmp    10282d <__alltraps>

001021b8 <vector115>:
.globl vector115
vector115:
  pushl $0
  1021b8:	6a 00                	push   $0x0
  pushl $115
  1021ba:	6a 73                	push   $0x73
  jmp __alltraps
  1021bc:	e9 6c 06 00 00       	jmp    10282d <__alltraps>

001021c1 <vector116>:
.globl vector116
vector116:
  pushl $0
  1021c1:	6a 00                	push   $0x0
  pushl $116
  1021c3:	6a 74                	push   $0x74
  jmp __alltraps
  1021c5:	e9 63 06 00 00       	jmp    10282d <__alltraps>

001021ca <vector117>:
.globl vector117
vector117:
  pushl $0
  1021ca:	6a 00                	push   $0x0
  pushl $117
  1021cc:	6a 75                	push   $0x75
  jmp __alltraps
  1021ce:	e9 5a 06 00 00       	jmp    10282d <__alltraps>

001021d3 <vector118>:
.globl vector118
vector118:
  pushl $0
  1021d3:	6a 00                	push   $0x0
  pushl $118
  1021d5:	6a 76                	push   $0x76
  jmp __alltraps
  1021d7:	e9 51 06 00 00       	jmp    10282d <__alltraps>

001021dc <vector119>:
.globl vector119
vector119:
  pushl $0
  1021dc:	6a 00                	push   $0x0
  pushl $119
  1021de:	6a 77                	push   $0x77
  jmp __alltraps
  1021e0:	e9 48 06 00 00       	jmp    10282d <__alltraps>

001021e5 <vector120>:
.globl vector120
vector120:
  pushl $0
  1021e5:	6a 00                	push   $0x0
  pushl $120
  1021e7:	6a 78                	push   $0x78
  jmp __alltraps
  1021e9:	e9 3f 06 00 00       	jmp    10282d <__alltraps>

001021ee <vector121>:
.globl vector121
vector121:
  pushl $0
  1021ee:	6a 00                	push   $0x0
  pushl $121
  1021f0:	6a 79                	push   $0x79
  jmp __alltraps
  1021f2:	e9 36 06 00 00       	jmp    10282d <__alltraps>

001021f7 <vector122>:
.globl vector122
vector122:
  pushl $0
  1021f7:	6a 00                	push   $0x0
  pushl $122
  1021f9:	6a 7a                	push   $0x7a
  jmp __alltraps
  1021fb:	e9 2d 06 00 00       	jmp    10282d <__alltraps>

00102200 <vector123>:
.globl vector123
vector123:
  pushl $0
  102200:	6a 00                	push   $0x0
  pushl $123
  102202:	6a 7b                	push   $0x7b
  jmp __alltraps
  102204:	e9 24 06 00 00       	jmp    10282d <__alltraps>

00102209 <vector124>:
.globl vector124
vector124:
  pushl $0
  102209:	6a 00                	push   $0x0
  pushl $124
  10220b:	6a 7c                	push   $0x7c
  jmp __alltraps
  10220d:	e9 1b 06 00 00       	jmp    10282d <__alltraps>

00102212 <vector125>:
.globl vector125
vector125:
  pushl $0
  102212:	6a 00                	push   $0x0
  pushl $125
  102214:	6a 7d                	push   $0x7d
  jmp __alltraps
  102216:	e9 12 06 00 00       	jmp    10282d <__alltraps>

0010221b <vector126>:
.globl vector126
vector126:
  pushl $0
  10221b:	6a 00                	push   $0x0
  pushl $126
  10221d:	6a 7e                	push   $0x7e
  jmp __alltraps
  10221f:	e9 09 06 00 00       	jmp    10282d <__alltraps>

00102224 <vector127>:
.globl vector127
vector127:
  pushl $0
  102224:	6a 00                	push   $0x0
  pushl $127
  102226:	6a 7f                	push   $0x7f
  jmp __alltraps
  102228:	e9 00 06 00 00       	jmp    10282d <__alltraps>

0010222d <vector128>:
.globl vector128
vector128:
  pushl $0
  10222d:	6a 00                	push   $0x0
  pushl $128
  10222f:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102234:	e9 f4 05 00 00       	jmp    10282d <__alltraps>

00102239 <vector129>:
.globl vector129
vector129:
  pushl $0
  102239:	6a 00                	push   $0x0
  pushl $129
  10223b:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102240:	e9 e8 05 00 00       	jmp    10282d <__alltraps>

00102245 <vector130>:
.globl vector130
vector130:
  pushl $0
  102245:	6a 00                	push   $0x0
  pushl $130
  102247:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10224c:	e9 dc 05 00 00       	jmp    10282d <__alltraps>

00102251 <vector131>:
.globl vector131
vector131:
  pushl $0
  102251:	6a 00                	push   $0x0
  pushl $131
  102253:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102258:	e9 d0 05 00 00       	jmp    10282d <__alltraps>

0010225d <vector132>:
.globl vector132
vector132:
  pushl $0
  10225d:	6a 00                	push   $0x0
  pushl $132
  10225f:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102264:	e9 c4 05 00 00       	jmp    10282d <__alltraps>

00102269 <vector133>:
.globl vector133
vector133:
  pushl $0
  102269:	6a 00                	push   $0x0
  pushl $133
  10226b:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102270:	e9 b8 05 00 00       	jmp    10282d <__alltraps>

00102275 <vector134>:
.globl vector134
vector134:
  pushl $0
  102275:	6a 00                	push   $0x0
  pushl $134
  102277:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  10227c:	e9 ac 05 00 00       	jmp    10282d <__alltraps>

00102281 <vector135>:
.globl vector135
vector135:
  pushl $0
  102281:	6a 00                	push   $0x0
  pushl $135
  102283:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102288:	e9 a0 05 00 00       	jmp    10282d <__alltraps>

0010228d <vector136>:
.globl vector136
vector136:
  pushl $0
  10228d:	6a 00                	push   $0x0
  pushl $136
  10228f:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102294:	e9 94 05 00 00       	jmp    10282d <__alltraps>

00102299 <vector137>:
.globl vector137
vector137:
  pushl $0
  102299:	6a 00                	push   $0x0
  pushl $137
  10229b:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1022a0:	e9 88 05 00 00       	jmp    10282d <__alltraps>

001022a5 <vector138>:
.globl vector138
vector138:
  pushl $0
  1022a5:	6a 00                	push   $0x0
  pushl $138
  1022a7:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1022ac:	e9 7c 05 00 00       	jmp    10282d <__alltraps>

001022b1 <vector139>:
.globl vector139
vector139:
  pushl $0
  1022b1:	6a 00                	push   $0x0
  pushl $139
  1022b3:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1022b8:	e9 70 05 00 00       	jmp    10282d <__alltraps>

001022bd <vector140>:
.globl vector140
vector140:
  pushl $0
  1022bd:	6a 00                	push   $0x0
  pushl $140
  1022bf:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1022c4:	e9 64 05 00 00       	jmp    10282d <__alltraps>

001022c9 <vector141>:
.globl vector141
vector141:
  pushl $0
  1022c9:	6a 00                	push   $0x0
  pushl $141
  1022cb:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1022d0:	e9 58 05 00 00       	jmp    10282d <__alltraps>

001022d5 <vector142>:
.globl vector142
vector142:
  pushl $0
  1022d5:	6a 00                	push   $0x0
  pushl $142
  1022d7:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1022dc:	e9 4c 05 00 00       	jmp    10282d <__alltraps>

001022e1 <vector143>:
.globl vector143
vector143:
  pushl $0
  1022e1:	6a 00                	push   $0x0
  pushl $143
  1022e3:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1022e8:	e9 40 05 00 00       	jmp    10282d <__alltraps>

001022ed <vector144>:
.globl vector144
vector144:
  pushl $0
  1022ed:	6a 00                	push   $0x0
  pushl $144
  1022ef:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1022f4:	e9 34 05 00 00       	jmp    10282d <__alltraps>

001022f9 <vector145>:
.globl vector145
vector145:
  pushl $0
  1022f9:	6a 00                	push   $0x0
  pushl $145
  1022fb:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102300:	e9 28 05 00 00       	jmp    10282d <__alltraps>

00102305 <vector146>:
.globl vector146
vector146:
  pushl $0
  102305:	6a 00                	push   $0x0
  pushl $146
  102307:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  10230c:	e9 1c 05 00 00       	jmp    10282d <__alltraps>

00102311 <vector147>:
.globl vector147
vector147:
  pushl $0
  102311:	6a 00                	push   $0x0
  pushl $147
  102313:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102318:	e9 10 05 00 00       	jmp    10282d <__alltraps>

0010231d <vector148>:
.globl vector148
vector148:
  pushl $0
  10231d:	6a 00                	push   $0x0
  pushl $148
  10231f:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102324:	e9 04 05 00 00       	jmp    10282d <__alltraps>

00102329 <vector149>:
.globl vector149
vector149:
  pushl $0
  102329:	6a 00                	push   $0x0
  pushl $149
  10232b:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102330:	e9 f8 04 00 00       	jmp    10282d <__alltraps>

00102335 <vector150>:
.globl vector150
vector150:
  pushl $0
  102335:	6a 00                	push   $0x0
  pushl $150
  102337:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10233c:	e9 ec 04 00 00       	jmp    10282d <__alltraps>

00102341 <vector151>:
.globl vector151
vector151:
  pushl $0
  102341:	6a 00                	push   $0x0
  pushl $151
  102343:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102348:	e9 e0 04 00 00       	jmp    10282d <__alltraps>

0010234d <vector152>:
.globl vector152
vector152:
  pushl $0
  10234d:	6a 00                	push   $0x0
  pushl $152
  10234f:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102354:	e9 d4 04 00 00       	jmp    10282d <__alltraps>

00102359 <vector153>:
.globl vector153
vector153:
  pushl $0
  102359:	6a 00                	push   $0x0
  pushl $153
  10235b:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102360:	e9 c8 04 00 00       	jmp    10282d <__alltraps>

00102365 <vector154>:
.globl vector154
vector154:
  pushl $0
  102365:	6a 00                	push   $0x0
  pushl $154
  102367:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  10236c:	e9 bc 04 00 00       	jmp    10282d <__alltraps>

00102371 <vector155>:
.globl vector155
vector155:
  pushl $0
  102371:	6a 00                	push   $0x0
  pushl $155
  102373:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102378:	e9 b0 04 00 00       	jmp    10282d <__alltraps>

0010237d <vector156>:
.globl vector156
vector156:
  pushl $0
  10237d:	6a 00                	push   $0x0
  pushl $156
  10237f:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102384:	e9 a4 04 00 00       	jmp    10282d <__alltraps>

00102389 <vector157>:
.globl vector157
vector157:
  pushl $0
  102389:	6a 00                	push   $0x0
  pushl $157
  10238b:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102390:	e9 98 04 00 00       	jmp    10282d <__alltraps>

00102395 <vector158>:
.globl vector158
vector158:
  pushl $0
  102395:	6a 00                	push   $0x0
  pushl $158
  102397:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  10239c:	e9 8c 04 00 00       	jmp    10282d <__alltraps>

001023a1 <vector159>:
.globl vector159
vector159:
  pushl $0
  1023a1:	6a 00                	push   $0x0
  pushl $159
  1023a3:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1023a8:	e9 80 04 00 00       	jmp    10282d <__alltraps>

001023ad <vector160>:
.globl vector160
vector160:
  pushl $0
  1023ad:	6a 00                	push   $0x0
  pushl $160
  1023af:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1023b4:	e9 74 04 00 00       	jmp    10282d <__alltraps>

001023b9 <vector161>:
.globl vector161
vector161:
  pushl $0
  1023b9:	6a 00                	push   $0x0
  pushl $161
  1023bb:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1023c0:	e9 68 04 00 00       	jmp    10282d <__alltraps>

001023c5 <vector162>:
.globl vector162
vector162:
  pushl $0
  1023c5:	6a 00                	push   $0x0
  pushl $162
  1023c7:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1023cc:	e9 5c 04 00 00       	jmp    10282d <__alltraps>

001023d1 <vector163>:
.globl vector163
vector163:
  pushl $0
  1023d1:	6a 00                	push   $0x0
  pushl $163
  1023d3:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1023d8:	e9 50 04 00 00       	jmp    10282d <__alltraps>

001023dd <vector164>:
.globl vector164
vector164:
  pushl $0
  1023dd:	6a 00                	push   $0x0
  pushl $164
  1023df:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1023e4:	e9 44 04 00 00       	jmp    10282d <__alltraps>

001023e9 <vector165>:
.globl vector165
vector165:
  pushl $0
  1023e9:	6a 00                	push   $0x0
  pushl $165
  1023eb:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1023f0:	e9 38 04 00 00       	jmp    10282d <__alltraps>

001023f5 <vector166>:
.globl vector166
vector166:
  pushl $0
  1023f5:	6a 00                	push   $0x0
  pushl $166
  1023f7:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1023fc:	e9 2c 04 00 00       	jmp    10282d <__alltraps>

00102401 <vector167>:
.globl vector167
vector167:
  pushl $0
  102401:	6a 00                	push   $0x0
  pushl $167
  102403:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102408:	e9 20 04 00 00       	jmp    10282d <__alltraps>

0010240d <vector168>:
.globl vector168
vector168:
  pushl $0
  10240d:	6a 00                	push   $0x0
  pushl $168
  10240f:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102414:	e9 14 04 00 00       	jmp    10282d <__alltraps>

00102419 <vector169>:
.globl vector169
vector169:
  pushl $0
  102419:	6a 00                	push   $0x0
  pushl $169
  10241b:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102420:	e9 08 04 00 00       	jmp    10282d <__alltraps>

00102425 <vector170>:
.globl vector170
vector170:
  pushl $0
  102425:	6a 00                	push   $0x0
  pushl $170
  102427:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  10242c:	e9 fc 03 00 00       	jmp    10282d <__alltraps>

00102431 <vector171>:
.globl vector171
vector171:
  pushl $0
  102431:	6a 00                	push   $0x0
  pushl $171
  102433:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102438:	e9 f0 03 00 00       	jmp    10282d <__alltraps>

0010243d <vector172>:
.globl vector172
vector172:
  pushl $0
  10243d:	6a 00                	push   $0x0
  pushl $172
  10243f:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102444:	e9 e4 03 00 00       	jmp    10282d <__alltraps>

00102449 <vector173>:
.globl vector173
vector173:
  pushl $0
  102449:	6a 00                	push   $0x0
  pushl $173
  10244b:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102450:	e9 d8 03 00 00       	jmp    10282d <__alltraps>

00102455 <vector174>:
.globl vector174
vector174:
  pushl $0
  102455:	6a 00                	push   $0x0
  pushl $174
  102457:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  10245c:	e9 cc 03 00 00       	jmp    10282d <__alltraps>

00102461 <vector175>:
.globl vector175
vector175:
  pushl $0
  102461:	6a 00                	push   $0x0
  pushl $175
  102463:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102468:	e9 c0 03 00 00       	jmp    10282d <__alltraps>

0010246d <vector176>:
.globl vector176
vector176:
  pushl $0
  10246d:	6a 00                	push   $0x0
  pushl $176
  10246f:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102474:	e9 b4 03 00 00       	jmp    10282d <__alltraps>

00102479 <vector177>:
.globl vector177
vector177:
  pushl $0
  102479:	6a 00                	push   $0x0
  pushl $177
  10247b:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102480:	e9 a8 03 00 00       	jmp    10282d <__alltraps>

00102485 <vector178>:
.globl vector178
vector178:
  pushl $0
  102485:	6a 00                	push   $0x0
  pushl $178
  102487:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  10248c:	e9 9c 03 00 00       	jmp    10282d <__alltraps>

00102491 <vector179>:
.globl vector179
vector179:
  pushl $0
  102491:	6a 00                	push   $0x0
  pushl $179
  102493:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102498:	e9 90 03 00 00       	jmp    10282d <__alltraps>

0010249d <vector180>:
.globl vector180
vector180:
  pushl $0
  10249d:	6a 00                	push   $0x0
  pushl $180
  10249f:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1024a4:	e9 84 03 00 00       	jmp    10282d <__alltraps>

001024a9 <vector181>:
.globl vector181
vector181:
  pushl $0
  1024a9:	6a 00                	push   $0x0
  pushl $181
  1024ab:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1024b0:	e9 78 03 00 00       	jmp    10282d <__alltraps>

001024b5 <vector182>:
.globl vector182
vector182:
  pushl $0
  1024b5:	6a 00                	push   $0x0
  pushl $182
  1024b7:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1024bc:	e9 6c 03 00 00       	jmp    10282d <__alltraps>

001024c1 <vector183>:
.globl vector183
vector183:
  pushl $0
  1024c1:	6a 00                	push   $0x0
  pushl $183
  1024c3:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1024c8:	e9 60 03 00 00       	jmp    10282d <__alltraps>

001024cd <vector184>:
.globl vector184
vector184:
  pushl $0
  1024cd:	6a 00                	push   $0x0
  pushl $184
  1024cf:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1024d4:	e9 54 03 00 00       	jmp    10282d <__alltraps>

001024d9 <vector185>:
.globl vector185
vector185:
  pushl $0
  1024d9:	6a 00                	push   $0x0
  pushl $185
  1024db:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1024e0:	e9 48 03 00 00       	jmp    10282d <__alltraps>

001024e5 <vector186>:
.globl vector186
vector186:
  pushl $0
  1024e5:	6a 00                	push   $0x0
  pushl $186
  1024e7:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1024ec:	e9 3c 03 00 00       	jmp    10282d <__alltraps>

001024f1 <vector187>:
.globl vector187
vector187:
  pushl $0
  1024f1:	6a 00                	push   $0x0
  pushl $187
  1024f3:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1024f8:	e9 30 03 00 00       	jmp    10282d <__alltraps>

001024fd <vector188>:
.globl vector188
vector188:
  pushl $0
  1024fd:	6a 00                	push   $0x0
  pushl $188
  1024ff:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102504:	e9 24 03 00 00       	jmp    10282d <__alltraps>

00102509 <vector189>:
.globl vector189
vector189:
  pushl $0
  102509:	6a 00                	push   $0x0
  pushl $189
  10250b:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102510:	e9 18 03 00 00       	jmp    10282d <__alltraps>

00102515 <vector190>:
.globl vector190
vector190:
  pushl $0
  102515:	6a 00                	push   $0x0
  pushl $190
  102517:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  10251c:	e9 0c 03 00 00       	jmp    10282d <__alltraps>

00102521 <vector191>:
.globl vector191
vector191:
  pushl $0
  102521:	6a 00                	push   $0x0
  pushl $191
  102523:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102528:	e9 00 03 00 00       	jmp    10282d <__alltraps>

0010252d <vector192>:
.globl vector192
vector192:
  pushl $0
  10252d:	6a 00                	push   $0x0
  pushl $192
  10252f:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102534:	e9 f4 02 00 00       	jmp    10282d <__alltraps>

00102539 <vector193>:
.globl vector193
vector193:
  pushl $0
  102539:	6a 00                	push   $0x0
  pushl $193
  10253b:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102540:	e9 e8 02 00 00       	jmp    10282d <__alltraps>

00102545 <vector194>:
.globl vector194
vector194:
  pushl $0
  102545:	6a 00                	push   $0x0
  pushl $194
  102547:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10254c:	e9 dc 02 00 00       	jmp    10282d <__alltraps>

00102551 <vector195>:
.globl vector195
vector195:
  pushl $0
  102551:	6a 00                	push   $0x0
  pushl $195
  102553:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102558:	e9 d0 02 00 00       	jmp    10282d <__alltraps>

0010255d <vector196>:
.globl vector196
vector196:
  pushl $0
  10255d:	6a 00                	push   $0x0
  pushl $196
  10255f:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102564:	e9 c4 02 00 00       	jmp    10282d <__alltraps>

00102569 <vector197>:
.globl vector197
vector197:
  pushl $0
  102569:	6a 00                	push   $0x0
  pushl $197
  10256b:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102570:	e9 b8 02 00 00       	jmp    10282d <__alltraps>

00102575 <vector198>:
.globl vector198
vector198:
  pushl $0
  102575:	6a 00                	push   $0x0
  pushl $198
  102577:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  10257c:	e9 ac 02 00 00       	jmp    10282d <__alltraps>

00102581 <vector199>:
.globl vector199
vector199:
  pushl $0
  102581:	6a 00                	push   $0x0
  pushl $199
  102583:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102588:	e9 a0 02 00 00       	jmp    10282d <__alltraps>

0010258d <vector200>:
.globl vector200
vector200:
  pushl $0
  10258d:	6a 00                	push   $0x0
  pushl $200
  10258f:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102594:	e9 94 02 00 00       	jmp    10282d <__alltraps>

00102599 <vector201>:
.globl vector201
vector201:
  pushl $0
  102599:	6a 00                	push   $0x0
  pushl $201
  10259b:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1025a0:	e9 88 02 00 00       	jmp    10282d <__alltraps>

001025a5 <vector202>:
.globl vector202
vector202:
  pushl $0
  1025a5:	6a 00                	push   $0x0
  pushl $202
  1025a7:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1025ac:	e9 7c 02 00 00       	jmp    10282d <__alltraps>

001025b1 <vector203>:
.globl vector203
vector203:
  pushl $0
  1025b1:	6a 00                	push   $0x0
  pushl $203
  1025b3:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1025b8:	e9 70 02 00 00       	jmp    10282d <__alltraps>

001025bd <vector204>:
.globl vector204
vector204:
  pushl $0
  1025bd:	6a 00                	push   $0x0
  pushl $204
  1025bf:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1025c4:	e9 64 02 00 00       	jmp    10282d <__alltraps>

001025c9 <vector205>:
.globl vector205
vector205:
  pushl $0
  1025c9:	6a 00                	push   $0x0
  pushl $205
  1025cb:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1025d0:	e9 58 02 00 00       	jmp    10282d <__alltraps>

001025d5 <vector206>:
.globl vector206
vector206:
  pushl $0
  1025d5:	6a 00                	push   $0x0
  pushl $206
  1025d7:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1025dc:	e9 4c 02 00 00       	jmp    10282d <__alltraps>

001025e1 <vector207>:
.globl vector207
vector207:
  pushl $0
  1025e1:	6a 00                	push   $0x0
  pushl $207
  1025e3:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1025e8:	e9 40 02 00 00       	jmp    10282d <__alltraps>

001025ed <vector208>:
.globl vector208
vector208:
  pushl $0
  1025ed:	6a 00                	push   $0x0
  pushl $208
  1025ef:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1025f4:	e9 34 02 00 00       	jmp    10282d <__alltraps>

001025f9 <vector209>:
.globl vector209
vector209:
  pushl $0
  1025f9:	6a 00                	push   $0x0
  pushl $209
  1025fb:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102600:	e9 28 02 00 00       	jmp    10282d <__alltraps>

00102605 <vector210>:
.globl vector210
vector210:
  pushl $0
  102605:	6a 00                	push   $0x0
  pushl $210
  102607:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  10260c:	e9 1c 02 00 00       	jmp    10282d <__alltraps>

00102611 <vector211>:
.globl vector211
vector211:
  pushl $0
  102611:	6a 00                	push   $0x0
  pushl $211
  102613:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102618:	e9 10 02 00 00       	jmp    10282d <__alltraps>

0010261d <vector212>:
.globl vector212
vector212:
  pushl $0
  10261d:	6a 00                	push   $0x0
  pushl $212
  10261f:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102624:	e9 04 02 00 00       	jmp    10282d <__alltraps>

00102629 <vector213>:
.globl vector213
vector213:
  pushl $0
  102629:	6a 00                	push   $0x0
  pushl $213
  10262b:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102630:	e9 f8 01 00 00       	jmp    10282d <__alltraps>

00102635 <vector214>:
.globl vector214
vector214:
  pushl $0
  102635:	6a 00                	push   $0x0
  pushl $214
  102637:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  10263c:	e9 ec 01 00 00       	jmp    10282d <__alltraps>

00102641 <vector215>:
.globl vector215
vector215:
  pushl $0
  102641:	6a 00                	push   $0x0
  pushl $215
  102643:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102648:	e9 e0 01 00 00       	jmp    10282d <__alltraps>

0010264d <vector216>:
.globl vector216
vector216:
  pushl $0
  10264d:	6a 00                	push   $0x0
  pushl $216
  10264f:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102654:	e9 d4 01 00 00       	jmp    10282d <__alltraps>

00102659 <vector217>:
.globl vector217
vector217:
  pushl $0
  102659:	6a 00                	push   $0x0
  pushl $217
  10265b:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102660:	e9 c8 01 00 00       	jmp    10282d <__alltraps>

00102665 <vector218>:
.globl vector218
vector218:
  pushl $0
  102665:	6a 00                	push   $0x0
  pushl $218
  102667:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  10266c:	e9 bc 01 00 00       	jmp    10282d <__alltraps>

00102671 <vector219>:
.globl vector219
vector219:
  pushl $0
  102671:	6a 00                	push   $0x0
  pushl $219
  102673:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102678:	e9 b0 01 00 00       	jmp    10282d <__alltraps>

0010267d <vector220>:
.globl vector220
vector220:
  pushl $0
  10267d:	6a 00                	push   $0x0
  pushl $220
  10267f:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102684:	e9 a4 01 00 00       	jmp    10282d <__alltraps>

00102689 <vector221>:
.globl vector221
vector221:
  pushl $0
  102689:	6a 00                	push   $0x0
  pushl $221
  10268b:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102690:	e9 98 01 00 00       	jmp    10282d <__alltraps>

00102695 <vector222>:
.globl vector222
vector222:
  pushl $0
  102695:	6a 00                	push   $0x0
  pushl $222
  102697:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  10269c:	e9 8c 01 00 00       	jmp    10282d <__alltraps>

001026a1 <vector223>:
.globl vector223
vector223:
  pushl $0
  1026a1:	6a 00                	push   $0x0
  pushl $223
  1026a3:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1026a8:	e9 80 01 00 00       	jmp    10282d <__alltraps>

001026ad <vector224>:
.globl vector224
vector224:
  pushl $0
  1026ad:	6a 00                	push   $0x0
  pushl $224
  1026af:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1026b4:	e9 74 01 00 00       	jmp    10282d <__alltraps>

001026b9 <vector225>:
.globl vector225
vector225:
  pushl $0
  1026b9:	6a 00                	push   $0x0
  pushl $225
  1026bb:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1026c0:	e9 68 01 00 00       	jmp    10282d <__alltraps>

001026c5 <vector226>:
.globl vector226
vector226:
  pushl $0
  1026c5:	6a 00                	push   $0x0
  pushl $226
  1026c7:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1026cc:	e9 5c 01 00 00       	jmp    10282d <__alltraps>

001026d1 <vector227>:
.globl vector227
vector227:
  pushl $0
  1026d1:	6a 00                	push   $0x0
  pushl $227
  1026d3:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1026d8:	e9 50 01 00 00       	jmp    10282d <__alltraps>

001026dd <vector228>:
.globl vector228
vector228:
  pushl $0
  1026dd:	6a 00                	push   $0x0
  pushl $228
  1026df:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1026e4:	e9 44 01 00 00       	jmp    10282d <__alltraps>

001026e9 <vector229>:
.globl vector229
vector229:
  pushl $0
  1026e9:	6a 00                	push   $0x0
  pushl $229
  1026eb:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1026f0:	e9 38 01 00 00       	jmp    10282d <__alltraps>

001026f5 <vector230>:
.globl vector230
vector230:
  pushl $0
  1026f5:	6a 00                	push   $0x0
  pushl $230
  1026f7:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1026fc:	e9 2c 01 00 00       	jmp    10282d <__alltraps>

00102701 <vector231>:
.globl vector231
vector231:
  pushl $0
  102701:	6a 00                	push   $0x0
  pushl $231
  102703:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102708:	e9 20 01 00 00       	jmp    10282d <__alltraps>

0010270d <vector232>:
.globl vector232
vector232:
  pushl $0
  10270d:	6a 00                	push   $0x0
  pushl $232
  10270f:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102714:	e9 14 01 00 00       	jmp    10282d <__alltraps>

00102719 <vector233>:
.globl vector233
vector233:
  pushl $0
  102719:	6a 00                	push   $0x0
  pushl $233
  10271b:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102720:	e9 08 01 00 00       	jmp    10282d <__alltraps>

00102725 <vector234>:
.globl vector234
vector234:
  pushl $0
  102725:	6a 00                	push   $0x0
  pushl $234
  102727:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  10272c:	e9 fc 00 00 00       	jmp    10282d <__alltraps>

00102731 <vector235>:
.globl vector235
vector235:
  pushl $0
  102731:	6a 00                	push   $0x0
  pushl $235
  102733:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102738:	e9 f0 00 00 00       	jmp    10282d <__alltraps>

0010273d <vector236>:
.globl vector236
vector236:
  pushl $0
  10273d:	6a 00                	push   $0x0
  pushl $236
  10273f:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102744:	e9 e4 00 00 00       	jmp    10282d <__alltraps>

00102749 <vector237>:
.globl vector237
vector237:
  pushl $0
  102749:	6a 00                	push   $0x0
  pushl $237
  10274b:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102750:	e9 d8 00 00 00       	jmp    10282d <__alltraps>

00102755 <vector238>:
.globl vector238
vector238:
  pushl $0
  102755:	6a 00                	push   $0x0
  pushl $238
  102757:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  10275c:	e9 cc 00 00 00       	jmp    10282d <__alltraps>

00102761 <vector239>:
.globl vector239
vector239:
  pushl $0
  102761:	6a 00                	push   $0x0
  pushl $239
  102763:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102768:	e9 c0 00 00 00       	jmp    10282d <__alltraps>

0010276d <vector240>:
.globl vector240
vector240:
  pushl $0
  10276d:	6a 00                	push   $0x0
  pushl $240
  10276f:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102774:	e9 b4 00 00 00       	jmp    10282d <__alltraps>

00102779 <vector241>:
.globl vector241
vector241:
  pushl $0
  102779:	6a 00                	push   $0x0
  pushl $241
  10277b:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102780:	e9 a8 00 00 00       	jmp    10282d <__alltraps>

00102785 <vector242>:
.globl vector242
vector242:
  pushl $0
  102785:	6a 00                	push   $0x0
  pushl $242
  102787:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  10278c:	e9 9c 00 00 00       	jmp    10282d <__alltraps>

00102791 <vector243>:
.globl vector243
vector243:
  pushl $0
  102791:	6a 00                	push   $0x0
  pushl $243
  102793:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102798:	e9 90 00 00 00       	jmp    10282d <__alltraps>

0010279d <vector244>:
.globl vector244
vector244:
  pushl $0
  10279d:	6a 00                	push   $0x0
  pushl $244
  10279f:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1027a4:	e9 84 00 00 00       	jmp    10282d <__alltraps>

001027a9 <vector245>:
.globl vector245
vector245:
  pushl $0
  1027a9:	6a 00                	push   $0x0
  pushl $245
  1027ab:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1027b0:	e9 78 00 00 00       	jmp    10282d <__alltraps>

001027b5 <vector246>:
.globl vector246
vector246:
  pushl $0
  1027b5:	6a 00                	push   $0x0
  pushl $246
  1027b7:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1027bc:	e9 6c 00 00 00       	jmp    10282d <__alltraps>

001027c1 <vector247>:
.globl vector247
vector247:
  pushl $0
  1027c1:	6a 00                	push   $0x0
  pushl $247
  1027c3:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1027c8:	e9 60 00 00 00       	jmp    10282d <__alltraps>

001027cd <vector248>:
.globl vector248
vector248:
  pushl $0
  1027cd:	6a 00                	push   $0x0
  pushl $248
  1027cf:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1027d4:	e9 54 00 00 00       	jmp    10282d <__alltraps>

001027d9 <vector249>:
.globl vector249
vector249:
  pushl $0
  1027d9:	6a 00                	push   $0x0
  pushl $249
  1027db:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1027e0:	e9 48 00 00 00       	jmp    10282d <__alltraps>

001027e5 <vector250>:
.globl vector250
vector250:
  pushl $0
  1027e5:	6a 00                	push   $0x0
  pushl $250
  1027e7:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1027ec:	e9 3c 00 00 00       	jmp    10282d <__alltraps>

001027f1 <vector251>:
.globl vector251
vector251:
  pushl $0
  1027f1:	6a 00                	push   $0x0
  pushl $251
  1027f3:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1027f8:	e9 30 00 00 00       	jmp    10282d <__alltraps>

001027fd <vector252>:
.globl vector252
vector252:
  pushl $0
  1027fd:	6a 00                	push   $0x0
  pushl $252
  1027ff:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102804:	e9 24 00 00 00       	jmp    10282d <__alltraps>

00102809 <vector253>:
.globl vector253
vector253:
  pushl $0
  102809:	6a 00                	push   $0x0
  pushl $253
  10280b:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102810:	e9 18 00 00 00       	jmp    10282d <__alltraps>

00102815 <vector254>:
.globl vector254
vector254:
  pushl $0
  102815:	6a 00                	push   $0x0
  pushl $254
  102817:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  10281c:	e9 0c 00 00 00       	jmp    10282d <__alltraps>

00102821 <vector255>:
.globl vector255
vector255:
  pushl $0
  102821:	6a 00                	push   $0x0
  pushl $255
  102823:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102828:	e9 00 00 00 00       	jmp    10282d <__alltraps>

0010282d <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  10282d:	1e                   	push   %ds
    pushl %es
  10282e:	06                   	push   %es
    pushl %fs
  10282f:	0f a0                	push   %fs
    pushl %gs
  102831:	0f a8                	push   %gs
    pushal
  102833:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102834:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102839:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  10283b:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  10283d:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  10283e:	e8 64 f5 ff ff       	call   101da7 <trap>

    # pop the pushed stack pointer
    popl %esp
  102843:	5c                   	pop    %esp

00102844 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102844:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102845:	0f a9                	pop    %gs
    popl %fs
  102847:	0f a1                	pop    %fs
    popl %es
  102849:	07                   	pop    %es
    popl %ds
  10284a:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  10284b:	83 c4 08             	add    $0x8,%esp
    iret
  10284e:	cf                   	iret   

0010284f <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  10284f:	55                   	push   %ebp
  102850:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102852:	8b 45 08             	mov    0x8(%ebp),%eax
  102855:	8b 15 18 df 11 00    	mov    0x11df18,%edx
  10285b:	29 d0                	sub    %edx,%eax
  10285d:	c1 f8 02             	sar    $0x2,%eax
  102860:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102866:	5d                   	pop    %ebp
  102867:	c3                   	ret    

00102868 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102868:	55                   	push   %ebp
  102869:	89 e5                	mov    %esp,%ebp
  10286b:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  10286e:	8b 45 08             	mov    0x8(%ebp),%eax
  102871:	89 04 24             	mov    %eax,(%esp)
  102874:	e8 d6 ff ff ff       	call   10284f <page2ppn>
  102879:	c1 e0 0c             	shl    $0xc,%eax
}
  10287c:	c9                   	leave  
  10287d:	c3                   	ret    

0010287e <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  10287e:	55                   	push   %ebp
  10287f:	89 e5                	mov    %esp,%ebp
  102881:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  102884:	8b 45 08             	mov    0x8(%ebp),%eax
  102887:	c1 e8 0c             	shr    $0xc,%eax
  10288a:	89 c2                	mov    %eax,%edx
  10288c:	a1 80 de 11 00       	mov    0x11de80,%eax
  102891:	39 c2                	cmp    %eax,%edx
  102893:	72 1c                	jb     1028b1 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  102895:	c7 44 24 08 b0 75 10 	movl   $0x1075b0,0x8(%esp)
  10289c:	00 
  10289d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  1028a4:	00 
  1028a5:	c7 04 24 cf 75 10 00 	movl   $0x1075cf,(%esp)
  1028ac:	e8 38 db ff ff       	call   1003e9 <__panic>
    }
    return &pages[PPN(pa)];
  1028b1:	8b 0d 18 df 11 00    	mov    0x11df18,%ecx
  1028b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1028ba:	c1 e8 0c             	shr    $0xc,%eax
  1028bd:	89 c2                	mov    %eax,%edx
  1028bf:	89 d0                	mov    %edx,%eax
  1028c1:	c1 e0 02             	shl    $0x2,%eax
  1028c4:	01 d0                	add    %edx,%eax
  1028c6:	c1 e0 02             	shl    $0x2,%eax
  1028c9:	01 c8                	add    %ecx,%eax
}
  1028cb:	c9                   	leave  
  1028cc:	c3                   	ret    

001028cd <page2kva>:

static inline void *
page2kva(struct Page *page) {
  1028cd:	55                   	push   %ebp
  1028ce:	89 e5                	mov    %esp,%ebp
  1028d0:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  1028d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1028d6:	89 04 24             	mov    %eax,(%esp)
  1028d9:	e8 8a ff ff ff       	call   102868 <page2pa>
  1028de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1028e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028e4:	c1 e8 0c             	shr    $0xc,%eax
  1028e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1028ea:	a1 80 de 11 00       	mov    0x11de80,%eax
  1028ef:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  1028f2:	72 23                	jb     102917 <page2kva+0x4a>
  1028f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1028fb:	c7 44 24 08 e0 75 10 	movl   $0x1075e0,0x8(%esp)
  102902:	00 
  102903:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  10290a:	00 
  10290b:	c7 04 24 cf 75 10 00 	movl   $0x1075cf,(%esp)
  102912:	e8 d2 da ff ff       	call   1003e9 <__panic>
  102917:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10291a:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  10291f:	c9                   	leave  
  102920:	c3                   	ret    

00102921 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  102921:	55                   	push   %ebp
  102922:	89 e5                	mov    %esp,%ebp
  102924:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  102927:	8b 45 08             	mov    0x8(%ebp),%eax
  10292a:	83 e0 01             	and    $0x1,%eax
  10292d:	85 c0                	test   %eax,%eax
  10292f:	75 1c                	jne    10294d <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  102931:	c7 44 24 08 04 76 10 	movl   $0x107604,0x8(%esp)
  102938:	00 
  102939:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  102940:	00 
  102941:	c7 04 24 cf 75 10 00 	movl   $0x1075cf,(%esp)
  102948:	e8 9c da ff ff       	call   1003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  10294d:	8b 45 08             	mov    0x8(%ebp),%eax
  102950:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102955:	89 04 24             	mov    %eax,(%esp)
  102958:	e8 21 ff ff ff       	call   10287e <pa2page>
}
  10295d:	c9                   	leave  
  10295e:	c3                   	ret    

0010295f <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  10295f:	55                   	push   %ebp
  102960:	89 e5                	mov    %esp,%ebp
  102962:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  102965:	8b 45 08             	mov    0x8(%ebp),%eax
  102968:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10296d:	89 04 24             	mov    %eax,(%esp)
  102970:	e8 09 ff ff ff       	call   10287e <pa2page>
}
  102975:	c9                   	leave  
  102976:	c3                   	ret    

00102977 <page_ref>:

static inline int
page_ref(struct Page *page) {
  102977:	55                   	push   %ebp
  102978:	89 e5                	mov    %esp,%ebp
    return page->ref;
  10297a:	8b 45 08             	mov    0x8(%ebp),%eax
  10297d:	8b 00                	mov    (%eax),%eax
}
  10297f:	5d                   	pop    %ebp
  102980:	c3                   	ret    

00102981 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102981:	55                   	push   %ebp
  102982:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102984:	8b 45 08             	mov    0x8(%ebp),%eax
  102987:	8b 55 0c             	mov    0xc(%ebp),%edx
  10298a:	89 10                	mov    %edx,(%eax)
}
  10298c:	90                   	nop
  10298d:	5d                   	pop    %ebp
  10298e:	c3                   	ret    

0010298f <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  10298f:	55                   	push   %ebp
  102990:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  102992:	8b 45 08             	mov    0x8(%ebp),%eax
  102995:	8b 00                	mov    (%eax),%eax
  102997:	8d 50 01             	lea    0x1(%eax),%edx
  10299a:	8b 45 08             	mov    0x8(%ebp),%eax
  10299d:	89 10                	mov    %edx,(%eax)
    return page->ref;
  10299f:	8b 45 08             	mov    0x8(%ebp),%eax
  1029a2:	8b 00                	mov    (%eax),%eax
}
  1029a4:	5d                   	pop    %ebp
  1029a5:	c3                   	ret    

001029a6 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  1029a6:	55                   	push   %ebp
  1029a7:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  1029a9:	8b 45 08             	mov    0x8(%ebp),%eax
  1029ac:	8b 00                	mov    (%eax),%eax
  1029ae:	8d 50 ff             	lea    -0x1(%eax),%edx
  1029b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1029b4:	89 10                	mov    %edx,(%eax)
    return page->ref;
  1029b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1029b9:	8b 00                	mov    (%eax),%eax
}
  1029bb:	5d                   	pop    %ebp
  1029bc:	c3                   	ret    

001029bd <__intr_save>:
__intr_save(void) {
  1029bd:	55                   	push   %ebp
  1029be:	89 e5                	mov    %esp,%ebp
  1029c0:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  1029c3:	9c                   	pushf  
  1029c4:	58                   	pop    %eax
  1029c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  1029c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  1029cb:	25 00 02 00 00       	and    $0x200,%eax
  1029d0:	85 c0                	test   %eax,%eax
  1029d2:	74 0c                	je     1029e0 <__intr_save+0x23>
        intr_disable();
  1029d4:	e8 b4 ee ff ff       	call   10188d <intr_disable>
        return 1;
  1029d9:	b8 01 00 00 00       	mov    $0x1,%eax
  1029de:	eb 05                	jmp    1029e5 <__intr_save+0x28>
    return 0;
  1029e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1029e5:	c9                   	leave  
  1029e6:	c3                   	ret    

001029e7 <__intr_restore>:
__intr_restore(bool flag) {
  1029e7:	55                   	push   %ebp
  1029e8:	89 e5                	mov    %esp,%ebp
  1029ea:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  1029ed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1029f1:	74 05                	je     1029f8 <__intr_restore+0x11>
        intr_enable();
  1029f3:	e8 8e ee ff ff       	call   101886 <intr_enable>
}
  1029f8:	90                   	nop
  1029f9:	c9                   	leave  
  1029fa:	c3                   	ret    

001029fb <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  1029fb:	55                   	push   %ebp
  1029fc:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  1029fe:	8b 45 08             	mov    0x8(%ebp),%eax
  102a01:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102a04:	b8 23 00 00 00       	mov    $0x23,%eax
  102a09:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102a0b:	b8 23 00 00 00       	mov    $0x23,%eax
  102a10:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102a12:	b8 10 00 00 00       	mov    $0x10,%eax
  102a17:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102a19:	b8 10 00 00 00       	mov    $0x10,%eax
  102a1e:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102a20:	b8 10 00 00 00       	mov    $0x10,%eax
  102a25:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102a27:	ea 2e 2a 10 00 08 00 	ljmp   $0x8,$0x102a2e
}
  102a2e:	90                   	nop
  102a2f:	5d                   	pop    %ebp
  102a30:	c3                   	ret    

00102a31 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102a31:	55                   	push   %ebp
  102a32:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102a34:	8b 45 08             	mov    0x8(%ebp),%eax
  102a37:	a3 a4 de 11 00       	mov    %eax,0x11dea4
}
  102a3c:	90                   	nop
  102a3d:	5d                   	pop    %ebp
  102a3e:	c3                   	ret    

00102a3f <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102a3f:	55                   	push   %ebp
  102a40:	89 e5                	mov    %esp,%ebp
  102a42:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102a45:	b8 00 a0 11 00       	mov    $0x11a000,%eax
  102a4a:	89 04 24             	mov    %eax,(%esp)
  102a4d:	e8 df ff ff ff       	call   102a31 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102a52:	66 c7 05 a8 de 11 00 	movw   $0x10,0x11dea8
  102a59:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102a5b:	66 c7 05 28 aa 11 00 	movw   $0x68,0x11aa28
  102a62:	68 00 
  102a64:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102a69:	0f b7 c0             	movzwl %ax,%eax
  102a6c:	66 a3 2a aa 11 00    	mov    %ax,0x11aa2a
  102a72:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102a77:	c1 e8 10             	shr    $0x10,%eax
  102a7a:	a2 2c aa 11 00       	mov    %al,0x11aa2c
  102a7f:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102a86:	24 f0                	and    $0xf0,%al
  102a88:	0c 09                	or     $0x9,%al
  102a8a:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102a8f:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102a96:	24 ef                	and    $0xef,%al
  102a98:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102a9d:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102aa4:	24 9f                	and    $0x9f,%al
  102aa6:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102aab:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102ab2:	0c 80                	or     $0x80,%al
  102ab4:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102ab9:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102ac0:	24 f0                	and    $0xf0,%al
  102ac2:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102ac7:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102ace:	24 ef                	and    $0xef,%al
  102ad0:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102ad5:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102adc:	24 df                	and    $0xdf,%al
  102ade:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102ae3:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102aea:	0c 40                	or     $0x40,%al
  102aec:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102af1:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102af8:	24 7f                	and    $0x7f,%al
  102afa:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102aff:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102b04:	c1 e8 18             	shr    $0x18,%eax
  102b07:	a2 2f aa 11 00       	mov    %al,0x11aa2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102b0c:	c7 04 24 30 aa 11 00 	movl   $0x11aa30,(%esp)
  102b13:	e8 e3 fe ff ff       	call   1029fb <lgdt>
  102b18:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102b1e:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102b22:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102b25:	90                   	nop
  102b26:	c9                   	leave  
  102b27:	c3                   	ret    

00102b28 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102b28:	55                   	push   %ebp
  102b29:	89 e5                	mov    %esp,%ebp
  102b2b:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102b2e:	c7 05 10 df 11 00 c0 	movl   $0x107fc0,0x11df10
  102b35:	7f 10 00 
    //pmm_manager = &buddy_system;
    cprintf("memory management: %s\n", pmm_manager->name);
  102b38:	a1 10 df 11 00       	mov    0x11df10,%eax
  102b3d:	8b 00                	mov    (%eax),%eax
  102b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b43:	c7 04 24 30 76 10 00 	movl   $0x107630,(%esp)
  102b4a:	e8 43 d7 ff ff       	call   100292 <cprintf>
    pmm_manager->init();
  102b4f:	a1 10 df 11 00       	mov    0x11df10,%eax
  102b54:	8b 40 04             	mov    0x4(%eax),%eax
  102b57:	ff d0                	call   *%eax
}
  102b59:	90                   	nop
  102b5a:	c9                   	leave  
  102b5b:	c3                   	ret    

00102b5c <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102b5c:	55                   	push   %ebp
  102b5d:	89 e5                	mov    %esp,%ebp
  102b5f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102b62:	a1 10 df 11 00       	mov    0x11df10,%eax
  102b67:	8b 40 08             	mov    0x8(%eax),%eax
  102b6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  102b71:	8b 55 08             	mov    0x8(%ebp),%edx
  102b74:	89 14 24             	mov    %edx,(%esp)
  102b77:	ff d0                	call   *%eax
}
  102b79:	90                   	nop
  102b7a:	c9                   	leave  
  102b7b:	c3                   	ret    

00102b7c <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102b7c:	55                   	push   %ebp
  102b7d:	89 e5                	mov    %esp,%ebp
  102b7f:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102b82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102b89:	e8 2f fe ff ff       	call   1029bd <__intr_save>
  102b8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102b91:	a1 10 df 11 00       	mov    0x11df10,%eax
  102b96:	8b 40 0c             	mov    0xc(%eax),%eax
  102b99:	8b 55 08             	mov    0x8(%ebp),%edx
  102b9c:	89 14 24             	mov    %edx,(%esp)
  102b9f:	ff d0                	call   *%eax
  102ba1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102ba4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ba7:	89 04 24             	mov    %eax,(%esp)
  102baa:	e8 38 fe ff ff       	call   1029e7 <__intr_restore>
    return page;
  102baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102bb2:	c9                   	leave  
  102bb3:	c3                   	ret    

00102bb4 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102bb4:	55                   	push   %ebp
  102bb5:	89 e5                	mov    %esp,%ebp
  102bb7:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102bba:	e8 fe fd ff ff       	call   1029bd <__intr_save>
  102bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102bc2:	a1 10 df 11 00       	mov    0x11df10,%eax
  102bc7:	8b 40 10             	mov    0x10(%eax),%eax
  102bca:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bcd:	89 54 24 04          	mov    %edx,0x4(%esp)
  102bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  102bd4:	89 14 24             	mov    %edx,(%esp)
  102bd7:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bdc:	89 04 24             	mov    %eax,(%esp)
  102bdf:	e8 03 fe ff ff       	call   1029e7 <__intr_restore>
}
  102be4:	90                   	nop
  102be5:	c9                   	leave  
  102be6:	c3                   	ret    

00102be7 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102be7:	55                   	push   %ebp
  102be8:	89 e5                	mov    %esp,%ebp
  102bea:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102bed:	e8 cb fd ff ff       	call   1029bd <__intr_save>
  102bf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102bf5:	a1 10 df 11 00       	mov    0x11df10,%eax
  102bfa:	8b 40 14             	mov    0x14(%eax),%eax
  102bfd:	ff d0                	call   *%eax
  102bff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c05:	89 04 24             	mov    %eax,(%esp)
  102c08:	e8 da fd ff ff       	call   1029e7 <__intr_restore>
    return ret;
  102c0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102c10:	c9                   	leave  
  102c11:	c3                   	ret    

00102c12 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102c12:	55                   	push   %ebp
  102c13:	89 e5                	mov    %esp,%ebp
  102c15:	57                   	push   %edi
  102c16:	56                   	push   %esi
  102c17:	53                   	push   %ebx
  102c18:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102c1e:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102c25:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102c2c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102c33:	c7 04 24 47 76 10 00 	movl   $0x107647,(%esp)
  102c3a:	e8 53 d6 ff ff       	call   100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102c3f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102c46:	e9 22 01 00 00       	jmp    102d6d <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102c4b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c4e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c51:	89 d0                	mov    %edx,%eax
  102c53:	c1 e0 02             	shl    $0x2,%eax
  102c56:	01 d0                	add    %edx,%eax
  102c58:	c1 e0 02             	shl    $0x2,%eax
  102c5b:	01 c8                	add    %ecx,%eax
  102c5d:	8b 50 08             	mov    0x8(%eax),%edx
  102c60:	8b 40 04             	mov    0x4(%eax),%eax
  102c63:	89 45 a0             	mov    %eax,-0x60(%ebp)
  102c66:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102c69:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c6c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c6f:	89 d0                	mov    %edx,%eax
  102c71:	c1 e0 02             	shl    $0x2,%eax
  102c74:	01 d0                	add    %edx,%eax
  102c76:	c1 e0 02             	shl    $0x2,%eax
  102c79:	01 c8                	add    %ecx,%eax
  102c7b:	8b 48 0c             	mov    0xc(%eax),%ecx
  102c7e:	8b 58 10             	mov    0x10(%eax),%ebx
  102c81:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102c84:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102c87:	01 c8                	add    %ecx,%eax
  102c89:	11 da                	adc    %ebx,%edx
  102c8b:	89 45 98             	mov    %eax,-0x68(%ebp)
  102c8e:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102c91:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c94:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c97:	89 d0                	mov    %edx,%eax
  102c99:	c1 e0 02             	shl    $0x2,%eax
  102c9c:	01 d0                	add    %edx,%eax
  102c9e:	c1 e0 02             	shl    $0x2,%eax
  102ca1:	01 c8                	add    %ecx,%eax
  102ca3:	83 c0 14             	add    $0x14,%eax
  102ca6:	8b 00                	mov    (%eax),%eax
  102ca8:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102cab:	8b 45 98             	mov    -0x68(%ebp),%eax
  102cae:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102cb1:	83 c0 ff             	add    $0xffffffff,%eax
  102cb4:	83 d2 ff             	adc    $0xffffffff,%edx
  102cb7:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102cbd:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102cc3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cc6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cc9:	89 d0                	mov    %edx,%eax
  102ccb:	c1 e0 02             	shl    $0x2,%eax
  102cce:	01 d0                	add    %edx,%eax
  102cd0:	c1 e0 02             	shl    $0x2,%eax
  102cd3:	01 c8                	add    %ecx,%eax
  102cd5:	8b 48 0c             	mov    0xc(%eax),%ecx
  102cd8:	8b 58 10             	mov    0x10(%eax),%ebx
  102cdb:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102cde:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102ce2:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102ce8:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102cee:	89 44 24 14          	mov    %eax,0x14(%esp)
  102cf2:	89 54 24 18          	mov    %edx,0x18(%esp)
  102cf6:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102cf9:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102cfc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102d00:	89 54 24 10          	mov    %edx,0x10(%esp)
  102d04:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102d08:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102d0c:	c7 04 24 54 76 10 00 	movl   $0x107654,(%esp)
  102d13:	e8 7a d5 ff ff       	call   100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102d18:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d1b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d1e:	89 d0                	mov    %edx,%eax
  102d20:	c1 e0 02             	shl    $0x2,%eax
  102d23:	01 d0                	add    %edx,%eax
  102d25:	c1 e0 02             	shl    $0x2,%eax
  102d28:	01 c8                	add    %ecx,%eax
  102d2a:	83 c0 14             	add    $0x14,%eax
  102d2d:	8b 00                	mov    (%eax),%eax
  102d2f:	83 f8 01             	cmp    $0x1,%eax
  102d32:	75 36                	jne    102d6a <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
  102d34:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d37:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d3a:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102d3d:	77 2b                	ja     102d6a <page_init+0x158>
  102d3f:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102d42:	72 05                	jb     102d49 <page_init+0x137>
  102d44:	3b 45 98             	cmp    -0x68(%ebp),%eax
  102d47:	73 21                	jae    102d6a <page_init+0x158>
  102d49:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102d4d:	77 1b                	ja     102d6a <page_init+0x158>
  102d4f:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102d53:	72 09                	jb     102d5e <page_init+0x14c>
  102d55:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
  102d5c:	77 0c                	ja     102d6a <page_init+0x158>
                maxpa = end;
  102d5e:	8b 45 98             	mov    -0x68(%ebp),%eax
  102d61:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102d64:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102d67:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102d6a:	ff 45 dc             	incl   -0x24(%ebp)
  102d6d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102d70:	8b 00                	mov    (%eax),%eax
  102d72:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102d75:	0f 8c d0 fe ff ff    	jl     102c4b <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102d7b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102d7f:	72 1d                	jb     102d9e <page_init+0x18c>
  102d81:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102d85:	77 09                	ja     102d90 <page_init+0x17e>
  102d87:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102d8e:	76 0e                	jbe    102d9e <page_init+0x18c>
        maxpa = KMEMSIZE;
  102d90:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102d97:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102d9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102da1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102da4:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102da8:	c1 ea 0c             	shr    $0xc,%edx
  102dab:	89 c1                	mov    %eax,%ecx
  102dad:	89 d3                	mov    %edx,%ebx
  102daf:	89 c8                	mov    %ecx,%eax
  102db1:	a3 80 de 11 00       	mov    %eax,0x11de80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102db6:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  102dbd:	b8 bc df 11 00       	mov    $0x11dfbc,%eax
  102dc2:	8d 50 ff             	lea    -0x1(%eax),%edx
  102dc5:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102dc8:	01 d0                	add    %edx,%eax
  102dca:	89 45 bc             	mov    %eax,-0x44(%ebp)
  102dcd:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102dd0:	ba 00 00 00 00       	mov    $0x0,%edx
  102dd5:	f7 75 c0             	divl   -0x40(%ebp)
  102dd8:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102ddb:	29 d0                	sub    %edx,%eax
  102ddd:	a3 18 df 11 00       	mov    %eax,0x11df18

    for (i = 0; i < npage; i ++) {
  102de2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102de9:	eb 2e                	jmp    102e19 <page_init+0x207>
        SetPageReserved(pages + i);
  102deb:	8b 0d 18 df 11 00    	mov    0x11df18,%ecx
  102df1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102df4:	89 d0                	mov    %edx,%eax
  102df6:	c1 e0 02             	shl    $0x2,%eax
  102df9:	01 d0                	add    %edx,%eax
  102dfb:	c1 e0 02             	shl    $0x2,%eax
  102dfe:	01 c8                	add    %ecx,%eax
  102e00:	83 c0 04             	add    $0x4,%eax
  102e03:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  102e0a:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e0d:	8b 45 90             	mov    -0x70(%ebp),%eax
  102e10:	8b 55 94             	mov    -0x6c(%ebp),%edx
  102e13:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
  102e16:	ff 45 dc             	incl   -0x24(%ebp)
  102e19:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e1c:	a1 80 de 11 00       	mov    0x11de80,%eax
  102e21:	39 c2                	cmp    %eax,%edx
  102e23:	72 c6                	jb     102deb <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102e25:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  102e2b:	89 d0                	mov    %edx,%eax
  102e2d:	c1 e0 02             	shl    $0x2,%eax
  102e30:	01 d0                	add    %edx,%eax
  102e32:	c1 e0 02             	shl    $0x2,%eax
  102e35:	89 c2                	mov    %eax,%edx
  102e37:	a1 18 df 11 00       	mov    0x11df18,%eax
  102e3c:	01 d0                	add    %edx,%eax
  102e3e:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102e41:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  102e48:	77 23                	ja     102e6d <page_init+0x25b>
  102e4a:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102e4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102e51:	c7 44 24 08 84 76 10 	movl   $0x107684,0x8(%esp)
  102e58:	00 
  102e59:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
  102e60:	00 
  102e61:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  102e68:	e8 7c d5 ff ff       	call   1003e9 <__panic>
  102e6d:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102e70:	05 00 00 00 40       	add    $0x40000000,%eax
  102e75:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  102e78:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e7f:	e9 69 01 00 00       	jmp    102fed <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102e84:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e87:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e8a:	89 d0                	mov    %edx,%eax
  102e8c:	c1 e0 02             	shl    $0x2,%eax
  102e8f:	01 d0                	add    %edx,%eax
  102e91:	c1 e0 02             	shl    $0x2,%eax
  102e94:	01 c8                	add    %ecx,%eax
  102e96:	8b 50 08             	mov    0x8(%eax),%edx
  102e99:	8b 40 04             	mov    0x4(%eax),%eax
  102e9c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102e9f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102ea2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ea5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ea8:	89 d0                	mov    %edx,%eax
  102eaa:	c1 e0 02             	shl    $0x2,%eax
  102ead:	01 d0                	add    %edx,%eax
  102eaf:	c1 e0 02             	shl    $0x2,%eax
  102eb2:	01 c8                	add    %ecx,%eax
  102eb4:	8b 48 0c             	mov    0xc(%eax),%ecx
  102eb7:	8b 58 10             	mov    0x10(%eax),%ebx
  102eba:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102ebd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102ec0:	01 c8                	add    %ecx,%eax
  102ec2:	11 da                	adc    %ebx,%edx
  102ec4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102ec7:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  102eca:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ecd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ed0:	89 d0                	mov    %edx,%eax
  102ed2:	c1 e0 02             	shl    $0x2,%eax
  102ed5:	01 d0                	add    %edx,%eax
  102ed7:	c1 e0 02             	shl    $0x2,%eax
  102eda:	01 c8                	add    %ecx,%eax
  102edc:	83 c0 14             	add    $0x14,%eax
  102edf:	8b 00                	mov    (%eax),%eax
  102ee1:	83 f8 01             	cmp    $0x1,%eax
  102ee4:	0f 85 00 01 00 00    	jne    102fea <page_init+0x3d8>
            if (begin < freemem) {
  102eea:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102eed:	ba 00 00 00 00       	mov    $0x0,%edx
  102ef2:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102ef5:	77 17                	ja     102f0e <page_init+0x2fc>
  102ef7:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102efa:	72 05                	jb     102f01 <page_init+0x2ef>
  102efc:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  102eff:	73 0d                	jae    102f0e <page_init+0x2fc>
                begin = freemem;
  102f01:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102f04:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f07:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  102f0e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f12:	72 1d                	jb     102f31 <page_init+0x31f>
  102f14:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f18:	77 09                	ja     102f23 <page_init+0x311>
  102f1a:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  102f21:	76 0e                	jbe    102f31 <page_init+0x31f>
                end = KMEMSIZE;
  102f23:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  102f2a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  102f31:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f34:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f37:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f3a:	0f 87 aa 00 00 00    	ja     102fea <page_init+0x3d8>
  102f40:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f43:	72 09                	jb     102f4e <page_init+0x33c>
  102f45:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102f48:	0f 83 9c 00 00 00    	jae    102fea <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
  102f4e:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  102f55:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102f58:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102f5b:	01 d0                	add    %edx,%eax
  102f5d:	48                   	dec    %eax
  102f5e:	89 45 ac             	mov    %eax,-0x54(%ebp)
  102f61:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102f64:	ba 00 00 00 00       	mov    $0x0,%edx
  102f69:	f7 75 b0             	divl   -0x50(%ebp)
  102f6c:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102f6f:	29 d0                	sub    %edx,%eax
  102f71:	ba 00 00 00 00       	mov    $0x0,%edx
  102f76:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f79:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  102f7c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102f7f:	89 45 a8             	mov    %eax,-0x58(%ebp)
  102f82:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102f85:	ba 00 00 00 00       	mov    $0x0,%edx
  102f8a:	89 c3                	mov    %eax,%ebx
  102f8c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  102f92:	89 de                	mov    %ebx,%esi
  102f94:	89 d0                	mov    %edx,%eax
  102f96:	83 e0 00             	and    $0x0,%eax
  102f99:	89 c7                	mov    %eax,%edi
  102f9b:	89 75 c8             	mov    %esi,-0x38(%ebp)
  102f9e:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  102fa1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102fa4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102fa7:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102faa:	77 3e                	ja     102fea <page_init+0x3d8>
  102fac:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102faf:	72 05                	jb     102fb6 <page_init+0x3a4>
  102fb1:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102fb4:	73 34                	jae    102fea <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  102fb6:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102fb9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102fbc:	2b 45 d0             	sub    -0x30(%ebp),%eax
  102fbf:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  102fc2:	89 c1                	mov    %eax,%ecx
  102fc4:	89 d3                	mov    %edx,%ebx
  102fc6:	89 c8                	mov    %ecx,%eax
  102fc8:	89 da                	mov    %ebx,%edx
  102fca:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102fce:	c1 ea 0c             	shr    $0xc,%edx
  102fd1:	89 c3                	mov    %eax,%ebx
  102fd3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102fd6:	89 04 24             	mov    %eax,(%esp)
  102fd9:	e8 a0 f8 ff ff       	call   10287e <pa2page>
  102fde:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102fe2:	89 04 24             	mov    %eax,(%esp)
  102fe5:	e8 72 fb ff ff       	call   102b5c <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  102fea:	ff 45 dc             	incl   -0x24(%ebp)
  102fed:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102ff0:	8b 00                	mov    (%eax),%eax
  102ff2:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102ff5:	0f 8c 89 fe ff ff    	jl     102e84 <page_init+0x272>
                }
            }
        }
    }
}
  102ffb:	90                   	nop
  102ffc:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  103002:	5b                   	pop    %ebx
  103003:	5e                   	pop    %esi
  103004:	5f                   	pop    %edi
  103005:	5d                   	pop    %ebp
  103006:	c3                   	ret    

00103007 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  103007:	55                   	push   %ebp
  103008:	89 e5                	mov    %esp,%ebp
  10300a:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  10300d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103010:	33 45 14             	xor    0x14(%ebp),%eax
  103013:	25 ff 0f 00 00       	and    $0xfff,%eax
  103018:	85 c0                	test   %eax,%eax
  10301a:	74 24                	je     103040 <boot_map_segment+0x39>
  10301c:	c7 44 24 0c b6 76 10 	movl   $0x1076b6,0xc(%esp)
  103023:	00 
  103024:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  10302b:	00 
  10302c:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  103033:	00 
  103034:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  10303b:	e8 a9 d3 ff ff       	call   1003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  103040:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  103047:	8b 45 0c             	mov    0xc(%ebp),%eax
  10304a:	25 ff 0f 00 00       	and    $0xfff,%eax
  10304f:	89 c2                	mov    %eax,%edx
  103051:	8b 45 10             	mov    0x10(%ebp),%eax
  103054:	01 c2                	add    %eax,%edx
  103056:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103059:	01 d0                	add    %edx,%eax
  10305b:	48                   	dec    %eax
  10305c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10305f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103062:	ba 00 00 00 00       	mov    $0x0,%edx
  103067:	f7 75 f0             	divl   -0x10(%ebp)
  10306a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10306d:	29 d0                	sub    %edx,%eax
  10306f:	c1 e8 0c             	shr    $0xc,%eax
  103072:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  103075:	8b 45 0c             	mov    0xc(%ebp),%eax
  103078:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10307b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10307e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103083:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  103086:	8b 45 14             	mov    0x14(%ebp),%eax
  103089:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10308c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10308f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103094:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103097:	eb 68                	jmp    103101 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  103099:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1030a0:	00 
  1030a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1030ab:	89 04 24             	mov    %eax,(%esp)
  1030ae:	e8 81 01 00 00       	call   103234 <get_pte>
  1030b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1030b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1030ba:	75 24                	jne    1030e0 <boot_map_segment+0xd9>
  1030bc:	c7 44 24 0c e2 76 10 	movl   $0x1076e2,0xc(%esp)
  1030c3:	00 
  1030c4:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  1030cb:	00 
  1030cc:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  1030d3:	00 
  1030d4:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  1030db:	e8 09 d3 ff ff       	call   1003e9 <__panic>
        *ptep = pa | PTE_P | perm;
  1030e0:	8b 45 14             	mov    0x14(%ebp),%eax
  1030e3:	0b 45 18             	or     0x18(%ebp),%eax
  1030e6:	83 c8 01             	or     $0x1,%eax
  1030e9:	89 c2                	mov    %eax,%edx
  1030eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030ee:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1030f0:	ff 4d f4             	decl   -0xc(%ebp)
  1030f3:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1030fa:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  103101:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103105:	75 92                	jne    103099 <boot_map_segment+0x92>
    }
}
  103107:	90                   	nop
  103108:	c9                   	leave  
  103109:	c3                   	ret    

0010310a <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  10310a:	55                   	push   %ebp
  10310b:	89 e5                	mov    %esp,%ebp
  10310d:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  103110:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103117:	e8 60 fa ff ff       	call   102b7c <alloc_pages>
  10311c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  10311f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103123:	75 1c                	jne    103141 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  103125:	c7 44 24 08 ef 76 10 	movl   $0x1076ef,0x8(%esp)
  10312c:	00 
  10312d:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
  103134:	00 
  103135:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  10313c:	e8 a8 d2 ff ff       	call   1003e9 <__panic>
    }
    return page2kva(p);
  103141:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103144:	89 04 24             	mov    %eax,(%esp)
  103147:	e8 81 f7 ff ff       	call   1028cd <page2kva>
}
  10314c:	c9                   	leave  
  10314d:	c3                   	ret    

0010314e <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  10314e:	55                   	push   %ebp
  10314f:	89 e5                	mov    %esp,%ebp
  103151:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  103154:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103159:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10315c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  103163:	77 23                	ja     103188 <pmm_init+0x3a>
  103165:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103168:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10316c:	c7 44 24 08 84 76 10 	movl   $0x107684,0x8(%esp)
  103173:	00 
  103174:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  10317b:	00 
  10317c:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103183:	e8 61 d2 ff ff       	call   1003e9 <__panic>
  103188:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10318b:	05 00 00 00 40       	add    $0x40000000,%eax
  103190:	a3 14 df 11 00       	mov    %eax,0x11df14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  103195:	e8 8e f9 ff ff       	call   102b28 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  10319a:	e8 73 fa ff ff       	call   102c12 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  10319f:	e8 de 03 00 00       	call   103582 <check_alloc_page>

    check_pgdir();
  1031a4:	e8 f8 03 00 00       	call   1035a1 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1031a9:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1031ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1031b1:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1031b8:	77 23                	ja     1031dd <pmm_init+0x8f>
  1031ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1031c1:	c7 44 24 08 84 76 10 	movl   $0x107684,0x8(%esp)
  1031c8:	00 
  1031c9:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
  1031d0:	00 
  1031d1:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  1031d8:	e8 0c d2 ff ff       	call   1003e9 <__panic>
  1031dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031e0:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  1031e6:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1031eb:	05 ac 0f 00 00       	add    $0xfac,%eax
  1031f0:	83 ca 03             	or     $0x3,%edx
  1031f3:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1031f5:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1031fa:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  103201:	00 
  103202:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103209:	00 
  10320a:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  103211:	38 
  103212:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  103219:	c0 
  10321a:	89 04 24             	mov    %eax,(%esp)
  10321d:	e8 e5 fd ff ff       	call   103007 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  103222:	e8 18 f8 ff ff       	call   102a3f <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  103227:	e8 11 0a 00 00       	call   103c3d <check_boot_pgdir>

    print_pgdir();
  10322c:	e8 8a 0e 00 00       	call   1040bb <print_pgdir>

}
  103231:	90                   	nop
  103232:	c9                   	leave  
  103233:	c3                   	ret    

00103234 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  103234:	55                   	push   %ebp
  103235:	89 e5                	mov    %esp,%ebp
  103237:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)]; //尝试获得页表
  10323a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10323d:	c1 e8 16             	shr    $0x16,%eax
  103240:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103247:	8b 45 08             	mov    0x8(%ebp),%eax
  10324a:	01 d0                	add    %edx,%eax
  10324c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //如果获取不成功
    if (!(*pdep & PTE_P))
  10324f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103252:	8b 00                	mov    (%eax),%eax
  103254:	83 e0 01             	and    $0x1,%eax
  103257:	85 c0                	test   %eax,%eax
  103259:	0f 85 af 00 00 00    	jne    10330e <get_pte+0xda>
    {
        struct Page *page;
        //如果create参数为0，则get_pte返回NULL；如果create参数不为0，则get_pte需要申请一个新的物理页(alloc_page)
        //假如不需要分配或是分配失败
        if (!create || (page = alloc_page()) == NULL) {
  10325f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103263:	74 15                	je     10327a <get_pte+0x46>
  103265:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10326c:	e8 0b f9 ff ff       	call   102b7c <alloc_pages>
  103271:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103274:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103278:	75 0a                	jne    103284 <get_pte+0x50>
            return NULL;
  10327a:	b8 00 00 00 00       	mov    $0x0,%eax
  10327f:	e9 e7 00 00 00       	jmp    10336b <get_pte+0x137>
        }
        //再在一级页表中添加页目录项指向表示二级页表的新物理页
        set_page_ref(page, 1); //引用次数加一(page的ref属性，一种counter)
  103284:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10328b:	00 
  10328c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10328f:	89 04 24             	mov    %eax,(%esp)
  103292:	e8 ea f6 ff ff       	call   102981 <set_page_ref>
        uintptr_t pa = page2pa(page); //得到该页物理地址
  103297:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10329a:	89 04 24             	mov    %eax,(%esp)
  10329d:	e8 c6 f5 ff ff       	call   102868 <page2pa>
  1032a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE); //物理地址转虚拟地址，并初始化
  1032a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1032ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032ae:	c1 e8 0c             	shr    $0xc,%eax
  1032b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1032b4:	a1 80 de 11 00       	mov    0x11de80,%eax
  1032b9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1032bc:	72 23                	jb     1032e1 <get_pte+0xad>
  1032be:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1032c5:	c7 44 24 08 e0 75 10 	movl   $0x1075e0,0x8(%esp)
  1032cc:	00 
  1032cd:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
  1032d4:	00 
  1032d5:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  1032dc:	e8 08 d1 ff ff       	call   1003e9 <__panic>
  1032e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032e4:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1032e9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1032f0:	00 
  1032f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1032f8:	00 
  1032f9:	89 04 24             	mov    %eax,(%esp)
  1032fc:	e8 7e 33 00 00       	call   10667f <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P; //设置控制位
  103301:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103304:	83 c8 07             	or     $0x7,%eax
  103307:	89 c2                	mov    %eax,%edx
  103309:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10330c:	89 10                	mov    %edx,(%eax)
    }
    //如果原来就有二级页表，或者新建立了页表，则只需返回对应项的地址即可
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  10330e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103311:	8b 00                	mov    (%eax),%eax
  103313:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103318:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10331b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10331e:	c1 e8 0c             	shr    $0xc,%eax
  103321:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103324:	a1 80 de 11 00       	mov    0x11de80,%eax
  103329:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10332c:	72 23                	jb     103351 <get_pte+0x11d>
  10332e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103331:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103335:	c7 44 24 08 e0 75 10 	movl   $0x1075e0,0x8(%esp)
  10333c:	00 
  10333d:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
  103344:	00 
  103345:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  10334c:	e8 98 d0 ff ff       	call   1003e9 <__panic>
  103351:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103354:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103359:	89 c2                	mov    %eax,%edx
  10335b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10335e:	c1 e8 0c             	shr    $0xc,%eax
  103361:	25 ff 03 00 00       	and    $0x3ff,%eax
  103366:	c1 e0 02             	shl    $0x2,%eax
  103369:	01 d0                	add    %edx,%eax

}
  10336b:	c9                   	leave  
  10336c:	c3                   	ret    

0010336d <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  10336d:	55                   	push   %ebp
  10336e:	89 e5                	mov    %esp,%ebp
  103370:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  103373:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10337a:	00 
  10337b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10337e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103382:	8b 45 08             	mov    0x8(%ebp),%eax
  103385:	89 04 24             	mov    %eax,(%esp)
  103388:	e8 a7 fe ff ff       	call   103234 <get_pte>
  10338d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  103390:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103394:	74 08                	je     10339e <get_page+0x31>
        *ptep_store = ptep;
  103396:	8b 45 10             	mov    0x10(%ebp),%eax
  103399:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10339c:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  10339e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1033a2:	74 1b                	je     1033bf <get_page+0x52>
  1033a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033a7:	8b 00                	mov    (%eax),%eax
  1033a9:	83 e0 01             	and    $0x1,%eax
  1033ac:	85 c0                	test   %eax,%eax
  1033ae:	74 0f                	je     1033bf <get_page+0x52>
        return pte2page(*ptep);
  1033b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033b3:	8b 00                	mov    (%eax),%eax
  1033b5:	89 04 24             	mov    %eax,(%esp)
  1033b8:	e8 64 f5 ff ff       	call   102921 <pte2page>
  1033bd:	eb 05                	jmp    1033c4 <get_page+0x57>
    }
    return NULL;
  1033bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1033c4:	c9                   	leave  
  1033c5:	c3                   	ret    

001033c6 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  1033c6:	55                   	push   %ebp
  1033c7:	89 e5                	mov    %esp,%ebp
  1033c9:	83 ec 28             	sub    $0x28,%esp
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
//ex3的代码 
    if (*ptep & PTE_P) {   //PTE_P代表页存在
  1033cc:	8b 45 10             	mov    0x10(%ebp),%eax
  1033cf:	8b 00                	mov    (%eax),%eax
  1033d1:	83 e0 01             	and    $0x1,%eax
  1033d4:	85 c0                	test   %eax,%eax
  1033d6:	74 4d                	je     103425 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep); //这个函数用于获取二级页表对应的物理页
  1033d8:	8b 45 10             	mov    0x10(%ebp),%eax
  1033db:	8b 00                	mov    (%eax),%eax
  1033dd:	89 04 24             	mov    %eax,(%esp)
  1033e0:	e8 3c f5 ff ff       	call   102921 <pte2page>
  1033e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) { //page_ref_dec(page)将ref减1，判断是否只使用了一次（只被二级页表引用一次）
  1033e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033eb:	89 04 24             	mov    %eax,(%esp)
  1033ee:	e8 b3 f5 ff ff       	call   1029a6 <page_ref_dec>
  1033f3:	85 c0                	test   %eax,%eax
  1033f5:	75 13                	jne    10340a <page_remove_pte+0x44>
            free_page(page); //则可以释放这个页
  1033f7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033fe:	00 
  1033ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103402:	89 04 24             	mov    %eax,(%esp)
  103405:	e8 aa f7 ff ff       	call   102bb4 <free_pages>
        }
        *ptep = 0;//如果还有更多的页表应用了它，不能释放，要取消二级映射，把二级页表ixang清零
  10340a:	8b 45 10             	mov    0x10(%ebp),%eax
  10340d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);//更新TLB，使TLB中的项无效（除非这个页表正在被使用）
  103413:	8b 45 0c             	mov    0xc(%ebp),%eax
  103416:	89 44 24 04          	mov    %eax,0x4(%esp)
  10341a:	8b 45 08             	mov    0x8(%ebp),%eax
  10341d:	89 04 24             	mov    %eax,(%esp)
  103420:	e8 01 01 00 00       	call   103526 <tlb_invalidate>
    }
}
  103425:	90                   	nop
  103426:	c9                   	leave  
  103427:	c3                   	ret    

00103428 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  103428:	55                   	push   %ebp
  103429:	89 e5                	mov    %esp,%ebp
  10342b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10342e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103435:	00 
  103436:	8b 45 0c             	mov    0xc(%ebp),%eax
  103439:	89 44 24 04          	mov    %eax,0x4(%esp)
  10343d:	8b 45 08             	mov    0x8(%ebp),%eax
  103440:	89 04 24             	mov    %eax,(%esp)
  103443:	e8 ec fd ff ff       	call   103234 <get_pte>
  103448:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  10344b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10344f:	74 19                	je     10346a <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  103451:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103454:	89 44 24 08          	mov    %eax,0x8(%esp)
  103458:	8b 45 0c             	mov    0xc(%ebp),%eax
  10345b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10345f:	8b 45 08             	mov    0x8(%ebp),%eax
  103462:	89 04 24             	mov    %eax,(%esp)
  103465:	e8 5c ff ff ff       	call   1033c6 <page_remove_pte>
    }
}
  10346a:	90                   	nop
  10346b:	c9                   	leave  
  10346c:	c3                   	ret    

0010346d <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  10346d:	55                   	push   %ebp
  10346e:	89 e5                	mov    %esp,%ebp
  103470:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  103473:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10347a:	00 
  10347b:	8b 45 10             	mov    0x10(%ebp),%eax
  10347e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103482:	8b 45 08             	mov    0x8(%ebp),%eax
  103485:	89 04 24             	mov    %eax,(%esp)
  103488:	e8 a7 fd ff ff       	call   103234 <get_pte>
  10348d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  103490:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103494:	75 0a                	jne    1034a0 <page_insert+0x33>
        return -E_NO_MEM;
  103496:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  10349b:	e9 84 00 00 00       	jmp    103524 <page_insert+0xb7>
    }
    page_ref_inc(page);
  1034a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034a3:	89 04 24             	mov    %eax,(%esp)
  1034a6:	e8 e4 f4 ff ff       	call   10298f <page_ref_inc>
    if (*ptep & PTE_P) {
  1034ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034ae:	8b 00                	mov    (%eax),%eax
  1034b0:	83 e0 01             	and    $0x1,%eax
  1034b3:	85 c0                	test   %eax,%eax
  1034b5:	74 3e                	je     1034f5 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  1034b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034ba:	8b 00                	mov    (%eax),%eax
  1034bc:	89 04 24             	mov    %eax,(%esp)
  1034bf:	e8 5d f4 ff ff       	call   102921 <pte2page>
  1034c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1034c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034ca:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1034cd:	75 0d                	jne    1034dc <page_insert+0x6f>
            page_ref_dec(page);
  1034cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034d2:	89 04 24             	mov    %eax,(%esp)
  1034d5:	e8 cc f4 ff ff       	call   1029a6 <page_ref_dec>
  1034da:	eb 19                	jmp    1034f5 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1034dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034df:	89 44 24 08          	mov    %eax,0x8(%esp)
  1034e3:	8b 45 10             	mov    0x10(%ebp),%eax
  1034e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1034ed:	89 04 24             	mov    %eax,(%esp)
  1034f0:	e8 d1 fe ff ff       	call   1033c6 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1034f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034f8:	89 04 24             	mov    %eax,(%esp)
  1034fb:	e8 68 f3 ff ff       	call   102868 <page2pa>
  103500:	0b 45 14             	or     0x14(%ebp),%eax
  103503:	83 c8 01             	or     $0x1,%eax
  103506:	89 c2                	mov    %eax,%edx
  103508:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10350b:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  10350d:	8b 45 10             	mov    0x10(%ebp),%eax
  103510:	89 44 24 04          	mov    %eax,0x4(%esp)
  103514:	8b 45 08             	mov    0x8(%ebp),%eax
  103517:	89 04 24             	mov    %eax,(%esp)
  10351a:	e8 07 00 00 00       	call   103526 <tlb_invalidate>
    return 0;
  10351f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103524:	c9                   	leave  
  103525:	c3                   	ret    

00103526 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  103526:	55                   	push   %ebp
  103527:	89 e5                	mov    %esp,%ebp
  103529:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  10352c:	0f 20 d8             	mov    %cr3,%eax
  10352f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  103532:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  103535:	8b 45 08             	mov    0x8(%ebp),%eax
  103538:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10353b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  103542:	77 23                	ja     103567 <tlb_invalidate+0x41>
  103544:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103547:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10354b:	c7 44 24 08 84 76 10 	movl   $0x107684,0x8(%esp)
  103552:	00 
  103553:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
  10355a:	00 
  10355b:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103562:	e8 82 ce ff ff       	call   1003e9 <__panic>
  103567:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10356a:	05 00 00 00 40       	add    $0x40000000,%eax
  10356f:	39 d0                	cmp    %edx,%eax
  103571:	75 0c                	jne    10357f <tlb_invalidate+0x59>
        invlpg((void *)la);
  103573:	8b 45 0c             	mov    0xc(%ebp),%eax
  103576:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  103579:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10357c:	0f 01 38             	invlpg (%eax)
    }
}
  10357f:	90                   	nop
  103580:	c9                   	leave  
  103581:	c3                   	ret    

00103582 <check_alloc_page>:

static void
check_alloc_page(void) {
  103582:	55                   	push   %ebp
  103583:	89 e5                	mov    %esp,%ebp
  103585:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  103588:	a1 10 df 11 00       	mov    0x11df10,%eax
  10358d:	8b 40 18             	mov    0x18(%eax),%eax
  103590:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  103592:	c7 04 24 08 77 10 00 	movl   $0x107708,(%esp)
  103599:	e8 f4 cc ff ff       	call   100292 <cprintf>
}
  10359e:	90                   	nop
  10359f:	c9                   	leave  
  1035a0:	c3                   	ret    

001035a1 <check_pgdir>:

static void
check_pgdir(void) {
  1035a1:	55                   	push   %ebp
  1035a2:	89 e5                	mov    %esp,%ebp
  1035a4:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1035a7:	a1 80 de 11 00       	mov    0x11de80,%eax
  1035ac:	3d 00 80 03 00       	cmp    $0x38000,%eax
  1035b1:	76 24                	jbe    1035d7 <check_pgdir+0x36>
  1035b3:	c7 44 24 0c 27 77 10 	movl   $0x107727,0xc(%esp)
  1035ba:	00 
  1035bb:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  1035c2:	00 
  1035c3:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  1035ca:	00 
  1035cb:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  1035d2:	e8 12 ce ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  1035d7:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1035dc:	85 c0                	test   %eax,%eax
  1035de:	74 0e                	je     1035ee <check_pgdir+0x4d>
  1035e0:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1035e5:	25 ff 0f 00 00       	and    $0xfff,%eax
  1035ea:	85 c0                	test   %eax,%eax
  1035ec:	74 24                	je     103612 <check_pgdir+0x71>
  1035ee:	c7 44 24 0c 44 77 10 	movl   $0x107744,0xc(%esp)
  1035f5:	00 
  1035f6:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  1035fd:	00 
  1035fe:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  103605:	00 
  103606:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  10360d:	e8 d7 cd ff ff       	call   1003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  103612:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103617:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10361e:	00 
  10361f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103626:	00 
  103627:	89 04 24             	mov    %eax,(%esp)
  10362a:	e8 3e fd ff ff       	call   10336d <get_page>
  10362f:	85 c0                	test   %eax,%eax
  103631:	74 24                	je     103657 <check_pgdir+0xb6>
  103633:	c7 44 24 0c 7c 77 10 	movl   $0x10777c,0xc(%esp)
  10363a:	00 
  10363b:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103642:	00 
  103643:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  10364a:	00 
  10364b:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103652:	e8 92 cd ff ff       	call   1003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  103657:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10365e:	e8 19 f5 ff ff       	call   102b7c <alloc_pages>
  103663:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  103666:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10366b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103672:	00 
  103673:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10367a:	00 
  10367b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10367e:	89 54 24 04          	mov    %edx,0x4(%esp)
  103682:	89 04 24             	mov    %eax,(%esp)
  103685:	e8 e3 fd ff ff       	call   10346d <page_insert>
  10368a:	85 c0                	test   %eax,%eax
  10368c:	74 24                	je     1036b2 <check_pgdir+0x111>
  10368e:	c7 44 24 0c a4 77 10 	movl   $0x1077a4,0xc(%esp)
  103695:	00 
  103696:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  10369d:	00 
  10369e:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  1036a5:	00 
  1036a6:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  1036ad:	e8 37 cd ff ff       	call   1003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  1036b2:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1036b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1036be:	00 
  1036bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1036c6:	00 
  1036c7:	89 04 24             	mov    %eax,(%esp)
  1036ca:	e8 65 fb ff ff       	call   103234 <get_pte>
  1036cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1036d6:	75 24                	jne    1036fc <check_pgdir+0x15b>
  1036d8:	c7 44 24 0c d0 77 10 	movl   $0x1077d0,0xc(%esp)
  1036df:	00 
  1036e0:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  1036e7:	00 
  1036e8:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  1036ef:	00 
  1036f0:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  1036f7:	e8 ed cc ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  1036fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1036ff:	8b 00                	mov    (%eax),%eax
  103701:	89 04 24             	mov    %eax,(%esp)
  103704:	e8 18 f2 ff ff       	call   102921 <pte2page>
  103709:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10370c:	74 24                	je     103732 <check_pgdir+0x191>
  10370e:	c7 44 24 0c fd 77 10 	movl   $0x1077fd,0xc(%esp)
  103715:	00 
  103716:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  10371d:	00 
  10371e:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
  103725:	00 
  103726:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  10372d:	e8 b7 cc ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 1);
  103732:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103735:	89 04 24             	mov    %eax,(%esp)
  103738:	e8 3a f2 ff ff       	call   102977 <page_ref>
  10373d:	83 f8 01             	cmp    $0x1,%eax
  103740:	74 24                	je     103766 <check_pgdir+0x1c5>
  103742:	c7 44 24 0c 13 78 10 	movl   $0x107813,0xc(%esp)
  103749:	00 
  10374a:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103751:	00 
  103752:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  103759:	00 
  10375a:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103761:	e8 83 cc ff ff       	call   1003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  103766:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10376b:	8b 00                	mov    (%eax),%eax
  10376d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103772:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103775:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103778:	c1 e8 0c             	shr    $0xc,%eax
  10377b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10377e:	a1 80 de 11 00       	mov    0x11de80,%eax
  103783:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103786:	72 23                	jb     1037ab <check_pgdir+0x20a>
  103788:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10378b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10378f:	c7 44 24 08 e0 75 10 	movl   $0x1075e0,0x8(%esp)
  103796:	00 
  103797:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  10379e:	00 
  10379f:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  1037a6:	e8 3e cc ff ff       	call   1003e9 <__panic>
  1037ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037ae:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1037b3:	83 c0 04             	add    $0x4,%eax
  1037b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1037b9:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1037be:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1037c5:	00 
  1037c6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1037cd:	00 
  1037ce:	89 04 24             	mov    %eax,(%esp)
  1037d1:	e8 5e fa ff ff       	call   103234 <get_pte>
  1037d6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  1037d9:	74 24                	je     1037ff <check_pgdir+0x25e>
  1037db:	c7 44 24 0c 28 78 10 	movl   $0x107828,0xc(%esp)
  1037e2:	00 
  1037e3:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  1037ea:	00 
  1037eb:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
  1037f2:	00 
  1037f3:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  1037fa:	e8 ea cb ff ff       	call   1003e9 <__panic>

    p2 = alloc_page();
  1037ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103806:	e8 71 f3 ff ff       	call   102b7c <alloc_pages>
  10380b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  10380e:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103813:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  10381a:	00 
  10381b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103822:	00 
  103823:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103826:	89 54 24 04          	mov    %edx,0x4(%esp)
  10382a:	89 04 24             	mov    %eax,(%esp)
  10382d:	e8 3b fc ff ff       	call   10346d <page_insert>
  103832:	85 c0                	test   %eax,%eax
  103834:	74 24                	je     10385a <check_pgdir+0x2b9>
  103836:	c7 44 24 0c 50 78 10 	movl   $0x107850,0xc(%esp)
  10383d:	00 
  10383e:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103845:	00 
  103846:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  10384d:	00 
  10384e:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103855:	e8 8f cb ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  10385a:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10385f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103866:	00 
  103867:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10386e:	00 
  10386f:	89 04 24             	mov    %eax,(%esp)
  103872:	e8 bd f9 ff ff       	call   103234 <get_pte>
  103877:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10387a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10387e:	75 24                	jne    1038a4 <check_pgdir+0x303>
  103880:	c7 44 24 0c 88 78 10 	movl   $0x107888,0xc(%esp)
  103887:	00 
  103888:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  10388f:	00 
  103890:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  103897:	00 
  103898:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  10389f:	e8 45 cb ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_U);
  1038a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038a7:	8b 00                	mov    (%eax),%eax
  1038a9:	83 e0 04             	and    $0x4,%eax
  1038ac:	85 c0                	test   %eax,%eax
  1038ae:	75 24                	jne    1038d4 <check_pgdir+0x333>
  1038b0:	c7 44 24 0c b8 78 10 	movl   $0x1078b8,0xc(%esp)
  1038b7:	00 
  1038b8:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  1038bf:	00 
  1038c0:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  1038c7:	00 
  1038c8:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  1038cf:	e8 15 cb ff ff       	call   1003e9 <__panic>
    assert(*ptep & PTE_W);
  1038d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038d7:	8b 00                	mov    (%eax),%eax
  1038d9:	83 e0 02             	and    $0x2,%eax
  1038dc:	85 c0                	test   %eax,%eax
  1038de:	75 24                	jne    103904 <check_pgdir+0x363>
  1038e0:	c7 44 24 0c c6 78 10 	movl   $0x1078c6,0xc(%esp)
  1038e7:	00 
  1038e8:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  1038ef:	00 
  1038f0:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  1038f7:	00 
  1038f8:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  1038ff:	e8 e5 ca ff ff       	call   1003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  103904:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103909:	8b 00                	mov    (%eax),%eax
  10390b:	83 e0 04             	and    $0x4,%eax
  10390e:	85 c0                	test   %eax,%eax
  103910:	75 24                	jne    103936 <check_pgdir+0x395>
  103912:	c7 44 24 0c d4 78 10 	movl   $0x1078d4,0xc(%esp)
  103919:	00 
  10391a:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103921:	00 
  103922:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  103929:	00 
  10392a:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103931:	e8 b3 ca ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 1);
  103936:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103939:	89 04 24             	mov    %eax,(%esp)
  10393c:	e8 36 f0 ff ff       	call   102977 <page_ref>
  103941:	83 f8 01             	cmp    $0x1,%eax
  103944:	74 24                	je     10396a <check_pgdir+0x3c9>
  103946:	c7 44 24 0c ea 78 10 	movl   $0x1078ea,0xc(%esp)
  10394d:	00 
  10394e:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103955:	00 
  103956:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  10395d:	00 
  10395e:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103965:	e8 7f ca ff ff       	call   1003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  10396a:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10396f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103976:	00 
  103977:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10397e:	00 
  10397f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103982:	89 54 24 04          	mov    %edx,0x4(%esp)
  103986:	89 04 24             	mov    %eax,(%esp)
  103989:	e8 df fa ff ff       	call   10346d <page_insert>
  10398e:	85 c0                	test   %eax,%eax
  103990:	74 24                	je     1039b6 <check_pgdir+0x415>
  103992:	c7 44 24 0c fc 78 10 	movl   $0x1078fc,0xc(%esp)
  103999:	00 
  10399a:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  1039a1:	00 
  1039a2:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  1039a9:	00 
  1039aa:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  1039b1:	e8 33 ca ff ff       	call   1003e9 <__panic>
    assert(page_ref(p1) == 2);
  1039b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1039b9:	89 04 24             	mov    %eax,(%esp)
  1039bc:	e8 b6 ef ff ff       	call   102977 <page_ref>
  1039c1:	83 f8 02             	cmp    $0x2,%eax
  1039c4:	74 24                	je     1039ea <check_pgdir+0x449>
  1039c6:	c7 44 24 0c 28 79 10 	movl   $0x107928,0xc(%esp)
  1039cd:	00 
  1039ce:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  1039d5:	00 
  1039d6:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  1039dd:	00 
  1039de:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  1039e5:	e8 ff c9 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  1039ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1039ed:	89 04 24             	mov    %eax,(%esp)
  1039f0:	e8 82 ef ff ff       	call   102977 <page_ref>
  1039f5:	85 c0                	test   %eax,%eax
  1039f7:	74 24                	je     103a1d <check_pgdir+0x47c>
  1039f9:	c7 44 24 0c 3a 79 10 	movl   $0x10793a,0xc(%esp)
  103a00:	00 
  103a01:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103a08:	00 
  103a09:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
  103a10:	00 
  103a11:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103a18:	e8 cc c9 ff ff       	call   1003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103a1d:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103a22:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103a29:	00 
  103a2a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a31:	00 
  103a32:	89 04 24             	mov    %eax,(%esp)
  103a35:	e8 fa f7 ff ff       	call   103234 <get_pte>
  103a3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a3d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a41:	75 24                	jne    103a67 <check_pgdir+0x4c6>
  103a43:	c7 44 24 0c 88 78 10 	movl   $0x107888,0xc(%esp)
  103a4a:	00 
  103a4b:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103a52:	00 
  103a53:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  103a5a:	00 
  103a5b:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103a62:	e8 82 c9 ff ff       	call   1003e9 <__panic>
    assert(pte2page(*ptep) == p1);
  103a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a6a:	8b 00                	mov    (%eax),%eax
  103a6c:	89 04 24             	mov    %eax,(%esp)
  103a6f:	e8 ad ee ff ff       	call   102921 <pte2page>
  103a74:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103a77:	74 24                	je     103a9d <check_pgdir+0x4fc>
  103a79:	c7 44 24 0c fd 77 10 	movl   $0x1077fd,0xc(%esp)
  103a80:	00 
  103a81:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103a88:	00 
  103a89:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
  103a90:	00 
  103a91:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103a98:	e8 4c c9 ff ff       	call   1003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
  103a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103aa0:	8b 00                	mov    (%eax),%eax
  103aa2:	83 e0 04             	and    $0x4,%eax
  103aa5:	85 c0                	test   %eax,%eax
  103aa7:	74 24                	je     103acd <check_pgdir+0x52c>
  103aa9:	c7 44 24 0c 4c 79 10 	movl   $0x10794c,0xc(%esp)
  103ab0:	00 
  103ab1:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103ab8:	00 
  103ab9:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  103ac0:	00 
  103ac1:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103ac8:	e8 1c c9 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
  103acd:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103ad2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103ad9:	00 
  103ada:	89 04 24             	mov    %eax,(%esp)
  103add:	e8 46 f9 ff ff       	call   103428 <page_remove>
    assert(page_ref(p1) == 1);
  103ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ae5:	89 04 24             	mov    %eax,(%esp)
  103ae8:	e8 8a ee ff ff       	call   102977 <page_ref>
  103aed:	83 f8 01             	cmp    $0x1,%eax
  103af0:	74 24                	je     103b16 <check_pgdir+0x575>
  103af2:	c7 44 24 0c 13 78 10 	movl   $0x107813,0xc(%esp)
  103af9:	00 
  103afa:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103b01:	00 
  103b02:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  103b09:	00 
  103b0a:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103b11:	e8 d3 c8 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103b16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b19:	89 04 24             	mov    %eax,(%esp)
  103b1c:	e8 56 ee ff ff       	call   102977 <page_ref>
  103b21:	85 c0                	test   %eax,%eax
  103b23:	74 24                	je     103b49 <check_pgdir+0x5a8>
  103b25:	c7 44 24 0c 3a 79 10 	movl   $0x10793a,0xc(%esp)
  103b2c:	00 
  103b2d:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103b34:	00 
  103b35:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  103b3c:	00 
  103b3d:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103b44:	e8 a0 c8 ff ff       	call   1003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103b49:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103b4e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103b55:	00 
  103b56:	89 04 24             	mov    %eax,(%esp)
  103b59:	e8 ca f8 ff ff       	call   103428 <page_remove>
    assert(page_ref(p1) == 0);
  103b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b61:	89 04 24             	mov    %eax,(%esp)
  103b64:	e8 0e ee ff ff       	call   102977 <page_ref>
  103b69:	85 c0                	test   %eax,%eax
  103b6b:	74 24                	je     103b91 <check_pgdir+0x5f0>
  103b6d:	c7 44 24 0c 61 79 10 	movl   $0x107961,0xc(%esp)
  103b74:	00 
  103b75:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103b7c:	00 
  103b7d:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
  103b84:	00 
  103b85:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103b8c:	e8 58 c8 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p2) == 0);
  103b91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b94:	89 04 24             	mov    %eax,(%esp)
  103b97:	e8 db ed ff ff       	call   102977 <page_ref>
  103b9c:	85 c0                	test   %eax,%eax
  103b9e:	74 24                	je     103bc4 <check_pgdir+0x623>
  103ba0:	c7 44 24 0c 3a 79 10 	movl   $0x10793a,0xc(%esp)
  103ba7:	00 
  103ba8:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103baf:	00 
  103bb0:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  103bb7:	00 
  103bb8:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103bbf:	e8 25 c8 ff ff       	call   1003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103bc4:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103bc9:	8b 00                	mov    (%eax),%eax
  103bcb:	89 04 24             	mov    %eax,(%esp)
  103bce:	e8 8c ed ff ff       	call   10295f <pde2page>
  103bd3:	89 04 24             	mov    %eax,(%esp)
  103bd6:	e8 9c ed ff ff       	call   102977 <page_ref>
  103bdb:	83 f8 01             	cmp    $0x1,%eax
  103bde:	74 24                	je     103c04 <check_pgdir+0x663>
  103be0:	c7 44 24 0c 74 79 10 	movl   $0x107974,0xc(%esp)
  103be7:	00 
  103be8:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103bef:	00 
  103bf0:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
  103bf7:	00 
  103bf8:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103bff:	e8 e5 c7 ff ff       	call   1003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103c04:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103c09:	8b 00                	mov    (%eax),%eax
  103c0b:	89 04 24             	mov    %eax,(%esp)
  103c0e:	e8 4c ed ff ff       	call   10295f <pde2page>
  103c13:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103c1a:	00 
  103c1b:	89 04 24             	mov    %eax,(%esp)
  103c1e:	e8 91 ef ff ff       	call   102bb4 <free_pages>
    boot_pgdir[0] = 0;
  103c23:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103c28:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103c2e:	c7 04 24 9b 79 10 00 	movl   $0x10799b,(%esp)
  103c35:	e8 58 c6 ff ff       	call   100292 <cprintf>
}
  103c3a:	90                   	nop
  103c3b:	c9                   	leave  
  103c3c:	c3                   	ret    

00103c3d <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103c3d:	55                   	push   %ebp
  103c3e:	89 e5                	mov    %esp,%ebp
  103c40:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103c43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103c4a:	e9 ca 00 00 00       	jmp    103d19 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103c55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c58:	c1 e8 0c             	shr    $0xc,%eax
  103c5b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103c5e:	a1 80 de 11 00       	mov    0x11de80,%eax
  103c63:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103c66:	72 23                	jb     103c8b <check_boot_pgdir+0x4e>
  103c68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103c6f:	c7 44 24 08 e0 75 10 	movl   $0x1075e0,0x8(%esp)
  103c76:	00 
  103c77:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
  103c7e:	00 
  103c7f:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103c86:	e8 5e c7 ff ff       	call   1003e9 <__panic>
  103c8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c8e:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103c93:	89 c2                	mov    %eax,%edx
  103c95:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103c9a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103ca1:	00 
  103ca2:	89 54 24 04          	mov    %edx,0x4(%esp)
  103ca6:	89 04 24             	mov    %eax,(%esp)
  103ca9:	e8 86 f5 ff ff       	call   103234 <get_pte>
  103cae:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103cb1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103cb5:	75 24                	jne    103cdb <check_boot_pgdir+0x9e>
  103cb7:	c7 44 24 0c b8 79 10 	movl   $0x1079b8,0xc(%esp)
  103cbe:	00 
  103cbf:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103cc6:	00 
  103cc7:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
  103cce:	00 
  103ccf:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103cd6:	e8 0e c7 ff ff       	call   1003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103cdb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103cde:	8b 00                	mov    (%eax),%eax
  103ce0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103ce5:	89 c2                	mov    %eax,%edx
  103ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103cea:	39 c2                	cmp    %eax,%edx
  103cec:	74 24                	je     103d12 <check_boot_pgdir+0xd5>
  103cee:	c7 44 24 0c f5 79 10 	movl   $0x1079f5,0xc(%esp)
  103cf5:	00 
  103cf6:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103cfd:	00 
  103cfe:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  103d05:	00 
  103d06:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103d0d:	e8 d7 c6 ff ff       	call   1003e9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  103d12:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103d19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103d1c:	a1 80 de 11 00       	mov    0x11de80,%eax
  103d21:	39 c2                	cmp    %eax,%edx
  103d23:	0f 82 26 ff ff ff    	jb     103c4f <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103d29:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103d2e:	05 ac 0f 00 00       	add    $0xfac,%eax
  103d33:	8b 00                	mov    (%eax),%eax
  103d35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103d3a:	89 c2                	mov    %eax,%edx
  103d3c:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103d41:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103d44:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103d4b:	77 23                	ja     103d70 <check_boot_pgdir+0x133>
  103d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103d54:	c7 44 24 08 84 76 10 	movl   $0x107684,0x8(%esp)
  103d5b:	00 
  103d5c:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  103d63:	00 
  103d64:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103d6b:	e8 79 c6 ff ff       	call   1003e9 <__panic>
  103d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d73:	05 00 00 00 40       	add    $0x40000000,%eax
  103d78:	39 d0                	cmp    %edx,%eax
  103d7a:	74 24                	je     103da0 <check_boot_pgdir+0x163>
  103d7c:	c7 44 24 0c 0c 7a 10 	movl   $0x107a0c,0xc(%esp)
  103d83:	00 
  103d84:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103d8b:	00 
  103d8c:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  103d93:	00 
  103d94:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103d9b:	e8 49 c6 ff ff       	call   1003e9 <__panic>

    assert(boot_pgdir[0] == 0);
  103da0:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103da5:	8b 00                	mov    (%eax),%eax
  103da7:	85 c0                	test   %eax,%eax
  103da9:	74 24                	je     103dcf <check_boot_pgdir+0x192>
  103dab:	c7 44 24 0c 40 7a 10 	movl   $0x107a40,0xc(%esp)
  103db2:	00 
  103db3:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103dba:	00 
  103dbb:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
  103dc2:	00 
  103dc3:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103dca:	e8 1a c6 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    p = alloc_page();
  103dcf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103dd6:	e8 a1 ed ff ff       	call   102b7c <alloc_pages>
  103ddb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103dde:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103de3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103dea:	00 
  103deb:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103df2:	00 
  103df3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103df6:	89 54 24 04          	mov    %edx,0x4(%esp)
  103dfa:	89 04 24             	mov    %eax,(%esp)
  103dfd:	e8 6b f6 ff ff       	call   10346d <page_insert>
  103e02:	85 c0                	test   %eax,%eax
  103e04:	74 24                	je     103e2a <check_boot_pgdir+0x1ed>
  103e06:	c7 44 24 0c 54 7a 10 	movl   $0x107a54,0xc(%esp)
  103e0d:	00 
  103e0e:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103e15:	00 
  103e16:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
  103e1d:	00 
  103e1e:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103e25:	e8 bf c5 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 1);
  103e2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103e2d:	89 04 24             	mov    %eax,(%esp)
  103e30:	e8 42 eb ff ff       	call   102977 <page_ref>
  103e35:	83 f8 01             	cmp    $0x1,%eax
  103e38:	74 24                	je     103e5e <check_boot_pgdir+0x221>
  103e3a:	c7 44 24 0c 82 7a 10 	movl   $0x107a82,0xc(%esp)
  103e41:	00 
  103e42:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103e49:	00 
  103e4a:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
  103e51:	00 
  103e52:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103e59:	e8 8b c5 ff ff       	call   1003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103e5e:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103e63:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103e6a:	00 
  103e6b:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  103e72:	00 
  103e73:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103e76:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e7a:	89 04 24             	mov    %eax,(%esp)
  103e7d:	e8 eb f5 ff ff       	call   10346d <page_insert>
  103e82:	85 c0                	test   %eax,%eax
  103e84:	74 24                	je     103eaa <check_boot_pgdir+0x26d>
  103e86:	c7 44 24 0c 94 7a 10 	movl   $0x107a94,0xc(%esp)
  103e8d:	00 
  103e8e:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103e95:	00 
  103e96:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
  103e9d:	00 
  103e9e:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103ea5:	e8 3f c5 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p) == 2);
  103eaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103ead:	89 04 24             	mov    %eax,(%esp)
  103eb0:	e8 c2 ea ff ff       	call   102977 <page_ref>
  103eb5:	83 f8 02             	cmp    $0x2,%eax
  103eb8:	74 24                	je     103ede <check_boot_pgdir+0x2a1>
  103eba:	c7 44 24 0c cb 7a 10 	movl   $0x107acb,0xc(%esp)
  103ec1:	00 
  103ec2:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103ec9:	00 
  103eca:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
  103ed1:	00 
  103ed2:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103ed9:	e8 0b c5 ff ff       	call   1003e9 <__panic>

    const char *str = "ucore: Hello world!!";
  103ede:	c7 45 e8 dc 7a 10 00 	movl   $0x107adc,-0x18(%ebp)
    strcpy((void *)0x100, str);
  103ee5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103ee8:	89 44 24 04          	mov    %eax,0x4(%esp)
  103eec:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103ef3:	e8 bd 24 00 00       	call   1063b5 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103ef8:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  103eff:	00 
  103f00:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f07:	e8 20 25 00 00       	call   10642c <strcmp>
  103f0c:	85 c0                	test   %eax,%eax
  103f0e:	74 24                	je     103f34 <check_boot_pgdir+0x2f7>
  103f10:	c7 44 24 0c f4 7a 10 	movl   $0x107af4,0xc(%esp)
  103f17:	00 
  103f18:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103f1f:	00 
  103f20:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
  103f27:	00 
  103f28:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103f2f:	e8 b5 c4 ff ff       	call   1003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  103f34:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103f37:	89 04 24             	mov    %eax,(%esp)
  103f3a:	e8 8e e9 ff ff       	call   1028cd <page2kva>
  103f3f:	05 00 01 00 00       	add    $0x100,%eax
  103f44:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  103f47:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f4e:	e8 0c 24 00 00       	call   10635f <strlen>
  103f53:	85 c0                	test   %eax,%eax
  103f55:	74 24                	je     103f7b <check_boot_pgdir+0x33e>
  103f57:	c7 44 24 0c 2c 7b 10 	movl   $0x107b2c,0xc(%esp)
  103f5e:	00 
  103f5f:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  103f66:	00 
  103f67:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
  103f6e:	00 
  103f6f:	c7 04 24 a8 76 10 00 	movl   $0x1076a8,(%esp)
  103f76:	e8 6e c4 ff ff       	call   1003e9 <__panic>

    free_page(p);
  103f7b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103f82:	00 
  103f83:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103f86:	89 04 24             	mov    %eax,(%esp)
  103f89:	e8 26 ec ff ff       	call   102bb4 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  103f8e:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103f93:	8b 00                	mov    (%eax),%eax
  103f95:	89 04 24             	mov    %eax,(%esp)
  103f98:	e8 c2 e9 ff ff       	call   10295f <pde2page>
  103f9d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103fa4:	00 
  103fa5:	89 04 24             	mov    %eax,(%esp)
  103fa8:	e8 07 ec ff ff       	call   102bb4 <free_pages>
    boot_pgdir[0] = 0;
  103fad:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103fb2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  103fb8:	c7 04 24 50 7b 10 00 	movl   $0x107b50,(%esp)
  103fbf:	e8 ce c2 ff ff       	call   100292 <cprintf>
}
  103fc4:	90                   	nop
  103fc5:	c9                   	leave  
  103fc6:	c3                   	ret    

00103fc7 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  103fc7:	55                   	push   %ebp
  103fc8:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  103fca:	8b 45 08             	mov    0x8(%ebp),%eax
  103fcd:	83 e0 04             	and    $0x4,%eax
  103fd0:	85 c0                	test   %eax,%eax
  103fd2:	74 04                	je     103fd8 <perm2str+0x11>
  103fd4:	b0 75                	mov    $0x75,%al
  103fd6:	eb 02                	jmp    103fda <perm2str+0x13>
  103fd8:	b0 2d                	mov    $0x2d,%al
  103fda:	a2 08 df 11 00       	mov    %al,0x11df08
    str[1] = 'r';
  103fdf:	c6 05 09 df 11 00 72 	movb   $0x72,0x11df09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  103fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  103fe9:	83 e0 02             	and    $0x2,%eax
  103fec:	85 c0                	test   %eax,%eax
  103fee:	74 04                	je     103ff4 <perm2str+0x2d>
  103ff0:	b0 77                	mov    $0x77,%al
  103ff2:	eb 02                	jmp    103ff6 <perm2str+0x2f>
  103ff4:	b0 2d                	mov    $0x2d,%al
  103ff6:	a2 0a df 11 00       	mov    %al,0x11df0a
    str[3] = '\0';
  103ffb:	c6 05 0b df 11 00 00 	movb   $0x0,0x11df0b
    return str;
  104002:	b8 08 df 11 00       	mov    $0x11df08,%eax
}
  104007:	5d                   	pop    %ebp
  104008:	c3                   	ret    

00104009 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  104009:	55                   	push   %ebp
  10400a:	89 e5                	mov    %esp,%ebp
  10400c:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  10400f:	8b 45 10             	mov    0x10(%ebp),%eax
  104012:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104015:	72 0d                	jb     104024 <get_pgtable_items+0x1b>
        return 0;
  104017:	b8 00 00 00 00       	mov    $0x0,%eax
  10401c:	e9 98 00 00 00       	jmp    1040b9 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  104021:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  104024:	8b 45 10             	mov    0x10(%ebp),%eax
  104027:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10402a:	73 18                	jae    104044 <get_pgtable_items+0x3b>
  10402c:	8b 45 10             	mov    0x10(%ebp),%eax
  10402f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104036:	8b 45 14             	mov    0x14(%ebp),%eax
  104039:	01 d0                	add    %edx,%eax
  10403b:	8b 00                	mov    (%eax),%eax
  10403d:	83 e0 01             	and    $0x1,%eax
  104040:	85 c0                	test   %eax,%eax
  104042:	74 dd                	je     104021 <get_pgtable_items+0x18>
    }
    if (start < right) {
  104044:	8b 45 10             	mov    0x10(%ebp),%eax
  104047:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10404a:	73 68                	jae    1040b4 <get_pgtable_items+0xab>
        if (left_store != NULL) {
  10404c:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  104050:	74 08                	je     10405a <get_pgtable_items+0x51>
            *left_store = start;
  104052:	8b 45 18             	mov    0x18(%ebp),%eax
  104055:	8b 55 10             	mov    0x10(%ebp),%edx
  104058:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  10405a:	8b 45 10             	mov    0x10(%ebp),%eax
  10405d:	8d 50 01             	lea    0x1(%eax),%edx
  104060:	89 55 10             	mov    %edx,0x10(%ebp)
  104063:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10406a:	8b 45 14             	mov    0x14(%ebp),%eax
  10406d:	01 d0                	add    %edx,%eax
  10406f:	8b 00                	mov    (%eax),%eax
  104071:	83 e0 07             	and    $0x7,%eax
  104074:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  104077:	eb 03                	jmp    10407c <get_pgtable_items+0x73>
            start ++;
  104079:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  10407c:	8b 45 10             	mov    0x10(%ebp),%eax
  10407f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104082:	73 1d                	jae    1040a1 <get_pgtable_items+0x98>
  104084:	8b 45 10             	mov    0x10(%ebp),%eax
  104087:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10408e:	8b 45 14             	mov    0x14(%ebp),%eax
  104091:	01 d0                	add    %edx,%eax
  104093:	8b 00                	mov    (%eax),%eax
  104095:	83 e0 07             	and    $0x7,%eax
  104098:	89 c2                	mov    %eax,%edx
  10409a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10409d:	39 c2                	cmp    %eax,%edx
  10409f:	74 d8                	je     104079 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  1040a1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1040a5:	74 08                	je     1040af <get_pgtable_items+0xa6>
            *right_store = start;
  1040a7:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1040aa:	8b 55 10             	mov    0x10(%ebp),%edx
  1040ad:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  1040af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1040b2:	eb 05                	jmp    1040b9 <get_pgtable_items+0xb0>
    }
    return 0;
  1040b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1040b9:	c9                   	leave  
  1040ba:	c3                   	ret    

001040bb <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  1040bb:	55                   	push   %ebp
  1040bc:	89 e5                	mov    %esp,%ebp
  1040be:	57                   	push   %edi
  1040bf:	56                   	push   %esi
  1040c0:	53                   	push   %ebx
  1040c1:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  1040c4:	c7 04 24 70 7b 10 00 	movl   $0x107b70,(%esp)
  1040cb:	e8 c2 c1 ff ff       	call   100292 <cprintf>
    size_t left, right = 0, perm;
  1040d0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1040d7:	e9 fa 00 00 00       	jmp    1041d6 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1040dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1040df:	89 04 24             	mov    %eax,(%esp)
  1040e2:	e8 e0 fe ff ff       	call   103fc7 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  1040e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1040ea:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1040ed:	29 d1                	sub    %edx,%ecx
  1040ef:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1040f1:	89 d6                	mov    %edx,%esi
  1040f3:	c1 e6 16             	shl    $0x16,%esi
  1040f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040f9:	89 d3                	mov    %edx,%ebx
  1040fb:	c1 e3 16             	shl    $0x16,%ebx
  1040fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104101:	89 d1                	mov    %edx,%ecx
  104103:	c1 e1 16             	shl    $0x16,%ecx
  104106:	8b 7d dc             	mov    -0x24(%ebp),%edi
  104109:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10410c:	29 d7                	sub    %edx,%edi
  10410e:	89 fa                	mov    %edi,%edx
  104110:	89 44 24 14          	mov    %eax,0x14(%esp)
  104114:	89 74 24 10          	mov    %esi,0x10(%esp)
  104118:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10411c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104120:	89 54 24 04          	mov    %edx,0x4(%esp)
  104124:	c7 04 24 a1 7b 10 00 	movl   $0x107ba1,(%esp)
  10412b:	e8 62 c1 ff ff       	call   100292 <cprintf>
        size_t l, r = left * NPTEENTRY;
  104130:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104133:	c1 e0 0a             	shl    $0xa,%eax
  104136:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104139:	eb 54                	jmp    10418f <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10413b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10413e:	89 04 24             	mov    %eax,(%esp)
  104141:	e8 81 fe ff ff       	call   103fc7 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  104146:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  104149:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10414c:	29 d1                	sub    %edx,%ecx
  10414e:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104150:	89 d6                	mov    %edx,%esi
  104152:	c1 e6 0c             	shl    $0xc,%esi
  104155:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104158:	89 d3                	mov    %edx,%ebx
  10415a:	c1 e3 0c             	shl    $0xc,%ebx
  10415d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104160:	89 d1                	mov    %edx,%ecx
  104162:	c1 e1 0c             	shl    $0xc,%ecx
  104165:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  104168:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10416b:	29 d7                	sub    %edx,%edi
  10416d:	89 fa                	mov    %edi,%edx
  10416f:	89 44 24 14          	mov    %eax,0x14(%esp)
  104173:	89 74 24 10          	mov    %esi,0x10(%esp)
  104177:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10417b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10417f:	89 54 24 04          	mov    %edx,0x4(%esp)
  104183:	c7 04 24 c0 7b 10 00 	movl   $0x107bc0,(%esp)
  10418a:	e8 03 c1 ff ff       	call   100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  10418f:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  104194:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104197:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10419a:	89 d3                	mov    %edx,%ebx
  10419c:	c1 e3 0a             	shl    $0xa,%ebx
  10419f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1041a2:	89 d1                	mov    %edx,%ecx
  1041a4:	c1 e1 0a             	shl    $0xa,%ecx
  1041a7:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  1041aa:	89 54 24 14          	mov    %edx,0x14(%esp)
  1041ae:	8d 55 d8             	lea    -0x28(%ebp),%edx
  1041b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  1041b5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1041b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1041bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1041c1:	89 0c 24             	mov    %ecx,(%esp)
  1041c4:	e8 40 fe ff ff       	call   104009 <get_pgtable_items>
  1041c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1041cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1041d0:	0f 85 65 ff ff ff    	jne    10413b <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1041d6:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  1041db:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1041de:	8d 55 dc             	lea    -0x24(%ebp),%edx
  1041e1:	89 54 24 14          	mov    %edx,0x14(%esp)
  1041e5:	8d 55 e0             	lea    -0x20(%ebp),%edx
  1041e8:	89 54 24 10          	mov    %edx,0x10(%esp)
  1041ec:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1041f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1041f4:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1041fb:	00 
  1041fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104203:	e8 01 fe ff ff       	call   104009 <get_pgtable_items>
  104208:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10420b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10420f:	0f 85 c7 fe ff ff    	jne    1040dc <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  104215:	c7 04 24 e4 7b 10 00 	movl   $0x107be4,(%esp)
  10421c:	e8 71 c0 ff ff       	call   100292 <cprintf>
}
  104221:	90                   	nop
  104222:	83 c4 4c             	add    $0x4c,%esp
  104225:	5b                   	pop    %ebx
  104226:	5e                   	pop    %esi
  104227:	5f                   	pop    %edi
  104228:	5d                   	pop    %ebp
  104229:	c3                   	ret    

0010422a <page2ppn>:
page2ppn(struct Page *page) {
  10422a:	55                   	push   %ebp
  10422b:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10422d:	8b 45 08             	mov    0x8(%ebp),%eax
  104230:	8b 15 18 df 11 00    	mov    0x11df18,%edx
  104236:	29 d0                	sub    %edx,%eax
  104238:	c1 f8 02             	sar    $0x2,%eax
  10423b:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  104241:	5d                   	pop    %ebp
  104242:	c3                   	ret    

00104243 <page2pa>:
page2pa(struct Page *page) {
  104243:	55                   	push   %ebp
  104244:	89 e5                	mov    %esp,%ebp
  104246:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104249:	8b 45 08             	mov    0x8(%ebp),%eax
  10424c:	89 04 24             	mov    %eax,(%esp)
  10424f:	e8 d6 ff ff ff       	call   10422a <page2ppn>
  104254:	c1 e0 0c             	shl    $0xc,%eax
}
  104257:	c9                   	leave  
  104258:	c3                   	ret    

00104259 <page_ref>:
page_ref(struct Page *page) {
  104259:	55                   	push   %ebp
  10425a:	89 e5                	mov    %esp,%ebp
    return page->ref;
  10425c:	8b 45 08             	mov    0x8(%ebp),%eax
  10425f:	8b 00                	mov    (%eax),%eax
}
  104261:	5d                   	pop    %ebp
  104262:	c3                   	ret    

00104263 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  104263:	55                   	push   %ebp
  104264:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  104266:	8b 45 08             	mov    0x8(%ebp),%eax
  104269:	8b 55 0c             	mov    0xc(%ebp),%edx
  10426c:	89 10                	mov    %edx,(%eax)
}
  10426e:	90                   	nop
  10426f:	5d                   	pop    %ebp
  104270:	c3                   	ret    

00104271 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  104271:	55                   	push   %ebp
  104272:	89 e5                	mov    %esp,%ebp
  104274:	83 ec 10             	sub    $0x10,%esp
  104277:	c7 45 fc 20 df 11 00 	movl   $0x11df20,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10427e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104281:	8b 55 fc             	mov    -0x4(%ebp),%edx
  104284:	89 50 04             	mov    %edx,0x4(%eax)
  104287:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10428a:	8b 50 04             	mov    0x4(%eax),%edx
  10428d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104290:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  104292:	c7 05 28 df 11 00 00 	movl   $0x0,0x11df28
  104299:	00 00 00 
}
  10429c:	90                   	nop
  10429d:	c9                   	leave  
  10429e:	c3                   	ret    

0010429f <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  10429f:	55                   	push   %ebp
  1042a0:	89 e5                	mov    %esp,%ebp
  1042a2:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  1042a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1042a9:	75 24                	jne    1042cf <default_init_memmap+0x30>
  1042ab:	c7 44 24 0c 18 7c 10 	movl   $0x107c18,0xc(%esp)
  1042b2:	00 
  1042b3:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  1042ba:	00 
  1042bb:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  1042c2:	00 
  1042c3:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  1042ca:	e8 1a c1 ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  1042cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1042d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1042d5:	eb 7d                	jmp    104354 <default_init_memmap+0xb5>
        assert(PageReserved(p));
  1042d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042da:	83 c0 04             	add    $0x4,%eax
  1042dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1042e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1042e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1042ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1042ed:	0f a3 10             	bt     %edx,(%eax)
  1042f0:	19 c0                	sbb    %eax,%eax
  1042f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  1042f5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1042f9:	0f 95 c0             	setne  %al
  1042fc:	0f b6 c0             	movzbl %al,%eax
  1042ff:	85 c0                	test   %eax,%eax
  104301:	75 24                	jne    104327 <default_init_memmap+0x88>
  104303:	c7 44 24 0c 49 7c 10 	movl   $0x107c49,0xc(%esp)
  10430a:	00 
  10430b:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104312:	00 
  104313:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  10431a:	00 
  10431b:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104322:	e8 c2 c0 ff ff       	call   1003e9 <__panic>
        p->flags = p->property = 0;
  104327:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10432a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  104331:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104334:	8b 50 08             	mov    0x8(%eax),%edx
  104337:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10433a:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  10433d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104344:	00 
  104345:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104348:	89 04 24             	mov    %eax,(%esp)
  10434b:	e8 13 ff ff ff       	call   104263 <set_page_ref>
    for (; p != base + n; p ++) {
  104350:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104354:	8b 55 0c             	mov    0xc(%ebp),%edx
  104357:	89 d0                	mov    %edx,%eax
  104359:	c1 e0 02             	shl    $0x2,%eax
  10435c:	01 d0                	add    %edx,%eax
  10435e:	c1 e0 02             	shl    $0x2,%eax
  104361:	89 c2                	mov    %eax,%edx
  104363:	8b 45 08             	mov    0x8(%ebp),%eax
  104366:	01 d0                	add    %edx,%eax
  104368:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10436b:	0f 85 66 ff ff ff    	jne    1042d7 <default_init_memmap+0x38>
	
    }
    base->property = n;
  104371:	8b 45 08             	mov    0x8(%ebp),%eax
  104374:	8b 55 0c             	mov    0xc(%ebp),%edx
  104377:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  10437a:	8b 45 08             	mov    0x8(%ebp),%eax
  10437d:	83 c0 04             	add    $0x4,%eax
  104380:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104387:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10438a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10438d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104390:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  104393:	8b 15 28 df 11 00    	mov    0x11df28,%edx
  104399:	8b 45 0c             	mov    0xc(%ebp),%eax
  10439c:	01 d0                	add    %edx,%eax
  10439e:	a3 28 df 11 00       	mov    %eax,0x11df28
    list_add_before(&free_list,&(base->page_link));
  1043a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1043a6:	83 c0 0c             	add    $0xc,%eax
  1043a9:	c7 45 e4 20 df 11 00 	movl   $0x11df20,-0x1c(%ebp)
  1043b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1043b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043b6:	8b 00                	mov    (%eax),%eax
  1043b8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1043bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1043be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1043c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1043c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1043ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1043cd:	89 10                	mov    %edx,(%eax)
  1043cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1043d2:	8b 10                	mov    (%eax),%edx
  1043d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1043d7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1043da:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043dd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1043e0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1043e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1043e9:	89 10                	mov    %edx,(%eax)
}
  1043eb:	90                   	nop
  1043ec:	c9                   	leave  
  1043ed:	c3                   	ret    

001043ee <default_alloc_pages>:
 *              return `p`.
 *      (4.2)
 *          If we can not find a free block with its size >=n, then return NULL.
*/
static struct Page *
default_alloc_pages(size_t n) {
  1043ee:	55                   	push   %ebp
  1043ef:	89 e5                	mov    %esp,%ebp
  1043f1:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  1043f4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1043f8:	75 24                	jne    10441e <default_alloc_pages+0x30>
  1043fa:	c7 44 24 0c 18 7c 10 	movl   $0x107c18,0xc(%esp)
  104401:	00 
  104402:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104409:	00 
  10440a:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  104411:	00 
  104412:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104419:	e8 cb bf ff ff       	call   1003e9 <__panic>
    if (n > nr_free) {
  10441e:	a1 28 df 11 00       	mov    0x11df28,%eax
  104423:	39 45 08             	cmp    %eax,0x8(%ebp)
  104426:	76 0a                	jbe    104432 <default_alloc_pages+0x44>
        return NULL;
  104428:	b8 00 00 00 00       	mov    $0x0,%eax
  10442d:	e9 49 01 00 00       	jmp    10457b <default_alloc_pages+0x18d>
    }
    struct Page *page=NULL;
  104432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  104439:	c7 45 f0 20 df 11 00 	movl   $0x11df20,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104440:	eb 1c                	jmp    10445e <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  104442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104445:	83 e8 0c             	sub    $0xc,%eax
  104448:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  10444b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10444e:	8b 40 08             	mov    0x8(%eax),%eax
  104451:	39 45 08             	cmp    %eax,0x8(%ebp)
  104454:	77 08                	ja     10445e <default_alloc_pages+0x70>
	   page=p;
  104456:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104459:	89 45 f4             	mov    %eax,-0xc(%ebp)
	   break;
  10445c:	eb 18                	jmp    104476 <default_alloc_pages+0x88>
  10445e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104461:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  104464:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104467:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  10446a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10446d:	81 7d f0 20 df 11 00 	cmpl   $0x11df20,-0x10(%ebp)
  104474:	75 cc                	jne    104442 <default_alloc_pages+0x54>
        }
    }
    if(page!=NULL){
  104476:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10447a:	0f 84 f8 00 00 00    	je     104578 <default_alloc_pages+0x18a>
	if(page->property>n){
  104480:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104483:	8b 40 08             	mov    0x8(%eax),%eax
  104486:	39 45 08             	cmp    %eax,0x8(%ebp)
  104489:	0f 83 98 00 00 00    	jae    104527 <default_alloc_pages+0x139>
	   struct Page*p=page+n;
  10448f:	8b 55 08             	mov    0x8(%ebp),%edx
  104492:	89 d0                	mov    %edx,%eax
  104494:	c1 e0 02             	shl    $0x2,%eax
  104497:	01 d0                	add    %edx,%eax
  104499:	c1 e0 02             	shl    $0x2,%eax
  10449c:	89 c2                	mov    %eax,%edx
  10449e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044a1:	01 d0                	add    %edx,%eax
  1044a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
	   p->property=page->property-n;
  1044a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044a9:	8b 40 08             	mov    0x8(%eax),%eax
  1044ac:	2b 45 08             	sub    0x8(%ebp),%eax
  1044af:	89 c2                	mov    %eax,%edx
  1044b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044b4:	89 50 08             	mov    %edx,0x8(%eax)
	   SetPageProperty(p);
  1044b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044ba:	83 c0 04             	add    $0x4,%eax
  1044bd:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  1044c4:	89 45 c0             	mov    %eax,-0x40(%ebp)
  1044c7:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1044ca:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1044cd:	0f ab 10             	bts    %edx,(%eax)
	   list_add(&(page->page_link),&(p->page_link));
  1044d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044d3:	83 c0 0c             	add    $0xc,%eax
  1044d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1044d9:	83 c2 0c             	add    $0xc,%edx
  1044dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  1044df:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1044e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1044e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1044e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1044eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
  1044ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1044f1:	8b 40 04             	mov    0x4(%eax),%eax
  1044f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1044f7:	89 55 d0             	mov    %edx,-0x30(%ebp)
  1044fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1044fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  104500:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
  104503:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104506:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104509:	89 10                	mov    %edx,(%eax)
  10450b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10450e:	8b 10                	mov    (%eax),%edx
  104510:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104513:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104516:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104519:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10451c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10451f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104522:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104525:	89 10                	mov    %edx,(%eax)
	}
	
	list_del(&(page->page_link));
  104527:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10452a:	83 c0 0c             	add    $0xc,%eax
  10452d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
  104530:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104533:	8b 40 04             	mov    0x4(%eax),%eax
  104536:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104539:	8b 12                	mov    (%edx),%edx
  10453b:	89 55 b0             	mov    %edx,-0x50(%ebp)
  10453e:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  104541:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104544:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104547:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  10454a:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10454d:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104550:	89 10                	mov    %edx,(%eax)
	nr_free-=n;
  104552:	a1 28 df 11 00       	mov    0x11df28,%eax
  104557:	2b 45 08             	sub    0x8(%ebp),%eax
  10455a:	a3 28 df 11 00       	mov    %eax,0x11df28
	ClearPageProperty(page);
  10455f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104562:	83 c0 04             	add    $0x4,%eax
  104565:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  10456c:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10456f:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104572:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104575:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  104578:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10457b:	c9                   	leave  
  10457c:	c3                   	ret    

0010457d <default_free_pages>:
 *  (5.3)
 *      Try to merge blocks at lower or higher addresses. Notice: This should
 *  change some pages' `p->property` correctly.
 */
static void
default_free_pages(struct Page *base, size_t n) {
  10457d:	55                   	push   %ebp
  10457e:	89 e5                	mov    %esp,%ebp
  104580:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  104586:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10458a:	75 24                	jne    1045b0 <default_free_pages+0x33>
  10458c:	c7 44 24 0c 18 7c 10 	movl   $0x107c18,0xc(%esp)
  104593:	00 
  104594:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  10459b:	00 
  10459c:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  1045a3:	00 
  1045a4:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  1045ab:	e8 39 be ff ff       	call   1003e9 <__panic>
    struct Page *p = base;
  1045b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1045b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1045b6:	e9 9d 00 00 00       	jmp    104658 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  1045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045be:	83 c0 04             	add    $0x4,%eax
  1045c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1045c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1045cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1045ce:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1045d1:	0f a3 10             	bt     %edx,(%eax)
  1045d4:	19 c0                	sbb    %eax,%eax
  1045d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  1045d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1045dd:	0f 95 c0             	setne  %al
  1045e0:	0f b6 c0             	movzbl %al,%eax
  1045e3:	85 c0                	test   %eax,%eax
  1045e5:	75 2c                	jne    104613 <default_free_pages+0x96>
  1045e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045ea:	83 c0 04             	add    $0x4,%eax
  1045ed:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  1045f4:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1045f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1045fa:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1045fd:	0f a3 10             	bt     %edx,(%eax)
  104600:	19 c0                	sbb    %eax,%eax
  104602:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  104605:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  104609:	0f 95 c0             	setne  %al
  10460c:	0f b6 c0             	movzbl %al,%eax
  10460f:	85 c0                	test   %eax,%eax
  104611:	74 24                	je     104637 <default_free_pages+0xba>
  104613:	c7 44 24 0c 5c 7c 10 	movl   $0x107c5c,0xc(%esp)
  10461a:	00 
  10461b:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104622:	00 
  104623:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  10462a:	00 
  10462b:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104632:	e8 b2 bd ff ff       	call   1003e9 <__panic>
        p->flags = 0;
  104637:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10463a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  104641:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104648:	00 
  104649:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10464c:	89 04 24             	mov    %eax,(%esp)
  10464f:	e8 0f fc ff ff       	call   104263 <set_page_ref>
    for (; p != base + n; p ++) {
  104654:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104658:	8b 55 0c             	mov    0xc(%ebp),%edx
  10465b:	89 d0                	mov    %edx,%eax
  10465d:	c1 e0 02             	shl    $0x2,%eax
  104660:	01 d0                	add    %edx,%eax
  104662:	c1 e0 02             	shl    $0x2,%eax
  104665:	89 c2                	mov    %eax,%edx
  104667:	8b 45 08             	mov    0x8(%ebp),%eax
  10466a:	01 d0                	add    %edx,%eax
  10466c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10466f:	0f 85 46 ff ff ff    	jne    1045bb <default_free_pages+0x3e>
    }
    base->property = n;
  104675:	8b 45 08             	mov    0x8(%ebp),%eax
  104678:	8b 55 0c             	mov    0xc(%ebp),%edx
  10467b:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  10467e:	8b 45 08             	mov    0x8(%ebp),%eax
  104681:	83 c0 04             	add    $0x4,%eax
  104684:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  10468b:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10468e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104691:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104694:	0f ab 10             	bts    %edx,(%eax)
  104697:	c7 45 d4 20 df 11 00 	movl   $0x11df20,-0x2c(%ebp)
    return listelm->next;
  10469e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1046a1:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  1046a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  1046a7:	e9 08 01 00 00       	jmp    1047b4 <default_free_pages+0x237>
        p = le2page(le, page_link);
  1046ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046af:	83 e8 0c             	sub    $0xc,%eax
  1046b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1046b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046b8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1046bb:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1046be:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  1046c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  1046c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1046c7:	8b 50 08             	mov    0x8(%eax),%edx
  1046ca:	89 d0                	mov    %edx,%eax
  1046cc:	c1 e0 02             	shl    $0x2,%eax
  1046cf:	01 d0                	add    %edx,%eax
  1046d1:	c1 e0 02             	shl    $0x2,%eax
  1046d4:	89 c2                	mov    %eax,%edx
  1046d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1046d9:	01 d0                	add    %edx,%eax
  1046db:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1046de:	75 5a                	jne    10473a <default_free_pages+0x1bd>
            base->property += p->property;
  1046e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1046e3:	8b 50 08             	mov    0x8(%eax),%edx
  1046e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046e9:	8b 40 08             	mov    0x8(%eax),%eax
  1046ec:	01 c2                	add    %eax,%edx
  1046ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1046f1:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  1046f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046f7:	83 c0 04             	add    $0x4,%eax
  1046fa:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  104701:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104704:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104707:	8b 55 b8             	mov    -0x48(%ebp),%edx
  10470a:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  10470d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104710:	83 c0 0c             	add    $0xc,%eax
  104713:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  104716:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104719:	8b 40 04             	mov    0x4(%eax),%eax
  10471c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  10471f:	8b 12                	mov    (%edx),%edx
  104721:	89 55 c0             	mov    %edx,-0x40(%ebp)
  104724:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  104727:	8b 45 c0             	mov    -0x40(%ebp),%eax
  10472a:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10472d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104730:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104733:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104736:	89 10                	mov    %edx,(%eax)
  104738:	eb 7a                	jmp    1047b4 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  10473a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10473d:	8b 50 08             	mov    0x8(%eax),%edx
  104740:	89 d0                	mov    %edx,%eax
  104742:	c1 e0 02             	shl    $0x2,%eax
  104745:	01 d0                	add    %edx,%eax
  104747:	c1 e0 02             	shl    $0x2,%eax
  10474a:	89 c2                	mov    %eax,%edx
  10474c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10474f:	01 d0                	add    %edx,%eax
  104751:	39 45 08             	cmp    %eax,0x8(%ebp)
  104754:	75 5e                	jne    1047b4 <default_free_pages+0x237>
            p->property += base->property;
  104756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104759:	8b 50 08             	mov    0x8(%eax),%edx
  10475c:	8b 45 08             	mov    0x8(%ebp),%eax
  10475f:	8b 40 08             	mov    0x8(%eax),%eax
  104762:	01 c2                	add    %eax,%edx
  104764:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104767:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  10476a:	8b 45 08             	mov    0x8(%ebp),%eax
  10476d:	83 c0 04             	add    $0x4,%eax
  104770:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  104777:	89 45 a0             	mov    %eax,-0x60(%ebp)
  10477a:	8b 45 a0             	mov    -0x60(%ebp),%eax
  10477d:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  104780:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  104783:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104786:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  104789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10478c:	83 c0 0c             	add    $0xc,%eax
  10478f:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  104792:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104795:	8b 40 04             	mov    0x4(%eax),%eax
  104798:	8b 55 b0             	mov    -0x50(%ebp),%edx
  10479b:	8b 12                	mov    (%edx),%edx
  10479d:	89 55 ac             	mov    %edx,-0x54(%ebp)
  1047a0:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  1047a3:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1047a6:	8b 55 a8             	mov    -0x58(%ebp),%edx
  1047a9:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1047ac:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1047af:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1047b2:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
  1047b4:	81 7d f0 20 df 11 00 	cmpl   $0x11df20,-0x10(%ebp)
  1047bb:	0f 85 eb fe ff ff    	jne    1046ac <default_free_pages+0x12f>
        }
    }
    SetPageProperty(base);
  1047c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1047c4:	83 c0 04             	add    $0x4,%eax
  1047c7:	c7 45 98 01 00 00 00 	movl   $0x1,-0x68(%ebp)
  1047ce:	89 45 94             	mov    %eax,-0x6c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1047d1:	8b 45 94             	mov    -0x6c(%ebp),%eax
  1047d4:	8b 55 98             	mov    -0x68(%ebp),%edx
  1047d7:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  1047da:	8b 15 28 df 11 00    	mov    0x11df28,%edx
  1047e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047e3:	01 d0                	add    %edx,%eax
  1047e5:	a3 28 df 11 00       	mov    %eax,0x11df28
  1047ea:	c7 45 9c 20 df 11 00 	movl   $0x11df20,-0x64(%ebp)
    return listelm->next;
  1047f1:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1047f4:	8b 40 04             	mov    0x4(%eax),%eax
    le=list_next(&free_list);
  1047f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
  1047fa:	eb 0f                	jmp    10480b <default_free_pages+0x28e>
  1047fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1047ff:	89 45 90             	mov    %eax,-0x70(%ebp)
  104802:	8b 45 90             	mov    -0x70(%ebp),%eax
  104805:	8b 40 04             	mov    0x4(%eax),%eax
	le=list_next(le);
  104808:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
  10480b:	81 7d f0 20 df 11 00 	cmpl   $0x11df20,-0x10(%ebp)
  104812:	74 0b                	je     10481f <default_free_pages+0x2a2>
  104814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104817:	83 e8 0c             	sub    $0xc,%eax
  10481a:	39 45 08             	cmp    %eax,0x8(%ebp)
  10481d:	77 dd                	ja     1047fc <default_free_pages+0x27f>
    }
    list_add_before(le, &(base->page_link));
  10481f:	8b 45 08             	mov    0x8(%ebp),%eax
  104822:	8d 50 0c             	lea    0xc(%eax),%edx
  104825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104828:	89 45 8c             	mov    %eax,-0x74(%ebp)
  10482b:	89 55 88             	mov    %edx,-0x78(%ebp)
    __list_add(elm, listelm->prev, listelm);
  10482e:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104831:	8b 00                	mov    (%eax),%eax
  104833:	8b 55 88             	mov    -0x78(%ebp),%edx
  104836:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104839:	89 45 80             	mov    %eax,-0x80(%ebp)
  10483c:	8b 45 8c             	mov    -0x74(%ebp),%eax
  10483f:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
    prev->next = next->prev = elm;
  104845:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  10484b:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10484e:	89 10                	mov    %edx,(%eax)
  104850:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  104856:	8b 10                	mov    (%eax),%edx
  104858:	8b 45 80             	mov    -0x80(%ebp),%eax
  10485b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10485e:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104861:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  104867:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10486a:	8b 45 84             	mov    -0x7c(%ebp),%eax
  10486d:	8b 55 80             	mov    -0x80(%ebp),%edx
  104870:	89 10                	mov    %edx,(%eax)
}
  104872:	90                   	nop
  104873:	c9                   	leave  
  104874:	c3                   	ret    

00104875 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  104875:	55                   	push   %ebp
  104876:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104878:	a1 28 df 11 00       	mov    0x11df28,%eax
}
  10487d:	5d                   	pop    %ebp
  10487e:	c3                   	ret    

0010487f <basic_check>:

static void
basic_check(void) {
  10487f:	55                   	push   %ebp
  104880:	89 e5                	mov    %esp,%ebp
  104882:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  104885:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10488c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10488f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104892:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104895:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  104898:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10489f:	e8 d8 e2 ff ff       	call   102b7c <alloc_pages>
  1048a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1048a7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1048ab:	75 24                	jne    1048d1 <basic_check+0x52>
  1048ad:	c7 44 24 0c 81 7c 10 	movl   $0x107c81,0xc(%esp)
  1048b4:	00 
  1048b5:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  1048bc:	00 
  1048bd:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
  1048c4:	00 
  1048c5:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  1048cc:	e8 18 bb ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  1048d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1048d8:	e8 9f e2 ff ff       	call   102b7c <alloc_pages>
  1048dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1048e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1048e4:	75 24                	jne    10490a <basic_check+0x8b>
  1048e6:	c7 44 24 0c 9d 7c 10 	movl   $0x107c9d,0xc(%esp)
  1048ed:	00 
  1048ee:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  1048f5:	00 
  1048f6:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
  1048fd:	00 
  1048fe:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104905:	e8 df ba ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  10490a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104911:	e8 66 e2 ff ff       	call   102b7c <alloc_pages>
  104916:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104919:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10491d:	75 24                	jne    104943 <basic_check+0xc4>
  10491f:	c7 44 24 0c b9 7c 10 	movl   $0x107cb9,0xc(%esp)
  104926:	00 
  104927:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  10492e:	00 
  10492f:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  104936:	00 
  104937:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  10493e:	e8 a6 ba ff ff       	call   1003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104943:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104946:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104949:	74 10                	je     10495b <basic_check+0xdc>
  10494b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10494e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104951:	74 08                	je     10495b <basic_check+0xdc>
  104953:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104956:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104959:	75 24                	jne    10497f <basic_check+0x100>
  10495b:	c7 44 24 0c d8 7c 10 	movl   $0x107cd8,0xc(%esp)
  104962:	00 
  104963:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  10496a:	00 
  10496b:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
  104972:	00 
  104973:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  10497a:	e8 6a ba ff ff       	call   1003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  10497f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104982:	89 04 24             	mov    %eax,(%esp)
  104985:	e8 cf f8 ff ff       	call   104259 <page_ref>
  10498a:	85 c0                	test   %eax,%eax
  10498c:	75 1e                	jne    1049ac <basic_check+0x12d>
  10498e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104991:	89 04 24             	mov    %eax,(%esp)
  104994:	e8 c0 f8 ff ff       	call   104259 <page_ref>
  104999:	85 c0                	test   %eax,%eax
  10499b:	75 0f                	jne    1049ac <basic_check+0x12d>
  10499d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049a0:	89 04 24             	mov    %eax,(%esp)
  1049a3:	e8 b1 f8 ff ff       	call   104259 <page_ref>
  1049a8:	85 c0                	test   %eax,%eax
  1049aa:	74 24                	je     1049d0 <basic_check+0x151>
  1049ac:	c7 44 24 0c fc 7c 10 	movl   $0x107cfc,0xc(%esp)
  1049b3:	00 
  1049b4:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  1049bb:	00 
  1049bc:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
  1049c3:	00 
  1049c4:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  1049cb:	e8 19 ba ff ff       	call   1003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  1049d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049d3:	89 04 24             	mov    %eax,(%esp)
  1049d6:	e8 68 f8 ff ff       	call   104243 <page2pa>
  1049db:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  1049e1:	c1 e2 0c             	shl    $0xc,%edx
  1049e4:	39 d0                	cmp    %edx,%eax
  1049e6:	72 24                	jb     104a0c <basic_check+0x18d>
  1049e8:	c7 44 24 0c 38 7d 10 	movl   $0x107d38,0xc(%esp)
  1049ef:	00 
  1049f0:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  1049f7:	00 
  1049f8:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  1049ff:	00 
  104a00:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104a07:	e8 dd b9 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  104a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a0f:	89 04 24             	mov    %eax,(%esp)
  104a12:	e8 2c f8 ff ff       	call   104243 <page2pa>
  104a17:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  104a1d:	c1 e2 0c             	shl    $0xc,%edx
  104a20:	39 d0                	cmp    %edx,%eax
  104a22:	72 24                	jb     104a48 <basic_check+0x1c9>
  104a24:	c7 44 24 0c 55 7d 10 	movl   $0x107d55,0xc(%esp)
  104a2b:	00 
  104a2c:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104a33:	00 
  104a34:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
  104a3b:	00 
  104a3c:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104a43:	e8 a1 b9 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a4b:	89 04 24             	mov    %eax,(%esp)
  104a4e:	e8 f0 f7 ff ff       	call   104243 <page2pa>
  104a53:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  104a59:	c1 e2 0c             	shl    $0xc,%edx
  104a5c:	39 d0                	cmp    %edx,%eax
  104a5e:	72 24                	jb     104a84 <basic_check+0x205>
  104a60:	c7 44 24 0c 72 7d 10 	movl   $0x107d72,0xc(%esp)
  104a67:	00 
  104a68:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104a6f:	00 
  104a70:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  104a77:	00 
  104a78:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104a7f:	e8 65 b9 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104a84:	a1 20 df 11 00       	mov    0x11df20,%eax
  104a89:	8b 15 24 df 11 00    	mov    0x11df24,%edx
  104a8f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104a92:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104a95:	c7 45 dc 20 df 11 00 	movl   $0x11df20,-0x24(%ebp)
    elm->prev = elm->next = elm;
  104a9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104a9f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104aa2:	89 50 04             	mov    %edx,0x4(%eax)
  104aa5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104aa8:	8b 50 04             	mov    0x4(%eax),%edx
  104aab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104aae:	89 10                	mov    %edx,(%eax)
  104ab0:	c7 45 e0 20 df 11 00 	movl   $0x11df20,-0x20(%ebp)
    return list->next == list;
  104ab7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104aba:	8b 40 04             	mov    0x4(%eax),%eax
  104abd:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104ac0:	0f 94 c0             	sete   %al
  104ac3:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104ac6:	85 c0                	test   %eax,%eax
  104ac8:	75 24                	jne    104aee <basic_check+0x26f>
  104aca:	c7 44 24 0c 8f 7d 10 	movl   $0x107d8f,0xc(%esp)
  104ad1:	00 
  104ad2:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104ad9:	00 
  104ada:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  104ae1:	00 
  104ae2:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104ae9:	e8 fb b8 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104aee:	a1 28 df 11 00       	mov    0x11df28,%eax
  104af3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104af6:	c7 05 28 df 11 00 00 	movl   $0x0,0x11df28
  104afd:	00 00 00 

    assert(alloc_page() == NULL);
  104b00:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b07:	e8 70 e0 ff ff       	call   102b7c <alloc_pages>
  104b0c:	85 c0                	test   %eax,%eax
  104b0e:	74 24                	je     104b34 <basic_check+0x2b5>
  104b10:	c7 44 24 0c a6 7d 10 	movl   $0x107da6,0xc(%esp)
  104b17:	00 
  104b18:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104b1f:	00 
  104b20:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  104b27:	00 
  104b28:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104b2f:	e8 b5 b8 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104b34:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b3b:	00 
  104b3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b3f:	89 04 24             	mov    %eax,(%esp)
  104b42:	e8 6d e0 ff ff       	call   102bb4 <free_pages>
    free_page(p1);
  104b47:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b4e:	00 
  104b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b52:	89 04 24             	mov    %eax,(%esp)
  104b55:	e8 5a e0 ff ff       	call   102bb4 <free_pages>
    free_page(p2);
  104b5a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b61:	00 
  104b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b65:	89 04 24             	mov    %eax,(%esp)
  104b68:	e8 47 e0 ff ff       	call   102bb4 <free_pages>
    assert(nr_free == 3);
  104b6d:	a1 28 df 11 00       	mov    0x11df28,%eax
  104b72:	83 f8 03             	cmp    $0x3,%eax
  104b75:	74 24                	je     104b9b <basic_check+0x31c>
  104b77:	c7 44 24 0c bb 7d 10 	movl   $0x107dbb,0xc(%esp)
  104b7e:	00 
  104b7f:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104b86:	00 
  104b87:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  104b8e:	00 
  104b8f:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104b96:	e8 4e b8 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  104b9b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ba2:	e8 d5 df ff ff       	call   102b7c <alloc_pages>
  104ba7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104baa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104bae:	75 24                	jne    104bd4 <basic_check+0x355>
  104bb0:	c7 44 24 0c 81 7c 10 	movl   $0x107c81,0xc(%esp)
  104bb7:	00 
  104bb8:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104bbf:	00 
  104bc0:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  104bc7:	00 
  104bc8:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104bcf:	e8 15 b8 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104bd4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104bdb:	e8 9c df ff ff       	call   102b7c <alloc_pages>
  104be0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104be3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104be7:	75 24                	jne    104c0d <basic_check+0x38e>
  104be9:	c7 44 24 0c 9d 7c 10 	movl   $0x107c9d,0xc(%esp)
  104bf0:	00 
  104bf1:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104bf8:	00 
  104bf9:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  104c00:	00 
  104c01:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104c08:	e8 dc b7 ff ff       	call   1003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104c0d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c14:	e8 63 df ff ff       	call   102b7c <alloc_pages>
  104c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104c1c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104c20:	75 24                	jne    104c46 <basic_check+0x3c7>
  104c22:	c7 44 24 0c b9 7c 10 	movl   $0x107cb9,0xc(%esp)
  104c29:	00 
  104c2a:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104c31:	00 
  104c32:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  104c39:	00 
  104c3a:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104c41:	e8 a3 b7 ff ff       	call   1003e9 <__panic>

    assert(alloc_page() == NULL);
  104c46:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c4d:	e8 2a df ff ff       	call   102b7c <alloc_pages>
  104c52:	85 c0                	test   %eax,%eax
  104c54:	74 24                	je     104c7a <basic_check+0x3fb>
  104c56:	c7 44 24 0c a6 7d 10 	movl   $0x107da6,0xc(%esp)
  104c5d:	00 
  104c5e:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104c65:	00 
  104c66:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  104c6d:	00 
  104c6e:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104c75:	e8 6f b7 ff ff       	call   1003e9 <__panic>

    free_page(p0);
  104c7a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104c81:	00 
  104c82:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c85:	89 04 24             	mov    %eax,(%esp)
  104c88:	e8 27 df ff ff       	call   102bb4 <free_pages>
  104c8d:	c7 45 d8 20 df 11 00 	movl   $0x11df20,-0x28(%ebp)
  104c94:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104c97:	8b 40 04             	mov    0x4(%eax),%eax
  104c9a:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104c9d:	0f 94 c0             	sete   %al
  104ca0:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104ca3:	85 c0                	test   %eax,%eax
  104ca5:	74 24                	je     104ccb <basic_check+0x44c>
  104ca7:	c7 44 24 0c c8 7d 10 	movl   $0x107dc8,0xc(%esp)
  104cae:	00 
  104caf:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104cb6:	00 
  104cb7:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  104cbe:	00 
  104cbf:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104cc6:	e8 1e b7 ff ff       	call   1003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104ccb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104cd2:	e8 a5 de ff ff       	call   102b7c <alloc_pages>
  104cd7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104cda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104cdd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104ce0:	74 24                	je     104d06 <basic_check+0x487>
  104ce2:	c7 44 24 0c e0 7d 10 	movl   $0x107de0,0xc(%esp)
  104ce9:	00 
  104cea:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104cf1:	00 
  104cf2:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  104cf9:	00 
  104cfa:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104d01:	e8 e3 b6 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104d06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104d0d:	e8 6a de ff ff       	call   102b7c <alloc_pages>
  104d12:	85 c0                	test   %eax,%eax
  104d14:	74 24                	je     104d3a <basic_check+0x4bb>
  104d16:	c7 44 24 0c a6 7d 10 	movl   $0x107da6,0xc(%esp)
  104d1d:	00 
  104d1e:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104d25:	00 
  104d26:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  104d2d:	00 
  104d2e:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104d35:	e8 af b6 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  104d3a:	a1 28 df 11 00       	mov    0x11df28,%eax
  104d3f:	85 c0                	test   %eax,%eax
  104d41:	74 24                	je     104d67 <basic_check+0x4e8>
  104d43:	c7 44 24 0c f9 7d 10 	movl   $0x107df9,0xc(%esp)
  104d4a:	00 
  104d4b:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104d52:	00 
  104d53:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  104d5a:	00 
  104d5b:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104d62:	e8 82 b6 ff ff       	call   1003e9 <__panic>
    free_list = free_list_store;
  104d67:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104d6a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104d6d:	a3 20 df 11 00       	mov    %eax,0x11df20
  104d72:	89 15 24 df 11 00    	mov    %edx,0x11df24
    nr_free = nr_free_store;
  104d78:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104d7b:	a3 28 df 11 00       	mov    %eax,0x11df28

    free_page(p);
  104d80:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d87:	00 
  104d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d8b:	89 04 24             	mov    %eax,(%esp)
  104d8e:	e8 21 de ff ff       	call   102bb4 <free_pages>
    free_page(p1);
  104d93:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d9a:	00 
  104d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d9e:	89 04 24             	mov    %eax,(%esp)
  104da1:	e8 0e de ff ff       	call   102bb4 <free_pages>
    free_page(p2);
  104da6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104dad:	00 
  104dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104db1:	89 04 24             	mov    %eax,(%esp)
  104db4:	e8 fb dd ff ff       	call   102bb4 <free_pages>
}
  104db9:	90                   	nop
  104dba:	c9                   	leave  
  104dbb:	c3                   	ret    

00104dbc <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104dbc:	55                   	push   %ebp
  104dbd:	89 e5                	mov    %esp,%ebp
  104dbf:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  104dc5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104dcc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104dd3:	c7 45 ec 20 df 11 00 	movl   $0x11df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104dda:	eb 6a                	jmp    104e46 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  104ddc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104ddf:	83 e8 0c             	sub    $0xc,%eax
  104de2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  104de5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104de8:	83 c0 04             	add    $0x4,%eax
  104deb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104df2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104df5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104df8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104dfb:	0f a3 10             	bt     %edx,(%eax)
  104dfe:	19 c0                	sbb    %eax,%eax
  104e00:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104e03:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  104e07:	0f 95 c0             	setne  %al
  104e0a:	0f b6 c0             	movzbl %al,%eax
  104e0d:	85 c0                	test   %eax,%eax
  104e0f:	75 24                	jne    104e35 <default_check+0x79>
  104e11:	c7 44 24 0c 06 7e 10 	movl   $0x107e06,0xc(%esp)
  104e18:	00 
  104e19:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104e20:	00 
  104e21:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  104e28:	00 
  104e29:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104e30:	e8 b4 b5 ff ff       	call   1003e9 <__panic>
        count ++, total += p->property;
  104e35:	ff 45 f4             	incl   -0xc(%ebp)
  104e38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104e3b:	8b 50 08             	mov    0x8(%eax),%edx
  104e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e41:	01 d0                	add    %edx,%eax
  104e43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104e46:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e49:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  104e4c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104e4f:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104e52:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104e55:	81 7d ec 20 df 11 00 	cmpl   $0x11df20,-0x14(%ebp)
  104e5c:	0f 85 7a ff ff ff    	jne    104ddc <default_check+0x20>
    }
    assert(total == nr_free_pages());
  104e62:	e8 80 dd ff ff       	call   102be7 <nr_free_pages>
  104e67:	89 c2                	mov    %eax,%edx
  104e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e6c:	39 c2                	cmp    %eax,%edx
  104e6e:	74 24                	je     104e94 <default_check+0xd8>
  104e70:	c7 44 24 0c 16 7e 10 	movl   $0x107e16,0xc(%esp)
  104e77:	00 
  104e78:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104e7f:	00 
  104e80:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  104e87:	00 
  104e88:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104e8f:	e8 55 b5 ff ff       	call   1003e9 <__panic>

    basic_check();
  104e94:	e8 e6 f9 ff ff       	call   10487f <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104e99:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104ea0:	e8 d7 dc ff ff       	call   102b7c <alloc_pages>
  104ea5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  104ea8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104eac:	75 24                	jne    104ed2 <default_check+0x116>
  104eae:	c7 44 24 0c 2f 7e 10 	movl   $0x107e2f,0xc(%esp)
  104eb5:	00 
  104eb6:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104ebd:	00 
  104ebe:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
  104ec5:	00 
  104ec6:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104ecd:	e8 17 b5 ff ff       	call   1003e9 <__panic>
    assert(!PageProperty(p0));
  104ed2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104ed5:	83 c0 04             	add    $0x4,%eax
  104ed8:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104edf:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104ee2:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104ee5:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104ee8:	0f a3 10             	bt     %edx,(%eax)
  104eeb:	19 c0                	sbb    %eax,%eax
  104eed:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104ef0:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  104ef4:	0f 95 c0             	setne  %al
  104ef7:	0f b6 c0             	movzbl %al,%eax
  104efa:	85 c0                	test   %eax,%eax
  104efc:	74 24                	je     104f22 <default_check+0x166>
  104efe:	c7 44 24 0c 3a 7e 10 	movl   $0x107e3a,0xc(%esp)
  104f05:	00 
  104f06:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104f0d:	00 
  104f0e:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  104f15:	00 
  104f16:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104f1d:	e8 c7 b4 ff ff       	call   1003e9 <__panic>

    list_entry_t free_list_store = free_list;
  104f22:	a1 20 df 11 00       	mov    0x11df20,%eax
  104f27:	8b 15 24 df 11 00    	mov    0x11df24,%edx
  104f2d:	89 45 80             	mov    %eax,-0x80(%ebp)
  104f30:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104f33:	c7 45 b0 20 df 11 00 	movl   $0x11df20,-0x50(%ebp)
    elm->prev = elm->next = elm;
  104f3a:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104f3d:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104f40:	89 50 04             	mov    %edx,0x4(%eax)
  104f43:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104f46:	8b 50 04             	mov    0x4(%eax),%edx
  104f49:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104f4c:	89 10                	mov    %edx,(%eax)
  104f4e:	c7 45 b4 20 df 11 00 	movl   $0x11df20,-0x4c(%ebp)
    return list->next == list;
  104f55:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104f58:	8b 40 04             	mov    0x4(%eax),%eax
  104f5b:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  104f5e:	0f 94 c0             	sete   %al
  104f61:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104f64:	85 c0                	test   %eax,%eax
  104f66:	75 24                	jne    104f8c <default_check+0x1d0>
  104f68:	c7 44 24 0c 8f 7d 10 	movl   $0x107d8f,0xc(%esp)
  104f6f:	00 
  104f70:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104f77:	00 
  104f78:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
  104f7f:	00 
  104f80:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104f87:	e8 5d b4 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  104f8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104f93:	e8 e4 db ff ff       	call   102b7c <alloc_pages>
  104f98:	85 c0                	test   %eax,%eax
  104f9a:	74 24                	je     104fc0 <default_check+0x204>
  104f9c:	c7 44 24 0c a6 7d 10 	movl   $0x107da6,0xc(%esp)
  104fa3:	00 
  104fa4:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  104fab:	00 
  104fac:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
  104fb3:	00 
  104fb4:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  104fbb:	e8 29 b4 ff ff       	call   1003e9 <__panic>

    unsigned int nr_free_store = nr_free;
  104fc0:	a1 28 df 11 00       	mov    0x11df28,%eax
  104fc5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  104fc8:	c7 05 28 df 11 00 00 	movl   $0x0,0x11df28
  104fcf:	00 00 00 

    free_pages(p0 + 2, 3);
  104fd2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104fd5:	83 c0 28             	add    $0x28,%eax
  104fd8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104fdf:	00 
  104fe0:	89 04 24             	mov    %eax,(%esp)
  104fe3:	e8 cc db ff ff       	call   102bb4 <free_pages>
    assert(alloc_pages(4) == NULL);
  104fe8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  104fef:	e8 88 db ff ff       	call   102b7c <alloc_pages>
  104ff4:	85 c0                	test   %eax,%eax
  104ff6:	74 24                	je     10501c <default_check+0x260>
  104ff8:	c7 44 24 0c 4c 7e 10 	movl   $0x107e4c,0xc(%esp)
  104fff:	00 
  105000:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  105007:	00 
  105008:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  10500f:	00 
  105010:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  105017:	e8 cd b3 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  10501c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10501f:	83 c0 28             	add    $0x28,%eax
  105022:	83 c0 04             	add    $0x4,%eax
  105025:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  10502c:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10502f:	8b 45 a8             	mov    -0x58(%ebp),%eax
  105032:	8b 55 ac             	mov    -0x54(%ebp),%edx
  105035:	0f a3 10             	bt     %edx,(%eax)
  105038:	19 c0                	sbb    %eax,%eax
  10503a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  10503d:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  105041:	0f 95 c0             	setne  %al
  105044:	0f b6 c0             	movzbl %al,%eax
  105047:	85 c0                	test   %eax,%eax
  105049:	74 0e                	je     105059 <default_check+0x29d>
  10504b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10504e:	83 c0 28             	add    $0x28,%eax
  105051:	8b 40 08             	mov    0x8(%eax),%eax
  105054:	83 f8 03             	cmp    $0x3,%eax
  105057:	74 24                	je     10507d <default_check+0x2c1>
  105059:	c7 44 24 0c 64 7e 10 	movl   $0x107e64,0xc(%esp)
  105060:	00 
  105061:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  105068:	00 
  105069:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
  105070:	00 
  105071:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  105078:	e8 6c b3 ff ff       	call   1003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  10507d:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  105084:	e8 f3 da ff ff       	call   102b7c <alloc_pages>
  105089:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10508c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  105090:	75 24                	jne    1050b6 <default_check+0x2fa>
  105092:	c7 44 24 0c 90 7e 10 	movl   $0x107e90,0xc(%esp)
  105099:	00 
  10509a:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  1050a1:	00 
  1050a2:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  1050a9:	00 
  1050aa:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  1050b1:	e8 33 b3 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  1050b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1050bd:	e8 ba da ff ff       	call   102b7c <alloc_pages>
  1050c2:	85 c0                	test   %eax,%eax
  1050c4:	74 24                	je     1050ea <default_check+0x32e>
  1050c6:	c7 44 24 0c a6 7d 10 	movl   $0x107da6,0xc(%esp)
  1050cd:	00 
  1050ce:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  1050d5:	00 
  1050d6:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
  1050dd:	00 
  1050de:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  1050e5:	e8 ff b2 ff ff       	call   1003e9 <__panic>
    assert(p0 + 2 == p1);
  1050ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1050ed:	83 c0 28             	add    $0x28,%eax
  1050f0:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  1050f3:	74 24                	je     105119 <default_check+0x35d>
  1050f5:	c7 44 24 0c ae 7e 10 	movl   $0x107eae,0xc(%esp)
  1050fc:	00 
  1050fd:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  105104:	00 
  105105:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
  10510c:	00 
  10510d:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  105114:	e8 d0 b2 ff ff       	call   1003e9 <__panic>

    p2 = p0 + 1;
  105119:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10511c:	83 c0 14             	add    $0x14,%eax
  10511f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  105122:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105129:	00 
  10512a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10512d:	89 04 24             	mov    %eax,(%esp)
  105130:	e8 7f da ff ff       	call   102bb4 <free_pages>
    free_pages(p1, 3);
  105135:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10513c:	00 
  10513d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105140:	89 04 24             	mov    %eax,(%esp)
  105143:	e8 6c da ff ff       	call   102bb4 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  105148:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10514b:	83 c0 04             	add    $0x4,%eax
  10514e:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  105155:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105158:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10515b:	8b 55 a0             	mov    -0x60(%ebp),%edx
  10515e:	0f a3 10             	bt     %edx,(%eax)
  105161:	19 c0                	sbb    %eax,%eax
  105163:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  105166:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  10516a:	0f 95 c0             	setne  %al
  10516d:	0f b6 c0             	movzbl %al,%eax
  105170:	85 c0                	test   %eax,%eax
  105172:	74 0b                	je     10517f <default_check+0x3c3>
  105174:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105177:	8b 40 08             	mov    0x8(%eax),%eax
  10517a:	83 f8 01             	cmp    $0x1,%eax
  10517d:	74 24                	je     1051a3 <default_check+0x3e7>
  10517f:	c7 44 24 0c bc 7e 10 	movl   $0x107ebc,0xc(%esp)
  105186:	00 
  105187:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  10518e:	00 
  10518f:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
  105196:	00 
  105197:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  10519e:	e8 46 b2 ff ff       	call   1003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  1051a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051a6:	83 c0 04             	add    $0x4,%eax
  1051a9:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  1051b0:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1051b3:	8b 45 90             	mov    -0x70(%ebp),%eax
  1051b6:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1051b9:	0f a3 10             	bt     %edx,(%eax)
  1051bc:	19 c0                	sbb    %eax,%eax
  1051be:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  1051c1:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  1051c5:	0f 95 c0             	setne  %al
  1051c8:	0f b6 c0             	movzbl %al,%eax
  1051cb:	85 c0                	test   %eax,%eax
  1051cd:	74 0b                	je     1051da <default_check+0x41e>
  1051cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051d2:	8b 40 08             	mov    0x8(%eax),%eax
  1051d5:	83 f8 03             	cmp    $0x3,%eax
  1051d8:	74 24                	je     1051fe <default_check+0x442>
  1051da:	c7 44 24 0c e4 7e 10 	movl   $0x107ee4,0xc(%esp)
  1051e1:	00 
  1051e2:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  1051e9:	00 
  1051ea:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
  1051f1:	00 
  1051f2:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  1051f9:	e8 eb b1 ff ff       	call   1003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1051fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105205:	e8 72 d9 ff ff       	call   102b7c <alloc_pages>
  10520a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10520d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105210:	83 e8 14             	sub    $0x14,%eax
  105213:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105216:	74 24                	je     10523c <default_check+0x480>
  105218:	c7 44 24 0c 0a 7f 10 	movl   $0x107f0a,0xc(%esp)
  10521f:	00 
  105220:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  105227:	00 
  105228:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
  10522f:	00 
  105230:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  105237:	e8 ad b1 ff ff       	call   1003e9 <__panic>
    free_page(p0);
  10523c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105243:	00 
  105244:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105247:	89 04 24             	mov    %eax,(%esp)
  10524a:	e8 65 d9 ff ff       	call   102bb4 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  10524f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  105256:	e8 21 d9 ff ff       	call   102b7c <alloc_pages>
  10525b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10525e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105261:	83 c0 14             	add    $0x14,%eax
  105264:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105267:	74 24                	je     10528d <default_check+0x4d1>
  105269:	c7 44 24 0c 28 7f 10 	movl   $0x107f28,0xc(%esp)
  105270:	00 
  105271:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  105278:	00 
  105279:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
  105280:	00 
  105281:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  105288:	e8 5c b1 ff ff       	call   1003e9 <__panic>

    free_pages(p0, 2);
  10528d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  105294:	00 
  105295:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105298:	89 04 24             	mov    %eax,(%esp)
  10529b:	e8 14 d9 ff ff       	call   102bb4 <free_pages>
    free_page(p2);
  1052a0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1052a7:	00 
  1052a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1052ab:	89 04 24             	mov    %eax,(%esp)
  1052ae:	e8 01 d9 ff ff       	call   102bb4 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  1052b3:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1052ba:	e8 bd d8 ff ff       	call   102b7c <alloc_pages>
  1052bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1052c2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1052c6:	75 24                	jne    1052ec <default_check+0x530>
  1052c8:	c7 44 24 0c 48 7f 10 	movl   $0x107f48,0xc(%esp)
  1052cf:	00 
  1052d0:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  1052d7:	00 
  1052d8:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
  1052df:	00 
  1052e0:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  1052e7:	e8 fd b0 ff ff       	call   1003e9 <__panic>
    assert(alloc_page() == NULL);
  1052ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1052f3:	e8 84 d8 ff ff       	call   102b7c <alloc_pages>
  1052f8:	85 c0                	test   %eax,%eax
  1052fa:	74 24                	je     105320 <default_check+0x564>
  1052fc:	c7 44 24 0c a6 7d 10 	movl   $0x107da6,0xc(%esp)
  105303:	00 
  105304:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  10530b:	00 
  10530c:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
  105313:	00 
  105314:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  10531b:	e8 c9 b0 ff ff       	call   1003e9 <__panic>

    assert(nr_free == 0);
  105320:	a1 28 df 11 00       	mov    0x11df28,%eax
  105325:	85 c0                	test   %eax,%eax
  105327:	74 24                	je     10534d <default_check+0x591>
  105329:	c7 44 24 0c f9 7d 10 	movl   $0x107df9,0xc(%esp)
  105330:	00 
  105331:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  105338:	00 
  105339:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
  105340:	00 
  105341:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  105348:	e8 9c b0 ff ff       	call   1003e9 <__panic>
    nr_free = nr_free_store;
  10534d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105350:	a3 28 df 11 00       	mov    %eax,0x11df28

    free_list = free_list_store;
  105355:	8b 45 80             	mov    -0x80(%ebp),%eax
  105358:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10535b:	a3 20 df 11 00       	mov    %eax,0x11df20
  105360:	89 15 24 df 11 00    	mov    %edx,0x11df24
    free_pages(p0, 5);
  105366:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  10536d:	00 
  10536e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105371:	89 04 24             	mov    %eax,(%esp)
  105374:	e8 3b d8 ff ff       	call   102bb4 <free_pages>

    le = &free_list;
  105379:	c7 45 ec 20 df 11 00 	movl   $0x11df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  105380:	eb 5a                	jmp    1053dc <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
  105382:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105385:	8b 40 04             	mov    0x4(%eax),%eax
  105388:	8b 00                	mov    (%eax),%eax
  10538a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  10538d:	75 0d                	jne    10539c <default_check+0x5e0>
  10538f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105392:	8b 00                	mov    (%eax),%eax
  105394:	8b 40 04             	mov    0x4(%eax),%eax
  105397:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  10539a:	74 24                	je     1053c0 <default_check+0x604>
  10539c:	c7 44 24 0c 68 7f 10 	movl   $0x107f68,0xc(%esp)
  1053a3:	00 
  1053a4:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  1053ab:	00 
  1053ac:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
  1053b3:	00 
  1053b4:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  1053bb:	e8 29 b0 ff ff       	call   1003e9 <__panic>
        struct Page *p = le2page(le, page_link);
  1053c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1053c3:	83 e8 0c             	sub    $0xc,%eax
  1053c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  1053c9:	ff 4d f4             	decl   -0xc(%ebp)
  1053cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1053cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1053d2:	8b 40 08             	mov    0x8(%eax),%eax
  1053d5:	29 c2                	sub    %eax,%edx
  1053d7:	89 d0                	mov    %edx,%eax
  1053d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1053dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1053df:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  1053e2:	8b 45 88             	mov    -0x78(%ebp),%eax
  1053e5:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  1053e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1053eb:	81 7d ec 20 df 11 00 	cmpl   $0x11df20,-0x14(%ebp)
  1053f2:	75 8e                	jne    105382 <default_check+0x5c6>
    }
    assert(count == 0);
  1053f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1053f8:	74 24                	je     10541e <default_check+0x662>
  1053fa:	c7 44 24 0c 95 7f 10 	movl   $0x107f95,0xc(%esp)
  105401:	00 
  105402:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  105409:	00 
  10540a:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
  105411:	00 
  105412:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  105419:	e8 cb af ff ff       	call   1003e9 <__panic>
    assert(total == 0);
  10541e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105422:	74 24                	je     105448 <default_check+0x68c>
  105424:	c7 44 24 0c a0 7f 10 	movl   $0x107fa0,0xc(%esp)
  10542b:	00 
  10542c:	c7 44 24 08 1e 7c 10 	movl   $0x107c1e,0x8(%esp)
  105433:	00 
  105434:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
  10543b:	00 
  10543c:	c7 04 24 33 7c 10 00 	movl   $0x107c33,(%esp)
  105443:	e8 a1 af ff ff       	call   1003e9 <__panic>
}
  105448:	90                   	nop
  105449:	c9                   	leave  
  10544a:	c3                   	ret    

0010544b <page2ppn>:
page2ppn(struct Page *page) {
  10544b:	55                   	push   %ebp
  10544c:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10544e:	8b 45 08             	mov    0x8(%ebp),%eax
  105451:	8b 15 18 df 11 00    	mov    0x11df18,%edx
  105457:	29 d0                	sub    %edx,%eax
  105459:	c1 f8 02             	sar    $0x2,%eax
  10545c:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  105462:	5d                   	pop    %ebp
  105463:	c3                   	ret    

00105464 <page2pa>:
page2pa(struct Page *page) {
  105464:	55                   	push   %ebp
  105465:	89 e5                	mov    %esp,%ebp
  105467:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  10546a:	8b 45 08             	mov    0x8(%ebp),%eax
  10546d:	89 04 24             	mov    %eax,(%esp)
  105470:	e8 d6 ff ff ff       	call   10544b <page2ppn>
  105475:	c1 e0 0c             	shl    $0xc,%eax
}
  105478:	c9                   	leave  
  105479:	c3                   	ret    

0010547a <page_ref>:
page_ref(struct Page *page) {
  10547a:	55                   	push   %ebp
  10547b:	89 e5                	mov    %esp,%ebp
    return page->ref;
  10547d:	8b 45 08             	mov    0x8(%ebp),%eax
  105480:	8b 00                	mov    (%eax),%eax
}
  105482:	5d                   	pop    %ebp
  105483:	c3                   	ret    

00105484 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  105484:	55                   	push   %ebp
  105485:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  105487:	8b 45 08             	mov    0x8(%ebp),%eax
  10548a:	8b 55 0c             	mov    0xc(%ebp),%edx
  10548d:	89 10                	mov    %edx,(%eax)
}
  10548f:	90                   	nop
  105490:	5d                   	pop    %ebp
  105491:	c3                   	ret    

00105492 <buddy_init>:

#define MAXLEVEL 12
free_area_t free_area[MAXLEVEL+1];

static void 
buddy_init(void){
  105492:	55                   	push   %ebp
  105493:	89 e5                	mov    %esp,%ebp
  105495:	83 ec 10             	sub    $0x10,%esp
     for(int i=0;i<=MAXLEVEL;i++){
  105498:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10549f:	eb 42                	jmp    1054e3 <buddy_init+0x51>
	list_init(&free_area[i].free_list);
  1054a1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1054a4:	89 d0                	mov    %edx,%eax
  1054a6:	01 c0                	add    %eax,%eax
  1054a8:	01 d0                	add    %edx,%eax
  1054aa:	c1 e0 02             	shl    $0x2,%eax
  1054ad:	05 20 df 11 00       	add    $0x11df20,%eax
  1054b2:	89 45 f8             	mov    %eax,-0x8(%ebp)
    elm->prev = elm->next = elm;
  1054b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1054b8:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1054bb:	89 50 04             	mov    %edx,0x4(%eax)
  1054be:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1054c1:	8b 50 04             	mov    0x4(%eax),%edx
  1054c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1054c7:	89 10                	mov    %edx,(%eax)
	free_area[i].nr_free=0;
  1054c9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1054cc:	89 d0                	mov    %edx,%eax
  1054ce:	01 c0                	add    %eax,%eax
  1054d0:	01 d0                	add    %edx,%eax
  1054d2:	c1 e0 02             	shl    $0x2,%eax
  1054d5:	05 28 df 11 00       	add    $0x11df28,%eax
  1054da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     for(int i=0;i<=MAXLEVEL;i++){
  1054e0:	ff 45 fc             	incl   -0x4(%ebp)
  1054e3:	83 7d fc 0c          	cmpl   $0xc,-0x4(%ebp)
  1054e7:	7e b8                	jle    1054a1 <buddy_init+0xf>
     }
}
  1054e9:	90                   	nop
  1054ea:	c9                   	leave  
  1054eb:	c3                   	ret    

001054ec <buddy_nr_free_page>:

static size_t
buddy_nr_free_page(void){
  1054ec:	55                   	push   %ebp
  1054ed:	89 e5                	mov    %esp,%ebp
  1054ef:	83 ec 10             	sub    $0x10,%esp
    size_t nr=0;
  1054f2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
  1054f9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  105500:	eb 1c                	jmp    10551e <buddy_nr_free_page+0x32>
	nr+=free_area[i].nr_free*(1<<MAXLEVEL);
  105502:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105505:	89 d0                	mov    %edx,%eax
  105507:	01 c0                	add    %eax,%eax
  105509:	01 d0                	add    %edx,%eax
  10550b:	c1 e0 02             	shl    $0x2,%eax
  10550e:	05 28 df 11 00       	add    $0x11df28,%eax
  105513:	8b 00                	mov    (%eax),%eax
  105515:	c1 e0 0c             	shl    $0xc,%eax
  105518:	01 45 fc             	add    %eax,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
  10551b:	ff 45 f8             	incl   -0x8(%ebp)
  10551e:	83 7d f8 0c          	cmpl   $0xc,-0x8(%ebp)
  105522:	7e de                	jle    105502 <buddy_nr_free_page+0x16>
    }
    return nr; 
  105524:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105527:	c9                   	leave  
  105528:	c3                   	ret    

00105529 <buddy_init_memmap>:

static void
buddy_init_memmap(struct Page* base,size_t n){
  105529:	55                   	push   %ebp
  10552a:	89 e5                	mov    %esp,%ebp
  10552c:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
  10552f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105533:	75 24                	jne    105559 <buddy_init_memmap+0x30>
  105535:	c7 44 24 0c dc 7f 10 	movl   $0x107fdc,0xc(%esp)
  10553c:	00 
  10553d:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  105544:	00 
  105545:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  10554c:	00 
  10554d:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  105554:	e8 90 ae ff ff       	call   1003e9 <__panic>
     struct Page* p=base;
  105559:	8b 45 08             	mov    0x8(%ebp),%eax
  10555c:	89 45 f4             	mov    %eax,-0xc(%ebp)
     for(;p!=base+n;p++){
  10555f:	eb 7d                	jmp    1055de <buddy_init_memmap+0xb5>
	assert(PageReserved(p));
  105561:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105564:	83 c0 04             	add    $0x4,%eax
  105567:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  10556e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105571:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105574:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105577:	0f a3 10             	bt     %edx,(%eax)
  10557a:	19 c0                	sbb    %eax,%eax
  10557c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  10557f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  105583:	0f 95 c0             	setne  %al
  105586:	0f b6 c0             	movzbl %al,%eax
  105589:	85 c0                	test   %eax,%eax
  10558b:	75 24                	jne    1055b1 <buddy_init_memmap+0x88>
  10558d:	c7 44 24 0c 0c 80 10 	movl   $0x10800c,0xc(%esp)
  105594:	00 
  105595:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  10559c:	00 
  10559d:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  1055a4:	00 
  1055a5:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  1055ac:	e8 38 ae ff ff       	call   1003e9 <__panic>
	p->flags=p->property=0;
  1055b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055b4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  1055bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055be:	8b 50 08             	mov    0x8(%eax),%edx
  1055c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055c4:	89 50 04             	mov    %edx,0x4(%eax)
	set_page_ref(p,0);
  1055c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1055ce:	00 
  1055cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055d2:	89 04 24             	mov    %eax,(%esp)
  1055d5:	e8 aa fe ff ff       	call   105484 <set_page_ref>
     for(;p!=base+n;p++){
  1055da:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1055de:	8b 55 0c             	mov    0xc(%ebp),%edx
  1055e1:	89 d0                	mov    %edx,%eax
  1055e3:	c1 e0 02             	shl    $0x2,%eax
  1055e6:	01 d0                	add    %edx,%eax
  1055e8:	c1 e0 02             	shl    $0x2,%eax
  1055eb:	89 c2                	mov    %eax,%edx
  1055ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1055f0:	01 d0                	add    %edx,%eax
  1055f2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1055f5:	0f 85 66 ff ff ff    	jne    105561 <buddy_init_memmap+0x38>
     }
     p=base;
  1055fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1055fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
     size_t temp=n;
  105601:	8b 45 0c             	mov    0xc(%ebp),%eax
  105604:	89 45 f0             	mov    %eax,-0x10(%ebp)
     int level=MAXLEVEL;
  105607:	c7 45 ec 0c 00 00 00 	movl   $0xc,-0x14(%ebp)
     while(level>=0){
  10560e:	e9 fd 00 00 00       	jmp    105710 <buddy_init_memmap+0x1e7>
	for(int i=0;i<temp/(1<<level);i++){
  105613:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  10561a:	e9 c7 00 00 00       	jmp    1056e6 <buddy_init_memmap+0x1bd>
	    struct Page* page=p;
  10561f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105622:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	    page->property=1<<level;
  105625:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105628:	ba 01 00 00 00       	mov    $0x1,%edx
  10562d:	88 c1                	mov    %al,%cl
  10562f:	d3 e2                	shl    %cl,%edx
  105631:	89 d0                	mov    %edx,%eax
  105633:	89 c2                	mov    %eax,%edx
  105635:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105638:	89 50 08             	mov    %edx,0x8(%eax)
	    SetPageProperty(p);
  10563b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10563e:	83 c0 04             	add    $0x4,%eax
  105641:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  105648:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10564b:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10564e:	8b 55 c0             	mov    -0x40(%ebp),%edx
  105651:	0f ab 10             	bts    %edx,(%eax)
	    list_add_before(&free_area[level].free_list,&(page->page_link));
  105654:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105657:	8d 48 0c             	lea    0xc(%eax),%ecx
  10565a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10565d:	89 d0                	mov    %edx,%eax
  10565f:	01 c0                	add    %eax,%eax
  105661:	01 d0                	add    %edx,%eax
  105663:	c1 e0 02             	shl    $0x2,%eax
  105666:	05 20 df 11 00       	add    $0x11df20,%eax
  10566b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  10566e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
    __list_add(elm, listelm->prev, listelm);
  105671:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105674:	8b 00                	mov    (%eax),%eax
  105676:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105679:	89 55 cc             	mov    %edx,-0x34(%ebp)
  10567c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10567f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105682:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
  105685:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105688:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10568b:	89 10                	mov    %edx,(%eax)
  10568d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105690:	8b 10                	mov    (%eax),%edx
  105692:	8b 45 c8             	mov    -0x38(%ebp),%eax
  105695:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  105698:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10569b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  10569e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1056a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1056a4:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1056a7:	89 10                	mov    %edx,(%eax)
	    p+=(1<<level);
  1056a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1056ac:	ba 14 00 00 00       	mov    $0x14,%edx
  1056b1:	88 c1                	mov    %al,%cl
  1056b3:	d3 e2                	shl    %cl,%edx
  1056b5:	89 d0                	mov    %edx,%eax
  1056b7:	01 45 f4             	add    %eax,-0xc(%ebp)
	    free_area[level].nr_free++;
  1056ba:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1056bd:	89 d0                	mov    %edx,%eax
  1056bf:	01 c0                	add    %eax,%eax
  1056c1:	01 d0                	add    %edx,%eax
  1056c3:	c1 e0 02             	shl    $0x2,%eax
  1056c6:	05 28 df 11 00       	add    $0x11df28,%eax
  1056cb:	8b 00                	mov    (%eax),%eax
  1056cd:	8d 48 01             	lea    0x1(%eax),%ecx
  1056d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1056d3:	89 d0                	mov    %edx,%eax
  1056d5:	01 c0                	add    %eax,%eax
  1056d7:	01 d0                	add    %edx,%eax
  1056d9:	c1 e0 02             	shl    $0x2,%eax
  1056dc:	05 28 df 11 00       	add    $0x11df28,%eax
  1056e1:	89 08                	mov    %ecx,(%eax)
	for(int i=0;i<temp/(1<<level);i++){
  1056e3:	ff 45 e8             	incl   -0x18(%ebp)
  1056e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1056e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1056ec:	88 c1                	mov    %al,%cl
  1056ee:	d3 ea                	shr    %cl,%edx
  1056f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1056f3:	39 c2                	cmp    %eax,%edx
  1056f5:	0f 87 24 ff ff ff    	ja     10561f <buddy_init_memmap+0xf6>
	}
	temp = temp % (1 << level);
  1056fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1056fe:	ba 01 00 00 00       	mov    $0x1,%edx
  105703:	88 c1                	mov    %al,%cl
  105705:	d3 e2                	shl    %cl,%edx
  105707:	89 d0                	mov    %edx,%eax
  105709:	48                   	dec    %eax
  10570a:	21 45 f0             	and    %eax,-0x10(%ebp)
	level--;
  10570d:	ff 4d ec             	decl   -0x14(%ebp)
     while(level>=0){
  105710:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  105714:	0f 89 f9 fe ff ff    	jns    105613 <buddy_init_memmap+0xea>
     }
}
  10571a:	90                   	nop
  10571b:	c9                   	leave  
  10571c:	c3                   	ret    

0010571d <buddy_my_partial>:

static void
buddy_my_partial(struct Page *base, size_t n, int level) {
  10571d:	55                   	push   %ebp
  10571e:	89 e5                	mov    %esp,%ebp
  105720:	83 ec 78             	sub    $0x78,%esp
    if (level < 0) return;
  105723:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105727:	0f 88 20 02 00 00    	js     10594d <buddy_my_partial+0x230>
    size_t temp = n;
  10572d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105730:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (level >= 0) {
  105733:	e9 7a 01 00 00       	jmp    1058b2 <buddy_my_partial+0x195>
        for (int i = 0; i < temp / (1 << level); i++) {
  105738:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  10573f:	e9 44 01 00 00       	jmp    105888 <buddy_my_partial+0x16b>
            base->property = (1 << level);
  105744:	8b 45 10             	mov    0x10(%ebp),%eax
  105747:	ba 01 00 00 00       	mov    $0x1,%edx
  10574c:	88 c1                	mov    %al,%cl
  10574e:	d3 e2                	shl    %cl,%edx
  105750:	89 d0                	mov    %edx,%eax
  105752:	89 c2                	mov    %eax,%edx
  105754:	8b 45 08             	mov    0x8(%ebp),%eax
  105757:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(base);
  10575a:	8b 45 08             	mov    0x8(%ebp),%eax
  10575d:	83 c0 04             	add    $0x4,%eax
  105760:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  105767:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10576a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10576d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  105770:	0f ab 10             	bts    %edx,(%eax)
            // add pages in order
            struct Page* p = NULL;
  105773:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
            list_entry_t* le = list_next(&(free_area[level].free_list));
  10577a:	8b 55 10             	mov    0x10(%ebp),%edx
  10577d:	89 d0                	mov    %edx,%eax
  10577f:	01 c0                	add    %eax,%eax
  105781:	01 d0                	add    %edx,%eax
  105783:	c1 e0 02             	shl    $0x2,%eax
  105786:	05 20 df 11 00       	add    $0x11df20,%eax
  10578b:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return listelm->next;
  10578e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105791:	8b 40 04             	mov    0x4(%eax),%eax
  105794:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105797:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10579a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return listelm->prev;
  10579d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1057a0:	8b 00                	mov    (%eax),%eax
            list_entry_t* bfle = list_prev(le);
  1057a2:	89 45 e8             	mov    %eax,-0x18(%ebp)
            while (le != &(free_area[level].free_list)) {
  1057a5:	eb 37                	jmp    1057de <buddy_my_partial+0xc1>
                p = le2page(le, page_link);
  1057a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1057aa:	83 e8 0c             	sub    $0xc,%eax
  1057ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
                if (base + base->property < le) break;
  1057b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1057b3:	8b 50 08             	mov    0x8(%eax),%edx
  1057b6:	89 d0                	mov    %edx,%eax
  1057b8:	c1 e0 02             	shl    $0x2,%eax
  1057bb:	01 d0                	add    %edx,%eax
  1057bd:	c1 e0 02             	shl    $0x2,%eax
  1057c0:	89 c2                	mov    %eax,%edx
  1057c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1057c5:	01 d0                	add    %edx,%eax
  1057c7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  1057ca:	77 2a                	ja     1057f6 <buddy_my_partial+0xd9>
                bfle = bfle->next;
  1057cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1057cf:	8b 40 04             	mov    0x4(%eax),%eax
  1057d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
                le = le->next;
  1057d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1057d8:	8b 40 04             	mov    0x4(%eax),%eax
  1057db:	89 45 ec             	mov    %eax,-0x14(%ebp)
            while (le != &(free_area[level].free_list)) {
  1057de:	8b 55 10             	mov    0x10(%ebp),%edx
  1057e1:	89 d0                	mov    %edx,%eax
  1057e3:	01 c0                	add    %eax,%eax
  1057e5:	01 d0                	add    %edx,%eax
  1057e7:	c1 e0 02             	shl    $0x2,%eax
  1057ea:	05 20 df 11 00       	add    $0x11df20,%eax
  1057ef:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  1057f2:	75 b3                	jne    1057a7 <buddy_my_partial+0x8a>
  1057f4:	eb 01                	jmp    1057f7 <buddy_my_partial+0xda>
                if (base + base->property < le) break;
  1057f6:	90                   	nop
            }
            list_add(bfle, &(base->page_link));
  1057f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1057fa:	8d 50 0c             	lea    0xc(%eax),%edx
  1057fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105800:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  105803:	89 55 c0             	mov    %edx,-0x40(%ebp)
  105806:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105809:	89 45 bc             	mov    %eax,-0x44(%ebp)
  10580c:	8b 45 c0             	mov    -0x40(%ebp),%eax
  10580f:	89 45 b8             	mov    %eax,-0x48(%ebp)
    __list_add(elm, listelm, listelm->next);
  105812:	8b 45 bc             	mov    -0x44(%ebp),%eax
  105815:	8b 40 04             	mov    0x4(%eax),%eax
  105818:	8b 55 b8             	mov    -0x48(%ebp),%edx
  10581b:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  10581e:	8b 55 bc             	mov    -0x44(%ebp),%edx
  105821:	89 55 b0             	mov    %edx,-0x50(%ebp)
  105824:	89 45 ac             	mov    %eax,-0x54(%ebp)
    prev->next = next->prev = elm;
  105827:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10582a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  10582d:	89 10                	mov    %edx,(%eax)
  10582f:	8b 45 ac             	mov    -0x54(%ebp),%eax
  105832:	8b 10                	mov    (%eax),%edx
  105834:	8b 45 b0             	mov    -0x50(%ebp),%eax
  105837:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10583a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10583d:	8b 55 ac             	mov    -0x54(%ebp),%edx
  105840:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  105843:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  105846:	8b 55 b0             	mov    -0x50(%ebp),%edx
  105849:	89 10                	mov    %edx,(%eax)
            base += (1 << level);
  10584b:	8b 45 10             	mov    0x10(%ebp),%eax
  10584e:	ba 14 00 00 00       	mov    $0x14,%edx
  105853:	88 c1                	mov    %al,%cl
  105855:	d3 e2                	shl    %cl,%edx
  105857:	89 d0                	mov    %edx,%eax
  105859:	01 45 08             	add    %eax,0x8(%ebp)
            free_area[level].nr_free++;
  10585c:	8b 55 10             	mov    0x10(%ebp),%edx
  10585f:	89 d0                	mov    %edx,%eax
  105861:	01 c0                	add    %eax,%eax
  105863:	01 d0                	add    %edx,%eax
  105865:	c1 e0 02             	shl    $0x2,%eax
  105868:	05 28 df 11 00       	add    $0x11df28,%eax
  10586d:	8b 00                	mov    (%eax),%eax
  10586f:	8d 48 01             	lea    0x1(%eax),%ecx
  105872:	8b 55 10             	mov    0x10(%ebp),%edx
  105875:	89 d0                	mov    %edx,%eax
  105877:	01 c0                	add    %eax,%eax
  105879:	01 d0                	add    %edx,%eax
  10587b:	c1 e0 02             	shl    $0x2,%eax
  10587e:	05 28 df 11 00       	add    $0x11df28,%eax
  105883:	89 08                	mov    %ecx,(%eax)
        for (int i = 0; i < temp / (1 << level); i++) {
  105885:	ff 45 f0             	incl   -0x10(%ebp)
  105888:	8b 45 10             	mov    0x10(%ebp),%eax
  10588b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10588e:	88 c1                	mov    %al,%cl
  105890:	d3 ea                	shr    %cl,%edx
  105892:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105895:	39 c2                	cmp    %eax,%edx
  105897:	0f 87 a7 fe ff ff    	ja     105744 <buddy_my_partial+0x27>
        }
        temp = temp % (1 << level);
  10589d:	8b 45 10             	mov    0x10(%ebp),%eax
  1058a0:	ba 01 00 00 00       	mov    $0x1,%edx
  1058a5:	88 c1                	mov    %al,%cl
  1058a7:	d3 e2                	shl    %cl,%edx
  1058a9:	89 d0                	mov    %edx,%eax
  1058ab:	48                   	dec    %eax
  1058ac:	21 45 f4             	and    %eax,-0xc(%ebp)
        level--;
  1058af:	ff 4d 10             	decl   0x10(%ebp)
    while (level >= 0) {
  1058b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1058b6:	0f 89 7c fe ff ff    	jns    105738 <buddy_my_partial+0x1b>
    }
    cprintf("alloc_page check: \n");
  1058bc:	c7 04 24 1c 80 10 00 	movl   $0x10801c,(%esp)
  1058c3:	e8 ca a9 ff ff       	call   100292 <cprintf>
    for (int i = MAXLEVEL; i >= 0; i--) {
  1058c8:	c7 45 e4 0c 00 00 00 	movl   $0xc,-0x1c(%ebp)
  1058cf:	eb 74                	jmp    105945 <buddy_my_partial+0x228>
        list_entry_t* le = list_next(&(free_area[i].free_list));
  1058d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1058d4:	89 d0                	mov    %edx,%eax
  1058d6:	01 c0                	add    %eax,%eax
  1058d8:	01 d0                	add    %edx,%eax
  1058da:	c1 e0 02             	shl    $0x2,%eax
  1058dd:	05 20 df 11 00       	add    $0x11df20,%eax
  1058e2:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return listelm->next;
  1058e5:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1058e8:	8b 40 04             	mov    0x4(%eax),%eax
  1058eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
  1058ee:	eb 3c                	jmp    10592c <buddy_my_partial+0x20f>
            struct Page* page = le2page(le, page_link);
  1058f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1058f3:	83 e8 0c             	sub    $0xc,%eax
  1058f6:	89 45 dc             	mov    %eax,-0x24(%ebp)
            cprintf("%d - %llx\n", i, page->page_link);
  1058f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1058fc:	8b 50 10             	mov    0x10(%eax),%edx
  1058ff:	8b 40 0c             	mov    0xc(%eax),%eax
  105902:	89 44 24 08          	mov    %eax,0x8(%esp)
  105906:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10590a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10590d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105911:	c7 04 24 30 80 10 00 	movl   $0x108030,(%esp)
  105918:	e8 75 a9 ff ff       	call   100292 <cprintf>
  10591d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105920:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  105923:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  105926:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
  105929:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
  10592c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10592f:	89 d0                	mov    %edx,%eax
  105931:	01 c0                	add    %eax,%eax
  105933:	01 d0                	add    %edx,%eax
  105935:	c1 e0 02             	shl    $0x2,%eax
  105938:	05 20 df 11 00       	add    $0x11df20,%eax
  10593d:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  105940:	75 ae                	jne    1058f0 <buddy_my_partial+0x1d3>
    for (int i = MAXLEVEL; i >= 0; i--) {
  105942:	ff 4d e4             	decl   -0x1c(%ebp)
  105945:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105949:	79 86                	jns    1058d1 <buddy_my_partial+0x1b4>
  10594b:	eb 01                	jmp    10594e <buddy_my_partial+0x231>
    if (level < 0) return;
  10594d:	90                   	nop
        }
    }
}
  10594e:	c9                   	leave  
  10594f:	c3                   	ret    

00105950 <buddy_my_merge>:

static void
buddy_my_merge(int level) {
  105950:	55                   	push   %ebp
  105951:	89 e5                	mov    %esp,%ebp
  105953:	83 ec 68             	sub    $0x68,%esp
    cprintf("before merge.\n");
  105956:	c7 04 24 3b 80 10 00 	movl   $0x10803b,(%esp)
  10595d:	e8 30 a9 ff ff       	call   100292 <cprintf>
    //bds_selfcheck();
    while (level < MAXLEVEL) {
  105962:	e9 dc 01 00 00       	jmp    105b43 <buddy_my_merge+0x1f3>
        if (free_area[level].nr_free <= 1) {
  105967:	8b 55 08             	mov    0x8(%ebp),%edx
  10596a:	89 d0                	mov    %edx,%eax
  10596c:	01 c0                	add    %eax,%eax
  10596e:	01 d0                	add    %edx,%eax
  105970:	c1 e0 02             	shl    $0x2,%eax
  105973:	05 28 df 11 00       	add    $0x11df28,%eax
  105978:	8b 00                	mov    (%eax),%eax
  10597a:	83 f8 01             	cmp    $0x1,%eax
  10597d:	77 08                	ja     105987 <buddy_my_merge+0x37>
            level++;
  10597f:	ff 45 08             	incl   0x8(%ebp)
            continue;
  105982:	e9 bc 01 00 00       	jmp    105b43 <buddy_my_merge+0x1f3>
        }
        list_entry_t* le = list_next(&(free_area[level].free_list));
  105987:	8b 55 08             	mov    0x8(%ebp),%edx
  10598a:	89 d0                	mov    %edx,%eax
  10598c:	01 c0                	add    %eax,%eax
  10598e:	01 d0                	add    %edx,%eax
  105990:	c1 e0 02             	shl    $0x2,%eax
  105993:	05 20 df 11 00       	add    $0x11df20,%eax
  105998:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10599b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10599e:	8b 40 04             	mov    0x4(%eax),%eax
  1059a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1059a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1059a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->prev;
  1059aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1059ad:	8b 00                	mov    (%eax),%eax
        list_entry_t* bfle = list_prev(le);
  1059af:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while (le != &(free_area[level].free_list)) {
  1059b2:	e9 6f 01 00 00       	jmp    105b26 <buddy_my_merge+0x1d6>
  1059b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return listelm->next;
  1059bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1059c0:	8b 40 04             	mov    0x4(%eax),%eax
            bfle = list_next(bfle);
  1059c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1059c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1059cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1059cf:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
  1059d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
            struct Page* ple = le2page(le, page_link);
  1059d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1059d8:	83 e8 0c             	sub    $0xc,%eax
  1059db:	89 45 ec             	mov    %eax,-0x14(%ebp)
            struct Page* pbf = le2page(bfle, page_link); 
  1059de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059e1:	83 e8 0c             	sub    $0xc,%eax
  1059e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
            cprintf("bfle addr is: %llx\n", pbf->page_link);
  1059e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1059ea:	8b 50 10             	mov    0x10(%eax),%edx
  1059ed:	8b 40 0c             	mov    0xc(%eax),%eax
  1059f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059f4:	89 54 24 08          	mov    %edx,0x8(%esp)
  1059f8:	c7 04 24 4a 80 10 00 	movl   $0x10804a,(%esp)
  1059ff:	e8 8e a8 ff ff       	call   100292 <cprintf>
            cprintf("le addr is: %llx\n", ple->page_link);
  105a04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a07:	8b 50 10             	mov    0x10(%eax),%edx
  105a0a:	8b 40 0c             	mov    0xc(%eax),%eax
  105a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a11:	89 54 24 08          	mov    %edx,0x8(%esp)
  105a15:	c7 04 24 5e 80 10 00 	movl   $0x10805e,(%esp)
  105a1c:	e8 71 a8 ff ff       	call   100292 <cprintf>
            if (pbf + pbf->property == ple) {            
  105a21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a24:	8b 50 08             	mov    0x8(%eax),%edx
  105a27:	89 d0                	mov    %edx,%eax
  105a29:	c1 e0 02             	shl    $0x2,%eax
  105a2c:	01 d0                	add    %edx,%eax
  105a2e:	c1 e0 02             	shl    $0x2,%eax
  105a31:	89 c2                	mov    %eax,%edx
  105a33:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a36:	01 d0                	add    %edx,%eax
  105a38:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  105a3b:	0f 85 e5 00 00 00    	jne    105b26 <buddy_my_merge+0x1d6>
  105a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a44:	89 45 b0             	mov    %eax,-0x50(%ebp)
  105a47:	8b 45 b0             	mov    -0x50(%ebp),%eax
  105a4a:	8b 40 04             	mov    0x4(%eax),%eax
                bfle = list_next(bfle);
  105a4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105a53:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  105a56:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  105a59:	8b 40 04             	mov    0x4(%eax),%eax
                le = list_next(le);
  105a5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
                pbf->property = pbf->property << 1;
  105a5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a62:	8b 40 08             	mov    0x8(%eax),%eax
  105a65:	8d 14 00             	lea    (%eax,%eax,1),%edx
  105a68:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a6b:	89 50 08             	mov    %edx,0x8(%eax)
                ClearPageProperty(ple);
  105a6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a71:	83 c0 04             	add    $0x4,%eax
  105a74:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  105a7b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105a7e:	8b 45 b8             	mov    -0x48(%ebp),%eax
  105a81:	8b 55 bc             	mov    -0x44(%ebp),%edx
  105a84:	0f b3 10             	btr    %edx,(%eax)
                list_del(&(pbf->page_link));
  105a87:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a8a:	83 c0 0c             	add    $0xc,%eax
  105a8d:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_del(listelm->prev, listelm->next);
  105a90:	8b 45 c8             	mov    -0x38(%ebp),%eax
  105a93:	8b 40 04             	mov    0x4(%eax),%eax
  105a96:	8b 55 c8             	mov    -0x38(%ebp),%edx
  105a99:	8b 12                	mov    (%edx),%edx
  105a9b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  105a9e:	89 45 c0             	mov    %eax,-0x40(%ebp)
    prev->next = next;
  105aa1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105aa4:	8b 55 c0             	mov    -0x40(%ebp),%edx
  105aa7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  105aaa:	8b 45 c0             	mov    -0x40(%ebp),%eax
  105aad:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  105ab0:	89 10                	mov    %edx,(%eax)
                list_del(&(ple->page_link));
  105ab2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105ab5:	83 c0 0c             	add    $0xc,%eax
  105ab8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_del(listelm->prev, listelm->next);
  105abb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105abe:	8b 40 04             	mov    0x4(%eax),%eax
  105ac1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105ac4:	8b 12                	mov    (%edx),%edx
  105ac6:	89 55 d0             	mov    %edx,-0x30(%ebp)
  105ac9:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next;
  105acc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105acf:	8b 55 cc             	mov    -0x34(%ebp),%edx
  105ad2:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  105ad5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105ad8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105adb:	89 10                	mov    %edx,(%eax)
                buddy_my_partial(pbf, pbf->property, level + 1);             
  105add:	8b 45 08             	mov    0x8(%ebp),%eax
  105ae0:	8d 50 01             	lea    0x1(%eax),%edx
  105ae3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ae6:	8b 40 08             	mov    0x8(%eax),%eax
  105ae9:	89 54 24 08          	mov    %edx,0x8(%esp)
  105aed:	89 44 24 04          	mov    %eax,0x4(%esp)
  105af1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105af4:	89 04 24             	mov    %eax,(%esp)
  105af7:	e8 21 fc ff ff       	call   10571d <buddy_my_partial>
                free_area[level].nr_free -= 2;              
  105afc:	8b 55 08             	mov    0x8(%ebp),%edx
  105aff:	89 d0                	mov    %edx,%eax
  105b01:	01 c0                	add    %eax,%eax
  105b03:	01 d0                	add    %edx,%eax
  105b05:	c1 e0 02             	shl    $0x2,%eax
  105b08:	05 28 df 11 00       	add    $0x11df28,%eax
  105b0d:	8b 00                	mov    (%eax),%eax
  105b0f:	8d 48 fe             	lea    -0x2(%eax),%ecx
  105b12:	8b 55 08             	mov    0x8(%ebp),%edx
  105b15:	89 d0                	mov    %edx,%eax
  105b17:	01 c0                	add    %eax,%eax
  105b19:	01 d0                	add    %edx,%eax
  105b1b:	c1 e0 02             	shl    $0x2,%eax
  105b1e:	05 28 df 11 00       	add    $0x11df28,%eax
  105b23:	89 08                	mov    %ecx,(%eax)
                continue;
  105b25:	90                   	nop
        while (le != &(free_area[level].free_list)) {
  105b26:	8b 55 08             	mov    0x8(%ebp),%edx
  105b29:	89 d0                	mov    %edx,%eax
  105b2b:	01 c0                	add    %eax,%eax
  105b2d:	01 d0                	add    %edx,%eax
  105b2f:	c1 e0 02             	shl    $0x2,%eax
  105b32:	05 20 df 11 00       	add    $0x11df20,%eax
  105b37:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  105b3a:	0f 85 77 fe ff ff    	jne    1059b7 <buddy_my_merge+0x67>
            } 
        }
        level++;
  105b40:	ff 45 08             	incl   0x8(%ebp)
    while (level < MAXLEVEL) {
  105b43:	83 7d 08 0b          	cmpl   $0xb,0x8(%ebp)
  105b47:	0f 8e 1a fe ff ff    	jle    105967 <buddy_my_merge+0x17>
    }
    //bds_selfcheck();
}
  105b4d:	90                   	nop
  105b4e:	c9                   	leave  
  105b4f:	c3                   	ret    

00105b50 <buddy_alloc_page>:

static struct Page*
buddy_alloc_page(size_t n){
  105b50:	55                   	push   %ebp
  105b51:	89 e5                	mov    %esp,%ebp
  105b53:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
  105b56:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105b5a:	75 24                	jne    105b80 <buddy_alloc_page+0x30>
  105b5c:	c7 44 24 0c dc 7f 10 	movl   $0x107fdc,0xc(%esp)
  105b63:	00 
  105b64:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  105b6b:	00 
  105b6c:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  105b73:	00 
  105b74:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  105b7b:	e8 69 a8 ff ff       	call   1003e9 <__panic>
     if(n>buddy_nr_free_page()){
  105b80:	e8 67 f9 ff ff       	call   1054ec <buddy_nr_free_page>
  105b85:	39 45 08             	cmp    %eax,0x8(%ebp)
  105b88:	76 0a                	jbe    105b94 <buddy_alloc_page+0x44>
	return NULL;
  105b8a:	b8 00 00 00 00       	mov    $0x0,%eax
  105b8f:	e9 62 01 00 00       	jmp    105cf6 <buddy_alloc_page+0x1a6>
     }
     int level=0;
  105b94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     while((1<<level)<n){
  105b9b:	eb 03                	jmp    105ba0 <buddy_alloc_page+0x50>
	level++;
  105b9d:	ff 45 f4             	incl   -0xc(%ebp)
     while((1<<level)<n){
  105ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105ba3:	ba 01 00 00 00       	mov    $0x1,%edx
  105ba8:	88 c1                	mov    %al,%cl
  105baa:	d3 e2                	shl    %cl,%edx
  105bac:	89 d0                	mov    %edx,%eax
  105bae:	39 45 08             	cmp    %eax,0x8(%ebp)
  105bb1:	77 ea                	ja     105b9d <buddy_alloc_page+0x4d>
     }
     //n=1<<level;
     for(int i=level;i<=MAXLEVEL;i++){
  105bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105bb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105bb9:	eb 22                	jmp    105bdd <buddy_alloc_page+0x8d>
	if(free_area[i].nr_free!=0){
  105bbb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105bbe:	89 d0                	mov    %edx,%eax
  105bc0:	01 c0                	add    %eax,%eax
  105bc2:	01 d0                	add    %edx,%eax
  105bc4:	c1 e0 02             	shl    $0x2,%eax
  105bc7:	05 28 df 11 00       	add    $0x11df28,%eax
  105bcc:	8b 00                	mov    (%eax),%eax
  105bce:	85 c0                	test   %eax,%eax
  105bd0:	74 08                	je     105bda <buddy_alloc_page+0x8a>
	   level=i;
  105bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    break;
  105bd8:	eb 09                	jmp    105be3 <buddy_alloc_page+0x93>
     for(int i=level;i<=MAXLEVEL;i++){
  105bda:	ff 45 f0             	incl   -0x10(%ebp)
  105bdd:	83 7d f0 0c          	cmpl   $0xc,-0x10(%ebp)
  105be1:	7e d8                	jle    105bbb <buddy_alloc_page+0x6b>
	}
     }
     if(level>MAXLEVEL){return NULL;}
  105be3:	83 7d f4 0c          	cmpl   $0xc,-0xc(%ebp)
  105be7:	7e 0a                	jle    105bf3 <buddy_alloc_page+0xa3>
  105be9:	b8 00 00 00 00       	mov    $0x0,%eax
  105bee:	e9 03 01 00 00       	jmp    105cf6 <buddy_alloc_page+0x1a6>
     list_entry_t *le=&free_area[level].free_list;
  105bf3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105bf6:	89 d0                	mov    %edx,%eax
  105bf8:	01 c0                	add    %eax,%eax
  105bfa:	01 d0                	add    %edx,%eax
  105bfc:	c1 e0 02             	shl    $0x2,%eax
  105bff:	05 20 df 11 00       	add    $0x11df20,%eax
  105c04:	89 45 ec             	mov    %eax,-0x14(%ebp)
     struct Page* page=le2page(le,page_link);
  105c07:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105c0a:	83 e8 0c             	sub    $0xc,%eax
  105c0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
     if (page != NULL) {
  105c10:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105c14:	0f 84 cd 00 00 00    	je     105ce7 <buddy_alloc_page+0x197>
        SetPageReserved(page);
  105c1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c1d:	83 c0 04             	add    $0x4,%eax
  105c20:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  105c27:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105c2a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105c2d:	8b 55 c8             	mov    -0x38(%ebp),%edx
  105c30:	0f ab 10             	bts    %edx,(%eax)
        // deal with partial work
        buddy_my_partial(page, page->property - n, level - 1);
  105c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105c36:	8d 50 ff             	lea    -0x1(%eax),%edx
  105c39:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c3c:	8b 40 08             	mov    0x8(%eax),%eax
  105c3f:	2b 45 08             	sub    0x8(%ebp),%eax
  105c42:	89 54 24 08          	mov    %edx,0x8(%esp)
  105c46:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c4d:	89 04 24             	mov    %eax,(%esp)
  105c50:	e8 c8 fa ff ff       	call   10571d <buddy_my_partial>
        ClearPageReserved(page);
  105c55:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c58:	83 c0 04             	add    $0x4,%eax
  105c5b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  105c62:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105c65:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105c68:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105c6b:	0f b3 10             	btr    %edx,(%eax)
        ClearPageProperty(page);
  105c6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c71:	83 c0 04             	add    $0x4,%eax
  105c74:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
  105c7b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  105c7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105c81:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105c84:	0f b3 10             	btr    %edx,(%eax)
        list_del(&(page->page_link));
  105c87:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c8a:	83 c0 0c             	add    $0xc,%eax
  105c8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
  105c90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105c93:	8b 40 04             	mov    0x4(%eax),%eax
  105c96:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105c99:	8b 12                	mov    (%edx),%edx
  105c9b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  105c9e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
  105ca1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ca4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105ca7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  105caa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105cad:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105cb0:	89 10                	mov    %edx,(%eax)
        free_area[level].nr_free--;
  105cb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105cb5:	89 d0                	mov    %edx,%eax
  105cb7:	01 c0                	add    %eax,%eax
  105cb9:	01 d0                	add    %edx,%eax
  105cbb:	c1 e0 02             	shl    $0x2,%eax
  105cbe:	05 28 df 11 00       	add    $0x11df28,%eax
  105cc3:	8b 00                	mov    (%eax),%eax
  105cc5:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105cc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ccb:	89 d0                	mov    %edx,%eax
  105ccd:	01 c0                	add    %eax,%eax
  105ccf:	01 d0                	add    %edx,%eax
  105cd1:	c1 e0 02             	shl    $0x2,%eax
  105cd4:	05 28 df 11 00       	add    $0x11df28,%eax
  105cd9:	89 08                	mov    %ecx,(%eax)
        buddy_my_merge(0);
  105cdb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  105ce2:	e8 69 fc ff ff       	call   105950 <buddy_my_merge>
    }
    cprintf("after allocate & merge\n");
  105ce7:	c7 04 24 70 80 10 00 	movl   $0x108070,(%esp)
  105cee:	e8 9f a5 ff ff       	call   100292 <cprintf>
    //bds_selfcheck();
    return page;
  105cf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
  105cf6:	c9                   	leave  
  105cf7:	c3                   	ret    

00105cf8 <buddy_free_page>:

static void 
buddy_free_page(struct Page* base, size_t n){
  105cf8:	55                   	push   %ebp
  105cf9:	89 e5                	mov    %esp,%ebp
  105cfb:	83 ec 48             	sub    $0x48,%esp
     assert(n > 0);
  105cfe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105d02:	75 24                	jne    105d28 <buddy_free_page+0x30>
  105d04:	c7 44 24 0c 88 80 10 	movl   $0x108088,0xc(%esp)
  105d0b:	00 
  105d0c:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  105d13:	00 
  105d14:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
  105d1b:	00 
  105d1c:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  105d23:	e8 c1 a6 ff ff       	call   1003e9 <__panic>
    struct Page* p = base;
  105d28:	8b 45 08             	mov    0x8(%ebp),%eax
  105d2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++) {
  105d2e:	e9 9d 00 00 00       	jmp    105dd0 <buddy_free_page+0xd8>
        assert(!PageReserved(p) && !PageProperty(p));
  105d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105d36:	83 c0 04             	add    $0x4,%eax
  105d39:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  105d40:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105d43:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105d46:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105d49:	0f a3 10             	bt     %edx,(%eax)
  105d4c:	19 c0                	sbb    %eax,%eax
  105d4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  105d51:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105d55:	0f 95 c0             	setne  %al
  105d58:	0f b6 c0             	movzbl %al,%eax
  105d5b:	85 c0                	test   %eax,%eax
  105d5d:	75 2c                	jne    105d8b <buddy_free_page+0x93>
  105d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105d62:	83 c0 04             	add    $0x4,%eax
  105d65:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  105d6c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105d6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105d72:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105d75:	0f a3 10             	bt     %edx,(%eax)
  105d78:	19 c0                	sbb    %eax,%eax
  105d7a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  105d7d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  105d81:	0f 95 c0             	setne  %al
  105d84:	0f b6 c0             	movzbl %al,%eax
  105d87:	85 c0                	test   %eax,%eax
  105d89:	74 24                	je     105daf <buddy_free_page+0xb7>
  105d8b:	c7 44 24 0c 90 80 10 	movl   $0x108090,0xc(%esp)
  105d92:	00 
  105d93:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  105d9a:	00 
  105d9b:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  105da2:	00 
  105da3:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  105daa:	e8 3a a6 ff ff       	call   1003e9 <__panic>
        p->flags = 0;
  105daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105db2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  105db9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105dc0:	00 
  105dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105dc4:	89 04 24             	mov    %eax,(%esp)
  105dc7:	e8 b8 f6 ff ff       	call   105484 <set_page_ref>
    for (; p != base + n; p++) {
  105dcc:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  105dd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  105dd3:	89 d0                	mov    %edx,%eax
  105dd5:	c1 e0 02             	shl    $0x2,%eax
  105dd8:	01 d0                	add    %edx,%eax
  105dda:	c1 e0 02             	shl    $0x2,%eax
  105ddd:	89 c2                	mov    %eax,%edx
  105ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  105de2:	01 d0                	add    %edx,%eax
  105de4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  105de7:	0f 85 46 ff ff ff    	jne    105d33 <buddy_free_page+0x3b>
    }
    // free pages
    base->property = n;
  105ded:	8b 45 08             	mov    0x8(%ebp),%eax
  105df0:	8b 55 0c             	mov    0xc(%ebp),%edx
  105df3:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  105df6:	8b 45 08             	mov    0x8(%ebp),%eax
  105df9:	83 c0 04             	add    $0x4,%eax
  105dfc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  105e03:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105e06:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105e09:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105e0c:	0f ab 10             	bts    %edx,(%eax)
    int level = 0;
  105e0f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    while ((1 << level) != n) { level++; }
  105e16:	eb 03                	jmp    105e1b <buddy_free_page+0x123>
  105e18:	ff 45 f0             	incl   -0x10(%ebp)
  105e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e1e:	ba 01 00 00 00       	mov    $0x1,%edx
  105e23:	88 c1                	mov    %al,%cl
  105e25:	d3 e2                	shl    %cl,%edx
  105e27:	89 d0                	mov    %edx,%eax
  105e29:	39 45 0c             	cmp    %eax,0xc(%ebp)
  105e2c:	75 ea                	jne    105e18 <buddy_free_page+0x120>
    buddy_my_partial(base, n, level);
  105e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e31:	89 44 24 08          	mov    %eax,0x8(%esp)
  105e35:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e38:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  105e3f:	89 04 24             	mov    %eax,(%esp)
  105e42:	e8 d6 f8 ff ff       	call   10571d <buddy_my_partial>
    //bds_selfcheck();
    free_area[level].nr_free++;
  105e47:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105e4a:	89 d0                	mov    %edx,%eax
  105e4c:	01 c0                	add    %eax,%eax
  105e4e:	01 d0                	add    %edx,%eax
  105e50:	c1 e0 02             	shl    $0x2,%eax
  105e53:	05 28 df 11 00       	add    $0x11df28,%eax
  105e58:	8b 00                	mov    (%eax),%eax
  105e5a:	8d 48 01             	lea    0x1(%eax),%ecx
  105e5d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105e60:	89 d0                	mov    %edx,%eax
  105e62:	01 c0                	add    %eax,%eax
  105e64:	01 d0                	add    %edx,%eax
  105e66:	c1 e0 02             	shl    $0x2,%eax
  105e69:	05 28 df 11 00       	add    $0x11df28,%eax
  105e6e:	89 08                	mov    %ecx,(%eax)
    buddy_my_merge(level); 
  105e70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e73:	89 04 24             	mov    %eax,(%esp)
  105e76:	e8 d5 fa ff ff       	call   105950 <buddy_my_merge>
    //buddy_selfcheck();
}
  105e7b:	90                   	nop
  105e7c:	c9                   	leave  
  105e7d:	c3                   	ret    

00105e7e <buddy_check>:

static void
buddy_check(void) {
  105e7e:	55                   	push   %ebp
  105e7f:	89 e5                	mov    %esp,%ebp
  105e81:	81 ec f8 00 00 00    	sub    $0xf8,%esp
    int count = 0, total = 0;
  105e87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  105e8e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) {
  105e95:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  105e9c:	e9 a4 00 00 00       	jmp    105f45 <buddy_check+0xc7>
        list_entry_t* free_list = &(free_area[i].free_list);
  105ea1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105ea4:	89 d0                	mov    %edx,%eax
  105ea6:	01 c0                	add    %eax,%eax
  105ea8:	01 d0                	add    %edx,%eax
  105eaa:	c1 e0 02             	shl    $0x2,%eax
  105ead:	05 20 df 11 00       	add    $0x11df20,%eax
  105eb2:	89 45 d0             	mov    %eax,-0x30(%ebp)
        list_entry_t* le = free_list;
  105eb5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105eb8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        while ((le = list_next(le)) != free_list) {
  105ebb:	eb 6a                	jmp    105f27 <buddy_check+0xa9>
            struct Page* p = le2page(le, page_link);
  105ebd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ec0:	83 e8 0c             	sub    $0xc,%eax
  105ec3:	89 45 cc             	mov    %eax,-0x34(%ebp)
            assert(PageProperty(p));
  105ec6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105ec9:	83 c0 04             	add    $0x4,%eax
  105ecc:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  105ed3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105ed6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105ed9:	8b 55 c8             	mov    -0x38(%ebp),%edx
  105edc:	0f a3 10             	bt     %edx,(%eax)
  105edf:	19 c0                	sbb    %eax,%eax
  105ee1:	89 45 c0             	mov    %eax,-0x40(%ebp)
    return oldbit != 0;
  105ee4:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  105ee8:	0f 95 c0             	setne  %al
  105eeb:	0f b6 c0             	movzbl %al,%eax
  105eee:	85 c0                	test   %eax,%eax
  105ef0:	75 24                	jne    105f16 <buddy_check+0x98>
  105ef2:	c7 44 24 0c b5 80 10 	movl   $0x1080b5,0xc(%esp)
  105ef9:	00 
  105efa:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  105f01:	00 
  105f02:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  105f09:	00 
  105f0a:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  105f11:	e8 d3 a4 ff ff       	call   1003e9 <__panic>
            count++;
  105f16:	ff 45 f4             	incl   -0xc(%ebp)
            total += p->property;
  105f19:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105f1c:	8b 50 08             	mov    0x8(%eax),%edx
  105f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f22:	01 d0                	add    %edx,%eax
  105f24:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f27:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105f2a:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return listelm->next;
  105f2d:	8b 45 bc             	mov    -0x44(%ebp),%eax
  105f30:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != free_list) {
  105f33:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105f36:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105f39:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  105f3c:	0f 85 7b ff ff ff    	jne    105ebd <buddy_check+0x3f>
    for (int i = 0; i <= MAXLEVEL; i++) {
  105f42:	ff 45 ec             	incl   -0x14(%ebp)
  105f45:	83 7d ec 0c          	cmpl   $0xc,-0x14(%ebp)
  105f49:	0f 8e 52 ff ff ff    	jle    105ea1 <buddy_check+0x23>
        }
    }
    assert(total == buddy_nr_free_page());
  105f4f:	e8 98 f5 ff ff       	call   1054ec <buddy_nr_free_page>
  105f54:	89 c2                	mov    %eax,%edx
  105f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f59:	39 c2                	cmp    %eax,%edx
  105f5b:	74 24                	je     105f81 <buddy_check+0x103>
  105f5d:	c7 44 24 0c c5 80 10 	movl   $0x1080c5,0xc(%esp)
  105f64:	00 
  105f65:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  105f6c:	00 
  105f6d:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
  105f74:	00 
  105f75:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  105f7c:	e8 68 a4 ff ff       	call   1003e9 <__panic>

    // basic check
    struct Page *p0, *p1, *p2;
    p0 = p1 =p2 = NULL;
  105f81:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105f88:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105f8b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  105f8e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105f91:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("p0\n");
  105f94:	c7 04 24 e3 80 10 00 	movl   $0x1080e3,(%esp)
  105f9b:	e8 f2 a2 ff ff       	call   100292 <cprintf>
    assert((p0 = alloc_page()) != NULL);
  105fa0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105fa7:	e8 d0 cb ff ff       	call   102b7c <alloc_pages>
  105fac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  105faf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  105fb3:	75 24                	jne    105fd9 <buddy_check+0x15b>
  105fb5:	c7 44 24 0c e7 80 10 	movl   $0x1080e7,0xc(%esp)
  105fbc:	00 
  105fbd:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  105fc4:	00 
  105fc5:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  105fcc:	00 
  105fcd:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  105fd4:	e8 10 a4 ff ff       	call   1003e9 <__panic>
    cprintf("p1\n");
  105fd9:	c7 04 24 03 81 10 00 	movl   $0x108103,(%esp)
  105fe0:	e8 ad a2 ff ff       	call   100292 <cprintf>
    assert((p1 = alloc_page()) != NULL);
  105fe5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105fec:	e8 8b cb ff ff       	call   102b7c <alloc_pages>
  105ff1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  105ff4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  105ff8:	75 24                	jne    10601e <buddy_check+0x1a0>
  105ffa:	c7 44 24 0c 07 81 10 	movl   $0x108107,0xc(%esp)
  106001:	00 
  106002:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  106009:	00 
  10600a:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  106011:	00 
  106012:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  106019:	e8 cb a3 ff ff       	call   1003e9 <__panic>
    cprintf("p2\n");
  10601e:	c7 04 24 23 81 10 00 	movl   $0x108123,(%esp)
  106025:	e8 68 a2 ff ff       	call   100292 <cprintf>
    assert((p2 = alloc_page()) != NULL);
  10602a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  106031:	e8 46 cb ff ff       	call   102b7c <alloc_pages>
  106036:	89 45 dc             	mov    %eax,-0x24(%ebp)
  106039:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10603d:	75 24                	jne    106063 <buddy_check+0x1e5>
  10603f:	c7 44 24 0c 27 81 10 	movl   $0x108127,0xc(%esp)
  106046:	00 
  106047:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  10604e:	00 
  10604f:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
  106056:	00 
  106057:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  10605e:	e8 86 a3 ff ff       	call   1003e9 <__panic>

    assert(p0 != p1 && p1 != p2 && p2 != p0);
  106063:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  106066:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  106069:	74 10                	je     10607b <buddy_check+0x1fd>
  10606b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10606e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  106071:	74 08                	je     10607b <buddy_check+0x1fd>
  106073:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106076:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  106079:	75 24                	jne    10609f <buddy_check+0x221>
  10607b:	c7 44 24 0c 44 81 10 	movl   $0x108144,0xc(%esp)
  106082:	00 
  106083:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  10608a:	00 
  10608b:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  106092:	00 
  106093:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  10609a:	e8 4a a3 ff ff       	call   1003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  10609f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1060a2:	89 04 24             	mov    %eax,(%esp)
  1060a5:	e8 d0 f3 ff ff       	call   10547a <page_ref>
  1060aa:	85 c0                	test   %eax,%eax
  1060ac:	75 1e                	jne    1060cc <buddy_check+0x24e>
  1060ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1060b1:	89 04 24             	mov    %eax,(%esp)
  1060b4:	e8 c1 f3 ff ff       	call   10547a <page_ref>
  1060b9:	85 c0                	test   %eax,%eax
  1060bb:	75 0f                	jne    1060cc <buddy_check+0x24e>
  1060bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1060c0:	89 04 24             	mov    %eax,(%esp)
  1060c3:	e8 b2 f3 ff ff       	call   10547a <page_ref>
  1060c8:	85 c0                	test   %eax,%eax
  1060ca:	74 24                	je     1060f0 <buddy_check+0x272>
  1060cc:	c7 44 24 0c 68 81 10 	movl   $0x108168,0xc(%esp)
  1060d3:	00 
  1060d4:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  1060db:	00 
  1060dc:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
  1060e3:	00 
  1060e4:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  1060eb:	e8 f9 a2 ff ff       	call   1003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  1060f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1060f3:	89 04 24             	mov    %eax,(%esp)
  1060f6:	e8 69 f3 ff ff       	call   105464 <page2pa>
  1060fb:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  106101:	c1 e2 0c             	shl    $0xc,%edx
  106104:	39 d0                	cmp    %edx,%eax
  106106:	72 24                	jb     10612c <buddy_check+0x2ae>
  106108:	c7 44 24 0c a4 81 10 	movl   $0x1081a4,0xc(%esp)
  10610f:	00 
  106110:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  106117:	00 
  106118:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  10611f:	00 
  106120:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  106127:	e8 bd a2 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  10612c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10612f:	89 04 24             	mov    %eax,(%esp)
  106132:	e8 2d f3 ff ff       	call   105464 <page2pa>
  106137:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  10613d:	c1 e2 0c             	shl    $0xc,%edx
  106140:	39 d0                	cmp    %edx,%eax
  106142:	72 24                	jb     106168 <buddy_check+0x2ea>
  106144:	c7 44 24 0c c1 81 10 	movl   $0x1081c1,0xc(%esp)
  10614b:	00 
  10614c:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  106153:	00 
  106154:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  10615b:	00 
  10615c:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  106163:	e8 81 a2 ff ff       	call   1003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  106168:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10616b:	89 04 24             	mov    %eax,(%esp)
  10616e:	e8 f1 f2 ff ff       	call   105464 <page2pa>
  106173:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  106179:	c1 e2 0c             	shl    $0xc,%edx
  10617c:	39 d0                	cmp    %edx,%eax
  10617e:	72 24                	jb     1061a4 <buddy_check+0x326>
  106180:	c7 44 24 0c de 81 10 	movl   $0x1081de,0xc(%esp)
  106187:	00 
  106188:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  10618f:	00 
  106190:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  106197:	00 
  106198:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  10619f:	e8 45 a2 ff ff       	call   1003e9 <__panic>
    cprintf("first part of check successfully.\n");
  1061a4:	c7 04 24 fc 81 10 00 	movl   $0x1081fc,(%esp)
  1061ab:	e8 e2 a0 ff ff       	call   100292 <cprintf>

    free_area_t temp_list[MAXLEVEL + 1];
    for (int i = 0; i <= MAXLEVEL; i++) {
  1061b0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1061b7:	e9 c5 00 00 00       	jmp    106281 <buddy_check+0x403>
        temp_list[i] = free_area[i];
  1061bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1061bf:	89 d0                	mov    %edx,%eax
  1061c1:	01 c0                	add    %eax,%eax
  1061c3:	01 d0                	add    %edx,%eax
  1061c5:	c1 e0 02             	shl    $0x2,%eax
  1061c8:	8d 4d f8             	lea    -0x8(%ebp),%ecx
  1061cb:	01 c8                	add    %ecx,%eax
  1061cd:	8d 90 20 ff ff ff    	lea    -0xe0(%eax),%edx
  1061d3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  1061d6:	89 c8                	mov    %ecx,%eax
  1061d8:	01 c0                	add    %eax,%eax
  1061da:	01 c8                	add    %ecx,%eax
  1061dc:	c1 e0 02             	shl    $0x2,%eax
  1061df:	05 20 df 11 00       	add    $0x11df20,%eax
  1061e4:	8b 08                	mov    (%eax),%ecx
  1061e6:	89 0a                	mov    %ecx,(%edx)
  1061e8:	8b 48 04             	mov    0x4(%eax),%ecx
  1061eb:	89 4a 04             	mov    %ecx,0x4(%edx)
  1061ee:	8b 40 08             	mov    0x8(%eax),%eax
  1061f1:	89 42 08             	mov    %eax,0x8(%edx)
        list_init(&(free_area[i].free_list));
  1061f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1061f7:	89 d0                	mov    %edx,%eax
  1061f9:	01 c0                	add    %eax,%eax
  1061fb:	01 d0                	add    %edx,%eax
  1061fd:	c1 e0 02             	shl    $0x2,%eax
  106200:	05 20 df 11 00       	add    $0x11df20,%eax
  106205:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    elm->prev = elm->next = elm;
  106208:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10620b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  10620e:	89 50 04             	mov    %edx,0x4(%eax)
  106211:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  106214:	8b 50 04             	mov    0x4(%eax),%edx
  106217:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10621a:	89 10                	mov    %edx,(%eax)
        assert(list_empty(&(free_area[i])));
  10621c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10621f:	89 d0                	mov    %edx,%eax
  106221:	01 c0                	add    %eax,%eax
  106223:	01 d0                	add    %edx,%eax
  106225:	c1 e0 02             	shl    $0x2,%eax
  106228:	05 20 df 11 00       	add    $0x11df20,%eax
  10622d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return list->next == list;
  106230:	8b 45 b8             	mov    -0x48(%ebp),%eax
  106233:	8b 40 04             	mov    0x4(%eax),%eax
  106236:	39 45 b8             	cmp    %eax,-0x48(%ebp)
  106239:	0f 94 c0             	sete   %al
  10623c:	0f b6 c0             	movzbl %al,%eax
  10623f:	85 c0                	test   %eax,%eax
  106241:	75 24                	jne    106267 <buddy_check+0x3e9>
  106243:	c7 44 24 0c 1f 82 10 	movl   $0x10821f,0xc(%esp)
  10624a:	00 
  10624b:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  106252:	00 
  106253:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  10625a:	00 
  10625b:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  106262:	e8 82 a1 ff ff       	call   1003e9 <__panic>
        free_area[i].nr_free = 0;
  106267:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10626a:	89 d0                	mov    %edx,%eax
  10626c:	01 c0                	add    %eax,%eax
  10626e:	01 d0                	add    %edx,%eax
  106270:	c1 e0 02             	shl    $0x2,%eax
  106273:	05 28 df 11 00       	add    $0x11df28,%eax
  106278:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    for (int i = 0; i <= MAXLEVEL; i++) {
  10627e:	ff 45 e4             	incl   -0x1c(%ebp)
  106281:	83 7d e4 0c          	cmpl   $0xc,-0x1c(%ebp)
  106285:	0f 8e 31 ff ff ff    	jle    1061bc <buddy_check+0x33e>
    }
    assert(alloc_page() == NULL);
  10628b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  106292:	e8 e5 c8 ff ff       	call   102b7c <alloc_pages>
  106297:	85 c0                	test   %eax,%eax
  106299:	74 24                	je     1062bf <buddy_check+0x441>
  10629b:	c7 44 24 0c 3b 82 10 	movl   $0x10823b,0xc(%esp)
  1062a2:	00 
  1062a3:	c7 44 24 08 e0 7f 10 	movl   $0x107fe0,0x8(%esp)
  1062aa:	00 
  1062ab:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  1062b2:	00 
  1062b3:	c7 04 24 f5 7f 10 00 	movl   $0x107ff5,(%esp)
  1062ba:	e8 2a a1 ff ff       	call   1003e9 <__panic>
    cprintf("clean successfully.\n");
  1062bf:	c7 04 24 50 82 10 00 	movl   $0x108250,(%esp)
  1062c6:	e8 c7 9f ff ff       	call   100292 <cprintf>
    cprintf("p0\n");
  1062cb:	c7 04 24 e3 80 10 00 	movl   $0x1080e3,(%esp)
  1062d2:	e8 bb 9f ff ff       	call   100292 <cprintf>
    free_page(p0);
  1062d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1062de:	00 
  1062df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1062e2:	89 04 24             	mov    %eax,(%esp)
  1062e5:	e8 ca c8 ff ff       	call   102bb4 <free_pages>
    cprintf("p1\n");
  1062ea:	c7 04 24 03 81 10 00 	movl   $0x108103,(%esp)
  1062f1:	e8 9c 9f ff ff       	call   100292 <cprintf>
    free_page(p1);
  1062f6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1062fd:	00 
  1062fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  106301:	89 04 24             	mov    %eax,(%esp)
  106304:	e8 ab c8 ff ff       	call   102bb4 <free_pages>
    cprintf("p2\n");
  106309:	c7 04 24 23 81 10 00 	movl   $0x108123,(%esp)
  106310:	e8 7d 9f ff ff       	call   100292 <cprintf>
    free_page(p2);
  106315:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10631c:	00 
  10631d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106320:	89 04 24             	mov    %eax,(%esp)
  106323:	e8 8c c8 ff ff       	call   102bb4 <free_pages>
    total = 0;
  106328:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
  10632f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  106336:	eb 1e                	jmp    106356 <buddy_check+0x4d8>
        total += free_area[i].nr_free;
  106338:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10633b:	89 d0                	mov    %edx,%eax
  10633d:	01 c0                	add    %eax,%eax
  10633f:	01 d0                	add    %edx,%eax
  106341:	c1 e0 02             	shl    $0x2,%eax
  106344:	05 28 df 11 00       	add    $0x11df28,%eax
  106349:	8b 10                	mov    (%eax),%edx
  10634b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10634e:	01 d0                	add    %edx,%eax
  106350:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
  106353:	ff 45 e0             	incl   -0x20(%ebp)
  106356:	83 7d e0 0c          	cmpl   $0xc,-0x20(%ebp)
  10635a:	7e dc                	jle    106338 <buddy_check+0x4ba>

    //assert((p0 = alloc_page()) != NULL);
    //assert((p1 = alloc_page()) != NULL);
    //assert((p2 = alloc_page()) != NULL);
    //assert(alloc_page() == NULL);
}
  10635c:	90                   	nop
  10635d:	c9                   	leave  
  10635e:	c3                   	ret    

0010635f <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  10635f:	55                   	push   %ebp
  106360:	89 e5                	mov    %esp,%ebp
  106362:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  106365:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  10636c:	eb 03                	jmp    106371 <strlen+0x12>
        cnt ++;
  10636e:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  106371:	8b 45 08             	mov    0x8(%ebp),%eax
  106374:	8d 50 01             	lea    0x1(%eax),%edx
  106377:	89 55 08             	mov    %edx,0x8(%ebp)
  10637a:	0f b6 00             	movzbl (%eax),%eax
  10637d:	84 c0                	test   %al,%al
  10637f:	75 ed                	jne    10636e <strlen+0xf>
    }
    return cnt;
  106381:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  106384:	c9                   	leave  
  106385:	c3                   	ret    

00106386 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  106386:	55                   	push   %ebp
  106387:	89 e5                	mov    %esp,%ebp
  106389:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  10638c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  106393:	eb 03                	jmp    106398 <strnlen+0x12>
        cnt ++;
  106395:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  106398:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10639b:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10639e:	73 10                	jae    1063b0 <strnlen+0x2a>
  1063a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1063a3:	8d 50 01             	lea    0x1(%eax),%edx
  1063a6:	89 55 08             	mov    %edx,0x8(%ebp)
  1063a9:	0f b6 00             	movzbl (%eax),%eax
  1063ac:	84 c0                	test   %al,%al
  1063ae:	75 e5                	jne    106395 <strnlen+0xf>
    }
    return cnt;
  1063b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1063b3:	c9                   	leave  
  1063b4:	c3                   	ret    

001063b5 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1063b5:	55                   	push   %ebp
  1063b6:	89 e5                	mov    %esp,%ebp
  1063b8:	57                   	push   %edi
  1063b9:	56                   	push   %esi
  1063ba:	83 ec 20             	sub    $0x20,%esp
  1063bd:	8b 45 08             	mov    0x8(%ebp),%eax
  1063c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1063c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  1063c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1063cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1063cf:	89 d1                	mov    %edx,%ecx
  1063d1:	89 c2                	mov    %eax,%edx
  1063d3:	89 ce                	mov    %ecx,%esi
  1063d5:	89 d7                	mov    %edx,%edi
  1063d7:	ac                   	lods   %ds:(%esi),%al
  1063d8:	aa                   	stos   %al,%es:(%edi)
  1063d9:	84 c0                	test   %al,%al
  1063db:	75 fa                	jne    1063d7 <strcpy+0x22>
  1063dd:	89 fa                	mov    %edi,%edx
  1063df:	89 f1                	mov    %esi,%ecx
  1063e1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1063e4:	89 55 e8             	mov    %edx,-0x18(%ebp)
  1063e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  1063ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  1063ed:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1063ee:	83 c4 20             	add    $0x20,%esp
  1063f1:	5e                   	pop    %esi
  1063f2:	5f                   	pop    %edi
  1063f3:	5d                   	pop    %ebp
  1063f4:	c3                   	ret    

001063f5 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1063f5:	55                   	push   %ebp
  1063f6:	89 e5                	mov    %esp,%ebp
  1063f8:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  1063fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1063fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  106401:	eb 1e                	jmp    106421 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  106403:	8b 45 0c             	mov    0xc(%ebp),%eax
  106406:	0f b6 10             	movzbl (%eax),%edx
  106409:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10640c:	88 10                	mov    %dl,(%eax)
  10640e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106411:	0f b6 00             	movzbl (%eax),%eax
  106414:	84 c0                	test   %al,%al
  106416:	74 03                	je     10641b <strncpy+0x26>
            src ++;
  106418:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  10641b:	ff 45 fc             	incl   -0x4(%ebp)
  10641e:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  106421:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106425:	75 dc                	jne    106403 <strncpy+0xe>
    }
    return dst;
  106427:	8b 45 08             	mov    0x8(%ebp),%eax
}
  10642a:	c9                   	leave  
  10642b:	c3                   	ret    

0010642c <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  10642c:	55                   	push   %ebp
  10642d:	89 e5                	mov    %esp,%ebp
  10642f:	57                   	push   %edi
  106430:	56                   	push   %esi
  106431:	83 ec 20             	sub    $0x20,%esp
  106434:	8b 45 08             	mov    0x8(%ebp),%eax
  106437:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10643a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10643d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  106440:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106443:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106446:	89 d1                	mov    %edx,%ecx
  106448:	89 c2                	mov    %eax,%edx
  10644a:	89 ce                	mov    %ecx,%esi
  10644c:	89 d7                	mov    %edx,%edi
  10644e:	ac                   	lods   %ds:(%esi),%al
  10644f:	ae                   	scas   %es:(%edi),%al
  106450:	75 08                	jne    10645a <strcmp+0x2e>
  106452:	84 c0                	test   %al,%al
  106454:	75 f8                	jne    10644e <strcmp+0x22>
  106456:	31 c0                	xor    %eax,%eax
  106458:	eb 04                	jmp    10645e <strcmp+0x32>
  10645a:	19 c0                	sbb    %eax,%eax
  10645c:	0c 01                	or     $0x1,%al
  10645e:	89 fa                	mov    %edi,%edx
  106460:	89 f1                	mov    %esi,%ecx
  106462:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106465:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  106468:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  10646b:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  10646e:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  10646f:	83 c4 20             	add    $0x20,%esp
  106472:	5e                   	pop    %esi
  106473:	5f                   	pop    %edi
  106474:	5d                   	pop    %ebp
  106475:	c3                   	ret    

00106476 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  106476:	55                   	push   %ebp
  106477:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  106479:	eb 09                	jmp    106484 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  10647b:	ff 4d 10             	decl   0x10(%ebp)
  10647e:	ff 45 08             	incl   0x8(%ebp)
  106481:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  106484:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106488:	74 1a                	je     1064a4 <strncmp+0x2e>
  10648a:	8b 45 08             	mov    0x8(%ebp),%eax
  10648d:	0f b6 00             	movzbl (%eax),%eax
  106490:	84 c0                	test   %al,%al
  106492:	74 10                	je     1064a4 <strncmp+0x2e>
  106494:	8b 45 08             	mov    0x8(%ebp),%eax
  106497:	0f b6 10             	movzbl (%eax),%edx
  10649a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10649d:	0f b6 00             	movzbl (%eax),%eax
  1064a0:	38 c2                	cmp    %al,%dl
  1064a2:	74 d7                	je     10647b <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  1064a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1064a8:	74 18                	je     1064c2 <strncmp+0x4c>
  1064aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1064ad:	0f b6 00             	movzbl (%eax),%eax
  1064b0:	0f b6 d0             	movzbl %al,%edx
  1064b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1064b6:	0f b6 00             	movzbl (%eax),%eax
  1064b9:	0f b6 c0             	movzbl %al,%eax
  1064bc:	29 c2                	sub    %eax,%edx
  1064be:	89 d0                	mov    %edx,%eax
  1064c0:	eb 05                	jmp    1064c7 <strncmp+0x51>
  1064c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1064c7:	5d                   	pop    %ebp
  1064c8:	c3                   	ret    

001064c9 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  1064c9:	55                   	push   %ebp
  1064ca:	89 e5                	mov    %esp,%ebp
  1064cc:	83 ec 04             	sub    $0x4,%esp
  1064cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1064d2:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1064d5:	eb 13                	jmp    1064ea <strchr+0x21>
        if (*s == c) {
  1064d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1064da:	0f b6 00             	movzbl (%eax),%eax
  1064dd:	38 45 fc             	cmp    %al,-0x4(%ebp)
  1064e0:	75 05                	jne    1064e7 <strchr+0x1e>
            return (char *)s;
  1064e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1064e5:	eb 12                	jmp    1064f9 <strchr+0x30>
        }
        s ++;
  1064e7:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  1064ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1064ed:	0f b6 00             	movzbl (%eax),%eax
  1064f0:	84 c0                	test   %al,%al
  1064f2:	75 e3                	jne    1064d7 <strchr+0xe>
    }
    return NULL;
  1064f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1064f9:	c9                   	leave  
  1064fa:	c3                   	ret    

001064fb <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  1064fb:	55                   	push   %ebp
  1064fc:	89 e5                	mov    %esp,%ebp
  1064fe:	83 ec 04             	sub    $0x4,%esp
  106501:	8b 45 0c             	mov    0xc(%ebp),%eax
  106504:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  106507:	eb 0e                	jmp    106517 <strfind+0x1c>
        if (*s == c) {
  106509:	8b 45 08             	mov    0x8(%ebp),%eax
  10650c:	0f b6 00             	movzbl (%eax),%eax
  10650f:	38 45 fc             	cmp    %al,-0x4(%ebp)
  106512:	74 0f                	je     106523 <strfind+0x28>
            break;
        }
        s ++;
  106514:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  106517:	8b 45 08             	mov    0x8(%ebp),%eax
  10651a:	0f b6 00             	movzbl (%eax),%eax
  10651d:	84 c0                	test   %al,%al
  10651f:	75 e8                	jne    106509 <strfind+0xe>
  106521:	eb 01                	jmp    106524 <strfind+0x29>
            break;
  106523:	90                   	nop
    }
    return (char *)s;
  106524:	8b 45 08             	mov    0x8(%ebp),%eax
}
  106527:	c9                   	leave  
  106528:	c3                   	ret    

00106529 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  106529:	55                   	push   %ebp
  10652a:	89 e5                	mov    %esp,%ebp
  10652c:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  10652f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  106536:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  10653d:	eb 03                	jmp    106542 <strtol+0x19>
        s ++;
  10653f:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  106542:	8b 45 08             	mov    0x8(%ebp),%eax
  106545:	0f b6 00             	movzbl (%eax),%eax
  106548:	3c 20                	cmp    $0x20,%al
  10654a:	74 f3                	je     10653f <strtol+0x16>
  10654c:	8b 45 08             	mov    0x8(%ebp),%eax
  10654f:	0f b6 00             	movzbl (%eax),%eax
  106552:	3c 09                	cmp    $0x9,%al
  106554:	74 e9                	je     10653f <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  106556:	8b 45 08             	mov    0x8(%ebp),%eax
  106559:	0f b6 00             	movzbl (%eax),%eax
  10655c:	3c 2b                	cmp    $0x2b,%al
  10655e:	75 05                	jne    106565 <strtol+0x3c>
        s ++;
  106560:	ff 45 08             	incl   0x8(%ebp)
  106563:	eb 14                	jmp    106579 <strtol+0x50>
    }
    else if (*s == '-') {
  106565:	8b 45 08             	mov    0x8(%ebp),%eax
  106568:	0f b6 00             	movzbl (%eax),%eax
  10656b:	3c 2d                	cmp    $0x2d,%al
  10656d:	75 0a                	jne    106579 <strtol+0x50>
        s ++, neg = 1;
  10656f:	ff 45 08             	incl   0x8(%ebp)
  106572:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  106579:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10657d:	74 06                	je     106585 <strtol+0x5c>
  10657f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  106583:	75 22                	jne    1065a7 <strtol+0x7e>
  106585:	8b 45 08             	mov    0x8(%ebp),%eax
  106588:	0f b6 00             	movzbl (%eax),%eax
  10658b:	3c 30                	cmp    $0x30,%al
  10658d:	75 18                	jne    1065a7 <strtol+0x7e>
  10658f:	8b 45 08             	mov    0x8(%ebp),%eax
  106592:	40                   	inc    %eax
  106593:	0f b6 00             	movzbl (%eax),%eax
  106596:	3c 78                	cmp    $0x78,%al
  106598:	75 0d                	jne    1065a7 <strtol+0x7e>
        s += 2, base = 16;
  10659a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  10659e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  1065a5:	eb 29                	jmp    1065d0 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  1065a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1065ab:	75 16                	jne    1065c3 <strtol+0x9a>
  1065ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1065b0:	0f b6 00             	movzbl (%eax),%eax
  1065b3:	3c 30                	cmp    $0x30,%al
  1065b5:	75 0c                	jne    1065c3 <strtol+0x9a>
        s ++, base = 8;
  1065b7:	ff 45 08             	incl   0x8(%ebp)
  1065ba:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  1065c1:	eb 0d                	jmp    1065d0 <strtol+0xa7>
    }
    else if (base == 0) {
  1065c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1065c7:	75 07                	jne    1065d0 <strtol+0xa7>
        base = 10;
  1065c9:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  1065d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1065d3:	0f b6 00             	movzbl (%eax),%eax
  1065d6:	3c 2f                	cmp    $0x2f,%al
  1065d8:	7e 1b                	jle    1065f5 <strtol+0xcc>
  1065da:	8b 45 08             	mov    0x8(%ebp),%eax
  1065dd:	0f b6 00             	movzbl (%eax),%eax
  1065e0:	3c 39                	cmp    $0x39,%al
  1065e2:	7f 11                	jg     1065f5 <strtol+0xcc>
            dig = *s - '0';
  1065e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1065e7:	0f b6 00             	movzbl (%eax),%eax
  1065ea:	0f be c0             	movsbl %al,%eax
  1065ed:	83 e8 30             	sub    $0x30,%eax
  1065f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1065f3:	eb 48                	jmp    10663d <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  1065f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1065f8:	0f b6 00             	movzbl (%eax),%eax
  1065fb:	3c 60                	cmp    $0x60,%al
  1065fd:	7e 1b                	jle    10661a <strtol+0xf1>
  1065ff:	8b 45 08             	mov    0x8(%ebp),%eax
  106602:	0f b6 00             	movzbl (%eax),%eax
  106605:	3c 7a                	cmp    $0x7a,%al
  106607:	7f 11                	jg     10661a <strtol+0xf1>
            dig = *s - 'a' + 10;
  106609:	8b 45 08             	mov    0x8(%ebp),%eax
  10660c:	0f b6 00             	movzbl (%eax),%eax
  10660f:	0f be c0             	movsbl %al,%eax
  106612:	83 e8 57             	sub    $0x57,%eax
  106615:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106618:	eb 23                	jmp    10663d <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  10661a:	8b 45 08             	mov    0x8(%ebp),%eax
  10661d:	0f b6 00             	movzbl (%eax),%eax
  106620:	3c 40                	cmp    $0x40,%al
  106622:	7e 3b                	jle    10665f <strtol+0x136>
  106624:	8b 45 08             	mov    0x8(%ebp),%eax
  106627:	0f b6 00             	movzbl (%eax),%eax
  10662a:	3c 5a                	cmp    $0x5a,%al
  10662c:	7f 31                	jg     10665f <strtol+0x136>
            dig = *s - 'A' + 10;
  10662e:	8b 45 08             	mov    0x8(%ebp),%eax
  106631:	0f b6 00             	movzbl (%eax),%eax
  106634:	0f be c0             	movsbl %al,%eax
  106637:	83 e8 37             	sub    $0x37,%eax
  10663a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  10663d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106640:	3b 45 10             	cmp    0x10(%ebp),%eax
  106643:	7d 19                	jge    10665e <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  106645:	ff 45 08             	incl   0x8(%ebp)
  106648:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10664b:	0f af 45 10          	imul   0x10(%ebp),%eax
  10664f:	89 c2                	mov    %eax,%edx
  106651:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106654:	01 d0                	add    %edx,%eax
  106656:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  106659:	e9 72 ff ff ff       	jmp    1065d0 <strtol+0xa7>
            break;
  10665e:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  10665f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  106663:	74 08                	je     10666d <strtol+0x144>
        *endptr = (char *) s;
  106665:	8b 45 0c             	mov    0xc(%ebp),%eax
  106668:	8b 55 08             	mov    0x8(%ebp),%edx
  10666b:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  10666d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  106671:	74 07                	je     10667a <strtol+0x151>
  106673:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106676:	f7 d8                	neg    %eax
  106678:	eb 03                	jmp    10667d <strtol+0x154>
  10667a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  10667d:	c9                   	leave  
  10667e:	c3                   	ret    

0010667f <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  10667f:	55                   	push   %ebp
  106680:	89 e5                	mov    %esp,%ebp
  106682:	57                   	push   %edi
  106683:	83 ec 24             	sub    $0x24,%esp
  106686:	8b 45 0c             	mov    0xc(%ebp),%eax
  106689:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  10668c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  106690:	8b 55 08             	mov    0x8(%ebp),%edx
  106693:	89 55 f8             	mov    %edx,-0x8(%ebp)
  106696:	88 45 f7             	mov    %al,-0x9(%ebp)
  106699:	8b 45 10             	mov    0x10(%ebp),%eax
  10669c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  10669f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1066a2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1066a6:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1066a9:	89 d7                	mov    %edx,%edi
  1066ab:	f3 aa                	rep stos %al,%es:(%edi)
  1066ad:	89 fa                	mov    %edi,%edx
  1066af:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1066b2:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  1066b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1066b8:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  1066b9:	83 c4 24             	add    $0x24,%esp
  1066bc:	5f                   	pop    %edi
  1066bd:	5d                   	pop    %ebp
  1066be:	c3                   	ret    

001066bf <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  1066bf:	55                   	push   %ebp
  1066c0:	89 e5                	mov    %esp,%ebp
  1066c2:	57                   	push   %edi
  1066c3:	56                   	push   %esi
  1066c4:	53                   	push   %ebx
  1066c5:	83 ec 30             	sub    $0x30,%esp
  1066c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1066cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1066ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1066d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1066d4:	8b 45 10             	mov    0x10(%ebp),%eax
  1066d7:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1066da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1066dd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1066e0:	73 42                	jae    106724 <memmove+0x65>
  1066e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1066e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1066e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1066eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1066ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1066f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1066f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1066f7:	c1 e8 02             	shr    $0x2,%eax
  1066fa:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1066fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1066ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106702:	89 d7                	mov    %edx,%edi
  106704:	89 c6                	mov    %eax,%esi
  106706:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  106708:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10670b:	83 e1 03             	and    $0x3,%ecx
  10670e:	74 02                	je     106712 <memmove+0x53>
  106710:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106712:	89 f0                	mov    %esi,%eax
  106714:	89 fa                	mov    %edi,%edx
  106716:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  106719:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10671c:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  10671f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  106722:	eb 36                	jmp    10675a <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  106724:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106727:	8d 50 ff             	lea    -0x1(%eax),%edx
  10672a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10672d:	01 c2                	add    %eax,%edx
  10672f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106732:	8d 48 ff             	lea    -0x1(%eax),%ecx
  106735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106738:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  10673b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10673e:	89 c1                	mov    %eax,%ecx
  106740:	89 d8                	mov    %ebx,%eax
  106742:	89 d6                	mov    %edx,%esi
  106744:	89 c7                	mov    %eax,%edi
  106746:	fd                   	std    
  106747:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106749:	fc                   	cld    
  10674a:	89 f8                	mov    %edi,%eax
  10674c:	89 f2                	mov    %esi,%edx
  10674e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  106751:	89 55 c8             	mov    %edx,-0x38(%ebp)
  106754:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  106757:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  10675a:	83 c4 30             	add    $0x30,%esp
  10675d:	5b                   	pop    %ebx
  10675e:	5e                   	pop    %esi
  10675f:	5f                   	pop    %edi
  106760:	5d                   	pop    %ebp
  106761:	c3                   	ret    

00106762 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  106762:	55                   	push   %ebp
  106763:	89 e5                	mov    %esp,%ebp
  106765:	57                   	push   %edi
  106766:	56                   	push   %esi
  106767:	83 ec 20             	sub    $0x20,%esp
  10676a:	8b 45 08             	mov    0x8(%ebp),%eax
  10676d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106770:	8b 45 0c             	mov    0xc(%ebp),%eax
  106773:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106776:	8b 45 10             	mov    0x10(%ebp),%eax
  106779:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10677c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10677f:	c1 e8 02             	shr    $0x2,%eax
  106782:	89 c1                	mov    %eax,%ecx
    asm volatile (
  106784:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10678a:	89 d7                	mov    %edx,%edi
  10678c:	89 c6                	mov    %eax,%esi
  10678e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  106790:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  106793:	83 e1 03             	and    $0x3,%ecx
  106796:	74 02                	je     10679a <memcpy+0x38>
  106798:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10679a:	89 f0                	mov    %esi,%eax
  10679c:	89 fa                	mov    %edi,%edx
  10679e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1067a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1067a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  1067a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  1067aa:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  1067ab:	83 c4 20             	add    $0x20,%esp
  1067ae:	5e                   	pop    %esi
  1067af:	5f                   	pop    %edi
  1067b0:	5d                   	pop    %ebp
  1067b1:	c3                   	ret    

001067b2 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  1067b2:	55                   	push   %ebp
  1067b3:	89 e5                	mov    %esp,%ebp
  1067b5:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  1067b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1067bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1067be:	8b 45 0c             	mov    0xc(%ebp),%eax
  1067c1:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1067c4:	eb 2e                	jmp    1067f4 <memcmp+0x42>
        if (*s1 != *s2) {
  1067c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1067c9:	0f b6 10             	movzbl (%eax),%edx
  1067cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1067cf:	0f b6 00             	movzbl (%eax),%eax
  1067d2:	38 c2                	cmp    %al,%dl
  1067d4:	74 18                	je     1067ee <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1067d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1067d9:	0f b6 00             	movzbl (%eax),%eax
  1067dc:	0f b6 d0             	movzbl %al,%edx
  1067df:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1067e2:	0f b6 00             	movzbl (%eax),%eax
  1067e5:	0f b6 c0             	movzbl %al,%eax
  1067e8:	29 c2                	sub    %eax,%edx
  1067ea:	89 d0                	mov    %edx,%eax
  1067ec:	eb 18                	jmp    106806 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  1067ee:	ff 45 fc             	incl   -0x4(%ebp)
  1067f1:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  1067f4:	8b 45 10             	mov    0x10(%ebp),%eax
  1067f7:	8d 50 ff             	lea    -0x1(%eax),%edx
  1067fa:	89 55 10             	mov    %edx,0x10(%ebp)
  1067fd:	85 c0                	test   %eax,%eax
  1067ff:	75 c5                	jne    1067c6 <memcmp+0x14>
    }
    return 0;
  106801:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106806:	c9                   	leave  
  106807:	c3                   	ret    

00106808 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  106808:	55                   	push   %ebp
  106809:	89 e5                	mov    %esp,%ebp
  10680b:	83 ec 58             	sub    $0x58,%esp
  10680e:	8b 45 10             	mov    0x10(%ebp),%eax
  106811:	89 45 d0             	mov    %eax,-0x30(%ebp)
  106814:	8b 45 14             	mov    0x14(%ebp),%eax
  106817:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  10681a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10681d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  106820:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106823:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  106826:	8b 45 18             	mov    0x18(%ebp),%eax
  106829:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10682c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10682f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106832:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106835:	89 55 f0             	mov    %edx,-0x10(%ebp)
  106838:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10683b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10683e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  106842:	74 1c                	je     106860 <printnum+0x58>
  106844:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106847:	ba 00 00 00 00       	mov    $0x0,%edx
  10684c:	f7 75 e4             	divl   -0x1c(%ebp)
  10684f:	89 55 f4             	mov    %edx,-0xc(%ebp)
  106852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106855:	ba 00 00 00 00       	mov    $0x0,%edx
  10685a:	f7 75 e4             	divl   -0x1c(%ebp)
  10685d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106860:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106863:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106866:	f7 75 e4             	divl   -0x1c(%ebp)
  106869:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10686c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10686f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106872:	8b 55 f0             	mov    -0x10(%ebp),%edx
  106875:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106878:	89 55 ec             	mov    %edx,-0x14(%ebp)
  10687b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10687e:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  106881:	8b 45 18             	mov    0x18(%ebp),%eax
  106884:	ba 00 00 00 00       	mov    $0x0,%edx
  106889:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  10688c:	72 56                	jb     1068e4 <printnum+0xdc>
  10688e:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  106891:	77 05                	ja     106898 <printnum+0x90>
  106893:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  106896:	72 4c                	jb     1068e4 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  106898:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10689b:	8d 50 ff             	lea    -0x1(%eax),%edx
  10689e:	8b 45 20             	mov    0x20(%ebp),%eax
  1068a1:	89 44 24 18          	mov    %eax,0x18(%esp)
  1068a5:	89 54 24 14          	mov    %edx,0x14(%esp)
  1068a9:	8b 45 18             	mov    0x18(%ebp),%eax
  1068ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  1068b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1068b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1068b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1068ba:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1068be:	8b 45 0c             	mov    0xc(%ebp),%eax
  1068c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1068c5:	8b 45 08             	mov    0x8(%ebp),%eax
  1068c8:	89 04 24             	mov    %eax,(%esp)
  1068cb:	e8 38 ff ff ff       	call   106808 <printnum>
  1068d0:	eb 1b                	jmp    1068ed <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1068d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1068d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1068d9:	8b 45 20             	mov    0x20(%ebp),%eax
  1068dc:	89 04 24             	mov    %eax,(%esp)
  1068df:	8b 45 08             	mov    0x8(%ebp),%eax
  1068e2:	ff d0                	call   *%eax
        while (-- width > 0)
  1068e4:	ff 4d 1c             	decl   0x1c(%ebp)
  1068e7:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1068eb:	7f e5                	jg     1068d2 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1068ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1068f0:	05 10 83 10 00       	add    $0x108310,%eax
  1068f5:	0f b6 00             	movzbl (%eax),%eax
  1068f8:	0f be c0             	movsbl %al,%eax
  1068fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  1068fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  106902:	89 04 24             	mov    %eax,(%esp)
  106905:	8b 45 08             	mov    0x8(%ebp),%eax
  106908:	ff d0                	call   *%eax
}
  10690a:	90                   	nop
  10690b:	c9                   	leave  
  10690c:	c3                   	ret    

0010690d <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  10690d:	55                   	push   %ebp
  10690e:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  106910:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  106914:	7e 14                	jle    10692a <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  106916:	8b 45 08             	mov    0x8(%ebp),%eax
  106919:	8b 00                	mov    (%eax),%eax
  10691b:	8d 48 08             	lea    0x8(%eax),%ecx
  10691e:	8b 55 08             	mov    0x8(%ebp),%edx
  106921:	89 0a                	mov    %ecx,(%edx)
  106923:	8b 50 04             	mov    0x4(%eax),%edx
  106926:	8b 00                	mov    (%eax),%eax
  106928:	eb 30                	jmp    10695a <getuint+0x4d>
    }
    else if (lflag) {
  10692a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10692e:	74 16                	je     106946 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  106930:	8b 45 08             	mov    0x8(%ebp),%eax
  106933:	8b 00                	mov    (%eax),%eax
  106935:	8d 48 04             	lea    0x4(%eax),%ecx
  106938:	8b 55 08             	mov    0x8(%ebp),%edx
  10693b:	89 0a                	mov    %ecx,(%edx)
  10693d:	8b 00                	mov    (%eax),%eax
  10693f:	ba 00 00 00 00       	mov    $0x0,%edx
  106944:	eb 14                	jmp    10695a <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  106946:	8b 45 08             	mov    0x8(%ebp),%eax
  106949:	8b 00                	mov    (%eax),%eax
  10694b:	8d 48 04             	lea    0x4(%eax),%ecx
  10694e:	8b 55 08             	mov    0x8(%ebp),%edx
  106951:	89 0a                	mov    %ecx,(%edx)
  106953:	8b 00                	mov    (%eax),%eax
  106955:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  10695a:	5d                   	pop    %ebp
  10695b:	c3                   	ret    

0010695c <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  10695c:	55                   	push   %ebp
  10695d:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10695f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  106963:	7e 14                	jle    106979 <getint+0x1d>
        return va_arg(*ap, long long);
  106965:	8b 45 08             	mov    0x8(%ebp),%eax
  106968:	8b 00                	mov    (%eax),%eax
  10696a:	8d 48 08             	lea    0x8(%eax),%ecx
  10696d:	8b 55 08             	mov    0x8(%ebp),%edx
  106970:	89 0a                	mov    %ecx,(%edx)
  106972:	8b 50 04             	mov    0x4(%eax),%edx
  106975:	8b 00                	mov    (%eax),%eax
  106977:	eb 28                	jmp    1069a1 <getint+0x45>
    }
    else if (lflag) {
  106979:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10697d:	74 12                	je     106991 <getint+0x35>
        return va_arg(*ap, long);
  10697f:	8b 45 08             	mov    0x8(%ebp),%eax
  106982:	8b 00                	mov    (%eax),%eax
  106984:	8d 48 04             	lea    0x4(%eax),%ecx
  106987:	8b 55 08             	mov    0x8(%ebp),%edx
  10698a:	89 0a                	mov    %ecx,(%edx)
  10698c:	8b 00                	mov    (%eax),%eax
  10698e:	99                   	cltd   
  10698f:	eb 10                	jmp    1069a1 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  106991:	8b 45 08             	mov    0x8(%ebp),%eax
  106994:	8b 00                	mov    (%eax),%eax
  106996:	8d 48 04             	lea    0x4(%eax),%ecx
  106999:	8b 55 08             	mov    0x8(%ebp),%edx
  10699c:	89 0a                	mov    %ecx,(%edx)
  10699e:	8b 00                	mov    (%eax),%eax
  1069a0:	99                   	cltd   
    }
}
  1069a1:	5d                   	pop    %ebp
  1069a2:	c3                   	ret    

001069a3 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1069a3:	55                   	push   %ebp
  1069a4:	89 e5                	mov    %esp,%ebp
  1069a6:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  1069a9:	8d 45 14             	lea    0x14(%ebp),%eax
  1069ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1069af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1069b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1069b6:	8b 45 10             	mov    0x10(%ebp),%eax
  1069b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1069bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1069c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1069c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1069c7:	89 04 24             	mov    %eax,(%esp)
  1069ca:	e8 03 00 00 00       	call   1069d2 <vprintfmt>
    va_end(ap);
}
  1069cf:	90                   	nop
  1069d0:	c9                   	leave  
  1069d1:	c3                   	ret    

001069d2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1069d2:	55                   	push   %ebp
  1069d3:	89 e5                	mov    %esp,%ebp
  1069d5:	56                   	push   %esi
  1069d6:	53                   	push   %ebx
  1069d7:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1069da:	eb 17                	jmp    1069f3 <vprintfmt+0x21>
            if (ch == '\0') {
  1069dc:	85 db                	test   %ebx,%ebx
  1069de:	0f 84 bf 03 00 00    	je     106da3 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  1069e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1069e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1069eb:	89 1c 24             	mov    %ebx,(%esp)
  1069ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1069f1:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1069f3:	8b 45 10             	mov    0x10(%ebp),%eax
  1069f6:	8d 50 01             	lea    0x1(%eax),%edx
  1069f9:	89 55 10             	mov    %edx,0x10(%ebp)
  1069fc:	0f b6 00             	movzbl (%eax),%eax
  1069ff:	0f b6 d8             	movzbl %al,%ebx
  106a02:	83 fb 25             	cmp    $0x25,%ebx
  106a05:	75 d5                	jne    1069dc <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  106a07:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  106a0b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  106a12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106a15:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  106a18:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  106a1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106a22:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  106a25:	8b 45 10             	mov    0x10(%ebp),%eax
  106a28:	8d 50 01             	lea    0x1(%eax),%edx
  106a2b:	89 55 10             	mov    %edx,0x10(%ebp)
  106a2e:	0f b6 00             	movzbl (%eax),%eax
  106a31:	0f b6 d8             	movzbl %al,%ebx
  106a34:	8d 43 dd             	lea    -0x23(%ebx),%eax
  106a37:	83 f8 55             	cmp    $0x55,%eax
  106a3a:	0f 87 37 03 00 00    	ja     106d77 <vprintfmt+0x3a5>
  106a40:	8b 04 85 34 83 10 00 	mov    0x108334(,%eax,4),%eax
  106a47:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  106a49:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  106a4d:	eb d6                	jmp    106a25 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  106a4f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  106a53:	eb d0                	jmp    106a25 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  106a55:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  106a5c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106a5f:	89 d0                	mov    %edx,%eax
  106a61:	c1 e0 02             	shl    $0x2,%eax
  106a64:	01 d0                	add    %edx,%eax
  106a66:	01 c0                	add    %eax,%eax
  106a68:	01 d8                	add    %ebx,%eax
  106a6a:	83 e8 30             	sub    $0x30,%eax
  106a6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  106a70:	8b 45 10             	mov    0x10(%ebp),%eax
  106a73:	0f b6 00             	movzbl (%eax),%eax
  106a76:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  106a79:	83 fb 2f             	cmp    $0x2f,%ebx
  106a7c:	7e 38                	jle    106ab6 <vprintfmt+0xe4>
  106a7e:	83 fb 39             	cmp    $0x39,%ebx
  106a81:	7f 33                	jg     106ab6 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  106a83:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  106a86:	eb d4                	jmp    106a5c <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  106a88:	8b 45 14             	mov    0x14(%ebp),%eax
  106a8b:	8d 50 04             	lea    0x4(%eax),%edx
  106a8e:	89 55 14             	mov    %edx,0x14(%ebp)
  106a91:	8b 00                	mov    (%eax),%eax
  106a93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  106a96:	eb 1f                	jmp    106ab7 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  106a98:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106a9c:	79 87                	jns    106a25 <vprintfmt+0x53>
                width = 0;
  106a9e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  106aa5:	e9 7b ff ff ff       	jmp    106a25 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  106aaa:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  106ab1:	e9 6f ff ff ff       	jmp    106a25 <vprintfmt+0x53>
            goto process_precision;
  106ab6:	90                   	nop

        process_precision:
            if (width < 0)
  106ab7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106abb:	0f 89 64 ff ff ff    	jns    106a25 <vprintfmt+0x53>
                width = precision, precision = -1;
  106ac1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106ac4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106ac7:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  106ace:	e9 52 ff ff ff       	jmp    106a25 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  106ad3:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  106ad6:	e9 4a ff ff ff       	jmp    106a25 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  106adb:	8b 45 14             	mov    0x14(%ebp),%eax
  106ade:	8d 50 04             	lea    0x4(%eax),%edx
  106ae1:	89 55 14             	mov    %edx,0x14(%ebp)
  106ae4:	8b 00                	mov    (%eax),%eax
  106ae6:	8b 55 0c             	mov    0xc(%ebp),%edx
  106ae9:	89 54 24 04          	mov    %edx,0x4(%esp)
  106aed:	89 04 24             	mov    %eax,(%esp)
  106af0:	8b 45 08             	mov    0x8(%ebp),%eax
  106af3:	ff d0                	call   *%eax
            break;
  106af5:	e9 a4 02 00 00       	jmp    106d9e <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  106afa:	8b 45 14             	mov    0x14(%ebp),%eax
  106afd:	8d 50 04             	lea    0x4(%eax),%edx
  106b00:	89 55 14             	mov    %edx,0x14(%ebp)
  106b03:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  106b05:	85 db                	test   %ebx,%ebx
  106b07:	79 02                	jns    106b0b <vprintfmt+0x139>
                err = -err;
  106b09:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  106b0b:	83 fb 06             	cmp    $0x6,%ebx
  106b0e:	7f 0b                	jg     106b1b <vprintfmt+0x149>
  106b10:	8b 34 9d f4 82 10 00 	mov    0x1082f4(,%ebx,4),%esi
  106b17:	85 f6                	test   %esi,%esi
  106b19:	75 23                	jne    106b3e <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  106b1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  106b1f:	c7 44 24 08 21 83 10 	movl   $0x108321,0x8(%esp)
  106b26:	00 
  106b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  106b31:	89 04 24             	mov    %eax,(%esp)
  106b34:	e8 6a fe ff ff       	call   1069a3 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  106b39:	e9 60 02 00 00       	jmp    106d9e <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  106b3e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  106b42:	c7 44 24 08 2a 83 10 	movl   $0x10832a,0x8(%esp)
  106b49:	00 
  106b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b51:	8b 45 08             	mov    0x8(%ebp),%eax
  106b54:	89 04 24             	mov    %eax,(%esp)
  106b57:	e8 47 fe ff ff       	call   1069a3 <printfmt>
            break;
  106b5c:	e9 3d 02 00 00       	jmp    106d9e <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  106b61:	8b 45 14             	mov    0x14(%ebp),%eax
  106b64:	8d 50 04             	lea    0x4(%eax),%edx
  106b67:	89 55 14             	mov    %edx,0x14(%ebp)
  106b6a:	8b 30                	mov    (%eax),%esi
  106b6c:	85 f6                	test   %esi,%esi
  106b6e:	75 05                	jne    106b75 <vprintfmt+0x1a3>
                p = "(null)";
  106b70:	be 2d 83 10 00       	mov    $0x10832d,%esi
            }
            if (width > 0 && padc != '-') {
  106b75:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106b79:	7e 76                	jle    106bf1 <vprintfmt+0x21f>
  106b7b:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  106b7f:	74 70                	je     106bf1 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  106b81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106b84:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b88:	89 34 24             	mov    %esi,(%esp)
  106b8b:	e8 f6 f7 ff ff       	call   106386 <strnlen>
  106b90:	8b 55 e8             	mov    -0x18(%ebp),%edx
  106b93:	29 c2                	sub    %eax,%edx
  106b95:	89 d0                	mov    %edx,%eax
  106b97:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106b9a:	eb 16                	jmp    106bb2 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  106b9c:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  106ba0:	8b 55 0c             	mov    0xc(%ebp),%edx
  106ba3:	89 54 24 04          	mov    %edx,0x4(%esp)
  106ba7:	89 04 24             	mov    %eax,(%esp)
  106baa:	8b 45 08             	mov    0x8(%ebp),%eax
  106bad:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  106baf:	ff 4d e8             	decl   -0x18(%ebp)
  106bb2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106bb6:	7f e4                	jg     106b9c <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  106bb8:	eb 37                	jmp    106bf1 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  106bba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  106bbe:	74 1f                	je     106bdf <vprintfmt+0x20d>
  106bc0:	83 fb 1f             	cmp    $0x1f,%ebx
  106bc3:	7e 05                	jle    106bca <vprintfmt+0x1f8>
  106bc5:	83 fb 7e             	cmp    $0x7e,%ebx
  106bc8:	7e 15                	jle    106bdf <vprintfmt+0x20d>
                    putch('?', putdat);
  106bca:	8b 45 0c             	mov    0xc(%ebp),%eax
  106bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  106bd1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  106bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  106bdb:	ff d0                	call   *%eax
  106bdd:	eb 0f                	jmp    106bee <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  106bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  106be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  106be6:	89 1c 24             	mov    %ebx,(%esp)
  106be9:	8b 45 08             	mov    0x8(%ebp),%eax
  106bec:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  106bee:	ff 4d e8             	decl   -0x18(%ebp)
  106bf1:	89 f0                	mov    %esi,%eax
  106bf3:	8d 70 01             	lea    0x1(%eax),%esi
  106bf6:	0f b6 00             	movzbl (%eax),%eax
  106bf9:	0f be d8             	movsbl %al,%ebx
  106bfc:	85 db                	test   %ebx,%ebx
  106bfe:	74 27                	je     106c27 <vprintfmt+0x255>
  106c00:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106c04:	78 b4                	js     106bba <vprintfmt+0x1e8>
  106c06:	ff 4d e4             	decl   -0x1c(%ebp)
  106c09:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106c0d:	79 ab                	jns    106bba <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  106c0f:	eb 16                	jmp    106c27 <vprintfmt+0x255>
                putch(' ', putdat);
  106c11:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c14:	89 44 24 04          	mov    %eax,0x4(%esp)
  106c18:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  106c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  106c22:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  106c24:	ff 4d e8             	decl   -0x18(%ebp)
  106c27:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106c2b:	7f e4                	jg     106c11 <vprintfmt+0x23f>
            }
            break;
  106c2d:	e9 6c 01 00 00       	jmp    106d9e <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  106c32:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106c35:	89 44 24 04          	mov    %eax,0x4(%esp)
  106c39:	8d 45 14             	lea    0x14(%ebp),%eax
  106c3c:	89 04 24             	mov    %eax,(%esp)
  106c3f:	e8 18 fd ff ff       	call   10695c <getint>
  106c44:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106c47:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  106c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106c50:	85 d2                	test   %edx,%edx
  106c52:	79 26                	jns    106c7a <vprintfmt+0x2a8>
                putch('-', putdat);
  106c54:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c57:	89 44 24 04          	mov    %eax,0x4(%esp)
  106c5b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  106c62:	8b 45 08             	mov    0x8(%ebp),%eax
  106c65:	ff d0                	call   *%eax
                num = -(long long)num;
  106c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106c6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106c6d:	f7 d8                	neg    %eax
  106c6f:	83 d2 00             	adc    $0x0,%edx
  106c72:	f7 da                	neg    %edx
  106c74:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106c77:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  106c7a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106c81:	e9 a8 00 00 00       	jmp    106d2e <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  106c86:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106c89:	89 44 24 04          	mov    %eax,0x4(%esp)
  106c8d:	8d 45 14             	lea    0x14(%ebp),%eax
  106c90:	89 04 24             	mov    %eax,(%esp)
  106c93:	e8 75 fc ff ff       	call   10690d <getuint>
  106c98:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106c9b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  106c9e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106ca5:	e9 84 00 00 00       	jmp    106d2e <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  106caa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106cad:	89 44 24 04          	mov    %eax,0x4(%esp)
  106cb1:	8d 45 14             	lea    0x14(%ebp),%eax
  106cb4:	89 04 24             	mov    %eax,(%esp)
  106cb7:	e8 51 fc ff ff       	call   10690d <getuint>
  106cbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106cbf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  106cc2:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  106cc9:	eb 63                	jmp    106d2e <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  106ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
  106cce:	89 44 24 04          	mov    %eax,0x4(%esp)
  106cd2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  106cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  106cdc:	ff d0                	call   *%eax
            putch('x', putdat);
  106cde:	8b 45 0c             	mov    0xc(%ebp),%eax
  106ce1:	89 44 24 04          	mov    %eax,0x4(%esp)
  106ce5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  106cec:	8b 45 08             	mov    0x8(%ebp),%eax
  106cef:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  106cf1:	8b 45 14             	mov    0x14(%ebp),%eax
  106cf4:	8d 50 04             	lea    0x4(%eax),%edx
  106cf7:	89 55 14             	mov    %edx,0x14(%ebp)
  106cfa:	8b 00                	mov    (%eax),%eax
  106cfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106cff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  106d06:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  106d0d:	eb 1f                	jmp    106d2e <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  106d0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106d12:	89 44 24 04          	mov    %eax,0x4(%esp)
  106d16:	8d 45 14             	lea    0x14(%ebp),%eax
  106d19:	89 04 24             	mov    %eax,(%esp)
  106d1c:	e8 ec fb ff ff       	call   10690d <getuint>
  106d21:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106d24:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  106d27:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  106d2e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  106d32:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106d35:	89 54 24 18          	mov    %edx,0x18(%esp)
  106d39:	8b 55 e8             	mov    -0x18(%ebp),%edx
  106d3c:	89 54 24 14          	mov    %edx,0x14(%esp)
  106d40:	89 44 24 10          	mov    %eax,0x10(%esp)
  106d44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106d47:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106d4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  106d4e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106d52:	8b 45 0c             	mov    0xc(%ebp),%eax
  106d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  106d59:	8b 45 08             	mov    0x8(%ebp),%eax
  106d5c:	89 04 24             	mov    %eax,(%esp)
  106d5f:	e8 a4 fa ff ff       	call   106808 <printnum>
            break;
  106d64:	eb 38                	jmp    106d9e <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  106d66:	8b 45 0c             	mov    0xc(%ebp),%eax
  106d69:	89 44 24 04          	mov    %eax,0x4(%esp)
  106d6d:	89 1c 24             	mov    %ebx,(%esp)
  106d70:	8b 45 08             	mov    0x8(%ebp),%eax
  106d73:	ff d0                	call   *%eax
            break;
  106d75:	eb 27                	jmp    106d9e <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  106d77:	8b 45 0c             	mov    0xc(%ebp),%eax
  106d7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  106d7e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  106d85:	8b 45 08             	mov    0x8(%ebp),%eax
  106d88:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  106d8a:	ff 4d 10             	decl   0x10(%ebp)
  106d8d:	eb 03                	jmp    106d92 <vprintfmt+0x3c0>
  106d8f:	ff 4d 10             	decl   0x10(%ebp)
  106d92:	8b 45 10             	mov    0x10(%ebp),%eax
  106d95:	48                   	dec    %eax
  106d96:	0f b6 00             	movzbl (%eax),%eax
  106d99:	3c 25                	cmp    $0x25,%al
  106d9b:	75 f2                	jne    106d8f <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  106d9d:	90                   	nop
    while (1) {
  106d9e:	e9 37 fc ff ff       	jmp    1069da <vprintfmt+0x8>
                return;
  106da3:	90                   	nop
        }
    }
}
  106da4:	83 c4 40             	add    $0x40,%esp
  106da7:	5b                   	pop    %ebx
  106da8:	5e                   	pop    %esi
  106da9:	5d                   	pop    %ebp
  106daa:	c3                   	ret    

00106dab <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  106dab:	55                   	push   %ebp
  106dac:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  106dae:	8b 45 0c             	mov    0xc(%ebp),%eax
  106db1:	8b 40 08             	mov    0x8(%eax),%eax
  106db4:	8d 50 01             	lea    0x1(%eax),%edx
  106db7:	8b 45 0c             	mov    0xc(%ebp),%eax
  106dba:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  106dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  106dc0:	8b 10                	mov    (%eax),%edx
  106dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  106dc5:	8b 40 04             	mov    0x4(%eax),%eax
  106dc8:	39 c2                	cmp    %eax,%edx
  106dca:	73 12                	jae    106dde <sprintputch+0x33>
        *b->buf ++ = ch;
  106dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  106dcf:	8b 00                	mov    (%eax),%eax
  106dd1:	8d 48 01             	lea    0x1(%eax),%ecx
  106dd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  106dd7:	89 0a                	mov    %ecx,(%edx)
  106dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  106ddc:	88 10                	mov    %dl,(%eax)
    }
}
  106dde:	90                   	nop
  106ddf:	5d                   	pop    %ebp
  106de0:	c3                   	ret    

00106de1 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  106de1:	55                   	push   %ebp
  106de2:	89 e5                	mov    %esp,%ebp
  106de4:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  106de7:	8d 45 14             	lea    0x14(%ebp),%eax
  106dea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  106ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106df0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106df4:	8b 45 10             	mov    0x10(%ebp),%eax
  106df7:	89 44 24 08          	mov    %eax,0x8(%esp)
  106dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  106dfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  106e02:	8b 45 08             	mov    0x8(%ebp),%eax
  106e05:	89 04 24             	mov    %eax,(%esp)
  106e08:	e8 08 00 00 00       	call   106e15 <vsnprintf>
  106e0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  106e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106e13:	c9                   	leave  
  106e14:	c3                   	ret    

00106e15 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  106e15:	55                   	push   %ebp
  106e16:	89 e5                	mov    %esp,%ebp
  106e18:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  106e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  106e1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106e21:	8b 45 0c             	mov    0xc(%ebp),%eax
  106e24:	8d 50 ff             	lea    -0x1(%eax),%edx
  106e27:	8b 45 08             	mov    0x8(%ebp),%eax
  106e2a:	01 d0                	add    %edx,%eax
  106e2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106e2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  106e36:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  106e3a:	74 0a                	je     106e46 <vsnprintf+0x31>
  106e3c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106e42:	39 c2                	cmp    %eax,%edx
  106e44:	76 07                	jbe    106e4d <vsnprintf+0x38>
        return -E_INVAL;
  106e46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  106e4b:	eb 2a                	jmp    106e77 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  106e4d:	8b 45 14             	mov    0x14(%ebp),%eax
  106e50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106e54:	8b 45 10             	mov    0x10(%ebp),%eax
  106e57:	89 44 24 08          	mov    %eax,0x8(%esp)
  106e5b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  106e5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  106e62:	c7 04 24 ab 6d 10 00 	movl   $0x106dab,(%esp)
  106e69:	e8 64 fb ff ff       	call   1069d2 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  106e6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106e71:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  106e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106e77:	c9                   	leave  
  106e78:	c3                   	ret    
