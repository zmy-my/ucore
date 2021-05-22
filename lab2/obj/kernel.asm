
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
c010005d:	e8 f9 65 00 00       	call   c010665b <memset>

    cons_init();                // init the console
c0100062:	e8 80 15 00 00       	call   c01015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 60 6e 10 c0 	movl   $0xc0106e60,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 7c 6e 10 c0 	movl   $0xc0106e7c,(%esp)
c010007c:	e8 11 02 00 00       	call   c0100292 <cprintf>

    print_kerninfo();
c0100081:	e8 b2 08 00 00       	call   c0100938 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 89 00 00 00       	call   c0100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 9a 30 00 00       	call   c010312a <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 b7 16 00 00       	call   c010174c <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 17 18 00 00       	call   c01018b1 <idt_init>

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
c0100162:	c7 04 24 81 6e 10 c0 	movl   $0xc0106e81,(%esp)
c0100169:	e8 24 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100172:	89 c2                	mov    %eax,%edx
c0100174:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 8f 6e 10 c0 	movl   $0xc0106e8f,(%esp)
c0100188:	e8 05 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	89 c2                	mov    %eax,%edx
c0100193:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c0100198:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a0:	c7 04 24 9d 6e 10 c0 	movl   $0xc0106e9d,(%esp)
c01001a7:	e8 e6 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b0:	89 c2                	mov    %eax,%edx
c01001b2:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bf:	c7 04 24 ab 6e 10 c0 	movl   $0xc0106eab,(%esp)
c01001c6:	e8 c7 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001cf:	89 c2                	mov    %eax,%edx
c01001d1:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001de:	c7 04 24 b9 6e 10 c0 	movl   $0xc0106eb9,(%esp)
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
c010020f:	c7 04 24 c8 6e 10 c0 	movl   $0xc0106ec8,(%esp)
c0100216:	e8 77 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_user();
c010021b:	e8 d8 ff ff ff       	call   c01001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100220:	e8 15 ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100225:	c7 04 24 e8 6e 10 c0 	movl   $0xc0106ee8,(%esp)
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
c0100288:	e8 21 67 00 00       	call   c01069ae <vprintfmt>
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
c0100347:	c7 04 24 07 6f 10 c0 	movl   $0xc0106f07,(%esp)
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
c0100416:	c7 04 24 0a 6f 10 c0 	movl   $0xc0106f0a,(%esp)
c010041d:	e8 70 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c0100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100425:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100429:	8b 45 10             	mov    0x10(%ebp),%eax
c010042c:	89 04 24             	mov    %eax,(%esp)
c010042f:	e8 2b fe ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c0100434:	c7 04 24 26 6f 10 c0 	movl   $0xc0106f26,(%esp)
c010043b:	e8 52 fe ff ff       	call   c0100292 <cprintf>
    
    cprintf("stack trackback:\n");
c0100440:	c7 04 24 28 6f 10 c0 	movl   $0xc0106f28,(%esp)
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
c0100481:	c7 04 24 3a 6f 10 c0 	movl   $0xc0106f3a,(%esp)
c0100488:	e8 05 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c010048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100490:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100494:	8b 45 10             	mov    0x10(%ebp),%eax
c0100497:	89 04 24             	mov    %eax,(%esp)
c010049a:	e8 c0 fd ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c010049f:	c7 04 24 26 6f 10 c0 	movl   $0xc0106f26,(%esp)
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
c010060f:	c7 00 58 6f 10 c0    	movl   $0xc0106f58,(%eax)
    info->eip_line = 0;
c0100615:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010061f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100622:	c7 40 08 58 6f 10 c0 	movl   $0xc0106f58,0x8(%eax)
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
c0100646:	c7 45 f4 4c 84 10 c0 	movl   $0xc010844c,-0xc(%ebp)
    stab_end = __STAB_END__;
c010064d:	c7 45 f0 d0 4d 11 c0 	movl   $0xc0114dd0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100654:	c7 45 ec d1 4d 11 c0 	movl   $0xc0114dd1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010065b:	c7 45 e8 ba 7a 11 c0 	movl   $0xc0117aba,-0x18(%ebp)

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
c01007b6:	e8 1c 5d 00 00       	call   c01064d7 <strfind>
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
c010093e:	c7 04 24 62 6f 10 c0 	movl   $0xc0106f62,(%esp)
c0100945:	e8 48 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010094a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100951:	c0 
c0100952:	c7 04 24 7b 6f 10 c0 	movl   $0xc0106f7b,(%esp)
c0100959:	e8 34 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010095e:	c7 44 24 04 55 6e 10 	movl   $0xc0106e55,0x4(%esp)
c0100965:	c0 
c0100966:	c7 04 24 93 6f 10 c0 	movl   $0xc0106f93,(%esp)
c010096d:	e8 20 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100972:	c7 44 24 04 00 d0 11 	movl   $0xc011d000,0x4(%esp)
c0100979:	c0 
c010097a:	c7 04 24 ab 6f 10 c0 	movl   $0xc0106fab,(%esp)
c0100981:	e8 0c f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100986:	c7 44 24 04 bc df 11 	movl   $0xc011dfbc,0x4(%esp)
c010098d:	c0 
c010098e:	c7 04 24 c3 6f 10 c0 	movl   $0xc0106fc3,(%esp)
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
c01009c0:	c7 04 24 dc 6f 10 c0 	movl   $0xc0106fdc,(%esp)
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
c01009f5:	c7 04 24 06 70 10 c0 	movl   $0xc0107006,(%esp)
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
c0100a63:	c7 04 24 22 70 10 c0 	movl   $0xc0107022,(%esp)
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
c0100ab6:	c7 04 24 34 70 10 c0 	movl   $0xc0107034,(%esp)
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
c0100ae9:	c7 04 24 50 70 10 c0 	movl   $0xc0107050,(%esp)
c0100af0:	e8 9d f7 ff ff       	call   c0100292 <cprintf>
		for(int i=0;i<4;i++){
c0100af5:	ff 45 e8             	incl   -0x18(%ebp)
c0100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100afc:	7e d6                	jle    c0100ad4 <print_stackframe+0x51>
		}
		cprintf("\n");
c0100afe:	c7 04 24 58 70 10 c0 	movl   $0xc0107058,(%esp)
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
c0100b71:	c7 04 24 dc 70 10 c0 	movl   $0xc01070dc,(%esp)
c0100b78:	e8 28 59 00 00       	call   c01064a5 <strchr>
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
c0100b99:	c7 04 24 e1 70 10 c0 	movl   $0xc01070e1,(%esp)
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
c0100bdb:	c7 04 24 dc 70 10 c0 	movl   $0xc01070dc,(%esp)
c0100be2:	e8 be 58 00 00       	call   c01064a5 <strchr>
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
c0100c48:	e8 bb 57 00 00       	call   c0106408 <strcmp>
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
c0100c94:	c7 04 24 ff 70 10 c0 	movl   $0xc01070ff,(%esp)
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
c0100cb1:	c7 04 24 18 71 10 c0 	movl   $0xc0107118,(%esp)
c0100cb8:	e8 d5 f5 ff ff       	call   c0100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cbd:	c7 04 24 40 71 10 c0 	movl   $0xc0107140,(%esp)
c0100cc4:	e8 c9 f5 ff ff       	call   c0100292 <cprintf>

    if (tf != NULL) {
c0100cc9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100ccd:	74 0b                	je     c0100cda <kmonitor+0x2f>
        print_trapframe(tf);
c0100ccf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cd2:	89 04 24             	mov    %eax,(%esp)
c0100cd5:	e8 11 0d 00 00       	call   c01019eb <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cda:	c7 04 24 65 71 10 c0 	movl   $0xc0107165,(%esp)
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
c0100d48:	c7 04 24 69 71 10 c0 	movl   $0xc0107169,(%esp)
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
c0100dd3:	c7 04 24 72 71 10 c0 	movl   $0xc0107172,(%esp)
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
c0101215:	e8 81 54 00 00       	call   c010669b <memmove>
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
c0101595:	c7 04 24 8d 71 10 c0 	movl   $0xc010718d,(%esp)
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
c0101605:	c7 04 24 99 71 10 c0 	movl   $0xc0107199,(%esp)
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
c01018a2:	c7 04 24 c0 71 10 c0 	movl   $0xc01071c0,(%esp)
c01018a9:	e8 e4 e9 ff ff       	call   c0100292 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01018ae:	90                   	nop
c01018af:	c9                   	leave  
c01018b0:	c3                   	ret    

c01018b1 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018b1:	55                   	push   %ebp
c01018b2:	89 e5                	mov    %esp,%ebp
c01018b4:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01018b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018be:	e9 c4 00 00 00       	jmp    c0101987 <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018c6:	8b 04 85 e0 a5 11 c0 	mov    -0x3fee5a20(,%eax,4),%eax
c01018cd:	0f b7 d0             	movzwl %ax,%edx
c01018d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018d3:	66 89 14 c5 80 d6 11 	mov    %dx,-0x3fee2980(,%eax,8)
c01018da:	c0 
c01018db:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018de:	66 c7 04 c5 82 d6 11 	movw   $0x8,-0x3fee297e(,%eax,8)
c01018e5:	c0 08 00 
c01018e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018eb:	0f b6 14 c5 84 d6 11 	movzbl -0x3fee297c(,%eax,8),%edx
c01018f2:	c0 
c01018f3:	80 e2 e0             	and    $0xe0,%dl
c01018f6:	88 14 c5 84 d6 11 c0 	mov    %dl,-0x3fee297c(,%eax,8)
c01018fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101900:	0f b6 14 c5 84 d6 11 	movzbl -0x3fee297c(,%eax,8),%edx
c0101907:	c0 
c0101908:	80 e2 1f             	and    $0x1f,%dl
c010190b:	88 14 c5 84 d6 11 c0 	mov    %dl,-0x3fee297c(,%eax,8)
c0101912:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101915:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c010191c:	c0 
c010191d:	80 e2 f0             	and    $0xf0,%dl
c0101920:	80 ca 0e             	or     $0xe,%dl
c0101923:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c010192a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010192d:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c0101934:	c0 
c0101935:	80 e2 ef             	and    $0xef,%dl
c0101938:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c010193f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101942:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c0101949:	c0 
c010194a:	80 e2 9f             	and    $0x9f,%dl
c010194d:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c0101954:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101957:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c010195e:	c0 
c010195f:	80 ca 80             	or     $0x80,%dl
c0101962:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c0101969:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010196c:	8b 04 85 e0 a5 11 c0 	mov    -0x3fee5a20(,%eax,4),%eax
c0101973:	c1 e8 10             	shr    $0x10,%eax
c0101976:	0f b7 d0             	movzwl %ax,%edx
c0101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197c:	66 89 14 c5 86 d6 11 	mov    %dx,-0x3fee297a(,%eax,8)
c0101983:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0101984:	ff 45 fc             	incl   -0x4(%ebp)
c0101987:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010198a:	3d ff 00 00 00       	cmp    $0xff,%eax
c010198f:	0f 86 2e ff ff ff    	jbe    c01018c3 <idt_init+0x12>
c0101995:	c7 45 f8 60 a5 11 c0 	movl   $0xc011a560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010199c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010199f:	0f 01 18             	lidtl  (%eax)
    }
    lidt(&idt_pd);
}
c01019a2:	90                   	nop
c01019a3:	c9                   	leave  
c01019a4:	c3                   	ret    

c01019a5 <trapname>:

static const char *
trapname(int trapno) {
c01019a5:	55                   	push   %ebp
c01019a6:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01019a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01019ab:	83 f8 13             	cmp    $0x13,%eax
c01019ae:	77 0c                	ja     c01019bc <trapname+0x17>
        return excnames[trapno];
c01019b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01019b3:	8b 04 85 20 75 10 c0 	mov    -0x3fef8ae0(,%eax,4),%eax
c01019ba:	eb 18                	jmp    c01019d4 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01019bc:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01019c0:	7e 0d                	jle    c01019cf <trapname+0x2a>
c01019c2:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01019c6:	7f 07                	jg     c01019cf <trapname+0x2a>
        return "Hardware Interrupt";
c01019c8:	b8 ca 71 10 c0       	mov    $0xc01071ca,%eax
c01019cd:	eb 05                	jmp    c01019d4 <trapname+0x2f>
    }
    return "(unknown trap)";
c01019cf:	b8 dd 71 10 c0       	mov    $0xc01071dd,%eax
}
c01019d4:	5d                   	pop    %ebp
c01019d5:	c3                   	ret    

c01019d6 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01019d6:	55                   	push   %ebp
c01019d7:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01019d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01019dc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01019e0:	83 f8 08             	cmp    $0x8,%eax
c01019e3:	0f 94 c0             	sete   %al
c01019e6:	0f b6 c0             	movzbl %al,%eax
}
c01019e9:	5d                   	pop    %ebp
c01019ea:	c3                   	ret    

c01019eb <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01019eb:	55                   	push   %ebp
c01019ec:	89 e5                	mov    %esp,%ebp
c01019ee:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01019f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01019f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019f8:	c7 04 24 1e 72 10 c0 	movl   $0xc010721e,(%esp)
c01019ff:	e8 8e e8 ff ff       	call   c0100292 <cprintf>
    print_regs(&tf->tf_regs);
c0101a04:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a07:	89 04 24             	mov    %eax,(%esp)
c0101a0a:	e8 8f 01 00 00       	call   c0101b9e <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a12:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a1a:	c7 04 24 2f 72 10 c0 	movl   $0xc010722f,(%esp)
c0101a21:	e8 6c e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a26:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a29:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a31:	c7 04 24 42 72 10 c0 	movl   $0xc0107242,(%esp)
c0101a38:	e8 55 e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a40:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101a44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a48:	c7 04 24 55 72 10 c0 	movl   $0xc0107255,(%esp)
c0101a4f:	e8 3e e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101a54:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a57:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a5f:	c7 04 24 68 72 10 c0 	movl   $0xc0107268,(%esp)
c0101a66:	e8 27 e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101a6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a6e:	8b 40 30             	mov    0x30(%eax),%eax
c0101a71:	89 04 24             	mov    %eax,(%esp)
c0101a74:	e8 2c ff ff ff       	call   c01019a5 <trapname>
c0101a79:	89 c2                	mov    %eax,%edx
c0101a7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a7e:	8b 40 30             	mov    0x30(%eax),%eax
c0101a81:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101a85:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a89:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0101a90:	e8 fd e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101a95:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a98:	8b 40 34             	mov    0x34(%eax),%eax
c0101a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a9f:	c7 04 24 8d 72 10 c0 	movl   $0xc010728d,(%esp)
c0101aa6:	e8 e7 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101aab:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aae:	8b 40 38             	mov    0x38(%eax),%eax
c0101ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ab5:	c7 04 24 9c 72 10 c0 	movl   $0xc010729c,(%esp)
c0101abc:	e8 d1 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101ac1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101acc:	c7 04 24 ab 72 10 c0 	movl   $0xc01072ab,(%esp)
c0101ad3:	e8 ba e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101adb:	8b 40 40             	mov    0x40(%eax),%eax
c0101ade:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae2:	c7 04 24 be 72 10 c0 	movl   $0xc01072be,(%esp)
c0101ae9:	e8 a4 e7 ff ff       	call   c0100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101aee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101af5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101afc:	eb 3d                	jmp    c0101b3b <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101afe:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b01:	8b 50 40             	mov    0x40(%eax),%edx
c0101b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b07:	21 d0                	and    %edx,%eax
c0101b09:	85 c0                	test   %eax,%eax
c0101b0b:	74 28                	je     c0101b35 <print_trapframe+0x14a>
c0101b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b10:	8b 04 85 80 a5 11 c0 	mov    -0x3fee5a80(,%eax,4),%eax
c0101b17:	85 c0                	test   %eax,%eax
c0101b19:	74 1a                	je     c0101b35 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0101b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b1e:	8b 04 85 80 a5 11 c0 	mov    -0x3fee5a80(,%eax,4),%eax
c0101b25:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b29:	c7 04 24 cd 72 10 c0 	movl   $0xc01072cd,(%esp)
c0101b30:	e8 5d e7 ff ff       	call   c0100292 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b35:	ff 45 f4             	incl   -0xc(%ebp)
c0101b38:	d1 65 f0             	shll   -0x10(%ebp)
c0101b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b3e:	83 f8 17             	cmp    $0x17,%eax
c0101b41:	76 bb                	jbe    c0101afe <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101b43:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b46:	8b 40 40             	mov    0x40(%eax),%eax
c0101b49:	c1 e8 0c             	shr    $0xc,%eax
c0101b4c:	83 e0 03             	and    $0x3,%eax
c0101b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b53:	c7 04 24 d1 72 10 c0 	movl   $0xc01072d1,(%esp)
c0101b5a:	e8 33 e7 ff ff       	call   c0100292 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101b5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b62:	89 04 24             	mov    %eax,(%esp)
c0101b65:	e8 6c fe ff ff       	call   c01019d6 <trap_in_kernel>
c0101b6a:	85 c0                	test   %eax,%eax
c0101b6c:	75 2d                	jne    c0101b9b <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b71:	8b 40 44             	mov    0x44(%eax),%eax
c0101b74:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b78:	c7 04 24 da 72 10 c0 	movl   $0xc01072da,(%esp)
c0101b7f:	e8 0e e7 ff ff       	call   c0100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101b84:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b87:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b8f:	c7 04 24 e9 72 10 c0 	movl   $0xc01072e9,(%esp)
c0101b96:	e8 f7 e6 ff ff       	call   c0100292 <cprintf>
    }
}
c0101b9b:	90                   	nop
c0101b9c:	c9                   	leave  
c0101b9d:	c3                   	ret    

c0101b9e <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101b9e:	55                   	push   %ebp
c0101b9f:	89 e5                	mov    %esp,%ebp
c0101ba1:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101ba4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba7:	8b 00                	mov    (%eax),%eax
c0101ba9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bad:	c7 04 24 fc 72 10 c0 	movl   $0xc01072fc,(%esp)
c0101bb4:	e8 d9 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bbc:	8b 40 04             	mov    0x4(%eax),%eax
c0101bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bc3:	c7 04 24 0b 73 10 c0 	movl   $0xc010730b,(%esp)
c0101bca:	e8 c3 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101bcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd2:	8b 40 08             	mov    0x8(%eax),%eax
c0101bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bd9:	c7 04 24 1a 73 10 c0 	movl   $0xc010731a,(%esp)
c0101be0:	e8 ad e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101be5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be8:	8b 40 0c             	mov    0xc(%eax),%eax
c0101beb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bef:	c7 04 24 29 73 10 c0 	movl   $0xc0107329,(%esp)
c0101bf6:	e8 97 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101bfb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bfe:	8b 40 10             	mov    0x10(%eax),%eax
c0101c01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c05:	c7 04 24 38 73 10 c0 	movl   $0xc0107338,(%esp)
c0101c0c:	e8 81 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c11:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c14:	8b 40 14             	mov    0x14(%eax),%eax
c0101c17:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c1b:	c7 04 24 47 73 10 c0 	movl   $0xc0107347,(%esp)
c0101c22:	e8 6b e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c27:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c2a:	8b 40 18             	mov    0x18(%eax),%eax
c0101c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c31:	c7 04 24 56 73 10 c0 	movl   $0xc0107356,(%esp)
c0101c38:	e8 55 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101c3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c40:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101c43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c47:	c7 04 24 65 73 10 c0 	movl   $0xc0107365,(%esp)
c0101c4e:	e8 3f e6 ff ff       	call   c0100292 <cprintf>
}
c0101c53:	90                   	nop
c0101c54:	c9                   	leave  
c0101c55:	c3                   	ret    

c0101c56 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101c56:	55                   	push   %ebp
c0101c57:	89 e5                	mov    %esp,%ebp
c0101c59:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101c5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c5f:	8b 40 30             	mov    0x30(%eax),%eax
c0101c62:	83 f8 2f             	cmp    $0x2f,%eax
c0101c65:	77 21                	ja     c0101c88 <trap_dispatch+0x32>
c0101c67:	83 f8 2e             	cmp    $0x2e,%eax
c0101c6a:	0f 83 0c 01 00 00    	jae    c0101d7c <trap_dispatch+0x126>
c0101c70:	83 f8 21             	cmp    $0x21,%eax
c0101c73:	0f 84 8c 00 00 00    	je     c0101d05 <trap_dispatch+0xaf>
c0101c79:	83 f8 24             	cmp    $0x24,%eax
c0101c7c:	74 61                	je     c0101cdf <trap_dispatch+0x89>
c0101c7e:	83 f8 20             	cmp    $0x20,%eax
c0101c81:	74 16                	je     c0101c99 <trap_dispatch+0x43>
c0101c83:	e9 bf 00 00 00       	jmp    c0101d47 <trap_dispatch+0xf1>
c0101c88:	83 e8 78             	sub    $0x78,%eax
c0101c8b:	83 f8 01             	cmp    $0x1,%eax
c0101c8e:	0f 87 b3 00 00 00    	ja     c0101d47 <trap_dispatch+0xf1>
c0101c94:	e9 92 00 00 00       	jmp    c0101d2b <trap_dispatch+0xd5>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101c99:	a1 0c df 11 c0       	mov    0xc011df0c,%eax
c0101c9e:	40                   	inc    %eax
c0101c9f:	a3 0c df 11 c0       	mov    %eax,0xc011df0c
        if (ticks % TICK_NUM == 0) {
c0101ca4:	8b 0d 0c df 11 c0    	mov    0xc011df0c,%ecx
c0101caa:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101caf:	89 c8                	mov    %ecx,%eax
c0101cb1:	f7 e2                	mul    %edx
c0101cb3:	c1 ea 05             	shr    $0x5,%edx
c0101cb6:	89 d0                	mov    %edx,%eax
c0101cb8:	c1 e0 02             	shl    $0x2,%eax
c0101cbb:	01 d0                	add    %edx,%eax
c0101cbd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101cc4:	01 d0                	add    %edx,%eax
c0101cc6:	c1 e0 02             	shl    $0x2,%eax
c0101cc9:	29 c1                	sub    %eax,%ecx
c0101ccb:	89 ca                	mov    %ecx,%edx
c0101ccd:	85 d2                	test   %edx,%edx
c0101ccf:	0f 85 aa 00 00 00    	jne    c0101d7f <trap_dispatch+0x129>
            print_ticks();
c0101cd5:	e8 ba fb ff ff       	call   c0101894 <print_ticks>
        }
        break;
c0101cda:	e9 a0 00 00 00       	jmp    c0101d7f <trap_dispatch+0x129>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101cdf:	e8 6d f9 ff ff       	call   c0101651 <cons_getc>
c0101ce4:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101ce7:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101ceb:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101cef:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101cf3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cf7:	c7 04 24 74 73 10 c0 	movl   $0xc0107374,(%esp)
c0101cfe:	e8 8f e5 ff ff       	call   c0100292 <cprintf>
        break;
c0101d03:	eb 7b                	jmp    c0101d80 <trap_dispatch+0x12a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d05:	e8 47 f9 ff ff       	call   c0101651 <cons_getc>
c0101d0a:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d0d:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d11:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d15:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d19:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d1d:	c7 04 24 86 73 10 c0 	movl   $0xc0107386,(%esp)
c0101d24:	e8 69 e5 ff ff       	call   c0100292 <cprintf>
        break;
c0101d29:	eb 55                	jmp    c0101d80 <trap_dispatch+0x12a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101d2b:	c7 44 24 08 95 73 10 	movl   $0xc0107395,0x8(%esp)
c0101d32:	c0 
c0101d33:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
c0101d3a:	00 
c0101d3b:	c7 04 24 a5 73 10 c0 	movl   $0xc01073a5,(%esp)
c0101d42:	e8 a2 e6 ff ff       	call   c01003e9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101d47:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d4a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101d4e:	83 e0 03             	and    $0x3,%eax
c0101d51:	85 c0                	test   %eax,%eax
c0101d53:	75 2b                	jne    c0101d80 <trap_dispatch+0x12a>
            print_trapframe(tf);
c0101d55:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d58:	89 04 24             	mov    %eax,(%esp)
c0101d5b:	e8 8b fc ff ff       	call   c01019eb <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101d60:	c7 44 24 08 b6 73 10 	movl   $0xc01073b6,0x8(%esp)
c0101d67:	c0 
c0101d68:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0101d6f:	00 
c0101d70:	c7 04 24 a5 73 10 c0 	movl   $0xc01073a5,(%esp)
c0101d77:	e8 6d e6 ff ff       	call   c01003e9 <__panic>
        break;
c0101d7c:	90                   	nop
c0101d7d:	eb 01                	jmp    c0101d80 <trap_dispatch+0x12a>
        break;
c0101d7f:	90                   	nop
        }
    }
}
c0101d80:	90                   	nop
c0101d81:	c9                   	leave  
c0101d82:	c3                   	ret    

c0101d83 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101d83:	55                   	push   %ebp
c0101d84:	89 e5                	mov    %esp,%ebp
c0101d86:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101d89:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d8c:	89 04 24             	mov    %eax,(%esp)
c0101d8f:	e8 c2 fe ff ff       	call   c0101c56 <trap_dispatch>
}
c0101d94:	90                   	nop
c0101d95:	c9                   	leave  
c0101d96:	c3                   	ret    

c0101d97 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101d97:	6a 00                	push   $0x0
  pushl $0
c0101d99:	6a 00                	push   $0x0
  jmp __alltraps
c0101d9b:	e9 69 0a 00 00       	jmp    c0102809 <__alltraps>

c0101da0 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101da0:	6a 00                	push   $0x0
  pushl $1
c0101da2:	6a 01                	push   $0x1
  jmp __alltraps
c0101da4:	e9 60 0a 00 00       	jmp    c0102809 <__alltraps>

c0101da9 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101da9:	6a 00                	push   $0x0
  pushl $2
c0101dab:	6a 02                	push   $0x2
  jmp __alltraps
c0101dad:	e9 57 0a 00 00       	jmp    c0102809 <__alltraps>

c0101db2 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101db2:	6a 00                	push   $0x0
  pushl $3
c0101db4:	6a 03                	push   $0x3
  jmp __alltraps
c0101db6:	e9 4e 0a 00 00       	jmp    c0102809 <__alltraps>

c0101dbb <vector4>:
.globl vector4
vector4:
  pushl $0
c0101dbb:	6a 00                	push   $0x0
  pushl $4
c0101dbd:	6a 04                	push   $0x4
  jmp __alltraps
c0101dbf:	e9 45 0a 00 00       	jmp    c0102809 <__alltraps>

c0101dc4 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101dc4:	6a 00                	push   $0x0
  pushl $5
c0101dc6:	6a 05                	push   $0x5
  jmp __alltraps
c0101dc8:	e9 3c 0a 00 00       	jmp    c0102809 <__alltraps>

c0101dcd <vector6>:
.globl vector6
vector6:
  pushl $0
c0101dcd:	6a 00                	push   $0x0
  pushl $6
c0101dcf:	6a 06                	push   $0x6
  jmp __alltraps
c0101dd1:	e9 33 0a 00 00       	jmp    c0102809 <__alltraps>

c0101dd6 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101dd6:	6a 00                	push   $0x0
  pushl $7
c0101dd8:	6a 07                	push   $0x7
  jmp __alltraps
c0101dda:	e9 2a 0a 00 00       	jmp    c0102809 <__alltraps>

c0101ddf <vector8>:
.globl vector8
vector8:
  pushl $8
c0101ddf:	6a 08                	push   $0x8
  jmp __alltraps
c0101de1:	e9 23 0a 00 00       	jmp    c0102809 <__alltraps>

c0101de6 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101de6:	6a 00                	push   $0x0
  pushl $9
c0101de8:	6a 09                	push   $0x9
  jmp __alltraps
c0101dea:	e9 1a 0a 00 00       	jmp    c0102809 <__alltraps>

c0101def <vector10>:
.globl vector10
vector10:
  pushl $10
c0101def:	6a 0a                	push   $0xa
  jmp __alltraps
c0101df1:	e9 13 0a 00 00       	jmp    c0102809 <__alltraps>

c0101df6 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101df6:	6a 0b                	push   $0xb
  jmp __alltraps
c0101df8:	e9 0c 0a 00 00       	jmp    c0102809 <__alltraps>

c0101dfd <vector12>:
.globl vector12
vector12:
  pushl $12
c0101dfd:	6a 0c                	push   $0xc
  jmp __alltraps
c0101dff:	e9 05 0a 00 00       	jmp    c0102809 <__alltraps>

c0101e04 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e04:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e06:	e9 fe 09 00 00       	jmp    c0102809 <__alltraps>

c0101e0b <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e0b:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e0d:	e9 f7 09 00 00       	jmp    c0102809 <__alltraps>

c0101e12 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e12:	6a 00                	push   $0x0
  pushl $15
c0101e14:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e16:	e9 ee 09 00 00       	jmp    c0102809 <__alltraps>

c0101e1b <vector16>:
.globl vector16
vector16:
  pushl $0
c0101e1b:	6a 00                	push   $0x0
  pushl $16
c0101e1d:	6a 10                	push   $0x10
  jmp __alltraps
c0101e1f:	e9 e5 09 00 00       	jmp    c0102809 <__alltraps>

c0101e24 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101e24:	6a 11                	push   $0x11
  jmp __alltraps
c0101e26:	e9 de 09 00 00       	jmp    c0102809 <__alltraps>

c0101e2b <vector18>:
.globl vector18
vector18:
  pushl $0
c0101e2b:	6a 00                	push   $0x0
  pushl $18
c0101e2d:	6a 12                	push   $0x12
  jmp __alltraps
c0101e2f:	e9 d5 09 00 00       	jmp    c0102809 <__alltraps>

c0101e34 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101e34:	6a 00                	push   $0x0
  pushl $19
c0101e36:	6a 13                	push   $0x13
  jmp __alltraps
c0101e38:	e9 cc 09 00 00       	jmp    c0102809 <__alltraps>

c0101e3d <vector20>:
.globl vector20
vector20:
  pushl $0
c0101e3d:	6a 00                	push   $0x0
  pushl $20
c0101e3f:	6a 14                	push   $0x14
  jmp __alltraps
c0101e41:	e9 c3 09 00 00       	jmp    c0102809 <__alltraps>

c0101e46 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101e46:	6a 00                	push   $0x0
  pushl $21
c0101e48:	6a 15                	push   $0x15
  jmp __alltraps
c0101e4a:	e9 ba 09 00 00       	jmp    c0102809 <__alltraps>

c0101e4f <vector22>:
.globl vector22
vector22:
  pushl $0
c0101e4f:	6a 00                	push   $0x0
  pushl $22
c0101e51:	6a 16                	push   $0x16
  jmp __alltraps
c0101e53:	e9 b1 09 00 00       	jmp    c0102809 <__alltraps>

c0101e58 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101e58:	6a 00                	push   $0x0
  pushl $23
c0101e5a:	6a 17                	push   $0x17
  jmp __alltraps
c0101e5c:	e9 a8 09 00 00       	jmp    c0102809 <__alltraps>

c0101e61 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101e61:	6a 00                	push   $0x0
  pushl $24
c0101e63:	6a 18                	push   $0x18
  jmp __alltraps
c0101e65:	e9 9f 09 00 00       	jmp    c0102809 <__alltraps>

c0101e6a <vector25>:
.globl vector25
vector25:
  pushl $0
c0101e6a:	6a 00                	push   $0x0
  pushl $25
c0101e6c:	6a 19                	push   $0x19
  jmp __alltraps
c0101e6e:	e9 96 09 00 00       	jmp    c0102809 <__alltraps>

c0101e73 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101e73:	6a 00                	push   $0x0
  pushl $26
c0101e75:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101e77:	e9 8d 09 00 00       	jmp    c0102809 <__alltraps>

c0101e7c <vector27>:
.globl vector27
vector27:
  pushl $0
c0101e7c:	6a 00                	push   $0x0
  pushl $27
c0101e7e:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101e80:	e9 84 09 00 00       	jmp    c0102809 <__alltraps>

c0101e85 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101e85:	6a 00                	push   $0x0
  pushl $28
c0101e87:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101e89:	e9 7b 09 00 00       	jmp    c0102809 <__alltraps>

c0101e8e <vector29>:
.globl vector29
vector29:
  pushl $0
c0101e8e:	6a 00                	push   $0x0
  pushl $29
c0101e90:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101e92:	e9 72 09 00 00       	jmp    c0102809 <__alltraps>

c0101e97 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101e97:	6a 00                	push   $0x0
  pushl $30
c0101e99:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101e9b:	e9 69 09 00 00       	jmp    c0102809 <__alltraps>

c0101ea0 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101ea0:	6a 00                	push   $0x0
  pushl $31
c0101ea2:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101ea4:	e9 60 09 00 00       	jmp    c0102809 <__alltraps>

c0101ea9 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101ea9:	6a 00                	push   $0x0
  pushl $32
c0101eab:	6a 20                	push   $0x20
  jmp __alltraps
c0101ead:	e9 57 09 00 00       	jmp    c0102809 <__alltraps>

c0101eb2 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101eb2:	6a 00                	push   $0x0
  pushl $33
c0101eb4:	6a 21                	push   $0x21
  jmp __alltraps
c0101eb6:	e9 4e 09 00 00       	jmp    c0102809 <__alltraps>

c0101ebb <vector34>:
.globl vector34
vector34:
  pushl $0
c0101ebb:	6a 00                	push   $0x0
  pushl $34
c0101ebd:	6a 22                	push   $0x22
  jmp __alltraps
c0101ebf:	e9 45 09 00 00       	jmp    c0102809 <__alltraps>

c0101ec4 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101ec4:	6a 00                	push   $0x0
  pushl $35
c0101ec6:	6a 23                	push   $0x23
  jmp __alltraps
c0101ec8:	e9 3c 09 00 00       	jmp    c0102809 <__alltraps>

c0101ecd <vector36>:
.globl vector36
vector36:
  pushl $0
c0101ecd:	6a 00                	push   $0x0
  pushl $36
c0101ecf:	6a 24                	push   $0x24
  jmp __alltraps
c0101ed1:	e9 33 09 00 00       	jmp    c0102809 <__alltraps>

c0101ed6 <vector37>:
.globl vector37
vector37:
  pushl $0
c0101ed6:	6a 00                	push   $0x0
  pushl $37
c0101ed8:	6a 25                	push   $0x25
  jmp __alltraps
c0101eda:	e9 2a 09 00 00       	jmp    c0102809 <__alltraps>

c0101edf <vector38>:
.globl vector38
vector38:
  pushl $0
c0101edf:	6a 00                	push   $0x0
  pushl $38
c0101ee1:	6a 26                	push   $0x26
  jmp __alltraps
c0101ee3:	e9 21 09 00 00       	jmp    c0102809 <__alltraps>

c0101ee8 <vector39>:
.globl vector39
vector39:
  pushl $0
c0101ee8:	6a 00                	push   $0x0
  pushl $39
c0101eea:	6a 27                	push   $0x27
  jmp __alltraps
c0101eec:	e9 18 09 00 00       	jmp    c0102809 <__alltraps>

c0101ef1 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101ef1:	6a 00                	push   $0x0
  pushl $40
c0101ef3:	6a 28                	push   $0x28
  jmp __alltraps
c0101ef5:	e9 0f 09 00 00       	jmp    c0102809 <__alltraps>

c0101efa <vector41>:
.globl vector41
vector41:
  pushl $0
c0101efa:	6a 00                	push   $0x0
  pushl $41
c0101efc:	6a 29                	push   $0x29
  jmp __alltraps
c0101efe:	e9 06 09 00 00       	jmp    c0102809 <__alltraps>

c0101f03 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f03:	6a 00                	push   $0x0
  pushl $42
c0101f05:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f07:	e9 fd 08 00 00       	jmp    c0102809 <__alltraps>

c0101f0c <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f0c:	6a 00                	push   $0x0
  pushl $43
c0101f0e:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f10:	e9 f4 08 00 00       	jmp    c0102809 <__alltraps>

c0101f15 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f15:	6a 00                	push   $0x0
  pushl $44
c0101f17:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101f19:	e9 eb 08 00 00       	jmp    c0102809 <__alltraps>

c0101f1e <vector45>:
.globl vector45
vector45:
  pushl $0
c0101f1e:	6a 00                	push   $0x0
  pushl $45
c0101f20:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101f22:	e9 e2 08 00 00       	jmp    c0102809 <__alltraps>

c0101f27 <vector46>:
.globl vector46
vector46:
  pushl $0
c0101f27:	6a 00                	push   $0x0
  pushl $46
c0101f29:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101f2b:	e9 d9 08 00 00       	jmp    c0102809 <__alltraps>

c0101f30 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101f30:	6a 00                	push   $0x0
  pushl $47
c0101f32:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101f34:	e9 d0 08 00 00       	jmp    c0102809 <__alltraps>

c0101f39 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101f39:	6a 00                	push   $0x0
  pushl $48
c0101f3b:	6a 30                	push   $0x30
  jmp __alltraps
c0101f3d:	e9 c7 08 00 00       	jmp    c0102809 <__alltraps>

c0101f42 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101f42:	6a 00                	push   $0x0
  pushl $49
c0101f44:	6a 31                	push   $0x31
  jmp __alltraps
c0101f46:	e9 be 08 00 00       	jmp    c0102809 <__alltraps>

c0101f4b <vector50>:
.globl vector50
vector50:
  pushl $0
c0101f4b:	6a 00                	push   $0x0
  pushl $50
c0101f4d:	6a 32                	push   $0x32
  jmp __alltraps
c0101f4f:	e9 b5 08 00 00       	jmp    c0102809 <__alltraps>

c0101f54 <vector51>:
.globl vector51
vector51:
  pushl $0
c0101f54:	6a 00                	push   $0x0
  pushl $51
c0101f56:	6a 33                	push   $0x33
  jmp __alltraps
c0101f58:	e9 ac 08 00 00       	jmp    c0102809 <__alltraps>

c0101f5d <vector52>:
.globl vector52
vector52:
  pushl $0
c0101f5d:	6a 00                	push   $0x0
  pushl $52
c0101f5f:	6a 34                	push   $0x34
  jmp __alltraps
c0101f61:	e9 a3 08 00 00       	jmp    c0102809 <__alltraps>

c0101f66 <vector53>:
.globl vector53
vector53:
  pushl $0
c0101f66:	6a 00                	push   $0x0
  pushl $53
c0101f68:	6a 35                	push   $0x35
  jmp __alltraps
c0101f6a:	e9 9a 08 00 00       	jmp    c0102809 <__alltraps>

c0101f6f <vector54>:
.globl vector54
vector54:
  pushl $0
c0101f6f:	6a 00                	push   $0x0
  pushl $54
c0101f71:	6a 36                	push   $0x36
  jmp __alltraps
c0101f73:	e9 91 08 00 00       	jmp    c0102809 <__alltraps>

c0101f78 <vector55>:
.globl vector55
vector55:
  pushl $0
c0101f78:	6a 00                	push   $0x0
  pushl $55
c0101f7a:	6a 37                	push   $0x37
  jmp __alltraps
c0101f7c:	e9 88 08 00 00       	jmp    c0102809 <__alltraps>

c0101f81 <vector56>:
.globl vector56
vector56:
  pushl $0
c0101f81:	6a 00                	push   $0x0
  pushl $56
c0101f83:	6a 38                	push   $0x38
  jmp __alltraps
c0101f85:	e9 7f 08 00 00       	jmp    c0102809 <__alltraps>

c0101f8a <vector57>:
.globl vector57
vector57:
  pushl $0
c0101f8a:	6a 00                	push   $0x0
  pushl $57
c0101f8c:	6a 39                	push   $0x39
  jmp __alltraps
c0101f8e:	e9 76 08 00 00       	jmp    c0102809 <__alltraps>

c0101f93 <vector58>:
.globl vector58
vector58:
  pushl $0
c0101f93:	6a 00                	push   $0x0
  pushl $58
c0101f95:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101f97:	e9 6d 08 00 00       	jmp    c0102809 <__alltraps>

c0101f9c <vector59>:
.globl vector59
vector59:
  pushl $0
c0101f9c:	6a 00                	push   $0x0
  pushl $59
c0101f9e:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101fa0:	e9 64 08 00 00       	jmp    c0102809 <__alltraps>

c0101fa5 <vector60>:
.globl vector60
vector60:
  pushl $0
c0101fa5:	6a 00                	push   $0x0
  pushl $60
c0101fa7:	6a 3c                	push   $0x3c
  jmp __alltraps
c0101fa9:	e9 5b 08 00 00       	jmp    c0102809 <__alltraps>

c0101fae <vector61>:
.globl vector61
vector61:
  pushl $0
c0101fae:	6a 00                	push   $0x0
  pushl $61
c0101fb0:	6a 3d                	push   $0x3d
  jmp __alltraps
c0101fb2:	e9 52 08 00 00       	jmp    c0102809 <__alltraps>

c0101fb7 <vector62>:
.globl vector62
vector62:
  pushl $0
c0101fb7:	6a 00                	push   $0x0
  pushl $62
c0101fb9:	6a 3e                	push   $0x3e
  jmp __alltraps
c0101fbb:	e9 49 08 00 00       	jmp    c0102809 <__alltraps>

c0101fc0 <vector63>:
.globl vector63
vector63:
  pushl $0
c0101fc0:	6a 00                	push   $0x0
  pushl $63
c0101fc2:	6a 3f                	push   $0x3f
  jmp __alltraps
c0101fc4:	e9 40 08 00 00       	jmp    c0102809 <__alltraps>

c0101fc9 <vector64>:
.globl vector64
vector64:
  pushl $0
c0101fc9:	6a 00                	push   $0x0
  pushl $64
c0101fcb:	6a 40                	push   $0x40
  jmp __alltraps
c0101fcd:	e9 37 08 00 00       	jmp    c0102809 <__alltraps>

c0101fd2 <vector65>:
.globl vector65
vector65:
  pushl $0
c0101fd2:	6a 00                	push   $0x0
  pushl $65
c0101fd4:	6a 41                	push   $0x41
  jmp __alltraps
c0101fd6:	e9 2e 08 00 00       	jmp    c0102809 <__alltraps>

c0101fdb <vector66>:
.globl vector66
vector66:
  pushl $0
c0101fdb:	6a 00                	push   $0x0
  pushl $66
c0101fdd:	6a 42                	push   $0x42
  jmp __alltraps
c0101fdf:	e9 25 08 00 00       	jmp    c0102809 <__alltraps>

c0101fe4 <vector67>:
.globl vector67
vector67:
  pushl $0
c0101fe4:	6a 00                	push   $0x0
  pushl $67
c0101fe6:	6a 43                	push   $0x43
  jmp __alltraps
c0101fe8:	e9 1c 08 00 00       	jmp    c0102809 <__alltraps>

c0101fed <vector68>:
.globl vector68
vector68:
  pushl $0
c0101fed:	6a 00                	push   $0x0
  pushl $68
c0101fef:	6a 44                	push   $0x44
  jmp __alltraps
c0101ff1:	e9 13 08 00 00       	jmp    c0102809 <__alltraps>

c0101ff6 <vector69>:
.globl vector69
vector69:
  pushl $0
c0101ff6:	6a 00                	push   $0x0
  pushl $69
c0101ff8:	6a 45                	push   $0x45
  jmp __alltraps
c0101ffa:	e9 0a 08 00 00       	jmp    c0102809 <__alltraps>

c0101fff <vector70>:
.globl vector70
vector70:
  pushl $0
c0101fff:	6a 00                	push   $0x0
  pushl $70
c0102001:	6a 46                	push   $0x46
  jmp __alltraps
c0102003:	e9 01 08 00 00       	jmp    c0102809 <__alltraps>

c0102008 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102008:	6a 00                	push   $0x0
  pushl $71
c010200a:	6a 47                	push   $0x47
  jmp __alltraps
c010200c:	e9 f8 07 00 00       	jmp    c0102809 <__alltraps>

c0102011 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102011:	6a 00                	push   $0x0
  pushl $72
c0102013:	6a 48                	push   $0x48
  jmp __alltraps
c0102015:	e9 ef 07 00 00       	jmp    c0102809 <__alltraps>

c010201a <vector73>:
.globl vector73
vector73:
  pushl $0
c010201a:	6a 00                	push   $0x0
  pushl $73
c010201c:	6a 49                	push   $0x49
  jmp __alltraps
c010201e:	e9 e6 07 00 00       	jmp    c0102809 <__alltraps>

c0102023 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102023:	6a 00                	push   $0x0
  pushl $74
c0102025:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102027:	e9 dd 07 00 00       	jmp    c0102809 <__alltraps>

c010202c <vector75>:
.globl vector75
vector75:
  pushl $0
c010202c:	6a 00                	push   $0x0
  pushl $75
c010202e:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102030:	e9 d4 07 00 00       	jmp    c0102809 <__alltraps>

c0102035 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102035:	6a 00                	push   $0x0
  pushl $76
c0102037:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102039:	e9 cb 07 00 00       	jmp    c0102809 <__alltraps>

c010203e <vector77>:
.globl vector77
vector77:
  pushl $0
c010203e:	6a 00                	push   $0x0
  pushl $77
c0102040:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102042:	e9 c2 07 00 00       	jmp    c0102809 <__alltraps>

c0102047 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102047:	6a 00                	push   $0x0
  pushl $78
c0102049:	6a 4e                	push   $0x4e
  jmp __alltraps
c010204b:	e9 b9 07 00 00       	jmp    c0102809 <__alltraps>

c0102050 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102050:	6a 00                	push   $0x0
  pushl $79
c0102052:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102054:	e9 b0 07 00 00       	jmp    c0102809 <__alltraps>

c0102059 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102059:	6a 00                	push   $0x0
  pushl $80
c010205b:	6a 50                	push   $0x50
  jmp __alltraps
c010205d:	e9 a7 07 00 00       	jmp    c0102809 <__alltraps>

c0102062 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102062:	6a 00                	push   $0x0
  pushl $81
c0102064:	6a 51                	push   $0x51
  jmp __alltraps
c0102066:	e9 9e 07 00 00       	jmp    c0102809 <__alltraps>

c010206b <vector82>:
.globl vector82
vector82:
  pushl $0
c010206b:	6a 00                	push   $0x0
  pushl $82
c010206d:	6a 52                	push   $0x52
  jmp __alltraps
c010206f:	e9 95 07 00 00       	jmp    c0102809 <__alltraps>

c0102074 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102074:	6a 00                	push   $0x0
  pushl $83
c0102076:	6a 53                	push   $0x53
  jmp __alltraps
c0102078:	e9 8c 07 00 00       	jmp    c0102809 <__alltraps>

c010207d <vector84>:
.globl vector84
vector84:
  pushl $0
c010207d:	6a 00                	push   $0x0
  pushl $84
c010207f:	6a 54                	push   $0x54
  jmp __alltraps
c0102081:	e9 83 07 00 00       	jmp    c0102809 <__alltraps>

c0102086 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102086:	6a 00                	push   $0x0
  pushl $85
c0102088:	6a 55                	push   $0x55
  jmp __alltraps
c010208a:	e9 7a 07 00 00       	jmp    c0102809 <__alltraps>

c010208f <vector86>:
.globl vector86
vector86:
  pushl $0
c010208f:	6a 00                	push   $0x0
  pushl $86
c0102091:	6a 56                	push   $0x56
  jmp __alltraps
c0102093:	e9 71 07 00 00       	jmp    c0102809 <__alltraps>

c0102098 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102098:	6a 00                	push   $0x0
  pushl $87
c010209a:	6a 57                	push   $0x57
  jmp __alltraps
c010209c:	e9 68 07 00 00       	jmp    c0102809 <__alltraps>

c01020a1 <vector88>:
.globl vector88
vector88:
  pushl $0
c01020a1:	6a 00                	push   $0x0
  pushl $88
c01020a3:	6a 58                	push   $0x58
  jmp __alltraps
c01020a5:	e9 5f 07 00 00       	jmp    c0102809 <__alltraps>

c01020aa <vector89>:
.globl vector89
vector89:
  pushl $0
c01020aa:	6a 00                	push   $0x0
  pushl $89
c01020ac:	6a 59                	push   $0x59
  jmp __alltraps
c01020ae:	e9 56 07 00 00       	jmp    c0102809 <__alltraps>

c01020b3 <vector90>:
.globl vector90
vector90:
  pushl $0
c01020b3:	6a 00                	push   $0x0
  pushl $90
c01020b5:	6a 5a                	push   $0x5a
  jmp __alltraps
c01020b7:	e9 4d 07 00 00       	jmp    c0102809 <__alltraps>

c01020bc <vector91>:
.globl vector91
vector91:
  pushl $0
c01020bc:	6a 00                	push   $0x0
  pushl $91
c01020be:	6a 5b                	push   $0x5b
  jmp __alltraps
c01020c0:	e9 44 07 00 00       	jmp    c0102809 <__alltraps>

c01020c5 <vector92>:
.globl vector92
vector92:
  pushl $0
c01020c5:	6a 00                	push   $0x0
  pushl $92
c01020c7:	6a 5c                	push   $0x5c
  jmp __alltraps
c01020c9:	e9 3b 07 00 00       	jmp    c0102809 <__alltraps>

c01020ce <vector93>:
.globl vector93
vector93:
  pushl $0
c01020ce:	6a 00                	push   $0x0
  pushl $93
c01020d0:	6a 5d                	push   $0x5d
  jmp __alltraps
c01020d2:	e9 32 07 00 00       	jmp    c0102809 <__alltraps>

c01020d7 <vector94>:
.globl vector94
vector94:
  pushl $0
c01020d7:	6a 00                	push   $0x0
  pushl $94
c01020d9:	6a 5e                	push   $0x5e
  jmp __alltraps
c01020db:	e9 29 07 00 00       	jmp    c0102809 <__alltraps>

c01020e0 <vector95>:
.globl vector95
vector95:
  pushl $0
c01020e0:	6a 00                	push   $0x0
  pushl $95
c01020e2:	6a 5f                	push   $0x5f
  jmp __alltraps
c01020e4:	e9 20 07 00 00       	jmp    c0102809 <__alltraps>

c01020e9 <vector96>:
.globl vector96
vector96:
  pushl $0
c01020e9:	6a 00                	push   $0x0
  pushl $96
c01020eb:	6a 60                	push   $0x60
  jmp __alltraps
c01020ed:	e9 17 07 00 00       	jmp    c0102809 <__alltraps>

c01020f2 <vector97>:
.globl vector97
vector97:
  pushl $0
c01020f2:	6a 00                	push   $0x0
  pushl $97
c01020f4:	6a 61                	push   $0x61
  jmp __alltraps
c01020f6:	e9 0e 07 00 00       	jmp    c0102809 <__alltraps>

c01020fb <vector98>:
.globl vector98
vector98:
  pushl $0
c01020fb:	6a 00                	push   $0x0
  pushl $98
c01020fd:	6a 62                	push   $0x62
  jmp __alltraps
c01020ff:	e9 05 07 00 00       	jmp    c0102809 <__alltraps>

c0102104 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102104:	6a 00                	push   $0x0
  pushl $99
c0102106:	6a 63                	push   $0x63
  jmp __alltraps
c0102108:	e9 fc 06 00 00       	jmp    c0102809 <__alltraps>

c010210d <vector100>:
.globl vector100
vector100:
  pushl $0
c010210d:	6a 00                	push   $0x0
  pushl $100
c010210f:	6a 64                	push   $0x64
  jmp __alltraps
c0102111:	e9 f3 06 00 00       	jmp    c0102809 <__alltraps>

c0102116 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102116:	6a 00                	push   $0x0
  pushl $101
c0102118:	6a 65                	push   $0x65
  jmp __alltraps
c010211a:	e9 ea 06 00 00       	jmp    c0102809 <__alltraps>

c010211f <vector102>:
.globl vector102
vector102:
  pushl $0
c010211f:	6a 00                	push   $0x0
  pushl $102
c0102121:	6a 66                	push   $0x66
  jmp __alltraps
c0102123:	e9 e1 06 00 00       	jmp    c0102809 <__alltraps>

c0102128 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102128:	6a 00                	push   $0x0
  pushl $103
c010212a:	6a 67                	push   $0x67
  jmp __alltraps
c010212c:	e9 d8 06 00 00       	jmp    c0102809 <__alltraps>

c0102131 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102131:	6a 00                	push   $0x0
  pushl $104
c0102133:	6a 68                	push   $0x68
  jmp __alltraps
c0102135:	e9 cf 06 00 00       	jmp    c0102809 <__alltraps>

c010213a <vector105>:
.globl vector105
vector105:
  pushl $0
c010213a:	6a 00                	push   $0x0
  pushl $105
c010213c:	6a 69                	push   $0x69
  jmp __alltraps
c010213e:	e9 c6 06 00 00       	jmp    c0102809 <__alltraps>

c0102143 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102143:	6a 00                	push   $0x0
  pushl $106
c0102145:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102147:	e9 bd 06 00 00       	jmp    c0102809 <__alltraps>

c010214c <vector107>:
.globl vector107
vector107:
  pushl $0
c010214c:	6a 00                	push   $0x0
  pushl $107
c010214e:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102150:	e9 b4 06 00 00       	jmp    c0102809 <__alltraps>

c0102155 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102155:	6a 00                	push   $0x0
  pushl $108
c0102157:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102159:	e9 ab 06 00 00       	jmp    c0102809 <__alltraps>

c010215e <vector109>:
.globl vector109
vector109:
  pushl $0
c010215e:	6a 00                	push   $0x0
  pushl $109
c0102160:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102162:	e9 a2 06 00 00       	jmp    c0102809 <__alltraps>

c0102167 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102167:	6a 00                	push   $0x0
  pushl $110
c0102169:	6a 6e                	push   $0x6e
  jmp __alltraps
c010216b:	e9 99 06 00 00       	jmp    c0102809 <__alltraps>

c0102170 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102170:	6a 00                	push   $0x0
  pushl $111
c0102172:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102174:	e9 90 06 00 00       	jmp    c0102809 <__alltraps>

c0102179 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102179:	6a 00                	push   $0x0
  pushl $112
c010217b:	6a 70                	push   $0x70
  jmp __alltraps
c010217d:	e9 87 06 00 00       	jmp    c0102809 <__alltraps>

c0102182 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102182:	6a 00                	push   $0x0
  pushl $113
c0102184:	6a 71                	push   $0x71
  jmp __alltraps
c0102186:	e9 7e 06 00 00       	jmp    c0102809 <__alltraps>

c010218b <vector114>:
.globl vector114
vector114:
  pushl $0
c010218b:	6a 00                	push   $0x0
  pushl $114
c010218d:	6a 72                	push   $0x72
  jmp __alltraps
c010218f:	e9 75 06 00 00       	jmp    c0102809 <__alltraps>

c0102194 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102194:	6a 00                	push   $0x0
  pushl $115
c0102196:	6a 73                	push   $0x73
  jmp __alltraps
c0102198:	e9 6c 06 00 00       	jmp    c0102809 <__alltraps>

c010219d <vector116>:
.globl vector116
vector116:
  pushl $0
c010219d:	6a 00                	push   $0x0
  pushl $116
c010219f:	6a 74                	push   $0x74
  jmp __alltraps
c01021a1:	e9 63 06 00 00       	jmp    c0102809 <__alltraps>

c01021a6 <vector117>:
.globl vector117
vector117:
  pushl $0
c01021a6:	6a 00                	push   $0x0
  pushl $117
c01021a8:	6a 75                	push   $0x75
  jmp __alltraps
c01021aa:	e9 5a 06 00 00       	jmp    c0102809 <__alltraps>

c01021af <vector118>:
.globl vector118
vector118:
  pushl $0
c01021af:	6a 00                	push   $0x0
  pushl $118
c01021b1:	6a 76                	push   $0x76
  jmp __alltraps
c01021b3:	e9 51 06 00 00       	jmp    c0102809 <__alltraps>

c01021b8 <vector119>:
.globl vector119
vector119:
  pushl $0
c01021b8:	6a 00                	push   $0x0
  pushl $119
c01021ba:	6a 77                	push   $0x77
  jmp __alltraps
c01021bc:	e9 48 06 00 00       	jmp    c0102809 <__alltraps>

c01021c1 <vector120>:
.globl vector120
vector120:
  pushl $0
c01021c1:	6a 00                	push   $0x0
  pushl $120
c01021c3:	6a 78                	push   $0x78
  jmp __alltraps
c01021c5:	e9 3f 06 00 00       	jmp    c0102809 <__alltraps>

c01021ca <vector121>:
.globl vector121
vector121:
  pushl $0
c01021ca:	6a 00                	push   $0x0
  pushl $121
c01021cc:	6a 79                	push   $0x79
  jmp __alltraps
c01021ce:	e9 36 06 00 00       	jmp    c0102809 <__alltraps>

c01021d3 <vector122>:
.globl vector122
vector122:
  pushl $0
c01021d3:	6a 00                	push   $0x0
  pushl $122
c01021d5:	6a 7a                	push   $0x7a
  jmp __alltraps
c01021d7:	e9 2d 06 00 00       	jmp    c0102809 <__alltraps>

c01021dc <vector123>:
.globl vector123
vector123:
  pushl $0
c01021dc:	6a 00                	push   $0x0
  pushl $123
c01021de:	6a 7b                	push   $0x7b
  jmp __alltraps
c01021e0:	e9 24 06 00 00       	jmp    c0102809 <__alltraps>

c01021e5 <vector124>:
.globl vector124
vector124:
  pushl $0
c01021e5:	6a 00                	push   $0x0
  pushl $124
c01021e7:	6a 7c                	push   $0x7c
  jmp __alltraps
c01021e9:	e9 1b 06 00 00       	jmp    c0102809 <__alltraps>

c01021ee <vector125>:
.globl vector125
vector125:
  pushl $0
c01021ee:	6a 00                	push   $0x0
  pushl $125
c01021f0:	6a 7d                	push   $0x7d
  jmp __alltraps
c01021f2:	e9 12 06 00 00       	jmp    c0102809 <__alltraps>

c01021f7 <vector126>:
.globl vector126
vector126:
  pushl $0
c01021f7:	6a 00                	push   $0x0
  pushl $126
c01021f9:	6a 7e                	push   $0x7e
  jmp __alltraps
c01021fb:	e9 09 06 00 00       	jmp    c0102809 <__alltraps>

c0102200 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102200:	6a 00                	push   $0x0
  pushl $127
c0102202:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102204:	e9 00 06 00 00       	jmp    c0102809 <__alltraps>

c0102209 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102209:	6a 00                	push   $0x0
  pushl $128
c010220b:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102210:	e9 f4 05 00 00       	jmp    c0102809 <__alltraps>

c0102215 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102215:	6a 00                	push   $0x0
  pushl $129
c0102217:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c010221c:	e9 e8 05 00 00       	jmp    c0102809 <__alltraps>

c0102221 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102221:	6a 00                	push   $0x0
  pushl $130
c0102223:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102228:	e9 dc 05 00 00       	jmp    c0102809 <__alltraps>

c010222d <vector131>:
.globl vector131
vector131:
  pushl $0
c010222d:	6a 00                	push   $0x0
  pushl $131
c010222f:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102234:	e9 d0 05 00 00       	jmp    c0102809 <__alltraps>

c0102239 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102239:	6a 00                	push   $0x0
  pushl $132
c010223b:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102240:	e9 c4 05 00 00       	jmp    c0102809 <__alltraps>

c0102245 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102245:	6a 00                	push   $0x0
  pushl $133
c0102247:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c010224c:	e9 b8 05 00 00       	jmp    c0102809 <__alltraps>

c0102251 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102251:	6a 00                	push   $0x0
  pushl $134
c0102253:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102258:	e9 ac 05 00 00       	jmp    c0102809 <__alltraps>

c010225d <vector135>:
.globl vector135
vector135:
  pushl $0
c010225d:	6a 00                	push   $0x0
  pushl $135
c010225f:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102264:	e9 a0 05 00 00       	jmp    c0102809 <__alltraps>

c0102269 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102269:	6a 00                	push   $0x0
  pushl $136
c010226b:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102270:	e9 94 05 00 00       	jmp    c0102809 <__alltraps>

c0102275 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102275:	6a 00                	push   $0x0
  pushl $137
c0102277:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c010227c:	e9 88 05 00 00       	jmp    c0102809 <__alltraps>

c0102281 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102281:	6a 00                	push   $0x0
  pushl $138
c0102283:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102288:	e9 7c 05 00 00       	jmp    c0102809 <__alltraps>

c010228d <vector139>:
.globl vector139
vector139:
  pushl $0
c010228d:	6a 00                	push   $0x0
  pushl $139
c010228f:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102294:	e9 70 05 00 00       	jmp    c0102809 <__alltraps>

c0102299 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102299:	6a 00                	push   $0x0
  pushl $140
c010229b:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01022a0:	e9 64 05 00 00       	jmp    c0102809 <__alltraps>

c01022a5 <vector141>:
.globl vector141
vector141:
  pushl $0
c01022a5:	6a 00                	push   $0x0
  pushl $141
c01022a7:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01022ac:	e9 58 05 00 00       	jmp    c0102809 <__alltraps>

c01022b1 <vector142>:
.globl vector142
vector142:
  pushl $0
c01022b1:	6a 00                	push   $0x0
  pushl $142
c01022b3:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01022b8:	e9 4c 05 00 00       	jmp    c0102809 <__alltraps>

c01022bd <vector143>:
.globl vector143
vector143:
  pushl $0
c01022bd:	6a 00                	push   $0x0
  pushl $143
c01022bf:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01022c4:	e9 40 05 00 00       	jmp    c0102809 <__alltraps>

c01022c9 <vector144>:
.globl vector144
vector144:
  pushl $0
c01022c9:	6a 00                	push   $0x0
  pushl $144
c01022cb:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01022d0:	e9 34 05 00 00       	jmp    c0102809 <__alltraps>

c01022d5 <vector145>:
.globl vector145
vector145:
  pushl $0
c01022d5:	6a 00                	push   $0x0
  pushl $145
c01022d7:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01022dc:	e9 28 05 00 00       	jmp    c0102809 <__alltraps>

c01022e1 <vector146>:
.globl vector146
vector146:
  pushl $0
c01022e1:	6a 00                	push   $0x0
  pushl $146
c01022e3:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01022e8:	e9 1c 05 00 00       	jmp    c0102809 <__alltraps>

c01022ed <vector147>:
.globl vector147
vector147:
  pushl $0
c01022ed:	6a 00                	push   $0x0
  pushl $147
c01022ef:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01022f4:	e9 10 05 00 00       	jmp    c0102809 <__alltraps>

c01022f9 <vector148>:
.globl vector148
vector148:
  pushl $0
c01022f9:	6a 00                	push   $0x0
  pushl $148
c01022fb:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102300:	e9 04 05 00 00       	jmp    c0102809 <__alltraps>

c0102305 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102305:	6a 00                	push   $0x0
  pushl $149
c0102307:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010230c:	e9 f8 04 00 00       	jmp    c0102809 <__alltraps>

c0102311 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102311:	6a 00                	push   $0x0
  pushl $150
c0102313:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102318:	e9 ec 04 00 00       	jmp    c0102809 <__alltraps>

c010231d <vector151>:
.globl vector151
vector151:
  pushl $0
c010231d:	6a 00                	push   $0x0
  pushl $151
c010231f:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102324:	e9 e0 04 00 00       	jmp    c0102809 <__alltraps>

c0102329 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102329:	6a 00                	push   $0x0
  pushl $152
c010232b:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102330:	e9 d4 04 00 00       	jmp    c0102809 <__alltraps>

c0102335 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102335:	6a 00                	push   $0x0
  pushl $153
c0102337:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010233c:	e9 c8 04 00 00       	jmp    c0102809 <__alltraps>

c0102341 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102341:	6a 00                	push   $0x0
  pushl $154
c0102343:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102348:	e9 bc 04 00 00       	jmp    c0102809 <__alltraps>

c010234d <vector155>:
.globl vector155
vector155:
  pushl $0
c010234d:	6a 00                	push   $0x0
  pushl $155
c010234f:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102354:	e9 b0 04 00 00       	jmp    c0102809 <__alltraps>

c0102359 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102359:	6a 00                	push   $0x0
  pushl $156
c010235b:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102360:	e9 a4 04 00 00       	jmp    c0102809 <__alltraps>

c0102365 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102365:	6a 00                	push   $0x0
  pushl $157
c0102367:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010236c:	e9 98 04 00 00       	jmp    c0102809 <__alltraps>

c0102371 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102371:	6a 00                	push   $0x0
  pushl $158
c0102373:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102378:	e9 8c 04 00 00       	jmp    c0102809 <__alltraps>

c010237d <vector159>:
.globl vector159
vector159:
  pushl $0
c010237d:	6a 00                	push   $0x0
  pushl $159
c010237f:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102384:	e9 80 04 00 00       	jmp    c0102809 <__alltraps>

c0102389 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102389:	6a 00                	push   $0x0
  pushl $160
c010238b:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102390:	e9 74 04 00 00       	jmp    c0102809 <__alltraps>

c0102395 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102395:	6a 00                	push   $0x0
  pushl $161
c0102397:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010239c:	e9 68 04 00 00       	jmp    c0102809 <__alltraps>

c01023a1 <vector162>:
.globl vector162
vector162:
  pushl $0
c01023a1:	6a 00                	push   $0x0
  pushl $162
c01023a3:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01023a8:	e9 5c 04 00 00       	jmp    c0102809 <__alltraps>

c01023ad <vector163>:
.globl vector163
vector163:
  pushl $0
c01023ad:	6a 00                	push   $0x0
  pushl $163
c01023af:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01023b4:	e9 50 04 00 00       	jmp    c0102809 <__alltraps>

c01023b9 <vector164>:
.globl vector164
vector164:
  pushl $0
c01023b9:	6a 00                	push   $0x0
  pushl $164
c01023bb:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01023c0:	e9 44 04 00 00       	jmp    c0102809 <__alltraps>

c01023c5 <vector165>:
.globl vector165
vector165:
  pushl $0
c01023c5:	6a 00                	push   $0x0
  pushl $165
c01023c7:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01023cc:	e9 38 04 00 00       	jmp    c0102809 <__alltraps>

c01023d1 <vector166>:
.globl vector166
vector166:
  pushl $0
c01023d1:	6a 00                	push   $0x0
  pushl $166
c01023d3:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01023d8:	e9 2c 04 00 00       	jmp    c0102809 <__alltraps>

c01023dd <vector167>:
.globl vector167
vector167:
  pushl $0
c01023dd:	6a 00                	push   $0x0
  pushl $167
c01023df:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01023e4:	e9 20 04 00 00       	jmp    c0102809 <__alltraps>

c01023e9 <vector168>:
.globl vector168
vector168:
  pushl $0
c01023e9:	6a 00                	push   $0x0
  pushl $168
c01023eb:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01023f0:	e9 14 04 00 00       	jmp    c0102809 <__alltraps>

c01023f5 <vector169>:
.globl vector169
vector169:
  pushl $0
c01023f5:	6a 00                	push   $0x0
  pushl $169
c01023f7:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01023fc:	e9 08 04 00 00       	jmp    c0102809 <__alltraps>

c0102401 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102401:	6a 00                	push   $0x0
  pushl $170
c0102403:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102408:	e9 fc 03 00 00       	jmp    c0102809 <__alltraps>

c010240d <vector171>:
.globl vector171
vector171:
  pushl $0
c010240d:	6a 00                	push   $0x0
  pushl $171
c010240f:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102414:	e9 f0 03 00 00       	jmp    c0102809 <__alltraps>

c0102419 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102419:	6a 00                	push   $0x0
  pushl $172
c010241b:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102420:	e9 e4 03 00 00       	jmp    c0102809 <__alltraps>

c0102425 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102425:	6a 00                	push   $0x0
  pushl $173
c0102427:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010242c:	e9 d8 03 00 00       	jmp    c0102809 <__alltraps>

c0102431 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102431:	6a 00                	push   $0x0
  pushl $174
c0102433:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102438:	e9 cc 03 00 00       	jmp    c0102809 <__alltraps>

c010243d <vector175>:
.globl vector175
vector175:
  pushl $0
c010243d:	6a 00                	push   $0x0
  pushl $175
c010243f:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102444:	e9 c0 03 00 00       	jmp    c0102809 <__alltraps>

c0102449 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102449:	6a 00                	push   $0x0
  pushl $176
c010244b:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102450:	e9 b4 03 00 00       	jmp    c0102809 <__alltraps>

c0102455 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102455:	6a 00                	push   $0x0
  pushl $177
c0102457:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010245c:	e9 a8 03 00 00       	jmp    c0102809 <__alltraps>

c0102461 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102461:	6a 00                	push   $0x0
  pushl $178
c0102463:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102468:	e9 9c 03 00 00       	jmp    c0102809 <__alltraps>

c010246d <vector179>:
.globl vector179
vector179:
  pushl $0
c010246d:	6a 00                	push   $0x0
  pushl $179
c010246f:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102474:	e9 90 03 00 00       	jmp    c0102809 <__alltraps>

c0102479 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102479:	6a 00                	push   $0x0
  pushl $180
c010247b:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102480:	e9 84 03 00 00       	jmp    c0102809 <__alltraps>

c0102485 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102485:	6a 00                	push   $0x0
  pushl $181
c0102487:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010248c:	e9 78 03 00 00       	jmp    c0102809 <__alltraps>

c0102491 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102491:	6a 00                	push   $0x0
  pushl $182
c0102493:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102498:	e9 6c 03 00 00       	jmp    c0102809 <__alltraps>

c010249d <vector183>:
.globl vector183
vector183:
  pushl $0
c010249d:	6a 00                	push   $0x0
  pushl $183
c010249f:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01024a4:	e9 60 03 00 00       	jmp    c0102809 <__alltraps>

c01024a9 <vector184>:
.globl vector184
vector184:
  pushl $0
c01024a9:	6a 00                	push   $0x0
  pushl $184
c01024ab:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01024b0:	e9 54 03 00 00       	jmp    c0102809 <__alltraps>

c01024b5 <vector185>:
.globl vector185
vector185:
  pushl $0
c01024b5:	6a 00                	push   $0x0
  pushl $185
c01024b7:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01024bc:	e9 48 03 00 00       	jmp    c0102809 <__alltraps>

c01024c1 <vector186>:
.globl vector186
vector186:
  pushl $0
c01024c1:	6a 00                	push   $0x0
  pushl $186
c01024c3:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01024c8:	e9 3c 03 00 00       	jmp    c0102809 <__alltraps>

c01024cd <vector187>:
.globl vector187
vector187:
  pushl $0
c01024cd:	6a 00                	push   $0x0
  pushl $187
c01024cf:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01024d4:	e9 30 03 00 00       	jmp    c0102809 <__alltraps>

c01024d9 <vector188>:
.globl vector188
vector188:
  pushl $0
c01024d9:	6a 00                	push   $0x0
  pushl $188
c01024db:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01024e0:	e9 24 03 00 00       	jmp    c0102809 <__alltraps>

c01024e5 <vector189>:
.globl vector189
vector189:
  pushl $0
c01024e5:	6a 00                	push   $0x0
  pushl $189
c01024e7:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01024ec:	e9 18 03 00 00       	jmp    c0102809 <__alltraps>

c01024f1 <vector190>:
.globl vector190
vector190:
  pushl $0
c01024f1:	6a 00                	push   $0x0
  pushl $190
c01024f3:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01024f8:	e9 0c 03 00 00       	jmp    c0102809 <__alltraps>

c01024fd <vector191>:
.globl vector191
vector191:
  pushl $0
c01024fd:	6a 00                	push   $0x0
  pushl $191
c01024ff:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102504:	e9 00 03 00 00       	jmp    c0102809 <__alltraps>

c0102509 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102509:	6a 00                	push   $0x0
  pushl $192
c010250b:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102510:	e9 f4 02 00 00       	jmp    c0102809 <__alltraps>

c0102515 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102515:	6a 00                	push   $0x0
  pushl $193
c0102517:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010251c:	e9 e8 02 00 00       	jmp    c0102809 <__alltraps>

c0102521 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102521:	6a 00                	push   $0x0
  pushl $194
c0102523:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102528:	e9 dc 02 00 00       	jmp    c0102809 <__alltraps>

c010252d <vector195>:
.globl vector195
vector195:
  pushl $0
c010252d:	6a 00                	push   $0x0
  pushl $195
c010252f:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102534:	e9 d0 02 00 00       	jmp    c0102809 <__alltraps>

c0102539 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102539:	6a 00                	push   $0x0
  pushl $196
c010253b:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102540:	e9 c4 02 00 00       	jmp    c0102809 <__alltraps>

c0102545 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102545:	6a 00                	push   $0x0
  pushl $197
c0102547:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010254c:	e9 b8 02 00 00       	jmp    c0102809 <__alltraps>

c0102551 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102551:	6a 00                	push   $0x0
  pushl $198
c0102553:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102558:	e9 ac 02 00 00       	jmp    c0102809 <__alltraps>

c010255d <vector199>:
.globl vector199
vector199:
  pushl $0
c010255d:	6a 00                	push   $0x0
  pushl $199
c010255f:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102564:	e9 a0 02 00 00       	jmp    c0102809 <__alltraps>

c0102569 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102569:	6a 00                	push   $0x0
  pushl $200
c010256b:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102570:	e9 94 02 00 00       	jmp    c0102809 <__alltraps>

c0102575 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102575:	6a 00                	push   $0x0
  pushl $201
c0102577:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010257c:	e9 88 02 00 00       	jmp    c0102809 <__alltraps>

c0102581 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102581:	6a 00                	push   $0x0
  pushl $202
c0102583:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102588:	e9 7c 02 00 00       	jmp    c0102809 <__alltraps>

c010258d <vector203>:
.globl vector203
vector203:
  pushl $0
c010258d:	6a 00                	push   $0x0
  pushl $203
c010258f:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102594:	e9 70 02 00 00       	jmp    c0102809 <__alltraps>

c0102599 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102599:	6a 00                	push   $0x0
  pushl $204
c010259b:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01025a0:	e9 64 02 00 00       	jmp    c0102809 <__alltraps>

c01025a5 <vector205>:
.globl vector205
vector205:
  pushl $0
c01025a5:	6a 00                	push   $0x0
  pushl $205
c01025a7:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01025ac:	e9 58 02 00 00       	jmp    c0102809 <__alltraps>

c01025b1 <vector206>:
.globl vector206
vector206:
  pushl $0
c01025b1:	6a 00                	push   $0x0
  pushl $206
c01025b3:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01025b8:	e9 4c 02 00 00       	jmp    c0102809 <__alltraps>

c01025bd <vector207>:
.globl vector207
vector207:
  pushl $0
c01025bd:	6a 00                	push   $0x0
  pushl $207
c01025bf:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01025c4:	e9 40 02 00 00       	jmp    c0102809 <__alltraps>

c01025c9 <vector208>:
.globl vector208
vector208:
  pushl $0
c01025c9:	6a 00                	push   $0x0
  pushl $208
c01025cb:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01025d0:	e9 34 02 00 00       	jmp    c0102809 <__alltraps>

c01025d5 <vector209>:
.globl vector209
vector209:
  pushl $0
c01025d5:	6a 00                	push   $0x0
  pushl $209
c01025d7:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01025dc:	e9 28 02 00 00       	jmp    c0102809 <__alltraps>

c01025e1 <vector210>:
.globl vector210
vector210:
  pushl $0
c01025e1:	6a 00                	push   $0x0
  pushl $210
c01025e3:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01025e8:	e9 1c 02 00 00       	jmp    c0102809 <__alltraps>

c01025ed <vector211>:
.globl vector211
vector211:
  pushl $0
c01025ed:	6a 00                	push   $0x0
  pushl $211
c01025ef:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01025f4:	e9 10 02 00 00       	jmp    c0102809 <__alltraps>

c01025f9 <vector212>:
.globl vector212
vector212:
  pushl $0
c01025f9:	6a 00                	push   $0x0
  pushl $212
c01025fb:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102600:	e9 04 02 00 00       	jmp    c0102809 <__alltraps>

c0102605 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102605:	6a 00                	push   $0x0
  pushl $213
c0102607:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010260c:	e9 f8 01 00 00       	jmp    c0102809 <__alltraps>

c0102611 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102611:	6a 00                	push   $0x0
  pushl $214
c0102613:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102618:	e9 ec 01 00 00       	jmp    c0102809 <__alltraps>

c010261d <vector215>:
.globl vector215
vector215:
  pushl $0
c010261d:	6a 00                	push   $0x0
  pushl $215
c010261f:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102624:	e9 e0 01 00 00       	jmp    c0102809 <__alltraps>

c0102629 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102629:	6a 00                	push   $0x0
  pushl $216
c010262b:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102630:	e9 d4 01 00 00       	jmp    c0102809 <__alltraps>

c0102635 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102635:	6a 00                	push   $0x0
  pushl $217
c0102637:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010263c:	e9 c8 01 00 00       	jmp    c0102809 <__alltraps>

c0102641 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102641:	6a 00                	push   $0x0
  pushl $218
c0102643:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102648:	e9 bc 01 00 00       	jmp    c0102809 <__alltraps>

c010264d <vector219>:
.globl vector219
vector219:
  pushl $0
c010264d:	6a 00                	push   $0x0
  pushl $219
c010264f:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102654:	e9 b0 01 00 00       	jmp    c0102809 <__alltraps>

c0102659 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102659:	6a 00                	push   $0x0
  pushl $220
c010265b:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102660:	e9 a4 01 00 00       	jmp    c0102809 <__alltraps>

c0102665 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102665:	6a 00                	push   $0x0
  pushl $221
c0102667:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010266c:	e9 98 01 00 00       	jmp    c0102809 <__alltraps>

c0102671 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102671:	6a 00                	push   $0x0
  pushl $222
c0102673:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102678:	e9 8c 01 00 00       	jmp    c0102809 <__alltraps>

c010267d <vector223>:
.globl vector223
vector223:
  pushl $0
c010267d:	6a 00                	push   $0x0
  pushl $223
c010267f:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102684:	e9 80 01 00 00       	jmp    c0102809 <__alltraps>

c0102689 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102689:	6a 00                	push   $0x0
  pushl $224
c010268b:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102690:	e9 74 01 00 00       	jmp    c0102809 <__alltraps>

c0102695 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102695:	6a 00                	push   $0x0
  pushl $225
c0102697:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010269c:	e9 68 01 00 00       	jmp    c0102809 <__alltraps>

c01026a1 <vector226>:
.globl vector226
vector226:
  pushl $0
c01026a1:	6a 00                	push   $0x0
  pushl $226
c01026a3:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01026a8:	e9 5c 01 00 00       	jmp    c0102809 <__alltraps>

c01026ad <vector227>:
.globl vector227
vector227:
  pushl $0
c01026ad:	6a 00                	push   $0x0
  pushl $227
c01026af:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01026b4:	e9 50 01 00 00       	jmp    c0102809 <__alltraps>

c01026b9 <vector228>:
.globl vector228
vector228:
  pushl $0
c01026b9:	6a 00                	push   $0x0
  pushl $228
c01026bb:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01026c0:	e9 44 01 00 00       	jmp    c0102809 <__alltraps>

c01026c5 <vector229>:
.globl vector229
vector229:
  pushl $0
c01026c5:	6a 00                	push   $0x0
  pushl $229
c01026c7:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01026cc:	e9 38 01 00 00       	jmp    c0102809 <__alltraps>

c01026d1 <vector230>:
.globl vector230
vector230:
  pushl $0
c01026d1:	6a 00                	push   $0x0
  pushl $230
c01026d3:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01026d8:	e9 2c 01 00 00       	jmp    c0102809 <__alltraps>

c01026dd <vector231>:
.globl vector231
vector231:
  pushl $0
c01026dd:	6a 00                	push   $0x0
  pushl $231
c01026df:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01026e4:	e9 20 01 00 00       	jmp    c0102809 <__alltraps>

c01026e9 <vector232>:
.globl vector232
vector232:
  pushl $0
c01026e9:	6a 00                	push   $0x0
  pushl $232
c01026eb:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01026f0:	e9 14 01 00 00       	jmp    c0102809 <__alltraps>

c01026f5 <vector233>:
.globl vector233
vector233:
  pushl $0
c01026f5:	6a 00                	push   $0x0
  pushl $233
c01026f7:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01026fc:	e9 08 01 00 00       	jmp    c0102809 <__alltraps>

c0102701 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102701:	6a 00                	push   $0x0
  pushl $234
c0102703:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102708:	e9 fc 00 00 00       	jmp    c0102809 <__alltraps>

c010270d <vector235>:
.globl vector235
vector235:
  pushl $0
c010270d:	6a 00                	push   $0x0
  pushl $235
c010270f:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102714:	e9 f0 00 00 00       	jmp    c0102809 <__alltraps>

c0102719 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102719:	6a 00                	push   $0x0
  pushl $236
c010271b:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102720:	e9 e4 00 00 00       	jmp    c0102809 <__alltraps>

c0102725 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102725:	6a 00                	push   $0x0
  pushl $237
c0102727:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010272c:	e9 d8 00 00 00       	jmp    c0102809 <__alltraps>

c0102731 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102731:	6a 00                	push   $0x0
  pushl $238
c0102733:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102738:	e9 cc 00 00 00       	jmp    c0102809 <__alltraps>

c010273d <vector239>:
.globl vector239
vector239:
  pushl $0
c010273d:	6a 00                	push   $0x0
  pushl $239
c010273f:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102744:	e9 c0 00 00 00       	jmp    c0102809 <__alltraps>

c0102749 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102749:	6a 00                	push   $0x0
  pushl $240
c010274b:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102750:	e9 b4 00 00 00       	jmp    c0102809 <__alltraps>

c0102755 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102755:	6a 00                	push   $0x0
  pushl $241
c0102757:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010275c:	e9 a8 00 00 00       	jmp    c0102809 <__alltraps>

c0102761 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102761:	6a 00                	push   $0x0
  pushl $242
c0102763:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102768:	e9 9c 00 00 00       	jmp    c0102809 <__alltraps>

c010276d <vector243>:
.globl vector243
vector243:
  pushl $0
c010276d:	6a 00                	push   $0x0
  pushl $243
c010276f:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102774:	e9 90 00 00 00       	jmp    c0102809 <__alltraps>

c0102779 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102779:	6a 00                	push   $0x0
  pushl $244
c010277b:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102780:	e9 84 00 00 00       	jmp    c0102809 <__alltraps>

c0102785 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102785:	6a 00                	push   $0x0
  pushl $245
c0102787:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010278c:	e9 78 00 00 00       	jmp    c0102809 <__alltraps>

c0102791 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102791:	6a 00                	push   $0x0
  pushl $246
c0102793:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102798:	e9 6c 00 00 00       	jmp    c0102809 <__alltraps>

c010279d <vector247>:
.globl vector247
vector247:
  pushl $0
c010279d:	6a 00                	push   $0x0
  pushl $247
c010279f:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01027a4:	e9 60 00 00 00       	jmp    c0102809 <__alltraps>

c01027a9 <vector248>:
.globl vector248
vector248:
  pushl $0
c01027a9:	6a 00                	push   $0x0
  pushl $248
c01027ab:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01027b0:	e9 54 00 00 00       	jmp    c0102809 <__alltraps>

c01027b5 <vector249>:
.globl vector249
vector249:
  pushl $0
c01027b5:	6a 00                	push   $0x0
  pushl $249
c01027b7:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01027bc:	e9 48 00 00 00       	jmp    c0102809 <__alltraps>

c01027c1 <vector250>:
.globl vector250
vector250:
  pushl $0
c01027c1:	6a 00                	push   $0x0
  pushl $250
c01027c3:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01027c8:	e9 3c 00 00 00       	jmp    c0102809 <__alltraps>

c01027cd <vector251>:
.globl vector251
vector251:
  pushl $0
c01027cd:	6a 00                	push   $0x0
  pushl $251
c01027cf:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01027d4:	e9 30 00 00 00       	jmp    c0102809 <__alltraps>

c01027d9 <vector252>:
.globl vector252
vector252:
  pushl $0
c01027d9:	6a 00                	push   $0x0
  pushl $252
c01027db:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01027e0:	e9 24 00 00 00       	jmp    c0102809 <__alltraps>

c01027e5 <vector253>:
.globl vector253
vector253:
  pushl $0
c01027e5:	6a 00                	push   $0x0
  pushl $253
c01027e7:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01027ec:	e9 18 00 00 00       	jmp    c0102809 <__alltraps>

c01027f1 <vector254>:
.globl vector254
vector254:
  pushl $0
c01027f1:	6a 00                	push   $0x0
  pushl $254
c01027f3:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01027f8:	e9 0c 00 00 00       	jmp    c0102809 <__alltraps>

c01027fd <vector255>:
.globl vector255
vector255:
  pushl $0
c01027fd:	6a 00                	push   $0x0
  pushl $255
c01027ff:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102804:	e9 00 00 00 00       	jmp    c0102809 <__alltraps>

c0102809 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102809:	1e                   	push   %ds
    pushl %es
c010280a:	06                   	push   %es
    pushl %fs
c010280b:	0f a0                	push   %fs
    pushl %gs
c010280d:	0f a8                	push   %gs
    pushal
c010280f:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102810:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102815:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102817:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102819:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010281a:	e8 64 f5 ff ff       	call   c0101d83 <trap>

    # pop the pushed stack pointer
    popl %esp
c010281f:	5c                   	pop    %esp

c0102820 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102820:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102821:	0f a9                	pop    %gs
    popl %fs
c0102823:	0f a1                	pop    %fs
    popl %es
c0102825:	07                   	pop    %es
    popl %ds
c0102826:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102827:	83 c4 08             	add    $0x8,%esp
    iret
c010282a:	cf                   	iret   

c010282b <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010282b:	55                   	push   %ebp
c010282c:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010282e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102831:	8b 15 18 df 11 c0    	mov    0xc011df18,%edx
c0102837:	29 d0                	sub    %edx,%eax
c0102839:	c1 f8 02             	sar    $0x2,%eax
c010283c:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102842:	5d                   	pop    %ebp
c0102843:	c3                   	ret    

c0102844 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102844:	55                   	push   %ebp
c0102845:	89 e5                	mov    %esp,%ebp
c0102847:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010284a:	8b 45 08             	mov    0x8(%ebp),%eax
c010284d:	89 04 24             	mov    %eax,(%esp)
c0102850:	e8 d6 ff ff ff       	call   c010282b <page2ppn>
c0102855:	c1 e0 0c             	shl    $0xc,%eax
}
c0102858:	c9                   	leave  
c0102859:	c3                   	ret    

c010285a <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010285a:	55                   	push   %ebp
c010285b:	89 e5                	mov    %esp,%ebp
c010285d:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0102860:	8b 45 08             	mov    0x8(%ebp),%eax
c0102863:	c1 e8 0c             	shr    $0xc,%eax
c0102866:	89 c2                	mov    %eax,%edx
c0102868:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c010286d:	39 c2                	cmp    %eax,%edx
c010286f:	72 1c                	jb     c010288d <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102871:	c7 44 24 08 70 75 10 	movl   $0xc0107570,0x8(%esp)
c0102878:	c0 
c0102879:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0102880:	00 
c0102881:	c7 04 24 8f 75 10 c0 	movl   $0xc010758f,(%esp)
c0102888:	e8 5c db ff ff       	call   c01003e9 <__panic>
    }
    return &pages[PPN(pa)];
c010288d:	8b 0d 18 df 11 c0    	mov    0xc011df18,%ecx
c0102893:	8b 45 08             	mov    0x8(%ebp),%eax
c0102896:	c1 e8 0c             	shr    $0xc,%eax
c0102899:	89 c2                	mov    %eax,%edx
c010289b:	89 d0                	mov    %edx,%eax
c010289d:	c1 e0 02             	shl    $0x2,%eax
c01028a0:	01 d0                	add    %edx,%eax
c01028a2:	c1 e0 02             	shl    $0x2,%eax
c01028a5:	01 c8                	add    %ecx,%eax
}
c01028a7:	c9                   	leave  
c01028a8:	c3                   	ret    

c01028a9 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01028a9:	55                   	push   %ebp
c01028aa:	89 e5                	mov    %esp,%ebp
c01028ac:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01028af:	8b 45 08             	mov    0x8(%ebp),%eax
c01028b2:	89 04 24             	mov    %eax,(%esp)
c01028b5:	e8 8a ff ff ff       	call   c0102844 <page2pa>
c01028ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01028bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028c0:	c1 e8 0c             	shr    $0xc,%eax
c01028c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01028c6:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c01028cb:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01028ce:	72 23                	jb     c01028f3 <page2kva+0x4a>
c01028d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028d7:	c7 44 24 08 a0 75 10 	movl   $0xc01075a0,0x8(%esp)
c01028de:	c0 
c01028df:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c01028e6:	00 
c01028e7:	c7 04 24 8f 75 10 c0 	movl   $0xc010758f,(%esp)
c01028ee:	e8 f6 da ff ff       	call   c01003e9 <__panic>
c01028f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028f6:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01028fb:	c9                   	leave  
c01028fc:	c3                   	ret    

c01028fd <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c01028fd:	55                   	push   %ebp
c01028fe:	89 e5                	mov    %esp,%ebp
c0102900:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0102903:	8b 45 08             	mov    0x8(%ebp),%eax
c0102906:	83 e0 01             	and    $0x1,%eax
c0102909:	85 c0                	test   %eax,%eax
c010290b:	75 1c                	jne    c0102929 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c010290d:	c7 44 24 08 c4 75 10 	movl   $0xc01075c4,0x8(%esp)
c0102914:	c0 
c0102915:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c010291c:	00 
c010291d:	c7 04 24 8f 75 10 c0 	movl   $0xc010758f,(%esp)
c0102924:	e8 c0 da ff ff       	call   c01003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0102929:	8b 45 08             	mov    0x8(%ebp),%eax
c010292c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102931:	89 04 24             	mov    %eax,(%esp)
c0102934:	e8 21 ff ff ff       	call   c010285a <pa2page>
}
c0102939:	c9                   	leave  
c010293a:	c3                   	ret    

c010293b <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c010293b:	55                   	push   %ebp
c010293c:	89 e5                	mov    %esp,%ebp
c010293e:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0102941:	8b 45 08             	mov    0x8(%ebp),%eax
c0102944:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102949:	89 04 24             	mov    %eax,(%esp)
c010294c:	e8 09 ff ff ff       	call   c010285a <pa2page>
}
c0102951:	c9                   	leave  
c0102952:	c3                   	ret    

c0102953 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0102953:	55                   	push   %ebp
c0102954:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102956:	8b 45 08             	mov    0x8(%ebp),%eax
c0102959:	8b 00                	mov    (%eax),%eax
}
c010295b:	5d                   	pop    %ebp
c010295c:	c3                   	ret    

c010295d <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c010295d:	55                   	push   %ebp
c010295e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102960:	8b 45 08             	mov    0x8(%ebp),%eax
c0102963:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102966:	89 10                	mov    %edx,(%eax)
}
c0102968:	90                   	nop
c0102969:	5d                   	pop    %ebp
c010296a:	c3                   	ret    

c010296b <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c010296b:	55                   	push   %ebp
c010296c:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c010296e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102971:	8b 00                	mov    (%eax),%eax
c0102973:	8d 50 01             	lea    0x1(%eax),%edx
c0102976:	8b 45 08             	mov    0x8(%ebp),%eax
c0102979:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010297b:	8b 45 08             	mov    0x8(%ebp),%eax
c010297e:	8b 00                	mov    (%eax),%eax
}
c0102980:	5d                   	pop    %ebp
c0102981:	c3                   	ret    

c0102982 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0102982:	55                   	push   %ebp
c0102983:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0102985:	8b 45 08             	mov    0x8(%ebp),%eax
c0102988:	8b 00                	mov    (%eax),%eax
c010298a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010298d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102990:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102992:	8b 45 08             	mov    0x8(%ebp),%eax
c0102995:	8b 00                	mov    (%eax),%eax
}
c0102997:	5d                   	pop    %ebp
c0102998:	c3                   	ret    

c0102999 <__intr_save>:
__intr_save(void) {
c0102999:	55                   	push   %ebp
c010299a:	89 e5                	mov    %esp,%ebp
c010299c:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010299f:	9c                   	pushf  
c01029a0:	58                   	pop    %eax
c01029a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01029a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01029a7:	25 00 02 00 00       	and    $0x200,%eax
c01029ac:	85 c0                	test   %eax,%eax
c01029ae:	74 0c                	je     c01029bc <__intr_save+0x23>
        intr_disable();
c01029b0:	e8 d8 ee ff ff       	call   c010188d <intr_disable>
        return 1;
c01029b5:	b8 01 00 00 00       	mov    $0x1,%eax
c01029ba:	eb 05                	jmp    c01029c1 <__intr_save+0x28>
    return 0;
c01029bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01029c1:	c9                   	leave  
c01029c2:	c3                   	ret    

c01029c3 <__intr_restore>:
__intr_restore(bool flag) {
c01029c3:	55                   	push   %ebp
c01029c4:	89 e5                	mov    %esp,%ebp
c01029c6:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01029c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01029cd:	74 05                	je     c01029d4 <__intr_restore+0x11>
        intr_enable();
c01029cf:	e8 b2 ee ff ff       	call   c0101886 <intr_enable>
}
c01029d4:	90                   	nop
c01029d5:	c9                   	leave  
c01029d6:	c3                   	ret    

c01029d7 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01029d7:	55                   	push   %ebp
c01029d8:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01029da:	8b 45 08             	mov    0x8(%ebp),%eax
c01029dd:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01029e0:	b8 23 00 00 00       	mov    $0x23,%eax
c01029e5:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01029e7:	b8 23 00 00 00       	mov    $0x23,%eax
c01029ec:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01029ee:	b8 10 00 00 00       	mov    $0x10,%eax
c01029f3:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01029f5:	b8 10 00 00 00       	mov    $0x10,%eax
c01029fa:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c01029fc:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a01:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102a03:	ea 0a 2a 10 c0 08 00 	ljmp   $0x8,$0xc0102a0a
}
c0102a0a:	90                   	nop
c0102a0b:	5d                   	pop    %ebp
c0102a0c:	c3                   	ret    

c0102a0d <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102a0d:	55                   	push   %ebp
c0102a0e:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102a10:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a13:	a3 a4 de 11 c0       	mov    %eax,0xc011dea4
}
c0102a18:	90                   	nop
c0102a19:	5d                   	pop    %ebp
c0102a1a:	c3                   	ret    

c0102a1b <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102a1b:	55                   	push   %ebp
c0102a1c:	89 e5                	mov    %esp,%ebp
c0102a1e:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102a21:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0102a26:	89 04 24             	mov    %eax,(%esp)
c0102a29:	e8 df ff ff ff       	call   c0102a0d <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102a2e:	66 c7 05 a8 de 11 c0 	movw   $0x10,0xc011dea8
c0102a35:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102a37:	66 c7 05 28 aa 11 c0 	movw   $0x68,0xc011aa28
c0102a3e:	68 00 
c0102a40:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102a45:	0f b7 c0             	movzwl %ax,%eax
c0102a48:	66 a3 2a aa 11 c0    	mov    %ax,0xc011aa2a
c0102a4e:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102a53:	c1 e8 10             	shr    $0x10,%eax
c0102a56:	a2 2c aa 11 c0       	mov    %al,0xc011aa2c
c0102a5b:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102a62:	24 f0                	and    $0xf0,%al
c0102a64:	0c 09                	or     $0x9,%al
c0102a66:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102a6b:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102a72:	24 ef                	and    $0xef,%al
c0102a74:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102a79:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102a80:	24 9f                	and    $0x9f,%al
c0102a82:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102a87:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102a8e:	0c 80                	or     $0x80,%al
c0102a90:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102a95:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102a9c:	24 f0                	and    $0xf0,%al
c0102a9e:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102aa3:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102aaa:	24 ef                	and    $0xef,%al
c0102aac:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102ab1:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102ab8:	24 df                	and    $0xdf,%al
c0102aba:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102abf:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102ac6:	0c 40                	or     $0x40,%al
c0102ac8:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102acd:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102ad4:	24 7f                	and    $0x7f,%al
c0102ad6:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102adb:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102ae0:	c1 e8 18             	shr    $0x18,%eax
c0102ae3:	a2 2f aa 11 c0       	mov    %al,0xc011aa2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102ae8:	c7 04 24 30 aa 11 c0 	movl   $0xc011aa30,(%esp)
c0102aef:	e8 e3 fe ff ff       	call   c01029d7 <lgdt>
c0102af4:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102afa:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102afe:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102b01:	90                   	nop
c0102b02:	c9                   	leave  
c0102b03:	c3                   	ret    

c0102b04 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102b04:	55                   	push   %ebp
c0102b05:	89 e5                	mov    %esp,%ebp
c0102b07:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102b0a:	c7 05 10 df 11 c0 80 	movl   $0xc0107f80,0xc011df10
c0102b11:	7f 10 c0 
    //pmm_manager = &buddy_system;
    cprintf("memory management: %s\n", pmm_manager->name);
c0102b14:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b19:	8b 00                	mov    (%eax),%eax
c0102b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102b1f:	c7 04 24 f0 75 10 c0 	movl   $0xc01075f0,(%esp)
c0102b26:	e8 67 d7 ff ff       	call   c0100292 <cprintf>
    pmm_manager->init();
c0102b2b:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b30:	8b 40 04             	mov    0x4(%eax),%eax
c0102b33:	ff d0                	call   *%eax
}
c0102b35:	90                   	nop
c0102b36:	c9                   	leave  
c0102b37:	c3                   	ret    

c0102b38 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102b38:	55                   	push   %ebp
c0102b39:	89 e5                	mov    %esp,%ebp
c0102b3b:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102b3e:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b43:	8b 40 08             	mov    0x8(%eax),%eax
c0102b46:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102b49:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102b4d:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b50:	89 14 24             	mov    %edx,(%esp)
c0102b53:	ff d0                	call   *%eax
}
c0102b55:	90                   	nop
c0102b56:	c9                   	leave  
c0102b57:	c3                   	ret    

c0102b58 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102b58:	55                   	push   %ebp
c0102b59:	89 e5                	mov    %esp,%ebp
c0102b5b:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102b5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102b65:	e8 2f fe ff ff       	call   c0102999 <__intr_save>
c0102b6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102b6d:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b72:	8b 40 0c             	mov    0xc(%eax),%eax
c0102b75:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b78:	89 14 24             	mov    %edx,(%esp)
c0102b7b:	ff d0                	call   *%eax
c0102b7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b83:	89 04 24             	mov    %eax,(%esp)
c0102b86:	e8 38 fe ff ff       	call   c01029c3 <__intr_restore>
    return page;
c0102b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102b8e:	c9                   	leave  
c0102b8f:	c3                   	ret    

c0102b90 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102b90:	55                   	push   %ebp
c0102b91:	89 e5                	mov    %esp,%ebp
c0102b93:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102b96:	e8 fe fd ff ff       	call   c0102999 <__intr_save>
c0102b9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102b9e:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102ba3:	8b 40 10             	mov    0x10(%eax),%eax
c0102ba6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102ba9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102bad:	8b 55 08             	mov    0x8(%ebp),%edx
c0102bb0:	89 14 24             	mov    %edx,(%esp)
c0102bb3:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bb8:	89 04 24             	mov    %eax,(%esp)
c0102bbb:	e8 03 fe ff ff       	call   c01029c3 <__intr_restore>
}
c0102bc0:	90                   	nop
c0102bc1:	c9                   	leave  
c0102bc2:	c3                   	ret    

c0102bc3 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102bc3:	55                   	push   %ebp
c0102bc4:	89 e5                	mov    %esp,%ebp
c0102bc6:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102bc9:	e8 cb fd ff ff       	call   c0102999 <__intr_save>
c0102bce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102bd1:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102bd6:	8b 40 14             	mov    0x14(%eax),%eax
c0102bd9:	ff d0                	call   *%eax
c0102bdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102be1:	89 04 24             	mov    %eax,(%esp)
c0102be4:	e8 da fd ff ff       	call   c01029c3 <__intr_restore>
    return ret;
c0102be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102bec:	c9                   	leave  
c0102bed:	c3                   	ret    

c0102bee <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102bee:	55                   	push   %ebp
c0102bef:	89 e5                	mov    %esp,%ebp
c0102bf1:	57                   	push   %edi
c0102bf2:	56                   	push   %esi
c0102bf3:	53                   	push   %ebx
c0102bf4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102bfa:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102c01:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102c08:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102c0f:	c7 04 24 07 76 10 c0 	movl   $0xc0107607,(%esp)
c0102c16:	e8 77 d6 ff ff       	call   c0100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102c1b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102c22:	e9 22 01 00 00       	jmp    c0102d49 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102c27:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c2a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c2d:	89 d0                	mov    %edx,%eax
c0102c2f:	c1 e0 02             	shl    $0x2,%eax
c0102c32:	01 d0                	add    %edx,%eax
c0102c34:	c1 e0 02             	shl    $0x2,%eax
c0102c37:	01 c8                	add    %ecx,%eax
c0102c39:	8b 50 08             	mov    0x8(%eax),%edx
c0102c3c:	8b 40 04             	mov    0x4(%eax),%eax
c0102c3f:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0102c42:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102c45:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c48:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c4b:	89 d0                	mov    %edx,%eax
c0102c4d:	c1 e0 02             	shl    $0x2,%eax
c0102c50:	01 d0                	add    %edx,%eax
c0102c52:	c1 e0 02             	shl    $0x2,%eax
c0102c55:	01 c8                	add    %ecx,%eax
c0102c57:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102c5a:	8b 58 10             	mov    0x10(%eax),%ebx
c0102c5d:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102c60:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102c63:	01 c8                	add    %ecx,%eax
c0102c65:	11 da                	adc    %ebx,%edx
c0102c67:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102c6a:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102c6d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c70:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c73:	89 d0                	mov    %edx,%eax
c0102c75:	c1 e0 02             	shl    $0x2,%eax
c0102c78:	01 d0                	add    %edx,%eax
c0102c7a:	c1 e0 02             	shl    $0x2,%eax
c0102c7d:	01 c8                	add    %ecx,%eax
c0102c7f:	83 c0 14             	add    $0x14,%eax
c0102c82:	8b 00                	mov    (%eax),%eax
c0102c84:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102c87:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102c8a:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102c8d:	83 c0 ff             	add    $0xffffffff,%eax
c0102c90:	83 d2 ff             	adc    $0xffffffff,%edx
c0102c93:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102c99:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102c9f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ca2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ca5:	89 d0                	mov    %edx,%eax
c0102ca7:	c1 e0 02             	shl    $0x2,%eax
c0102caa:	01 d0                	add    %edx,%eax
c0102cac:	c1 e0 02             	shl    $0x2,%eax
c0102caf:	01 c8                	add    %ecx,%eax
c0102cb1:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102cb4:	8b 58 10             	mov    0x10(%eax),%ebx
c0102cb7:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102cba:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102cbe:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102cc4:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102cca:	89 44 24 14          	mov    %eax,0x14(%esp)
c0102cce:	89 54 24 18          	mov    %edx,0x18(%esp)
c0102cd2:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102cd5:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102cd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102cdc:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102ce0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102ce4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102ce8:	c7 04 24 14 76 10 c0 	movl   $0xc0107614,(%esp)
c0102cef:	e8 9e d5 ff ff       	call   c0100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102cf4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cf7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102cfa:	89 d0                	mov    %edx,%eax
c0102cfc:	c1 e0 02             	shl    $0x2,%eax
c0102cff:	01 d0                	add    %edx,%eax
c0102d01:	c1 e0 02             	shl    $0x2,%eax
c0102d04:	01 c8                	add    %ecx,%eax
c0102d06:	83 c0 14             	add    $0x14,%eax
c0102d09:	8b 00                	mov    (%eax),%eax
c0102d0b:	83 f8 01             	cmp    $0x1,%eax
c0102d0e:	75 36                	jne    c0102d46 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0102d10:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d13:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d16:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102d19:	77 2b                	ja     c0102d46 <page_init+0x158>
c0102d1b:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102d1e:	72 05                	jb     c0102d25 <page_init+0x137>
c0102d20:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0102d23:	73 21                	jae    c0102d46 <page_init+0x158>
c0102d25:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102d29:	77 1b                	ja     c0102d46 <page_init+0x158>
c0102d2b:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102d2f:	72 09                	jb     c0102d3a <page_init+0x14c>
c0102d31:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c0102d38:	77 0c                	ja     c0102d46 <page_init+0x158>
                maxpa = end;
c0102d3a:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102d3d:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102d40:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102d43:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0102d46:	ff 45 dc             	incl   -0x24(%ebp)
c0102d49:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102d4c:	8b 00                	mov    (%eax),%eax
c0102d4e:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102d51:	0f 8c d0 fe ff ff    	jl     c0102c27 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102d57:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102d5b:	72 1d                	jb     c0102d7a <page_init+0x18c>
c0102d5d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102d61:	77 09                	ja     c0102d6c <page_init+0x17e>
c0102d63:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102d6a:	76 0e                	jbe    c0102d7a <page_init+0x18c>
        maxpa = KMEMSIZE;
c0102d6c:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102d73:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102d7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d7d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d80:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102d84:	c1 ea 0c             	shr    $0xc,%edx
c0102d87:	89 c1                	mov    %eax,%ecx
c0102d89:	89 d3                	mov    %edx,%ebx
c0102d8b:	89 c8                	mov    %ecx,%eax
c0102d8d:	a3 80 de 11 c0       	mov    %eax,0xc011de80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102d92:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0102d99:	b8 bc df 11 c0       	mov    $0xc011dfbc,%eax
c0102d9e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102da1:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102da4:	01 d0                	add    %edx,%eax
c0102da6:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0102da9:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102dac:	ba 00 00 00 00       	mov    $0x0,%edx
c0102db1:	f7 75 c0             	divl   -0x40(%ebp)
c0102db4:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102db7:	29 d0                	sub    %edx,%eax
c0102db9:	a3 18 df 11 c0       	mov    %eax,0xc011df18

    for (i = 0; i < npage; i ++) {
c0102dbe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102dc5:	eb 2e                	jmp    c0102df5 <page_init+0x207>
        SetPageReserved(pages + i);
c0102dc7:	8b 0d 18 df 11 c0    	mov    0xc011df18,%ecx
c0102dcd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102dd0:	89 d0                	mov    %edx,%eax
c0102dd2:	c1 e0 02             	shl    $0x2,%eax
c0102dd5:	01 d0                	add    %edx,%eax
c0102dd7:	c1 e0 02             	shl    $0x2,%eax
c0102dda:	01 c8                	add    %ecx,%eax
c0102ddc:	83 c0 04             	add    $0x4,%eax
c0102ddf:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0102de6:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102de9:	8b 45 90             	mov    -0x70(%ebp),%eax
c0102dec:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0102def:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0102df2:	ff 45 dc             	incl   -0x24(%ebp)
c0102df5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102df8:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0102dfd:	39 c2                	cmp    %eax,%edx
c0102dff:	72 c6                	jb     c0102dc7 <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102e01:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0102e07:	89 d0                	mov    %edx,%eax
c0102e09:	c1 e0 02             	shl    $0x2,%eax
c0102e0c:	01 d0                	add    %edx,%eax
c0102e0e:	c1 e0 02             	shl    $0x2,%eax
c0102e11:	89 c2                	mov    %eax,%edx
c0102e13:	a1 18 df 11 c0       	mov    0xc011df18,%eax
c0102e18:	01 d0                	add    %edx,%eax
c0102e1a:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102e1d:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0102e24:	77 23                	ja     c0102e49 <page_init+0x25b>
c0102e26:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102e29:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102e2d:	c7 44 24 08 44 76 10 	movl   $0xc0107644,0x8(%esp)
c0102e34:	c0 
c0102e35:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0102e3c:	00 
c0102e3d:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0102e44:	e8 a0 d5 ff ff       	call   c01003e9 <__panic>
c0102e49:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102e4c:	05 00 00 00 40       	add    $0x40000000,%eax
c0102e51:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0102e54:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e5b:	e9 69 01 00 00       	jmp    c0102fc9 <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102e60:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e63:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e66:	89 d0                	mov    %edx,%eax
c0102e68:	c1 e0 02             	shl    $0x2,%eax
c0102e6b:	01 d0                	add    %edx,%eax
c0102e6d:	c1 e0 02             	shl    $0x2,%eax
c0102e70:	01 c8                	add    %ecx,%eax
c0102e72:	8b 50 08             	mov    0x8(%eax),%edx
c0102e75:	8b 40 04             	mov    0x4(%eax),%eax
c0102e78:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102e7b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102e7e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e81:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e84:	89 d0                	mov    %edx,%eax
c0102e86:	c1 e0 02             	shl    $0x2,%eax
c0102e89:	01 d0                	add    %edx,%eax
c0102e8b:	c1 e0 02             	shl    $0x2,%eax
c0102e8e:	01 c8                	add    %ecx,%eax
c0102e90:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102e93:	8b 58 10             	mov    0x10(%eax),%ebx
c0102e96:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102e99:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102e9c:	01 c8                	add    %ecx,%eax
c0102e9e:	11 da                	adc    %ebx,%edx
c0102ea0:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102ea3:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0102ea6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ea9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102eac:	89 d0                	mov    %edx,%eax
c0102eae:	c1 e0 02             	shl    $0x2,%eax
c0102eb1:	01 d0                	add    %edx,%eax
c0102eb3:	c1 e0 02             	shl    $0x2,%eax
c0102eb6:	01 c8                	add    %ecx,%eax
c0102eb8:	83 c0 14             	add    $0x14,%eax
c0102ebb:	8b 00                	mov    (%eax),%eax
c0102ebd:	83 f8 01             	cmp    $0x1,%eax
c0102ec0:	0f 85 00 01 00 00    	jne    c0102fc6 <page_init+0x3d8>
            if (begin < freemem) {
c0102ec6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102ec9:	ba 00 00 00 00       	mov    $0x0,%edx
c0102ece:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0102ed1:	77 17                	ja     c0102eea <page_init+0x2fc>
c0102ed3:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0102ed6:	72 05                	jb     c0102edd <page_init+0x2ef>
c0102ed8:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0102edb:	73 0d                	jae    c0102eea <page_init+0x2fc>
                begin = freemem;
c0102edd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102ee0:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102ee3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0102eea:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102eee:	72 1d                	jb     c0102f0d <page_init+0x31f>
c0102ef0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102ef4:	77 09                	ja     c0102eff <page_init+0x311>
c0102ef6:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0102efd:	76 0e                	jbe    c0102f0d <page_init+0x31f>
                end = KMEMSIZE;
c0102eff:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0102f06:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0102f0d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f10:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f13:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f16:	0f 87 aa 00 00 00    	ja     c0102fc6 <page_init+0x3d8>
c0102f1c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f1f:	72 09                	jb     c0102f2a <page_init+0x33c>
c0102f21:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102f24:	0f 83 9c 00 00 00    	jae    c0102fc6 <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
c0102f2a:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0102f31:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102f34:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102f37:	01 d0                	add    %edx,%eax
c0102f39:	48                   	dec    %eax
c0102f3a:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0102f3d:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102f40:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f45:	f7 75 b0             	divl   -0x50(%ebp)
c0102f48:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102f4b:	29 d0                	sub    %edx,%eax
c0102f4d:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f52:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f55:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0102f58:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102f5b:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0102f5e:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102f61:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f66:	89 c3                	mov    %eax,%ebx
c0102f68:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0102f6e:	89 de                	mov    %ebx,%esi
c0102f70:	89 d0                	mov    %edx,%eax
c0102f72:	83 e0 00             	and    $0x0,%eax
c0102f75:	89 c7                	mov    %eax,%edi
c0102f77:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0102f7a:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0102f7d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f80:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f83:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f86:	77 3e                	ja     c0102fc6 <page_init+0x3d8>
c0102f88:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f8b:	72 05                	jb     c0102f92 <page_init+0x3a4>
c0102f8d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102f90:	73 34                	jae    c0102fc6 <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0102f92:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102f95:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102f98:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0102f9b:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0102f9e:	89 c1                	mov    %eax,%ecx
c0102fa0:	89 d3                	mov    %edx,%ebx
c0102fa2:	89 c8                	mov    %ecx,%eax
c0102fa4:	89 da                	mov    %ebx,%edx
c0102fa6:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102faa:	c1 ea 0c             	shr    $0xc,%edx
c0102fad:	89 c3                	mov    %eax,%ebx
c0102faf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102fb2:	89 04 24             	mov    %eax,(%esp)
c0102fb5:	e8 a0 f8 ff ff       	call   c010285a <pa2page>
c0102fba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0102fbe:	89 04 24             	mov    %eax,(%esp)
c0102fc1:	e8 72 fb ff ff       	call   c0102b38 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0102fc6:	ff 45 dc             	incl   -0x24(%ebp)
c0102fc9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102fcc:	8b 00                	mov    (%eax),%eax
c0102fce:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102fd1:	0f 8c 89 fe ff ff    	jl     c0102e60 <page_init+0x272>
                }
            }
        }
    }
}
c0102fd7:	90                   	nop
c0102fd8:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0102fde:	5b                   	pop    %ebx
c0102fdf:	5e                   	pop    %esi
c0102fe0:	5f                   	pop    %edi
c0102fe1:	5d                   	pop    %ebp
c0102fe2:	c3                   	ret    

c0102fe3 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0102fe3:	55                   	push   %ebp
c0102fe4:	89 e5                	mov    %esp,%ebp
c0102fe6:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0102fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102fec:	33 45 14             	xor    0x14(%ebp),%eax
c0102fef:	25 ff 0f 00 00       	and    $0xfff,%eax
c0102ff4:	85 c0                	test   %eax,%eax
c0102ff6:	74 24                	je     c010301c <boot_map_segment+0x39>
c0102ff8:	c7 44 24 0c 76 76 10 	movl   $0xc0107676,0xc(%esp)
c0102fff:	c0 
c0103000:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103007:	c0 
c0103008:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c010300f:	00 
c0103010:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103017:	e8 cd d3 ff ff       	call   c01003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010301c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0103023:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103026:	25 ff 0f 00 00       	and    $0xfff,%eax
c010302b:	89 c2                	mov    %eax,%edx
c010302d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103030:	01 c2                	add    %eax,%edx
c0103032:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103035:	01 d0                	add    %edx,%eax
c0103037:	48                   	dec    %eax
c0103038:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010303b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010303e:	ba 00 00 00 00       	mov    $0x0,%edx
c0103043:	f7 75 f0             	divl   -0x10(%ebp)
c0103046:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103049:	29 d0                	sub    %edx,%eax
c010304b:	c1 e8 0c             	shr    $0xc,%eax
c010304e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103051:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103054:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103057:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010305a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010305f:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0103062:	8b 45 14             	mov    0x14(%ebp),%eax
c0103065:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103068:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010306b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103070:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103073:	eb 68                	jmp    c01030dd <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0103075:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010307c:	00 
c010307d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103080:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103084:	8b 45 08             	mov    0x8(%ebp),%eax
c0103087:	89 04 24             	mov    %eax,(%esp)
c010308a:	e8 81 01 00 00       	call   c0103210 <get_pte>
c010308f:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0103092:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103096:	75 24                	jne    c01030bc <boot_map_segment+0xd9>
c0103098:	c7 44 24 0c a2 76 10 	movl   $0xc01076a2,0xc(%esp)
c010309f:	c0 
c01030a0:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c01030a7:	c0 
c01030a8:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c01030af:	00 
c01030b0:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c01030b7:	e8 2d d3 ff ff       	call   c01003e9 <__panic>
        *ptep = pa | PTE_P | perm;
c01030bc:	8b 45 14             	mov    0x14(%ebp),%eax
c01030bf:	0b 45 18             	or     0x18(%ebp),%eax
c01030c2:	83 c8 01             	or     $0x1,%eax
c01030c5:	89 c2                	mov    %eax,%edx
c01030c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030ca:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01030cc:	ff 4d f4             	decl   -0xc(%ebp)
c01030cf:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01030d6:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01030dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01030e1:	75 92                	jne    c0103075 <boot_map_segment+0x92>
    }
}
c01030e3:	90                   	nop
c01030e4:	c9                   	leave  
c01030e5:	c3                   	ret    

c01030e6 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01030e6:	55                   	push   %ebp
c01030e7:	89 e5                	mov    %esp,%ebp
c01030e9:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01030ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01030f3:	e8 60 fa ff ff       	call   c0102b58 <alloc_pages>
c01030f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01030fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01030ff:	75 1c                	jne    c010311d <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0103101:	c7 44 24 08 af 76 10 	movl   $0xc01076af,0x8(%esp)
c0103108:	c0 
c0103109:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0103110:	00 
c0103111:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103118:	e8 cc d2 ff ff       	call   c01003e9 <__panic>
    }
    return page2kva(p);
c010311d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103120:	89 04 24             	mov    %eax,(%esp)
c0103123:	e8 81 f7 ff ff       	call   c01028a9 <page2kva>
}
c0103128:	c9                   	leave  
c0103129:	c3                   	ret    

c010312a <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010312a:	55                   	push   %ebp
c010312b:	89 e5                	mov    %esp,%ebp
c010312d:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0103130:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103135:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103138:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010313f:	77 23                	ja     c0103164 <pmm_init+0x3a>
c0103141:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103144:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103148:	c7 44 24 08 44 76 10 	movl   $0xc0107644,0x8(%esp)
c010314f:	c0 
c0103150:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0103157:	00 
c0103158:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c010315f:	e8 85 d2 ff ff       	call   c01003e9 <__panic>
c0103164:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103167:	05 00 00 00 40       	add    $0x40000000,%eax
c010316c:	a3 14 df 11 c0       	mov    %eax,0xc011df14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0103171:	e8 8e f9 ff ff       	call   c0102b04 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103176:	e8 73 fa ff ff       	call   c0102bee <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010317b:	e8 de 03 00 00       	call   c010355e <check_alloc_page>

    check_pgdir();
c0103180:	e8 f8 03 00 00       	call   c010357d <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0103185:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010318a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010318d:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103194:	77 23                	ja     c01031b9 <pmm_init+0x8f>
c0103196:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103199:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010319d:	c7 44 24 08 44 76 10 	movl   $0xc0107644,0x8(%esp)
c01031a4:	c0 
c01031a5:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c01031ac:	00 
c01031ad:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c01031b4:	e8 30 d2 ff ff       	call   c01003e9 <__panic>
c01031b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031bc:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c01031c2:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01031c7:	05 ac 0f 00 00       	add    $0xfac,%eax
c01031cc:	83 ca 03             	or     $0x3,%edx
c01031cf:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01031d1:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01031d6:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01031dd:	00 
c01031de:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01031e5:	00 
c01031e6:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01031ed:	38 
c01031ee:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01031f5:	c0 
c01031f6:	89 04 24             	mov    %eax,(%esp)
c01031f9:	e8 e5 fd ff ff       	call   c0102fe3 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01031fe:	e8 18 f8 ff ff       	call   c0102a1b <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0103203:	e8 11 0a 00 00       	call   c0103c19 <check_boot_pgdir>

    print_pgdir();
c0103208:	e8 8a 0e 00 00       	call   c0104097 <print_pgdir>

}
c010320d:	90                   	nop
c010320e:	c9                   	leave  
c010320f:	c3                   	ret    

c0103210 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0103210:	55                   	push   %ebp
c0103211:	89 e5                	mov    %esp,%ebp
c0103213:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];                      // (1) find page directory entry
c0103216:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103219:	c1 e8 16             	shr    $0x16,%eax
c010321c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103223:	8b 45 08             	mov    0x8(%ebp),%eax
c0103226:	01 d0                	add    %edx,%eax
c0103228:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)){                              // (2) check if entry is not present 
        struct Page *page;
c010322b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010322e:	8b 00                	mov    (%eax),%eax
c0103230:	83 e0 01             	and    $0x1,%eax
c0103233:	85 c0                	test   %eax,%eax
c0103235:	0f 85 af 00 00 00    	jne    c01032ea <get_pte+0xda>
        if (create){                                    // (3) check if creating is needed, then alloc page for page table
            if((page = alloc_page())==NULL)
                return NULL;
        }else
            return NULL;
c010323b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010323f:	74 15                	je     c0103256 <get_pte+0x46>
c0103241:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103248:	e8 0b f9 ff ff       	call   c0102b58 <alloc_pages>
c010324d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103250:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103254:	75 0a                	jne    c0103260 <get_pte+0x50>
        set_page_ref(page, 1);                          // (4) set page reference
c0103256:	b8 00 00 00 00       	mov    $0x0,%eax
c010325b:	e9 e7 00 00 00       	jmp    c0103347 <get_pte+0x137>
        uintptr_t addr = page2pa(page);                 // (5) get linear address of page
        memset(KADDR(addr), 0, PGSIZE);                  // (6) clear page content using memset
        *pdep = addr | PTE_U | PTE_W | PTE_P;             // (7) set page directory entry's permission
c0103260:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103267:	00 
c0103268:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010326b:	89 04 24             	mov    %eax,(%esp)
c010326e:	e8 ea f6 ff ff       	call   c010295d <set_page_ref>
    }
c0103273:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103276:	89 04 24             	mov    %eax,(%esp)
c0103279:	e8 c6 f5 ff ff       	call   c0102844 <page2pa>
c010327e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];// (8) return page table entry
c0103281:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103284:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103287:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010328a:	c1 e8 0c             	shr    $0xc,%eax
c010328d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103290:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103295:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103298:	72 23                	jb     c01032bd <get_pte+0xad>
c010329a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010329d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01032a1:	c7 44 24 08 a0 75 10 	movl   $0xc01075a0,0x8(%esp)
c01032a8:	c0 
c01032a9:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
c01032b0:	00 
c01032b1:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c01032b8:	e8 2c d1 ff ff       	call   c01003e9 <__panic>
c01032bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01032c0:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01032c5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01032cc:	00 
c01032cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01032d4:	00 
c01032d5:	89 04 24             	mov    %eax,(%esp)
c01032d8:	e8 7e 33 00 00       	call   c010665b <memset>
}
c01032dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032e0:	83 c8 07             	or     $0x7,%eax
c01032e3:	89 c2                	mov    %eax,%edx
c01032e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032e8:	89 10                	mov    %edx,(%eax)

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
c01032ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032ed:	8b 00                	mov    (%eax),%eax
c01032ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01032f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01032f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01032fa:	c1 e8 0c             	shr    $0xc,%eax
c01032fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103300:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103305:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103308:	72 23                	jb     c010332d <get_pte+0x11d>
c010330a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010330d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103311:	c7 44 24 08 a0 75 10 	movl   $0xc01075a0,0x8(%esp)
c0103318:	c0 
c0103319:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
c0103320:	00 
c0103321:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103328:	e8 bc d0 ff ff       	call   c01003e9 <__panic>
c010332d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103330:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103335:	89 c2                	mov    %eax,%edx
c0103337:	8b 45 0c             	mov    0xc(%ebp),%eax
c010333a:	c1 e8 0c             	shr    $0xc,%eax
c010333d:	25 ff 03 00 00       	and    $0x3ff,%eax
c0103342:	c1 e0 02             	shl    $0x2,%eax
c0103345:	01 d0                	add    %edx,%eax
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103347:	c9                   	leave  
c0103348:	c3                   	ret    

c0103349 <get_page>:
    if (ptep_store != NULL) {
        *ptep_store = ptep;
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103349:	55                   	push   %ebp
c010334a:	89 e5                	mov    %esp,%ebp
c010334c:	83 ec 28             	sub    $0x28,%esp
        return pte2page(*ptep);
c010334f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103356:	00 
c0103357:	8b 45 0c             	mov    0xc(%ebp),%eax
c010335a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010335e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103361:	89 04 24             	mov    %eax,(%esp)
c0103364:	e8 a7 fe ff ff       	call   c0103210 <get_pte>
c0103369:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
c010336c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103370:	74 08                	je     c010337a <get_page+0x31>
    return NULL;
c0103372:	8b 45 10             	mov    0x10(%ebp),%eax
c0103375:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103378:	89 10                	mov    %edx,(%eax)
}

c010337a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010337e:	74 1b                	je     c010339b <get_page+0x52>
c0103380:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103383:	8b 00                	mov    (%eax),%eax
c0103385:	83 e0 01             	and    $0x1,%eax
c0103388:	85 c0                	test   %eax,%eax
c010338a:	74 0f                	je     c010339b <get_page+0x52>
//page_remove_pte - free an Page sturct which is related linear address la
c010338c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010338f:	8b 00                	mov    (%eax),%eax
c0103391:	89 04 24             	mov    %eax,(%esp)
c0103394:	e8 64 f5 ff ff       	call   c01028fd <pte2page>
c0103399:	eb 05                	jmp    c01033a0 <get_page+0x57>
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
c010339b:	b8 00 00 00 00       	mov    $0x0,%eax
static inline void
c01033a0:	c9                   	leave  
c01033a1:	c3                   	ret    

c01033a2 <page_remove_pte>:
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
    /* LAB2 EXERCISE 3: YOUR CODE
     *
     * Please check if ptep is valid, and tlb must be manually updated if mapping is updated
     *
     * Maybe you want help comment, BELOW comments can help you finish the code
c01033a2:	55                   	push   %ebp
c01033a3:	89 e5                	mov    %esp,%ebp
c01033a5:	83 ec 28             	sub    $0x28,%esp
    if (*ptep & PTE_P) {   //PTE_P代表页存在
        struct Page *page = pte2page(*ptep); //这个函数用于获取二级页表对应的物理页
        if (page_ref_dec(page) == 0) { //page_ref_dec(page)将ref减1，判断是否只使用了一次（只被二级页表引用一次）
            free_page(page); //则可以释放这个页
        }
        *ptep = 0;//如果还有更多的页表应用了它，不能释放，要取消二级映射，把二级页表ixang清零
c01033a8:	8b 45 10             	mov    0x10(%ebp),%eax
c01033ab:	8b 00                	mov    (%eax),%eax
c01033ad:	83 e0 01             	and    $0x1,%eax
c01033b0:	85 c0                	test   %eax,%eax
c01033b2:	74 4d                	je     c0103401 <page_remove_pte+0x5f>
        tlb_invalidate(pgdir, la);//更新TLB，使TLB中的项无效（除非这个页表正在被使用）
c01033b4:	8b 45 10             	mov    0x10(%ebp),%eax
c01033b7:	8b 00                	mov    (%eax),%eax
c01033b9:	89 04 24             	mov    %eax,(%esp)
c01033bc:	e8 3c f5 ff ff       	call   c01028fd <pte2page>
c01033c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
c01033c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033c7:	89 04 24             	mov    %eax,(%esp)
c01033ca:	e8 b3 f5 ff ff       	call   c0102982 <page_ref_dec>
c01033cf:	85 c0                	test   %eax,%eax
c01033d1:	75 13                	jne    c01033e6 <page_remove_pte+0x44>
}
c01033d3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033da:	00 
c01033db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033de:	89 04 24             	mov    %eax,(%esp)
c01033e1:	e8 aa f7 ff ff       	call   c0102b90 <free_pages>

//page_remove - free an Page which is related linear address la and has an validated pte
c01033e6:	8b 45 10             	mov    0x10(%ebp),%eax
c01033e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
void
c01033ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033f2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01033f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01033f9:	89 04 24             	mov    %eax,(%esp)
c01033fc:	e8 01 01 00 00       	call   c0103502 <tlb_invalidate>
page_remove(pde_t *pgdir, uintptr_t la) {
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103401:	90                   	nop
c0103402:	c9                   	leave  
c0103403:	c3                   	ret    

c0103404 <page_remove>:
    if (ptep != NULL) {
        page_remove_pte(pgdir, la, ptep);
    }
}
c0103404:	55                   	push   %ebp
c0103405:	89 e5                	mov    %esp,%ebp
c0103407:	83 ec 28             	sub    $0x28,%esp

c010340a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103411:	00 
c0103412:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103415:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103419:	8b 45 08             	mov    0x8(%ebp),%eax
c010341c:	89 04 24             	mov    %eax,(%esp)
c010341f:	e8 ec fd ff ff       	call   c0103210 <get_pte>
c0103424:	89 45 f4             	mov    %eax,-0xc(%ebp)
//page_insert - build the map of phy addr of an Page with the linear addr la
c0103427:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010342b:	74 19                	je     c0103446 <page_remove+0x42>
// paramemters:
c010342d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103430:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103434:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103437:	89 44 24 04          	mov    %eax,0x4(%esp)
c010343b:	8b 45 08             	mov    0x8(%ebp),%eax
c010343e:	89 04 24             	mov    %eax,(%esp)
c0103441:	e8 5c ff ff ff       	call   c01033a2 <page_remove_pte>
//  pgdir: the kernel virtual base address of PDT
//  page:  the Page which need to map
c0103446:	90                   	nop
c0103447:	c9                   	leave  
c0103448:	c3                   	ret    

c0103449 <page_insert>:
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL) {
        return -E_NO_MEM;
    }
    page_ref_inc(page);
c0103449:	55                   	push   %ebp
c010344a:	89 e5                	mov    %esp,%ebp
c010344c:	83 ec 28             	sub    $0x28,%esp
    if (*ptep & PTE_P) {
c010344f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103456:	00 
c0103457:	8b 45 10             	mov    0x10(%ebp),%eax
c010345a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010345e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103461:	89 04 24             	mov    %eax,(%esp)
c0103464:	e8 a7 fd ff ff       	call   c0103210 <get_pte>
c0103469:	89 45 f4             	mov    %eax,-0xc(%ebp)
        struct Page *p = pte2page(*ptep);
c010346c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103470:	75 0a                	jne    c010347c <page_insert+0x33>
        if (p == page) {
c0103472:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103477:	e9 84 00 00 00       	jmp    c0103500 <page_insert+0xb7>
            page_ref_dec(page);
        }
c010347c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010347f:	89 04 24             	mov    %eax,(%esp)
c0103482:	e8 e4 f4 ff ff       	call   c010296b <page_ref_inc>
        else {
c0103487:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010348a:	8b 00                	mov    (%eax),%eax
c010348c:	83 e0 01             	and    $0x1,%eax
c010348f:	85 c0                	test   %eax,%eax
c0103491:	74 3e                	je     c01034d1 <page_insert+0x88>
            page_remove_pte(pgdir, la, ptep);
c0103493:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103496:	8b 00                	mov    (%eax),%eax
c0103498:	89 04 24             	mov    %eax,(%esp)
c010349b:	e8 5d f4 ff ff       	call   c01028fd <pte2page>
c01034a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
c01034a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034a6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01034a9:	75 0d                	jne    c01034b8 <page_insert+0x6f>
    }
c01034ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034ae:	89 04 24             	mov    %eax,(%esp)
c01034b1:	e8 cc f4 ff ff       	call   c0102982 <page_ref_dec>
c01034b6:	eb 19                	jmp    c01034d1 <page_insert+0x88>
    *ptep = page2pa(page) | PTE_P | perm;
    tlb_invalidate(pgdir, la);
    return 0;
c01034b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034bb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01034bf:	8b 45 10             	mov    0x10(%ebp),%eax
c01034c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01034c9:	89 04 24             	mov    %eax,(%esp)
c01034cc:	e8 d1 fe ff ff       	call   c01033a2 <page_remove_pte>
}

// invalidate a TLB entry, but only if the page tables being
c01034d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034d4:	89 04 24             	mov    %eax,(%esp)
c01034d7:	e8 68 f3 ff ff       	call   c0102844 <page2pa>
c01034dc:	0b 45 14             	or     0x14(%ebp),%eax
c01034df:	83 c8 01             	or     $0x1,%eax
c01034e2:	89 c2                	mov    %eax,%edx
c01034e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034e7:	89 10                	mov    %edx,(%eax)
// edited are the ones currently in use by the processor.
c01034e9:	8b 45 10             	mov    0x10(%ebp),%eax
c01034ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01034f3:	89 04 24             	mov    %eax,(%esp)
c01034f6:	e8 07 00 00 00       	call   c0103502 <tlb_invalidate>
void
c01034fb:	b8 00 00 00 00       	mov    $0x0,%eax
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0103500:	c9                   	leave  
c0103501:	c3                   	ret    

c0103502 <tlb_invalidate>:
    if (rcr3() == PADDR(pgdir)) {
        invlpg((void *)la);
    }
}

c0103502:	55                   	push   %ebp
c0103503:	89 e5                	mov    %esp,%ebp
c0103505:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103508:	0f 20 d8             	mov    %cr3,%eax
c010350b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c010350e:	8b 55 f0             	mov    -0x10(%ebp),%edx
static void
c0103511:	8b 45 08             	mov    0x8(%ebp),%eax
c0103514:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103517:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010351e:	77 23                	ja     c0103543 <tlb_invalidate+0x41>
c0103520:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103523:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103527:	c7 44 24 08 44 76 10 	movl   $0xc0107644,0x8(%esp)
c010352e:	c0 
c010352f:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c0103536:	00 
c0103537:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c010353e:	e8 a6 ce ff ff       	call   c01003e9 <__panic>
c0103543:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103546:	05 00 00 00 40       	add    $0x40000000,%eax
c010354b:	39 d0                	cmp    %edx,%eax
c010354d:	75 0c                	jne    c010355b <tlb_invalidate+0x59>
check_alloc_page(void) {
c010354f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103552:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103555:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103558:	0f 01 38             	invlpg (%eax)
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
c010355b:	90                   	nop
c010355c:	c9                   	leave  
c010355d:	c3                   	ret    

c010355e <check_alloc_page>:
}

static void
c010355e:	55                   	push   %ebp
c010355f:	89 e5                	mov    %esp,%ebp
c0103561:	83 ec 18             	sub    $0x18,%esp
check_pgdir(void) {
c0103564:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0103569:	8b 40 18             	mov    0x18(%eax),%eax
c010356c:	ff d0                	call   *%eax
    assert(npage <= KMEMSIZE / PGSIZE);
c010356e:	c7 04 24 c8 76 10 c0 	movl   $0xc01076c8,(%esp)
c0103575:	e8 18 cd ff ff       	call   c0100292 <cprintf>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010357a:	90                   	nop
c010357b:	c9                   	leave  
c010357c:	c3                   	ret    

c010357d <check_pgdir>:
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);

    struct Page *p1, *p2;
c010357d:	55                   	push   %ebp
c010357e:	89 e5                	mov    %esp,%ebp
c0103580:	83 ec 38             	sub    $0x38,%esp
    p1 = alloc_page();
c0103583:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103588:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010358d:	76 24                	jbe    c01035b3 <check_pgdir+0x36>
c010358f:	c7 44 24 0c e7 76 10 	movl   $0xc01076e7,0xc(%esp)
c0103596:	c0 
c0103597:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c010359e:	c0 
c010359f:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c01035a6:	00 
c01035a7:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c01035ae:	e8 36 ce ff ff       	call   c01003e9 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01035b3:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01035b8:	85 c0                	test   %eax,%eax
c01035ba:	74 0e                	je     c01035ca <check_pgdir+0x4d>
c01035bc:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01035c1:	25 ff 0f 00 00       	and    $0xfff,%eax
c01035c6:	85 c0                	test   %eax,%eax
c01035c8:	74 24                	je     c01035ee <check_pgdir+0x71>
c01035ca:	c7 44 24 0c 04 77 10 	movl   $0xc0107704,0xc(%esp)
c01035d1:	c0 
c01035d2:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c01035d9:	c0 
c01035da:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c01035e1:	00 
c01035e2:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c01035e9:	e8 fb cd ff ff       	call   c01003e9 <__panic>

c01035ee:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01035f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01035fa:	00 
c01035fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103602:	00 
c0103603:	89 04 24             	mov    %eax,(%esp)
c0103606:	e8 3e fd ff ff       	call   c0103349 <get_page>
c010360b:	85 c0                	test   %eax,%eax
c010360d:	74 24                	je     c0103633 <check_pgdir+0xb6>
c010360f:	c7 44 24 0c 3c 77 10 	movl   $0xc010773c,0xc(%esp)
c0103616:	c0 
c0103617:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c010361e:	c0 
c010361f:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0103626:	00 
c0103627:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c010362e:	e8 b6 cd ff ff       	call   c01003e9 <__panic>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
c0103633:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010363a:	e8 19 f5 ff ff       	call   c0102b58 <alloc_pages>
c010363f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_ref(p1) == 1);
c0103642:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103647:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010364e:	00 
c010364f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103656:	00 
c0103657:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010365a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010365e:	89 04 24             	mov    %eax,(%esp)
c0103661:	e8 e3 fd ff ff       	call   c0103449 <page_insert>
c0103666:	85 c0                	test   %eax,%eax
c0103668:	74 24                	je     c010368e <check_pgdir+0x111>
c010366a:	c7 44 24 0c 64 77 10 	movl   $0xc0107764,0xc(%esp)
c0103671:	c0 
c0103672:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103679:	c0 
c010367a:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0103681:	00 
c0103682:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103689:	e8 5b cd ff ff       	call   c01003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c010368e:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103693:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010369a:	00 
c010369b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01036a2:	00 
c01036a3:	89 04 24             	mov    %eax,(%esp)
c01036a6:	e8 65 fb ff ff       	call   c0103210 <get_pte>
c01036ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01036ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01036b2:	75 24                	jne    c01036d8 <check_pgdir+0x15b>
c01036b4:	c7 44 24 0c 90 77 10 	movl   $0xc0107790,0xc(%esp)
c01036bb:	c0 
c01036bc:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c01036c3:	c0 
c01036c4:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c01036cb:	00 
c01036cc:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c01036d3:	e8 11 cd ff ff       	call   c01003e9 <__panic>

c01036d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036db:	8b 00                	mov    (%eax),%eax
c01036dd:	89 04 24             	mov    %eax,(%esp)
c01036e0:	e8 18 f2 ff ff       	call   c01028fd <pte2page>
c01036e5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01036e8:	74 24                	je     c010370e <check_pgdir+0x191>
c01036ea:	c7 44 24 0c bd 77 10 	movl   $0xc01077bd,0xc(%esp)
c01036f1:	c0 
c01036f2:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c01036f9:	c0 
c01036fa:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0103701:	00 
c0103702:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103709:	e8 db cc ff ff       	call   c01003e9 <__panic>
    p2 = alloc_page();
c010370e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103711:	89 04 24             	mov    %eax,(%esp)
c0103714:	e8 3a f2 ff ff       	call   c0102953 <page_ref>
c0103719:	83 f8 01             	cmp    $0x1,%eax
c010371c:	74 24                	je     c0103742 <check_pgdir+0x1c5>
c010371e:	c7 44 24 0c d3 77 10 	movl   $0xc01077d3,0xc(%esp)
c0103725:	c0 
c0103726:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c010372d:	c0 
c010372e:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0103735:	00 
c0103736:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c010373d:	e8 a7 cc ff ff       	call   c01003e9 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103742:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103747:	8b 00                	mov    (%eax),%eax
c0103749:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010374e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103751:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103754:	c1 e8 0c             	shr    $0xc,%eax
c0103757:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010375a:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c010375f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103762:	72 23                	jb     c0103787 <check_pgdir+0x20a>
c0103764:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103767:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010376b:	c7 44 24 08 a0 75 10 	movl   $0xc01075a0,0x8(%esp)
c0103772:	c0 
c0103773:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c010377a:	00 
c010377b:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103782:	e8 62 cc ff ff       	call   c01003e9 <__panic>
c0103787:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010378a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010378f:	83 c0 04             	add    $0x4,%eax
c0103792:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(*ptep & PTE_U);
c0103795:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010379a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01037a1:	00 
c01037a2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01037a9:	00 
c01037aa:	89 04 24             	mov    %eax,(%esp)
c01037ad:	e8 5e fa ff ff       	call   c0103210 <get_pte>
c01037b2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01037b5:	74 24                	je     c01037db <check_pgdir+0x25e>
c01037b7:	c7 44 24 0c e8 77 10 	movl   $0xc01077e8,0xc(%esp)
c01037be:	c0 
c01037bf:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c01037c6:	c0 
c01037c7:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c01037ce:	00 
c01037cf:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c01037d6:	e8 0e cc ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_W);
    assert(boot_pgdir[0] & PTE_U);
c01037db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01037e2:	e8 71 f3 ff ff       	call   c0102b58 <alloc_pages>
c01037e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_ref(p2) == 1);
c01037ea:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01037ef:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01037f6:	00 
c01037f7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01037fe:	00 
c01037ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103802:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103806:	89 04 24             	mov    %eax,(%esp)
c0103809:	e8 3b fc ff ff       	call   c0103449 <page_insert>
c010380e:	85 c0                	test   %eax,%eax
c0103810:	74 24                	je     c0103836 <check_pgdir+0x2b9>
c0103812:	c7 44 24 0c 10 78 10 	movl   $0xc0107810,0xc(%esp)
c0103819:	c0 
c010381a:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103821:	c0 
c0103822:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0103829:	00 
c010382a:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103831:	e8 b3 cb ff ff       	call   c01003e9 <__panic>

c0103836:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010383b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103842:	00 
c0103843:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010384a:	00 
c010384b:	89 04 24             	mov    %eax,(%esp)
c010384e:	e8 bd f9 ff ff       	call   c0103210 <get_pte>
c0103853:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103856:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010385a:	75 24                	jne    c0103880 <check_pgdir+0x303>
c010385c:	c7 44 24 0c 48 78 10 	movl   $0xc0107848,0xc(%esp)
c0103863:	c0 
c0103864:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c010386b:	c0 
c010386c:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0103873:	00 
c0103874:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c010387b:	e8 69 cb ff ff       	call   c01003e9 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103880:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103883:	8b 00                	mov    (%eax),%eax
c0103885:	83 e0 04             	and    $0x4,%eax
c0103888:	85 c0                	test   %eax,%eax
c010388a:	75 24                	jne    c01038b0 <check_pgdir+0x333>
c010388c:	c7 44 24 0c 78 78 10 	movl   $0xc0107878,0xc(%esp)
c0103893:	c0 
c0103894:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c010389b:	c0 
c010389c:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c01038a3:	00 
c01038a4:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c01038ab:	e8 39 cb ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 2);
c01038b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038b3:	8b 00                	mov    (%eax),%eax
c01038b5:	83 e0 02             	and    $0x2,%eax
c01038b8:	85 c0                	test   %eax,%eax
c01038ba:	75 24                	jne    c01038e0 <check_pgdir+0x363>
c01038bc:	c7 44 24 0c 86 78 10 	movl   $0xc0107886,0xc(%esp)
c01038c3:	c0 
c01038c4:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c01038cb:	c0 
c01038cc:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c01038d3:	00 
c01038d4:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c01038db:	e8 09 cb ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c01038e0:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01038e5:	8b 00                	mov    (%eax),%eax
c01038e7:	83 e0 04             	and    $0x4,%eax
c01038ea:	85 c0                	test   %eax,%eax
c01038ec:	75 24                	jne    c0103912 <check_pgdir+0x395>
c01038ee:	c7 44 24 0c 94 78 10 	movl   $0xc0107894,0xc(%esp)
c01038f5:	c0 
c01038f6:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c01038fd:	c0 
c01038fe:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0103905:	00 
c0103906:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c010390d:	e8 d7 ca ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103912:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103915:	89 04 24             	mov    %eax,(%esp)
c0103918:	e8 36 f0 ff ff       	call   c0102953 <page_ref>
c010391d:	83 f8 01             	cmp    $0x1,%eax
c0103920:	74 24                	je     c0103946 <check_pgdir+0x3c9>
c0103922:	c7 44 24 0c aa 78 10 	movl   $0xc01078aa,0xc(%esp)
c0103929:	c0 
c010392a:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103931:	c0 
c0103932:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0103939:	00 
c010393a:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103941:	e8 a3 ca ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
    assert((*ptep & PTE_U) == 0);
c0103946:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010394b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103952:	00 
c0103953:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010395a:	00 
c010395b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010395e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103962:	89 04 24             	mov    %eax,(%esp)
c0103965:	e8 df fa ff ff       	call   c0103449 <page_insert>
c010396a:	85 c0                	test   %eax,%eax
c010396c:	74 24                	je     c0103992 <check_pgdir+0x415>
c010396e:	c7 44 24 0c bc 78 10 	movl   $0xc01078bc,0xc(%esp)
c0103975:	c0 
c0103976:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c010397d:	c0 
c010397e:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c0103985:	00 
c0103986:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c010398d:	e8 57 ca ff ff       	call   c01003e9 <__panic>

c0103992:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103995:	89 04 24             	mov    %eax,(%esp)
c0103998:	e8 b6 ef ff ff       	call   c0102953 <page_ref>
c010399d:	83 f8 02             	cmp    $0x2,%eax
c01039a0:	74 24                	je     c01039c6 <check_pgdir+0x449>
c01039a2:	c7 44 24 0c e8 78 10 	movl   $0xc01078e8,0xc(%esp)
c01039a9:	c0 
c01039aa:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c01039b1:	c0 
c01039b2:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c01039b9:	00 
c01039ba:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c01039c1:	e8 23 ca ff ff       	call   c01003e9 <__panic>
    page_remove(boot_pgdir, 0x0);
c01039c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039c9:	89 04 24             	mov    %eax,(%esp)
c01039cc:	e8 82 ef ff ff       	call   c0102953 <page_ref>
c01039d1:	85 c0                	test   %eax,%eax
c01039d3:	74 24                	je     c01039f9 <check_pgdir+0x47c>
c01039d5:	c7 44 24 0c fa 78 10 	movl   $0xc01078fa,0xc(%esp)
c01039dc:	c0 
c01039dd:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c01039e4:	c0 
c01039e5:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c01039ec:	00 
c01039ed:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c01039f4:	e8 f0 c9 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 1);
c01039f9:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01039fe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103a05:	00 
c0103a06:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103a0d:	00 
c0103a0e:	89 04 24             	mov    %eax,(%esp)
c0103a11:	e8 fa f7 ff ff       	call   c0103210 <get_pte>
c0103a16:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a1d:	75 24                	jne    c0103a43 <check_pgdir+0x4c6>
c0103a1f:	c7 44 24 0c 48 78 10 	movl   $0xc0107848,0xc(%esp)
c0103a26:	c0 
c0103a27:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103a2e:	c0 
c0103a2f:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0103a36:	00 
c0103a37:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103a3e:	e8 a6 c9 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a46:	8b 00                	mov    (%eax),%eax
c0103a48:	89 04 24             	mov    %eax,(%esp)
c0103a4b:	e8 ad ee ff ff       	call   c01028fd <pte2page>
c0103a50:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103a53:	74 24                	je     c0103a79 <check_pgdir+0x4fc>
c0103a55:	c7 44 24 0c bd 77 10 	movl   $0xc01077bd,0xc(%esp)
c0103a5c:	c0 
c0103a5d:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103a64:	c0 
c0103a65:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c0103a6c:	00 
c0103a6d:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103a74:	e8 70 c9 ff ff       	call   c01003e9 <__panic>

c0103a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a7c:	8b 00                	mov    (%eax),%eax
c0103a7e:	83 e0 04             	and    $0x4,%eax
c0103a81:	85 c0                	test   %eax,%eax
c0103a83:	74 24                	je     c0103aa9 <check_pgdir+0x52c>
c0103a85:	c7 44 24 0c 0c 79 10 	movl   $0xc010790c,0xc(%esp)
c0103a8c:	c0 
c0103a8d:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103a94:	c0 
c0103a95:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0103a9c:	00 
c0103a9d:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103aa4:	e8 40 c9 ff ff       	call   c01003e9 <__panic>
    page_remove(boot_pgdir, PGSIZE);
    assert(page_ref(p1) == 0);
c0103aa9:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103aae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103ab5:	00 
c0103ab6:	89 04 24             	mov    %eax,(%esp)
c0103ab9:	e8 46 f9 ff ff       	call   c0103404 <page_remove>
    assert(page_ref(p2) == 0);
c0103abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ac1:	89 04 24             	mov    %eax,(%esp)
c0103ac4:	e8 8a ee ff ff       	call   c0102953 <page_ref>
c0103ac9:	83 f8 01             	cmp    $0x1,%eax
c0103acc:	74 24                	je     c0103af2 <check_pgdir+0x575>
c0103ace:	c7 44 24 0c d3 77 10 	movl   $0xc01077d3,0xc(%esp)
c0103ad5:	c0 
c0103ad6:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103add:	c0 
c0103ade:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0103ae5:	00 
c0103ae6:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103aed:	e8 f7 c8 ff ff       	call   c01003e9 <__panic>

c0103af2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103af5:	89 04 24             	mov    %eax,(%esp)
c0103af8:	e8 56 ee ff ff       	call   c0102953 <page_ref>
c0103afd:	85 c0                	test   %eax,%eax
c0103aff:	74 24                	je     c0103b25 <check_pgdir+0x5a8>
c0103b01:	c7 44 24 0c fa 78 10 	movl   $0xc01078fa,0xc(%esp)
c0103b08:	c0 
c0103b09:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103b10:	c0 
c0103b11:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0103b18:	00 
c0103b19:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103b20:	e8 c4 c8 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
    free_page(pde2page(boot_pgdir[0]));
c0103b25:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103b2a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103b31:	00 
c0103b32:	89 04 24             	mov    %eax,(%esp)
c0103b35:	e8 ca f8 ff ff       	call   c0103404 <page_remove>
    boot_pgdir[0] = 0;
c0103b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b3d:	89 04 24             	mov    %eax,(%esp)
c0103b40:	e8 0e ee ff ff       	call   c0102953 <page_ref>
c0103b45:	85 c0                	test   %eax,%eax
c0103b47:	74 24                	je     c0103b6d <check_pgdir+0x5f0>
c0103b49:	c7 44 24 0c 21 79 10 	movl   $0xc0107921,0xc(%esp)
c0103b50:	c0 
c0103b51:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103b58:	c0 
c0103b59:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0103b60:	00 
c0103b61:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103b68:	e8 7c c8 ff ff       	call   c01003e9 <__panic>

c0103b6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b70:	89 04 24             	mov    %eax,(%esp)
c0103b73:	e8 db ed ff ff       	call   c0102953 <page_ref>
c0103b78:	85 c0                	test   %eax,%eax
c0103b7a:	74 24                	je     c0103ba0 <check_pgdir+0x623>
c0103b7c:	c7 44 24 0c fa 78 10 	movl   $0xc01078fa,0xc(%esp)
c0103b83:	c0 
c0103b84:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103b8b:	c0 
c0103b8c:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0103b93:	00 
c0103b94:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103b9b:	e8 49 c8 ff ff       	call   c01003e9 <__panic>
    cprintf("check_pgdir() succeeded!\n");
}
c0103ba0:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103ba5:	8b 00                	mov    (%eax),%eax
c0103ba7:	89 04 24             	mov    %eax,(%esp)
c0103baa:	e8 8c ed ff ff       	call   c010293b <pde2page>
c0103baf:	89 04 24             	mov    %eax,(%esp)
c0103bb2:	e8 9c ed ff ff       	call   c0102953 <page_ref>
c0103bb7:	83 f8 01             	cmp    $0x1,%eax
c0103bba:	74 24                	je     c0103be0 <check_pgdir+0x663>
c0103bbc:	c7 44 24 0c 34 79 10 	movl   $0xc0107934,0xc(%esp)
c0103bc3:	c0 
c0103bc4:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103bcb:	c0 
c0103bcc:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0103bd3:	00 
c0103bd4:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103bdb:	e8 09 c8 ff ff       	call   c01003e9 <__panic>

c0103be0:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103be5:	8b 00                	mov    (%eax),%eax
c0103be7:	89 04 24             	mov    %eax,(%esp)
c0103bea:	e8 4c ed ff ff       	call   c010293b <pde2page>
c0103bef:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103bf6:	00 
c0103bf7:	89 04 24             	mov    %eax,(%esp)
c0103bfa:	e8 91 ef ff ff       	call   c0102b90 <free_pages>
static void
c0103bff:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103c04:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
check_boot_pgdir(void) {
    pte_t *ptep;
c0103c0a:	c7 04 24 5b 79 10 c0 	movl   $0xc010795b,(%esp)
c0103c11:	e8 7c c6 ff ff       	call   c0100292 <cprintf>
    int i;
c0103c16:	90                   	nop
c0103c17:	c9                   	leave  
c0103c18:	c3                   	ret    

c0103c19 <check_boot_pgdir>:
    for (i = 0; i < npage; i += PGSIZE) {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
c0103c19:	55                   	push   %ebp
c0103c1a:	89 e5                	mov    %esp,%ebp
c0103c1c:	83 ec 38             	sub    $0x38,%esp
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103c1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103c26:	e9 ca 00 00 00       	jmp    c0103cf5 <check_boot_pgdir+0xdc>

c0103c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103c31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c34:	c1 e8 0c             	shr    $0xc,%eax
c0103c37:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103c3a:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103c3f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103c42:	72 23                	jb     c0103c67 <check_boot_pgdir+0x4e>
c0103c44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c47:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103c4b:	c7 44 24 08 a0 75 10 	movl   $0xc01075a0,0x8(%esp)
c0103c52:	c0 
c0103c53:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0103c5a:	00 
c0103c5b:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103c62:	e8 82 c7 ff ff       	call   c01003e9 <__panic>
c0103c67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c6a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103c6f:	89 c2                	mov    %eax,%edx
c0103c71:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103c76:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103c7d:	00 
c0103c7e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103c82:	89 04 24             	mov    %eax,(%esp)
c0103c85:	e8 86 f5 ff ff       	call   c0103210 <get_pte>
c0103c8a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103c8d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103c91:	75 24                	jne    c0103cb7 <check_boot_pgdir+0x9e>
c0103c93:	c7 44 24 0c 78 79 10 	movl   $0xc0107978,0xc(%esp)
c0103c9a:	c0 
c0103c9b:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103ca2:	c0 
c0103ca3:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0103caa:	00 
c0103cab:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103cb2:	e8 32 c7 ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir[0] == 0);
c0103cb7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cba:	8b 00                	mov    (%eax),%eax
c0103cbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103cc1:	89 c2                	mov    %eax,%edx
c0103cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cc6:	39 c2                	cmp    %eax,%edx
c0103cc8:	74 24                	je     c0103cee <check_boot_pgdir+0xd5>
c0103cca:	c7 44 24 0c b5 79 10 	movl   $0xc01079b5,0xc(%esp)
c0103cd1:	c0 
c0103cd2:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103cd9:	c0 
c0103cda:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0103ce1:	00 
c0103ce2:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103ce9:	e8 fb c6 ff ff       	call   c01003e9 <__panic>
    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103cee:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103cf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103cf8:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103cfd:	39 c2                	cmp    %eax,%edx
c0103cff:	0f 82 26 ff ff ff    	jb     c0103c2b <check_boot_pgdir+0x12>

    struct Page *p;
    p = alloc_page();
c0103d05:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103d0a:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103d0f:	8b 00                	mov    (%eax),%eax
c0103d11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d16:	89 c2                	mov    %eax,%edx
c0103d18:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103d1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103d20:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103d27:	77 23                	ja     c0103d4c <check_boot_pgdir+0x133>
c0103d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103d30:	c7 44 24 08 44 76 10 	movl   $0xc0107644,0x8(%esp)
c0103d37:	c0 
c0103d38:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0103d3f:	00 
c0103d40:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103d47:	e8 9d c6 ff ff       	call   c01003e9 <__panic>
c0103d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d4f:	05 00 00 00 40       	add    $0x40000000,%eax
c0103d54:	39 d0                	cmp    %edx,%eax
c0103d56:	74 24                	je     c0103d7c <check_boot_pgdir+0x163>
c0103d58:	c7 44 24 0c cc 79 10 	movl   $0xc01079cc,0xc(%esp)
c0103d5f:	c0 
c0103d60:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103d67:	c0 
c0103d68:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0103d6f:	00 
c0103d70:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103d77:	e8 6d c6 ff ff       	call   c01003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
    assert(page_ref(p) == 1);
c0103d7c:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103d81:	8b 00                	mov    (%eax),%eax
c0103d83:	85 c0                	test   %eax,%eax
c0103d85:	74 24                	je     c0103dab <check_boot_pgdir+0x192>
c0103d87:	c7 44 24 0c 00 7a 10 	movl   $0xc0107a00,0xc(%esp)
c0103d8e:	c0 
c0103d8f:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103d96:	c0 
c0103d97:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0103d9e:	00 
c0103d9f:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103da6:	e8 3e c6 ff ff       	call   c01003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
    assert(page_ref(p) == 2);

c0103dab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103db2:	e8 a1 ed ff ff       	call   c0102b58 <alloc_pages>
c0103db7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    const char *str = "ucore: Hello world!!";
c0103dba:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103dbf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103dc6:	00 
c0103dc7:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103dce:	00 
c0103dcf:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103dd2:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103dd6:	89 04 24             	mov    %eax,(%esp)
c0103dd9:	e8 6b f6 ff ff       	call   c0103449 <page_insert>
c0103dde:	85 c0                	test   %eax,%eax
c0103de0:	74 24                	je     c0103e06 <check_boot_pgdir+0x1ed>
c0103de2:	c7 44 24 0c 14 7a 10 	movl   $0xc0107a14,0xc(%esp)
c0103de9:	c0 
c0103dea:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103df1:	c0 
c0103df2:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c0103df9:	00 
c0103dfa:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103e01:	e8 e3 c5 ff ff       	call   c01003e9 <__panic>
    strcpy((void *)0x100, str);
c0103e06:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e09:	89 04 24             	mov    %eax,(%esp)
c0103e0c:	e8 42 eb ff ff       	call   c0102953 <page_ref>
c0103e11:	83 f8 01             	cmp    $0x1,%eax
c0103e14:	74 24                	je     c0103e3a <check_boot_pgdir+0x221>
c0103e16:	c7 44 24 0c 42 7a 10 	movl   $0xc0107a42,0xc(%esp)
c0103e1d:	c0 
c0103e1e:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103e25:	c0 
c0103e26:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0103e2d:	00 
c0103e2e:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103e35:	e8 af c5 ff ff       	call   c01003e9 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0103e3a:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103e3f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103e46:	00 
c0103e47:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0103e4e:	00 
c0103e4f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103e52:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e56:	89 04 24             	mov    %eax,(%esp)
c0103e59:	e8 eb f5 ff ff       	call   c0103449 <page_insert>
c0103e5e:	85 c0                	test   %eax,%eax
c0103e60:	74 24                	je     c0103e86 <check_boot_pgdir+0x26d>
c0103e62:	c7 44 24 0c 54 7a 10 	movl   $0xc0107a54,0xc(%esp)
c0103e69:	c0 
c0103e6a:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103e71:	c0 
c0103e72:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c0103e79:	00 
c0103e7a:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103e81:	e8 63 c5 ff ff       	call   c01003e9 <__panic>

c0103e86:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e89:	89 04 24             	mov    %eax,(%esp)
c0103e8c:	e8 c2 ea ff ff       	call   c0102953 <page_ref>
c0103e91:	83 f8 02             	cmp    $0x2,%eax
c0103e94:	74 24                	je     c0103eba <check_boot_pgdir+0x2a1>
c0103e96:	c7 44 24 0c 8b 7a 10 	movl   $0xc0107a8b,0xc(%esp)
c0103e9d:	c0 
c0103e9e:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103ea5:	c0 
c0103ea6:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c0103ead:	00 
c0103eae:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103eb5:	e8 2f c5 ff ff       	call   c01003e9 <__panic>
    *(char *)(page2kva(p) + 0x100) = '\0';
    assert(strlen((const char *)0x100) == 0);
c0103eba:	c7 45 e8 9c 7a 10 c0 	movl   $0xc0107a9c,-0x18(%ebp)

c0103ec1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103ec4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ec8:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103ecf:	e8 bd 24 00 00       	call   c0106391 <strcpy>
    free_page(p);
c0103ed4:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0103edb:	00 
c0103edc:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103ee3:	e8 20 25 00 00       	call   c0106408 <strcmp>
c0103ee8:	85 c0                	test   %eax,%eax
c0103eea:	74 24                	je     c0103f10 <check_boot_pgdir+0x2f7>
c0103eec:	c7 44 24 0c b4 7a 10 	movl   $0xc0107ab4,0xc(%esp)
c0103ef3:	c0 
c0103ef4:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103efb:	c0 
c0103efc:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
c0103f03:	00 
c0103f04:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103f0b:	e8 d9 c4 ff ff       	call   c01003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
    boot_pgdir[0] = 0;
c0103f10:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f13:	89 04 24             	mov    %eax,(%esp)
c0103f16:	e8 8e e9 ff ff       	call   c01028a9 <page2kva>
c0103f1b:	05 00 01 00 00       	add    $0x100,%eax
c0103f20:	c6 00 00             	movb   $0x0,(%eax)

c0103f23:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f2a:	e8 0c 24 00 00       	call   c010633b <strlen>
c0103f2f:	85 c0                	test   %eax,%eax
c0103f31:	74 24                	je     c0103f57 <check_boot_pgdir+0x33e>
c0103f33:	c7 44 24 0c ec 7a 10 	movl   $0xc0107aec,0xc(%esp)
c0103f3a:	c0 
c0103f3b:	c7 44 24 08 8d 76 10 	movl   $0xc010768d,0x8(%esp)
c0103f42:	c0 
c0103f43:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
c0103f4a:	00 
c0103f4b:	c7 04 24 68 76 10 c0 	movl   $0xc0107668,(%esp)
c0103f52:	e8 92 c4 ff ff       	call   c01003e9 <__panic>
    cprintf("check_boot_pgdir() succeeded!\n");
}
c0103f57:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f5e:	00 
c0103f5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f62:	89 04 24             	mov    %eax,(%esp)
c0103f65:	e8 26 ec ff ff       	call   c0102b90 <free_pages>

c0103f6a:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103f6f:	8b 00                	mov    (%eax),%eax
c0103f71:	89 04 24             	mov    %eax,(%esp)
c0103f74:	e8 c2 e9 ff ff       	call   c010293b <pde2page>
c0103f79:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f80:	00 
c0103f81:	89 04 24             	mov    %eax,(%esp)
c0103f84:	e8 07 ec ff ff       	call   c0102b90 <free_pages>
//perm2str - use string 'u,r,w,-' to present the permission
c0103f89:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103f8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
static const char *
perm2str(int perm) {
c0103f94:	c7 04 24 10 7b 10 c0 	movl   $0xc0107b10,(%esp)
c0103f9b:	e8 f2 c2 ff ff       	call   c0100292 <cprintf>
    static char str[4];
c0103fa0:	90                   	nop
c0103fa1:	c9                   	leave  
c0103fa2:	c3                   	ret    

c0103fa3 <perm2str>:
    str[0] = (perm & PTE_U) ? 'u' : '-';
    str[1] = 'r';
    str[2] = (perm & PTE_W) ? 'w' : '-';
    str[3] = '\0';
c0103fa3:	55                   	push   %ebp
c0103fa4:	89 e5                	mov    %esp,%ebp
    return str;
}
c0103fa6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fa9:	83 e0 04             	and    $0x4,%eax
c0103fac:	85 c0                	test   %eax,%eax
c0103fae:	74 04                	je     c0103fb4 <perm2str+0x11>
c0103fb0:	b0 75                	mov    $0x75,%al
c0103fb2:	eb 02                	jmp    c0103fb6 <perm2str+0x13>
c0103fb4:	b0 2d                	mov    $0x2d,%al
c0103fb6:	a2 08 df 11 c0       	mov    %al,0xc011df08

c0103fbb:	c6 05 09 df 11 c0 72 	movb   $0x72,0xc011df09
//get_pgtable_items - In [left, right] range of PDT or PT, find a continuous linear addr space
c0103fc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fc5:	83 e0 02             	and    $0x2,%eax
c0103fc8:	85 c0                	test   %eax,%eax
c0103fca:	74 04                	je     c0103fd0 <perm2str+0x2d>
c0103fcc:	b0 77                	mov    $0x77,%al
c0103fce:	eb 02                	jmp    c0103fd2 <perm2str+0x2f>
c0103fd0:	b0 2d                	mov    $0x2d,%al
c0103fd2:	a2 0a df 11 c0       	mov    %al,0xc011df0a
//                  - (left_store*X_SIZE~right_store*X_SIZE) for PDT or PT
c0103fd7:	c6 05 0b df 11 c0 00 	movb   $0x0,0xc011df0b
//                  - X_SIZE=PTSIZE=4M, if PDT; X_SIZE=PGSIZE=4K, if PT
c0103fde:	b8 08 df 11 c0       	mov    $0xc011df08,%eax
// paramemters:
c0103fe3:	5d                   	pop    %ebp
c0103fe4:	c3                   	ret    

c0103fe5 <get_pgtable_items>:
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0103fe5:	55                   	push   %ebp
c0103fe6:	89 e5                	mov    %esp,%ebp
c0103fe8:	83 ec 10             	sub    $0x10,%esp
    }
c0103feb:	8b 45 10             	mov    0x10(%ebp),%eax
c0103fee:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103ff1:	72 0d                	jb     c0104000 <get_pgtable_items+0x1b>
    if (start < right) {
c0103ff3:	b8 00 00 00 00       	mov    $0x0,%eax
c0103ff8:	e9 98 00 00 00       	jmp    c0104095 <get_pgtable_items+0xb0>
        if (left_store != NULL) {
            *left_store = start;
        }
c0103ffd:	ff 45 10             	incl   0x10(%ebp)
            *left_store = start;
c0104000:	8b 45 10             	mov    0x10(%ebp),%eax
c0104003:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104006:	73 18                	jae    c0104020 <get_pgtable_items+0x3b>
c0104008:	8b 45 10             	mov    0x10(%ebp),%eax
c010400b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104012:	8b 45 14             	mov    0x14(%ebp),%eax
c0104015:	01 d0                	add    %edx,%eax
c0104017:	8b 00                	mov    (%eax),%eax
c0104019:	83 e0 01             	and    $0x1,%eax
c010401c:	85 c0                	test   %eax,%eax
c010401e:	74 dd                	je     c0103ffd <get_pgtable_items+0x18>
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104020:	8b 45 10             	mov    0x10(%ebp),%eax
c0104023:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104026:	73 68                	jae    c0104090 <get_pgtable_items+0xab>
            start ++;
c0104028:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c010402c:	74 08                	je     c0104036 <get_pgtable_items+0x51>
        }
c010402e:	8b 45 18             	mov    0x18(%ebp),%eax
c0104031:	8b 55 10             	mov    0x10(%ebp),%edx
c0104034:	89 10                	mov    %edx,(%eax)
        if (right_store != NULL) {
            *right_store = start;
c0104036:	8b 45 10             	mov    0x10(%ebp),%eax
c0104039:	8d 50 01             	lea    0x1(%eax),%edx
c010403c:	89 55 10             	mov    %edx,0x10(%ebp)
c010403f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104046:	8b 45 14             	mov    0x14(%ebp),%eax
c0104049:	01 d0                	add    %edx,%eax
c010404b:	8b 00                	mov    (%eax),%eax
c010404d:	83 e0 07             	and    $0x7,%eax
c0104050:	89 45 fc             	mov    %eax,-0x4(%ebp)
        }
c0104053:	eb 03                	jmp    c0104058 <get_pgtable_items+0x73>
        return perm;
c0104055:	ff 45 10             	incl   0x10(%ebp)
        }
c0104058:	8b 45 10             	mov    0x10(%ebp),%eax
c010405b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010405e:	73 1d                	jae    c010407d <get_pgtable_items+0x98>
c0104060:	8b 45 10             	mov    0x10(%ebp),%eax
c0104063:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010406a:	8b 45 14             	mov    0x14(%ebp),%eax
c010406d:	01 d0                	add    %edx,%eax
c010406f:	8b 00                	mov    (%eax),%eax
c0104071:	83 e0 07             	and    $0x7,%eax
c0104074:	89 c2                	mov    %eax,%edx
c0104076:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104079:	39 c2                	cmp    %eax,%edx
c010407b:	74 d8                	je     c0104055 <get_pgtable_items+0x70>
    }
    return 0;
c010407d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0104081:	74 08                	je     c010408b <get_pgtable_items+0xa6>
}
c0104083:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0104086:	8b 55 10             	mov    0x10(%ebp),%edx
c0104089:	89 10                	mov    %edx,(%eax)

//print_pgdir - print the PDT&PT
c010408b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010408e:	eb 05                	jmp    c0104095 <get_pgtable_items+0xb0>
void
print_pgdir(void) {
c0104090:	b8 00 00 00 00       	mov    $0x0,%eax
    cprintf("-------------------- BEGIN --------------------\n");
c0104095:	c9                   	leave  
c0104096:	c3                   	ret    

c0104097 <print_pgdir>:
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104097:	55                   	push   %ebp
c0104098:	89 e5                	mov    %esp,%ebp
c010409a:	57                   	push   %edi
c010409b:	56                   	push   %esi
c010409c:	53                   	push   %ebx
c010409d:	83 ec 4c             	sub    $0x4c,%esp
        size_t l, r = left * NPTEENTRY;
c01040a0:	c7 04 24 30 7b 10 c0 	movl   $0xc0107b30,(%esp)
c01040a7:	e8 e6 c1 ff ff       	call   c0100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01040ac:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01040b3:	e9 fa 00 00 00       	jmp    c01041b2 <print_pgdir+0x11b>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01040b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040bb:	89 04 24             	mov    %eax,(%esp)
c01040be:	e8 e0 fe ff ff       	call   c0103fa3 <perm2str>
        }
c01040c3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01040c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01040c9:	29 d1                	sub    %edx,%ecx
c01040cb:	89 ca                	mov    %ecx,%edx
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01040cd:	89 d6                	mov    %edx,%esi
c01040cf:	c1 e6 16             	shl    $0x16,%esi
c01040d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040d5:	89 d3                	mov    %edx,%ebx
c01040d7:	c1 e3 16             	shl    $0x16,%ebx
c01040da:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01040dd:	89 d1                	mov    %edx,%ecx
c01040df:	c1 e1 16             	shl    $0x16,%ecx
c01040e2:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01040e5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01040e8:	29 d7                	sub    %edx,%edi
c01040ea:	89 fa                	mov    %edi,%edx
c01040ec:	89 44 24 14          	mov    %eax,0x14(%esp)
c01040f0:	89 74 24 10          	mov    %esi,0x10(%esp)
c01040f4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01040f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01040fc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104100:	c7 04 24 61 7b 10 c0 	movl   $0xc0107b61,(%esp)
c0104107:	e8 86 c1 ff ff       	call   c0100292 <cprintf>
    }
c010410c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010410f:	c1 e0 0a             	shl    $0xa,%eax
c0104112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("--------------------- END ---------------------\n");
c0104115:	eb 54                	jmp    c010416b <print_pgdir+0xd4>
}
c0104117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010411a:	89 04 24             	mov    %eax,(%esp)
c010411d:	e8 81 fe ff ff       	call   c0103fa3 <perm2str>

c0104122:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104125:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104128:	29 d1                	sub    %edx,%ecx
c010412a:	89 ca                	mov    %ecx,%edx
}
c010412c:	89 d6                	mov    %edx,%esi
c010412e:	c1 e6 0c             	shl    $0xc,%esi
c0104131:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104134:	89 d3                	mov    %edx,%ebx
c0104136:	c1 e3 0c             	shl    $0xc,%ebx
c0104139:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010413c:	89 d1                	mov    %edx,%ecx
c010413e:	c1 e1 0c             	shl    $0xc,%ecx
c0104141:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0104144:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104147:	29 d7                	sub    %edx,%edi
c0104149:	89 fa                	mov    %edi,%edx
c010414b:	89 44 24 14          	mov    %eax,0x14(%esp)
c010414f:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104153:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104157:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010415b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010415f:	c7 04 24 80 7b 10 c0 	movl   $0xc0107b80,(%esp)
c0104166:	e8 27 c1 ff ff       	call   c0100292 <cprintf>
    cprintf("--------------------- END ---------------------\n");
c010416b:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0104170:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104173:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104176:	89 d3                	mov    %edx,%ebx
c0104178:	c1 e3 0a             	shl    $0xa,%ebx
c010417b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010417e:	89 d1                	mov    %edx,%ecx
c0104180:	c1 e1 0a             	shl    $0xa,%ecx
c0104183:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104186:	89 54 24 14          	mov    %edx,0x14(%esp)
c010418a:	8d 55 d8             	lea    -0x28(%ebp),%edx
c010418d:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104191:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0104195:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104199:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010419d:	89 0c 24             	mov    %ecx,(%esp)
c01041a0:	e8 40 fe ff ff       	call   c0103fe5 <get_pgtable_items>
c01041a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01041a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01041ac:	0f 85 65 ff ff ff    	jne    c0104117 <print_pgdir+0x80>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01041b2:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01041b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01041ba:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01041bd:	89 54 24 14          	mov    %edx,0x14(%esp)
c01041c1:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01041c4:	89 54 24 10          	mov    %edx,0x10(%esp)
c01041c8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01041cc:	89 44 24 08          	mov    %eax,0x8(%esp)
c01041d0:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01041d7:	00 
c01041d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01041df:	e8 01 fe ff ff       	call   c0103fe5 <get_pgtable_items>
c01041e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01041e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01041eb:	0f 85 c7 fe ff ff    	jne    c01040b8 <print_pgdir+0x21>
c01041f1:	c7 04 24 a4 7b 10 c0 	movl   $0xc0107ba4,(%esp)
c01041f8:	e8 95 c0 ff ff       	call   c0100292 <cprintf>
c01041fd:	90                   	nop
c01041fe:	83 c4 4c             	add    $0x4c,%esp
c0104201:	5b                   	pop    %ebx
c0104202:	5e                   	pop    %esi
c0104203:	5f                   	pop    %edi
c0104204:	5d                   	pop    %ebp
c0104205:	c3                   	ret    

c0104206 <page2ppn>:
page2ppn(struct Page *page) {
c0104206:	55                   	push   %ebp
c0104207:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104209:	8b 45 08             	mov    0x8(%ebp),%eax
c010420c:	8b 15 18 df 11 c0    	mov    0xc011df18,%edx
c0104212:	29 d0                	sub    %edx,%eax
c0104214:	c1 f8 02             	sar    $0x2,%eax
c0104217:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010421d:	5d                   	pop    %ebp
c010421e:	c3                   	ret    

c010421f <page2pa>:
page2pa(struct Page *page) {
c010421f:	55                   	push   %ebp
c0104220:	89 e5                	mov    %esp,%ebp
c0104222:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104225:	8b 45 08             	mov    0x8(%ebp),%eax
c0104228:	89 04 24             	mov    %eax,(%esp)
c010422b:	e8 d6 ff ff ff       	call   c0104206 <page2ppn>
c0104230:	c1 e0 0c             	shl    $0xc,%eax
}
c0104233:	c9                   	leave  
c0104234:	c3                   	ret    

c0104235 <page_ref>:
page_ref(struct Page *page) {
c0104235:	55                   	push   %ebp
c0104236:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104238:	8b 45 08             	mov    0x8(%ebp),%eax
c010423b:	8b 00                	mov    (%eax),%eax
}
c010423d:	5d                   	pop    %ebp
c010423e:	c3                   	ret    

c010423f <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010423f:	55                   	push   %ebp
c0104240:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104242:	8b 45 08             	mov    0x8(%ebp),%eax
c0104245:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104248:	89 10                	mov    %edx,(%eax)
}
c010424a:	90                   	nop
c010424b:	5d                   	pop    %ebp
c010424c:	c3                   	ret    

c010424d <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010424d:	55                   	push   %ebp
c010424e:	89 e5                	mov    %esp,%ebp
c0104250:	83 ec 10             	sub    $0x10,%esp
c0104253:	c7 45 fc 20 df 11 c0 	movl   $0xc011df20,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010425a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010425d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104260:	89 50 04             	mov    %edx,0x4(%eax)
c0104263:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104266:	8b 50 04             	mov    0x4(%eax),%edx
c0104269:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010426c:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c010426e:	c7 05 28 df 11 c0 00 	movl   $0x0,0xc011df28
c0104275:	00 00 00 
}
c0104278:	90                   	nop
c0104279:	c9                   	leave  
c010427a:	c3                   	ret    

c010427b <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010427b:	55                   	push   %ebp
c010427c:	89 e5                	mov    %esp,%ebp
c010427e:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0104281:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104285:	75 24                	jne    c01042ab <default_init_memmap+0x30>
c0104287:	c7 44 24 0c d8 7b 10 	movl   $0xc0107bd8,0xc(%esp)
c010428e:	c0 
c010428f:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104296:	c0 
c0104297:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010429e:	00 
c010429f:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c01042a6:	e8 3e c1 ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c01042ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01042ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01042b1:	eb 7d                	jmp    c0104330 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c01042b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042b6:	83 c0 04             	add    $0x4,%eax
c01042b9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01042c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01042c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01042c9:	0f a3 10             	bt     %edx,(%eax)
c01042cc:	19 c0                	sbb    %eax,%eax
c01042ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01042d1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01042d5:	0f 95 c0             	setne  %al
c01042d8:	0f b6 c0             	movzbl %al,%eax
c01042db:	85 c0                	test   %eax,%eax
c01042dd:	75 24                	jne    c0104303 <default_init_memmap+0x88>
c01042df:	c7 44 24 0c 09 7c 10 	movl   $0xc0107c09,0xc(%esp)
c01042e6:	c0 
c01042e7:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c01042ee:	c0 
c01042ef:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01042f6:	00 
c01042f7:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c01042fe:	e8 e6 c0 ff ff       	call   c01003e9 <__panic>
        p->flags = p->property = 0;
c0104303:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104306:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010430d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104310:	8b 50 08             	mov    0x8(%eax),%edx
c0104313:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104316:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0104319:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104320:	00 
c0104321:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104324:	89 04 24             	mov    %eax,(%esp)
c0104327:	e8 13 ff ff ff       	call   c010423f <set_page_ref>
    for (; p != base + n; p ++) {
c010432c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104330:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104333:	89 d0                	mov    %edx,%eax
c0104335:	c1 e0 02             	shl    $0x2,%eax
c0104338:	01 d0                	add    %edx,%eax
c010433a:	c1 e0 02             	shl    $0x2,%eax
c010433d:	89 c2                	mov    %eax,%edx
c010433f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104342:	01 d0                	add    %edx,%eax
c0104344:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104347:	0f 85 66 ff ff ff    	jne    c01042b3 <default_init_memmap+0x38>
	
    }
    base->property = n;
c010434d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104350:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104353:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104356:	8b 45 08             	mov    0x8(%ebp),%eax
c0104359:	83 c0 04             	add    $0x4,%eax
c010435c:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104363:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104366:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104369:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010436c:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c010436f:	8b 15 28 df 11 c0    	mov    0xc011df28,%edx
c0104375:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104378:	01 d0                	add    %edx,%eax
c010437a:	a3 28 df 11 c0       	mov    %eax,0xc011df28
    list_add_before(&free_list,&(base->page_link));
c010437f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104382:	83 c0 0c             	add    $0xc,%eax
c0104385:	c7 45 e4 20 df 11 c0 	movl   $0xc011df20,-0x1c(%ebp)
c010438c:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010438f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104392:	8b 00                	mov    (%eax),%eax
c0104394:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104397:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010439a:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010439d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01043a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01043a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01043a9:	89 10                	mov    %edx,(%eax)
c01043ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01043ae:	8b 10                	mov    (%eax),%edx
c01043b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01043b3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01043b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01043bc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01043bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01043c5:	89 10                	mov    %edx,(%eax)
}
c01043c7:	90                   	nop
c01043c8:	c9                   	leave  
c01043c9:	c3                   	ret    

c01043ca <default_alloc_pages>:
 *              return `p`.
 *      (4.2)
 *          If we can not find a free block with its size >=n, then return NULL.
*/
static struct Page *
default_alloc_pages(size_t n) {
c01043ca:	55                   	push   %ebp
c01043cb:	89 e5                	mov    %esp,%ebp
c01043cd:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01043d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01043d4:	75 24                	jne    c01043fa <default_alloc_pages+0x30>
c01043d6:	c7 44 24 0c d8 7b 10 	movl   $0xc0107bd8,0xc(%esp)
c01043dd:	c0 
c01043de:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c01043e5:	c0 
c01043e6:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c01043ed:	00 
c01043ee:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c01043f5:	e8 ef bf ff ff       	call   c01003e9 <__panic>
    if (n > nr_free) {
c01043fa:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c01043ff:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104402:	76 0a                	jbe    c010440e <default_alloc_pages+0x44>
        return NULL;
c0104404:	b8 00 00 00 00       	mov    $0x0,%eax
c0104409:	e9 49 01 00 00       	jmp    c0104557 <default_alloc_pages+0x18d>
    }
    struct Page *page=NULL;
c010440e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0104415:	c7 45 f0 20 df 11 c0 	movl   $0xc011df20,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010441c:	eb 1c                	jmp    c010443a <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c010441e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104421:	83 e8 0c             	sub    $0xc,%eax
c0104424:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0104427:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010442a:	8b 40 08             	mov    0x8(%eax),%eax
c010442d:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104430:	77 08                	ja     c010443a <default_alloc_pages+0x70>
	   page=p;
c0104432:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104435:	89 45 f4             	mov    %eax,-0xc(%ebp)
	   break;
c0104438:	eb 18                	jmp    c0104452 <default_alloc_pages+0x88>
c010443a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010443d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0104440:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104443:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104446:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104449:	81 7d f0 20 df 11 c0 	cmpl   $0xc011df20,-0x10(%ebp)
c0104450:	75 cc                	jne    c010441e <default_alloc_pages+0x54>
        }
    }
    if(page!=NULL){
c0104452:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104456:	0f 84 f8 00 00 00    	je     c0104554 <default_alloc_pages+0x18a>
	if(page->property>n){
c010445c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010445f:	8b 40 08             	mov    0x8(%eax),%eax
c0104462:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104465:	0f 83 98 00 00 00    	jae    c0104503 <default_alloc_pages+0x139>
	   struct Page*p=page+n;
c010446b:	8b 55 08             	mov    0x8(%ebp),%edx
c010446e:	89 d0                	mov    %edx,%eax
c0104470:	c1 e0 02             	shl    $0x2,%eax
c0104473:	01 d0                	add    %edx,%eax
c0104475:	c1 e0 02             	shl    $0x2,%eax
c0104478:	89 c2                	mov    %eax,%edx
c010447a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010447d:	01 d0                	add    %edx,%eax
c010447f:	89 45 e8             	mov    %eax,-0x18(%ebp)
	   p->property=page->property-n;
c0104482:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104485:	8b 40 08             	mov    0x8(%eax),%eax
c0104488:	2b 45 08             	sub    0x8(%ebp),%eax
c010448b:	89 c2                	mov    %eax,%edx
c010448d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104490:	89 50 08             	mov    %edx,0x8(%eax)
	   SetPageProperty(p);
c0104493:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104496:	83 c0 04             	add    $0x4,%eax
c0104499:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c01044a0:	89 45 c0             	mov    %eax,-0x40(%ebp)
c01044a3:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01044a6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01044a9:	0f ab 10             	bts    %edx,(%eax)
	   list_add(&(page->page_link),&(p->page_link));
c01044ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044af:	83 c0 0c             	add    $0xc,%eax
c01044b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01044b5:	83 c2 0c             	add    $0xc,%edx
c01044b8:	89 55 e0             	mov    %edx,-0x20(%ebp)
c01044bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01044be:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01044c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01044c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01044c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c01044ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01044cd:	8b 40 04             	mov    0x4(%eax),%eax
c01044d0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01044d3:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01044d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01044d9:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01044dc:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c01044df:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01044e2:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01044e5:	89 10                	mov    %edx,(%eax)
c01044e7:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01044ea:	8b 10                	mov    (%eax),%edx
c01044ec:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01044ef:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01044f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01044f5:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01044f8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01044fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01044fe:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104501:	89 10                	mov    %edx,(%eax)
	}
	
	list_del(&(page->page_link));
c0104503:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104506:	83 c0 0c             	add    $0xc,%eax
c0104509:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
c010450c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010450f:	8b 40 04             	mov    0x4(%eax),%eax
c0104512:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104515:	8b 12                	mov    (%edx),%edx
c0104517:	89 55 b0             	mov    %edx,-0x50(%ebp)
c010451a:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010451d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104520:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104523:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104526:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104529:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010452c:	89 10                	mov    %edx,(%eax)
	nr_free-=n;
c010452e:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104533:	2b 45 08             	sub    0x8(%ebp),%eax
c0104536:	a3 28 df 11 c0       	mov    %eax,0xc011df28
	ClearPageProperty(page);
c010453b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010453e:	83 c0 04             	add    $0x4,%eax
c0104541:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0104548:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010454b:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010454e:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104551:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0104554:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104557:	c9                   	leave  
c0104558:	c3                   	ret    

c0104559 <default_free_pages>:
 *  (5.3)
 *      Try to merge blocks at lower or higher addresses. Notice: This should
 *  change some pages' `p->property` correctly.
 */
static void
default_free_pages(struct Page *base, size_t n) {
c0104559:	55                   	push   %ebp
c010455a:	89 e5                	mov    %esp,%ebp
c010455c:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0104562:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104566:	75 24                	jne    c010458c <default_free_pages+0x33>
c0104568:	c7 44 24 0c d8 7b 10 	movl   $0xc0107bd8,0xc(%esp)
c010456f:	c0 
c0104570:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104577:	c0 
c0104578:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c010457f:	00 
c0104580:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104587:	e8 5d be ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c010458c:	8b 45 08             	mov    0x8(%ebp),%eax
c010458f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104592:	e9 9d 00 00 00       	jmp    c0104634 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0104597:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010459a:	83 c0 04             	add    $0x4,%eax
c010459d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01045a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01045a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01045aa:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01045ad:	0f a3 10             	bt     %edx,(%eax)
c01045b0:	19 c0                	sbb    %eax,%eax
c01045b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01045b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01045b9:	0f 95 c0             	setne  %al
c01045bc:	0f b6 c0             	movzbl %al,%eax
c01045bf:	85 c0                	test   %eax,%eax
c01045c1:	75 2c                	jne    c01045ef <default_free_pages+0x96>
c01045c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045c6:	83 c0 04             	add    $0x4,%eax
c01045c9:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01045d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01045d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01045d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01045d9:	0f a3 10             	bt     %edx,(%eax)
c01045dc:	19 c0                	sbb    %eax,%eax
c01045de:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01045e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01045e5:	0f 95 c0             	setne  %al
c01045e8:	0f b6 c0             	movzbl %al,%eax
c01045eb:	85 c0                	test   %eax,%eax
c01045ed:	74 24                	je     c0104613 <default_free_pages+0xba>
c01045ef:	c7 44 24 0c 1c 7c 10 	movl   $0xc0107c1c,0xc(%esp)
c01045f6:	c0 
c01045f7:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c01045fe:	c0 
c01045ff:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0104606:	00 
c0104607:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c010460e:	e8 d6 bd ff ff       	call   c01003e9 <__panic>
        p->flags = 0;
c0104613:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104616:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c010461d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104624:	00 
c0104625:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104628:	89 04 24             	mov    %eax,(%esp)
c010462b:	e8 0f fc ff ff       	call   c010423f <set_page_ref>
    for (; p != base + n; p ++) {
c0104630:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104634:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104637:	89 d0                	mov    %edx,%eax
c0104639:	c1 e0 02             	shl    $0x2,%eax
c010463c:	01 d0                	add    %edx,%eax
c010463e:	c1 e0 02             	shl    $0x2,%eax
c0104641:	89 c2                	mov    %eax,%edx
c0104643:	8b 45 08             	mov    0x8(%ebp),%eax
c0104646:	01 d0                	add    %edx,%eax
c0104648:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010464b:	0f 85 46 ff ff ff    	jne    c0104597 <default_free_pages+0x3e>
    }
    base->property = n;
c0104651:	8b 45 08             	mov    0x8(%ebp),%eax
c0104654:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104657:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010465a:	8b 45 08             	mov    0x8(%ebp),%eax
c010465d:	83 c0 04             	add    $0x4,%eax
c0104660:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104667:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010466a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010466d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104670:	0f ab 10             	bts    %edx,(%eax)
c0104673:	c7 45 d4 20 df 11 c0 	movl   $0xc011df20,-0x2c(%ebp)
    return listelm->next;
c010467a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010467d:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0104680:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0104683:	e9 08 01 00 00       	jmp    c0104790 <default_free_pages+0x237>
        p = le2page(le, page_link);
c0104688:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010468b:	83 e8 0c             	sub    $0xc,%eax
c010468e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104691:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104694:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104697:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010469a:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c010469d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c01046a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01046a3:	8b 50 08             	mov    0x8(%eax),%edx
c01046a6:	89 d0                	mov    %edx,%eax
c01046a8:	c1 e0 02             	shl    $0x2,%eax
c01046ab:	01 d0                	add    %edx,%eax
c01046ad:	c1 e0 02             	shl    $0x2,%eax
c01046b0:	89 c2                	mov    %eax,%edx
c01046b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01046b5:	01 d0                	add    %edx,%eax
c01046b7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01046ba:	75 5a                	jne    c0104716 <default_free_pages+0x1bd>
            base->property += p->property;
c01046bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01046bf:	8b 50 08             	mov    0x8(%eax),%edx
c01046c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046c5:	8b 40 08             	mov    0x8(%eax),%eax
c01046c8:	01 c2                	add    %eax,%edx
c01046ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01046cd:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c01046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046d3:	83 c0 04             	add    $0x4,%eax
c01046d6:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c01046dd:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01046e0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01046e3:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01046e6:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c01046e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046ec:	83 c0 0c             	add    $0xc,%eax
c01046ef:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01046f2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01046f5:	8b 40 04             	mov    0x4(%eax),%eax
c01046f8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01046fb:	8b 12                	mov    (%edx),%edx
c01046fd:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0104700:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c0104703:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104706:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104709:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010470c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010470f:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104712:	89 10                	mov    %edx,(%eax)
c0104714:	eb 7a                	jmp    c0104790 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c0104716:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104719:	8b 50 08             	mov    0x8(%eax),%edx
c010471c:	89 d0                	mov    %edx,%eax
c010471e:	c1 e0 02             	shl    $0x2,%eax
c0104721:	01 d0                	add    %edx,%eax
c0104723:	c1 e0 02             	shl    $0x2,%eax
c0104726:	89 c2                	mov    %eax,%edx
c0104728:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010472b:	01 d0                	add    %edx,%eax
c010472d:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104730:	75 5e                	jne    c0104790 <default_free_pages+0x237>
            p->property += base->property;
c0104732:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104735:	8b 50 08             	mov    0x8(%eax),%edx
c0104738:	8b 45 08             	mov    0x8(%ebp),%eax
c010473b:	8b 40 08             	mov    0x8(%eax),%eax
c010473e:	01 c2                	add    %eax,%edx
c0104740:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104743:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0104746:	8b 45 08             	mov    0x8(%ebp),%eax
c0104749:	83 c0 04             	add    $0x4,%eax
c010474c:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0104753:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0104756:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104759:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010475c:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c010475f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104762:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0104765:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104768:	83 c0 0c             	add    $0xc,%eax
c010476b:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c010476e:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104771:	8b 40 04             	mov    0x4(%eax),%eax
c0104774:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104777:	8b 12                	mov    (%edx),%edx
c0104779:	89 55 ac             	mov    %edx,-0x54(%ebp)
c010477c:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c010477f:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104782:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104785:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104788:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010478b:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010478e:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
c0104790:	81 7d f0 20 df 11 c0 	cmpl   $0xc011df20,-0x10(%ebp)
c0104797:	0f 85 eb fe ff ff    	jne    c0104688 <default_free_pages+0x12f>
        }
    }
    SetPageProperty(base);
c010479d:	8b 45 08             	mov    0x8(%ebp),%eax
c01047a0:	83 c0 04             	add    $0x4,%eax
c01047a3:	c7 45 98 01 00 00 00 	movl   $0x1,-0x68(%ebp)
c01047aa:	89 45 94             	mov    %eax,-0x6c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01047ad:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01047b0:	8b 55 98             	mov    -0x68(%ebp),%edx
c01047b3:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01047b6:	8b 15 28 df 11 c0    	mov    0xc011df28,%edx
c01047bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047bf:	01 d0                	add    %edx,%eax
c01047c1:	a3 28 df 11 c0       	mov    %eax,0xc011df28
c01047c6:	c7 45 9c 20 df 11 c0 	movl   $0xc011df20,-0x64(%ebp)
    return listelm->next;
c01047cd:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01047d0:	8b 40 04             	mov    0x4(%eax),%eax
    le=list_next(&free_list);
c01047d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
c01047d6:	eb 0f                	jmp    c01047e7 <default_free_pages+0x28e>
c01047d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047db:	89 45 90             	mov    %eax,-0x70(%ebp)
c01047de:	8b 45 90             	mov    -0x70(%ebp),%eax
c01047e1:	8b 40 04             	mov    0x4(%eax),%eax
	le=list_next(le);
c01047e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
c01047e7:	81 7d f0 20 df 11 c0 	cmpl   $0xc011df20,-0x10(%ebp)
c01047ee:	74 0b                	je     c01047fb <default_free_pages+0x2a2>
c01047f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047f3:	83 e8 0c             	sub    $0xc,%eax
c01047f6:	39 45 08             	cmp    %eax,0x8(%ebp)
c01047f9:	77 dd                	ja     c01047d8 <default_free_pages+0x27f>
    }
    list_add_before(le, &(base->page_link));
c01047fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01047fe:	8d 50 0c             	lea    0xc(%eax),%edx
c0104801:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104804:	89 45 8c             	mov    %eax,-0x74(%ebp)
c0104807:	89 55 88             	mov    %edx,-0x78(%ebp)
    __list_add(elm, listelm->prev, listelm);
c010480a:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010480d:	8b 00                	mov    (%eax),%eax
c010480f:	8b 55 88             	mov    -0x78(%ebp),%edx
c0104812:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104815:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104818:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010481b:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
    prev->next = next->prev = elm;
c0104821:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104827:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010482a:	89 10                	mov    %edx,(%eax)
c010482c:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104832:	8b 10                	mov    (%eax),%edx
c0104834:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104837:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010483a:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010483d:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0104843:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104846:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104849:	8b 55 80             	mov    -0x80(%ebp),%edx
c010484c:	89 10                	mov    %edx,(%eax)
}
c010484e:	90                   	nop
c010484f:	c9                   	leave  
c0104850:	c3                   	ret    

c0104851 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0104851:	55                   	push   %ebp
c0104852:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104854:	a1 28 df 11 c0       	mov    0xc011df28,%eax
}
c0104859:	5d                   	pop    %ebp
c010485a:	c3                   	ret    

c010485b <basic_check>:

static void
basic_check(void) {
c010485b:	55                   	push   %ebp
c010485c:	89 e5                	mov    %esp,%ebp
c010485e:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104861:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104868:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010486b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010486e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104871:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104874:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010487b:	e8 d8 e2 ff ff       	call   c0102b58 <alloc_pages>
c0104880:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104883:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104887:	75 24                	jne    c01048ad <basic_check+0x52>
c0104889:	c7 44 24 0c 41 7c 10 	movl   $0xc0107c41,0xc(%esp)
c0104890:	c0 
c0104891:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104898:	c0 
c0104899:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c01048a0:	00 
c01048a1:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c01048a8:	e8 3c bb ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01048ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01048b4:	e8 9f e2 ff ff       	call   c0102b58 <alloc_pages>
c01048b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01048c0:	75 24                	jne    c01048e6 <basic_check+0x8b>
c01048c2:	c7 44 24 0c 5d 7c 10 	movl   $0xc0107c5d,0xc(%esp)
c01048c9:	c0 
c01048ca:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c01048d1:	c0 
c01048d2:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c01048d9:	00 
c01048da:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c01048e1:	e8 03 bb ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01048e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01048ed:	e8 66 e2 ff ff       	call   c0102b58 <alloc_pages>
c01048f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01048f9:	75 24                	jne    c010491f <basic_check+0xc4>
c01048fb:	c7 44 24 0c 79 7c 10 	movl   $0xc0107c79,0xc(%esp)
c0104902:	c0 
c0104903:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c010490a:	c0 
c010490b:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0104912:	00 
c0104913:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c010491a:	e8 ca ba ff ff       	call   c01003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c010491f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104922:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104925:	74 10                	je     c0104937 <basic_check+0xdc>
c0104927:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010492a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010492d:	74 08                	je     c0104937 <basic_check+0xdc>
c010492f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104932:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104935:	75 24                	jne    c010495b <basic_check+0x100>
c0104937:	c7 44 24 0c 98 7c 10 	movl   $0xc0107c98,0xc(%esp)
c010493e:	c0 
c010493f:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104946:	c0 
c0104947:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c010494e:	00 
c010494f:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104956:	e8 8e ba ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010495b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010495e:	89 04 24             	mov    %eax,(%esp)
c0104961:	e8 cf f8 ff ff       	call   c0104235 <page_ref>
c0104966:	85 c0                	test   %eax,%eax
c0104968:	75 1e                	jne    c0104988 <basic_check+0x12d>
c010496a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010496d:	89 04 24             	mov    %eax,(%esp)
c0104970:	e8 c0 f8 ff ff       	call   c0104235 <page_ref>
c0104975:	85 c0                	test   %eax,%eax
c0104977:	75 0f                	jne    c0104988 <basic_check+0x12d>
c0104979:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010497c:	89 04 24             	mov    %eax,(%esp)
c010497f:	e8 b1 f8 ff ff       	call   c0104235 <page_ref>
c0104984:	85 c0                	test   %eax,%eax
c0104986:	74 24                	je     c01049ac <basic_check+0x151>
c0104988:	c7 44 24 0c bc 7c 10 	movl   $0xc0107cbc,0xc(%esp)
c010498f:	c0 
c0104990:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104997:	c0 
c0104998:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c010499f:	00 
c01049a0:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c01049a7:	e8 3d ba ff ff       	call   c01003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01049ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049af:	89 04 24             	mov    %eax,(%esp)
c01049b2:	e8 68 f8 ff ff       	call   c010421f <page2pa>
c01049b7:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c01049bd:	c1 e2 0c             	shl    $0xc,%edx
c01049c0:	39 d0                	cmp    %edx,%eax
c01049c2:	72 24                	jb     c01049e8 <basic_check+0x18d>
c01049c4:	c7 44 24 0c f8 7c 10 	movl   $0xc0107cf8,0xc(%esp)
c01049cb:	c0 
c01049cc:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c01049d3:	c0 
c01049d4:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c01049db:	00 
c01049dc:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c01049e3:	e8 01 ba ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01049e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049eb:	89 04 24             	mov    %eax,(%esp)
c01049ee:	e8 2c f8 ff ff       	call   c010421f <page2pa>
c01049f3:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c01049f9:	c1 e2 0c             	shl    $0xc,%edx
c01049fc:	39 d0                	cmp    %edx,%eax
c01049fe:	72 24                	jb     c0104a24 <basic_check+0x1c9>
c0104a00:	c7 44 24 0c 15 7d 10 	movl   $0xc0107d15,0xc(%esp)
c0104a07:	c0 
c0104a08:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104a0f:	c0 
c0104a10:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
c0104a17:	00 
c0104a18:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104a1f:	e8 c5 b9 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a27:	89 04 24             	mov    %eax,(%esp)
c0104a2a:	e8 f0 f7 ff ff       	call   c010421f <page2pa>
c0104a2f:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0104a35:	c1 e2 0c             	shl    $0xc,%edx
c0104a38:	39 d0                	cmp    %edx,%eax
c0104a3a:	72 24                	jb     c0104a60 <basic_check+0x205>
c0104a3c:	c7 44 24 0c 32 7d 10 	movl   $0xc0107d32,0xc(%esp)
c0104a43:	c0 
c0104a44:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104a4b:	c0 
c0104a4c:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0104a53:	00 
c0104a54:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104a5b:	e8 89 b9 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104a60:	a1 20 df 11 c0       	mov    0xc011df20,%eax
c0104a65:	8b 15 24 df 11 c0    	mov    0xc011df24,%edx
c0104a6b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104a6e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104a71:	c7 45 dc 20 df 11 c0 	movl   $0xc011df20,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0104a78:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a7b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a7e:	89 50 04             	mov    %edx,0x4(%eax)
c0104a81:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a84:	8b 50 04             	mov    0x4(%eax),%edx
c0104a87:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a8a:	89 10                	mov    %edx,(%eax)
c0104a8c:	c7 45 e0 20 df 11 c0 	movl   $0xc011df20,-0x20(%ebp)
    return list->next == list;
c0104a93:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a96:	8b 40 04             	mov    0x4(%eax),%eax
c0104a99:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104a9c:	0f 94 c0             	sete   %al
c0104a9f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104aa2:	85 c0                	test   %eax,%eax
c0104aa4:	75 24                	jne    c0104aca <basic_check+0x26f>
c0104aa6:	c7 44 24 0c 4f 7d 10 	movl   $0xc0107d4f,0xc(%esp)
c0104aad:	c0 
c0104aae:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104ab5:	c0 
c0104ab6:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0104abd:	00 
c0104abe:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104ac5:	e8 1f b9 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104aca:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104acf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104ad2:	c7 05 28 df 11 c0 00 	movl   $0x0,0xc011df28
c0104ad9:	00 00 00 

    assert(alloc_page() == NULL);
c0104adc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ae3:	e8 70 e0 ff ff       	call   c0102b58 <alloc_pages>
c0104ae8:	85 c0                	test   %eax,%eax
c0104aea:	74 24                	je     c0104b10 <basic_check+0x2b5>
c0104aec:	c7 44 24 0c 66 7d 10 	movl   $0xc0107d66,0xc(%esp)
c0104af3:	c0 
c0104af4:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104afb:	c0 
c0104afc:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0104b03:	00 
c0104b04:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104b0b:	e8 d9 b8 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104b10:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b17:	00 
c0104b18:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b1b:	89 04 24             	mov    %eax,(%esp)
c0104b1e:	e8 6d e0 ff ff       	call   c0102b90 <free_pages>
    free_page(p1);
c0104b23:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b2a:	00 
c0104b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b2e:	89 04 24             	mov    %eax,(%esp)
c0104b31:	e8 5a e0 ff ff       	call   c0102b90 <free_pages>
    free_page(p2);
c0104b36:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b3d:	00 
c0104b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b41:	89 04 24             	mov    %eax,(%esp)
c0104b44:	e8 47 e0 ff ff       	call   c0102b90 <free_pages>
    assert(nr_free == 3);
c0104b49:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104b4e:	83 f8 03             	cmp    $0x3,%eax
c0104b51:	74 24                	je     c0104b77 <basic_check+0x31c>
c0104b53:	c7 44 24 0c 7b 7d 10 	movl   $0xc0107d7b,0xc(%esp)
c0104b5a:	c0 
c0104b5b:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104b62:	c0 
c0104b63:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c0104b6a:	00 
c0104b6b:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104b72:	e8 72 b8 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104b77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b7e:	e8 d5 df ff ff       	call   c0102b58 <alloc_pages>
c0104b83:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104b86:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104b8a:	75 24                	jne    c0104bb0 <basic_check+0x355>
c0104b8c:	c7 44 24 0c 41 7c 10 	movl   $0xc0107c41,0xc(%esp)
c0104b93:	c0 
c0104b94:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104b9b:	c0 
c0104b9c:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0104ba3:	00 
c0104ba4:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104bab:	e8 39 b8 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104bb0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104bb7:	e8 9c df ff ff       	call   c0102b58 <alloc_pages>
c0104bbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104bbf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104bc3:	75 24                	jne    c0104be9 <basic_check+0x38e>
c0104bc5:	c7 44 24 0c 5d 7c 10 	movl   $0xc0107c5d,0xc(%esp)
c0104bcc:	c0 
c0104bcd:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104bd4:	c0 
c0104bd5:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0104bdc:	00 
c0104bdd:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104be4:	e8 00 b8 ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104be9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104bf0:	e8 63 df ff ff       	call   c0102b58 <alloc_pages>
c0104bf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104bf8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104bfc:	75 24                	jne    c0104c22 <basic_check+0x3c7>
c0104bfe:	c7 44 24 0c 79 7c 10 	movl   $0xc0107c79,0xc(%esp)
c0104c05:	c0 
c0104c06:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104c0d:	c0 
c0104c0e:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0104c15:	00 
c0104c16:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104c1d:	e8 c7 b7 ff ff       	call   c01003e9 <__panic>

    assert(alloc_page() == NULL);
c0104c22:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c29:	e8 2a df ff ff       	call   c0102b58 <alloc_pages>
c0104c2e:	85 c0                	test   %eax,%eax
c0104c30:	74 24                	je     c0104c56 <basic_check+0x3fb>
c0104c32:	c7 44 24 0c 66 7d 10 	movl   $0xc0107d66,0xc(%esp)
c0104c39:	c0 
c0104c3a:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104c41:	c0 
c0104c42:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0104c49:	00 
c0104c4a:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104c51:	e8 93 b7 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104c56:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104c5d:	00 
c0104c5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c61:	89 04 24             	mov    %eax,(%esp)
c0104c64:	e8 27 df ff ff       	call   c0102b90 <free_pages>
c0104c69:	c7 45 d8 20 df 11 c0 	movl   $0xc011df20,-0x28(%ebp)
c0104c70:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104c73:	8b 40 04             	mov    0x4(%eax),%eax
c0104c76:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104c79:	0f 94 c0             	sete   %al
c0104c7c:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104c7f:	85 c0                	test   %eax,%eax
c0104c81:	74 24                	je     c0104ca7 <basic_check+0x44c>
c0104c83:	c7 44 24 0c 88 7d 10 	movl   $0xc0107d88,0xc(%esp)
c0104c8a:	c0 
c0104c8b:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104c92:	c0 
c0104c93:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0104c9a:	00 
c0104c9b:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104ca2:	e8 42 b7 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104ca7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104cae:	e8 a5 de ff ff       	call   c0102b58 <alloc_pages>
c0104cb3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104cb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104cb9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104cbc:	74 24                	je     c0104ce2 <basic_check+0x487>
c0104cbe:	c7 44 24 0c a0 7d 10 	movl   $0xc0107da0,0xc(%esp)
c0104cc5:	c0 
c0104cc6:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104ccd:	c0 
c0104cce:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0104cd5:	00 
c0104cd6:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104cdd:	e8 07 b7 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104ce2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ce9:	e8 6a de ff ff       	call   c0102b58 <alloc_pages>
c0104cee:	85 c0                	test   %eax,%eax
c0104cf0:	74 24                	je     c0104d16 <basic_check+0x4bb>
c0104cf2:	c7 44 24 0c 66 7d 10 	movl   $0xc0107d66,0xc(%esp)
c0104cf9:	c0 
c0104cfa:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104d01:	c0 
c0104d02:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0104d09:	00 
c0104d0a:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104d11:	e8 d3 b6 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c0104d16:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104d1b:	85 c0                	test   %eax,%eax
c0104d1d:	74 24                	je     c0104d43 <basic_check+0x4e8>
c0104d1f:	c7 44 24 0c b9 7d 10 	movl   $0xc0107db9,0xc(%esp)
c0104d26:	c0 
c0104d27:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104d2e:	c0 
c0104d2f:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0104d36:	00 
c0104d37:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104d3e:	e8 a6 b6 ff ff       	call   c01003e9 <__panic>
    free_list = free_list_store;
c0104d43:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d46:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104d49:	a3 20 df 11 c0       	mov    %eax,0xc011df20
c0104d4e:	89 15 24 df 11 c0    	mov    %edx,0xc011df24
    nr_free = nr_free_store;
c0104d54:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d57:	a3 28 df 11 c0       	mov    %eax,0xc011df28

    free_page(p);
c0104d5c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d63:	00 
c0104d64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d67:	89 04 24             	mov    %eax,(%esp)
c0104d6a:	e8 21 de ff ff       	call   c0102b90 <free_pages>
    free_page(p1);
c0104d6f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d76:	00 
c0104d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d7a:	89 04 24             	mov    %eax,(%esp)
c0104d7d:	e8 0e de ff ff       	call   c0102b90 <free_pages>
    free_page(p2);
c0104d82:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d89:	00 
c0104d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d8d:	89 04 24             	mov    %eax,(%esp)
c0104d90:	e8 fb dd ff ff       	call   c0102b90 <free_pages>
}
c0104d95:	90                   	nop
c0104d96:	c9                   	leave  
c0104d97:	c3                   	ret    

c0104d98 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104d98:	55                   	push   %ebp
c0104d99:	89 e5                	mov    %esp,%ebp
c0104d9b:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0104da1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104da8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104daf:	c7 45 ec 20 df 11 c0 	movl   $0xc011df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104db6:	eb 6a                	jmp    c0104e22 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0104db8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104dbb:	83 e8 0c             	sub    $0xc,%eax
c0104dbe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0104dc1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104dc4:	83 c0 04             	add    $0x4,%eax
c0104dc7:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104dce:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104dd1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104dd4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104dd7:	0f a3 10             	bt     %edx,(%eax)
c0104dda:	19 c0                	sbb    %eax,%eax
c0104ddc:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104ddf:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104de3:	0f 95 c0             	setne  %al
c0104de6:	0f b6 c0             	movzbl %al,%eax
c0104de9:	85 c0                	test   %eax,%eax
c0104deb:	75 24                	jne    c0104e11 <default_check+0x79>
c0104ded:	c7 44 24 0c c6 7d 10 	movl   $0xc0107dc6,0xc(%esp)
c0104df4:	c0 
c0104df5:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104dfc:	c0 
c0104dfd:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0104e04:	00 
c0104e05:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104e0c:	e8 d8 b5 ff ff       	call   c01003e9 <__panic>
        count ++, total += p->property;
c0104e11:	ff 45 f4             	incl   -0xc(%ebp)
c0104e14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104e17:	8b 50 08             	mov    0x8(%eax),%edx
c0104e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e1d:	01 d0                	add    %edx,%eax
c0104e1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e22:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e25:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0104e28:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104e2b:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104e2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104e31:	81 7d ec 20 df 11 c0 	cmpl   $0xc011df20,-0x14(%ebp)
c0104e38:	0f 85 7a ff ff ff    	jne    c0104db8 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0104e3e:	e8 80 dd ff ff       	call   c0102bc3 <nr_free_pages>
c0104e43:	89 c2                	mov    %eax,%edx
c0104e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e48:	39 c2                	cmp    %eax,%edx
c0104e4a:	74 24                	je     c0104e70 <default_check+0xd8>
c0104e4c:	c7 44 24 0c d6 7d 10 	movl   $0xc0107dd6,0xc(%esp)
c0104e53:	c0 
c0104e54:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104e5b:	c0 
c0104e5c:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0104e63:	00 
c0104e64:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104e6b:	e8 79 b5 ff ff       	call   c01003e9 <__panic>

    basic_check();
c0104e70:	e8 e6 f9 ff ff       	call   c010485b <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104e75:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104e7c:	e8 d7 dc ff ff       	call   c0102b58 <alloc_pages>
c0104e81:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0104e84:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104e88:	75 24                	jne    c0104eae <default_check+0x116>
c0104e8a:	c7 44 24 0c ef 7d 10 	movl   $0xc0107def,0xc(%esp)
c0104e91:	c0 
c0104e92:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104e99:	c0 
c0104e9a:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0104ea1:	00 
c0104ea2:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104ea9:	e8 3b b5 ff ff       	call   c01003e9 <__panic>
    assert(!PageProperty(p0));
c0104eae:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104eb1:	83 c0 04             	add    $0x4,%eax
c0104eb4:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104ebb:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104ebe:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104ec1:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104ec4:	0f a3 10             	bt     %edx,(%eax)
c0104ec7:	19 c0                	sbb    %eax,%eax
c0104ec9:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104ecc:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104ed0:	0f 95 c0             	setne  %al
c0104ed3:	0f b6 c0             	movzbl %al,%eax
c0104ed6:	85 c0                	test   %eax,%eax
c0104ed8:	74 24                	je     c0104efe <default_check+0x166>
c0104eda:	c7 44 24 0c fa 7d 10 	movl   $0xc0107dfa,0xc(%esp)
c0104ee1:	c0 
c0104ee2:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104ee9:	c0 
c0104eea:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0104ef1:	00 
c0104ef2:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104ef9:	e8 eb b4 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104efe:	a1 20 df 11 c0       	mov    0xc011df20,%eax
c0104f03:	8b 15 24 df 11 c0    	mov    0xc011df24,%edx
c0104f09:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104f0c:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104f0f:	c7 45 b0 20 df 11 c0 	movl   $0xc011df20,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0104f16:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104f19:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104f1c:	89 50 04             	mov    %edx,0x4(%eax)
c0104f1f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104f22:	8b 50 04             	mov    0x4(%eax),%edx
c0104f25:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104f28:	89 10                	mov    %edx,(%eax)
c0104f2a:	c7 45 b4 20 df 11 c0 	movl   $0xc011df20,-0x4c(%ebp)
    return list->next == list;
c0104f31:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104f34:	8b 40 04             	mov    0x4(%eax),%eax
c0104f37:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0104f3a:	0f 94 c0             	sete   %al
c0104f3d:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104f40:	85 c0                	test   %eax,%eax
c0104f42:	75 24                	jne    c0104f68 <default_check+0x1d0>
c0104f44:	c7 44 24 0c 4f 7d 10 	movl   $0xc0107d4f,0xc(%esp)
c0104f4b:	c0 
c0104f4c:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104f53:	c0 
c0104f54:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0104f5b:	00 
c0104f5c:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104f63:	e8 81 b4 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104f68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f6f:	e8 e4 db ff ff       	call   c0102b58 <alloc_pages>
c0104f74:	85 c0                	test   %eax,%eax
c0104f76:	74 24                	je     c0104f9c <default_check+0x204>
c0104f78:	c7 44 24 0c 66 7d 10 	movl   $0xc0107d66,0xc(%esp)
c0104f7f:	c0 
c0104f80:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104f87:	c0 
c0104f88:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0104f8f:	00 
c0104f90:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104f97:	e8 4d b4 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104f9c:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104fa1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0104fa4:	c7 05 28 df 11 c0 00 	movl   $0x0,0xc011df28
c0104fab:	00 00 00 

    free_pages(p0 + 2, 3);
c0104fae:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104fb1:	83 c0 28             	add    $0x28,%eax
c0104fb4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104fbb:	00 
c0104fbc:	89 04 24             	mov    %eax,(%esp)
c0104fbf:	e8 cc db ff ff       	call   c0102b90 <free_pages>
    assert(alloc_pages(4) == NULL);
c0104fc4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104fcb:	e8 88 db ff ff       	call   c0102b58 <alloc_pages>
c0104fd0:	85 c0                	test   %eax,%eax
c0104fd2:	74 24                	je     c0104ff8 <default_check+0x260>
c0104fd4:	c7 44 24 0c 0c 7e 10 	movl   $0xc0107e0c,0xc(%esp)
c0104fdb:	c0 
c0104fdc:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0104fe3:	c0 
c0104fe4:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0104feb:	00 
c0104fec:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0104ff3:	e8 f1 b3 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104ff8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ffb:	83 c0 28             	add    $0x28,%eax
c0104ffe:	83 c0 04             	add    $0x4,%eax
c0105001:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0105008:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010500b:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010500e:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0105011:	0f a3 10             	bt     %edx,(%eax)
c0105014:	19 c0                	sbb    %eax,%eax
c0105016:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0105019:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c010501d:	0f 95 c0             	setne  %al
c0105020:	0f b6 c0             	movzbl %al,%eax
c0105023:	85 c0                	test   %eax,%eax
c0105025:	74 0e                	je     c0105035 <default_check+0x29d>
c0105027:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010502a:	83 c0 28             	add    $0x28,%eax
c010502d:	8b 40 08             	mov    0x8(%eax),%eax
c0105030:	83 f8 03             	cmp    $0x3,%eax
c0105033:	74 24                	je     c0105059 <default_check+0x2c1>
c0105035:	c7 44 24 0c 24 7e 10 	movl   $0xc0107e24,0xc(%esp)
c010503c:	c0 
c010503d:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0105044:	c0 
c0105045:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c010504c:	00 
c010504d:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0105054:	e8 90 b3 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0105059:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105060:	e8 f3 da ff ff       	call   c0102b58 <alloc_pages>
c0105065:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105068:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010506c:	75 24                	jne    c0105092 <default_check+0x2fa>
c010506e:	c7 44 24 0c 50 7e 10 	movl   $0xc0107e50,0xc(%esp)
c0105075:	c0 
c0105076:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c010507d:	c0 
c010507e:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c0105085:	00 
c0105086:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c010508d:	e8 57 b3 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0105092:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105099:	e8 ba da ff ff       	call   c0102b58 <alloc_pages>
c010509e:	85 c0                	test   %eax,%eax
c01050a0:	74 24                	je     c01050c6 <default_check+0x32e>
c01050a2:	c7 44 24 0c 66 7d 10 	movl   $0xc0107d66,0xc(%esp)
c01050a9:	c0 
c01050aa:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c01050b1:	c0 
c01050b2:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c01050b9:	00 
c01050ba:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c01050c1:	e8 23 b3 ff ff       	call   c01003e9 <__panic>
    assert(p0 + 2 == p1);
c01050c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050c9:	83 c0 28             	add    $0x28,%eax
c01050cc:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01050cf:	74 24                	je     c01050f5 <default_check+0x35d>
c01050d1:	c7 44 24 0c 6e 7e 10 	movl   $0xc0107e6e,0xc(%esp)
c01050d8:	c0 
c01050d9:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c01050e0:	c0 
c01050e1:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c01050e8:	00 
c01050e9:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c01050f0:	e8 f4 b2 ff ff       	call   c01003e9 <__panic>

    p2 = p0 + 1;
c01050f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050f8:	83 c0 14             	add    $0x14,%eax
c01050fb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01050fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105105:	00 
c0105106:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105109:	89 04 24             	mov    %eax,(%esp)
c010510c:	e8 7f da ff ff       	call   c0102b90 <free_pages>
    free_pages(p1, 3);
c0105111:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105118:	00 
c0105119:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010511c:	89 04 24             	mov    %eax,(%esp)
c010511f:	e8 6c da ff ff       	call   c0102b90 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0105124:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105127:	83 c0 04             	add    $0x4,%eax
c010512a:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0105131:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105134:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105137:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010513a:	0f a3 10             	bt     %edx,(%eax)
c010513d:	19 c0                	sbb    %eax,%eax
c010513f:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105142:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105146:	0f 95 c0             	setne  %al
c0105149:	0f b6 c0             	movzbl %al,%eax
c010514c:	85 c0                	test   %eax,%eax
c010514e:	74 0b                	je     c010515b <default_check+0x3c3>
c0105150:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105153:	8b 40 08             	mov    0x8(%eax),%eax
c0105156:	83 f8 01             	cmp    $0x1,%eax
c0105159:	74 24                	je     c010517f <default_check+0x3e7>
c010515b:	c7 44 24 0c 7c 7e 10 	movl   $0xc0107e7c,0xc(%esp)
c0105162:	c0 
c0105163:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c010516a:	c0 
c010516b:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
c0105172:	00 
c0105173:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c010517a:	e8 6a b2 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c010517f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105182:	83 c0 04             	add    $0x4,%eax
c0105185:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010518c:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010518f:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105192:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0105195:	0f a3 10             	bt     %edx,(%eax)
c0105198:	19 c0                	sbb    %eax,%eax
c010519a:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c010519d:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01051a1:	0f 95 c0             	setne  %al
c01051a4:	0f b6 c0             	movzbl %al,%eax
c01051a7:	85 c0                	test   %eax,%eax
c01051a9:	74 0b                	je     c01051b6 <default_check+0x41e>
c01051ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051ae:	8b 40 08             	mov    0x8(%eax),%eax
c01051b1:	83 f8 03             	cmp    $0x3,%eax
c01051b4:	74 24                	je     c01051da <default_check+0x442>
c01051b6:	c7 44 24 0c a4 7e 10 	movl   $0xc0107ea4,0xc(%esp)
c01051bd:	c0 
c01051be:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c01051c5:	c0 
c01051c6:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
c01051cd:	00 
c01051ce:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c01051d5:	e8 0f b2 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01051da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01051e1:	e8 72 d9 ff ff       	call   c0102b58 <alloc_pages>
c01051e6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01051e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01051ec:	83 e8 14             	sub    $0x14,%eax
c01051ef:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01051f2:	74 24                	je     c0105218 <default_check+0x480>
c01051f4:	c7 44 24 0c ca 7e 10 	movl   $0xc0107eca,0xc(%esp)
c01051fb:	c0 
c01051fc:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0105203:	c0 
c0105204:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
c010520b:	00 
c010520c:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0105213:	e8 d1 b1 ff ff       	call   c01003e9 <__panic>
    free_page(p0);
c0105218:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010521f:	00 
c0105220:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105223:	89 04 24             	mov    %eax,(%esp)
c0105226:	e8 65 d9 ff ff       	call   c0102b90 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010522b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0105232:	e8 21 d9 ff ff       	call   c0102b58 <alloc_pages>
c0105237:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010523a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010523d:	83 c0 14             	add    $0x14,%eax
c0105240:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105243:	74 24                	je     c0105269 <default_check+0x4d1>
c0105245:	c7 44 24 0c e8 7e 10 	movl   $0xc0107ee8,0xc(%esp)
c010524c:	c0 
c010524d:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0105254:	c0 
c0105255:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
c010525c:	00 
c010525d:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0105264:	e8 80 b1 ff ff       	call   c01003e9 <__panic>

    free_pages(p0, 2);
c0105269:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0105270:	00 
c0105271:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105274:	89 04 24             	mov    %eax,(%esp)
c0105277:	e8 14 d9 ff ff       	call   c0102b90 <free_pages>
    free_page(p2);
c010527c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105283:	00 
c0105284:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105287:	89 04 24             	mov    %eax,(%esp)
c010528a:	e8 01 d9 ff ff       	call   c0102b90 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010528f:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105296:	e8 bd d8 ff ff       	call   c0102b58 <alloc_pages>
c010529b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010529e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01052a2:	75 24                	jne    c01052c8 <default_check+0x530>
c01052a4:	c7 44 24 0c 08 7f 10 	movl   $0xc0107f08,0xc(%esp)
c01052ab:	c0 
c01052ac:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c01052b3:	c0 
c01052b4:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c01052bb:	00 
c01052bc:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c01052c3:	e8 21 b1 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c01052c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01052cf:	e8 84 d8 ff ff       	call   c0102b58 <alloc_pages>
c01052d4:	85 c0                	test   %eax,%eax
c01052d6:	74 24                	je     c01052fc <default_check+0x564>
c01052d8:	c7 44 24 0c 66 7d 10 	movl   $0xc0107d66,0xc(%esp)
c01052df:	c0 
c01052e0:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c01052e7:	c0 
c01052e8:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c01052ef:	00 
c01052f0:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c01052f7:	e8 ed b0 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c01052fc:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0105301:	85 c0                	test   %eax,%eax
c0105303:	74 24                	je     c0105329 <default_check+0x591>
c0105305:	c7 44 24 0c b9 7d 10 	movl   $0xc0107db9,0xc(%esp)
c010530c:	c0 
c010530d:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0105314:	c0 
c0105315:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
c010531c:	00 
c010531d:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0105324:	e8 c0 b0 ff ff       	call   c01003e9 <__panic>
    nr_free = nr_free_store;
c0105329:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010532c:	a3 28 df 11 c0       	mov    %eax,0xc011df28

    free_list = free_list_store;
c0105331:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105334:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105337:	a3 20 df 11 c0       	mov    %eax,0xc011df20
c010533c:	89 15 24 df 11 c0    	mov    %edx,0xc011df24
    free_pages(p0, 5);
c0105342:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0105349:	00 
c010534a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010534d:	89 04 24             	mov    %eax,(%esp)
c0105350:	e8 3b d8 ff ff       	call   c0102b90 <free_pages>

    le = &free_list;
c0105355:	c7 45 ec 20 df 11 c0 	movl   $0xc011df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010535c:	eb 5a                	jmp    c01053b8 <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
c010535e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105361:	8b 40 04             	mov    0x4(%eax),%eax
c0105364:	8b 00                	mov    (%eax),%eax
c0105366:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105369:	75 0d                	jne    c0105378 <default_check+0x5e0>
c010536b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010536e:	8b 00                	mov    (%eax),%eax
c0105370:	8b 40 04             	mov    0x4(%eax),%eax
c0105373:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105376:	74 24                	je     c010539c <default_check+0x604>
c0105378:	c7 44 24 0c 28 7f 10 	movl   $0xc0107f28,0xc(%esp)
c010537f:	c0 
c0105380:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c0105387:	c0 
c0105388:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
c010538f:	00 
c0105390:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c0105397:	e8 4d b0 ff ff       	call   c01003e9 <__panic>
        struct Page *p = le2page(le, page_link);
c010539c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010539f:	83 e8 0c             	sub    $0xc,%eax
c01053a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c01053a5:	ff 4d f4             	decl   -0xc(%ebp)
c01053a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01053ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01053ae:	8b 40 08             	mov    0x8(%eax),%eax
c01053b1:	29 c2                	sub    %eax,%edx
c01053b3:	89 d0                	mov    %edx,%eax
c01053b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01053b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053bb:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c01053be:	8b 45 88             	mov    -0x78(%ebp),%eax
c01053c1:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01053c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01053c7:	81 7d ec 20 df 11 c0 	cmpl   $0xc011df20,-0x14(%ebp)
c01053ce:	75 8e                	jne    c010535e <default_check+0x5c6>
    }
    assert(count == 0);
c01053d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01053d4:	74 24                	je     c01053fa <default_check+0x662>
c01053d6:	c7 44 24 0c 55 7f 10 	movl   $0xc0107f55,0xc(%esp)
c01053dd:	c0 
c01053de:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c01053e5:	c0 
c01053e6:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
c01053ed:	00 
c01053ee:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c01053f5:	e8 ef af ff ff       	call   c01003e9 <__panic>
    assert(total == 0);
c01053fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01053fe:	74 24                	je     c0105424 <default_check+0x68c>
c0105400:	c7 44 24 0c 60 7f 10 	movl   $0xc0107f60,0xc(%esp)
c0105407:	c0 
c0105408:	c7 44 24 08 de 7b 10 	movl   $0xc0107bde,0x8(%esp)
c010540f:	c0 
c0105410:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
c0105417:	00 
c0105418:	c7 04 24 f3 7b 10 c0 	movl   $0xc0107bf3,(%esp)
c010541f:	e8 c5 af ff ff       	call   c01003e9 <__panic>
}
c0105424:	90                   	nop
c0105425:	c9                   	leave  
c0105426:	c3                   	ret    

c0105427 <page2ppn>:
page2ppn(struct Page *page) {
c0105427:	55                   	push   %ebp
c0105428:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010542a:	8b 45 08             	mov    0x8(%ebp),%eax
c010542d:	8b 15 18 df 11 c0    	mov    0xc011df18,%edx
c0105433:	29 d0                	sub    %edx,%eax
c0105435:	c1 f8 02             	sar    $0x2,%eax
c0105438:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010543e:	5d                   	pop    %ebp
c010543f:	c3                   	ret    

c0105440 <page2pa>:
page2pa(struct Page *page) {
c0105440:	55                   	push   %ebp
c0105441:	89 e5                	mov    %esp,%ebp
c0105443:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0105446:	8b 45 08             	mov    0x8(%ebp),%eax
c0105449:	89 04 24             	mov    %eax,(%esp)
c010544c:	e8 d6 ff ff ff       	call   c0105427 <page2ppn>
c0105451:	c1 e0 0c             	shl    $0xc,%eax
}
c0105454:	c9                   	leave  
c0105455:	c3                   	ret    

c0105456 <page_ref>:
page_ref(struct Page *page) {
c0105456:	55                   	push   %ebp
c0105457:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0105459:	8b 45 08             	mov    0x8(%ebp),%eax
c010545c:	8b 00                	mov    (%eax),%eax
}
c010545e:	5d                   	pop    %ebp
c010545f:	c3                   	ret    

c0105460 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0105460:	55                   	push   %ebp
c0105461:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0105463:	8b 45 08             	mov    0x8(%ebp),%eax
c0105466:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105469:	89 10                	mov    %edx,(%eax)
}
c010546b:	90                   	nop
c010546c:	5d                   	pop    %ebp
c010546d:	c3                   	ret    

c010546e <buddy_init>:

#define MAXLEVEL 12
free_area_t free_area[MAXLEVEL+1];

static void 
buddy_init(void){
c010546e:	55                   	push   %ebp
c010546f:	89 e5                	mov    %esp,%ebp
c0105471:	83 ec 10             	sub    $0x10,%esp
     for(int i=0;i<=MAXLEVEL;i++){
c0105474:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010547b:	eb 42                	jmp    c01054bf <buddy_init+0x51>
	list_init(&free_area[i].free_list);
c010547d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0105480:	89 d0                	mov    %edx,%eax
c0105482:	01 c0                	add    %eax,%eax
c0105484:	01 d0                	add    %edx,%eax
c0105486:	c1 e0 02             	shl    $0x2,%eax
c0105489:	05 20 df 11 c0       	add    $0xc011df20,%eax
c010548e:	89 45 f8             	mov    %eax,-0x8(%ebp)
    elm->prev = elm->next = elm;
c0105491:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105494:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105497:	89 50 04             	mov    %edx,0x4(%eax)
c010549a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010549d:	8b 50 04             	mov    0x4(%eax),%edx
c01054a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01054a3:	89 10                	mov    %edx,(%eax)
	free_area[i].nr_free=0;
c01054a5:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01054a8:	89 d0                	mov    %edx,%eax
c01054aa:	01 c0                	add    %eax,%eax
c01054ac:	01 d0                	add    %edx,%eax
c01054ae:	c1 e0 02             	shl    $0x2,%eax
c01054b1:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01054b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     for(int i=0;i<=MAXLEVEL;i++){
c01054bc:	ff 45 fc             	incl   -0x4(%ebp)
c01054bf:	83 7d fc 0c          	cmpl   $0xc,-0x4(%ebp)
c01054c3:	7e b8                	jle    c010547d <buddy_init+0xf>
     }
}
c01054c5:	90                   	nop
c01054c6:	c9                   	leave  
c01054c7:	c3                   	ret    

c01054c8 <buddy_nr_free_page>:

static size_t
buddy_nr_free_page(void){
c01054c8:	55                   	push   %ebp
c01054c9:	89 e5                	mov    %esp,%ebp
c01054cb:	83 ec 10             	sub    $0x10,%esp
    size_t nr=0;
c01054ce:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
c01054d5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
c01054dc:	eb 1c                	jmp    c01054fa <buddy_nr_free_page+0x32>
	nr+=free_area[i].nr_free*(1<<MAXLEVEL);
c01054de:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01054e1:	89 d0                	mov    %edx,%eax
c01054e3:	01 c0                	add    %eax,%eax
c01054e5:	01 d0                	add    %edx,%eax
c01054e7:	c1 e0 02             	shl    $0x2,%eax
c01054ea:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01054ef:	8b 00                	mov    (%eax),%eax
c01054f1:	c1 e0 0c             	shl    $0xc,%eax
c01054f4:	01 45 fc             	add    %eax,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
c01054f7:	ff 45 f8             	incl   -0x8(%ebp)
c01054fa:	83 7d f8 0c          	cmpl   $0xc,-0x8(%ebp)
c01054fe:	7e de                	jle    c01054de <buddy_nr_free_page+0x16>
    }
    return nr; 
c0105500:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105503:	c9                   	leave  
c0105504:	c3                   	ret    

c0105505 <buddy_init_memmap>:

static void
buddy_init_memmap(struct Page* base,size_t n){
c0105505:	55                   	push   %ebp
c0105506:	89 e5                	mov    %esp,%ebp
c0105508:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
c010550b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010550f:	75 24                	jne    c0105535 <buddy_init_memmap+0x30>
c0105511:	c7 44 24 0c 9c 7f 10 	movl   $0xc0107f9c,0xc(%esp)
c0105518:	c0 
c0105519:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c0105520:	c0 
c0105521:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
c0105528:	00 
c0105529:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c0105530:	e8 b4 ae ff ff       	call   c01003e9 <__panic>
     struct Page* p=base;
c0105535:	8b 45 08             	mov    0x8(%ebp),%eax
c0105538:	89 45 f4             	mov    %eax,-0xc(%ebp)
     for(;p!=base+n;p++){
c010553b:	eb 7d                	jmp    c01055ba <buddy_init_memmap+0xb5>
	assert(PageReserved(p));
c010553d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105540:	83 c0 04             	add    $0x4,%eax
c0105543:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c010554a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010554d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105550:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105553:	0f a3 10             	bt     %edx,(%eax)
c0105556:	19 c0                	sbb    %eax,%eax
c0105558:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c010555b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010555f:	0f 95 c0             	setne  %al
c0105562:	0f b6 c0             	movzbl %al,%eax
c0105565:	85 c0                	test   %eax,%eax
c0105567:	75 24                	jne    c010558d <buddy_init_memmap+0x88>
c0105569:	c7 44 24 0c cc 7f 10 	movl   $0xc0107fcc,0xc(%esp)
c0105570:	c0 
c0105571:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c0105578:	c0 
c0105579:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
c0105580:	00 
c0105581:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c0105588:	e8 5c ae ff ff       	call   c01003e9 <__panic>
	p->flags=p->property=0;
c010558d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105590:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0105597:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010559a:	8b 50 08             	mov    0x8(%eax),%edx
c010559d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055a0:	89 50 04             	mov    %edx,0x4(%eax)
	set_page_ref(p,0);
c01055a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01055aa:	00 
c01055ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055ae:	89 04 24             	mov    %eax,(%esp)
c01055b1:	e8 aa fe ff ff       	call   c0105460 <set_page_ref>
     for(;p!=base+n;p++){
c01055b6:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01055ba:	8b 55 0c             	mov    0xc(%ebp),%edx
c01055bd:	89 d0                	mov    %edx,%eax
c01055bf:	c1 e0 02             	shl    $0x2,%eax
c01055c2:	01 d0                	add    %edx,%eax
c01055c4:	c1 e0 02             	shl    $0x2,%eax
c01055c7:	89 c2                	mov    %eax,%edx
c01055c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01055cc:	01 d0                	add    %edx,%eax
c01055ce:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01055d1:	0f 85 66 ff ff ff    	jne    c010553d <buddy_init_memmap+0x38>
     }
     p=base;
c01055d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01055da:	89 45 f4             	mov    %eax,-0xc(%ebp)
     size_t temp=n;
c01055dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
     int level=MAXLEVEL;
c01055e3:	c7 45 ec 0c 00 00 00 	movl   $0xc,-0x14(%ebp)
     while(level>=0){
c01055ea:	e9 fd 00 00 00       	jmp    c01056ec <buddy_init_memmap+0x1e7>
	for(int i=0;i<temp/(1<<level);i++){
c01055ef:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01055f6:	e9 c7 00 00 00       	jmp    c01056c2 <buddy_init_memmap+0x1bd>
	    struct Page* page=p;
c01055fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	    page->property=1<<level;
c0105601:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105604:	ba 01 00 00 00       	mov    $0x1,%edx
c0105609:	88 c1                	mov    %al,%cl
c010560b:	d3 e2                	shl    %cl,%edx
c010560d:	89 d0                	mov    %edx,%eax
c010560f:	89 c2                	mov    %eax,%edx
c0105611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105614:	89 50 08             	mov    %edx,0x8(%eax)
	    SetPageProperty(p);
c0105617:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010561a:	83 c0 04             	add    $0x4,%eax
c010561d:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0105624:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105627:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010562a:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010562d:	0f ab 10             	bts    %edx,(%eax)
	    list_add_before(&free_area[level].free_list,&(page->page_link));
c0105630:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105633:	8d 48 0c             	lea    0xc(%eax),%ecx
c0105636:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105639:	89 d0                	mov    %edx,%eax
c010563b:	01 c0                	add    %eax,%eax
c010563d:	01 d0                	add    %edx,%eax
c010563f:	c1 e0 02             	shl    $0x2,%eax
c0105642:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105647:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010564a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
    __list_add(elm, listelm->prev, listelm);
c010564d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105650:	8b 00                	mov    (%eax),%eax
c0105652:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105655:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0105658:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010565b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010565e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
c0105661:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105664:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105667:	89 10                	mov    %edx,(%eax)
c0105669:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010566c:	8b 10                	mov    (%eax),%edx
c010566e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105671:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105674:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105677:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010567a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010567d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105680:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105683:	89 10                	mov    %edx,(%eax)
	    p+=(1<<level);
c0105685:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105688:	ba 14 00 00 00       	mov    $0x14,%edx
c010568d:	88 c1                	mov    %al,%cl
c010568f:	d3 e2                	shl    %cl,%edx
c0105691:	89 d0                	mov    %edx,%eax
c0105693:	01 45 f4             	add    %eax,-0xc(%ebp)
	    free_area[level].nr_free++;
c0105696:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105699:	89 d0                	mov    %edx,%eax
c010569b:	01 c0                	add    %eax,%eax
c010569d:	01 d0                	add    %edx,%eax
c010569f:	c1 e0 02             	shl    $0x2,%eax
c01056a2:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01056a7:	8b 00                	mov    (%eax),%eax
c01056a9:	8d 48 01             	lea    0x1(%eax),%ecx
c01056ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01056af:	89 d0                	mov    %edx,%eax
c01056b1:	01 c0                	add    %eax,%eax
c01056b3:	01 d0                	add    %edx,%eax
c01056b5:	c1 e0 02             	shl    $0x2,%eax
c01056b8:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01056bd:	89 08                	mov    %ecx,(%eax)
	for(int i=0;i<temp/(1<<level);i++){
c01056bf:	ff 45 e8             	incl   -0x18(%ebp)
c01056c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01056c8:	88 c1                	mov    %al,%cl
c01056ca:	d3 ea                	shr    %cl,%edx
c01056cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01056cf:	39 c2                	cmp    %eax,%edx
c01056d1:	0f 87 24 ff ff ff    	ja     c01055fb <buddy_init_memmap+0xf6>
	}
	temp = temp % (1 << level);
c01056d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056da:	ba 01 00 00 00       	mov    $0x1,%edx
c01056df:	88 c1                	mov    %al,%cl
c01056e1:	d3 e2                	shl    %cl,%edx
c01056e3:	89 d0                	mov    %edx,%eax
c01056e5:	48                   	dec    %eax
c01056e6:	21 45 f0             	and    %eax,-0x10(%ebp)
	level--;
c01056e9:	ff 4d ec             	decl   -0x14(%ebp)
     while(level>=0){
c01056ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01056f0:	0f 89 f9 fe ff ff    	jns    c01055ef <buddy_init_memmap+0xea>
     }
}
c01056f6:	90                   	nop
c01056f7:	c9                   	leave  
c01056f8:	c3                   	ret    

c01056f9 <buddy_my_partial>:

static void
buddy_my_partial(struct Page *base, size_t n, int level) {
c01056f9:	55                   	push   %ebp
c01056fa:	89 e5                	mov    %esp,%ebp
c01056fc:	83 ec 78             	sub    $0x78,%esp
    if (level < 0) return;
c01056ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105703:	0f 88 20 02 00 00    	js     c0105929 <buddy_my_partial+0x230>
    size_t temp = n;
c0105709:	8b 45 0c             	mov    0xc(%ebp),%eax
c010570c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (level >= 0) {
c010570f:	e9 7a 01 00 00       	jmp    c010588e <buddy_my_partial+0x195>
        for (int i = 0; i < temp / (1 << level); i++) {
c0105714:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010571b:	e9 44 01 00 00       	jmp    c0105864 <buddy_my_partial+0x16b>
            base->property = (1 << level);
c0105720:	8b 45 10             	mov    0x10(%ebp),%eax
c0105723:	ba 01 00 00 00       	mov    $0x1,%edx
c0105728:	88 c1                	mov    %al,%cl
c010572a:	d3 e2                	shl    %cl,%edx
c010572c:	89 d0                	mov    %edx,%eax
c010572e:	89 c2                	mov    %eax,%edx
c0105730:	8b 45 08             	mov    0x8(%ebp),%eax
c0105733:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(base);
c0105736:	8b 45 08             	mov    0x8(%ebp),%eax
c0105739:	83 c0 04             	add    $0x4,%eax
c010573c:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0105743:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105746:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105749:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010574c:	0f ab 10             	bts    %edx,(%eax)
            // add pages in order
            struct Page* p = NULL;
c010574f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
            list_entry_t* le = list_next(&(free_area[level].free_list));
c0105756:	8b 55 10             	mov    0x10(%ebp),%edx
c0105759:	89 d0                	mov    %edx,%eax
c010575b:	01 c0                	add    %eax,%eax
c010575d:	01 d0                	add    %edx,%eax
c010575f:	c1 e0 02             	shl    $0x2,%eax
c0105762:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105767:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return listelm->next;
c010576a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010576d:	8b 40 04             	mov    0x4(%eax),%eax
c0105770:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105773:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105776:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return listelm->prev;
c0105779:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010577c:	8b 00                	mov    (%eax),%eax
            list_entry_t* bfle = list_prev(le);
c010577e:	89 45 e8             	mov    %eax,-0x18(%ebp)
            while (le != &(free_area[level].free_list)) {
c0105781:	eb 37                	jmp    c01057ba <buddy_my_partial+0xc1>
                p = le2page(le, page_link);
c0105783:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105786:	83 e8 0c             	sub    $0xc,%eax
c0105789:	89 45 d8             	mov    %eax,-0x28(%ebp)
                if (base + base->property < le) break;
c010578c:	8b 45 08             	mov    0x8(%ebp),%eax
c010578f:	8b 50 08             	mov    0x8(%eax),%edx
c0105792:	89 d0                	mov    %edx,%eax
c0105794:	c1 e0 02             	shl    $0x2,%eax
c0105797:	01 d0                	add    %edx,%eax
c0105799:	c1 e0 02             	shl    $0x2,%eax
c010579c:	89 c2                	mov    %eax,%edx
c010579e:	8b 45 08             	mov    0x8(%ebp),%eax
c01057a1:	01 d0                	add    %edx,%eax
c01057a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01057a6:	77 2a                	ja     c01057d2 <buddy_my_partial+0xd9>
                bfle = bfle->next;
c01057a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057ab:	8b 40 04             	mov    0x4(%eax),%eax
c01057ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
                le = le->next;
c01057b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057b4:	8b 40 04             	mov    0x4(%eax),%eax
c01057b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
            while (le != &(free_area[level].free_list)) {
c01057ba:	8b 55 10             	mov    0x10(%ebp),%edx
c01057bd:	89 d0                	mov    %edx,%eax
c01057bf:	01 c0                	add    %eax,%eax
c01057c1:	01 d0                	add    %edx,%eax
c01057c3:	c1 e0 02             	shl    $0x2,%eax
c01057c6:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01057cb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01057ce:	75 b3                	jne    c0105783 <buddy_my_partial+0x8a>
c01057d0:	eb 01                	jmp    c01057d3 <buddy_my_partial+0xda>
                if (base + base->property < le) break;
c01057d2:	90                   	nop
            }
            list_add(bfle, &(base->page_link));
c01057d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01057d6:	8d 50 0c             	lea    0xc(%eax),%edx
c01057d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057dc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01057df:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01057e2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01057e5:	89 45 bc             	mov    %eax,-0x44(%ebp)
c01057e8:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01057eb:	89 45 b8             	mov    %eax,-0x48(%ebp)
    __list_add(elm, listelm, listelm->next);
c01057ee:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01057f1:	8b 40 04             	mov    0x4(%eax),%eax
c01057f4:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01057f7:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c01057fa:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01057fd:	89 55 b0             	mov    %edx,-0x50(%ebp)
c0105800:	89 45 ac             	mov    %eax,-0x54(%ebp)
    prev->next = next->prev = elm;
c0105803:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105806:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0105809:	89 10                	mov    %edx,(%eax)
c010580b:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010580e:	8b 10                	mov    (%eax),%edx
c0105810:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105813:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105816:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105819:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010581c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010581f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105822:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0105825:	89 10                	mov    %edx,(%eax)
            base += (1 << level);
c0105827:	8b 45 10             	mov    0x10(%ebp),%eax
c010582a:	ba 14 00 00 00       	mov    $0x14,%edx
c010582f:	88 c1                	mov    %al,%cl
c0105831:	d3 e2                	shl    %cl,%edx
c0105833:	89 d0                	mov    %edx,%eax
c0105835:	01 45 08             	add    %eax,0x8(%ebp)
            free_area[level].nr_free++;
c0105838:	8b 55 10             	mov    0x10(%ebp),%edx
c010583b:	89 d0                	mov    %edx,%eax
c010583d:	01 c0                	add    %eax,%eax
c010583f:	01 d0                	add    %edx,%eax
c0105841:	c1 e0 02             	shl    $0x2,%eax
c0105844:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105849:	8b 00                	mov    (%eax),%eax
c010584b:	8d 48 01             	lea    0x1(%eax),%ecx
c010584e:	8b 55 10             	mov    0x10(%ebp),%edx
c0105851:	89 d0                	mov    %edx,%eax
c0105853:	01 c0                	add    %eax,%eax
c0105855:	01 d0                	add    %edx,%eax
c0105857:	c1 e0 02             	shl    $0x2,%eax
c010585a:	05 28 df 11 c0       	add    $0xc011df28,%eax
c010585f:	89 08                	mov    %ecx,(%eax)
        for (int i = 0; i < temp / (1 << level); i++) {
c0105861:	ff 45 f0             	incl   -0x10(%ebp)
c0105864:	8b 45 10             	mov    0x10(%ebp),%eax
c0105867:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010586a:	88 c1                	mov    %al,%cl
c010586c:	d3 ea                	shr    %cl,%edx
c010586e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105871:	39 c2                	cmp    %eax,%edx
c0105873:	0f 87 a7 fe ff ff    	ja     c0105720 <buddy_my_partial+0x27>
        }
        temp = temp % (1 << level);
c0105879:	8b 45 10             	mov    0x10(%ebp),%eax
c010587c:	ba 01 00 00 00       	mov    $0x1,%edx
c0105881:	88 c1                	mov    %al,%cl
c0105883:	d3 e2                	shl    %cl,%edx
c0105885:	89 d0                	mov    %edx,%eax
c0105887:	48                   	dec    %eax
c0105888:	21 45 f4             	and    %eax,-0xc(%ebp)
        level--;
c010588b:	ff 4d 10             	decl   0x10(%ebp)
    while (level >= 0) {
c010588e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105892:	0f 89 7c fe ff ff    	jns    c0105714 <buddy_my_partial+0x1b>
    }
    cprintf("alloc_page check: \n");
c0105898:	c7 04 24 dc 7f 10 c0 	movl   $0xc0107fdc,(%esp)
c010589f:	e8 ee a9 ff ff       	call   c0100292 <cprintf>
    for (int i = MAXLEVEL; i >= 0; i--) {
c01058a4:	c7 45 e4 0c 00 00 00 	movl   $0xc,-0x1c(%ebp)
c01058ab:	eb 74                	jmp    c0105921 <buddy_my_partial+0x228>
        list_entry_t* le = list_next(&(free_area[i].free_list));
c01058ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01058b0:	89 d0                	mov    %edx,%eax
c01058b2:	01 c0                	add    %eax,%eax
c01058b4:	01 d0                	add    %edx,%eax
c01058b6:	c1 e0 02             	shl    $0x2,%eax
c01058b9:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01058be:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return listelm->next;
c01058c1:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01058c4:	8b 40 04             	mov    0x4(%eax),%eax
c01058c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
c01058ca:	eb 3c                	jmp    c0105908 <buddy_my_partial+0x20f>
            struct Page* page = le2page(le, page_link);
c01058cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058cf:	83 e8 0c             	sub    $0xc,%eax
c01058d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
            cprintf("%d - %llx\n", i, page->page_link);
c01058d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01058d8:	8b 50 10             	mov    0x10(%eax),%edx
c01058db:	8b 40 0c             	mov    0xc(%eax),%eax
c01058de:	89 44 24 08          	mov    %eax,0x8(%esp)
c01058e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01058e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01058e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058ed:	c7 04 24 f0 7f 10 c0 	movl   $0xc0107ff0,(%esp)
c01058f4:	e8 99 a9 ff ff       	call   c0100292 <cprintf>
c01058f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058fc:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c01058ff:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105902:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
c0105905:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
c0105908:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010590b:	89 d0                	mov    %edx,%eax
c010590d:	01 c0                	add    %eax,%eax
c010590f:	01 d0                	add    %edx,%eax
c0105911:	c1 e0 02             	shl    $0x2,%eax
c0105914:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105919:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010591c:	75 ae                	jne    c01058cc <buddy_my_partial+0x1d3>
    for (int i = MAXLEVEL; i >= 0; i--) {
c010591e:	ff 4d e4             	decl   -0x1c(%ebp)
c0105921:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105925:	79 86                	jns    c01058ad <buddy_my_partial+0x1b4>
c0105927:	eb 01                	jmp    c010592a <buddy_my_partial+0x231>
    if (level < 0) return;
c0105929:	90                   	nop
        }
    }
}
c010592a:	c9                   	leave  
c010592b:	c3                   	ret    

c010592c <buddy_my_merge>:

static void
buddy_my_merge(int level) {
c010592c:	55                   	push   %ebp
c010592d:	89 e5                	mov    %esp,%ebp
c010592f:	83 ec 68             	sub    $0x68,%esp
    cprintf("before merge.\n");
c0105932:	c7 04 24 fb 7f 10 c0 	movl   $0xc0107ffb,(%esp)
c0105939:	e8 54 a9 ff ff       	call   c0100292 <cprintf>
    //bds_selfcheck();
    while (level < MAXLEVEL) {
c010593e:	e9 dc 01 00 00       	jmp    c0105b1f <buddy_my_merge+0x1f3>
        if (free_area[level].nr_free <= 1) {
c0105943:	8b 55 08             	mov    0x8(%ebp),%edx
c0105946:	89 d0                	mov    %edx,%eax
c0105948:	01 c0                	add    %eax,%eax
c010594a:	01 d0                	add    %edx,%eax
c010594c:	c1 e0 02             	shl    $0x2,%eax
c010594f:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105954:	8b 00                	mov    (%eax),%eax
c0105956:	83 f8 01             	cmp    $0x1,%eax
c0105959:	77 08                	ja     c0105963 <buddy_my_merge+0x37>
            level++;
c010595b:	ff 45 08             	incl   0x8(%ebp)
            continue;
c010595e:	e9 bc 01 00 00       	jmp    c0105b1f <buddy_my_merge+0x1f3>
        }
        list_entry_t* le = list_next(&(free_area[level].free_list));
c0105963:	8b 55 08             	mov    0x8(%ebp),%edx
c0105966:	89 d0                	mov    %edx,%eax
c0105968:	01 c0                	add    %eax,%eax
c010596a:	01 d0                	add    %edx,%eax
c010596c:	c1 e0 02             	shl    $0x2,%eax
c010596f:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105974:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105977:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010597a:	8b 40 04             	mov    0x4(%eax),%eax
c010597d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105980:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105983:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->prev;
c0105986:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105989:	8b 00                	mov    (%eax),%eax
        list_entry_t* bfle = list_prev(le);
c010598b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while (le != &(free_area[level].free_list)) {
c010598e:	e9 6f 01 00 00       	jmp    c0105b02 <buddy_my_merge+0x1d6>
c0105993:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105996:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return listelm->next;
c0105999:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010599c:	8b 40 04             	mov    0x4(%eax),%eax
            bfle = list_next(bfle);
c010599f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01059a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01059ab:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
c01059ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
            struct Page* ple = le2page(le, page_link);
c01059b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059b4:	83 e8 0c             	sub    $0xc,%eax
c01059b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
            struct Page* pbf = le2page(bfle, page_link); 
c01059ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059bd:	83 e8 0c             	sub    $0xc,%eax
c01059c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
            cprintf("bfle addr is: %llx\n", pbf->page_link);
c01059c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059c6:	8b 50 10             	mov    0x10(%eax),%edx
c01059c9:	8b 40 0c             	mov    0xc(%eax),%eax
c01059cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059d0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01059d4:	c7 04 24 0a 80 10 c0 	movl   $0xc010800a,(%esp)
c01059db:	e8 b2 a8 ff ff       	call   c0100292 <cprintf>
            cprintf("le addr is: %llx\n", ple->page_link);
c01059e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059e3:	8b 50 10             	mov    0x10(%eax),%edx
c01059e6:	8b 40 0c             	mov    0xc(%eax),%eax
c01059e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059ed:	89 54 24 08          	mov    %edx,0x8(%esp)
c01059f1:	c7 04 24 1e 80 10 c0 	movl   $0xc010801e,(%esp)
c01059f8:	e8 95 a8 ff ff       	call   c0100292 <cprintf>
            if (pbf + pbf->property == ple) {            
c01059fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a00:	8b 50 08             	mov    0x8(%eax),%edx
c0105a03:	89 d0                	mov    %edx,%eax
c0105a05:	c1 e0 02             	shl    $0x2,%eax
c0105a08:	01 d0                	add    %edx,%eax
c0105a0a:	c1 e0 02             	shl    $0x2,%eax
c0105a0d:	89 c2                	mov    %eax,%edx
c0105a0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a12:	01 d0                	add    %edx,%eax
c0105a14:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105a17:	0f 85 e5 00 00 00    	jne    c0105b02 <buddy_my_merge+0x1d6>
c0105a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a20:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0105a23:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105a26:	8b 40 04             	mov    0x4(%eax),%eax
                bfle = list_next(bfle);
c0105a29:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a2f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0105a32:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105a35:	8b 40 04             	mov    0x4(%eax),%eax
                le = list_next(le);
c0105a38:	89 45 f4             	mov    %eax,-0xc(%ebp)
                pbf->property = pbf->property << 1;
c0105a3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a3e:	8b 40 08             	mov    0x8(%eax),%eax
c0105a41:	8d 14 00             	lea    (%eax,%eax,1),%edx
c0105a44:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a47:	89 50 08             	mov    %edx,0x8(%eax)
                ClearPageProperty(ple);
c0105a4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a4d:	83 c0 04             	add    $0x4,%eax
c0105a50:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0105a57:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105a5a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105a5d:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0105a60:	0f b3 10             	btr    %edx,(%eax)
                list_del(&(pbf->page_link));
c0105a63:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a66:	83 c0 0c             	add    $0xc,%eax
c0105a69:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105a6c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105a6f:	8b 40 04             	mov    0x4(%eax),%eax
c0105a72:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105a75:	8b 12                	mov    (%edx),%edx
c0105a77:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c0105a7a:	89 45 c0             	mov    %eax,-0x40(%ebp)
    prev->next = next;
c0105a7d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105a80:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105a83:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105a86:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105a89:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105a8c:	89 10                	mov    %edx,(%eax)
                list_del(&(ple->page_link));
c0105a8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a91:	83 c0 0c             	add    $0xc,%eax
c0105a94:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105a97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105a9a:	8b 40 04             	mov    0x4(%eax),%eax
c0105a9d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105aa0:	8b 12                	mov    (%edx),%edx
c0105aa2:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0105aa5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next;
c0105aa8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105aab:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105aae:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105ab1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105ab4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105ab7:	89 10                	mov    %edx,(%eax)
                buddy_my_partial(pbf, pbf->property, level + 1);             
c0105ab9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105abc:	8d 50 01             	lea    0x1(%eax),%edx
c0105abf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ac2:	8b 40 08             	mov    0x8(%eax),%eax
c0105ac5:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105acd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ad0:	89 04 24             	mov    %eax,(%esp)
c0105ad3:	e8 21 fc ff ff       	call   c01056f9 <buddy_my_partial>
                free_area[level].nr_free -= 2;              
c0105ad8:	8b 55 08             	mov    0x8(%ebp),%edx
c0105adb:	89 d0                	mov    %edx,%eax
c0105add:	01 c0                	add    %eax,%eax
c0105adf:	01 d0                	add    %edx,%eax
c0105ae1:	c1 e0 02             	shl    $0x2,%eax
c0105ae4:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105ae9:	8b 00                	mov    (%eax),%eax
c0105aeb:	8d 48 fe             	lea    -0x2(%eax),%ecx
c0105aee:	8b 55 08             	mov    0x8(%ebp),%edx
c0105af1:	89 d0                	mov    %edx,%eax
c0105af3:	01 c0                	add    %eax,%eax
c0105af5:	01 d0                	add    %edx,%eax
c0105af7:	c1 e0 02             	shl    $0x2,%eax
c0105afa:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105aff:	89 08                	mov    %ecx,(%eax)
                continue;
c0105b01:	90                   	nop
        while (le != &(free_area[level].free_list)) {
c0105b02:	8b 55 08             	mov    0x8(%ebp),%edx
c0105b05:	89 d0                	mov    %edx,%eax
c0105b07:	01 c0                	add    %eax,%eax
c0105b09:	01 d0                	add    %edx,%eax
c0105b0b:	c1 e0 02             	shl    $0x2,%eax
c0105b0e:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105b13:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105b16:	0f 85 77 fe ff ff    	jne    c0105993 <buddy_my_merge+0x67>
            } 
        }
        level++;
c0105b1c:	ff 45 08             	incl   0x8(%ebp)
    while (level < MAXLEVEL) {
c0105b1f:	83 7d 08 0b          	cmpl   $0xb,0x8(%ebp)
c0105b23:	0f 8e 1a fe ff ff    	jle    c0105943 <buddy_my_merge+0x17>
    }
    //bds_selfcheck();
}
c0105b29:	90                   	nop
c0105b2a:	c9                   	leave  
c0105b2b:	c3                   	ret    

c0105b2c <buddy_alloc_page>:

static struct Page*
buddy_alloc_page(size_t n){
c0105b2c:	55                   	push   %ebp
c0105b2d:	89 e5                	mov    %esp,%ebp
c0105b2f:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
c0105b32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105b36:	75 24                	jne    c0105b5c <buddy_alloc_page+0x30>
c0105b38:	c7 44 24 0c 9c 7f 10 	movl   $0xc0107f9c,0xc(%esp)
c0105b3f:	c0 
c0105b40:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c0105b47:	c0 
c0105b48:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0105b4f:	00 
c0105b50:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c0105b57:	e8 8d a8 ff ff       	call   c01003e9 <__panic>
     if(n>buddy_nr_free_page()){
c0105b5c:	e8 67 f9 ff ff       	call   c01054c8 <buddy_nr_free_page>
c0105b61:	39 45 08             	cmp    %eax,0x8(%ebp)
c0105b64:	76 0a                	jbe    c0105b70 <buddy_alloc_page+0x44>
	return NULL;
c0105b66:	b8 00 00 00 00       	mov    $0x0,%eax
c0105b6b:	e9 62 01 00 00       	jmp    c0105cd2 <buddy_alloc_page+0x1a6>
     }
     int level=0;
c0105b70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     while((1<<level)<n){
c0105b77:	eb 03                	jmp    c0105b7c <buddy_alloc_page+0x50>
	level++;
c0105b79:	ff 45 f4             	incl   -0xc(%ebp)
     while((1<<level)<n){
c0105b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b7f:	ba 01 00 00 00       	mov    $0x1,%edx
c0105b84:	88 c1                	mov    %al,%cl
c0105b86:	d3 e2                	shl    %cl,%edx
c0105b88:	89 d0                	mov    %edx,%eax
c0105b8a:	39 45 08             	cmp    %eax,0x8(%ebp)
c0105b8d:	77 ea                	ja     c0105b79 <buddy_alloc_page+0x4d>
     }
     //n=1<<level;
     for(int i=level;i<=MAXLEVEL;i++){
c0105b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b95:	eb 22                	jmp    c0105bb9 <buddy_alloc_page+0x8d>
	if(free_area[i].nr_free!=0){
c0105b97:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105b9a:	89 d0                	mov    %edx,%eax
c0105b9c:	01 c0                	add    %eax,%eax
c0105b9e:	01 d0                	add    %edx,%eax
c0105ba0:	c1 e0 02             	shl    $0x2,%eax
c0105ba3:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105ba8:	8b 00                	mov    (%eax),%eax
c0105baa:	85 c0                	test   %eax,%eax
c0105bac:	74 08                	je     c0105bb6 <buddy_alloc_page+0x8a>
	   level=i;
c0105bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    break;
c0105bb4:	eb 09                	jmp    c0105bbf <buddy_alloc_page+0x93>
     for(int i=level;i<=MAXLEVEL;i++){
c0105bb6:	ff 45 f0             	incl   -0x10(%ebp)
c0105bb9:	83 7d f0 0c          	cmpl   $0xc,-0x10(%ebp)
c0105bbd:	7e d8                	jle    c0105b97 <buddy_alloc_page+0x6b>
	}
     }
     if(level>MAXLEVEL){return NULL;}
c0105bbf:	83 7d f4 0c          	cmpl   $0xc,-0xc(%ebp)
c0105bc3:	7e 0a                	jle    c0105bcf <buddy_alloc_page+0xa3>
c0105bc5:	b8 00 00 00 00       	mov    $0x0,%eax
c0105bca:	e9 03 01 00 00       	jmp    c0105cd2 <buddy_alloc_page+0x1a6>
     list_entry_t *le=&free_area[level].free_list;
c0105bcf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105bd2:	89 d0                	mov    %edx,%eax
c0105bd4:	01 c0                	add    %eax,%eax
c0105bd6:	01 d0                	add    %edx,%eax
c0105bd8:	c1 e0 02             	shl    $0x2,%eax
c0105bdb:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105be0:	89 45 ec             	mov    %eax,-0x14(%ebp)
     struct Page* page=le2page(le,page_link);
c0105be3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105be6:	83 e8 0c             	sub    $0xc,%eax
c0105be9:	89 45 e8             	mov    %eax,-0x18(%ebp)
     if (page != NULL) {
c0105bec:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105bf0:	0f 84 cd 00 00 00    	je     c0105cc3 <buddy_alloc_page+0x197>
        SetPageReserved(page);
c0105bf6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105bf9:	83 c0 04             	add    $0x4,%eax
c0105bfc:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
c0105c03:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105c06:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105c09:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105c0c:	0f ab 10             	bts    %edx,(%eax)
        // deal with partial work
        buddy_my_partial(page, page->property - n, level - 1);
c0105c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c12:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105c15:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c18:	8b 40 08             	mov    0x8(%eax),%eax
c0105c1b:	2b 45 08             	sub    0x8(%ebp),%eax
c0105c1e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105c22:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c26:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c29:	89 04 24             	mov    %eax,(%esp)
c0105c2c:	e8 c8 fa ff ff       	call   c01056f9 <buddy_my_partial>
        ClearPageReserved(page);
c0105c31:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c34:	83 c0 04             	add    $0x4,%eax
c0105c37:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
c0105c3e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105c41:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105c44:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105c47:	0f b3 10             	btr    %edx,(%eax)
        ClearPageProperty(page);
c0105c4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c4d:	83 c0 04             	add    $0x4,%eax
c0105c50:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
c0105c57:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105c5a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105c5d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105c60:	0f b3 10             	btr    %edx,(%eax)
        list_del(&(page->page_link));
c0105c63:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c66:	83 c0 0c             	add    $0xc,%eax
c0105c69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105c6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c6f:	8b 40 04             	mov    0x4(%eax),%eax
c0105c72:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105c75:	8b 12                	mov    (%edx),%edx
c0105c77:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0105c7a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c0105c7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c80:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105c83:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105c86:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105c89:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105c8c:	89 10                	mov    %edx,(%eax)
        free_area[level].nr_free--;
c0105c8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c91:	89 d0                	mov    %edx,%eax
c0105c93:	01 c0                	add    %eax,%eax
c0105c95:	01 d0                	add    %edx,%eax
c0105c97:	c1 e0 02             	shl    $0x2,%eax
c0105c9a:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105c9f:	8b 00                	mov    (%eax),%eax
c0105ca1:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105ca4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ca7:	89 d0                	mov    %edx,%eax
c0105ca9:	01 c0                	add    %eax,%eax
c0105cab:	01 d0                	add    %edx,%eax
c0105cad:	c1 e0 02             	shl    $0x2,%eax
c0105cb0:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105cb5:	89 08                	mov    %ecx,(%eax)
        buddy_my_merge(0);
c0105cb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105cbe:	e8 69 fc ff ff       	call   c010592c <buddy_my_merge>
    }
    cprintf("after allocate & merge\n");
c0105cc3:	c7 04 24 30 80 10 c0 	movl   $0xc0108030,(%esp)
c0105cca:	e8 c3 a5 ff ff       	call   c0100292 <cprintf>
    //bds_selfcheck();
    return page;
c0105ccf:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
c0105cd2:	c9                   	leave  
c0105cd3:	c3                   	ret    

c0105cd4 <buddy_free_page>:

static void 
buddy_free_page(struct Page* base, size_t n){
c0105cd4:	55                   	push   %ebp
c0105cd5:	89 e5                	mov    %esp,%ebp
c0105cd7:	83 ec 48             	sub    $0x48,%esp
     assert(n > 0);
c0105cda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105cde:	75 24                	jne    c0105d04 <buddy_free_page+0x30>
c0105ce0:	c7 44 24 0c 48 80 10 	movl   $0xc0108048,0xc(%esp)
c0105ce7:	c0 
c0105ce8:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c0105cef:	c0 
c0105cf0:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0105cf7:	00 
c0105cf8:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c0105cff:	e8 e5 a6 ff ff       	call   c01003e9 <__panic>
    struct Page* p = base;
c0105d04:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++) {
c0105d0a:	e9 9d 00 00 00       	jmp    c0105dac <buddy_free_page+0xd8>
        assert(!PageReserved(p) && !PageProperty(p));
c0105d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d12:	83 c0 04             	add    $0x4,%eax
c0105d15:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105d1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105d1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d22:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105d25:	0f a3 10             	bt     %edx,(%eax)
c0105d28:	19 c0                	sbb    %eax,%eax
c0105d2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0105d2d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105d31:	0f 95 c0             	setne  %al
c0105d34:	0f b6 c0             	movzbl %al,%eax
c0105d37:	85 c0                	test   %eax,%eax
c0105d39:	75 2c                	jne    c0105d67 <buddy_free_page+0x93>
c0105d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d3e:	83 c0 04             	add    $0x4,%eax
c0105d41:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0105d48:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105d4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105d4e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105d51:	0f a3 10             	bt     %edx,(%eax)
c0105d54:	19 c0                	sbb    %eax,%eax
c0105d56:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0105d59:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105d5d:	0f 95 c0             	setne  %al
c0105d60:	0f b6 c0             	movzbl %al,%eax
c0105d63:	85 c0                	test   %eax,%eax
c0105d65:	74 24                	je     c0105d8b <buddy_free_page+0xb7>
c0105d67:	c7 44 24 0c 50 80 10 	movl   $0xc0108050,0xc(%esp)
c0105d6e:	c0 
c0105d6f:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c0105d76:	c0 
c0105d77:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
c0105d7e:	00 
c0105d7f:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c0105d86:	e8 5e a6 ff ff       	call   c01003e9 <__panic>
        p->flags = 0;
c0105d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d8e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0105d95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105d9c:	00 
c0105d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105da0:	89 04 24             	mov    %eax,(%esp)
c0105da3:	e8 b8 f6 ff ff       	call   c0105460 <set_page_ref>
    for (; p != base + n; p++) {
c0105da8:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0105dac:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105daf:	89 d0                	mov    %edx,%eax
c0105db1:	c1 e0 02             	shl    $0x2,%eax
c0105db4:	01 d0                	add    %edx,%eax
c0105db6:	c1 e0 02             	shl    $0x2,%eax
c0105db9:	89 c2                	mov    %eax,%edx
c0105dbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dbe:	01 d0                	add    %edx,%eax
c0105dc0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105dc3:	0f 85 46 ff ff ff    	jne    c0105d0f <buddy_free_page+0x3b>
    }
    // free pages
    base->property = n;
c0105dc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dcc:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105dcf:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0105dd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dd5:	83 c0 04             	add    $0x4,%eax
c0105dd8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0105ddf:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105de2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105de5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105de8:	0f ab 10             	bts    %edx,(%eax)
    int level = 0;
c0105deb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    while ((1 << level) != n) { level++; }
c0105df2:	eb 03                	jmp    c0105df7 <buddy_free_page+0x123>
c0105df4:	ff 45 f0             	incl   -0x10(%ebp)
c0105df7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105dfa:	ba 01 00 00 00       	mov    $0x1,%edx
c0105dff:	88 c1                	mov    %al,%cl
c0105e01:	d3 e2                	shl    %cl,%edx
c0105e03:	89 d0                	mov    %edx,%eax
c0105e05:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0105e08:	75 ea                	jne    c0105df4 <buddy_free_page+0x120>
    buddy_my_partial(base, n, level);
c0105e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e0d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e18:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e1b:	89 04 24             	mov    %eax,(%esp)
c0105e1e:	e8 d6 f8 ff ff       	call   c01056f9 <buddy_my_partial>
    //bds_selfcheck();
    free_area[level].nr_free++;
c0105e23:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105e26:	89 d0                	mov    %edx,%eax
c0105e28:	01 c0                	add    %eax,%eax
c0105e2a:	01 d0                	add    %edx,%eax
c0105e2c:	c1 e0 02             	shl    $0x2,%eax
c0105e2f:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105e34:	8b 00                	mov    (%eax),%eax
c0105e36:	8d 48 01             	lea    0x1(%eax),%ecx
c0105e39:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105e3c:	89 d0                	mov    %edx,%eax
c0105e3e:	01 c0                	add    %eax,%eax
c0105e40:	01 d0                	add    %edx,%eax
c0105e42:	c1 e0 02             	shl    $0x2,%eax
c0105e45:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105e4a:	89 08                	mov    %ecx,(%eax)
    buddy_my_merge(level); 
c0105e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e4f:	89 04 24             	mov    %eax,(%esp)
c0105e52:	e8 d5 fa ff ff       	call   c010592c <buddy_my_merge>
    //buddy_selfcheck();
}
c0105e57:	90                   	nop
c0105e58:	c9                   	leave  
c0105e59:	c3                   	ret    

c0105e5a <buddy_check>:

static void
buddy_check(void) {
c0105e5a:	55                   	push   %ebp
c0105e5b:	89 e5                	mov    %esp,%ebp
c0105e5d:	81 ec f8 00 00 00    	sub    $0xf8,%esp
    int count = 0, total = 0;
c0105e63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105e6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) {
c0105e71:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105e78:	e9 a4 00 00 00       	jmp    c0105f21 <buddy_check+0xc7>
        list_entry_t* free_list = &(free_area[i].free_list);
c0105e7d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105e80:	89 d0                	mov    %edx,%eax
c0105e82:	01 c0                	add    %eax,%eax
c0105e84:	01 d0                	add    %edx,%eax
c0105e86:	c1 e0 02             	shl    $0x2,%eax
c0105e89:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105e8e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        list_entry_t* le = free_list;
c0105e91:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105e94:	89 45 e8             	mov    %eax,-0x18(%ebp)
        while ((le = list_next(le)) != free_list) {
c0105e97:	eb 6a                	jmp    c0105f03 <buddy_check+0xa9>
            struct Page* p = le2page(le, page_link);
c0105e99:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e9c:	83 e8 0c             	sub    $0xc,%eax
c0105e9f:	89 45 cc             	mov    %eax,-0x34(%ebp)
            assert(PageProperty(p));
c0105ea2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105ea5:	83 c0 04             	add    $0x4,%eax
c0105ea8:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0105eaf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105eb2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105eb5:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105eb8:	0f a3 10             	bt     %edx,(%eax)
c0105ebb:	19 c0                	sbb    %eax,%eax
c0105ebd:	89 45 c0             	mov    %eax,-0x40(%ebp)
    return oldbit != 0;
c0105ec0:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0105ec4:	0f 95 c0             	setne  %al
c0105ec7:	0f b6 c0             	movzbl %al,%eax
c0105eca:	85 c0                	test   %eax,%eax
c0105ecc:	75 24                	jne    c0105ef2 <buddy_check+0x98>
c0105ece:	c7 44 24 0c 75 80 10 	movl   $0xc0108075,0xc(%esp)
c0105ed5:	c0 
c0105ed6:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c0105edd:	c0 
c0105ede:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0105ee5:	00 
c0105ee6:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c0105eed:	e8 f7 a4 ff ff       	call   c01003e9 <__panic>
            count++;
c0105ef2:	ff 45 f4             	incl   -0xc(%ebp)
            total += p->property;
c0105ef5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105ef8:	8b 50 08             	mov    0x8(%eax),%edx
c0105efb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105efe:	01 d0                	add    %edx,%eax
c0105f00:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f03:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f06:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return listelm->next;
c0105f09:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105f0c:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != free_list) {
c0105f0f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105f12:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f15:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105f18:	0f 85 7b ff ff ff    	jne    c0105e99 <buddy_check+0x3f>
    for (int i = 0; i <= MAXLEVEL; i++) {
c0105f1e:	ff 45 ec             	incl   -0x14(%ebp)
c0105f21:	83 7d ec 0c          	cmpl   $0xc,-0x14(%ebp)
c0105f25:	0f 8e 52 ff ff ff    	jle    c0105e7d <buddy_check+0x23>
        }
    }
    assert(total == buddy_nr_free_page());
c0105f2b:	e8 98 f5 ff ff       	call   c01054c8 <buddy_nr_free_page>
c0105f30:	89 c2                	mov    %eax,%edx
c0105f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f35:	39 c2                	cmp    %eax,%edx
c0105f37:	74 24                	je     c0105f5d <buddy_check+0x103>
c0105f39:	c7 44 24 0c 85 80 10 	movl   $0xc0108085,0xc(%esp)
c0105f40:	c0 
c0105f41:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c0105f48:	c0 
c0105f49:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0105f50:	00 
c0105f51:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c0105f58:	e8 8c a4 ff ff       	call   c01003e9 <__panic>

    // basic check
    struct Page *p0, *p1, *p2;
    p0 = p1 =p2 = NULL;
c0105f5d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105f64:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f67:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105f6a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105f6d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("p0\n");
c0105f70:	c7 04 24 a3 80 10 c0 	movl   $0xc01080a3,(%esp)
c0105f77:	e8 16 a3 ff ff       	call   c0100292 <cprintf>
    assert((p0 = alloc_page()) != NULL);
c0105f7c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105f83:	e8 d0 cb ff ff       	call   c0102b58 <alloc_pages>
c0105f88:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105f8b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0105f8f:	75 24                	jne    c0105fb5 <buddy_check+0x15b>
c0105f91:	c7 44 24 0c a7 80 10 	movl   $0xc01080a7,0xc(%esp)
c0105f98:	c0 
c0105f99:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c0105fa0:	c0 
c0105fa1:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c0105fa8:	00 
c0105fa9:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c0105fb0:	e8 34 a4 ff ff       	call   c01003e9 <__panic>
    cprintf("p1\n");
c0105fb5:	c7 04 24 c3 80 10 c0 	movl   $0xc01080c3,(%esp)
c0105fbc:	e8 d1 a2 ff ff       	call   c0100292 <cprintf>
    assert((p1 = alloc_page()) != NULL);
c0105fc1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105fc8:	e8 8b cb ff ff       	call   c0102b58 <alloc_pages>
c0105fcd:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105fd0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105fd4:	75 24                	jne    c0105ffa <buddy_check+0x1a0>
c0105fd6:	c7 44 24 0c c7 80 10 	movl   $0xc01080c7,0xc(%esp)
c0105fdd:	c0 
c0105fde:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c0105fe5:	c0 
c0105fe6:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0105fed:	00 
c0105fee:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c0105ff5:	e8 ef a3 ff ff       	call   c01003e9 <__panic>
    cprintf("p2\n");
c0105ffa:	c7 04 24 e3 80 10 c0 	movl   $0xc01080e3,(%esp)
c0106001:	e8 8c a2 ff ff       	call   c0100292 <cprintf>
    assert((p2 = alloc_page()) != NULL);
c0106006:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010600d:	e8 46 cb ff ff       	call   c0102b58 <alloc_pages>
c0106012:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106015:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106019:	75 24                	jne    c010603f <buddy_check+0x1e5>
c010601b:	c7 44 24 0c e7 80 10 	movl   $0xc01080e7,0xc(%esp)
c0106022:	c0 
c0106023:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c010602a:	c0 
c010602b:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0106032:	00 
c0106033:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c010603a:	e8 aa a3 ff ff       	call   c01003e9 <__panic>

    assert(p0 != p1 && p1 != p2 && p2 != p0);
c010603f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106042:	3b 45 d8             	cmp    -0x28(%ebp),%eax
c0106045:	74 10                	je     c0106057 <buddy_check+0x1fd>
c0106047:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010604a:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010604d:	74 08                	je     c0106057 <buddy_check+0x1fd>
c010604f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106052:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0106055:	75 24                	jne    c010607b <buddy_check+0x221>
c0106057:	c7 44 24 0c 04 81 10 	movl   $0xc0108104,0xc(%esp)
c010605e:	c0 
c010605f:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c0106066:	c0 
c0106067:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c010606e:	00 
c010606f:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c0106076:	e8 6e a3 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010607b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010607e:	89 04 24             	mov    %eax,(%esp)
c0106081:	e8 d0 f3 ff ff       	call   c0105456 <page_ref>
c0106086:	85 c0                	test   %eax,%eax
c0106088:	75 1e                	jne    c01060a8 <buddy_check+0x24e>
c010608a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010608d:	89 04 24             	mov    %eax,(%esp)
c0106090:	e8 c1 f3 ff ff       	call   c0105456 <page_ref>
c0106095:	85 c0                	test   %eax,%eax
c0106097:	75 0f                	jne    c01060a8 <buddy_check+0x24e>
c0106099:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010609c:	89 04 24             	mov    %eax,(%esp)
c010609f:	e8 b2 f3 ff ff       	call   c0105456 <page_ref>
c01060a4:	85 c0                	test   %eax,%eax
c01060a6:	74 24                	je     c01060cc <buddy_check+0x272>
c01060a8:	c7 44 24 0c 28 81 10 	movl   $0xc0108128,0xc(%esp)
c01060af:	c0 
c01060b0:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c01060b7:	c0 
c01060b8:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c01060bf:	00 
c01060c0:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c01060c7:	e8 1d a3 ff ff       	call   c01003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01060cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01060cf:	89 04 24             	mov    %eax,(%esp)
c01060d2:	e8 69 f3 ff ff       	call   c0105440 <page2pa>
c01060d7:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c01060dd:	c1 e2 0c             	shl    $0xc,%edx
c01060e0:	39 d0                	cmp    %edx,%eax
c01060e2:	72 24                	jb     c0106108 <buddy_check+0x2ae>
c01060e4:	c7 44 24 0c 64 81 10 	movl   $0xc0108164,0xc(%esp)
c01060eb:	c0 
c01060ec:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c01060f3:	c0 
c01060f4:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c01060fb:	00 
c01060fc:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c0106103:	e8 e1 a2 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0106108:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010610b:	89 04 24             	mov    %eax,(%esp)
c010610e:	e8 2d f3 ff ff       	call   c0105440 <page2pa>
c0106113:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0106119:	c1 e2 0c             	shl    $0xc,%edx
c010611c:	39 d0                	cmp    %edx,%eax
c010611e:	72 24                	jb     c0106144 <buddy_check+0x2ea>
c0106120:	c7 44 24 0c 81 81 10 	movl   $0xc0108181,0xc(%esp)
c0106127:	c0 
c0106128:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c010612f:	c0 
c0106130:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0106137:	00 
c0106138:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c010613f:	e8 a5 a2 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0106144:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106147:	89 04 24             	mov    %eax,(%esp)
c010614a:	e8 f1 f2 ff ff       	call   c0105440 <page2pa>
c010614f:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0106155:	c1 e2 0c             	shl    $0xc,%edx
c0106158:	39 d0                	cmp    %edx,%eax
c010615a:	72 24                	jb     c0106180 <buddy_check+0x326>
c010615c:	c7 44 24 0c 9e 81 10 	movl   $0xc010819e,0xc(%esp)
c0106163:	c0 
c0106164:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c010616b:	c0 
c010616c:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0106173:	00 
c0106174:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c010617b:	e8 69 a2 ff ff       	call   c01003e9 <__panic>
    cprintf("first part of check successfully.\n");
c0106180:	c7 04 24 bc 81 10 c0 	movl   $0xc01081bc,(%esp)
c0106187:	e8 06 a1 ff ff       	call   c0100292 <cprintf>

    free_area_t temp_list[MAXLEVEL + 1];
    for (int i = 0; i <= MAXLEVEL; i++) {
c010618c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0106193:	e9 c5 00 00 00       	jmp    c010625d <buddy_check+0x403>
        temp_list[i] = free_area[i];
c0106198:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010619b:	89 d0                	mov    %edx,%eax
c010619d:	01 c0                	add    %eax,%eax
c010619f:	01 d0                	add    %edx,%eax
c01061a1:	c1 e0 02             	shl    $0x2,%eax
c01061a4:	8d 4d f8             	lea    -0x8(%ebp),%ecx
c01061a7:	01 c8                	add    %ecx,%eax
c01061a9:	8d 90 20 ff ff ff    	lea    -0xe0(%eax),%edx
c01061af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c01061b2:	89 c8                	mov    %ecx,%eax
c01061b4:	01 c0                	add    %eax,%eax
c01061b6:	01 c8                	add    %ecx,%eax
c01061b8:	c1 e0 02             	shl    $0x2,%eax
c01061bb:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01061c0:	8b 08                	mov    (%eax),%ecx
c01061c2:	89 0a                	mov    %ecx,(%edx)
c01061c4:	8b 48 04             	mov    0x4(%eax),%ecx
c01061c7:	89 4a 04             	mov    %ecx,0x4(%edx)
c01061ca:	8b 40 08             	mov    0x8(%eax),%eax
c01061cd:	89 42 08             	mov    %eax,0x8(%edx)
        list_init(&(free_area[i].free_list));
c01061d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01061d3:	89 d0                	mov    %edx,%eax
c01061d5:	01 c0                	add    %eax,%eax
c01061d7:	01 d0                	add    %edx,%eax
c01061d9:	c1 e0 02             	shl    $0x2,%eax
c01061dc:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01061e1:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    elm->prev = elm->next = elm;
c01061e4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01061e7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01061ea:	89 50 04             	mov    %edx,0x4(%eax)
c01061ed:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01061f0:	8b 50 04             	mov    0x4(%eax),%edx
c01061f3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01061f6:	89 10                	mov    %edx,(%eax)
        assert(list_empty(&(free_area[i])));
c01061f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01061fb:	89 d0                	mov    %edx,%eax
c01061fd:	01 c0                	add    %eax,%eax
c01061ff:	01 d0                	add    %edx,%eax
c0106201:	c1 e0 02             	shl    $0x2,%eax
c0106204:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0106209:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return list->next == list;
c010620c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010620f:	8b 40 04             	mov    0x4(%eax),%eax
c0106212:	39 45 b8             	cmp    %eax,-0x48(%ebp)
c0106215:	0f 94 c0             	sete   %al
c0106218:	0f b6 c0             	movzbl %al,%eax
c010621b:	85 c0                	test   %eax,%eax
c010621d:	75 24                	jne    c0106243 <buddy_check+0x3e9>
c010621f:	c7 44 24 0c df 81 10 	movl   $0xc01081df,0xc(%esp)
c0106226:	c0 
c0106227:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c010622e:	c0 
c010622f:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0106236:	00 
c0106237:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c010623e:	e8 a6 a1 ff ff       	call   c01003e9 <__panic>
        free_area[i].nr_free = 0;
c0106243:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106246:	89 d0                	mov    %edx,%eax
c0106248:	01 c0                	add    %eax,%eax
c010624a:	01 d0                	add    %edx,%eax
c010624c:	c1 e0 02             	shl    $0x2,%eax
c010624f:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0106254:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    for (int i = 0; i <= MAXLEVEL; i++) {
c010625a:	ff 45 e4             	incl   -0x1c(%ebp)
c010625d:	83 7d e4 0c          	cmpl   $0xc,-0x1c(%ebp)
c0106261:	0f 8e 31 ff ff ff    	jle    c0106198 <buddy_check+0x33e>
    }
    assert(alloc_page() == NULL);
c0106267:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010626e:	e8 e5 c8 ff ff       	call   c0102b58 <alloc_pages>
c0106273:	85 c0                	test   %eax,%eax
c0106275:	74 24                	je     c010629b <buddy_check+0x441>
c0106277:	c7 44 24 0c fb 81 10 	movl   $0xc01081fb,0xc(%esp)
c010627e:	c0 
c010627f:	c7 44 24 08 a0 7f 10 	movl   $0xc0107fa0,0x8(%esp)
c0106286:	c0 
c0106287:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c010628e:	00 
c010628f:	c7 04 24 b5 7f 10 c0 	movl   $0xc0107fb5,(%esp)
c0106296:	e8 4e a1 ff ff       	call   c01003e9 <__panic>
    cprintf("clean successfully.\n");
c010629b:	c7 04 24 10 82 10 c0 	movl   $0xc0108210,(%esp)
c01062a2:	e8 eb 9f ff ff       	call   c0100292 <cprintf>
    cprintf("p0\n");
c01062a7:	c7 04 24 a3 80 10 c0 	movl   $0xc01080a3,(%esp)
c01062ae:	e8 df 9f ff ff       	call   c0100292 <cprintf>
    free_page(p0);
c01062b3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01062ba:	00 
c01062bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01062be:	89 04 24             	mov    %eax,(%esp)
c01062c1:	e8 ca c8 ff ff       	call   c0102b90 <free_pages>
    cprintf("p1\n");
c01062c6:	c7 04 24 c3 80 10 c0 	movl   $0xc01080c3,(%esp)
c01062cd:	e8 c0 9f ff ff       	call   c0100292 <cprintf>
    free_page(p1);
c01062d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01062d9:	00 
c01062da:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01062dd:	89 04 24             	mov    %eax,(%esp)
c01062e0:	e8 ab c8 ff ff       	call   c0102b90 <free_pages>
    cprintf("p2\n");
c01062e5:	c7 04 24 e3 80 10 c0 	movl   $0xc01080e3,(%esp)
c01062ec:	e8 a1 9f ff ff       	call   c0100292 <cprintf>
    free_page(p2);
c01062f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01062f8:	00 
c01062f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01062fc:	89 04 24             	mov    %eax,(%esp)
c01062ff:	e8 8c c8 ff ff       	call   c0102b90 <free_pages>
    total = 0;
c0106304:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
c010630b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0106312:	eb 1e                	jmp    c0106332 <buddy_check+0x4d8>
        total += free_area[i].nr_free;
c0106314:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106317:	89 d0                	mov    %edx,%eax
c0106319:	01 c0                	add    %eax,%eax
c010631b:	01 d0                	add    %edx,%eax
c010631d:	c1 e0 02             	shl    $0x2,%eax
c0106320:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0106325:	8b 10                	mov    (%eax),%edx
c0106327:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010632a:	01 d0                	add    %edx,%eax
c010632c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
c010632f:	ff 45 e0             	incl   -0x20(%ebp)
c0106332:	83 7d e0 0c          	cmpl   $0xc,-0x20(%ebp)
c0106336:	7e dc                	jle    c0106314 <buddy_check+0x4ba>

    //assert((p0 = alloc_page()) != NULL);
    //assert((p1 = alloc_page()) != NULL);
    //assert((p2 = alloc_page()) != NULL);
    //assert(alloc_page() == NULL);
}
c0106338:	90                   	nop
c0106339:	c9                   	leave  
c010633a:	c3                   	ret    

c010633b <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010633b:	55                   	push   %ebp
c010633c:	89 e5                	mov    %esp,%ebp
c010633e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0106341:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0106348:	eb 03                	jmp    c010634d <strlen+0x12>
        cnt ++;
c010634a:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c010634d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106350:	8d 50 01             	lea    0x1(%eax),%edx
c0106353:	89 55 08             	mov    %edx,0x8(%ebp)
c0106356:	0f b6 00             	movzbl (%eax),%eax
c0106359:	84 c0                	test   %al,%al
c010635b:	75 ed                	jne    c010634a <strlen+0xf>
    }
    return cnt;
c010635d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0106360:	c9                   	leave  
c0106361:	c3                   	ret    

c0106362 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0106362:	55                   	push   %ebp
c0106363:	89 e5                	mov    %esp,%ebp
c0106365:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0106368:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010636f:	eb 03                	jmp    c0106374 <strnlen+0x12>
        cnt ++;
c0106371:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0106374:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106377:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010637a:	73 10                	jae    c010638c <strnlen+0x2a>
c010637c:	8b 45 08             	mov    0x8(%ebp),%eax
c010637f:	8d 50 01             	lea    0x1(%eax),%edx
c0106382:	89 55 08             	mov    %edx,0x8(%ebp)
c0106385:	0f b6 00             	movzbl (%eax),%eax
c0106388:	84 c0                	test   %al,%al
c010638a:	75 e5                	jne    c0106371 <strnlen+0xf>
    }
    return cnt;
c010638c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010638f:	c9                   	leave  
c0106390:	c3                   	ret    

c0106391 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0106391:	55                   	push   %ebp
c0106392:	89 e5                	mov    %esp,%ebp
c0106394:	57                   	push   %edi
c0106395:	56                   	push   %esi
c0106396:	83 ec 20             	sub    $0x20,%esp
c0106399:	8b 45 08             	mov    0x8(%ebp),%eax
c010639c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010639f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01063a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01063a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063ab:	89 d1                	mov    %edx,%ecx
c01063ad:	89 c2                	mov    %eax,%edx
c01063af:	89 ce                	mov    %ecx,%esi
c01063b1:	89 d7                	mov    %edx,%edi
c01063b3:	ac                   	lods   %ds:(%esi),%al
c01063b4:	aa                   	stos   %al,%es:(%edi)
c01063b5:	84 c0                	test   %al,%al
c01063b7:	75 fa                	jne    c01063b3 <strcpy+0x22>
c01063b9:	89 fa                	mov    %edi,%edx
c01063bb:	89 f1                	mov    %esi,%ecx
c01063bd:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01063c0:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01063c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01063c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c01063c9:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c01063ca:	83 c4 20             	add    $0x20,%esp
c01063cd:	5e                   	pop    %esi
c01063ce:	5f                   	pop    %edi
c01063cf:	5d                   	pop    %ebp
c01063d0:	c3                   	ret    

c01063d1 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c01063d1:	55                   	push   %ebp
c01063d2:	89 e5                	mov    %esp,%ebp
c01063d4:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c01063d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01063da:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c01063dd:	eb 1e                	jmp    c01063fd <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c01063df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063e2:	0f b6 10             	movzbl (%eax),%edx
c01063e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01063e8:	88 10                	mov    %dl,(%eax)
c01063ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01063ed:	0f b6 00             	movzbl (%eax),%eax
c01063f0:	84 c0                	test   %al,%al
c01063f2:	74 03                	je     c01063f7 <strncpy+0x26>
            src ++;
c01063f4:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c01063f7:	ff 45 fc             	incl   -0x4(%ebp)
c01063fa:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c01063fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106401:	75 dc                	jne    c01063df <strncpy+0xe>
    }
    return dst;
c0106403:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106406:	c9                   	leave  
c0106407:	c3                   	ret    

c0106408 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0106408:	55                   	push   %ebp
c0106409:	89 e5                	mov    %esp,%ebp
c010640b:	57                   	push   %edi
c010640c:	56                   	push   %esi
c010640d:	83 ec 20             	sub    $0x20,%esp
c0106410:	8b 45 08             	mov    0x8(%ebp),%eax
c0106413:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106416:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106419:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010641c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010641f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106422:	89 d1                	mov    %edx,%ecx
c0106424:	89 c2                	mov    %eax,%edx
c0106426:	89 ce                	mov    %ecx,%esi
c0106428:	89 d7                	mov    %edx,%edi
c010642a:	ac                   	lods   %ds:(%esi),%al
c010642b:	ae                   	scas   %es:(%edi),%al
c010642c:	75 08                	jne    c0106436 <strcmp+0x2e>
c010642e:	84 c0                	test   %al,%al
c0106430:	75 f8                	jne    c010642a <strcmp+0x22>
c0106432:	31 c0                	xor    %eax,%eax
c0106434:	eb 04                	jmp    c010643a <strcmp+0x32>
c0106436:	19 c0                	sbb    %eax,%eax
c0106438:	0c 01                	or     $0x1,%al
c010643a:	89 fa                	mov    %edi,%edx
c010643c:	89 f1                	mov    %esi,%ecx
c010643e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106441:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106444:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0106447:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c010644a:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010644b:	83 c4 20             	add    $0x20,%esp
c010644e:	5e                   	pop    %esi
c010644f:	5f                   	pop    %edi
c0106450:	5d                   	pop    %ebp
c0106451:	c3                   	ret    

c0106452 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0106452:	55                   	push   %ebp
c0106453:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106455:	eb 09                	jmp    c0106460 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0106457:	ff 4d 10             	decl   0x10(%ebp)
c010645a:	ff 45 08             	incl   0x8(%ebp)
c010645d:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106460:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106464:	74 1a                	je     c0106480 <strncmp+0x2e>
c0106466:	8b 45 08             	mov    0x8(%ebp),%eax
c0106469:	0f b6 00             	movzbl (%eax),%eax
c010646c:	84 c0                	test   %al,%al
c010646e:	74 10                	je     c0106480 <strncmp+0x2e>
c0106470:	8b 45 08             	mov    0x8(%ebp),%eax
c0106473:	0f b6 10             	movzbl (%eax),%edx
c0106476:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106479:	0f b6 00             	movzbl (%eax),%eax
c010647c:	38 c2                	cmp    %al,%dl
c010647e:	74 d7                	je     c0106457 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0106480:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106484:	74 18                	je     c010649e <strncmp+0x4c>
c0106486:	8b 45 08             	mov    0x8(%ebp),%eax
c0106489:	0f b6 00             	movzbl (%eax),%eax
c010648c:	0f b6 d0             	movzbl %al,%edx
c010648f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106492:	0f b6 00             	movzbl (%eax),%eax
c0106495:	0f b6 c0             	movzbl %al,%eax
c0106498:	29 c2                	sub    %eax,%edx
c010649a:	89 d0                	mov    %edx,%eax
c010649c:	eb 05                	jmp    c01064a3 <strncmp+0x51>
c010649e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01064a3:	5d                   	pop    %ebp
c01064a4:	c3                   	ret    

c01064a5 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c01064a5:	55                   	push   %ebp
c01064a6:	89 e5                	mov    %esp,%ebp
c01064a8:	83 ec 04             	sub    $0x4,%esp
c01064ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064ae:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01064b1:	eb 13                	jmp    c01064c6 <strchr+0x21>
        if (*s == c) {
c01064b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01064b6:	0f b6 00             	movzbl (%eax),%eax
c01064b9:	38 45 fc             	cmp    %al,-0x4(%ebp)
c01064bc:	75 05                	jne    c01064c3 <strchr+0x1e>
            return (char *)s;
c01064be:	8b 45 08             	mov    0x8(%ebp),%eax
c01064c1:	eb 12                	jmp    c01064d5 <strchr+0x30>
        }
        s ++;
c01064c3:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c01064c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01064c9:	0f b6 00             	movzbl (%eax),%eax
c01064cc:	84 c0                	test   %al,%al
c01064ce:	75 e3                	jne    c01064b3 <strchr+0xe>
    }
    return NULL;
c01064d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01064d5:	c9                   	leave  
c01064d6:	c3                   	ret    

c01064d7 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c01064d7:	55                   	push   %ebp
c01064d8:	89 e5                	mov    %esp,%ebp
c01064da:	83 ec 04             	sub    $0x4,%esp
c01064dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064e0:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01064e3:	eb 0e                	jmp    c01064f3 <strfind+0x1c>
        if (*s == c) {
c01064e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01064e8:	0f b6 00             	movzbl (%eax),%eax
c01064eb:	38 45 fc             	cmp    %al,-0x4(%ebp)
c01064ee:	74 0f                	je     c01064ff <strfind+0x28>
            break;
        }
        s ++;
c01064f0:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c01064f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01064f6:	0f b6 00             	movzbl (%eax),%eax
c01064f9:	84 c0                	test   %al,%al
c01064fb:	75 e8                	jne    c01064e5 <strfind+0xe>
c01064fd:	eb 01                	jmp    c0106500 <strfind+0x29>
            break;
c01064ff:	90                   	nop
    }
    return (char *)s;
c0106500:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106503:	c9                   	leave  
c0106504:	c3                   	ret    

c0106505 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0106505:	55                   	push   %ebp
c0106506:	89 e5                	mov    %esp,%ebp
c0106508:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010650b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0106512:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0106519:	eb 03                	jmp    c010651e <strtol+0x19>
        s ++;
c010651b:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010651e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106521:	0f b6 00             	movzbl (%eax),%eax
c0106524:	3c 20                	cmp    $0x20,%al
c0106526:	74 f3                	je     c010651b <strtol+0x16>
c0106528:	8b 45 08             	mov    0x8(%ebp),%eax
c010652b:	0f b6 00             	movzbl (%eax),%eax
c010652e:	3c 09                	cmp    $0x9,%al
c0106530:	74 e9                	je     c010651b <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0106532:	8b 45 08             	mov    0x8(%ebp),%eax
c0106535:	0f b6 00             	movzbl (%eax),%eax
c0106538:	3c 2b                	cmp    $0x2b,%al
c010653a:	75 05                	jne    c0106541 <strtol+0x3c>
        s ++;
c010653c:	ff 45 08             	incl   0x8(%ebp)
c010653f:	eb 14                	jmp    c0106555 <strtol+0x50>
    }
    else if (*s == '-') {
c0106541:	8b 45 08             	mov    0x8(%ebp),%eax
c0106544:	0f b6 00             	movzbl (%eax),%eax
c0106547:	3c 2d                	cmp    $0x2d,%al
c0106549:	75 0a                	jne    c0106555 <strtol+0x50>
        s ++, neg = 1;
c010654b:	ff 45 08             	incl   0x8(%ebp)
c010654e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0106555:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106559:	74 06                	je     c0106561 <strtol+0x5c>
c010655b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010655f:	75 22                	jne    c0106583 <strtol+0x7e>
c0106561:	8b 45 08             	mov    0x8(%ebp),%eax
c0106564:	0f b6 00             	movzbl (%eax),%eax
c0106567:	3c 30                	cmp    $0x30,%al
c0106569:	75 18                	jne    c0106583 <strtol+0x7e>
c010656b:	8b 45 08             	mov    0x8(%ebp),%eax
c010656e:	40                   	inc    %eax
c010656f:	0f b6 00             	movzbl (%eax),%eax
c0106572:	3c 78                	cmp    $0x78,%al
c0106574:	75 0d                	jne    c0106583 <strtol+0x7e>
        s += 2, base = 16;
c0106576:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010657a:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0106581:	eb 29                	jmp    c01065ac <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0106583:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106587:	75 16                	jne    c010659f <strtol+0x9a>
c0106589:	8b 45 08             	mov    0x8(%ebp),%eax
c010658c:	0f b6 00             	movzbl (%eax),%eax
c010658f:	3c 30                	cmp    $0x30,%al
c0106591:	75 0c                	jne    c010659f <strtol+0x9a>
        s ++, base = 8;
c0106593:	ff 45 08             	incl   0x8(%ebp)
c0106596:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010659d:	eb 0d                	jmp    c01065ac <strtol+0xa7>
    }
    else if (base == 0) {
c010659f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01065a3:	75 07                	jne    c01065ac <strtol+0xa7>
        base = 10;
c01065a5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c01065ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01065af:	0f b6 00             	movzbl (%eax),%eax
c01065b2:	3c 2f                	cmp    $0x2f,%al
c01065b4:	7e 1b                	jle    c01065d1 <strtol+0xcc>
c01065b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01065b9:	0f b6 00             	movzbl (%eax),%eax
c01065bc:	3c 39                	cmp    $0x39,%al
c01065be:	7f 11                	jg     c01065d1 <strtol+0xcc>
            dig = *s - '0';
c01065c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01065c3:	0f b6 00             	movzbl (%eax),%eax
c01065c6:	0f be c0             	movsbl %al,%eax
c01065c9:	83 e8 30             	sub    $0x30,%eax
c01065cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01065cf:	eb 48                	jmp    c0106619 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c01065d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01065d4:	0f b6 00             	movzbl (%eax),%eax
c01065d7:	3c 60                	cmp    $0x60,%al
c01065d9:	7e 1b                	jle    c01065f6 <strtol+0xf1>
c01065db:	8b 45 08             	mov    0x8(%ebp),%eax
c01065de:	0f b6 00             	movzbl (%eax),%eax
c01065e1:	3c 7a                	cmp    $0x7a,%al
c01065e3:	7f 11                	jg     c01065f6 <strtol+0xf1>
            dig = *s - 'a' + 10;
c01065e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01065e8:	0f b6 00             	movzbl (%eax),%eax
c01065eb:	0f be c0             	movsbl %al,%eax
c01065ee:	83 e8 57             	sub    $0x57,%eax
c01065f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01065f4:	eb 23                	jmp    c0106619 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c01065f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01065f9:	0f b6 00             	movzbl (%eax),%eax
c01065fc:	3c 40                	cmp    $0x40,%al
c01065fe:	7e 3b                	jle    c010663b <strtol+0x136>
c0106600:	8b 45 08             	mov    0x8(%ebp),%eax
c0106603:	0f b6 00             	movzbl (%eax),%eax
c0106606:	3c 5a                	cmp    $0x5a,%al
c0106608:	7f 31                	jg     c010663b <strtol+0x136>
            dig = *s - 'A' + 10;
c010660a:	8b 45 08             	mov    0x8(%ebp),%eax
c010660d:	0f b6 00             	movzbl (%eax),%eax
c0106610:	0f be c0             	movsbl %al,%eax
c0106613:	83 e8 37             	sub    $0x37,%eax
c0106616:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0106619:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010661c:	3b 45 10             	cmp    0x10(%ebp),%eax
c010661f:	7d 19                	jge    c010663a <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0106621:	ff 45 08             	incl   0x8(%ebp)
c0106624:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106627:	0f af 45 10          	imul   0x10(%ebp),%eax
c010662b:	89 c2                	mov    %eax,%edx
c010662d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106630:	01 d0                	add    %edx,%eax
c0106632:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0106635:	e9 72 ff ff ff       	jmp    c01065ac <strtol+0xa7>
            break;
c010663a:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c010663b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010663f:	74 08                	je     c0106649 <strtol+0x144>
        *endptr = (char *) s;
c0106641:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106644:	8b 55 08             	mov    0x8(%ebp),%edx
c0106647:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0106649:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010664d:	74 07                	je     c0106656 <strtol+0x151>
c010664f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106652:	f7 d8                	neg    %eax
c0106654:	eb 03                	jmp    c0106659 <strtol+0x154>
c0106656:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0106659:	c9                   	leave  
c010665a:	c3                   	ret    

c010665b <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010665b:	55                   	push   %ebp
c010665c:	89 e5                	mov    %esp,%ebp
c010665e:	57                   	push   %edi
c010665f:	83 ec 24             	sub    $0x24,%esp
c0106662:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106665:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0106668:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010666c:	8b 55 08             	mov    0x8(%ebp),%edx
c010666f:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0106672:	88 45 f7             	mov    %al,-0x9(%ebp)
c0106675:	8b 45 10             	mov    0x10(%ebp),%eax
c0106678:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010667b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010667e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0106682:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0106685:	89 d7                	mov    %edx,%edi
c0106687:	f3 aa                	rep stos %al,%es:(%edi)
c0106689:	89 fa                	mov    %edi,%edx
c010668b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010668e:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0106691:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106694:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0106695:	83 c4 24             	add    $0x24,%esp
c0106698:	5f                   	pop    %edi
c0106699:	5d                   	pop    %ebp
c010669a:	c3                   	ret    

c010669b <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010669b:	55                   	push   %ebp
c010669c:	89 e5                	mov    %esp,%ebp
c010669e:	57                   	push   %edi
c010669f:	56                   	push   %esi
c01066a0:	53                   	push   %ebx
c01066a1:	83 ec 30             	sub    $0x30,%esp
c01066a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01066a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01066aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01066ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01066b0:	8b 45 10             	mov    0x10(%ebp),%eax
c01066b3:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c01066b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066b9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01066bc:	73 42                	jae    c0106700 <memmove+0x65>
c01066be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01066c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01066c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01066ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01066cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01066d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01066d3:	c1 e8 02             	shr    $0x2,%eax
c01066d6:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01066d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01066db:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01066de:	89 d7                	mov    %edx,%edi
c01066e0:	89 c6                	mov    %eax,%esi
c01066e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01066e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01066e7:	83 e1 03             	and    $0x3,%ecx
c01066ea:	74 02                	je     c01066ee <memmove+0x53>
c01066ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01066ee:	89 f0                	mov    %esi,%eax
c01066f0:	89 fa                	mov    %edi,%edx
c01066f2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c01066f5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01066f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c01066fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c01066fe:	eb 36                	jmp    c0106736 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0106700:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106703:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106706:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106709:	01 c2                	add    %eax,%edx
c010670b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010670e:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0106711:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106714:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0106717:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010671a:	89 c1                	mov    %eax,%ecx
c010671c:	89 d8                	mov    %ebx,%eax
c010671e:	89 d6                	mov    %edx,%esi
c0106720:	89 c7                	mov    %eax,%edi
c0106722:	fd                   	std    
c0106723:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106725:	fc                   	cld    
c0106726:	89 f8                	mov    %edi,%eax
c0106728:	89 f2                	mov    %esi,%edx
c010672a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010672d:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106730:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0106733:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0106736:	83 c4 30             	add    $0x30,%esp
c0106739:	5b                   	pop    %ebx
c010673a:	5e                   	pop    %esi
c010673b:	5f                   	pop    %edi
c010673c:	5d                   	pop    %ebp
c010673d:	c3                   	ret    

c010673e <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010673e:	55                   	push   %ebp
c010673f:	89 e5                	mov    %esp,%ebp
c0106741:	57                   	push   %edi
c0106742:	56                   	push   %esi
c0106743:	83 ec 20             	sub    $0x20,%esp
c0106746:	8b 45 08             	mov    0x8(%ebp),%eax
c0106749:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010674c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010674f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106752:	8b 45 10             	mov    0x10(%ebp),%eax
c0106755:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106758:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010675b:	c1 e8 02             	shr    $0x2,%eax
c010675e:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0106760:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106763:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106766:	89 d7                	mov    %edx,%edi
c0106768:	89 c6                	mov    %eax,%esi
c010676a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010676c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010676f:	83 e1 03             	and    $0x3,%ecx
c0106772:	74 02                	je     c0106776 <memcpy+0x38>
c0106774:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106776:	89 f0                	mov    %esi,%eax
c0106778:	89 fa                	mov    %edi,%edx
c010677a:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010677d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0106780:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0106783:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0106786:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0106787:	83 c4 20             	add    $0x20,%esp
c010678a:	5e                   	pop    %esi
c010678b:	5f                   	pop    %edi
c010678c:	5d                   	pop    %ebp
c010678d:	c3                   	ret    

c010678e <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010678e:	55                   	push   %ebp
c010678f:	89 e5                	mov    %esp,%ebp
c0106791:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0106794:	8b 45 08             	mov    0x8(%ebp),%eax
c0106797:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010679a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010679d:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c01067a0:	eb 2e                	jmp    c01067d0 <memcmp+0x42>
        if (*s1 != *s2) {
c01067a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01067a5:	0f b6 10             	movzbl (%eax),%edx
c01067a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01067ab:	0f b6 00             	movzbl (%eax),%eax
c01067ae:	38 c2                	cmp    %al,%dl
c01067b0:	74 18                	je     c01067ca <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c01067b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01067b5:	0f b6 00             	movzbl (%eax),%eax
c01067b8:	0f b6 d0             	movzbl %al,%edx
c01067bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01067be:	0f b6 00             	movzbl (%eax),%eax
c01067c1:	0f b6 c0             	movzbl %al,%eax
c01067c4:	29 c2                	sub    %eax,%edx
c01067c6:	89 d0                	mov    %edx,%eax
c01067c8:	eb 18                	jmp    c01067e2 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c01067ca:	ff 45 fc             	incl   -0x4(%ebp)
c01067cd:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c01067d0:	8b 45 10             	mov    0x10(%ebp),%eax
c01067d3:	8d 50 ff             	lea    -0x1(%eax),%edx
c01067d6:	89 55 10             	mov    %edx,0x10(%ebp)
c01067d9:	85 c0                	test   %eax,%eax
c01067db:	75 c5                	jne    c01067a2 <memcmp+0x14>
    }
    return 0;
c01067dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01067e2:	c9                   	leave  
c01067e3:	c3                   	ret    

c01067e4 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01067e4:	55                   	push   %ebp
c01067e5:	89 e5                	mov    %esp,%ebp
c01067e7:	83 ec 58             	sub    $0x58,%esp
c01067ea:	8b 45 10             	mov    0x10(%ebp),%eax
c01067ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01067f0:	8b 45 14             	mov    0x14(%ebp),%eax
c01067f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01067f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01067f9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01067fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01067ff:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0106802:	8b 45 18             	mov    0x18(%ebp),%eax
c0106805:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106808:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010680b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010680e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106811:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0106814:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106817:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010681a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010681e:	74 1c                	je     c010683c <printnum+0x58>
c0106820:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106823:	ba 00 00 00 00       	mov    $0x0,%edx
c0106828:	f7 75 e4             	divl   -0x1c(%ebp)
c010682b:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010682e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106831:	ba 00 00 00 00       	mov    $0x0,%edx
c0106836:	f7 75 e4             	divl   -0x1c(%ebp)
c0106839:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010683c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010683f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106842:	f7 75 e4             	divl   -0x1c(%ebp)
c0106845:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106848:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010684b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010684e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106851:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106854:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0106857:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010685a:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010685d:	8b 45 18             	mov    0x18(%ebp),%eax
c0106860:	ba 00 00 00 00       	mov    $0x0,%edx
c0106865:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0106868:	72 56                	jb     c01068c0 <printnum+0xdc>
c010686a:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c010686d:	77 05                	ja     c0106874 <printnum+0x90>
c010686f:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0106872:	72 4c                	jb     c01068c0 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0106874:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106877:	8d 50 ff             	lea    -0x1(%eax),%edx
c010687a:	8b 45 20             	mov    0x20(%ebp),%eax
c010687d:	89 44 24 18          	mov    %eax,0x18(%esp)
c0106881:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106885:	8b 45 18             	mov    0x18(%ebp),%eax
c0106888:	89 44 24 10          	mov    %eax,0x10(%esp)
c010688c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010688f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106892:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106896:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010689a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010689d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01068a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01068a4:	89 04 24             	mov    %eax,(%esp)
c01068a7:	e8 38 ff ff ff       	call   c01067e4 <printnum>
c01068ac:	eb 1b                	jmp    c01068c9 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01068ae:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01068b5:	8b 45 20             	mov    0x20(%ebp),%eax
c01068b8:	89 04 24             	mov    %eax,(%esp)
c01068bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01068be:	ff d0                	call   *%eax
        while (-- width > 0)
c01068c0:	ff 4d 1c             	decl   0x1c(%ebp)
c01068c3:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01068c7:	7f e5                	jg     c01068ae <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01068c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01068cc:	05 d0 82 10 c0       	add    $0xc01082d0,%eax
c01068d1:	0f b6 00             	movzbl (%eax),%eax
c01068d4:	0f be c0             	movsbl %al,%eax
c01068d7:	8b 55 0c             	mov    0xc(%ebp),%edx
c01068da:	89 54 24 04          	mov    %edx,0x4(%esp)
c01068de:	89 04 24             	mov    %eax,(%esp)
c01068e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01068e4:	ff d0                	call   *%eax
}
c01068e6:	90                   	nop
c01068e7:	c9                   	leave  
c01068e8:	c3                   	ret    

c01068e9 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01068e9:	55                   	push   %ebp
c01068ea:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01068ec:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01068f0:	7e 14                	jle    c0106906 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01068f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01068f5:	8b 00                	mov    (%eax),%eax
c01068f7:	8d 48 08             	lea    0x8(%eax),%ecx
c01068fa:	8b 55 08             	mov    0x8(%ebp),%edx
c01068fd:	89 0a                	mov    %ecx,(%edx)
c01068ff:	8b 50 04             	mov    0x4(%eax),%edx
c0106902:	8b 00                	mov    (%eax),%eax
c0106904:	eb 30                	jmp    c0106936 <getuint+0x4d>
    }
    else if (lflag) {
c0106906:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010690a:	74 16                	je     c0106922 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010690c:	8b 45 08             	mov    0x8(%ebp),%eax
c010690f:	8b 00                	mov    (%eax),%eax
c0106911:	8d 48 04             	lea    0x4(%eax),%ecx
c0106914:	8b 55 08             	mov    0x8(%ebp),%edx
c0106917:	89 0a                	mov    %ecx,(%edx)
c0106919:	8b 00                	mov    (%eax),%eax
c010691b:	ba 00 00 00 00       	mov    $0x0,%edx
c0106920:	eb 14                	jmp    c0106936 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0106922:	8b 45 08             	mov    0x8(%ebp),%eax
c0106925:	8b 00                	mov    (%eax),%eax
c0106927:	8d 48 04             	lea    0x4(%eax),%ecx
c010692a:	8b 55 08             	mov    0x8(%ebp),%edx
c010692d:	89 0a                	mov    %ecx,(%edx)
c010692f:	8b 00                	mov    (%eax),%eax
c0106931:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0106936:	5d                   	pop    %ebp
c0106937:	c3                   	ret    

c0106938 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0106938:	55                   	push   %ebp
c0106939:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010693b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010693f:	7e 14                	jle    c0106955 <getint+0x1d>
        return va_arg(*ap, long long);
c0106941:	8b 45 08             	mov    0x8(%ebp),%eax
c0106944:	8b 00                	mov    (%eax),%eax
c0106946:	8d 48 08             	lea    0x8(%eax),%ecx
c0106949:	8b 55 08             	mov    0x8(%ebp),%edx
c010694c:	89 0a                	mov    %ecx,(%edx)
c010694e:	8b 50 04             	mov    0x4(%eax),%edx
c0106951:	8b 00                	mov    (%eax),%eax
c0106953:	eb 28                	jmp    c010697d <getint+0x45>
    }
    else if (lflag) {
c0106955:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106959:	74 12                	je     c010696d <getint+0x35>
        return va_arg(*ap, long);
c010695b:	8b 45 08             	mov    0x8(%ebp),%eax
c010695e:	8b 00                	mov    (%eax),%eax
c0106960:	8d 48 04             	lea    0x4(%eax),%ecx
c0106963:	8b 55 08             	mov    0x8(%ebp),%edx
c0106966:	89 0a                	mov    %ecx,(%edx)
c0106968:	8b 00                	mov    (%eax),%eax
c010696a:	99                   	cltd   
c010696b:	eb 10                	jmp    c010697d <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010696d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106970:	8b 00                	mov    (%eax),%eax
c0106972:	8d 48 04             	lea    0x4(%eax),%ecx
c0106975:	8b 55 08             	mov    0x8(%ebp),%edx
c0106978:	89 0a                	mov    %ecx,(%edx)
c010697a:	8b 00                	mov    (%eax),%eax
c010697c:	99                   	cltd   
    }
}
c010697d:	5d                   	pop    %ebp
c010697e:	c3                   	ret    

c010697f <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010697f:	55                   	push   %ebp
c0106980:	89 e5                	mov    %esp,%ebp
c0106982:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0106985:	8d 45 14             	lea    0x14(%ebp),%eax
c0106988:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010698b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010698e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106992:	8b 45 10             	mov    0x10(%ebp),%eax
c0106995:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106999:	8b 45 0c             	mov    0xc(%ebp),%eax
c010699c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01069a3:	89 04 24             	mov    %eax,(%esp)
c01069a6:	e8 03 00 00 00       	call   c01069ae <vprintfmt>
    va_end(ap);
}
c01069ab:	90                   	nop
c01069ac:	c9                   	leave  
c01069ad:	c3                   	ret    

c01069ae <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c01069ae:	55                   	push   %ebp
c01069af:	89 e5                	mov    %esp,%ebp
c01069b1:	56                   	push   %esi
c01069b2:	53                   	push   %ebx
c01069b3:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01069b6:	eb 17                	jmp    c01069cf <vprintfmt+0x21>
            if (ch == '\0') {
c01069b8:	85 db                	test   %ebx,%ebx
c01069ba:	0f 84 bf 03 00 00    	je     c0106d7f <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c01069c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069c3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069c7:	89 1c 24             	mov    %ebx,(%esp)
c01069ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01069cd:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01069cf:	8b 45 10             	mov    0x10(%ebp),%eax
c01069d2:	8d 50 01             	lea    0x1(%eax),%edx
c01069d5:	89 55 10             	mov    %edx,0x10(%ebp)
c01069d8:	0f b6 00             	movzbl (%eax),%eax
c01069db:	0f b6 d8             	movzbl %al,%ebx
c01069de:	83 fb 25             	cmp    $0x25,%ebx
c01069e1:	75 d5                	jne    c01069b8 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c01069e3:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01069e7:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01069ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01069f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01069f4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01069fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01069fe:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0106a01:	8b 45 10             	mov    0x10(%ebp),%eax
c0106a04:	8d 50 01             	lea    0x1(%eax),%edx
c0106a07:	89 55 10             	mov    %edx,0x10(%ebp)
c0106a0a:	0f b6 00             	movzbl (%eax),%eax
c0106a0d:	0f b6 d8             	movzbl %al,%ebx
c0106a10:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0106a13:	83 f8 55             	cmp    $0x55,%eax
c0106a16:	0f 87 37 03 00 00    	ja     c0106d53 <vprintfmt+0x3a5>
c0106a1c:	8b 04 85 f4 82 10 c0 	mov    -0x3fef7d0c(,%eax,4),%eax
c0106a23:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0106a25:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0106a29:	eb d6                	jmp    c0106a01 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0106a2b:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0106a2f:	eb d0                	jmp    c0106a01 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0106a31:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0106a38:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106a3b:	89 d0                	mov    %edx,%eax
c0106a3d:	c1 e0 02             	shl    $0x2,%eax
c0106a40:	01 d0                	add    %edx,%eax
c0106a42:	01 c0                	add    %eax,%eax
c0106a44:	01 d8                	add    %ebx,%eax
c0106a46:	83 e8 30             	sub    $0x30,%eax
c0106a49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0106a4c:	8b 45 10             	mov    0x10(%ebp),%eax
c0106a4f:	0f b6 00             	movzbl (%eax),%eax
c0106a52:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0106a55:	83 fb 2f             	cmp    $0x2f,%ebx
c0106a58:	7e 38                	jle    c0106a92 <vprintfmt+0xe4>
c0106a5a:	83 fb 39             	cmp    $0x39,%ebx
c0106a5d:	7f 33                	jg     c0106a92 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c0106a5f:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0106a62:	eb d4                	jmp    c0106a38 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0106a64:	8b 45 14             	mov    0x14(%ebp),%eax
c0106a67:	8d 50 04             	lea    0x4(%eax),%edx
c0106a6a:	89 55 14             	mov    %edx,0x14(%ebp)
c0106a6d:	8b 00                	mov    (%eax),%eax
c0106a6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0106a72:	eb 1f                	jmp    c0106a93 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0106a74:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106a78:	79 87                	jns    c0106a01 <vprintfmt+0x53>
                width = 0;
c0106a7a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0106a81:	e9 7b ff ff ff       	jmp    c0106a01 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0106a86:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0106a8d:	e9 6f ff ff ff       	jmp    c0106a01 <vprintfmt+0x53>
            goto process_precision;
c0106a92:	90                   	nop

        process_precision:
            if (width < 0)
c0106a93:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106a97:	0f 89 64 ff ff ff    	jns    c0106a01 <vprintfmt+0x53>
                width = precision, precision = -1;
c0106a9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106aa0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106aa3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0106aaa:	e9 52 ff ff ff       	jmp    c0106a01 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0106aaf:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0106ab2:	e9 4a ff ff ff       	jmp    c0106a01 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0106ab7:	8b 45 14             	mov    0x14(%ebp),%eax
c0106aba:	8d 50 04             	lea    0x4(%eax),%edx
c0106abd:	89 55 14             	mov    %edx,0x14(%ebp)
c0106ac0:	8b 00                	mov    (%eax),%eax
c0106ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106ac5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106ac9:	89 04 24             	mov    %eax,(%esp)
c0106acc:	8b 45 08             	mov    0x8(%ebp),%eax
c0106acf:	ff d0                	call   *%eax
            break;
c0106ad1:	e9 a4 02 00 00       	jmp    c0106d7a <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0106ad6:	8b 45 14             	mov    0x14(%ebp),%eax
c0106ad9:	8d 50 04             	lea    0x4(%eax),%edx
c0106adc:	89 55 14             	mov    %edx,0x14(%ebp)
c0106adf:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0106ae1:	85 db                	test   %ebx,%ebx
c0106ae3:	79 02                	jns    c0106ae7 <vprintfmt+0x139>
                err = -err;
c0106ae5:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0106ae7:	83 fb 06             	cmp    $0x6,%ebx
c0106aea:	7f 0b                	jg     c0106af7 <vprintfmt+0x149>
c0106aec:	8b 34 9d b4 82 10 c0 	mov    -0x3fef7d4c(,%ebx,4),%esi
c0106af3:	85 f6                	test   %esi,%esi
c0106af5:	75 23                	jne    c0106b1a <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0106af7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106afb:	c7 44 24 08 e1 82 10 	movl   $0xc01082e1,0x8(%esp)
c0106b02:	c0 
c0106b03:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b06:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b0d:	89 04 24             	mov    %eax,(%esp)
c0106b10:	e8 6a fe ff ff       	call   c010697f <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0106b15:	e9 60 02 00 00       	jmp    c0106d7a <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c0106b1a:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0106b1e:	c7 44 24 08 ea 82 10 	movl   $0xc01082ea,0x8(%esp)
c0106b25:	c0 
c0106b26:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b30:	89 04 24             	mov    %eax,(%esp)
c0106b33:	e8 47 fe ff ff       	call   c010697f <printfmt>
            break;
c0106b38:	e9 3d 02 00 00       	jmp    c0106d7a <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0106b3d:	8b 45 14             	mov    0x14(%ebp),%eax
c0106b40:	8d 50 04             	lea    0x4(%eax),%edx
c0106b43:	89 55 14             	mov    %edx,0x14(%ebp)
c0106b46:	8b 30                	mov    (%eax),%esi
c0106b48:	85 f6                	test   %esi,%esi
c0106b4a:	75 05                	jne    c0106b51 <vprintfmt+0x1a3>
                p = "(null)";
c0106b4c:	be ed 82 10 c0       	mov    $0xc01082ed,%esi
            }
            if (width > 0 && padc != '-') {
c0106b51:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106b55:	7e 76                	jle    c0106bcd <vprintfmt+0x21f>
c0106b57:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0106b5b:	74 70                	je     c0106bcd <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106b5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b60:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b64:	89 34 24             	mov    %esi,(%esp)
c0106b67:	e8 f6 f7 ff ff       	call   c0106362 <strnlen>
c0106b6c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106b6f:	29 c2                	sub    %eax,%edx
c0106b71:	89 d0                	mov    %edx,%eax
c0106b73:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106b76:	eb 16                	jmp    c0106b8e <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0106b78:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0106b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106b7f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106b83:	89 04 24             	mov    %eax,(%esp)
c0106b86:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b89:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106b8b:	ff 4d e8             	decl   -0x18(%ebp)
c0106b8e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106b92:	7f e4                	jg     c0106b78 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106b94:	eb 37                	jmp    c0106bcd <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0106b96:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106b9a:	74 1f                	je     c0106bbb <vprintfmt+0x20d>
c0106b9c:	83 fb 1f             	cmp    $0x1f,%ebx
c0106b9f:	7e 05                	jle    c0106ba6 <vprintfmt+0x1f8>
c0106ba1:	83 fb 7e             	cmp    $0x7e,%ebx
c0106ba4:	7e 15                	jle    c0106bbb <vprintfmt+0x20d>
                    putch('?', putdat);
c0106ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ba9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bad:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0106bb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bb7:	ff d0                	call   *%eax
c0106bb9:	eb 0f                	jmp    c0106bca <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0106bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bc2:	89 1c 24             	mov    %ebx,(%esp)
c0106bc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bc8:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106bca:	ff 4d e8             	decl   -0x18(%ebp)
c0106bcd:	89 f0                	mov    %esi,%eax
c0106bcf:	8d 70 01             	lea    0x1(%eax),%esi
c0106bd2:	0f b6 00             	movzbl (%eax),%eax
c0106bd5:	0f be d8             	movsbl %al,%ebx
c0106bd8:	85 db                	test   %ebx,%ebx
c0106bda:	74 27                	je     c0106c03 <vprintfmt+0x255>
c0106bdc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106be0:	78 b4                	js     c0106b96 <vprintfmt+0x1e8>
c0106be2:	ff 4d e4             	decl   -0x1c(%ebp)
c0106be5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106be9:	79 ab                	jns    c0106b96 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0106beb:	eb 16                	jmp    c0106c03 <vprintfmt+0x255>
                putch(' ', putdat);
c0106bed:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bf0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bf4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0106bfb:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bfe:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0106c00:	ff 4d e8             	decl   -0x18(%ebp)
c0106c03:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106c07:	7f e4                	jg     c0106bed <vprintfmt+0x23f>
            }
            break;
c0106c09:	e9 6c 01 00 00       	jmp    c0106d7a <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0106c0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106c11:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c15:	8d 45 14             	lea    0x14(%ebp),%eax
c0106c18:	89 04 24             	mov    %eax,(%esp)
c0106c1b:	e8 18 fd ff ff       	call   c0106938 <getint>
c0106c20:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c23:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0106c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c29:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106c2c:	85 d2                	test   %edx,%edx
c0106c2e:	79 26                	jns    c0106c56 <vprintfmt+0x2a8>
                putch('-', putdat);
c0106c30:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c33:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c37:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0106c3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c41:	ff d0                	call   *%eax
                num = -(long long)num;
c0106c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c46:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106c49:	f7 d8                	neg    %eax
c0106c4b:	83 d2 00             	adc    $0x0,%edx
c0106c4e:	f7 da                	neg    %edx
c0106c50:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c53:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0106c56:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106c5d:	e9 a8 00 00 00       	jmp    c0106d0a <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0106c62:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106c65:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c69:	8d 45 14             	lea    0x14(%ebp),%eax
c0106c6c:	89 04 24             	mov    %eax,(%esp)
c0106c6f:	e8 75 fc ff ff       	call   c01068e9 <getuint>
c0106c74:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c77:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0106c7a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106c81:	e9 84 00 00 00       	jmp    c0106d0a <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0106c86:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106c89:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c8d:	8d 45 14             	lea    0x14(%ebp),%eax
c0106c90:	89 04 24             	mov    %eax,(%esp)
c0106c93:	e8 51 fc ff ff       	call   c01068e9 <getuint>
c0106c98:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c9b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0106c9e:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0106ca5:	eb 63                	jmp    c0106d0a <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0106ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106caa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106cae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0106cb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cb8:	ff d0                	call   *%eax
            putch('x', putdat);
c0106cba:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106cc1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0106cc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ccb:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0106ccd:	8b 45 14             	mov    0x14(%ebp),%eax
c0106cd0:	8d 50 04             	lea    0x4(%eax),%edx
c0106cd3:	89 55 14             	mov    %edx,0x14(%ebp)
c0106cd6:	8b 00                	mov    (%eax),%eax
c0106cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106cdb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0106ce2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0106ce9:	eb 1f                	jmp    c0106d0a <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0106ceb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106cee:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106cf2:	8d 45 14             	lea    0x14(%ebp),%eax
c0106cf5:	89 04 24             	mov    %eax,(%esp)
c0106cf8:	e8 ec fb ff ff       	call   c01068e9 <getuint>
c0106cfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106d00:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0106d03:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0106d0a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0106d0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d11:	89 54 24 18          	mov    %edx,0x18(%esp)
c0106d15:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106d18:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106d1c:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d23:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106d26:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106d2a:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d35:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d38:	89 04 24             	mov    %eax,(%esp)
c0106d3b:	e8 a4 fa ff ff       	call   c01067e4 <printnum>
            break;
c0106d40:	eb 38                	jmp    c0106d7a <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0106d42:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d45:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d49:	89 1c 24             	mov    %ebx,(%esp)
c0106d4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d4f:	ff d0                	call   *%eax
            break;
c0106d51:	eb 27                	jmp    c0106d7a <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0106d53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d5a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0106d61:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d64:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0106d66:	ff 4d 10             	decl   0x10(%ebp)
c0106d69:	eb 03                	jmp    c0106d6e <vprintfmt+0x3c0>
c0106d6b:	ff 4d 10             	decl   0x10(%ebp)
c0106d6e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106d71:	48                   	dec    %eax
c0106d72:	0f b6 00             	movzbl (%eax),%eax
c0106d75:	3c 25                	cmp    $0x25,%al
c0106d77:	75 f2                	jne    c0106d6b <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0106d79:	90                   	nop
    while (1) {
c0106d7a:	e9 37 fc ff ff       	jmp    c01069b6 <vprintfmt+0x8>
                return;
c0106d7f:	90                   	nop
        }
    }
}
c0106d80:	83 c4 40             	add    $0x40,%esp
c0106d83:	5b                   	pop    %ebx
c0106d84:	5e                   	pop    %esi
c0106d85:	5d                   	pop    %ebp
c0106d86:	c3                   	ret    

c0106d87 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0106d87:	55                   	push   %ebp
c0106d88:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0106d8a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d8d:	8b 40 08             	mov    0x8(%eax),%eax
c0106d90:	8d 50 01             	lea    0x1(%eax),%edx
c0106d93:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d96:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106d99:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d9c:	8b 10                	mov    (%eax),%edx
c0106d9e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106da1:	8b 40 04             	mov    0x4(%eax),%eax
c0106da4:	39 c2                	cmp    %eax,%edx
c0106da6:	73 12                	jae    c0106dba <sprintputch+0x33>
        *b->buf ++ = ch;
c0106da8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106dab:	8b 00                	mov    (%eax),%eax
c0106dad:	8d 48 01             	lea    0x1(%eax),%ecx
c0106db0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106db3:	89 0a                	mov    %ecx,(%edx)
c0106db5:	8b 55 08             	mov    0x8(%ebp),%edx
c0106db8:	88 10                	mov    %dl,(%eax)
    }
}
c0106dba:	90                   	nop
c0106dbb:	5d                   	pop    %ebp
c0106dbc:	c3                   	ret    

c0106dbd <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0106dbd:	55                   	push   %ebp
c0106dbe:	89 e5                	mov    %esp,%ebp
c0106dc0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0106dc3:	8d 45 14             	lea    0x14(%ebp),%eax
c0106dc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0106dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106dcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106dd0:	8b 45 10             	mov    0x10(%ebp),%eax
c0106dd3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106dda:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106dde:	8b 45 08             	mov    0x8(%ebp),%eax
c0106de1:	89 04 24             	mov    %eax,(%esp)
c0106de4:	e8 08 00 00 00       	call   c0106df1 <vsnprintf>
c0106de9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0106dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106def:	c9                   	leave  
c0106df0:	c3                   	ret    

c0106df1 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0106df1:	55                   	push   %ebp
c0106df2:	89 e5                	mov    %esp,%ebp
c0106df4:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0106df7:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dfa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e00:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106e03:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e06:	01 d0                	add    %edx,%eax
c0106e08:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106e0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0106e12:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106e16:	74 0a                	je     c0106e22 <vsnprintf+0x31>
c0106e18:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e1e:	39 c2                	cmp    %eax,%edx
c0106e20:	76 07                	jbe    c0106e29 <vsnprintf+0x38>
        return -E_INVAL;
c0106e22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0106e27:	eb 2a                	jmp    c0106e53 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0106e29:	8b 45 14             	mov    0x14(%ebp),%eax
c0106e2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106e30:	8b 45 10             	mov    0x10(%ebp),%eax
c0106e33:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106e37:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0106e3a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106e3e:	c7 04 24 87 6d 10 c0 	movl   $0xc0106d87,(%esp)
c0106e45:	e8 64 fb ff ff       	call   c01069ae <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0106e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e4d:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0106e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106e53:	c9                   	leave  
c0106e54:	c3                   	ret    
