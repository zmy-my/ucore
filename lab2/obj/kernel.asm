
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 b0 11 00       	mov    $0x11b000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 b0 11 c0       	mov    %eax,0xc011b000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 a0 11 c0       	mov    $0xc011a000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba bc df 11 c0       	mov    $0xc011dfbc,%edx
c0100041:	b8 00 d0 11 c0       	mov    $0xc011d000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 d0 11 c0 	movl   $0xc011d000,(%esp)
c010005d:	e8 1d 66 00 00       	call   c010667f <memset>

    cons_init();                // init the console
c0100062:	e8 80 15 00 00       	call   c01015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 80 6e 10 c0 	movl   $0xc0106e80,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 9c 6e 10 c0 	movl   $0xc0106e9c,(%esp)
c010007c:	e8 11 02 00 00       	call   c0100292 <cprintf>

    print_kerninfo();
c0100081:	e8 b2 08 00 00       	call   c0100938 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 89 00 00 00       	call   c0100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 be 30 00 00       	call   c010314e <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 b7 16 00 00       	call   c010174c <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 3c 18 00 00       	call   c01018d6 <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 eb 0c 00 00       	call   c0100d8a <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 e2 17 00 00       	call   c0101886 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	55                   	push   %ebp
c01000a7:	89 e5                	mov    %esp,%ebp
c01000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b3:	00 
c01000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bb:	00 
c01000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c3:	e8 b0 0c 00 00       	call   c0100d78 <mon_backtrace>
}
c01000c8:	90                   	nop
c01000c9:	c9                   	leave  
c01000ca:	c3                   	ret    

c01000cb <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000cb:	55                   	push   %ebp
c01000cc:	89 e5                	mov    %esp,%ebp
c01000ce:	53                   	push   %ebx
c01000cf:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000db:	8b 45 08             	mov    0x8(%ebp),%eax
c01000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000ea:	89 04 24             	mov    %eax,(%esp)
c01000ed:	e8 b4 ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000f2:	90                   	nop
c01000f3:	83 c4 14             	add    $0x14,%esp
c01000f6:	5b                   	pop    %ebx
c01000f7:	5d                   	pop    %ebp
c01000f8:	c3                   	ret    

c01000f9 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f9:	55                   	push   %ebp
c01000fa:	89 e5                	mov    %esp,%ebp
c01000fc:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000ff:	8b 45 10             	mov    0x10(%ebp),%eax
c0100102:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100106:	8b 45 08             	mov    0x8(%ebp),%eax
c0100109:	89 04 24             	mov    %eax,(%esp)
c010010c:	e8 ba ff ff ff       	call   c01000cb <grade_backtrace1>
}
c0100111:	90                   	nop
c0100112:	c9                   	leave  
c0100113:	c3                   	ret    

c0100114 <grade_backtrace>:

void
grade_backtrace(void) {
c0100114:	55                   	push   %ebp
c0100115:	89 e5                	mov    %esp,%ebp
c0100117:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011a:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011f:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100126:	ff 
c0100127:	89 44 24 04          	mov    %eax,0x4(%esp)
c010012b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100132:	e8 c2 ff ff ff       	call   c01000f9 <grade_backtrace0>
}
c0100137:	90                   	nop
c0100138:	c9                   	leave  
c0100139:	c3                   	ret    

c010013a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013a:	55                   	push   %ebp
c010013b:	89 e5                	mov    %esp,%ebp
c010013d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100140:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100143:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100146:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100149:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010014c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100150:	83 e0 03             	and    $0x3,%eax
c0100153:	89 c2                	mov    %eax,%edx
c0100155:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c010015a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100162:	c7 04 24 a1 6e 10 c0 	movl   $0xc0106ea1,(%esp)
c0100169:	e8 24 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100172:	89 c2                	mov    %eax,%edx
c0100174:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 af 6e 10 c0 	movl   $0xc0106eaf,(%esp)
c0100188:	e8 05 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	89 c2                	mov    %eax,%edx
c0100193:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c0100198:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a0:	c7 04 24 bd 6e 10 c0 	movl   $0xc0106ebd,(%esp)
c01001a7:	e8 e6 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b0:	89 c2                	mov    %eax,%edx
c01001b2:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bf:	c7 04 24 cb 6e 10 c0 	movl   $0xc0106ecb,(%esp)
c01001c6:	e8 c7 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001cf:	89 c2                	mov    %eax,%edx
c01001d1:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001de:	c7 04 24 d9 6e 10 c0 	movl   $0xc0106ed9,(%esp)
c01001e5:	e8 a8 00 00 00       	call   c0100292 <cprintf>
    round ++;
c01001ea:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001ef:	40                   	inc    %eax
c01001f0:	a3 00 d0 11 c0       	mov    %eax,0xc011d000
}
c01001f5:	90                   	nop
c01001f6:	c9                   	leave  
c01001f7:	c3                   	ret    

c01001f8 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001f8:	55                   	push   %ebp
c01001f9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001fb:	90                   	nop
c01001fc:	5d                   	pop    %ebp
c01001fd:	c3                   	ret    

c01001fe <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001fe:	55                   	push   %ebp
c01001ff:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100201:	90                   	nop
c0100202:	5d                   	pop    %ebp
c0100203:	c3                   	ret    

c0100204 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100204:	55                   	push   %ebp
c0100205:	89 e5                	mov    %esp,%ebp
c0100207:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010020a:	e8 2b ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010020f:	c7 04 24 e8 6e 10 c0 	movl   $0xc0106ee8,(%esp)
c0100216:	e8 77 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_user();
c010021b:	e8 d8 ff ff ff       	call   c01001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100220:	e8 15 ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100225:	c7 04 24 08 6f 10 c0 	movl   $0xc0106f08,(%esp)
c010022c:	e8 61 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_kernel();
c0100231:	e8 c8 ff ff ff       	call   c01001fe <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100236:	e8 ff fe ff ff       	call   c010013a <lab1_print_cur_status>
}
c010023b:	90                   	nop
c010023c:	c9                   	leave  
c010023d:	c3                   	ret    

c010023e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010023e:	55                   	push   %ebp
c010023f:	89 e5                	mov    %esp,%ebp
c0100241:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100244:	8b 45 08             	mov    0x8(%ebp),%eax
c0100247:	89 04 24             	mov    %eax,(%esp)
c010024a:	e8 c5 13 00 00       	call   c0101614 <cons_putc>
    (*cnt) ++;
c010024f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100252:	8b 00                	mov    (%eax),%eax
c0100254:	8d 50 01             	lea    0x1(%eax),%edx
c0100257:	8b 45 0c             	mov    0xc(%ebp),%eax
c010025a:	89 10                	mov    %edx,(%eax)
}
c010025c:	90                   	nop
c010025d:	c9                   	leave  
c010025e:	c3                   	ret    

c010025f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010025f:	55                   	push   %ebp
c0100260:	89 e5                	mov    %esp,%ebp
c0100262:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100265:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010026c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100273:	8b 45 08             	mov    0x8(%ebp),%eax
c0100276:	89 44 24 08          	mov    %eax,0x8(%esp)
c010027a:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010027d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100281:	c7 04 24 3e 02 10 c0 	movl   $0xc010023e,(%esp)
c0100288:	e8 45 67 00 00       	call   c01069d2 <vprintfmt>
    return cnt;
c010028d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100290:	c9                   	leave  
c0100291:	c3                   	ret    

c0100292 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100292:	55                   	push   %ebp
c0100293:	89 e5                	mov    %esp,%ebp
c0100295:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100298:	8d 45 0c             	lea    0xc(%ebp),%eax
c010029b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010029e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01002a8:	89 04 24             	mov    %eax,(%esp)
c01002ab:	e8 af ff ff ff       	call   c010025f <vcprintf>
c01002b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002b6:	c9                   	leave  
c01002b7:	c3                   	ret    

c01002b8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002b8:	55                   	push   %ebp
c01002b9:	89 e5                	mov    %esp,%ebp
c01002bb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002be:	8b 45 08             	mov    0x8(%ebp),%eax
c01002c1:	89 04 24             	mov    %eax,(%esp)
c01002c4:	e8 4b 13 00 00       	call   c0101614 <cons_putc>
}
c01002c9:	90                   	nop
c01002ca:	c9                   	leave  
c01002cb:	c3                   	ret    

c01002cc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002cc:	55                   	push   %ebp
c01002cd:	89 e5                	mov    %esp,%ebp
c01002cf:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002d9:	eb 13                	jmp    c01002ee <cputs+0x22>
        cputch(c, &cnt);
c01002db:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002df:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002e2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002e6:	89 04 24             	mov    %eax,(%esp)
c01002e9:	e8 50 ff ff ff       	call   c010023e <cputch>
    while ((c = *str ++) != '\0') {
c01002ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01002f1:	8d 50 01             	lea    0x1(%eax),%edx
c01002f4:	89 55 08             	mov    %edx,0x8(%ebp)
c01002f7:	0f b6 00             	movzbl (%eax),%eax
c01002fa:	88 45 f7             	mov    %al,-0x9(%ebp)
c01002fd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100301:	75 d8                	jne    c01002db <cputs+0xf>
    }
    cputch('\n', &cnt);
c0100303:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100306:	89 44 24 04          	mov    %eax,0x4(%esp)
c010030a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100311:	e8 28 ff ff ff       	call   c010023e <cputch>
    return cnt;
c0100316:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100319:	c9                   	leave  
c010031a:	c3                   	ret    

c010031b <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010031b:	55                   	push   %ebp
c010031c:	89 e5                	mov    %esp,%ebp
c010031e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100321:	e8 2b 13 00 00       	call   c0101651 <cons_getc>
c0100326:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100329:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010032d:	74 f2                	je     c0100321 <getchar+0x6>
        /* do nothing */;
    return c;
c010032f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100332:	c9                   	leave  
c0100333:	c3                   	ret    

c0100334 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100334:	55                   	push   %ebp
c0100335:	89 e5                	mov    %esp,%ebp
c0100337:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010033a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010033e:	74 13                	je     c0100353 <readline+0x1f>
        cprintf("%s", prompt);
c0100340:	8b 45 08             	mov    0x8(%ebp),%eax
c0100343:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100347:	c7 04 24 27 6f 10 c0 	movl   $0xc0106f27,(%esp)
c010034e:	e8 3f ff ff ff       	call   c0100292 <cprintf>
    }
    int i = 0, c;
c0100353:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010035a:	e8 bc ff ff ff       	call   c010031b <getchar>
c010035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100362:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100366:	79 07                	jns    c010036f <readline+0x3b>
            return NULL;
c0100368:	b8 00 00 00 00       	mov    $0x0,%eax
c010036d:	eb 78                	jmp    c01003e7 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010036f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100373:	7e 28                	jle    c010039d <readline+0x69>
c0100375:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010037c:	7f 1f                	jg     c010039d <readline+0x69>
            cputchar(c);
c010037e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100381:	89 04 24             	mov    %eax,(%esp)
c0100384:	e8 2f ff ff ff       	call   c01002b8 <cputchar>
            buf[i ++] = c;
c0100389:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010038c:	8d 50 01             	lea    0x1(%eax),%edx
c010038f:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100392:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100395:	88 90 20 d0 11 c0    	mov    %dl,-0x3fee2fe0(%eax)
c010039b:	eb 45                	jmp    c01003e2 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c010039d:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003a1:	75 16                	jne    c01003b9 <readline+0x85>
c01003a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003a7:	7e 10                	jle    c01003b9 <readline+0x85>
            cputchar(c);
c01003a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003ac:	89 04 24             	mov    %eax,(%esp)
c01003af:	e8 04 ff ff ff       	call   c01002b8 <cputchar>
            i --;
c01003b4:	ff 4d f4             	decl   -0xc(%ebp)
c01003b7:	eb 29                	jmp    c01003e2 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003b9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003bd:	74 06                	je     c01003c5 <readline+0x91>
c01003bf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003c3:	75 95                	jne    c010035a <readline+0x26>
            cputchar(c);
c01003c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c8:	89 04 24             	mov    %eax,(%esp)
c01003cb:	e8 e8 fe ff ff       	call   c01002b8 <cputchar>
            buf[i] = '\0';
c01003d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003d3:	05 20 d0 11 c0       	add    $0xc011d020,%eax
c01003d8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003db:	b8 20 d0 11 c0       	mov    $0xc011d020,%eax
c01003e0:	eb 05                	jmp    c01003e7 <readline+0xb3>
        c = getchar();
c01003e2:	e9 73 ff ff ff       	jmp    c010035a <readline+0x26>
        }
    }
}
c01003e7:	c9                   	leave  
c01003e8:	c3                   	ret    

c01003e9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003e9:	55                   	push   %ebp
c01003ea:	89 e5                	mov    %esp,%ebp
c01003ec:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c01003ef:	a1 20 d4 11 c0       	mov    0xc011d420,%eax
c01003f4:	85 c0                	test   %eax,%eax
c01003f6:	75 5b                	jne    c0100453 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c01003f8:	c7 05 20 d4 11 c0 01 	movl   $0x1,0xc011d420
c01003ff:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100402:	8d 45 14             	lea    0x14(%ebp),%eax
c0100405:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100408:	8b 45 0c             	mov    0xc(%ebp),%eax
c010040b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010040f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100412:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100416:	c7 04 24 2a 6f 10 c0 	movl   $0xc0106f2a,(%esp)
c010041d:	e8 70 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c0100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100425:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100429:	8b 45 10             	mov    0x10(%ebp),%eax
c010042c:	89 04 24             	mov    %eax,(%esp)
c010042f:	e8 2b fe ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c0100434:	c7 04 24 46 6f 10 c0 	movl   $0xc0106f46,(%esp)
c010043b:	e8 52 fe ff ff       	call   c0100292 <cprintf>
    
    cprintf("stack trackback:\n");
c0100440:	c7 04 24 48 6f 10 c0 	movl   $0xc0106f48,(%esp)
c0100447:	e8 46 fe ff ff       	call   c0100292 <cprintf>
    print_stackframe();
c010044c:	e8 32 06 00 00       	call   c0100a83 <print_stackframe>
c0100451:	eb 01                	jmp    c0100454 <__panic+0x6b>
        goto panic_dead;
c0100453:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100454:	e8 34 14 00 00       	call   c010188d <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100459:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100460:	e8 46 08 00 00       	call   c0100cab <kmonitor>
c0100465:	eb f2                	jmp    c0100459 <__panic+0x70>

c0100467 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100467:	55                   	push   %ebp
c0100468:	89 e5                	mov    %esp,%ebp
c010046a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c010046d:	8d 45 14             	lea    0x14(%ebp),%eax
c0100470:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100473:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100476:	89 44 24 08          	mov    %eax,0x8(%esp)
c010047a:	8b 45 08             	mov    0x8(%ebp),%eax
c010047d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100481:	c7 04 24 5a 6f 10 c0 	movl   $0xc0106f5a,(%esp)
c0100488:	e8 05 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c010048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100490:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100494:	8b 45 10             	mov    0x10(%ebp),%eax
c0100497:	89 04 24             	mov    %eax,(%esp)
c010049a:	e8 c0 fd ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c010049f:	c7 04 24 46 6f 10 c0 	movl   $0xc0106f46,(%esp)
c01004a6:	e8 e7 fd ff ff       	call   c0100292 <cprintf>
    va_end(ap);
}
c01004ab:	90                   	nop
c01004ac:	c9                   	leave  
c01004ad:	c3                   	ret    

c01004ae <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004ae:	55                   	push   %ebp
c01004af:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004b1:	a1 20 d4 11 c0       	mov    0xc011d420,%eax
}
c01004b6:	5d                   	pop    %ebp
c01004b7:	c3                   	ret    

c01004b8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004b8:	55                   	push   %ebp
c01004b9:	89 e5                	mov    %esp,%ebp
c01004bb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004c1:	8b 00                	mov    (%eax),%eax
c01004c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01004c9:	8b 00                	mov    (%eax),%eax
c01004cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004d5:	e9 ca 00 00 00       	jmp    c01005a4 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004da:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004e0:	01 d0                	add    %edx,%eax
c01004e2:	89 c2                	mov    %eax,%edx
c01004e4:	c1 ea 1f             	shr    $0x1f,%edx
c01004e7:	01 d0                	add    %edx,%eax
c01004e9:	d1 f8                	sar    %eax
c01004eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004f4:	eb 03                	jmp    c01004f9 <stab_binsearch+0x41>
            m --;
c01004f6:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c01004f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01004ff:	7c 1f                	jl     c0100520 <stab_binsearch+0x68>
c0100501:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100504:	89 d0                	mov    %edx,%eax
c0100506:	01 c0                	add    %eax,%eax
c0100508:	01 d0                	add    %edx,%eax
c010050a:	c1 e0 02             	shl    $0x2,%eax
c010050d:	89 c2                	mov    %eax,%edx
c010050f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100512:	01 d0                	add    %edx,%eax
c0100514:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100518:	0f b6 c0             	movzbl %al,%eax
c010051b:	39 45 14             	cmp    %eax,0x14(%ebp)
c010051e:	75 d6                	jne    c01004f6 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100520:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100523:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100526:	7d 09                	jge    c0100531 <stab_binsearch+0x79>
            l = true_m + 1;
c0100528:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010052b:	40                   	inc    %eax
c010052c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010052f:	eb 73                	jmp    c01005a4 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100531:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100538:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010053b:	89 d0                	mov    %edx,%eax
c010053d:	01 c0                	add    %eax,%eax
c010053f:	01 d0                	add    %edx,%eax
c0100541:	c1 e0 02             	shl    $0x2,%eax
c0100544:	89 c2                	mov    %eax,%edx
c0100546:	8b 45 08             	mov    0x8(%ebp),%eax
c0100549:	01 d0                	add    %edx,%eax
c010054b:	8b 40 08             	mov    0x8(%eax),%eax
c010054e:	39 45 18             	cmp    %eax,0x18(%ebp)
c0100551:	76 11                	jbe    c0100564 <stab_binsearch+0xac>
            *region_left = m;
c0100553:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100556:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100559:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010055b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010055e:	40                   	inc    %eax
c010055f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100562:	eb 40                	jmp    c01005a4 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c0100564:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100567:	89 d0                	mov    %edx,%eax
c0100569:	01 c0                	add    %eax,%eax
c010056b:	01 d0                	add    %edx,%eax
c010056d:	c1 e0 02             	shl    $0x2,%eax
c0100570:	89 c2                	mov    %eax,%edx
c0100572:	8b 45 08             	mov    0x8(%ebp),%eax
c0100575:	01 d0                	add    %edx,%eax
c0100577:	8b 40 08             	mov    0x8(%eax),%eax
c010057a:	39 45 18             	cmp    %eax,0x18(%ebp)
c010057d:	73 14                	jae    c0100593 <stab_binsearch+0xdb>
            *region_right = m - 1;
c010057f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100582:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100585:	8b 45 10             	mov    0x10(%ebp),%eax
c0100588:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c010058a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010058d:	48                   	dec    %eax
c010058e:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100591:	eb 11                	jmp    c01005a4 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c0100593:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100596:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100599:	89 10                	mov    %edx,(%eax)
            l = m;
c010059b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059e:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005a1:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01005a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005a7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005aa:	0f 8e 2a ff ff ff    	jle    c01004da <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01005b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005b4:	75 0f                	jne    c01005c5 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b9:	8b 00                	mov    (%eax),%eax
c01005bb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005be:	8b 45 10             	mov    0x10(%ebp),%eax
c01005c1:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005c3:	eb 3e                	jmp    c0100603 <stab_binsearch+0x14b>
        l = *region_right;
c01005c5:	8b 45 10             	mov    0x10(%ebp),%eax
c01005c8:	8b 00                	mov    (%eax),%eax
c01005ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005cd:	eb 03                	jmp    c01005d2 <stab_binsearch+0x11a>
c01005cf:	ff 4d fc             	decl   -0x4(%ebp)
c01005d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d5:	8b 00                	mov    (%eax),%eax
c01005d7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01005da:	7e 1f                	jle    c01005fb <stab_binsearch+0x143>
c01005dc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005df:	89 d0                	mov    %edx,%eax
c01005e1:	01 c0                	add    %eax,%eax
c01005e3:	01 d0                	add    %edx,%eax
c01005e5:	c1 e0 02             	shl    $0x2,%eax
c01005e8:	89 c2                	mov    %eax,%edx
c01005ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01005ed:	01 d0                	add    %edx,%eax
c01005ef:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01005f3:	0f b6 c0             	movzbl %al,%eax
c01005f6:	39 45 14             	cmp    %eax,0x14(%ebp)
c01005f9:	75 d4                	jne    c01005cf <stab_binsearch+0x117>
        *region_left = l;
c01005fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100601:	89 10                	mov    %edx,(%eax)
}
c0100603:	90                   	nop
c0100604:	c9                   	leave  
c0100605:	c3                   	ret    

c0100606 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100606:	55                   	push   %ebp
c0100607:	89 e5                	mov    %esp,%ebp
c0100609:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010060c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060f:	c7 00 78 6f 10 c0    	movl   $0xc0106f78,(%eax)
    info->eip_line = 0;
c0100615:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010061f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100622:	c7 40 08 78 6f 10 c0 	movl   $0xc0106f78,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100629:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100633:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100636:	8b 55 08             	mov    0x8(%ebp),%edx
c0100639:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010063c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100646:	c7 45 f4 8c 84 10 c0 	movl   $0xc010848c,-0xc(%ebp)
    stab_end = __STAB_END__;
c010064d:	c7 45 f0 1c 4e 11 c0 	movl   $0xc0114e1c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100654:	c7 45 ec 1d 4e 11 c0 	movl   $0xc0114e1d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010065b:	c7 45 e8 06 7b 11 c0 	movl   $0xc0117b06,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100662:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100665:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100668:	76 0b                	jbe    c0100675 <debuginfo_eip+0x6f>
c010066a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010066d:	48                   	dec    %eax
c010066e:	0f b6 00             	movzbl (%eax),%eax
c0100671:	84 c0                	test   %al,%al
c0100673:	74 0a                	je     c010067f <debuginfo_eip+0x79>
        return -1;
c0100675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010067a:	e9 b7 02 00 00       	jmp    c0100936 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010067f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100686:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100689:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010068c:	29 c2                	sub    %eax,%edx
c010068e:	89 d0                	mov    %edx,%eax
c0100690:	c1 f8 02             	sar    $0x2,%eax
c0100693:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0100699:	48                   	dec    %eax
c010069a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c010069d:	8b 45 08             	mov    0x8(%ebp),%eax
c01006a0:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006a4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006ab:	00 
c01006ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006af:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006bd:	89 04 24             	mov    %eax,(%esp)
c01006c0:	e8 f3 fd ff ff       	call   c01004b8 <stab_binsearch>
    if (lfile == 0)
c01006c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006c8:	85 c0                	test   %eax,%eax
c01006ca:	75 0a                	jne    c01006d6 <debuginfo_eip+0xd0>
        return -1;
c01006cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006d1:	e9 60 02 00 00       	jmp    c0100936 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01006e5:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006e9:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c01006f0:	00 
c01006f1:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006f8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100702:	89 04 24             	mov    %eax,(%esp)
c0100705:	e8 ae fd ff ff       	call   c01004b8 <stab_binsearch>

    if (lfun <= rfun) {
c010070a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010070d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100710:	39 c2                	cmp    %eax,%edx
c0100712:	7f 7c                	jg     c0100790 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100714:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100717:	89 c2                	mov    %eax,%edx
c0100719:	89 d0                	mov    %edx,%eax
c010071b:	01 c0                	add    %eax,%eax
c010071d:	01 d0                	add    %edx,%eax
c010071f:	c1 e0 02             	shl    $0x2,%eax
c0100722:	89 c2                	mov    %eax,%edx
c0100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100727:	01 d0                	add    %edx,%eax
c0100729:	8b 00                	mov    (%eax),%eax
c010072b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010072e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100731:	29 d1                	sub    %edx,%ecx
c0100733:	89 ca                	mov    %ecx,%edx
c0100735:	39 d0                	cmp    %edx,%eax
c0100737:	73 22                	jae    c010075b <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100739:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010073c:	89 c2                	mov    %eax,%edx
c010073e:	89 d0                	mov    %edx,%eax
c0100740:	01 c0                	add    %eax,%eax
c0100742:	01 d0                	add    %edx,%eax
c0100744:	c1 e0 02             	shl    $0x2,%eax
c0100747:	89 c2                	mov    %eax,%edx
c0100749:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074c:	01 d0                	add    %edx,%eax
c010074e:	8b 10                	mov    (%eax),%edx
c0100750:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100753:	01 c2                	add    %eax,%edx
c0100755:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100758:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010075b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010075e:	89 c2                	mov    %eax,%edx
c0100760:	89 d0                	mov    %edx,%eax
c0100762:	01 c0                	add    %eax,%eax
c0100764:	01 d0                	add    %edx,%eax
c0100766:	c1 e0 02             	shl    $0x2,%eax
c0100769:	89 c2                	mov    %eax,%edx
c010076b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010076e:	01 d0                	add    %edx,%eax
c0100770:	8b 50 08             	mov    0x8(%eax),%edx
c0100773:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100776:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100779:	8b 45 0c             	mov    0xc(%ebp),%eax
c010077c:	8b 40 10             	mov    0x10(%eax),%eax
c010077f:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100782:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100785:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100788:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010078b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010078e:	eb 15                	jmp    c01007a5 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0100790:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100793:	8b 55 08             	mov    0x8(%ebp),%edx
c0100796:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0100799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010079c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c010079f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a8:	8b 40 08             	mov    0x8(%eax),%eax
c01007ab:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007b2:	00 
c01007b3:	89 04 24             	mov    %eax,(%esp)
c01007b6:	e8 40 5d 00 00       	call   c01064fb <strfind>
c01007bb:	89 c2                	mov    %eax,%edx
c01007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c0:	8b 40 08             	mov    0x8(%eax),%eax
c01007c3:	29 c2                	sub    %eax,%edx
c01007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01007ce:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007d2:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007d9:	00 
c01007da:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007e1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007eb:	89 04 24             	mov    %eax,(%esp)
c01007ee:	e8 c5 fc ff ff       	call   c01004b8 <stab_binsearch>
    if (lline <= rline) {
c01007f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007f9:	39 c2                	cmp    %eax,%edx
c01007fb:	7f 23                	jg     c0100820 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
c01007fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100800:	89 c2                	mov    %eax,%edx
c0100802:	89 d0                	mov    %edx,%eax
c0100804:	01 c0                	add    %eax,%eax
c0100806:	01 d0                	add    %edx,%eax
c0100808:	c1 e0 02             	shl    $0x2,%eax
c010080b:	89 c2                	mov    %eax,%edx
c010080d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100810:	01 d0                	add    %edx,%eax
c0100812:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100816:	89 c2                	mov    %eax,%edx
c0100818:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010081e:	eb 11                	jmp    c0100831 <debuginfo_eip+0x22b>
        return -1;
c0100820:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100825:	e9 0c 01 00 00       	jmp    c0100936 <debuginfo_eip+0x330>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010082a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010082d:	48                   	dec    %eax
c010082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100831:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100837:	39 c2                	cmp    %eax,%edx
c0100839:	7c 56                	jl     c0100891 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
c010083b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010083e:	89 c2                	mov    %eax,%edx
c0100840:	89 d0                	mov    %edx,%eax
c0100842:	01 c0                	add    %eax,%eax
c0100844:	01 d0                	add    %edx,%eax
c0100846:	c1 e0 02             	shl    $0x2,%eax
c0100849:	89 c2                	mov    %eax,%edx
c010084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010084e:	01 d0                	add    %edx,%eax
c0100850:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100854:	3c 84                	cmp    $0x84,%al
c0100856:	74 39                	je     c0100891 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085b:	89 c2                	mov    %eax,%edx
c010085d:	89 d0                	mov    %edx,%eax
c010085f:	01 c0                	add    %eax,%eax
c0100861:	01 d0                	add    %edx,%eax
c0100863:	c1 e0 02             	shl    $0x2,%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086b:	01 d0                	add    %edx,%eax
c010086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100871:	3c 64                	cmp    $0x64,%al
c0100873:	75 b5                	jne    c010082a <debuginfo_eip+0x224>
c0100875:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100878:	89 c2                	mov    %eax,%edx
c010087a:	89 d0                	mov    %edx,%eax
c010087c:	01 c0                	add    %eax,%eax
c010087e:	01 d0                	add    %edx,%eax
c0100880:	c1 e0 02             	shl    $0x2,%eax
c0100883:	89 c2                	mov    %eax,%edx
c0100885:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100888:	01 d0                	add    %edx,%eax
c010088a:	8b 40 08             	mov    0x8(%eax),%eax
c010088d:	85 c0                	test   %eax,%eax
c010088f:	74 99                	je     c010082a <debuginfo_eip+0x224>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100891:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100897:	39 c2                	cmp    %eax,%edx
c0100899:	7c 46                	jl     c01008e1 <debuginfo_eip+0x2db>
c010089b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010089e:	89 c2                	mov    %eax,%edx
c01008a0:	89 d0                	mov    %edx,%eax
c01008a2:	01 c0                	add    %eax,%eax
c01008a4:	01 d0                	add    %edx,%eax
c01008a6:	c1 e0 02             	shl    $0x2,%eax
c01008a9:	89 c2                	mov    %eax,%edx
c01008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ae:	01 d0                	add    %edx,%eax
c01008b0:	8b 00                	mov    (%eax),%eax
c01008b2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008b8:	29 d1                	sub    %edx,%ecx
c01008ba:	89 ca                	mov    %ecx,%edx
c01008bc:	39 d0                	cmp    %edx,%eax
c01008be:	73 21                	jae    c01008e1 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008c3:	89 c2                	mov    %eax,%edx
c01008c5:	89 d0                	mov    %edx,%eax
c01008c7:	01 c0                	add    %eax,%eax
c01008c9:	01 d0                	add    %edx,%eax
c01008cb:	c1 e0 02             	shl    $0x2,%eax
c01008ce:	89 c2                	mov    %eax,%edx
c01008d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008d3:	01 d0                	add    %edx,%eax
c01008d5:	8b 10                	mov    (%eax),%edx
c01008d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008da:	01 c2                	add    %eax,%edx
c01008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008df:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008e7:	39 c2                	cmp    %eax,%edx
c01008e9:	7d 46                	jge    c0100931 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
c01008eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008ee:	40                   	inc    %eax
c01008ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01008f2:	eb 16                	jmp    c010090a <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008f7:	8b 40 14             	mov    0x14(%eax),%eax
c01008fa:	8d 50 01             	lea    0x1(%eax),%edx
c01008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100900:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100903:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100906:	40                   	inc    %eax
c0100907:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010090a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010090d:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0100910:	39 c2                	cmp    %eax,%edx
c0100912:	7d 1d                	jge    c0100931 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100914:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100917:	89 c2                	mov    %eax,%edx
c0100919:	89 d0                	mov    %edx,%eax
c010091b:	01 c0                	add    %eax,%eax
c010091d:	01 d0                	add    %edx,%eax
c010091f:	c1 e0 02             	shl    $0x2,%eax
c0100922:	89 c2                	mov    %eax,%edx
c0100924:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100927:	01 d0                	add    %edx,%eax
c0100929:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010092d:	3c a0                	cmp    $0xa0,%al
c010092f:	74 c3                	je     c01008f4 <debuginfo_eip+0x2ee>
        }
    }
    return 0;
c0100931:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100936:	c9                   	leave  
c0100937:	c3                   	ret    

c0100938 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100938:	55                   	push   %ebp
c0100939:	89 e5                	mov    %esp,%ebp
c010093b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010093e:	c7 04 24 82 6f 10 c0 	movl   $0xc0106f82,(%esp)
c0100945:	e8 48 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010094a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100951:	c0 
c0100952:	c7 04 24 9b 6f 10 c0 	movl   $0xc0106f9b,(%esp)
c0100959:	e8 34 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010095e:	c7 44 24 04 79 6e 10 	movl   $0xc0106e79,0x4(%esp)
c0100965:	c0 
c0100966:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c010096d:	e8 20 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100972:	c7 44 24 04 00 d0 11 	movl   $0xc011d000,0x4(%esp)
c0100979:	c0 
c010097a:	c7 04 24 cb 6f 10 c0 	movl   $0xc0106fcb,(%esp)
c0100981:	e8 0c f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100986:	c7 44 24 04 bc df 11 	movl   $0xc011dfbc,0x4(%esp)
c010098d:	c0 
c010098e:	c7 04 24 e3 6f 10 c0 	movl   $0xc0106fe3,(%esp)
c0100995:	e8 f8 f8 ff ff       	call   c0100292 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c010099a:	b8 bc df 11 c0       	mov    $0xc011dfbc,%eax
c010099f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009a5:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009aa:	29 c2                	sub    %eax,%edx
c01009ac:	89 d0                	mov    %edx,%eax
c01009ae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009b4:	85 c0                	test   %eax,%eax
c01009b6:	0f 48 c2             	cmovs  %edx,%eax
c01009b9:	c1 f8 0a             	sar    $0xa,%eax
c01009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009c0:	c7 04 24 fc 6f 10 c0 	movl   $0xc0106ffc,(%esp)
c01009c7:	e8 c6 f8 ff ff       	call   c0100292 <cprintf>
}
c01009cc:	90                   	nop
c01009cd:	c9                   	leave  
c01009ce:	c3                   	ret    

c01009cf <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009cf:	55                   	push   %ebp
c01009d0:	89 e5                	mov    %esp,%ebp
c01009d2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009d8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009df:	8b 45 08             	mov    0x8(%ebp),%eax
c01009e2:	89 04 24             	mov    %eax,(%esp)
c01009e5:	e8 1c fc ff ff       	call   c0100606 <debuginfo_eip>
c01009ea:	85 c0                	test   %eax,%eax
c01009ec:	74 15                	je     c0100a03 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f5:	c7 04 24 26 70 10 c0 	movl   $0xc0107026,(%esp)
c01009fc:	e8 91 f8 ff ff       	call   c0100292 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a01:	eb 6c                	jmp    c0100a6f <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a0a:	eb 1b                	jmp    c0100a27 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a12:	01 d0                	add    %edx,%eax
c0100a14:	0f b6 00             	movzbl (%eax),%eax
c0100a17:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a20:	01 ca                	add    %ecx,%edx
c0100a22:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a24:	ff 45 f4             	incl   -0xc(%ebp)
c0100a27:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a2a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a2d:	7c dd                	jl     c0100a0c <print_debuginfo+0x3d>
        fnname[j] = '\0';
c0100a2f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a38:	01 d0                	add    %edx,%eax
c0100a3a:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a40:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a43:	89 d1                	mov    %edx,%ecx
c0100a45:	29 c1                	sub    %eax,%ecx
c0100a47:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a4d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a51:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a57:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a5b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a63:	c7 04 24 42 70 10 c0 	movl   $0xc0107042,(%esp)
c0100a6a:	e8 23 f8 ff ff       	call   c0100292 <cprintf>
}
c0100a6f:	90                   	nop
c0100a70:	c9                   	leave  
c0100a71:	c3                   	ret    

c0100a72 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a72:	55                   	push   %ebp
c0100a73:	89 e5                	mov    %esp,%ebp
c0100a75:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a78:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a81:	c9                   	leave  
c0100a82:	c3                   	ret    

c0100a83 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a83:	55                   	push   %ebp
c0100a84:	89 e5                	mov    %esp,%ebp
c0100a86:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a89:	89 e8                	mov    %ebp,%eax
c0100a8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp=read_ebp();
c0100a91:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip=read_eip();
c0100a94:	e8 d9 ff ff ff       	call   c0100a72 <read_eip>
c0100a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for(int i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++){
c0100a9c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100aa3:	e9 84 00 00 00       	jmp    c0100b2c <print_stackframe+0xa9>
		cprintf("epb:0x%08x eip:0x%08x args:",ebp,eip);
c0100aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100aab:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab6:	c7 04 24 54 70 10 c0 	movl   $0xc0107054,(%esp)
c0100abd:	e8 d0 f7 ff ff       	call   c0100292 <cprintf>
		uint32_t* calling_arguments = (uint32_t*)ebp+2; 
c0100ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ac5:	83 c0 08             	add    $0x8,%eax
c0100ac8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for(int i=0;i<4;i++){
c0100acb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100ad2:	eb 24                	jmp    c0100af8 <print_stackframe+0x75>
			cprintf("0x%08x ", calling_arguments[i]);
c0100ad4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ad7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100ade:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100ae1:	01 d0                	add    %edx,%eax
c0100ae3:	8b 00                	mov    (%eax),%eax
c0100ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ae9:	c7 04 24 70 70 10 c0 	movl   $0xc0107070,(%esp)
c0100af0:	e8 9d f7 ff ff       	call   c0100292 <cprintf>
		for(int i=0;i<4;i++){
c0100af5:	ff 45 e8             	incl   -0x18(%ebp)
c0100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100afc:	7e d6                	jle    c0100ad4 <print_stackframe+0x51>
		}
		cprintf("\n");
c0100afe:	c7 04 24 78 70 10 c0 	movl   $0xc0107078,(%esp)
c0100b05:	e8 88 f7 ff ff       	call   c0100292 <cprintf>
		print_debuginfo(eip-1);
c0100b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b0d:	48                   	dec    %eax
c0100b0e:	89 04 24             	mov    %eax,(%esp)
c0100b11:	e8 b9 fe ff ff       	call   c01009cf <print_debuginfo>
		eip=((uint32_t*)ebp)[1];
c0100b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b19:	83 c0 04             	add    $0x4,%eax
c0100b1c:	8b 00                	mov    (%eax),%eax
c0100b1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp=((uint32_t*)ebp)[0];
c0100b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b24:	8b 00                	mov    (%eax),%eax
c0100b26:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(int i=0;ebp!=0&&i<STACKFRAME_DEPTH;i++){
c0100b29:	ff 45 ec             	incl   -0x14(%ebp)
c0100b2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b30:	74 0a                	je     c0100b3c <print_stackframe+0xb9>
c0100b32:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b36:	0f 8e 6c ff ff ff    	jle    c0100aa8 <print_stackframe+0x25>
	}
}
c0100b3c:	90                   	nop
c0100b3d:	c9                   	leave  
c0100b3e:	c3                   	ret    

c0100b3f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b3f:	55                   	push   %ebp
c0100b40:	89 e5                	mov    %esp,%ebp
c0100b42:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b4c:	eb 0c                	jmp    c0100b5a <parse+0x1b>
            *buf ++ = '\0';
c0100b4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b51:	8d 50 01             	lea    0x1(%eax),%edx
c0100b54:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b57:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b5d:	0f b6 00             	movzbl (%eax),%eax
c0100b60:	84 c0                	test   %al,%al
c0100b62:	74 1d                	je     c0100b81 <parse+0x42>
c0100b64:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b67:	0f b6 00             	movzbl (%eax),%eax
c0100b6a:	0f be c0             	movsbl %al,%eax
c0100b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b71:	c7 04 24 fc 70 10 c0 	movl   $0xc01070fc,(%esp)
c0100b78:	e8 4c 59 00 00       	call   c01064c9 <strchr>
c0100b7d:	85 c0                	test   %eax,%eax
c0100b7f:	75 cd                	jne    c0100b4e <parse+0xf>
        }
        if (*buf == '\0') {
c0100b81:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b84:	0f b6 00             	movzbl (%eax),%eax
c0100b87:	84 c0                	test   %al,%al
c0100b89:	74 65                	je     c0100bf0 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b8b:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b8f:	75 14                	jne    c0100ba5 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b91:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b98:	00 
c0100b99:	c7 04 24 01 71 10 c0 	movl   $0xc0107101,(%esp)
c0100ba0:	e8 ed f6 ff ff       	call   c0100292 <cprintf>
        }
        argv[argc ++] = buf;
c0100ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ba8:	8d 50 01             	lea    0x1(%eax),%edx
c0100bab:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bb8:	01 c2                	add    %eax,%edx
c0100bba:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bbd:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bbf:	eb 03                	jmp    c0100bc4 <parse+0x85>
            buf ++;
c0100bc1:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc7:	0f b6 00             	movzbl (%eax),%eax
c0100bca:	84 c0                	test   %al,%al
c0100bcc:	74 8c                	je     c0100b5a <parse+0x1b>
c0100bce:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd1:	0f b6 00             	movzbl (%eax),%eax
c0100bd4:	0f be c0             	movsbl %al,%eax
c0100bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bdb:	c7 04 24 fc 70 10 c0 	movl   $0xc01070fc,(%esp)
c0100be2:	e8 e2 58 00 00       	call   c01064c9 <strchr>
c0100be7:	85 c0                	test   %eax,%eax
c0100be9:	74 d6                	je     c0100bc1 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100beb:	e9 6a ff ff ff       	jmp    c0100b5a <parse+0x1b>
            break;
c0100bf0:	90                   	nop
        }
    }
    return argc;
c0100bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100bf4:	c9                   	leave  
c0100bf5:	c3                   	ret    

c0100bf6 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100bf6:	55                   	push   %ebp
c0100bf7:	89 e5                	mov    %esp,%ebp
c0100bf9:	53                   	push   %ebx
c0100bfa:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100bfd:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c04:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c07:	89 04 24             	mov    %eax,(%esp)
c0100c0a:	e8 30 ff ff ff       	call   c0100b3f <parse>
c0100c0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c16:	75 0a                	jne    c0100c22 <runcmd+0x2c>
        return 0;
c0100c18:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c1d:	e9 83 00 00 00       	jmp    c0100ca5 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c29:	eb 5a                	jmp    c0100c85 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c2b:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c31:	89 d0                	mov    %edx,%eax
c0100c33:	01 c0                	add    %eax,%eax
c0100c35:	01 d0                	add    %edx,%eax
c0100c37:	c1 e0 02             	shl    $0x2,%eax
c0100c3a:	05 00 a0 11 c0       	add    $0xc011a000,%eax
c0100c3f:	8b 00                	mov    (%eax),%eax
c0100c41:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c45:	89 04 24             	mov    %eax,(%esp)
c0100c48:	e8 df 57 00 00       	call   c010642c <strcmp>
c0100c4d:	85 c0                	test   %eax,%eax
c0100c4f:	75 31                	jne    c0100c82 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c51:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c54:	89 d0                	mov    %edx,%eax
c0100c56:	01 c0                	add    %eax,%eax
c0100c58:	01 d0                	add    %edx,%eax
c0100c5a:	c1 e0 02             	shl    $0x2,%eax
c0100c5d:	05 08 a0 11 c0       	add    $0xc011a008,%eax
c0100c62:	8b 10                	mov    (%eax),%edx
c0100c64:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c67:	83 c0 04             	add    $0x4,%eax
c0100c6a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c6d:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c77:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c7b:	89 1c 24             	mov    %ebx,(%esp)
c0100c7e:	ff d2                	call   *%edx
c0100c80:	eb 23                	jmp    c0100ca5 <runcmd+0xaf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c82:	ff 45 f4             	incl   -0xc(%ebp)
c0100c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c88:	83 f8 02             	cmp    $0x2,%eax
c0100c8b:	76 9e                	jbe    c0100c2b <runcmd+0x35>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c8d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c90:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c94:	c7 04 24 1f 71 10 c0 	movl   $0xc010711f,(%esp)
c0100c9b:	e8 f2 f5 ff ff       	call   c0100292 <cprintf>
    return 0;
c0100ca0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ca5:	83 c4 64             	add    $0x64,%esp
c0100ca8:	5b                   	pop    %ebx
c0100ca9:	5d                   	pop    %ebp
c0100caa:	c3                   	ret    

c0100cab <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cab:	55                   	push   %ebp
c0100cac:	89 e5                	mov    %esp,%ebp
c0100cae:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cb1:	c7 04 24 38 71 10 c0 	movl   $0xc0107138,(%esp)
c0100cb8:	e8 d5 f5 ff ff       	call   c0100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cbd:	c7 04 24 60 71 10 c0 	movl   $0xc0107160,(%esp)
c0100cc4:	e8 c9 f5 ff ff       	call   c0100292 <cprintf>

    if (tf != NULL) {
c0100cc9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100ccd:	74 0b                	je     c0100cda <kmonitor+0x2f>
        print_trapframe(tf);
c0100ccf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cd2:	89 04 24             	mov    %eax,(%esp)
c0100cd5:	e8 35 0d 00 00       	call   c0101a0f <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cda:	c7 04 24 85 71 10 c0 	movl   $0xc0107185,(%esp)
c0100ce1:	e8 4e f6 ff ff       	call   c0100334 <readline>
c0100ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100ce9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100ced:	74 eb                	je     c0100cda <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100cef:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cf9:	89 04 24             	mov    %eax,(%esp)
c0100cfc:	e8 f5 fe ff ff       	call   c0100bf6 <runcmd>
c0100d01:	85 c0                	test   %eax,%eax
c0100d03:	78 02                	js     c0100d07 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100d05:	eb d3                	jmp    c0100cda <kmonitor+0x2f>
                break;
c0100d07:	90                   	nop
            }
        }
    }
}
c0100d08:	90                   	nop
c0100d09:	c9                   	leave  
c0100d0a:	c3                   	ret    

c0100d0b <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d0b:	55                   	push   %ebp
c0100d0c:	89 e5                	mov    %esp,%ebp
c0100d0e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d18:	eb 3d                	jmp    c0100d57 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d1d:	89 d0                	mov    %edx,%eax
c0100d1f:	01 c0                	add    %eax,%eax
c0100d21:	01 d0                	add    %edx,%eax
c0100d23:	c1 e0 02             	shl    $0x2,%eax
c0100d26:	05 04 a0 11 c0       	add    $0xc011a004,%eax
c0100d2b:	8b 08                	mov    (%eax),%ecx
c0100d2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d30:	89 d0                	mov    %edx,%eax
c0100d32:	01 c0                	add    %eax,%eax
c0100d34:	01 d0                	add    %edx,%eax
c0100d36:	c1 e0 02             	shl    $0x2,%eax
c0100d39:	05 00 a0 11 c0       	add    $0xc011a000,%eax
c0100d3e:	8b 00                	mov    (%eax),%eax
c0100d40:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d48:	c7 04 24 89 71 10 c0 	movl   $0xc0107189,(%esp)
c0100d4f:	e8 3e f5 ff ff       	call   c0100292 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d54:	ff 45 f4             	incl   -0xc(%ebp)
c0100d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d5a:	83 f8 02             	cmp    $0x2,%eax
c0100d5d:	76 bb                	jbe    c0100d1a <mon_help+0xf>
    }
    return 0;
c0100d5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d64:	c9                   	leave  
c0100d65:	c3                   	ret    

c0100d66 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d66:	55                   	push   %ebp
c0100d67:	89 e5                	mov    %esp,%ebp
c0100d69:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d6c:	e8 c7 fb ff ff       	call   c0100938 <print_kerninfo>
    return 0;
c0100d71:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d76:	c9                   	leave  
c0100d77:	c3                   	ret    

c0100d78 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d78:	55                   	push   %ebp
c0100d79:	89 e5                	mov    %esp,%ebp
c0100d7b:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d7e:	e8 00 fd ff ff       	call   c0100a83 <print_stackframe>
    return 0;
c0100d83:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d88:	c9                   	leave  
c0100d89:	c3                   	ret    

c0100d8a <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d8a:	55                   	push   %ebp
c0100d8b:	89 e5                	mov    %esp,%ebp
c0100d8d:	83 ec 28             	sub    $0x28,%esp
c0100d90:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100d96:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100d9a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100d9e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100da2:	ee                   	out    %al,(%dx)
c0100da3:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100da9:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100dad:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100db1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100db5:	ee                   	out    %al,(%dx)
c0100db6:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100dbc:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
c0100dc0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100dc4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dc8:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dc9:	c7 05 0c df 11 c0 00 	movl   $0x0,0xc011df0c
c0100dd0:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100dd3:	c7 04 24 92 71 10 c0 	movl   $0xc0107192,(%esp)
c0100dda:	e8 b3 f4 ff ff       	call   c0100292 <cprintf>
    pic_enable(IRQ_TIMER);
c0100ddf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100de6:	e8 2e 09 00 00       	call   c0101719 <pic_enable>
}
c0100deb:	90                   	nop
c0100dec:	c9                   	leave  
c0100ded:	c3                   	ret    

c0100dee <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100dee:	55                   	push   %ebp
c0100def:	89 e5                	mov    %esp,%ebp
c0100df1:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100df4:	9c                   	pushf  
c0100df5:	58                   	pop    %eax
c0100df6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100dfc:	25 00 02 00 00       	and    $0x200,%eax
c0100e01:	85 c0                	test   %eax,%eax
c0100e03:	74 0c                	je     c0100e11 <__intr_save+0x23>
        intr_disable();
c0100e05:	e8 83 0a 00 00       	call   c010188d <intr_disable>
        return 1;
c0100e0a:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e0f:	eb 05                	jmp    c0100e16 <__intr_save+0x28>
    }
    return 0;
c0100e11:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e16:	c9                   	leave  
c0100e17:	c3                   	ret    

c0100e18 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e18:	55                   	push   %ebp
c0100e19:	89 e5                	mov    %esp,%ebp
c0100e1b:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e1e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e22:	74 05                	je     c0100e29 <__intr_restore+0x11>
        intr_enable();
c0100e24:	e8 5d 0a 00 00       	call   c0101886 <intr_enable>
    }
}
c0100e29:	90                   	nop
c0100e2a:	c9                   	leave  
c0100e2b:	c3                   	ret    

c0100e2c <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e2c:	55                   	push   %ebp
c0100e2d:	89 e5                	mov    %esp,%ebp
c0100e2f:	83 ec 10             	sub    $0x10,%esp
c0100e32:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e38:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e3c:	89 c2                	mov    %eax,%edx
c0100e3e:	ec                   	in     (%dx),%al
c0100e3f:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100e42:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e48:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e4c:	89 c2                	mov    %eax,%edx
c0100e4e:	ec                   	in     (%dx),%al
c0100e4f:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e52:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e58:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e5c:	89 c2                	mov    %eax,%edx
c0100e5e:	ec                   	in     (%dx),%al
c0100e5f:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e62:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100e68:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e6c:	89 c2                	mov    %eax,%edx
c0100e6e:	ec                   	in     (%dx),%al
c0100e6f:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e72:	90                   	nop
c0100e73:	c9                   	leave  
c0100e74:	c3                   	ret    

c0100e75 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e75:	55                   	push   %ebp
c0100e76:	89 e5                	mov    %esp,%ebp
c0100e78:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e7b:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e82:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e85:	0f b7 00             	movzwl (%eax),%eax
c0100e88:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e8f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e97:	0f b7 00             	movzwl (%eax),%eax
c0100e9a:	0f b7 c0             	movzwl %ax,%eax
c0100e9d:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100ea2:	74 12                	je     c0100eb6 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ea4:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100eab:	66 c7 05 46 d4 11 c0 	movw   $0x3b4,0xc011d446
c0100eb2:	b4 03 
c0100eb4:	eb 13                	jmp    c0100ec9 <cga_init+0x54>
    } else {
        *cp = was;
c0100eb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ebd:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ec0:	66 c7 05 46 d4 11 c0 	movw   $0x3d4,0xc011d446
c0100ec7:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ec9:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c0100ed0:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100ed4:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ed8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100edc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100ee0:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ee1:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c0100ee8:	40                   	inc    %eax
c0100ee9:	0f b7 c0             	movzwl %ax,%eax
c0100eec:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ef0:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ef4:	89 c2                	mov    %eax,%edx
c0100ef6:	ec                   	in     (%dx),%al
c0100ef7:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100efa:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100efe:	0f b6 c0             	movzbl %al,%eax
c0100f01:	c1 e0 08             	shl    $0x8,%eax
c0100f04:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f07:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c0100f0e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f12:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f16:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f1a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f1e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f1f:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c0100f26:	40                   	inc    %eax
c0100f27:	0f b7 c0             	movzwl %ax,%eax
c0100f2a:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f2e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f32:	89 c2                	mov    %eax,%edx
c0100f34:	ec                   	in     (%dx),%al
c0100f35:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100f38:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f3c:	0f b6 c0             	movzbl %al,%eax
c0100f3f:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f42:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f45:	a3 40 d4 11 c0       	mov    %eax,0xc011d440
    crt_pos = pos;
c0100f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f4d:	0f b7 c0             	movzwl %ax,%eax
c0100f50:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
}
c0100f56:	90                   	nop
c0100f57:	c9                   	leave  
c0100f58:	c3                   	ret    

c0100f59 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f59:	55                   	push   %ebp
c0100f5a:	89 e5                	mov    %esp,%ebp
c0100f5c:	83 ec 48             	sub    $0x48,%esp
c0100f5f:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100f65:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f69:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100f6d:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100f71:	ee                   	out    %al,(%dx)
c0100f72:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100f78:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
c0100f7c:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100f80:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0100f84:	ee                   	out    %al,(%dx)
c0100f85:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0100f8b:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
c0100f8f:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0100f93:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0100f97:	ee                   	out    %al,(%dx)
c0100f98:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100f9e:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0100fa2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fa6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100faa:	ee                   	out    %al,(%dx)
c0100fab:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0100fb1:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
c0100fb5:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fb9:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fbd:	ee                   	out    %al,(%dx)
c0100fbe:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0100fc4:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
c0100fc8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fcc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fd0:	ee                   	out    %al,(%dx)
c0100fd1:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fd7:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
c0100fdb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fdf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fe3:	ee                   	out    %al,(%dx)
c0100fe4:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fea:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100fee:	89 c2                	mov    %eax,%edx
c0100ff0:	ec                   	in     (%dx),%al
c0100ff1:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100ff4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100ff8:	3c ff                	cmp    $0xff,%al
c0100ffa:	0f 95 c0             	setne  %al
c0100ffd:	0f b6 c0             	movzbl %al,%eax
c0101000:	a3 48 d4 11 c0       	mov    %eax,0xc011d448
c0101005:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010100b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010100f:	89 c2                	mov    %eax,%edx
c0101011:	ec                   	in     (%dx),%al
c0101012:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101015:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010101b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010101f:	89 c2                	mov    %eax,%edx
c0101021:	ec                   	in     (%dx),%al
c0101022:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101025:	a1 48 d4 11 c0       	mov    0xc011d448,%eax
c010102a:	85 c0                	test   %eax,%eax
c010102c:	74 0c                	je     c010103a <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c010102e:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101035:	e8 df 06 00 00       	call   c0101719 <pic_enable>
    }
}
c010103a:	90                   	nop
c010103b:	c9                   	leave  
c010103c:	c3                   	ret    

c010103d <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010103d:	55                   	push   %ebp
c010103e:	89 e5                	mov    %esp,%ebp
c0101040:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101043:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010104a:	eb 08                	jmp    c0101054 <lpt_putc_sub+0x17>
        delay();
c010104c:	e8 db fd ff ff       	call   c0100e2c <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101051:	ff 45 fc             	incl   -0x4(%ebp)
c0101054:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010105a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010105e:	89 c2                	mov    %eax,%edx
c0101060:	ec                   	in     (%dx),%al
c0101061:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101064:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101068:	84 c0                	test   %al,%al
c010106a:	78 09                	js     c0101075 <lpt_putc_sub+0x38>
c010106c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101073:	7e d7                	jle    c010104c <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c0101075:	8b 45 08             	mov    0x8(%ebp),%eax
c0101078:	0f b6 c0             	movzbl %al,%eax
c010107b:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c0101081:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101084:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101088:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010108c:	ee                   	out    %al,(%dx)
c010108d:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101093:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101097:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010109b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010109f:	ee                   	out    %al,(%dx)
c01010a0:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01010a6:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
c01010aa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010ae:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010b2:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010b3:	90                   	nop
c01010b4:	c9                   	leave  
c01010b5:	c3                   	ret    

c01010b6 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010b6:	55                   	push   %ebp
c01010b7:	89 e5                	mov    %esp,%ebp
c01010b9:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010bc:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010c0:	74 0d                	je     c01010cf <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01010c5:	89 04 24             	mov    %eax,(%esp)
c01010c8:	e8 70 ff ff ff       	call   c010103d <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c01010cd:	eb 24                	jmp    c01010f3 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c01010cf:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010d6:	e8 62 ff ff ff       	call   c010103d <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010db:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010e2:	e8 56 ff ff ff       	call   c010103d <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010e7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010ee:	e8 4a ff ff ff       	call   c010103d <lpt_putc_sub>
}
c01010f3:	90                   	nop
c01010f4:	c9                   	leave  
c01010f5:	c3                   	ret    

c01010f6 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01010f6:	55                   	push   %ebp
c01010f7:	89 e5                	mov    %esp,%ebp
c01010f9:	53                   	push   %ebx
c01010fa:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01010fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101100:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101105:	85 c0                	test   %eax,%eax
c0101107:	75 07                	jne    c0101110 <cga_putc+0x1a>
        c |= 0x0700;
c0101109:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101110:	8b 45 08             	mov    0x8(%ebp),%eax
c0101113:	0f b6 c0             	movzbl %al,%eax
c0101116:	83 f8 0a             	cmp    $0xa,%eax
c0101119:	74 55                	je     c0101170 <cga_putc+0x7a>
c010111b:	83 f8 0d             	cmp    $0xd,%eax
c010111e:	74 63                	je     c0101183 <cga_putc+0x8d>
c0101120:	83 f8 08             	cmp    $0x8,%eax
c0101123:	0f 85 94 00 00 00    	jne    c01011bd <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
c0101129:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c0101130:	85 c0                	test   %eax,%eax
c0101132:	0f 84 af 00 00 00    	je     c01011e7 <cga_putc+0xf1>
            crt_pos --;
c0101138:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c010113f:	48                   	dec    %eax
c0101140:	0f b7 c0             	movzwl %ax,%eax
c0101143:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101149:	8b 45 08             	mov    0x8(%ebp),%eax
c010114c:	98                   	cwtl   
c010114d:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101152:	98                   	cwtl   
c0101153:	83 c8 20             	or     $0x20,%eax
c0101156:	98                   	cwtl   
c0101157:	8b 15 40 d4 11 c0    	mov    0xc011d440,%edx
c010115d:	0f b7 0d 44 d4 11 c0 	movzwl 0xc011d444,%ecx
c0101164:	01 c9                	add    %ecx,%ecx
c0101166:	01 ca                	add    %ecx,%edx
c0101168:	0f b7 c0             	movzwl %ax,%eax
c010116b:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c010116e:	eb 77                	jmp    c01011e7 <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
c0101170:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c0101177:	83 c0 50             	add    $0x50,%eax
c010117a:	0f b7 c0             	movzwl %ax,%eax
c010117d:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101183:	0f b7 1d 44 d4 11 c0 	movzwl 0xc011d444,%ebx
c010118a:	0f b7 0d 44 d4 11 c0 	movzwl 0xc011d444,%ecx
c0101191:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101196:	89 c8                	mov    %ecx,%eax
c0101198:	f7 e2                	mul    %edx
c010119a:	c1 ea 06             	shr    $0x6,%edx
c010119d:	89 d0                	mov    %edx,%eax
c010119f:	c1 e0 02             	shl    $0x2,%eax
c01011a2:	01 d0                	add    %edx,%eax
c01011a4:	c1 e0 04             	shl    $0x4,%eax
c01011a7:	29 c1                	sub    %eax,%ecx
c01011a9:	89 c8                	mov    %ecx,%eax
c01011ab:	0f b7 c0             	movzwl %ax,%eax
c01011ae:	29 c3                	sub    %eax,%ebx
c01011b0:	89 d8                	mov    %ebx,%eax
c01011b2:	0f b7 c0             	movzwl %ax,%eax
c01011b5:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
        break;
c01011bb:	eb 2b                	jmp    c01011e8 <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011bd:	8b 0d 40 d4 11 c0    	mov    0xc011d440,%ecx
c01011c3:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c01011ca:	8d 50 01             	lea    0x1(%eax),%edx
c01011cd:	0f b7 d2             	movzwl %dx,%edx
c01011d0:	66 89 15 44 d4 11 c0 	mov    %dx,0xc011d444
c01011d7:	01 c0                	add    %eax,%eax
c01011d9:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01011df:	0f b7 c0             	movzwl %ax,%eax
c01011e2:	66 89 02             	mov    %ax,(%edx)
        break;
c01011e5:	eb 01                	jmp    c01011e8 <cga_putc+0xf2>
        break;
c01011e7:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011e8:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c01011ef:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c01011f4:	76 5d                	jbe    c0101253 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011f6:	a1 40 d4 11 c0       	mov    0xc011d440,%eax
c01011fb:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101201:	a1 40 d4 11 c0       	mov    0xc011d440,%eax
c0101206:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010120d:	00 
c010120e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101212:	89 04 24             	mov    %eax,(%esp)
c0101215:	e8 a5 54 00 00       	call   c01066bf <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010121a:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101221:	eb 14                	jmp    c0101237 <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
c0101223:	a1 40 d4 11 c0       	mov    0xc011d440,%eax
c0101228:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010122b:	01 d2                	add    %edx,%edx
c010122d:	01 d0                	add    %edx,%eax
c010122f:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101234:	ff 45 f4             	incl   -0xc(%ebp)
c0101237:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010123e:	7e e3                	jle    c0101223 <cga_putc+0x12d>
        }
        crt_pos -= CRT_COLS;
c0101240:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c0101247:	83 e8 50             	sub    $0x50,%eax
c010124a:	0f b7 c0             	movzwl %ax,%eax
c010124d:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101253:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c010125a:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c010125e:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
c0101262:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101266:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010126a:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c010126b:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c0101272:	c1 e8 08             	shr    $0x8,%eax
c0101275:	0f b7 c0             	movzwl %ax,%eax
c0101278:	0f b6 c0             	movzbl %al,%eax
c010127b:	0f b7 15 46 d4 11 c0 	movzwl 0xc011d446,%edx
c0101282:	42                   	inc    %edx
c0101283:	0f b7 d2             	movzwl %dx,%edx
c0101286:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010128a:	88 45 e9             	mov    %al,-0x17(%ebp)
c010128d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101291:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101295:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101296:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c010129d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01012a1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
c01012a5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012a9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012ad:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012ae:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c01012b5:	0f b6 c0             	movzbl %al,%eax
c01012b8:	0f b7 15 46 d4 11 c0 	movzwl 0xc011d446,%edx
c01012bf:	42                   	inc    %edx
c01012c0:	0f b7 d2             	movzwl %dx,%edx
c01012c3:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c01012c7:	88 45 f1             	mov    %al,-0xf(%ebp)
c01012ca:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01012ce:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012d2:	ee                   	out    %al,(%dx)
}
c01012d3:	90                   	nop
c01012d4:	83 c4 34             	add    $0x34,%esp
c01012d7:	5b                   	pop    %ebx
c01012d8:	5d                   	pop    %ebp
c01012d9:	c3                   	ret    

c01012da <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012da:	55                   	push   %ebp
c01012db:	89 e5                	mov    %esp,%ebp
c01012dd:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012e7:	eb 08                	jmp    c01012f1 <serial_putc_sub+0x17>
        delay();
c01012e9:	e8 3e fb ff ff       	call   c0100e2c <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012ee:	ff 45 fc             	incl   -0x4(%ebp)
c01012f1:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012f7:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01012fb:	89 c2                	mov    %eax,%edx
c01012fd:	ec                   	in     (%dx),%al
c01012fe:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101301:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101305:	0f b6 c0             	movzbl %al,%eax
c0101308:	83 e0 20             	and    $0x20,%eax
c010130b:	85 c0                	test   %eax,%eax
c010130d:	75 09                	jne    c0101318 <serial_putc_sub+0x3e>
c010130f:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101316:	7e d1                	jle    c01012e9 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101318:	8b 45 08             	mov    0x8(%ebp),%eax
c010131b:	0f b6 c0             	movzbl %al,%eax
c010131e:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101324:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101327:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010132b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010132f:	ee                   	out    %al,(%dx)
}
c0101330:	90                   	nop
c0101331:	c9                   	leave  
c0101332:	c3                   	ret    

c0101333 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101333:	55                   	push   %ebp
c0101334:	89 e5                	mov    %esp,%ebp
c0101336:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101339:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010133d:	74 0d                	je     c010134c <serial_putc+0x19>
        serial_putc_sub(c);
c010133f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101342:	89 04 24             	mov    %eax,(%esp)
c0101345:	e8 90 ff ff ff       	call   c01012da <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c010134a:	eb 24                	jmp    c0101370 <serial_putc+0x3d>
        serial_putc_sub('\b');
c010134c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101353:	e8 82 ff ff ff       	call   c01012da <serial_putc_sub>
        serial_putc_sub(' ');
c0101358:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010135f:	e8 76 ff ff ff       	call   c01012da <serial_putc_sub>
        serial_putc_sub('\b');
c0101364:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010136b:	e8 6a ff ff ff       	call   c01012da <serial_putc_sub>
}
c0101370:	90                   	nop
c0101371:	c9                   	leave  
c0101372:	c3                   	ret    

c0101373 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101373:	55                   	push   %ebp
c0101374:	89 e5                	mov    %esp,%ebp
c0101376:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101379:	eb 33                	jmp    c01013ae <cons_intr+0x3b>
        if (c != 0) {
c010137b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010137f:	74 2d                	je     c01013ae <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101381:	a1 64 d6 11 c0       	mov    0xc011d664,%eax
c0101386:	8d 50 01             	lea    0x1(%eax),%edx
c0101389:	89 15 64 d6 11 c0    	mov    %edx,0xc011d664
c010138f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101392:	88 90 60 d4 11 c0    	mov    %dl,-0x3fee2ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101398:	a1 64 d6 11 c0       	mov    0xc011d664,%eax
c010139d:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013a2:	75 0a                	jne    c01013ae <cons_intr+0x3b>
                cons.wpos = 0;
c01013a4:	c7 05 64 d6 11 c0 00 	movl   $0x0,0xc011d664
c01013ab:	00 00 00 
    while ((c = (*proc)()) != -1) {
c01013ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01013b1:	ff d0                	call   *%eax
c01013b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013b6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013ba:	75 bf                	jne    c010137b <cons_intr+0x8>
            }
        }
    }
}
c01013bc:	90                   	nop
c01013bd:	c9                   	leave  
c01013be:	c3                   	ret    

c01013bf <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013bf:	55                   	push   %ebp
c01013c0:	89 e5                	mov    %esp,%ebp
c01013c2:	83 ec 10             	sub    $0x10,%esp
c01013c5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013cb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013cf:	89 c2                	mov    %eax,%edx
c01013d1:	ec                   	in     (%dx),%al
c01013d2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013d5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013d9:	0f b6 c0             	movzbl %al,%eax
c01013dc:	83 e0 01             	and    $0x1,%eax
c01013df:	85 c0                	test   %eax,%eax
c01013e1:	75 07                	jne    c01013ea <serial_proc_data+0x2b>
        return -1;
c01013e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013e8:	eb 2a                	jmp    c0101414 <serial_proc_data+0x55>
c01013ea:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013f0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01013f4:	89 c2                	mov    %eax,%edx
c01013f6:	ec                   	in     (%dx),%al
c01013f7:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01013fa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013fe:	0f b6 c0             	movzbl %al,%eax
c0101401:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101404:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101408:	75 07                	jne    c0101411 <serial_proc_data+0x52>
        c = '\b';
c010140a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101414:	c9                   	leave  
c0101415:	c3                   	ret    

c0101416 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101416:	55                   	push   %ebp
c0101417:	89 e5                	mov    %esp,%ebp
c0101419:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010141c:	a1 48 d4 11 c0       	mov    0xc011d448,%eax
c0101421:	85 c0                	test   %eax,%eax
c0101423:	74 0c                	je     c0101431 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101425:	c7 04 24 bf 13 10 c0 	movl   $0xc01013bf,(%esp)
c010142c:	e8 42 ff ff ff       	call   c0101373 <cons_intr>
    }
}
c0101431:	90                   	nop
c0101432:	c9                   	leave  
c0101433:	c3                   	ret    

c0101434 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101434:	55                   	push   %ebp
c0101435:	89 e5                	mov    %esp,%ebp
c0101437:	83 ec 38             	sub    $0x38,%esp
c010143a:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101440:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101443:	89 c2                	mov    %eax,%edx
c0101445:	ec                   	in     (%dx),%al
c0101446:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101449:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010144d:	0f b6 c0             	movzbl %al,%eax
c0101450:	83 e0 01             	and    $0x1,%eax
c0101453:	85 c0                	test   %eax,%eax
c0101455:	75 0a                	jne    c0101461 <kbd_proc_data+0x2d>
        return -1;
c0101457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010145c:	e9 55 01 00 00       	jmp    c01015b6 <kbd_proc_data+0x182>
c0101461:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101467:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010146a:	89 c2                	mov    %eax,%edx
c010146c:	ec                   	in     (%dx),%al
c010146d:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101470:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101474:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101477:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010147b:	75 17                	jne    c0101494 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c010147d:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c0101482:	83 c8 40             	or     $0x40,%eax
c0101485:	a3 68 d6 11 c0       	mov    %eax,0xc011d668
        return 0;
c010148a:	b8 00 00 00 00       	mov    $0x0,%eax
c010148f:	e9 22 01 00 00       	jmp    c01015b6 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
c0101494:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101498:	84 c0                	test   %al,%al
c010149a:	79 45                	jns    c01014e1 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010149c:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c01014a1:	83 e0 40             	and    $0x40,%eax
c01014a4:	85 c0                	test   %eax,%eax
c01014a6:	75 08                	jne    c01014b0 <kbd_proc_data+0x7c>
c01014a8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ac:	24 7f                	and    $0x7f,%al
c01014ae:	eb 04                	jmp    c01014b4 <kbd_proc_data+0x80>
c01014b0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014b4:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014b7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014bb:	0f b6 80 40 a0 11 c0 	movzbl -0x3fee5fc0(%eax),%eax
c01014c2:	0c 40                	or     $0x40,%al
c01014c4:	0f b6 c0             	movzbl %al,%eax
c01014c7:	f7 d0                	not    %eax
c01014c9:	89 c2                	mov    %eax,%edx
c01014cb:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c01014d0:	21 d0                	and    %edx,%eax
c01014d2:	a3 68 d6 11 c0       	mov    %eax,0xc011d668
        return 0;
c01014d7:	b8 00 00 00 00       	mov    $0x0,%eax
c01014dc:	e9 d5 00 00 00       	jmp    c01015b6 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
c01014e1:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c01014e6:	83 e0 40             	and    $0x40,%eax
c01014e9:	85 c0                	test   %eax,%eax
c01014eb:	74 11                	je     c01014fe <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014ed:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014f1:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c01014f6:	83 e0 bf             	and    $0xffffffbf,%eax
c01014f9:	a3 68 d6 11 c0       	mov    %eax,0xc011d668
    }

    shift |= shiftcode[data];
c01014fe:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101502:	0f b6 80 40 a0 11 c0 	movzbl -0x3fee5fc0(%eax),%eax
c0101509:	0f b6 d0             	movzbl %al,%edx
c010150c:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c0101511:	09 d0                	or     %edx,%eax
c0101513:	a3 68 d6 11 c0       	mov    %eax,0xc011d668
    shift ^= togglecode[data];
c0101518:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151c:	0f b6 80 40 a1 11 c0 	movzbl -0x3fee5ec0(%eax),%eax
c0101523:	0f b6 d0             	movzbl %al,%edx
c0101526:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c010152b:	31 d0                	xor    %edx,%eax
c010152d:	a3 68 d6 11 c0       	mov    %eax,0xc011d668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101532:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c0101537:	83 e0 03             	and    $0x3,%eax
c010153a:	8b 14 85 40 a5 11 c0 	mov    -0x3fee5ac0(,%eax,4),%edx
c0101541:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101545:	01 d0                	add    %edx,%eax
c0101547:	0f b6 00             	movzbl (%eax),%eax
c010154a:	0f b6 c0             	movzbl %al,%eax
c010154d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101550:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c0101555:	83 e0 08             	and    $0x8,%eax
c0101558:	85 c0                	test   %eax,%eax
c010155a:	74 22                	je     c010157e <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c010155c:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101560:	7e 0c                	jle    c010156e <kbd_proc_data+0x13a>
c0101562:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101566:	7f 06                	jg     c010156e <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101568:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010156c:	eb 10                	jmp    c010157e <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c010156e:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101572:	7e 0a                	jle    c010157e <kbd_proc_data+0x14a>
c0101574:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101578:	7f 04                	jg     c010157e <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c010157a:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010157e:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c0101583:	f7 d0                	not    %eax
c0101585:	83 e0 06             	and    $0x6,%eax
c0101588:	85 c0                	test   %eax,%eax
c010158a:	75 27                	jne    c01015b3 <kbd_proc_data+0x17f>
c010158c:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101593:	75 1e                	jne    c01015b3 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
c0101595:	c7 04 24 ad 71 10 c0 	movl   $0xc01071ad,(%esp)
c010159c:	e8 f1 ec ff ff       	call   c0100292 <cprintf>
c01015a1:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015a7:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015ab:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015af:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01015b2:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015b6:	c9                   	leave  
c01015b7:	c3                   	ret    

c01015b8 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015b8:	55                   	push   %ebp
c01015b9:	89 e5                	mov    %esp,%ebp
c01015bb:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015be:	c7 04 24 34 14 10 c0 	movl   $0xc0101434,(%esp)
c01015c5:	e8 a9 fd ff ff       	call   c0101373 <cons_intr>
}
c01015ca:	90                   	nop
c01015cb:	c9                   	leave  
c01015cc:	c3                   	ret    

c01015cd <kbd_init>:

static void
kbd_init(void) {
c01015cd:	55                   	push   %ebp
c01015ce:	89 e5                	mov    %esp,%ebp
c01015d0:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015d3:	e8 e0 ff ff ff       	call   c01015b8 <kbd_intr>
    pic_enable(IRQ_KBD);
c01015d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015df:	e8 35 01 00 00       	call   c0101719 <pic_enable>
}
c01015e4:	90                   	nop
c01015e5:	c9                   	leave  
c01015e6:	c3                   	ret    

c01015e7 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015e7:	55                   	push   %ebp
c01015e8:	89 e5                	mov    %esp,%ebp
c01015ea:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015ed:	e8 83 f8 ff ff       	call   c0100e75 <cga_init>
    serial_init();
c01015f2:	e8 62 f9 ff ff       	call   c0100f59 <serial_init>
    kbd_init();
c01015f7:	e8 d1 ff ff ff       	call   c01015cd <kbd_init>
    if (!serial_exists) {
c01015fc:	a1 48 d4 11 c0       	mov    0xc011d448,%eax
c0101601:	85 c0                	test   %eax,%eax
c0101603:	75 0c                	jne    c0101611 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101605:	c7 04 24 b9 71 10 c0 	movl   $0xc01071b9,(%esp)
c010160c:	e8 81 ec ff ff       	call   c0100292 <cprintf>
    }
}
c0101611:	90                   	nop
c0101612:	c9                   	leave  
c0101613:	c3                   	ret    

c0101614 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101614:	55                   	push   %ebp
c0101615:	89 e5                	mov    %esp,%ebp
c0101617:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010161a:	e8 cf f7 ff ff       	call   c0100dee <__intr_save>
c010161f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101622:	8b 45 08             	mov    0x8(%ebp),%eax
c0101625:	89 04 24             	mov    %eax,(%esp)
c0101628:	e8 89 fa ff ff       	call   c01010b6 <lpt_putc>
        cga_putc(c);
c010162d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101630:	89 04 24             	mov    %eax,(%esp)
c0101633:	e8 be fa ff ff       	call   c01010f6 <cga_putc>
        serial_putc(c);
c0101638:	8b 45 08             	mov    0x8(%ebp),%eax
c010163b:	89 04 24             	mov    %eax,(%esp)
c010163e:	e8 f0 fc ff ff       	call   c0101333 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101643:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101646:	89 04 24             	mov    %eax,(%esp)
c0101649:	e8 ca f7 ff ff       	call   c0100e18 <__intr_restore>
}
c010164e:	90                   	nop
c010164f:	c9                   	leave  
c0101650:	c3                   	ret    

c0101651 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101651:	55                   	push   %ebp
c0101652:	89 e5                	mov    %esp,%ebp
c0101654:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010165e:	e8 8b f7 ff ff       	call   c0100dee <__intr_save>
c0101663:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101666:	e8 ab fd ff ff       	call   c0101416 <serial_intr>
        kbd_intr();
c010166b:	e8 48 ff ff ff       	call   c01015b8 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101670:	8b 15 60 d6 11 c0    	mov    0xc011d660,%edx
c0101676:	a1 64 d6 11 c0       	mov    0xc011d664,%eax
c010167b:	39 c2                	cmp    %eax,%edx
c010167d:	74 31                	je     c01016b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010167f:	a1 60 d6 11 c0       	mov    0xc011d660,%eax
c0101684:	8d 50 01             	lea    0x1(%eax),%edx
c0101687:	89 15 60 d6 11 c0    	mov    %edx,0xc011d660
c010168d:	0f b6 80 60 d4 11 c0 	movzbl -0x3fee2ba0(%eax),%eax
c0101694:	0f b6 c0             	movzbl %al,%eax
c0101697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010169a:	a1 60 d6 11 c0       	mov    0xc011d660,%eax
c010169f:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016a4:	75 0a                	jne    c01016b0 <cons_getc+0x5f>
                cons.rpos = 0;
c01016a6:	c7 05 60 d6 11 c0 00 	movl   $0x0,0xc011d660
c01016ad:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016b3:	89 04 24             	mov    %eax,(%esp)
c01016b6:	e8 5d f7 ff ff       	call   c0100e18 <__intr_restore>
    return c;
c01016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016be:	c9                   	leave  
c01016bf:	c3                   	ret    

c01016c0 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016c0:	55                   	push   %ebp
c01016c1:	89 e5                	mov    %esp,%ebp
c01016c3:	83 ec 14             	sub    $0x14,%esp
c01016c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01016c9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016d0:	66 a3 50 a5 11 c0    	mov    %ax,0xc011a550
    if (did_init) {
c01016d6:	a1 6c d6 11 c0       	mov    0xc011d66c,%eax
c01016db:	85 c0                	test   %eax,%eax
c01016dd:	74 37                	je     c0101716 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016df:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016e2:	0f b6 c0             	movzbl %al,%eax
c01016e5:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c01016eb:	88 45 f9             	mov    %al,-0x7(%ebp)
c01016ee:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01016f2:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01016f6:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01016f7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016fb:	c1 e8 08             	shr    $0x8,%eax
c01016fe:	0f b7 c0             	movzwl %ax,%eax
c0101701:	0f b6 c0             	movzbl %al,%eax
c0101704:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c010170a:	88 45 fd             	mov    %al,-0x3(%ebp)
c010170d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101711:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101715:	ee                   	out    %al,(%dx)
    }
}
c0101716:	90                   	nop
c0101717:	c9                   	leave  
c0101718:	c3                   	ret    

c0101719 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101719:	55                   	push   %ebp
c010171a:	89 e5                	mov    %esp,%ebp
c010171c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010171f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101722:	ba 01 00 00 00       	mov    $0x1,%edx
c0101727:	88 c1                	mov    %al,%cl
c0101729:	d3 e2                	shl    %cl,%edx
c010172b:	89 d0                	mov    %edx,%eax
c010172d:	98                   	cwtl   
c010172e:	f7 d0                	not    %eax
c0101730:	0f bf d0             	movswl %ax,%edx
c0101733:	0f b7 05 50 a5 11 c0 	movzwl 0xc011a550,%eax
c010173a:	98                   	cwtl   
c010173b:	21 d0                	and    %edx,%eax
c010173d:	98                   	cwtl   
c010173e:	0f b7 c0             	movzwl %ax,%eax
c0101741:	89 04 24             	mov    %eax,(%esp)
c0101744:	e8 77 ff ff ff       	call   c01016c0 <pic_setmask>
}
c0101749:	90                   	nop
c010174a:	c9                   	leave  
c010174b:	c3                   	ret    

c010174c <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010174c:	55                   	push   %ebp
c010174d:	89 e5                	mov    %esp,%ebp
c010174f:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101752:	c7 05 6c d6 11 c0 01 	movl   $0x1,0xc011d66c
c0101759:	00 00 00 
c010175c:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0101762:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
c0101766:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010176a:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010176e:	ee                   	out    %al,(%dx)
c010176f:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0101775:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
c0101779:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010177d:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101781:	ee                   	out    %al,(%dx)
c0101782:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101788:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
c010178c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101790:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101794:	ee                   	out    %al,(%dx)
c0101795:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c010179b:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c010179f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01017a3:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01017a7:	ee                   	out    %al,(%dx)
c01017a8:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c01017ae:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
c01017b2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01017b6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01017ba:	ee                   	out    %al,(%dx)
c01017bb:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01017c1:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
c01017c5:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017c9:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01017cd:	ee                   	out    %al,(%dx)
c01017ce:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01017d4:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
c01017d8:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01017dc:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01017e0:	ee                   	out    %al,(%dx)
c01017e1:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c01017e7:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
c01017eb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017ef:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017f3:	ee                   	out    %al,(%dx)
c01017f4:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c01017fa:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
c01017fe:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101802:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101806:	ee                   	out    %al,(%dx)
c0101807:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c010180d:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
c0101811:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101815:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101819:	ee                   	out    %al,(%dx)
c010181a:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0101820:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
c0101824:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101828:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010182c:	ee                   	out    %al,(%dx)
c010182d:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0101833:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
c0101837:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010183b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010183f:	ee                   	out    %al,(%dx)
c0101840:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0101846:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
c010184a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010184e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101852:	ee                   	out    %al,(%dx)
c0101853:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c0101859:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
c010185d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101861:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101865:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101866:	0f b7 05 50 a5 11 c0 	movzwl 0xc011a550,%eax
c010186d:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101872:	74 0f                	je     c0101883 <pic_init+0x137>
        pic_setmask(irq_mask);
c0101874:	0f b7 05 50 a5 11 c0 	movzwl 0xc011a550,%eax
c010187b:	89 04 24             	mov    %eax,(%esp)
c010187e:	e8 3d fe ff ff       	call   c01016c0 <pic_setmask>
    }
}
c0101883:	90                   	nop
c0101884:	c9                   	leave  
c0101885:	c3                   	ret    

c0101886 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101886:	55                   	push   %ebp
c0101887:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101889:	fb                   	sti    
    sti();
}
c010188a:	90                   	nop
c010188b:	5d                   	pop    %ebp
c010188c:	c3                   	ret    

c010188d <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010188d:	55                   	push   %ebp
c010188e:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101890:	fa                   	cli    
    cli();
}
c0101891:	90                   	nop
c0101892:	5d                   	pop    %ebp
c0101893:	c3                   	ret    

c0101894 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0101894:	55                   	push   %ebp
c0101895:	89 e5                	mov    %esp,%ebp
c0101897:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010189a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01018a1:	00 
c01018a2:	c7 04 24 e0 71 10 c0 	movl   $0xc01071e0,(%esp)
c01018a9:	e8 e4 e9 ff ff       	call   c0100292 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01018ae:	c7 04 24 ea 71 10 c0 	movl   $0xc01071ea,(%esp)
c01018b5:	e8 d8 e9 ff ff       	call   c0100292 <cprintf>
    panic("EOT: kernel seems ok.");
c01018ba:	c7 44 24 08 f8 71 10 	movl   $0xc01071f8,0x8(%esp)
c01018c1:	c0 
c01018c2:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c01018c9:	00 
c01018ca:	c7 04 24 0e 72 10 c0 	movl   $0xc010720e,(%esp)
c01018d1:	e8 13 eb ff ff       	call   c01003e9 <__panic>

c01018d6 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018d6:	55                   	push   %ebp
c01018d7:	89 e5                	mov    %esp,%ebp
c01018d9:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	for(int i=0;i<256;i++){
c01018dc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018e3:	e9 c4 00 00 00       	jmp    c01019ac <idt_init+0xd6>
		SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL)
c01018e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018eb:	8b 04 85 e0 a5 11 c0 	mov    -0x3fee5a20(,%eax,4),%eax
c01018f2:	0f b7 d0             	movzwl %ax,%edx
c01018f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f8:	66 89 14 c5 80 d6 11 	mov    %dx,-0x3fee2980(,%eax,8)
c01018ff:	c0 
c0101900:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101903:	66 c7 04 c5 82 d6 11 	movw   $0x8,-0x3fee297e(,%eax,8)
c010190a:	c0 08 00 
c010190d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101910:	0f b6 14 c5 84 d6 11 	movzbl -0x3fee297c(,%eax,8),%edx
c0101917:	c0 
c0101918:	80 e2 e0             	and    $0xe0,%dl
c010191b:	88 14 c5 84 d6 11 c0 	mov    %dl,-0x3fee297c(,%eax,8)
c0101922:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101925:	0f b6 14 c5 84 d6 11 	movzbl -0x3fee297c(,%eax,8),%edx
c010192c:	c0 
c010192d:	80 e2 1f             	and    $0x1f,%dl
c0101930:	88 14 c5 84 d6 11 c0 	mov    %dl,-0x3fee297c(,%eax,8)
c0101937:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010193a:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c0101941:	c0 
c0101942:	80 e2 f0             	and    $0xf0,%dl
c0101945:	80 ca 0e             	or     $0xe,%dl
c0101948:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c010194f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101952:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c0101959:	c0 
c010195a:	80 e2 ef             	and    $0xef,%dl
c010195d:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c0101964:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101967:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c010196e:	c0 
c010196f:	80 e2 9f             	and    $0x9f,%dl
c0101972:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c0101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197c:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c0101983:	c0 
c0101984:	80 ca 80             	or     $0x80,%dl
c0101987:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c010198e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101991:	8b 04 85 e0 a5 11 c0 	mov    -0x3fee5a20(,%eax,4),%eax
c0101998:	c1 e8 10             	shr    $0x10,%eax
c010199b:	0f b7 d0             	movzwl %ax,%edx
c010199e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019a1:	66 89 14 c5 86 d6 11 	mov    %dx,-0x3fee297a(,%eax,8)
c01019a8:	c0 
	for(int i=0;i<256;i++){
c01019a9:	ff 45 fc             	incl   -0x4(%ebp)
c01019ac:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c01019b3:	0f 8e 2f ff ff ff    	jle    c01018e8 <idt_init+0x12>
c01019b9:	c7 45 f8 60 a5 11 c0 	movl   $0xc011a560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01019c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01019c3:	0f 01 18             	lidtl  (%eax)
	}
	lidt(&idt_pd);
}
c01019c6:	90                   	nop
c01019c7:	c9                   	leave  
c01019c8:	c3                   	ret    

c01019c9 <trapname>:

static const char *
trapname(int trapno) {
c01019c9:	55                   	push   %ebp
c01019ca:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01019cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01019cf:	83 f8 13             	cmp    $0x13,%eax
c01019d2:	77 0c                	ja     c01019e0 <trapname+0x17>
        return excnames[trapno];
c01019d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01019d7:	8b 04 85 60 75 10 c0 	mov    -0x3fef8aa0(,%eax,4),%eax
c01019de:	eb 18                	jmp    c01019f8 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01019e0:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01019e4:	7e 0d                	jle    c01019f3 <trapname+0x2a>
c01019e6:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01019ea:	7f 07                	jg     c01019f3 <trapname+0x2a>
        return "Hardware Interrupt";
c01019ec:	b8 1f 72 10 c0       	mov    $0xc010721f,%eax
c01019f1:	eb 05                	jmp    c01019f8 <trapname+0x2f>
    }
    return "(unknown trap)";
c01019f3:	b8 32 72 10 c0       	mov    $0xc0107232,%eax
}
c01019f8:	5d                   	pop    %ebp
c01019f9:	c3                   	ret    

c01019fa <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01019fa:	55                   	push   %ebp
c01019fb:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01019fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a00:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a04:	83 f8 08             	cmp    $0x8,%eax
c0101a07:	0f 94 c0             	sete   %al
c0101a0a:	0f b6 c0             	movzbl %al,%eax
}
c0101a0d:	5d                   	pop    %ebp
c0101a0e:	c3                   	ret    

c0101a0f <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a0f:	55                   	push   %ebp
c0101a10:	89 e5                	mov    %esp,%ebp
c0101a12:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a15:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a18:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a1c:	c7 04 24 73 72 10 c0 	movl   $0xc0107273,(%esp)
c0101a23:	e8 6a e8 ff ff       	call   c0100292 <cprintf>
    print_regs(&tf->tf_regs);
c0101a28:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a2b:	89 04 24             	mov    %eax,(%esp)
c0101a2e:	e8 8f 01 00 00       	call   c0101bc2 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a33:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a36:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a3a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a3e:	c7 04 24 84 72 10 c0 	movl   $0xc0107284,(%esp)
c0101a45:	e8 48 e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a4d:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a51:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a55:	c7 04 24 97 72 10 c0 	movl   $0xc0107297,(%esp)
c0101a5c:	e8 31 e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101a61:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a64:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101a68:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a6c:	c7 04 24 aa 72 10 c0 	movl   $0xc01072aa,(%esp)
c0101a73:	e8 1a e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101a78:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a7b:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a83:	c7 04 24 bd 72 10 c0 	movl   $0xc01072bd,(%esp)
c0101a8a:	e8 03 e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a92:	8b 40 30             	mov    0x30(%eax),%eax
c0101a95:	89 04 24             	mov    %eax,(%esp)
c0101a98:	e8 2c ff ff ff       	call   c01019c9 <trapname>
c0101a9d:	89 c2                	mov    %eax,%edx
c0101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa2:	8b 40 30             	mov    0x30(%eax),%eax
c0101aa5:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101aa9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aad:	c7 04 24 d0 72 10 c0 	movl   $0xc01072d0,(%esp)
c0101ab4:	e8 d9 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101ab9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101abc:	8b 40 34             	mov    0x34(%eax),%eax
c0101abf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ac3:	c7 04 24 e2 72 10 c0 	movl   $0xc01072e2,(%esp)
c0101aca:	e8 c3 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101acf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad2:	8b 40 38             	mov    0x38(%eax),%eax
c0101ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ad9:	c7 04 24 f1 72 10 c0 	movl   $0xc01072f1,(%esp)
c0101ae0:	e8 ad e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ae8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101aec:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101af0:	c7 04 24 00 73 10 c0 	movl   $0xc0107300,(%esp)
c0101af7:	e8 96 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101afc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aff:	8b 40 40             	mov    0x40(%eax),%eax
c0101b02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b06:	c7 04 24 13 73 10 c0 	movl   $0xc0107313,(%esp)
c0101b0d:	e8 80 e7 ff ff       	call   c0100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b19:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b20:	eb 3d                	jmp    c0101b5f <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b22:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b25:	8b 50 40             	mov    0x40(%eax),%edx
c0101b28:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b2b:	21 d0                	and    %edx,%eax
c0101b2d:	85 c0                	test   %eax,%eax
c0101b2f:	74 28                	je     c0101b59 <print_trapframe+0x14a>
c0101b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b34:	8b 04 85 80 a5 11 c0 	mov    -0x3fee5a80(,%eax,4),%eax
c0101b3b:	85 c0                	test   %eax,%eax
c0101b3d:	74 1a                	je     c0101b59 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0101b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b42:	8b 04 85 80 a5 11 c0 	mov    -0x3fee5a80(,%eax,4),%eax
c0101b49:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b4d:	c7 04 24 22 73 10 c0 	movl   $0xc0107322,(%esp)
c0101b54:	e8 39 e7 ff ff       	call   c0100292 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b59:	ff 45 f4             	incl   -0xc(%ebp)
c0101b5c:	d1 65 f0             	shll   -0x10(%ebp)
c0101b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b62:	83 f8 17             	cmp    $0x17,%eax
c0101b65:	76 bb                	jbe    c0101b22 <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101b67:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b6a:	8b 40 40             	mov    0x40(%eax),%eax
c0101b6d:	c1 e8 0c             	shr    $0xc,%eax
c0101b70:	83 e0 03             	and    $0x3,%eax
c0101b73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b77:	c7 04 24 26 73 10 c0 	movl   $0xc0107326,(%esp)
c0101b7e:	e8 0f e7 ff ff       	call   c0100292 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101b83:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b86:	89 04 24             	mov    %eax,(%esp)
c0101b89:	e8 6c fe ff ff       	call   c01019fa <trap_in_kernel>
c0101b8e:	85 c0                	test   %eax,%eax
c0101b90:	75 2d                	jne    c0101bbf <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101b92:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b95:	8b 40 44             	mov    0x44(%eax),%eax
c0101b98:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b9c:	c7 04 24 2f 73 10 c0 	movl   $0xc010732f,(%esp)
c0101ba3:	e8 ea e6 ff ff       	call   c0100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101ba8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bab:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101baf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bb3:	c7 04 24 3e 73 10 c0 	movl   $0xc010733e,(%esp)
c0101bba:	e8 d3 e6 ff ff       	call   c0100292 <cprintf>
    }
}
c0101bbf:	90                   	nop
c0101bc0:	c9                   	leave  
c0101bc1:	c3                   	ret    

c0101bc2 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101bc2:	55                   	push   %ebp
c0101bc3:	89 e5                	mov    %esp,%ebp
c0101bc5:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bcb:	8b 00                	mov    (%eax),%eax
c0101bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bd1:	c7 04 24 51 73 10 c0 	movl   $0xc0107351,(%esp)
c0101bd8:	e8 b5 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be0:	8b 40 04             	mov    0x4(%eax),%eax
c0101be3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101be7:	c7 04 24 60 73 10 c0 	movl   $0xc0107360,(%esp)
c0101bee:	e8 9f e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf6:	8b 40 08             	mov    0x8(%eax),%eax
c0101bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bfd:	c7 04 24 6f 73 10 c0 	movl   $0xc010736f,(%esp)
c0101c04:	e8 89 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c09:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0c:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c13:	c7 04 24 7e 73 10 c0 	movl   $0xc010737e,(%esp)
c0101c1a:	e8 73 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c22:	8b 40 10             	mov    0x10(%eax),%eax
c0101c25:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c29:	c7 04 24 8d 73 10 c0 	movl   $0xc010738d,(%esp)
c0101c30:	e8 5d e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c38:	8b 40 14             	mov    0x14(%eax),%eax
c0101c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c3f:	c7 04 24 9c 73 10 c0 	movl   $0xc010739c,(%esp)
c0101c46:	e8 47 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c4e:	8b 40 18             	mov    0x18(%eax),%eax
c0101c51:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c55:	c7 04 24 ab 73 10 c0 	movl   $0xc01073ab,(%esp)
c0101c5c:	e8 31 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101c61:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c64:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101c67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c6b:	c7 04 24 ba 73 10 c0 	movl   $0xc01073ba,(%esp)
c0101c72:	e8 1b e6 ff ff       	call   c0100292 <cprintf>
}
c0101c77:	90                   	nop
c0101c78:	c9                   	leave  
c0101c79:	c3                   	ret    

c0101c7a <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101c7a:	55                   	push   %ebp
c0101c7b:	89 e5                	mov    %esp,%ebp
c0101c7d:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101c80:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c83:	8b 40 30             	mov    0x30(%eax),%eax
c0101c86:	83 f8 2f             	cmp    $0x2f,%eax
c0101c89:	77 21                	ja     c0101cac <trap_dispatch+0x32>
c0101c8b:	83 f8 2e             	cmp    $0x2e,%eax
c0101c8e:	0f 83 0c 01 00 00    	jae    c0101da0 <trap_dispatch+0x126>
c0101c94:	83 f8 21             	cmp    $0x21,%eax
c0101c97:	0f 84 8c 00 00 00    	je     c0101d29 <trap_dispatch+0xaf>
c0101c9d:	83 f8 24             	cmp    $0x24,%eax
c0101ca0:	74 61                	je     c0101d03 <trap_dispatch+0x89>
c0101ca2:	83 f8 20             	cmp    $0x20,%eax
c0101ca5:	74 16                	je     c0101cbd <trap_dispatch+0x43>
c0101ca7:	e9 bf 00 00 00       	jmp    c0101d6b <trap_dispatch+0xf1>
c0101cac:	83 e8 78             	sub    $0x78,%eax
c0101caf:	83 f8 01             	cmp    $0x1,%eax
c0101cb2:	0f 87 b3 00 00 00    	ja     c0101d6b <trap_dispatch+0xf1>
c0101cb8:	e9 92 00 00 00       	jmp    c0101d4f <trap_dispatch+0xd5>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	ticks+=1;
c0101cbd:	a1 0c df 11 c0       	mov    0xc011df0c,%eax
c0101cc2:	40                   	inc    %eax
c0101cc3:	a3 0c df 11 c0       	mov    %eax,0xc011df0c
	if(ticks%TICK_NUM==0){
c0101cc8:	8b 0d 0c df 11 c0    	mov    0xc011df0c,%ecx
c0101cce:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101cd3:	89 c8                	mov    %ecx,%eax
c0101cd5:	f7 e2                	mul    %edx
c0101cd7:	c1 ea 05             	shr    $0x5,%edx
c0101cda:	89 d0                	mov    %edx,%eax
c0101cdc:	c1 e0 02             	shl    $0x2,%eax
c0101cdf:	01 d0                	add    %edx,%eax
c0101ce1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101ce8:	01 d0                	add    %edx,%eax
c0101cea:	c1 e0 02             	shl    $0x2,%eax
c0101ced:	29 c1                	sub    %eax,%ecx
c0101cef:	89 ca                	mov    %ecx,%edx
c0101cf1:	85 d2                	test   %edx,%edx
c0101cf3:	0f 85 aa 00 00 00    	jne    c0101da3 <trap_dispatch+0x129>
		print_ticks();	
c0101cf9:	e8 96 fb ff ff       	call   c0101894 <print_ticks>
	}
        break;
c0101cfe:	e9 a0 00 00 00       	jmp    c0101da3 <trap_dispatch+0x129>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d03:	e8 49 f9 ff ff       	call   c0101651 <cons_getc>
c0101d08:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d0b:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d0f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d13:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d17:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d1b:	c7 04 24 c9 73 10 c0 	movl   $0xc01073c9,(%esp)
c0101d22:	e8 6b e5 ff ff       	call   c0100292 <cprintf>
        break;
c0101d27:	eb 7b                	jmp    c0101da4 <trap_dispatch+0x12a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d29:	e8 23 f9 ff ff       	call   c0101651 <cons_getc>
c0101d2e:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d31:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d35:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d39:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d41:	c7 04 24 db 73 10 c0 	movl   $0xc01073db,(%esp)
c0101d48:	e8 45 e5 ff ff       	call   c0100292 <cprintf>
        break;
c0101d4d:	eb 55                	jmp    c0101da4 <trap_dispatch+0x12a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101d4f:	c7 44 24 08 ea 73 10 	movl   $0xc01073ea,0x8(%esp)
c0101d56:	c0 
c0101d57:	c7 44 24 04 ab 00 00 	movl   $0xab,0x4(%esp)
c0101d5e:	00 
c0101d5f:	c7 04 24 0e 72 10 c0 	movl   $0xc010720e,(%esp)
c0101d66:	e8 7e e6 ff ff       	call   c01003e9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101d6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d6e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101d72:	83 e0 03             	and    $0x3,%eax
c0101d75:	85 c0                	test   %eax,%eax
c0101d77:	75 2b                	jne    c0101da4 <trap_dispatch+0x12a>
            print_trapframe(tf);
c0101d79:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d7c:	89 04 24             	mov    %eax,(%esp)
c0101d7f:	e8 8b fc ff ff       	call   c0101a0f <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101d84:	c7 44 24 08 fa 73 10 	movl   $0xc01073fa,0x8(%esp)
c0101d8b:	c0 
c0101d8c:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c0101d93:	00 
c0101d94:	c7 04 24 0e 72 10 c0 	movl   $0xc010720e,(%esp)
c0101d9b:	e8 49 e6 ff ff       	call   c01003e9 <__panic>
        break;
c0101da0:	90                   	nop
c0101da1:	eb 01                	jmp    c0101da4 <trap_dispatch+0x12a>
        break;
c0101da3:	90                   	nop
        }
    }
}
c0101da4:	90                   	nop
c0101da5:	c9                   	leave  
c0101da6:	c3                   	ret    

c0101da7 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101da7:	55                   	push   %ebp
c0101da8:	89 e5                	mov    %esp,%ebp
c0101daa:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101dad:	8b 45 08             	mov    0x8(%ebp),%eax
c0101db0:	89 04 24             	mov    %eax,(%esp)
c0101db3:	e8 c2 fe ff ff       	call   c0101c7a <trap_dispatch>
}
c0101db8:	90                   	nop
c0101db9:	c9                   	leave  
c0101dba:	c3                   	ret    

c0101dbb <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101dbb:	6a 00                	push   $0x0
  pushl $0
c0101dbd:	6a 00                	push   $0x0
  jmp __alltraps
c0101dbf:	e9 69 0a 00 00       	jmp    c010282d <__alltraps>

c0101dc4 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101dc4:	6a 00                	push   $0x0
  pushl $1
c0101dc6:	6a 01                	push   $0x1
  jmp __alltraps
c0101dc8:	e9 60 0a 00 00       	jmp    c010282d <__alltraps>

c0101dcd <vector2>:
.globl vector2
vector2:
  pushl $0
c0101dcd:	6a 00                	push   $0x0
  pushl $2
c0101dcf:	6a 02                	push   $0x2
  jmp __alltraps
c0101dd1:	e9 57 0a 00 00       	jmp    c010282d <__alltraps>

c0101dd6 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101dd6:	6a 00                	push   $0x0
  pushl $3
c0101dd8:	6a 03                	push   $0x3
  jmp __alltraps
c0101dda:	e9 4e 0a 00 00       	jmp    c010282d <__alltraps>

c0101ddf <vector4>:
.globl vector4
vector4:
  pushl $0
c0101ddf:	6a 00                	push   $0x0
  pushl $4
c0101de1:	6a 04                	push   $0x4
  jmp __alltraps
c0101de3:	e9 45 0a 00 00       	jmp    c010282d <__alltraps>

c0101de8 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101de8:	6a 00                	push   $0x0
  pushl $5
c0101dea:	6a 05                	push   $0x5
  jmp __alltraps
c0101dec:	e9 3c 0a 00 00       	jmp    c010282d <__alltraps>

c0101df1 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101df1:	6a 00                	push   $0x0
  pushl $6
c0101df3:	6a 06                	push   $0x6
  jmp __alltraps
c0101df5:	e9 33 0a 00 00       	jmp    c010282d <__alltraps>

c0101dfa <vector7>:
.globl vector7
vector7:
  pushl $0
c0101dfa:	6a 00                	push   $0x0
  pushl $7
c0101dfc:	6a 07                	push   $0x7
  jmp __alltraps
c0101dfe:	e9 2a 0a 00 00       	jmp    c010282d <__alltraps>

c0101e03 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101e03:	6a 08                	push   $0x8
  jmp __alltraps
c0101e05:	e9 23 0a 00 00       	jmp    c010282d <__alltraps>

c0101e0a <vector9>:
.globl vector9
vector9:
  pushl $0
c0101e0a:	6a 00                	push   $0x0
  pushl $9
c0101e0c:	6a 09                	push   $0x9
  jmp __alltraps
c0101e0e:	e9 1a 0a 00 00       	jmp    c010282d <__alltraps>

c0101e13 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101e13:	6a 0a                	push   $0xa
  jmp __alltraps
c0101e15:	e9 13 0a 00 00       	jmp    c010282d <__alltraps>

c0101e1a <vector11>:
.globl vector11
vector11:
  pushl $11
c0101e1a:	6a 0b                	push   $0xb
  jmp __alltraps
c0101e1c:	e9 0c 0a 00 00       	jmp    c010282d <__alltraps>

c0101e21 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101e21:	6a 0c                	push   $0xc
  jmp __alltraps
c0101e23:	e9 05 0a 00 00       	jmp    c010282d <__alltraps>

c0101e28 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e28:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e2a:	e9 fe 09 00 00       	jmp    c010282d <__alltraps>

c0101e2f <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e2f:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e31:	e9 f7 09 00 00       	jmp    c010282d <__alltraps>

c0101e36 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e36:	6a 00                	push   $0x0
  pushl $15
c0101e38:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e3a:	e9 ee 09 00 00       	jmp    c010282d <__alltraps>

c0101e3f <vector16>:
.globl vector16
vector16:
  pushl $0
c0101e3f:	6a 00                	push   $0x0
  pushl $16
c0101e41:	6a 10                	push   $0x10
  jmp __alltraps
c0101e43:	e9 e5 09 00 00       	jmp    c010282d <__alltraps>

c0101e48 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101e48:	6a 11                	push   $0x11
  jmp __alltraps
c0101e4a:	e9 de 09 00 00       	jmp    c010282d <__alltraps>

c0101e4f <vector18>:
.globl vector18
vector18:
  pushl $0
c0101e4f:	6a 00                	push   $0x0
  pushl $18
c0101e51:	6a 12                	push   $0x12
  jmp __alltraps
c0101e53:	e9 d5 09 00 00       	jmp    c010282d <__alltraps>

c0101e58 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101e58:	6a 00                	push   $0x0
  pushl $19
c0101e5a:	6a 13                	push   $0x13
  jmp __alltraps
c0101e5c:	e9 cc 09 00 00       	jmp    c010282d <__alltraps>

c0101e61 <vector20>:
.globl vector20
vector20:
  pushl $0
c0101e61:	6a 00                	push   $0x0
  pushl $20
c0101e63:	6a 14                	push   $0x14
  jmp __alltraps
c0101e65:	e9 c3 09 00 00       	jmp    c010282d <__alltraps>

c0101e6a <vector21>:
.globl vector21
vector21:
  pushl $0
c0101e6a:	6a 00                	push   $0x0
  pushl $21
c0101e6c:	6a 15                	push   $0x15
  jmp __alltraps
c0101e6e:	e9 ba 09 00 00       	jmp    c010282d <__alltraps>

c0101e73 <vector22>:
.globl vector22
vector22:
  pushl $0
c0101e73:	6a 00                	push   $0x0
  pushl $22
c0101e75:	6a 16                	push   $0x16
  jmp __alltraps
c0101e77:	e9 b1 09 00 00       	jmp    c010282d <__alltraps>

c0101e7c <vector23>:
.globl vector23
vector23:
  pushl $0
c0101e7c:	6a 00                	push   $0x0
  pushl $23
c0101e7e:	6a 17                	push   $0x17
  jmp __alltraps
c0101e80:	e9 a8 09 00 00       	jmp    c010282d <__alltraps>

c0101e85 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101e85:	6a 00                	push   $0x0
  pushl $24
c0101e87:	6a 18                	push   $0x18
  jmp __alltraps
c0101e89:	e9 9f 09 00 00       	jmp    c010282d <__alltraps>

c0101e8e <vector25>:
.globl vector25
vector25:
  pushl $0
c0101e8e:	6a 00                	push   $0x0
  pushl $25
c0101e90:	6a 19                	push   $0x19
  jmp __alltraps
c0101e92:	e9 96 09 00 00       	jmp    c010282d <__alltraps>

c0101e97 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101e97:	6a 00                	push   $0x0
  pushl $26
c0101e99:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101e9b:	e9 8d 09 00 00       	jmp    c010282d <__alltraps>

c0101ea0 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101ea0:	6a 00                	push   $0x0
  pushl $27
c0101ea2:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101ea4:	e9 84 09 00 00       	jmp    c010282d <__alltraps>

c0101ea9 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101ea9:	6a 00                	push   $0x0
  pushl $28
c0101eab:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101ead:	e9 7b 09 00 00       	jmp    c010282d <__alltraps>

c0101eb2 <vector29>:
.globl vector29
vector29:
  pushl $0
c0101eb2:	6a 00                	push   $0x0
  pushl $29
c0101eb4:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101eb6:	e9 72 09 00 00       	jmp    c010282d <__alltraps>

c0101ebb <vector30>:
.globl vector30
vector30:
  pushl $0
c0101ebb:	6a 00                	push   $0x0
  pushl $30
c0101ebd:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101ebf:	e9 69 09 00 00       	jmp    c010282d <__alltraps>

c0101ec4 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101ec4:	6a 00                	push   $0x0
  pushl $31
c0101ec6:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101ec8:	e9 60 09 00 00       	jmp    c010282d <__alltraps>

c0101ecd <vector32>:
.globl vector32
vector32:
  pushl $0
c0101ecd:	6a 00                	push   $0x0
  pushl $32
c0101ecf:	6a 20                	push   $0x20
  jmp __alltraps
c0101ed1:	e9 57 09 00 00       	jmp    c010282d <__alltraps>

c0101ed6 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101ed6:	6a 00                	push   $0x0
  pushl $33
c0101ed8:	6a 21                	push   $0x21
  jmp __alltraps
c0101eda:	e9 4e 09 00 00       	jmp    c010282d <__alltraps>

c0101edf <vector34>:
.globl vector34
vector34:
  pushl $0
c0101edf:	6a 00                	push   $0x0
  pushl $34
c0101ee1:	6a 22                	push   $0x22
  jmp __alltraps
c0101ee3:	e9 45 09 00 00       	jmp    c010282d <__alltraps>

c0101ee8 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101ee8:	6a 00                	push   $0x0
  pushl $35
c0101eea:	6a 23                	push   $0x23
  jmp __alltraps
c0101eec:	e9 3c 09 00 00       	jmp    c010282d <__alltraps>

c0101ef1 <vector36>:
.globl vector36
vector36:
  pushl $0
c0101ef1:	6a 00                	push   $0x0
  pushl $36
c0101ef3:	6a 24                	push   $0x24
  jmp __alltraps
c0101ef5:	e9 33 09 00 00       	jmp    c010282d <__alltraps>

c0101efa <vector37>:
.globl vector37
vector37:
  pushl $0
c0101efa:	6a 00                	push   $0x0
  pushl $37
c0101efc:	6a 25                	push   $0x25
  jmp __alltraps
c0101efe:	e9 2a 09 00 00       	jmp    c010282d <__alltraps>

c0101f03 <vector38>:
.globl vector38
vector38:
  pushl $0
c0101f03:	6a 00                	push   $0x0
  pushl $38
c0101f05:	6a 26                	push   $0x26
  jmp __alltraps
c0101f07:	e9 21 09 00 00       	jmp    c010282d <__alltraps>

c0101f0c <vector39>:
.globl vector39
vector39:
  pushl $0
c0101f0c:	6a 00                	push   $0x0
  pushl $39
c0101f0e:	6a 27                	push   $0x27
  jmp __alltraps
c0101f10:	e9 18 09 00 00       	jmp    c010282d <__alltraps>

c0101f15 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101f15:	6a 00                	push   $0x0
  pushl $40
c0101f17:	6a 28                	push   $0x28
  jmp __alltraps
c0101f19:	e9 0f 09 00 00       	jmp    c010282d <__alltraps>

c0101f1e <vector41>:
.globl vector41
vector41:
  pushl $0
c0101f1e:	6a 00                	push   $0x0
  pushl $41
c0101f20:	6a 29                	push   $0x29
  jmp __alltraps
c0101f22:	e9 06 09 00 00       	jmp    c010282d <__alltraps>

c0101f27 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f27:	6a 00                	push   $0x0
  pushl $42
c0101f29:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f2b:	e9 fd 08 00 00       	jmp    c010282d <__alltraps>

c0101f30 <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f30:	6a 00                	push   $0x0
  pushl $43
c0101f32:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f34:	e9 f4 08 00 00       	jmp    c010282d <__alltraps>

c0101f39 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f39:	6a 00                	push   $0x0
  pushl $44
c0101f3b:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101f3d:	e9 eb 08 00 00       	jmp    c010282d <__alltraps>

c0101f42 <vector45>:
.globl vector45
vector45:
  pushl $0
c0101f42:	6a 00                	push   $0x0
  pushl $45
c0101f44:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101f46:	e9 e2 08 00 00       	jmp    c010282d <__alltraps>

c0101f4b <vector46>:
.globl vector46
vector46:
  pushl $0
c0101f4b:	6a 00                	push   $0x0
  pushl $46
c0101f4d:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101f4f:	e9 d9 08 00 00       	jmp    c010282d <__alltraps>

c0101f54 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101f54:	6a 00                	push   $0x0
  pushl $47
c0101f56:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101f58:	e9 d0 08 00 00       	jmp    c010282d <__alltraps>

c0101f5d <vector48>:
.globl vector48
vector48:
  pushl $0
c0101f5d:	6a 00                	push   $0x0
  pushl $48
c0101f5f:	6a 30                	push   $0x30
  jmp __alltraps
c0101f61:	e9 c7 08 00 00       	jmp    c010282d <__alltraps>

c0101f66 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101f66:	6a 00                	push   $0x0
  pushl $49
c0101f68:	6a 31                	push   $0x31
  jmp __alltraps
c0101f6a:	e9 be 08 00 00       	jmp    c010282d <__alltraps>

c0101f6f <vector50>:
.globl vector50
vector50:
  pushl $0
c0101f6f:	6a 00                	push   $0x0
  pushl $50
c0101f71:	6a 32                	push   $0x32
  jmp __alltraps
c0101f73:	e9 b5 08 00 00       	jmp    c010282d <__alltraps>

c0101f78 <vector51>:
.globl vector51
vector51:
  pushl $0
c0101f78:	6a 00                	push   $0x0
  pushl $51
c0101f7a:	6a 33                	push   $0x33
  jmp __alltraps
c0101f7c:	e9 ac 08 00 00       	jmp    c010282d <__alltraps>

c0101f81 <vector52>:
.globl vector52
vector52:
  pushl $0
c0101f81:	6a 00                	push   $0x0
  pushl $52
c0101f83:	6a 34                	push   $0x34
  jmp __alltraps
c0101f85:	e9 a3 08 00 00       	jmp    c010282d <__alltraps>

c0101f8a <vector53>:
.globl vector53
vector53:
  pushl $0
c0101f8a:	6a 00                	push   $0x0
  pushl $53
c0101f8c:	6a 35                	push   $0x35
  jmp __alltraps
c0101f8e:	e9 9a 08 00 00       	jmp    c010282d <__alltraps>

c0101f93 <vector54>:
.globl vector54
vector54:
  pushl $0
c0101f93:	6a 00                	push   $0x0
  pushl $54
c0101f95:	6a 36                	push   $0x36
  jmp __alltraps
c0101f97:	e9 91 08 00 00       	jmp    c010282d <__alltraps>

c0101f9c <vector55>:
.globl vector55
vector55:
  pushl $0
c0101f9c:	6a 00                	push   $0x0
  pushl $55
c0101f9e:	6a 37                	push   $0x37
  jmp __alltraps
c0101fa0:	e9 88 08 00 00       	jmp    c010282d <__alltraps>

c0101fa5 <vector56>:
.globl vector56
vector56:
  pushl $0
c0101fa5:	6a 00                	push   $0x0
  pushl $56
c0101fa7:	6a 38                	push   $0x38
  jmp __alltraps
c0101fa9:	e9 7f 08 00 00       	jmp    c010282d <__alltraps>

c0101fae <vector57>:
.globl vector57
vector57:
  pushl $0
c0101fae:	6a 00                	push   $0x0
  pushl $57
c0101fb0:	6a 39                	push   $0x39
  jmp __alltraps
c0101fb2:	e9 76 08 00 00       	jmp    c010282d <__alltraps>

c0101fb7 <vector58>:
.globl vector58
vector58:
  pushl $0
c0101fb7:	6a 00                	push   $0x0
  pushl $58
c0101fb9:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101fbb:	e9 6d 08 00 00       	jmp    c010282d <__alltraps>

c0101fc0 <vector59>:
.globl vector59
vector59:
  pushl $0
c0101fc0:	6a 00                	push   $0x0
  pushl $59
c0101fc2:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101fc4:	e9 64 08 00 00       	jmp    c010282d <__alltraps>

c0101fc9 <vector60>:
.globl vector60
vector60:
  pushl $0
c0101fc9:	6a 00                	push   $0x0
  pushl $60
c0101fcb:	6a 3c                	push   $0x3c
  jmp __alltraps
c0101fcd:	e9 5b 08 00 00       	jmp    c010282d <__alltraps>

c0101fd2 <vector61>:
.globl vector61
vector61:
  pushl $0
c0101fd2:	6a 00                	push   $0x0
  pushl $61
c0101fd4:	6a 3d                	push   $0x3d
  jmp __alltraps
c0101fd6:	e9 52 08 00 00       	jmp    c010282d <__alltraps>

c0101fdb <vector62>:
.globl vector62
vector62:
  pushl $0
c0101fdb:	6a 00                	push   $0x0
  pushl $62
c0101fdd:	6a 3e                	push   $0x3e
  jmp __alltraps
c0101fdf:	e9 49 08 00 00       	jmp    c010282d <__alltraps>

c0101fe4 <vector63>:
.globl vector63
vector63:
  pushl $0
c0101fe4:	6a 00                	push   $0x0
  pushl $63
c0101fe6:	6a 3f                	push   $0x3f
  jmp __alltraps
c0101fe8:	e9 40 08 00 00       	jmp    c010282d <__alltraps>

c0101fed <vector64>:
.globl vector64
vector64:
  pushl $0
c0101fed:	6a 00                	push   $0x0
  pushl $64
c0101fef:	6a 40                	push   $0x40
  jmp __alltraps
c0101ff1:	e9 37 08 00 00       	jmp    c010282d <__alltraps>

c0101ff6 <vector65>:
.globl vector65
vector65:
  pushl $0
c0101ff6:	6a 00                	push   $0x0
  pushl $65
c0101ff8:	6a 41                	push   $0x41
  jmp __alltraps
c0101ffa:	e9 2e 08 00 00       	jmp    c010282d <__alltraps>

c0101fff <vector66>:
.globl vector66
vector66:
  pushl $0
c0101fff:	6a 00                	push   $0x0
  pushl $66
c0102001:	6a 42                	push   $0x42
  jmp __alltraps
c0102003:	e9 25 08 00 00       	jmp    c010282d <__alltraps>

c0102008 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102008:	6a 00                	push   $0x0
  pushl $67
c010200a:	6a 43                	push   $0x43
  jmp __alltraps
c010200c:	e9 1c 08 00 00       	jmp    c010282d <__alltraps>

c0102011 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102011:	6a 00                	push   $0x0
  pushl $68
c0102013:	6a 44                	push   $0x44
  jmp __alltraps
c0102015:	e9 13 08 00 00       	jmp    c010282d <__alltraps>

c010201a <vector69>:
.globl vector69
vector69:
  pushl $0
c010201a:	6a 00                	push   $0x0
  pushl $69
c010201c:	6a 45                	push   $0x45
  jmp __alltraps
c010201e:	e9 0a 08 00 00       	jmp    c010282d <__alltraps>

c0102023 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102023:	6a 00                	push   $0x0
  pushl $70
c0102025:	6a 46                	push   $0x46
  jmp __alltraps
c0102027:	e9 01 08 00 00       	jmp    c010282d <__alltraps>

c010202c <vector71>:
.globl vector71
vector71:
  pushl $0
c010202c:	6a 00                	push   $0x0
  pushl $71
c010202e:	6a 47                	push   $0x47
  jmp __alltraps
c0102030:	e9 f8 07 00 00       	jmp    c010282d <__alltraps>

c0102035 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102035:	6a 00                	push   $0x0
  pushl $72
c0102037:	6a 48                	push   $0x48
  jmp __alltraps
c0102039:	e9 ef 07 00 00       	jmp    c010282d <__alltraps>

c010203e <vector73>:
.globl vector73
vector73:
  pushl $0
c010203e:	6a 00                	push   $0x0
  pushl $73
c0102040:	6a 49                	push   $0x49
  jmp __alltraps
c0102042:	e9 e6 07 00 00       	jmp    c010282d <__alltraps>

c0102047 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102047:	6a 00                	push   $0x0
  pushl $74
c0102049:	6a 4a                	push   $0x4a
  jmp __alltraps
c010204b:	e9 dd 07 00 00       	jmp    c010282d <__alltraps>

c0102050 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102050:	6a 00                	push   $0x0
  pushl $75
c0102052:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102054:	e9 d4 07 00 00       	jmp    c010282d <__alltraps>

c0102059 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102059:	6a 00                	push   $0x0
  pushl $76
c010205b:	6a 4c                	push   $0x4c
  jmp __alltraps
c010205d:	e9 cb 07 00 00       	jmp    c010282d <__alltraps>

c0102062 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102062:	6a 00                	push   $0x0
  pushl $77
c0102064:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102066:	e9 c2 07 00 00       	jmp    c010282d <__alltraps>

c010206b <vector78>:
.globl vector78
vector78:
  pushl $0
c010206b:	6a 00                	push   $0x0
  pushl $78
c010206d:	6a 4e                	push   $0x4e
  jmp __alltraps
c010206f:	e9 b9 07 00 00       	jmp    c010282d <__alltraps>

c0102074 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102074:	6a 00                	push   $0x0
  pushl $79
c0102076:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102078:	e9 b0 07 00 00       	jmp    c010282d <__alltraps>

c010207d <vector80>:
.globl vector80
vector80:
  pushl $0
c010207d:	6a 00                	push   $0x0
  pushl $80
c010207f:	6a 50                	push   $0x50
  jmp __alltraps
c0102081:	e9 a7 07 00 00       	jmp    c010282d <__alltraps>

c0102086 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102086:	6a 00                	push   $0x0
  pushl $81
c0102088:	6a 51                	push   $0x51
  jmp __alltraps
c010208a:	e9 9e 07 00 00       	jmp    c010282d <__alltraps>

c010208f <vector82>:
.globl vector82
vector82:
  pushl $0
c010208f:	6a 00                	push   $0x0
  pushl $82
c0102091:	6a 52                	push   $0x52
  jmp __alltraps
c0102093:	e9 95 07 00 00       	jmp    c010282d <__alltraps>

c0102098 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102098:	6a 00                	push   $0x0
  pushl $83
c010209a:	6a 53                	push   $0x53
  jmp __alltraps
c010209c:	e9 8c 07 00 00       	jmp    c010282d <__alltraps>

c01020a1 <vector84>:
.globl vector84
vector84:
  pushl $0
c01020a1:	6a 00                	push   $0x0
  pushl $84
c01020a3:	6a 54                	push   $0x54
  jmp __alltraps
c01020a5:	e9 83 07 00 00       	jmp    c010282d <__alltraps>

c01020aa <vector85>:
.globl vector85
vector85:
  pushl $0
c01020aa:	6a 00                	push   $0x0
  pushl $85
c01020ac:	6a 55                	push   $0x55
  jmp __alltraps
c01020ae:	e9 7a 07 00 00       	jmp    c010282d <__alltraps>

c01020b3 <vector86>:
.globl vector86
vector86:
  pushl $0
c01020b3:	6a 00                	push   $0x0
  pushl $86
c01020b5:	6a 56                	push   $0x56
  jmp __alltraps
c01020b7:	e9 71 07 00 00       	jmp    c010282d <__alltraps>

c01020bc <vector87>:
.globl vector87
vector87:
  pushl $0
c01020bc:	6a 00                	push   $0x0
  pushl $87
c01020be:	6a 57                	push   $0x57
  jmp __alltraps
c01020c0:	e9 68 07 00 00       	jmp    c010282d <__alltraps>

c01020c5 <vector88>:
.globl vector88
vector88:
  pushl $0
c01020c5:	6a 00                	push   $0x0
  pushl $88
c01020c7:	6a 58                	push   $0x58
  jmp __alltraps
c01020c9:	e9 5f 07 00 00       	jmp    c010282d <__alltraps>

c01020ce <vector89>:
.globl vector89
vector89:
  pushl $0
c01020ce:	6a 00                	push   $0x0
  pushl $89
c01020d0:	6a 59                	push   $0x59
  jmp __alltraps
c01020d2:	e9 56 07 00 00       	jmp    c010282d <__alltraps>

c01020d7 <vector90>:
.globl vector90
vector90:
  pushl $0
c01020d7:	6a 00                	push   $0x0
  pushl $90
c01020d9:	6a 5a                	push   $0x5a
  jmp __alltraps
c01020db:	e9 4d 07 00 00       	jmp    c010282d <__alltraps>

c01020e0 <vector91>:
.globl vector91
vector91:
  pushl $0
c01020e0:	6a 00                	push   $0x0
  pushl $91
c01020e2:	6a 5b                	push   $0x5b
  jmp __alltraps
c01020e4:	e9 44 07 00 00       	jmp    c010282d <__alltraps>

c01020e9 <vector92>:
.globl vector92
vector92:
  pushl $0
c01020e9:	6a 00                	push   $0x0
  pushl $92
c01020eb:	6a 5c                	push   $0x5c
  jmp __alltraps
c01020ed:	e9 3b 07 00 00       	jmp    c010282d <__alltraps>

c01020f2 <vector93>:
.globl vector93
vector93:
  pushl $0
c01020f2:	6a 00                	push   $0x0
  pushl $93
c01020f4:	6a 5d                	push   $0x5d
  jmp __alltraps
c01020f6:	e9 32 07 00 00       	jmp    c010282d <__alltraps>

c01020fb <vector94>:
.globl vector94
vector94:
  pushl $0
c01020fb:	6a 00                	push   $0x0
  pushl $94
c01020fd:	6a 5e                	push   $0x5e
  jmp __alltraps
c01020ff:	e9 29 07 00 00       	jmp    c010282d <__alltraps>

c0102104 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102104:	6a 00                	push   $0x0
  pushl $95
c0102106:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102108:	e9 20 07 00 00       	jmp    c010282d <__alltraps>

c010210d <vector96>:
.globl vector96
vector96:
  pushl $0
c010210d:	6a 00                	push   $0x0
  pushl $96
c010210f:	6a 60                	push   $0x60
  jmp __alltraps
c0102111:	e9 17 07 00 00       	jmp    c010282d <__alltraps>

c0102116 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102116:	6a 00                	push   $0x0
  pushl $97
c0102118:	6a 61                	push   $0x61
  jmp __alltraps
c010211a:	e9 0e 07 00 00       	jmp    c010282d <__alltraps>

c010211f <vector98>:
.globl vector98
vector98:
  pushl $0
c010211f:	6a 00                	push   $0x0
  pushl $98
c0102121:	6a 62                	push   $0x62
  jmp __alltraps
c0102123:	e9 05 07 00 00       	jmp    c010282d <__alltraps>

c0102128 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102128:	6a 00                	push   $0x0
  pushl $99
c010212a:	6a 63                	push   $0x63
  jmp __alltraps
c010212c:	e9 fc 06 00 00       	jmp    c010282d <__alltraps>

c0102131 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102131:	6a 00                	push   $0x0
  pushl $100
c0102133:	6a 64                	push   $0x64
  jmp __alltraps
c0102135:	e9 f3 06 00 00       	jmp    c010282d <__alltraps>

c010213a <vector101>:
.globl vector101
vector101:
  pushl $0
c010213a:	6a 00                	push   $0x0
  pushl $101
c010213c:	6a 65                	push   $0x65
  jmp __alltraps
c010213e:	e9 ea 06 00 00       	jmp    c010282d <__alltraps>

c0102143 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102143:	6a 00                	push   $0x0
  pushl $102
c0102145:	6a 66                	push   $0x66
  jmp __alltraps
c0102147:	e9 e1 06 00 00       	jmp    c010282d <__alltraps>

c010214c <vector103>:
.globl vector103
vector103:
  pushl $0
c010214c:	6a 00                	push   $0x0
  pushl $103
c010214e:	6a 67                	push   $0x67
  jmp __alltraps
c0102150:	e9 d8 06 00 00       	jmp    c010282d <__alltraps>

c0102155 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102155:	6a 00                	push   $0x0
  pushl $104
c0102157:	6a 68                	push   $0x68
  jmp __alltraps
c0102159:	e9 cf 06 00 00       	jmp    c010282d <__alltraps>

c010215e <vector105>:
.globl vector105
vector105:
  pushl $0
c010215e:	6a 00                	push   $0x0
  pushl $105
c0102160:	6a 69                	push   $0x69
  jmp __alltraps
c0102162:	e9 c6 06 00 00       	jmp    c010282d <__alltraps>

c0102167 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102167:	6a 00                	push   $0x0
  pushl $106
c0102169:	6a 6a                	push   $0x6a
  jmp __alltraps
c010216b:	e9 bd 06 00 00       	jmp    c010282d <__alltraps>

c0102170 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102170:	6a 00                	push   $0x0
  pushl $107
c0102172:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102174:	e9 b4 06 00 00       	jmp    c010282d <__alltraps>

c0102179 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102179:	6a 00                	push   $0x0
  pushl $108
c010217b:	6a 6c                	push   $0x6c
  jmp __alltraps
c010217d:	e9 ab 06 00 00       	jmp    c010282d <__alltraps>

c0102182 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102182:	6a 00                	push   $0x0
  pushl $109
c0102184:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102186:	e9 a2 06 00 00       	jmp    c010282d <__alltraps>

c010218b <vector110>:
.globl vector110
vector110:
  pushl $0
c010218b:	6a 00                	push   $0x0
  pushl $110
c010218d:	6a 6e                	push   $0x6e
  jmp __alltraps
c010218f:	e9 99 06 00 00       	jmp    c010282d <__alltraps>

c0102194 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102194:	6a 00                	push   $0x0
  pushl $111
c0102196:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102198:	e9 90 06 00 00       	jmp    c010282d <__alltraps>

c010219d <vector112>:
.globl vector112
vector112:
  pushl $0
c010219d:	6a 00                	push   $0x0
  pushl $112
c010219f:	6a 70                	push   $0x70
  jmp __alltraps
c01021a1:	e9 87 06 00 00       	jmp    c010282d <__alltraps>

c01021a6 <vector113>:
.globl vector113
vector113:
  pushl $0
c01021a6:	6a 00                	push   $0x0
  pushl $113
c01021a8:	6a 71                	push   $0x71
  jmp __alltraps
c01021aa:	e9 7e 06 00 00       	jmp    c010282d <__alltraps>

c01021af <vector114>:
.globl vector114
vector114:
  pushl $0
c01021af:	6a 00                	push   $0x0
  pushl $114
c01021b1:	6a 72                	push   $0x72
  jmp __alltraps
c01021b3:	e9 75 06 00 00       	jmp    c010282d <__alltraps>

c01021b8 <vector115>:
.globl vector115
vector115:
  pushl $0
c01021b8:	6a 00                	push   $0x0
  pushl $115
c01021ba:	6a 73                	push   $0x73
  jmp __alltraps
c01021bc:	e9 6c 06 00 00       	jmp    c010282d <__alltraps>

c01021c1 <vector116>:
.globl vector116
vector116:
  pushl $0
c01021c1:	6a 00                	push   $0x0
  pushl $116
c01021c3:	6a 74                	push   $0x74
  jmp __alltraps
c01021c5:	e9 63 06 00 00       	jmp    c010282d <__alltraps>

c01021ca <vector117>:
.globl vector117
vector117:
  pushl $0
c01021ca:	6a 00                	push   $0x0
  pushl $117
c01021cc:	6a 75                	push   $0x75
  jmp __alltraps
c01021ce:	e9 5a 06 00 00       	jmp    c010282d <__alltraps>

c01021d3 <vector118>:
.globl vector118
vector118:
  pushl $0
c01021d3:	6a 00                	push   $0x0
  pushl $118
c01021d5:	6a 76                	push   $0x76
  jmp __alltraps
c01021d7:	e9 51 06 00 00       	jmp    c010282d <__alltraps>

c01021dc <vector119>:
.globl vector119
vector119:
  pushl $0
c01021dc:	6a 00                	push   $0x0
  pushl $119
c01021de:	6a 77                	push   $0x77
  jmp __alltraps
c01021e0:	e9 48 06 00 00       	jmp    c010282d <__alltraps>

c01021e5 <vector120>:
.globl vector120
vector120:
  pushl $0
c01021e5:	6a 00                	push   $0x0
  pushl $120
c01021e7:	6a 78                	push   $0x78
  jmp __alltraps
c01021e9:	e9 3f 06 00 00       	jmp    c010282d <__alltraps>

c01021ee <vector121>:
.globl vector121
vector121:
  pushl $0
c01021ee:	6a 00                	push   $0x0
  pushl $121
c01021f0:	6a 79                	push   $0x79
  jmp __alltraps
c01021f2:	e9 36 06 00 00       	jmp    c010282d <__alltraps>

c01021f7 <vector122>:
.globl vector122
vector122:
  pushl $0
c01021f7:	6a 00                	push   $0x0
  pushl $122
c01021f9:	6a 7a                	push   $0x7a
  jmp __alltraps
c01021fb:	e9 2d 06 00 00       	jmp    c010282d <__alltraps>

c0102200 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102200:	6a 00                	push   $0x0
  pushl $123
c0102202:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102204:	e9 24 06 00 00       	jmp    c010282d <__alltraps>

c0102209 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102209:	6a 00                	push   $0x0
  pushl $124
c010220b:	6a 7c                	push   $0x7c
  jmp __alltraps
c010220d:	e9 1b 06 00 00       	jmp    c010282d <__alltraps>

c0102212 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102212:	6a 00                	push   $0x0
  pushl $125
c0102214:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102216:	e9 12 06 00 00       	jmp    c010282d <__alltraps>

c010221b <vector126>:
.globl vector126
vector126:
  pushl $0
c010221b:	6a 00                	push   $0x0
  pushl $126
c010221d:	6a 7e                	push   $0x7e
  jmp __alltraps
c010221f:	e9 09 06 00 00       	jmp    c010282d <__alltraps>

c0102224 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102224:	6a 00                	push   $0x0
  pushl $127
c0102226:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102228:	e9 00 06 00 00       	jmp    c010282d <__alltraps>

c010222d <vector128>:
.globl vector128
vector128:
  pushl $0
c010222d:	6a 00                	push   $0x0
  pushl $128
c010222f:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102234:	e9 f4 05 00 00       	jmp    c010282d <__alltraps>

c0102239 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102239:	6a 00                	push   $0x0
  pushl $129
c010223b:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102240:	e9 e8 05 00 00       	jmp    c010282d <__alltraps>

c0102245 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102245:	6a 00                	push   $0x0
  pushl $130
c0102247:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010224c:	e9 dc 05 00 00       	jmp    c010282d <__alltraps>

c0102251 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102251:	6a 00                	push   $0x0
  pushl $131
c0102253:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102258:	e9 d0 05 00 00       	jmp    c010282d <__alltraps>

c010225d <vector132>:
.globl vector132
vector132:
  pushl $0
c010225d:	6a 00                	push   $0x0
  pushl $132
c010225f:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102264:	e9 c4 05 00 00       	jmp    c010282d <__alltraps>

c0102269 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102269:	6a 00                	push   $0x0
  pushl $133
c010226b:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102270:	e9 b8 05 00 00       	jmp    c010282d <__alltraps>

c0102275 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102275:	6a 00                	push   $0x0
  pushl $134
c0102277:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c010227c:	e9 ac 05 00 00       	jmp    c010282d <__alltraps>

c0102281 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102281:	6a 00                	push   $0x0
  pushl $135
c0102283:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102288:	e9 a0 05 00 00       	jmp    c010282d <__alltraps>

c010228d <vector136>:
.globl vector136
vector136:
  pushl $0
c010228d:	6a 00                	push   $0x0
  pushl $136
c010228f:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102294:	e9 94 05 00 00       	jmp    c010282d <__alltraps>

c0102299 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102299:	6a 00                	push   $0x0
  pushl $137
c010229b:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01022a0:	e9 88 05 00 00       	jmp    c010282d <__alltraps>

c01022a5 <vector138>:
.globl vector138
vector138:
  pushl $0
c01022a5:	6a 00                	push   $0x0
  pushl $138
c01022a7:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01022ac:	e9 7c 05 00 00       	jmp    c010282d <__alltraps>

c01022b1 <vector139>:
.globl vector139
vector139:
  pushl $0
c01022b1:	6a 00                	push   $0x0
  pushl $139
c01022b3:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01022b8:	e9 70 05 00 00       	jmp    c010282d <__alltraps>

c01022bd <vector140>:
.globl vector140
vector140:
  pushl $0
c01022bd:	6a 00                	push   $0x0
  pushl $140
c01022bf:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01022c4:	e9 64 05 00 00       	jmp    c010282d <__alltraps>

c01022c9 <vector141>:
.globl vector141
vector141:
  pushl $0
c01022c9:	6a 00                	push   $0x0
  pushl $141
c01022cb:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01022d0:	e9 58 05 00 00       	jmp    c010282d <__alltraps>

c01022d5 <vector142>:
.globl vector142
vector142:
  pushl $0
c01022d5:	6a 00                	push   $0x0
  pushl $142
c01022d7:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01022dc:	e9 4c 05 00 00       	jmp    c010282d <__alltraps>

c01022e1 <vector143>:
.globl vector143
vector143:
  pushl $0
c01022e1:	6a 00                	push   $0x0
  pushl $143
c01022e3:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01022e8:	e9 40 05 00 00       	jmp    c010282d <__alltraps>

c01022ed <vector144>:
.globl vector144
vector144:
  pushl $0
c01022ed:	6a 00                	push   $0x0
  pushl $144
c01022ef:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01022f4:	e9 34 05 00 00       	jmp    c010282d <__alltraps>

c01022f9 <vector145>:
.globl vector145
vector145:
  pushl $0
c01022f9:	6a 00                	push   $0x0
  pushl $145
c01022fb:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102300:	e9 28 05 00 00       	jmp    c010282d <__alltraps>

c0102305 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102305:	6a 00                	push   $0x0
  pushl $146
c0102307:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c010230c:	e9 1c 05 00 00       	jmp    c010282d <__alltraps>

c0102311 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102311:	6a 00                	push   $0x0
  pushl $147
c0102313:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102318:	e9 10 05 00 00       	jmp    c010282d <__alltraps>

c010231d <vector148>:
.globl vector148
vector148:
  pushl $0
c010231d:	6a 00                	push   $0x0
  pushl $148
c010231f:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102324:	e9 04 05 00 00       	jmp    c010282d <__alltraps>

c0102329 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102329:	6a 00                	push   $0x0
  pushl $149
c010232b:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102330:	e9 f8 04 00 00       	jmp    c010282d <__alltraps>

c0102335 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102335:	6a 00                	push   $0x0
  pushl $150
c0102337:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010233c:	e9 ec 04 00 00       	jmp    c010282d <__alltraps>

c0102341 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102341:	6a 00                	push   $0x0
  pushl $151
c0102343:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102348:	e9 e0 04 00 00       	jmp    c010282d <__alltraps>

c010234d <vector152>:
.globl vector152
vector152:
  pushl $0
c010234d:	6a 00                	push   $0x0
  pushl $152
c010234f:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102354:	e9 d4 04 00 00       	jmp    c010282d <__alltraps>

c0102359 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102359:	6a 00                	push   $0x0
  pushl $153
c010235b:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102360:	e9 c8 04 00 00       	jmp    c010282d <__alltraps>

c0102365 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102365:	6a 00                	push   $0x0
  pushl $154
c0102367:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010236c:	e9 bc 04 00 00       	jmp    c010282d <__alltraps>

c0102371 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102371:	6a 00                	push   $0x0
  pushl $155
c0102373:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102378:	e9 b0 04 00 00       	jmp    c010282d <__alltraps>

c010237d <vector156>:
.globl vector156
vector156:
  pushl $0
c010237d:	6a 00                	push   $0x0
  pushl $156
c010237f:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102384:	e9 a4 04 00 00       	jmp    c010282d <__alltraps>

c0102389 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102389:	6a 00                	push   $0x0
  pushl $157
c010238b:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102390:	e9 98 04 00 00       	jmp    c010282d <__alltraps>

c0102395 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102395:	6a 00                	push   $0x0
  pushl $158
c0102397:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010239c:	e9 8c 04 00 00       	jmp    c010282d <__alltraps>

c01023a1 <vector159>:
.globl vector159
vector159:
  pushl $0
c01023a1:	6a 00                	push   $0x0
  pushl $159
c01023a3:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01023a8:	e9 80 04 00 00       	jmp    c010282d <__alltraps>

c01023ad <vector160>:
.globl vector160
vector160:
  pushl $0
c01023ad:	6a 00                	push   $0x0
  pushl $160
c01023af:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01023b4:	e9 74 04 00 00       	jmp    c010282d <__alltraps>

c01023b9 <vector161>:
.globl vector161
vector161:
  pushl $0
c01023b9:	6a 00                	push   $0x0
  pushl $161
c01023bb:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01023c0:	e9 68 04 00 00       	jmp    c010282d <__alltraps>

c01023c5 <vector162>:
.globl vector162
vector162:
  pushl $0
c01023c5:	6a 00                	push   $0x0
  pushl $162
c01023c7:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01023cc:	e9 5c 04 00 00       	jmp    c010282d <__alltraps>

c01023d1 <vector163>:
.globl vector163
vector163:
  pushl $0
c01023d1:	6a 00                	push   $0x0
  pushl $163
c01023d3:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01023d8:	e9 50 04 00 00       	jmp    c010282d <__alltraps>

c01023dd <vector164>:
.globl vector164
vector164:
  pushl $0
c01023dd:	6a 00                	push   $0x0
  pushl $164
c01023df:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01023e4:	e9 44 04 00 00       	jmp    c010282d <__alltraps>

c01023e9 <vector165>:
.globl vector165
vector165:
  pushl $0
c01023e9:	6a 00                	push   $0x0
  pushl $165
c01023eb:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01023f0:	e9 38 04 00 00       	jmp    c010282d <__alltraps>

c01023f5 <vector166>:
.globl vector166
vector166:
  pushl $0
c01023f5:	6a 00                	push   $0x0
  pushl $166
c01023f7:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01023fc:	e9 2c 04 00 00       	jmp    c010282d <__alltraps>

c0102401 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102401:	6a 00                	push   $0x0
  pushl $167
c0102403:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102408:	e9 20 04 00 00       	jmp    c010282d <__alltraps>

c010240d <vector168>:
.globl vector168
vector168:
  pushl $0
c010240d:	6a 00                	push   $0x0
  pushl $168
c010240f:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102414:	e9 14 04 00 00       	jmp    c010282d <__alltraps>

c0102419 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102419:	6a 00                	push   $0x0
  pushl $169
c010241b:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102420:	e9 08 04 00 00       	jmp    c010282d <__alltraps>

c0102425 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102425:	6a 00                	push   $0x0
  pushl $170
c0102427:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010242c:	e9 fc 03 00 00       	jmp    c010282d <__alltraps>

c0102431 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102431:	6a 00                	push   $0x0
  pushl $171
c0102433:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102438:	e9 f0 03 00 00       	jmp    c010282d <__alltraps>

c010243d <vector172>:
.globl vector172
vector172:
  pushl $0
c010243d:	6a 00                	push   $0x0
  pushl $172
c010243f:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102444:	e9 e4 03 00 00       	jmp    c010282d <__alltraps>

c0102449 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102449:	6a 00                	push   $0x0
  pushl $173
c010244b:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102450:	e9 d8 03 00 00       	jmp    c010282d <__alltraps>

c0102455 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102455:	6a 00                	push   $0x0
  pushl $174
c0102457:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010245c:	e9 cc 03 00 00       	jmp    c010282d <__alltraps>

c0102461 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102461:	6a 00                	push   $0x0
  pushl $175
c0102463:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102468:	e9 c0 03 00 00       	jmp    c010282d <__alltraps>

c010246d <vector176>:
.globl vector176
vector176:
  pushl $0
c010246d:	6a 00                	push   $0x0
  pushl $176
c010246f:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102474:	e9 b4 03 00 00       	jmp    c010282d <__alltraps>

c0102479 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102479:	6a 00                	push   $0x0
  pushl $177
c010247b:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102480:	e9 a8 03 00 00       	jmp    c010282d <__alltraps>

c0102485 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102485:	6a 00                	push   $0x0
  pushl $178
c0102487:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010248c:	e9 9c 03 00 00       	jmp    c010282d <__alltraps>

c0102491 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102491:	6a 00                	push   $0x0
  pushl $179
c0102493:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102498:	e9 90 03 00 00       	jmp    c010282d <__alltraps>

c010249d <vector180>:
.globl vector180
vector180:
  pushl $0
c010249d:	6a 00                	push   $0x0
  pushl $180
c010249f:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01024a4:	e9 84 03 00 00       	jmp    c010282d <__alltraps>

c01024a9 <vector181>:
.globl vector181
vector181:
  pushl $0
c01024a9:	6a 00                	push   $0x0
  pushl $181
c01024ab:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01024b0:	e9 78 03 00 00       	jmp    c010282d <__alltraps>

c01024b5 <vector182>:
.globl vector182
vector182:
  pushl $0
c01024b5:	6a 00                	push   $0x0
  pushl $182
c01024b7:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01024bc:	e9 6c 03 00 00       	jmp    c010282d <__alltraps>

c01024c1 <vector183>:
.globl vector183
vector183:
  pushl $0
c01024c1:	6a 00                	push   $0x0
  pushl $183
c01024c3:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01024c8:	e9 60 03 00 00       	jmp    c010282d <__alltraps>

c01024cd <vector184>:
.globl vector184
vector184:
  pushl $0
c01024cd:	6a 00                	push   $0x0
  pushl $184
c01024cf:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01024d4:	e9 54 03 00 00       	jmp    c010282d <__alltraps>

c01024d9 <vector185>:
.globl vector185
vector185:
  pushl $0
c01024d9:	6a 00                	push   $0x0
  pushl $185
c01024db:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01024e0:	e9 48 03 00 00       	jmp    c010282d <__alltraps>

c01024e5 <vector186>:
.globl vector186
vector186:
  pushl $0
c01024e5:	6a 00                	push   $0x0
  pushl $186
c01024e7:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01024ec:	e9 3c 03 00 00       	jmp    c010282d <__alltraps>

c01024f1 <vector187>:
.globl vector187
vector187:
  pushl $0
c01024f1:	6a 00                	push   $0x0
  pushl $187
c01024f3:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01024f8:	e9 30 03 00 00       	jmp    c010282d <__alltraps>

c01024fd <vector188>:
.globl vector188
vector188:
  pushl $0
c01024fd:	6a 00                	push   $0x0
  pushl $188
c01024ff:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102504:	e9 24 03 00 00       	jmp    c010282d <__alltraps>

c0102509 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102509:	6a 00                	push   $0x0
  pushl $189
c010250b:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102510:	e9 18 03 00 00       	jmp    c010282d <__alltraps>

c0102515 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102515:	6a 00                	push   $0x0
  pushl $190
c0102517:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010251c:	e9 0c 03 00 00       	jmp    c010282d <__alltraps>

c0102521 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102521:	6a 00                	push   $0x0
  pushl $191
c0102523:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102528:	e9 00 03 00 00       	jmp    c010282d <__alltraps>

c010252d <vector192>:
.globl vector192
vector192:
  pushl $0
c010252d:	6a 00                	push   $0x0
  pushl $192
c010252f:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102534:	e9 f4 02 00 00       	jmp    c010282d <__alltraps>

c0102539 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102539:	6a 00                	push   $0x0
  pushl $193
c010253b:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102540:	e9 e8 02 00 00       	jmp    c010282d <__alltraps>

c0102545 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102545:	6a 00                	push   $0x0
  pushl $194
c0102547:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010254c:	e9 dc 02 00 00       	jmp    c010282d <__alltraps>

c0102551 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102551:	6a 00                	push   $0x0
  pushl $195
c0102553:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102558:	e9 d0 02 00 00       	jmp    c010282d <__alltraps>

c010255d <vector196>:
.globl vector196
vector196:
  pushl $0
c010255d:	6a 00                	push   $0x0
  pushl $196
c010255f:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102564:	e9 c4 02 00 00       	jmp    c010282d <__alltraps>

c0102569 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102569:	6a 00                	push   $0x0
  pushl $197
c010256b:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102570:	e9 b8 02 00 00       	jmp    c010282d <__alltraps>

c0102575 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102575:	6a 00                	push   $0x0
  pushl $198
c0102577:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010257c:	e9 ac 02 00 00       	jmp    c010282d <__alltraps>

c0102581 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102581:	6a 00                	push   $0x0
  pushl $199
c0102583:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102588:	e9 a0 02 00 00       	jmp    c010282d <__alltraps>

c010258d <vector200>:
.globl vector200
vector200:
  pushl $0
c010258d:	6a 00                	push   $0x0
  pushl $200
c010258f:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102594:	e9 94 02 00 00       	jmp    c010282d <__alltraps>

c0102599 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102599:	6a 00                	push   $0x0
  pushl $201
c010259b:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01025a0:	e9 88 02 00 00       	jmp    c010282d <__alltraps>

c01025a5 <vector202>:
.globl vector202
vector202:
  pushl $0
c01025a5:	6a 00                	push   $0x0
  pushl $202
c01025a7:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01025ac:	e9 7c 02 00 00       	jmp    c010282d <__alltraps>

c01025b1 <vector203>:
.globl vector203
vector203:
  pushl $0
c01025b1:	6a 00                	push   $0x0
  pushl $203
c01025b3:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01025b8:	e9 70 02 00 00       	jmp    c010282d <__alltraps>

c01025bd <vector204>:
.globl vector204
vector204:
  pushl $0
c01025bd:	6a 00                	push   $0x0
  pushl $204
c01025bf:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01025c4:	e9 64 02 00 00       	jmp    c010282d <__alltraps>

c01025c9 <vector205>:
.globl vector205
vector205:
  pushl $0
c01025c9:	6a 00                	push   $0x0
  pushl $205
c01025cb:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01025d0:	e9 58 02 00 00       	jmp    c010282d <__alltraps>

c01025d5 <vector206>:
.globl vector206
vector206:
  pushl $0
c01025d5:	6a 00                	push   $0x0
  pushl $206
c01025d7:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01025dc:	e9 4c 02 00 00       	jmp    c010282d <__alltraps>

c01025e1 <vector207>:
.globl vector207
vector207:
  pushl $0
c01025e1:	6a 00                	push   $0x0
  pushl $207
c01025e3:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01025e8:	e9 40 02 00 00       	jmp    c010282d <__alltraps>

c01025ed <vector208>:
.globl vector208
vector208:
  pushl $0
c01025ed:	6a 00                	push   $0x0
  pushl $208
c01025ef:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01025f4:	e9 34 02 00 00       	jmp    c010282d <__alltraps>

c01025f9 <vector209>:
.globl vector209
vector209:
  pushl $0
c01025f9:	6a 00                	push   $0x0
  pushl $209
c01025fb:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102600:	e9 28 02 00 00       	jmp    c010282d <__alltraps>

c0102605 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102605:	6a 00                	push   $0x0
  pushl $210
c0102607:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010260c:	e9 1c 02 00 00       	jmp    c010282d <__alltraps>

c0102611 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102611:	6a 00                	push   $0x0
  pushl $211
c0102613:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102618:	e9 10 02 00 00       	jmp    c010282d <__alltraps>

c010261d <vector212>:
.globl vector212
vector212:
  pushl $0
c010261d:	6a 00                	push   $0x0
  pushl $212
c010261f:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102624:	e9 04 02 00 00       	jmp    c010282d <__alltraps>

c0102629 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102629:	6a 00                	push   $0x0
  pushl $213
c010262b:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102630:	e9 f8 01 00 00       	jmp    c010282d <__alltraps>

c0102635 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102635:	6a 00                	push   $0x0
  pushl $214
c0102637:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010263c:	e9 ec 01 00 00       	jmp    c010282d <__alltraps>

c0102641 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102641:	6a 00                	push   $0x0
  pushl $215
c0102643:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102648:	e9 e0 01 00 00       	jmp    c010282d <__alltraps>

c010264d <vector216>:
.globl vector216
vector216:
  pushl $0
c010264d:	6a 00                	push   $0x0
  pushl $216
c010264f:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102654:	e9 d4 01 00 00       	jmp    c010282d <__alltraps>

c0102659 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102659:	6a 00                	push   $0x0
  pushl $217
c010265b:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102660:	e9 c8 01 00 00       	jmp    c010282d <__alltraps>

c0102665 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102665:	6a 00                	push   $0x0
  pushl $218
c0102667:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010266c:	e9 bc 01 00 00       	jmp    c010282d <__alltraps>

c0102671 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102671:	6a 00                	push   $0x0
  pushl $219
c0102673:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102678:	e9 b0 01 00 00       	jmp    c010282d <__alltraps>

c010267d <vector220>:
.globl vector220
vector220:
  pushl $0
c010267d:	6a 00                	push   $0x0
  pushl $220
c010267f:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102684:	e9 a4 01 00 00       	jmp    c010282d <__alltraps>

c0102689 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102689:	6a 00                	push   $0x0
  pushl $221
c010268b:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102690:	e9 98 01 00 00       	jmp    c010282d <__alltraps>

c0102695 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102695:	6a 00                	push   $0x0
  pushl $222
c0102697:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010269c:	e9 8c 01 00 00       	jmp    c010282d <__alltraps>

c01026a1 <vector223>:
.globl vector223
vector223:
  pushl $0
c01026a1:	6a 00                	push   $0x0
  pushl $223
c01026a3:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01026a8:	e9 80 01 00 00       	jmp    c010282d <__alltraps>

c01026ad <vector224>:
.globl vector224
vector224:
  pushl $0
c01026ad:	6a 00                	push   $0x0
  pushl $224
c01026af:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01026b4:	e9 74 01 00 00       	jmp    c010282d <__alltraps>

c01026b9 <vector225>:
.globl vector225
vector225:
  pushl $0
c01026b9:	6a 00                	push   $0x0
  pushl $225
c01026bb:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01026c0:	e9 68 01 00 00       	jmp    c010282d <__alltraps>

c01026c5 <vector226>:
.globl vector226
vector226:
  pushl $0
c01026c5:	6a 00                	push   $0x0
  pushl $226
c01026c7:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01026cc:	e9 5c 01 00 00       	jmp    c010282d <__alltraps>

c01026d1 <vector227>:
.globl vector227
vector227:
  pushl $0
c01026d1:	6a 00                	push   $0x0
  pushl $227
c01026d3:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01026d8:	e9 50 01 00 00       	jmp    c010282d <__alltraps>

c01026dd <vector228>:
.globl vector228
vector228:
  pushl $0
c01026dd:	6a 00                	push   $0x0
  pushl $228
c01026df:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01026e4:	e9 44 01 00 00       	jmp    c010282d <__alltraps>

c01026e9 <vector229>:
.globl vector229
vector229:
  pushl $0
c01026e9:	6a 00                	push   $0x0
  pushl $229
c01026eb:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01026f0:	e9 38 01 00 00       	jmp    c010282d <__alltraps>

c01026f5 <vector230>:
.globl vector230
vector230:
  pushl $0
c01026f5:	6a 00                	push   $0x0
  pushl $230
c01026f7:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01026fc:	e9 2c 01 00 00       	jmp    c010282d <__alltraps>

c0102701 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102701:	6a 00                	push   $0x0
  pushl $231
c0102703:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102708:	e9 20 01 00 00       	jmp    c010282d <__alltraps>

c010270d <vector232>:
.globl vector232
vector232:
  pushl $0
c010270d:	6a 00                	push   $0x0
  pushl $232
c010270f:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102714:	e9 14 01 00 00       	jmp    c010282d <__alltraps>

c0102719 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102719:	6a 00                	push   $0x0
  pushl $233
c010271b:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102720:	e9 08 01 00 00       	jmp    c010282d <__alltraps>

c0102725 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102725:	6a 00                	push   $0x0
  pushl $234
c0102727:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010272c:	e9 fc 00 00 00       	jmp    c010282d <__alltraps>

c0102731 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102731:	6a 00                	push   $0x0
  pushl $235
c0102733:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102738:	e9 f0 00 00 00       	jmp    c010282d <__alltraps>

c010273d <vector236>:
.globl vector236
vector236:
  pushl $0
c010273d:	6a 00                	push   $0x0
  pushl $236
c010273f:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102744:	e9 e4 00 00 00       	jmp    c010282d <__alltraps>

c0102749 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102749:	6a 00                	push   $0x0
  pushl $237
c010274b:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102750:	e9 d8 00 00 00       	jmp    c010282d <__alltraps>

c0102755 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102755:	6a 00                	push   $0x0
  pushl $238
c0102757:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010275c:	e9 cc 00 00 00       	jmp    c010282d <__alltraps>

c0102761 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102761:	6a 00                	push   $0x0
  pushl $239
c0102763:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102768:	e9 c0 00 00 00       	jmp    c010282d <__alltraps>

c010276d <vector240>:
.globl vector240
vector240:
  pushl $0
c010276d:	6a 00                	push   $0x0
  pushl $240
c010276f:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102774:	e9 b4 00 00 00       	jmp    c010282d <__alltraps>

c0102779 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102779:	6a 00                	push   $0x0
  pushl $241
c010277b:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102780:	e9 a8 00 00 00       	jmp    c010282d <__alltraps>

c0102785 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102785:	6a 00                	push   $0x0
  pushl $242
c0102787:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010278c:	e9 9c 00 00 00       	jmp    c010282d <__alltraps>

c0102791 <vector243>:
.globl vector243
vector243:
  pushl $0
c0102791:	6a 00                	push   $0x0
  pushl $243
c0102793:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102798:	e9 90 00 00 00       	jmp    c010282d <__alltraps>

c010279d <vector244>:
.globl vector244
vector244:
  pushl $0
c010279d:	6a 00                	push   $0x0
  pushl $244
c010279f:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01027a4:	e9 84 00 00 00       	jmp    c010282d <__alltraps>

c01027a9 <vector245>:
.globl vector245
vector245:
  pushl $0
c01027a9:	6a 00                	push   $0x0
  pushl $245
c01027ab:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01027b0:	e9 78 00 00 00       	jmp    c010282d <__alltraps>

c01027b5 <vector246>:
.globl vector246
vector246:
  pushl $0
c01027b5:	6a 00                	push   $0x0
  pushl $246
c01027b7:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01027bc:	e9 6c 00 00 00       	jmp    c010282d <__alltraps>

c01027c1 <vector247>:
.globl vector247
vector247:
  pushl $0
c01027c1:	6a 00                	push   $0x0
  pushl $247
c01027c3:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01027c8:	e9 60 00 00 00       	jmp    c010282d <__alltraps>

c01027cd <vector248>:
.globl vector248
vector248:
  pushl $0
c01027cd:	6a 00                	push   $0x0
  pushl $248
c01027cf:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01027d4:	e9 54 00 00 00       	jmp    c010282d <__alltraps>

c01027d9 <vector249>:
.globl vector249
vector249:
  pushl $0
c01027d9:	6a 00                	push   $0x0
  pushl $249
c01027db:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01027e0:	e9 48 00 00 00       	jmp    c010282d <__alltraps>

c01027e5 <vector250>:
.globl vector250
vector250:
  pushl $0
c01027e5:	6a 00                	push   $0x0
  pushl $250
c01027e7:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01027ec:	e9 3c 00 00 00       	jmp    c010282d <__alltraps>

c01027f1 <vector251>:
.globl vector251
vector251:
  pushl $0
c01027f1:	6a 00                	push   $0x0
  pushl $251
c01027f3:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01027f8:	e9 30 00 00 00       	jmp    c010282d <__alltraps>

c01027fd <vector252>:
.globl vector252
vector252:
  pushl $0
c01027fd:	6a 00                	push   $0x0
  pushl $252
c01027ff:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102804:	e9 24 00 00 00       	jmp    c010282d <__alltraps>

c0102809 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102809:	6a 00                	push   $0x0
  pushl $253
c010280b:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102810:	e9 18 00 00 00       	jmp    c010282d <__alltraps>

c0102815 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102815:	6a 00                	push   $0x0
  pushl $254
c0102817:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010281c:	e9 0c 00 00 00       	jmp    c010282d <__alltraps>

c0102821 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102821:	6a 00                	push   $0x0
  pushl $255
c0102823:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102828:	e9 00 00 00 00       	jmp    c010282d <__alltraps>

c010282d <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c010282d:	1e                   	push   %ds
    pushl %es
c010282e:	06                   	push   %es
    pushl %fs
c010282f:	0f a0                	push   %fs
    pushl %gs
c0102831:	0f a8                	push   %gs
    pushal
c0102833:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102834:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102839:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010283b:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010283d:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010283e:	e8 64 f5 ff ff       	call   c0101da7 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102843:	5c                   	pop    %esp

c0102844 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102844:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102845:	0f a9                	pop    %gs
    popl %fs
c0102847:	0f a1                	pop    %fs
    popl %es
c0102849:	07                   	pop    %es
    popl %ds
c010284a:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010284b:	83 c4 08             	add    $0x8,%esp
    iret
c010284e:	cf                   	iret   

c010284f <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010284f:	55                   	push   %ebp
c0102850:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102852:	8b 45 08             	mov    0x8(%ebp),%eax
c0102855:	8b 15 18 df 11 c0    	mov    0xc011df18,%edx
c010285b:	29 d0                	sub    %edx,%eax
c010285d:	c1 f8 02             	sar    $0x2,%eax
c0102860:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102866:	5d                   	pop    %ebp
c0102867:	c3                   	ret    

c0102868 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102868:	55                   	push   %ebp
c0102869:	89 e5                	mov    %esp,%ebp
c010286b:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010286e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102871:	89 04 24             	mov    %eax,(%esp)
c0102874:	e8 d6 ff ff ff       	call   c010284f <page2ppn>
c0102879:	c1 e0 0c             	shl    $0xc,%eax
}
c010287c:	c9                   	leave  
c010287d:	c3                   	ret    

c010287e <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010287e:	55                   	push   %ebp
c010287f:	89 e5                	mov    %esp,%ebp
c0102881:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0102884:	8b 45 08             	mov    0x8(%ebp),%eax
c0102887:	c1 e8 0c             	shr    $0xc,%eax
c010288a:	89 c2                	mov    %eax,%edx
c010288c:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0102891:	39 c2                	cmp    %eax,%edx
c0102893:	72 1c                	jb     c01028b1 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102895:	c7 44 24 08 b0 75 10 	movl   $0xc01075b0,0x8(%esp)
c010289c:	c0 
c010289d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c01028a4:	00 
c01028a5:	c7 04 24 cf 75 10 c0 	movl   $0xc01075cf,(%esp)
c01028ac:	e8 38 db ff ff       	call   c01003e9 <__panic>
    }
    return &pages[PPN(pa)];
c01028b1:	8b 0d 18 df 11 c0    	mov    0xc011df18,%ecx
c01028b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01028ba:	c1 e8 0c             	shr    $0xc,%eax
c01028bd:	89 c2                	mov    %eax,%edx
c01028bf:	89 d0                	mov    %edx,%eax
c01028c1:	c1 e0 02             	shl    $0x2,%eax
c01028c4:	01 d0                	add    %edx,%eax
c01028c6:	c1 e0 02             	shl    $0x2,%eax
c01028c9:	01 c8                	add    %ecx,%eax
}
c01028cb:	c9                   	leave  
c01028cc:	c3                   	ret    

c01028cd <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01028cd:	55                   	push   %ebp
c01028ce:	89 e5                	mov    %esp,%ebp
c01028d0:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01028d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01028d6:	89 04 24             	mov    %eax,(%esp)
c01028d9:	e8 8a ff ff ff       	call   c0102868 <page2pa>
c01028de:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01028e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028e4:	c1 e8 0c             	shr    $0xc,%eax
c01028e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01028ea:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c01028ef:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01028f2:	72 23                	jb     c0102917 <page2kva+0x4a>
c01028f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028fb:	c7 44 24 08 e0 75 10 	movl   $0xc01075e0,0x8(%esp)
c0102902:	c0 
c0102903:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c010290a:	00 
c010290b:	c7 04 24 cf 75 10 c0 	movl   $0xc01075cf,(%esp)
c0102912:	e8 d2 da ff ff       	call   c01003e9 <__panic>
c0102917:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010291a:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010291f:	c9                   	leave  
c0102920:	c3                   	ret    

c0102921 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0102921:	55                   	push   %ebp
c0102922:	89 e5                	mov    %esp,%ebp
c0102924:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0102927:	8b 45 08             	mov    0x8(%ebp),%eax
c010292a:	83 e0 01             	and    $0x1,%eax
c010292d:	85 c0                	test   %eax,%eax
c010292f:	75 1c                	jne    c010294d <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0102931:	c7 44 24 08 04 76 10 	movl   $0xc0107604,0x8(%esp)
c0102938:	c0 
c0102939:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0102940:	00 
c0102941:	c7 04 24 cf 75 10 c0 	movl   $0xc01075cf,(%esp)
c0102948:	e8 9c da ff ff       	call   c01003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c010294d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102950:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102955:	89 04 24             	mov    %eax,(%esp)
c0102958:	e8 21 ff ff ff       	call   c010287e <pa2page>
}
c010295d:	c9                   	leave  
c010295e:	c3                   	ret    

c010295f <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c010295f:	55                   	push   %ebp
c0102960:	89 e5                	mov    %esp,%ebp
c0102962:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0102965:	8b 45 08             	mov    0x8(%ebp),%eax
c0102968:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010296d:	89 04 24             	mov    %eax,(%esp)
c0102970:	e8 09 ff ff ff       	call   c010287e <pa2page>
}
c0102975:	c9                   	leave  
c0102976:	c3                   	ret    

c0102977 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0102977:	55                   	push   %ebp
c0102978:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010297a:	8b 45 08             	mov    0x8(%ebp),%eax
c010297d:	8b 00                	mov    (%eax),%eax
}
c010297f:	5d                   	pop    %ebp
c0102980:	c3                   	ret    

c0102981 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102981:	55                   	push   %ebp
c0102982:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102984:	8b 45 08             	mov    0x8(%ebp),%eax
c0102987:	8b 55 0c             	mov    0xc(%ebp),%edx
c010298a:	89 10                	mov    %edx,(%eax)
}
c010298c:	90                   	nop
c010298d:	5d                   	pop    %ebp
c010298e:	c3                   	ret    

c010298f <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c010298f:	55                   	push   %ebp
c0102990:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0102992:	8b 45 08             	mov    0x8(%ebp),%eax
c0102995:	8b 00                	mov    (%eax),%eax
c0102997:	8d 50 01             	lea    0x1(%eax),%edx
c010299a:	8b 45 08             	mov    0x8(%ebp),%eax
c010299d:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010299f:	8b 45 08             	mov    0x8(%ebp),%eax
c01029a2:	8b 00                	mov    (%eax),%eax
}
c01029a4:	5d                   	pop    %ebp
c01029a5:	c3                   	ret    

c01029a6 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01029a6:	55                   	push   %ebp
c01029a7:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01029a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01029ac:	8b 00                	mov    (%eax),%eax
c01029ae:	8d 50 ff             	lea    -0x1(%eax),%edx
c01029b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01029b4:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01029b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01029b9:	8b 00                	mov    (%eax),%eax
}
c01029bb:	5d                   	pop    %ebp
c01029bc:	c3                   	ret    

c01029bd <__intr_save>:
__intr_save(void) {
c01029bd:	55                   	push   %ebp
c01029be:	89 e5                	mov    %esp,%ebp
c01029c0:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01029c3:	9c                   	pushf  
c01029c4:	58                   	pop    %eax
c01029c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01029c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01029cb:	25 00 02 00 00       	and    $0x200,%eax
c01029d0:	85 c0                	test   %eax,%eax
c01029d2:	74 0c                	je     c01029e0 <__intr_save+0x23>
        intr_disable();
c01029d4:	e8 b4 ee ff ff       	call   c010188d <intr_disable>
        return 1;
c01029d9:	b8 01 00 00 00       	mov    $0x1,%eax
c01029de:	eb 05                	jmp    c01029e5 <__intr_save+0x28>
    return 0;
c01029e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01029e5:	c9                   	leave  
c01029e6:	c3                   	ret    

c01029e7 <__intr_restore>:
__intr_restore(bool flag) {
c01029e7:	55                   	push   %ebp
c01029e8:	89 e5                	mov    %esp,%ebp
c01029ea:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01029ed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01029f1:	74 05                	je     c01029f8 <__intr_restore+0x11>
        intr_enable();
c01029f3:	e8 8e ee ff ff       	call   c0101886 <intr_enable>
}
c01029f8:	90                   	nop
c01029f9:	c9                   	leave  
c01029fa:	c3                   	ret    

c01029fb <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01029fb:	55                   	push   %ebp
c01029fc:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01029fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a01:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102a04:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a09:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102a0b:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a10:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102a12:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a17:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102a19:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a1e:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102a20:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a25:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102a27:	ea 2e 2a 10 c0 08 00 	ljmp   $0x8,$0xc0102a2e
}
c0102a2e:	90                   	nop
c0102a2f:	5d                   	pop    %ebp
c0102a30:	c3                   	ret    

c0102a31 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102a31:	55                   	push   %ebp
c0102a32:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102a34:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a37:	a3 a4 de 11 c0       	mov    %eax,0xc011dea4
}
c0102a3c:	90                   	nop
c0102a3d:	5d                   	pop    %ebp
c0102a3e:	c3                   	ret    

c0102a3f <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102a3f:	55                   	push   %ebp
c0102a40:	89 e5                	mov    %esp,%ebp
c0102a42:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102a45:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0102a4a:	89 04 24             	mov    %eax,(%esp)
c0102a4d:	e8 df ff ff ff       	call   c0102a31 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102a52:	66 c7 05 a8 de 11 c0 	movw   $0x10,0xc011dea8
c0102a59:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102a5b:	66 c7 05 28 aa 11 c0 	movw   $0x68,0xc011aa28
c0102a62:	68 00 
c0102a64:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102a69:	0f b7 c0             	movzwl %ax,%eax
c0102a6c:	66 a3 2a aa 11 c0    	mov    %ax,0xc011aa2a
c0102a72:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102a77:	c1 e8 10             	shr    $0x10,%eax
c0102a7a:	a2 2c aa 11 c0       	mov    %al,0xc011aa2c
c0102a7f:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102a86:	24 f0                	and    $0xf0,%al
c0102a88:	0c 09                	or     $0x9,%al
c0102a8a:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102a8f:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102a96:	24 ef                	and    $0xef,%al
c0102a98:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102a9d:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102aa4:	24 9f                	and    $0x9f,%al
c0102aa6:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102aab:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102ab2:	0c 80                	or     $0x80,%al
c0102ab4:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102ab9:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102ac0:	24 f0                	and    $0xf0,%al
c0102ac2:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102ac7:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102ace:	24 ef                	and    $0xef,%al
c0102ad0:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102ad5:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102adc:	24 df                	and    $0xdf,%al
c0102ade:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102ae3:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102aea:	0c 40                	or     $0x40,%al
c0102aec:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102af1:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102af8:	24 7f                	and    $0x7f,%al
c0102afa:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102aff:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102b04:	c1 e8 18             	shr    $0x18,%eax
c0102b07:	a2 2f aa 11 c0       	mov    %al,0xc011aa2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102b0c:	c7 04 24 30 aa 11 c0 	movl   $0xc011aa30,(%esp)
c0102b13:	e8 e3 fe ff ff       	call   c01029fb <lgdt>
c0102b18:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102b1e:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102b22:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102b25:	90                   	nop
c0102b26:	c9                   	leave  
c0102b27:	c3                   	ret    

c0102b28 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102b28:	55                   	push   %ebp
c0102b29:	89 e5                	mov    %esp,%ebp
c0102b2b:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102b2e:	c7 05 10 df 11 c0 c0 	movl   $0xc0107fc0,0xc011df10
c0102b35:	7f 10 c0 
    //pmm_manager = &buddy_system;
    cprintf("memory management: %s\n", pmm_manager->name);
c0102b38:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b3d:	8b 00                	mov    (%eax),%eax
c0102b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102b43:	c7 04 24 30 76 10 c0 	movl   $0xc0107630,(%esp)
c0102b4a:	e8 43 d7 ff ff       	call   c0100292 <cprintf>
    pmm_manager->init();
c0102b4f:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b54:	8b 40 04             	mov    0x4(%eax),%eax
c0102b57:	ff d0                	call   *%eax
}
c0102b59:	90                   	nop
c0102b5a:	c9                   	leave  
c0102b5b:	c3                   	ret    

c0102b5c <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102b5c:	55                   	push   %ebp
c0102b5d:	89 e5                	mov    %esp,%ebp
c0102b5f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102b62:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b67:	8b 40 08             	mov    0x8(%eax),%eax
c0102b6a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102b6d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102b71:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b74:	89 14 24             	mov    %edx,(%esp)
c0102b77:	ff d0                	call   *%eax
}
c0102b79:	90                   	nop
c0102b7a:	c9                   	leave  
c0102b7b:	c3                   	ret    

c0102b7c <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102b7c:	55                   	push   %ebp
c0102b7d:	89 e5                	mov    %esp,%ebp
c0102b7f:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102b82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102b89:	e8 2f fe ff ff       	call   c01029bd <__intr_save>
c0102b8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102b91:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b96:	8b 40 0c             	mov    0xc(%eax),%eax
c0102b99:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b9c:	89 14 24             	mov    %edx,(%esp)
c0102b9f:	ff d0                	call   *%eax
c0102ba1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102ba4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ba7:	89 04 24             	mov    %eax,(%esp)
c0102baa:	e8 38 fe ff ff       	call   c01029e7 <__intr_restore>
    return page;
c0102baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102bb2:	c9                   	leave  
c0102bb3:	c3                   	ret    

c0102bb4 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102bb4:	55                   	push   %ebp
c0102bb5:	89 e5                	mov    %esp,%ebp
c0102bb7:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102bba:	e8 fe fd ff ff       	call   c01029bd <__intr_save>
c0102bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102bc2:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102bc7:	8b 40 10             	mov    0x10(%eax),%eax
c0102bca:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102bcd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102bd1:	8b 55 08             	mov    0x8(%ebp),%edx
c0102bd4:	89 14 24             	mov    %edx,(%esp)
c0102bd7:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bdc:	89 04 24             	mov    %eax,(%esp)
c0102bdf:	e8 03 fe ff ff       	call   c01029e7 <__intr_restore>
}
c0102be4:	90                   	nop
c0102be5:	c9                   	leave  
c0102be6:	c3                   	ret    

c0102be7 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102be7:	55                   	push   %ebp
c0102be8:	89 e5                	mov    %esp,%ebp
c0102bea:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102bed:	e8 cb fd ff ff       	call   c01029bd <__intr_save>
c0102bf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102bf5:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102bfa:	8b 40 14             	mov    0x14(%eax),%eax
c0102bfd:	ff d0                	call   *%eax
c0102bff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c05:	89 04 24             	mov    %eax,(%esp)
c0102c08:	e8 da fd ff ff       	call   c01029e7 <__intr_restore>
    return ret;
c0102c0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102c10:	c9                   	leave  
c0102c11:	c3                   	ret    

c0102c12 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102c12:	55                   	push   %ebp
c0102c13:	89 e5                	mov    %esp,%ebp
c0102c15:	57                   	push   %edi
c0102c16:	56                   	push   %esi
c0102c17:	53                   	push   %ebx
c0102c18:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102c1e:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102c25:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102c2c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102c33:	c7 04 24 47 76 10 c0 	movl   $0xc0107647,(%esp)
c0102c3a:	e8 53 d6 ff ff       	call   c0100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102c3f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102c46:	e9 22 01 00 00       	jmp    c0102d6d <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102c4b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c4e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c51:	89 d0                	mov    %edx,%eax
c0102c53:	c1 e0 02             	shl    $0x2,%eax
c0102c56:	01 d0                	add    %edx,%eax
c0102c58:	c1 e0 02             	shl    $0x2,%eax
c0102c5b:	01 c8                	add    %ecx,%eax
c0102c5d:	8b 50 08             	mov    0x8(%eax),%edx
c0102c60:	8b 40 04             	mov    0x4(%eax),%eax
c0102c63:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0102c66:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102c69:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c6c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c6f:	89 d0                	mov    %edx,%eax
c0102c71:	c1 e0 02             	shl    $0x2,%eax
c0102c74:	01 d0                	add    %edx,%eax
c0102c76:	c1 e0 02             	shl    $0x2,%eax
c0102c79:	01 c8                	add    %ecx,%eax
c0102c7b:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102c7e:	8b 58 10             	mov    0x10(%eax),%ebx
c0102c81:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102c84:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102c87:	01 c8                	add    %ecx,%eax
c0102c89:	11 da                	adc    %ebx,%edx
c0102c8b:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102c8e:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102c91:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c94:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c97:	89 d0                	mov    %edx,%eax
c0102c99:	c1 e0 02             	shl    $0x2,%eax
c0102c9c:	01 d0                	add    %edx,%eax
c0102c9e:	c1 e0 02             	shl    $0x2,%eax
c0102ca1:	01 c8                	add    %ecx,%eax
c0102ca3:	83 c0 14             	add    $0x14,%eax
c0102ca6:	8b 00                	mov    (%eax),%eax
c0102ca8:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102cab:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102cae:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102cb1:	83 c0 ff             	add    $0xffffffff,%eax
c0102cb4:	83 d2 ff             	adc    $0xffffffff,%edx
c0102cb7:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102cbd:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102cc3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cc6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102cc9:	89 d0                	mov    %edx,%eax
c0102ccb:	c1 e0 02             	shl    $0x2,%eax
c0102cce:	01 d0                	add    %edx,%eax
c0102cd0:	c1 e0 02             	shl    $0x2,%eax
c0102cd3:	01 c8                	add    %ecx,%eax
c0102cd5:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102cd8:	8b 58 10             	mov    0x10(%eax),%ebx
c0102cdb:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102cde:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102ce2:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102ce8:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102cee:	89 44 24 14          	mov    %eax,0x14(%esp)
c0102cf2:	89 54 24 18          	mov    %edx,0x18(%esp)
c0102cf6:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102cf9:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102cfc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102d00:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102d04:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102d08:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102d0c:	c7 04 24 54 76 10 c0 	movl   $0xc0107654,(%esp)
c0102d13:	e8 7a d5 ff ff       	call   c0100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102d18:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102d1b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d1e:	89 d0                	mov    %edx,%eax
c0102d20:	c1 e0 02             	shl    $0x2,%eax
c0102d23:	01 d0                	add    %edx,%eax
c0102d25:	c1 e0 02             	shl    $0x2,%eax
c0102d28:	01 c8                	add    %ecx,%eax
c0102d2a:	83 c0 14             	add    $0x14,%eax
c0102d2d:	8b 00                	mov    (%eax),%eax
c0102d2f:	83 f8 01             	cmp    $0x1,%eax
c0102d32:	75 36                	jne    c0102d6a <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0102d34:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d37:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d3a:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102d3d:	77 2b                	ja     c0102d6a <page_init+0x158>
c0102d3f:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102d42:	72 05                	jb     c0102d49 <page_init+0x137>
c0102d44:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0102d47:	73 21                	jae    c0102d6a <page_init+0x158>
c0102d49:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102d4d:	77 1b                	ja     c0102d6a <page_init+0x158>
c0102d4f:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102d53:	72 09                	jb     c0102d5e <page_init+0x14c>
c0102d55:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c0102d5c:	77 0c                	ja     c0102d6a <page_init+0x158>
                maxpa = end;
c0102d5e:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102d61:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102d64:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102d67:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0102d6a:	ff 45 dc             	incl   -0x24(%ebp)
c0102d6d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102d70:	8b 00                	mov    (%eax),%eax
c0102d72:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102d75:	0f 8c d0 fe ff ff    	jl     c0102c4b <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102d7b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102d7f:	72 1d                	jb     c0102d9e <page_init+0x18c>
c0102d81:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102d85:	77 09                	ja     c0102d90 <page_init+0x17e>
c0102d87:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102d8e:	76 0e                	jbe    c0102d9e <page_init+0x18c>
        maxpa = KMEMSIZE;
c0102d90:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102d97:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102d9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102da1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102da4:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102da8:	c1 ea 0c             	shr    $0xc,%edx
c0102dab:	89 c1                	mov    %eax,%ecx
c0102dad:	89 d3                	mov    %edx,%ebx
c0102daf:	89 c8                	mov    %ecx,%eax
c0102db1:	a3 80 de 11 c0       	mov    %eax,0xc011de80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102db6:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0102dbd:	b8 bc df 11 c0       	mov    $0xc011dfbc,%eax
c0102dc2:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102dc5:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102dc8:	01 d0                	add    %edx,%eax
c0102dca:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0102dcd:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102dd0:	ba 00 00 00 00       	mov    $0x0,%edx
c0102dd5:	f7 75 c0             	divl   -0x40(%ebp)
c0102dd8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102ddb:	29 d0                	sub    %edx,%eax
c0102ddd:	a3 18 df 11 c0       	mov    %eax,0xc011df18

    for (i = 0; i < npage; i ++) {
c0102de2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102de9:	eb 2e                	jmp    c0102e19 <page_init+0x207>
        SetPageReserved(pages + i);
c0102deb:	8b 0d 18 df 11 c0    	mov    0xc011df18,%ecx
c0102df1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102df4:	89 d0                	mov    %edx,%eax
c0102df6:	c1 e0 02             	shl    $0x2,%eax
c0102df9:	01 d0                	add    %edx,%eax
c0102dfb:	c1 e0 02             	shl    $0x2,%eax
c0102dfe:	01 c8                	add    %ecx,%eax
c0102e00:	83 c0 04             	add    $0x4,%eax
c0102e03:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0102e0a:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102e0d:	8b 45 90             	mov    -0x70(%ebp),%eax
c0102e10:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0102e13:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0102e16:	ff 45 dc             	incl   -0x24(%ebp)
c0102e19:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e1c:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0102e21:	39 c2                	cmp    %eax,%edx
c0102e23:	72 c6                	jb     c0102deb <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102e25:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0102e2b:	89 d0                	mov    %edx,%eax
c0102e2d:	c1 e0 02             	shl    $0x2,%eax
c0102e30:	01 d0                	add    %edx,%eax
c0102e32:	c1 e0 02             	shl    $0x2,%eax
c0102e35:	89 c2                	mov    %eax,%edx
c0102e37:	a1 18 df 11 c0       	mov    0xc011df18,%eax
c0102e3c:	01 d0                	add    %edx,%eax
c0102e3e:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102e41:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0102e48:	77 23                	ja     c0102e6d <page_init+0x25b>
c0102e4a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102e4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102e51:	c7 44 24 08 84 76 10 	movl   $0xc0107684,0x8(%esp)
c0102e58:	c0 
c0102e59:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0102e60:	00 
c0102e61:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0102e68:	e8 7c d5 ff ff       	call   c01003e9 <__panic>
c0102e6d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102e70:	05 00 00 00 40       	add    $0x40000000,%eax
c0102e75:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0102e78:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e7f:	e9 69 01 00 00       	jmp    c0102fed <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102e84:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e87:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e8a:	89 d0                	mov    %edx,%eax
c0102e8c:	c1 e0 02             	shl    $0x2,%eax
c0102e8f:	01 d0                	add    %edx,%eax
c0102e91:	c1 e0 02             	shl    $0x2,%eax
c0102e94:	01 c8                	add    %ecx,%eax
c0102e96:	8b 50 08             	mov    0x8(%eax),%edx
c0102e99:	8b 40 04             	mov    0x4(%eax),%eax
c0102e9c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102e9f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102ea2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ea5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ea8:	89 d0                	mov    %edx,%eax
c0102eaa:	c1 e0 02             	shl    $0x2,%eax
c0102ead:	01 d0                	add    %edx,%eax
c0102eaf:	c1 e0 02             	shl    $0x2,%eax
c0102eb2:	01 c8                	add    %ecx,%eax
c0102eb4:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102eb7:	8b 58 10             	mov    0x10(%eax),%ebx
c0102eba:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102ebd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102ec0:	01 c8                	add    %ecx,%eax
c0102ec2:	11 da                	adc    %ebx,%edx
c0102ec4:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102ec7:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0102eca:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ecd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ed0:	89 d0                	mov    %edx,%eax
c0102ed2:	c1 e0 02             	shl    $0x2,%eax
c0102ed5:	01 d0                	add    %edx,%eax
c0102ed7:	c1 e0 02             	shl    $0x2,%eax
c0102eda:	01 c8                	add    %ecx,%eax
c0102edc:	83 c0 14             	add    $0x14,%eax
c0102edf:	8b 00                	mov    (%eax),%eax
c0102ee1:	83 f8 01             	cmp    $0x1,%eax
c0102ee4:	0f 85 00 01 00 00    	jne    c0102fea <page_init+0x3d8>
            if (begin < freemem) {
c0102eea:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102eed:	ba 00 00 00 00       	mov    $0x0,%edx
c0102ef2:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0102ef5:	77 17                	ja     c0102f0e <page_init+0x2fc>
c0102ef7:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0102efa:	72 05                	jb     c0102f01 <page_init+0x2ef>
c0102efc:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0102eff:	73 0d                	jae    c0102f0e <page_init+0x2fc>
                begin = freemem;
c0102f01:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102f04:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f07:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0102f0e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f12:	72 1d                	jb     c0102f31 <page_init+0x31f>
c0102f14:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f18:	77 09                	ja     c0102f23 <page_init+0x311>
c0102f1a:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0102f21:	76 0e                	jbe    c0102f31 <page_init+0x31f>
                end = KMEMSIZE;
c0102f23:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0102f2a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0102f31:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f34:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f37:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f3a:	0f 87 aa 00 00 00    	ja     c0102fea <page_init+0x3d8>
c0102f40:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f43:	72 09                	jb     c0102f4e <page_init+0x33c>
c0102f45:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102f48:	0f 83 9c 00 00 00    	jae    c0102fea <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
c0102f4e:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0102f55:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102f58:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102f5b:	01 d0                	add    %edx,%eax
c0102f5d:	48                   	dec    %eax
c0102f5e:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0102f61:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102f64:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f69:	f7 75 b0             	divl   -0x50(%ebp)
c0102f6c:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102f6f:	29 d0                	sub    %edx,%eax
c0102f71:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f76:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f79:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0102f7c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102f7f:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0102f82:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102f85:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f8a:	89 c3                	mov    %eax,%ebx
c0102f8c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0102f92:	89 de                	mov    %ebx,%esi
c0102f94:	89 d0                	mov    %edx,%eax
c0102f96:	83 e0 00             	and    $0x0,%eax
c0102f99:	89 c7                	mov    %eax,%edi
c0102f9b:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0102f9e:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0102fa1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102fa4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102fa7:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102faa:	77 3e                	ja     c0102fea <page_init+0x3d8>
c0102fac:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102faf:	72 05                	jb     c0102fb6 <page_init+0x3a4>
c0102fb1:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102fb4:	73 34                	jae    c0102fea <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0102fb6:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102fb9:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102fbc:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0102fbf:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0102fc2:	89 c1                	mov    %eax,%ecx
c0102fc4:	89 d3                	mov    %edx,%ebx
c0102fc6:	89 c8                	mov    %ecx,%eax
c0102fc8:	89 da                	mov    %ebx,%edx
c0102fca:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102fce:	c1 ea 0c             	shr    $0xc,%edx
c0102fd1:	89 c3                	mov    %eax,%ebx
c0102fd3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102fd6:	89 04 24             	mov    %eax,(%esp)
c0102fd9:	e8 a0 f8 ff ff       	call   c010287e <pa2page>
c0102fde:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0102fe2:	89 04 24             	mov    %eax,(%esp)
c0102fe5:	e8 72 fb ff ff       	call   c0102b5c <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0102fea:	ff 45 dc             	incl   -0x24(%ebp)
c0102fed:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102ff0:	8b 00                	mov    (%eax),%eax
c0102ff2:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102ff5:	0f 8c 89 fe ff ff    	jl     c0102e84 <page_init+0x272>
                }
            }
        }
    }
}
c0102ffb:	90                   	nop
c0102ffc:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0103002:	5b                   	pop    %ebx
c0103003:	5e                   	pop    %esi
c0103004:	5f                   	pop    %edi
c0103005:	5d                   	pop    %ebp
c0103006:	c3                   	ret    

c0103007 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0103007:	55                   	push   %ebp
c0103008:	89 e5                	mov    %esp,%ebp
c010300a:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c010300d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103010:	33 45 14             	xor    0x14(%ebp),%eax
c0103013:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103018:	85 c0                	test   %eax,%eax
c010301a:	74 24                	je     c0103040 <boot_map_segment+0x39>
c010301c:	c7 44 24 0c b6 76 10 	movl   $0xc01076b6,0xc(%esp)
c0103023:	c0 
c0103024:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c010302b:	c0 
c010302c:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0103033:	00 
c0103034:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c010303b:	e8 a9 d3 ff ff       	call   c01003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0103040:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0103047:	8b 45 0c             	mov    0xc(%ebp),%eax
c010304a:	25 ff 0f 00 00       	and    $0xfff,%eax
c010304f:	89 c2                	mov    %eax,%edx
c0103051:	8b 45 10             	mov    0x10(%ebp),%eax
c0103054:	01 c2                	add    %eax,%edx
c0103056:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103059:	01 d0                	add    %edx,%eax
c010305b:	48                   	dec    %eax
c010305c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010305f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103062:	ba 00 00 00 00       	mov    $0x0,%edx
c0103067:	f7 75 f0             	divl   -0x10(%ebp)
c010306a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010306d:	29 d0                	sub    %edx,%eax
c010306f:	c1 e8 0c             	shr    $0xc,%eax
c0103072:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103075:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103078:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010307b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010307e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103083:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0103086:	8b 45 14             	mov    0x14(%ebp),%eax
c0103089:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010308c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010308f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103094:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103097:	eb 68                	jmp    c0103101 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0103099:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01030a0:	00 
c01030a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01030a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01030ab:	89 04 24             	mov    %eax,(%esp)
c01030ae:	e8 81 01 00 00       	call   c0103234 <get_pte>
c01030b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01030b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01030ba:	75 24                	jne    c01030e0 <boot_map_segment+0xd9>
c01030bc:	c7 44 24 0c e2 76 10 	movl   $0xc01076e2,0xc(%esp)
c01030c3:	c0 
c01030c4:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c01030cb:	c0 
c01030cc:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c01030d3:	00 
c01030d4:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c01030db:	e8 09 d3 ff ff       	call   c01003e9 <__panic>
        *ptep = pa | PTE_P | perm;
c01030e0:	8b 45 14             	mov    0x14(%ebp),%eax
c01030e3:	0b 45 18             	or     0x18(%ebp),%eax
c01030e6:	83 c8 01             	or     $0x1,%eax
c01030e9:	89 c2                	mov    %eax,%edx
c01030eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030ee:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01030f0:	ff 4d f4             	decl   -0xc(%ebp)
c01030f3:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01030fa:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103101:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103105:	75 92                	jne    c0103099 <boot_map_segment+0x92>
    }
}
c0103107:	90                   	nop
c0103108:	c9                   	leave  
c0103109:	c3                   	ret    

c010310a <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010310a:	55                   	push   %ebp
c010310b:	89 e5                	mov    %esp,%ebp
c010310d:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0103110:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103117:	e8 60 fa ff ff       	call   c0102b7c <alloc_pages>
c010311c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c010311f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103123:	75 1c                	jne    c0103141 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0103125:	c7 44 24 08 ef 76 10 	movl   $0xc01076ef,0x8(%esp)
c010312c:	c0 
c010312d:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0103134:	00 
c0103135:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c010313c:	e8 a8 d2 ff ff       	call   c01003e9 <__panic>
    }
    return page2kva(p);
c0103141:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103144:	89 04 24             	mov    %eax,(%esp)
c0103147:	e8 81 f7 ff ff       	call   c01028cd <page2kva>
}
c010314c:	c9                   	leave  
c010314d:	c3                   	ret    

c010314e <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010314e:	55                   	push   %ebp
c010314f:	89 e5                	mov    %esp,%ebp
c0103151:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0103154:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103159:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010315c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103163:	77 23                	ja     c0103188 <pmm_init+0x3a>
c0103165:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103168:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010316c:	c7 44 24 08 84 76 10 	movl   $0xc0107684,0x8(%esp)
c0103173:	c0 
c0103174:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c010317b:	00 
c010317c:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103183:	e8 61 d2 ff ff       	call   c01003e9 <__panic>
c0103188:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010318b:	05 00 00 00 40       	add    $0x40000000,%eax
c0103190:	a3 14 df 11 c0       	mov    %eax,0xc011df14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0103195:	e8 8e f9 ff ff       	call   c0102b28 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010319a:	e8 73 fa ff ff       	call   c0102c12 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010319f:	e8 de 03 00 00       	call   c0103582 <check_alloc_page>

    check_pgdir();
c01031a4:	e8 f8 03 00 00       	call   c01035a1 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01031a9:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01031ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01031b1:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01031b8:	77 23                	ja     c01031dd <pmm_init+0x8f>
c01031ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01031c1:	c7 44 24 08 84 76 10 	movl   $0xc0107684,0x8(%esp)
c01031c8:	c0 
c01031c9:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c01031d0:	00 
c01031d1:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c01031d8:	e8 0c d2 ff ff       	call   c01003e9 <__panic>
c01031dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031e0:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c01031e6:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01031eb:	05 ac 0f 00 00       	add    $0xfac,%eax
c01031f0:	83 ca 03             	or     $0x3,%edx
c01031f3:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01031f5:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01031fa:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0103201:	00 
c0103202:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103209:	00 
c010320a:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0103211:	38 
c0103212:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0103219:	c0 
c010321a:	89 04 24             	mov    %eax,(%esp)
c010321d:	e8 e5 fd ff ff       	call   c0103007 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0103222:	e8 18 f8 ff ff       	call   c0102a3f <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0103227:	e8 11 0a 00 00       	call   c0103c3d <check_boot_pgdir>

    print_pgdir();
c010322c:	e8 8a 0e 00 00       	call   c01040bb <print_pgdir>

}
c0103231:	90                   	nop
c0103232:	c9                   	leave  
c0103233:	c3                   	ret    

c0103234 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0103234:	55                   	push   %ebp
c0103235:	89 e5                	mov    %esp,%ebp
c0103237:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)]; //尝试获得页表
c010323a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010323d:	c1 e8 16             	shr    $0x16,%eax
c0103240:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103247:	8b 45 08             	mov    0x8(%ebp),%eax
c010324a:	01 d0                	add    %edx,%eax
c010324c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //如果获取不成功
    if (!(*pdep & PTE_P))
c010324f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103252:	8b 00                	mov    (%eax),%eax
c0103254:	83 e0 01             	and    $0x1,%eax
c0103257:	85 c0                	test   %eax,%eax
c0103259:	0f 85 af 00 00 00    	jne    c010330e <get_pte+0xda>
    {
        struct Page *page;
        //如果create参数为0，则get_pte返回NULL；如果create参数不为0，则get_pte需要申请一个新的物理页(alloc_page)
        //假如不需要分配或是分配失败
        if (!create || (page = alloc_page()) == NULL) {
c010325f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103263:	74 15                	je     c010327a <get_pte+0x46>
c0103265:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010326c:	e8 0b f9 ff ff       	call   c0102b7c <alloc_pages>
c0103271:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103274:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103278:	75 0a                	jne    c0103284 <get_pte+0x50>
            return NULL;
c010327a:	b8 00 00 00 00       	mov    $0x0,%eax
c010327f:	e9 e7 00 00 00       	jmp    c010336b <get_pte+0x137>
        }
        //再在一级页表中添加页目录项指向表示二级页表的新物理页
        set_page_ref(page, 1); //引用次数加一(page的ref属性，一种counter)
c0103284:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010328b:	00 
c010328c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010328f:	89 04 24             	mov    %eax,(%esp)
c0103292:	e8 ea f6 ff ff       	call   c0102981 <set_page_ref>
        uintptr_t pa = page2pa(page); //得到该页物理地址
c0103297:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010329a:	89 04 24             	mov    %eax,(%esp)
c010329d:	e8 c6 f5 ff ff       	call   c0102868 <page2pa>
c01032a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE); //物理地址转虚拟地址，并初始化
c01032a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01032ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01032ae:	c1 e8 0c             	shr    $0xc,%eax
c01032b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01032b4:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c01032b9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01032bc:	72 23                	jb     c01032e1 <get_pte+0xad>
c01032be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01032c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01032c5:	c7 44 24 08 e0 75 10 	movl   $0xc01075e0,0x8(%esp)
c01032cc:	c0 
c01032cd:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
c01032d4:	00 
c01032d5:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c01032dc:	e8 08 d1 ff ff       	call   c01003e9 <__panic>
c01032e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01032e4:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01032e9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01032f0:	00 
c01032f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01032f8:	00 
c01032f9:	89 04 24             	mov    %eax,(%esp)
c01032fc:	e8 7e 33 00 00       	call   c010667f <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P; //设置控制位
c0103301:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103304:	83 c8 07             	or     $0x7,%eax
c0103307:	89 c2                	mov    %eax,%edx
c0103309:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010330c:	89 10                	mov    %edx,(%eax)
    }
    //如果原来就有二级页表，或者新建立了页表，则只需返回对应项的地址即可
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c010330e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103311:	8b 00                	mov    (%eax),%eax
c0103313:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103318:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010331b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010331e:	c1 e8 0c             	shr    $0xc,%eax
c0103321:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103324:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103329:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010332c:	72 23                	jb     c0103351 <get_pte+0x11d>
c010332e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103331:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103335:	c7 44 24 08 e0 75 10 	movl   $0xc01075e0,0x8(%esp)
c010333c:	c0 
c010333d:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
c0103344:	00 
c0103345:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c010334c:	e8 98 d0 ff ff       	call   c01003e9 <__panic>
c0103351:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103354:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103359:	89 c2                	mov    %eax,%edx
c010335b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010335e:	c1 e8 0c             	shr    $0xc,%eax
c0103361:	25 ff 03 00 00       	and    $0x3ff,%eax
c0103366:	c1 e0 02             	shl    $0x2,%eax
c0103369:	01 d0                	add    %edx,%eax

}
c010336b:	c9                   	leave  
c010336c:	c3                   	ret    

c010336d <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010336d:	55                   	push   %ebp
c010336e:	89 e5                	mov    %esp,%ebp
c0103370:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103373:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010337a:	00 
c010337b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010337e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103382:	8b 45 08             	mov    0x8(%ebp),%eax
c0103385:	89 04 24             	mov    %eax,(%esp)
c0103388:	e8 a7 fe ff ff       	call   c0103234 <get_pte>
c010338d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0103390:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103394:	74 08                	je     c010339e <get_page+0x31>
        *ptep_store = ptep;
c0103396:	8b 45 10             	mov    0x10(%ebp),%eax
c0103399:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010339c:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010339e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01033a2:	74 1b                	je     c01033bf <get_page+0x52>
c01033a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033a7:	8b 00                	mov    (%eax),%eax
c01033a9:	83 e0 01             	and    $0x1,%eax
c01033ac:	85 c0                	test   %eax,%eax
c01033ae:	74 0f                	je     c01033bf <get_page+0x52>
        return pte2page(*ptep);
c01033b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033b3:	8b 00                	mov    (%eax),%eax
c01033b5:	89 04 24             	mov    %eax,(%esp)
c01033b8:	e8 64 f5 ff ff       	call   c0102921 <pte2page>
c01033bd:	eb 05                	jmp    c01033c4 <get_page+0x57>
    }
    return NULL;
c01033bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01033c4:	c9                   	leave  
c01033c5:	c3                   	ret    

c01033c6 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01033c6:	55                   	push   %ebp
c01033c7:	89 e5                	mov    %esp,%ebp
c01033c9:	83 ec 28             	sub    $0x28,%esp
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
//ex3的代码 
    if (*ptep & PTE_P) {   //PTE_P代表页存在
c01033cc:	8b 45 10             	mov    0x10(%ebp),%eax
c01033cf:	8b 00                	mov    (%eax),%eax
c01033d1:	83 e0 01             	and    $0x1,%eax
c01033d4:	85 c0                	test   %eax,%eax
c01033d6:	74 4d                	je     c0103425 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep); //这个函数用于获取二级页表对应的物理页
c01033d8:	8b 45 10             	mov    0x10(%ebp),%eax
c01033db:	8b 00                	mov    (%eax),%eax
c01033dd:	89 04 24             	mov    %eax,(%esp)
c01033e0:	e8 3c f5 ff ff       	call   c0102921 <pte2page>
c01033e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) { //page_ref_dec(page)将ref减1，判断是否只使用了一次（只被二级页表引用一次）
c01033e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033eb:	89 04 24             	mov    %eax,(%esp)
c01033ee:	e8 b3 f5 ff ff       	call   c01029a6 <page_ref_dec>
c01033f3:	85 c0                	test   %eax,%eax
c01033f5:	75 13                	jne    c010340a <page_remove_pte+0x44>
            free_page(page); //则可以释放这个页
c01033f7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033fe:	00 
c01033ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103402:	89 04 24             	mov    %eax,(%esp)
c0103405:	e8 aa f7 ff ff       	call   c0102bb4 <free_pages>
        }
        *ptep = 0;//如果还有更多的页表应用了它，不能释放，要取消二级映射，把二级页表ixang清零
c010340a:	8b 45 10             	mov    0x10(%ebp),%eax
c010340d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);//更新TLB，使TLB中的项无效（除非这个页表正在被使用）
c0103413:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103416:	89 44 24 04          	mov    %eax,0x4(%esp)
c010341a:	8b 45 08             	mov    0x8(%ebp),%eax
c010341d:	89 04 24             	mov    %eax,(%esp)
c0103420:	e8 01 01 00 00       	call   c0103526 <tlb_invalidate>
    }
}
c0103425:	90                   	nop
c0103426:	c9                   	leave  
c0103427:	c3                   	ret    

c0103428 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0103428:	55                   	push   %ebp
c0103429:	89 e5                	mov    %esp,%ebp
c010342b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010342e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103435:	00 
c0103436:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103439:	89 44 24 04          	mov    %eax,0x4(%esp)
c010343d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103440:	89 04 24             	mov    %eax,(%esp)
c0103443:	e8 ec fd ff ff       	call   c0103234 <get_pte>
c0103448:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c010344b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010344f:	74 19                	je     c010346a <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0103451:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103454:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103458:	8b 45 0c             	mov    0xc(%ebp),%eax
c010345b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010345f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103462:	89 04 24             	mov    %eax,(%esp)
c0103465:	e8 5c ff ff ff       	call   c01033c6 <page_remove_pte>
    }
}
c010346a:	90                   	nop
c010346b:	c9                   	leave  
c010346c:	c3                   	ret    

c010346d <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c010346d:	55                   	push   %ebp
c010346e:	89 e5                	mov    %esp,%ebp
c0103470:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0103473:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010347a:	00 
c010347b:	8b 45 10             	mov    0x10(%ebp),%eax
c010347e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103482:	8b 45 08             	mov    0x8(%ebp),%eax
c0103485:	89 04 24             	mov    %eax,(%esp)
c0103488:	e8 a7 fd ff ff       	call   c0103234 <get_pte>
c010348d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0103490:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103494:	75 0a                	jne    c01034a0 <page_insert+0x33>
        return -E_NO_MEM;
c0103496:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010349b:	e9 84 00 00 00       	jmp    c0103524 <page_insert+0xb7>
    }
    page_ref_inc(page);
c01034a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034a3:	89 04 24             	mov    %eax,(%esp)
c01034a6:	e8 e4 f4 ff ff       	call   c010298f <page_ref_inc>
    if (*ptep & PTE_P) {
c01034ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034ae:	8b 00                	mov    (%eax),%eax
c01034b0:	83 e0 01             	and    $0x1,%eax
c01034b3:	85 c0                	test   %eax,%eax
c01034b5:	74 3e                	je     c01034f5 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01034b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034ba:	8b 00                	mov    (%eax),%eax
c01034bc:	89 04 24             	mov    %eax,(%esp)
c01034bf:	e8 5d f4 ff ff       	call   c0102921 <pte2page>
c01034c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01034c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034ca:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01034cd:	75 0d                	jne    c01034dc <page_insert+0x6f>
            page_ref_dec(page);
c01034cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034d2:	89 04 24             	mov    %eax,(%esp)
c01034d5:	e8 cc f4 ff ff       	call   c01029a6 <page_ref_dec>
c01034da:	eb 19                	jmp    c01034f5 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01034dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034df:	89 44 24 08          	mov    %eax,0x8(%esp)
c01034e3:	8b 45 10             	mov    0x10(%ebp),%eax
c01034e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01034ed:	89 04 24             	mov    %eax,(%esp)
c01034f0:	e8 d1 fe ff ff       	call   c01033c6 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01034f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034f8:	89 04 24             	mov    %eax,(%esp)
c01034fb:	e8 68 f3 ff ff       	call   c0102868 <page2pa>
c0103500:	0b 45 14             	or     0x14(%ebp),%eax
c0103503:	83 c8 01             	or     $0x1,%eax
c0103506:	89 c2                	mov    %eax,%edx
c0103508:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010350b:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010350d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103510:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103514:	8b 45 08             	mov    0x8(%ebp),%eax
c0103517:	89 04 24             	mov    %eax,(%esp)
c010351a:	e8 07 00 00 00       	call   c0103526 <tlb_invalidate>
    return 0;
c010351f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103524:	c9                   	leave  
c0103525:	c3                   	ret    

c0103526 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0103526:	55                   	push   %ebp
c0103527:	89 e5                	mov    %esp,%ebp
c0103529:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010352c:	0f 20 d8             	mov    %cr3,%eax
c010352f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0103532:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0103535:	8b 45 08             	mov    0x8(%ebp),%eax
c0103538:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010353b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103542:	77 23                	ja     c0103567 <tlb_invalidate+0x41>
c0103544:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103547:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010354b:	c7 44 24 08 84 76 10 	movl   $0xc0107684,0x8(%esp)
c0103552:	c0 
c0103553:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c010355a:	00 
c010355b:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103562:	e8 82 ce ff ff       	call   c01003e9 <__panic>
c0103567:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010356a:	05 00 00 00 40       	add    $0x40000000,%eax
c010356f:	39 d0                	cmp    %edx,%eax
c0103571:	75 0c                	jne    c010357f <tlb_invalidate+0x59>
        invlpg((void *)la);
c0103573:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103576:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103579:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010357c:	0f 01 38             	invlpg (%eax)
    }
}
c010357f:	90                   	nop
c0103580:	c9                   	leave  
c0103581:	c3                   	ret    

c0103582 <check_alloc_page>:

static void
check_alloc_page(void) {
c0103582:	55                   	push   %ebp
c0103583:	89 e5                	mov    %esp,%ebp
c0103585:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0103588:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c010358d:	8b 40 18             	mov    0x18(%eax),%eax
c0103590:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0103592:	c7 04 24 08 77 10 c0 	movl   $0xc0107708,(%esp)
c0103599:	e8 f4 cc ff ff       	call   c0100292 <cprintf>
}
c010359e:	90                   	nop
c010359f:	c9                   	leave  
c01035a0:	c3                   	ret    

c01035a1 <check_pgdir>:

static void
check_pgdir(void) {
c01035a1:	55                   	push   %ebp
c01035a2:	89 e5                	mov    %esp,%ebp
c01035a4:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01035a7:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c01035ac:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01035b1:	76 24                	jbe    c01035d7 <check_pgdir+0x36>
c01035b3:	c7 44 24 0c 27 77 10 	movl   $0xc0107727,0xc(%esp)
c01035ba:	c0 
c01035bb:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c01035c2:	c0 
c01035c3:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c01035ca:	00 
c01035cb:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c01035d2:	e8 12 ce ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01035d7:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01035dc:	85 c0                	test   %eax,%eax
c01035de:	74 0e                	je     c01035ee <check_pgdir+0x4d>
c01035e0:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01035e5:	25 ff 0f 00 00       	and    $0xfff,%eax
c01035ea:	85 c0                	test   %eax,%eax
c01035ec:	74 24                	je     c0103612 <check_pgdir+0x71>
c01035ee:	c7 44 24 0c 44 77 10 	movl   $0xc0107744,0xc(%esp)
c01035f5:	c0 
c01035f6:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c01035fd:	c0 
c01035fe:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c0103605:	00 
c0103606:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c010360d:	e8 d7 cd ff ff       	call   c01003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0103612:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103617:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010361e:	00 
c010361f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103626:	00 
c0103627:	89 04 24             	mov    %eax,(%esp)
c010362a:	e8 3e fd ff ff       	call   c010336d <get_page>
c010362f:	85 c0                	test   %eax,%eax
c0103631:	74 24                	je     c0103657 <check_pgdir+0xb6>
c0103633:	c7 44 24 0c 7c 77 10 	movl   $0xc010777c,0xc(%esp)
c010363a:	c0 
c010363b:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103642:	c0 
c0103643:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c010364a:	00 
c010364b:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103652:	e8 92 cd ff ff       	call   c01003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0103657:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010365e:	e8 19 f5 ff ff       	call   c0102b7c <alloc_pages>
c0103663:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0103666:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010366b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103672:	00 
c0103673:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010367a:	00 
c010367b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010367e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103682:	89 04 24             	mov    %eax,(%esp)
c0103685:	e8 e3 fd ff ff       	call   c010346d <page_insert>
c010368a:	85 c0                	test   %eax,%eax
c010368c:	74 24                	je     c01036b2 <check_pgdir+0x111>
c010368e:	c7 44 24 0c a4 77 10 	movl   $0xc01077a4,0xc(%esp)
c0103695:	c0 
c0103696:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c010369d:	c0 
c010369e:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c01036a5:	00 
c01036a6:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c01036ad:	e8 37 cd ff ff       	call   c01003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01036b2:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01036b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01036be:	00 
c01036bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01036c6:	00 
c01036c7:	89 04 24             	mov    %eax,(%esp)
c01036ca:	e8 65 fb ff ff       	call   c0103234 <get_pte>
c01036cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01036d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01036d6:	75 24                	jne    c01036fc <check_pgdir+0x15b>
c01036d8:	c7 44 24 0c d0 77 10 	movl   $0xc01077d0,0xc(%esp)
c01036df:	c0 
c01036e0:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c01036e7:	c0 
c01036e8:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c01036ef:	00 
c01036f0:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c01036f7:	e8 ed cc ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c01036fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036ff:	8b 00                	mov    (%eax),%eax
c0103701:	89 04 24             	mov    %eax,(%esp)
c0103704:	e8 18 f2 ff ff       	call   c0102921 <pte2page>
c0103709:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010370c:	74 24                	je     c0103732 <check_pgdir+0x191>
c010370e:	c7 44 24 0c fd 77 10 	movl   $0xc01077fd,0xc(%esp)
c0103715:	c0 
c0103716:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c010371d:	c0 
c010371e:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0103725:	00 
c0103726:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c010372d:	e8 b7 cc ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 1);
c0103732:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103735:	89 04 24             	mov    %eax,(%esp)
c0103738:	e8 3a f2 ff ff       	call   c0102977 <page_ref>
c010373d:	83 f8 01             	cmp    $0x1,%eax
c0103740:	74 24                	je     c0103766 <check_pgdir+0x1c5>
c0103742:	c7 44 24 0c 13 78 10 	movl   $0xc0107813,0xc(%esp)
c0103749:	c0 
c010374a:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103751:	c0 
c0103752:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0103759:	00 
c010375a:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103761:	e8 83 cc ff ff       	call   c01003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0103766:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010376b:	8b 00                	mov    (%eax),%eax
c010376d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103772:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103775:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103778:	c1 e8 0c             	shr    $0xc,%eax
c010377b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010377e:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103783:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103786:	72 23                	jb     c01037ab <check_pgdir+0x20a>
c0103788:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010378b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010378f:	c7 44 24 08 e0 75 10 	movl   $0xc01075e0,0x8(%esp)
c0103796:	c0 
c0103797:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c010379e:	00 
c010379f:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c01037a6:	e8 3e cc ff ff       	call   c01003e9 <__panic>
c01037ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037ae:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01037b3:	83 c0 04             	add    $0x4,%eax
c01037b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01037b9:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01037be:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01037c5:	00 
c01037c6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01037cd:	00 
c01037ce:	89 04 24             	mov    %eax,(%esp)
c01037d1:	e8 5e fa ff ff       	call   c0103234 <get_pte>
c01037d6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01037d9:	74 24                	je     c01037ff <check_pgdir+0x25e>
c01037db:	c7 44 24 0c 28 78 10 	movl   $0xc0107828,0xc(%esp)
c01037e2:	c0 
c01037e3:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c01037ea:	c0 
c01037eb:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c01037f2:	00 
c01037f3:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c01037fa:	e8 ea cb ff ff       	call   c01003e9 <__panic>

    p2 = alloc_page();
c01037ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103806:	e8 71 f3 ff ff       	call   c0102b7c <alloc_pages>
c010380b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010380e:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103813:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c010381a:	00 
c010381b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103822:	00 
c0103823:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103826:	89 54 24 04          	mov    %edx,0x4(%esp)
c010382a:	89 04 24             	mov    %eax,(%esp)
c010382d:	e8 3b fc ff ff       	call   c010346d <page_insert>
c0103832:	85 c0                	test   %eax,%eax
c0103834:	74 24                	je     c010385a <check_pgdir+0x2b9>
c0103836:	c7 44 24 0c 50 78 10 	movl   $0xc0107850,0xc(%esp)
c010383d:	c0 
c010383e:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103845:	c0 
c0103846:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c010384d:	00 
c010384e:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103855:	e8 8f cb ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010385a:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010385f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103866:	00 
c0103867:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010386e:	00 
c010386f:	89 04 24             	mov    %eax,(%esp)
c0103872:	e8 bd f9 ff ff       	call   c0103234 <get_pte>
c0103877:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010387a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010387e:	75 24                	jne    c01038a4 <check_pgdir+0x303>
c0103880:	c7 44 24 0c 88 78 10 	movl   $0xc0107888,0xc(%esp)
c0103887:	c0 
c0103888:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c010388f:	c0 
c0103890:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0103897:	00 
c0103898:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c010389f:	e8 45 cb ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_U);
c01038a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038a7:	8b 00                	mov    (%eax),%eax
c01038a9:	83 e0 04             	and    $0x4,%eax
c01038ac:	85 c0                	test   %eax,%eax
c01038ae:	75 24                	jne    c01038d4 <check_pgdir+0x333>
c01038b0:	c7 44 24 0c b8 78 10 	movl   $0xc01078b8,0xc(%esp)
c01038b7:	c0 
c01038b8:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c01038bf:	c0 
c01038c0:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c01038c7:	00 
c01038c8:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c01038cf:	e8 15 cb ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_W);
c01038d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038d7:	8b 00                	mov    (%eax),%eax
c01038d9:	83 e0 02             	and    $0x2,%eax
c01038dc:	85 c0                	test   %eax,%eax
c01038de:	75 24                	jne    c0103904 <check_pgdir+0x363>
c01038e0:	c7 44 24 0c c6 78 10 	movl   $0xc01078c6,0xc(%esp)
c01038e7:	c0 
c01038e8:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c01038ef:	c0 
c01038f0:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c01038f7:	00 
c01038f8:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c01038ff:	e8 e5 ca ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103904:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103909:	8b 00                	mov    (%eax),%eax
c010390b:	83 e0 04             	and    $0x4,%eax
c010390e:	85 c0                	test   %eax,%eax
c0103910:	75 24                	jne    c0103936 <check_pgdir+0x395>
c0103912:	c7 44 24 0c d4 78 10 	movl   $0xc01078d4,0xc(%esp)
c0103919:	c0 
c010391a:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103921:	c0 
c0103922:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0103929:	00 
c010392a:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103931:	e8 b3 ca ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 1);
c0103936:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103939:	89 04 24             	mov    %eax,(%esp)
c010393c:	e8 36 f0 ff ff       	call   c0102977 <page_ref>
c0103941:	83 f8 01             	cmp    $0x1,%eax
c0103944:	74 24                	je     c010396a <check_pgdir+0x3c9>
c0103946:	c7 44 24 0c ea 78 10 	movl   $0xc01078ea,0xc(%esp)
c010394d:	c0 
c010394e:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103955:	c0 
c0103956:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c010395d:	00 
c010395e:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103965:	e8 7f ca ff ff       	call   c01003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c010396a:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010396f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103976:	00 
c0103977:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010397e:	00 
c010397f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103982:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103986:	89 04 24             	mov    %eax,(%esp)
c0103989:	e8 df fa ff ff       	call   c010346d <page_insert>
c010398e:	85 c0                	test   %eax,%eax
c0103990:	74 24                	je     c01039b6 <check_pgdir+0x415>
c0103992:	c7 44 24 0c fc 78 10 	movl   $0xc01078fc,0xc(%esp)
c0103999:	c0 
c010399a:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c01039a1:	c0 
c01039a2:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c01039a9:	00 
c01039aa:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c01039b1:	e8 33 ca ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 2);
c01039b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039b9:	89 04 24             	mov    %eax,(%esp)
c01039bc:	e8 b6 ef ff ff       	call   c0102977 <page_ref>
c01039c1:	83 f8 02             	cmp    $0x2,%eax
c01039c4:	74 24                	je     c01039ea <check_pgdir+0x449>
c01039c6:	c7 44 24 0c 28 79 10 	movl   $0xc0107928,0xc(%esp)
c01039cd:	c0 
c01039ce:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c01039d5:	c0 
c01039d6:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c01039dd:	00 
c01039de:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c01039e5:	e8 ff c9 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c01039ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039ed:	89 04 24             	mov    %eax,(%esp)
c01039f0:	e8 82 ef ff ff       	call   c0102977 <page_ref>
c01039f5:	85 c0                	test   %eax,%eax
c01039f7:	74 24                	je     c0103a1d <check_pgdir+0x47c>
c01039f9:	c7 44 24 0c 3a 79 10 	movl   $0xc010793a,0xc(%esp)
c0103a00:	c0 
c0103a01:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103a08:	c0 
c0103a09:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c0103a10:	00 
c0103a11:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103a18:	e8 cc c9 ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103a1d:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103a22:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103a29:	00 
c0103a2a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103a31:	00 
c0103a32:	89 04 24             	mov    %eax,(%esp)
c0103a35:	e8 fa f7 ff ff       	call   c0103234 <get_pte>
c0103a3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a3d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a41:	75 24                	jne    c0103a67 <check_pgdir+0x4c6>
c0103a43:	c7 44 24 0c 88 78 10 	movl   $0xc0107888,0xc(%esp)
c0103a4a:	c0 
c0103a4b:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103a52:	c0 
c0103a53:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0103a5a:	00 
c0103a5b:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103a62:	e8 82 c9 ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a6a:	8b 00                	mov    (%eax),%eax
c0103a6c:	89 04 24             	mov    %eax,(%esp)
c0103a6f:	e8 ad ee ff ff       	call   c0102921 <pte2page>
c0103a74:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103a77:	74 24                	je     c0103a9d <check_pgdir+0x4fc>
c0103a79:	c7 44 24 0c fd 77 10 	movl   $0xc01077fd,0xc(%esp)
c0103a80:	c0 
c0103a81:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103a88:	c0 
c0103a89:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c0103a90:	00 
c0103a91:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103a98:	e8 4c c9 ff ff       	call   c01003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103aa0:	8b 00                	mov    (%eax),%eax
c0103aa2:	83 e0 04             	and    $0x4,%eax
c0103aa5:	85 c0                	test   %eax,%eax
c0103aa7:	74 24                	je     c0103acd <check_pgdir+0x52c>
c0103aa9:	c7 44 24 0c 4c 79 10 	movl   $0xc010794c,0xc(%esp)
c0103ab0:	c0 
c0103ab1:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103ab8:	c0 
c0103ab9:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0103ac0:	00 
c0103ac1:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103ac8:	e8 1c c9 ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103acd:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103ad2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103ad9:	00 
c0103ada:	89 04 24             	mov    %eax,(%esp)
c0103add:	e8 46 f9 ff ff       	call   c0103428 <page_remove>
    assert(page_ref(p1) == 1);
c0103ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ae5:	89 04 24             	mov    %eax,(%esp)
c0103ae8:	e8 8a ee ff ff       	call   c0102977 <page_ref>
c0103aed:	83 f8 01             	cmp    $0x1,%eax
c0103af0:	74 24                	je     c0103b16 <check_pgdir+0x575>
c0103af2:	c7 44 24 0c 13 78 10 	movl   $0xc0107813,0xc(%esp)
c0103af9:	c0 
c0103afa:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103b01:	c0 
c0103b02:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0103b09:	00 
c0103b0a:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103b11:	e8 d3 c8 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103b16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b19:	89 04 24             	mov    %eax,(%esp)
c0103b1c:	e8 56 ee ff ff       	call   c0102977 <page_ref>
c0103b21:	85 c0                	test   %eax,%eax
c0103b23:	74 24                	je     c0103b49 <check_pgdir+0x5a8>
c0103b25:	c7 44 24 0c 3a 79 10 	movl   $0xc010793a,0xc(%esp)
c0103b2c:	c0 
c0103b2d:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103b34:	c0 
c0103b35:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0103b3c:	00 
c0103b3d:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103b44:	e8 a0 c8 ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103b49:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103b4e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103b55:	00 
c0103b56:	89 04 24             	mov    %eax,(%esp)
c0103b59:	e8 ca f8 ff ff       	call   c0103428 <page_remove>
    assert(page_ref(p1) == 0);
c0103b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b61:	89 04 24             	mov    %eax,(%esp)
c0103b64:	e8 0e ee ff ff       	call   c0102977 <page_ref>
c0103b69:	85 c0                	test   %eax,%eax
c0103b6b:	74 24                	je     c0103b91 <check_pgdir+0x5f0>
c0103b6d:	c7 44 24 0c 61 79 10 	movl   $0xc0107961,0xc(%esp)
c0103b74:	c0 
c0103b75:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103b7c:	c0 
c0103b7d:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0103b84:	00 
c0103b85:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103b8c:	e8 58 c8 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103b91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b94:	89 04 24             	mov    %eax,(%esp)
c0103b97:	e8 db ed ff ff       	call   c0102977 <page_ref>
c0103b9c:	85 c0                	test   %eax,%eax
c0103b9e:	74 24                	je     c0103bc4 <check_pgdir+0x623>
c0103ba0:	c7 44 24 0c 3a 79 10 	movl   $0xc010793a,0xc(%esp)
c0103ba7:	c0 
c0103ba8:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103baf:	c0 
c0103bb0:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0103bb7:	00 
c0103bb8:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103bbf:	e8 25 c8 ff ff       	call   c01003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103bc4:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103bc9:	8b 00                	mov    (%eax),%eax
c0103bcb:	89 04 24             	mov    %eax,(%esp)
c0103bce:	e8 8c ed ff ff       	call   c010295f <pde2page>
c0103bd3:	89 04 24             	mov    %eax,(%esp)
c0103bd6:	e8 9c ed ff ff       	call   c0102977 <page_ref>
c0103bdb:	83 f8 01             	cmp    $0x1,%eax
c0103bde:	74 24                	je     c0103c04 <check_pgdir+0x663>
c0103be0:	c7 44 24 0c 74 79 10 	movl   $0xc0107974,0xc(%esp)
c0103be7:	c0 
c0103be8:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103bef:	c0 
c0103bf0:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0103bf7:	00 
c0103bf8:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103bff:	e8 e5 c7 ff ff       	call   c01003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103c04:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103c09:	8b 00                	mov    (%eax),%eax
c0103c0b:	89 04 24             	mov    %eax,(%esp)
c0103c0e:	e8 4c ed ff ff       	call   c010295f <pde2page>
c0103c13:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c1a:	00 
c0103c1b:	89 04 24             	mov    %eax,(%esp)
c0103c1e:	e8 91 ef ff ff       	call   c0102bb4 <free_pages>
    boot_pgdir[0] = 0;
c0103c23:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103c28:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103c2e:	c7 04 24 9b 79 10 c0 	movl   $0xc010799b,(%esp)
c0103c35:	e8 58 c6 ff ff       	call   c0100292 <cprintf>
}
c0103c3a:	90                   	nop
c0103c3b:	c9                   	leave  
c0103c3c:	c3                   	ret    

c0103c3d <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103c3d:	55                   	push   %ebp
c0103c3e:	89 e5                	mov    %esp,%ebp
c0103c40:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103c43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103c4a:	e9 ca 00 00 00       	jmp    c0103d19 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103c55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c58:	c1 e8 0c             	shr    $0xc,%eax
c0103c5b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103c5e:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103c63:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103c66:	72 23                	jb     c0103c8b <check_boot_pgdir+0x4e>
c0103c68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103c6f:	c7 44 24 08 e0 75 10 	movl   $0xc01075e0,0x8(%esp)
c0103c76:	c0 
c0103c77:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0103c7e:	00 
c0103c7f:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103c86:	e8 5e c7 ff ff       	call   c01003e9 <__panic>
c0103c8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c8e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103c93:	89 c2                	mov    %eax,%edx
c0103c95:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103c9a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103ca1:	00 
c0103ca2:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103ca6:	89 04 24             	mov    %eax,(%esp)
c0103ca9:	e8 86 f5 ff ff       	call   c0103234 <get_pte>
c0103cae:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103cb1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103cb5:	75 24                	jne    c0103cdb <check_boot_pgdir+0x9e>
c0103cb7:	c7 44 24 0c b8 79 10 	movl   $0xc01079b8,0xc(%esp)
c0103cbe:	c0 
c0103cbf:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103cc6:	c0 
c0103cc7:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0103cce:	00 
c0103ccf:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103cd6:	e8 0e c7 ff ff       	call   c01003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103cdb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cde:	8b 00                	mov    (%eax),%eax
c0103ce0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103ce5:	89 c2                	mov    %eax,%edx
c0103ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cea:	39 c2                	cmp    %eax,%edx
c0103cec:	74 24                	je     c0103d12 <check_boot_pgdir+0xd5>
c0103cee:	c7 44 24 0c f5 79 10 	movl   $0xc01079f5,0xc(%esp)
c0103cf5:	c0 
c0103cf6:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103cfd:	c0 
c0103cfe:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0103d05:	00 
c0103d06:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103d0d:	e8 d7 c6 ff ff       	call   c01003e9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0103d12:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103d19:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103d1c:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103d21:	39 c2                	cmp    %eax,%edx
c0103d23:	0f 82 26 ff ff ff    	jb     c0103c4f <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103d29:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103d2e:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103d33:	8b 00                	mov    (%eax),%eax
c0103d35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d3a:	89 c2                	mov    %eax,%edx
c0103d3c:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103d41:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103d44:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103d4b:	77 23                	ja     c0103d70 <check_boot_pgdir+0x133>
c0103d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d50:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103d54:	c7 44 24 08 84 76 10 	movl   $0xc0107684,0x8(%esp)
c0103d5b:	c0 
c0103d5c:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0103d63:	00 
c0103d64:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103d6b:	e8 79 c6 ff ff       	call   c01003e9 <__panic>
c0103d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d73:	05 00 00 00 40       	add    $0x40000000,%eax
c0103d78:	39 d0                	cmp    %edx,%eax
c0103d7a:	74 24                	je     c0103da0 <check_boot_pgdir+0x163>
c0103d7c:	c7 44 24 0c 0c 7a 10 	movl   $0xc0107a0c,0xc(%esp)
c0103d83:	c0 
c0103d84:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103d8b:	c0 
c0103d8c:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0103d93:	00 
c0103d94:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103d9b:	e8 49 c6 ff ff       	call   c01003e9 <__panic>

    assert(boot_pgdir[0] == 0);
c0103da0:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103da5:	8b 00                	mov    (%eax),%eax
c0103da7:	85 c0                	test   %eax,%eax
c0103da9:	74 24                	je     c0103dcf <check_boot_pgdir+0x192>
c0103dab:	c7 44 24 0c 40 7a 10 	movl   $0xc0107a40,0xc(%esp)
c0103db2:	c0 
c0103db3:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103dba:	c0 
c0103dbb:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0103dc2:	00 
c0103dc3:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103dca:	e8 1a c6 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    p = alloc_page();
c0103dcf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103dd6:	e8 a1 ed ff ff       	call   c0102b7c <alloc_pages>
c0103ddb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103dde:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103de3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103dea:	00 
c0103deb:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103df2:	00 
c0103df3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103df6:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103dfa:	89 04 24             	mov    %eax,(%esp)
c0103dfd:	e8 6b f6 ff ff       	call   c010346d <page_insert>
c0103e02:	85 c0                	test   %eax,%eax
c0103e04:	74 24                	je     c0103e2a <check_boot_pgdir+0x1ed>
c0103e06:	c7 44 24 0c 54 7a 10 	movl   $0xc0107a54,0xc(%esp)
c0103e0d:	c0 
c0103e0e:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103e15:	c0 
c0103e16:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c0103e1d:	00 
c0103e1e:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103e25:	e8 bf c5 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 1);
c0103e2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e2d:	89 04 24             	mov    %eax,(%esp)
c0103e30:	e8 42 eb ff ff       	call   c0102977 <page_ref>
c0103e35:	83 f8 01             	cmp    $0x1,%eax
c0103e38:	74 24                	je     c0103e5e <check_boot_pgdir+0x221>
c0103e3a:	c7 44 24 0c 82 7a 10 	movl   $0xc0107a82,0xc(%esp)
c0103e41:	c0 
c0103e42:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103e49:	c0 
c0103e4a:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0103e51:	00 
c0103e52:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103e59:	e8 8b c5 ff ff       	call   c01003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0103e5e:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103e63:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103e6a:	00 
c0103e6b:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0103e72:	00 
c0103e73:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103e76:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e7a:	89 04 24             	mov    %eax,(%esp)
c0103e7d:	e8 eb f5 ff ff       	call   c010346d <page_insert>
c0103e82:	85 c0                	test   %eax,%eax
c0103e84:	74 24                	je     c0103eaa <check_boot_pgdir+0x26d>
c0103e86:	c7 44 24 0c 94 7a 10 	movl   $0xc0107a94,0xc(%esp)
c0103e8d:	c0 
c0103e8e:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103e95:	c0 
c0103e96:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c0103e9d:	00 
c0103e9e:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103ea5:	e8 3f c5 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 2);
c0103eaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ead:	89 04 24             	mov    %eax,(%esp)
c0103eb0:	e8 c2 ea ff ff       	call   c0102977 <page_ref>
c0103eb5:	83 f8 02             	cmp    $0x2,%eax
c0103eb8:	74 24                	je     c0103ede <check_boot_pgdir+0x2a1>
c0103eba:	c7 44 24 0c cb 7a 10 	movl   $0xc0107acb,0xc(%esp)
c0103ec1:	c0 
c0103ec2:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103ec9:	c0 
c0103eca:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c0103ed1:	00 
c0103ed2:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103ed9:	e8 0b c5 ff ff       	call   c01003e9 <__panic>

    const char *str = "ucore: Hello world!!";
c0103ede:	c7 45 e8 dc 7a 10 c0 	movl   $0xc0107adc,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0103ee5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ee8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103eec:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103ef3:	e8 bd 24 00 00       	call   c01063b5 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0103ef8:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0103eff:	00 
c0103f00:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f07:	e8 20 25 00 00       	call   c010642c <strcmp>
c0103f0c:	85 c0                	test   %eax,%eax
c0103f0e:	74 24                	je     c0103f34 <check_boot_pgdir+0x2f7>
c0103f10:	c7 44 24 0c f4 7a 10 	movl   $0xc0107af4,0xc(%esp)
c0103f17:	c0 
c0103f18:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103f1f:	c0 
c0103f20:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
c0103f27:	00 
c0103f28:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103f2f:	e8 b5 c4 ff ff       	call   c01003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0103f34:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f37:	89 04 24             	mov    %eax,(%esp)
c0103f3a:	e8 8e e9 ff ff       	call   c01028cd <page2kva>
c0103f3f:	05 00 01 00 00       	add    $0x100,%eax
c0103f44:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0103f47:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f4e:	e8 0c 24 00 00       	call   c010635f <strlen>
c0103f53:	85 c0                	test   %eax,%eax
c0103f55:	74 24                	je     c0103f7b <check_boot_pgdir+0x33e>
c0103f57:	c7 44 24 0c 2c 7b 10 	movl   $0xc0107b2c,0xc(%esp)
c0103f5e:	c0 
c0103f5f:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0103f66:	c0 
c0103f67:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
c0103f6e:	00 
c0103f6f:	c7 04 24 a8 76 10 c0 	movl   $0xc01076a8,(%esp)
c0103f76:	e8 6e c4 ff ff       	call   c01003e9 <__panic>

    free_page(p);
c0103f7b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f82:	00 
c0103f83:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f86:	89 04 24             	mov    %eax,(%esp)
c0103f89:	e8 26 ec ff ff       	call   c0102bb4 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0103f8e:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103f93:	8b 00                	mov    (%eax),%eax
c0103f95:	89 04 24             	mov    %eax,(%esp)
c0103f98:	e8 c2 e9 ff ff       	call   c010295f <pde2page>
c0103f9d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103fa4:	00 
c0103fa5:	89 04 24             	mov    %eax,(%esp)
c0103fa8:	e8 07 ec ff ff       	call   c0102bb4 <free_pages>
    boot_pgdir[0] = 0;
c0103fad:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103fb2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0103fb8:	c7 04 24 50 7b 10 c0 	movl   $0xc0107b50,(%esp)
c0103fbf:	e8 ce c2 ff ff       	call   c0100292 <cprintf>
}
c0103fc4:	90                   	nop
c0103fc5:	c9                   	leave  
c0103fc6:	c3                   	ret    

c0103fc7 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0103fc7:	55                   	push   %ebp
c0103fc8:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0103fca:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fcd:	83 e0 04             	and    $0x4,%eax
c0103fd0:	85 c0                	test   %eax,%eax
c0103fd2:	74 04                	je     c0103fd8 <perm2str+0x11>
c0103fd4:	b0 75                	mov    $0x75,%al
c0103fd6:	eb 02                	jmp    c0103fda <perm2str+0x13>
c0103fd8:	b0 2d                	mov    $0x2d,%al
c0103fda:	a2 08 df 11 c0       	mov    %al,0xc011df08
    str[1] = 'r';
c0103fdf:	c6 05 09 df 11 c0 72 	movb   $0x72,0xc011df09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0103fe6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fe9:	83 e0 02             	and    $0x2,%eax
c0103fec:	85 c0                	test   %eax,%eax
c0103fee:	74 04                	je     c0103ff4 <perm2str+0x2d>
c0103ff0:	b0 77                	mov    $0x77,%al
c0103ff2:	eb 02                	jmp    c0103ff6 <perm2str+0x2f>
c0103ff4:	b0 2d                	mov    $0x2d,%al
c0103ff6:	a2 0a df 11 c0       	mov    %al,0xc011df0a
    str[3] = '\0';
c0103ffb:	c6 05 0b df 11 c0 00 	movb   $0x0,0xc011df0b
    return str;
c0104002:	b8 08 df 11 c0       	mov    $0xc011df08,%eax
}
c0104007:	5d                   	pop    %ebp
c0104008:	c3                   	ret    

c0104009 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0104009:	55                   	push   %ebp
c010400a:	89 e5                	mov    %esp,%ebp
c010400c:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c010400f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104012:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104015:	72 0d                	jb     c0104024 <get_pgtable_items+0x1b>
        return 0;
c0104017:	b8 00 00 00 00       	mov    $0x0,%eax
c010401c:	e9 98 00 00 00       	jmp    c01040b9 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0104021:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0104024:	8b 45 10             	mov    0x10(%ebp),%eax
c0104027:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010402a:	73 18                	jae    c0104044 <get_pgtable_items+0x3b>
c010402c:	8b 45 10             	mov    0x10(%ebp),%eax
c010402f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104036:	8b 45 14             	mov    0x14(%ebp),%eax
c0104039:	01 d0                	add    %edx,%eax
c010403b:	8b 00                	mov    (%eax),%eax
c010403d:	83 e0 01             	and    $0x1,%eax
c0104040:	85 c0                	test   %eax,%eax
c0104042:	74 dd                	je     c0104021 <get_pgtable_items+0x18>
    }
    if (start < right) {
c0104044:	8b 45 10             	mov    0x10(%ebp),%eax
c0104047:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010404a:	73 68                	jae    c01040b4 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c010404c:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0104050:	74 08                	je     c010405a <get_pgtable_items+0x51>
            *left_store = start;
c0104052:	8b 45 18             	mov    0x18(%ebp),%eax
c0104055:	8b 55 10             	mov    0x10(%ebp),%edx
c0104058:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c010405a:	8b 45 10             	mov    0x10(%ebp),%eax
c010405d:	8d 50 01             	lea    0x1(%eax),%edx
c0104060:	89 55 10             	mov    %edx,0x10(%ebp)
c0104063:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010406a:	8b 45 14             	mov    0x14(%ebp),%eax
c010406d:	01 d0                	add    %edx,%eax
c010406f:	8b 00                	mov    (%eax),%eax
c0104071:	83 e0 07             	and    $0x7,%eax
c0104074:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104077:	eb 03                	jmp    c010407c <get_pgtable_items+0x73>
            start ++;
c0104079:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010407c:	8b 45 10             	mov    0x10(%ebp),%eax
c010407f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104082:	73 1d                	jae    c01040a1 <get_pgtable_items+0x98>
c0104084:	8b 45 10             	mov    0x10(%ebp),%eax
c0104087:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010408e:	8b 45 14             	mov    0x14(%ebp),%eax
c0104091:	01 d0                	add    %edx,%eax
c0104093:	8b 00                	mov    (%eax),%eax
c0104095:	83 e0 07             	and    $0x7,%eax
c0104098:	89 c2                	mov    %eax,%edx
c010409a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010409d:	39 c2                	cmp    %eax,%edx
c010409f:	74 d8                	je     c0104079 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c01040a1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01040a5:	74 08                	je     c01040af <get_pgtable_items+0xa6>
            *right_store = start;
c01040a7:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01040aa:	8b 55 10             	mov    0x10(%ebp),%edx
c01040ad:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01040af:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01040b2:	eb 05                	jmp    c01040b9 <get_pgtable_items+0xb0>
    }
    return 0;
c01040b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01040b9:	c9                   	leave  
c01040ba:	c3                   	ret    

c01040bb <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01040bb:	55                   	push   %ebp
c01040bc:	89 e5                	mov    %esp,%ebp
c01040be:	57                   	push   %edi
c01040bf:	56                   	push   %esi
c01040c0:	53                   	push   %ebx
c01040c1:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c01040c4:	c7 04 24 70 7b 10 c0 	movl   $0xc0107b70,(%esp)
c01040cb:	e8 c2 c1 ff ff       	call   c0100292 <cprintf>
    size_t left, right = 0, perm;
c01040d0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01040d7:	e9 fa 00 00 00       	jmp    c01041d6 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01040dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040df:	89 04 24             	mov    %eax,(%esp)
c01040e2:	e8 e0 fe ff ff       	call   c0103fc7 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c01040e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01040ea:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01040ed:	29 d1                	sub    %edx,%ecx
c01040ef:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01040f1:	89 d6                	mov    %edx,%esi
c01040f3:	c1 e6 16             	shl    $0x16,%esi
c01040f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040f9:	89 d3                	mov    %edx,%ebx
c01040fb:	c1 e3 16             	shl    $0x16,%ebx
c01040fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104101:	89 d1                	mov    %edx,%ecx
c0104103:	c1 e1 16             	shl    $0x16,%ecx
c0104106:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0104109:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010410c:	29 d7                	sub    %edx,%edi
c010410e:	89 fa                	mov    %edi,%edx
c0104110:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104114:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104118:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010411c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104120:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104124:	c7 04 24 a1 7b 10 c0 	movl   $0xc0107ba1,(%esp)
c010412b:	e8 62 c1 ff ff       	call   c0100292 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0104130:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104133:	c1 e0 0a             	shl    $0xa,%eax
c0104136:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104139:	eb 54                	jmp    c010418f <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010413b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010413e:	89 04 24             	mov    %eax,(%esp)
c0104141:	e8 81 fe ff ff       	call   c0103fc7 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0104146:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104149:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010414c:	29 d1                	sub    %edx,%ecx
c010414e:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104150:	89 d6                	mov    %edx,%esi
c0104152:	c1 e6 0c             	shl    $0xc,%esi
c0104155:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104158:	89 d3                	mov    %edx,%ebx
c010415a:	c1 e3 0c             	shl    $0xc,%ebx
c010415d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104160:	89 d1                	mov    %edx,%ecx
c0104162:	c1 e1 0c             	shl    $0xc,%ecx
c0104165:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0104168:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010416b:	29 d7                	sub    %edx,%edi
c010416d:	89 fa                	mov    %edi,%edx
c010416f:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104173:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104177:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010417b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010417f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104183:	c7 04 24 c0 7b 10 c0 	movl   $0xc0107bc0,(%esp)
c010418a:	e8 03 c1 ff ff       	call   c0100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010418f:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0104194:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104197:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010419a:	89 d3                	mov    %edx,%ebx
c010419c:	c1 e3 0a             	shl    $0xa,%ebx
c010419f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01041a2:	89 d1                	mov    %edx,%ecx
c01041a4:	c1 e1 0a             	shl    $0xa,%ecx
c01041a7:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c01041aa:	89 54 24 14          	mov    %edx,0x14(%esp)
c01041ae:	8d 55 d8             	lea    -0x28(%ebp),%edx
c01041b1:	89 54 24 10          	mov    %edx,0x10(%esp)
c01041b5:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01041b9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01041bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01041c1:	89 0c 24             	mov    %ecx,(%esp)
c01041c4:	e8 40 fe ff ff       	call   c0104009 <get_pgtable_items>
c01041c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01041cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01041d0:	0f 85 65 ff ff ff    	jne    c010413b <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01041d6:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01041db:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01041de:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01041e1:	89 54 24 14          	mov    %edx,0x14(%esp)
c01041e5:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01041e8:	89 54 24 10          	mov    %edx,0x10(%esp)
c01041ec:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01041f0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01041f4:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01041fb:	00 
c01041fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0104203:	e8 01 fe ff ff       	call   c0104009 <get_pgtable_items>
c0104208:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010420b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010420f:	0f 85 c7 fe ff ff    	jne    c01040dc <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0104215:	c7 04 24 e4 7b 10 c0 	movl   $0xc0107be4,(%esp)
c010421c:	e8 71 c0 ff ff       	call   c0100292 <cprintf>
}
c0104221:	90                   	nop
c0104222:	83 c4 4c             	add    $0x4c,%esp
c0104225:	5b                   	pop    %ebx
c0104226:	5e                   	pop    %esi
c0104227:	5f                   	pop    %edi
c0104228:	5d                   	pop    %ebp
c0104229:	c3                   	ret    

c010422a <page2ppn>:
page2ppn(struct Page *page) {
c010422a:	55                   	push   %ebp
c010422b:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010422d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104230:	8b 15 18 df 11 c0    	mov    0xc011df18,%edx
c0104236:	29 d0                	sub    %edx,%eax
c0104238:	c1 f8 02             	sar    $0x2,%eax
c010423b:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0104241:	5d                   	pop    %ebp
c0104242:	c3                   	ret    

c0104243 <page2pa>:
page2pa(struct Page *page) {
c0104243:	55                   	push   %ebp
c0104244:	89 e5                	mov    %esp,%ebp
c0104246:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104249:	8b 45 08             	mov    0x8(%ebp),%eax
c010424c:	89 04 24             	mov    %eax,(%esp)
c010424f:	e8 d6 ff ff ff       	call   c010422a <page2ppn>
c0104254:	c1 e0 0c             	shl    $0xc,%eax
}
c0104257:	c9                   	leave  
c0104258:	c3                   	ret    

c0104259 <page_ref>:
page_ref(struct Page *page) {
c0104259:	55                   	push   %ebp
c010425a:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010425c:	8b 45 08             	mov    0x8(%ebp),%eax
c010425f:	8b 00                	mov    (%eax),%eax
}
c0104261:	5d                   	pop    %ebp
c0104262:	c3                   	ret    

c0104263 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0104263:	55                   	push   %ebp
c0104264:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104266:	8b 45 08             	mov    0x8(%ebp),%eax
c0104269:	8b 55 0c             	mov    0xc(%ebp),%edx
c010426c:	89 10                	mov    %edx,(%eax)
}
c010426e:	90                   	nop
c010426f:	5d                   	pop    %ebp
c0104270:	c3                   	ret    

c0104271 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0104271:	55                   	push   %ebp
c0104272:	89 e5                	mov    %esp,%ebp
c0104274:	83 ec 10             	sub    $0x10,%esp
c0104277:	c7 45 fc 20 df 11 c0 	movl   $0xc011df20,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010427e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104281:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104284:	89 50 04             	mov    %edx,0x4(%eax)
c0104287:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010428a:	8b 50 04             	mov    0x4(%eax),%edx
c010428d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104290:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0104292:	c7 05 28 df 11 c0 00 	movl   $0x0,0xc011df28
c0104299:	00 00 00 
}
c010429c:	90                   	nop
c010429d:	c9                   	leave  
c010429e:	c3                   	ret    

c010429f <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010429f:	55                   	push   %ebp
c01042a0:	89 e5                	mov    %esp,%ebp
c01042a2:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01042a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01042a9:	75 24                	jne    c01042cf <default_init_memmap+0x30>
c01042ab:	c7 44 24 0c 18 7c 10 	movl   $0xc0107c18,0xc(%esp)
c01042b2:	c0 
c01042b3:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c01042ba:	c0 
c01042bb:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01042c2:	00 
c01042c3:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c01042ca:	e8 1a c1 ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c01042cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01042d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01042d5:	eb 7d                	jmp    c0104354 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c01042d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042da:	83 c0 04             	add    $0x4,%eax
c01042dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01042e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01042ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01042ed:	0f a3 10             	bt     %edx,(%eax)
c01042f0:	19 c0                	sbb    %eax,%eax
c01042f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01042f5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01042f9:	0f 95 c0             	setne  %al
c01042fc:	0f b6 c0             	movzbl %al,%eax
c01042ff:	85 c0                	test   %eax,%eax
c0104301:	75 24                	jne    c0104327 <default_init_memmap+0x88>
c0104303:	c7 44 24 0c 49 7c 10 	movl   $0xc0107c49,0xc(%esp)
c010430a:	c0 
c010430b:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104312:	c0 
c0104313:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010431a:	00 
c010431b:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104322:	e8 c2 c0 ff ff       	call   c01003e9 <__panic>
        p->flags = p->property = 0;
c0104327:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010432a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0104331:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104334:	8b 50 08             	mov    0x8(%eax),%edx
c0104337:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010433a:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c010433d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104344:	00 
c0104345:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104348:	89 04 24             	mov    %eax,(%esp)
c010434b:	e8 13 ff ff ff       	call   c0104263 <set_page_ref>
    for (; p != base + n; p ++) {
c0104350:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104354:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104357:	89 d0                	mov    %edx,%eax
c0104359:	c1 e0 02             	shl    $0x2,%eax
c010435c:	01 d0                	add    %edx,%eax
c010435e:	c1 e0 02             	shl    $0x2,%eax
c0104361:	89 c2                	mov    %eax,%edx
c0104363:	8b 45 08             	mov    0x8(%ebp),%eax
c0104366:	01 d0                	add    %edx,%eax
c0104368:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010436b:	0f 85 66 ff ff ff    	jne    c01042d7 <default_init_memmap+0x38>
	
    }
    base->property = n;
c0104371:	8b 45 08             	mov    0x8(%ebp),%eax
c0104374:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104377:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010437a:	8b 45 08             	mov    0x8(%ebp),%eax
c010437d:	83 c0 04             	add    $0x4,%eax
c0104380:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104387:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010438a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010438d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104390:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0104393:	8b 15 28 df 11 c0    	mov    0xc011df28,%edx
c0104399:	8b 45 0c             	mov    0xc(%ebp),%eax
c010439c:	01 d0                	add    %edx,%eax
c010439e:	a3 28 df 11 c0       	mov    %eax,0xc011df28
    list_add_before(&free_list,&(base->page_link));
c01043a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01043a6:	83 c0 0c             	add    $0xc,%eax
c01043a9:	c7 45 e4 20 df 11 c0 	movl   $0xc011df20,-0x1c(%ebp)
c01043b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01043b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043b6:	8b 00                	mov    (%eax),%eax
c01043b8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01043bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01043be:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01043c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01043c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01043ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01043cd:	89 10                	mov    %edx,(%eax)
c01043cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01043d2:	8b 10                	mov    (%eax),%edx
c01043d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01043d7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01043da:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043dd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01043e0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01043e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01043e9:	89 10                	mov    %edx,(%eax)
}
c01043eb:	90                   	nop
c01043ec:	c9                   	leave  
c01043ed:	c3                   	ret    

c01043ee <default_alloc_pages>:
 *              return `p`.
 *      (4.2)
 *          If we can not find a free block with its size >=n, then return NULL.
*/
static struct Page *
default_alloc_pages(size_t n) {
c01043ee:	55                   	push   %ebp
c01043ef:	89 e5                	mov    %esp,%ebp
c01043f1:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01043f4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01043f8:	75 24                	jne    c010441e <default_alloc_pages+0x30>
c01043fa:	c7 44 24 0c 18 7c 10 	movl   $0xc0107c18,0xc(%esp)
c0104401:	c0 
c0104402:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104409:	c0 
c010440a:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0104411:	00 
c0104412:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104419:	e8 cb bf ff ff       	call   c01003e9 <__panic>
    if (n > nr_free) {
c010441e:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104423:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104426:	76 0a                	jbe    c0104432 <default_alloc_pages+0x44>
        return NULL;
c0104428:	b8 00 00 00 00       	mov    $0x0,%eax
c010442d:	e9 49 01 00 00       	jmp    c010457b <default_alloc_pages+0x18d>
    }
    struct Page *page=NULL;
c0104432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0104439:	c7 45 f0 20 df 11 c0 	movl   $0xc011df20,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104440:	eb 1c                	jmp    c010445e <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0104442:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104445:	83 e8 0c             	sub    $0xc,%eax
c0104448:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c010444b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010444e:	8b 40 08             	mov    0x8(%eax),%eax
c0104451:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104454:	77 08                	ja     c010445e <default_alloc_pages+0x70>
	   page=p;
c0104456:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104459:	89 45 f4             	mov    %eax,-0xc(%ebp)
	   break;
c010445c:	eb 18                	jmp    c0104476 <default_alloc_pages+0x88>
c010445e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104461:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0104464:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104467:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010446a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010446d:	81 7d f0 20 df 11 c0 	cmpl   $0xc011df20,-0x10(%ebp)
c0104474:	75 cc                	jne    c0104442 <default_alloc_pages+0x54>
        }
    }
    if(page!=NULL){
c0104476:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010447a:	0f 84 f8 00 00 00    	je     c0104578 <default_alloc_pages+0x18a>
	if(page->property>n){
c0104480:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104483:	8b 40 08             	mov    0x8(%eax),%eax
c0104486:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104489:	0f 83 98 00 00 00    	jae    c0104527 <default_alloc_pages+0x139>
	   struct Page*p=page+n;
c010448f:	8b 55 08             	mov    0x8(%ebp),%edx
c0104492:	89 d0                	mov    %edx,%eax
c0104494:	c1 e0 02             	shl    $0x2,%eax
c0104497:	01 d0                	add    %edx,%eax
c0104499:	c1 e0 02             	shl    $0x2,%eax
c010449c:	89 c2                	mov    %eax,%edx
c010449e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044a1:	01 d0                	add    %edx,%eax
c01044a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
	   p->property=page->property-n;
c01044a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044a9:	8b 40 08             	mov    0x8(%eax),%eax
c01044ac:	2b 45 08             	sub    0x8(%ebp),%eax
c01044af:	89 c2                	mov    %eax,%edx
c01044b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044b4:	89 50 08             	mov    %edx,0x8(%eax)
	   SetPageProperty(p);
c01044b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044ba:	83 c0 04             	add    $0x4,%eax
c01044bd:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c01044c4:	89 45 c0             	mov    %eax,-0x40(%ebp)
c01044c7:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01044ca:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01044cd:	0f ab 10             	bts    %edx,(%eax)
	   list_add(&(page->page_link),&(p->page_link));
c01044d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044d3:	83 c0 0c             	add    $0xc,%eax
c01044d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01044d9:	83 c2 0c             	add    $0xc,%edx
c01044dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
c01044df:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01044e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01044e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01044e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01044eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c01044ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01044f1:	8b 40 04             	mov    0x4(%eax),%eax
c01044f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01044f7:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01044fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01044fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0104500:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0104503:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104506:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104509:	89 10                	mov    %edx,(%eax)
c010450b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010450e:	8b 10                	mov    (%eax),%edx
c0104510:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104513:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104516:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104519:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010451c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010451f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104522:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104525:	89 10                	mov    %edx,(%eax)
	}
	
	list_del(&(page->page_link));
c0104527:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010452a:	83 c0 0c             	add    $0xc,%eax
c010452d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104530:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104533:	8b 40 04             	mov    0x4(%eax),%eax
c0104536:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104539:	8b 12                	mov    (%edx),%edx
c010453b:	89 55 b0             	mov    %edx,-0x50(%ebp)
c010453e:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104541:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104544:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104547:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010454a:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010454d:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104550:	89 10                	mov    %edx,(%eax)
	nr_free-=n;
c0104552:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104557:	2b 45 08             	sub    0x8(%ebp),%eax
c010455a:	a3 28 df 11 c0       	mov    %eax,0xc011df28
	ClearPageProperty(page);
c010455f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104562:	83 c0 04             	add    $0x4,%eax
c0104565:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c010456c:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010456f:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104572:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104575:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0104578:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010457b:	c9                   	leave  
c010457c:	c3                   	ret    

c010457d <default_free_pages>:
 *  (5.3)
 *      Try to merge blocks at lower or higher addresses. Notice: This should
 *  change some pages' `p->property` correctly.
 */
static void
default_free_pages(struct Page *base, size_t n) {
c010457d:	55                   	push   %ebp
c010457e:	89 e5                	mov    %esp,%ebp
c0104580:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0104586:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010458a:	75 24                	jne    c01045b0 <default_free_pages+0x33>
c010458c:	c7 44 24 0c 18 7c 10 	movl   $0xc0107c18,0xc(%esp)
c0104593:	c0 
c0104594:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c010459b:	c0 
c010459c:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c01045a3:	00 
c01045a4:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c01045ab:	e8 39 be ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c01045b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01045b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01045b6:	e9 9d 00 00 00       	jmp    c0104658 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c01045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045be:	83 c0 04             	add    $0x4,%eax
c01045c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01045c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01045cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01045ce:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01045d1:	0f a3 10             	bt     %edx,(%eax)
c01045d4:	19 c0                	sbb    %eax,%eax
c01045d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01045d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01045dd:	0f 95 c0             	setne  %al
c01045e0:	0f b6 c0             	movzbl %al,%eax
c01045e3:	85 c0                	test   %eax,%eax
c01045e5:	75 2c                	jne    c0104613 <default_free_pages+0x96>
c01045e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045ea:	83 c0 04             	add    $0x4,%eax
c01045ed:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01045f4:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01045f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01045fa:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01045fd:	0f a3 10             	bt     %edx,(%eax)
c0104600:	19 c0                	sbb    %eax,%eax
c0104602:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0104605:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0104609:	0f 95 c0             	setne  %al
c010460c:	0f b6 c0             	movzbl %al,%eax
c010460f:	85 c0                	test   %eax,%eax
c0104611:	74 24                	je     c0104637 <default_free_pages+0xba>
c0104613:	c7 44 24 0c 5c 7c 10 	movl   $0xc0107c5c,0xc(%esp)
c010461a:	c0 
c010461b:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104622:	c0 
c0104623:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c010462a:	00 
c010462b:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104632:	e8 b2 bd ff ff       	call   c01003e9 <__panic>
        p->flags = 0;
c0104637:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010463a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0104641:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104648:	00 
c0104649:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010464c:	89 04 24             	mov    %eax,(%esp)
c010464f:	e8 0f fc ff ff       	call   c0104263 <set_page_ref>
    for (; p != base + n; p ++) {
c0104654:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104658:	8b 55 0c             	mov    0xc(%ebp),%edx
c010465b:	89 d0                	mov    %edx,%eax
c010465d:	c1 e0 02             	shl    $0x2,%eax
c0104660:	01 d0                	add    %edx,%eax
c0104662:	c1 e0 02             	shl    $0x2,%eax
c0104665:	89 c2                	mov    %eax,%edx
c0104667:	8b 45 08             	mov    0x8(%ebp),%eax
c010466a:	01 d0                	add    %edx,%eax
c010466c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010466f:	0f 85 46 ff ff ff    	jne    c01045bb <default_free_pages+0x3e>
    }
    base->property = n;
c0104675:	8b 45 08             	mov    0x8(%ebp),%eax
c0104678:	8b 55 0c             	mov    0xc(%ebp),%edx
c010467b:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010467e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104681:	83 c0 04             	add    $0x4,%eax
c0104684:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010468b:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010468e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104691:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104694:	0f ab 10             	bts    %edx,(%eax)
c0104697:	c7 45 d4 20 df 11 c0 	movl   $0xc011df20,-0x2c(%ebp)
    return listelm->next;
c010469e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01046a1:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c01046a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01046a7:	e9 08 01 00 00       	jmp    c01047b4 <default_free_pages+0x237>
        p = le2page(le, page_link);
c01046ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046af:	83 e8 0c             	sub    $0xc,%eax
c01046b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046b8:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01046bb:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01046be:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01046c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c01046c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01046c7:	8b 50 08             	mov    0x8(%eax),%edx
c01046ca:	89 d0                	mov    %edx,%eax
c01046cc:	c1 e0 02             	shl    $0x2,%eax
c01046cf:	01 d0                	add    %edx,%eax
c01046d1:	c1 e0 02             	shl    $0x2,%eax
c01046d4:	89 c2                	mov    %eax,%edx
c01046d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01046d9:	01 d0                	add    %edx,%eax
c01046db:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01046de:	75 5a                	jne    c010473a <default_free_pages+0x1bd>
            base->property += p->property;
c01046e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01046e3:	8b 50 08             	mov    0x8(%eax),%edx
c01046e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046e9:	8b 40 08             	mov    0x8(%eax),%eax
c01046ec:	01 c2                	add    %eax,%edx
c01046ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01046f1:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c01046f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046f7:	83 c0 04             	add    $0x4,%eax
c01046fa:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0104701:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104704:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104707:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010470a:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c010470d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104710:	83 c0 0c             	add    $0xc,%eax
c0104713:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104716:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104719:	8b 40 04             	mov    0x4(%eax),%eax
c010471c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010471f:	8b 12                	mov    (%edx),%edx
c0104721:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0104724:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c0104727:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010472a:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010472d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104730:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104733:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104736:	89 10                	mov    %edx,(%eax)
c0104738:	eb 7a                	jmp    c01047b4 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c010473a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010473d:	8b 50 08             	mov    0x8(%eax),%edx
c0104740:	89 d0                	mov    %edx,%eax
c0104742:	c1 e0 02             	shl    $0x2,%eax
c0104745:	01 d0                	add    %edx,%eax
c0104747:	c1 e0 02             	shl    $0x2,%eax
c010474a:	89 c2                	mov    %eax,%edx
c010474c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010474f:	01 d0                	add    %edx,%eax
c0104751:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104754:	75 5e                	jne    c01047b4 <default_free_pages+0x237>
            p->property += base->property;
c0104756:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104759:	8b 50 08             	mov    0x8(%eax),%edx
c010475c:	8b 45 08             	mov    0x8(%ebp),%eax
c010475f:	8b 40 08             	mov    0x8(%eax),%eax
c0104762:	01 c2                	add    %eax,%edx
c0104764:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104767:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c010476a:	8b 45 08             	mov    0x8(%ebp),%eax
c010476d:	83 c0 04             	add    $0x4,%eax
c0104770:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0104777:	89 45 a0             	mov    %eax,-0x60(%ebp)
c010477a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010477d:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104780:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0104783:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104786:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0104789:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010478c:	83 c0 0c             	add    $0xc,%eax
c010478f:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104792:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104795:	8b 40 04             	mov    0x4(%eax),%eax
c0104798:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010479b:	8b 12                	mov    (%edx),%edx
c010479d:	89 55 ac             	mov    %edx,-0x54(%ebp)
c01047a0:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c01047a3:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01047a6:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01047a9:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01047ac:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01047af:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01047b2:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
c01047b4:	81 7d f0 20 df 11 c0 	cmpl   $0xc011df20,-0x10(%ebp)
c01047bb:	0f 85 eb fe ff ff    	jne    c01046ac <default_free_pages+0x12f>
        }
    }
    SetPageProperty(base);
c01047c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01047c4:	83 c0 04             	add    $0x4,%eax
c01047c7:	c7 45 98 01 00 00 00 	movl   $0x1,-0x68(%ebp)
c01047ce:	89 45 94             	mov    %eax,-0x6c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01047d1:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01047d4:	8b 55 98             	mov    -0x68(%ebp),%edx
c01047d7:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01047da:	8b 15 28 df 11 c0    	mov    0xc011df28,%edx
c01047e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047e3:	01 d0                	add    %edx,%eax
c01047e5:	a3 28 df 11 c0       	mov    %eax,0xc011df28
c01047ea:	c7 45 9c 20 df 11 c0 	movl   $0xc011df20,-0x64(%ebp)
    return listelm->next;
c01047f1:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01047f4:	8b 40 04             	mov    0x4(%eax),%eax
    le=list_next(&free_list);
c01047f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
c01047fa:	eb 0f                	jmp    c010480b <default_free_pages+0x28e>
c01047fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047ff:	89 45 90             	mov    %eax,-0x70(%ebp)
c0104802:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104805:	8b 40 04             	mov    0x4(%eax),%eax
	le=list_next(le);
c0104808:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
c010480b:	81 7d f0 20 df 11 c0 	cmpl   $0xc011df20,-0x10(%ebp)
c0104812:	74 0b                	je     c010481f <default_free_pages+0x2a2>
c0104814:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104817:	83 e8 0c             	sub    $0xc,%eax
c010481a:	39 45 08             	cmp    %eax,0x8(%ebp)
c010481d:	77 dd                	ja     c01047fc <default_free_pages+0x27f>
    }
    list_add_before(le, &(base->page_link));
c010481f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104822:	8d 50 0c             	lea    0xc(%eax),%edx
c0104825:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104828:	89 45 8c             	mov    %eax,-0x74(%ebp)
c010482b:	89 55 88             	mov    %edx,-0x78(%ebp)
    __list_add(elm, listelm->prev, listelm);
c010482e:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104831:	8b 00                	mov    (%eax),%eax
c0104833:	8b 55 88             	mov    -0x78(%ebp),%edx
c0104836:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104839:	89 45 80             	mov    %eax,-0x80(%ebp)
c010483c:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010483f:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
    prev->next = next->prev = elm;
c0104845:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c010484b:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010484e:	89 10                	mov    %edx,(%eax)
c0104850:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104856:	8b 10                	mov    (%eax),%edx
c0104858:	8b 45 80             	mov    -0x80(%ebp),%eax
c010485b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010485e:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104861:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0104867:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010486a:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010486d:	8b 55 80             	mov    -0x80(%ebp),%edx
c0104870:	89 10                	mov    %edx,(%eax)
}
c0104872:	90                   	nop
c0104873:	c9                   	leave  
c0104874:	c3                   	ret    

c0104875 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0104875:	55                   	push   %ebp
c0104876:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104878:	a1 28 df 11 c0       	mov    0xc011df28,%eax
}
c010487d:	5d                   	pop    %ebp
c010487e:	c3                   	ret    

c010487f <basic_check>:

static void
basic_check(void) {
c010487f:	55                   	push   %ebp
c0104880:	89 e5                	mov    %esp,%ebp
c0104882:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104885:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010488c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010488f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104892:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104895:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104898:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010489f:	e8 d8 e2 ff ff       	call   c0102b7c <alloc_pages>
c01048a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01048a7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01048ab:	75 24                	jne    c01048d1 <basic_check+0x52>
c01048ad:	c7 44 24 0c 81 7c 10 	movl   $0xc0107c81,0xc(%esp)
c01048b4:	c0 
c01048b5:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c01048bc:	c0 
c01048bd:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c01048c4:	00 
c01048c5:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c01048cc:	e8 18 bb ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01048d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01048d8:	e8 9f e2 ff ff       	call   c0102b7c <alloc_pages>
c01048dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01048e4:	75 24                	jne    c010490a <basic_check+0x8b>
c01048e6:	c7 44 24 0c 9d 7c 10 	movl   $0xc0107c9d,0xc(%esp)
c01048ed:	c0 
c01048ee:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c01048f5:	c0 
c01048f6:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c01048fd:	00 
c01048fe:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104905:	e8 df ba ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010490a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104911:	e8 66 e2 ff ff       	call   c0102b7c <alloc_pages>
c0104916:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104919:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010491d:	75 24                	jne    c0104943 <basic_check+0xc4>
c010491f:	c7 44 24 0c b9 7c 10 	movl   $0xc0107cb9,0xc(%esp)
c0104926:	c0 
c0104927:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c010492e:	c0 
c010492f:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0104936:	00 
c0104937:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c010493e:	e8 a6 ba ff ff       	call   c01003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104943:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104946:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104949:	74 10                	je     c010495b <basic_check+0xdc>
c010494b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010494e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104951:	74 08                	je     c010495b <basic_check+0xdc>
c0104953:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104956:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104959:	75 24                	jne    c010497f <basic_check+0x100>
c010495b:	c7 44 24 0c d8 7c 10 	movl   $0xc0107cd8,0xc(%esp)
c0104962:	c0 
c0104963:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c010496a:	c0 
c010496b:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c0104972:	00 
c0104973:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c010497a:	e8 6a ba ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010497f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104982:	89 04 24             	mov    %eax,(%esp)
c0104985:	e8 cf f8 ff ff       	call   c0104259 <page_ref>
c010498a:	85 c0                	test   %eax,%eax
c010498c:	75 1e                	jne    c01049ac <basic_check+0x12d>
c010498e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104991:	89 04 24             	mov    %eax,(%esp)
c0104994:	e8 c0 f8 ff ff       	call   c0104259 <page_ref>
c0104999:	85 c0                	test   %eax,%eax
c010499b:	75 0f                	jne    c01049ac <basic_check+0x12d>
c010499d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049a0:	89 04 24             	mov    %eax,(%esp)
c01049a3:	e8 b1 f8 ff ff       	call   c0104259 <page_ref>
c01049a8:	85 c0                	test   %eax,%eax
c01049aa:	74 24                	je     c01049d0 <basic_check+0x151>
c01049ac:	c7 44 24 0c fc 7c 10 	movl   $0xc0107cfc,0xc(%esp)
c01049b3:	c0 
c01049b4:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c01049bb:	c0 
c01049bc:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c01049c3:	00 
c01049c4:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c01049cb:	e8 19 ba ff ff       	call   c01003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01049d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049d3:	89 04 24             	mov    %eax,(%esp)
c01049d6:	e8 68 f8 ff ff       	call   c0104243 <page2pa>
c01049db:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c01049e1:	c1 e2 0c             	shl    $0xc,%edx
c01049e4:	39 d0                	cmp    %edx,%eax
c01049e6:	72 24                	jb     c0104a0c <basic_check+0x18d>
c01049e8:	c7 44 24 0c 38 7d 10 	movl   $0xc0107d38,0xc(%esp)
c01049ef:	c0 
c01049f0:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c01049f7:	c0 
c01049f8:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c01049ff:	00 
c0104a00:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104a07:	e8 dd b9 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0104a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a0f:	89 04 24             	mov    %eax,(%esp)
c0104a12:	e8 2c f8 ff ff       	call   c0104243 <page2pa>
c0104a17:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0104a1d:	c1 e2 0c             	shl    $0xc,%edx
c0104a20:	39 d0                	cmp    %edx,%eax
c0104a22:	72 24                	jb     c0104a48 <basic_check+0x1c9>
c0104a24:	c7 44 24 0c 55 7d 10 	movl   $0xc0107d55,0xc(%esp)
c0104a2b:	c0 
c0104a2c:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104a33:	c0 
c0104a34:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
c0104a3b:	00 
c0104a3c:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104a43:	e8 a1 b9 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a4b:	89 04 24             	mov    %eax,(%esp)
c0104a4e:	e8 f0 f7 ff ff       	call   c0104243 <page2pa>
c0104a53:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0104a59:	c1 e2 0c             	shl    $0xc,%edx
c0104a5c:	39 d0                	cmp    %edx,%eax
c0104a5e:	72 24                	jb     c0104a84 <basic_check+0x205>
c0104a60:	c7 44 24 0c 72 7d 10 	movl   $0xc0107d72,0xc(%esp)
c0104a67:	c0 
c0104a68:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104a6f:	c0 
c0104a70:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0104a77:	00 
c0104a78:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104a7f:	e8 65 b9 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104a84:	a1 20 df 11 c0       	mov    0xc011df20,%eax
c0104a89:	8b 15 24 df 11 c0    	mov    0xc011df24,%edx
c0104a8f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104a92:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104a95:	c7 45 dc 20 df 11 c0 	movl   $0xc011df20,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0104a9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a9f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104aa2:	89 50 04             	mov    %edx,0x4(%eax)
c0104aa5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104aa8:	8b 50 04             	mov    0x4(%eax),%edx
c0104aab:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104aae:	89 10                	mov    %edx,(%eax)
c0104ab0:	c7 45 e0 20 df 11 c0 	movl   $0xc011df20,-0x20(%ebp)
    return list->next == list;
c0104ab7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104aba:	8b 40 04             	mov    0x4(%eax),%eax
c0104abd:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104ac0:	0f 94 c0             	sete   %al
c0104ac3:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104ac6:	85 c0                	test   %eax,%eax
c0104ac8:	75 24                	jne    c0104aee <basic_check+0x26f>
c0104aca:	c7 44 24 0c 8f 7d 10 	movl   $0xc0107d8f,0xc(%esp)
c0104ad1:	c0 
c0104ad2:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104ad9:	c0 
c0104ada:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0104ae1:	00 
c0104ae2:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104ae9:	e8 fb b8 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104aee:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104af3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104af6:	c7 05 28 df 11 c0 00 	movl   $0x0,0xc011df28
c0104afd:	00 00 00 

    assert(alloc_page() == NULL);
c0104b00:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b07:	e8 70 e0 ff ff       	call   c0102b7c <alloc_pages>
c0104b0c:	85 c0                	test   %eax,%eax
c0104b0e:	74 24                	je     c0104b34 <basic_check+0x2b5>
c0104b10:	c7 44 24 0c a6 7d 10 	movl   $0xc0107da6,0xc(%esp)
c0104b17:	c0 
c0104b18:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104b1f:	c0 
c0104b20:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0104b27:	00 
c0104b28:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104b2f:	e8 b5 b8 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104b34:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b3b:	00 
c0104b3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b3f:	89 04 24             	mov    %eax,(%esp)
c0104b42:	e8 6d e0 ff ff       	call   c0102bb4 <free_pages>
    free_page(p1);
c0104b47:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b4e:	00 
c0104b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b52:	89 04 24             	mov    %eax,(%esp)
c0104b55:	e8 5a e0 ff ff       	call   c0102bb4 <free_pages>
    free_page(p2);
c0104b5a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b61:	00 
c0104b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b65:	89 04 24             	mov    %eax,(%esp)
c0104b68:	e8 47 e0 ff ff       	call   c0102bb4 <free_pages>
    assert(nr_free == 3);
c0104b6d:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104b72:	83 f8 03             	cmp    $0x3,%eax
c0104b75:	74 24                	je     c0104b9b <basic_check+0x31c>
c0104b77:	c7 44 24 0c bb 7d 10 	movl   $0xc0107dbb,0xc(%esp)
c0104b7e:	c0 
c0104b7f:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104b86:	c0 
c0104b87:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c0104b8e:	00 
c0104b8f:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104b96:	e8 4e b8 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104b9b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ba2:	e8 d5 df ff ff       	call   c0102b7c <alloc_pages>
c0104ba7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104baa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104bae:	75 24                	jne    c0104bd4 <basic_check+0x355>
c0104bb0:	c7 44 24 0c 81 7c 10 	movl   $0xc0107c81,0xc(%esp)
c0104bb7:	c0 
c0104bb8:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104bbf:	c0 
c0104bc0:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0104bc7:	00 
c0104bc8:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104bcf:	e8 15 b8 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104bd4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104bdb:	e8 9c df ff ff       	call   c0102b7c <alloc_pages>
c0104be0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104be3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104be7:	75 24                	jne    c0104c0d <basic_check+0x38e>
c0104be9:	c7 44 24 0c 9d 7c 10 	movl   $0xc0107c9d,0xc(%esp)
c0104bf0:	c0 
c0104bf1:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104bf8:	c0 
c0104bf9:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0104c00:	00 
c0104c01:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104c08:	e8 dc b7 ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104c0d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c14:	e8 63 df ff ff       	call   c0102b7c <alloc_pages>
c0104c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c1c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104c20:	75 24                	jne    c0104c46 <basic_check+0x3c7>
c0104c22:	c7 44 24 0c b9 7c 10 	movl   $0xc0107cb9,0xc(%esp)
c0104c29:	c0 
c0104c2a:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104c31:	c0 
c0104c32:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0104c39:	00 
c0104c3a:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104c41:	e8 a3 b7 ff ff       	call   c01003e9 <__panic>

    assert(alloc_page() == NULL);
c0104c46:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c4d:	e8 2a df ff ff       	call   c0102b7c <alloc_pages>
c0104c52:	85 c0                	test   %eax,%eax
c0104c54:	74 24                	je     c0104c7a <basic_check+0x3fb>
c0104c56:	c7 44 24 0c a6 7d 10 	movl   $0xc0107da6,0xc(%esp)
c0104c5d:	c0 
c0104c5e:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104c65:	c0 
c0104c66:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0104c6d:	00 
c0104c6e:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104c75:	e8 6f b7 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104c7a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104c81:	00 
c0104c82:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c85:	89 04 24             	mov    %eax,(%esp)
c0104c88:	e8 27 df ff ff       	call   c0102bb4 <free_pages>
c0104c8d:	c7 45 d8 20 df 11 c0 	movl   $0xc011df20,-0x28(%ebp)
c0104c94:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104c97:	8b 40 04             	mov    0x4(%eax),%eax
c0104c9a:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104c9d:	0f 94 c0             	sete   %al
c0104ca0:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104ca3:	85 c0                	test   %eax,%eax
c0104ca5:	74 24                	je     c0104ccb <basic_check+0x44c>
c0104ca7:	c7 44 24 0c c8 7d 10 	movl   $0xc0107dc8,0xc(%esp)
c0104cae:	c0 
c0104caf:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104cb6:	c0 
c0104cb7:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0104cbe:	00 
c0104cbf:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104cc6:	e8 1e b7 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104ccb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104cd2:	e8 a5 de ff ff       	call   c0102b7c <alloc_pages>
c0104cd7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104cda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104cdd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104ce0:	74 24                	je     c0104d06 <basic_check+0x487>
c0104ce2:	c7 44 24 0c e0 7d 10 	movl   $0xc0107de0,0xc(%esp)
c0104ce9:	c0 
c0104cea:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104cf1:	c0 
c0104cf2:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0104cf9:	00 
c0104cfa:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104d01:	e8 e3 b6 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104d06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104d0d:	e8 6a de ff ff       	call   c0102b7c <alloc_pages>
c0104d12:	85 c0                	test   %eax,%eax
c0104d14:	74 24                	je     c0104d3a <basic_check+0x4bb>
c0104d16:	c7 44 24 0c a6 7d 10 	movl   $0xc0107da6,0xc(%esp)
c0104d1d:	c0 
c0104d1e:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104d25:	c0 
c0104d26:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0104d2d:	00 
c0104d2e:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104d35:	e8 af b6 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c0104d3a:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104d3f:	85 c0                	test   %eax,%eax
c0104d41:	74 24                	je     c0104d67 <basic_check+0x4e8>
c0104d43:	c7 44 24 0c f9 7d 10 	movl   $0xc0107df9,0xc(%esp)
c0104d4a:	c0 
c0104d4b:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104d52:	c0 
c0104d53:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0104d5a:	00 
c0104d5b:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104d62:	e8 82 b6 ff ff       	call   c01003e9 <__panic>
    free_list = free_list_store;
c0104d67:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d6a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104d6d:	a3 20 df 11 c0       	mov    %eax,0xc011df20
c0104d72:	89 15 24 df 11 c0    	mov    %edx,0xc011df24
    nr_free = nr_free_store;
c0104d78:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d7b:	a3 28 df 11 c0       	mov    %eax,0xc011df28

    free_page(p);
c0104d80:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d87:	00 
c0104d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d8b:	89 04 24             	mov    %eax,(%esp)
c0104d8e:	e8 21 de ff ff       	call   c0102bb4 <free_pages>
    free_page(p1);
c0104d93:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d9a:	00 
c0104d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d9e:	89 04 24             	mov    %eax,(%esp)
c0104da1:	e8 0e de ff ff       	call   c0102bb4 <free_pages>
    free_page(p2);
c0104da6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104dad:	00 
c0104dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104db1:	89 04 24             	mov    %eax,(%esp)
c0104db4:	e8 fb dd ff ff       	call   c0102bb4 <free_pages>
}
c0104db9:	90                   	nop
c0104dba:	c9                   	leave  
c0104dbb:	c3                   	ret    

c0104dbc <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104dbc:	55                   	push   %ebp
c0104dbd:	89 e5                	mov    %esp,%ebp
c0104dbf:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0104dc5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104dcc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104dd3:	c7 45 ec 20 df 11 c0 	movl   $0xc011df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104dda:	eb 6a                	jmp    c0104e46 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0104ddc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ddf:	83 e8 0c             	sub    $0xc,%eax
c0104de2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0104de5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104de8:	83 c0 04             	add    $0x4,%eax
c0104deb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104df2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104df5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104df8:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104dfb:	0f a3 10             	bt     %edx,(%eax)
c0104dfe:	19 c0                	sbb    %eax,%eax
c0104e00:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104e03:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104e07:	0f 95 c0             	setne  %al
c0104e0a:	0f b6 c0             	movzbl %al,%eax
c0104e0d:	85 c0                	test   %eax,%eax
c0104e0f:	75 24                	jne    c0104e35 <default_check+0x79>
c0104e11:	c7 44 24 0c 06 7e 10 	movl   $0xc0107e06,0xc(%esp)
c0104e18:	c0 
c0104e19:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104e20:	c0 
c0104e21:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0104e28:	00 
c0104e29:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104e30:	e8 b4 b5 ff ff       	call   c01003e9 <__panic>
        count ++, total += p->property;
c0104e35:	ff 45 f4             	incl   -0xc(%ebp)
c0104e38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104e3b:	8b 50 08             	mov    0x8(%eax),%edx
c0104e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e41:	01 d0                	add    %edx,%eax
c0104e43:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e46:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e49:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0104e4c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104e4f:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104e52:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104e55:	81 7d ec 20 df 11 c0 	cmpl   $0xc011df20,-0x14(%ebp)
c0104e5c:	0f 85 7a ff ff ff    	jne    c0104ddc <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0104e62:	e8 80 dd ff ff       	call   c0102be7 <nr_free_pages>
c0104e67:	89 c2                	mov    %eax,%edx
c0104e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e6c:	39 c2                	cmp    %eax,%edx
c0104e6e:	74 24                	je     c0104e94 <default_check+0xd8>
c0104e70:	c7 44 24 0c 16 7e 10 	movl   $0xc0107e16,0xc(%esp)
c0104e77:	c0 
c0104e78:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104e7f:	c0 
c0104e80:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0104e87:	00 
c0104e88:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104e8f:	e8 55 b5 ff ff       	call   c01003e9 <__panic>

    basic_check();
c0104e94:	e8 e6 f9 ff ff       	call   c010487f <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104e99:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104ea0:	e8 d7 dc ff ff       	call   c0102b7c <alloc_pages>
c0104ea5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0104ea8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104eac:	75 24                	jne    c0104ed2 <default_check+0x116>
c0104eae:	c7 44 24 0c 2f 7e 10 	movl   $0xc0107e2f,0xc(%esp)
c0104eb5:	c0 
c0104eb6:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104ebd:	c0 
c0104ebe:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0104ec5:	00 
c0104ec6:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104ecd:	e8 17 b5 ff ff       	call   c01003e9 <__panic>
    assert(!PageProperty(p0));
c0104ed2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ed5:	83 c0 04             	add    $0x4,%eax
c0104ed8:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104edf:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104ee2:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104ee5:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104ee8:	0f a3 10             	bt     %edx,(%eax)
c0104eeb:	19 c0                	sbb    %eax,%eax
c0104eed:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104ef0:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104ef4:	0f 95 c0             	setne  %al
c0104ef7:	0f b6 c0             	movzbl %al,%eax
c0104efa:	85 c0                	test   %eax,%eax
c0104efc:	74 24                	je     c0104f22 <default_check+0x166>
c0104efe:	c7 44 24 0c 3a 7e 10 	movl   $0xc0107e3a,0xc(%esp)
c0104f05:	c0 
c0104f06:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104f0d:	c0 
c0104f0e:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0104f15:	00 
c0104f16:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104f1d:	e8 c7 b4 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104f22:	a1 20 df 11 c0       	mov    0xc011df20,%eax
c0104f27:	8b 15 24 df 11 c0    	mov    0xc011df24,%edx
c0104f2d:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104f30:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104f33:	c7 45 b0 20 df 11 c0 	movl   $0xc011df20,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0104f3a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104f3d:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104f40:	89 50 04             	mov    %edx,0x4(%eax)
c0104f43:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104f46:	8b 50 04             	mov    0x4(%eax),%edx
c0104f49:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104f4c:	89 10                	mov    %edx,(%eax)
c0104f4e:	c7 45 b4 20 df 11 c0 	movl   $0xc011df20,-0x4c(%ebp)
    return list->next == list;
c0104f55:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104f58:	8b 40 04             	mov    0x4(%eax),%eax
c0104f5b:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0104f5e:	0f 94 c0             	sete   %al
c0104f61:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104f64:	85 c0                	test   %eax,%eax
c0104f66:	75 24                	jne    c0104f8c <default_check+0x1d0>
c0104f68:	c7 44 24 0c 8f 7d 10 	movl   $0xc0107d8f,0xc(%esp)
c0104f6f:	c0 
c0104f70:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104f77:	c0 
c0104f78:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0104f7f:	00 
c0104f80:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104f87:	e8 5d b4 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104f8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f93:	e8 e4 db ff ff       	call   c0102b7c <alloc_pages>
c0104f98:	85 c0                	test   %eax,%eax
c0104f9a:	74 24                	je     c0104fc0 <default_check+0x204>
c0104f9c:	c7 44 24 0c a6 7d 10 	movl   $0xc0107da6,0xc(%esp)
c0104fa3:	c0 
c0104fa4:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0104fab:	c0 
c0104fac:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0104fb3:	00 
c0104fb4:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0104fbb:	e8 29 b4 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104fc0:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104fc5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0104fc8:	c7 05 28 df 11 c0 00 	movl   $0x0,0xc011df28
c0104fcf:	00 00 00 

    free_pages(p0 + 2, 3);
c0104fd2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104fd5:	83 c0 28             	add    $0x28,%eax
c0104fd8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104fdf:	00 
c0104fe0:	89 04 24             	mov    %eax,(%esp)
c0104fe3:	e8 cc db ff ff       	call   c0102bb4 <free_pages>
    assert(alloc_pages(4) == NULL);
c0104fe8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104fef:	e8 88 db ff ff       	call   c0102b7c <alloc_pages>
c0104ff4:	85 c0                	test   %eax,%eax
c0104ff6:	74 24                	je     c010501c <default_check+0x260>
c0104ff8:	c7 44 24 0c 4c 7e 10 	movl   $0xc0107e4c,0xc(%esp)
c0104fff:	c0 
c0105000:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0105007:	c0 
c0105008:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c010500f:	00 
c0105010:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0105017:	e8 cd b3 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010501c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010501f:	83 c0 28             	add    $0x28,%eax
c0105022:	83 c0 04             	add    $0x4,%eax
c0105025:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c010502c:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010502f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105032:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0105035:	0f a3 10             	bt     %edx,(%eax)
c0105038:	19 c0                	sbb    %eax,%eax
c010503a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c010503d:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0105041:	0f 95 c0             	setne  %al
c0105044:	0f b6 c0             	movzbl %al,%eax
c0105047:	85 c0                	test   %eax,%eax
c0105049:	74 0e                	je     c0105059 <default_check+0x29d>
c010504b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010504e:	83 c0 28             	add    $0x28,%eax
c0105051:	8b 40 08             	mov    0x8(%eax),%eax
c0105054:	83 f8 03             	cmp    $0x3,%eax
c0105057:	74 24                	je     c010507d <default_check+0x2c1>
c0105059:	c7 44 24 0c 64 7e 10 	movl   $0xc0107e64,0xc(%esp)
c0105060:	c0 
c0105061:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0105068:	c0 
c0105069:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0105070:	00 
c0105071:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0105078:	e8 6c b3 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010507d:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105084:	e8 f3 da ff ff       	call   c0102b7c <alloc_pages>
c0105089:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010508c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105090:	75 24                	jne    c01050b6 <default_check+0x2fa>
c0105092:	c7 44 24 0c 90 7e 10 	movl   $0xc0107e90,0xc(%esp)
c0105099:	c0 
c010509a:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c01050a1:	c0 
c01050a2:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c01050a9:	00 
c01050aa:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c01050b1:	e8 33 b3 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c01050b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01050bd:	e8 ba da ff ff       	call   c0102b7c <alloc_pages>
c01050c2:	85 c0                	test   %eax,%eax
c01050c4:	74 24                	je     c01050ea <default_check+0x32e>
c01050c6:	c7 44 24 0c a6 7d 10 	movl   $0xc0107da6,0xc(%esp)
c01050cd:	c0 
c01050ce:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c01050d5:	c0 
c01050d6:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c01050dd:	00 
c01050de:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c01050e5:	e8 ff b2 ff ff       	call   c01003e9 <__panic>
    assert(p0 + 2 == p1);
c01050ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050ed:	83 c0 28             	add    $0x28,%eax
c01050f0:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01050f3:	74 24                	je     c0105119 <default_check+0x35d>
c01050f5:	c7 44 24 0c ae 7e 10 	movl   $0xc0107eae,0xc(%esp)
c01050fc:	c0 
c01050fd:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0105104:	c0 
c0105105:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c010510c:	00 
c010510d:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0105114:	e8 d0 b2 ff ff       	call   c01003e9 <__panic>

    p2 = p0 + 1;
c0105119:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010511c:	83 c0 14             	add    $0x14,%eax
c010511f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0105122:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105129:	00 
c010512a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010512d:	89 04 24             	mov    %eax,(%esp)
c0105130:	e8 7f da ff ff       	call   c0102bb4 <free_pages>
    free_pages(p1, 3);
c0105135:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010513c:	00 
c010513d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105140:	89 04 24             	mov    %eax,(%esp)
c0105143:	e8 6c da ff ff       	call   c0102bb4 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0105148:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010514b:	83 c0 04             	add    $0x4,%eax
c010514e:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0105155:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105158:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010515b:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010515e:	0f a3 10             	bt     %edx,(%eax)
c0105161:	19 c0                	sbb    %eax,%eax
c0105163:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105166:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010516a:	0f 95 c0             	setne  %al
c010516d:	0f b6 c0             	movzbl %al,%eax
c0105170:	85 c0                	test   %eax,%eax
c0105172:	74 0b                	je     c010517f <default_check+0x3c3>
c0105174:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105177:	8b 40 08             	mov    0x8(%eax),%eax
c010517a:	83 f8 01             	cmp    $0x1,%eax
c010517d:	74 24                	je     c01051a3 <default_check+0x3e7>
c010517f:	c7 44 24 0c bc 7e 10 	movl   $0xc0107ebc,0xc(%esp)
c0105186:	c0 
c0105187:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c010518e:	c0 
c010518f:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
c0105196:	00 
c0105197:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c010519e:	e8 46 b2 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01051a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051a6:	83 c0 04             	add    $0x4,%eax
c01051a9:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01051b0:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01051b3:	8b 45 90             	mov    -0x70(%ebp),%eax
c01051b6:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01051b9:	0f a3 10             	bt     %edx,(%eax)
c01051bc:	19 c0                	sbb    %eax,%eax
c01051be:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01051c1:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01051c5:	0f 95 c0             	setne  %al
c01051c8:	0f b6 c0             	movzbl %al,%eax
c01051cb:	85 c0                	test   %eax,%eax
c01051cd:	74 0b                	je     c01051da <default_check+0x41e>
c01051cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051d2:	8b 40 08             	mov    0x8(%eax),%eax
c01051d5:	83 f8 03             	cmp    $0x3,%eax
c01051d8:	74 24                	je     c01051fe <default_check+0x442>
c01051da:	c7 44 24 0c e4 7e 10 	movl   $0xc0107ee4,0xc(%esp)
c01051e1:	c0 
c01051e2:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c01051e9:	c0 
c01051ea:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
c01051f1:	00 
c01051f2:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c01051f9:	e8 eb b1 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01051fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105205:	e8 72 d9 ff ff       	call   c0102b7c <alloc_pages>
c010520a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010520d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105210:	83 e8 14             	sub    $0x14,%eax
c0105213:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105216:	74 24                	je     c010523c <default_check+0x480>
c0105218:	c7 44 24 0c 0a 7f 10 	movl   $0xc0107f0a,0xc(%esp)
c010521f:	c0 
c0105220:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0105227:	c0 
c0105228:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
c010522f:	00 
c0105230:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0105237:	e8 ad b1 ff ff       	call   c01003e9 <__panic>
    free_page(p0);
c010523c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105243:	00 
c0105244:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105247:	89 04 24             	mov    %eax,(%esp)
c010524a:	e8 65 d9 ff ff       	call   c0102bb4 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010524f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0105256:	e8 21 d9 ff ff       	call   c0102b7c <alloc_pages>
c010525b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010525e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105261:	83 c0 14             	add    $0x14,%eax
c0105264:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105267:	74 24                	je     c010528d <default_check+0x4d1>
c0105269:	c7 44 24 0c 28 7f 10 	movl   $0xc0107f28,0xc(%esp)
c0105270:	c0 
c0105271:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0105278:	c0 
c0105279:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
c0105280:	00 
c0105281:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0105288:	e8 5c b1 ff ff       	call   c01003e9 <__panic>

    free_pages(p0, 2);
c010528d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0105294:	00 
c0105295:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105298:	89 04 24             	mov    %eax,(%esp)
c010529b:	e8 14 d9 ff ff       	call   c0102bb4 <free_pages>
    free_page(p2);
c01052a0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052a7:	00 
c01052a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01052ab:	89 04 24             	mov    %eax,(%esp)
c01052ae:	e8 01 d9 ff ff       	call   c0102bb4 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01052b3:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01052ba:	e8 bd d8 ff ff       	call   c0102b7c <alloc_pages>
c01052bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01052c2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01052c6:	75 24                	jne    c01052ec <default_check+0x530>
c01052c8:	c7 44 24 0c 48 7f 10 	movl   $0xc0107f48,0xc(%esp)
c01052cf:	c0 
c01052d0:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c01052d7:	c0 
c01052d8:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c01052df:	00 
c01052e0:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c01052e7:	e8 fd b0 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c01052ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01052f3:	e8 84 d8 ff ff       	call   c0102b7c <alloc_pages>
c01052f8:	85 c0                	test   %eax,%eax
c01052fa:	74 24                	je     c0105320 <default_check+0x564>
c01052fc:	c7 44 24 0c a6 7d 10 	movl   $0xc0107da6,0xc(%esp)
c0105303:	c0 
c0105304:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c010530b:	c0 
c010530c:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c0105313:	00 
c0105314:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c010531b:	e8 c9 b0 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c0105320:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0105325:	85 c0                	test   %eax,%eax
c0105327:	74 24                	je     c010534d <default_check+0x591>
c0105329:	c7 44 24 0c f9 7d 10 	movl   $0xc0107df9,0xc(%esp)
c0105330:	c0 
c0105331:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0105338:	c0 
c0105339:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
c0105340:	00 
c0105341:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0105348:	e8 9c b0 ff ff       	call   c01003e9 <__panic>
    nr_free = nr_free_store;
c010534d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105350:	a3 28 df 11 c0       	mov    %eax,0xc011df28

    free_list = free_list_store;
c0105355:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105358:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010535b:	a3 20 df 11 c0       	mov    %eax,0xc011df20
c0105360:	89 15 24 df 11 c0    	mov    %edx,0xc011df24
    free_pages(p0, 5);
c0105366:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010536d:	00 
c010536e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105371:	89 04 24             	mov    %eax,(%esp)
c0105374:	e8 3b d8 ff ff       	call   c0102bb4 <free_pages>

    le = &free_list;
c0105379:	c7 45 ec 20 df 11 c0 	movl   $0xc011df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105380:	eb 5a                	jmp    c01053dc <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
c0105382:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105385:	8b 40 04             	mov    0x4(%eax),%eax
c0105388:	8b 00                	mov    (%eax),%eax
c010538a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010538d:	75 0d                	jne    c010539c <default_check+0x5e0>
c010538f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105392:	8b 00                	mov    (%eax),%eax
c0105394:	8b 40 04             	mov    0x4(%eax),%eax
c0105397:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010539a:	74 24                	je     c01053c0 <default_check+0x604>
c010539c:	c7 44 24 0c 68 7f 10 	movl   $0xc0107f68,0xc(%esp)
c01053a3:	c0 
c01053a4:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c01053ab:	c0 
c01053ac:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
c01053b3:	00 
c01053b4:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c01053bb:	e8 29 b0 ff ff       	call   c01003e9 <__panic>
        struct Page *p = le2page(le, page_link);
c01053c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053c3:	83 e8 0c             	sub    $0xc,%eax
c01053c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c01053c9:	ff 4d f4             	decl   -0xc(%ebp)
c01053cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01053cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01053d2:	8b 40 08             	mov    0x8(%eax),%eax
c01053d5:	29 c2                	sub    %eax,%edx
c01053d7:	89 d0                	mov    %edx,%eax
c01053d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01053dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053df:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c01053e2:	8b 45 88             	mov    -0x78(%ebp),%eax
c01053e5:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01053e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01053eb:	81 7d ec 20 df 11 c0 	cmpl   $0xc011df20,-0x14(%ebp)
c01053f2:	75 8e                	jne    c0105382 <default_check+0x5c6>
    }
    assert(count == 0);
c01053f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01053f8:	74 24                	je     c010541e <default_check+0x662>
c01053fa:	c7 44 24 0c 95 7f 10 	movl   $0xc0107f95,0xc(%esp)
c0105401:	c0 
c0105402:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0105409:	c0 
c010540a:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
c0105411:	00 
c0105412:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0105419:	e8 cb af ff ff       	call   c01003e9 <__panic>
    assert(total == 0);
c010541e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105422:	74 24                	je     c0105448 <default_check+0x68c>
c0105424:	c7 44 24 0c a0 7f 10 	movl   $0xc0107fa0,0xc(%esp)
c010542b:	c0 
c010542c:	c7 44 24 08 1e 7c 10 	movl   $0xc0107c1e,0x8(%esp)
c0105433:	c0 
c0105434:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
c010543b:	00 
c010543c:	c7 04 24 33 7c 10 c0 	movl   $0xc0107c33,(%esp)
c0105443:	e8 a1 af ff ff       	call   c01003e9 <__panic>
}
c0105448:	90                   	nop
c0105449:	c9                   	leave  
c010544a:	c3                   	ret    

c010544b <page2ppn>:
page2ppn(struct Page *page) {
c010544b:	55                   	push   %ebp
c010544c:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010544e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105451:	8b 15 18 df 11 c0    	mov    0xc011df18,%edx
c0105457:	29 d0                	sub    %edx,%eax
c0105459:	c1 f8 02             	sar    $0x2,%eax
c010545c:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0105462:	5d                   	pop    %ebp
c0105463:	c3                   	ret    

c0105464 <page2pa>:
page2pa(struct Page *page) {
c0105464:	55                   	push   %ebp
c0105465:	89 e5                	mov    %esp,%ebp
c0105467:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010546a:	8b 45 08             	mov    0x8(%ebp),%eax
c010546d:	89 04 24             	mov    %eax,(%esp)
c0105470:	e8 d6 ff ff ff       	call   c010544b <page2ppn>
c0105475:	c1 e0 0c             	shl    $0xc,%eax
}
c0105478:	c9                   	leave  
c0105479:	c3                   	ret    

c010547a <page_ref>:
page_ref(struct Page *page) {
c010547a:	55                   	push   %ebp
c010547b:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010547d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105480:	8b 00                	mov    (%eax),%eax
}
c0105482:	5d                   	pop    %ebp
c0105483:	c3                   	ret    

c0105484 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0105484:	55                   	push   %ebp
c0105485:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0105487:	8b 45 08             	mov    0x8(%ebp),%eax
c010548a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010548d:	89 10                	mov    %edx,(%eax)
}
c010548f:	90                   	nop
c0105490:	5d                   	pop    %ebp
c0105491:	c3                   	ret    

c0105492 <buddy_init>:

#define MAXLEVEL 12
free_area_t free_area[MAXLEVEL+1];

static void 
buddy_init(void){
c0105492:	55                   	push   %ebp
c0105493:	89 e5                	mov    %esp,%ebp
c0105495:	83 ec 10             	sub    $0x10,%esp
     for(int i=0;i<=MAXLEVEL;i++){
c0105498:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010549f:	eb 42                	jmp    c01054e3 <buddy_init+0x51>
	list_init(&free_area[i].free_list);
c01054a1:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01054a4:	89 d0                	mov    %edx,%eax
c01054a6:	01 c0                	add    %eax,%eax
c01054a8:	01 d0                	add    %edx,%eax
c01054aa:	c1 e0 02             	shl    $0x2,%eax
c01054ad:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01054b2:	89 45 f8             	mov    %eax,-0x8(%ebp)
    elm->prev = elm->next = elm;
c01054b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01054b8:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01054bb:	89 50 04             	mov    %edx,0x4(%eax)
c01054be:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01054c1:	8b 50 04             	mov    0x4(%eax),%edx
c01054c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01054c7:	89 10                	mov    %edx,(%eax)
	free_area[i].nr_free=0;
c01054c9:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01054cc:	89 d0                	mov    %edx,%eax
c01054ce:	01 c0                	add    %eax,%eax
c01054d0:	01 d0                	add    %edx,%eax
c01054d2:	c1 e0 02             	shl    $0x2,%eax
c01054d5:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01054da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     for(int i=0;i<=MAXLEVEL;i++){
c01054e0:	ff 45 fc             	incl   -0x4(%ebp)
c01054e3:	83 7d fc 0c          	cmpl   $0xc,-0x4(%ebp)
c01054e7:	7e b8                	jle    c01054a1 <buddy_init+0xf>
     }
}
c01054e9:	90                   	nop
c01054ea:	c9                   	leave  
c01054eb:	c3                   	ret    

c01054ec <buddy_nr_free_page>:

static size_t
buddy_nr_free_page(void){
c01054ec:	55                   	push   %ebp
c01054ed:	89 e5                	mov    %esp,%ebp
c01054ef:	83 ec 10             	sub    $0x10,%esp
    size_t nr=0;
c01054f2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
c01054f9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
c0105500:	eb 1c                	jmp    c010551e <buddy_nr_free_page+0x32>
	nr+=free_area[i].nr_free*(1<<MAXLEVEL);
c0105502:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105505:	89 d0                	mov    %edx,%eax
c0105507:	01 c0                	add    %eax,%eax
c0105509:	01 d0                	add    %edx,%eax
c010550b:	c1 e0 02             	shl    $0x2,%eax
c010550e:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105513:	8b 00                	mov    (%eax),%eax
c0105515:	c1 e0 0c             	shl    $0xc,%eax
c0105518:	01 45 fc             	add    %eax,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
c010551b:	ff 45 f8             	incl   -0x8(%ebp)
c010551e:	83 7d f8 0c          	cmpl   $0xc,-0x8(%ebp)
c0105522:	7e de                	jle    c0105502 <buddy_nr_free_page+0x16>
    }
    return nr; 
c0105524:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105527:	c9                   	leave  
c0105528:	c3                   	ret    

c0105529 <buddy_init_memmap>:

static void
buddy_init_memmap(struct Page* base,size_t n){
c0105529:	55                   	push   %ebp
c010552a:	89 e5                	mov    %esp,%ebp
c010552c:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
c010552f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105533:	75 24                	jne    c0105559 <buddy_init_memmap+0x30>
c0105535:	c7 44 24 0c dc 7f 10 	movl   $0xc0107fdc,0xc(%esp)
c010553c:	c0 
c010553d:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c0105544:	c0 
c0105545:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
c010554c:	00 
c010554d:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c0105554:	e8 90 ae ff ff       	call   c01003e9 <__panic>
     struct Page* p=base;
c0105559:	8b 45 08             	mov    0x8(%ebp),%eax
c010555c:	89 45 f4             	mov    %eax,-0xc(%ebp)
     for(;p!=base+n;p++){
c010555f:	eb 7d                	jmp    c01055de <buddy_init_memmap+0xb5>
	assert(PageReserved(p));
c0105561:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105564:	83 c0 04             	add    $0x4,%eax
c0105567:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c010556e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105571:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105574:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105577:	0f a3 10             	bt     %edx,(%eax)
c010557a:	19 c0                	sbb    %eax,%eax
c010557c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c010557f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105583:	0f 95 c0             	setne  %al
c0105586:	0f b6 c0             	movzbl %al,%eax
c0105589:	85 c0                	test   %eax,%eax
c010558b:	75 24                	jne    c01055b1 <buddy_init_memmap+0x88>
c010558d:	c7 44 24 0c 0c 80 10 	movl   $0xc010800c,0xc(%esp)
c0105594:	c0 
c0105595:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c010559c:	c0 
c010559d:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
c01055a4:	00 
c01055a5:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c01055ac:	e8 38 ae ff ff       	call   c01003e9 <__panic>
	p->flags=p->property=0;
c01055b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055b4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01055bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055be:	8b 50 08             	mov    0x8(%eax),%edx
c01055c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055c4:	89 50 04             	mov    %edx,0x4(%eax)
	set_page_ref(p,0);
c01055c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01055ce:	00 
c01055cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055d2:	89 04 24             	mov    %eax,(%esp)
c01055d5:	e8 aa fe ff ff       	call   c0105484 <set_page_ref>
     for(;p!=base+n;p++){
c01055da:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01055de:	8b 55 0c             	mov    0xc(%ebp),%edx
c01055e1:	89 d0                	mov    %edx,%eax
c01055e3:	c1 e0 02             	shl    $0x2,%eax
c01055e6:	01 d0                	add    %edx,%eax
c01055e8:	c1 e0 02             	shl    $0x2,%eax
c01055eb:	89 c2                	mov    %eax,%edx
c01055ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f0:	01 d0                	add    %edx,%eax
c01055f2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01055f5:	0f 85 66 ff ff ff    	jne    c0105561 <buddy_init_memmap+0x38>
     }
     p=base;
c01055fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01055fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
     size_t temp=n;
c0105601:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105604:	89 45 f0             	mov    %eax,-0x10(%ebp)
     int level=MAXLEVEL;
c0105607:	c7 45 ec 0c 00 00 00 	movl   $0xc,-0x14(%ebp)
     while(level>=0){
c010560e:	e9 fd 00 00 00       	jmp    c0105710 <buddy_init_memmap+0x1e7>
	for(int i=0;i<temp/(1<<level);i++){
c0105613:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010561a:	e9 c7 00 00 00       	jmp    c01056e6 <buddy_init_memmap+0x1bd>
	    struct Page* page=p;
c010561f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105622:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	    page->property=1<<level;
c0105625:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105628:	ba 01 00 00 00       	mov    $0x1,%edx
c010562d:	88 c1                	mov    %al,%cl
c010562f:	d3 e2                	shl    %cl,%edx
c0105631:	89 d0                	mov    %edx,%eax
c0105633:	89 c2                	mov    %eax,%edx
c0105635:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105638:	89 50 08             	mov    %edx,0x8(%eax)
	    SetPageProperty(p);
c010563b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010563e:	83 c0 04             	add    $0x4,%eax
c0105641:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0105648:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010564b:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010564e:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105651:	0f ab 10             	bts    %edx,(%eax)
	    list_add_before(&free_area[level].free_list,&(page->page_link));
c0105654:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105657:	8d 48 0c             	lea    0xc(%eax),%ecx
c010565a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010565d:	89 d0                	mov    %edx,%eax
c010565f:	01 c0                	add    %eax,%eax
c0105661:	01 d0                	add    %edx,%eax
c0105663:	c1 e0 02             	shl    $0x2,%eax
c0105666:	05 20 df 11 c0       	add    $0xc011df20,%eax
c010566b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010566e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0105671:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105674:	8b 00                	mov    (%eax),%eax
c0105676:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105679:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010567c:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010567f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105682:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
c0105685:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105688:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010568b:	89 10                	mov    %edx,(%eax)
c010568d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105690:	8b 10                	mov    (%eax),%edx
c0105692:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105695:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105698:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010569b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010569e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01056a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01056a4:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01056a7:	89 10                	mov    %edx,(%eax)
	    p+=(1<<level);
c01056a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056ac:	ba 14 00 00 00       	mov    $0x14,%edx
c01056b1:	88 c1                	mov    %al,%cl
c01056b3:	d3 e2                	shl    %cl,%edx
c01056b5:	89 d0                	mov    %edx,%eax
c01056b7:	01 45 f4             	add    %eax,-0xc(%ebp)
	    free_area[level].nr_free++;
c01056ba:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01056bd:	89 d0                	mov    %edx,%eax
c01056bf:	01 c0                	add    %eax,%eax
c01056c1:	01 d0                	add    %edx,%eax
c01056c3:	c1 e0 02             	shl    $0x2,%eax
c01056c6:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01056cb:	8b 00                	mov    (%eax),%eax
c01056cd:	8d 48 01             	lea    0x1(%eax),%ecx
c01056d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01056d3:	89 d0                	mov    %edx,%eax
c01056d5:	01 c0                	add    %eax,%eax
c01056d7:	01 d0                	add    %edx,%eax
c01056d9:	c1 e0 02             	shl    $0x2,%eax
c01056dc:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01056e1:	89 08                	mov    %ecx,(%eax)
	for(int i=0;i<temp/(1<<level);i++){
c01056e3:	ff 45 e8             	incl   -0x18(%ebp)
c01056e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01056ec:	88 c1                	mov    %al,%cl
c01056ee:	d3 ea                	shr    %cl,%edx
c01056f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01056f3:	39 c2                	cmp    %eax,%edx
c01056f5:	0f 87 24 ff ff ff    	ja     c010561f <buddy_init_memmap+0xf6>
	}
	temp = temp % (1 << level);
c01056fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056fe:	ba 01 00 00 00       	mov    $0x1,%edx
c0105703:	88 c1                	mov    %al,%cl
c0105705:	d3 e2                	shl    %cl,%edx
c0105707:	89 d0                	mov    %edx,%eax
c0105709:	48                   	dec    %eax
c010570a:	21 45 f0             	and    %eax,-0x10(%ebp)
	level--;
c010570d:	ff 4d ec             	decl   -0x14(%ebp)
     while(level>=0){
c0105710:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105714:	0f 89 f9 fe ff ff    	jns    c0105613 <buddy_init_memmap+0xea>
     }
}
c010571a:	90                   	nop
c010571b:	c9                   	leave  
c010571c:	c3                   	ret    

c010571d <buddy_my_partial>:

static void
buddy_my_partial(struct Page *base, size_t n, int level) {
c010571d:	55                   	push   %ebp
c010571e:	89 e5                	mov    %esp,%ebp
c0105720:	83 ec 78             	sub    $0x78,%esp
    if (level < 0) return;
c0105723:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105727:	0f 88 20 02 00 00    	js     c010594d <buddy_my_partial+0x230>
    size_t temp = n;
c010572d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105730:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (level >= 0) {
c0105733:	e9 7a 01 00 00       	jmp    c01058b2 <buddy_my_partial+0x195>
        for (int i = 0; i < temp / (1 << level); i++) {
c0105738:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010573f:	e9 44 01 00 00       	jmp    c0105888 <buddy_my_partial+0x16b>
            base->property = (1 << level);
c0105744:	8b 45 10             	mov    0x10(%ebp),%eax
c0105747:	ba 01 00 00 00       	mov    $0x1,%edx
c010574c:	88 c1                	mov    %al,%cl
c010574e:	d3 e2                	shl    %cl,%edx
c0105750:	89 d0                	mov    %edx,%eax
c0105752:	89 c2                	mov    %eax,%edx
c0105754:	8b 45 08             	mov    0x8(%ebp),%eax
c0105757:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(base);
c010575a:	8b 45 08             	mov    0x8(%ebp),%eax
c010575d:	83 c0 04             	add    $0x4,%eax
c0105760:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0105767:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010576a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010576d:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105770:	0f ab 10             	bts    %edx,(%eax)
            // add pages in order
            struct Page* p = NULL;
c0105773:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
            list_entry_t* le = list_next(&(free_area[level].free_list));
c010577a:	8b 55 10             	mov    0x10(%ebp),%edx
c010577d:	89 d0                	mov    %edx,%eax
c010577f:	01 c0                	add    %eax,%eax
c0105781:	01 d0                	add    %edx,%eax
c0105783:	c1 e0 02             	shl    $0x2,%eax
c0105786:	05 20 df 11 c0       	add    $0xc011df20,%eax
c010578b:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return listelm->next;
c010578e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105791:	8b 40 04             	mov    0x4(%eax),%eax
c0105794:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105797:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010579a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return listelm->prev;
c010579d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01057a0:	8b 00                	mov    (%eax),%eax
            list_entry_t* bfle = list_prev(le);
c01057a2:	89 45 e8             	mov    %eax,-0x18(%ebp)
            while (le != &(free_area[level].free_list)) {
c01057a5:	eb 37                	jmp    c01057de <buddy_my_partial+0xc1>
                p = le2page(le, page_link);
c01057a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057aa:	83 e8 0c             	sub    $0xc,%eax
c01057ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
                if (base + base->property < le) break;
c01057b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01057b3:	8b 50 08             	mov    0x8(%eax),%edx
c01057b6:	89 d0                	mov    %edx,%eax
c01057b8:	c1 e0 02             	shl    $0x2,%eax
c01057bb:	01 d0                	add    %edx,%eax
c01057bd:	c1 e0 02             	shl    $0x2,%eax
c01057c0:	89 c2                	mov    %eax,%edx
c01057c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01057c5:	01 d0                	add    %edx,%eax
c01057c7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01057ca:	77 2a                	ja     c01057f6 <buddy_my_partial+0xd9>
                bfle = bfle->next;
c01057cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057cf:	8b 40 04             	mov    0x4(%eax),%eax
c01057d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
                le = le->next;
c01057d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057d8:	8b 40 04             	mov    0x4(%eax),%eax
c01057db:	89 45 ec             	mov    %eax,-0x14(%ebp)
            while (le != &(free_area[level].free_list)) {
c01057de:	8b 55 10             	mov    0x10(%ebp),%edx
c01057e1:	89 d0                	mov    %edx,%eax
c01057e3:	01 c0                	add    %eax,%eax
c01057e5:	01 d0                	add    %edx,%eax
c01057e7:	c1 e0 02             	shl    $0x2,%eax
c01057ea:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01057ef:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01057f2:	75 b3                	jne    c01057a7 <buddy_my_partial+0x8a>
c01057f4:	eb 01                	jmp    c01057f7 <buddy_my_partial+0xda>
                if (base + base->property < le) break;
c01057f6:	90                   	nop
            }
            list_add(bfle, &(base->page_link));
c01057f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01057fa:	8d 50 0c             	lea    0xc(%eax),%edx
c01057fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105800:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0105803:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0105806:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105809:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010580c:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010580f:	89 45 b8             	mov    %eax,-0x48(%ebp)
    __list_add(elm, listelm, listelm->next);
c0105812:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105815:	8b 40 04             	mov    0x4(%eax),%eax
c0105818:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010581b:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c010581e:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0105821:	89 55 b0             	mov    %edx,-0x50(%ebp)
c0105824:	89 45 ac             	mov    %eax,-0x54(%ebp)
    prev->next = next->prev = elm;
c0105827:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010582a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010582d:	89 10                	mov    %edx,(%eax)
c010582f:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105832:	8b 10                	mov    (%eax),%edx
c0105834:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105837:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010583a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010583d:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0105840:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105843:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105846:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0105849:	89 10                	mov    %edx,(%eax)
            base += (1 << level);
c010584b:	8b 45 10             	mov    0x10(%ebp),%eax
c010584e:	ba 14 00 00 00       	mov    $0x14,%edx
c0105853:	88 c1                	mov    %al,%cl
c0105855:	d3 e2                	shl    %cl,%edx
c0105857:	89 d0                	mov    %edx,%eax
c0105859:	01 45 08             	add    %eax,0x8(%ebp)
            free_area[level].nr_free++;
c010585c:	8b 55 10             	mov    0x10(%ebp),%edx
c010585f:	89 d0                	mov    %edx,%eax
c0105861:	01 c0                	add    %eax,%eax
c0105863:	01 d0                	add    %edx,%eax
c0105865:	c1 e0 02             	shl    $0x2,%eax
c0105868:	05 28 df 11 c0       	add    $0xc011df28,%eax
c010586d:	8b 00                	mov    (%eax),%eax
c010586f:	8d 48 01             	lea    0x1(%eax),%ecx
c0105872:	8b 55 10             	mov    0x10(%ebp),%edx
c0105875:	89 d0                	mov    %edx,%eax
c0105877:	01 c0                	add    %eax,%eax
c0105879:	01 d0                	add    %edx,%eax
c010587b:	c1 e0 02             	shl    $0x2,%eax
c010587e:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105883:	89 08                	mov    %ecx,(%eax)
        for (int i = 0; i < temp / (1 << level); i++) {
c0105885:	ff 45 f0             	incl   -0x10(%ebp)
c0105888:	8b 45 10             	mov    0x10(%ebp),%eax
c010588b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010588e:	88 c1                	mov    %al,%cl
c0105890:	d3 ea                	shr    %cl,%edx
c0105892:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105895:	39 c2                	cmp    %eax,%edx
c0105897:	0f 87 a7 fe ff ff    	ja     c0105744 <buddy_my_partial+0x27>
        }
        temp = temp % (1 << level);
c010589d:	8b 45 10             	mov    0x10(%ebp),%eax
c01058a0:	ba 01 00 00 00       	mov    $0x1,%edx
c01058a5:	88 c1                	mov    %al,%cl
c01058a7:	d3 e2                	shl    %cl,%edx
c01058a9:	89 d0                	mov    %edx,%eax
c01058ab:	48                   	dec    %eax
c01058ac:	21 45 f4             	and    %eax,-0xc(%ebp)
        level--;
c01058af:	ff 4d 10             	decl   0x10(%ebp)
    while (level >= 0) {
c01058b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01058b6:	0f 89 7c fe ff ff    	jns    c0105738 <buddy_my_partial+0x1b>
    }
    cprintf("alloc_page check: \n");
c01058bc:	c7 04 24 1c 80 10 c0 	movl   $0xc010801c,(%esp)
c01058c3:	e8 ca a9 ff ff       	call   c0100292 <cprintf>
    for (int i = MAXLEVEL; i >= 0; i--) {
c01058c8:	c7 45 e4 0c 00 00 00 	movl   $0xc,-0x1c(%ebp)
c01058cf:	eb 74                	jmp    c0105945 <buddy_my_partial+0x228>
        list_entry_t* le = list_next(&(free_area[i].free_list));
c01058d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01058d4:	89 d0                	mov    %edx,%eax
c01058d6:	01 c0                	add    %eax,%eax
c01058d8:	01 d0                	add    %edx,%eax
c01058da:	c1 e0 02             	shl    $0x2,%eax
c01058dd:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01058e2:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return listelm->next;
c01058e5:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01058e8:	8b 40 04             	mov    0x4(%eax),%eax
c01058eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
c01058ee:	eb 3c                	jmp    c010592c <buddy_my_partial+0x20f>
            struct Page* page = le2page(le, page_link);
c01058f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058f3:	83 e8 0c             	sub    $0xc,%eax
c01058f6:	89 45 dc             	mov    %eax,-0x24(%ebp)
            cprintf("%d - %llx\n", i, page->page_link);
c01058f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01058fc:	8b 50 10             	mov    0x10(%eax),%edx
c01058ff:	8b 40 0c             	mov    0xc(%eax),%eax
c0105902:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105906:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010590a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010590d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105911:	c7 04 24 30 80 10 c0 	movl   $0xc0108030,(%esp)
c0105918:	e8 75 a9 ff ff       	call   c0100292 <cprintf>
c010591d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105920:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0105923:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105926:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
c0105929:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
c010592c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010592f:	89 d0                	mov    %edx,%eax
c0105931:	01 c0                	add    %eax,%eax
c0105933:	01 d0                	add    %edx,%eax
c0105935:	c1 e0 02             	shl    $0x2,%eax
c0105938:	05 20 df 11 c0       	add    $0xc011df20,%eax
c010593d:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105940:	75 ae                	jne    c01058f0 <buddy_my_partial+0x1d3>
    for (int i = MAXLEVEL; i >= 0; i--) {
c0105942:	ff 4d e4             	decl   -0x1c(%ebp)
c0105945:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105949:	79 86                	jns    c01058d1 <buddy_my_partial+0x1b4>
c010594b:	eb 01                	jmp    c010594e <buddy_my_partial+0x231>
    if (level < 0) return;
c010594d:	90                   	nop
        }
    }
}
c010594e:	c9                   	leave  
c010594f:	c3                   	ret    

c0105950 <buddy_my_merge>:

static void
buddy_my_merge(int level) {
c0105950:	55                   	push   %ebp
c0105951:	89 e5                	mov    %esp,%ebp
c0105953:	83 ec 68             	sub    $0x68,%esp
    cprintf("before merge.\n");
c0105956:	c7 04 24 3b 80 10 c0 	movl   $0xc010803b,(%esp)
c010595d:	e8 30 a9 ff ff       	call   c0100292 <cprintf>
    //bds_selfcheck();
    while (level < MAXLEVEL) {
c0105962:	e9 dc 01 00 00       	jmp    c0105b43 <buddy_my_merge+0x1f3>
        if (free_area[level].nr_free <= 1) {
c0105967:	8b 55 08             	mov    0x8(%ebp),%edx
c010596a:	89 d0                	mov    %edx,%eax
c010596c:	01 c0                	add    %eax,%eax
c010596e:	01 d0                	add    %edx,%eax
c0105970:	c1 e0 02             	shl    $0x2,%eax
c0105973:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105978:	8b 00                	mov    (%eax),%eax
c010597a:	83 f8 01             	cmp    $0x1,%eax
c010597d:	77 08                	ja     c0105987 <buddy_my_merge+0x37>
            level++;
c010597f:	ff 45 08             	incl   0x8(%ebp)
            continue;
c0105982:	e9 bc 01 00 00       	jmp    c0105b43 <buddy_my_merge+0x1f3>
        }
        list_entry_t* le = list_next(&(free_area[level].free_list));
c0105987:	8b 55 08             	mov    0x8(%ebp),%edx
c010598a:	89 d0                	mov    %edx,%eax
c010598c:	01 c0                	add    %eax,%eax
c010598e:	01 d0                	add    %edx,%eax
c0105990:	c1 e0 02             	shl    $0x2,%eax
c0105993:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105998:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010599b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010599e:	8b 40 04             	mov    0x4(%eax),%eax
c01059a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->prev;
c01059aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01059ad:	8b 00                	mov    (%eax),%eax
        list_entry_t* bfle = list_prev(le);
c01059af:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while (le != &(free_area[level].free_list)) {
c01059b2:	e9 6f 01 00 00       	jmp    c0105b26 <buddy_my_merge+0x1d6>
c01059b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return listelm->next;
c01059bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01059c0:	8b 40 04             	mov    0x4(%eax),%eax
            bfle = list_next(bfle);
c01059c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01059cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01059cf:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
c01059d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
            struct Page* ple = le2page(le, page_link);
c01059d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059d8:	83 e8 0c             	sub    $0xc,%eax
c01059db:	89 45 ec             	mov    %eax,-0x14(%ebp)
            struct Page* pbf = le2page(bfle, page_link); 
c01059de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059e1:	83 e8 0c             	sub    $0xc,%eax
c01059e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
            cprintf("bfle addr is: %llx\n", pbf->page_link);
c01059e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059ea:	8b 50 10             	mov    0x10(%eax),%edx
c01059ed:	8b 40 0c             	mov    0xc(%eax),%eax
c01059f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059f4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01059f8:	c7 04 24 4a 80 10 c0 	movl   $0xc010804a,(%esp)
c01059ff:	e8 8e a8 ff ff       	call   c0100292 <cprintf>
            cprintf("le addr is: %llx\n", ple->page_link);
c0105a04:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a07:	8b 50 10             	mov    0x10(%eax),%edx
c0105a0a:	8b 40 0c             	mov    0xc(%eax),%eax
c0105a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a11:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105a15:	c7 04 24 5e 80 10 c0 	movl   $0xc010805e,(%esp)
c0105a1c:	e8 71 a8 ff ff       	call   c0100292 <cprintf>
            if (pbf + pbf->property == ple) {            
c0105a21:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a24:	8b 50 08             	mov    0x8(%eax),%edx
c0105a27:	89 d0                	mov    %edx,%eax
c0105a29:	c1 e0 02             	shl    $0x2,%eax
c0105a2c:	01 d0                	add    %edx,%eax
c0105a2e:	c1 e0 02             	shl    $0x2,%eax
c0105a31:	89 c2                	mov    %eax,%edx
c0105a33:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a36:	01 d0                	add    %edx,%eax
c0105a38:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105a3b:	0f 85 e5 00 00 00    	jne    c0105b26 <buddy_my_merge+0x1d6>
c0105a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a44:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0105a47:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105a4a:	8b 40 04             	mov    0x4(%eax),%eax
                bfle = list_next(bfle);
c0105a4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a53:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0105a56:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105a59:	8b 40 04             	mov    0x4(%eax),%eax
                le = list_next(le);
c0105a5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
                pbf->property = pbf->property << 1;
c0105a5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a62:	8b 40 08             	mov    0x8(%eax),%eax
c0105a65:	8d 14 00             	lea    (%eax,%eax,1),%edx
c0105a68:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a6b:	89 50 08             	mov    %edx,0x8(%eax)
                ClearPageProperty(ple);
c0105a6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a71:	83 c0 04             	add    $0x4,%eax
c0105a74:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0105a7b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105a7e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105a81:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0105a84:	0f b3 10             	btr    %edx,(%eax)
                list_del(&(pbf->page_link));
c0105a87:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a8a:	83 c0 0c             	add    $0xc,%eax
c0105a8d:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105a90:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105a93:	8b 40 04             	mov    0x4(%eax),%eax
c0105a96:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105a99:	8b 12                	mov    (%edx),%edx
c0105a9b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c0105a9e:	89 45 c0             	mov    %eax,-0x40(%ebp)
    prev->next = next;
c0105aa1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105aa4:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105aa7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105aaa:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105aad:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105ab0:	89 10                	mov    %edx,(%eax)
                list_del(&(ple->page_link));
c0105ab2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ab5:	83 c0 0c             	add    $0xc,%eax
c0105ab8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105abb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105abe:	8b 40 04             	mov    0x4(%eax),%eax
c0105ac1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105ac4:	8b 12                	mov    (%edx),%edx
c0105ac6:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0105ac9:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next;
c0105acc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105acf:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105ad2:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105ad5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105ad8:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105adb:	89 10                	mov    %edx,(%eax)
                buddy_my_partial(pbf, pbf->property, level + 1);             
c0105add:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ae0:	8d 50 01             	lea    0x1(%eax),%edx
c0105ae3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ae6:	8b 40 08             	mov    0x8(%eax),%eax
c0105ae9:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105aed:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105af1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105af4:	89 04 24             	mov    %eax,(%esp)
c0105af7:	e8 21 fc ff ff       	call   c010571d <buddy_my_partial>
                free_area[level].nr_free -= 2;              
c0105afc:	8b 55 08             	mov    0x8(%ebp),%edx
c0105aff:	89 d0                	mov    %edx,%eax
c0105b01:	01 c0                	add    %eax,%eax
c0105b03:	01 d0                	add    %edx,%eax
c0105b05:	c1 e0 02             	shl    $0x2,%eax
c0105b08:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105b0d:	8b 00                	mov    (%eax),%eax
c0105b0f:	8d 48 fe             	lea    -0x2(%eax),%ecx
c0105b12:	8b 55 08             	mov    0x8(%ebp),%edx
c0105b15:	89 d0                	mov    %edx,%eax
c0105b17:	01 c0                	add    %eax,%eax
c0105b19:	01 d0                	add    %edx,%eax
c0105b1b:	c1 e0 02             	shl    $0x2,%eax
c0105b1e:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105b23:	89 08                	mov    %ecx,(%eax)
                continue;
c0105b25:	90                   	nop
        while (le != &(free_area[level].free_list)) {
c0105b26:	8b 55 08             	mov    0x8(%ebp),%edx
c0105b29:	89 d0                	mov    %edx,%eax
c0105b2b:	01 c0                	add    %eax,%eax
c0105b2d:	01 d0                	add    %edx,%eax
c0105b2f:	c1 e0 02             	shl    $0x2,%eax
c0105b32:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105b37:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105b3a:	0f 85 77 fe ff ff    	jne    c01059b7 <buddy_my_merge+0x67>
            } 
        }
        level++;
c0105b40:	ff 45 08             	incl   0x8(%ebp)
    while (level < MAXLEVEL) {
c0105b43:	83 7d 08 0b          	cmpl   $0xb,0x8(%ebp)
c0105b47:	0f 8e 1a fe ff ff    	jle    c0105967 <buddy_my_merge+0x17>
    }
    //bds_selfcheck();
}
c0105b4d:	90                   	nop
c0105b4e:	c9                   	leave  
c0105b4f:	c3                   	ret    

c0105b50 <buddy_alloc_page>:

static struct Page*
buddy_alloc_page(size_t n){
c0105b50:	55                   	push   %ebp
c0105b51:	89 e5                	mov    %esp,%ebp
c0105b53:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
c0105b56:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105b5a:	75 24                	jne    c0105b80 <buddy_alloc_page+0x30>
c0105b5c:	c7 44 24 0c dc 7f 10 	movl   $0xc0107fdc,0xc(%esp)
c0105b63:	c0 
c0105b64:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c0105b6b:	c0 
c0105b6c:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0105b73:	00 
c0105b74:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c0105b7b:	e8 69 a8 ff ff       	call   c01003e9 <__panic>
     if(n>buddy_nr_free_page()){
c0105b80:	e8 67 f9 ff ff       	call   c01054ec <buddy_nr_free_page>
c0105b85:	39 45 08             	cmp    %eax,0x8(%ebp)
c0105b88:	76 0a                	jbe    c0105b94 <buddy_alloc_page+0x44>
	return NULL;
c0105b8a:	b8 00 00 00 00       	mov    $0x0,%eax
c0105b8f:	e9 62 01 00 00       	jmp    c0105cf6 <buddy_alloc_page+0x1a6>
     }
     int level=0;
c0105b94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     while((1<<level)<n){
c0105b9b:	eb 03                	jmp    c0105ba0 <buddy_alloc_page+0x50>
	level++;
c0105b9d:	ff 45 f4             	incl   -0xc(%ebp)
     while((1<<level)<n){
c0105ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ba3:	ba 01 00 00 00       	mov    $0x1,%edx
c0105ba8:	88 c1                	mov    %al,%cl
c0105baa:	d3 e2                	shl    %cl,%edx
c0105bac:	89 d0                	mov    %edx,%eax
c0105bae:	39 45 08             	cmp    %eax,0x8(%ebp)
c0105bb1:	77 ea                	ja     c0105b9d <buddy_alloc_page+0x4d>
     }
     //n=1<<level;
     for(int i=level;i<=MAXLEVEL;i++){
c0105bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105bb9:	eb 22                	jmp    c0105bdd <buddy_alloc_page+0x8d>
	if(free_area[i].nr_free!=0){
c0105bbb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105bbe:	89 d0                	mov    %edx,%eax
c0105bc0:	01 c0                	add    %eax,%eax
c0105bc2:	01 d0                	add    %edx,%eax
c0105bc4:	c1 e0 02             	shl    $0x2,%eax
c0105bc7:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105bcc:	8b 00                	mov    (%eax),%eax
c0105bce:	85 c0                	test   %eax,%eax
c0105bd0:	74 08                	je     c0105bda <buddy_alloc_page+0x8a>
	   level=i;
c0105bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    break;
c0105bd8:	eb 09                	jmp    c0105be3 <buddy_alloc_page+0x93>
     for(int i=level;i<=MAXLEVEL;i++){
c0105bda:	ff 45 f0             	incl   -0x10(%ebp)
c0105bdd:	83 7d f0 0c          	cmpl   $0xc,-0x10(%ebp)
c0105be1:	7e d8                	jle    c0105bbb <buddy_alloc_page+0x6b>
	}
     }
     if(level>MAXLEVEL){return NULL;}
c0105be3:	83 7d f4 0c          	cmpl   $0xc,-0xc(%ebp)
c0105be7:	7e 0a                	jle    c0105bf3 <buddy_alloc_page+0xa3>
c0105be9:	b8 00 00 00 00       	mov    $0x0,%eax
c0105bee:	e9 03 01 00 00       	jmp    c0105cf6 <buddy_alloc_page+0x1a6>
     list_entry_t *le=&free_area[level].free_list;
c0105bf3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105bf6:	89 d0                	mov    %edx,%eax
c0105bf8:	01 c0                	add    %eax,%eax
c0105bfa:	01 d0                	add    %edx,%eax
c0105bfc:	c1 e0 02             	shl    $0x2,%eax
c0105bff:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105c04:	89 45 ec             	mov    %eax,-0x14(%ebp)
     struct Page* page=le2page(le,page_link);
c0105c07:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c0a:	83 e8 0c             	sub    $0xc,%eax
c0105c0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
     if (page != NULL) {
c0105c10:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105c14:	0f 84 cd 00 00 00    	je     c0105ce7 <buddy_alloc_page+0x197>
        SetPageReserved(page);
c0105c1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c1d:	83 c0 04             	add    $0x4,%eax
c0105c20:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
c0105c27:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105c2a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105c2d:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105c30:	0f ab 10             	bts    %edx,(%eax)
        // deal with partial work
        buddy_my_partial(page, page->property - n, level - 1);
c0105c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c36:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105c39:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c3c:	8b 40 08             	mov    0x8(%eax),%eax
c0105c3f:	2b 45 08             	sub    0x8(%ebp),%eax
c0105c42:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105c46:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c4d:	89 04 24             	mov    %eax,(%esp)
c0105c50:	e8 c8 fa ff ff       	call   c010571d <buddy_my_partial>
        ClearPageReserved(page);
c0105c55:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c58:	83 c0 04             	add    $0x4,%eax
c0105c5b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
c0105c62:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105c65:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105c68:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105c6b:	0f b3 10             	btr    %edx,(%eax)
        ClearPageProperty(page);
c0105c6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c71:	83 c0 04             	add    $0x4,%eax
c0105c74:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
c0105c7b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105c7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105c81:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105c84:	0f b3 10             	btr    %edx,(%eax)
        list_del(&(page->page_link));
c0105c87:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c8a:	83 c0 0c             	add    $0xc,%eax
c0105c8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105c90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c93:	8b 40 04             	mov    0x4(%eax),%eax
c0105c96:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105c99:	8b 12                	mov    (%edx),%edx
c0105c9b:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0105c9e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c0105ca1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ca4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105ca7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105caa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105cad:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105cb0:	89 10                	mov    %edx,(%eax)
        free_area[level].nr_free--;
c0105cb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105cb5:	89 d0                	mov    %edx,%eax
c0105cb7:	01 c0                	add    %eax,%eax
c0105cb9:	01 d0                	add    %edx,%eax
c0105cbb:	c1 e0 02             	shl    $0x2,%eax
c0105cbe:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105cc3:	8b 00                	mov    (%eax),%eax
c0105cc5:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105cc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ccb:	89 d0                	mov    %edx,%eax
c0105ccd:	01 c0                	add    %eax,%eax
c0105ccf:	01 d0                	add    %edx,%eax
c0105cd1:	c1 e0 02             	shl    $0x2,%eax
c0105cd4:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105cd9:	89 08                	mov    %ecx,(%eax)
        buddy_my_merge(0);
c0105cdb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105ce2:	e8 69 fc ff ff       	call   c0105950 <buddy_my_merge>
    }
    cprintf("after allocate & merge\n");
c0105ce7:	c7 04 24 70 80 10 c0 	movl   $0xc0108070,(%esp)
c0105cee:	e8 9f a5 ff ff       	call   c0100292 <cprintf>
    //bds_selfcheck();
    return page;
c0105cf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
c0105cf6:	c9                   	leave  
c0105cf7:	c3                   	ret    

c0105cf8 <buddy_free_page>:

static void 
buddy_free_page(struct Page* base, size_t n){
c0105cf8:	55                   	push   %ebp
c0105cf9:	89 e5                	mov    %esp,%ebp
c0105cfb:	83 ec 48             	sub    $0x48,%esp
     assert(n > 0);
c0105cfe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105d02:	75 24                	jne    c0105d28 <buddy_free_page+0x30>
c0105d04:	c7 44 24 0c 88 80 10 	movl   $0xc0108088,0xc(%esp)
c0105d0b:	c0 
c0105d0c:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c0105d13:	c0 
c0105d14:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0105d1b:	00 
c0105d1c:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c0105d23:	e8 c1 a6 ff ff       	call   c01003e9 <__panic>
    struct Page* p = base;
c0105d28:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++) {
c0105d2e:	e9 9d 00 00 00       	jmp    c0105dd0 <buddy_free_page+0xd8>
        assert(!PageReserved(p) && !PageProperty(p));
c0105d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d36:	83 c0 04             	add    $0x4,%eax
c0105d39:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105d40:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105d43:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d46:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105d49:	0f a3 10             	bt     %edx,(%eax)
c0105d4c:	19 c0                	sbb    %eax,%eax
c0105d4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0105d51:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105d55:	0f 95 c0             	setne  %al
c0105d58:	0f b6 c0             	movzbl %al,%eax
c0105d5b:	85 c0                	test   %eax,%eax
c0105d5d:	75 2c                	jne    c0105d8b <buddy_free_page+0x93>
c0105d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d62:	83 c0 04             	add    $0x4,%eax
c0105d65:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0105d6c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105d6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105d72:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105d75:	0f a3 10             	bt     %edx,(%eax)
c0105d78:	19 c0                	sbb    %eax,%eax
c0105d7a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0105d7d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105d81:	0f 95 c0             	setne  %al
c0105d84:	0f b6 c0             	movzbl %al,%eax
c0105d87:	85 c0                	test   %eax,%eax
c0105d89:	74 24                	je     c0105daf <buddy_free_page+0xb7>
c0105d8b:	c7 44 24 0c 90 80 10 	movl   $0xc0108090,0xc(%esp)
c0105d92:	c0 
c0105d93:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c0105d9a:	c0 
c0105d9b:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
c0105da2:	00 
c0105da3:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c0105daa:	e8 3a a6 ff ff       	call   c01003e9 <__panic>
        p->flags = 0;
c0105daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105db2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0105db9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105dc0:	00 
c0105dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dc4:	89 04 24             	mov    %eax,(%esp)
c0105dc7:	e8 b8 f6 ff ff       	call   c0105484 <set_page_ref>
    for (; p != base + n; p++) {
c0105dcc:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0105dd0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105dd3:	89 d0                	mov    %edx,%eax
c0105dd5:	c1 e0 02             	shl    $0x2,%eax
c0105dd8:	01 d0                	add    %edx,%eax
c0105dda:	c1 e0 02             	shl    $0x2,%eax
c0105ddd:	89 c2                	mov    %eax,%edx
c0105ddf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105de2:	01 d0                	add    %edx,%eax
c0105de4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105de7:	0f 85 46 ff ff ff    	jne    c0105d33 <buddy_free_page+0x3b>
    }
    // free pages
    base->property = n;
c0105ded:	8b 45 08             	mov    0x8(%ebp),%eax
c0105df0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105df3:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0105df6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105df9:	83 c0 04             	add    $0x4,%eax
c0105dfc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0105e03:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105e06:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105e09:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105e0c:	0f ab 10             	bts    %edx,(%eax)
    int level = 0;
c0105e0f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    while ((1 << level) != n) { level++; }
c0105e16:	eb 03                	jmp    c0105e1b <buddy_free_page+0x123>
c0105e18:	ff 45 f0             	incl   -0x10(%ebp)
c0105e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e1e:	ba 01 00 00 00       	mov    $0x1,%edx
c0105e23:	88 c1                	mov    %al,%cl
c0105e25:	d3 e2                	shl    %cl,%edx
c0105e27:	89 d0                	mov    %edx,%eax
c0105e29:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0105e2c:	75 ea                	jne    c0105e18 <buddy_free_page+0x120>
    buddy_my_partial(base, n, level);
c0105e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e31:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e35:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e38:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e3f:	89 04 24             	mov    %eax,(%esp)
c0105e42:	e8 d6 f8 ff ff       	call   c010571d <buddy_my_partial>
    //bds_selfcheck();
    free_area[level].nr_free++;
c0105e47:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105e4a:	89 d0                	mov    %edx,%eax
c0105e4c:	01 c0                	add    %eax,%eax
c0105e4e:	01 d0                	add    %edx,%eax
c0105e50:	c1 e0 02             	shl    $0x2,%eax
c0105e53:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105e58:	8b 00                	mov    (%eax),%eax
c0105e5a:	8d 48 01             	lea    0x1(%eax),%ecx
c0105e5d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105e60:	89 d0                	mov    %edx,%eax
c0105e62:	01 c0                	add    %eax,%eax
c0105e64:	01 d0                	add    %edx,%eax
c0105e66:	c1 e0 02             	shl    $0x2,%eax
c0105e69:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105e6e:	89 08                	mov    %ecx,(%eax)
    buddy_my_merge(level); 
c0105e70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e73:	89 04 24             	mov    %eax,(%esp)
c0105e76:	e8 d5 fa ff ff       	call   c0105950 <buddy_my_merge>
    //buddy_selfcheck();
}
c0105e7b:	90                   	nop
c0105e7c:	c9                   	leave  
c0105e7d:	c3                   	ret    

c0105e7e <buddy_check>:

static void
buddy_check(void) {
c0105e7e:	55                   	push   %ebp
c0105e7f:	89 e5                	mov    %esp,%ebp
c0105e81:	81 ec f8 00 00 00    	sub    $0xf8,%esp
    int count = 0, total = 0;
c0105e87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105e8e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) {
c0105e95:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105e9c:	e9 a4 00 00 00       	jmp    c0105f45 <buddy_check+0xc7>
        list_entry_t* free_list = &(free_area[i].free_list);
c0105ea1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105ea4:	89 d0                	mov    %edx,%eax
c0105ea6:	01 c0                	add    %eax,%eax
c0105ea8:	01 d0                	add    %edx,%eax
c0105eaa:	c1 e0 02             	shl    $0x2,%eax
c0105ead:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105eb2:	89 45 d0             	mov    %eax,-0x30(%ebp)
        list_entry_t* le = free_list;
c0105eb5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105eb8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        while ((le = list_next(le)) != free_list) {
c0105ebb:	eb 6a                	jmp    c0105f27 <buddy_check+0xa9>
            struct Page* p = le2page(le, page_link);
c0105ebd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ec0:	83 e8 0c             	sub    $0xc,%eax
c0105ec3:	89 45 cc             	mov    %eax,-0x34(%ebp)
            assert(PageProperty(p));
c0105ec6:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105ec9:	83 c0 04             	add    $0x4,%eax
c0105ecc:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0105ed3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105ed6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105ed9:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105edc:	0f a3 10             	bt     %edx,(%eax)
c0105edf:	19 c0                	sbb    %eax,%eax
c0105ee1:	89 45 c0             	mov    %eax,-0x40(%ebp)
    return oldbit != 0;
c0105ee4:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0105ee8:	0f 95 c0             	setne  %al
c0105eeb:	0f b6 c0             	movzbl %al,%eax
c0105eee:	85 c0                	test   %eax,%eax
c0105ef0:	75 24                	jne    c0105f16 <buddy_check+0x98>
c0105ef2:	c7 44 24 0c b5 80 10 	movl   $0xc01080b5,0xc(%esp)
c0105ef9:	c0 
c0105efa:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c0105f01:	c0 
c0105f02:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0105f09:	00 
c0105f0a:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c0105f11:	e8 d3 a4 ff ff       	call   c01003e9 <__panic>
            count++;
c0105f16:	ff 45 f4             	incl   -0xc(%ebp)
            total += p->property;
c0105f19:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105f1c:	8b 50 08             	mov    0x8(%eax),%edx
c0105f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f22:	01 d0                	add    %edx,%eax
c0105f24:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f27:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f2a:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return listelm->next;
c0105f2d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105f30:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != free_list) {
c0105f33:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105f36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f39:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105f3c:	0f 85 7b ff ff ff    	jne    c0105ebd <buddy_check+0x3f>
    for (int i = 0; i <= MAXLEVEL; i++) {
c0105f42:	ff 45 ec             	incl   -0x14(%ebp)
c0105f45:	83 7d ec 0c          	cmpl   $0xc,-0x14(%ebp)
c0105f49:	0f 8e 52 ff ff ff    	jle    c0105ea1 <buddy_check+0x23>
        }
    }
    assert(total == buddy_nr_free_page());
c0105f4f:	e8 98 f5 ff ff       	call   c01054ec <buddy_nr_free_page>
c0105f54:	89 c2                	mov    %eax,%edx
c0105f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f59:	39 c2                	cmp    %eax,%edx
c0105f5b:	74 24                	je     c0105f81 <buddy_check+0x103>
c0105f5d:	c7 44 24 0c c5 80 10 	movl   $0xc01080c5,0xc(%esp)
c0105f64:	c0 
c0105f65:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c0105f6c:	c0 
c0105f6d:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0105f74:	00 
c0105f75:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c0105f7c:	e8 68 a4 ff ff       	call   c01003e9 <__panic>

    // basic check
    struct Page *p0, *p1, *p2;
    p0 = p1 =p2 = NULL;
c0105f81:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105f88:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f8b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105f8e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105f91:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("p0\n");
c0105f94:	c7 04 24 e3 80 10 c0 	movl   $0xc01080e3,(%esp)
c0105f9b:	e8 f2 a2 ff ff       	call   c0100292 <cprintf>
    assert((p0 = alloc_page()) != NULL);
c0105fa0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105fa7:	e8 d0 cb ff ff       	call   c0102b7c <alloc_pages>
c0105fac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105faf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0105fb3:	75 24                	jne    c0105fd9 <buddy_check+0x15b>
c0105fb5:	c7 44 24 0c e7 80 10 	movl   $0xc01080e7,0xc(%esp)
c0105fbc:	c0 
c0105fbd:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c0105fc4:	c0 
c0105fc5:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c0105fcc:	00 
c0105fcd:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c0105fd4:	e8 10 a4 ff ff       	call   c01003e9 <__panic>
    cprintf("p1\n");
c0105fd9:	c7 04 24 03 81 10 c0 	movl   $0xc0108103,(%esp)
c0105fe0:	e8 ad a2 ff ff       	call   c0100292 <cprintf>
    assert((p1 = alloc_page()) != NULL);
c0105fe5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105fec:	e8 8b cb ff ff       	call   c0102b7c <alloc_pages>
c0105ff1:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105ff4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105ff8:	75 24                	jne    c010601e <buddy_check+0x1a0>
c0105ffa:	c7 44 24 0c 07 81 10 	movl   $0xc0108107,0xc(%esp)
c0106001:	c0 
c0106002:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c0106009:	c0 
c010600a:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0106011:	00 
c0106012:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c0106019:	e8 cb a3 ff ff       	call   c01003e9 <__panic>
    cprintf("p2\n");
c010601e:	c7 04 24 23 81 10 c0 	movl   $0xc0108123,(%esp)
c0106025:	e8 68 a2 ff ff       	call   c0100292 <cprintf>
    assert((p2 = alloc_page()) != NULL);
c010602a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106031:	e8 46 cb ff ff       	call   c0102b7c <alloc_pages>
c0106036:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106039:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010603d:	75 24                	jne    c0106063 <buddy_check+0x1e5>
c010603f:	c7 44 24 0c 27 81 10 	movl   $0xc0108127,0xc(%esp)
c0106046:	c0 
c0106047:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c010604e:	c0 
c010604f:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0106056:	00 
c0106057:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c010605e:	e8 86 a3 ff ff       	call   c01003e9 <__panic>

    assert(p0 != p1 && p1 != p2 && p2 != p0);
c0106063:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106066:	3b 45 d8             	cmp    -0x28(%ebp),%eax
c0106069:	74 10                	je     c010607b <buddy_check+0x1fd>
c010606b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010606e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0106071:	74 08                	je     c010607b <buddy_check+0x1fd>
c0106073:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106076:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0106079:	75 24                	jne    c010609f <buddy_check+0x221>
c010607b:	c7 44 24 0c 44 81 10 	movl   $0xc0108144,0xc(%esp)
c0106082:	c0 
c0106083:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c010608a:	c0 
c010608b:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0106092:	00 
c0106093:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c010609a:	e8 4a a3 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010609f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01060a2:	89 04 24             	mov    %eax,(%esp)
c01060a5:	e8 d0 f3 ff ff       	call   c010547a <page_ref>
c01060aa:	85 c0                	test   %eax,%eax
c01060ac:	75 1e                	jne    c01060cc <buddy_check+0x24e>
c01060ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01060b1:	89 04 24             	mov    %eax,(%esp)
c01060b4:	e8 c1 f3 ff ff       	call   c010547a <page_ref>
c01060b9:	85 c0                	test   %eax,%eax
c01060bb:	75 0f                	jne    c01060cc <buddy_check+0x24e>
c01060bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01060c0:	89 04 24             	mov    %eax,(%esp)
c01060c3:	e8 b2 f3 ff ff       	call   c010547a <page_ref>
c01060c8:	85 c0                	test   %eax,%eax
c01060ca:	74 24                	je     c01060f0 <buddy_check+0x272>
c01060cc:	c7 44 24 0c 68 81 10 	movl   $0xc0108168,0xc(%esp)
c01060d3:	c0 
c01060d4:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c01060db:	c0 
c01060dc:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c01060e3:	00 
c01060e4:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c01060eb:	e8 f9 a2 ff ff       	call   c01003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01060f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01060f3:	89 04 24             	mov    %eax,(%esp)
c01060f6:	e8 69 f3 ff ff       	call   c0105464 <page2pa>
c01060fb:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0106101:	c1 e2 0c             	shl    $0xc,%edx
c0106104:	39 d0                	cmp    %edx,%eax
c0106106:	72 24                	jb     c010612c <buddy_check+0x2ae>
c0106108:	c7 44 24 0c a4 81 10 	movl   $0xc01081a4,0xc(%esp)
c010610f:	c0 
c0106110:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c0106117:	c0 
c0106118:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c010611f:	00 
c0106120:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c0106127:	e8 bd a2 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c010612c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010612f:	89 04 24             	mov    %eax,(%esp)
c0106132:	e8 2d f3 ff ff       	call   c0105464 <page2pa>
c0106137:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c010613d:	c1 e2 0c             	shl    $0xc,%edx
c0106140:	39 d0                	cmp    %edx,%eax
c0106142:	72 24                	jb     c0106168 <buddy_check+0x2ea>
c0106144:	c7 44 24 0c c1 81 10 	movl   $0xc01081c1,0xc(%esp)
c010614b:	c0 
c010614c:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c0106153:	c0 
c0106154:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c010615b:	00 
c010615c:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c0106163:	e8 81 a2 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0106168:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010616b:	89 04 24             	mov    %eax,(%esp)
c010616e:	e8 f1 f2 ff ff       	call   c0105464 <page2pa>
c0106173:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0106179:	c1 e2 0c             	shl    $0xc,%edx
c010617c:	39 d0                	cmp    %edx,%eax
c010617e:	72 24                	jb     c01061a4 <buddy_check+0x326>
c0106180:	c7 44 24 0c de 81 10 	movl   $0xc01081de,0xc(%esp)
c0106187:	c0 
c0106188:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c010618f:	c0 
c0106190:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0106197:	00 
c0106198:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c010619f:	e8 45 a2 ff ff       	call   c01003e9 <__panic>
    cprintf("first part of check successfully.\n");
c01061a4:	c7 04 24 fc 81 10 c0 	movl   $0xc01081fc,(%esp)
c01061ab:	e8 e2 a0 ff ff       	call   c0100292 <cprintf>

    free_area_t temp_list[MAXLEVEL + 1];
    for (int i = 0; i <= MAXLEVEL; i++) {
c01061b0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01061b7:	e9 c5 00 00 00       	jmp    c0106281 <buddy_check+0x403>
        temp_list[i] = free_area[i];
c01061bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01061bf:	89 d0                	mov    %edx,%eax
c01061c1:	01 c0                	add    %eax,%eax
c01061c3:	01 d0                	add    %edx,%eax
c01061c5:	c1 e0 02             	shl    $0x2,%eax
c01061c8:	8d 4d f8             	lea    -0x8(%ebp),%ecx
c01061cb:	01 c8                	add    %ecx,%eax
c01061cd:	8d 90 20 ff ff ff    	lea    -0xe0(%eax),%edx
c01061d3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c01061d6:	89 c8                	mov    %ecx,%eax
c01061d8:	01 c0                	add    %eax,%eax
c01061da:	01 c8                	add    %ecx,%eax
c01061dc:	c1 e0 02             	shl    $0x2,%eax
c01061df:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01061e4:	8b 08                	mov    (%eax),%ecx
c01061e6:	89 0a                	mov    %ecx,(%edx)
c01061e8:	8b 48 04             	mov    0x4(%eax),%ecx
c01061eb:	89 4a 04             	mov    %ecx,0x4(%edx)
c01061ee:	8b 40 08             	mov    0x8(%eax),%eax
c01061f1:	89 42 08             	mov    %eax,0x8(%edx)
        list_init(&(free_area[i].free_list));
c01061f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01061f7:	89 d0                	mov    %edx,%eax
c01061f9:	01 c0                	add    %eax,%eax
c01061fb:	01 d0                	add    %edx,%eax
c01061fd:	c1 e0 02             	shl    $0x2,%eax
c0106200:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0106205:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    elm->prev = elm->next = elm;
c0106208:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010620b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010620e:	89 50 04             	mov    %edx,0x4(%eax)
c0106211:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106214:	8b 50 04             	mov    0x4(%eax),%edx
c0106217:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010621a:	89 10                	mov    %edx,(%eax)
        assert(list_empty(&(free_area[i])));
c010621c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010621f:	89 d0                	mov    %edx,%eax
c0106221:	01 c0                	add    %eax,%eax
c0106223:	01 d0                	add    %edx,%eax
c0106225:	c1 e0 02             	shl    $0x2,%eax
c0106228:	05 20 df 11 c0       	add    $0xc011df20,%eax
c010622d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return list->next == list;
c0106230:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106233:	8b 40 04             	mov    0x4(%eax),%eax
c0106236:	39 45 b8             	cmp    %eax,-0x48(%ebp)
c0106239:	0f 94 c0             	sete   %al
c010623c:	0f b6 c0             	movzbl %al,%eax
c010623f:	85 c0                	test   %eax,%eax
c0106241:	75 24                	jne    c0106267 <buddy_check+0x3e9>
c0106243:	c7 44 24 0c 1f 82 10 	movl   $0xc010821f,0xc(%esp)
c010624a:	c0 
c010624b:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c0106252:	c0 
c0106253:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c010625a:	00 
c010625b:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c0106262:	e8 82 a1 ff ff       	call   c01003e9 <__panic>
        free_area[i].nr_free = 0;
c0106267:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010626a:	89 d0                	mov    %edx,%eax
c010626c:	01 c0                	add    %eax,%eax
c010626e:	01 d0                	add    %edx,%eax
c0106270:	c1 e0 02             	shl    $0x2,%eax
c0106273:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0106278:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    for (int i = 0; i <= MAXLEVEL; i++) {
c010627e:	ff 45 e4             	incl   -0x1c(%ebp)
c0106281:	83 7d e4 0c          	cmpl   $0xc,-0x1c(%ebp)
c0106285:	0f 8e 31 ff ff ff    	jle    c01061bc <buddy_check+0x33e>
    }
    assert(alloc_page() == NULL);
c010628b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106292:	e8 e5 c8 ff ff       	call   c0102b7c <alloc_pages>
c0106297:	85 c0                	test   %eax,%eax
c0106299:	74 24                	je     c01062bf <buddy_check+0x441>
c010629b:	c7 44 24 0c 3b 82 10 	movl   $0xc010823b,0xc(%esp)
c01062a2:	c0 
c01062a3:	c7 44 24 08 e0 7f 10 	movl   $0xc0107fe0,0x8(%esp)
c01062aa:	c0 
c01062ab:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c01062b2:	00 
c01062b3:	c7 04 24 f5 7f 10 c0 	movl   $0xc0107ff5,(%esp)
c01062ba:	e8 2a a1 ff ff       	call   c01003e9 <__panic>
    cprintf("clean successfully.\n");
c01062bf:	c7 04 24 50 82 10 c0 	movl   $0xc0108250,(%esp)
c01062c6:	e8 c7 9f ff ff       	call   c0100292 <cprintf>
    cprintf("p0\n");
c01062cb:	c7 04 24 e3 80 10 c0 	movl   $0xc01080e3,(%esp)
c01062d2:	e8 bb 9f ff ff       	call   c0100292 <cprintf>
    free_page(p0);
c01062d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01062de:	00 
c01062df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01062e2:	89 04 24             	mov    %eax,(%esp)
c01062e5:	e8 ca c8 ff ff       	call   c0102bb4 <free_pages>
    cprintf("p1\n");
c01062ea:	c7 04 24 03 81 10 c0 	movl   $0xc0108103,(%esp)
c01062f1:	e8 9c 9f ff ff       	call   c0100292 <cprintf>
    free_page(p1);
c01062f6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01062fd:	00 
c01062fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106301:	89 04 24             	mov    %eax,(%esp)
c0106304:	e8 ab c8 ff ff       	call   c0102bb4 <free_pages>
    cprintf("p2\n");
c0106309:	c7 04 24 23 81 10 c0 	movl   $0xc0108123,(%esp)
c0106310:	e8 7d 9f ff ff       	call   c0100292 <cprintf>
    free_page(p2);
c0106315:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010631c:	00 
c010631d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106320:	89 04 24             	mov    %eax,(%esp)
c0106323:	e8 8c c8 ff ff       	call   c0102bb4 <free_pages>
    total = 0;
c0106328:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
c010632f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0106336:	eb 1e                	jmp    c0106356 <buddy_check+0x4d8>
        total += free_area[i].nr_free;
c0106338:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010633b:	89 d0                	mov    %edx,%eax
c010633d:	01 c0                	add    %eax,%eax
c010633f:	01 d0                	add    %edx,%eax
c0106341:	c1 e0 02             	shl    $0x2,%eax
c0106344:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0106349:	8b 10                	mov    (%eax),%edx
c010634b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010634e:	01 d0                	add    %edx,%eax
c0106350:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
c0106353:	ff 45 e0             	incl   -0x20(%ebp)
c0106356:	83 7d e0 0c          	cmpl   $0xc,-0x20(%ebp)
c010635a:	7e dc                	jle    c0106338 <buddy_check+0x4ba>

    //assert((p0 = alloc_page()) != NULL);
    //assert((p1 = alloc_page()) != NULL);
    //assert((p2 = alloc_page()) != NULL);
    //assert(alloc_page() == NULL);
}
c010635c:	90                   	nop
c010635d:	c9                   	leave  
c010635e:	c3                   	ret    

c010635f <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010635f:	55                   	push   %ebp
c0106360:	89 e5                	mov    %esp,%ebp
c0106362:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0106365:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010636c:	eb 03                	jmp    c0106371 <strlen+0x12>
        cnt ++;
c010636e:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0106371:	8b 45 08             	mov    0x8(%ebp),%eax
c0106374:	8d 50 01             	lea    0x1(%eax),%edx
c0106377:	89 55 08             	mov    %edx,0x8(%ebp)
c010637a:	0f b6 00             	movzbl (%eax),%eax
c010637d:	84 c0                	test   %al,%al
c010637f:	75 ed                	jne    c010636e <strlen+0xf>
    }
    return cnt;
c0106381:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0106384:	c9                   	leave  
c0106385:	c3                   	ret    

c0106386 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0106386:	55                   	push   %ebp
c0106387:	89 e5                	mov    %esp,%ebp
c0106389:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010638c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0106393:	eb 03                	jmp    c0106398 <strnlen+0x12>
        cnt ++;
c0106395:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0106398:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010639b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010639e:	73 10                	jae    c01063b0 <strnlen+0x2a>
c01063a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01063a3:	8d 50 01             	lea    0x1(%eax),%edx
c01063a6:	89 55 08             	mov    %edx,0x8(%ebp)
c01063a9:	0f b6 00             	movzbl (%eax),%eax
c01063ac:	84 c0                	test   %al,%al
c01063ae:	75 e5                	jne    c0106395 <strnlen+0xf>
    }
    return cnt;
c01063b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01063b3:	c9                   	leave  
c01063b4:	c3                   	ret    

c01063b5 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c01063b5:	55                   	push   %ebp
c01063b6:	89 e5                	mov    %esp,%ebp
c01063b8:	57                   	push   %edi
c01063b9:	56                   	push   %esi
c01063ba:	83 ec 20             	sub    $0x20,%esp
c01063bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01063c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01063c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01063c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01063cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063cf:	89 d1                	mov    %edx,%ecx
c01063d1:	89 c2                	mov    %eax,%edx
c01063d3:	89 ce                	mov    %ecx,%esi
c01063d5:	89 d7                	mov    %edx,%edi
c01063d7:	ac                   	lods   %ds:(%esi),%al
c01063d8:	aa                   	stos   %al,%es:(%edi)
c01063d9:	84 c0                	test   %al,%al
c01063db:	75 fa                	jne    c01063d7 <strcpy+0x22>
c01063dd:	89 fa                	mov    %edi,%edx
c01063df:	89 f1                	mov    %esi,%ecx
c01063e1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01063e4:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01063e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01063ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c01063ed:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c01063ee:	83 c4 20             	add    $0x20,%esp
c01063f1:	5e                   	pop    %esi
c01063f2:	5f                   	pop    %edi
c01063f3:	5d                   	pop    %ebp
c01063f4:	c3                   	ret    

c01063f5 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c01063f5:	55                   	push   %ebp
c01063f6:	89 e5                	mov    %esp,%ebp
c01063f8:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c01063fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01063fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0106401:	eb 1e                	jmp    c0106421 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0106403:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106406:	0f b6 10             	movzbl (%eax),%edx
c0106409:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010640c:	88 10                	mov    %dl,(%eax)
c010640e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106411:	0f b6 00             	movzbl (%eax),%eax
c0106414:	84 c0                	test   %al,%al
c0106416:	74 03                	je     c010641b <strncpy+0x26>
            src ++;
c0106418:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c010641b:	ff 45 fc             	incl   -0x4(%ebp)
c010641e:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0106421:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106425:	75 dc                	jne    c0106403 <strncpy+0xe>
    }
    return dst;
c0106427:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010642a:	c9                   	leave  
c010642b:	c3                   	ret    

c010642c <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010642c:	55                   	push   %ebp
c010642d:	89 e5                	mov    %esp,%ebp
c010642f:	57                   	push   %edi
c0106430:	56                   	push   %esi
c0106431:	83 ec 20             	sub    $0x20,%esp
c0106434:	8b 45 08             	mov    0x8(%ebp),%eax
c0106437:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010643a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010643d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0106440:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106443:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106446:	89 d1                	mov    %edx,%ecx
c0106448:	89 c2                	mov    %eax,%edx
c010644a:	89 ce                	mov    %ecx,%esi
c010644c:	89 d7                	mov    %edx,%edi
c010644e:	ac                   	lods   %ds:(%esi),%al
c010644f:	ae                   	scas   %es:(%edi),%al
c0106450:	75 08                	jne    c010645a <strcmp+0x2e>
c0106452:	84 c0                	test   %al,%al
c0106454:	75 f8                	jne    c010644e <strcmp+0x22>
c0106456:	31 c0                	xor    %eax,%eax
c0106458:	eb 04                	jmp    c010645e <strcmp+0x32>
c010645a:	19 c0                	sbb    %eax,%eax
c010645c:	0c 01                	or     $0x1,%al
c010645e:	89 fa                	mov    %edi,%edx
c0106460:	89 f1                	mov    %esi,%ecx
c0106462:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106465:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106468:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c010646b:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c010646e:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010646f:	83 c4 20             	add    $0x20,%esp
c0106472:	5e                   	pop    %esi
c0106473:	5f                   	pop    %edi
c0106474:	5d                   	pop    %ebp
c0106475:	c3                   	ret    

c0106476 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0106476:	55                   	push   %ebp
c0106477:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106479:	eb 09                	jmp    c0106484 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c010647b:	ff 4d 10             	decl   0x10(%ebp)
c010647e:	ff 45 08             	incl   0x8(%ebp)
c0106481:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106484:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106488:	74 1a                	je     c01064a4 <strncmp+0x2e>
c010648a:	8b 45 08             	mov    0x8(%ebp),%eax
c010648d:	0f b6 00             	movzbl (%eax),%eax
c0106490:	84 c0                	test   %al,%al
c0106492:	74 10                	je     c01064a4 <strncmp+0x2e>
c0106494:	8b 45 08             	mov    0x8(%ebp),%eax
c0106497:	0f b6 10             	movzbl (%eax),%edx
c010649a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010649d:	0f b6 00             	movzbl (%eax),%eax
c01064a0:	38 c2                	cmp    %al,%dl
c01064a2:	74 d7                	je     c010647b <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c01064a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01064a8:	74 18                	je     c01064c2 <strncmp+0x4c>
c01064aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01064ad:	0f b6 00             	movzbl (%eax),%eax
c01064b0:	0f b6 d0             	movzbl %al,%edx
c01064b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064b6:	0f b6 00             	movzbl (%eax),%eax
c01064b9:	0f b6 c0             	movzbl %al,%eax
c01064bc:	29 c2                	sub    %eax,%edx
c01064be:	89 d0                	mov    %edx,%eax
c01064c0:	eb 05                	jmp    c01064c7 <strncmp+0x51>
c01064c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01064c7:	5d                   	pop    %ebp
c01064c8:	c3                   	ret    

c01064c9 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c01064c9:	55                   	push   %ebp
c01064ca:	89 e5                	mov    %esp,%ebp
c01064cc:	83 ec 04             	sub    $0x4,%esp
c01064cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064d2:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01064d5:	eb 13                	jmp    c01064ea <strchr+0x21>
        if (*s == c) {
c01064d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01064da:	0f b6 00             	movzbl (%eax),%eax
c01064dd:	38 45 fc             	cmp    %al,-0x4(%ebp)
c01064e0:	75 05                	jne    c01064e7 <strchr+0x1e>
            return (char *)s;
c01064e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01064e5:	eb 12                	jmp    c01064f9 <strchr+0x30>
        }
        s ++;
c01064e7:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c01064ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01064ed:	0f b6 00             	movzbl (%eax),%eax
c01064f0:	84 c0                	test   %al,%al
c01064f2:	75 e3                	jne    c01064d7 <strchr+0xe>
    }
    return NULL;
c01064f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01064f9:	c9                   	leave  
c01064fa:	c3                   	ret    

c01064fb <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c01064fb:	55                   	push   %ebp
c01064fc:	89 e5                	mov    %esp,%ebp
c01064fe:	83 ec 04             	sub    $0x4,%esp
c0106501:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106504:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0106507:	eb 0e                	jmp    c0106517 <strfind+0x1c>
        if (*s == c) {
c0106509:	8b 45 08             	mov    0x8(%ebp),%eax
c010650c:	0f b6 00             	movzbl (%eax),%eax
c010650f:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0106512:	74 0f                	je     c0106523 <strfind+0x28>
            break;
        }
        s ++;
c0106514:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0106517:	8b 45 08             	mov    0x8(%ebp),%eax
c010651a:	0f b6 00             	movzbl (%eax),%eax
c010651d:	84 c0                	test   %al,%al
c010651f:	75 e8                	jne    c0106509 <strfind+0xe>
c0106521:	eb 01                	jmp    c0106524 <strfind+0x29>
            break;
c0106523:	90                   	nop
    }
    return (char *)s;
c0106524:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106527:	c9                   	leave  
c0106528:	c3                   	ret    

c0106529 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0106529:	55                   	push   %ebp
c010652a:	89 e5                	mov    %esp,%ebp
c010652c:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010652f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0106536:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010653d:	eb 03                	jmp    c0106542 <strtol+0x19>
        s ++;
c010653f:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0106542:	8b 45 08             	mov    0x8(%ebp),%eax
c0106545:	0f b6 00             	movzbl (%eax),%eax
c0106548:	3c 20                	cmp    $0x20,%al
c010654a:	74 f3                	je     c010653f <strtol+0x16>
c010654c:	8b 45 08             	mov    0x8(%ebp),%eax
c010654f:	0f b6 00             	movzbl (%eax),%eax
c0106552:	3c 09                	cmp    $0x9,%al
c0106554:	74 e9                	je     c010653f <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0106556:	8b 45 08             	mov    0x8(%ebp),%eax
c0106559:	0f b6 00             	movzbl (%eax),%eax
c010655c:	3c 2b                	cmp    $0x2b,%al
c010655e:	75 05                	jne    c0106565 <strtol+0x3c>
        s ++;
c0106560:	ff 45 08             	incl   0x8(%ebp)
c0106563:	eb 14                	jmp    c0106579 <strtol+0x50>
    }
    else if (*s == '-') {
c0106565:	8b 45 08             	mov    0x8(%ebp),%eax
c0106568:	0f b6 00             	movzbl (%eax),%eax
c010656b:	3c 2d                	cmp    $0x2d,%al
c010656d:	75 0a                	jne    c0106579 <strtol+0x50>
        s ++, neg = 1;
c010656f:	ff 45 08             	incl   0x8(%ebp)
c0106572:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0106579:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010657d:	74 06                	je     c0106585 <strtol+0x5c>
c010657f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0106583:	75 22                	jne    c01065a7 <strtol+0x7e>
c0106585:	8b 45 08             	mov    0x8(%ebp),%eax
c0106588:	0f b6 00             	movzbl (%eax),%eax
c010658b:	3c 30                	cmp    $0x30,%al
c010658d:	75 18                	jne    c01065a7 <strtol+0x7e>
c010658f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106592:	40                   	inc    %eax
c0106593:	0f b6 00             	movzbl (%eax),%eax
c0106596:	3c 78                	cmp    $0x78,%al
c0106598:	75 0d                	jne    c01065a7 <strtol+0x7e>
        s += 2, base = 16;
c010659a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010659e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c01065a5:	eb 29                	jmp    c01065d0 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c01065a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01065ab:	75 16                	jne    c01065c3 <strtol+0x9a>
c01065ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01065b0:	0f b6 00             	movzbl (%eax),%eax
c01065b3:	3c 30                	cmp    $0x30,%al
c01065b5:	75 0c                	jne    c01065c3 <strtol+0x9a>
        s ++, base = 8;
c01065b7:	ff 45 08             	incl   0x8(%ebp)
c01065ba:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c01065c1:	eb 0d                	jmp    c01065d0 <strtol+0xa7>
    }
    else if (base == 0) {
c01065c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01065c7:	75 07                	jne    c01065d0 <strtol+0xa7>
        base = 10;
c01065c9:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c01065d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01065d3:	0f b6 00             	movzbl (%eax),%eax
c01065d6:	3c 2f                	cmp    $0x2f,%al
c01065d8:	7e 1b                	jle    c01065f5 <strtol+0xcc>
c01065da:	8b 45 08             	mov    0x8(%ebp),%eax
c01065dd:	0f b6 00             	movzbl (%eax),%eax
c01065e0:	3c 39                	cmp    $0x39,%al
c01065e2:	7f 11                	jg     c01065f5 <strtol+0xcc>
            dig = *s - '0';
c01065e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01065e7:	0f b6 00             	movzbl (%eax),%eax
c01065ea:	0f be c0             	movsbl %al,%eax
c01065ed:	83 e8 30             	sub    $0x30,%eax
c01065f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01065f3:	eb 48                	jmp    c010663d <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c01065f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01065f8:	0f b6 00             	movzbl (%eax),%eax
c01065fb:	3c 60                	cmp    $0x60,%al
c01065fd:	7e 1b                	jle    c010661a <strtol+0xf1>
c01065ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0106602:	0f b6 00             	movzbl (%eax),%eax
c0106605:	3c 7a                	cmp    $0x7a,%al
c0106607:	7f 11                	jg     c010661a <strtol+0xf1>
            dig = *s - 'a' + 10;
c0106609:	8b 45 08             	mov    0x8(%ebp),%eax
c010660c:	0f b6 00             	movzbl (%eax),%eax
c010660f:	0f be c0             	movsbl %al,%eax
c0106612:	83 e8 57             	sub    $0x57,%eax
c0106615:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106618:	eb 23                	jmp    c010663d <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010661a:	8b 45 08             	mov    0x8(%ebp),%eax
c010661d:	0f b6 00             	movzbl (%eax),%eax
c0106620:	3c 40                	cmp    $0x40,%al
c0106622:	7e 3b                	jle    c010665f <strtol+0x136>
c0106624:	8b 45 08             	mov    0x8(%ebp),%eax
c0106627:	0f b6 00             	movzbl (%eax),%eax
c010662a:	3c 5a                	cmp    $0x5a,%al
c010662c:	7f 31                	jg     c010665f <strtol+0x136>
            dig = *s - 'A' + 10;
c010662e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106631:	0f b6 00             	movzbl (%eax),%eax
c0106634:	0f be c0             	movsbl %al,%eax
c0106637:	83 e8 37             	sub    $0x37,%eax
c010663a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010663d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106640:	3b 45 10             	cmp    0x10(%ebp),%eax
c0106643:	7d 19                	jge    c010665e <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0106645:	ff 45 08             	incl   0x8(%ebp)
c0106648:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010664b:	0f af 45 10          	imul   0x10(%ebp),%eax
c010664f:	89 c2                	mov    %eax,%edx
c0106651:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106654:	01 d0                	add    %edx,%eax
c0106656:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0106659:	e9 72 ff ff ff       	jmp    c01065d0 <strtol+0xa7>
            break;
c010665e:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c010665f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106663:	74 08                	je     c010666d <strtol+0x144>
        *endptr = (char *) s;
c0106665:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106668:	8b 55 08             	mov    0x8(%ebp),%edx
c010666b:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010666d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0106671:	74 07                	je     c010667a <strtol+0x151>
c0106673:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106676:	f7 d8                	neg    %eax
c0106678:	eb 03                	jmp    c010667d <strtol+0x154>
c010667a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010667d:	c9                   	leave  
c010667e:	c3                   	ret    

c010667f <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010667f:	55                   	push   %ebp
c0106680:	89 e5                	mov    %esp,%ebp
c0106682:	57                   	push   %edi
c0106683:	83 ec 24             	sub    $0x24,%esp
c0106686:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106689:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010668c:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0106690:	8b 55 08             	mov    0x8(%ebp),%edx
c0106693:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0106696:	88 45 f7             	mov    %al,-0x9(%ebp)
c0106699:	8b 45 10             	mov    0x10(%ebp),%eax
c010669c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010669f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01066a2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01066a6:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01066a9:	89 d7                	mov    %edx,%edi
c01066ab:	f3 aa                	rep stos %al,%es:(%edi)
c01066ad:	89 fa                	mov    %edi,%edx
c01066af:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01066b2:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c01066b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01066b8:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c01066b9:	83 c4 24             	add    $0x24,%esp
c01066bc:	5f                   	pop    %edi
c01066bd:	5d                   	pop    %ebp
c01066be:	c3                   	ret    

c01066bf <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c01066bf:	55                   	push   %ebp
c01066c0:	89 e5                	mov    %esp,%ebp
c01066c2:	57                   	push   %edi
c01066c3:	56                   	push   %esi
c01066c4:	53                   	push   %ebx
c01066c5:	83 ec 30             	sub    $0x30,%esp
c01066c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01066cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01066ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01066d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01066d4:	8b 45 10             	mov    0x10(%ebp),%eax
c01066d7:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c01066da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066dd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01066e0:	73 42                	jae    c0106724 <memmove+0x65>
c01066e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01066e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01066eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01066ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01066f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01066f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01066f7:	c1 e8 02             	shr    $0x2,%eax
c01066fa:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01066fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01066ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106702:	89 d7                	mov    %edx,%edi
c0106704:	89 c6                	mov    %eax,%esi
c0106706:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106708:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010670b:	83 e1 03             	and    $0x3,%ecx
c010670e:	74 02                	je     c0106712 <memmove+0x53>
c0106710:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106712:	89 f0                	mov    %esi,%eax
c0106714:	89 fa                	mov    %edi,%edx
c0106716:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0106719:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010671c:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010671f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c0106722:	eb 36                	jmp    c010675a <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0106724:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106727:	8d 50 ff             	lea    -0x1(%eax),%edx
c010672a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010672d:	01 c2                	add    %eax,%edx
c010672f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106732:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0106735:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106738:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010673b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010673e:	89 c1                	mov    %eax,%ecx
c0106740:	89 d8                	mov    %ebx,%eax
c0106742:	89 d6                	mov    %edx,%esi
c0106744:	89 c7                	mov    %eax,%edi
c0106746:	fd                   	std    
c0106747:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106749:	fc                   	cld    
c010674a:	89 f8                	mov    %edi,%eax
c010674c:	89 f2                	mov    %esi,%edx
c010674e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0106751:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106754:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0106757:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010675a:	83 c4 30             	add    $0x30,%esp
c010675d:	5b                   	pop    %ebx
c010675e:	5e                   	pop    %esi
c010675f:	5f                   	pop    %edi
c0106760:	5d                   	pop    %ebp
c0106761:	c3                   	ret    

c0106762 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0106762:	55                   	push   %ebp
c0106763:	89 e5                	mov    %esp,%ebp
c0106765:	57                   	push   %edi
c0106766:	56                   	push   %esi
c0106767:	83 ec 20             	sub    $0x20,%esp
c010676a:	8b 45 08             	mov    0x8(%ebp),%eax
c010676d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106770:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106773:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106776:	8b 45 10             	mov    0x10(%ebp),%eax
c0106779:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010677c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010677f:	c1 e8 02             	shr    $0x2,%eax
c0106782:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0106784:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106787:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010678a:	89 d7                	mov    %edx,%edi
c010678c:	89 c6                	mov    %eax,%esi
c010678e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106790:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0106793:	83 e1 03             	and    $0x3,%ecx
c0106796:	74 02                	je     c010679a <memcpy+0x38>
c0106798:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010679a:	89 f0                	mov    %esi,%eax
c010679c:	89 fa                	mov    %edi,%edx
c010679e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01067a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01067a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c01067a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c01067aa:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c01067ab:	83 c4 20             	add    $0x20,%esp
c01067ae:	5e                   	pop    %esi
c01067af:	5f                   	pop    %edi
c01067b0:	5d                   	pop    %ebp
c01067b1:	c3                   	ret    

c01067b2 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c01067b2:	55                   	push   %ebp
c01067b3:	89 e5                	mov    %esp,%ebp
c01067b5:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c01067b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01067bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c01067be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01067c1:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c01067c4:	eb 2e                	jmp    c01067f4 <memcmp+0x42>
        if (*s1 != *s2) {
c01067c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01067c9:	0f b6 10             	movzbl (%eax),%edx
c01067cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01067cf:	0f b6 00             	movzbl (%eax),%eax
c01067d2:	38 c2                	cmp    %al,%dl
c01067d4:	74 18                	je     c01067ee <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c01067d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01067d9:	0f b6 00             	movzbl (%eax),%eax
c01067dc:	0f b6 d0             	movzbl %al,%edx
c01067df:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01067e2:	0f b6 00             	movzbl (%eax),%eax
c01067e5:	0f b6 c0             	movzbl %al,%eax
c01067e8:	29 c2                	sub    %eax,%edx
c01067ea:	89 d0                	mov    %edx,%eax
c01067ec:	eb 18                	jmp    c0106806 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c01067ee:	ff 45 fc             	incl   -0x4(%ebp)
c01067f1:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c01067f4:	8b 45 10             	mov    0x10(%ebp),%eax
c01067f7:	8d 50 ff             	lea    -0x1(%eax),%edx
c01067fa:	89 55 10             	mov    %edx,0x10(%ebp)
c01067fd:	85 c0                	test   %eax,%eax
c01067ff:	75 c5                	jne    c01067c6 <memcmp+0x14>
    }
    return 0;
c0106801:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106806:	c9                   	leave  
c0106807:	c3                   	ret    

c0106808 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0106808:	55                   	push   %ebp
c0106809:	89 e5                	mov    %esp,%ebp
c010680b:	83 ec 58             	sub    $0x58,%esp
c010680e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106811:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106814:	8b 45 14             	mov    0x14(%ebp),%eax
c0106817:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010681a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010681d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106820:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106823:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0106826:	8b 45 18             	mov    0x18(%ebp),%eax
c0106829:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010682c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010682f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106832:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106835:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0106838:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010683b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010683e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106842:	74 1c                	je     c0106860 <printnum+0x58>
c0106844:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106847:	ba 00 00 00 00       	mov    $0x0,%edx
c010684c:	f7 75 e4             	divl   -0x1c(%ebp)
c010684f:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0106852:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106855:	ba 00 00 00 00       	mov    $0x0,%edx
c010685a:	f7 75 e4             	divl   -0x1c(%ebp)
c010685d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106860:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106863:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106866:	f7 75 e4             	divl   -0x1c(%ebp)
c0106869:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010686c:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010686f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106872:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106875:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106878:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010687b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010687e:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0106881:	8b 45 18             	mov    0x18(%ebp),%eax
c0106884:	ba 00 00 00 00       	mov    $0x0,%edx
c0106889:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c010688c:	72 56                	jb     c01068e4 <printnum+0xdc>
c010688e:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0106891:	77 05                	ja     c0106898 <printnum+0x90>
c0106893:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0106896:	72 4c                	jb     c01068e4 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0106898:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010689b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010689e:	8b 45 20             	mov    0x20(%ebp),%eax
c01068a1:	89 44 24 18          	mov    %eax,0x18(%esp)
c01068a5:	89 54 24 14          	mov    %edx,0x14(%esp)
c01068a9:	8b 45 18             	mov    0x18(%ebp),%eax
c01068ac:	89 44 24 10          	mov    %eax,0x10(%esp)
c01068b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01068b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01068b6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01068ba:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01068be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068c1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01068c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01068c8:	89 04 24             	mov    %eax,(%esp)
c01068cb:	e8 38 ff ff ff       	call   c0106808 <printnum>
c01068d0:	eb 1b                	jmp    c01068ed <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01068d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068d5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01068d9:	8b 45 20             	mov    0x20(%ebp),%eax
c01068dc:	89 04 24             	mov    %eax,(%esp)
c01068df:	8b 45 08             	mov    0x8(%ebp),%eax
c01068e2:	ff d0                	call   *%eax
        while (-- width > 0)
c01068e4:	ff 4d 1c             	decl   0x1c(%ebp)
c01068e7:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01068eb:	7f e5                	jg     c01068d2 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01068ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01068f0:	05 10 83 10 c0       	add    $0xc0108310,%eax
c01068f5:	0f b6 00             	movzbl (%eax),%eax
c01068f8:	0f be c0             	movsbl %al,%eax
c01068fb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01068fe:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106902:	89 04 24             	mov    %eax,(%esp)
c0106905:	8b 45 08             	mov    0x8(%ebp),%eax
c0106908:	ff d0                	call   *%eax
}
c010690a:	90                   	nop
c010690b:	c9                   	leave  
c010690c:	c3                   	ret    

c010690d <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010690d:	55                   	push   %ebp
c010690e:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0106910:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0106914:	7e 14                	jle    c010692a <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0106916:	8b 45 08             	mov    0x8(%ebp),%eax
c0106919:	8b 00                	mov    (%eax),%eax
c010691b:	8d 48 08             	lea    0x8(%eax),%ecx
c010691e:	8b 55 08             	mov    0x8(%ebp),%edx
c0106921:	89 0a                	mov    %ecx,(%edx)
c0106923:	8b 50 04             	mov    0x4(%eax),%edx
c0106926:	8b 00                	mov    (%eax),%eax
c0106928:	eb 30                	jmp    c010695a <getuint+0x4d>
    }
    else if (lflag) {
c010692a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010692e:	74 16                	je     c0106946 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0106930:	8b 45 08             	mov    0x8(%ebp),%eax
c0106933:	8b 00                	mov    (%eax),%eax
c0106935:	8d 48 04             	lea    0x4(%eax),%ecx
c0106938:	8b 55 08             	mov    0x8(%ebp),%edx
c010693b:	89 0a                	mov    %ecx,(%edx)
c010693d:	8b 00                	mov    (%eax),%eax
c010693f:	ba 00 00 00 00       	mov    $0x0,%edx
c0106944:	eb 14                	jmp    c010695a <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0106946:	8b 45 08             	mov    0x8(%ebp),%eax
c0106949:	8b 00                	mov    (%eax),%eax
c010694b:	8d 48 04             	lea    0x4(%eax),%ecx
c010694e:	8b 55 08             	mov    0x8(%ebp),%edx
c0106951:	89 0a                	mov    %ecx,(%edx)
c0106953:	8b 00                	mov    (%eax),%eax
c0106955:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010695a:	5d                   	pop    %ebp
c010695b:	c3                   	ret    

c010695c <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010695c:	55                   	push   %ebp
c010695d:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010695f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0106963:	7e 14                	jle    c0106979 <getint+0x1d>
        return va_arg(*ap, long long);
c0106965:	8b 45 08             	mov    0x8(%ebp),%eax
c0106968:	8b 00                	mov    (%eax),%eax
c010696a:	8d 48 08             	lea    0x8(%eax),%ecx
c010696d:	8b 55 08             	mov    0x8(%ebp),%edx
c0106970:	89 0a                	mov    %ecx,(%edx)
c0106972:	8b 50 04             	mov    0x4(%eax),%edx
c0106975:	8b 00                	mov    (%eax),%eax
c0106977:	eb 28                	jmp    c01069a1 <getint+0x45>
    }
    else if (lflag) {
c0106979:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010697d:	74 12                	je     c0106991 <getint+0x35>
        return va_arg(*ap, long);
c010697f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106982:	8b 00                	mov    (%eax),%eax
c0106984:	8d 48 04             	lea    0x4(%eax),%ecx
c0106987:	8b 55 08             	mov    0x8(%ebp),%edx
c010698a:	89 0a                	mov    %ecx,(%edx)
c010698c:	8b 00                	mov    (%eax),%eax
c010698e:	99                   	cltd   
c010698f:	eb 10                	jmp    c01069a1 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0106991:	8b 45 08             	mov    0x8(%ebp),%eax
c0106994:	8b 00                	mov    (%eax),%eax
c0106996:	8d 48 04             	lea    0x4(%eax),%ecx
c0106999:	8b 55 08             	mov    0x8(%ebp),%edx
c010699c:	89 0a                	mov    %ecx,(%edx)
c010699e:	8b 00                	mov    (%eax),%eax
c01069a0:	99                   	cltd   
    }
}
c01069a1:	5d                   	pop    %ebp
c01069a2:	c3                   	ret    

c01069a3 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01069a3:	55                   	push   %ebp
c01069a4:	89 e5                	mov    %esp,%ebp
c01069a6:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01069a9:	8d 45 14             	lea    0x14(%ebp),%eax
c01069ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01069af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01069b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01069b6:	8b 45 10             	mov    0x10(%ebp),%eax
c01069b9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01069bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01069c7:	89 04 24             	mov    %eax,(%esp)
c01069ca:	e8 03 00 00 00       	call   c01069d2 <vprintfmt>
    va_end(ap);
}
c01069cf:	90                   	nop
c01069d0:	c9                   	leave  
c01069d1:	c3                   	ret    

c01069d2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c01069d2:	55                   	push   %ebp
c01069d3:	89 e5                	mov    %esp,%ebp
c01069d5:	56                   	push   %esi
c01069d6:	53                   	push   %ebx
c01069d7:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01069da:	eb 17                	jmp    c01069f3 <vprintfmt+0x21>
            if (ch == '\0') {
c01069dc:	85 db                	test   %ebx,%ebx
c01069de:	0f 84 bf 03 00 00    	je     c0106da3 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c01069e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069eb:	89 1c 24             	mov    %ebx,(%esp)
c01069ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01069f1:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01069f3:	8b 45 10             	mov    0x10(%ebp),%eax
c01069f6:	8d 50 01             	lea    0x1(%eax),%edx
c01069f9:	89 55 10             	mov    %edx,0x10(%ebp)
c01069fc:	0f b6 00             	movzbl (%eax),%eax
c01069ff:	0f b6 d8             	movzbl %al,%ebx
c0106a02:	83 fb 25             	cmp    $0x25,%ebx
c0106a05:	75 d5                	jne    c01069dc <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0106a07:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0106a0b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0106a12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a15:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0106a18:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106a1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106a22:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0106a25:	8b 45 10             	mov    0x10(%ebp),%eax
c0106a28:	8d 50 01             	lea    0x1(%eax),%edx
c0106a2b:	89 55 10             	mov    %edx,0x10(%ebp)
c0106a2e:	0f b6 00             	movzbl (%eax),%eax
c0106a31:	0f b6 d8             	movzbl %al,%ebx
c0106a34:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0106a37:	83 f8 55             	cmp    $0x55,%eax
c0106a3a:	0f 87 37 03 00 00    	ja     c0106d77 <vprintfmt+0x3a5>
c0106a40:	8b 04 85 34 83 10 c0 	mov    -0x3fef7ccc(,%eax,4),%eax
c0106a47:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0106a49:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0106a4d:	eb d6                	jmp    c0106a25 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0106a4f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0106a53:	eb d0                	jmp    c0106a25 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0106a55:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0106a5c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106a5f:	89 d0                	mov    %edx,%eax
c0106a61:	c1 e0 02             	shl    $0x2,%eax
c0106a64:	01 d0                	add    %edx,%eax
c0106a66:	01 c0                	add    %eax,%eax
c0106a68:	01 d8                	add    %ebx,%eax
c0106a6a:	83 e8 30             	sub    $0x30,%eax
c0106a6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0106a70:	8b 45 10             	mov    0x10(%ebp),%eax
c0106a73:	0f b6 00             	movzbl (%eax),%eax
c0106a76:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0106a79:	83 fb 2f             	cmp    $0x2f,%ebx
c0106a7c:	7e 38                	jle    c0106ab6 <vprintfmt+0xe4>
c0106a7e:	83 fb 39             	cmp    $0x39,%ebx
c0106a81:	7f 33                	jg     c0106ab6 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c0106a83:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0106a86:	eb d4                	jmp    c0106a5c <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0106a88:	8b 45 14             	mov    0x14(%ebp),%eax
c0106a8b:	8d 50 04             	lea    0x4(%eax),%edx
c0106a8e:	89 55 14             	mov    %edx,0x14(%ebp)
c0106a91:	8b 00                	mov    (%eax),%eax
c0106a93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0106a96:	eb 1f                	jmp    c0106ab7 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0106a98:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106a9c:	79 87                	jns    c0106a25 <vprintfmt+0x53>
                width = 0;
c0106a9e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0106aa5:	e9 7b ff ff ff       	jmp    c0106a25 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0106aaa:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0106ab1:	e9 6f ff ff ff       	jmp    c0106a25 <vprintfmt+0x53>
            goto process_precision;
c0106ab6:	90                   	nop

        process_precision:
            if (width < 0)
c0106ab7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106abb:	0f 89 64 ff ff ff    	jns    c0106a25 <vprintfmt+0x53>
                width = precision, precision = -1;
c0106ac1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ac4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106ac7:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0106ace:	e9 52 ff ff ff       	jmp    c0106a25 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0106ad3:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0106ad6:	e9 4a ff ff ff       	jmp    c0106a25 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0106adb:	8b 45 14             	mov    0x14(%ebp),%eax
c0106ade:	8d 50 04             	lea    0x4(%eax),%edx
c0106ae1:	89 55 14             	mov    %edx,0x14(%ebp)
c0106ae4:	8b 00                	mov    (%eax),%eax
c0106ae6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106ae9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106aed:	89 04 24             	mov    %eax,(%esp)
c0106af0:	8b 45 08             	mov    0x8(%ebp),%eax
c0106af3:	ff d0                	call   *%eax
            break;
c0106af5:	e9 a4 02 00 00       	jmp    c0106d9e <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0106afa:	8b 45 14             	mov    0x14(%ebp),%eax
c0106afd:	8d 50 04             	lea    0x4(%eax),%edx
c0106b00:	89 55 14             	mov    %edx,0x14(%ebp)
c0106b03:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0106b05:	85 db                	test   %ebx,%ebx
c0106b07:	79 02                	jns    c0106b0b <vprintfmt+0x139>
                err = -err;
c0106b09:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0106b0b:	83 fb 06             	cmp    $0x6,%ebx
c0106b0e:	7f 0b                	jg     c0106b1b <vprintfmt+0x149>
c0106b10:	8b 34 9d f4 82 10 c0 	mov    -0x3fef7d0c(,%ebx,4),%esi
c0106b17:	85 f6                	test   %esi,%esi
c0106b19:	75 23                	jne    c0106b3e <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0106b1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106b1f:	c7 44 24 08 21 83 10 	movl   $0xc0108321,0x8(%esp)
c0106b26:	c0 
c0106b27:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b31:	89 04 24             	mov    %eax,(%esp)
c0106b34:	e8 6a fe ff ff       	call   c01069a3 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0106b39:	e9 60 02 00 00       	jmp    c0106d9e <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c0106b3e:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0106b42:	c7 44 24 08 2a 83 10 	movl   $0xc010832a,0x8(%esp)
c0106b49:	c0 
c0106b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b51:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b54:	89 04 24             	mov    %eax,(%esp)
c0106b57:	e8 47 fe ff ff       	call   c01069a3 <printfmt>
            break;
c0106b5c:	e9 3d 02 00 00       	jmp    c0106d9e <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0106b61:	8b 45 14             	mov    0x14(%ebp),%eax
c0106b64:	8d 50 04             	lea    0x4(%eax),%edx
c0106b67:	89 55 14             	mov    %edx,0x14(%ebp)
c0106b6a:	8b 30                	mov    (%eax),%esi
c0106b6c:	85 f6                	test   %esi,%esi
c0106b6e:	75 05                	jne    c0106b75 <vprintfmt+0x1a3>
                p = "(null)";
c0106b70:	be 2d 83 10 c0       	mov    $0xc010832d,%esi
            }
            if (width > 0 && padc != '-') {
c0106b75:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106b79:	7e 76                	jle    c0106bf1 <vprintfmt+0x21f>
c0106b7b:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0106b7f:	74 70                	je     c0106bf1 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106b81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b88:	89 34 24             	mov    %esi,(%esp)
c0106b8b:	e8 f6 f7 ff ff       	call   c0106386 <strnlen>
c0106b90:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106b93:	29 c2                	sub    %eax,%edx
c0106b95:	89 d0                	mov    %edx,%eax
c0106b97:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106b9a:	eb 16                	jmp    c0106bb2 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0106b9c:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0106ba0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106ba3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106ba7:	89 04 24             	mov    %eax,(%esp)
c0106baa:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bad:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106baf:	ff 4d e8             	decl   -0x18(%ebp)
c0106bb2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106bb6:	7f e4                	jg     c0106b9c <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106bb8:	eb 37                	jmp    c0106bf1 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0106bba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106bbe:	74 1f                	je     c0106bdf <vprintfmt+0x20d>
c0106bc0:	83 fb 1f             	cmp    $0x1f,%ebx
c0106bc3:	7e 05                	jle    c0106bca <vprintfmt+0x1f8>
c0106bc5:	83 fb 7e             	cmp    $0x7e,%ebx
c0106bc8:	7e 15                	jle    c0106bdf <vprintfmt+0x20d>
                    putch('?', putdat);
c0106bca:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bd1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0106bd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bdb:	ff d0                	call   *%eax
c0106bdd:	eb 0f                	jmp    c0106bee <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0106bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106be2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106be6:	89 1c 24             	mov    %ebx,(%esp)
c0106be9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bec:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106bee:	ff 4d e8             	decl   -0x18(%ebp)
c0106bf1:	89 f0                	mov    %esi,%eax
c0106bf3:	8d 70 01             	lea    0x1(%eax),%esi
c0106bf6:	0f b6 00             	movzbl (%eax),%eax
c0106bf9:	0f be d8             	movsbl %al,%ebx
c0106bfc:	85 db                	test   %ebx,%ebx
c0106bfe:	74 27                	je     c0106c27 <vprintfmt+0x255>
c0106c00:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106c04:	78 b4                	js     c0106bba <vprintfmt+0x1e8>
c0106c06:	ff 4d e4             	decl   -0x1c(%ebp)
c0106c09:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106c0d:	79 ab                	jns    c0106bba <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0106c0f:	eb 16                	jmp    c0106c27 <vprintfmt+0x255>
                putch(' ', putdat);
c0106c11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c18:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0106c1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c22:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0106c24:	ff 4d e8             	decl   -0x18(%ebp)
c0106c27:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106c2b:	7f e4                	jg     c0106c11 <vprintfmt+0x23f>
            }
            break;
c0106c2d:	e9 6c 01 00 00       	jmp    c0106d9e <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0106c32:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106c35:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c39:	8d 45 14             	lea    0x14(%ebp),%eax
c0106c3c:	89 04 24             	mov    %eax,(%esp)
c0106c3f:	e8 18 fd ff ff       	call   c010695c <getint>
c0106c44:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c47:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0106c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106c50:	85 d2                	test   %edx,%edx
c0106c52:	79 26                	jns    c0106c7a <vprintfmt+0x2a8>
                putch('-', putdat);
c0106c54:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c5b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0106c62:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c65:	ff d0                	call   *%eax
                num = -(long long)num;
c0106c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106c6d:	f7 d8                	neg    %eax
c0106c6f:	83 d2 00             	adc    $0x0,%edx
c0106c72:	f7 da                	neg    %edx
c0106c74:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c77:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0106c7a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106c81:	e9 a8 00 00 00       	jmp    c0106d2e <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0106c86:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106c89:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c8d:	8d 45 14             	lea    0x14(%ebp),%eax
c0106c90:	89 04 24             	mov    %eax,(%esp)
c0106c93:	e8 75 fc ff ff       	call   c010690d <getuint>
c0106c98:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c9b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0106c9e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106ca5:	e9 84 00 00 00       	jmp    c0106d2e <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0106caa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106cad:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106cb1:	8d 45 14             	lea    0x14(%ebp),%eax
c0106cb4:	89 04 24             	mov    %eax,(%esp)
c0106cb7:	e8 51 fc ff ff       	call   c010690d <getuint>
c0106cbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106cbf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0106cc2:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0106cc9:	eb 63                	jmp    c0106d2e <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0106ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106cce:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106cd2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0106cd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cdc:	ff d0                	call   *%eax
            putch('x', putdat);
c0106cde:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ce1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ce5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0106cec:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cef:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0106cf1:	8b 45 14             	mov    0x14(%ebp),%eax
c0106cf4:	8d 50 04             	lea    0x4(%eax),%edx
c0106cf7:	89 55 14             	mov    %edx,0x14(%ebp)
c0106cfa:	8b 00                	mov    (%eax),%eax
c0106cfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106cff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0106d06:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0106d0d:	eb 1f                	jmp    c0106d2e <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0106d0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106d12:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d16:	8d 45 14             	lea    0x14(%ebp),%eax
c0106d19:	89 04 24             	mov    %eax,(%esp)
c0106d1c:	e8 ec fb ff ff       	call   c010690d <getuint>
c0106d21:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106d24:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0106d27:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0106d2e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0106d32:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d35:	89 54 24 18          	mov    %edx,0x18(%esp)
c0106d39:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106d3c:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106d40:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106d44:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d47:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106d4a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106d4e:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106d52:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d55:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d59:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d5c:	89 04 24             	mov    %eax,(%esp)
c0106d5f:	e8 a4 fa ff ff       	call   c0106808 <printnum>
            break;
c0106d64:	eb 38                	jmp    c0106d9e <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0106d66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d6d:	89 1c 24             	mov    %ebx,(%esp)
c0106d70:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d73:	ff d0                	call   *%eax
            break;
c0106d75:	eb 27                	jmp    c0106d9e <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0106d77:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d7a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d7e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0106d85:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d88:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0106d8a:	ff 4d 10             	decl   0x10(%ebp)
c0106d8d:	eb 03                	jmp    c0106d92 <vprintfmt+0x3c0>
c0106d8f:	ff 4d 10             	decl   0x10(%ebp)
c0106d92:	8b 45 10             	mov    0x10(%ebp),%eax
c0106d95:	48                   	dec    %eax
c0106d96:	0f b6 00             	movzbl (%eax),%eax
c0106d99:	3c 25                	cmp    $0x25,%al
c0106d9b:	75 f2                	jne    c0106d8f <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0106d9d:	90                   	nop
    while (1) {
c0106d9e:	e9 37 fc ff ff       	jmp    c01069da <vprintfmt+0x8>
                return;
c0106da3:	90                   	nop
        }
    }
}
c0106da4:	83 c4 40             	add    $0x40,%esp
c0106da7:	5b                   	pop    %ebx
c0106da8:	5e                   	pop    %esi
c0106da9:	5d                   	pop    %ebp
c0106daa:	c3                   	ret    

c0106dab <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0106dab:	55                   	push   %ebp
c0106dac:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0106dae:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106db1:	8b 40 08             	mov    0x8(%eax),%eax
c0106db4:	8d 50 01             	lea    0x1(%eax),%edx
c0106db7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106dba:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106dc0:	8b 10                	mov    (%eax),%edx
c0106dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106dc5:	8b 40 04             	mov    0x4(%eax),%eax
c0106dc8:	39 c2                	cmp    %eax,%edx
c0106dca:	73 12                	jae    c0106dde <sprintputch+0x33>
        *b->buf ++ = ch;
c0106dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106dcf:	8b 00                	mov    (%eax),%eax
c0106dd1:	8d 48 01             	lea    0x1(%eax),%ecx
c0106dd4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106dd7:	89 0a                	mov    %ecx,(%edx)
c0106dd9:	8b 55 08             	mov    0x8(%ebp),%edx
c0106ddc:	88 10                	mov    %dl,(%eax)
    }
}
c0106dde:	90                   	nop
c0106ddf:	5d                   	pop    %ebp
c0106de0:	c3                   	ret    

c0106de1 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0106de1:	55                   	push   %ebp
c0106de2:	89 e5                	mov    %esp,%ebp
c0106de4:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0106de7:	8d 45 14             	lea    0x14(%ebp),%eax
c0106dea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0106ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106df0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106df4:	8b 45 10             	mov    0x10(%ebp),%eax
c0106df7:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106dfe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106e02:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e05:	89 04 24             	mov    %eax,(%esp)
c0106e08:	e8 08 00 00 00       	call   c0106e15 <vsnprintf>
c0106e0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0106e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106e13:	c9                   	leave  
c0106e14:	c3                   	ret    

c0106e15 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0106e15:	55                   	push   %ebp
c0106e16:	89 e5                	mov    %esp,%ebp
c0106e18:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0106e1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106e21:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e24:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106e27:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e2a:	01 d0                	add    %edx,%eax
c0106e2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106e2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0106e36:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106e3a:	74 0a                	je     c0106e46 <vsnprintf+0x31>
c0106e3c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e42:	39 c2                	cmp    %eax,%edx
c0106e44:	76 07                	jbe    c0106e4d <vsnprintf+0x38>
        return -E_INVAL;
c0106e46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0106e4b:	eb 2a                	jmp    c0106e77 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0106e4d:	8b 45 14             	mov    0x14(%ebp),%eax
c0106e50:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106e54:	8b 45 10             	mov    0x10(%ebp),%eax
c0106e57:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106e5b:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0106e5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106e62:	c7 04 24 ab 6d 10 c0 	movl   $0xc0106dab,(%esp)
c0106e69:	e8 64 fb ff ff       	call   c01069d2 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0106e6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e71:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0106e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106e77:	c9                   	leave  
c0106e78:	c3                   	ret    
