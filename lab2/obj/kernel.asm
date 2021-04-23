
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
c010005d:	e8 b7 64 00 00       	call   c0106519 <memset>

    cons_init();                // init the console
c0100062:	e8 80 15 00 00       	call   c01015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 20 6d 10 c0 	movl   $0xc0106d20,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 3c 6d 10 c0 	movl   $0xc0106d3c,(%esp)
c010007c:	e8 11 02 00 00       	call   c0100292 <cprintf>

    print_kerninfo();
c0100081:	e8 b2 08 00 00       	call   c0100938 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 89 00 00 00       	call   c0100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 8b 30 00 00       	call   c010311b <pmm_init>

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
c0100162:	c7 04 24 41 6d 10 c0 	movl   $0xc0106d41,(%esp)
c0100169:	e8 24 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100172:	89 c2                	mov    %eax,%edx
c0100174:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 4f 6d 10 c0 	movl   $0xc0106d4f,(%esp)
c0100188:	e8 05 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	89 c2                	mov    %eax,%edx
c0100193:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c0100198:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a0:	c7 04 24 5d 6d 10 c0 	movl   $0xc0106d5d,(%esp)
c01001a7:	e8 e6 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b0:	89 c2                	mov    %eax,%edx
c01001b2:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bf:	c7 04 24 6b 6d 10 c0 	movl   $0xc0106d6b,(%esp)
c01001c6:	e8 c7 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001cf:	89 c2                	mov    %eax,%edx
c01001d1:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001de:	c7 04 24 79 6d 10 c0 	movl   $0xc0106d79,(%esp)
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
c010020f:	c7 04 24 88 6d 10 c0 	movl   $0xc0106d88,(%esp)
c0100216:	e8 77 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_user();
c010021b:	e8 d8 ff ff ff       	call   c01001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100220:	e8 15 ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100225:	c7 04 24 a8 6d 10 c0 	movl   $0xc0106da8,(%esp)
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
c0100288:	e8 df 65 00 00       	call   c010686c <vprintfmt>
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
c0100347:	c7 04 24 c7 6d 10 c0 	movl   $0xc0106dc7,(%esp)
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
c0100416:	c7 04 24 ca 6d 10 c0 	movl   $0xc0106dca,(%esp)
c010041d:	e8 70 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c0100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100425:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100429:	8b 45 10             	mov    0x10(%ebp),%eax
c010042c:	89 04 24             	mov    %eax,(%esp)
c010042f:	e8 2b fe ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c0100434:	c7 04 24 e6 6d 10 c0 	movl   $0xc0106de6,(%esp)
c010043b:	e8 52 fe ff ff       	call   c0100292 <cprintf>
    
    cprintf("stack trackback:\n");
c0100440:	c7 04 24 e8 6d 10 c0 	movl   $0xc0106de8,(%esp)
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
c0100481:	c7 04 24 fa 6d 10 c0 	movl   $0xc0106dfa,(%esp)
c0100488:	e8 05 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c010048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100490:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100494:	8b 45 10             	mov    0x10(%ebp),%eax
c0100497:	89 04 24             	mov    %eax,(%esp)
c010049a:	e8 c0 fd ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c010049f:	c7 04 24 e6 6d 10 c0 	movl   $0xc0106de6,(%esp)
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
c010060f:	c7 00 18 6e 10 c0    	movl   $0xc0106e18,(%eax)
    info->eip_line = 0;
c0100615:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010061f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100622:	c7 40 08 18 6e 10 c0 	movl   $0xc0106e18,0x8(%eax)
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
c0100646:	c7 45 f4 0c 83 10 c0 	movl   $0xc010830c,-0xc(%ebp)
    stab_end = __STAB_END__;
c010064d:	c7 45 f0 ec 4a 11 c0 	movl   $0xc0114aec,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100654:	c7 45 ec ed 4a 11 c0 	movl   $0xc0114aed,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010065b:	c7 45 e8 c0 77 11 c0 	movl   $0xc01177c0,-0x18(%ebp)

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
c01007b6:	e8 da 5b 00 00       	call   c0106395 <strfind>
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
c010093e:	c7 04 24 22 6e 10 c0 	movl   $0xc0106e22,(%esp)
c0100945:	e8 48 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010094a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100951:	c0 
c0100952:	c7 04 24 3b 6e 10 c0 	movl   $0xc0106e3b,(%esp)
c0100959:	e8 34 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010095e:	c7 44 24 04 13 6d 10 	movl   $0xc0106d13,0x4(%esp)
c0100965:	c0 
c0100966:	c7 04 24 53 6e 10 c0 	movl   $0xc0106e53,(%esp)
c010096d:	e8 20 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100972:	c7 44 24 04 00 d0 11 	movl   $0xc011d000,0x4(%esp)
c0100979:	c0 
c010097a:	c7 04 24 6b 6e 10 c0 	movl   $0xc0106e6b,(%esp)
c0100981:	e8 0c f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100986:	c7 44 24 04 bc df 11 	movl   $0xc011dfbc,0x4(%esp)
c010098d:	c0 
c010098e:	c7 04 24 83 6e 10 c0 	movl   $0xc0106e83,(%esp)
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
c01009c0:	c7 04 24 9c 6e 10 c0 	movl   $0xc0106e9c,(%esp)
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
c01009f5:	c7 04 24 c6 6e 10 c0 	movl   $0xc0106ec6,(%esp)
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
c0100a63:	c7 04 24 e2 6e 10 c0 	movl   $0xc0106ee2,(%esp)
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
c0100ab6:	c7 04 24 f4 6e 10 c0 	movl   $0xc0106ef4,(%esp)
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
c0100ae9:	c7 04 24 10 6f 10 c0 	movl   $0xc0106f10,(%esp)
c0100af0:	e8 9d f7 ff ff       	call   c0100292 <cprintf>
		for(int i=0;i<4;i++){
c0100af5:	ff 45 e8             	incl   -0x18(%ebp)
c0100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100afc:	7e d6                	jle    c0100ad4 <print_stackframe+0x51>
		}
		cprintf("\n");
c0100afe:	c7 04 24 18 6f 10 c0 	movl   $0xc0106f18,(%esp)
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
c0100b71:	c7 04 24 9c 6f 10 c0 	movl   $0xc0106f9c,(%esp)
c0100b78:	e8 e6 57 00 00       	call   c0106363 <strchr>
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
c0100b99:	c7 04 24 a1 6f 10 c0 	movl   $0xc0106fa1,(%esp)
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
c0100bdb:	c7 04 24 9c 6f 10 c0 	movl   $0xc0106f9c,(%esp)
c0100be2:	e8 7c 57 00 00       	call   c0106363 <strchr>
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
c0100c48:	e8 79 56 00 00       	call   c01062c6 <strcmp>
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
c0100c94:	c7 04 24 bf 6f 10 c0 	movl   $0xc0106fbf,(%esp)
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
c0100cb1:	c7 04 24 d8 6f 10 c0 	movl   $0xc0106fd8,(%esp)
c0100cb8:	e8 d5 f5 ff ff       	call   c0100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cbd:	c7 04 24 00 70 10 c0 	movl   $0xc0107000,(%esp)
c0100cc4:	e8 c9 f5 ff ff       	call   c0100292 <cprintf>

    if (tf != NULL) {
c0100cc9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100ccd:	74 0b                	je     c0100cda <kmonitor+0x2f>
        print_trapframe(tf);
c0100ccf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cd2:	89 04 24             	mov    %eax,(%esp)
c0100cd5:	e8 10 0d 00 00       	call   c01019ea <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cda:	c7 04 24 25 70 10 c0 	movl   $0xc0107025,(%esp)
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
c0100d48:	c7 04 24 29 70 10 c0 	movl   $0xc0107029,(%esp)
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
c0100dd3:	c7 04 24 32 70 10 c0 	movl   $0xc0107032,(%esp)
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
c0101215:	e8 3f 53 00 00       	call   c0106559 <memmove>
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
c0101595:	c7 04 24 4d 70 10 c0 	movl   $0xc010704d,(%esp)
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
c0101605:	c7 04 24 59 70 10 c0 	movl   $0xc0107059,(%esp)
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
c01018a2:	c7 04 24 80 70 10 c0 	movl   $0xc0107080,(%esp)
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
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	for(int i=0;i<256;i++){
c01018b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018be:	e9 c4 00 00 00       	jmp    c0101987 <idt_init+0xd6>
		SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL)
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
	for(int i=0;i<256;i++){
c0101984:	ff 45 fc             	incl   -0x4(%ebp)
c0101987:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c010198e:	0f 8e 2f ff ff ff    	jle    c01018c3 <idt_init+0x12>
c0101994:	c7 45 f8 60 a5 11 c0 	movl   $0xc011a560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010199b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010199e:	0f 01 18             	lidtl  (%eax)
	}
	lidt(&idt_pd);
}
c01019a1:	90                   	nop
c01019a2:	c9                   	leave  
c01019a3:	c3                   	ret    

c01019a4 <trapname>:

static const char *
trapname(int trapno) {
c01019a4:	55                   	push   %ebp
c01019a5:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01019a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01019aa:	83 f8 13             	cmp    $0x13,%eax
c01019ad:	77 0c                	ja     c01019bb <trapname+0x17>
        return excnames[trapno];
c01019af:	8b 45 08             	mov    0x8(%ebp),%eax
c01019b2:	8b 04 85 e0 73 10 c0 	mov    -0x3fef8c20(,%eax,4),%eax
c01019b9:	eb 18                	jmp    c01019d3 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01019bb:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01019bf:	7e 0d                	jle    c01019ce <trapname+0x2a>
c01019c1:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01019c5:	7f 07                	jg     c01019ce <trapname+0x2a>
        return "Hardware Interrupt";
c01019c7:	b8 8a 70 10 c0       	mov    $0xc010708a,%eax
c01019cc:	eb 05                	jmp    c01019d3 <trapname+0x2f>
    }
    return "(unknown trap)";
c01019ce:	b8 9d 70 10 c0       	mov    $0xc010709d,%eax
}
c01019d3:	5d                   	pop    %ebp
c01019d4:	c3                   	ret    

c01019d5 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01019d5:	55                   	push   %ebp
c01019d6:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01019d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01019db:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01019df:	83 f8 08             	cmp    $0x8,%eax
c01019e2:	0f 94 c0             	sete   %al
c01019e5:	0f b6 c0             	movzbl %al,%eax
}
c01019e8:	5d                   	pop    %ebp
c01019e9:	c3                   	ret    

c01019ea <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01019ea:	55                   	push   %ebp
c01019eb:	89 e5                	mov    %esp,%ebp
c01019ed:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01019f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01019f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019f7:	c7 04 24 de 70 10 c0 	movl   $0xc01070de,(%esp)
c01019fe:	e8 8f e8 ff ff       	call   c0100292 <cprintf>
    print_regs(&tf->tf_regs);
c0101a03:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a06:	89 04 24             	mov    %eax,(%esp)
c0101a09:	e8 8f 01 00 00       	call   c0101b9d <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a11:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a19:	c7 04 24 ef 70 10 c0 	movl   $0xc01070ef,(%esp)
c0101a20:	e8 6d e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a28:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a30:	c7 04 24 02 71 10 c0 	movl   $0xc0107102,(%esp)
c0101a37:	e8 56 e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a3f:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101a43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a47:	c7 04 24 15 71 10 c0 	movl   $0xc0107115,(%esp)
c0101a4e:	e8 3f e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101a53:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a56:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a5e:	c7 04 24 28 71 10 c0 	movl   $0xc0107128,(%esp)
c0101a65:	e8 28 e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101a6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a6d:	8b 40 30             	mov    0x30(%eax),%eax
c0101a70:	89 04 24             	mov    %eax,(%esp)
c0101a73:	e8 2c ff ff ff       	call   c01019a4 <trapname>
c0101a78:	89 c2                	mov    %eax,%edx
c0101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a7d:	8b 40 30             	mov    0x30(%eax),%eax
c0101a80:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101a84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a88:	c7 04 24 3b 71 10 c0 	movl   $0xc010713b,(%esp)
c0101a8f:	e8 fe e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101a94:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a97:	8b 40 34             	mov    0x34(%eax),%eax
c0101a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a9e:	c7 04 24 4d 71 10 c0 	movl   $0xc010714d,(%esp)
c0101aa5:	e8 e8 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101aaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aad:	8b 40 38             	mov    0x38(%eax),%eax
c0101ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ab4:	c7 04 24 5c 71 10 c0 	movl   $0xc010715c,(%esp)
c0101abb:	e8 d2 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101ac0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101acb:	c7 04 24 6b 71 10 c0 	movl   $0xc010716b,(%esp)
c0101ad2:	e8 bb e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ada:	8b 40 40             	mov    0x40(%eax),%eax
c0101add:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae1:	c7 04 24 7e 71 10 c0 	movl   $0xc010717e,(%esp)
c0101ae8:	e8 a5 e7 ff ff       	call   c0100292 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101aed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101af4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101afb:	eb 3d                	jmp    c0101b3a <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101afd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b00:	8b 50 40             	mov    0x40(%eax),%edx
c0101b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b06:	21 d0                	and    %edx,%eax
c0101b08:	85 c0                	test   %eax,%eax
c0101b0a:	74 28                	je     c0101b34 <print_trapframe+0x14a>
c0101b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b0f:	8b 04 85 80 a5 11 c0 	mov    -0x3fee5a80(,%eax,4),%eax
c0101b16:	85 c0                	test   %eax,%eax
c0101b18:	74 1a                	je     c0101b34 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0101b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b1d:	8b 04 85 80 a5 11 c0 	mov    -0x3fee5a80(,%eax,4),%eax
c0101b24:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b28:	c7 04 24 8d 71 10 c0 	movl   $0xc010718d,(%esp)
c0101b2f:	e8 5e e7 ff ff       	call   c0100292 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b34:	ff 45 f4             	incl   -0xc(%ebp)
c0101b37:	d1 65 f0             	shll   -0x10(%ebp)
c0101b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b3d:	83 f8 17             	cmp    $0x17,%eax
c0101b40:	76 bb                	jbe    c0101afd <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101b42:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b45:	8b 40 40             	mov    0x40(%eax),%eax
c0101b48:	c1 e8 0c             	shr    $0xc,%eax
c0101b4b:	83 e0 03             	and    $0x3,%eax
c0101b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b52:	c7 04 24 91 71 10 c0 	movl   $0xc0107191,(%esp)
c0101b59:	e8 34 e7 ff ff       	call   c0100292 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101b5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b61:	89 04 24             	mov    %eax,(%esp)
c0101b64:	e8 6c fe ff ff       	call   c01019d5 <trap_in_kernel>
c0101b69:	85 c0                	test   %eax,%eax
c0101b6b:	75 2d                	jne    c0101b9a <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b70:	8b 40 44             	mov    0x44(%eax),%eax
c0101b73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b77:	c7 04 24 9a 71 10 c0 	movl   $0xc010719a,(%esp)
c0101b7e:	e8 0f e7 ff ff       	call   c0100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101b83:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b86:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b8e:	c7 04 24 a9 71 10 c0 	movl   $0xc01071a9,(%esp)
c0101b95:	e8 f8 e6 ff ff       	call   c0100292 <cprintf>
    }
}
c0101b9a:	90                   	nop
c0101b9b:	c9                   	leave  
c0101b9c:	c3                   	ret    

c0101b9d <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101b9d:	55                   	push   %ebp
c0101b9e:	89 e5                	mov    %esp,%ebp
c0101ba0:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba6:	8b 00                	mov    (%eax),%eax
c0101ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bac:	c7 04 24 bc 71 10 c0 	movl   $0xc01071bc,(%esp)
c0101bb3:	e8 da e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101bb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bbb:	8b 40 04             	mov    0x4(%eax),%eax
c0101bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bc2:	c7 04 24 cb 71 10 c0 	movl   $0xc01071cb,(%esp)
c0101bc9:	e8 c4 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101bce:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd1:	8b 40 08             	mov    0x8(%eax),%eax
c0101bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bd8:	c7 04 24 da 71 10 c0 	movl   $0xc01071da,(%esp)
c0101bdf:	e8 ae e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101be4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be7:	8b 40 0c             	mov    0xc(%eax),%eax
c0101bea:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bee:	c7 04 24 e9 71 10 c0 	movl   $0xc01071e9,(%esp)
c0101bf5:	e8 98 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bfd:	8b 40 10             	mov    0x10(%eax),%eax
c0101c00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c04:	c7 04 24 f8 71 10 c0 	movl   $0xc01071f8,(%esp)
c0101c0b:	e8 82 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c10:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c13:	8b 40 14             	mov    0x14(%eax),%eax
c0101c16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c1a:	c7 04 24 07 72 10 c0 	movl   $0xc0107207,(%esp)
c0101c21:	e8 6c e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c26:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c29:	8b 40 18             	mov    0x18(%eax),%eax
c0101c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c30:	c7 04 24 16 72 10 c0 	movl   $0xc0107216,(%esp)
c0101c37:	e8 56 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101c3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c3f:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101c42:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c46:	c7 04 24 25 72 10 c0 	movl   $0xc0107225,(%esp)
c0101c4d:	e8 40 e6 ff ff       	call   c0100292 <cprintf>
}
c0101c52:	90                   	nop
c0101c53:	c9                   	leave  
c0101c54:	c3                   	ret    

c0101c55 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101c55:	55                   	push   %ebp
c0101c56:	89 e5                	mov    %esp,%ebp
c0101c58:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c5e:	8b 40 30             	mov    0x30(%eax),%eax
c0101c61:	83 f8 2f             	cmp    $0x2f,%eax
c0101c64:	77 21                	ja     c0101c87 <trap_dispatch+0x32>
c0101c66:	83 f8 2e             	cmp    $0x2e,%eax
c0101c69:	0f 83 0c 01 00 00    	jae    c0101d7b <trap_dispatch+0x126>
c0101c6f:	83 f8 21             	cmp    $0x21,%eax
c0101c72:	0f 84 8c 00 00 00    	je     c0101d04 <trap_dispatch+0xaf>
c0101c78:	83 f8 24             	cmp    $0x24,%eax
c0101c7b:	74 61                	je     c0101cde <trap_dispatch+0x89>
c0101c7d:	83 f8 20             	cmp    $0x20,%eax
c0101c80:	74 16                	je     c0101c98 <trap_dispatch+0x43>
c0101c82:	e9 bf 00 00 00       	jmp    c0101d46 <trap_dispatch+0xf1>
c0101c87:	83 e8 78             	sub    $0x78,%eax
c0101c8a:	83 f8 01             	cmp    $0x1,%eax
c0101c8d:	0f 87 b3 00 00 00    	ja     c0101d46 <trap_dispatch+0xf1>
c0101c93:	e9 92 00 00 00       	jmp    c0101d2a <trap_dispatch+0xd5>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	ticks+=1;
c0101c98:	a1 0c df 11 c0       	mov    0xc011df0c,%eax
c0101c9d:	40                   	inc    %eax
c0101c9e:	a3 0c df 11 c0       	mov    %eax,0xc011df0c
	if(ticks%TICK_NUM==0){
c0101ca3:	8b 0d 0c df 11 c0    	mov    0xc011df0c,%ecx
c0101ca9:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101cae:	89 c8                	mov    %ecx,%eax
c0101cb0:	f7 e2                	mul    %edx
c0101cb2:	c1 ea 05             	shr    $0x5,%edx
c0101cb5:	89 d0                	mov    %edx,%eax
c0101cb7:	c1 e0 02             	shl    $0x2,%eax
c0101cba:	01 d0                	add    %edx,%eax
c0101cbc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101cc3:	01 d0                	add    %edx,%eax
c0101cc5:	c1 e0 02             	shl    $0x2,%eax
c0101cc8:	29 c1                	sub    %eax,%ecx
c0101cca:	89 ca                	mov    %ecx,%edx
c0101ccc:	85 d2                	test   %edx,%edx
c0101cce:	0f 85 aa 00 00 00    	jne    c0101d7e <trap_dispatch+0x129>
		print_ticks();	
c0101cd4:	e8 bb fb ff ff       	call   c0101894 <print_ticks>
	}
        break;
c0101cd9:	e9 a0 00 00 00       	jmp    c0101d7e <trap_dispatch+0x129>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101cde:	e8 6e f9 ff ff       	call   c0101651 <cons_getc>
c0101ce3:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101ce6:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101cea:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101cee:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cf6:	c7 04 24 34 72 10 c0 	movl   $0xc0107234,(%esp)
c0101cfd:	e8 90 e5 ff ff       	call   c0100292 <cprintf>
        break;
c0101d02:	eb 7b                	jmp    c0101d7f <trap_dispatch+0x12a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d04:	e8 48 f9 ff ff       	call   c0101651 <cons_getc>
c0101d09:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d0c:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d10:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d14:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d18:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d1c:	c7 04 24 46 72 10 c0 	movl   $0xc0107246,(%esp)
c0101d23:	e8 6a e5 ff ff       	call   c0100292 <cprintf>
        break;
c0101d28:	eb 55                	jmp    c0101d7f <trap_dispatch+0x12a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101d2a:	c7 44 24 08 55 72 10 	movl   $0xc0107255,0x8(%esp)
c0101d31:	c0 
c0101d32:	c7 44 24 04 ab 00 00 	movl   $0xab,0x4(%esp)
c0101d39:	00 
c0101d3a:	c7 04 24 65 72 10 c0 	movl   $0xc0107265,(%esp)
c0101d41:	e8 a3 e6 ff ff       	call   c01003e9 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101d46:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d49:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101d4d:	83 e0 03             	and    $0x3,%eax
c0101d50:	85 c0                	test   %eax,%eax
c0101d52:	75 2b                	jne    c0101d7f <trap_dispatch+0x12a>
            print_trapframe(tf);
c0101d54:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d57:	89 04 24             	mov    %eax,(%esp)
c0101d5a:	e8 8b fc ff ff       	call   c01019ea <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101d5f:	c7 44 24 08 76 72 10 	movl   $0xc0107276,0x8(%esp)
c0101d66:	c0 
c0101d67:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c0101d6e:	00 
c0101d6f:	c7 04 24 65 72 10 c0 	movl   $0xc0107265,(%esp)
c0101d76:	e8 6e e6 ff ff       	call   c01003e9 <__panic>
        break;
c0101d7b:	90                   	nop
c0101d7c:	eb 01                	jmp    c0101d7f <trap_dispatch+0x12a>
        break;
c0101d7e:	90                   	nop
        }
    }
}
c0101d7f:	90                   	nop
c0101d80:	c9                   	leave  
c0101d81:	c3                   	ret    

c0101d82 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101d82:	55                   	push   %ebp
c0101d83:	89 e5                	mov    %esp,%ebp
c0101d85:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101d88:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d8b:	89 04 24             	mov    %eax,(%esp)
c0101d8e:	e8 c2 fe ff ff       	call   c0101c55 <trap_dispatch>
}
c0101d93:	90                   	nop
c0101d94:	c9                   	leave  
c0101d95:	c3                   	ret    

c0101d96 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101d96:	6a 00                	push   $0x0
  pushl $0
c0101d98:	6a 00                	push   $0x0
  jmp __alltraps
c0101d9a:	e9 69 0a 00 00       	jmp    c0102808 <__alltraps>

c0101d9f <vector1>:
.globl vector1
vector1:
  pushl $0
c0101d9f:	6a 00                	push   $0x0
  pushl $1
c0101da1:	6a 01                	push   $0x1
  jmp __alltraps
c0101da3:	e9 60 0a 00 00       	jmp    c0102808 <__alltraps>

c0101da8 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101da8:	6a 00                	push   $0x0
  pushl $2
c0101daa:	6a 02                	push   $0x2
  jmp __alltraps
c0101dac:	e9 57 0a 00 00       	jmp    c0102808 <__alltraps>

c0101db1 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101db1:	6a 00                	push   $0x0
  pushl $3
c0101db3:	6a 03                	push   $0x3
  jmp __alltraps
c0101db5:	e9 4e 0a 00 00       	jmp    c0102808 <__alltraps>

c0101dba <vector4>:
.globl vector4
vector4:
  pushl $0
c0101dba:	6a 00                	push   $0x0
  pushl $4
c0101dbc:	6a 04                	push   $0x4
  jmp __alltraps
c0101dbe:	e9 45 0a 00 00       	jmp    c0102808 <__alltraps>

c0101dc3 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101dc3:	6a 00                	push   $0x0
  pushl $5
c0101dc5:	6a 05                	push   $0x5
  jmp __alltraps
c0101dc7:	e9 3c 0a 00 00       	jmp    c0102808 <__alltraps>

c0101dcc <vector6>:
.globl vector6
vector6:
  pushl $0
c0101dcc:	6a 00                	push   $0x0
  pushl $6
c0101dce:	6a 06                	push   $0x6
  jmp __alltraps
c0101dd0:	e9 33 0a 00 00       	jmp    c0102808 <__alltraps>

c0101dd5 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101dd5:	6a 00                	push   $0x0
  pushl $7
c0101dd7:	6a 07                	push   $0x7
  jmp __alltraps
c0101dd9:	e9 2a 0a 00 00       	jmp    c0102808 <__alltraps>

c0101dde <vector8>:
.globl vector8
vector8:
  pushl $8
c0101dde:	6a 08                	push   $0x8
  jmp __alltraps
c0101de0:	e9 23 0a 00 00       	jmp    c0102808 <__alltraps>

c0101de5 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101de5:	6a 00                	push   $0x0
  pushl $9
c0101de7:	6a 09                	push   $0x9
  jmp __alltraps
c0101de9:	e9 1a 0a 00 00       	jmp    c0102808 <__alltraps>

c0101dee <vector10>:
.globl vector10
vector10:
  pushl $10
c0101dee:	6a 0a                	push   $0xa
  jmp __alltraps
c0101df0:	e9 13 0a 00 00       	jmp    c0102808 <__alltraps>

c0101df5 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101df5:	6a 0b                	push   $0xb
  jmp __alltraps
c0101df7:	e9 0c 0a 00 00       	jmp    c0102808 <__alltraps>

c0101dfc <vector12>:
.globl vector12
vector12:
  pushl $12
c0101dfc:	6a 0c                	push   $0xc
  jmp __alltraps
c0101dfe:	e9 05 0a 00 00       	jmp    c0102808 <__alltraps>

c0101e03 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e03:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e05:	e9 fe 09 00 00       	jmp    c0102808 <__alltraps>

c0101e0a <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e0a:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e0c:	e9 f7 09 00 00       	jmp    c0102808 <__alltraps>

c0101e11 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e11:	6a 00                	push   $0x0
  pushl $15
c0101e13:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e15:	e9 ee 09 00 00       	jmp    c0102808 <__alltraps>

c0101e1a <vector16>:
.globl vector16
vector16:
  pushl $0
c0101e1a:	6a 00                	push   $0x0
  pushl $16
c0101e1c:	6a 10                	push   $0x10
  jmp __alltraps
c0101e1e:	e9 e5 09 00 00       	jmp    c0102808 <__alltraps>

c0101e23 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101e23:	6a 11                	push   $0x11
  jmp __alltraps
c0101e25:	e9 de 09 00 00       	jmp    c0102808 <__alltraps>

c0101e2a <vector18>:
.globl vector18
vector18:
  pushl $0
c0101e2a:	6a 00                	push   $0x0
  pushl $18
c0101e2c:	6a 12                	push   $0x12
  jmp __alltraps
c0101e2e:	e9 d5 09 00 00       	jmp    c0102808 <__alltraps>

c0101e33 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101e33:	6a 00                	push   $0x0
  pushl $19
c0101e35:	6a 13                	push   $0x13
  jmp __alltraps
c0101e37:	e9 cc 09 00 00       	jmp    c0102808 <__alltraps>

c0101e3c <vector20>:
.globl vector20
vector20:
  pushl $0
c0101e3c:	6a 00                	push   $0x0
  pushl $20
c0101e3e:	6a 14                	push   $0x14
  jmp __alltraps
c0101e40:	e9 c3 09 00 00       	jmp    c0102808 <__alltraps>

c0101e45 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101e45:	6a 00                	push   $0x0
  pushl $21
c0101e47:	6a 15                	push   $0x15
  jmp __alltraps
c0101e49:	e9 ba 09 00 00       	jmp    c0102808 <__alltraps>

c0101e4e <vector22>:
.globl vector22
vector22:
  pushl $0
c0101e4e:	6a 00                	push   $0x0
  pushl $22
c0101e50:	6a 16                	push   $0x16
  jmp __alltraps
c0101e52:	e9 b1 09 00 00       	jmp    c0102808 <__alltraps>

c0101e57 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101e57:	6a 00                	push   $0x0
  pushl $23
c0101e59:	6a 17                	push   $0x17
  jmp __alltraps
c0101e5b:	e9 a8 09 00 00       	jmp    c0102808 <__alltraps>

c0101e60 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101e60:	6a 00                	push   $0x0
  pushl $24
c0101e62:	6a 18                	push   $0x18
  jmp __alltraps
c0101e64:	e9 9f 09 00 00       	jmp    c0102808 <__alltraps>

c0101e69 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101e69:	6a 00                	push   $0x0
  pushl $25
c0101e6b:	6a 19                	push   $0x19
  jmp __alltraps
c0101e6d:	e9 96 09 00 00       	jmp    c0102808 <__alltraps>

c0101e72 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101e72:	6a 00                	push   $0x0
  pushl $26
c0101e74:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101e76:	e9 8d 09 00 00       	jmp    c0102808 <__alltraps>

c0101e7b <vector27>:
.globl vector27
vector27:
  pushl $0
c0101e7b:	6a 00                	push   $0x0
  pushl $27
c0101e7d:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101e7f:	e9 84 09 00 00       	jmp    c0102808 <__alltraps>

c0101e84 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101e84:	6a 00                	push   $0x0
  pushl $28
c0101e86:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101e88:	e9 7b 09 00 00       	jmp    c0102808 <__alltraps>

c0101e8d <vector29>:
.globl vector29
vector29:
  pushl $0
c0101e8d:	6a 00                	push   $0x0
  pushl $29
c0101e8f:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101e91:	e9 72 09 00 00       	jmp    c0102808 <__alltraps>

c0101e96 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101e96:	6a 00                	push   $0x0
  pushl $30
c0101e98:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101e9a:	e9 69 09 00 00       	jmp    c0102808 <__alltraps>

c0101e9f <vector31>:
.globl vector31
vector31:
  pushl $0
c0101e9f:	6a 00                	push   $0x0
  pushl $31
c0101ea1:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101ea3:	e9 60 09 00 00       	jmp    c0102808 <__alltraps>

c0101ea8 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101ea8:	6a 00                	push   $0x0
  pushl $32
c0101eaa:	6a 20                	push   $0x20
  jmp __alltraps
c0101eac:	e9 57 09 00 00       	jmp    c0102808 <__alltraps>

c0101eb1 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101eb1:	6a 00                	push   $0x0
  pushl $33
c0101eb3:	6a 21                	push   $0x21
  jmp __alltraps
c0101eb5:	e9 4e 09 00 00       	jmp    c0102808 <__alltraps>

c0101eba <vector34>:
.globl vector34
vector34:
  pushl $0
c0101eba:	6a 00                	push   $0x0
  pushl $34
c0101ebc:	6a 22                	push   $0x22
  jmp __alltraps
c0101ebe:	e9 45 09 00 00       	jmp    c0102808 <__alltraps>

c0101ec3 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101ec3:	6a 00                	push   $0x0
  pushl $35
c0101ec5:	6a 23                	push   $0x23
  jmp __alltraps
c0101ec7:	e9 3c 09 00 00       	jmp    c0102808 <__alltraps>

c0101ecc <vector36>:
.globl vector36
vector36:
  pushl $0
c0101ecc:	6a 00                	push   $0x0
  pushl $36
c0101ece:	6a 24                	push   $0x24
  jmp __alltraps
c0101ed0:	e9 33 09 00 00       	jmp    c0102808 <__alltraps>

c0101ed5 <vector37>:
.globl vector37
vector37:
  pushl $0
c0101ed5:	6a 00                	push   $0x0
  pushl $37
c0101ed7:	6a 25                	push   $0x25
  jmp __alltraps
c0101ed9:	e9 2a 09 00 00       	jmp    c0102808 <__alltraps>

c0101ede <vector38>:
.globl vector38
vector38:
  pushl $0
c0101ede:	6a 00                	push   $0x0
  pushl $38
c0101ee0:	6a 26                	push   $0x26
  jmp __alltraps
c0101ee2:	e9 21 09 00 00       	jmp    c0102808 <__alltraps>

c0101ee7 <vector39>:
.globl vector39
vector39:
  pushl $0
c0101ee7:	6a 00                	push   $0x0
  pushl $39
c0101ee9:	6a 27                	push   $0x27
  jmp __alltraps
c0101eeb:	e9 18 09 00 00       	jmp    c0102808 <__alltraps>

c0101ef0 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101ef0:	6a 00                	push   $0x0
  pushl $40
c0101ef2:	6a 28                	push   $0x28
  jmp __alltraps
c0101ef4:	e9 0f 09 00 00       	jmp    c0102808 <__alltraps>

c0101ef9 <vector41>:
.globl vector41
vector41:
  pushl $0
c0101ef9:	6a 00                	push   $0x0
  pushl $41
c0101efb:	6a 29                	push   $0x29
  jmp __alltraps
c0101efd:	e9 06 09 00 00       	jmp    c0102808 <__alltraps>

c0101f02 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f02:	6a 00                	push   $0x0
  pushl $42
c0101f04:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f06:	e9 fd 08 00 00       	jmp    c0102808 <__alltraps>

c0101f0b <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f0b:	6a 00                	push   $0x0
  pushl $43
c0101f0d:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f0f:	e9 f4 08 00 00       	jmp    c0102808 <__alltraps>

c0101f14 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f14:	6a 00                	push   $0x0
  pushl $44
c0101f16:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101f18:	e9 eb 08 00 00       	jmp    c0102808 <__alltraps>

c0101f1d <vector45>:
.globl vector45
vector45:
  pushl $0
c0101f1d:	6a 00                	push   $0x0
  pushl $45
c0101f1f:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101f21:	e9 e2 08 00 00       	jmp    c0102808 <__alltraps>

c0101f26 <vector46>:
.globl vector46
vector46:
  pushl $0
c0101f26:	6a 00                	push   $0x0
  pushl $46
c0101f28:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101f2a:	e9 d9 08 00 00       	jmp    c0102808 <__alltraps>

c0101f2f <vector47>:
.globl vector47
vector47:
  pushl $0
c0101f2f:	6a 00                	push   $0x0
  pushl $47
c0101f31:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101f33:	e9 d0 08 00 00       	jmp    c0102808 <__alltraps>

c0101f38 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101f38:	6a 00                	push   $0x0
  pushl $48
c0101f3a:	6a 30                	push   $0x30
  jmp __alltraps
c0101f3c:	e9 c7 08 00 00       	jmp    c0102808 <__alltraps>

c0101f41 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101f41:	6a 00                	push   $0x0
  pushl $49
c0101f43:	6a 31                	push   $0x31
  jmp __alltraps
c0101f45:	e9 be 08 00 00       	jmp    c0102808 <__alltraps>

c0101f4a <vector50>:
.globl vector50
vector50:
  pushl $0
c0101f4a:	6a 00                	push   $0x0
  pushl $50
c0101f4c:	6a 32                	push   $0x32
  jmp __alltraps
c0101f4e:	e9 b5 08 00 00       	jmp    c0102808 <__alltraps>

c0101f53 <vector51>:
.globl vector51
vector51:
  pushl $0
c0101f53:	6a 00                	push   $0x0
  pushl $51
c0101f55:	6a 33                	push   $0x33
  jmp __alltraps
c0101f57:	e9 ac 08 00 00       	jmp    c0102808 <__alltraps>

c0101f5c <vector52>:
.globl vector52
vector52:
  pushl $0
c0101f5c:	6a 00                	push   $0x0
  pushl $52
c0101f5e:	6a 34                	push   $0x34
  jmp __alltraps
c0101f60:	e9 a3 08 00 00       	jmp    c0102808 <__alltraps>

c0101f65 <vector53>:
.globl vector53
vector53:
  pushl $0
c0101f65:	6a 00                	push   $0x0
  pushl $53
c0101f67:	6a 35                	push   $0x35
  jmp __alltraps
c0101f69:	e9 9a 08 00 00       	jmp    c0102808 <__alltraps>

c0101f6e <vector54>:
.globl vector54
vector54:
  pushl $0
c0101f6e:	6a 00                	push   $0x0
  pushl $54
c0101f70:	6a 36                	push   $0x36
  jmp __alltraps
c0101f72:	e9 91 08 00 00       	jmp    c0102808 <__alltraps>

c0101f77 <vector55>:
.globl vector55
vector55:
  pushl $0
c0101f77:	6a 00                	push   $0x0
  pushl $55
c0101f79:	6a 37                	push   $0x37
  jmp __alltraps
c0101f7b:	e9 88 08 00 00       	jmp    c0102808 <__alltraps>

c0101f80 <vector56>:
.globl vector56
vector56:
  pushl $0
c0101f80:	6a 00                	push   $0x0
  pushl $56
c0101f82:	6a 38                	push   $0x38
  jmp __alltraps
c0101f84:	e9 7f 08 00 00       	jmp    c0102808 <__alltraps>

c0101f89 <vector57>:
.globl vector57
vector57:
  pushl $0
c0101f89:	6a 00                	push   $0x0
  pushl $57
c0101f8b:	6a 39                	push   $0x39
  jmp __alltraps
c0101f8d:	e9 76 08 00 00       	jmp    c0102808 <__alltraps>

c0101f92 <vector58>:
.globl vector58
vector58:
  pushl $0
c0101f92:	6a 00                	push   $0x0
  pushl $58
c0101f94:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101f96:	e9 6d 08 00 00       	jmp    c0102808 <__alltraps>

c0101f9b <vector59>:
.globl vector59
vector59:
  pushl $0
c0101f9b:	6a 00                	push   $0x0
  pushl $59
c0101f9d:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101f9f:	e9 64 08 00 00       	jmp    c0102808 <__alltraps>

c0101fa4 <vector60>:
.globl vector60
vector60:
  pushl $0
c0101fa4:	6a 00                	push   $0x0
  pushl $60
c0101fa6:	6a 3c                	push   $0x3c
  jmp __alltraps
c0101fa8:	e9 5b 08 00 00       	jmp    c0102808 <__alltraps>

c0101fad <vector61>:
.globl vector61
vector61:
  pushl $0
c0101fad:	6a 00                	push   $0x0
  pushl $61
c0101faf:	6a 3d                	push   $0x3d
  jmp __alltraps
c0101fb1:	e9 52 08 00 00       	jmp    c0102808 <__alltraps>

c0101fb6 <vector62>:
.globl vector62
vector62:
  pushl $0
c0101fb6:	6a 00                	push   $0x0
  pushl $62
c0101fb8:	6a 3e                	push   $0x3e
  jmp __alltraps
c0101fba:	e9 49 08 00 00       	jmp    c0102808 <__alltraps>

c0101fbf <vector63>:
.globl vector63
vector63:
  pushl $0
c0101fbf:	6a 00                	push   $0x0
  pushl $63
c0101fc1:	6a 3f                	push   $0x3f
  jmp __alltraps
c0101fc3:	e9 40 08 00 00       	jmp    c0102808 <__alltraps>

c0101fc8 <vector64>:
.globl vector64
vector64:
  pushl $0
c0101fc8:	6a 00                	push   $0x0
  pushl $64
c0101fca:	6a 40                	push   $0x40
  jmp __alltraps
c0101fcc:	e9 37 08 00 00       	jmp    c0102808 <__alltraps>

c0101fd1 <vector65>:
.globl vector65
vector65:
  pushl $0
c0101fd1:	6a 00                	push   $0x0
  pushl $65
c0101fd3:	6a 41                	push   $0x41
  jmp __alltraps
c0101fd5:	e9 2e 08 00 00       	jmp    c0102808 <__alltraps>

c0101fda <vector66>:
.globl vector66
vector66:
  pushl $0
c0101fda:	6a 00                	push   $0x0
  pushl $66
c0101fdc:	6a 42                	push   $0x42
  jmp __alltraps
c0101fde:	e9 25 08 00 00       	jmp    c0102808 <__alltraps>

c0101fe3 <vector67>:
.globl vector67
vector67:
  pushl $0
c0101fe3:	6a 00                	push   $0x0
  pushl $67
c0101fe5:	6a 43                	push   $0x43
  jmp __alltraps
c0101fe7:	e9 1c 08 00 00       	jmp    c0102808 <__alltraps>

c0101fec <vector68>:
.globl vector68
vector68:
  pushl $0
c0101fec:	6a 00                	push   $0x0
  pushl $68
c0101fee:	6a 44                	push   $0x44
  jmp __alltraps
c0101ff0:	e9 13 08 00 00       	jmp    c0102808 <__alltraps>

c0101ff5 <vector69>:
.globl vector69
vector69:
  pushl $0
c0101ff5:	6a 00                	push   $0x0
  pushl $69
c0101ff7:	6a 45                	push   $0x45
  jmp __alltraps
c0101ff9:	e9 0a 08 00 00       	jmp    c0102808 <__alltraps>

c0101ffe <vector70>:
.globl vector70
vector70:
  pushl $0
c0101ffe:	6a 00                	push   $0x0
  pushl $70
c0102000:	6a 46                	push   $0x46
  jmp __alltraps
c0102002:	e9 01 08 00 00       	jmp    c0102808 <__alltraps>

c0102007 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102007:	6a 00                	push   $0x0
  pushl $71
c0102009:	6a 47                	push   $0x47
  jmp __alltraps
c010200b:	e9 f8 07 00 00       	jmp    c0102808 <__alltraps>

c0102010 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102010:	6a 00                	push   $0x0
  pushl $72
c0102012:	6a 48                	push   $0x48
  jmp __alltraps
c0102014:	e9 ef 07 00 00       	jmp    c0102808 <__alltraps>

c0102019 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102019:	6a 00                	push   $0x0
  pushl $73
c010201b:	6a 49                	push   $0x49
  jmp __alltraps
c010201d:	e9 e6 07 00 00       	jmp    c0102808 <__alltraps>

c0102022 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102022:	6a 00                	push   $0x0
  pushl $74
c0102024:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102026:	e9 dd 07 00 00       	jmp    c0102808 <__alltraps>

c010202b <vector75>:
.globl vector75
vector75:
  pushl $0
c010202b:	6a 00                	push   $0x0
  pushl $75
c010202d:	6a 4b                	push   $0x4b
  jmp __alltraps
c010202f:	e9 d4 07 00 00       	jmp    c0102808 <__alltraps>

c0102034 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102034:	6a 00                	push   $0x0
  pushl $76
c0102036:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102038:	e9 cb 07 00 00       	jmp    c0102808 <__alltraps>

c010203d <vector77>:
.globl vector77
vector77:
  pushl $0
c010203d:	6a 00                	push   $0x0
  pushl $77
c010203f:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102041:	e9 c2 07 00 00       	jmp    c0102808 <__alltraps>

c0102046 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102046:	6a 00                	push   $0x0
  pushl $78
c0102048:	6a 4e                	push   $0x4e
  jmp __alltraps
c010204a:	e9 b9 07 00 00       	jmp    c0102808 <__alltraps>

c010204f <vector79>:
.globl vector79
vector79:
  pushl $0
c010204f:	6a 00                	push   $0x0
  pushl $79
c0102051:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102053:	e9 b0 07 00 00       	jmp    c0102808 <__alltraps>

c0102058 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102058:	6a 00                	push   $0x0
  pushl $80
c010205a:	6a 50                	push   $0x50
  jmp __alltraps
c010205c:	e9 a7 07 00 00       	jmp    c0102808 <__alltraps>

c0102061 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102061:	6a 00                	push   $0x0
  pushl $81
c0102063:	6a 51                	push   $0x51
  jmp __alltraps
c0102065:	e9 9e 07 00 00       	jmp    c0102808 <__alltraps>

c010206a <vector82>:
.globl vector82
vector82:
  pushl $0
c010206a:	6a 00                	push   $0x0
  pushl $82
c010206c:	6a 52                	push   $0x52
  jmp __alltraps
c010206e:	e9 95 07 00 00       	jmp    c0102808 <__alltraps>

c0102073 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102073:	6a 00                	push   $0x0
  pushl $83
c0102075:	6a 53                	push   $0x53
  jmp __alltraps
c0102077:	e9 8c 07 00 00       	jmp    c0102808 <__alltraps>

c010207c <vector84>:
.globl vector84
vector84:
  pushl $0
c010207c:	6a 00                	push   $0x0
  pushl $84
c010207e:	6a 54                	push   $0x54
  jmp __alltraps
c0102080:	e9 83 07 00 00       	jmp    c0102808 <__alltraps>

c0102085 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102085:	6a 00                	push   $0x0
  pushl $85
c0102087:	6a 55                	push   $0x55
  jmp __alltraps
c0102089:	e9 7a 07 00 00       	jmp    c0102808 <__alltraps>

c010208e <vector86>:
.globl vector86
vector86:
  pushl $0
c010208e:	6a 00                	push   $0x0
  pushl $86
c0102090:	6a 56                	push   $0x56
  jmp __alltraps
c0102092:	e9 71 07 00 00       	jmp    c0102808 <__alltraps>

c0102097 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102097:	6a 00                	push   $0x0
  pushl $87
c0102099:	6a 57                	push   $0x57
  jmp __alltraps
c010209b:	e9 68 07 00 00       	jmp    c0102808 <__alltraps>

c01020a0 <vector88>:
.globl vector88
vector88:
  pushl $0
c01020a0:	6a 00                	push   $0x0
  pushl $88
c01020a2:	6a 58                	push   $0x58
  jmp __alltraps
c01020a4:	e9 5f 07 00 00       	jmp    c0102808 <__alltraps>

c01020a9 <vector89>:
.globl vector89
vector89:
  pushl $0
c01020a9:	6a 00                	push   $0x0
  pushl $89
c01020ab:	6a 59                	push   $0x59
  jmp __alltraps
c01020ad:	e9 56 07 00 00       	jmp    c0102808 <__alltraps>

c01020b2 <vector90>:
.globl vector90
vector90:
  pushl $0
c01020b2:	6a 00                	push   $0x0
  pushl $90
c01020b4:	6a 5a                	push   $0x5a
  jmp __alltraps
c01020b6:	e9 4d 07 00 00       	jmp    c0102808 <__alltraps>

c01020bb <vector91>:
.globl vector91
vector91:
  pushl $0
c01020bb:	6a 00                	push   $0x0
  pushl $91
c01020bd:	6a 5b                	push   $0x5b
  jmp __alltraps
c01020bf:	e9 44 07 00 00       	jmp    c0102808 <__alltraps>

c01020c4 <vector92>:
.globl vector92
vector92:
  pushl $0
c01020c4:	6a 00                	push   $0x0
  pushl $92
c01020c6:	6a 5c                	push   $0x5c
  jmp __alltraps
c01020c8:	e9 3b 07 00 00       	jmp    c0102808 <__alltraps>

c01020cd <vector93>:
.globl vector93
vector93:
  pushl $0
c01020cd:	6a 00                	push   $0x0
  pushl $93
c01020cf:	6a 5d                	push   $0x5d
  jmp __alltraps
c01020d1:	e9 32 07 00 00       	jmp    c0102808 <__alltraps>

c01020d6 <vector94>:
.globl vector94
vector94:
  pushl $0
c01020d6:	6a 00                	push   $0x0
  pushl $94
c01020d8:	6a 5e                	push   $0x5e
  jmp __alltraps
c01020da:	e9 29 07 00 00       	jmp    c0102808 <__alltraps>

c01020df <vector95>:
.globl vector95
vector95:
  pushl $0
c01020df:	6a 00                	push   $0x0
  pushl $95
c01020e1:	6a 5f                	push   $0x5f
  jmp __alltraps
c01020e3:	e9 20 07 00 00       	jmp    c0102808 <__alltraps>

c01020e8 <vector96>:
.globl vector96
vector96:
  pushl $0
c01020e8:	6a 00                	push   $0x0
  pushl $96
c01020ea:	6a 60                	push   $0x60
  jmp __alltraps
c01020ec:	e9 17 07 00 00       	jmp    c0102808 <__alltraps>

c01020f1 <vector97>:
.globl vector97
vector97:
  pushl $0
c01020f1:	6a 00                	push   $0x0
  pushl $97
c01020f3:	6a 61                	push   $0x61
  jmp __alltraps
c01020f5:	e9 0e 07 00 00       	jmp    c0102808 <__alltraps>

c01020fa <vector98>:
.globl vector98
vector98:
  pushl $0
c01020fa:	6a 00                	push   $0x0
  pushl $98
c01020fc:	6a 62                	push   $0x62
  jmp __alltraps
c01020fe:	e9 05 07 00 00       	jmp    c0102808 <__alltraps>

c0102103 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102103:	6a 00                	push   $0x0
  pushl $99
c0102105:	6a 63                	push   $0x63
  jmp __alltraps
c0102107:	e9 fc 06 00 00       	jmp    c0102808 <__alltraps>

c010210c <vector100>:
.globl vector100
vector100:
  pushl $0
c010210c:	6a 00                	push   $0x0
  pushl $100
c010210e:	6a 64                	push   $0x64
  jmp __alltraps
c0102110:	e9 f3 06 00 00       	jmp    c0102808 <__alltraps>

c0102115 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102115:	6a 00                	push   $0x0
  pushl $101
c0102117:	6a 65                	push   $0x65
  jmp __alltraps
c0102119:	e9 ea 06 00 00       	jmp    c0102808 <__alltraps>

c010211e <vector102>:
.globl vector102
vector102:
  pushl $0
c010211e:	6a 00                	push   $0x0
  pushl $102
c0102120:	6a 66                	push   $0x66
  jmp __alltraps
c0102122:	e9 e1 06 00 00       	jmp    c0102808 <__alltraps>

c0102127 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102127:	6a 00                	push   $0x0
  pushl $103
c0102129:	6a 67                	push   $0x67
  jmp __alltraps
c010212b:	e9 d8 06 00 00       	jmp    c0102808 <__alltraps>

c0102130 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102130:	6a 00                	push   $0x0
  pushl $104
c0102132:	6a 68                	push   $0x68
  jmp __alltraps
c0102134:	e9 cf 06 00 00       	jmp    c0102808 <__alltraps>

c0102139 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102139:	6a 00                	push   $0x0
  pushl $105
c010213b:	6a 69                	push   $0x69
  jmp __alltraps
c010213d:	e9 c6 06 00 00       	jmp    c0102808 <__alltraps>

c0102142 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102142:	6a 00                	push   $0x0
  pushl $106
c0102144:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102146:	e9 bd 06 00 00       	jmp    c0102808 <__alltraps>

c010214b <vector107>:
.globl vector107
vector107:
  pushl $0
c010214b:	6a 00                	push   $0x0
  pushl $107
c010214d:	6a 6b                	push   $0x6b
  jmp __alltraps
c010214f:	e9 b4 06 00 00       	jmp    c0102808 <__alltraps>

c0102154 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102154:	6a 00                	push   $0x0
  pushl $108
c0102156:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102158:	e9 ab 06 00 00       	jmp    c0102808 <__alltraps>

c010215d <vector109>:
.globl vector109
vector109:
  pushl $0
c010215d:	6a 00                	push   $0x0
  pushl $109
c010215f:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102161:	e9 a2 06 00 00       	jmp    c0102808 <__alltraps>

c0102166 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102166:	6a 00                	push   $0x0
  pushl $110
c0102168:	6a 6e                	push   $0x6e
  jmp __alltraps
c010216a:	e9 99 06 00 00       	jmp    c0102808 <__alltraps>

c010216f <vector111>:
.globl vector111
vector111:
  pushl $0
c010216f:	6a 00                	push   $0x0
  pushl $111
c0102171:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102173:	e9 90 06 00 00       	jmp    c0102808 <__alltraps>

c0102178 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102178:	6a 00                	push   $0x0
  pushl $112
c010217a:	6a 70                	push   $0x70
  jmp __alltraps
c010217c:	e9 87 06 00 00       	jmp    c0102808 <__alltraps>

c0102181 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102181:	6a 00                	push   $0x0
  pushl $113
c0102183:	6a 71                	push   $0x71
  jmp __alltraps
c0102185:	e9 7e 06 00 00       	jmp    c0102808 <__alltraps>

c010218a <vector114>:
.globl vector114
vector114:
  pushl $0
c010218a:	6a 00                	push   $0x0
  pushl $114
c010218c:	6a 72                	push   $0x72
  jmp __alltraps
c010218e:	e9 75 06 00 00       	jmp    c0102808 <__alltraps>

c0102193 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102193:	6a 00                	push   $0x0
  pushl $115
c0102195:	6a 73                	push   $0x73
  jmp __alltraps
c0102197:	e9 6c 06 00 00       	jmp    c0102808 <__alltraps>

c010219c <vector116>:
.globl vector116
vector116:
  pushl $0
c010219c:	6a 00                	push   $0x0
  pushl $116
c010219e:	6a 74                	push   $0x74
  jmp __alltraps
c01021a0:	e9 63 06 00 00       	jmp    c0102808 <__alltraps>

c01021a5 <vector117>:
.globl vector117
vector117:
  pushl $0
c01021a5:	6a 00                	push   $0x0
  pushl $117
c01021a7:	6a 75                	push   $0x75
  jmp __alltraps
c01021a9:	e9 5a 06 00 00       	jmp    c0102808 <__alltraps>

c01021ae <vector118>:
.globl vector118
vector118:
  pushl $0
c01021ae:	6a 00                	push   $0x0
  pushl $118
c01021b0:	6a 76                	push   $0x76
  jmp __alltraps
c01021b2:	e9 51 06 00 00       	jmp    c0102808 <__alltraps>

c01021b7 <vector119>:
.globl vector119
vector119:
  pushl $0
c01021b7:	6a 00                	push   $0x0
  pushl $119
c01021b9:	6a 77                	push   $0x77
  jmp __alltraps
c01021bb:	e9 48 06 00 00       	jmp    c0102808 <__alltraps>

c01021c0 <vector120>:
.globl vector120
vector120:
  pushl $0
c01021c0:	6a 00                	push   $0x0
  pushl $120
c01021c2:	6a 78                	push   $0x78
  jmp __alltraps
c01021c4:	e9 3f 06 00 00       	jmp    c0102808 <__alltraps>

c01021c9 <vector121>:
.globl vector121
vector121:
  pushl $0
c01021c9:	6a 00                	push   $0x0
  pushl $121
c01021cb:	6a 79                	push   $0x79
  jmp __alltraps
c01021cd:	e9 36 06 00 00       	jmp    c0102808 <__alltraps>

c01021d2 <vector122>:
.globl vector122
vector122:
  pushl $0
c01021d2:	6a 00                	push   $0x0
  pushl $122
c01021d4:	6a 7a                	push   $0x7a
  jmp __alltraps
c01021d6:	e9 2d 06 00 00       	jmp    c0102808 <__alltraps>

c01021db <vector123>:
.globl vector123
vector123:
  pushl $0
c01021db:	6a 00                	push   $0x0
  pushl $123
c01021dd:	6a 7b                	push   $0x7b
  jmp __alltraps
c01021df:	e9 24 06 00 00       	jmp    c0102808 <__alltraps>

c01021e4 <vector124>:
.globl vector124
vector124:
  pushl $0
c01021e4:	6a 00                	push   $0x0
  pushl $124
c01021e6:	6a 7c                	push   $0x7c
  jmp __alltraps
c01021e8:	e9 1b 06 00 00       	jmp    c0102808 <__alltraps>

c01021ed <vector125>:
.globl vector125
vector125:
  pushl $0
c01021ed:	6a 00                	push   $0x0
  pushl $125
c01021ef:	6a 7d                	push   $0x7d
  jmp __alltraps
c01021f1:	e9 12 06 00 00       	jmp    c0102808 <__alltraps>

c01021f6 <vector126>:
.globl vector126
vector126:
  pushl $0
c01021f6:	6a 00                	push   $0x0
  pushl $126
c01021f8:	6a 7e                	push   $0x7e
  jmp __alltraps
c01021fa:	e9 09 06 00 00       	jmp    c0102808 <__alltraps>

c01021ff <vector127>:
.globl vector127
vector127:
  pushl $0
c01021ff:	6a 00                	push   $0x0
  pushl $127
c0102201:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102203:	e9 00 06 00 00       	jmp    c0102808 <__alltraps>

c0102208 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102208:	6a 00                	push   $0x0
  pushl $128
c010220a:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c010220f:	e9 f4 05 00 00       	jmp    c0102808 <__alltraps>

c0102214 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102214:	6a 00                	push   $0x0
  pushl $129
c0102216:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c010221b:	e9 e8 05 00 00       	jmp    c0102808 <__alltraps>

c0102220 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102220:	6a 00                	push   $0x0
  pushl $130
c0102222:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102227:	e9 dc 05 00 00       	jmp    c0102808 <__alltraps>

c010222c <vector131>:
.globl vector131
vector131:
  pushl $0
c010222c:	6a 00                	push   $0x0
  pushl $131
c010222e:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102233:	e9 d0 05 00 00       	jmp    c0102808 <__alltraps>

c0102238 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102238:	6a 00                	push   $0x0
  pushl $132
c010223a:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010223f:	e9 c4 05 00 00       	jmp    c0102808 <__alltraps>

c0102244 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102244:	6a 00                	push   $0x0
  pushl $133
c0102246:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c010224b:	e9 b8 05 00 00       	jmp    c0102808 <__alltraps>

c0102250 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102250:	6a 00                	push   $0x0
  pushl $134
c0102252:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102257:	e9 ac 05 00 00       	jmp    c0102808 <__alltraps>

c010225c <vector135>:
.globl vector135
vector135:
  pushl $0
c010225c:	6a 00                	push   $0x0
  pushl $135
c010225e:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102263:	e9 a0 05 00 00       	jmp    c0102808 <__alltraps>

c0102268 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102268:	6a 00                	push   $0x0
  pushl $136
c010226a:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010226f:	e9 94 05 00 00       	jmp    c0102808 <__alltraps>

c0102274 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102274:	6a 00                	push   $0x0
  pushl $137
c0102276:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c010227b:	e9 88 05 00 00       	jmp    c0102808 <__alltraps>

c0102280 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102280:	6a 00                	push   $0x0
  pushl $138
c0102282:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102287:	e9 7c 05 00 00       	jmp    c0102808 <__alltraps>

c010228c <vector139>:
.globl vector139
vector139:
  pushl $0
c010228c:	6a 00                	push   $0x0
  pushl $139
c010228e:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102293:	e9 70 05 00 00       	jmp    c0102808 <__alltraps>

c0102298 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102298:	6a 00                	push   $0x0
  pushl $140
c010229a:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010229f:	e9 64 05 00 00       	jmp    c0102808 <__alltraps>

c01022a4 <vector141>:
.globl vector141
vector141:
  pushl $0
c01022a4:	6a 00                	push   $0x0
  pushl $141
c01022a6:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01022ab:	e9 58 05 00 00       	jmp    c0102808 <__alltraps>

c01022b0 <vector142>:
.globl vector142
vector142:
  pushl $0
c01022b0:	6a 00                	push   $0x0
  pushl $142
c01022b2:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01022b7:	e9 4c 05 00 00       	jmp    c0102808 <__alltraps>

c01022bc <vector143>:
.globl vector143
vector143:
  pushl $0
c01022bc:	6a 00                	push   $0x0
  pushl $143
c01022be:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01022c3:	e9 40 05 00 00       	jmp    c0102808 <__alltraps>

c01022c8 <vector144>:
.globl vector144
vector144:
  pushl $0
c01022c8:	6a 00                	push   $0x0
  pushl $144
c01022ca:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01022cf:	e9 34 05 00 00       	jmp    c0102808 <__alltraps>

c01022d4 <vector145>:
.globl vector145
vector145:
  pushl $0
c01022d4:	6a 00                	push   $0x0
  pushl $145
c01022d6:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01022db:	e9 28 05 00 00       	jmp    c0102808 <__alltraps>

c01022e0 <vector146>:
.globl vector146
vector146:
  pushl $0
c01022e0:	6a 00                	push   $0x0
  pushl $146
c01022e2:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01022e7:	e9 1c 05 00 00       	jmp    c0102808 <__alltraps>

c01022ec <vector147>:
.globl vector147
vector147:
  pushl $0
c01022ec:	6a 00                	push   $0x0
  pushl $147
c01022ee:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01022f3:	e9 10 05 00 00       	jmp    c0102808 <__alltraps>

c01022f8 <vector148>:
.globl vector148
vector148:
  pushl $0
c01022f8:	6a 00                	push   $0x0
  pushl $148
c01022fa:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01022ff:	e9 04 05 00 00       	jmp    c0102808 <__alltraps>

c0102304 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102304:	6a 00                	push   $0x0
  pushl $149
c0102306:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010230b:	e9 f8 04 00 00       	jmp    c0102808 <__alltraps>

c0102310 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102310:	6a 00                	push   $0x0
  pushl $150
c0102312:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102317:	e9 ec 04 00 00       	jmp    c0102808 <__alltraps>

c010231c <vector151>:
.globl vector151
vector151:
  pushl $0
c010231c:	6a 00                	push   $0x0
  pushl $151
c010231e:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102323:	e9 e0 04 00 00       	jmp    c0102808 <__alltraps>

c0102328 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102328:	6a 00                	push   $0x0
  pushl $152
c010232a:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010232f:	e9 d4 04 00 00       	jmp    c0102808 <__alltraps>

c0102334 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102334:	6a 00                	push   $0x0
  pushl $153
c0102336:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010233b:	e9 c8 04 00 00       	jmp    c0102808 <__alltraps>

c0102340 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102340:	6a 00                	push   $0x0
  pushl $154
c0102342:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102347:	e9 bc 04 00 00       	jmp    c0102808 <__alltraps>

c010234c <vector155>:
.globl vector155
vector155:
  pushl $0
c010234c:	6a 00                	push   $0x0
  pushl $155
c010234e:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102353:	e9 b0 04 00 00       	jmp    c0102808 <__alltraps>

c0102358 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102358:	6a 00                	push   $0x0
  pushl $156
c010235a:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010235f:	e9 a4 04 00 00       	jmp    c0102808 <__alltraps>

c0102364 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102364:	6a 00                	push   $0x0
  pushl $157
c0102366:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010236b:	e9 98 04 00 00       	jmp    c0102808 <__alltraps>

c0102370 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102370:	6a 00                	push   $0x0
  pushl $158
c0102372:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102377:	e9 8c 04 00 00       	jmp    c0102808 <__alltraps>

c010237c <vector159>:
.globl vector159
vector159:
  pushl $0
c010237c:	6a 00                	push   $0x0
  pushl $159
c010237e:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102383:	e9 80 04 00 00       	jmp    c0102808 <__alltraps>

c0102388 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102388:	6a 00                	push   $0x0
  pushl $160
c010238a:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010238f:	e9 74 04 00 00       	jmp    c0102808 <__alltraps>

c0102394 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102394:	6a 00                	push   $0x0
  pushl $161
c0102396:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010239b:	e9 68 04 00 00       	jmp    c0102808 <__alltraps>

c01023a0 <vector162>:
.globl vector162
vector162:
  pushl $0
c01023a0:	6a 00                	push   $0x0
  pushl $162
c01023a2:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01023a7:	e9 5c 04 00 00       	jmp    c0102808 <__alltraps>

c01023ac <vector163>:
.globl vector163
vector163:
  pushl $0
c01023ac:	6a 00                	push   $0x0
  pushl $163
c01023ae:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01023b3:	e9 50 04 00 00       	jmp    c0102808 <__alltraps>

c01023b8 <vector164>:
.globl vector164
vector164:
  pushl $0
c01023b8:	6a 00                	push   $0x0
  pushl $164
c01023ba:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01023bf:	e9 44 04 00 00       	jmp    c0102808 <__alltraps>

c01023c4 <vector165>:
.globl vector165
vector165:
  pushl $0
c01023c4:	6a 00                	push   $0x0
  pushl $165
c01023c6:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01023cb:	e9 38 04 00 00       	jmp    c0102808 <__alltraps>

c01023d0 <vector166>:
.globl vector166
vector166:
  pushl $0
c01023d0:	6a 00                	push   $0x0
  pushl $166
c01023d2:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01023d7:	e9 2c 04 00 00       	jmp    c0102808 <__alltraps>

c01023dc <vector167>:
.globl vector167
vector167:
  pushl $0
c01023dc:	6a 00                	push   $0x0
  pushl $167
c01023de:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01023e3:	e9 20 04 00 00       	jmp    c0102808 <__alltraps>

c01023e8 <vector168>:
.globl vector168
vector168:
  pushl $0
c01023e8:	6a 00                	push   $0x0
  pushl $168
c01023ea:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01023ef:	e9 14 04 00 00       	jmp    c0102808 <__alltraps>

c01023f4 <vector169>:
.globl vector169
vector169:
  pushl $0
c01023f4:	6a 00                	push   $0x0
  pushl $169
c01023f6:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01023fb:	e9 08 04 00 00       	jmp    c0102808 <__alltraps>

c0102400 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102400:	6a 00                	push   $0x0
  pushl $170
c0102402:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102407:	e9 fc 03 00 00       	jmp    c0102808 <__alltraps>

c010240c <vector171>:
.globl vector171
vector171:
  pushl $0
c010240c:	6a 00                	push   $0x0
  pushl $171
c010240e:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102413:	e9 f0 03 00 00       	jmp    c0102808 <__alltraps>

c0102418 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102418:	6a 00                	push   $0x0
  pushl $172
c010241a:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c010241f:	e9 e4 03 00 00       	jmp    c0102808 <__alltraps>

c0102424 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102424:	6a 00                	push   $0x0
  pushl $173
c0102426:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010242b:	e9 d8 03 00 00       	jmp    c0102808 <__alltraps>

c0102430 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102430:	6a 00                	push   $0x0
  pushl $174
c0102432:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102437:	e9 cc 03 00 00       	jmp    c0102808 <__alltraps>

c010243c <vector175>:
.globl vector175
vector175:
  pushl $0
c010243c:	6a 00                	push   $0x0
  pushl $175
c010243e:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102443:	e9 c0 03 00 00       	jmp    c0102808 <__alltraps>

c0102448 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102448:	6a 00                	push   $0x0
  pushl $176
c010244a:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010244f:	e9 b4 03 00 00       	jmp    c0102808 <__alltraps>

c0102454 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102454:	6a 00                	push   $0x0
  pushl $177
c0102456:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010245b:	e9 a8 03 00 00       	jmp    c0102808 <__alltraps>

c0102460 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102460:	6a 00                	push   $0x0
  pushl $178
c0102462:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102467:	e9 9c 03 00 00       	jmp    c0102808 <__alltraps>

c010246c <vector179>:
.globl vector179
vector179:
  pushl $0
c010246c:	6a 00                	push   $0x0
  pushl $179
c010246e:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102473:	e9 90 03 00 00       	jmp    c0102808 <__alltraps>

c0102478 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102478:	6a 00                	push   $0x0
  pushl $180
c010247a:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010247f:	e9 84 03 00 00       	jmp    c0102808 <__alltraps>

c0102484 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102484:	6a 00                	push   $0x0
  pushl $181
c0102486:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010248b:	e9 78 03 00 00       	jmp    c0102808 <__alltraps>

c0102490 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102490:	6a 00                	push   $0x0
  pushl $182
c0102492:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102497:	e9 6c 03 00 00       	jmp    c0102808 <__alltraps>

c010249c <vector183>:
.globl vector183
vector183:
  pushl $0
c010249c:	6a 00                	push   $0x0
  pushl $183
c010249e:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01024a3:	e9 60 03 00 00       	jmp    c0102808 <__alltraps>

c01024a8 <vector184>:
.globl vector184
vector184:
  pushl $0
c01024a8:	6a 00                	push   $0x0
  pushl $184
c01024aa:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01024af:	e9 54 03 00 00       	jmp    c0102808 <__alltraps>

c01024b4 <vector185>:
.globl vector185
vector185:
  pushl $0
c01024b4:	6a 00                	push   $0x0
  pushl $185
c01024b6:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01024bb:	e9 48 03 00 00       	jmp    c0102808 <__alltraps>

c01024c0 <vector186>:
.globl vector186
vector186:
  pushl $0
c01024c0:	6a 00                	push   $0x0
  pushl $186
c01024c2:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01024c7:	e9 3c 03 00 00       	jmp    c0102808 <__alltraps>

c01024cc <vector187>:
.globl vector187
vector187:
  pushl $0
c01024cc:	6a 00                	push   $0x0
  pushl $187
c01024ce:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01024d3:	e9 30 03 00 00       	jmp    c0102808 <__alltraps>

c01024d8 <vector188>:
.globl vector188
vector188:
  pushl $0
c01024d8:	6a 00                	push   $0x0
  pushl $188
c01024da:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01024df:	e9 24 03 00 00       	jmp    c0102808 <__alltraps>

c01024e4 <vector189>:
.globl vector189
vector189:
  pushl $0
c01024e4:	6a 00                	push   $0x0
  pushl $189
c01024e6:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01024eb:	e9 18 03 00 00       	jmp    c0102808 <__alltraps>

c01024f0 <vector190>:
.globl vector190
vector190:
  pushl $0
c01024f0:	6a 00                	push   $0x0
  pushl $190
c01024f2:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01024f7:	e9 0c 03 00 00       	jmp    c0102808 <__alltraps>

c01024fc <vector191>:
.globl vector191
vector191:
  pushl $0
c01024fc:	6a 00                	push   $0x0
  pushl $191
c01024fe:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102503:	e9 00 03 00 00       	jmp    c0102808 <__alltraps>

c0102508 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102508:	6a 00                	push   $0x0
  pushl $192
c010250a:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c010250f:	e9 f4 02 00 00       	jmp    c0102808 <__alltraps>

c0102514 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102514:	6a 00                	push   $0x0
  pushl $193
c0102516:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010251b:	e9 e8 02 00 00       	jmp    c0102808 <__alltraps>

c0102520 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102520:	6a 00                	push   $0x0
  pushl $194
c0102522:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102527:	e9 dc 02 00 00       	jmp    c0102808 <__alltraps>

c010252c <vector195>:
.globl vector195
vector195:
  pushl $0
c010252c:	6a 00                	push   $0x0
  pushl $195
c010252e:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102533:	e9 d0 02 00 00       	jmp    c0102808 <__alltraps>

c0102538 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102538:	6a 00                	push   $0x0
  pushl $196
c010253a:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010253f:	e9 c4 02 00 00       	jmp    c0102808 <__alltraps>

c0102544 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102544:	6a 00                	push   $0x0
  pushl $197
c0102546:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010254b:	e9 b8 02 00 00       	jmp    c0102808 <__alltraps>

c0102550 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102550:	6a 00                	push   $0x0
  pushl $198
c0102552:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102557:	e9 ac 02 00 00       	jmp    c0102808 <__alltraps>

c010255c <vector199>:
.globl vector199
vector199:
  pushl $0
c010255c:	6a 00                	push   $0x0
  pushl $199
c010255e:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102563:	e9 a0 02 00 00       	jmp    c0102808 <__alltraps>

c0102568 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102568:	6a 00                	push   $0x0
  pushl $200
c010256a:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010256f:	e9 94 02 00 00       	jmp    c0102808 <__alltraps>

c0102574 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102574:	6a 00                	push   $0x0
  pushl $201
c0102576:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010257b:	e9 88 02 00 00       	jmp    c0102808 <__alltraps>

c0102580 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102580:	6a 00                	push   $0x0
  pushl $202
c0102582:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102587:	e9 7c 02 00 00       	jmp    c0102808 <__alltraps>

c010258c <vector203>:
.globl vector203
vector203:
  pushl $0
c010258c:	6a 00                	push   $0x0
  pushl $203
c010258e:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102593:	e9 70 02 00 00       	jmp    c0102808 <__alltraps>

c0102598 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102598:	6a 00                	push   $0x0
  pushl $204
c010259a:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010259f:	e9 64 02 00 00       	jmp    c0102808 <__alltraps>

c01025a4 <vector205>:
.globl vector205
vector205:
  pushl $0
c01025a4:	6a 00                	push   $0x0
  pushl $205
c01025a6:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01025ab:	e9 58 02 00 00       	jmp    c0102808 <__alltraps>

c01025b0 <vector206>:
.globl vector206
vector206:
  pushl $0
c01025b0:	6a 00                	push   $0x0
  pushl $206
c01025b2:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01025b7:	e9 4c 02 00 00       	jmp    c0102808 <__alltraps>

c01025bc <vector207>:
.globl vector207
vector207:
  pushl $0
c01025bc:	6a 00                	push   $0x0
  pushl $207
c01025be:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01025c3:	e9 40 02 00 00       	jmp    c0102808 <__alltraps>

c01025c8 <vector208>:
.globl vector208
vector208:
  pushl $0
c01025c8:	6a 00                	push   $0x0
  pushl $208
c01025ca:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01025cf:	e9 34 02 00 00       	jmp    c0102808 <__alltraps>

c01025d4 <vector209>:
.globl vector209
vector209:
  pushl $0
c01025d4:	6a 00                	push   $0x0
  pushl $209
c01025d6:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01025db:	e9 28 02 00 00       	jmp    c0102808 <__alltraps>

c01025e0 <vector210>:
.globl vector210
vector210:
  pushl $0
c01025e0:	6a 00                	push   $0x0
  pushl $210
c01025e2:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01025e7:	e9 1c 02 00 00       	jmp    c0102808 <__alltraps>

c01025ec <vector211>:
.globl vector211
vector211:
  pushl $0
c01025ec:	6a 00                	push   $0x0
  pushl $211
c01025ee:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01025f3:	e9 10 02 00 00       	jmp    c0102808 <__alltraps>

c01025f8 <vector212>:
.globl vector212
vector212:
  pushl $0
c01025f8:	6a 00                	push   $0x0
  pushl $212
c01025fa:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01025ff:	e9 04 02 00 00       	jmp    c0102808 <__alltraps>

c0102604 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102604:	6a 00                	push   $0x0
  pushl $213
c0102606:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010260b:	e9 f8 01 00 00       	jmp    c0102808 <__alltraps>

c0102610 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102610:	6a 00                	push   $0x0
  pushl $214
c0102612:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102617:	e9 ec 01 00 00       	jmp    c0102808 <__alltraps>

c010261c <vector215>:
.globl vector215
vector215:
  pushl $0
c010261c:	6a 00                	push   $0x0
  pushl $215
c010261e:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102623:	e9 e0 01 00 00       	jmp    c0102808 <__alltraps>

c0102628 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102628:	6a 00                	push   $0x0
  pushl $216
c010262a:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010262f:	e9 d4 01 00 00       	jmp    c0102808 <__alltraps>

c0102634 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102634:	6a 00                	push   $0x0
  pushl $217
c0102636:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010263b:	e9 c8 01 00 00       	jmp    c0102808 <__alltraps>

c0102640 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102640:	6a 00                	push   $0x0
  pushl $218
c0102642:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102647:	e9 bc 01 00 00       	jmp    c0102808 <__alltraps>

c010264c <vector219>:
.globl vector219
vector219:
  pushl $0
c010264c:	6a 00                	push   $0x0
  pushl $219
c010264e:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102653:	e9 b0 01 00 00       	jmp    c0102808 <__alltraps>

c0102658 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102658:	6a 00                	push   $0x0
  pushl $220
c010265a:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010265f:	e9 a4 01 00 00       	jmp    c0102808 <__alltraps>

c0102664 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102664:	6a 00                	push   $0x0
  pushl $221
c0102666:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010266b:	e9 98 01 00 00       	jmp    c0102808 <__alltraps>

c0102670 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102670:	6a 00                	push   $0x0
  pushl $222
c0102672:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102677:	e9 8c 01 00 00       	jmp    c0102808 <__alltraps>

c010267c <vector223>:
.globl vector223
vector223:
  pushl $0
c010267c:	6a 00                	push   $0x0
  pushl $223
c010267e:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102683:	e9 80 01 00 00       	jmp    c0102808 <__alltraps>

c0102688 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102688:	6a 00                	push   $0x0
  pushl $224
c010268a:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010268f:	e9 74 01 00 00       	jmp    c0102808 <__alltraps>

c0102694 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102694:	6a 00                	push   $0x0
  pushl $225
c0102696:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010269b:	e9 68 01 00 00       	jmp    c0102808 <__alltraps>

c01026a0 <vector226>:
.globl vector226
vector226:
  pushl $0
c01026a0:	6a 00                	push   $0x0
  pushl $226
c01026a2:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01026a7:	e9 5c 01 00 00       	jmp    c0102808 <__alltraps>

c01026ac <vector227>:
.globl vector227
vector227:
  pushl $0
c01026ac:	6a 00                	push   $0x0
  pushl $227
c01026ae:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01026b3:	e9 50 01 00 00       	jmp    c0102808 <__alltraps>

c01026b8 <vector228>:
.globl vector228
vector228:
  pushl $0
c01026b8:	6a 00                	push   $0x0
  pushl $228
c01026ba:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01026bf:	e9 44 01 00 00       	jmp    c0102808 <__alltraps>

c01026c4 <vector229>:
.globl vector229
vector229:
  pushl $0
c01026c4:	6a 00                	push   $0x0
  pushl $229
c01026c6:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01026cb:	e9 38 01 00 00       	jmp    c0102808 <__alltraps>

c01026d0 <vector230>:
.globl vector230
vector230:
  pushl $0
c01026d0:	6a 00                	push   $0x0
  pushl $230
c01026d2:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01026d7:	e9 2c 01 00 00       	jmp    c0102808 <__alltraps>

c01026dc <vector231>:
.globl vector231
vector231:
  pushl $0
c01026dc:	6a 00                	push   $0x0
  pushl $231
c01026de:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01026e3:	e9 20 01 00 00       	jmp    c0102808 <__alltraps>

c01026e8 <vector232>:
.globl vector232
vector232:
  pushl $0
c01026e8:	6a 00                	push   $0x0
  pushl $232
c01026ea:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01026ef:	e9 14 01 00 00       	jmp    c0102808 <__alltraps>

c01026f4 <vector233>:
.globl vector233
vector233:
  pushl $0
c01026f4:	6a 00                	push   $0x0
  pushl $233
c01026f6:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01026fb:	e9 08 01 00 00       	jmp    c0102808 <__alltraps>

c0102700 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102700:	6a 00                	push   $0x0
  pushl $234
c0102702:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102707:	e9 fc 00 00 00       	jmp    c0102808 <__alltraps>

c010270c <vector235>:
.globl vector235
vector235:
  pushl $0
c010270c:	6a 00                	push   $0x0
  pushl $235
c010270e:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102713:	e9 f0 00 00 00       	jmp    c0102808 <__alltraps>

c0102718 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102718:	6a 00                	push   $0x0
  pushl $236
c010271a:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010271f:	e9 e4 00 00 00       	jmp    c0102808 <__alltraps>

c0102724 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102724:	6a 00                	push   $0x0
  pushl $237
c0102726:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010272b:	e9 d8 00 00 00       	jmp    c0102808 <__alltraps>

c0102730 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102730:	6a 00                	push   $0x0
  pushl $238
c0102732:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102737:	e9 cc 00 00 00       	jmp    c0102808 <__alltraps>

c010273c <vector239>:
.globl vector239
vector239:
  pushl $0
c010273c:	6a 00                	push   $0x0
  pushl $239
c010273e:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102743:	e9 c0 00 00 00       	jmp    c0102808 <__alltraps>

c0102748 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102748:	6a 00                	push   $0x0
  pushl $240
c010274a:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010274f:	e9 b4 00 00 00       	jmp    c0102808 <__alltraps>

c0102754 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102754:	6a 00                	push   $0x0
  pushl $241
c0102756:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010275b:	e9 a8 00 00 00       	jmp    c0102808 <__alltraps>

c0102760 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102760:	6a 00                	push   $0x0
  pushl $242
c0102762:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102767:	e9 9c 00 00 00       	jmp    c0102808 <__alltraps>

c010276c <vector243>:
.globl vector243
vector243:
  pushl $0
c010276c:	6a 00                	push   $0x0
  pushl $243
c010276e:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102773:	e9 90 00 00 00       	jmp    c0102808 <__alltraps>

c0102778 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102778:	6a 00                	push   $0x0
  pushl $244
c010277a:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010277f:	e9 84 00 00 00       	jmp    c0102808 <__alltraps>

c0102784 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102784:	6a 00                	push   $0x0
  pushl $245
c0102786:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010278b:	e9 78 00 00 00       	jmp    c0102808 <__alltraps>

c0102790 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102790:	6a 00                	push   $0x0
  pushl $246
c0102792:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102797:	e9 6c 00 00 00       	jmp    c0102808 <__alltraps>

c010279c <vector247>:
.globl vector247
vector247:
  pushl $0
c010279c:	6a 00                	push   $0x0
  pushl $247
c010279e:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01027a3:	e9 60 00 00 00       	jmp    c0102808 <__alltraps>

c01027a8 <vector248>:
.globl vector248
vector248:
  pushl $0
c01027a8:	6a 00                	push   $0x0
  pushl $248
c01027aa:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01027af:	e9 54 00 00 00       	jmp    c0102808 <__alltraps>

c01027b4 <vector249>:
.globl vector249
vector249:
  pushl $0
c01027b4:	6a 00                	push   $0x0
  pushl $249
c01027b6:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01027bb:	e9 48 00 00 00       	jmp    c0102808 <__alltraps>

c01027c0 <vector250>:
.globl vector250
vector250:
  pushl $0
c01027c0:	6a 00                	push   $0x0
  pushl $250
c01027c2:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01027c7:	e9 3c 00 00 00       	jmp    c0102808 <__alltraps>

c01027cc <vector251>:
.globl vector251
vector251:
  pushl $0
c01027cc:	6a 00                	push   $0x0
  pushl $251
c01027ce:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01027d3:	e9 30 00 00 00       	jmp    c0102808 <__alltraps>

c01027d8 <vector252>:
.globl vector252
vector252:
  pushl $0
c01027d8:	6a 00                	push   $0x0
  pushl $252
c01027da:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01027df:	e9 24 00 00 00       	jmp    c0102808 <__alltraps>

c01027e4 <vector253>:
.globl vector253
vector253:
  pushl $0
c01027e4:	6a 00                	push   $0x0
  pushl $253
c01027e6:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01027eb:	e9 18 00 00 00       	jmp    c0102808 <__alltraps>

c01027f0 <vector254>:
.globl vector254
vector254:
  pushl $0
c01027f0:	6a 00                	push   $0x0
  pushl $254
c01027f2:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01027f7:	e9 0c 00 00 00       	jmp    c0102808 <__alltraps>

c01027fc <vector255>:
.globl vector255
vector255:
  pushl $0
c01027fc:	6a 00                	push   $0x0
  pushl $255
c01027fe:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102803:	e9 00 00 00 00       	jmp    c0102808 <__alltraps>

c0102808 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102808:	1e                   	push   %ds
    pushl %es
c0102809:	06                   	push   %es
    pushl %fs
c010280a:	0f a0                	push   %fs
    pushl %gs
c010280c:	0f a8                	push   %gs
    pushal
c010280e:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c010280f:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102814:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102816:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102818:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102819:	e8 64 f5 ff ff       	call   c0101d82 <trap>

    # pop the pushed stack pointer
    popl %esp
c010281e:	5c                   	pop    %esp

c010281f <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c010281f:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102820:	0f a9                	pop    %gs
    popl %fs
c0102822:	0f a1                	pop    %fs
    popl %es
c0102824:	07                   	pop    %es
    popl %ds
c0102825:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102826:	83 c4 08             	add    $0x8,%esp
    iret
c0102829:	cf                   	iret   

c010282a <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010282a:	55                   	push   %ebp
c010282b:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010282d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102830:	8b 15 18 df 11 c0    	mov    0xc011df18,%edx
c0102836:	29 d0                	sub    %edx,%eax
c0102838:	c1 f8 02             	sar    $0x2,%eax
c010283b:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102841:	5d                   	pop    %ebp
c0102842:	c3                   	ret    

c0102843 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102843:	55                   	push   %ebp
c0102844:	89 e5                	mov    %esp,%ebp
c0102846:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102849:	8b 45 08             	mov    0x8(%ebp),%eax
c010284c:	89 04 24             	mov    %eax,(%esp)
c010284f:	e8 d6 ff ff ff       	call   c010282a <page2ppn>
c0102854:	c1 e0 0c             	shl    $0xc,%eax
}
c0102857:	c9                   	leave  
c0102858:	c3                   	ret    

c0102859 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0102859:	55                   	push   %ebp
c010285a:	89 e5                	mov    %esp,%ebp
c010285c:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010285f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102862:	c1 e8 0c             	shr    $0xc,%eax
c0102865:	89 c2                	mov    %eax,%edx
c0102867:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c010286c:	39 c2                	cmp    %eax,%edx
c010286e:	72 1c                	jb     c010288c <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102870:	c7 44 24 08 30 74 10 	movl   $0xc0107430,0x8(%esp)
c0102877:	c0 
c0102878:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c010287f:	00 
c0102880:	c7 04 24 4f 74 10 c0 	movl   $0xc010744f,(%esp)
c0102887:	e8 5d db ff ff       	call   c01003e9 <__panic>
    }
    return &pages[PPN(pa)];
c010288c:	8b 0d 18 df 11 c0    	mov    0xc011df18,%ecx
c0102892:	8b 45 08             	mov    0x8(%ebp),%eax
c0102895:	c1 e8 0c             	shr    $0xc,%eax
c0102898:	89 c2                	mov    %eax,%edx
c010289a:	89 d0                	mov    %edx,%eax
c010289c:	c1 e0 02             	shl    $0x2,%eax
c010289f:	01 d0                	add    %edx,%eax
c01028a1:	c1 e0 02             	shl    $0x2,%eax
c01028a4:	01 c8                	add    %ecx,%eax
}
c01028a6:	c9                   	leave  
c01028a7:	c3                   	ret    

c01028a8 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01028a8:	55                   	push   %ebp
c01028a9:	89 e5                	mov    %esp,%ebp
c01028ab:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01028ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01028b1:	89 04 24             	mov    %eax,(%esp)
c01028b4:	e8 8a ff ff ff       	call   c0102843 <page2pa>
c01028b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01028bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028bf:	c1 e8 0c             	shr    $0xc,%eax
c01028c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01028c5:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c01028ca:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01028cd:	72 23                	jb     c01028f2 <page2kva+0x4a>
c01028cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028d6:	c7 44 24 08 60 74 10 	movl   $0xc0107460,0x8(%esp)
c01028dd:	c0 
c01028de:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c01028e5:	00 
c01028e6:	c7 04 24 4f 74 10 c0 	movl   $0xc010744f,(%esp)
c01028ed:	e8 f7 da ff ff       	call   c01003e9 <__panic>
c01028f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028f5:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01028fa:	c9                   	leave  
c01028fb:	c3                   	ret    

c01028fc <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c01028fc:	55                   	push   %ebp
c01028fd:	89 e5                	mov    %esp,%ebp
c01028ff:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0102902:	8b 45 08             	mov    0x8(%ebp),%eax
c0102905:	83 e0 01             	and    $0x1,%eax
c0102908:	85 c0                	test   %eax,%eax
c010290a:	75 1c                	jne    c0102928 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c010290c:	c7 44 24 08 84 74 10 	movl   $0xc0107484,0x8(%esp)
c0102913:	c0 
c0102914:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c010291b:	00 
c010291c:	c7 04 24 4f 74 10 c0 	movl   $0xc010744f,(%esp)
c0102923:	e8 c1 da ff ff       	call   c01003e9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0102928:	8b 45 08             	mov    0x8(%ebp),%eax
c010292b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102930:	89 04 24             	mov    %eax,(%esp)
c0102933:	e8 21 ff ff ff       	call   c0102859 <pa2page>
}
c0102938:	c9                   	leave  
c0102939:	c3                   	ret    

c010293a <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c010293a:	55                   	push   %ebp
c010293b:	89 e5                	mov    %esp,%ebp
c010293d:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0102940:	8b 45 08             	mov    0x8(%ebp),%eax
c0102943:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102948:	89 04 24             	mov    %eax,(%esp)
c010294b:	e8 09 ff ff ff       	call   c0102859 <pa2page>
}
c0102950:	c9                   	leave  
c0102951:	c3                   	ret    

c0102952 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0102952:	55                   	push   %ebp
c0102953:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102955:	8b 45 08             	mov    0x8(%ebp),%eax
c0102958:	8b 00                	mov    (%eax),%eax
}
c010295a:	5d                   	pop    %ebp
c010295b:	c3                   	ret    

c010295c <page_ref_inc>:
set_page_ref(struct Page *page, int val) {
    page->ref = val;
}

static inline int
page_ref_inc(struct Page *page) {
c010295c:	55                   	push   %ebp
c010295d:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c010295f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102962:	8b 00                	mov    (%eax),%eax
c0102964:	8d 50 01             	lea    0x1(%eax),%edx
c0102967:	8b 45 08             	mov    0x8(%ebp),%eax
c010296a:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010296c:	8b 45 08             	mov    0x8(%ebp),%eax
c010296f:	8b 00                	mov    (%eax),%eax
}
c0102971:	5d                   	pop    %ebp
c0102972:	c3                   	ret    

c0102973 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0102973:	55                   	push   %ebp
c0102974:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0102976:	8b 45 08             	mov    0x8(%ebp),%eax
c0102979:	8b 00                	mov    (%eax),%eax
c010297b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010297e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102981:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102983:	8b 45 08             	mov    0x8(%ebp),%eax
c0102986:	8b 00                	mov    (%eax),%eax
}
c0102988:	5d                   	pop    %ebp
c0102989:	c3                   	ret    

c010298a <__intr_save>:
__intr_save(void) {
c010298a:	55                   	push   %ebp
c010298b:	89 e5                	mov    %esp,%ebp
c010298d:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102990:	9c                   	pushf  
c0102991:	58                   	pop    %eax
c0102992:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102995:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102998:	25 00 02 00 00       	and    $0x200,%eax
c010299d:	85 c0                	test   %eax,%eax
c010299f:	74 0c                	je     c01029ad <__intr_save+0x23>
        intr_disable();
c01029a1:	e8 e7 ee ff ff       	call   c010188d <intr_disable>
        return 1;
c01029a6:	b8 01 00 00 00       	mov    $0x1,%eax
c01029ab:	eb 05                	jmp    c01029b2 <__intr_save+0x28>
    return 0;
c01029ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01029b2:	c9                   	leave  
c01029b3:	c3                   	ret    

c01029b4 <__intr_restore>:
__intr_restore(bool flag) {
c01029b4:	55                   	push   %ebp
c01029b5:	89 e5                	mov    %esp,%ebp
c01029b7:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01029ba:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01029be:	74 05                	je     c01029c5 <__intr_restore+0x11>
        intr_enable();
c01029c0:	e8 c1 ee ff ff       	call   c0101886 <intr_enable>
}
c01029c5:	90                   	nop
c01029c6:	c9                   	leave  
c01029c7:	c3                   	ret    

c01029c8 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01029c8:	55                   	push   %ebp
c01029c9:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01029cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01029ce:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01029d1:	b8 23 00 00 00       	mov    $0x23,%eax
c01029d6:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01029d8:	b8 23 00 00 00       	mov    $0x23,%eax
c01029dd:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01029df:	b8 10 00 00 00       	mov    $0x10,%eax
c01029e4:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01029e6:	b8 10 00 00 00       	mov    $0x10,%eax
c01029eb:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c01029ed:	b8 10 00 00 00       	mov    $0x10,%eax
c01029f2:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c01029f4:	ea fb 29 10 c0 08 00 	ljmp   $0x8,$0xc01029fb
}
c01029fb:	90                   	nop
c01029fc:	5d                   	pop    %ebp
c01029fd:	c3                   	ret    

c01029fe <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c01029fe:	55                   	push   %ebp
c01029ff:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102a01:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a04:	a3 a4 de 11 c0       	mov    %eax,0xc011dea4
}
c0102a09:	90                   	nop
c0102a0a:	5d                   	pop    %ebp
c0102a0b:	c3                   	ret    

c0102a0c <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102a0c:	55                   	push   %ebp
c0102a0d:	89 e5                	mov    %esp,%ebp
c0102a0f:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102a12:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0102a17:	89 04 24             	mov    %eax,(%esp)
c0102a1a:	e8 df ff ff ff       	call   c01029fe <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102a1f:	66 c7 05 a8 de 11 c0 	movw   $0x10,0xc011dea8
c0102a26:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102a28:	66 c7 05 28 aa 11 c0 	movw   $0x68,0xc011aa28
c0102a2f:	68 00 
c0102a31:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102a36:	0f b7 c0             	movzwl %ax,%eax
c0102a39:	66 a3 2a aa 11 c0    	mov    %ax,0xc011aa2a
c0102a3f:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102a44:	c1 e8 10             	shr    $0x10,%eax
c0102a47:	a2 2c aa 11 c0       	mov    %al,0xc011aa2c
c0102a4c:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102a53:	24 f0                	and    $0xf0,%al
c0102a55:	0c 09                	or     $0x9,%al
c0102a57:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102a5c:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102a63:	24 ef                	and    $0xef,%al
c0102a65:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102a6a:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102a71:	24 9f                	and    $0x9f,%al
c0102a73:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102a78:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102a7f:	0c 80                	or     $0x80,%al
c0102a81:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102a86:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102a8d:	24 f0                	and    $0xf0,%al
c0102a8f:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102a94:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102a9b:	24 ef                	and    $0xef,%al
c0102a9d:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102aa2:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102aa9:	24 df                	and    $0xdf,%al
c0102aab:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102ab0:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102ab7:	0c 40                	or     $0x40,%al
c0102ab9:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102abe:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102ac5:	24 7f                	and    $0x7f,%al
c0102ac7:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102acc:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102ad1:	c1 e8 18             	shr    $0x18,%eax
c0102ad4:	a2 2f aa 11 c0       	mov    %al,0xc011aa2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102ad9:	c7 04 24 30 aa 11 c0 	movl   $0xc011aa30,(%esp)
c0102ae0:	e8 e3 fe ff ff       	call   c01029c8 <lgdt>
c0102ae5:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102aeb:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102aef:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102af2:	90                   	nop
c0102af3:	c9                   	leave  
c0102af4:	c3                   	ret    

c0102af5 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102af5:	55                   	push   %ebp
c0102af6:	89 e5                	mov    %esp,%ebp
c0102af8:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102afb:	c7 05 10 df 11 c0 40 	movl   $0xc0107e40,0xc011df10
c0102b02:	7e 10 c0 
    //pmm_manager = &buddy_system;
    cprintf("memory management: %s\n", pmm_manager->name);
c0102b05:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b0a:	8b 00                	mov    (%eax),%eax
c0102b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102b10:	c7 04 24 b0 74 10 c0 	movl   $0xc01074b0,(%esp)
c0102b17:	e8 76 d7 ff ff       	call   c0100292 <cprintf>
    pmm_manager->init();
c0102b1c:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b21:	8b 40 04             	mov    0x4(%eax),%eax
c0102b24:	ff d0                	call   *%eax
}
c0102b26:	90                   	nop
c0102b27:	c9                   	leave  
c0102b28:	c3                   	ret    

c0102b29 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102b29:	55                   	push   %ebp
c0102b2a:	89 e5                	mov    %esp,%ebp
c0102b2c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102b2f:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b34:	8b 40 08             	mov    0x8(%eax),%eax
c0102b37:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102b3a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102b3e:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b41:	89 14 24             	mov    %edx,(%esp)
c0102b44:	ff d0                	call   *%eax
}
c0102b46:	90                   	nop
c0102b47:	c9                   	leave  
c0102b48:	c3                   	ret    

c0102b49 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102b49:	55                   	push   %ebp
c0102b4a:	89 e5                	mov    %esp,%ebp
c0102b4c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102b4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102b56:	e8 2f fe ff ff       	call   c010298a <__intr_save>
c0102b5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102b5e:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b63:	8b 40 0c             	mov    0xc(%eax),%eax
c0102b66:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b69:	89 14 24             	mov    %edx,(%esp)
c0102b6c:	ff d0                	call   *%eax
c0102b6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b74:	89 04 24             	mov    %eax,(%esp)
c0102b77:	e8 38 fe ff ff       	call   c01029b4 <__intr_restore>
    return page;
c0102b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102b7f:	c9                   	leave  
c0102b80:	c3                   	ret    

c0102b81 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102b81:	55                   	push   %ebp
c0102b82:	89 e5                	mov    %esp,%ebp
c0102b84:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102b87:	e8 fe fd ff ff       	call   c010298a <__intr_save>
c0102b8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102b8f:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b94:	8b 40 10             	mov    0x10(%eax),%eax
c0102b97:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102b9a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102b9e:	8b 55 08             	mov    0x8(%ebp),%edx
c0102ba1:	89 14 24             	mov    %edx,(%esp)
c0102ba4:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ba9:	89 04 24             	mov    %eax,(%esp)
c0102bac:	e8 03 fe ff ff       	call   c01029b4 <__intr_restore>
}
c0102bb1:	90                   	nop
c0102bb2:	c9                   	leave  
c0102bb3:	c3                   	ret    

c0102bb4 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102bb4:	55                   	push   %ebp
c0102bb5:	89 e5                	mov    %esp,%ebp
c0102bb7:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102bba:	e8 cb fd ff ff       	call   c010298a <__intr_save>
c0102bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102bc2:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102bc7:	8b 40 14             	mov    0x14(%eax),%eax
c0102bca:	ff d0                	call   *%eax
c0102bcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bd2:	89 04 24             	mov    %eax,(%esp)
c0102bd5:	e8 da fd ff ff       	call   c01029b4 <__intr_restore>
    return ret;
c0102bda:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102bdd:	c9                   	leave  
c0102bde:	c3                   	ret    

c0102bdf <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102bdf:	55                   	push   %ebp
c0102be0:	89 e5                	mov    %esp,%ebp
c0102be2:	57                   	push   %edi
c0102be3:	56                   	push   %esi
c0102be4:	53                   	push   %ebx
c0102be5:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102beb:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102bf2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102bf9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102c00:	c7 04 24 c7 74 10 c0 	movl   $0xc01074c7,(%esp)
c0102c07:	e8 86 d6 ff ff       	call   c0100292 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102c0c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102c13:	e9 22 01 00 00       	jmp    c0102d3a <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102c18:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c1b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c1e:	89 d0                	mov    %edx,%eax
c0102c20:	c1 e0 02             	shl    $0x2,%eax
c0102c23:	01 d0                	add    %edx,%eax
c0102c25:	c1 e0 02             	shl    $0x2,%eax
c0102c28:	01 c8                	add    %ecx,%eax
c0102c2a:	8b 50 08             	mov    0x8(%eax),%edx
c0102c2d:	8b 40 04             	mov    0x4(%eax),%eax
c0102c30:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0102c33:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102c36:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c39:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c3c:	89 d0                	mov    %edx,%eax
c0102c3e:	c1 e0 02             	shl    $0x2,%eax
c0102c41:	01 d0                	add    %edx,%eax
c0102c43:	c1 e0 02             	shl    $0x2,%eax
c0102c46:	01 c8                	add    %ecx,%eax
c0102c48:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102c4b:	8b 58 10             	mov    0x10(%eax),%ebx
c0102c4e:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102c51:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102c54:	01 c8                	add    %ecx,%eax
c0102c56:	11 da                	adc    %ebx,%edx
c0102c58:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102c5b:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102c5e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c61:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c64:	89 d0                	mov    %edx,%eax
c0102c66:	c1 e0 02             	shl    $0x2,%eax
c0102c69:	01 d0                	add    %edx,%eax
c0102c6b:	c1 e0 02             	shl    $0x2,%eax
c0102c6e:	01 c8                	add    %ecx,%eax
c0102c70:	83 c0 14             	add    $0x14,%eax
c0102c73:	8b 00                	mov    (%eax),%eax
c0102c75:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102c78:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102c7b:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102c7e:	83 c0 ff             	add    $0xffffffff,%eax
c0102c81:	83 d2 ff             	adc    $0xffffffff,%edx
c0102c84:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102c8a:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102c90:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c93:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c96:	89 d0                	mov    %edx,%eax
c0102c98:	c1 e0 02             	shl    $0x2,%eax
c0102c9b:	01 d0                	add    %edx,%eax
c0102c9d:	c1 e0 02             	shl    $0x2,%eax
c0102ca0:	01 c8                	add    %ecx,%eax
c0102ca2:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102ca5:	8b 58 10             	mov    0x10(%eax),%ebx
c0102ca8:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102cab:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102caf:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102cb5:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102cbb:	89 44 24 14          	mov    %eax,0x14(%esp)
c0102cbf:	89 54 24 18          	mov    %edx,0x18(%esp)
c0102cc3:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102cc6:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102cc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102ccd:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102cd1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102cd5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102cd9:	c7 04 24 d4 74 10 c0 	movl   $0xc01074d4,(%esp)
c0102ce0:	e8 ad d5 ff ff       	call   c0100292 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102ce5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ce8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ceb:	89 d0                	mov    %edx,%eax
c0102ced:	c1 e0 02             	shl    $0x2,%eax
c0102cf0:	01 d0                	add    %edx,%eax
c0102cf2:	c1 e0 02             	shl    $0x2,%eax
c0102cf5:	01 c8                	add    %ecx,%eax
c0102cf7:	83 c0 14             	add    $0x14,%eax
c0102cfa:	8b 00                	mov    (%eax),%eax
c0102cfc:	83 f8 01             	cmp    $0x1,%eax
c0102cff:	75 36                	jne    c0102d37 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0102d01:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d04:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d07:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102d0a:	77 2b                	ja     c0102d37 <page_init+0x158>
c0102d0c:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102d0f:	72 05                	jb     c0102d16 <page_init+0x137>
c0102d11:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0102d14:	73 21                	jae    c0102d37 <page_init+0x158>
c0102d16:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102d1a:	77 1b                	ja     c0102d37 <page_init+0x158>
c0102d1c:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102d20:	72 09                	jb     c0102d2b <page_init+0x14c>
c0102d22:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c0102d29:	77 0c                	ja     c0102d37 <page_init+0x158>
                maxpa = end;
c0102d2b:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102d2e:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102d31:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102d34:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0102d37:	ff 45 dc             	incl   -0x24(%ebp)
c0102d3a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102d3d:	8b 00                	mov    (%eax),%eax
c0102d3f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102d42:	0f 8c d0 fe ff ff    	jl     c0102c18 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102d48:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102d4c:	72 1d                	jb     c0102d6b <page_init+0x18c>
c0102d4e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102d52:	77 09                	ja     c0102d5d <page_init+0x17e>
c0102d54:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102d5b:	76 0e                	jbe    c0102d6b <page_init+0x18c>
        maxpa = KMEMSIZE;
c0102d5d:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102d64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d71:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102d75:	c1 ea 0c             	shr    $0xc,%edx
c0102d78:	89 c1                	mov    %eax,%ecx
c0102d7a:	89 d3                	mov    %edx,%ebx
c0102d7c:	89 c8                	mov    %ecx,%eax
c0102d7e:	a3 80 de 11 c0       	mov    %eax,0xc011de80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102d83:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0102d8a:	b8 bc df 11 c0       	mov    $0xc011dfbc,%eax
c0102d8f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102d92:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102d95:	01 d0                	add    %edx,%eax
c0102d97:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0102d9a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102d9d:	ba 00 00 00 00       	mov    $0x0,%edx
c0102da2:	f7 75 c0             	divl   -0x40(%ebp)
c0102da5:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102da8:	29 d0                	sub    %edx,%eax
c0102daa:	a3 18 df 11 c0       	mov    %eax,0xc011df18

    for (i = 0; i < npage; i ++) {
c0102daf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102db6:	eb 2e                	jmp    c0102de6 <page_init+0x207>
        SetPageReserved(pages + i);
c0102db8:	8b 0d 18 df 11 c0    	mov    0xc011df18,%ecx
c0102dbe:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102dc1:	89 d0                	mov    %edx,%eax
c0102dc3:	c1 e0 02             	shl    $0x2,%eax
c0102dc6:	01 d0                	add    %edx,%eax
c0102dc8:	c1 e0 02             	shl    $0x2,%eax
c0102dcb:	01 c8                	add    %ecx,%eax
c0102dcd:	83 c0 04             	add    $0x4,%eax
c0102dd0:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0102dd7:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102dda:	8b 45 90             	mov    -0x70(%ebp),%eax
c0102ddd:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0102de0:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0102de3:	ff 45 dc             	incl   -0x24(%ebp)
c0102de6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102de9:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0102dee:	39 c2                	cmp    %eax,%edx
c0102df0:	72 c6                	jb     c0102db8 <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102df2:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0102df8:	89 d0                	mov    %edx,%eax
c0102dfa:	c1 e0 02             	shl    $0x2,%eax
c0102dfd:	01 d0                	add    %edx,%eax
c0102dff:	c1 e0 02             	shl    $0x2,%eax
c0102e02:	89 c2                	mov    %eax,%edx
c0102e04:	a1 18 df 11 c0       	mov    0xc011df18,%eax
c0102e09:	01 d0                	add    %edx,%eax
c0102e0b:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102e0e:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0102e15:	77 23                	ja     c0102e3a <page_init+0x25b>
c0102e17:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102e1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102e1e:	c7 44 24 08 04 75 10 	movl   $0xc0107504,0x8(%esp)
c0102e25:	c0 
c0102e26:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0102e2d:	00 
c0102e2e:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0102e35:	e8 af d5 ff ff       	call   c01003e9 <__panic>
c0102e3a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102e3d:	05 00 00 00 40       	add    $0x40000000,%eax
c0102e42:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0102e45:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e4c:	e9 69 01 00 00       	jmp    c0102fba <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102e51:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e54:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e57:	89 d0                	mov    %edx,%eax
c0102e59:	c1 e0 02             	shl    $0x2,%eax
c0102e5c:	01 d0                	add    %edx,%eax
c0102e5e:	c1 e0 02             	shl    $0x2,%eax
c0102e61:	01 c8                	add    %ecx,%eax
c0102e63:	8b 50 08             	mov    0x8(%eax),%edx
c0102e66:	8b 40 04             	mov    0x4(%eax),%eax
c0102e69:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102e6c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102e6f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e72:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e75:	89 d0                	mov    %edx,%eax
c0102e77:	c1 e0 02             	shl    $0x2,%eax
c0102e7a:	01 d0                	add    %edx,%eax
c0102e7c:	c1 e0 02             	shl    $0x2,%eax
c0102e7f:	01 c8                	add    %ecx,%eax
c0102e81:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102e84:	8b 58 10             	mov    0x10(%eax),%ebx
c0102e87:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102e8a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102e8d:	01 c8                	add    %ecx,%eax
c0102e8f:	11 da                	adc    %ebx,%edx
c0102e91:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102e94:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0102e97:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e9a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e9d:	89 d0                	mov    %edx,%eax
c0102e9f:	c1 e0 02             	shl    $0x2,%eax
c0102ea2:	01 d0                	add    %edx,%eax
c0102ea4:	c1 e0 02             	shl    $0x2,%eax
c0102ea7:	01 c8                	add    %ecx,%eax
c0102ea9:	83 c0 14             	add    $0x14,%eax
c0102eac:	8b 00                	mov    (%eax),%eax
c0102eae:	83 f8 01             	cmp    $0x1,%eax
c0102eb1:	0f 85 00 01 00 00    	jne    c0102fb7 <page_init+0x3d8>
            if (begin < freemem) {
c0102eb7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102eba:	ba 00 00 00 00       	mov    $0x0,%edx
c0102ebf:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0102ec2:	77 17                	ja     c0102edb <page_init+0x2fc>
c0102ec4:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0102ec7:	72 05                	jb     c0102ece <page_init+0x2ef>
c0102ec9:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0102ecc:	73 0d                	jae    c0102edb <page_init+0x2fc>
                begin = freemem;
c0102ece:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102ed1:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102ed4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0102edb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102edf:	72 1d                	jb     c0102efe <page_init+0x31f>
c0102ee1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102ee5:	77 09                	ja     c0102ef0 <page_init+0x311>
c0102ee7:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0102eee:	76 0e                	jbe    c0102efe <page_init+0x31f>
                end = KMEMSIZE;
c0102ef0:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0102ef7:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0102efe:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f01:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f04:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f07:	0f 87 aa 00 00 00    	ja     c0102fb7 <page_init+0x3d8>
c0102f0d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f10:	72 09                	jb     c0102f1b <page_init+0x33c>
c0102f12:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102f15:	0f 83 9c 00 00 00    	jae    c0102fb7 <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
c0102f1b:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0102f22:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102f25:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102f28:	01 d0                	add    %edx,%eax
c0102f2a:	48                   	dec    %eax
c0102f2b:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0102f2e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102f31:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f36:	f7 75 b0             	divl   -0x50(%ebp)
c0102f39:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102f3c:	29 d0                	sub    %edx,%eax
c0102f3e:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f43:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f46:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0102f49:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102f4c:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0102f4f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102f52:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f57:	89 c3                	mov    %eax,%ebx
c0102f59:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0102f5f:	89 de                	mov    %ebx,%esi
c0102f61:	89 d0                	mov    %edx,%eax
c0102f63:	83 e0 00             	and    $0x0,%eax
c0102f66:	89 c7                	mov    %eax,%edi
c0102f68:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0102f6b:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0102f6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f71:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f74:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f77:	77 3e                	ja     c0102fb7 <page_init+0x3d8>
c0102f79:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f7c:	72 05                	jb     c0102f83 <page_init+0x3a4>
c0102f7e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102f81:	73 34                	jae    c0102fb7 <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0102f83:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102f86:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102f89:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0102f8c:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0102f8f:	89 c1                	mov    %eax,%ecx
c0102f91:	89 d3                	mov    %edx,%ebx
c0102f93:	89 c8                	mov    %ecx,%eax
c0102f95:	89 da                	mov    %ebx,%edx
c0102f97:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102f9b:	c1 ea 0c             	shr    $0xc,%edx
c0102f9e:	89 c3                	mov    %eax,%ebx
c0102fa0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102fa3:	89 04 24             	mov    %eax,(%esp)
c0102fa6:	e8 ae f8 ff ff       	call   c0102859 <pa2page>
c0102fab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0102faf:	89 04 24             	mov    %eax,(%esp)
c0102fb2:	e8 72 fb ff ff       	call   c0102b29 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0102fb7:	ff 45 dc             	incl   -0x24(%ebp)
c0102fba:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102fbd:	8b 00                	mov    (%eax),%eax
c0102fbf:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102fc2:	0f 8c 89 fe ff ff    	jl     c0102e51 <page_init+0x272>
                }
            }
        }
    }
}
c0102fc8:	90                   	nop
c0102fc9:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0102fcf:	5b                   	pop    %ebx
c0102fd0:	5e                   	pop    %esi
c0102fd1:	5f                   	pop    %edi
c0102fd2:	5d                   	pop    %ebp
c0102fd3:	c3                   	ret    

c0102fd4 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0102fd4:	55                   	push   %ebp
c0102fd5:	89 e5                	mov    %esp,%ebp
c0102fd7:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0102fda:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102fdd:	33 45 14             	xor    0x14(%ebp),%eax
c0102fe0:	25 ff 0f 00 00       	and    $0xfff,%eax
c0102fe5:	85 c0                	test   %eax,%eax
c0102fe7:	74 24                	je     c010300d <boot_map_segment+0x39>
c0102fe9:	c7 44 24 0c 36 75 10 	movl   $0xc0107536,0xc(%esp)
c0102ff0:	c0 
c0102ff1:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0102ff8:	c0 
c0102ff9:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0103000:	00 
c0103001:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103008:	e8 dc d3 ff ff       	call   c01003e9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010300d:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0103014:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103017:	25 ff 0f 00 00       	and    $0xfff,%eax
c010301c:	89 c2                	mov    %eax,%edx
c010301e:	8b 45 10             	mov    0x10(%ebp),%eax
c0103021:	01 c2                	add    %eax,%edx
c0103023:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103026:	01 d0                	add    %edx,%eax
c0103028:	48                   	dec    %eax
c0103029:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010302c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010302f:	ba 00 00 00 00       	mov    $0x0,%edx
c0103034:	f7 75 f0             	divl   -0x10(%ebp)
c0103037:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010303a:	29 d0                	sub    %edx,%eax
c010303c:	c1 e8 0c             	shr    $0xc,%eax
c010303f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103042:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103045:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103048:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010304b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103050:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0103053:	8b 45 14             	mov    0x14(%ebp),%eax
c0103056:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103059:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010305c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103061:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103064:	eb 68                	jmp    c01030ce <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0103066:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010306d:	00 
c010306e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103075:	8b 45 08             	mov    0x8(%ebp),%eax
c0103078:	89 04 24             	mov    %eax,(%esp)
c010307b:	e8 81 01 00 00       	call   c0103201 <get_pte>
c0103080:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0103083:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103087:	75 24                	jne    c01030ad <boot_map_segment+0xd9>
c0103089:	c7 44 24 0c 62 75 10 	movl   $0xc0107562,0xc(%esp)
c0103090:	c0 
c0103091:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103098:	c0 
c0103099:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c01030a0:	00 
c01030a1:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01030a8:	e8 3c d3 ff ff       	call   c01003e9 <__panic>
        *ptep = pa | PTE_P | perm;
c01030ad:	8b 45 14             	mov    0x14(%ebp),%eax
c01030b0:	0b 45 18             	or     0x18(%ebp),%eax
c01030b3:	83 c8 01             	or     $0x1,%eax
c01030b6:	89 c2                	mov    %eax,%edx
c01030b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030bb:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01030bd:	ff 4d f4             	decl   -0xc(%ebp)
c01030c0:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01030c7:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01030ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01030d2:	75 92                	jne    c0103066 <boot_map_segment+0x92>
    }
}
c01030d4:	90                   	nop
c01030d5:	c9                   	leave  
c01030d6:	c3                   	ret    

c01030d7 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01030d7:	55                   	push   %ebp
c01030d8:	89 e5                	mov    %esp,%ebp
c01030da:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01030dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01030e4:	e8 60 fa ff ff       	call   c0102b49 <alloc_pages>
c01030e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01030ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01030f0:	75 1c                	jne    c010310e <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01030f2:	c7 44 24 08 6f 75 10 	movl   $0xc010756f,0x8(%esp)
c01030f9:	c0 
c01030fa:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0103101:	00 
c0103102:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103109:	e8 db d2 ff ff       	call   c01003e9 <__panic>
    }
    return page2kva(p);
c010310e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103111:	89 04 24             	mov    %eax,(%esp)
c0103114:	e8 8f f7 ff ff       	call   c01028a8 <page2kva>
}
c0103119:	c9                   	leave  
c010311a:	c3                   	ret    

c010311b <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010311b:	55                   	push   %ebp
c010311c:	89 e5                	mov    %esp,%ebp
c010311e:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0103121:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103126:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103129:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103130:	77 23                	ja     c0103155 <pmm_init+0x3a>
c0103132:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103135:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103139:	c7 44 24 08 04 75 10 	movl   $0xc0107504,0x8(%esp)
c0103140:	c0 
c0103141:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0103148:	00 
c0103149:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103150:	e8 94 d2 ff ff       	call   c01003e9 <__panic>
c0103155:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103158:	05 00 00 00 40       	add    $0x40000000,%eax
c010315d:	a3 14 df 11 c0       	mov    %eax,0xc011df14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0103162:	e8 8e f9 ff ff       	call   c0102af5 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103167:	e8 73 fa ff ff       	call   c0102bdf <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010316c:	e8 ab 02 00 00       	call   c010341c <check_alloc_page>

    check_pgdir();
c0103171:	e8 c5 02 00 00       	call   c010343b <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0103176:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010317b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010317e:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103185:	77 23                	ja     c01031aa <pmm_init+0x8f>
c0103187:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010318a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010318e:	c7 44 24 08 04 75 10 	movl   $0xc0107504,0x8(%esp)
c0103195:	c0 
c0103196:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c010319d:	00 
c010319e:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01031a5:	e8 3f d2 ff ff       	call   c01003e9 <__panic>
c01031aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031ad:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c01031b3:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01031b8:	05 ac 0f 00 00       	add    $0xfac,%eax
c01031bd:	83 ca 03             	or     $0x3,%edx
c01031c0:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01031c2:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01031c7:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01031ce:	00 
c01031cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01031d6:	00 
c01031d7:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01031de:	38 
c01031df:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01031e6:	c0 
c01031e7:	89 04 24             	mov    %eax,(%esp)
c01031ea:	e8 e5 fd ff ff       	call   c0102fd4 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01031ef:	e8 18 f8 ff ff       	call   c0102a0c <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01031f4:	e8 de 08 00 00       	call   c0103ad7 <check_boot_pgdir>

    print_pgdir();
c01031f9:	e8 57 0d 00 00       	call   c0103f55 <print_pgdir>

}
c01031fe:	90                   	nop
c01031ff:	c9                   	leave  
c0103200:	c3                   	ret    

c0103201 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0103201:	55                   	push   %ebp
c0103202:	89 e5                	mov    %esp,%ebp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
c0103204:	90                   	nop
c0103205:	5d                   	pop    %ebp
c0103206:	c3                   	ret    

c0103207 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0103207:	55                   	push   %ebp
c0103208:	89 e5                	mov    %esp,%ebp
c010320a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010320d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103214:	00 
c0103215:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103218:	89 44 24 04          	mov    %eax,0x4(%esp)
c010321c:	8b 45 08             	mov    0x8(%ebp),%eax
c010321f:	89 04 24             	mov    %eax,(%esp)
c0103222:	e8 da ff ff ff       	call   c0103201 <get_pte>
c0103227:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010322a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010322e:	74 08                	je     c0103238 <get_page+0x31>
        *ptep_store = ptep;
c0103230:	8b 45 10             	mov    0x10(%ebp),%eax
c0103233:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103236:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103238:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010323c:	74 1b                	je     c0103259 <get_page+0x52>
c010323e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103241:	8b 00                	mov    (%eax),%eax
c0103243:	83 e0 01             	and    $0x1,%eax
c0103246:	85 c0                	test   %eax,%eax
c0103248:	74 0f                	je     c0103259 <get_page+0x52>
        return pte2page(*ptep);
c010324a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010324d:	8b 00                	mov    (%eax),%eax
c010324f:	89 04 24             	mov    %eax,(%esp)
c0103252:	e8 a5 f6 ff ff       	call   c01028fc <pte2page>
c0103257:	eb 05                	jmp    c010325e <get_page+0x57>
    }
    return NULL;
c0103259:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010325e:	c9                   	leave  
c010325f:	c3                   	ret    

c0103260 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0103260:	55                   	push   %ebp
c0103261:	89 e5                	mov    %esp,%ebp
c0103263:	83 ec 28             	sub    $0x28,%esp
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
//ex3的代码 
    if (*ptep & PTE_P) {   //PTE_P代表页存在
c0103266:	8b 45 10             	mov    0x10(%ebp),%eax
c0103269:	8b 00                	mov    (%eax),%eax
c010326b:	83 e0 01             	and    $0x1,%eax
c010326e:	85 c0                	test   %eax,%eax
c0103270:	74 4d                	je     c01032bf <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep); //这个函数用于获取物理地址
c0103272:	8b 45 10             	mov    0x10(%ebp),%eax
c0103275:	8b 00                	mov    (%eax),%eax
c0103277:	89 04 24             	mov    %eax,(%esp)
c010327a:	e8 7d f6 ff ff       	call   c01028fc <pte2page>
c010327f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) { //page_ref_dec(page)将ref减1，判断是否只使用了一次（只被二级页表引用一次）
c0103282:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103285:	89 04 24             	mov    %eax,(%esp)
c0103288:	e8 e6 f6 ff ff       	call   c0102973 <page_ref_dec>
c010328d:	85 c0                	test   %eax,%eax
c010328f:	75 13                	jne    c01032a4 <page_remove_pte+0x44>
            free_page(page); //则可以释放这个页
c0103291:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103298:	00 
c0103299:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010329c:	89 04 24             	mov    %eax,(%esp)
c010329f:	e8 dd f8 ff ff       	call   c0102b81 <free_pages>
        }
        *ptep = 0;//如果还有更多的页表应用了它，不能释放，取消二级映射
c01032a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01032a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c01032ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01032b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01032b7:	89 04 24             	mov    %eax,(%esp)
c01032ba:	e8 01 01 00 00       	call   c01033c0 <tlb_invalidate>
    }
}
c01032bf:	90                   	nop
c01032c0:	c9                   	leave  
c01032c1:	c3                   	ret    

c01032c2 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01032c2:	55                   	push   %ebp
c01032c3:	89 e5                	mov    %esp,%ebp
c01032c5:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01032c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01032cf:	00 
c01032d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032d3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01032d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01032da:	89 04 24             	mov    %eax,(%esp)
c01032dd:	e8 1f ff ff ff       	call   c0103201 <get_pte>
c01032e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01032e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032e9:	74 19                	je     c0103304 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01032eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032ee:	89 44 24 08          	mov    %eax,0x8(%esp)
c01032f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01032f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01032fc:	89 04 24             	mov    %eax,(%esp)
c01032ff:	e8 5c ff ff ff       	call   c0103260 <page_remove_pte>
    }
}
c0103304:	90                   	nop
c0103305:	c9                   	leave  
c0103306:	c3                   	ret    

c0103307 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0103307:	55                   	push   %ebp
c0103308:	89 e5                	mov    %esp,%ebp
c010330a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010330d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103314:	00 
c0103315:	8b 45 10             	mov    0x10(%ebp),%eax
c0103318:	89 44 24 04          	mov    %eax,0x4(%esp)
c010331c:	8b 45 08             	mov    0x8(%ebp),%eax
c010331f:	89 04 24             	mov    %eax,(%esp)
c0103322:	e8 da fe ff ff       	call   c0103201 <get_pte>
c0103327:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c010332a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010332e:	75 0a                	jne    c010333a <page_insert+0x33>
        return -E_NO_MEM;
c0103330:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103335:	e9 84 00 00 00       	jmp    c01033be <page_insert+0xb7>
    }
    page_ref_inc(page);
c010333a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010333d:	89 04 24             	mov    %eax,(%esp)
c0103340:	e8 17 f6 ff ff       	call   c010295c <page_ref_inc>
    if (*ptep & PTE_P) {
c0103345:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103348:	8b 00                	mov    (%eax),%eax
c010334a:	83 e0 01             	and    $0x1,%eax
c010334d:	85 c0                	test   %eax,%eax
c010334f:	74 3e                	je     c010338f <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0103351:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103354:	8b 00                	mov    (%eax),%eax
c0103356:	89 04 24             	mov    %eax,(%esp)
c0103359:	e8 9e f5 ff ff       	call   c01028fc <pte2page>
c010335e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0103361:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103364:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103367:	75 0d                	jne    c0103376 <page_insert+0x6f>
            page_ref_dec(page);
c0103369:	8b 45 0c             	mov    0xc(%ebp),%eax
c010336c:	89 04 24             	mov    %eax,(%esp)
c010336f:	e8 ff f5 ff ff       	call   c0102973 <page_ref_dec>
c0103374:	eb 19                	jmp    c010338f <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0103376:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103379:	89 44 24 08          	mov    %eax,0x8(%esp)
c010337d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103380:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103384:	8b 45 08             	mov    0x8(%ebp),%eax
c0103387:	89 04 24             	mov    %eax,(%esp)
c010338a:	e8 d1 fe ff ff       	call   c0103260 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c010338f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103392:	89 04 24             	mov    %eax,(%esp)
c0103395:	e8 a9 f4 ff ff       	call   c0102843 <page2pa>
c010339a:	0b 45 14             	or     0x14(%ebp),%eax
c010339d:	83 c8 01             	or     $0x1,%eax
c01033a0:	89 c2                	mov    %eax,%edx
c01033a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033a5:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01033a7:	8b 45 10             	mov    0x10(%ebp),%eax
c01033aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01033ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01033b1:	89 04 24             	mov    %eax,(%esp)
c01033b4:	e8 07 00 00 00       	call   c01033c0 <tlb_invalidate>
    return 0;
c01033b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01033be:	c9                   	leave  
c01033bf:	c3                   	ret    

c01033c0 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01033c0:	55                   	push   %ebp
c01033c1:	89 e5                	mov    %esp,%ebp
c01033c3:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01033c6:	0f 20 d8             	mov    %cr3,%eax
c01033c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01033cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01033cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01033d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01033d5:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01033dc:	77 23                	ja     c0103401 <tlb_invalidate+0x41>
c01033de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01033e5:	c7 44 24 08 04 75 10 	movl   $0xc0107504,0x8(%esp)
c01033ec:	c0 
c01033ed:	c7 44 24 04 ce 01 00 	movl   $0x1ce,0x4(%esp)
c01033f4:	00 
c01033f5:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01033fc:	e8 e8 cf ff ff       	call   c01003e9 <__panic>
c0103401:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103404:	05 00 00 00 40       	add    $0x40000000,%eax
c0103409:	39 d0                	cmp    %edx,%eax
c010340b:	75 0c                	jne    c0103419 <tlb_invalidate+0x59>
        invlpg((void *)la);
c010340d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103410:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103413:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103416:	0f 01 38             	invlpg (%eax)
    }
}
c0103419:	90                   	nop
c010341a:	c9                   	leave  
c010341b:	c3                   	ret    

c010341c <check_alloc_page>:

static void
check_alloc_page(void) {
c010341c:	55                   	push   %ebp
c010341d:	89 e5                	mov    %esp,%ebp
c010341f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0103422:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0103427:	8b 40 18             	mov    0x18(%eax),%eax
c010342a:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c010342c:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103433:	e8 5a ce ff ff       	call   c0100292 <cprintf>
}
c0103438:	90                   	nop
c0103439:	c9                   	leave  
c010343a:	c3                   	ret    

c010343b <check_pgdir>:

static void
check_pgdir(void) {
c010343b:	55                   	push   %ebp
c010343c:	89 e5                	mov    %esp,%ebp
c010343e:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0103441:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103446:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010344b:	76 24                	jbe    c0103471 <check_pgdir+0x36>
c010344d:	c7 44 24 0c a7 75 10 	movl   $0xc01075a7,0xc(%esp)
c0103454:	c0 
c0103455:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c010345c:	c0 
c010345d:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c0103464:	00 
c0103465:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c010346c:	e8 78 cf ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0103471:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103476:	85 c0                	test   %eax,%eax
c0103478:	74 0e                	je     c0103488 <check_pgdir+0x4d>
c010347a:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010347f:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103484:	85 c0                	test   %eax,%eax
c0103486:	74 24                	je     c01034ac <check_pgdir+0x71>
c0103488:	c7 44 24 0c c4 75 10 	movl   $0xc01075c4,0xc(%esp)
c010348f:	c0 
c0103490:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103497:	c0 
c0103498:	c7 44 24 04 dc 01 00 	movl   $0x1dc,0x4(%esp)
c010349f:	00 
c01034a0:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01034a7:	e8 3d cf ff ff       	call   c01003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01034ac:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01034b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01034b8:	00 
c01034b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01034c0:	00 
c01034c1:	89 04 24             	mov    %eax,(%esp)
c01034c4:	e8 3e fd ff ff       	call   c0103207 <get_page>
c01034c9:	85 c0                	test   %eax,%eax
c01034cb:	74 24                	je     c01034f1 <check_pgdir+0xb6>
c01034cd:	c7 44 24 0c fc 75 10 	movl   $0xc01075fc,0xc(%esp)
c01034d4:	c0 
c01034d5:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c01034dc:	c0 
c01034dd:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
c01034e4:	00 
c01034e5:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01034ec:	e8 f8 ce ff ff       	call   c01003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01034f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01034f8:	e8 4c f6 ff ff       	call   c0102b49 <alloc_pages>
c01034fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0103500:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103505:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010350c:	00 
c010350d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103514:	00 
c0103515:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103518:	89 54 24 04          	mov    %edx,0x4(%esp)
c010351c:	89 04 24             	mov    %eax,(%esp)
c010351f:	e8 e3 fd ff ff       	call   c0103307 <page_insert>
c0103524:	85 c0                	test   %eax,%eax
c0103526:	74 24                	je     c010354c <check_pgdir+0x111>
c0103528:	c7 44 24 0c 24 76 10 	movl   $0xc0107624,0xc(%esp)
c010352f:	c0 
c0103530:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103537:	c0 
c0103538:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c010353f:	00 
c0103540:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103547:	e8 9d ce ff ff       	call   c01003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c010354c:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103551:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103558:	00 
c0103559:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103560:	00 
c0103561:	89 04 24             	mov    %eax,(%esp)
c0103564:	e8 98 fc ff ff       	call   c0103201 <get_pte>
c0103569:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010356c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103570:	75 24                	jne    c0103596 <check_pgdir+0x15b>
c0103572:	c7 44 24 0c 50 76 10 	movl   $0xc0107650,0xc(%esp)
c0103579:	c0 
c010357a:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103581:	c0 
c0103582:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c0103589:	00 
c010358a:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103591:	e8 53 ce ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103596:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103599:	8b 00                	mov    (%eax),%eax
c010359b:	89 04 24             	mov    %eax,(%esp)
c010359e:	e8 59 f3 ff ff       	call   c01028fc <pte2page>
c01035a3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01035a6:	74 24                	je     c01035cc <check_pgdir+0x191>
c01035a8:	c7 44 24 0c 7d 76 10 	movl   $0xc010767d,0xc(%esp)
c01035af:	c0 
c01035b0:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c01035b7:	c0 
c01035b8:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c01035bf:	00 
c01035c0:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01035c7:	e8 1d ce ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 1);
c01035cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035cf:	89 04 24             	mov    %eax,(%esp)
c01035d2:	e8 7b f3 ff ff       	call   c0102952 <page_ref>
c01035d7:	83 f8 01             	cmp    $0x1,%eax
c01035da:	74 24                	je     c0103600 <check_pgdir+0x1c5>
c01035dc:	c7 44 24 0c 93 76 10 	movl   $0xc0107693,0xc(%esp)
c01035e3:	c0 
c01035e4:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c01035eb:	c0 
c01035ec:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c01035f3:	00 
c01035f4:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01035fb:	e8 e9 cd ff ff       	call   c01003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0103600:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103605:	8b 00                	mov    (%eax),%eax
c0103607:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010360c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010360f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103612:	c1 e8 0c             	shr    $0xc,%eax
c0103615:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103618:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c010361d:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103620:	72 23                	jb     c0103645 <check_pgdir+0x20a>
c0103622:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103625:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103629:	c7 44 24 08 60 74 10 	movl   $0xc0107460,0x8(%esp)
c0103630:	c0 
c0103631:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0103638:	00 
c0103639:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103640:	e8 a4 cd ff ff       	call   c01003e9 <__panic>
c0103645:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103648:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010364d:	83 c0 04             	add    $0x4,%eax
c0103650:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0103653:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103658:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010365f:	00 
c0103660:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103667:	00 
c0103668:	89 04 24             	mov    %eax,(%esp)
c010366b:	e8 91 fb ff ff       	call   c0103201 <get_pte>
c0103670:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103673:	74 24                	je     c0103699 <check_pgdir+0x25e>
c0103675:	c7 44 24 0c a8 76 10 	movl   $0xc01076a8,0xc(%esp)
c010367c:	c0 
c010367d:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103684:	c0 
c0103685:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c010368c:	00 
c010368d:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103694:	e8 50 cd ff ff       	call   c01003e9 <__panic>

    p2 = alloc_page();
c0103699:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01036a0:	e8 a4 f4 ff ff       	call   c0102b49 <alloc_pages>
c01036a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01036a8:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01036ad:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01036b4:	00 
c01036b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01036bc:	00 
c01036bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01036c0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01036c4:	89 04 24             	mov    %eax,(%esp)
c01036c7:	e8 3b fc ff ff       	call   c0103307 <page_insert>
c01036cc:	85 c0                	test   %eax,%eax
c01036ce:	74 24                	je     c01036f4 <check_pgdir+0x2b9>
c01036d0:	c7 44 24 0c d0 76 10 	movl   $0xc01076d0,0xc(%esp)
c01036d7:	c0 
c01036d8:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c01036df:	c0 
c01036e0:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c01036e7:	00 
c01036e8:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01036ef:	e8 f5 cc ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01036f4:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01036f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103700:	00 
c0103701:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103708:	00 
c0103709:	89 04 24             	mov    %eax,(%esp)
c010370c:	e8 f0 fa ff ff       	call   c0103201 <get_pte>
c0103711:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103714:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103718:	75 24                	jne    c010373e <check_pgdir+0x303>
c010371a:	c7 44 24 0c 08 77 10 	movl   $0xc0107708,0xc(%esp)
c0103721:	c0 
c0103722:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103729:	c0 
c010372a:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0103731:	00 
c0103732:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103739:	e8 ab cc ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_U);
c010373e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103741:	8b 00                	mov    (%eax),%eax
c0103743:	83 e0 04             	and    $0x4,%eax
c0103746:	85 c0                	test   %eax,%eax
c0103748:	75 24                	jne    c010376e <check_pgdir+0x333>
c010374a:	c7 44 24 0c 38 77 10 	movl   $0xc0107738,0xc(%esp)
c0103751:	c0 
c0103752:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103759:	c0 
c010375a:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c0103761:	00 
c0103762:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103769:	e8 7b cc ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_W);
c010376e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103771:	8b 00                	mov    (%eax),%eax
c0103773:	83 e0 02             	and    $0x2,%eax
c0103776:	85 c0                	test   %eax,%eax
c0103778:	75 24                	jne    c010379e <check_pgdir+0x363>
c010377a:	c7 44 24 0c 46 77 10 	movl   $0xc0107746,0xc(%esp)
c0103781:	c0 
c0103782:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103789:	c0 
c010378a:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c0103791:	00 
c0103792:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103799:	e8 4b cc ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c010379e:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01037a3:	8b 00                	mov    (%eax),%eax
c01037a5:	83 e0 04             	and    $0x4,%eax
c01037a8:	85 c0                	test   %eax,%eax
c01037aa:	75 24                	jne    c01037d0 <check_pgdir+0x395>
c01037ac:	c7 44 24 0c 54 77 10 	movl   $0xc0107754,0xc(%esp)
c01037b3:	c0 
c01037b4:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c01037bb:	c0 
c01037bc:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c01037c3:	00 
c01037c4:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01037cb:	e8 19 cc ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 1);
c01037d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037d3:	89 04 24             	mov    %eax,(%esp)
c01037d6:	e8 77 f1 ff ff       	call   c0102952 <page_ref>
c01037db:	83 f8 01             	cmp    $0x1,%eax
c01037de:	74 24                	je     c0103804 <check_pgdir+0x3c9>
c01037e0:	c7 44 24 0c 6a 77 10 	movl   $0xc010776a,0xc(%esp)
c01037e7:	c0 
c01037e8:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c01037ef:	c0 
c01037f0:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c01037f7:	00 
c01037f8:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01037ff:	e8 e5 cb ff ff       	call   c01003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103804:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103809:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103810:	00 
c0103811:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103818:	00 
c0103819:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010381c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103820:	89 04 24             	mov    %eax,(%esp)
c0103823:	e8 df fa ff ff       	call   c0103307 <page_insert>
c0103828:	85 c0                	test   %eax,%eax
c010382a:	74 24                	je     c0103850 <check_pgdir+0x415>
c010382c:	c7 44 24 0c 7c 77 10 	movl   $0xc010777c,0xc(%esp)
c0103833:	c0 
c0103834:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c010383b:	c0 
c010383c:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c0103843:	00 
c0103844:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c010384b:	e8 99 cb ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 2);
c0103850:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103853:	89 04 24             	mov    %eax,(%esp)
c0103856:	e8 f7 f0 ff ff       	call   c0102952 <page_ref>
c010385b:	83 f8 02             	cmp    $0x2,%eax
c010385e:	74 24                	je     c0103884 <check_pgdir+0x449>
c0103860:	c7 44 24 0c a8 77 10 	movl   $0xc01077a8,0xc(%esp)
c0103867:	c0 
c0103868:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c010386f:	c0 
c0103870:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0103877:	00 
c0103878:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c010387f:	e8 65 cb ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103887:	89 04 24             	mov    %eax,(%esp)
c010388a:	e8 c3 f0 ff ff       	call   c0102952 <page_ref>
c010388f:	85 c0                	test   %eax,%eax
c0103891:	74 24                	je     c01038b7 <check_pgdir+0x47c>
c0103893:	c7 44 24 0c ba 77 10 	movl   $0xc01077ba,0xc(%esp)
c010389a:	c0 
c010389b:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c01038a2:	c0 
c01038a3:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c01038aa:	00 
c01038ab:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01038b2:	e8 32 cb ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01038b7:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01038bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01038c3:	00 
c01038c4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01038cb:	00 
c01038cc:	89 04 24             	mov    %eax,(%esp)
c01038cf:	e8 2d f9 ff ff       	call   c0103201 <get_pte>
c01038d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01038d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01038db:	75 24                	jne    c0103901 <check_pgdir+0x4c6>
c01038dd:	c7 44 24 0c 08 77 10 	movl   $0xc0107708,0xc(%esp)
c01038e4:	c0 
c01038e5:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c01038ec:	c0 
c01038ed:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c01038f4:	00 
c01038f5:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01038fc:	e8 e8 ca ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103901:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103904:	8b 00                	mov    (%eax),%eax
c0103906:	89 04 24             	mov    %eax,(%esp)
c0103909:	e8 ee ef ff ff       	call   c01028fc <pte2page>
c010390e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103911:	74 24                	je     c0103937 <check_pgdir+0x4fc>
c0103913:	c7 44 24 0c 7d 76 10 	movl   $0xc010767d,0xc(%esp)
c010391a:	c0 
c010391b:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103922:	c0 
c0103923:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c010392a:	00 
c010392b:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103932:	e8 b2 ca ff ff       	call   c01003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103937:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010393a:	8b 00                	mov    (%eax),%eax
c010393c:	83 e0 04             	and    $0x4,%eax
c010393f:	85 c0                	test   %eax,%eax
c0103941:	74 24                	je     c0103967 <check_pgdir+0x52c>
c0103943:	c7 44 24 0c cc 77 10 	movl   $0xc01077cc,0xc(%esp)
c010394a:	c0 
c010394b:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103952:	c0 
c0103953:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c010395a:	00 
c010395b:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103962:	e8 82 ca ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103967:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010396c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103973:	00 
c0103974:	89 04 24             	mov    %eax,(%esp)
c0103977:	e8 46 f9 ff ff       	call   c01032c2 <page_remove>
    assert(page_ref(p1) == 1);
c010397c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010397f:	89 04 24             	mov    %eax,(%esp)
c0103982:	e8 cb ef ff ff       	call   c0102952 <page_ref>
c0103987:	83 f8 01             	cmp    $0x1,%eax
c010398a:	74 24                	je     c01039b0 <check_pgdir+0x575>
c010398c:	c7 44 24 0c 93 76 10 	movl   $0xc0107693,0xc(%esp)
c0103993:	c0 
c0103994:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c010399b:	c0 
c010399c:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c01039a3:	00 
c01039a4:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01039ab:	e8 39 ca ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c01039b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039b3:	89 04 24             	mov    %eax,(%esp)
c01039b6:	e8 97 ef ff ff       	call   c0102952 <page_ref>
c01039bb:	85 c0                	test   %eax,%eax
c01039bd:	74 24                	je     c01039e3 <check_pgdir+0x5a8>
c01039bf:	c7 44 24 0c ba 77 10 	movl   $0xc01077ba,0xc(%esp)
c01039c6:	c0 
c01039c7:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c01039ce:	c0 
c01039cf:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c01039d6:	00 
c01039d7:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01039de:	e8 06 ca ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01039e3:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01039e8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01039ef:	00 
c01039f0:	89 04 24             	mov    %eax,(%esp)
c01039f3:	e8 ca f8 ff ff       	call   c01032c2 <page_remove>
    assert(page_ref(p1) == 0);
c01039f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039fb:	89 04 24             	mov    %eax,(%esp)
c01039fe:	e8 4f ef ff ff       	call   c0102952 <page_ref>
c0103a03:	85 c0                	test   %eax,%eax
c0103a05:	74 24                	je     c0103a2b <check_pgdir+0x5f0>
c0103a07:	c7 44 24 0c e1 77 10 	movl   $0xc01077e1,0xc(%esp)
c0103a0e:	c0 
c0103a0f:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103a16:	c0 
c0103a17:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0103a1e:	00 
c0103a1f:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103a26:	e8 be c9 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103a2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a2e:	89 04 24             	mov    %eax,(%esp)
c0103a31:	e8 1c ef ff ff       	call   c0102952 <page_ref>
c0103a36:	85 c0                	test   %eax,%eax
c0103a38:	74 24                	je     c0103a5e <check_pgdir+0x623>
c0103a3a:	c7 44 24 0c ba 77 10 	movl   $0xc01077ba,0xc(%esp)
c0103a41:	c0 
c0103a42:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103a49:	c0 
c0103a4a:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0103a51:	00 
c0103a52:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103a59:	e8 8b c9 ff ff       	call   c01003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103a5e:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103a63:	8b 00                	mov    (%eax),%eax
c0103a65:	89 04 24             	mov    %eax,(%esp)
c0103a68:	e8 cd ee ff ff       	call   c010293a <pde2page>
c0103a6d:	89 04 24             	mov    %eax,(%esp)
c0103a70:	e8 dd ee ff ff       	call   c0102952 <page_ref>
c0103a75:	83 f8 01             	cmp    $0x1,%eax
c0103a78:	74 24                	je     c0103a9e <check_pgdir+0x663>
c0103a7a:	c7 44 24 0c f4 77 10 	movl   $0xc01077f4,0xc(%esp)
c0103a81:	c0 
c0103a82:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103a89:	c0 
c0103a8a:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c0103a91:	00 
c0103a92:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103a99:	e8 4b c9 ff ff       	call   c01003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103a9e:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103aa3:	8b 00                	mov    (%eax),%eax
c0103aa5:	89 04 24             	mov    %eax,(%esp)
c0103aa8:	e8 8d ee ff ff       	call   c010293a <pde2page>
c0103aad:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ab4:	00 
c0103ab5:	89 04 24             	mov    %eax,(%esp)
c0103ab8:	e8 c4 f0 ff ff       	call   c0102b81 <free_pages>
    boot_pgdir[0] = 0;
c0103abd:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103ac2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103ac8:	c7 04 24 1b 78 10 c0 	movl   $0xc010781b,(%esp)
c0103acf:	e8 be c7 ff ff       	call   c0100292 <cprintf>
}
c0103ad4:	90                   	nop
c0103ad5:	c9                   	leave  
c0103ad6:	c3                   	ret    

c0103ad7 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103ad7:	55                   	push   %ebp
c0103ad8:	89 e5                	mov    %esp,%ebp
c0103ada:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103add:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103ae4:	e9 ca 00 00 00       	jmp    c0103bb3 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103aef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103af2:	c1 e8 0c             	shr    $0xc,%eax
c0103af5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103af8:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103afd:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103b00:	72 23                	jb     c0103b25 <check_boot_pgdir+0x4e>
c0103b02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b05:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b09:	c7 44 24 08 60 74 10 	movl   $0xc0107460,0x8(%esp)
c0103b10:	c0 
c0103b11:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0103b18:	00 
c0103b19:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103b20:	e8 c4 c8 ff ff       	call   c01003e9 <__panic>
c0103b25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b28:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103b2d:	89 c2                	mov    %eax,%edx
c0103b2f:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103b34:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103b3b:	00 
c0103b3c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103b40:	89 04 24             	mov    %eax,(%esp)
c0103b43:	e8 b9 f6 ff ff       	call   c0103201 <get_pte>
c0103b48:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103b4b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103b4f:	75 24                	jne    c0103b75 <check_boot_pgdir+0x9e>
c0103b51:	c7 44 24 0c 38 78 10 	movl   $0xc0107838,0xc(%esp)
c0103b58:	c0 
c0103b59:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103b60:	c0 
c0103b61:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0103b68:	00 
c0103b69:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103b70:	e8 74 c8 ff ff       	call   c01003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103b75:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b78:	8b 00                	mov    (%eax),%eax
c0103b7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b7f:	89 c2                	mov    %eax,%edx
c0103b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b84:	39 c2                	cmp    %eax,%edx
c0103b86:	74 24                	je     c0103bac <check_boot_pgdir+0xd5>
c0103b88:	c7 44 24 0c 75 78 10 	movl   $0xc0107875,0xc(%esp)
c0103b8f:	c0 
c0103b90:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103b97:	c0 
c0103b98:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0103b9f:	00 
c0103ba0:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103ba7:	e8 3d c8 ff ff       	call   c01003e9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0103bac:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103bb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103bb6:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103bbb:	39 c2                	cmp    %eax,%edx
c0103bbd:	0f 82 26 ff ff ff    	jb     c0103ae9 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103bc3:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103bc8:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103bcd:	8b 00                	mov    (%eax),%eax
c0103bcf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103bd4:	89 c2                	mov    %eax,%edx
c0103bd6:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103bdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103bde:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103be5:	77 23                	ja     c0103c0a <check_boot_pgdir+0x133>
c0103be7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bea:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103bee:	c7 44 24 08 04 75 10 	movl   $0xc0107504,0x8(%esp)
c0103bf5:	c0 
c0103bf6:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0103bfd:	00 
c0103bfe:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103c05:	e8 df c7 ff ff       	call   c01003e9 <__panic>
c0103c0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c0d:	05 00 00 00 40       	add    $0x40000000,%eax
c0103c12:	39 d0                	cmp    %edx,%eax
c0103c14:	74 24                	je     c0103c3a <check_boot_pgdir+0x163>
c0103c16:	c7 44 24 0c 8c 78 10 	movl   $0xc010788c,0xc(%esp)
c0103c1d:	c0 
c0103c1e:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103c25:	c0 
c0103c26:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0103c2d:	00 
c0103c2e:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103c35:	e8 af c7 ff ff       	call   c01003e9 <__panic>

    assert(boot_pgdir[0] == 0);
c0103c3a:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103c3f:	8b 00                	mov    (%eax),%eax
c0103c41:	85 c0                	test   %eax,%eax
c0103c43:	74 24                	je     c0103c69 <check_boot_pgdir+0x192>
c0103c45:	c7 44 24 0c c0 78 10 	movl   $0xc01078c0,0xc(%esp)
c0103c4c:	c0 
c0103c4d:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103c54:	c0 
c0103c55:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0103c5c:	00 
c0103c5d:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103c64:	e8 80 c7 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    p = alloc_page();
c0103c69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c70:	e8 d4 ee ff ff       	call   c0102b49 <alloc_pages>
c0103c75:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103c78:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103c7d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103c84:	00 
c0103c85:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103c8c:	00 
c0103c8d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103c90:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103c94:	89 04 24             	mov    %eax,(%esp)
c0103c97:	e8 6b f6 ff ff       	call   c0103307 <page_insert>
c0103c9c:	85 c0                	test   %eax,%eax
c0103c9e:	74 24                	je     c0103cc4 <check_boot_pgdir+0x1ed>
c0103ca0:	c7 44 24 0c d4 78 10 	movl   $0xc01078d4,0xc(%esp)
c0103ca7:	c0 
c0103ca8:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103caf:	c0 
c0103cb0:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0103cb7:	00 
c0103cb8:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103cbf:	e8 25 c7 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 1);
c0103cc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103cc7:	89 04 24             	mov    %eax,(%esp)
c0103cca:	e8 83 ec ff ff       	call   c0102952 <page_ref>
c0103ccf:	83 f8 01             	cmp    $0x1,%eax
c0103cd2:	74 24                	je     c0103cf8 <check_boot_pgdir+0x221>
c0103cd4:	c7 44 24 0c 02 79 10 	movl   $0xc0107902,0xc(%esp)
c0103cdb:	c0 
c0103cdc:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103ce3:	c0 
c0103ce4:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0103ceb:	00 
c0103cec:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103cf3:	e8 f1 c6 ff ff       	call   c01003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0103cf8:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103cfd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103d04:	00 
c0103d05:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0103d0c:	00 
c0103d0d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103d10:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103d14:	89 04 24             	mov    %eax,(%esp)
c0103d17:	e8 eb f5 ff ff       	call   c0103307 <page_insert>
c0103d1c:	85 c0                	test   %eax,%eax
c0103d1e:	74 24                	je     c0103d44 <check_boot_pgdir+0x26d>
c0103d20:	c7 44 24 0c 14 79 10 	movl   $0xc0107914,0xc(%esp)
c0103d27:	c0 
c0103d28:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103d2f:	c0 
c0103d30:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0103d37:	00 
c0103d38:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103d3f:	e8 a5 c6 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 2);
c0103d44:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d47:	89 04 24             	mov    %eax,(%esp)
c0103d4a:	e8 03 ec ff ff       	call   c0102952 <page_ref>
c0103d4f:	83 f8 02             	cmp    $0x2,%eax
c0103d52:	74 24                	je     c0103d78 <check_boot_pgdir+0x2a1>
c0103d54:	c7 44 24 0c 4b 79 10 	movl   $0xc010794b,0xc(%esp)
c0103d5b:	c0 
c0103d5c:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103d63:	c0 
c0103d64:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0103d6b:	00 
c0103d6c:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103d73:	e8 71 c6 ff ff       	call   c01003e9 <__panic>

    const char *str = "ucore: Hello world!!";
c0103d78:	c7 45 e8 5c 79 10 c0 	movl   $0xc010795c,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0103d7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d82:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d86:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103d8d:	e8 bd 24 00 00       	call   c010624f <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0103d92:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0103d99:	00 
c0103d9a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103da1:	e8 20 25 00 00       	call   c01062c6 <strcmp>
c0103da6:	85 c0                	test   %eax,%eax
c0103da8:	74 24                	je     c0103dce <check_boot_pgdir+0x2f7>
c0103daa:	c7 44 24 0c 74 79 10 	movl   $0xc0107974,0xc(%esp)
c0103db1:	c0 
c0103db2:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103db9:	c0 
c0103dba:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0103dc1:	00 
c0103dc2:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103dc9:	e8 1b c6 ff ff       	call   c01003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0103dce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103dd1:	89 04 24             	mov    %eax,(%esp)
c0103dd4:	e8 cf ea ff ff       	call   c01028a8 <page2kva>
c0103dd9:	05 00 01 00 00       	add    $0x100,%eax
c0103dde:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0103de1:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103de8:	e8 0c 24 00 00       	call   c01061f9 <strlen>
c0103ded:	85 c0                	test   %eax,%eax
c0103def:	74 24                	je     c0103e15 <check_boot_pgdir+0x33e>
c0103df1:	c7 44 24 0c ac 79 10 	movl   $0xc01079ac,0xc(%esp)
c0103df8:	c0 
c0103df9:	c7 44 24 08 4d 75 10 	movl   $0xc010754d,0x8(%esp)
c0103e00:	c0 
c0103e01:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0103e08:	00 
c0103e09:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c0103e10:	e8 d4 c5 ff ff       	call   c01003e9 <__panic>

    free_page(p);
c0103e15:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e1c:	00 
c0103e1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e20:	89 04 24             	mov    %eax,(%esp)
c0103e23:	e8 59 ed ff ff       	call   c0102b81 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0103e28:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103e2d:	8b 00                	mov    (%eax),%eax
c0103e2f:	89 04 24             	mov    %eax,(%esp)
c0103e32:	e8 03 eb ff ff       	call   c010293a <pde2page>
c0103e37:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e3e:	00 
c0103e3f:	89 04 24             	mov    %eax,(%esp)
c0103e42:	e8 3a ed ff ff       	call   c0102b81 <free_pages>
    boot_pgdir[0] = 0;
c0103e47:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103e4c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0103e52:	c7 04 24 d0 79 10 c0 	movl   $0xc01079d0,(%esp)
c0103e59:	e8 34 c4 ff ff       	call   c0100292 <cprintf>
}
c0103e5e:	90                   	nop
c0103e5f:	c9                   	leave  
c0103e60:	c3                   	ret    

c0103e61 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0103e61:	55                   	push   %ebp
c0103e62:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0103e64:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e67:	83 e0 04             	and    $0x4,%eax
c0103e6a:	85 c0                	test   %eax,%eax
c0103e6c:	74 04                	je     c0103e72 <perm2str+0x11>
c0103e6e:	b0 75                	mov    $0x75,%al
c0103e70:	eb 02                	jmp    c0103e74 <perm2str+0x13>
c0103e72:	b0 2d                	mov    $0x2d,%al
c0103e74:	a2 08 df 11 c0       	mov    %al,0xc011df08
    str[1] = 'r';
c0103e79:	c6 05 09 df 11 c0 72 	movb   $0x72,0xc011df09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0103e80:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e83:	83 e0 02             	and    $0x2,%eax
c0103e86:	85 c0                	test   %eax,%eax
c0103e88:	74 04                	je     c0103e8e <perm2str+0x2d>
c0103e8a:	b0 77                	mov    $0x77,%al
c0103e8c:	eb 02                	jmp    c0103e90 <perm2str+0x2f>
c0103e8e:	b0 2d                	mov    $0x2d,%al
c0103e90:	a2 0a df 11 c0       	mov    %al,0xc011df0a
    str[3] = '\0';
c0103e95:	c6 05 0b df 11 c0 00 	movb   $0x0,0xc011df0b
    return str;
c0103e9c:	b8 08 df 11 c0       	mov    $0xc011df08,%eax
}
c0103ea1:	5d                   	pop    %ebp
c0103ea2:	c3                   	ret    

c0103ea3 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0103ea3:	55                   	push   %ebp
c0103ea4:	89 e5                	mov    %esp,%ebp
c0103ea6:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0103ea9:	8b 45 10             	mov    0x10(%ebp),%eax
c0103eac:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103eaf:	72 0d                	jb     c0103ebe <get_pgtable_items+0x1b>
        return 0;
c0103eb1:	b8 00 00 00 00       	mov    $0x0,%eax
c0103eb6:	e9 98 00 00 00       	jmp    c0103f53 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0103ebb:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0103ebe:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ec1:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103ec4:	73 18                	jae    c0103ede <get_pgtable_items+0x3b>
c0103ec6:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ec9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103ed0:	8b 45 14             	mov    0x14(%ebp),%eax
c0103ed3:	01 d0                	add    %edx,%eax
c0103ed5:	8b 00                	mov    (%eax),%eax
c0103ed7:	83 e0 01             	and    $0x1,%eax
c0103eda:	85 c0                	test   %eax,%eax
c0103edc:	74 dd                	je     c0103ebb <get_pgtable_items+0x18>
    }
    if (start < right) {
c0103ede:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ee1:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103ee4:	73 68                	jae    c0103f4e <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0103ee6:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0103eea:	74 08                	je     c0103ef4 <get_pgtable_items+0x51>
            *left_store = start;
c0103eec:	8b 45 18             	mov    0x18(%ebp),%eax
c0103eef:	8b 55 10             	mov    0x10(%ebp),%edx
c0103ef2:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0103ef4:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ef7:	8d 50 01             	lea    0x1(%eax),%edx
c0103efa:	89 55 10             	mov    %edx,0x10(%ebp)
c0103efd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103f04:	8b 45 14             	mov    0x14(%ebp),%eax
c0103f07:	01 d0                	add    %edx,%eax
c0103f09:	8b 00                	mov    (%eax),%eax
c0103f0b:	83 e0 07             	and    $0x7,%eax
c0103f0e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0103f11:	eb 03                	jmp    c0103f16 <get_pgtable_items+0x73>
            start ++;
c0103f13:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0103f16:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f19:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103f1c:	73 1d                	jae    c0103f3b <get_pgtable_items+0x98>
c0103f1e:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f21:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103f28:	8b 45 14             	mov    0x14(%ebp),%eax
c0103f2b:	01 d0                	add    %edx,%eax
c0103f2d:	8b 00                	mov    (%eax),%eax
c0103f2f:	83 e0 07             	and    $0x7,%eax
c0103f32:	89 c2                	mov    %eax,%edx
c0103f34:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103f37:	39 c2                	cmp    %eax,%edx
c0103f39:	74 d8                	je     c0103f13 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0103f3b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0103f3f:	74 08                	je     c0103f49 <get_pgtable_items+0xa6>
            *right_store = start;
c0103f41:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0103f44:	8b 55 10             	mov    0x10(%ebp),%edx
c0103f47:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0103f49:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103f4c:	eb 05                	jmp    c0103f53 <get_pgtable_items+0xb0>
    }
    return 0;
c0103f4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103f53:	c9                   	leave  
c0103f54:	c3                   	ret    

c0103f55 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0103f55:	55                   	push   %ebp
c0103f56:	89 e5                	mov    %esp,%ebp
c0103f58:	57                   	push   %edi
c0103f59:	56                   	push   %esi
c0103f5a:	53                   	push   %ebx
c0103f5b:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0103f5e:	c7 04 24 f0 79 10 c0 	movl   $0xc01079f0,(%esp)
c0103f65:	e8 28 c3 ff ff       	call   c0100292 <cprintf>
    size_t left, right = 0, perm;
c0103f6a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0103f71:	e9 fa 00 00 00       	jmp    c0104070 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0103f76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f79:	89 04 24             	mov    %eax,(%esp)
c0103f7c:	e8 e0 fe ff ff       	call   c0103e61 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0103f81:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0103f84:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103f87:	29 d1                	sub    %edx,%ecx
c0103f89:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0103f8b:	89 d6                	mov    %edx,%esi
c0103f8d:	c1 e6 16             	shl    $0x16,%esi
c0103f90:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f93:	89 d3                	mov    %edx,%ebx
c0103f95:	c1 e3 16             	shl    $0x16,%ebx
c0103f98:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103f9b:	89 d1                	mov    %edx,%ecx
c0103f9d:	c1 e1 16             	shl    $0x16,%ecx
c0103fa0:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0103fa3:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103fa6:	29 d7                	sub    %edx,%edi
c0103fa8:	89 fa                	mov    %edi,%edx
c0103faa:	89 44 24 14          	mov    %eax,0x14(%esp)
c0103fae:	89 74 24 10          	mov    %esi,0x10(%esp)
c0103fb2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0103fb6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103fba:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103fbe:	c7 04 24 21 7a 10 c0 	movl   $0xc0107a21,(%esp)
c0103fc5:	e8 c8 c2 ff ff       	call   c0100292 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0103fca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fcd:	c1 e0 0a             	shl    $0xa,%eax
c0103fd0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0103fd3:	eb 54                	jmp    c0104029 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0103fd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103fd8:	89 04 24             	mov    %eax,(%esp)
c0103fdb:	e8 81 fe ff ff       	call   c0103e61 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0103fe0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0103fe3:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103fe6:	29 d1                	sub    %edx,%ecx
c0103fe8:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0103fea:	89 d6                	mov    %edx,%esi
c0103fec:	c1 e6 0c             	shl    $0xc,%esi
c0103fef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103ff2:	89 d3                	mov    %edx,%ebx
c0103ff4:	c1 e3 0c             	shl    $0xc,%ebx
c0103ff7:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103ffa:	89 d1                	mov    %edx,%ecx
c0103ffc:	c1 e1 0c             	shl    $0xc,%ecx
c0103fff:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0104002:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104005:	29 d7                	sub    %edx,%edi
c0104007:	89 fa                	mov    %edi,%edx
c0104009:	89 44 24 14          	mov    %eax,0x14(%esp)
c010400d:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104011:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104015:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104019:	89 54 24 04          	mov    %edx,0x4(%esp)
c010401d:	c7 04 24 40 7a 10 c0 	movl   $0xc0107a40,(%esp)
c0104024:	e8 69 c2 ff ff       	call   c0100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104029:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c010402e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104031:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104034:	89 d3                	mov    %edx,%ebx
c0104036:	c1 e3 0a             	shl    $0xa,%ebx
c0104039:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010403c:	89 d1                	mov    %edx,%ecx
c010403e:	c1 e1 0a             	shl    $0xa,%ecx
c0104041:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104044:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104048:	8d 55 d8             	lea    -0x28(%ebp),%edx
c010404b:	89 54 24 10          	mov    %edx,0x10(%esp)
c010404f:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0104053:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104057:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010405b:	89 0c 24             	mov    %ecx,(%esp)
c010405e:	e8 40 fe ff ff       	call   c0103ea3 <get_pgtable_items>
c0104063:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104066:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010406a:	0f 85 65 ff ff ff    	jne    c0103fd5 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104070:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0104075:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104078:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010407b:	89 54 24 14          	mov    %edx,0x14(%esp)
c010407f:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0104082:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104086:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010408a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010408e:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0104095:	00 
c0104096:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010409d:	e8 01 fe ff ff       	call   c0103ea3 <get_pgtable_items>
c01040a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01040a5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01040a9:	0f 85 c7 fe ff ff    	jne    c0103f76 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01040af:	c7 04 24 64 7a 10 c0 	movl   $0xc0107a64,(%esp)
c01040b6:	e8 d7 c1 ff ff       	call   c0100292 <cprintf>
}
c01040bb:	90                   	nop
c01040bc:	83 c4 4c             	add    $0x4c,%esp
c01040bf:	5b                   	pop    %ebx
c01040c0:	5e                   	pop    %esi
c01040c1:	5f                   	pop    %edi
c01040c2:	5d                   	pop    %ebp
c01040c3:	c3                   	ret    

c01040c4 <page2ppn>:
page2ppn(struct Page *page) {
c01040c4:	55                   	push   %ebp
c01040c5:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01040c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01040ca:	8b 15 18 df 11 c0    	mov    0xc011df18,%edx
c01040d0:	29 d0                	sub    %edx,%eax
c01040d2:	c1 f8 02             	sar    $0x2,%eax
c01040d5:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01040db:	5d                   	pop    %ebp
c01040dc:	c3                   	ret    

c01040dd <page2pa>:
page2pa(struct Page *page) {
c01040dd:	55                   	push   %ebp
c01040de:	89 e5                	mov    %esp,%ebp
c01040e0:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01040e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01040e6:	89 04 24             	mov    %eax,(%esp)
c01040e9:	e8 d6 ff ff ff       	call   c01040c4 <page2ppn>
c01040ee:	c1 e0 0c             	shl    $0xc,%eax
}
c01040f1:	c9                   	leave  
c01040f2:	c3                   	ret    

c01040f3 <page_ref>:
page_ref(struct Page *page) {
c01040f3:	55                   	push   %ebp
c01040f4:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01040f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01040f9:	8b 00                	mov    (%eax),%eax
}
c01040fb:	5d                   	pop    %ebp
c01040fc:	c3                   	ret    

c01040fd <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c01040fd:	55                   	push   %ebp
c01040fe:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104100:	8b 45 08             	mov    0x8(%ebp),%eax
c0104103:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104106:	89 10                	mov    %edx,(%eax)
}
c0104108:	90                   	nop
c0104109:	5d                   	pop    %ebp
c010410a:	c3                   	ret    

c010410b <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010410b:	55                   	push   %ebp
c010410c:	89 e5                	mov    %esp,%ebp
c010410e:	83 ec 10             	sub    $0x10,%esp
c0104111:	c7 45 fc 20 df 11 c0 	movl   $0xc011df20,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104118:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010411b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010411e:	89 50 04             	mov    %edx,0x4(%eax)
c0104121:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104124:	8b 50 04             	mov    0x4(%eax),%edx
c0104127:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010412a:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c010412c:	c7 05 28 df 11 c0 00 	movl   $0x0,0xc011df28
c0104133:	00 00 00 
}
c0104136:	90                   	nop
c0104137:	c9                   	leave  
c0104138:	c3                   	ret    

c0104139 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0104139:	55                   	push   %ebp
c010413a:	89 e5                	mov    %esp,%ebp
c010413c:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c010413f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104143:	75 24                	jne    c0104169 <default_init_memmap+0x30>
c0104145:	c7 44 24 0c 98 7a 10 	movl   $0xc0107a98,0xc(%esp)
c010414c:	c0 
c010414d:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104154:	c0 
c0104155:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010415c:	00 
c010415d:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104164:	e8 80 c2 ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c0104169:	8b 45 08             	mov    0x8(%ebp),%eax
c010416c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010416f:	eb 7d                	jmp    c01041ee <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0104171:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104174:	83 c0 04             	add    $0x4,%eax
c0104177:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010417e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104181:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104184:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104187:	0f a3 10             	bt     %edx,(%eax)
c010418a:	19 c0                	sbb    %eax,%eax
c010418c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c010418f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104193:	0f 95 c0             	setne  %al
c0104196:	0f b6 c0             	movzbl %al,%eax
c0104199:	85 c0                	test   %eax,%eax
c010419b:	75 24                	jne    c01041c1 <default_init_memmap+0x88>
c010419d:	c7 44 24 0c c9 7a 10 	movl   $0xc0107ac9,0xc(%esp)
c01041a4:	c0 
c01041a5:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c01041ac:	c0 
c01041ad:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01041b4:	00 
c01041b5:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c01041bc:	e8 28 c2 ff ff       	call   c01003e9 <__panic>
        p->flags = p->property = 0;
c01041c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041c4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01041cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041ce:	8b 50 08             	mov    0x8(%eax),%edx
c01041d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041d4:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01041d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01041de:	00 
c01041df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041e2:	89 04 24             	mov    %eax,(%esp)
c01041e5:	e8 13 ff ff ff       	call   c01040fd <set_page_ref>
    for (; p != base + n; p ++) {
c01041ea:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01041ee:	8b 55 0c             	mov    0xc(%ebp),%edx
c01041f1:	89 d0                	mov    %edx,%eax
c01041f3:	c1 e0 02             	shl    $0x2,%eax
c01041f6:	01 d0                	add    %edx,%eax
c01041f8:	c1 e0 02             	shl    $0x2,%eax
c01041fb:	89 c2                	mov    %eax,%edx
c01041fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0104200:	01 d0                	add    %edx,%eax
c0104202:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104205:	0f 85 66 ff ff ff    	jne    c0104171 <default_init_memmap+0x38>
	
    }
    base->property = n;
c010420b:	8b 45 08             	mov    0x8(%ebp),%eax
c010420e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104211:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104214:	8b 45 08             	mov    0x8(%ebp),%eax
c0104217:	83 c0 04             	add    $0x4,%eax
c010421a:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104221:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104224:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104227:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010422a:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c010422d:	8b 15 28 df 11 c0    	mov    0xc011df28,%edx
c0104233:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104236:	01 d0                	add    %edx,%eax
c0104238:	a3 28 df 11 c0       	mov    %eax,0xc011df28
    list_add_before(&free_list,&(base->page_link));
c010423d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104240:	83 c0 0c             	add    $0xc,%eax
c0104243:	c7 45 e4 20 df 11 c0 	movl   $0xc011df20,-0x1c(%ebp)
c010424a:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010424d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104250:	8b 00                	mov    (%eax),%eax
c0104252:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104255:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0104258:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010425b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010425e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104261:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104264:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104267:	89 10                	mov    %edx,(%eax)
c0104269:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010426c:	8b 10                	mov    (%eax),%edx
c010426e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104271:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104274:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104277:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010427a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010427d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104280:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104283:	89 10                	mov    %edx,(%eax)
}
c0104285:	90                   	nop
c0104286:	c9                   	leave  
c0104287:	c3                   	ret    

c0104288 <default_alloc_pages>:
 *              return `p`.
 *      (4.2)
 *          If we can not find a free block with its size >=n, then return NULL.
*/
static struct Page *
default_alloc_pages(size_t n) {
c0104288:	55                   	push   %ebp
c0104289:	89 e5                	mov    %esp,%ebp
c010428b:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c010428e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104292:	75 24                	jne    c01042b8 <default_alloc_pages+0x30>
c0104294:	c7 44 24 0c 98 7a 10 	movl   $0xc0107a98,0xc(%esp)
c010429b:	c0 
c010429c:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c01042a3:	c0 
c01042a4:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c01042ab:	00 
c01042ac:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c01042b3:	e8 31 c1 ff ff       	call   c01003e9 <__panic>
    if (n > nr_free) {
c01042b8:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c01042bd:	39 45 08             	cmp    %eax,0x8(%ebp)
c01042c0:	76 0a                	jbe    c01042cc <default_alloc_pages+0x44>
        return NULL;
c01042c2:	b8 00 00 00 00       	mov    $0x0,%eax
c01042c7:	e9 49 01 00 00       	jmp    c0104415 <default_alloc_pages+0x18d>
    }
    struct Page *page=NULL;
c01042cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01042d3:	c7 45 f0 20 df 11 c0 	movl   $0xc011df20,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01042da:	eb 1c                	jmp    c01042f8 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c01042dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01042df:	83 e8 0c             	sub    $0xc,%eax
c01042e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c01042e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01042e8:	8b 40 08             	mov    0x8(%eax),%eax
c01042eb:	39 45 08             	cmp    %eax,0x8(%ebp)
c01042ee:	77 08                	ja     c01042f8 <default_alloc_pages+0x70>
	   page=p;
c01042f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01042f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	   break;
c01042f6:	eb 18                	jmp    c0104310 <default_alloc_pages+0x88>
c01042f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01042fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c01042fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104301:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104304:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104307:	81 7d f0 20 df 11 c0 	cmpl   $0xc011df20,-0x10(%ebp)
c010430e:	75 cc                	jne    c01042dc <default_alloc_pages+0x54>
        }
    }
    if(page!=NULL){
c0104310:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104314:	0f 84 f8 00 00 00    	je     c0104412 <default_alloc_pages+0x18a>
	if(page->property>n){
c010431a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010431d:	8b 40 08             	mov    0x8(%eax),%eax
c0104320:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104323:	0f 83 98 00 00 00    	jae    c01043c1 <default_alloc_pages+0x139>
	   struct Page*p=page+n;
c0104329:	8b 55 08             	mov    0x8(%ebp),%edx
c010432c:	89 d0                	mov    %edx,%eax
c010432e:	c1 e0 02             	shl    $0x2,%eax
c0104331:	01 d0                	add    %edx,%eax
c0104333:	c1 e0 02             	shl    $0x2,%eax
c0104336:	89 c2                	mov    %eax,%edx
c0104338:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010433b:	01 d0                	add    %edx,%eax
c010433d:	89 45 e8             	mov    %eax,-0x18(%ebp)
	   p->property=page->property-n;
c0104340:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104343:	8b 40 08             	mov    0x8(%eax),%eax
c0104346:	2b 45 08             	sub    0x8(%ebp),%eax
c0104349:	89 c2                	mov    %eax,%edx
c010434b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010434e:	89 50 08             	mov    %edx,0x8(%eax)
	   SetPageProperty(p);
c0104351:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104354:	83 c0 04             	add    $0x4,%eax
c0104357:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c010435e:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0104361:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104364:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104367:	0f ab 10             	bts    %edx,(%eax)
	   list_add(&(page->page_link),&(p->page_link));
c010436a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010436d:	83 c0 0c             	add    $0xc,%eax
c0104370:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104373:	83 c2 0c             	add    $0xc,%edx
c0104376:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0104379:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010437c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010437f:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104382:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104385:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0104388:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010438b:	8b 40 04             	mov    0x4(%eax),%eax
c010438e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104391:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0104394:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104397:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010439a:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c010439d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01043a0:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01043a3:	89 10                	mov    %edx,(%eax)
c01043a5:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01043a8:	8b 10                	mov    (%eax),%edx
c01043aa:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01043ad:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01043b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043b3:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01043b6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01043b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043bc:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01043bf:	89 10                	mov    %edx,(%eax)
	}
	
	list_del(&(page->page_link));
c01043c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043c4:	83 c0 0c             	add    $0xc,%eax
c01043c7:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01043ca:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01043cd:	8b 40 04             	mov    0x4(%eax),%eax
c01043d0:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01043d3:	8b 12                	mov    (%edx),%edx
c01043d5:	89 55 b0             	mov    %edx,-0x50(%ebp)
c01043d8:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01043db:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01043de:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01043e1:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01043e4:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01043e7:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01043ea:	89 10                	mov    %edx,(%eax)
	nr_free-=n;
c01043ec:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c01043f1:	2b 45 08             	sub    0x8(%ebp),%eax
c01043f4:	a3 28 df 11 c0       	mov    %eax,0xc011df28
	ClearPageProperty(page);
c01043f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043fc:	83 c0 04             	add    $0x4,%eax
c01043ff:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0104406:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104409:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010440c:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010440f:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0104412:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104415:	c9                   	leave  
c0104416:	c3                   	ret    

c0104417 <default_free_pages>:
 *  (5.3)
 *      Try to merge blocks at lower or higher addresses. Notice: This should
 *  change some pages' `p->property` correctly.
 */
static void
default_free_pages(struct Page *base, size_t n) {
c0104417:	55                   	push   %ebp
c0104418:	89 e5                	mov    %esp,%ebp
c010441a:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0104420:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104424:	75 24                	jne    c010444a <default_free_pages+0x33>
c0104426:	c7 44 24 0c 98 7a 10 	movl   $0xc0107a98,0xc(%esp)
c010442d:	c0 
c010442e:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104435:	c0 
c0104436:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c010443d:	00 
c010443e:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104445:	e8 9f bf ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c010444a:	8b 45 08             	mov    0x8(%ebp),%eax
c010444d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104450:	e9 9d 00 00 00       	jmp    c01044f2 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0104455:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104458:	83 c0 04             	add    $0x4,%eax
c010445b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104462:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104465:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104468:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010446b:	0f a3 10             	bt     %edx,(%eax)
c010446e:	19 c0                	sbb    %eax,%eax
c0104470:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0104473:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104477:	0f 95 c0             	setne  %al
c010447a:	0f b6 c0             	movzbl %al,%eax
c010447d:	85 c0                	test   %eax,%eax
c010447f:	75 2c                	jne    c01044ad <default_free_pages+0x96>
c0104481:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104484:	83 c0 04             	add    $0x4,%eax
c0104487:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c010448e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104491:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104494:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104497:	0f a3 10             	bt     %edx,(%eax)
c010449a:	19 c0                	sbb    %eax,%eax
c010449c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c010449f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01044a3:	0f 95 c0             	setne  %al
c01044a6:	0f b6 c0             	movzbl %al,%eax
c01044a9:	85 c0                	test   %eax,%eax
c01044ab:	74 24                	je     c01044d1 <default_free_pages+0xba>
c01044ad:	c7 44 24 0c dc 7a 10 	movl   $0xc0107adc,0xc(%esp)
c01044b4:	c0 
c01044b5:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c01044bc:	c0 
c01044bd:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c01044c4:	00 
c01044c5:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c01044cc:	e8 18 bf ff ff       	call   c01003e9 <__panic>
        p->flags = 0;
c01044d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044d4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01044db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01044e2:	00 
c01044e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044e6:	89 04 24             	mov    %eax,(%esp)
c01044e9:	e8 0f fc ff ff       	call   c01040fd <set_page_ref>
    for (; p != base + n; p ++) {
c01044ee:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01044f2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01044f5:	89 d0                	mov    %edx,%eax
c01044f7:	c1 e0 02             	shl    $0x2,%eax
c01044fa:	01 d0                	add    %edx,%eax
c01044fc:	c1 e0 02             	shl    $0x2,%eax
c01044ff:	89 c2                	mov    %eax,%edx
c0104501:	8b 45 08             	mov    0x8(%ebp),%eax
c0104504:	01 d0                	add    %edx,%eax
c0104506:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104509:	0f 85 46 ff ff ff    	jne    c0104455 <default_free_pages+0x3e>
    }
    base->property = n;
c010450f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104512:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104515:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104518:	8b 45 08             	mov    0x8(%ebp),%eax
c010451b:	83 c0 04             	add    $0x4,%eax
c010451e:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104525:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104528:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010452b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010452e:	0f ab 10             	bts    %edx,(%eax)
c0104531:	c7 45 d4 20 df 11 c0 	movl   $0xc011df20,-0x2c(%ebp)
    return listelm->next;
c0104538:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010453b:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c010453e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0104541:	e9 08 01 00 00       	jmp    c010464e <default_free_pages+0x237>
        p = le2page(le, page_link);
c0104546:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104549:	83 e8 0c             	sub    $0xc,%eax
c010454c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010454f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104552:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104555:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104558:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c010455b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c010455e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104561:	8b 50 08             	mov    0x8(%eax),%edx
c0104564:	89 d0                	mov    %edx,%eax
c0104566:	c1 e0 02             	shl    $0x2,%eax
c0104569:	01 d0                	add    %edx,%eax
c010456b:	c1 e0 02             	shl    $0x2,%eax
c010456e:	89 c2                	mov    %eax,%edx
c0104570:	8b 45 08             	mov    0x8(%ebp),%eax
c0104573:	01 d0                	add    %edx,%eax
c0104575:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104578:	75 5a                	jne    c01045d4 <default_free_pages+0x1bd>
            base->property += p->property;
c010457a:	8b 45 08             	mov    0x8(%ebp),%eax
c010457d:	8b 50 08             	mov    0x8(%eax),%edx
c0104580:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104583:	8b 40 08             	mov    0x8(%eax),%eax
c0104586:	01 c2                	add    %eax,%edx
c0104588:	8b 45 08             	mov    0x8(%ebp),%eax
c010458b:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c010458e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104591:	83 c0 04             	add    $0x4,%eax
c0104594:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010459b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010459e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01045a1:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01045a4:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c01045a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045aa:	83 c0 0c             	add    $0xc,%eax
c01045ad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01045b0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01045b3:	8b 40 04             	mov    0x4(%eax),%eax
c01045b6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01045b9:	8b 12                	mov    (%edx),%edx
c01045bb:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01045be:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c01045c1:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01045c4:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01045c7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01045ca:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01045cd:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01045d0:	89 10                	mov    %edx,(%eax)
c01045d2:	eb 7a                	jmp    c010464e <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c01045d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045d7:	8b 50 08             	mov    0x8(%eax),%edx
c01045da:	89 d0                	mov    %edx,%eax
c01045dc:	c1 e0 02             	shl    $0x2,%eax
c01045df:	01 d0                	add    %edx,%eax
c01045e1:	c1 e0 02             	shl    $0x2,%eax
c01045e4:	89 c2                	mov    %eax,%edx
c01045e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045e9:	01 d0                	add    %edx,%eax
c01045eb:	39 45 08             	cmp    %eax,0x8(%ebp)
c01045ee:	75 5e                	jne    c010464e <default_free_pages+0x237>
            p->property += base->property;
c01045f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045f3:	8b 50 08             	mov    0x8(%eax),%edx
c01045f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01045f9:	8b 40 08             	mov    0x8(%eax),%eax
c01045fc:	01 c2                	add    %eax,%edx
c01045fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104601:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0104604:	8b 45 08             	mov    0x8(%ebp),%eax
c0104607:	83 c0 04             	add    $0x4,%eax
c010460a:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0104611:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0104614:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104617:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010461a:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c010461d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104620:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0104623:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104626:	83 c0 0c             	add    $0xc,%eax
c0104629:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c010462c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010462f:	8b 40 04             	mov    0x4(%eax),%eax
c0104632:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104635:	8b 12                	mov    (%edx),%edx
c0104637:	89 55 ac             	mov    %edx,-0x54(%ebp)
c010463a:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c010463d:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104640:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104643:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104646:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104649:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010464c:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
c010464e:	81 7d f0 20 df 11 c0 	cmpl   $0xc011df20,-0x10(%ebp)
c0104655:	0f 85 eb fe ff ff    	jne    c0104546 <default_free_pages+0x12f>
        }
    }
    SetPageProperty(base);
c010465b:	8b 45 08             	mov    0x8(%ebp),%eax
c010465e:	83 c0 04             	add    $0x4,%eax
c0104661:	c7 45 98 01 00 00 00 	movl   $0x1,-0x68(%ebp)
c0104668:	89 45 94             	mov    %eax,-0x6c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010466b:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010466e:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104671:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0104674:	8b 15 28 df 11 c0    	mov    0xc011df28,%edx
c010467a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010467d:	01 d0                	add    %edx,%eax
c010467f:	a3 28 df 11 c0       	mov    %eax,0xc011df28
c0104684:	c7 45 9c 20 df 11 c0 	movl   $0xc011df20,-0x64(%ebp)
    return listelm->next;
c010468b:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010468e:	8b 40 04             	mov    0x4(%eax),%eax
    le=list_next(&free_list);
c0104691:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
c0104694:	eb 0f                	jmp    c01046a5 <default_free_pages+0x28e>
c0104696:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104699:	89 45 90             	mov    %eax,-0x70(%ebp)
c010469c:	8b 45 90             	mov    -0x70(%ebp),%eax
c010469f:	8b 40 04             	mov    0x4(%eax),%eax
	le=list_next(le);
c01046a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
c01046a5:	81 7d f0 20 df 11 c0 	cmpl   $0xc011df20,-0x10(%ebp)
c01046ac:	74 0b                	je     c01046b9 <default_free_pages+0x2a2>
c01046ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046b1:	83 e8 0c             	sub    $0xc,%eax
c01046b4:	39 45 08             	cmp    %eax,0x8(%ebp)
c01046b7:	77 dd                	ja     c0104696 <default_free_pages+0x27f>
    }
    list_add_before(le, &(base->page_link));
c01046b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01046bc:	8d 50 0c             	lea    0xc(%eax),%edx
c01046bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046c2:	89 45 8c             	mov    %eax,-0x74(%ebp)
c01046c5:	89 55 88             	mov    %edx,-0x78(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01046c8:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01046cb:	8b 00                	mov    (%eax),%eax
c01046cd:	8b 55 88             	mov    -0x78(%ebp),%edx
c01046d0:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01046d3:	89 45 80             	mov    %eax,-0x80(%ebp)
c01046d6:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01046d9:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
    prev->next = next->prev = elm;
c01046df:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01046e5:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01046e8:	89 10                	mov    %edx,(%eax)
c01046ea:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01046f0:	8b 10                	mov    (%eax),%edx
c01046f2:	8b 45 80             	mov    -0x80(%ebp),%eax
c01046f5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01046f8:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01046fb:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0104701:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104704:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104707:	8b 55 80             	mov    -0x80(%ebp),%edx
c010470a:	89 10                	mov    %edx,(%eax)
}
c010470c:	90                   	nop
c010470d:	c9                   	leave  
c010470e:	c3                   	ret    

c010470f <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c010470f:	55                   	push   %ebp
c0104710:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104712:	a1 28 df 11 c0       	mov    0xc011df28,%eax
}
c0104717:	5d                   	pop    %ebp
c0104718:	c3                   	ret    

c0104719 <basic_check>:

static void
basic_check(void) {
c0104719:	55                   	push   %ebp
c010471a:	89 e5                	mov    %esp,%ebp
c010471c:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c010471f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104726:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104729:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010472c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010472f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104732:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104739:	e8 0b e4 ff ff       	call   c0102b49 <alloc_pages>
c010473e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104741:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104745:	75 24                	jne    c010476b <basic_check+0x52>
c0104747:	c7 44 24 0c 01 7b 10 	movl   $0xc0107b01,0xc(%esp)
c010474e:	c0 
c010474f:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104756:	c0 
c0104757:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c010475e:	00 
c010475f:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104766:	e8 7e bc ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010476b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104772:	e8 d2 e3 ff ff       	call   c0102b49 <alloc_pages>
c0104777:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010477a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010477e:	75 24                	jne    c01047a4 <basic_check+0x8b>
c0104780:	c7 44 24 0c 1d 7b 10 	movl   $0xc0107b1d,0xc(%esp)
c0104787:	c0 
c0104788:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c010478f:	c0 
c0104790:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0104797:	00 
c0104798:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c010479f:	e8 45 bc ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01047a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01047ab:	e8 99 e3 ff ff       	call   c0102b49 <alloc_pages>
c01047b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01047b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01047b7:	75 24                	jne    c01047dd <basic_check+0xc4>
c01047b9:	c7 44 24 0c 39 7b 10 	movl   $0xc0107b39,0xc(%esp)
c01047c0:	c0 
c01047c1:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c01047c8:	c0 
c01047c9:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c01047d0:	00 
c01047d1:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c01047d8:	e8 0c bc ff ff       	call   c01003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c01047dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047e0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01047e3:	74 10                	je     c01047f5 <basic_check+0xdc>
c01047e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047e8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01047eb:	74 08                	je     c01047f5 <basic_check+0xdc>
c01047ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047f0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01047f3:	75 24                	jne    c0104819 <basic_check+0x100>
c01047f5:	c7 44 24 0c 58 7b 10 	movl   $0xc0107b58,0xc(%esp)
c01047fc:	c0 
c01047fd:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104804:	c0 
c0104805:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c010480c:	00 
c010480d:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104814:	e8 d0 bb ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0104819:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010481c:	89 04 24             	mov    %eax,(%esp)
c010481f:	e8 cf f8 ff ff       	call   c01040f3 <page_ref>
c0104824:	85 c0                	test   %eax,%eax
c0104826:	75 1e                	jne    c0104846 <basic_check+0x12d>
c0104828:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010482b:	89 04 24             	mov    %eax,(%esp)
c010482e:	e8 c0 f8 ff ff       	call   c01040f3 <page_ref>
c0104833:	85 c0                	test   %eax,%eax
c0104835:	75 0f                	jne    c0104846 <basic_check+0x12d>
c0104837:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010483a:	89 04 24             	mov    %eax,(%esp)
c010483d:	e8 b1 f8 ff ff       	call   c01040f3 <page_ref>
c0104842:	85 c0                	test   %eax,%eax
c0104844:	74 24                	je     c010486a <basic_check+0x151>
c0104846:	c7 44 24 0c 7c 7b 10 	movl   $0xc0107b7c,0xc(%esp)
c010484d:	c0 
c010484e:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104855:	c0 
c0104856:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c010485d:	00 
c010485e:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104865:	e8 7f bb ff ff       	call   c01003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c010486a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010486d:	89 04 24             	mov    %eax,(%esp)
c0104870:	e8 68 f8 ff ff       	call   c01040dd <page2pa>
c0104875:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c010487b:	c1 e2 0c             	shl    $0xc,%edx
c010487e:	39 d0                	cmp    %edx,%eax
c0104880:	72 24                	jb     c01048a6 <basic_check+0x18d>
c0104882:	c7 44 24 0c b8 7b 10 	movl   $0xc0107bb8,0xc(%esp)
c0104889:	c0 
c010488a:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104891:	c0 
c0104892:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0104899:	00 
c010489a:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c01048a1:	e8 43 bb ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01048a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048a9:	89 04 24             	mov    %eax,(%esp)
c01048ac:	e8 2c f8 ff ff       	call   c01040dd <page2pa>
c01048b1:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c01048b7:	c1 e2 0c             	shl    $0xc,%edx
c01048ba:	39 d0                	cmp    %edx,%eax
c01048bc:	72 24                	jb     c01048e2 <basic_check+0x1c9>
c01048be:	c7 44 24 0c d5 7b 10 	movl   $0xc0107bd5,0xc(%esp)
c01048c5:	c0 
c01048c6:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c01048cd:	c0 
c01048ce:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
c01048d5:	00 
c01048d6:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c01048dd:	e8 07 bb ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01048e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048e5:	89 04 24             	mov    %eax,(%esp)
c01048e8:	e8 f0 f7 ff ff       	call   c01040dd <page2pa>
c01048ed:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c01048f3:	c1 e2 0c             	shl    $0xc,%edx
c01048f6:	39 d0                	cmp    %edx,%eax
c01048f8:	72 24                	jb     c010491e <basic_check+0x205>
c01048fa:	c7 44 24 0c f2 7b 10 	movl   $0xc0107bf2,0xc(%esp)
c0104901:	c0 
c0104902:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104909:	c0 
c010490a:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0104911:	00 
c0104912:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104919:	e8 cb ba ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c010491e:	a1 20 df 11 c0       	mov    0xc011df20,%eax
c0104923:	8b 15 24 df 11 c0    	mov    0xc011df24,%edx
c0104929:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010492c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010492f:	c7 45 dc 20 df 11 c0 	movl   $0xc011df20,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0104936:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104939:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010493c:	89 50 04             	mov    %edx,0x4(%eax)
c010493f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104942:	8b 50 04             	mov    0x4(%eax),%edx
c0104945:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104948:	89 10                	mov    %edx,(%eax)
c010494a:	c7 45 e0 20 df 11 c0 	movl   $0xc011df20,-0x20(%ebp)
    return list->next == list;
c0104951:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104954:	8b 40 04             	mov    0x4(%eax),%eax
c0104957:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010495a:	0f 94 c0             	sete   %al
c010495d:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104960:	85 c0                	test   %eax,%eax
c0104962:	75 24                	jne    c0104988 <basic_check+0x26f>
c0104964:	c7 44 24 0c 0f 7c 10 	movl   $0xc0107c0f,0xc(%esp)
c010496b:	c0 
c010496c:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104973:	c0 
c0104974:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c010497b:	00 
c010497c:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104983:	e8 61 ba ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104988:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c010498d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104990:	c7 05 28 df 11 c0 00 	movl   $0x0,0xc011df28
c0104997:	00 00 00 

    assert(alloc_page() == NULL);
c010499a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01049a1:	e8 a3 e1 ff ff       	call   c0102b49 <alloc_pages>
c01049a6:	85 c0                	test   %eax,%eax
c01049a8:	74 24                	je     c01049ce <basic_check+0x2b5>
c01049aa:	c7 44 24 0c 26 7c 10 	movl   $0xc0107c26,0xc(%esp)
c01049b1:	c0 
c01049b2:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c01049b9:	c0 
c01049ba:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c01049c1:	00 
c01049c2:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c01049c9:	e8 1b ba ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c01049ce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01049d5:	00 
c01049d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049d9:	89 04 24             	mov    %eax,(%esp)
c01049dc:	e8 a0 e1 ff ff       	call   c0102b81 <free_pages>
    free_page(p1);
c01049e1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01049e8:	00 
c01049e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049ec:	89 04 24             	mov    %eax,(%esp)
c01049ef:	e8 8d e1 ff ff       	call   c0102b81 <free_pages>
    free_page(p2);
c01049f4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01049fb:	00 
c01049fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049ff:	89 04 24             	mov    %eax,(%esp)
c0104a02:	e8 7a e1 ff ff       	call   c0102b81 <free_pages>
    assert(nr_free == 3);
c0104a07:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104a0c:	83 f8 03             	cmp    $0x3,%eax
c0104a0f:	74 24                	je     c0104a35 <basic_check+0x31c>
c0104a11:	c7 44 24 0c 3b 7c 10 	movl   $0xc0107c3b,0xc(%esp)
c0104a18:	c0 
c0104a19:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104a20:	c0 
c0104a21:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c0104a28:	00 
c0104a29:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104a30:	e8 b4 b9 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104a35:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a3c:	e8 08 e1 ff ff       	call   c0102b49 <alloc_pages>
c0104a41:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104a44:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104a48:	75 24                	jne    c0104a6e <basic_check+0x355>
c0104a4a:	c7 44 24 0c 01 7b 10 	movl   $0xc0107b01,0xc(%esp)
c0104a51:	c0 
c0104a52:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104a59:	c0 
c0104a5a:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0104a61:	00 
c0104a62:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104a69:	e8 7b b9 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104a6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a75:	e8 cf e0 ff ff       	call   c0102b49 <alloc_pages>
c0104a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a7d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104a81:	75 24                	jne    c0104aa7 <basic_check+0x38e>
c0104a83:	c7 44 24 0c 1d 7b 10 	movl   $0xc0107b1d,0xc(%esp)
c0104a8a:	c0 
c0104a8b:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104a92:	c0 
c0104a93:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0104a9a:	00 
c0104a9b:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104aa2:	e8 42 b9 ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104aa7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104aae:	e8 96 e0 ff ff       	call   c0102b49 <alloc_pages>
c0104ab3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104ab6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104aba:	75 24                	jne    c0104ae0 <basic_check+0x3c7>
c0104abc:	c7 44 24 0c 39 7b 10 	movl   $0xc0107b39,0xc(%esp)
c0104ac3:	c0 
c0104ac4:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104acb:	c0 
c0104acc:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0104ad3:	00 
c0104ad4:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104adb:	e8 09 b9 ff ff       	call   c01003e9 <__panic>

    assert(alloc_page() == NULL);
c0104ae0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ae7:	e8 5d e0 ff ff       	call   c0102b49 <alloc_pages>
c0104aec:	85 c0                	test   %eax,%eax
c0104aee:	74 24                	je     c0104b14 <basic_check+0x3fb>
c0104af0:	c7 44 24 0c 26 7c 10 	movl   $0xc0107c26,0xc(%esp)
c0104af7:	c0 
c0104af8:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104aff:	c0 
c0104b00:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0104b07:	00 
c0104b08:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104b0f:	e8 d5 b8 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104b14:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b1b:	00 
c0104b1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b1f:	89 04 24             	mov    %eax,(%esp)
c0104b22:	e8 5a e0 ff ff       	call   c0102b81 <free_pages>
c0104b27:	c7 45 d8 20 df 11 c0 	movl   $0xc011df20,-0x28(%ebp)
c0104b2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104b31:	8b 40 04             	mov    0x4(%eax),%eax
c0104b34:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104b37:	0f 94 c0             	sete   %al
c0104b3a:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104b3d:	85 c0                	test   %eax,%eax
c0104b3f:	74 24                	je     c0104b65 <basic_check+0x44c>
c0104b41:	c7 44 24 0c 48 7c 10 	movl   $0xc0107c48,0xc(%esp)
c0104b48:	c0 
c0104b49:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104b50:	c0 
c0104b51:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0104b58:	00 
c0104b59:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104b60:	e8 84 b8 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104b65:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b6c:	e8 d8 df ff ff       	call   c0102b49 <alloc_pages>
c0104b71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104b74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b77:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104b7a:	74 24                	je     c0104ba0 <basic_check+0x487>
c0104b7c:	c7 44 24 0c 60 7c 10 	movl   $0xc0107c60,0xc(%esp)
c0104b83:	c0 
c0104b84:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104b8b:	c0 
c0104b8c:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0104b93:	00 
c0104b94:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104b9b:	e8 49 b8 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104ba0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ba7:	e8 9d df ff ff       	call   c0102b49 <alloc_pages>
c0104bac:	85 c0                	test   %eax,%eax
c0104bae:	74 24                	je     c0104bd4 <basic_check+0x4bb>
c0104bb0:	c7 44 24 0c 26 7c 10 	movl   $0xc0107c26,0xc(%esp)
c0104bb7:	c0 
c0104bb8:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104bbf:	c0 
c0104bc0:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0104bc7:	00 
c0104bc8:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104bcf:	e8 15 b8 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c0104bd4:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104bd9:	85 c0                	test   %eax,%eax
c0104bdb:	74 24                	je     c0104c01 <basic_check+0x4e8>
c0104bdd:	c7 44 24 0c 79 7c 10 	movl   $0xc0107c79,0xc(%esp)
c0104be4:	c0 
c0104be5:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104bec:	c0 
c0104bed:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0104bf4:	00 
c0104bf5:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104bfc:	e8 e8 b7 ff ff       	call   c01003e9 <__panic>
    free_list = free_list_store;
c0104c01:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104c04:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104c07:	a3 20 df 11 c0       	mov    %eax,0xc011df20
c0104c0c:	89 15 24 df 11 c0    	mov    %edx,0xc011df24
    nr_free = nr_free_store;
c0104c12:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104c15:	a3 28 df 11 c0       	mov    %eax,0xc011df28

    free_page(p);
c0104c1a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104c21:	00 
c0104c22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c25:	89 04 24             	mov    %eax,(%esp)
c0104c28:	e8 54 df ff ff       	call   c0102b81 <free_pages>
    free_page(p1);
c0104c2d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104c34:	00 
c0104c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c38:	89 04 24             	mov    %eax,(%esp)
c0104c3b:	e8 41 df ff ff       	call   c0102b81 <free_pages>
    free_page(p2);
c0104c40:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104c47:	00 
c0104c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c4b:	89 04 24             	mov    %eax,(%esp)
c0104c4e:	e8 2e df ff ff       	call   c0102b81 <free_pages>
}
c0104c53:	90                   	nop
c0104c54:	c9                   	leave  
c0104c55:	c3                   	ret    

c0104c56 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104c56:	55                   	push   %ebp
c0104c57:	89 e5                	mov    %esp,%ebp
c0104c59:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0104c5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104c66:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104c6d:	c7 45 ec 20 df 11 c0 	movl   $0xc011df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104c74:	eb 6a                	jmp    c0104ce0 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0104c76:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c79:	83 e8 0c             	sub    $0xc,%eax
c0104c7c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0104c7f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104c82:	83 c0 04             	add    $0x4,%eax
c0104c85:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104c8c:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104c8f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104c92:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104c95:	0f a3 10             	bt     %edx,(%eax)
c0104c98:	19 c0                	sbb    %eax,%eax
c0104c9a:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104c9d:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104ca1:	0f 95 c0             	setne  %al
c0104ca4:	0f b6 c0             	movzbl %al,%eax
c0104ca7:	85 c0                	test   %eax,%eax
c0104ca9:	75 24                	jne    c0104ccf <default_check+0x79>
c0104cab:	c7 44 24 0c 86 7c 10 	movl   $0xc0107c86,0xc(%esp)
c0104cb2:	c0 
c0104cb3:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104cba:	c0 
c0104cbb:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0104cc2:	00 
c0104cc3:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104cca:	e8 1a b7 ff ff       	call   c01003e9 <__panic>
        count ++, total += p->property;
c0104ccf:	ff 45 f4             	incl   -0xc(%ebp)
c0104cd2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104cd5:	8b 50 08             	mov    0x8(%eax),%edx
c0104cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cdb:	01 d0                	add    %edx,%eax
c0104cdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ce0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ce3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0104ce6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104ce9:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104cec:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104cef:	81 7d ec 20 df 11 c0 	cmpl   $0xc011df20,-0x14(%ebp)
c0104cf6:	0f 85 7a ff ff ff    	jne    c0104c76 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0104cfc:	e8 b3 de ff ff       	call   c0102bb4 <nr_free_pages>
c0104d01:	89 c2                	mov    %eax,%edx
c0104d03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d06:	39 c2                	cmp    %eax,%edx
c0104d08:	74 24                	je     c0104d2e <default_check+0xd8>
c0104d0a:	c7 44 24 0c 96 7c 10 	movl   $0xc0107c96,0xc(%esp)
c0104d11:	c0 
c0104d12:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104d19:	c0 
c0104d1a:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0104d21:	00 
c0104d22:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104d29:	e8 bb b6 ff ff       	call   c01003e9 <__panic>

    basic_check();
c0104d2e:	e8 e6 f9 ff ff       	call   c0104719 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104d33:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104d3a:	e8 0a de ff ff       	call   c0102b49 <alloc_pages>
c0104d3f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0104d42:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104d46:	75 24                	jne    c0104d6c <default_check+0x116>
c0104d48:	c7 44 24 0c af 7c 10 	movl   $0xc0107caf,0xc(%esp)
c0104d4f:	c0 
c0104d50:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104d57:	c0 
c0104d58:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0104d5f:	00 
c0104d60:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104d67:	e8 7d b6 ff ff       	call   c01003e9 <__panic>
    assert(!PageProperty(p0));
c0104d6c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d6f:	83 c0 04             	add    $0x4,%eax
c0104d72:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104d79:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104d7c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104d7f:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104d82:	0f a3 10             	bt     %edx,(%eax)
c0104d85:	19 c0                	sbb    %eax,%eax
c0104d87:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104d8a:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104d8e:	0f 95 c0             	setne  %al
c0104d91:	0f b6 c0             	movzbl %al,%eax
c0104d94:	85 c0                	test   %eax,%eax
c0104d96:	74 24                	je     c0104dbc <default_check+0x166>
c0104d98:	c7 44 24 0c ba 7c 10 	movl   $0xc0107cba,0xc(%esp)
c0104d9f:	c0 
c0104da0:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104da7:	c0 
c0104da8:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0104daf:	00 
c0104db0:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104db7:	e8 2d b6 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104dbc:	a1 20 df 11 c0       	mov    0xc011df20,%eax
c0104dc1:	8b 15 24 df 11 c0    	mov    0xc011df24,%edx
c0104dc7:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104dca:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104dcd:	c7 45 b0 20 df 11 c0 	movl   $0xc011df20,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0104dd4:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104dd7:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104dda:	89 50 04             	mov    %edx,0x4(%eax)
c0104ddd:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104de0:	8b 50 04             	mov    0x4(%eax),%edx
c0104de3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104de6:	89 10                	mov    %edx,(%eax)
c0104de8:	c7 45 b4 20 df 11 c0 	movl   $0xc011df20,-0x4c(%ebp)
    return list->next == list;
c0104def:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104df2:	8b 40 04             	mov    0x4(%eax),%eax
c0104df5:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0104df8:	0f 94 c0             	sete   %al
c0104dfb:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104dfe:	85 c0                	test   %eax,%eax
c0104e00:	75 24                	jne    c0104e26 <default_check+0x1d0>
c0104e02:	c7 44 24 0c 0f 7c 10 	movl   $0xc0107c0f,0xc(%esp)
c0104e09:	c0 
c0104e0a:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104e11:	c0 
c0104e12:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0104e19:	00 
c0104e1a:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104e21:	e8 c3 b5 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104e26:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e2d:	e8 17 dd ff ff       	call   c0102b49 <alloc_pages>
c0104e32:	85 c0                	test   %eax,%eax
c0104e34:	74 24                	je     c0104e5a <default_check+0x204>
c0104e36:	c7 44 24 0c 26 7c 10 	movl   $0xc0107c26,0xc(%esp)
c0104e3d:	c0 
c0104e3e:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104e45:	c0 
c0104e46:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0104e4d:	00 
c0104e4e:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104e55:	e8 8f b5 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104e5a:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104e5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0104e62:	c7 05 28 df 11 c0 00 	movl   $0x0,0xc011df28
c0104e69:	00 00 00 

    free_pages(p0 + 2, 3);
c0104e6c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e6f:	83 c0 28             	add    $0x28,%eax
c0104e72:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104e79:	00 
c0104e7a:	89 04 24             	mov    %eax,(%esp)
c0104e7d:	e8 ff dc ff ff       	call   c0102b81 <free_pages>
    assert(alloc_pages(4) == NULL);
c0104e82:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104e89:	e8 bb dc ff ff       	call   c0102b49 <alloc_pages>
c0104e8e:	85 c0                	test   %eax,%eax
c0104e90:	74 24                	je     c0104eb6 <default_check+0x260>
c0104e92:	c7 44 24 0c cc 7c 10 	movl   $0xc0107ccc,0xc(%esp)
c0104e99:	c0 
c0104e9a:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104ea1:	c0 
c0104ea2:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0104ea9:	00 
c0104eaa:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104eb1:	e8 33 b5 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104eb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104eb9:	83 c0 28             	add    $0x28,%eax
c0104ebc:	83 c0 04             	add    $0x4,%eax
c0104ebf:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0104ec6:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104ec9:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104ecc:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104ecf:	0f a3 10             	bt     %edx,(%eax)
c0104ed2:	19 c0                	sbb    %eax,%eax
c0104ed4:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104ed7:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104edb:	0f 95 c0             	setne  %al
c0104ede:	0f b6 c0             	movzbl %al,%eax
c0104ee1:	85 c0                	test   %eax,%eax
c0104ee3:	74 0e                	je     c0104ef3 <default_check+0x29d>
c0104ee5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ee8:	83 c0 28             	add    $0x28,%eax
c0104eeb:	8b 40 08             	mov    0x8(%eax),%eax
c0104eee:	83 f8 03             	cmp    $0x3,%eax
c0104ef1:	74 24                	je     c0104f17 <default_check+0x2c1>
c0104ef3:	c7 44 24 0c e4 7c 10 	movl   $0xc0107ce4,0xc(%esp)
c0104efa:	c0 
c0104efb:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104f02:	c0 
c0104f03:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0104f0a:	00 
c0104f0b:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104f12:	e8 d2 b4 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104f17:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104f1e:	e8 26 dc ff ff       	call   c0102b49 <alloc_pages>
c0104f23:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104f26:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104f2a:	75 24                	jne    c0104f50 <default_check+0x2fa>
c0104f2c:	c7 44 24 0c 10 7d 10 	movl   $0xc0107d10,0xc(%esp)
c0104f33:	c0 
c0104f34:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104f3b:	c0 
c0104f3c:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c0104f43:	00 
c0104f44:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104f4b:	e8 99 b4 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104f50:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f57:	e8 ed db ff ff       	call   c0102b49 <alloc_pages>
c0104f5c:	85 c0                	test   %eax,%eax
c0104f5e:	74 24                	je     c0104f84 <default_check+0x32e>
c0104f60:	c7 44 24 0c 26 7c 10 	movl   $0xc0107c26,0xc(%esp)
c0104f67:	c0 
c0104f68:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104f6f:	c0 
c0104f70:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c0104f77:	00 
c0104f78:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104f7f:	e8 65 b4 ff ff       	call   c01003e9 <__panic>
    assert(p0 + 2 == p1);
c0104f84:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f87:	83 c0 28             	add    $0x28,%eax
c0104f8a:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104f8d:	74 24                	je     c0104fb3 <default_check+0x35d>
c0104f8f:	c7 44 24 0c 2e 7d 10 	movl   $0xc0107d2e,0xc(%esp)
c0104f96:	c0 
c0104f97:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0104f9e:	c0 
c0104f9f:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c0104fa6:	00 
c0104fa7:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0104fae:	e8 36 b4 ff ff       	call   c01003e9 <__panic>

    p2 = p0 + 1;
c0104fb3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104fb6:	83 c0 14             	add    $0x14,%eax
c0104fb9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0104fbc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104fc3:	00 
c0104fc4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104fc7:	89 04 24             	mov    %eax,(%esp)
c0104fca:	e8 b2 db ff ff       	call   c0102b81 <free_pages>
    free_pages(p1, 3);
c0104fcf:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104fd6:	00 
c0104fd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104fda:	89 04 24             	mov    %eax,(%esp)
c0104fdd:	e8 9f db ff ff       	call   c0102b81 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0104fe2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104fe5:	83 c0 04             	add    $0x4,%eax
c0104fe8:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0104fef:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104ff2:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104ff5:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104ff8:	0f a3 10             	bt     %edx,(%eax)
c0104ffb:	19 c0                	sbb    %eax,%eax
c0104ffd:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105000:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105004:	0f 95 c0             	setne  %al
c0105007:	0f b6 c0             	movzbl %al,%eax
c010500a:	85 c0                	test   %eax,%eax
c010500c:	74 0b                	je     c0105019 <default_check+0x3c3>
c010500e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105011:	8b 40 08             	mov    0x8(%eax),%eax
c0105014:	83 f8 01             	cmp    $0x1,%eax
c0105017:	74 24                	je     c010503d <default_check+0x3e7>
c0105019:	c7 44 24 0c 3c 7d 10 	movl   $0xc0107d3c,0xc(%esp)
c0105020:	c0 
c0105021:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0105028:	c0 
c0105029:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
c0105030:	00 
c0105031:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0105038:	e8 ac b3 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c010503d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105040:	83 c0 04             	add    $0x4,%eax
c0105043:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010504a:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010504d:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105050:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0105053:	0f a3 10             	bt     %edx,(%eax)
c0105056:	19 c0                	sbb    %eax,%eax
c0105058:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c010505b:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c010505f:	0f 95 c0             	setne  %al
c0105062:	0f b6 c0             	movzbl %al,%eax
c0105065:	85 c0                	test   %eax,%eax
c0105067:	74 0b                	je     c0105074 <default_check+0x41e>
c0105069:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010506c:	8b 40 08             	mov    0x8(%eax),%eax
c010506f:	83 f8 03             	cmp    $0x3,%eax
c0105072:	74 24                	je     c0105098 <default_check+0x442>
c0105074:	c7 44 24 0c 64 7d 10 	movl   $0xc0107d64,0xc(%esp)
c010507b:	c0 
c010507c:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0105083:	c0 
c0105084:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
c010508b:	00 
c010508c:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0105093:	e8 51 b3 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0105098:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010509f:	e8 a5 da ff ff       	call   c0102b49 <alloc_pages>
c01050a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01050a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01050aa:	83 e8 14             	sub    $0x14,%eax
c01050ad:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01050b0:	74 24                	je     c01050d6 <default_check+0x480>
c01050b2:	c7 44 24 0c 8a 7d 10 	movl   $0xc0107d8a,0xc(%esp)
c01050b9:	c0 
c01050ba:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c01050c1:	c0 
c01050c2:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
c01050c9:	00 
c01050ca:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c01050d1:	e8 13 b3 ff ff       	call   c01003e9 <__panic>
    free_page(p0);
c01050d6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050dd:	00 
c01050de:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050e1:	89 04 24             	mov    %eax,(%esp)
c01050e4:	e8 98 da ff ff       	call   c0102b81 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01050e9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01050f0:	e8 54 da ff ff       	call   c0102b49 <alloc_pages>
c01050f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01050f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01050fb:	83 c0 14             	add    $0x14,%eax
c01050fe:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105101:	74 24                	je     c0105127 <default_check+0x4d1>
c0105103:	c7 44 24 0c a8 7d 10 	movl   $0xc0107da8,0xc(%esp)
c010510a:	c0 
c010510b:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0105112:	c0 
c0105113:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
c010511a:	00 
c010511b:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0105122:	e8 c2 b2 ff ff       	call   c01003e9 <__panic>

    free_pages(p0, 2);
c0105127:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010512e:	00 
c010512f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105132:	89 04 24             	mov    %eax,(%esp)
c0105135:	e8 47 da ff ff       	call   c0102b81 <free_pages>
    free_page(p2);
c010513a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105141:	00 
c0105142:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105145:	89 04 24             	mov    %eax,(%esp)
c0105148:	e8 34 da ff ff       	call   c0102b81 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010514d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105154:	e8 f0 d9 ff ff       	call   c0102b49 <alloc_pages>
c0105159:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010515c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105160:	75 24                	jne    c0105186 <default_check+0x530>
c0105162:	c7 44 24 0c c8 7d 10 	movl   $0xc0107dc8,0xc(%esp)
c0105169:	c0 
c010516a:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0105171:	c0 
c0105172:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c0105179:	00 
c010517a:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0105181:	e8 63 b2 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0105186:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010518d:	e8 b7 d9 ff ff       	call   c0102b49 <alloc_pages>
c0105192:	85 c0                	test   %eax,%eax
c0105194:	74 24                	je     c01051ba <default_check+0x564>
c0105196:	c7 44 24 0c 26 7c 10 	movl   $0xc0107c26,0xc(%esp)
c010519d:	c0 
c010519e:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c01051a5:	c0 
c01051a6:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c01051ad:	00 
c01051ae:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c01051b5:	e8 2f b2 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c01051ba:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c01051bf:	85 c0                	test   %eax,%eax
c01051c1:	74 24                	je     c01051e7 <default_check+0x591>
c01051c3:	c7 44 24 0c 79 7c 10 	movl   $0xc0107c79,0xc(%esp)
c01051ca:	c0 
c01051cb:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c01051d2:	c0 
c01051d3:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
c01051da:	00 
c01051db:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c01051e2:	e8 02 b2 ff ff       	call   c01003e9 <__panic>
    nr_free = nr_free_store;
c01051e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01051ea:	a3 28 df 11 c0       	mov    %eax,0xc011df28

    free_list = free_list_store;
c01051ef:	8b 45 80             	mov    -0x80(%ebp),%eax
c01051f2:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01051f5:	a3 20 df 11 c0       	mov    %eax,0xc011df20
c01051fa:	89 15 24 df 11 c0    	mov    %edx,0xc011df24
    free_pages(p0, 5);
c0105200:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0105207:	00 
c0105208:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010520b:	89 04 24             	mov    %eax,(%esp)
c010520e:	e8 6e d9 ff ff       	call   c0102b81 <free_pages>

    le = &free_list;
c0105213:	c7 45 ec 20 df 11 c0 	movl   $0xc011df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010521a:	eb 5a                	jmp    c0105276 <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
c010521c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010521f:	8b 40 04             	mov    0x4(%eax),%eax
c0105222:	8b 00                	mov    (%eax),%eax
c0105224:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105227:	75 0d                	jne    c0105236 <default_check+0x5e0>
c0105229:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010522c:	8b 00                	mov    (%eax),%eax
c010522e:	8b 40 04             	mov    0x4(%eax),%eax
c0105231:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105234:	74 24                	je     c010525a <default_check+0x604>
c0105236:	c7 44 24 0c e8 7d 10 	movl   $0xc0107de8,0xc(%esp)
c010523d:	c0 
c010523e:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c0105245:	c0 
c0105246:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
c010524d:	00 
c010524e:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c0105255:	e8 8f b1 ff ff       	call   c01003e9 <__panic>
        struct Page *p = le2page(le, page_link);
c010525a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010525d:	83 e8 0c             	sub    $0xc,%eax
c0105260:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0105263:	ff 4d f4             	decl   -0xc(%ebp)
c0105266:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105269:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010526c:	8b 40 08             	mov    0x8(%eax),%eax
c010526f:	29 c2                	sub    %eax,%edx
c0105271:	89 d0                	mov    %edx,%eax
c0105273:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105276:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105279:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c010527c:	8b 45 88             	mov    -0x78(%ebp),%eax
c010527f:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105282:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105285:	81 7d ec 20 df 11 c0 	cmpl   $0xc011df20,-0x14(%ebp)
c010528c:	75 8e                	jne    c010521c <default_check+0x5c6>
    }
    assert(count == 0);
c010528e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105292:	74 24                	je     c01052b8 <default_check+0x662>
c0105294:	c7 44 24 0c 15 7e 10 	movl   $0xc0107e15,0xc(%esp)
c010529b:	c0 
c010529c:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c01052a3:	c0 
c01052a4:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
c01052ab:	00 
c01052ac:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c01052b3:	e8 31 b1 ff ff       	call   c01003e9 <__panic>
    assert(total == 0);
c01052b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01052bc:	74 24                	je     c01052e2 <default_check+0x68c>
c01052be:	c7 44 24 0c 20 7e 10 	movl   $0xc0107e20,0xc(%esp)
c01052c5:	c0 
c01052c6:	c7 44 24 08 9e 7a 10 	movl   $0xc0107a9e,0x8(%esp)
c01052cd:	c0 
c01052ce:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
c01052d5:	00 
c01052d6:	c7 04 24 b3 7a 10 c0 	movl   $0xc0107ab3,(%esp)
c01052dd:	e8 07 b1 ff ff       	call   c01003e9 <__panic>
}
c01052e2:	90                   	nop
c01052e3:	c9                   	leave  
c01052e4:	c3                   	ret    

c01052e5 <page2ppn>:
page2ppn(struct Page *page) {
c01052e5:	55                   	push   %ebp
c01052e6:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01052e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01052eb:	8b 15 18 df 11 c0    	mov    0xc011df18,%edx
c01052f1:	29 d0                	sub    %edx,%eax
c01052f3:	c1 f8 02             	sar    $0x2,%eax
c01052f6:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01052fc:	5d                   	pop    %ebp
c01052fd:	c3                   	ret    

c01052fe <page2pa>:
page2pa(struct Page *page) {
c01052fe:	55                   	push   %ebp
c01052ff:	89 e5                	mov    %esp,%ebp
c0105301:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0105304:	8b 45 08             	mov    0x8(%ebp),%eax
c0105307:	89 04 24             	mov    %eax,(%esp)
c010530a:	e8 d6 ff ff ff       	call   c01052e5 <page2ppn>
c010530f:	c1 e0 0c             	shl    $0xc,%eax
}
c0105312:	c9                   	leave  
c0105313:	c3                   	ret    

c0105314 <page_ref>:
page_ref(struct Page *page) {
c0105314:	55                   	push   %ebp
c0105315:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0105317:	8b 45 08             	mov    0x8(%ebp),%eax
c010531a:	8b 00                	mov    (%eax),%eax
}
c010531c:	5d                   	pop    %ebp
c010531d:	c3                   	ret    

c010531e <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010531e:	55                   	push   %ebp
c010531f:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0105321:	8b 45 08             	mov    0x8(%ebp),%eax
c0105324:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105327:	89 10                	mov    %edx,(%eax)
}
c0105329:	90                   	nop
c010532a:	5d                   	pop    %ebp
c010532b:	c3                   	ret    

c010532c <buddy_init>:

#define MAXLEVEL 12
free_area_t free_area[MAXLEVEL+1];

static void 
buddy_init(void){
c010532c:	55                   	push   %ebp
c010532d:	89 e5                	mov    %esp,%ebp
c010532f:	83 ec 10             	sub    $0x10,%esp
     for(int i=0;i<=MAXLEVEL;i++){
c0105332:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0105339:	eb 42                	jmp    c010537d <buddy_init+0x51>
	list_init(&free_area[i].free_list);
c010533b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010533e:	89 d0                	mov    %edx,%eax
c0105340:	01 c0                	add    %eax,%eax
c0105342:	01 d0                	add    %edx,%eax
c0105344:	c1 e0 02             	shl    $0x2,%eax
c0105347:	05 20 df 11 c0       	add    $0xc011df20,%eax
c010534c:	89 45 f8             	mov    %eax,-0x8(%ebp)
    elm->prev = elm->next = elm;
c010534f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105352:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105355:	89 50 04             	mov    %edx,0x4(%eax)
c0105358:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010535b:	8b 50 04             	mov    0x4(%eax),%edx
c010535e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105361:	89 10                	mov    %edx,(%eax)
	free_area[i].nr_free=0;
c0105363:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0105366:	89 d0                	mov    %edx,%eax
c0105368:	01 c0                	add    %eax,%eax
c010536a:	01 d0                	add    %edx,%eax
c010536c:	c1 e0 02             	shl    $0x2,%eax
c010536f:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105374:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     for(int i=0;i<=MAXLEVEL;i++){
c010537a:	ff 45 fc             	incl   -0x4(%ebp)
c010537d:	83 7d fc 0c          	cmpl   $0xc,-0x4(%ebp)
c0105381:	7e b8                	jle    c010533b <buddy_init+0xf>
     }
}
c0105383:	90                   	nop
c0105384:	c9                   	leave  
c0105385:	c3                   	ret    

c0105386 <buddy_nr_free_page>:

static size_t
buddy_nr_free_page(void){
c0105386:	55                   	push   %ebp
c0105387:	89 e5                	mov    %esp,%ebp
c0105389:	83 ec 10             	sub    $0x10,%esp
    size_t nr=0;
c010538c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
c0105393:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
c010539a:	eb 1c                	jmp    c01053b8 <buddy_nr_free_page+0x32>
	nr+=free_area[i].nr_free*(1<<MAXLEVEL);
c010539c:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010539f:	89 d0                	mov    %edx,%eax
c01053a1:	01 c0                	add    %eax,%eax
c01053a3:	01 d0                	add    %edx,%eax
c01053a5:	c1 e0 02             	shl    $0x2,%eax
c01053a8:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01053ad:	8b 00                	mov    (%eax),%eax
c01053af:	c1 e0 0c             	shl    $0xc,%eax
c01053b2:	01 45 fc             	add    %eax,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
c01053b5:	ff 45 f8             	incl   -0x8(%ebp)
c01053b8:	83 7d f8 0c          	cmpl   $0xc,-0x8(%ebp)
c01053bc:	7e de                	jle    c010539c <buddy_nr_free_page+0x16>
    }
    return nr; 
c01053be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01053c1:	c9                   	leave  
c01053c2:	c3                   	ret    

c01053c3 <buddy_init_memmap>:

static void
buddy_init_memmap(struct Page* base,size_t n){
c01053c3:	55                   	push   %ebp
c01053c4:	89 e5                	mov    %esp,%ebp
c01053c6:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
c01053c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01053cd:	75 24                	jne    c01053f3 <buddy_init_memmap+0x30>
c01053cf:	c7 44 24 0c 5c 7e 10 	movl   $0xc0107e5c,0xc(%esp)
c01053d6:	c0 
c01053d7:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c01053de:	c0 
c01053df:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
c01053e6:	00 
c01053e7:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c01053ee:	e8 f6 af ff ff       	call   c01003e9 <__panic>
     struct Page* p=base;
c01053f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01053f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
     for(;p!=base+n;p++){
c01053f9:	eb 7d                	jmp    c0105478 <buddy_init_memmap+0xb5>
	assert(PageReserved(p));
c01053fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053fe:	83 c0 04             	add    $0x4,%eax
c0105401:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0105408:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010540b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010540e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105411:	0f a3 10             	bt     %edx,(%eax)
c0105414:	19 c0                	sbb    %eax,%eax
c0105416:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0105419:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010541d:	0f 95 c0             	setne  %al
c0105420:	0f b6 c0             	movzbl %al,%eax
c0105423:	85 c0                	test   %eax,%eax
c0105425:	75 24                	jne    c010544b <buddy_init_memmap+0x88>
c0105427:	c7 44 24 0c 8c 7e 10 	movl   $0xc0107e8c,0xc(%esp)
c010542e:	c0 
c010542f:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0105436:	c0 
c0105437:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
c010543e:	00 
c010543f:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0105446:	e8 9e af ff ff       	call   c01003e9 <__panic>
	p->flags=p->property=0;
c010544b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010544e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0105455:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105458:	8b 50 08             	mov    0x8(%eax),%edx
c010545b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010545e:	89 50 04             	mov    %edx,0x4(%eax)
	set_page_ref(p,0);
c0105461:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105468:	00 
c0105469:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010546c:	89 04 24             	mov    %eax,(%esp)
c010546f:	e8 aa fe ff ff       	call   c010531e <set_page_ref>
     for(;p!=base+n;p++){
c0105474:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0105478:	8b 55 0c             	mov    0xc(%ebp),%edx
c010547b:	89 d0                	mov    %edx,%eax
c010547d:	c1 e0 02             	shl    $0x2,%eax
c0105480:	01 d0                	add    %edx,%eax
c0105482:	c1 e0 02             	shl    $0x2,%eax
c0105485:	89 c2                	mov    %eax,%edx
c0105487:	8b 45 08             	mov    0x8(%ebp),%eax
c010548a:	01 d0                	add    %edx,%eax
c010548c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010548f:	0f 85 66 ff ff ff    	jne    c01053fb <buddy_init_memmap+0x38>
     }
     p=base;
c0105495:	8b 45 08             	mov    0x8(%ebp),%eax
c0105498:	89 45 f4             	mov    %eax,-0xc(%ebp)
     size_t temp=n;
c010549b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010549e:	89 45 f0             	mov    %eax,-0x10(%ebp)
     int level=MAXLEVEL;
c01054a1:	c7 45 ec 0c 00 00 00 	movl   $0xc,-0x14(%ebp)
     while(level>=0){
c01054a8:	e9 fd 00 00 00       	jmp    c01055aa <buddy_init_memmap+0x1e7>
	for(int i=0;i<temp/(1<<level);i++){
c01054ad:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01054b4:	e9 c7 00 00 00       	jmp    c0105580 <buddy_init_memmap+0x1bd>
	    struct Page* page=p;
c01054b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	    page->property=1<<level;
c01054bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01054c2:	ba 01 00 00 00       	mov    $0x1,%edx
c01054c7:	88 c1                	mov    %al,%cl
c01054c9:	d3 e2                	shl    %cl,%edx
c01054cb:	89 d0                	mov    %edx,%eax
c01054cd:	89 c2                	mov    %eax,%edx
c01054cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054d2:	89 50 08             	mov    %edx,0x8(%eax)
	    SetPageProperty(p);
c01054d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054d8:	83 c0 04             	add    $0x4,%eax
c01054db:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01054e2:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01054e5:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01054e8:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01054eb:	0f ab 10             	bts    %edx,(%eax)
	    list_add_before(&free_area[level].free_list,&(page->page_link));
c01054ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054f1:	8d 48 0c             	lea    0xc(%eax),%ecx
c01054f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01054f7:	89 d0                	mov    %edx,%eax
c01054f9:	01 c0                	add    %eax,%eax
c01054fb:	01 d0                	add    %edx,%eax
c01054fd:	c1 e0 02             	shl    $0x2,%eax
c0105500:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105505:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105508:	89 4d d0             	mov    %ecx,-0x30(%ebp)
    __list_add(elm, listelm->prev, listelm);
c010550b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010550e:	8b 00                	mov    (%eax),%eax
c0105510:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105513:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0105516:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105519:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010551c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
c010551f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105522:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105525:	89 10                	mov    %edx,(%eax)
c0105527:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010552a:	8b 10                	mov    (%eax),%edx
c010552c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010552f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105532:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105535:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105538:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010553b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010553e:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105541:	89 10                	mov    %edx,(%eax)
	    p+=(1<<level);
c0105543:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105546:	ba 14 00 00 00       	mov    $0x14,%edx
c010554b:	88 c1                	mov    %al,%cl
c010554d:	d3 e2                	shl    %cl,%edx
c010554f:	89 d0                	mov    %edx,%eax
c0105551:	01 45 f4             	add    %eax,-0xc(%ebp)
	    free_area[level].nr_free++;
c0105554:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105557:	89 d0                	mov    %edx,%eax
c0105559:	01 c0                	add    %eax,%eax
c010555b:	01 d0                	add    %edx,%eax
c010555d:	c1 e0 02             	shl    $0x2,%eax
c0105560:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105565:	8b 00                	mov    (%eax),%eax
c0105567:	8d 48 01             	lea    0x1(%eax),%ecx
c010556a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010556d:	89 d0                	mov    %edx,%eax
c010556f:	01 c0                	add    %eax,%eax
c0105571:	01 d0                	add    %edx,%eax
c0105573:	c1 e0 02             	shl    $0x2,%eax
c0105576:	05 28 df 11 c0       	add    $0xc011df28,%eax
c010557b:	89 08                	mov    %ecx,(%eax)
	for(int i=0;i<temp/(1<<level);i++){
c010557d:	ff 45 e8             	incl   -0x18(%ebp)
c0105580:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105583:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105586:	88 c1                	mov    %al,%cl
c0105588:	d3 ea                	shr    %cl,%edx
c010558a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010558d:	39 c2                	cmp    %eax,%edx
c010558f:	0f 87 24 ff ff ff    	ja     c01054b9 <buddy_init_memmap+0xf6>
	}
	temp = temp % (1 << level);
c0105595:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105598:	ba 01 00 00 00       	mov    $0x1,%edx
c010559d:	88 c1                	mov    %al,%cl
c010559f:	d3 e2                	shl    %cl,%edx
c01055a1:	89 d0                	mov    %edx,%eax
c01055a3:	48                   	dec    %eax
c01055a4:	21 45 f0             	and    %eax,-0x10(%ebp)
	level--;
c01055a7:	ff 4d ec             	decl   -0x14(%ebp)
     while(level>=0){
c01055aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01055ae:	0f 89 f9 fe ff ff    	jns    c01054ad <buddy_init_memmap+0xea>
     }
}
c01055b4:	90                   	nop
c01055b5:	c9                   	leave  
c01055b6:	c3                   	ret    

c01055b7 <buddy_my_partial>:

static void
buddy_my_partial(struct Page *base, size_t n, int level) {
c01055b7:	55                   	push   %ebp
c01055b8:	89 e5                	mov    %esp,%ebp
c01055ba:	83 ec 78             	sub    $0x78,%esp
    if (level < 0) return;
c01055bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01055c1:	0f 88 20 02 00 00    	js     c01057e7 <buddy_my_partial+0x230>
    size_t temp = n;
c01055c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (level >= 0) {
c01055cd:	e9 7a 01 00 00       	jmp    c010574c <buddy_my_partial+0x195>
        for (int i = 0; i < temp / (1 << level); i++) {
c01055d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01055d9:	e9 44 01 00 00       	jmp    c0105722 <buddy_my_partial+0x16b>
            base->property = (1 << level);
c01055de:	8b 45 10             	mov    0x10(%ebp),%eax
c01055e1:	ba 01 00 00 00       	mov    $0x1,%edx
c01055e6:	88 c1                	mov    %al,%cl
c01055e8:	d3 e2                	shl    %cl,%edx
c01055ea:	89 d0                	mov    %edx,%eax
c01055ec:	89 c2                	mov    %eax,%edx
c01055ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f1:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(base);
c01055f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f7:	83 c0 04             	add    $0x4,%eax
c01055fa:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0105601:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105604:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105607:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010560a:	0f ab 10             	bts    %edx,(%eax)
            // add pages in order
            struct Page* p = NULL;
c010560d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
            list_entry_t* le = list_next(&(free_area[level].free_list));
c0105614:	8b 55 10             	mov    0x10(%ebp),%edx
c0105617:	89 d0                	mov    %edx,%eax
c0105619:	01 c0                	add    %eax,%eax
c010561b:	01 d0                	add    %edx,%eax
c010561d:	c1 e0 02             	shl    $0x2,%eax
c0105620:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105625:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return listelm->next;
c0105628:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010562b:	8b 40 04             	mov    0x4(%eax),%eax
c010562e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105631:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105634:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return listelm->prev;
c0105637:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010563a:	8b 00                	mov    (%eax),%eax
            list_entry_t* bfle = list_prev(le);
c010563c:	89 45 e8             	mov    %eax,-0x18(%ebp)
            while (le != &(free_area[level].free_list)) {
c010563f:	eb 37                	jmp    c0105678 <buddy_my_partial+0xc1>
                p = le2page(le, page_link);
c0105641:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105644:	83 e8 0c             	sub    $0xc,%eax
c0105647:	89 45 d8             	mov    %eax,-0x28(%ebp)
                if (base + base->property < le) break;
c010564a:	8b 45 08             	mov    0x8(%ebp),%eax
c010564d:	8b 50 08             	mov    0x8(%eax),%edx
c0105650:	89 d0                	mov    %edx,%eax
c0105652:	c1 e0 02             	shl    $0x2,%eax
c0105655:	01 d0                	add    %edx,%eax
c0105657:	c1 e0 02             	shl    $0x2,%eax
c010565a:	89 c2                	mov    %eax,%edx
c010565c:	8b 45 08             	mov    0x8(%ebp),%eax
c010565f:	01 d0                	add    %edx,%eax
c0105661:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105664:	77 2a                	ja     c0105690 <buddy_my_partial+0xd9>
                bfle = bfle->next;
c0105666:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105669:	8b 40 04             	mov    0x4(%eax),%eax
c010566c:	89 45 e8             	mov    %eax,-0x18(%ebp)
                le = le->next;
c010566f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105672:	8b 40 04             	mov    0x4(%eax),%eax
c0105675:	89 45 ec             	mov    %eax,-0x14(%ebp)
            while (le != &(free_area[level].free_list)) {
c0105678:	8b 55 10             	mov    0x10(%ebp),%edx
c010567b:	89 d0                	mov    %edx,%eax
c010567d:	01 c0                	add    %eax,%eax
c010567f:	01 d0                	add    %edx,%eax
c0105681:	c1 e0 02             	shl    $0x2,%eax
c0105684:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105689:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010568c:	75 b3                	jne    c0105641 <buddy_my_partial+0x8a>
c010568e:	eb 01                	jmp    c0105691 <buddy_my_partial+0xda>
                if (base + base->property < le) break;
c0105690:	90                   	nop
            }
            list_add(bfle, &(base->page_link));
c0105691:	8b 45 08             	mov    0x8(%ebp),%eax
c0105694:	8d 50 0c             	lea    0xc(%eax),%edx
c0105697:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010569a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010569d:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01056a0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01056a3:	89 45 bc             	mov    %eax,-0x44(%ebp)
c01056a6:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01056a9:	89 45 b8             	mov    %eax,-0x48(%ebp)
    __list_add(elm, listelm, listelm->next);
c01056ac:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01056af:	8b 40 04             	mov    0x4(%eax),%eax
c01056b2:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01056b5:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c01056b8:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01056bb:	89 55 b0             	mov    %edx,-0x50(%ebp)
c01056be:	89 45 ac             	mov    %eax,-0x54(%ebp)
    prev->next = next->prev = elm;
c01056c1:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01056c4:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01056c7:	89 10                	mov    %edx,(%eax)
c01056c9:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01056cc:	8b 10                	mov    (%eax),%edx
c01056ce:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01056d1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01056d4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01056d7:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01056da:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01056dd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01056e0:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01056e3:	89 10                	mov    %edx,(%eax)
            base += (1 << level);
c01056e5:	8b 45 10             	mov    0x10(%ebp),%eax
c01056e8:	ba 14 00 00 00       	mov    $0x14,%edx
c01056ed:	88 c1                	mov    %al,%cl
c01056ef:	d3 e2                	shl    %cl,%edx
c01056f1:	89 d0                	mov    %edx,%eax
c01056f3:	01 45 08             	add    %eax,0x8(%ebp)
            free_area[level].nr_free++;
c01056f6:	8b 55 10             	mov    0x10(%ebp),%edx
c01056f9:	89 d0                	mov    %edx,%eax
c01056fb:	01 c0                	add    %eax,%eax
c01056fd:	01 d0                	add    %edx,%eax
c01056ff:	c1 e0 02             	shl    $0x2,%eax
c0105702:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105707:	8b 00                	mov    (%eax),%eax
c0105709:	8d 48 01             	lea    0x1(%eax),%ecx
c010570c:	8b 55 10             	mov    0x10(%ebp),%edx
c010570f:	89 d0                	mov    %edx,%eax
c0105711:	01 c0                	add    %eax,%eax
c0105713:	01 d0                	add    %edx,%eax
c0105715:	c1 e0 02             	shl    $0x2,%eax
c0105718:	05 28 df 11 c0       	add    $0xc011df28,%eax
c010571d:	89 08                	mov    %ecx,(%eax)
        for (int i = 0; i < temp / (1 << level); i++) {
c010571f:	ff 45 f0             	incl   -0x10(%ebp)
c0105722:	8b 45 10             	mov    0x10(%ebp),%eax
c0105725:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105728:	88 c1                	mov    %al,%cl
c010572a:	d3 ea                	shr    %cl,%edx
c010572c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010572f:	39 c2                	cmp    %eax,%edx
c0105731:	0f 87 a7 fe ff ff    	ja     c01055de <buddy_my_partial+0x27>
        }
        temp = temp % (1 << level);
c0105737:	8b 45 10             	mov    0x10(%ebp),%eax
c010573a:	ba 01 00 00 00       	mov    $0x1,%edx
c010573f:	88 c1                	mov    %al,%cl
c0105741:	d3 e2                	shl    %cl,%edx
c0105743:	89 d0                	mov    %edx,%eax
c0105745:	48                   	dec    %eax
c0105746:	21 45 f4             	and    %eax,-0xc(%ebp)
        level--;
c0105749:	ff 4d 10             	decl   0x10(%ebp)
    while (level >= 0) {
c010574c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105750:	0f 89 7c fe ff ff    	jns    c01055d2 <buddy_my_partial+0x1b>
    }
    cprintf("alloc_page check: \n");
c0105756:	c7 04 24 9c 7e 10 c0 	movl   $0xc0107e9c,(%esp)
c010575d:	e8 30 ab ff ff       	call   c0100292 <cprintf>
    for (int i = MAXLEVEL; i >= 0; i--) {
c0105762:	c7 45 e4 0c 00 00 00 	movl   $0xc,-0x1c(%ebp)
c0105769:	eb 74                	jmp    c01057df <buddy_my_partial+0x228>
        list_entry_t* le = list_next(&(free_area[i].free_list));
c010576b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010576e:	89 d0                	mov    %edx,%eax
c0105770:	01 c0                	add    %eax,%eax
c0105772:	01 d0                	add    %edx,%eax
c0105774:	c1 e0 02             	shl    $0x2,%eax
c0105777:	05 20 df 11 c0       	add    $0xc011df20,%eax
c010577c:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return listelm->next;
c010577f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105782:	8b 40 04             	mov    0x4(%eax),%eax
c0105785:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
c0105788:	eb 3c                	jmp    c01057c6 <buddy_my_partial+0x20f>
            struct Page* page = le2page(le, page_link);
c010578a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010578d:	83 e8 0c             	sub    $0xc,%eax
c0105790:	89 45 dc             	mov    %eax,-0x24(%ebp)
            cprintf("%d - %llx\n", i, page->page_link);
c0105793:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105796:	8b 50 10             	mov    0x10(%eax),%edx
c0105799:	8b 40 0c             	mov    0xc(%eax),%eax
c010579c:	89 44 24 08          	mov    %eax,0x8(%esp)
c01057a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01057a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057ab:	c7 04 24 b0 7e 10 c0 	movl   $0xc0107eb0,(%esp)
c01057b2:	e8 db aa ff ff       	call   c0100292 <cprintf>
c01057b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057ba:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c01057bd:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01057c0:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
c01057c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
c01057c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01057c9:	89 d0                	mov    %edx,%eax
c01057cb:	01 c0                	add    %eax,%eax
c01057cd:	01 d0                	add    %edx,%eax
c01057cf:	c1 e0 02             	shl    $0x2,%eax
c01057d2:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01057d7:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01057da:	75 ae                	jne    c010578a <buddy_my_partial+0x1d3>
    for (int i = MAXLEVEL; i >= 0; i--) {
c01057dc:	ff 4d e4             	decl   -0x1c(%ebp)
c01057df:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01057e3:	79 86                	jns    c010576b <buddy_my_partial+0x1b4>
c01057e5:	eb 01                	jmp    c01057e8 <buddy_my_partial+0x231>
    if (level < 0) return;
c01057e7:	90                   	nop
        }
    }
}
c01057e8:	c9                   	leave  
c01057e9:	c3                   	ret    

c01057ea <buddy_my_merge>:

static void
buddy_my_merge(int level) {
c01057ea:	55                   	push   %ebp
c01057eb:	89 e5                	mov    %esp,%ebp
c01057ed:	83 ec 68             	sub    $0x68,%esp
    cprintf("before merge.\n");
c01057f0:	c7 04 24 bb 7e 10 c0 	movl   $0xc0107ebb,(%esp)
c01057f7:	e8 96 aa ff ff       	call   c0100292 <cprintf>
    //bds_selfcheck();
    while (level < MAXLEVEL) {
c01057fc:	e9 dc 01 00 00       	jmp    c01059dd <buddy_my_merge+0x1f3>
        if (free_area[level].nr_free <= 1) {
c0105801:	8b 55 08             	mov    0x8(%ebp),%edx
c0105804:	89 d0                	mov    %edx,%eax
c0105806:	01 c0                	add    %eax,%eax
c0105808:	01 d0                	add    %edx,%eax
c010580a:	c1 e0 02             	shl    $0x2,%eax
c010580d:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105812:	8b 00                	mov    (%eax),%eax
c0105814:	83 f8 01             	cmp    $0x1,%eax
c0105817:	77 08                	ja     c0105821 <buddy_my_merge+0x37>
            level++;
c0105819:	ff 45 08             	incl   0x8(%ebp)
            continue;
c010581c:	e9 bc 01 00 00       	jmp    c01059dd <buddy_my_merge+0x1f3>
        }
        list_entry_t* le = list_next(&(free_area[level].free_list));
c0105821:	8b 55 08             	mov    0x8(%ebp),%edx
c0105824:	89 d0                	mov    %edx,%eax
c0105826:	01 c0                	add    %eax,%eax
c0105828:	01 d0                	add    %edx,%eax
c010582a:	c1 e0 02             	shl    $0x2,%eax
c010582d:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105832:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105835:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105838:	8b 40 04             	mov    0x4(%eax),%eax
c010583b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010583e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105841:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->prev;
c0105844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105847:	8b 00                	mov    (%eax),%eax
        list_entry_t* bfle = list_prev(le);
c0105849:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while (le != &(free_area[level].free_list)) {
c010584c:	e9 6f 01 00 00       	jmp    c01059c0 <buddy_my_merge+0x1d6>
c0105851:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105854:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return listelm->next;
c0105857:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010585a:	8b 40 04             	mov    0x4(%eax),%eax
            bfle = list_next(bfle);
c010585d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105860:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105863:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105866:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105869:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
c010586c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            struct Page* ple = le2page(le, page_link);
c010586f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105872:	83 e8 0c             	sub    $0xc,%eax
c0105875:	89 45 ec             	mov    %eax,-0x14(%ebp)
            struct Page* pbf = le2page(bfle, page_link); 
c0105878:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010587b:	83 e8 0c             	sub    $0xc,%eax
c010587e:	89 45 e8             	mov    %eax,-0x18(%ebp)
            cprintf("bfle addr is: %llx\n", pbf->page_link);
c0105881:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105884:	8b 50 10             	mov    0x10(%eax),%edx
c0105887:	8b 40 0c             	mov    0xc(%eax),%eax
c010588a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010588e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105892:	c7 04 24 ca 7e 10 c0 	movl   $0xc0107eca,(%esp)
c0105899:	e8 f4 a9 ff ff       	call   c0100292 <cprintf>
            cprintf("le addr is: %llx\n", ple->page_link);
c010589e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058a1:	8b 50 10             	mov    0x10(%eax),%edx
c01058a4:	8b 40 0c             	mov    0xc(%eax),%eax
c01058a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058ab:	89 54 24 08          	mov    %edx,0x8(%esp)
c01058af:	c7 04 24 de 7e 10 c0 	movl   $0xc0107ede,(%esp)
c01058b6:	e8 d7 a9 ff ff       	call   c0100292 <cprintf>
            if (pbf + pbf->property == ple) {            
c01058bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058be:	8b 50 08             	mov    0x8(%eax),%edx
c01058c1:	89 d0                	mov    %edx,%eax
c01058c3:	c1 e0 02             	shl    $0x2,%eax
c01058c6:	01 d0                	add    %edx,%eax
c01058c8:	c1 e0 02             	shl    $0x2,%eax
c01058cb:	89 c2                	mov    %eax,%edx
c01058cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058d0:	01 d0                	add    %edx,%eax
c01058d2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01058d5:	0f 85 e5 00 00 00    	jne    c01059c0 <buddy_my_merge+0x1d6>
c01058db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058de:	89 45 b0             	mov    %eax,-0x50(%ebp)
c01058e1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01058e4:	8b 40 04             	mov    0x4(%eax),%eax
                bfle = list_next(bfle);
c01058e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058ed:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01058f0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01058f3:	8b 40 04             	mov    0x4(%eax),%eax
                le = list_next(le);
c01058f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
                pbf->property = pbf->property << 1;
c01058f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058fc:	8b 40 08             	mov    0x8(%eax),%eax
c01058ff:	8d 14 00             	lea    (%eax,%eax,1),%edx
c0105902:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105905:	89 50 08             	mov    %edx,0x8(%eax)
                ClearPageProperty(ple);
c0105908:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010590b:	83 c0 04             	add    $0x4,%eax
c010590e:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0105915:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105918:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010591b:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010591e:	0f b3 10             	btr    %edx,(%eax)
                list_del(&(pbf->page_link));
c0105921:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105924:	83 c0 0c             	add    $0xc,%eax
c0105927:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_del(listelm->prev, listelm->next);
c010592a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010592d:	8b 40 04             	mov    0x4(%eax),%eax
c0105930:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105933:	8b 12                	mov    (%edx),%edx
c0105935:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c0105938:	89 45 c0             	mov    %eax,-0x40(%ebp)
    prev->next = next;
c010593b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010593e:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105941:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105944:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105947:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010594a:	89 10                	mov    %edx,(%eax)
                list_del(&(ple->page_link));
c010594c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010594f:	83 c0 0c             	add    $0xc,%eax
c0105952:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105955:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105958:	8b 40 04             	mov    0x4(%eax),%eax
c010595b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010595e:	8b 12                	mov    (%edx),%edx
c0105960:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0105963:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next;
c0105966:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105969:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010596c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010596f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105972:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105975:	89 10                	mov    %edx,(%eax)
                buddy_my_partial(pbf, pbf->property, level + 1);             
c0105977:	8b 45 08             	mov    0x8(%ebp),%eax
c010597a:	8d 50 01             	lea    0x1(%eax),%edx
c010597d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105980:	8b 40 08             	mov    0x8(%eax),%eax
c0105983:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105987:	89 44 24 04          	mov    %eax,0x4(%esp)
c010598b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010598e:	89 04 24             	mov    %eax,(%esp)
c0105991:	e8 21 fc ff ff       	call   c01055b7 <buddy_my_partial>
                free_area[level].nr_free -= 2;              
c0105996:	8b 55 08             	mov    0x8(%ebp),%edx
c0105999:	89 d0                	mov    %edx,%eax
c010599b:	01 c0                	add    %eax,%eax
c010599d:	01 d0                	add    %edx,%eax
c010599f:	c1 e0 02             	shl    $0x2,%eax
c01059a2:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01059a7:	8b 00                	mov    (%eax),%eax
c01059a9:	8d 48 fe             	lea    -0x2(%eax),%ecx
c01059ac:	8b 55 08             	mov    0x8(%ebp),%edx
c01059af:	89 d0                	mov    %edx,%eax
c01059b1:	01 c0                	add    %eax,%eax
c01059b3:	01 d0                	add    %edx,%eax
c01059b5:	c1 e0 02             	shl    $0x2,%eax
c01059b8:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01059bd:	89 08                	mov    %ecx,(%eax)
                continue;
c01059bf:	90                   	nop
        while (le != &(free_area[level].free_list)) {
c01059c0:	8b 55 08             	mov    0x8(%ebp),%edx
c01059c3:	89 d0                	mov    %edx,%eax
c01059c5:	01 c0                	add    %eax,%eax
c01059c7:	01 d0                	add    %edx,%eax
c01059c9:	c1 e0 02             	shl    $0x2,%eax
c01059cc:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01059d1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01059d4:	0f 85 77 fe ff ff    	jne    c0105851 <buddy_my_merge+0x67>
            } 
        }
        level++;
c01059da:	ff 45 08             	incl   0x8(%ebp)
    while (level < MAXLEVEL) {
c01059dd:	83 7d 08 0b          	cmpl   $0xb,0x8(%ebp)
c01059e1:	0f 8e 1a fe ff ff    	jle    c0105801 <buddy_my_merge+0x17>
    }
    //bds_selfcheck();
}
c01059e7:	90                   	nop
c01059e8:	c9                   	leave  
c01059e9:	c3                   	ret    

c01059ea <buddy_alloc_page>:

static struct Page*
buddy_alloc_page(size_t n){
c01059ea:	55                   	push   %ebp
c01059eb:	89 e5                	mov    %esp,%ebp
c01059ed:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
c01059f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01059f4:	75 24                	jne    c0105a1a <buddy_alloc_page+0x30>
c01059f6:	c7 44 24 0c 5c 7e 10 	movl   $0xc0107e5c,0xc(%esp)
c01059fd:	c0 
c01059fe:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0105a05:	c0 
c0105a06:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0105a0d:	00 
c0105a0e:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0105a15:	e8 cf a9 ff ff       	call   c01003e9 <__panic>
     if(n>buddy_nr_free_page()){
c0105a1a:	e8 67 f9 ff ff       	call   c0105386 <buddy_nr_free_page>
c0105a1f:	39 45 08             	cmp    %eax,0x8(%ebp)
c0105a22:	76 0a                	jbe    c0105a2e <buddy_alloc_page+0x44>
	return NULL;
c0105a24:	b8 00 00 00 00       	mov    $0x0,%eax
c0105a29:	e9 62 01 00 00       	jmp    c0105b90 <buddy_alloc_page+0x1a6>
     }
     int level=0;
c0105a2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     while((1<<level)<n){
c0105a35:	eb 03                	jmp    c0105a3a <buddy_alloc_page+0x50>
	level++;
c0105a37:	ff 45 f4             	incl   -0xc(%ebp)
     while((1<<level)<n){
c0105a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a3d:	ba 01 00 00 00       	mov    $0x1,%edx
c0105a42:	88 c1                	mov    %al,%cl
c0105a44:	d3 e2                	shl    %cl,%edx
c0105a46:	89 d0                	mov    %edx,%eax
c0105a48:	39 45 08             	cmp    %eax,0x8(%ebp)
c0105a4b:	77 ea                	ja     c0105a37 <buddy_alloc_page+0x4d>
     }
     //n=1<<level;
     for(int i=level;i<=MAXLEVEL;i++){
c0105a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a50:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a53:	eb 22                	jmp    c0105a77 <buddy_alloc_page+0x8d>
	if(free_area[i].nr_free!=0){
c0105a55:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105a58:	89 d0                	mov    %edx,%eax
c0105a5a:	01 c0                	add    %eax,%eax
c0105a5c:	01 d0                	add    %edx,%eax
c0105a5e:	c1 e0 02             	shl    $0x2,%eax
c0105a61:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105a66:	8b 00                	mov    (%eax),%eax
c0105a68:	85 c0                	test   %eax,%eax
c0105a6a:	74 08                	je     c0105a74 <buddy_alloc_page+0x8a>
	   level=i;
c0105a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    break;
c0105a72:	eb 09                	jmp    c0105a7d <buddy_alloc_page+0x93>
     for(int i=level;i<=MAXLEVEL;i++){
c0105a74:	ff 45 f0             	incl   -0x10(%ebp)
c0105a77:	83 7d f0 0c          	cmpl   $0xc,-0x10(%ebp)
c0105a7b:	7e d8                	jle    c0105a55 <buddy_alloc_page+0x6b>
	}
     }
     if(level>MAXLEVEL){return NULL;}
c0105a7d:	83 7d f4 0c          	cmpl   $0xc,-0xc(%ebp)
c0105a81:	7e 0a                	jle    c0105a8d <buddy_alloc_page+0xa3>
c0105a83:	b8 00 00 00 00       	mov    $0x0,%eax
c0105a88:	e9 03 01 00 00       	jmp    c0105b90 <buddy_alloc_page+0x1a6>
     list_entry_t *le=&free_area[level].free_list;
c0105a8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a90:	89 d0                	mov    %edx,%eax
c0105a92:	01 c0                	add    %eax,%eax
c0105a94:	01 d0                	add    %edx,%eax
c0105a96:	c1 e0 02             	shl    $0x2,%eax
c0105a99:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105a9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
     struct Page* page=le2page(le,page_link);
c0105aa1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105aa4:	83 e8 0c             	sub    $0xc,%eax
c0105aa7:	89 45 e8             	mov    %eax,-0x18(%ebp)
     if (page != NULL) {
c0105aaa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105aae:	0f 84 cd 00 00 00    	je     c0105b81 <buddy_alloc_page+0x197>
        SetPageReserved(page);
c0105ab4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ab7:	83 c0 04             	add    $0x4,%eax
c0105aba:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
c0105ac1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105ac4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105ac7:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105aca:	0f ab 10             	bts    %edx,(%eax)
        // deal with partial work
        buddy_my_partial(page, page->property - n, level - 1);
c0105acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ad0:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105ad3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ad6:	8b 40 08             	mov    0x8(%eax),%eax
c0105ad9:	2b 45 08             	sub    0x8(%ebp),%eax
c0105adc:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105ae0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ae4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ae7:	89 04 24             	mov    %eax,(%esp)
c0105aea:	e8 c8 fa ff ff       	call   c01055b7 <buddy_my_partial>
        ClearPageReserved(page);
c0105aef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105af2:	83 c0 04             	add    $0x4,%eax
c0105af5:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
c0105afc:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105aff:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105b02:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105b05:	0f b3 10             	btr    %edx,(%eax)
        ClearPageProperty(page);
c0105b08:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b0b:	83 c0 04             	add    $0x4,%eax
c0105b0e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
c0105b15:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105b18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105b1b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105b1e:	0f b3 10             	btr    %edx,(%eax)
        list_del(&(page->page_link));
c0105b21:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b24:	83 c0 0c             	add    $0xc,%eax
c0105b27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105b2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b2d:	8b 40 04             	mov    0x4(%eax),%eax
c0105b30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105b33:	8b 12                	mov    (%edx),%edx
c0105b35:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0105b38:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c0105b3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b3e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105b41:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105b44:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105b47:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105b4a:	89 10                	mov    %edx,(%eax)
        free_area[level].nr_free--;
c0105b4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b4f:	89 d0                	mov    %edx,%eax
c0105b51:	01 c0                	add    %eax,%eax
c0105b53:	01 d0                	add    %edx,%eax
c0105b55:	c1 e0 02             	shl    $0x2,%eax
c0105b58:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105b5d:	8b 00                	mov    (%eax),%eax
c0105b5f:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105b62:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b65:	89 d0                	mov    %edx,%eax
c0105b67:	01 c0                	add    %eax,%eax
c0105b69:	01 d0                	add    %edx,%eax
c0105b6b:	c1 e0 02             	shl    $0x2,%eax
c0105b6e:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105b73:	89 08                	mov    %ecx,(%eax)
        buddy_my_merge(0);
c0105b75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105b7c:	e8 69 fc ff ff       	call   c01057ea <buddy_my_merge>
    }
    cprintf("after allocate & merge\n");
c0105b81:	c7 04 24 f0 7e 10 c0 	movl   $0xc0107ef0,(%esp)
c0105b88:	e8 05 a7 ff ff       	call   c0100292 <cprintf>
    //bds_selfcheck();
    return page;
c0105b8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
c0105b90:	c9                   	leave  
c0105b91:	c3                   	ret    

c0105b92 <buddy_free_page>:

static void 
buddy_free_page(struct Page* base, size_t n){
c0105b92:	55                   	push   %ebp
c0105b93:	89 e5                	mov    %esp,%ebp
c0105b95:	83 ec 48             	sub    $0x48,%esp
     assert(n > 0);
c0105b98:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105b9c:	75 24                	jne    c0105bc2 <buddy_free_page+0x30>
c0105b9e:	c7 44 24 0c 08 7f 10 	movl   $0xc0107f08,0xc(%esp)
c0105ba5:	c0 
c0105ba6:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0105bad:	c0 
c0105bae:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0105bb5:	00 
c0105bb6:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0105bbd:	e8 27 a8 ff ff       	call   c01003e9 <__panic>
    struct Page* p = base;
c0105bc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++) {
c0105bc8:	e9 9d 00 00 00       	jmp    c0105c6a <buddy_free_page+0xd8>
        assert(!PageReserved(p) && !PageProperty(p));
c0105bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bd0:	83 c0 04             	add    $0x4,%eax
c0105bd3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105bda:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105bdd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105be0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105be3:	0f a3 10             	bt     %edx,(%eax)
c0105be6:	19 c0                	sbb    %eax,%eax
c0105be8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0105beb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105bef:	0f 95 c0             	setne  %al
c0105bf2:	0f b6 c0             	movzbl %al,%eax
c0105bf5:	85 c0                	test   %eax,%eax
c0105bf7:	75 2c                	jne    c0105c25 <buddy_free_page+0x93>
c0105bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bfc:	83 c0 04             	add    $0x4,%eax
c0105bff:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0105c06:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105c09:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105c0c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105c0f:	0f a3 10             	bt     %edx,(%eax)
c0105c12:	19 c0                	sbb    %eax,%eax
c0105c14:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0105c17:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105c1b:	0f 95 c0             	setne  %al
c0105c1e:	0f b6 c0             	movzbl %al,%eax
c0105c21:	85 c0                	test   %eax,%eax
c0105c23:	74 24                	je     c0105c49 <buddy_free_page+0xb7>
c0105c25:	c7 44 24 0c 10 7f 10 	movl   $0xc0107f10,0xc(%esp)
c0105c2c:	c0 
c0105c2d:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0105c34:	c0 
c0105c35:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
c0105c3c:	00 
c0105c3d:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0105c44:	e8 a0 a7 ff ff       	call   c01003e9 <__panic>
        p->flags = 0;
c0105c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c4c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0105c53:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105c5a:	00 
c0105c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c5e:	89 04 24             	mov    %eax,(%esp)
c0105c61:	e8 b8 f6 ff ff       	call   c010531e <set_page_ref>
    for (; p != base + n; p++) {
c0105c66:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0105c6a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105c6d:	89 d0                	mov    %edx,%eax
c0105c6f:	c1 e0 02             	shl    $0x2,%eax
c0105c72:	01 d0                	add    %edx,%eax
c0105c74:	c1 e0 02             	shl    $0x2,%eax
c0105c77:	89 c2                	mov    %eax,%edx
c0105c79:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c7c:	01 d0                	add    %edx,%eax
c0105c7e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105c81:	0f 85 46 ff ff ff    	jne    c0105bcd <buddy_free_page+0x3b>
    }
    // free pages
    base->property = n;
c0105c87:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c8a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105c8d:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0105c90:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c93:	83 c0 04             	add    $0x4,%eax
c0105c96:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0105c9d:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105ca0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105ca3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105ca6:	0f ab 10             	bts    %edx,(%eax)
    int level = 0;
c0105ca9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    while ((1 << level) != n) { level++; }
c0105cb0:	eb 03                	jmp    c0105cb5 <buddy_free_page+0x123>
c0105cb2:	ff 45 f0             	incl   -0x10(%ebp)
c0105cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cb8:	ba 01 00 00 00       	mov    $0x1,%edx
c0105cbd:	88 c1                	mov    %al,%cl
c0105cbf:	d3 e2                	shl    %cl,%edx
c0105cc1:	89 d0                	mov    %edx,%eax
c0105cc3:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0105cc6:	75 ea                	jne    c0105cb2 <buddy_free_page+0x120>
    buddy_my_partial(base, n, level);
c0105cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ccb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cd9:	89 04 24             	mov    %eax,(%esp)
c0105cdc:	e8 d6 f8 ff ff       	call   c01055b7 <buddy_my_partial>
    //bds_selfcheck();
    free_area[level].nr_free++;
c0105ce1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105ce4:	89 d0                	mov    %edx,%eax
c0105ce6:	01 c0                	add    %eax,%eax
c0105ce8:	01 d0                	add    %edx,%eax
c0105cea:	c1 e0 02             	shl    $0x2,%eax
c0105ced:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105cf2:	8b 00                	mov    (%eax),%eax
c0105cf4:	8d 48 01             	lea    0x1(%eax),%ecx
c0105cf7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105cfa:	89 d0                	mov    %edx,%eax
c0105cfc:	01 c0                	add    %eax,%eax
c0105cfe:	01 d0                	add    %edx,%eax
c0105d00:	c1 e0 02             	shl    $0x2,%eax
c0105d03:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105d08:	89 08                	mov    %ecx,(%eax)
    buddy_my_merge(level); 
c0105d0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d0d:	89 04 24             	mov    %eax,(%esp)
c0105d10:	e8 d5 fa ff ff       	call   c01057ea <buddy_my_merge>
    //buddy_selfcheck();
}
c0105d15:	90                   	nop
c0105d16:	c9                   	leave  
c0105d17:	c3                   	ret    

c0105d18 <buddy_check>:

static void
buddy_check(void) {
c0105d18:	55                   	push   %ebp
c0105d19:	89 e5                	mov    %esp,%ebp
c0105d1b:	81 ec f8 00 00 00    	sub    $0xf8,%esp
    int count = 0, total = 0;
c0105d21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105d28:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) {
c0105d2f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105d36:	e9 a4 00 00 00       	jmp    c0105ddf <buddy_check+0xc7>
        list_entry_t* free_list = &(free_area[i].free_list);
c0105d3b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105d3e:	89 d0                	mov    %edx,%eax
c0105d40:	01 c0                	add    %eax,%eax
c0105d42:	01 d0                	add    %edx,%eax
c0105d44:	c1 e0 02             	shl    $0x2,%eax
c0105d47:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105d4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
        list_entry_t* le = free_list;
c0105d4f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105d52:	89 45 e8             	mov    %eax,-0x18(%ebp)
        while ((le = list_next(le)) != free_list) {
c0105d55:	eb 6a                	jmp    c0105dc1 <buddy_check+0xa9>
            struct Page* p = le2page(le, page_link);
c0105d57:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d5a:	83 e8 0c             	sub    $0xc,%eax
c0105d5d:	89 45 cc             	mov    %eax,-0x34(%ebp)
            assert(PageProperty(p));
c0105d60:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105d63:	83 c0 04             	add    $0x4,%eax
c0105d66:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0105d6d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105d70:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105d73:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105d76:	0f a3 10             	bt     %edx,(%eax)
c0105d79:	19 c0                	sbb    %eax,%eax
c0105d7b:	89 45 c0             	mov    %eax,-0x40(%ebp)
    return oldbit != 0;
c0105d7e:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0105d82:	0f 95 c0             	setne  %al
c0105d85:	0f b6 c0             	movzbl %al,%eax
c0105d88:	85 c0                	test   %eax,%eax
c0105d8a:	75 24                	jne    c0105db0 <buddy_check+0x98>
c0105d8c:	c7 44 24 0c 35 7f 10 	movl   $0xc0107f35,0xc(%esp)
c0105d93:	c0 
c0105d94:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0105d9b:	c0 
c0105d9c:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0105da3:	00 
c0105da4:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0105dab:	e8 39 a6 ff ff       	call   c01003e9 <__panic>
            count++;
c0105db0:	ff 45 f4             	incl   -0xc(%ebp)
            total += p->property;
c0105db3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105db6:	8b 50 08             	mov    0x8(%eax),%edx
c0105db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105dbc:	01 d0                	add    %edx,%eax
c0105dbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105dc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105dc4:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return listelm->next;
c0105dc7:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105dca:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != free_list) {
c0105dcd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105dd0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105dd3:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105dd6:	0f 85 7b ff ff ff    	jne    c0105d57 <buddy_check+0x3f>
    for (int i = 0; i <= MAXLEVEL; i++) {
c0105ddc:	ff 45 ec             	incl   -0x14(%ebp)
c0105ddf:	83 7d ec 0c          	cmpl   $0xc,-0x14(%ebp)
c0105de3:	0f 8e 52 ff ff ff    	jle    c0105d3b <buddy_check+0x23>
        }
    }
    assert(total == buddy_nr_free_page());
c0105de9:	e8 98 f5 ff ff       	call   c0105386 <buddy_nr_free_page>
c0105dee:	89 c2                	mov    %eax,%edx
c0105df0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105df3:	39 c2                	cmp    %eax,%edx
c0105df5:	74 24                	je     c0105e1b <buddy_check+0x103>
c0105df7:	c7 44 24 0c 45 7f 10 	movl   $0xc0107f45,0xc(%esp)
c0105dfe:	c0 
c0105dff:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0105e06:	c0 
c0105e07:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0105e0e:	00 
c0105e0f:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0105e16:	e8 ce a5 ff ff       	call   c01003e9 <__panic>

    // basic check
    struct Page *p0, *p1, *p2;
    p0 = p1 =p2 = NULL;
c0105e1b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105e22:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e25:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105e28:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105e2b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("p0\n");
c0105e2e:	c7 04 24 63 7f 10 c0 	movl   $0xc0107f63,(%esp)
c0105e35:	e8 58 a4 ff ff       	call   c0100292 <cprintf>
    assert((p0 = alloc_page()) != NULL);
c0105e3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e41:	e8 03 cd ff ff       	call   c0102b49 <alloc_pages>
c0105e46:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105e49:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0105e4d:	75 24                	jne    c0105e73 <buddy_check+0x15b>
c0105e4f:	c7 44 24 0c 67 7f 10 	movl   $0xc0107f67,0xc(%esp)
c0105e56:	c0 
c0105e57:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0105e5e:	c0 
c0105e5f:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c0105e66:	00 
c0105e67:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0105e6e:	e8 76 a5 ff ff       	call   c01003e9 <__panic>
    cprintf("p1\n");
c0105e73:	c7 04 24 83 7f 10 c0 	movl   $0xc0107f83,(%esp)
c0105e7a:	e8 13 a4 ff ff       	call   c0100292 <cprintf>
    assert((p1 = alloc_page()) != NULL);
c0105e7f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e86:	e8 be cc ff ff       	call   c0102b49 <alloc_pages>
c0105e8b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105e8e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105e92:	75 24                	jne    c0105eb8 <buddy_check+0x1a0>
c0105e94:	c7 44 24 0c 87 7f 10 	movl   $0xc0107f87,0xc(%esp)
c0105e9b:	c0 
c0105e9c:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0105ea3:	c0 
c0105ea4:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0105eab:	00 
c0105eac:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0105eb3:	e8 31 a5 ff ff       	call   c01003e9 <__panic>
    cprintf("p2\n");
c0105eb8:	c7 04 24 a3 7f 10 c0 	movl   $0xc0107fa3,(%esp)
c0105ebf:	e8 ce a3 ff ff       	call   c0100292 <cprintf>
    assert((p2 = alloc_page()) != NULL);
c0105ec4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105ecb:	e8 79 cc ff ff       	call   c0102b49 <alloc_pages>
c0105ed0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105ed3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105ed7:	75 24                	jne    c0105efd <buddy_check+0x1e5>
c0105ed9:	c7 44 24 0c a7 7f 10 	movl   $0xc0107fa7,0xc(%esp)
c0105ee0:	c0 
c0105ee1:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0105ee8:	c0 
c0105ee9:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0105ef0:	00 
c0105ef1:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0105ef8:	e8 ec a4 ff ff       	call   c01003e9 <__panic>

    assert(p0 != p1 && p1 != p2 && p2 != p0);
c0105efd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105f00:	3b 45 d8             	cmp    -0x28(%ebp),%eax
c0105f03:	74 10                	je     c0105f15 <buddy_check+0x1fd>
c0105f05:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105f08:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0105f0b:	74 08                	je     c0105f15 <buddy_check+0x1fd>
c0105f0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f10:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0105f13:	75 24                	jne    c0105f39 <buddy_check+0x221>
c0105f15:	c7 44 24 0c c4 7f 10 	movl   $0xc0107fc4,0xc(%esp)
c0105f1c:	c0 
c0105f1d:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0105f24:	c0 
c0105f25:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0105f2c:	00 
c0105f2d:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0105f34:	e8 b0 a4 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0105f39:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105f3c:	89 04 24             	mov    %eax,(%esp)
c0105f3f:	e8 d0 f3 ff ff       	call   c0105314 <page_ref>
c0105f44:	85 c0                	test   %eax,%eax
c0105f46:	75 1e                	jne    c0105f66 <buddy_check+0x24e>
c0105f48:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105f4b:	89 04 24             	mov    %eax,(%esp)
c0105f4e:	e8 c1 f3 ff ff       	call   c0105314 <page_ref>
c0105f53:	85 c0                	test   %eax,%eax
c0105f55:	75 0f                	jne    c0105f66 <buddy_check+0x24e>
c0105f57:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f5a:	89 04 24             	mov    %eax,(%esp)
c0105f5d:	e8 b2 f3 ff ff       	call   c0105314 <page_ref>
c0105f62:	85 c0                	test   %eax,%eax
c0105f64:	74 24                	je     c0105f8a <buddy_check+0x272>
c0105f66:	c7 44 24 0c e8 7f 10 	movl   $0xc0107fe8,0xc(%esp)
c0105f6d:	c0 
c0105f6e:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0105f75:	c0 
c0105f76:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0105f7d:	00 
c0105f7e:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0105f85:	e8 5f a4 ff ff       	call   c01003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0105f8a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105f8d:	89 04 24             	mov    %eax,(%esp)
c0105f90:	e8 69 f3 ff ff       	call   c01052fe <page2pa>
c0105f95:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0105f9b:	c1 e2 0c             	shl    $0xc,%edx
c0105f9e:	39 d0                	cmp    %edx,%eax
c0105fa0:	72 24                	jb     c0105fc6 <buddy_check+0x2ae>
c0105fa2:	c7 44 24 0c 24 80 10 	movl   $0xc0108024,0xc(%esp)
c0105fa9:	c0 
c0105faa:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0105fb1:	c0 
c0105fb2:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0105fb9:	00 
c0105fba:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0105fc1:	e8 23 a4 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0105fc6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105fc9:	89 04 24             	mov    %eax,(%esp)
c0105fcc:	e8 2d f3 ff ff       	call   c01052fe <page2pa>
c0105fd1:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0105fd7:	c1 e2 0c             	shl    $0xc,%edx
c0105fda:	39 d0                	cmp    %edx,%eax
c0105fdc:	72 24                	jb     c0106002 <buddy_check+0x2ea>
c0105fde:	c7 44 24 0c 41 80 10 	movl   $0xc0108041,0xc(%esp)
c0105fe5:	c0 
c0105fe6:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0105fed:	c0 
c0105fee:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0105ff5:	00 
c0105ff6:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0105ffd:	e8 e7 a3 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0106002:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106005:	89 04 24             	mov    %eax,(%esp)
c0106008:	e8 f1 f2 ff ff       	call   c01052fe <page2pa>
c010600d:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0106013:	c1 e2 0c             	shl    $0xc,%edx
c0106016:	39 d0                	cmp    %edx,%eax
c0106018:	72 24                	jb     c010603e <buddy_check+0x326>
c010601a:	c7 44 24 0c 5e 80 10 	movl   $0xc010805e,0xc(%esp)
c0106021:	c0 
c0106022:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0106029:	c0 
c010602a:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0106031:	00 
c0106032:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0106039:	e8 ab a3 ff ff       	call   c01003e9 <__panic>
    cprintf("first part of check successfully.\n");
c010603e:	c7 04 24 7c 80 10 c0 	movl   $0xc010807c,(%esp)
c0106045:	e8 48 a2 ff ff       	call   c0100292 <cprintf>

    free_area_t temp_list[MAXLEVEL + 1];
    for (int i = 0; i <= MAXLEVEL; i++) {
c010604a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0106051:	e9 c5 00 00 00       	jmp    c010611b <buddy_check+0x403>
        temp_list[i] = free_area[i];
c0106056:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106059:	89 d0                	mov    %edx,%eax
c010605b:	01 c0                	add    %eax,%eax
c010605d:	01 d0                	add    %edx,%eax
c010605f:	c1 e0 02             	shl    $0x2,%eax
c0106062:	8d 4d f8             	lea    -0x8(%ebp),%ecx
c0106065:	01 c8                	add    %ecx,%eax
c0106067:	8d 90 20 ff ff ff    	lea    -0xe0(%eax),%edx
c010606d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c0106070:	89 c8                	mov    %ecx,%eax
c0106072:	01 c0                	add    %eax,%eax
c0106074:	01 c8                	add    %ecx,%eax
c0106076:	c1 e0 02             	shl    $0x2,%eax
c0106079:	05 20 df 11 c0       	add    $0xc011df20,%eax
c010607e:	8b 08                	mov    (%eax),%ecx
c0106080:	89 0a                	mov    %ecx,(%edx)
c0106082:	8b 48 04             	mov    0x4(%eax),%ecx
c0106085:	89 4a 04             	mov    %ecx,0x4(%edx)
c0106088:	8b 40 08             	mov    0x8(%eax),%eax
c010608b:	89 42 08             	mov    %eax,0x8(%edx)
        list_init(&(free_area[i].free_list));
c010608e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106091:	89 d0                	mov    %edx,%eax
c0106093:	01 c0                	add    %eax,%eax
c0106095:	01 d0                	add    %edx,%eax
c0106097:	c1 e0 02             	shl    $0x2,%eax
c010609a:	05 20 df 11 c0       	add    $0xc011df20,%eax
c010609f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    elm->prev = elm->next = elm;
c01060a2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01060a5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01060a8:	89 50 04             	mov    %edx,0x4(%eax)
c01060ab:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01060ae:	8b 50 04             	mov    0x4(%eax),%edx
c01060b1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01060b4:	89 10                	mov    %edx,(%eax)
        assert(list_empty(&(free_area[i])));
c01060b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01060b9:	89 d0                	mov    %edx,%eax
c01060bb:	01 c0                	add    %eax,%eax
c01060bd:	01 d0                	add    %edx,%eax
c01060bf:	c1 e0 02             	shl    $0x2,%eax
c01060c2:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01060c7:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return list->next == list;
c01060ca:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01060cd:	8b 40 04             	mov    0x4(%eax),%eax
c01060d0:	39 45 b8             	cmp    %eax,-0x48(%ebp)
c01060d3:	0f 94 c0             	sete   %al
c01060d6:	0f b6 c0             	movzbl %al,%eax
c01060d9:	85 c0                	test   %eax,%eax
c01060db:	75 24                	jne    c0106101 <buddy_check+0x3e9>
c01060dd:	c7 44 24 0c 9f 80 10 	movl   $0xc010809f,0xc(%esp)
c01060e4:	c0 
c01060e5:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c01060ec:	c0 
c01060ed:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c01060f4:	00 
c01060f5:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c01060fc:	e8 e8 a2 ff ff       	call   c01003e9 <__panic>
        free_area[i].nr_free = 0;
c0106101:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106104:	89 d0                	mov    %edx,%eax
c0106106:	01 c0                	add    %eax,%eax
c0106108:	01 d0                	add    %edx,%eax
c010610a:	c1 e0 02             	shl    $0x2,%eax
c010610d:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0106112:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    for (int i = 0; i <= MAXLEVEL; i++) {
c0106118:	ff 45 e4             	incl   -0x1c(%ebp)
c010611b:	83 7d e4 0c          	cmpl   $0xc,-0x1c(%ebp)
c010611f:	0f 8e 31 ff ff ff    	jle    c0106056 <buddy_check+0x33e>
    }
    assert(alloc_page() == NULL);
c0106125:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010612c:	e8 18 ca ff ff       	call   c0102b49 <alloc_pages>
c0106131:	85 c0                	test   %eax,%eax
c0106133:	74 24                	je     c0106159 <buddy_check+0x441>
c0106135:	c7 44 24 0c bb 80 10 	movl   $0xc01080bb,0xc(%esp)
c010613c:	c0 
c010613d:	c7 44 24 08 60 7e 10 	movl   $0xc0107e60,0x8(%esp)
c0106144:	c0 
c0106145:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c010614c:	00 
c010614d:	c7 04 24 75 7e 10 c0 	movl   $0xc0107e75,(%esp)
c0106154:	e8 90 a2 ff ff       	call   c01003e9 <__panic>
    cprintf("clean successfully.\n");
c0106159:	c7 04 24 d0 80 10 c0 	movl   $0xc01080d0,(%esp)
c0106160:	e8 2d a1 ff ff       	call   c0100292 <cprintf>
    cprintf("p0\n");
c0106165:	c7 04 24 63 7f 10 c0 	movl   $0xc0107f63,(%esp)
c010616c:	e8 21 a1 ff ff       	call   c0100292 <cprintf>
    free_page(p0);
c0106171:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106178:	00 
c0106179:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010617c:	89 04 24             	mov    %eax,(%esp)
c010617f:	e8 fd c9 ff ff       	call   c0102b81 <free_pages>
    cprintf("p1\n");
c0106184:	c7 04 24 83 7f 10 c0 	movl   $0xc0107f83,(%esp)
c010618b:	e8 02 a1 ff ff       	call   c0100292 <cprintf>
    free_page(p1);
c0106190:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106197:	00 
c0106198:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010619b:	89 04 24             	mov    %eax,(%esp)
c010619e:	e8 de c9 ff ff       	call   c0102b81 <free_pages>
    cprintf("p2\n");
c01061a3:	c7 04 24 a3 7f 10 c0 	movl   $0xc0107fa3,(%esp)
c01061aa:	e8 e3 a0 ff ff       	call   c0100292 <cprintf>
    free_page(p2);
c01061af:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01061b6:	00 
c01061b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01061ba:	89 04 24             	mov    %eax,(%esp)
c01061bd:	e8 bf c9 ff ff       	call   c0102b81 <free_pages>
    total = 0;
c01061c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
c01061c9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c01061d0:	eb 1e                	jmp    c01061f0 <buddy_check+0x4d8>
        total += free_area[i].nr_free;
c01061d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01061d5:	89 d0                	mov    %edx,%eax
c01061d7:	01 c0                	add    %eax,%eax
c01061d9:	01 d0                	add    %edx,%eax
c01061db:	c1 e0 02             	shl    $0x2,%eax
c01061de:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01061e3:	8b 10                	mov    (%eax),%edx
c01061e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061e8:	01 d0                	add    %edx,%eax
c01061ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
c01061ed:	ff 45 e0             	incl   -0x20(%ebp)
c01061f0:	83 7d e0 0c          	cmpl   $0xc,-0x20(%ebp)
c01061f4:	7e dc                	jle    c01061d2 <buddy_check+0x4ba>

    //assert((p0 = alloc_page()) != NULL);
    //assert((p1 = alloc_page()) != NULL);
    //assert((p2 = alloc_page()) != NULL);
    //assert(alloc_page() == NULL);
}
c01061f6:	90                   	nop
c01061f7:	c9                   	leave  
c01061f8:	c3                   	ret    

c01061f9 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01061f9:	55                   	push   %ebp
c01061fa:	89 e5                	mov    %esp,%ebp
c01061fc:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01061ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0106206:	eb 03                	jmp    c010620b <strlen+0x12>
        cnt ++;
c0106208:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c010620b:	8b 45 08             	mov    0x8(%ebp),%eax
c010620e:	8d 50 01             	lea    0x1(%eax),%edx
c0106211:	89 55 08             	mov    %edx,0x8(%ebp)
c0106214:	0f b6 00             	movzbl (%eax),%eax
c0106217:	84 c0                	test   %al,%al
c0106219:	75 ed                	jne    c0106208 <strlen+0xf>
    }
    return cnt;
c010621b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010621e:	c9                   	leave  
c010621f:	c3                   	ret    

c0106220 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0106220:	55                   	push   %ebp
c0106221:	89 e5                	mov    %esp,%ebp
c0106223:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0106226:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010622d:	eb 03                	jmp    c0106232 <strnlen+0x12>
        cnt ++;
c010622f:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0106232:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106235:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106238:	73 10                	jae    c010624a <strnlen+0x2a>
c010623a:	8b 45 08             	mov    0x8(%ebp),%eax
c010623d:	8d 50 01             	lea    0x1(%eax),%edx
c0106240:	89 55 08             	mov    %edx,0x8(%ebp)
c0106243:	0f b6 00             	movzbl (%eax),%eax
c0106246:	84 c0                	test   %al,%al
c0106248:	75 e5                	jne    c010622f <strnlen+0xf>
    }
    return cnt;
c010624a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010624d:	c9                   	leave  
c010624e:	c3                   	ret    

c010624f <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010624f:	55                   	push   %ebp
c0106250:	89 e5                	mov    %esp,%ebp
c0106252:	57                   	push   %edi
c0106253:	56                   	push   %esi
c0106254:	83 ec 20             	sub    $0x20,%esp
c0106257:	8b 45 08             	mov    0x8(%ebp),%eax
c010625a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010625d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106260:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0106263:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106266:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106269:	89 d1                	mov    %edx,%ecx
c010626b:	89 c2                	mov    %eax,%edx
c010626d:	89 ce                	mov    %ecx,%esi
c010626f:	89 d7                	mov    %edx,%edi
c0106271:	ac                   	lods   %ds:(%esi),%al
c0106272:	aa                   	stos   %al,%es:(%edi)
c0106273:	84 c0                	test   %al,%al
c0106275:	75 fa                	jne    c0106271 <strcpy+0x22>
c0106277:	89 fa                	mov    %edi,%edx
c0106279:	89 f1                	mov    %esi,%ecx
c010627b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010627e:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0106281:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0106284:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0106287:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0106288:	83 c4 20             	add    $0x20,%esp
c010628b:	5e                   	pop    %esi
c010628c:	5f                   	pop    %edi
c010628d:	5d                   	pop    %ebp
c010628e:	c3                   	ret    

c010628f <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010628f:	55                   	push   %ebp
c0106290:	89 e5                	mov    %esp,%ebp
c0106292:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0106295:	8b 45 08             	mov    0x8(%ebp),%eax
c0106298:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010629b:	eb 1e                	jmp    c01062bb <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c010629d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01062a0:	0f b6 10             	movzbl (%eax),%edx
c01062a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01062a6:	88 10                	mov    %dl,(%eax)
c01062a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01062ab:	0f b6 00             	movzbl (%eax),%eax
c01062ae:	84 c0                	test   %al,%al
c01062b0:	74 03                	je     c01062b5 <strncpy+0x26>
            src ++;
c01062b2:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c01062b5:	ff 45 fc             	incl   -0x4(%ebp)
c01062b8:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c01062bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01062bf:	75 dc                	jne    c010629d <strncpy+0xe>
    }
    return dst;
c01062c1:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01062c4:	c9                   	leave  
c01062c5:	c3                   	ret    

c01062c6 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01062c6:	55                   	push   %ebp
c01062c7:	89 e5                	mov    %esp,%ebp
c01062c9:	57                   	push   %edi
c01062ca:	56                   	push   %esi
c01062cb:	83 ec 20             	sub    $0x20,%esp
c01062ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01062d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01062d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01062d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c01062da:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01062dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01062e0:	89 d1                	mov    %edx,%ecx
c01062e2:	89 c2                	mov    %eax,%edx
c01062e4:	89 ce                	mov    %ecx,%esi
c01062e6:	89 d7                	mov    %edx,%edi
c01062e8:	ac                   	lods   %ds:(%esi),%al
c01062e9:	ae                   	scas   %es:(%edi),%al
c01062ea:	75 08                	jne    c01062f4 <strcmp+0x2e>
c01062ec:	84 c0                	test   %al,%al
c01062ee:	75 f8                	jne    c01062e8 <strcmp+0x22>
c01062f0:	31 c0                	xor    %eax,%eax
c01062f2:	eb 04                	jmp    c01062f8 <strcmp+0x32>
c01062f4:	19 c0                	sbb    %eax,%eax
c01062f6:	0c 01                	or     $0x1,%al
c01062f8:	89 fa                	mov    %edi,%edx
c01062fa:	89 f1                	mov    %esi,%ecx
c01062fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01062ff:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106302:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0106305:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c0106308:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0106309:	83 c4 20             	add    $0x20,%esp
c010630c:	5e                   	pop    %esi
c010630d:	5f                   	pop    %edi
c010630e:	5d                   	pop    %ebp
c010630f:	c3                   	ret    

c0106310 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0106310:	55                   	push   %ebp
c0106311:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106313:	eb 09                	jmp    c010631e <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0106315:	ff 4d 10             	decl   0x10(%ebp)
c0106318:	ff 45 08             	incl   0x8(%ebp)
c010631b:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010631e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106322:	74 1a                	je     c010633e <strncmp+0x2e>
c0106324:	8b 45 08             	mov    0x8(%ebp),%eax
c0106327:	0f b6 00             	movzbl (%eax),%eax
c010632a:	84 c0                	test   %al,%al
c010632c:	74 10                	je     c010633e <strncmp+0x2e>
c010632e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106331:	0f b6 10             	movzbl (%eax),%edx
c0106334:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106337:	0f b6 00             	movzbl (%eax),%eax
c010633a:	38 c2                	cmp    %al,%dl
c010633c:	74 d7                	je     c0106315 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010633e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106342:	74 18                	je     c010635c <strncmp+0x4c>
c0106344:	8b 45 08             	mov    0x8(%ebp),%eax
c0106347:	0f b6 00             	movzbl (%eax),%eax
c010634a:	0f b6 d0             	movzbl %al,%edx
c010634d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106350:	0f b6 00             	movzbl (%eax),%eax
c0106353:	0f b6 c0             	movzbl %al,%eax
c0106356:	29 c2                	sub    %eax,%edx
c0106358:	89 d0                	mov    %edx,%eax
c010635a:	eb 05                	jmp    c0106361 <strncmp+0x51>
c010635c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106361:	5d                   	pop    %ebp
c0106362:	c3                   	ret    

c0106363 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0106363:	55                   	push   %ebp
c0106364:	89 e5                	mov    %esp,%ebp
c0106366:	83 ec 04             	sub    $0x4,%esp
c0106369:	8b 45 0c             	mov    0xc(%ebp),%eax
c010636c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010636f:	eb 13                	jmp    c0106384 <strchr+0x21>
        if (*s == c) {
c0106371:	8b 45 08             	mov    0x8(%ebp),%eax
c0106374:	0f b6 00             	movzbl (%eax),%eax
c0106377:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010637a:	75 05                	jne    c0106381 <strchr+0x1e>
            return (char *)s;
c010637c:	8b 45 08             	mov    0x8(%ebp),%eax
c010637f:	eb 12                	jmp    c0106393 <strchr+0x30>
        }
        s ++;
c0106381:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0106384:	8b 45 08             	mov    0x8(%ebp),%eax
c0106387:	0f b6 00             	movzbl (%eax),%eax
c010638a:	84 c0                	test   %al,%al
c010638c:	75 e3                	jne    c0106371 <strchr+0xe>
    }
    return NULL;
c010638e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106393:	c9                   	leave  
c0106394:	c3                   	ret    

c0106395 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0106395:	55                   	push   %ebp
c0106396:	89 e5                	mov    %esp,%ebp
c0106398:	83 ec 04             	sub    $0x4,%esp
c010639b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010639e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01063a1:	eb 0e                	jmp    c01063b1 <strfind+0x1c>
        if (*s == c) {
c01063a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01063a6:	0f b6 00             	movzbl (%eax),%eax
c01063a9:	38 45 fc             	cmp    %al,-0x4(%ebp)
c01063ac:	74 0f                	je     c01063bd <strfind+0x28>
            break;
        }
        s ++;
c01063ae:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c01063b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01063b4:	0f b6 00             	movzbl (%eax),%eax
c01063b7:	84 c0                	test   %al,%al
c01063b9:	75 e8                	jne    c01063a3 <strfind+0xe>
c01063bb:	eb 01                	jmp    c01063be <strfind+0x29>
            break;
c01063bd:	90                   	nop
    }
    return (char *)s;
c01063be:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01063c1:	c9                   	leave  
c01063c2:	c3                   	ret    

c01063c3 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c01063c3:	55                   	push   %ebp
c01063c4:	89 e5                	mov    %esp,%ebp
c01063c6:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c01063c9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c01063d0:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01063d7:	eb 03                	jmp    c01063dc <strtol+0x19>
        s ++;
c01063d9:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c01063dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01063df:	0f b6 00             	movzbl (%eax),%eax
c01063e2:	3c 20                	cmp    $0x20,%al
c01063e4:	74 f3                	je     c01063d9 <strtol+0x16>
c01063e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01063e9:	0f b6 00             	movzbl (%eax),%eax
c01063ec:	3c 09                	cmp    $0x9,%al
c01063ee:	74 e9                	je     c01063d9 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c01063f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01063f3:	0f b6 00             	movzbl (%eax),%eax
c01063f6:	3c 2b                	cmp    $0x2b,%al
c01063f8:	75 05                	jne    c01063ff <strtol+0x3c>
        s ++;
c01063fa:	ff 45 08             	incl   0x8(%ebp)
c01063fd:	eb 14                	jmp    c0106413 <strtol+0x50>
    }
    else if (*s == '-') {
c01063ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0106402:	0f b6 00             	movzbl (%eax),%eax
c0106405:	3c 2d                	cmp    $0x2d,%al
c0106407:	75 0a                	jne    c0106413 <strtol+0x50>
        s ++, neg = 1;
c0106409:	ff 45 08             	incl   0x8(%ebp)
c010640c:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0106413:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106417:	74 06                	je     c010641f <strtol+0x5c>
c0106419:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010641d:	75 22                	jne    c0106441 <strtol+0x7e>
c010641f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106422:	0f b6 00             	movzbl (%eax),%eax
c0106425:	3c 30                	cmp    $0x30,%al
c0106427:	75 18                	jne    c0106441 <strtol+0x7e>
c0106429:	8b 45 08             	mov    0x8(%ebp),%eax
c010642c:	40                   	inc    %eax
c010642d:	0f b6 00             	movzbl (%eax),%eax
c0106430:	3c 78                	cmp    $0x78,%al
c0106432:	75 0d                	jne    c0106441 <strtol+0x7e>
        s += 2, base = 16;
c0106434:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0106438:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010643f:	eb 29                	jmp    c010646a <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0106441:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106445:	75 16                	jne    c010645d <strtol+0x9a>
c0106447:	8b 45 08             	mov    0x8(%ebp),%eax
c010644a:	0f b6 00             	movzbl (%eax),%eax
c010644d:	3c 30                	cmp    $0x30,%al
c010644f:	75 0c                	jne    c010645d <strtol+0x9a>
        s ++, base = 8;
c0106451:	ff 45 08             	incl   0x8(%ebp)
c0106454:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010645b:	eb 0d                	jmp    c010646a <strtol+0xa7>
    }
    else if (base == 0) {
c010645d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106461:	75 07                	jne    c010646a <strtol+0xa7>
        base = 10;
c0106463:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010646a:	8b 45 08             	mov    0x8(%ebp),%eax
c010646d:	0f b6 00             	movzbl (%eax),%eax
c0106470:	3c 2f                	cmp    $0x2f,%al
c0106472:	7e 1b                	jle    c010648f <strtol+0xcc>
c0106474:	8b 45 08             	mov    0x8(%ebp),%eax
c0106477:	0f b6 00             	movzbl (%eax),%eax
c010647a:	3c 39                	cmp    $0x39,%al
c010647c:	7f 11                	jg     c010648f <strtol+0xcc>
            dig = *s - '0';
c010647e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106481:	0f b6 00             	movzbl (%eax),%eax
c0106484:	0f be c0             	movsbl %al,%eax
c0106487:	83 e8 30             	sub    $0x30,%eax
c010648a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010648d:	eb 48                	jmp    c01064d7 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010648f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106492:	0f b6 00             	movzbl (%eax),%eax
c0106495:	3c 60                	cmp    $0x60,%al
c0106497:	7e 1b                	jle    c01064b4 <strtol+0xf1>
c0106499:	8b 45 08             	mov    0x8(%ebp),%eax
c010649c:	0f b6 00             	movzbl (%eax),%eax
c010649f:	3c 7a                	cmp    $0x7a,%al
c01064a1:	7f 11                	jg     c01064b4 <strtol+0xf1>
            dig = *s - 'a' + 10;
c01064a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01064a6:	0f b6 00             	movzbl (%eax),%eax
c01064a9:	0f be c0             	movsbl %al,%eax
c01064ac:	83 e8 57             	sub    $0x57,%eax
c01064af:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01064b2:	eb 23                	jmp    c01064d7 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c01064b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01064b7:	0f b6 00             	movzbl (%eax),%eax
c01064ba:	3c 40                	cmp    $0x40,%al
c01064bc:	7e 3b                	jle    c01064f9 <strtol+0x136>
c01064be:	8b 45 08             	mov    0x8(%ebp),%eax
c01064c1:	0f b6 00             	movzbl (%eax),%eax
c01064c4:	3c 5a                	cmp    $0x5a,%al
c01064c6:	7f 31                	jg     c01064f9 <strtol+0x136>
            dig = *s - 'A' + 10;
c01064c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01064cb:	0f b6 00             	movzbl (%eax),%eax
c01064ce:	0f be c0             	movsbl %al,%eax
c01064d1:	83 e8 37             	sub    $0x37,%eax
c01064d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c01064d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01064da:	3b 45 10             	cmp    0x10(%ebp),%eax
c01064dd:	7d 19                	jge    c01064f8 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c01064df:	ff 45 08             	incl   0x8(%ebp)
c01064e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01064e5:	0f af 45 10          	imul   0x10(%ebp),%eax
c01064e9:	89 c2                	mov    %eax,%edx
c01064eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01064ee:	01 d0                	add    %edx,%eax
c01064f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c01064f3:	e9 72 ff ff ff       	jmp    c010646a <strtol+0xa7>
            break;
c01064f8:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c01064f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01064fd:	74 08                	je     c0106507 <strtol+0x144>
        *endptr = (char *) s;
c01064ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106502:	8b 55 08             	mov    0x8(%ebp),%edx
c0106505:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0106507:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010650b:	74 07                	je     c0106514 <strtol+0x151>
c010650d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106510:	f7 d8                	neg    %eax
c0106512:	eb 03                	jmp    c0106517 <strtol+0x154>
c0106514:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0106517:	c9                   	leave  
c0106518:	c3                   	ret    

c0106519 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0106519:	55                   	push   %ebp
c010651a:	89 e5                	mov    %esp,%ebp
c010651c:	57                   	push   %edi
c010651d:	83 ec 24             	sub    $0x24,%esp
c0106520:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106523:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0106526:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010652a:	8b 55 08             	mov    0x8(%ebp),%edx
c010652d:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0106530:	88 45 f7             	mov    %al,-0x9(%ebp)
c0106533:	8b 45 10             	mov    0x10(%ebp),%eax
c0106536:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0106539:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010653c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0106540:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0106543:	89 d7                	mov    %edx,%edi
c0106545:	f3 aa                	rep stos %al,%es:(%edi)
c0106547:	89 fa                	mov    %edi,%edx
c0106549:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010654c:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010654f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106552:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0106553:	83 c4 24             	add    $0x24,%esp
c0106556:	5f                   	pop    %edi
c0106557:	5d                   	pop    %ebp
c0106558:	c3                   	ret    

c0106559 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0106559:	55                   	push   %ebp
c010655a:	89 e5                	mov    %esp,%ebp
c010655c:	57                   	push   %edi
c010655d:	56                   	push   %esi
c010655e:	53                   	push   %ebx
c010655f:	83 ec 30             	sub    $0x30,%esp
c0106562:	8b 45 08             	mov    0x8(%ebp),%eax
c0106565:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106568:	8b 45 0c             	mov    0xc(%ebp),%eax
c010656b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010656e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106571:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0106574:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106577:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010657a:	73 42                	jae    c01065be <memmove+0x65>
c010657c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010657f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106582:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106585:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106588:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010658b:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010658e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106591:	c1 e8 02             	shr    $0x2,%eax
c0106594:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0106596:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106599:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010659c:	89 d7                	mov    %edx,%edi
c010659e:	89 c6                	mov    %eax,%esi
c01065a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01065a2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01065a5:	83 e1 03             	and    $0x3,%ecx
c01065a8:	74 02                	je     c01065ac <memmove+0x53>
c01065aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01065ac:	89 f0                	mov    %esi,%eax
c01065ae:	89 fa                	mov    %edi,%edx
c01065b0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c01065b3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01065b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c01065b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c01065bc:	eb 36                	jmp    c01065f4 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c01065be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01065c1:	8d 50 ff             	lea    -0x1(%eax),%edx
c01065c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01065c7:	01 c2                	add    %eax,%edx
c01065c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01065cc:	8d 48 ff             	lea    -0x1(%eax),%ecx
c01065cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065d2:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c01065d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01065d8:	89 c1                	mov    %eax,%ecx
c01065da:	89 d8                	mov    %ebx,%eax
c01065dc:	89 d6                	mov    %edx,%esi
c01065de:	89 c7                	mov    %eax,%edi
c01065e0:	fd                   	std    
c01065e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01065e3:	fc                   	cld    
c01065e4:	89 f8                	mov    %edi,%eax
c01065e6:	89 f2                	mov    %esi,%edx
c01065e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01065eb:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01065ee:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c01065f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01065f4:	83 c4 30             	add    $0x30,%esp
c01065f7:	5b                   	pop    %ebx
c01065f8:	5e                   	pop    %esi
c01065f9:	5f                   	pop    %edi
c01065fa:	5d                   	pop    %ebp
c01065fb:	c3                   	ret    

c01065fc <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01065fc:	55                   	push   %ebp
c01065fd:	89 e5                	mov    %esp,%ebp
c01065ff:	57                   	push   %edi
c0106600:	56                   	push   %esi
c0106601:	83 ec 20             	sub    $0x20,%esp
c0106604:	8b 45 08             	mov    0x8(%ebp),%eax
c0106607:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010660a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010660d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106610:	8b 45 10             	mov    0x10(%ebp),%eax
c0106613:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106616:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106619:	c1 e8 02             	shr    $0x2,%eax
c010661c:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010661e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106621:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106624:	89 d7                	mov    %edx,%edi
c0106626:	89 c6                	mov    %eax,%esi
c0106628:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010662a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010662d:	83 e1 03             	and    $0x3,%ecx
c0106630:	74 02                	je     c0106634 <memcpy+0x38>
c0106632:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106634:	89 f0                	mov    %esi,%eax
c0106636:	89 fa                	mov    %edi,%edx
c0106638:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010663b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010663e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0106641:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0106644:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0106645:	83 c4 20             	add    $0x20,%esp
c0106648:	5e                   	pop    %esi
c0106649:	5f                   	pop    %edi
c010664a:	5d                   	pop    %ebp
c010664b:	c3                   	ret    

c010664c <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010664c:	55                   	push   %ebp
c010664d:	89 e5                	mov    %esp,%ebp
c010664f:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0106652:	8b 45 08             	mov    0x8(%ebp),%eax
c0106655:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0106658:	8b 45 0c             	mov    0xc(%ebp),%eax
c010665b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010665e:	eb 2e                	jmp    c010668e <memcmp+0x42>
        if (*s1 != *s2) {
c0106660:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106663:	0f b6 10             	movzbl (%eax),%edx
c0106666:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106669:	0f b6 00             	movzbl (%eax),%eax
c010666c:	38 c2                	cmp    %al,%dl
c010666e:	74 18                	je     c0106688 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0106670:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106673:	0f b6 00             	movzbl (%eax),%eax
c0106676:	0f b6 d0             	movzbl %al,%edx
c0106679:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010667c:	0f b6 00             	movzbl (%eax),%eax
c010667f:	0f b6 c0             	movzbl %al,%eax
c0106682:	29 c2                	sub    %eax,%edx
c0106684:	89 d0                	mov    %edx,%eax
c0106686:	eb 18                	jmp    c01066a0 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0106688:	ff 45 fc             	incl   -0x4(%ebp)
c010668b:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c010668e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106691:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106694:	89 55 10             	mov    %edx,0x10(%ebp)
c0106697:	85 c0                	test   %eax,%eax
c0106699:	75 c5                	jne    c0106660 <memcmp+0x14>
    }
    return 0;
c010669b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01066a0:	c9                   	leave  
c01066a1:	c3                   	ret    

c01066a2 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01066a2:	55                   	push   %ebp
c01066a3:	89 e5                	mov    %esp,%ebp
c01066a5:	83 ec 58             	sub    $0x58,%esp
c01066a8:	8b 45 10             	mov    0x10(%ebp),%eax
c01066ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01066ae:	8b 45 14             	mov    0x14(%ebp),%eax
c01066b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01066b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01066b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01066ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01066bd:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01066c0:	8b 45 18             	mov    0x18(%ebp),%eax
c01066c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01066c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01066c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01066cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01066cf:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01066d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01066d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01066dc:	74 1c                	je     c01066fa <printnum+0x58>
c01066de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066e1:	ba 00 00 00 00       	mov    $0x0,%edx
c01066e6:	f7 75 e4             	divl   -0x1c(%ebp)
c01066e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01066ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066ef:	ba 00 00 00 00       	mov    $0x0,%edx
c01066f4:	f7 75 e4             	divl   -0x1c(%ebp)
c01066f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01066fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01066fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106700:	f7 75 e4             	divl   -0x1c(%ebp)
c0106703:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106706:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0106709:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010670c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010670f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106712:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0106715:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106718:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010671b:	8b 45 18             	mov    0x18(%ebp),%eax
c010671e:	ba 00 00 00 00       	mov    $0x0,%edx
c0106723:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0106726:	72 56                	jb     c010677e <printnum+0xdc>
c0106728:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c010672b:	77 05                	ja     c0106732 <printnum+0x90>
c010672d:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0106730:	72 4c                	jb     c010677e <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0106732:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106735:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106738:	8b 45 20             	mov    0x20(%ebp),%eax
c010673b:	89 44 24 18          	mov    %eax,0x18(%esp)
c010673f:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106743:	8b 45 18             	mov    0x18(%ebp),%eax
c0106746:	89 44 24 10          	mov    %eax,0x10(%esp)
c010674a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010674d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106750:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106754:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106758:	8b 45 0c             	mov    0xc(%ebp),%eax
c010675b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010675f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106762:	89 04 24             	mov    %eax,(%esp)
c0106765:	e8 38 ff ff ff       	call   c01066a2 <printnum>
c010676a:	eb 1b                	jmp    c0106787 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010676c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010676f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106773:	8b 45 20             	mov    0x20(%ebp),%eax
c0106776:	89 04 24             	mov    %eax,(%esp)
c0106779:	8b 45 08             	mov    0x8(%ebp),%eax
c010677c:	ff d0                	call   *%eax
        while (-- width > 0)
c010677e:	ff 4d 1c             	decl   0x1c(%ebp)
c0106781:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106785:	7f e5                	jg     c010676c <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0106787:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010678a:	05 90 81 10 c0       	add    $0xc0108190,%eax
c010678f:	0f b6 00             	movzbl (%eax),%eax
c0106792:	0f be c0             	movsbl %al,%eax
c0106795:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106798:	89 54 24 04          	mov    %edx,0x4(%esp)
c010679c:	89 04 24             	mov    %eax,(%esp)
c010679f:	8b 45 08             	mov    0x8(%ebp),%eax
c01067a2:	ff d0                	call   *%eax
}
c01067a4:	90                   	nop
c01067a5:	c9                   	leave  
c01067a6:	c3                   	ret    

c01067a7 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01067a7:	55                   	push   %ebp
c01067a8:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01067aa:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01067ae:	7e 14                	jle    c01067c4 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01067b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01067b3:	8b 00                	mov    (%eax),%eax
c01067b5:	8d 48 08             	lea    0x8(%eax),%ecx
c01067b8:	8b 55 08             	mov    0x8(%ebp),%edx
c01067bb:	89 0a                	mov    %ecx,(%edx)
c01067bd:	8b 50 04             	mov    0x4(%eax),%edx
c01067c0:	8b 00                	mov    (%eax),%eax
c01067c2:	eb 30                	jmp    c01067f4 <getuint+0x4d>
    }
    else if (lflag) {
c01067c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01067c8:	74 16                	je     c01067e0 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01067ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01067cd:	8b 00                	mov    (%eax),%eax
c01067cf:	8d 48 04             	lea    0x4(%eax),%ecx
c01067d2:	8b 55 08             	mov    0x8(%ebp),%edx
c01067d5:	89 0a                	mov    %ecx,(%edx)
c01067d7:	8b 00                	mov    (%eax),%eax
c01067d9:	ba 00 00 00 00       	mov    $0x0,%edx
c01067de:	eb 14                	jmp    c01067f4 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01067e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01067e3:	8b 00                	mov    (%eax),%eax
c01067e5:	8d 48 04             	lea    0x4(%eax),%ecx
c01067e8:	8b 55 08             	mov    0x8(%ebp),%edx
c01067eb:	89 0a                	mov    %ecx,(%edx)
c01067ed:	8b 00                	mov    (%eax),%eax
c01067ef:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01067f4:	5d                   	pop    %ebp
c01067f5:	c3                   	ret    

c01067f6 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01067f6:	55                   	push   %ebp
c01067f7:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01067f9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01067fd:	7e 14                	jle    c0106813 <getint+0x1d>
        return va_arg(*ap, long long);
c01067ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0106802:	8b 00                	mov    (%eax),%eax
c0106804:	8d 48 08             	lea    0x8(%eax),%ecx
c0106807:	8b 55 08             	mov    0x8(%ebp),%edx
c010680a:	89 0a                	mov    %ecx,(%edx)
c010680c:	8b 50 04             	mov    0x4(%eax),%edx
c010680f:	8b 00                	mov    (%eax),%eax
c0106811:	eb 28                	jmp    c010683b <getint+0x45>
    }
    else if (lflag) {
c0106813:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106817:	74 12                	je     c010682b <getint+0x35>
        return va_arg(*ap, long);
c0106819:	8b 45 08             	mov    0x8(%ebp),%eax
c010681c:	8b 00                	mov    (%eax),%eax
c010681e:	8d 48 04             	lea    0x4(%eax),%ecx
c0106821:	8b 55 08             	mov    0x8(%ebp),%edx
c0106824:	89 0a                	mov    %ecx,(%edx)
c0106826:	8b 00                	mov    (%eax),%eax
c0106828:	99                   	cltd   
c0106829:	eb 10                	jmp    c010683b <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010682b:	8b 45 08             	mov    0x8(%ebp),%eax
c010682e:	8b 00                	mov    (%eax),%eax
c0106830:	8d 48 04             	lea    0x4(%eax),%ecx
c0106833:	8b 55 08             	mov    0x8(%ebp),%edx
c0106836:	89 0a                	mov    %ecx,(%edx)
c0106838:	8b 00                	mov    (%eax),%eax
c010683a:	99                   	cltd   
    }
}
c010683b:	5d                   	pop    %ebp
c010683c:	c3                   	ret    

c010683d <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010683d:	55                   	push   %ebp
c010683e:	89 e5                	mov    %esp,%ebp
c0106840:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0106843:	8d 45 14             	lea    0x14(%ebp),%eax
c0106846:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0106849:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010684c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106850:	8b 45 10             	mov    0x10(%ebp),%eax
c0106853:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106857:	8b 45 0c             	mov    0xc(%ebp),%eax
c010685a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010685e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106861:	89 04 24             	mov    %eax,(%esp)
c0106864:	e8 03 00 00 00       	call   c010686c <vprintfmt>
    va_end(ap);
}
c0106869:	90                   	nop
c010686a:	c9                   	leave  
c010686b:	c3                   	ret    

c010686c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010686c:	55                   	push   %ebp
c010686d:	89 e5                	mov    %esp,%ebp
c010686f:	56                   	push   %esi
c0106870:	53                   	push   %ebx
c0106871:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0106874:	eb 17                	jmp    c010688d <vprintfmt+0x21>
            if (ch == '\0') {
c0106876:	85 db                	test   %ebx,%ebx
c0106878:	0f 84 bf 03 00 00    	je     c0106c3d <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c010687e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106881:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106885:	89 1c 24             	mov    %ebx,(%esp)
c0106888:	8b 45 08             	mov    0x8(%ebp),%eax
c010688b:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010688d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106890:	8d 50 01             	lea    0x1(%eax),%edx
c0106893:	89 55 10             	mov    %edx,0x10(%ebp)
c0106896:	0f b6 00             	movzbl (%eax),%eax
c0106899:	0f b6 d8             	movzbl %al,%ebx
c010689c:	83 fb 25             	cmp    $0x25,%ebx
c010689f:	75 d5                	jne    c0106876 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c01068a1:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01068a5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01068ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068af:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01068b2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01068b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01068bc:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01068bf:	8b 45 10             	mov    0x10(%ebp),%eax
c01068c2:	8d 50 01             	lea    0x1(%eax),%edx
c01068c5:	89 55 10             	mov    %edx,0x10(%ebp)
c01068c8:	0f b6 00             	movzbl (%eax),%eax
c01068cb:	0f b6 d8             	movzbl %al,%ebx
c01068ce:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01068d1:	83 f8 55             	cmp    $0x55,%eax
c01068d4:	0f 87 37 03 00 00    	ja     c0106c11 <vprintfmt+0x3a5>
c01068da:	8b 04 85 b4 81 10 c0 	mov    -0x3fef7e4c(,%eax,4),%eax
c01068e1:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c01068e3:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01068e7:	eb d6                	jmp    c01068bf <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01068e9:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01068ed:	eb d0                	jmp    c01068bf <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01068ef:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01068f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01068f9:	89 d0                	mov    %edx,%eax
c01068fb:	c1 e0 02             	shl    $0x2,%eax
c01068fe:	01 d0                	add    %edx,%eax
c0106900:	01 c0                	add    %eax,%eax
c0106902:	01 d8                	add    %ebx,%eax
c0106904:	83 e8 30             	sub    $0x30,%eax
c0106907:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010690a:	8b 45 10             	mov    0x10(%ebp),%eax
c010690d:	0f b6 00             	movzbl (%eax),%eax
c0106910:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0106913:	83 fb 2f             	cmp    $0x2f,%ebx
c0106916:	7e 38                	jle    c0106950 <vprintfmt+0xe4>
c0106918:	83 fb 39             	cmp    $0x39,%ebx
c010691b:	7f 33                	jg     c0106950 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c010691d:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0106920:	eb d4                	jmp    c01068f6 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0106922:	8b 45 14             	mov    0x14(%ebp),%eax
c0106925:	8d 50 04             	lea    0x4(%eax),%edx
c0106928:	89 55 14             	mov    %edx,0x14(%ebp)
c010692b:	8b 00                	mov    (%eax),%eax
c010692d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0106930:	eb 1f                	jmp    c0106951 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0106932:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106936:	79 87                	jns    c01068bf <vprintfmt+0x53>
                width = 0;
c0106938:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010693f:	e9 7b ff ff ff       	jmp    c01068bf <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0106944:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010694b:	e9 6f ff ff ff       	jmp    c01068bf <vprintfmt+0x53>
            goto process_precision;
c0106950:	90                   	nop

        process_precision:
            if (width < 0)
c0106951:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106955:	0f 89 64 ff ff ff    	jns    c01068bf <vprintfmt+0x53>
                width = precision, precision = -1;
c010695b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010695e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106961:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0106968:	e9 52 ff ff ff       	jmp    c01068bf <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010696d:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0106970:	e9 4a ff ff ff       	jmp    c01068bf <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0106975:	8b 45 14             	mov    0x14(%ebp),%eax
c0106978:	8d 50 04             	lea    0x4(%eax),%edx
c010697b:	89 55 14             	mov    %edx,0x14(%ebp)
c010697e:	8b 00                	mov    (%eax),%eax
c0106980:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106983:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106987:	89 04 24             	mov    %eax,(%esp)
c010698a:	8b 45 08             	mov    0x8(%ebp),%eax
c010698d:	ff d0                	call   *%eax
            break;
c010698f:	e9 a4 02 00 00       	jmp    c0106c38 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0106994:	8b 45 14             	mov    0x14(%ebp),%eax
c0106997:	8d 50 04             	lea    0x4(%eax),%edx
c010699a:	89 55 14             	mov    %edx,0x14(%ebp)
c010699d:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010699f:	85 db                	test   %ebx,%ebx
c01069a1:	79 02                	jns    c01069a5 <vprintfmt+0x139>
                err = -err;
c01069a3:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01069a5:	83 fb 06             	cmp    $0x6,%ebx
c01069a8:	7f 0b                	jg     c01069b5 <vprintfmt+0x149>
c01069aa:	8b 34 9d 74 81 10 c0 	mov    -0x3fef7e8c(,%ebx,4),%esi
c01069b1:	85 f6                	test   %esi,%esi
c01069b3:	75 23                	jne    c01069d8 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c01069b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01069b9:	c7 44 24 08 a1 81 10 	movl   $0xc01081a1,0x8(%esp)
c01069c0:	c0 
c01069c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01069cb:	89 04 24             	mov    %eax,(%esp)
c01069ce:	e8 6a fe ff ff       	call   c010683d <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c01069d3:	e9 60 02 00 00       	jmp    c0106c38 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c01069d8:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01069dc:	c7 44 24 08 aa 81 10 	movl   $0xc01081aa,0x8(%esp)
c01069e3:	c0 
c01069e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01069ee:	89 04 24             	mov    %eax,(%esp)
c01069f1:	e8 47 fe ff ff       	call   c010683d <printfmt>
            break;
c01069f6:	e9 3d 02 00 00       	jmp    c0106c38 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01069fb:	8b 45 14             	mov    0x14(%ebp),%eax
c01069fe:	8d 50 04             	lea    0x4(%eax),%edx
c0106a01:	89 55 14             	mov    %edx,0x14(%ebp)
c0106a04:	8b 30                	mov    (%eax),%esi
c0106a06:	85 f6                	test   %esi,%esi
c0106a08:	75 05                	jne    c0106a0f <vprintfmt+0x1a3>
                p = "(null)";
c0106a0a:	be ad 81 10 c0       	mov    $0xc01081ad,%esi
            }
            if (width > 0 && padc != '-') {
c0106a0f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106a13:	7e 76                	jle    c0106a8b <vprintfmt+0x21f>
c0106a15:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0106a19:	74 70                	je     c0106a8b <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106a1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a22:	89 34 24             	mov    %esi,(%esp)
c0106a25:	e8 f6 f7 ff ff       	call   c0106220 <strnlen>
c0106a2a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106a2d:	29 c2                	sub    %eax,%edx
c0106a2f:	89 d0                	mov    %edx,%eax
c0106a31:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106a34:	eb 16                	jmp    c0106a4c <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0106a36:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0106a3a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106a3d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a41:	89 04 24             	mov    %eax,(%esp)
c0106a44:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a47:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106a49:	ff 4d e8             	decl   -0x18(%ebp)
c0106a4c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106a50:	7f e4                	jg     c0106a36 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106a52:	eb 37                	jmp    c0106a8b <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0106a54:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106a58:	74 1f                	je     c0106a79 <vprintfmt+0x20d>
c0106a5a:	83 fb 1f             	cmp    $0x1f,%ebx
c0106a5d:	7e 05                	jle    c0106a64 <vprintfmt+0x1f8>
c0106a5f:	83 fb 7e             	cmp    $0x7e,%ebx
c0106a62:	7e 15                	jle    c0106a79 <vprintfmt+0x20d>
                    putch('?', putdat);
c0106a64:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a6b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0106a72:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a75:	ff d0                	call   *%eax
c0106a77:	eb 0f                	jmp    c0106a88 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0106a79:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a80:	89 1c 24             	mov    %ebx,(%esp)
c0106a83:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a86:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106a88:	ff 4d e8             	decl   -0x18(%ebp)
c0106a8b:	89 f0                	mov    %esi,%eax
c0106a8d:	8d 70 01             	lea    0x1(%eax),%esi
c0106a90:	0f b6 00             	movzbl (%eax),%eax
c0106a93:	0f be d8             	movsbl %al,%ebx
c0106a96:	85 db                	test   %ebx,%ebx
c0106a98:	74 27                	je     c0106ac1 <vprintfmt+0x255>
c0106a9a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106a9e:	78 b4                	js     c0106a54 <vprintfmt+0x1e8>
c0106aa0:	ff 4d e4             	decl   -0x1c(%ebp)
c0106aa3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106aa7:	79 ab                	jns    c0106a54 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0106aa9:	eb 16                	jmp    c0106ac1 <vprintfmt+0x255>
                putch(' ', putdat);
c0106aab:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106aae:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ab2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0106ab9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106abc:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0106abe:	ff 4d e8             	decl   -0x18(%ebp)
c0106ac1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106ac5:	7f e4                	jg     c0106aab <vprintfmt+0x23f>
            }
            break;
c0106ac7:	e9 6c 01 00 00       	jmp    c0106c38 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0106acc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106acf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ad3:	8d 45 14             	lea    0x14(%ebp),%eax
c0106ad6:	89 04 24             	mov    %eax,(%esp)
c0106ad9:	e8 18 fd ff ff       	call   c01067f6 <getint>
c0106ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106ae1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0106ae4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ae7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106aea:	85 d2                	test   %edx,%edx
c0106aec:	79 26                	jns    c0106b14 <vprintfmt+0x2a8>
                putch('-', putdat);
c0106aee:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106af1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106af5:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0106afc:	8b 45 08             	mov    0x8(%ebp),%eax
c0106aff:	ff d0                	call   *%eax
                num = -(long long)num;
c0106b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b04:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106b07:	f7 d8                	neg    %eax
c0106b09:	83 d2 00             	adc    $0x0,%edx
c0106b0c:	f7 da                	neg    %edx
c0106b0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b11:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0106b14:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106b1b:	e9 a8 00 00 00       	jmp    c0106bc8 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0106b20:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b23:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b27:	8d 45 14             	lea    0x14(%ebp),%eax
c0106b2a:	89 04 24             	mov    %eax,(%esp)
c0106b2d:	e8 75 fc ff ff       	call   c01067a7 <getuint>
c0106b32:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b35:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0106b38:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106b3f:	e9 84 00 00 00       	jmp    c0106bc8 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0106b44:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b4b:	8d 45 14             	lea    0x14(%ebp),%eax
c0106b4e:	89 04 24             	mov    %eax,(%esp)
c0106b51:	e8 51 fc ff ff       	call   c01067a7 <getuint>
c0106b56:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b59:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0106b5c:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0106b63:	eb 63                	jmp    c0106bc8 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0106b65:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b68:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b6c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0106b73:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b76:	ff d0                	call   *%eax
            putch('x', putdat);
c0106b78:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b7f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0106b86:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b89:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0106b8b:	8b 45 14             	mov    0x14(%ebp),%eax
c0106b8e:	8d 50 04             	lea    0x4(%eax),%edx
c0106b91:	89 55 14             	mov    %edx,0x14(%ebp)
c0106b94:	8b 00                	mov    (%eax),%eax
c0106b96:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0106ba0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0106ba7:	eb 1f                	jmp    c0106bc8 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0106ba9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106bac:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bb0:	8d 45 14             	lea    0x14(%ebp),%eax
c0106bb3:	89 04 24             	mov    %eax,(%esp)
c0106bb6:	e8 ec fb ff ff       	call   c01067a7 <getuint>
c0106bbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106bbe:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0106bc1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0106bc8:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0106bcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bcf:	89 54 24 18          	mov    %edx,0x18(%esp)
c0106bd3:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106bd6:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106bda:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106be1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106be4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106be8:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106bec:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bef:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bf6:	89 04 24             	mov    %eax,(%esp)
c0106bf9:	e8 a4 fa ff ff       	call   c01066a2 <printnum>
            break;
c0106bfe:	eb 38                	jmp    c0106c38 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0106c00:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c07:	89 1c 24             	mov    %ebx,(%esp)
c0106c0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c0d:	ff d0                	call   *%eax
            break;
c0106c0f:	eb 27                	jmp    c0106c38 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0106c11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c18:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0106c1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c22:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0106c24:	ff 4d 10             	decl   0x10(%ebp)
c0106c27:	eb 03                	jmp    c0106c2c <vprintfmt+0x3c0>
c0106c29:	ff 4d 10             	decl   0x10(%ebp)
c0106c2c:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c2f:	48                   	dec    %eax
c0106c30:	0f b6 00             	movzbl (%eax),%eax
c0106c33:	3c 25                	cmp    $0x25,%al
c0106c35:	75 f2                	jne    c0106c29 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0106c37:	90                   	nop
    while (1) {
c0106c38:	e9 37 fc ff ff       	jmp    c0106874 <vprintfmt+0x8>
                return;
c0106c3d:	90                   	nop
        }
    }
}
c0106c3e:	83 c4 40             	add    $0x40,%esp
c0106c41:	5b                   	pop    %ebx
c0106c42:	5e                   	pop    %esi
c0106c43:	5d                   	pop    %ebp
c0106c44:	c3                   	ret    

c0106c45 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0106c45:	55                   	push   %ebp
c0106c46:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0106c48:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c4b:	8b 40 08             	mov    0x8(%eax),%eax
c0106c4e:	8d 50 01             	lea    0x1(%eax),%edx
c0106c51:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c54:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106c57:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c5a:	8b 10                	mov    (%eax),%edx
c0106c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c5f:	8b 40 04             	mov    0x4(%eax),%eax
c0106c62:	39 c2                	cmp    %eax,%edx
c0106c64:	73 12                	jae    c0106c78 <sprintputch+0x33>
        *b->buf ++ = ch;
c0106c66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c69:	8b 00                	mov    (%eax),%eax
c0106c6b:	8d 48 01             	lea    0x1(%eax),%ecx
c0106c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106c71:	89 0a                	mov    %ecx,(%edx)
c0106c73:	8b 55 08             	mov    0x8(%ebp),%edx
c0106c76:	88 10                	mov    %dl,(%eax)
    }
}
c0106c78:	90                   	nop
c0106c79:	5d                   	pop    %ebp
c0106c7a:	c3                   	ret    

c0106c7b <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0106c7b:	55                   	push   %ebp
c0106c7c:	89 e5                	mov    %esp,%ebp
c0106c7e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0106c81:	8d 45 14             	lea    0x14(%ebp),%eax
c0106c84:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0106c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106c8e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c91:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106c95:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c98:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c9f:	89 04 24             	mov    %eax,(%esp)
c0106ca2:	e8 08 00 00 00       	call   c0106caf <vsnprintf>
c0106ca7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0106caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106cad:	c9                   	leave  
c0106cae:	c3                   	ret    

c0106caf <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0106caf:	55                   	push   %ebp
c0106cb0:	89 e5                	mov    %esp,%ebp
c0106cb2:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0106cb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106cbe:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106cc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cc4:	01 d0                	add    %edx,%eax
c0106cc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106cc9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0106cd0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106cd4:	74 0a                	je     c0106ce0 <vsnprintf+0x31>
c0106cd6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106cdc:	39 c2                	cmp    %eax,%edx
c0106cde:	76 07                	jbe    c0106ce7 <vsnprintf+0x38>
        return -E_INVAL;
c0106ce0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0106ce5:	eb 2a                	jmp    c0106d11 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0106ce7:	8b 45 14             	mov    0x14(%ebp),%eax
c0106cea:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106cee:	8b 45 10             	mov    0x10(%ebp),%eax
c0106cf1:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106cf5:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0106cf8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106cfc:	c7 04 24 45 6c 10 c0 	movl   $0xc0106c45,(%esp)
c0106d03:	e8 64 fb ff ff       	call   c010686c <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0106d08:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d0b:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0106d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106d11:	c9                   	leave  
c0106d12:	c3                   	ret    
