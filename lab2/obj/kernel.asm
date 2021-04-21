
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
c010005d:	e8 5b 64 00 00       	call   c01064bd <memset>

    cons_init();                // init the console
c0100062:	e8 80 15 00 00       	call   c01015e7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 c0 6c 10 c0 	movl   $0xc0106cc0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 dc 6c 10 c0 	movl   $0xc0106cdc,(%esp)
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
c0100162:	c7 04 24 e1 6c 10 c0 	movl   $0xc0106ce1,(%esp)
c0100169:	e8 24 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100172:	89 c2                	mov    %eax,%edx
c0100174:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 ef 6c 10 c0 	movl   $0xc0106cef,(%esp)
c0100188:	e8 05 01 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	89 c2                	mov    %eax,%edx
c0100193:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c0100198:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a0:	c7 04 24 fd 6c 10 c0 	movl   $0xc0106cfd,(%esp)
c01001a7:	e8 e6 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b0:	89 c2                	mov    %eax,%edx
c01001b2:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bf:	c7 04 24 0b 6d 10 c0 	movl   $0xc0106d0b,(%esp)
c01001c6:	e8 c7 00 00 00       	call   c0100292 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001cf:	89 c2                	mov    %eax,%edx
c01001d1:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001de:	c7 04 24 19 6d 10 c0 	movl   $0xc0106d19,(%esp)
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
c010020f:	c7 04 24 28 6d 10 c0 	movl   $0xc0106d28,(%esp)
c0100216:	e8 77 00 00 00       	call   c0100292 <cprintf>
    lab1_switch_to_user();
c010021b:	e8 d8 ff ff ff       	call   c01001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100220:	e8 15 ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100225:	c7 04 24 48 6d 10 c0 	movl   $0xc0106d48,(%esp)
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
c0100288:	e8 83 65 00 00       	call   c0106810 <vprintfmt>
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
c0100347:	c7 04 24 67 6d 10 c0 	movl   $0xc0106d67,(%esp)
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
c0100416:	c7 04 24 6a 6d 10 c0 	movl   $0xc0106d6a,(%esp)
c010041d:	e8 70 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c0100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100425:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100429:	8b 45 10             	mov    0x10(%ebp),%eax
c010042c:	89 04 24             	mov    %eax,(%esp)
c010042f:	e8 2b fe ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c0100434:	c7 04 24 86 6d 10 c0 	movl   $0xc0106d86,(%esp)
c010043b:	e8 52 fe ff ff       	call   c0100292 <cprintf>
    
    cprintf("stack trackback:\n");
c0100440:	c7 04 24 88 6d 10 c0 	movl   $0xc0106d88,(%esp)
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
c0100481:	c7 04 24 9a 6d 10 c0 	movl   $0xc0106d9a,(%esp)
c0100488:	e8 05 fe ff ff       	call   c0100292 <cprintf>
    vcprintf(fmt, ap);
c010048d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100490:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100494:	8b 45 10             	mov    0x10(%ebp),%eax
c0100497:	89 04 24             	mov    %eax,(%esp)
c010049a:	e8 c0 fd ff ff       	call   c010025f <vcprintf>
    cprintf("\n");
c010049f:	c7 04 24 86 6d 10 c0 	movl   $0xc0106d86,(%esp)
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
c010060f:	c7 00 b8 6d 10 c0    	movl   $0xc0106db8,(%eax)
    info->eip_line = 0;
c0100615:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100618:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010061f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100622:	c7 40 08 b8 6d 10 c0 	movl   $0xc0106db8,0x8(%eax)
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
c0100646:	c7 45 f4 ac 82 10 c0 	movl   $0xc01082ac,-0xc(%ebp)
    stab_end = __STAB_END__;
c010064d:	c7 45 f0 20 4a 11 c0 	movl   $0xc0114a20,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100654:	c7 45 ec 21 4a 11 c0 	movl   $0xc0114a21,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010065b:	c7 45 e8 f4 76 11 c0 	movl   $0xc01176f4,-0x18(%ebp)

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
c01007b6:	e8 7e 5b 00 00       	call   c0106339 <strfind>
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
c010093e:	c7 04 24 c2 6d 10 c0 	movl   $0xc0106dc2,(%esp)
c0100945:	e8 48 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010094a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100951:	c0 
c0100952:	c7 04 24 db 6d 10 c0 	movl   $0xc0106ddb,(%esp)
c0100959:	e8 34 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010095e:	c7 44 24 04 b7 6c 10 	movl   $0xc0106cb7,0x4(%esp)
c0100965:	c0 
c0100966:	c7 04 24 f3 6d 10 c0 	movl   $0xc0106df3,(%esp)
c010096d:	e8 20 f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100972:	c7 44 24 04 00 d0 11 	movl   $0xc011d000,0x4(%esp)
c0100979:	c0 
c010097a:	c7 04 24 0b 6e 10 c0 	movl   $0xc0106e0b,(%esp)
c0100981:	e8 0c f9 ff ff       	call   c0100292 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100986:	c7 44 24 04 bc df 11 	movl   $0xc011dfbc,0x4(%esp)
c010098d:	c0 
c010098e:	c7 04 24 23 6e 10 c0 	movl   $0xc0106e23,(%esp)
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
c01009c0:	c7 04 24 3c 6e 10 c0 	movl   $0xc0106e3c,(%esp)
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
c01009f5:	c7 04 24 66 6e 10 c0 	movl   $0xc0106e66,(%esp)
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
c0100a63:	c7 04 24 82 6e 10 c0 	movl   $0xc0106e82,(%esp)
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
c0100ab6:	c7 04 24 94 6e 10 c0 	movl   $0xc0106e94,(%esp)
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
c0100ae9:	c7 04 24 b0 6e 10 c0 	movl   $0xc0106eb0,(%esp)
c0100af0:	e8 9d f7 ff ff       	call   c0100292 <cprintf>
		for(int i=0;i<4;i++){
c0100af5:	ff 45 e8             	incl   -0x18(%ebp)
c0100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100afc:	7e d6                	jle    c0100ad4 <print_stackframe+0x51>
		}
		cprintf("\n");
c0100afe:	c7 04 24 b8 6e 10 c0 	movl   $0xc0106eb8,(%esp)
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
c0100b71:	c7 04 24 3c 6f 10 c0 	movl   $0xc0106f3c,(%esp)
c0100b78:	e8 8a 57 00 00       	call   c0106307 <strchr>
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
c0100b99:	c7 04 24 41 6f 10 c0 	movl   $0xc0106f41,(%esp)
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
c0100bdb:	c7 04 24 3c 6f 10 c0 	movl   $0xc0106f3c,(%esp)
c0100be2:	e8 20 57 00 00       	call   c0106307 <strchr>
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
c0100c48:	e8 1d 56 00 00       	call   c010626a <strcmp>
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
c0100c94:	c7 04 24 5f 6f 10 c0 	movl   $0xc0106f5f,(%esp)
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
c0100cb1:	c7 04 24 78 6f 10 c0 	movl   $0xc0106f78,(%esp)
c0100cb8:	e8 d5 f5 ff ff       	call   c0100292 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cbd:	c7 04 24 a0 6f 10 c0 	movl   $0xc0106fa0,(%esp)
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
c0100cda:	c7 04 24 c5 6f 10 c0 	movl   $0xc0106fc5,(%esp)
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
c0100d48:	c7 04 24 c9 6f 10 c0 	movl   $0xc0106fc9,(%esp)
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
c0100dd3:	c7 04 24 d2 6f 10 c0 	movl   $0xc0106fd2,(%esp)
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
c0101215:	e8 e3 52 00 00       	call   c01064fd <memmove>
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
c0101595:	c7 04 24 ed 6f 10 c0 	movl   $0xc0106fed,(%esp)
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
c0101605:	c7 04 24 f9 6f 10 c0 	movl   $0xc0106ff9,(%esp)
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
c01018a2:	c7 04 24 20 70 10 c0 	movl   $0xc0107020,(%esp)
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
c01019b2:	8b 04 85 80 73 10 c0 	mov    -0x3fef8c80(,%eax,4),%eax
c01019b9:	eb 18                	jmp    c01019d3 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01019bb:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01019bf:	7e 0d                	jle    c01019ce <trapname+0x2a>
c01019c1:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01019c5:	7f 07                	jg     c01019ce <trapname+0x2a>
        return "Hardware Interrupt";
c01019c7:	b8 2a 70 10 c0       	mov    $0xc010702a,%eax
c01019cc:	eb 05                	jmp    c01019d3 <trapname+0x2f>
    }
    return "(unknown trap)";
c01019ce:	b8 3d 70 10 c0       	mov    $0xc010703d,%eax
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
c01019f7:	c7 04 24 7e 70 10 c0 	movl   $0xc010707e,(%esp)
c01019fe:	e8 8f e8 ff ff       	call   c0100292 <cprintf>
    print_regs(&tf->tf_regs);
c0101a03:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a06:	89 04 24             	mov    %eax,(%esp)
c0101a09:	e8 8f 01 00 00       	call   c0101b9d <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a11:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a19:	c7 04 24 8f 70 10 c0 	movl   $0xc010708f,(%esp)
c0101a20:	e8 6d e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a28:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a30:	c7 04 24 a2 70 10 c0 	movl   $0xc01070a2,(%esp)
c0101a37:	e8 56 e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a3f:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101a43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a47:	c7 04 24 b5 70 10 c0 	movl   $0xc01070b5,(%esp)
c0101a4e:	e8 3f e8 ff ff       	call   c0100292 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101a53:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a56:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a5e:	c7 04 24 c8 70 10 c0 	movl   $0xc01070c8,(%esp)
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
c0101a88:	c7 04 24 db 70 10 c0 	movl   $0xc01070db,(%esp)
c0101a8f:	e8 fe e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101a94:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a97:	8b 40 34             	mov    0x34(%eax),%eax
c0101a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a9e:	c7 04 24 ed 70 10 c0 	movl   $0xc01070ed,(%esp)
c0101aa5:	e8 e8 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101aaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aad:	8b 40 38             	mov    0x38(%eax),%eax
c0101ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ab4:	c7 04 24 fc 70 10 c0 	movl   $0xc01070fc,(%esp)
c0101abb:	e8 d2 e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101ac0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101acb:	c7 04 24 0b 71 10 c0 	movl   $0xc010710b,(%esp)
c0101ad2:	e8 bb e7 ff ff       	call   c0100292 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ada:	8b 40 40             	mov    0x40(%eax),%eax
c0101add:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae1:	c7 04 24 1e 71 10 c0 	movl   $0xc010711e,(%esp)
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
c0101b28:	c7 04 24 2d 71 10 c0 	movl   $0xc010712d,(%esp)
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
c0101b52:	c7 04 24 31 71 10 c0 	movl   $0xc0107131,(%esp)
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
c0101b77:	c7 04 24 3a 71 10 c0 	movl   $0xc010713a,(%esp)
c0101b7e:	e8 0f e7 ff ff       	call   c0100292 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101b83:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b86:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b8e:	c7 04 24 49 71 10 c0 	movl   $0xc0107149,(%esp)
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
c0101bac:	c7 04 24 5c 71 10 c0 	movl   $0xc010715c,(%esp)
c0101bb3:	e8 da e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101bb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bbb:	8b 40 04             	mov    0x4(%eax),%eax
c0101bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bc2:	c7 04 24 6b 71 10 c0 	movl   $0xc010716b,(%esp)
c0101bc9:	e8 c4 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101bce:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd1:	8b 40 08             	mov    0x8(%eax),%eax
c0101bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bd8:	c7 04 24 7a 71 10 c0 	movl   $0xc010717a,(%esp)
c0101bdf:	e8 ae e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101be4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be7:	8b 40 0c             	mov    0xc(%eax),%eax
c0101bea:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bee:	c7 04 24 89 71 10 c0 	movl   $0xc0107189,(%esp)
c0101bf5:	e8 98 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bfd:	8b 40 10             	mov    0x10(%eax),%eax
c0101c00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c04:	c7 04 24 98 71 10 c0 	movl   $0xc0107198,(%esp)
c0101c0b:	e8 82 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c10:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c13:	8b 40 14             	mov    0x14(%eax),%eax
c0101c16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c1a:	c7 04 24 a7 71 10 c0 	movl   $0xc01071a7,(%esp)
c0101c21:	e8 6c e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c26:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c29:	8b 40 18             	mov    0x18(%eax),%eax
c0101c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c30:	c7 04 24 b6 71 10 c0 	movl   $0xc01071b6,(%esp)
c0101c37:	e8 56 e6 ff ff       	call   c0100292 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101c3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c3f:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101c42:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c46:	c7 04 24 c5 71 10 c0 	movl   $0xc01071c5,(%esp)
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
c0101cf6:	c7 04 24 d4 71 10 c0 	movl   $0xc01071d4,(%esp)
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
c0101d1c:	c7 04 24 e6 71 10 c0 	movl   $0xc01071e6,(%esp)
c0101d23:	e8 6a e5 ff ff       	call   c0100292 <cprintf>
        break;
c0101d28:	eb 55                	jmp    c0101d7f <trap_dispatch+0x12a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101d2a:	c7 44 24 08 f5 71 10 	movl   $0xc01071f5,0x8(%esp)
c0101d31:	c0 
c0101d32:	c7 44 24 04 ab 00 00 	movl   $0xab,0x4(%esp)
c0101d39:	00 
c0101d3a:	c7 04 24 05 72 10 c0 	movl   $0xc0107205,(%esp)
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
c0101d5f:	c7 44 24 08 16 72 10 	movl   $0xc0107216,0x8(%esp)
c0101d66:	c0 
c0101d67:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c0101d6e:	00 
c0101d6f:	c7 04 24 05 72 10 c0 	movl   $0xc0107205,(%esp)
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
c0102870:	c7 44 24 08 d0 73 10 	movl   $0xc01073d0,0x8(%esp)
c0102877:	c0 
c0102878:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c010287f:	00 
c0102880:	c7 04 24 ef 73 10 c0 	movl   $0xc01073ef,(%esp)
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
c01028d6:	c7 44 24 08 00 74 10 	movl   $0xc0107400,0x8(%esp)
c01028dd:	c0 
c01028de:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c01028e5:	00 
c01028e6:	c7 04 24 ef 73 10 c0 	movl   $0xc01073ef,(%esp)
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
c010290c:	c7 44 24 08 24 74 10 	movl   $0xc0107424,0x8(%esp)
c0102913:	c0 
c0102914:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c010291b:	00 
c010291c:	c7 04 24 ef 73 10 c0 	movl   $0xc01073ef,(%esp)
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
    //pmm_manager = &default_pmm_manager;
    pmm_manager = &buddy_system;
c0102afb:	c7 05 10 df 11 c0 94 	movl   $0xc0108094,0xc011df10
c0102b02:	80 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102b05:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102b0a:	8b 00                	mov    (%eax),%eax
c0102b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102b10:	c7 04 24 50 74 10 c0 	movl   $0xc0107450,(%esp)
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
c0102c00:	c7 04 24 67 74 10 c0 	movl   $0xc0107467,(%esp)
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
c0102cd9:	c7 04 24 74 74 10 c0 	movl   $0xc0107474,(%esp)
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
c0102e1e:	c7 44 24 08 a4 74 10 	movl   $0xc01074a4,0x8(%esp)
c0102e25:	c0 
c0102e26:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0102e2d:	00 
c0102e2e:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
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
c0102fe9:	c7 44 24 0c d6 74 10 	movl   $0xc01074d6,0xc(%esp)
c0102ff0:	c0 
c0102ff1:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0102ff8:	c0 
c0102ff9:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0103000:	00 
c0103001:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
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
c0103089:	c7 44 24 0c 02 75 10 	movl   $0xc0107502,0xc(%esp)
c0103090:	c0 
c0103091:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103098:	c0 
c0103099:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c01030a0:	00 
c01030a1:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
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
c01030f2:	c7 44 24 08 0f 75 10 	movl   $0xc010750f,0x8(%esp)
c01030f9:	c0 
c01030fa:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0103101:	00 
c0103102:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
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
c0103139:	c7 44 24 08 a4 74 10 	movl   $0xc01074a4,0x8(%esp)
c0103140:	c0 
c0103141:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0103148:	00 
c0103149:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
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
c010316c:	e8 4f 02 00 00       	call   c01033c0 <check_alloc_page>

    check_pgdir();
c0103171:	e8 69 02 00 00       	call   c01033df <check_pgdir>

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
c010318e:	c7 44 24 08 a4 74 10 	movl   $0xc01074a4,0x8(%esp)
c0103195:	c0 
c0103196:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c010319d:	00 
c010319e:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
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
c01031f4:	e8 82 08 00 00       	call   c0103a7b <check_boot_pgdir>

    print_pgdir();
c01031f9:	e8 fb 0c 00 00       	call   c0103ef9 <print_pgdir>

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
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
c0103263:	90                   	nop
c0103264:	5d                   	pop    %ebp
c0103265:	c3                   	ret    

c0103266 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0103266:	55                   	push   %ebp
c0103267:	89 e5                	mov    %esp,%ebp
c0103269:	83 ec 1c             	sub    $0x1c,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010326c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103273:	00 
c0103274:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103277:	89 44 24 04          	mov    %eax,0x4(%esp)
c010327b:	8b 45 08             	mov    0x8(%ebp),%eax
c010327e:	89 04 24             	mov    %eax,(%esp)
c0103281:	e8 7b ff ff ff       	call   c0103201 <get_pte>
c0103286:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (ptep != NULL) {
c0103289:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010328d:	74 19                	je     c01032a8 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c010328f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103292:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103296:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103299:	89 44 24 04          	mov    %eax,0x4(%esp)
c010329d:	8b 45 08             	mov    0x8(%ebp),%eax
c01032a0:	89 04 24             	mov    %eax,(%esp)
c01032a3:	e8 b8 ff ff ff       	call   c0103260 <page_remove_pte>
    }
}
c01032a8:	90                   	nop
c01032a9:	c9                   	leave  
c01032aa:	c3                   	ret    

c01032ab <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01032ab:	55                   	push   %ebp
c01032ac:	89 e5                	mov    %esp,%ebp
c01032ae:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01032b1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01032b8:	00 
c01032b9:	8b 45 10             	mov    0x10(%ebp),%eax
c01032bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01032c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01032c3:	89 04 24             	mov    %eax,(%esp)
c01032c6:	e8 36 ff ff ff       	call   c0103201 <get_pte>
c01032cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01032ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032d2:	75 0a                	jne    c01032de <page_insert+0x33>
        return -E_NO_MEM;
c01032d4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01032d9:	e9 84 00 00 00       	jmp    c0103362 <page_insert+0xb7>
    }
    page_ref_inc(page);
c01032de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032e1:	89 04 24             	mov    %eax,(%esp)
c01032e4:	e8 73 f6 ff ff       	call   c010295c <page_ref_inc>
    if (*ptep & PTE_P) {
c01032e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032ec:	8b 00                	mov    (%eax),%eax
c01032ee:	83 e0 01             	and    $0x1,%eax
c01032f1:	85 c0                	test   %eax,%eax
c01032f3:	74 3e                	je     c0103333 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01032f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032f8:	8b 00                	mov    (%eax),%eax
c01032fa:	89 04 24             	mov    %eax,(%esp)
c01032fd:	e8 fa f5 ff ff       	call   c01028fc <pte2page>
c0103302:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0103305:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103308:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010330b:	75 0d                	jne    c010331a <page_insert+0x6f>
            page_ref_dec(page);
c010330d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103310:	89 04 24             	mov    %eax,(%esp)
c0103313:	e8 5b f6 ff ff       	call   c0102973 <page_ref_dec>
c0103318:	eb 19                	jmp    c0103333 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010331a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010331d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103321:	8b 45 10             	mov    0x10(%ebp),%eax
c0103324:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103328:	8b 45 08             	mov    0x8(%ebp),%eax
c010332b:	89 04 24             	mov    %eax,(%esp)
c010332e:	e8 2d ff ff ff       	call   c0103260 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0103333:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103336:	89 04 24             	mov    %eax,(%esp)
c0103339:	e8 05 f5 ff ff       	call   c0102843 <page2pa>
c010333e:	0b 45 14             	or     0x14(%ebp),%eax
c0103341:	83 c8 01             	or     $0x1,%eax
c0103344:	89 c2                	mov    %eax,%edx
c0103346:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103349:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010334b:	8b 45 10             	mov    0x10(%ebp),%eax
c010334e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103352:	8b 45 08             	mov    0x8(%ebp),%eax
c0103355:	89 04 24             	mov    %eax,(%esp)
c0103358:	e8 07 00 00 00       	call   c0103364 <tlb_invalidate>
    return 0;
c010335d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103362:	c9                   	leave  
c0103363:	c3                   	ret    

c0103364 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0103364:	55                   	push   %ebp
c0103365:	89 e5                	mov    %esp,%ebp
c0103367:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010336a:	0f 20 d8             	mov    %cr3,%eax
c010336d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0103370:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0103373:	8b 45 08             	mov    0x8(%ebp),%eax
c0103376:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103379:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103380:	77 23                	ja     c01033a5 <tlb_invalidate+0x41>
c0103382:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103385:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103389:	c7 44 24 08 a4 74 10 	movl   $0xc01074a4,0x8(%esp)
c0103390:	c0 
c0103391:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
c0103398:	00 
c0103399:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c01033a0:	e8 44 d0 ff ff       	call   c01003e9 <__panic>
c01033a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033a8:	05 00 00 00 40       	add    $0x40000000,%eax
c01033ad:	39 d0                	cmp    %edx,%eax
c01033af:	75 0c                	jne    c01033bd <tlb_invalidate+0x59>
        invlpg((void *)la);
c01033b1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01033b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01033ba:	0f 01 38             	invlpg (%eax)
    }
}
c01033bd:	90                   	nop
c01033be:	c9                   	leave  
c01033bf:	c3                   	ret    

c01033c0 <check_alloc_page>:

static void
check_alloc_page(void) {
c01033c0:	55                   	push   %ebp
c01033c1:	89 e5                	mov    %esp,%ebp
c01033c3:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01033c6:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c01033cb:	8b 40 18             	mov    0x18(%eax),%eax
c01033ce:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01033d0:	c7 04 24 28 75 10 c0 	movl   $0xc0107528,(%esp)
c01033d7:	e8 b6 ce ff ff       	call   c0100292 <cprintf>
}
c01033dc:	90                   	nop
c01033dd:	c9                   	leave  
c01033de:	c3                   	ret    

c01033df <check_pgdir>:

static void
check_pgdir(void) {
c01033df:	55                   	push   %ebp
c01033e0:	89 e5                	mov    %esp,%ebp
c01033e2:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01033e5:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c01033ea:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01033ef:	76 24                	jbe    c0103415 <check_pgdir+0x36>
c01033f1:	c7 44 24 0c 47 75 10 	movl   $0xc0107547,0xc(%esp)
c01033f8:	c0 
c01033f9:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103400:	c0 
c0103401:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
c0103408:	00 
c0103409:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103410:	e8 d4 cf ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0103415:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010341a:	85 c0                	test   %eax,%eax
c010341c:	74 0e                	je     c010342c <check_pgdir+0x4d>
c010341e:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103423:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103428:	85 c0                	test   %eax,%eax
c010342a:	74 24                	je     c0103450 <check_pgdir+0x71>
c010342c:	c7 44 24 0c 64 75 10 	movl   $0xc0107564,0xc(%esp)
c0103433:	c0 
c0103434:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c010343b:	c0 
c010343c:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
c0103443:	00 
c0103444:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c010344b:	e8 99 cf ff ff       	call   c01003e9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0103450:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103455:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010345c:	00 
c010345d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103464:	00 
c0103465:	89 04 24             	mov    %eax,(%esp)
c0103468:	e8 9a fd ff ff       	call   c0103207 <get_page>
c010346d:	85 c0                	test   %eax,%eax
c010346f:	74 24                	je     c0103495 <check_pgdir+0xb6>
c0103471:	c7 44 24 0c 9c 75 10 	movl   $0xc010759c,0xc(%esp)
c0103478:	c0 
c0103479:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103480:	c0 
c0103481:	c7 44 24 04 d4 01 00 	movl   $0x1d4,0x4(%esp)
c0103488:	00 
c0103489:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103490:	e8 54 cf ff ff       	call   c01003e9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0103495:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010349c:	e8 a8 f6 ff ff       	call   c0102b49 <alloc_pages>
c01034a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01034a4:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01034a9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01034b0:	00 
c01034b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01034b8:	00 
c01034b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01034bc:	89 54 24 04          	mov    %edx,0x4(%esp)
c01034c0:	89 04 24             	mov    %eax,(%esp)
c01034c3:	e8 e3 fd ff ff       	call   c01032ab <page_insert>
c01034c8:	85 c0                	test   %eax,%eax
c01034ca:	74 24                	je     c01034f0 <check_pgdir+0x111>
c01034cc:	c7 44 24 0c c4 75 10 	movl   $0xc01075c4,0xc(%esp)
c01034d3:	c0 
c01034d4:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c01034db:	c0 
c01034dc:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
c01034e3:	00 
c01034e4:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c01034eb:	e8 f9 ce ff ff       	call   c01003e9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01034f0:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01034f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01034fc:	00 
c01034fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103504:	00 
c0103505:	89 04 24             	mov    %eax,(%esp)
c0103508:	e8 f4 fc ff ff       	call   c0103201 <get_pte>
c010350d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103510:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103514:	75 24                	jne    c010353a <check_pgdir+0x15b>
c0103516:	c7 44 24 0c f0 75 10 	movl   $0xc01075f0,0xc(%esp)
c010351d:	c0 
c010351e:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103525:	c0 
c0103526:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c010352d:	00 
c010352e:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103535:	e8 af ce ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c010353a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010353d:	8b 00                	mov    (%eax),%eax
c010353f:	89 04 24             	mov    %eax,(%esp)
c0103542:	e8 b5 f3 ff ff       	call   c01028fc <pte2page>
c0103547:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010354a:	74 24                	je     c0103570 <check_pgdir+0x191>
c010354c:	c7 44 24 0c 1d 76 10 	movl   $0xc010761d,0xc(%esp)
c0103553:	c0 
c0103554:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c010355b:	c0 
c010355c:	c7 44 24 04 dc 01 00 	movl   $0x1dc,0x4(%esp)
c0103563:	00 
c0103564:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c010356b:	e8 79 ce ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 1);
c0103570:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103573:	89 04 24             	mov    %eax,(%esp)
c0103576:	e8 d7 f3 ff ff       	call   c0102952 <page_ref>
c010357b:	83 f8 01             	cmp    $0x1,%eax
c010357e:	74 24                	je     c01035a4 <check_pgdir+0x1c5>
c0103580:	c7 44 24 0c 33 76 10 	movl   $0xc0107633,0xc(%esp)
c0103587:	c0 
c0103588:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c010358f:	c0 
c0103590:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
c0103597:	00 
c0103598:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c010359f:	e8 45 ce ff ff       	call   c01003e9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01035a4:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01035a9:	8b 00                	mov    (%eax),%eax
c01035ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01035b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01035b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01035b6:	c1 e8 0c             	shr    $0xc,%eax
c01035b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01035bc:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c01035c1:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01035c4:	72 23                	jb     c01035e9 <check_pgdir+0x20a>
c01035c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01035c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01035cd:	c7 44 24 08 00 74 10 	movl   $0xc0107400,0x8(%esp)
c01035d4:	c0 
c01035d5:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
c01035dc:	00 
c01035dd:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c01035e4:	e8 00 ce ff ff       	call   c01003e9 <__panic>
c01035e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01035ec:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01035f1:	83 c0 04             	add    $0x4,%eax
c01035f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01035f7:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01035fc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103603:	00 
c0103604:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010360b:	00 
c010360c:	89 04 24             	mov    %eax,(%esp)
c010360f:	e8 ed fb ff ff       	call   c0103201 <get_pte>
c0103614:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103617:	74 24                	je     c010363d <check_pgdir+0x25e>
c0103619:	c7 44 24 0c 48 76 10 	movl   $0xc0107648,0xc(%esp)
c0103620:	c0 
c0103621:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103628:	c0 
c0103629:	c7 44 24 04 e0 01 00 	movl   $0x1e0,0x4(%esp)
c0103630:	00 
c0103631:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103638:	e8 ac cd ff ff       	call   c01003e9 <__panic>

    p2 = alloc_page();
c010363d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103644:	e8 00 f5 ff ff       	call   c0102b49 <alloc_pages>
c0103649:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010364c:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103651:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0103658:	00 
c0103659:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103660:	00 
c0103661:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103664:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103668:	89 04 24             	mov    %eax,(%esp)
c010366b:	e8 3b fc ff ff       	call   c01032ab <page_insert>
c0103670:	85 c0                	test   %eax,%eax
c0103672:	74 24                	je     c0103698 <check_pgdir+0x2b9>
c0103674:	c7 44 24 0c 70 76 10 	movl   $0xc0107670,0xc(%esp)
c010367b:	c0 
c010367c:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103683:	c0 
c0103684:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c010368b:	00 
c010368c:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103693:	e8 51 cd ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103698:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010369d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01036a4:	00 
c01036a5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01036ac:	00 
c01036ad:	89 04 24             	mov    %eax,(%esp)
c01036b0:	e8 4c fb ff ff       	call   c0103201 <get_pte>
c01036b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01036b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01036bc:	75 24                	jne    c01036e2 <check_pgdir+0x303>
c01036be:	c7 44 24 0c a8 76 10 	movl   $0xc01076a8,0xc(%esp)
c01036c5:	c0 
c01036c6:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c01036cd:	c0 
c01036ce:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c01036d5:	00 
c01036d6:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c01036dd:	e8 07 cd ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_U);
c01036e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036e5:	8b 00                	mov    (%eax),%eax
c01036e7:	83 e0 04             	and    $0x4,%eax
c01036ea:	85 c0                	test   %eax,%eax
c01036ec:	75 24                	jne    c0103712 <check_pgdir+0x333>
c01036ee:	c7 44 24 0c d8 76 10 	movl   $0xc01076d8,0xc(%esp)
c01036f5:	c0 
c01036f6:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c01036fd:	c0 
c01036fe:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c0103705:	00 
c0103706:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c010370d:	e8 d7 cc ff ff       	call   c01003e9 <__panic>
    assert(*ptep & PTE_W);
c0103712:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103715:	8b 00                	mov    (%eax),%eax
c0103717:	83 e0 02             	and    $0x2,%eax
c010371a:	85 c0                	test   %eax,%eax
c010371c:	75 24                	jne    c0103742 <check_pgdir+0x363>
c010371e:	c7 44 24 0c e6 76 10 	movl   $0xc01076e6,0xc(%esp)
c0103725:	c0 
c0103726:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c010372d:	c0 
c010372e:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c0103735:	00 
c0103736:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c010373d:	e8 a7 cc ff ff       	call   c01003e9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103742:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103747:	8b 00                	mov    (%eax),%eax
c0103749:	83 e0 04             	and    $0x4,%eax
c010374c:	85 c0                	test   %eax,%eax
c010374e:	75 24                	jne    c0103774 <check_pgdir+0x395>
c0103750:	c7 44 24 0c f4 76 10 	movl   $0xc01076f4,0xc(%esp)
c0103757:	c0 
c0103758:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c010375f:	c0 
c0103760:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c0103767:	00 
c0103768:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c010376f:	e8 75 cc ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 1);
c0103774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103777:	89 04 24             	mov    %eax,(%esp)
c010377a:	e8 d3 f1 ff ff       	call   c0102952 <page_ref>
c010377f:	83 f8 01             	cmp    $0x1,%eax
c0103782:	74 24                	je     c01037a8 <check_pgdir+0x3c9>
c0103784:	c7 44 24 0c 0a 77 10 	movl   $0xc010770a,0xc(%esp)
c010378b:	c0 
c010378c:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103793:	c0 
c0103794:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c010379b:	00 
c010379c:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c01037a3:	e8 41 cc ff ff       	call   c01003e9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01037a8:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01037ad:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01037b4:	00 
c01037b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01037bc:	00 
c01037bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01037c0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01037c4:	89 04 24             	mov    %eax,(%esp)
c01037c7:	e8 df fa ff ff       	call   c01032ab <page_insert>
c01037cc:	85 c0                	test   %eax,%eax
c01037ce:	74 24                	je     c01037f4 <check_pgdir+0x415>
c01037d0:	c7 44 24 0c 1c 77 10 	movl   $0xc010771c,0xc(%esp)
c01037d7:	c0 
c01037d8:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c01037df:	c0 
c01037e0:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c01037e7:	00 
c01037e8:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c01037ef:	e8 f5 cb ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p1) == 2);
c01037f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037f7:	89 04 24             	mov    %eax,(%esp)
c01037fa:	e8 53 f1 ff ff       	call   c0102952 <page_ref>
c01037ff:	83 f8 02             	cmp    $0x2,%eax
c0103802:	74 24                	je     c0103828 <check_pgdir+0x449>
c0103804:	c7 44 24 0c 48 77 10 	movl   $0xc0107748,0xc(%esp)
c010380b:	c0 
c010380c:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103813:	c0 
c0103814:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c010381b:	00 
c010381c:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103823:	e8 c1 cb ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103828:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010382b:	89 04 24             	mov    %eax,(%esp)
c010382e:	e8 1f f1 ff ff       	call   c0102952 <page_ref>
c0103833:	85 c0                	test   %eax,%eax
c0103835:	74 24                	je     c010385b <check_pgdir+0x47c>
c0103837:	c7 44 24 0c 5a 77 10 	movl   $0xc010775a,0xc(%esp)
c010383e:	c0 
c010383f:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103846:	c0 
c0103847:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c010384e:	00 
c010384f:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103856:	e8 8e cb ff ff       	call   c01003e9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010385b:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103860:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103867:	00 
c0103868:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010386f:	00 
c0103870:	89 04 24             	mov    %eax,(%esp)
c0103873:	e8 89 f9 ff ff       	call   c0103201 <get_pte>
c0103878:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010387b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010387f:	75 24                	jne    c01038a5 <check_pgdir+0x4c6>
c0103881:	c7 44 24 0c a8 76 10 	movl   $0xc01076a8,0xc(%esp)
c0103888:	c0 
c0103889:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103890:	c0 
c0103891:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0103898:	00 
c0103899:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c01038a0:	e8 44 cb ff ff       	call   c01003e9 <__panic>
    assert(pte2page(*ptep) == p1);
c01038a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038a8:	8b 00                	mov    (%eax),%eax
c01038aa:	89 04 24             	mov    %eax,(%esp)
c01038ad:	e8 4a f0 ff ff       	call   c01028fc <pte2page>
c01038b2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01038b5:	74 24                	je     c01038db <check_pgdir+0x4fc>
c01038b7:	c7 44 24 0c 1d 76 10 	movl   $0xc010761d,0xc(%esp)
c01038be:	c0 
c01038bf:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c01038c6:	c0 
c01038c7:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c01038ce:	00 
c01038cf:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c01038d6:	e8 0e cb ff ff       	call   c01003e9 <__panic>
    assert((*ptep & PTE_U) == 0);
c01038db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038de:	8b 00                	mov    (%eax),%eax
c01038e0:	83 e0 04             	and    $0x4,%eax
c01038e3:	85 c0                	test   %eax,%eax
c01038e5:	74 24                	je     c010390b <check_pgdir+0x52c>
c01038e7:	c7 44 24 0c 6c 77 10 	movl   $0xc010776c,0xc(%esp)
c01038ee:	c0 
c01038ef:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c01038f6:	c0 
c01038f7:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c01038fe:	00 
c01038ff:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103906:	e8 de ca ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, 0x0);
c010390b:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103910:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103917:	00 
c0103918:	89 04 24             	mov    %eax,(%esp)
c010391b:	e8 46 f9 ff ff       	call   c0103266 <page_remove>
    assert(page_ref(p1) == 1);
c0103920:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103923:	89 04 24             	mov    %eax,(%esp)
c0103926:	e8 27 f0 ff ff       	call   c0102952 <page_ref>
c010392b:	83 f8 01             	cmp    $0x1,%eax
c010392e:	74 24                	je     c0103954 <check_pgdir+0x575>
c0103930:	c7 44 24 0c 33 76 10 	movl   $0xc0107633,0xc(%esp)
c0103937:	c0 
c0103938:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c010393f:	c0 
c0103940:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c0103947:	00 
c0103948:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c010394f:	e8 95 ca ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c0103954:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103957:	89 04 24             	mov    %eax,(%esp)
c010395a:	e8 f3 ef ff ff       	call   c0102952 <page_ref>
c010395f:	85 c0                	test   %eax,%eax
c0103961:	74 24                	je     c0103987 <check_pgdir+0x5a8>
c0103963:	c7 44 24 0c 5a 77 10 	movl   $0xc010775a,0xc(%esp)
c010396a:	c0 
c010396b:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103972:	c0 
c0103973:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c010397a:	00 
c010397b:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103982:	e8 62 ca ff ff       	call   c01003e9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103987:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010398c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103993:	00 
c0103994:	89 04 24             	mov    %eax,(%esp)
c0103997:	e8 ca f8 ff ff       	call   c0103266 <page_remove>
    assert(page_ref(p1) == 0);
c010399c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010399f:	89 04 24             	mov    %eax,(%esp)
c01039a2:	e8 ab ef ff ff       	call   c0102952 <page_ref>
c01039a7:	85 c0                	test   %eax,%eax
c01039a9:	74 24                	je     c01039cf <check_pgdir+0x5f0>
c01039ab:	c7 44 24 0c 81 77 10 	movl   $0xc0107781,0xc(%esp)
c01039b2:	c0 
c01039b3:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c01039ba:	c0 
c01039bb:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c01039c2:	00 
c01039c3:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c01039ca:	e8 1a ca ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p2) == 0);
c01039cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039d2:	89 04 24             	mov    %eax,(%esp)
c01039d5:	e8 78 ef ff ff       	call   c0102952 <page_ref>
c01039da:	85 c0                	test   %eax,%eax
c01039dc:	74 24                	je     c0103a02 <check_pgdir+0x623>
c01039de:	c7 44 24 0c 5a 77 10 	movl   $0xc010775a,0xc(%esp)
c01039e5:	c0 
c01039e6:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c01039ed:	c0 
c01039ee:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c01039f5:	00 
c01039f6:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c01039fd:	e8 e7 c9 ff ff       	call   c01003e9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103a02:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103a07:	8b 00                	mov    (%eax),%eax
c0103a09:	89 04 24             	mov    %eax,(%esp)
c0103a0c:	e8 29 ef ff ff       	call   c010293a <pde2page>
c0103a11:	89 04 24             	mov    %eax,(%esp)
c0103a14:	e8 39 ef ff ff       	call   c0102952 <page_ref>
c0103a19:	83 f8 01             	cmp    $0x1,%eax
c0103a1c:	74 24                	je     c0103a42 <check_pgdir+0x663>
c0103a1e:	c7 44 24 0c 94 77 10 	movl   $0xc0107794,0xc(%esp)
c0103a25:	c0 
c0103a26:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103a2d:	c0 
c0103a2e:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0103a35:	00 
c0103a36:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103a3d:	e8 a7 c9 ff ff       	call   c01003e9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103a42:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103a47:	8b 00                	mov    (%eax),%eax
c0103a49:	89 04 24             	mov    %eax,(%esp)
c0103a4c:	e8 e9 ee ff ff       	call   c010293a <pde2page>
c0103a51:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103a58:	00 
c0103a59:	89 04 24             	mov    %eax,(%esp)
c0103a5c:	e8 20 f1 ff ff       	call   c0102b81 <free_pages>
    boot_pgdir[0] = 0;
c0103a61:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103a66:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103a6c:	c7 04 24 bb 77 10 c0 	movl   $0xc01077bb,(%esp)
c0103a73:	e8 1a c8 ff ff       	call   c0100292 <cprintf>
}
c0103a78:	90                   	nop
c0103a79:	c9                   	leave  
c0103a7a:	c3                   	ret    

c0103a7b <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103a7b:	55                   	push   %ebp
c0103a7c:	89 e5                	mov    %esp,%ebp
c0103a7e:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103a81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103a88:	e9 ca 00 00 00       	jmp    c0103b57 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103a93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a96:	c1 e8 0c             	shr    $0xc,%eax
c0103a99:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103a9c:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103aa1:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103aa4:	72 23                	jb     c0103ac9 <check_boot_pgdir+0x4e>
c0103aa6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103aa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103aad:	c7 44 24 08 00 74 10 	movl   $0xc0107400,0x8(%esp)
c0103ab4:	c0 
c0103ab5:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0103abc:	00 
c0103abd:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103ac4:	e8 20 c9 ff ff       	call   c01003e9 <__panic>
c0103ac9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103acc:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103ad1:	89 c2                	mov    %eax,%edx
c0103ad3:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103ad8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103adf:	00 
c0103ae0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103ae4:	89 04 24             	mov    %eax,(%esp)
c0103ae7:	e8 15 f7 ff ff       	call   c0103201 <get_pte>
c0103aec:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103aef:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103af3:	75 24                	jne    c0103b19 <check_boot_pgdir+0x9e>
c0103af5:	c7 44 24 0c d8 77 10 	movl   $0xc01077d8,0xc(%esp)
c0103afc:	c0 
c0103afd:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103b04:	c0 
c0103b05:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0103b0c:	00 
c0103b0d:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103b14:	e8 d0 c8 ff ff       	call   c01003e9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103b19:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b1c:	8b 00                	mov    (%eax),%eax
c0103b1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b23:	89 c2                	mov    %eax,%edx
c0103b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b28:	39 c2                	cmp    %eax,%edx
c0103b2a:	74 24                	je     c0103b50 <check_boot_pgdir+0xd5>
c0103b2c:	c7 44 24 0c 15 78 10 	movl   $0xc0107815,0xc(%esp)
c0103b33:	c0 
c0103b34:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103b3b:	c0 
c0103b3c:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c0103b43:	00 
c0103b44:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103b4b:	e8 99 c8 ff ff       	call   c01003e9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0103b50:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103b57:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103b5a:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103b5f:	39 c2                	cmp    %eax,%edx
c0103b61:	0f 82 26 ff ff ff    	jb     c0103a8d <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103b67:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103b6c:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103b71:	8b 00                	mov    (%eax),%eax
c0103b73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b78:	89 c2                	mov    %eax,%edx
c0103b7a:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103b7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b82:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103b89:	77 23                	ja     c0103bae <check_boot_pgdir+0x133>
c0103b8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b92:	c7 44 24 08 a4 74 10 	movl   $0xc01074a4,0x8(%esp)
c0103b99:	c0 
c0103b9a:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0103ba1:	00 
c0103ba2:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103ba9:	e8 3b c8 ff ff       	call   c01003e9 <__panic>
c0103bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bb1:	05 00 00 00 40       	add    $0x40000000,%eax
c0103bb6:	39 d0                	cmp    %edx,%eax
c0103bb8:	74 24                	je     c0103bde <check_boot_pgdir+0x163>
c0103bba:	c7 44 24 0c 2c 78 10 	movl   $0xc010782c,0xc(%esp)
c0103bc1:	c0 
c0103bc2:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103bc9:	c0 
c0103bca:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0103bd1:	00 
c0103bd2:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103bd9:	e8 0b c8 ff ff       	call   c01003e9 <__panic>

    assert(boot_pgdir[0] == 0);
c0103bde:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103be3:	8b 00                	mov    (%eax),%eax
c0103be5:	85 c0                	test   %eax,%eax
c0103be7:	74 24                	je     c0103c0d <check_boot_pgdir+0x192>
c0103be9:	c7 44 24 0c 60 78 10 	movl   $0xc0107860,0xc(%esp)
c0103bf0:	c0 
c0103bf1:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103bf8:	c0 
c0103bf9:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0103c00:	00 
c0103c01:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103c08:	e8 dc c7 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    p = alloc_page();
c0103c0d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c14:	e8 30 ef ff ff       	call   c0102b49 <alloc_pages>
c0103c19:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103c1c:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103c21:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103c28:	00 
c0103c29:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103c30:	00 
c0103c31:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103c34:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103c38:	89 04 24             	mov    %eax,(%esp)
c0103c3b:	e8 6b f6 ff ff       	call   c01032ab <page_insert>
c0103c40:	85 c0                	test   %eax,%eax
c0103c42:	74 24                	je     c0103c68 <check_boot_pgdir+0x1ed>
c0103c44:	c7 44 24 0c 74 78 10 	movl   $0xc0107874,0xc(%esp)
c0103c4b:	c0 
c0103c4c:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103c53:	c0 
c0103c54:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0103c5b:	00 
c0103c5c:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103c63:	e8 81 c7 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 1);
c0103c68:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c6b:	89 04 24             	mov    %eax,(%esp)
c0103c6e:	e8 df ec ff ff       	call   c0102952 <page_ref>
c0103c73:	83 f8 01             	cmp    $0x1,%eax
c0103c76:	74 24                	je     c0103c9c <check_boot_pgdir+0x221>
c0103c78:	c7 44 24 0c a2 78 10 	movl   $0xc01078a2,0xc(%esp)
c0103c7f:	c0 
c0103c80:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103c87:	c0 
c0103c88:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0103c8f:	00 
c0103c90:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103c97:	e8 4d c7 ff ff       	call   c01003e9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0103c9c:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103ca1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103ca8:	00 
c0103ca9:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0103cb0:	00 
c0103cb1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103cb4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103cb8:	89 04 24             	mov    %eax,(%esp)
c0103cbb:	e8 eb f5 ff ff       	call   c01032ab <page_insert>
c0103cc0:	85 c0                	test   %eax,%eax
c0103cc2:	74 24                	je     c0103ce8 <check_boot_pgdir+0x26d>
c0103cc4:	c7 44 24 0c b4 78 10 	movl   $0xc01078b4,0xc(%esp)
c0103ccb:	c0 
c0103ccc:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103cd3:	c0 
c0103cd4:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0103cdb:	00 
c0103cdc:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103ce3:	e8 01 c7 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p) == 2);
c0103ce8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ceb:	89 04 24             	mov    %eax,(%esp)
c0103cee:	e8 5f ec ff ff       	call   c0102952 <page_ref>
c0103cf3:	83 f8 02             	cmp    $0x2,%eax
c0103cf6:	74 24                	je     c0103d1c <check_boot_pgdir+0x2a1>
c0103cf8:	c7 44 24 0c eb 78 10 	movl   $0xc01078eb,0xc(%esp)
c0103cff:	c0 
c0103d00:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103d07:	c0 
c0103d08:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0103d0f:	00 
c0103d10:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103d17:	e8 cd c6 ff ff       	call   c01003e9 <__panic>

    const char *str = "ucore: Hello world!!";
c0103d1c:	c7 45 e8 fc 78 10 c0 	movl   $0xc01078fc,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0103d23:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d26:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d2a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103d31:	e8 bd 24 00 00       	call   c01061f3 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0103d36:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0103d3d:	00 
c0103d3e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103d45:	e8 20 25 00 00       	call   c010626a <strcmp>
c0103d4a:	85 c0                	test   %eax,%eax
c0103d4c:	74 24                	je     c0103d72 <check_boot_pgdir+0x2f7>
c0103d4e:	c7 44 24 0c 14 79 10 	movl   $0xc0107914,0xc(%esp)
c0103d55:	c0 
c0103d56:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103d5d:	c0 
c0103d5e:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0103d65:	00 
c0103d66:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103d6d:	e8 77 c6 ff ff       	call   c01003e9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0103d72:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d75:	89 04 24             	mov    %eax,(%esp)
c0103d78:	e8 2b eb ff ff       	call   c01028a8 <page2kva>
c0103d7d:	05 00 01 00 00       	add    $0x100,%eax
c0103d82:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0103d85:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103d8c:	e8 0c 24 00 00       	call   c010619d <strlen>
c0103d91:	85 c0                	test   %eax,%eax
c0103d93:	74 24                	je     c0103db9 <check_boot_pgdir+0x33e>
c0103d95:	c7 44 24 0c 4c 79 10 	movl   $0xc010794c,0xc(%esp)
c0103d9c:	c0 
c0103d9d:	c7 44 24 08 ed 74 10 	movl   $0xc01074ed,0x8(%esp)
c0103da4:	c0 
c0103da5:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0103dac:	00 
c0103dad:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c0103db4:	e8 30 c6 ff ff       	call   c01003e9 <__panic>

    free_page(p);
c0103db9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103dc0:	00 
c0103dc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103dc4:	89 04 24             	mov    %eax,(%esp)
c0103dc7:	e8 b5 ed ff ff       	call   c0102b81 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0103dcc:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103dd1:	8b 00                	mov    (%eax),%eax
c0103dd3:	89 04 24             	mov    %eax,(%esp)
c0103dd6:	e8 5f eb ff ff       	call   c010293a <pde2page>
c0103ddb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103de2:	00 
c0103de3:	89 04 24             	mov    %eax,(%esp)
c0103de6:	e8 96 ed ff ff       	call   c0102b81 <free_pages>
    boot_pgdir[0] = 0;
c0103deb:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103df0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0103df6:	c7 04 24 70 79 10 c0 	movl   $0xc0107970,(%esp)
c0103dfd:	e8 90 c4 ff ff       	call   c0100292 <cprintf>
}
c0103e02:	90                   	nop
c0103e03:	c9                   	leave  
c0103e04:	c3                   	ret    

c0103e05 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0103e05:	55                   	push   %ebp
c0103e06:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0103e08:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e0b:	83 e0 04             	and    $0x4,%eax
c0103e0e:	85 c0                	test   %eax,%eax
c0103e10:	74 04                	je     c0103e16 <perm2str+0x11>
c0103e12:	b0 75                	mov    $0x75,%al
c0103e14:	eb 02                	jmp    c0103e18 <perm2str+0x13>
c0103e16:	b0 2d                	mov    $0x2d,%al
c0103e18:	a2 08 df 11 c0       	mov    %al,0xc011df08
    str[1] = 'r';
c0103e1d:	c6 05 09 df 11 c0 72 	movb   $0x72,0xc011df09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0103e24:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e27:	83 e0 02             	and    $0x2,%eax
c0103e2a:	85 c0                	test   %eax,%eax
c0103e2c:	74 04                	je     c0103e32 <perm2str+0x2d>
c0103e2e:	b0 77                	mov    $0x77,%al
c0103e30:	eb 02                	jmp    c0103e34 <perm2str+0x2f>
c0103e32:	b0 2d                	mov    $0x2d,%al
c0103e34:	a2 0a df 11 c0       	mov    %al,0xc011df0a
    str[3] = '\0';
c0103e39:	c6 05 0b df 11 c0 00 	movb   $0x0,0xc011df0b
    return str;
c0103e40:	b8 08 df 11 c0       	mov    $0xc011df08,%eax
}
c0103e45:	5d                   	pop    %ebp
c0103e46:	c3                   	ret    

c0103e47 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0103e47:	55                   	push   %ebp
c0103e48:	89 e5                	mov    %esp,%ebp
c0103e4a:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0103e4d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e50:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103e53:	72 0d                	jb     c0103e62 <get_pgtable_items+0x1b>
        return 0;
c0103e55:	b8 00 00 00 00       	mov    $0x0,%eax
c0103e5a:	e9 98 00 00 00       	jmp    c0103ef7 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0103e5f:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0103e62:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e65:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103e68:	73 18                	jae    c0103e82 <get_pgtable_items+0x3b>
c0103e6a:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e6d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103e74:	8b 45 14             	mov    0x14(%ebp),%eax
c0103e77:	01 d0                	add    %edx,%eax
c0103e79:	8b 00                	mov    (%eax),%eax
c0103e7b:	83 e0 01             	and    $0x1,%eax
c0103e7e:	85 c0                	test   %eax,%eax
c0103e80:	74 dd                	je     c0103e5f <get_pgtable_items+0x18>
    }
    if (start < right) {
c0103e82:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e85:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103e88:	73 68                	jae    c0103ef2 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0103e8a:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0103e8e:	74 08                	je     c0103e98 <get_pgtable_items+0x51>
            *left_store = start;
c0103e90:	8b 45 18             	mov    0x18(%ebp),%eax
c0103e93:	8b 55 10             	mov    0x10(%ebp),%edx
c0103e96:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0103e98:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e9b:	8d 50 01             	lea    0x1(%eax),%edx
c0103e9e:	89 55 10             	mov    %edx,0x10(%ebp)
c0103ea1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103ea8:	8b 45 14             	mov    0x14(%ebp),%eax
c0103eab:	01 d0                	add    %edx,%eax
c0103ead:	8b 00                	mov    (%eax),%eax
c0103eaf:	83 e0 07             	and    $0x7,%eax
c0103eb2:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0103eb5:	eb 03                	jmp    c0103eba <get_pgtable_items+0x73>
            start ++;
c0103eb7:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0103eba:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ebd:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103ec0:	73 1d                	jae    c0103edf <get_pgtable_items+0x98>
c0103ec2:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103ecc:	8b 45 14             	mov    0x14(%ebp),%eax
c0103ecf:	01 d0                	add    %edx,%eax
c0103ed1:	8b 00                	mov    (%eax),%eax
c0103ed3:	83 e0 07             	and    $0x7,%eax
c0103ed6:	89 c2                	mov    %eax,%edx
c0103ed8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103edb:	39 c2                	cmp    %eax,%edx
c0103edd:	74 d8                	je     c0103eb7 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0103edf:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0103ee3:	74 08                	je     c0103eed <get_pgtable_items+0xa6>
            *right_store = start;
c0103ee5:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0103ee8:	8b 55 10             	mov    0x10(%ebp),%edx
c0103eeb:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0103eed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103ef0:	eb 05                	jmp    c0103ef7 <get_pgtable_items+0xb0>
    }
    return 0;
c0103ef2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103ef7:	c9                   	leave  
c0103ef8:	c3                   	ret    

c0103ef9 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0103ef9:	55                   	push   %ebp
c0103efa:	89 e5                	mov    %esp,%ebp
c0103efc:	57                   	push   %edi
c0103efd:	56                   	push   %esi
c0103efe:	53                   	push   %ebx
c0103eff:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0103f02:	c7 04 24 90 79 10 c0 	movl   $0xc0107990,(%esp)
c0103f09:	e8 84 c3 ff ff       	call   c0100292 <cprintf>
    size_t left, right = 0, perm;
c0103f0e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0103f15:	e9 fa 00 00 00       	jmp    c0104014 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0103f1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f1d:	89 04 24             	mov    %eax,(%esp)
c0103f20:	e8 e0 fe ff ff       	call   c0103e05 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0103f25:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0103f28:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103f2b:	29 d1                	sub    %edx,%ecx
c0103f2d:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0103f2f:	89 d6                	mov    %edx,%esi
c0103f31:	c1 e6 16             	shl    $0x16,%esi
c0103f34:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f37:	89 d3                	mov    %edx,%ebx
c0103f39:	c1 e3 16             	shl    $0x16,%ebx
c0103f3c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103f3f:	89 d1                	mov    %edx,%ecx
c0103f41:	c1 e1 16             	shl    $0x16,%ecx
c0103f44:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0103f47:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103f4a:	29 d7                	sub    %edx,%edi
c0103f4c:	89 fa                	mov    %edi,%edx
c0103f4e:	89 44 24 14          	mov    %eax,0x14(%esp)
c0103f52:	89 74 24 10          	mov    %esi,0x10(%esp)
c0103f56:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0103f5a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103f5e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103f62:	c7 04 24 c1 79 10 c0 	movl   $0xc01079c1,(%esp)
c0103f69:	e8 24 c3 ff ff       	call   c0100292 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0103f6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f71:	c1 e0 0a             	shl    $0xa,%eax
c0103f74:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0103f77:	eb 54                	jmp    c0103fcd <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0103f79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f7c:	89 04 24             	mov    %eax,(%esp)
c0103f7f:	e8 81 fe ff ff       	call   c0103e05 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0103f84:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0103f87:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103f8a:	29 d1                	sub    %edx,%ecx
c0103f8c:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0103f8e:	89 d6                	mov    %edx,%esi
c0103f90:	c1 e6 0c             	shl    $0xc,%esi
c0103f93:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103f96:	89 d3                	mov    %edx,%ebx
c0103f98:	c1 e3 0c             	shl    $0xc,%ebx
c0103f9b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103f9e:	89 d1                	mov    %edx,%ecx
c0103fa0:	c1 e1 0c             	shl    $0xc,%ecx
c0103fa3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0103fa6:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103fa9:	29 d7                	sub    %edx,%edi
c0103fab:	89 fa                	mov    %edi,%edx
c0103fad:	89 44 24 14          	mov    %eax,0x14(%esp)
c0103fb1:	89 74 24 10          	mov    %esi,0x10(%esp)
c0103fb5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0103fb9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103fbd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103fc1:	c7 04 24 e0 79 10 c0 	movl   $0xc01079e0,(%esp)
c0103fc8:	e8 c5 c2 ff ff       	call   c0100292 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0103fcd:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0103fd2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103fd5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103fd8:	89 d3                	mov    %edx,%ebx
c0103fda:	c1 e3 0a             	shl    $0xa,%ebx
c0103fdd:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103fe0:	89 d1                	mov    %edx,%ecx
c0103fe2:	c1 e1 0a             	shl    $0xa,%ecx
c0103fe5:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0103fe8:	89 54 24 14          	mov    %edx,0x14(%esp)
c0103fec:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0103fef:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103ff3:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0103ff7:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103ffb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0103fff:	89 0c 24             	mov    %ecx,(%esp)
c0104002:	e8 40 fe ff ff       	call   c0103e47 <get_pgtable_items>
c0104007:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010400a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010400e:	0f 85 65 ff ff ff    	jne    c0103f79 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104014:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0104019:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010401c:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010401f:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104023:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0104026:	89 54 24 10          	mov    %edx,0x10(%esp)
c010402a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010402e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104032:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0104039:	00 
c010403a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0104041:	e8 01 fe ff ff       	call   c0103e47 <get_pgtable_items>
c0104046:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104049:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010404d:	0f 85 c7 fe ff ff    	jne    c0103f1a <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0104053:	c7 04 24 04 7a 10 c0 	movl   $0xc0107a04,(%esp)
c010405a:	e8 33 c2 ff ff       	call   c0100292 <cprintf>
}
c010405f:	90                   	nop
c0104060:	83 c4 4c             	add    $0x4c,%esp
c0104063:	5b                   	pop    %ebx
c0104064:	5e                   	pop    %esi
c0104065:	5f                   	pop    %edi
c0104066:	5d                   	pop    %ebp
c0104067:	c3                   	ret    

c0104068 <page2ppn>:
page2ppn(struct Page *page) {
c0104068:	55                   	push   %ebp
c0104069:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010406b:	8b 45 08             	mov    0x8(%ebp),%eax
c010406e:	8b 15 18 df 11 c0    	mov    0xc011df18,%edx
c0104074:	29 d0                	sub    %edx,%eax
c0104076:	c1 f8 02             	sar    $0x2,%eax
c0104079:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010407f:	5d                   	pop    %ebp
c0104080:	c3                   	ret    

c0104081 <page2pa>:
page2pa(struct Page *page) {
c0104081:	55                   	push   %ebp
c0104082:	89 e5                	mov    %esp,%ebp
c0104084:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104087:	8b 45 08             	mov    0x8(%ebp),%eax
c010408a:	89 04 24             	mov    %eax,(%esp)
c010408d:	e8 d6 ff ff ff       	call   c0104068 <page2ppn>
c0104092:	c1 e0 0c             	shl    $0xc,%eax
}
c0104095:	c9                   	leave  
c0104096:	c3                   	ret    

c0104097 <page_ref>:
page_ref(struct Page *page) {
c0104097:	55                   	push   %ebp
c0104098:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010409a:	8b 45 08             	mov    0x8(%ebp),%eax
c010409d:	8b 00                	mov    (%eax),%eax
}
c010409f:	5d                   	pop    %ebp
c01040a0:	c3                   	ret    

c01040a1 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c01040a1:	55                   	push   %ebp
c01040a2:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01040a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01040a7:	8b 55 0c             	mov    0xc(%ebp),%edx
c01040aa:	89 10                	mov    %edx,(%eax)
}
c01040ac:	90                   	nop
c01040ad:	5d                   	pop    %ebp
c01040ae:	c3                   	ret    

c01040af <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01040af:	55                   	push   %ebp
c01040b0:	89 e5                	mov    %esp,%ebp
c01040b2:	83 ec 10             	sub    $0x10,%esp
c01040b5:	c7 45 fc 20 df 11 c0 	movl   $0xc011df20,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01040bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01040bf:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01040c2:	89 50 04             	mov    %edx,0x4(%eax)
c01040c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01040c8:	8b 50 04             	mov    0x4(%eax),%edx
c01040cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01040ce:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01040d0:	c7 05 28 df 11 c0 00 	movl   $0x0,0xc011df28
c01040d7:	00 00 00 
}
c01040da:	90                   	nop
c01040db:	c9                   	leave  
c01040dc:	c3                   	ret    

c01040dd <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01040dd:	55                   	push   %ebp
c01040de:	89 e5                	mov    %esp,%ebp
c01040e0:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01040e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01040e7:	75 24                	jne    c010410d <default_init_memmap+0x30>
c01040e9:	c7 44 24 0c 38 7a 10 	movl   $0xc0107a38,0xc(%esp)
c01040f0:	c0 
c01040f1:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c01040f8:	c0 
c01040f9:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104100:	00 
c0104101:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104108:	e8 dc c2 ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c010410d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104110:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104113:	eb 7d                	jmp    c0104192 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0104115:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104118:	83 c0 04             	add    $0x4,%eax
c010411b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0104122:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104125:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104128:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010412b:	0f a3 10             	bt     %edx,(%eax)
c010412e:	19 c0                	sbb    %eax,%eax
c0104130:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0104133:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104137:	0f 95 c0             	setne  %al
c010413a:	0f b6 c0             	movzbl %al,%eax
c010413d:	85 c0                	test   %eax,%eax
c010413f:	75 24                	jne    c0104165 <default_init_memmap+0x88>
c0104141:	c7 44 24 0c 69 7a 10 	movl   $0xc0107a69,0xc(%esp)
c0104148:	c0 
c0104149:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104150:	c0 
c0104151:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0104158:	00 
c0104159:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104160:	e8 84 c2 ff ff       	call   c01003e9 <__panic>
        p->flags = p->property = 0;
c0104165:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104168:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010416f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104172:	8b 50 08             	mov    0x8(%eax),%edx
c0104175:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104178:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c010417b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104182:	00 
c0104183:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104186:	89 04 24             	mov    %eax,(%esp)
c0104189:	e8 13 ff ff ff       	call   c01040a1 <set_page_ref>
    for (; p != base + n; p ++) {
c010418e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104192:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104195:	89 d0                	mov    %edx,%eax
c0104197:	c1 e0 02             	shl    $0x2,%eax
c010419a:	01 d0                	add    %edx,%eax
c010419c:	c1 e0 02             	shl    $0x2,%eax
c010419f:	89 c2                	mov    %eax,%edx
c01041a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01041a4:	01 d0                	add    %edx,%eax
c01041a6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01041a9:	0f 85 66 ff ff ff    	jne    c0104115 <default_init_memmap+0x38>
	
    }
    base->property = n;
c01041af:	8b 45 08             	mov    0x8(%ebp),%eax
c01041b2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01041b5:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01041b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01041bb:	83 c0 04             	add    $0x4,%eax
c01041be:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01041c5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01041c8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01041cb:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01041ce:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01041d1:	8b 15 28 df 11 c0    	mov    0xc011df28,%edx
c01041d7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01041da:	01 d0                	add    %edx,%eax
c01041dc:	a3 28 df 11 c0       	mov    %eax,0xc011df28
    list_add_before(&free_list,&(base->page_link));
c01041e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01041e4:	83 c0 0c             	add    $0xc,%eax
c01041e7:	c7 45 e4 20 df 11 c0 	movl   $0xc011df20,-0x1c(%ebp)
c01041ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01041f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041f4:	8b 00                	mov    (%eax),%eax
c01041f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01041f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01041fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01041ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104202:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104205:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104208:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010420b:	89 10                	mov    %edx,(%eax)
c010420d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104210:	8b 10                	mov    (%eax),%edx
c0104212:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104215:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104218:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010421b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010421e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104221:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104224:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104227:	89 10                	mov    %edx,(%eax)
}
c0104229:	90                   	nop
c010422a:	c9                   	leave  
c010422b:	c3                   	ret    

c010422c <default_alloc_pages>:
 *              return `p`.
 *      (4.2)
 *          If we can not find a free block with its size >=n, then return NULL.
*/
static struct Page *
default_alloc_pages(size_t n) {
c010422c:	55                   	push   %ebp
c010422d:	89 e5                	mov    %esp,%ebp
c010422f:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0104232:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104236:	75 24                	jne    c010425c <default_alloc_pages+0x30>
c0104238:	c7 44 24 0c 38 7a 10 	movl   $0xc0107a38,0xc(%esp)
c010423f:	c0 
c0104240:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104247:	c0 
c0104248:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c010424f:	00 
c0104250:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104257:	e8 8d c1 ff ff       	call   c01003e9 <__panic>
    if (n > nr_free) {
c010425c:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104261:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104264:	76 0a                	jbe    c0104270 <default_alloc_pages+0x44>
        return NULL;
c0104266:	b8 00 00 00 00       	mov    $0x0,%eax
c010426b:	e9 49 01 00 00       	jmp    c01043b9 <default_alloc_pages+0x18d>
    }
    struct Page *page=NULL;
c0104270:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0104277:	c7 45 f0 20 df 11 c0 	movl   $0xc011df20,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010427e:	eb 1c                	jmp    c010429c <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0104280:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104283:	83 e8 0c             	sub    $0xc,%eax
c0104286:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0104289:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010428c:	8b 40 08             	mov    0x8(%eax),%eax
c010428f:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104292:	77 08                	ja     c010429c <default_alloc_pages+0x70>
	   page=p;
c0104294:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104297:	89 45 f4             	mov    %eax,-0xc(%ebp)
	   break;
c010429a:	eb 18                	jmp    c01042b4 <default_alloc_pages+0x88>
c010429c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010429f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c01042a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042a5:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01042a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01042ab:	81 7d f0 20 df 11 c0 	cmpl   $0xc011df20,-0x10(%ebp)
c01042b2:	75 cc                	jne    c0104280 <default_alloc_pages+0x54>
        }
    }
    if(page!=NULL){
c01042b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01042b8:	0f 84 f8 00 00 00    	je     c01043b6 <default_alloc_pages+0x18a>
	if(page->property>n){
c01042be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042c1:	8b 40 08             	mov    0x8(%eax),%eax
c01042c4:	39 45 08             	cmp    %eax,0x8(%ebp)
c01042c7:	0f 83 98 00 00 00    	jae    c0104365 <default_alloc_pages+0x139>
	   struct Page*p=page+n;
c01042cd:	8b 55 08             	mov    0x8(%ebp),%edx
c01042d0:	89 d0                	mov    %edx,%eax
c01042d2:	c1 e0 02             	shl    $0x2,%eax
c01042d5:	01 d0                	add    %edx,%eax
c01042d7:	c1 e0 02             	shl    $0x2,%eax
c01042da:	89 c2                	mov    %eax,%edx
c01042dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042df:	01 d0                	add    %edx,%eax
c01042e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
	   p->property=page->property-n;
c01042e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042e7:	8b 40 08             	mov    0x8(%eax),%eax
c01042ea:	2b 45 08             	sub    0x8(%ebp),%eax
c01042ed:	89 c2                	mov    %eax,%edx
c01042ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042f2:	89 50 08             	mov    %edx,0x8(%eax)
	   SetPageProperty(p);
c01042f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042f8:	83 c0 04             	add    $0x4,%eax
c01042fb:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0104302:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0104305:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104308:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010430b:	0f ab 10             	bts    %edx,(%eax)
	   list_add(&(page->page_link),&(p->page_link));
c010430e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104311:	83 c0 0c             	add    $0xc,%eax
c0104314:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104317:	83 c2 0c             	add    $0xc,%edx
c010431a:	89 55 e0             	mov    %edx,-0x20(%ebp)
c010431d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104320:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104323:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104326:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104329:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c010432c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010432f:	8b 40 04             	mov    0x4(%eax),%eax
c0104332:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104335:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0104338:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010433b:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010433e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0104341:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104344:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104347:	89 10                	mov    %edx,(%eax)
c0104349:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010434c:	8b 10                	mov    (%eax),%edx
c010434e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104351:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104354:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104357:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010435a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010435d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104360:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104363:	89 10                	mov    %edx,(%eax)
	}
	
	list_del(&(page->page_link));
c0104365:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104368:	83 c0 0c             	add    $0xc,%eax
c010436b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
c010436e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104371:	8b 40 04             	mov    0x4(%eax),%eax
c0104374:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104377:	8b 12                	mov    (%edx),%edx
c0104379:	89 55 b0             	mov    %edx,-0x50(%ebp)
c010437c:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010437f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104382:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104385:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104388:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010438b:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010438e:	89 10                	mov    %edx,(%eax)
	nr_free-=n;
c0104390:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104395:	2b 45 08             	sub    0x8(%ebp),%eax
c0104398:	a3 28 df 11 c0       	mov    %eax,0xc011df28
	ClearPageProperty(page);
c010439d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043a0:	83 c0 04             	add    $0x4,%eax
c01043a3:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c01043aa:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01043ad:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01043b0:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01043b3:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c01043b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01043b9:	c9                   	leave  
c01043ba:	c3                   	ret    

c01043bb <default_free_pages>:
 *  (5.3)
 *      Try to merge blocks at lower or higher addresses. Notice: This should
 *  change some pages' `p->property` correctly.
 */
static void
default_free_pages(struct Page *base, size_t n) {
c01043bb:	55                   	push   %ebp
c01043bc:	89 e5                	mov    %esp,%ebp
c01043be:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c01043c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01043c8:	75 24                	jne    c01043ee <default_free_pages+0x33>
c01043ca:	c7 44 24 0c 38 7a 10 	movl   $0xc0107a38,0xc(%esp)
c01043d1:	c0 
c01043d2:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c01043d9:	c0 
c01043da:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c01043e1:	00 
c01043e2:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c01043e9:	e8 fb bf ff ff       	call   c01003e9 <__panic>
    struct Page *p = base;
c01043ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01043f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01043f4:	e9 9d 00 00 00       	jmp    c0104496 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c01043f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043fc:	83 c0 04             	add    $0x4,%eax
c01043ff:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104406:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104409:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010440c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010440f:	0f a3 10             	bt     %edx,(%eax)
c0104412:	19 c0                	sbb    %eax,%eax
c0104414:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0104417:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010441b:	0f 95 c0             	setne  %al
c010441e:	0f b6 c0             	movzbl %al,%eax
c0104421:	85 c0                	test   %eax,%eax
c0104423:	75 2c                	jne    c0104451 <default_free_pages+0x96>
c0104425:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104428:	83 c0 04             	add    $0x4,%eax
c010442b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0104432:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104435:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104438:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010443b:	0f a3 10             	bt     %edx,(%eax)
c010443e:	19 c0                	sbb    %eax,%eax
c0104440:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0104443:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0104447:	0f 95 c0             	setne  %al
c010444a:	0f b6 c0             	movzbl %al,%eax
c010444d:	85 c0                	test   %eax,%eax
c010444f:	74 24                	je     c0104475 <default_free_pages+0xba>
c0104451:	c7 44 24 0c 7c 7a 10 	movl   $0xc0107a7c,0xc(%esp)
c0104458:	c0 
c0104459:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104460:	c0 
c0104461:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0104468:	00 
c0104469:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104470:	e8 74 bf ff ff       	call   c01003e9 <__panic>
        p->flags = 0;
c0104475:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104478:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c010447f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104486:	00 
c0104487:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010448a:	89 04 24             	mov    %eax,(%esp)
c010448d:	e8 0f fc ff ff       	call   c01040a1 <set_page_ref>
    for (; p != base + n; p ++) {
c0104492:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104496:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104499:	89 d0                	mov    %edx,%eax
c010449b:	c1 e0 02             	shl    $0x2,%eax
c010449e:	01 d0                	add    %edx,%eax
c01044a0:	c1 e0 02             	shl    $0x2,%eax
c01044a3:	89 c2                	mov    %eax,%edx
c01044a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01044a8:	01 d0                	add    %edx,%eax
c01044aa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01044ad:	0f 85 46 ff ff ff    	jne    c01043f9 <default_free_pages+0x3e>
    }
    base->property = n;
c01044b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01044b6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01044b9:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01044bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01044bf:	83 c0 04             	add    $0x4,%eax
c01044c2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01044c9:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01044cc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01044cf:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01044d2:	0f ab 10             	bts    %edx,(%eax)
c01044d5:	c7 45 d4 20 df 11 c0 	movl   $0xc011df20,-0x2c(%ebp)
    return listelm->next;
c01044dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01044df:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c01044e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01044e5:	e9 08 01 00 00       	jmp    c01045f2 <default_free_pages+0x237>
        p = le2page(le, page_link);
c01044ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044ed:	83 e8 0c             	sub    $0xc,%eax
c01044f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01044f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044f6:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01044f9:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01044fc:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01044ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0104502:	8b 45 08             	mov    0x8(%ebp),%eax
c0104505:	8b 50 08             	mov    0x8(%eax),%edx
c0104508:	89 d0                	mov    %edx,%eax
c010450a:	c1 e0 02             	shl    $0x2,%eax
c010450d:	01 d0                	add    %edx,%eax
c010450f:	c1 e0 02             	shl    $0x2,%eax
c0104512:	89 c2                	mov    %eax,%edx
c0104514:	8b 45 08             	mov    0x8(%ebp),%eax
c0104517:	01 d0                	add    %edx,%eax
c0104519:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010451c:	75 5a                	jne    c0104578 <default_free_pages+0x1bd>
            base->property += p->property;
c010451e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104521:	8b 50 08             	mov    0x8(%eax),%edx
c0104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104527:	8b 40 08             	mov    0x8(%eax),%eax
c010452a:	01 c2                	add    %eax,%edx
c010452c:	8b 45 08             	mov    0x8(%ebp),%eax
c010452f:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0104532:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104535:	83 c0 04             	add    $0x4,%eax
c0104538:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010453f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104542:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104545:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0104548:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c010454b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010454e:	83 c0 0c             	add    $0xc,%eax
c0104551:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104554:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104557:	8b 40 04             	mov    0x4(%eax),%eax
c010455a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010455d:	8b 12                	mov    (%edx),%edx
c010455f:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0104562:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c0104565:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104568:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010456b:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010456e:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104571:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104574:	89 10                	mov    %edx,(%eax)
c0104576:	eb 7a                	jmp    c01045f2 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c0104578:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010457b:	8b 50 08             	mov    0x8(%eax),%edx
c010457e:	89 d0                	mov    %edx,%eax
c0104580:	c1 e0 02             	shl    $0x2,%eax
c0104583:	01 d0                	add    %edx,%eax
c0104585:	c1 e0 02             	shl    $0x2,%eax
c0104588:	89 c2                	mov    %eax,%edx
c010458a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010458d:	01 d0                	add    %edx,%eax
c010458f:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104592:	75 5e                	jne    c01045f2 <default_free_pages+0x237>
            p->property += base->property;
c0104594:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104597:	8b 50 08             	mov    0x8(%eax),%edx
c010459a:	8b 45 08             	mov    0x8(%ebp),%eax
c010459d:	8b 40 08             	mov    0x8(%eax),%eax
c01045a0:	01 c2                	add    %eax,%edx
c01045a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045a5:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c01045a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01045ab:	83 c0 04             	add    $0x4,%eax
c01045ae:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c01045b5:	89 45 a0             	mov    %eax,-0x60(%ebp)
c01045b8:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01045bb:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01045be:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c01045c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045c4:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c01045c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045ca:	83 c0 0c             	add    $0xc,%eax
c01045cd:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c01045d0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01045d3:	8b 40 04             	mov    0x4(%eax),%eax
c01045d6:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01045d9:	8b 12                	mov    (%edx),%edx
c01045db:	89 55 ac             	mov    %edx,-0x54(%ebp)
c01045de:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c01045e1:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01045e4:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01045e7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01045ea:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01045ed:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01045f0:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
c01045f2:	81 7d f0 20 df 11 c0 	cmpl   $0xc011df20,-0x10(%ebp)
c01045f9:	0f 85 eb fe ff ff    	jne    c01044ea <default_free_pages+0x12f>
        }
    }
    SetPageProperty(base);
c01045ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0104602:	83 c0 04             	add    $0x4,%eax
c0104605:	c7 45 98 01 00 00 00 	movl   $0x1,-0x68(%ebp)
c010460c:	89 45 94             	mov    %eax,-0x6c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010460f:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104612:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104615:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0104618:	8b 15 28 df 11 c0    	mov    0xc011df28,%edx
c010461e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104621:	01 d0                	add    %edx,%eax
c0104623:	a3 28 df 11 c0       	mov    %eax,0xc011df28
c0104628:	c7 45 9c 20 df 11 c0 	movl   $0xc011df20,-0x64(%ebp)
    return listelm->next;
c010462f:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104632:	8b 40 04             	mov    0x4(%eax),%eax
    le=list_next(&free_list);
c0104635:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
c0104638:	eb 0f                	jmp    c0104649 <default_free_pages+0x28e>
c010463a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010463d:	89 45 90             	mov    %eax,-0x70(%ebp)
c0104640:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104643:	8b 40 04             	mov    0x4(%eax),%eax
	le=list_next(le);
c0104646:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le!=&free_list)&&base>le2page(le,page_link)){	
c0104649:	81 7d f0 20 df 11 c0 	cmpl   $0xc011df20,-0x10(%ebp)
c0104650:	74 0b                	je     c010465d <default_free_pages+0x2a2>
c0104652:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104655:	83 e8 0c             	sub    $0xc,%eax
c0104658:	39 45 08             	cmp    %eax,0x8(%ebp)
c010465b:	77 dd                	ja     c010463a <default_free_pages+0x27f>
    }
    list_add_before(le, &(base->page_link));
c010465d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104660:	8d 50 0c             	lea    0xc(%eax),%edx
c0104663:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104666:	89 45 8c             	mov    %eax,-0x74(%ebp)
c0104669:	89 55 88             	mov    %edx,-0x78(%ebp)
    __list_add(elm, listelm->prev, listelm);
c010466c:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010466f:	8b 00                	mov    (%eax),%eax
c0104671:	8b 55 88             	mov    -0x78(%ebp),%edx
c0104674:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104677:	89 45 80             	mov    %eax,-0x80(%ebp)
c010467a:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010467d:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
    prev->next = next->prev = elm;
c0104683:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104689:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010468c:	89 10                	mov    %edx,(%eax)
c010468e:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104694:	8b 10                	mov    (%eax),%edx
c0104696:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104699:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010469c:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010469f:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c01046a5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01046a8:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01046ab:	8b 55 80             	mov    -0x80(%ebp),%edx
c01046ae:	89 10                	mov    %edx,(%eax)
}
c01046b0:	90                   	nop
c01046b1:	c9                   	leave  
c01046b2:	c3                   	ret    

c01046b3 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c01046b3:	55                   	push   %ebp
c01046b4:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01046b6:	a1 28 df 11 c0       	mov    0xc011df28,%eax
}
c01046bb:	5d                   	pop    %ebp
c01046bc:	c3                   	ret    

c01046bd <basic_check>:

static void
basic_check(void) {
c01046bd:	55                   	push   %ebp
c01046be:	89 e5                	mov    %esp,%ebp
c01046c0:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c01046c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01046ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01046d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c01046d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01046dd:	e8 67 e4 ff ff       	call   c0102b49 <alloc_pages>
c01046e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01046e5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01046e9:	75 24                	jne    c010470f <basic_check+0x52>
c01046eb:	c7 44 24 0c a1 7a 10 	movl   $0xc0107aa1,0xc(%esp)
c01046f2:	c0 
c01046f3:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c01046fa:	c0 
c01046fb:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c0104702:	00 
c0104703:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c010470a:	e8 da bc ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010470f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104716:	e8 2e e4 ff ff       	call   c0102b49 <alloc_pages>
c010471b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010471e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104722:	75 24                	jne    c0104748 <basic_check+0x8b>
c0104724:	c7 44 24 0c bd 7a 10 	movl   $0xc0107abd,0xc(%esp)
c010472b:	c0 
c010472c:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104733:	c0 
c0104734:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c010473b:	00 
c010473c:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104743:	e8 a1 bc ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104748:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010474f:	e8 f5 e3 ff ff       	call   c0102b49 <alloc_pages>
c0104754:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104757:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010475b:	75 24                	jne    c0104781 <basic_check+0xc4>
c010475d:	c7 44 24 0c d9 7a 10 	movl   $0xc0107ad9,0xc(%esp)
c0104764:	c0 
c0104765:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c010476c:	c0 
c010476d:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0104774:	00 
c0104775:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c010477c:	e8 68 bc ff ff       	call   c01003e9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104781:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104784:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104787:	74 10                	je     c0104799 <basic_check+0xdc>
c0104789:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010478c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010478f:	74 08                	je     c0104799 <basic_check+0xdc>
c0104791:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104794:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104797:	75 24                	jne    c01047bd <basic_check+0x100>
c0104799:	c7 44 24 0c f8 7a 10 	movl   $0xc0107af8,0xc(%esp)
c01047a0:	c0 
c01047a1:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c01047a8:	c0 
c01047a9:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c01047b0:	00 
c01047b1:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c01047b8:	e8 2c bc ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c01047bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047c0:	89 04 24             	mov    %eax,(%esp)
c01047c3:	e8 cf f8 ff ff       	call   c0104097 <page_ref>
c01047c8:	85 c0                	test   %eax,%eax
c01047ca:	75 1e                	jne    c01047ea <basic_check+0x12d>
c01047cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047cf:	89 04 24             	mov    %eax,(%esp)
c01047d2:	e8 c0 f8 ff ff       	call   c0104097 <page_ref>
c01047d7:	85 c0                	test   %eax,%eax
c01047d9:	75 0f                	jne    c01047ea <basic_check+0x12d>
c01047db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047de:	89 04 24             	mov    %eax,(%esp)
c01047e1:	e8 b1 f8 ff ff       	call   c0104097 <page_ref>
c01047e6:	85 c0                	test   %eax,%eax
c01047e8:	74 24                	je     c010480e <basic_check+0x151>
c01047ea:	c7 44 24 0c 1c 7b 10 	movl   $0xc0107b1c,0xc(%esp)
c01047f1:	c0 
c01047f2:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c01047f9:	c0 
c01047fa:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0104801:	00 
c0104802:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104809:	e8 db bb ff ff       	call   c01003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c010480e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104811:	89 04 24             	mov    %eax,(%esp)
c0104814:	e8 68 f8 ff ff       	call   c0104081 <page2pa>
c0104819:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c010481f:	c1 e2 0c             	shl    $0xc,%edx
c0104822:	39 d0                	cmp    %edx,%eax
c0104824:	72 24                	jb     c010484a <basic_check+0x18d>
c0104826:	c7 44 24 0c 58 7b 10 	movl   $0xc0107b58,0xc(%esp)
c010482d:	c0 
c010482e:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104835:	c0 
c0104836:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c010483d:	00 
c010483e:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104845:	e8 9f bb ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c010484a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010484d:	89 04 24             	mov    %eax,(%esp)
c0104850:	e8 2c f8 ff ff       	call   c0104081 <page2pa>
c0104855:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c010485b:	c1 e2 0c             	shl    $0xc,%edx
c010485e:	39 d0                	cmp    %edx,%eax
c0104860:	72 24                	jb     c0104886 <basic_check+0x1c9>
c0104862:	c7 44 24 0c 75 7b 10 	movl   $0xc0107b75,0xc(%esp)
c0104869:	c0 
c010486a:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104871:	c0 
c0104872:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
c0104879:	00 
c010487a:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104881:	e8 63 bb ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104886:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104889:	89 04 24             	mov    %eax,(%esp)
c010488c:	e8 f0 f7 ff ff       	call   c0104081 <page2pa>
c0104891:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0104897:	c1 e2 0c             	shl    $0xc,%edx
c010489a:	39 d0                	cmp    %edx,%eax
c010489c:	72 24                	jb     c01048c2 <basic_check+0x205>
c010489e:	c7 44 24 0c 92 7b 10 	movl   $0xc0107b92,0xc(%esp)
c01048a5:	c0 
c01048a6:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c01048ad:	c0 
c01048ae:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01048b5:	00 
c01048b6:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c01048bd:	e8 27 bb ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c01048c2:	a1 20 df 11 c0       	mov    0xc011df20,%eax
c01048c7:	8b 15 24 df 11 c0    	mov    0xc011df24,%edx
c01048cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01048d0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01048d3:	c7 45 dc 20 df 11 c0 	movl   $0xc011df20,-0x24(%ebp)
    elm->prev = elm->next = elm;
c01048da:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01048dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01048e0:	89 50 04             	mov    %edx,0x4(%eax)
c01048e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01048e6:	8b 50 04             	mov    0x4(%eax),%edx
c01048e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01048ec:	89 10                	mov    %edx,(%eax)
c01048ee:	c7 45 e0 20 df 11 c0 	movl   $0xc011df20,-0x20(%ebp)
    return list->next == list;
c01048f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048f8:	8b 40 04             	mov    0x4(%eax),%eax
c01048fb:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01048fe:	0f 94 c0             	sete   %al
c0104901:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104904:	85 c0                	test   %eax,%eax
c0104906:	75 24                	jne    c010492c <basic_check+0x26f>
c0104908:	c7 44 24 0c af 7b 10 	movl   $0xc0107baf,0xc(%esp)
c010490f:	c0 
c0104910:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104917:	c0 
c0104918:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c010491f:	00 
c0104920:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104927:	e8 bd ba ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c010492c:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104931:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104934:	c7 05 28 df 11 c0 00 	movl   $0x0,0xc011df28
c010493b:	00 00 00 

    assert(alloc_page() == NULL);
c010493e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104945:	e8 ff e1 ff ff       	call   c0102b49 <alloc_pages>
c010494a:	85 c0                	test   %eax,%eax
c010494c:	74 24                	je     c0104972 <basic_check+0x2b5>
c010494e:	c7 44 24 0c c6 7b 10 	movl   $0xc0107bc6,0xc(%esp)
c0104955:	c0 
c0104956:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c010495d:	c0 
c010495e:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0104965:	00 
c0104966:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c010496d:	e8 77 ba ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104972:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104979:	00 
c010497a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010497d:	89 04 24             	mov    %eax,(%esp)
c0104980:	e8 fc e1 ff ff       	call   c0102b81 <free_pages>
    free_page(p1);
c0104985:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010498c:	00 
c010498d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104990:	89 04 24             	mov    %eax,(%esp)
c0104993:	e8 e9 e1 ff ff       	call   c0102b81 <free_pages>
    free_page(p2);
c0104998:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010499f:	00 
c01049a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049a3:	89 04 24             	mov    %eax,(%esp)
c01049a6:	e8 d6 e1 ff ff       	call   c0102b81 <free_pages>
    assert(nr_free == 3);
c01049ab:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c01049b0:	83 f8 03             	cmp    $0x3,%eax
c01049b3:	74 24                	je     c01049d9 <basic_check+0x31c>
c01049b5:	c7 44 24 0c db 7b 10 	movl   $0xc0107bdb,0xc(%esp)
c01049bc:	c0 
c01049bd:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c01049c4:	c0 
c01049c5:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c01049cc:	00 
c01049cd:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c01049d4:	e8 10 ba ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c01049d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01049e0:	e8 64 e1 ff ff       	call   c0102b49 <alloc_pages>
c01049e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01049e8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01049ec:	75 24                	jne    c0104a12 <basic_check+0x355>
c01049ee:	c7 44 24 0c a1 7a 10 	movl   $0xc0107aa1,0xc(%esp)
c01049f5:	c0 
c01049f6:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c01049fd:	c0 
c01049fe:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0104a05:	00 
c0104a06:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104a0d:	e8 d7 b9 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104a12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a19:	e8 2b e1 ff ff       	call   c0102b49 <alloc_pages>
c0104a1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a21:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104a25:	75 24                	jne    c0104a4b <basic_check+0x38e>
c0104a27:	c7 44 24 0c bd 7a 10 	movl   $0xc0107abd,0xc(%esp)
c0104a2e:	c0 
c0104a2f:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104a36:	c0 
c0104a37:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0104a3e:	00 
c0104a3f:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104a46:	e8 9e b9 ff ff       	call   c01003e9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104a4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a52:	e8 f2 e0 ff ff       	call   c0102b49 <alloc_pages>
c0104a57:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104a5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104a5e:	75 24                	jne    c0104a84 <basic_check+0x3c7>
c0104a60:	c7 44 24 0c d9 7a 10 	movl   $0xc0107ad9,0xc(%esp)
c0104a67:	c0 
c0104a68:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104a6f:	c0 
c0104a70:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0104a77:	00 
c0104a78:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104a7f:	e8 65 b9 ff ff       	call   c01003e9 <__panic>

    assert(alloc_page() == NULL);
c0104a84:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a8b:	e8 b9 e0 ff ff       	call   c0102b49 <alloc_pages>
c0104a90:	85 c0                	test   %eax,%eax
c0104a92:	74 24                	je     c0104ab8 <basic_check+0x3fb>
c0104a94:	c7 44 24 0c c6 7b 10 	movl   $0xc0107bc6,0xc(%esp)
c0104a9b:	c0 
c0104a9c:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104aa3:	c0 
c0104aa4:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0104aab:	00 
c0104aac:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104ab3:	e8 31 b9 ff ff       	call   c01003e9 <__panic>

    free_page(p0);
c0104ab8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104abf:	00 
c0104ac0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ac3:	89 04 24             	mov    %eax,(%esp)
c0104ac6:	e8 b6 e0 ff ff       	call   c0102b81 <free_pages>
c0104acb:	c7 45 d8 20 df 11 c0 	movl   $0xc011df20,-0x28(%ebp)
c0104ad2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104ad5:	8b 40 04             	mov    0x4(%eax),%eax
c0104ad8:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104adb:	0f 94 c0             	sete   %al
c0104ade:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104ae1:	85 c0                	test   %eax,%eax
c0104ae3:	74 24                	je     c0104b09 <basic_check+0x44c>
c0104ae5:	c7 44 24 0c e8 7b 10 	movl   $0xc0107be8,0xc(%esp)
c0104aec:	c0 
c0104aed:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104af4:	c0 
c0104af5:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0104afc:	00 
c0104afd:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104b04:	e8 e0 b8 ff ff       	call   c01003e9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104b09:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b10:	e8 34 e0 ff ff       	call   c0102b49 <alloc_pages>
c0104b15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104b18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b1b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104b1e:	74 24                	je     c0104b44 <basic_check+0x487>
c0104b20:	c7 44 24 0c 00 7c 10 	movl   $0xc0107c00,0xc(%esp)
c0104b27:	c0 
c0104b28:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104b2f:	c0 
c0104b30:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0104b37:	00 
c0104b38:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104b3f:	e8 a5 b8 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104b44:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b4b:	e8 f9 df ff ff       	call   c0102b49 <alloc_pages>
c0104b50:	85 c0                	test   %eax,%eax
c0104b52:	74 24                	je     c0104b78 <basic_check+0x4bb>
c0104b54:	c7 44 24 0c c6 7b 10 	movl   $0xc0107bc6,0xc(%esp)
c0104b5b:	c0 
c0104b5c:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104b63:	c0 
c0104b64:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0104b6b:	00 
c0104b6c:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104b73:	e8 71 b8 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c0104b78:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104b7d:	85 c0                	test   %eax,%eax
c0104b7f:	74 24                	je     c0104ba5 <basic_check+0x4e8>
c0104b81:	c7 44 24 0c 19 7c 10 	movl   $0xc0107c19,0xc(%esp)
c0104b88:	c0 
c0104b89:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104b90:	c0 
c0104b91:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0104b98:	00 
c0104b99:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104ba0:	e8 44 b8 ff ff       	call   c01003e9 <__panic>
    free_list = free_list_store;
c0104ba5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104ba8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104bab:	a3 20 df 11 c0       	mov    %eax,0xc011df20
c0104bb0:	89 15 24 df 11 c0    	mov    %edx,0xc011df24
    nr_free = nr_free_store;
c0104bb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104bb9:	a3 28 df 11 c0       	mov    %eax,0xc011df28

    free_page(p);
c0104bbe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104bc5:	00 
c0104bc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104bc9:	89 04 24             	mov    %eax,(%esp)
c0104bcc:	e8 b0 df ff ff       	call   c0102b81 <free_pages>
    free_page(p1);
c0104bd1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104bd8:	00 
c0104bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bdc:	89 04 24             	mov    %eax,(%esp)
c0104bdf:	e8 9d df ff ff       	call   c0102b81 <free_pages>
    free_page(p2);
c0104be4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104beb:	00 
c0104bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bef:	89 04 24             	mov    %eax,(%esp)
c0104bf2:	e8 8a df ff ff       	call   c0102b81 <free_pages>
}
c0104bf7:	90                   	nop
c0104bf8:	c9                   	leave  
c0104bf9:	c3                   	ret    

c0104bfa <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104bfa:	55                   	push   %ebp
c0104bfb:	89 e5                	mov    %esp,%ebp
c0104bfd:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0104c03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104c0a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104c11:	c7 45 ec 20 df 11 c0 	movl   $0xc011df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104c18:	eb 6a                	jmp    c0104c84 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0104c1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c1d:	83 e8 0c             	sub    $0xc,%eax
c0104c20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0104c23:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104c26:	83 c0 04             	add    $0x4,%eax
c0104c29:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104c30:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104c33:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104c36:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104c39:	0f a3 10             	bt     %edx,(%eax)
c0104c3c:	19 c0                	sbb    %eax,%eax
c0104c3e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104c41:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104c45:	0f 95 c0             	setne  %al
c0104c48:	0f b6 c0             	movzbl %al,%eax
c0104c4b:	85 c0                	test   %eax,%eax
c0104c4d:	75 24                	jne    c0104c73 <default_check+0x79>
c0104c4f:	c7 44 24 0c 26 7c 10 	movl   $0xc0107c26,0xc(%esp)
c0104c56:	c0 
c0104c57:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104c5e:	c0 
c0104c5f:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0104c66:	00 
c0104c67:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104c6e:	e8 76 b7 ff ff       	call   c01003e9 <__panic>
        count ++, total += p->property;
c0104c73:	ff 45 f4             	incl   -0xc(%ebp)
c0104c76:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104c79:	8b 50 08             	mov    0x8(%eax),%edx
c0104c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c7f:	01 d0                	add    %edx,%eax
c0104c81:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c84:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c87:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0104c8a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104c8d:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104c90:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104c93:	81 7d ec 20 df 11 c0 	cmpl   $0xc011df20,-0x14(%ebp)
c0104c9a:	0f 85 7a ff ff ff    	jne    c0104c1a <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0104ca0:	e8 0f df ff ff       	call   c0102bb4 <nr_free_pages>
c0104ca5:	89 c2                	mov    %eax,%edx
c0104ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104caa:	39 c2                	cmp    %eax,%edx
c0104cac:	74 24                	je     c0104cd2 <default_check+0xd8>
c0104cae:	c7 44 24 0c 36 7c 10 	movl   $0xc0107c36,0xc(%esp)
c0104cb5:	c0 
c0104cb6:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104cbd:	c0 
c0104cbe:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0104cc5:	00 
c0104cc6:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104ccd:	e8 17 b7 ff ff       	call   c01003e9 <__panic>

    basic_check();
c0104cd2:	e8 e6 f9 ff ff       	call   c01046bd <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104cd7:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104cde:	e8 66 de ff ff       	call   c0102b49 <alloc_pages>
c0104ce3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0104ce6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104cea:	75 24                	jne    c0104d10 <default_check+0x116>
c0104cec:	c7 44 24 0c 4f 7c 10 	movl   $0xc0107c4f,0xc(%esp)
c0104cf3:	c0 
c0104cf4:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104cfb:	c0 
c0104cfc:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0104d03:	00 
c0104d04:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104d0b:	e8 d9 b6 ff ff       	call   c01003e9 <__panic>
    assert(!PageProperty(p0));
c0104d10:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d13:	83 c0 04             	add    $0x4,%eax
c0104d16:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104d1d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104d20:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104d23:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104d26:	0f a3 10             	bt     %edx,(%eax)
c0104d29:	19 c0                	sbb    %eax,%eax
c0104d2b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104d2e:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104d32:	0f 95 c0             	setne  %al
c0104d35:	0f b6 c0             	movzbl %al,%eax
c0104d38:	85 c0                	test   %eax,%eax
c0104d3a:	74 24                	je     c0104d60 <default_check+0x166>
c0104d3c:	c7 44 24 0c 5a 7c 10 	movl   $0xc0107c5a,0xc(%esp)
c0104d43:	c0 
c0104d44:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104d4b:	c0 
c0104d4c:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0104d53:	00 
c0104d54:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104d5b:	e8 89 b6 ff ff       	call   c01003e9 <__panic>

    list_entry_t free_list_store = free_list;
c0104d60:	a1 20 df 11 c0       	mov    0xc011df20,%eax
c0104d65:	8b 15 24 df 11 c0    	mov    0xc011df24,%edx
c0104d6b:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104d6e:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104d71:	c7 45 b0 20 df 11 c0 	movl   $0xc011df20,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0104d78:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104d7b:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104d7e:	89 50 04             	mov    %edx,0x4(%eax)
c0104d81:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104d84:	8b 50 04             	mov    0x4(%eax),%edx
c0104d87:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104d8a:	89 10                	mov    %edx,(%eax)
c0104d8c:	c7 45 b4 20 df 11 c0 	movl   $0xc011df20,-0x4c(%ebp)
    return list->next == list;
c0104d93:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104d96:	8b 40 04             	mov    0x4(%eax),%eax
c0104d99:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0104d9c:	0f 94 c0             	sete   %al
c0104d9f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104da2:	85 c0                	test   %eax,%eax
c0104da4:	75 24                	jne    c0104dca <default_check+0x1d0>
c0104da6:	c7 44 24 0c af 7b 10 	movl   $0xc0107baf,0xc(%esp)
c0104dad:	c0 
c0104dae:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104db5:	c0 
c0104db6:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0104dbd:	00 
c0104dbe:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104dc5:	e8 1f b6 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104dca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104dd1:	e8 73 dd ff ff       	call   c0102b49 <alloc_pages>
c0104dd6:	85 c0                	test   %eax,%eax
c0104dd8:	74 24                	je     c0104dfe <default_check+0x204>
c0104dda:	c7 44 24 0c c6 7b 10 	movl   $0xc0107bc6,0xc(%esp)
c0104de1:	c0 
c0104de2:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104de9:	c0 
c0104dea:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0104df1:	00 
c0104df2:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104df9:	e8 eb b5 ff ff       	call   c01003e9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104dfe:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0104e03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0104e06:	c7 05 28 df 11 c0 00 	movl   $0x0,0xc011df28
c0104e0d:	00 00 00 

    free_pages(p0 + 2, 3);
c0104e10:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e13:	83 c0 28             	add    $0x28,%eax
c0104e16:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104e1d:	00 
c0104e1e:	89 04 24             	mov    %eax,(%esp)
c0104e21:	e8 5b dd ff ff       	call   c0102b81 <free_pages>
    assert(alloc_pages(4) == NULL);
c0104e26:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104e2d:	e8 17 dd ff ff       	call   c0102b49 <alloc_pages>
c0104e32:	85 c0                	test   %eax,%eax
c0104e34:	74 24                	je     c0104e5a <default_check+0x260>
c0104e36:	c7 44 24 0c 6c 7c 10 	movl   $0xc0107c6c,0xc(%esp)
c0104e3d:	c0 
c0104e3e:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104e45:	c0 
c0104e46:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0104e4d:	00 
c0104e4e:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104e55:	e8 8f b5 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104e5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e5d:	83 c0 28             	add    $0x28,%eax
c0104e60:	83 c0 04             	add    $0x4,%eax
c0104e63:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0104e6a:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104e6d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104e70:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104e73:	0f a3 10             	bt     %edx,(%eax)
c0104e76:	19 c0                	sbb    %eax,%eax
c0104e78:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104e7b:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104e7f:	0f 95 c0             	setne  %al
c0104e82:	0f b6 c0             	movzbl %al,%eax
c0104e85:	85 c0                	test   %eax,%eax
c0104e87:	74 0e                	je     c0104e97 <default_check+0x29d>
c0104e89:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e8c:	83 c0 28             	add    $0x28,%eax
c0104e8f:	8b 40 08             	mov    0x8(%eax),%eax
c0104e92:	83 f8 03             	cmp    $0x3,%eax
c0104e95:	74 24                	je     c0104ebb <default_check+0x2c1>
c0104e97:	c7 44 24 0c 84 7c 10 	movl   $0xc0107c84,0xc(%esp)
c0104e9e:	c0 
c0104e9f:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104ea6:	c0 
c0104ea7:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0104eae:	00 
c0104eaf:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104eb6:	e8 2e b5 ff ff       	call   c01003e9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104ebb:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104ec2:	e8 82 dc ff ff       	call   c0102b49 <alloc_pages>
c0104ec7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104eca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104ece:	75 24                	jne    c0104ef4 <default_check+0x2fa>
c0104ed0:	c7 44 24 0c b0 7c 10 	movl   $0xc0107cb0,0xc(%esp)
c0104ed7:	c0 
c0104ed8:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104edf:	c0 
c0104ee0:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c0104ee7:	00 
c0104ee8:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104eef:	e8 f5 b4 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c0104ef4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104efb:	e8 49 dc ff ff       	call   c0102b49 <alloc_pages>
c0104f00:	85 c0                	test   %eax,%eax
c0104f02:	74 24                	je     c0104f28 <default_check+0x32e>
c0104f04:	c7 44 24 0c c6 7b 10 	movl   $0xc0107bc6,0xc(%esp)
c0104f0b:	c0 
c0104f0c:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104f13:	c0 
c0104f14:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c0104f1b:	00 
c0104f1c:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104f23:	e8 c1 b4 ff ff       	call   c01003e9 <__panic>
    assert(p0 + 2 == p1);
c0104f28:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f2b:	83 c0 28             	add    $0x28,%eax
c0104f2e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104f31:	74 24                	je     c0104f57 <default_check+0x35d>
c0104f33:	c7 44 24 0c ce 7c 10 	movl   $0xc0107cce,0xc(%esp)
c0104f3a:	c0 
c0104f3b:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104f42:	c0 
c0104f43:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c0104f4a:	00 
c0104f4b:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104f52:	e8 92 b4 ff ff       	call   c01003e9 <__panic>

    p2 = p0 + 1;
c0104f57:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f5a:	83 c0 14             	add    $0x14,%eax
c0104f5d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0104f60:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f67:	00 
c0104f68:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f6b:	89 04 24             	mov    %eax,(%esp)
c0104f6e:	e8 0e dc ff ff       	call   c0102b81 <free_pages>
    free_pages(p1, 3);
c0104f73:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104f7a:	00 
c0104f7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f7e:	89 04 24             	mov    %eax,(%esp)
c0104f81:	e8 fb db ff ff       	call   c0102b81 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0104f86:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f89:	83 c0 04             	add    $0x4,%eax
c0104f8c:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0104f93:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104f96:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104f99:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104f9c:	0f a3 10             	bt     %edx,(%eax)
c0104f9f:	19 c0                	sbb    %eax,%eax
c0104fa1:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0104fa4:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0104fa8:	0f 95 c0             	setne  %al
c0104fab:	0f b6 c0             	movzbl %al,%eax
c0104fae:	85 c0                	test   %eax,%eax
c0104fb0:	74 0b                	je     c0104fbd <default_check+0x3c3>
c0104fb2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104fb5:	8b 40 08             	mov    0x8(%eax),%eax
c0104fb8:	83 f8 01             	cmp    $0x1,%eax
c0104fbb:	74 24                	je     c0104fe1 <default_check+0x3e7>
c0104fbd:	c7 44 24 0c dc 7c 10 	movl   $0xc0107cdc,0xc(%esp)
c0104fc4:	c0 
c0104fc5:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0104fcc:	c0 
c0104fcd:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
c0104fd4:	00 
c0104fd5:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0104fdc:	e8 08 b4 ff ff       	call   c01003e9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104fe1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104fe4:	83 c0 04             	add    $0x4,%eax
c0104fe7:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0104fee:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104ff1:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104ff4:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104ff7:	0f a3 10             	bt     %edx,(%eax)
c0104ffa:	19 c0                	sbb    %eax,%eax
c0104ffc:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0104fff:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0105003:	0f 95 c0             	setne  %al
c0105006:	0f b6 c0             	movzbl %al,%eax
c0105009:	85 c0                	test   %eax,%eax
c010500b:	74 0b                	je     c0105018 <default_check+0x41e>
c010500d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105010:	8b 40 08             	mov    0x8(%eax),%eax
c0105013:	83 f8 03             	cmp    $0x3,%eax
c0105016:	74 24                	je     c010503c <default_check+0x442>
c0105018:	c7 44 24 0c 04 7d 10 	movl   $0xc0107d04,0xc(%esp)
c010501f:	c0 
c0105020:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0105027:	c0 
c0105028:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
c010502f:	00 
c0105030:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0105037:	e8 ad b3 ff ff       	call   c01003e9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010503c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105043:	e8 01 db ff ff       	call   c0102b49 <alloc_pages>
c0105048:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010504b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010504e:	83 e8 14             	sub    $0x14,%eax
c0105051:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105054:	74 24                	je     c010507a <default_check+0x480>
c0105056:	c7 44 24 0c 2a 7d 10 	movl   $0xc0107d2a,0xc(%esp)
c010505d:	c0 
c010505e:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0105065:	c0 
c0105066:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
c010506d:	00 
c010506e:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0105075:	e8 6f b3 ff ff       	call   c01003e9 <__panic>
    free_page(p0);
c010507a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105081:	00 
c0105082:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105085:	89 04 24             	mov    %eax,(%esp)
c0105088:	e8 f4 da ff ff       	call   c0102b81 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010508d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0105094:	e8 b0 da ff ff       	call   c0102b49 <alloc_pages>
c0105099:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010509c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010509f:	83 c0 14             	add    $0x14,%eax
c01050a2:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01050a5:	74 24                	je     c01050cb <default_check+0x4d1>
c01050a7:	c7 44 24 0c 48 7d 10 	movl   $0xc0107d48,0xc(%esp)
c01050ae:	c0 
c01050af:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c01050b6:	c0 
c01050b7:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
c01050be:	00 
c01050bf:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c01050c6:	e8 1e b3 ff ff       	call   c01003e9 <__panic>

    free_pages(p0, 2);
c01050cb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01050d2:	00 
c01050d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050d6:	89 04 24             	mov    %eax,(%esp)
c01050d9:	e8 a3 da ff ff       	call   c0102b81 <free_pages>
    free_page(p2);
c01050de:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050e5:	00 
c01050e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01050e9:	89 04 24             	mov    %eax,(%esp)
c01050ec:	e8 90 da ff ff       	call   c0102b81 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01050f1:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01050f8:	e8 4c da ff ff       	call   c0102b49 <alloc_pages>
c01050fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105100:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105104:	75 24                	jne    c010512a <default_check+0x530>
c0105106:	c7 44 24 0c 68 7d 10 	movl   $0xc0107d68,0xc(%esp)
c010510d:	c0 
c010510e:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0105115:	c0 
c0105116:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c010511d:	00 
c010511e:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0105125:	e8 bf b2 ff ff       	call   c01003e9 <__panic>
    assert(alloc_page() == NULL);
c010512a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105131:	e8 13 da ff ff       	call   c0102b49 <alloc_pages>
c0105136:	85 c0                	test   %eax,%eax
c0105138:	74 24                	je     c010515e <default_check+0x564>
c010513a:	c7 44 24 0c c6 7b 10 	movl   $0xc0107bc6,0xc(%esp)
c0105141:	c0 
c0105142:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0105149:	c0 
c010514a:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c0105151:	00 
c0105152:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0105159:	e8 8b b2 ff ff       	call   c01003e9 <__panic>

    assert(nr_free == 0);
c010515e:	a1 28 df 11 c0       	mov    0xc011df28,%eax
c0105163:	85 c0                	test   %eax,%eax
c0105165:	74 24                	je     c010518b <default_check+0x591>
c0105167:	c7 44 24 0c 19 7c 10 	movl   $0xc0107c19,0xc(%esp)
c010516e:	c0 
c010516f:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0105176:	c0 
c0105177:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
c010517e:	00 
c010517f:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0105186:	e8 5e b2 ff ff       	call   c01003e9 <__panic>
    nr_free = nr_free_store;
c010518b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010518e:	a3 28 df 11 c0       	mov    %eax,0xc011df28

    free_list = free_list_store;
c0105193:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105196:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105199:	a3 20 df 11 c0       	mov    %eax,0xc011df20
c010519e:	89 15 24 df 11 c0    	mov    %edx,0xc011df24
    free_pages(p0, 5);
c01051a4:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01051ab:	00 
c01051ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051af:	89 04 24             	mov    %eax,(%esp)
c01051b2:	e8 ca d9 ff ff       	call   c0102b81 <free_pages>

    le = &free_list;
c01051b7:	c7 45 ec 20 df 11 c0 	movl   $0xc011df20,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01051be:	eb 5a                	jmp    c010521a <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
c01051c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051c3:	8b 40 04             	mov    0x4(%eax),%eax
c01051c6:	8b 00                	mov    (%eax),%eax
c01051c8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01051cb:	75 0d                	jne    c01051da <default_check+0x5e0>
c01051cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051d0:	8b 00                	mov    (%eax),%eax
c01051d2:	8b 40 04             	mov    0x4(%eax),%eax
c01051d5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01051d8:	74 24                	je     c01051fe <default_check+0x604>
c01051da:	c7 44 24 0c 88 7d 10 	movl   $0xc0107d88,0xc(%esp)
c01051e1:	c0 
c01051e2:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c01051e9:	c0 
c01051ea:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
c01051f1:	00 
c01051f2:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c01051f9:	e8 eb b1 ff ff       	call   c01003e9 <__panic>
        struct Page *p = le2page(le, page_link);
c01051fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105201:	83 e8 0c             	sub    $0xc,%eax
c0105204:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0105207:	ff 4d f4             	decl   -0xc(%ebp)
c010520a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010520d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105210:	8b 40 08             	mov    0x8(%eax),%eax
c0105213:	29 c2                	sub    %eax,%edx
c0105215:	89 d0                	mov    %edx,%eax
c0105217:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010521a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010521d:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0105220:	8b 45 88             	mov    -0x78(%ebp),%eax
c0105223:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105226:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105229:	81 7d ec 20 df 11 c0 	cmpl   $0xc011df20,-0x14(%ebp)
c0105230:	75 8e                	jne    c01051c0 <default_check+0x5c6>
    }
    assert(count == 0);
c0105232:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105236:	74 24                	je     c010525c <default_check+0x662>
c0105238:	c7 44 24 0c b5 7d 10 	movl   $0xc0107db5,0xc(%esp)
c010523f:	c0 
c0105240:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0105247:	c0 
c0105248:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
c010524f:	00 
c0105250:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0105257:	e8 8d b1 ff ff       	call   c01003e9 <__panic>
    assert(total == 0);
c010525c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105260:	74 24                	je     c0105286 <default_check+0x68c>
c0105262:	c7 44 24 0c c0 7d 10 	movl   $0xc0107dc0,0xc(%esp)
c0105269:	c0 
c010526a:	c7 44 24 08 3e 7a 10 	movl   $0xc0107a3e,0x8(%esp)
c0105271:	c0 
c0105272:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
c0105279:	00 
c010527a:	c7 04 24 53 7a 10 c0 	movl   $0xc0107a53,(%esp)
c0105281:	e8 63 b1 ff ff       	call   c01003e9 <__panic>
}
c0105286:	90                   	nop
c0105287:	c9                   	leave  
c0105288:	c3                   	ret    

c0105289 <page2ppn>:
page2ppn(struct Page *page) {
c0105289:	55                   	push   %ebp
c010528a:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010528c:	8b 45 08             	mov    0x8(%ebp),%eax
c010528f:	8b 15 18 df 11 c0    	mov    0xc011df18,%edx
c0105295:	29 d0                	sub    %edx,%eax
c0105297:	c1 f8 02             	sar    $0x2,%eax
c010529a:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01052a0:	5d                   	pop    %ebp
c01052a1:	c3                   	ret    

c01052a2 <page2pa>:
page2pa(struct Page *page) {
c01052a2:	55                   	push   %ebp
c01052a3:	89 e5                	mov    %esp,%ebp
c01052a5:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01052a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01052ab:	89 04 24             	mov    %eax,(%esp)
c01052ae:	e8 d6 ff ff ff       	call   c0105289 <page2ppn>
c01052b3:	c1 e0 0c             	shl    $0xc,%eax
}
c01052b6:	c9                   	leave  
c01052b7:	c3                   	ret    

c01052b8 <page_ref>:
page_ref(struct Page *page) {
c01052b8:	55                   	push   %ebp
c01052b9:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01052bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01052be:	8b 00                	mov    (%eax),%eax
}
c01052c0:	5d                   	pop    %ebp
c01052c1:	c3                   	ret    

c01052c2 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c01052c2:	55                   	push   %ebp
c01052c3:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01052c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01052c8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01052cb:	89 10                	mov    %edx,(%eax)
}
c01052cd:	90                   	nop
c01052ce:	5d                   	pop    %ebp
c01052cf:	c3                   	ret    

c01052d0 <buddy_init>:

#define MAXLEVEL 12
free_area_t free_area[MAXLEVEL+1];

static void 
buddy_init(void){
c01052d0:	55                   	push   %ebp
c01052d1:	89 e5                	mov    %esp,%ebp
c01052d3:	83 ec 10             	sub    $0x10,%esp
     for(int i=0;i<=MAXLEVEL;i++){
c01052d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01052dd:	eb 42                	jmp    c0105321 <buddy_init+0x51>
	list_init(&free_area[i].free_list);
c01052df:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01052e2:	89 d0                	mov    %edx,%eax
c01052e4:	01 c0                	add    %eax,%eax
c01052e6:	01 d0                	add    %edx,%eax
c01052e8:	c1 e0 02             	shl    $0x2,%eax
c01052eb:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01052f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
    elm->prev = elm->next = elm;
c01052f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01052f6:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01052f9:	89 50 04             	mov    %edx,0x4(%eax)
c01052fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01052ff:	8b 50 04             	mov    0x4(%eax),%edx
c0105302:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105305:	89 10                	mov    %edx,(%eax)
	free_area[i].nr_free=0;
c0105307:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010530a:	89 d0                	mov    %edx,%eax
c010530c:	01 c0                	add    %eax,%eax
c010530e:	01 d0                	add    %edx,%eax
c0105310:	c1 e0 02             	shl    $0x2,%eax
c0105313:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105318:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     for(int i=0;i<=MAXLEVEL;i++){
c010531e:	ff 45 fc             	incl   -0x4(%ebp)
c0105321:	83 7d fc 0c          	cmpl   $0xc,-0x4(%ebp)
c0105325:	7e b8                	jle    c01052df <buddy_init+0xf>
     }
}
c0105327:	90                   	nop
c0105328:	c9                   	leave  
c0105329:	c3                   	ret    

c010532a <buddy_nr_free_page>:

static size_t
buddy_nr_free_page(void){
c010532a:	55                   	push   %ebp
c010532b:	89 e5                	mov    %esp,%ebp
c010532d:	83 ec 10             	sub    $0x10,%esp
    size_t nr=0;
c0105330:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
c0105337:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
c010533e:	eb 1c                	jmp    c010535c <buddy_nr_free_page+0x32>
	nr+=free_area[i].nr_free*(1<<MAXLEVEL);
c0105340:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105343:	89 d0                	mov    %edx,%eax
c0105345:	01 c0                	add    %eax,%eax
c0105347:	01 d0                	add    %edx,%eax
c0105349:	c1 e0 02             	shl    $0x2,%eax
c010534c:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105351:	8b 00                	mov    (%eax),%eax
c0105353:	c1 e0 0c             	shl    $0xc,%eax
c0105356:	01 45 fc             	add    %eax,-0x4(%ebp)
    for(int i=0;i<=MAXLEVEL;i++){
c0105359:	ff 45 f8             	incl   -0x8(%ebp)
c010535c:	83 7d f8 0c          	cmpl   $0xc,-0x8(%ebp)
c0105360:	7e de                	jle    c0105340 <buddy_nr_free_page+0x16>
    }
    return nr; 
c0105362:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105365:	c9                   	leave  
c0105366:	c3                   	ret    

c0105367 <buddy_init_memmap>:

static void
buddy_init_memmap(struct Page* base,size_t n){
c0105367:	55                   	push   %ebp
c0105368:	89 e5                	mov    %esp,%ebp
c010536a:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
c010536d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105371:	75 24                	jne    c0105397 <buddy_init_memmap+0x30>
c0105373:	c7 44 24 0c fc 7d 10 	movl   $0xc0107dfc,0xc(%esp)
c010537a:	c0 
c010537b:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0105382:	c0 
c0105383:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
c010538a:	00 
c010538b:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c0105392:	e8 52 b0 ff ff       	call   c01003e9 <__panic>
     struct Page* p=base;
c0105397:	8b 45 08             	mov    0x8(%ebp),%eax
c010539a:	89 45 f4             	mov    %eax,-0xc(%ebp)
     for(;p!=base+n;p++){
c010539d:	eb 7d                	jmp    c010541c <buddy_init_memmap+0xb5>
	assert(PageReserved(p));
c010539f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053a2:	83 c0 04             	add    $0x4,%eax
c01053a5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c01053ac:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01053af:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053b2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01053b5:	0f a3 10             	bt     %edx,(%eax)
c01053b8:	19 c0                	sbb    %eax,%eax
c01053ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01053bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01053c1:	0f 95 c0             	setne  %al
c01053c4:	0f b6 c0             	movzbl %al,%eax
c01053c7:	85 c0                	test   %eax,%eax
c01053c9:	75 24                	jne    c01053ef <buddy_init_memmap+0x88>
c01053cb:	c7 44 24 0c 2c 7e 10 	movl   $0xc0107e2c,0xc(%esp)
c01053d2:	c0 
c01053d3:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c01053da:	c0 
c01053db:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
c01053e2:	00 
c01053e3:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c01053ea:	e8 fa af ff ff       	call   c01003e9 <__panic>
	p->flags=p->property=0;
c01053ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053f2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01053f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053fc:	8b 50 08             	mov    0x8(%eax),%edx
c01053ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105402:	89 50 04             	mov    %edx,0x4(%eax)
	set_page_ref(p,0);
c0105405:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010540c:	00 
c010540d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105410:	89 04 24             	mov    %eax,(%esp)
c0105413:	e8 aa fe ff ff       	call   c01052c2 <set_page_ref>
     for(;p!=base+n;p++){
c0105418:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c010541c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010541f:	89 d0                	mov    %edx,%eax
c0105421:	c1 e0 02             	shl    $0x2,%eax
c0105424:	01 d0                	add    %edx,%eax
c0105426:	c1 e0 02             	shl    $0x2,%eax
c0105429:	89 c2                	mov    %eax,%edx
c010542b:	8b 45 08             	mov    0x8(%ebp),%eax
c010542e:	01 d0                	add    %edx,%eax
c0105430:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105433:	0f 85 66 ff ff ff    	jne    c010539f <buddy_init_memmap+0x38>
     }
     p=base;
c0105439:	8b 45 08             	mov    0x8(%ebp),%eax
c010543c:	89 45 f4             	mov    %eax,-0xc(%ebp)
     size_t temp=n;
c010543f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105442:	89 45 f0             	mov    %eax,-0x10(%ebp)
     int level=MAXLEVEL;
c0105445:	c7 45 ec 0c 00 00 00 	movl   $0xc,-0x14(%ebp)
     while(level>=0){
c010544c:	e9 fd 00 00 00       	jmp    c010554e <buddy_init_memmap+0x1e7>
	for(int i=0;i<temp/(1<<level);i++){
c0105451:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0105458:	e9 c7 00 00 00       	jmp    c0105524 <buddy_init_memmap+0x1bd>
	    struct Page* page=p;
c010545d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105460:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	    page->property=1<<level;
c0105463:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105466:	ba 01 00 00 00       	mov    $0x1,%edx
c010546b:	88 c1                	mov    %al,%cl
c010546d:	d3 e2                	shl    %cl,%edx
c010546f:	89 d0                	mov    %edx,%eax
c0105471:	89 c2                	mov    %eax,%edx
c0105473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105476:	89 50 08             	mov    %edx,0x8(%eax)
	    SetPageProperty(p);
c0105479:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010547c:	83 c0 04             	add    $0x4,%eax
c010547f:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0105486:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105489:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010548c:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010548f:	0f ab 10             	bts    %edx,(%eax)
	    list_add_before(&free_area[level].free_list,&(page->page_link));
c0105492:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105495:	8d 48 0c             	lea    0xc(%eax),%ecx
c0105498:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010549b:	89 d0                	mov    %edx,%eax
c010549d:	01 c0                	add    %eax,%eax
c010549f:	01 d0                	add    %edx,%eax
c01054a1:	c1 e0 02             	shl    $0x2,%eax
c01054a4:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01054a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01054ac:	89 4d d0             	mov    %ecx,-0x30(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01054af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01054b2:	8b 00                	mov    (%eax),%eax
c01054b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01054b7:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01054ba:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01054bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01054c0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
c01054c3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01054c6:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01054c9:	89 10                	mov    %edx,(%eax)
c01054cb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01054ce:	8b 10                	mov    (%eax),%edx
c01054d0:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01054d3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01054d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01054d9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01054dc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01054df:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01054e2:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01054e5:	89 10                	mov    %edx,(%eax)
	    p+=(1<<level);
c01054e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01054ea:	ba 14 00 00 00       	mov    $0x14,%edx
c01054ef:	88 c1                	mov    %al,%cl
c01054f1:	d3 e2                	shl    %cl,%edx
c01054f3:	89 d0                	mov    %edx,%eax
c01054f5:	01 45 f4             	add    %eax,-0xc(%ebp)
	    free_area[level].nr_free++;
c01054f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01054fb:	89 d0                	mov    %edx,%eax
c01054fd:	01 c0                	add    %eax,%eax
c01054ff:	01 d0                	add    %edx,%eax
c0105501:	c1 e0 02             	shl    $0x2,%eax
c0105504:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105509:	8b 00                	mov    (%eax),%eax
c010550b:	8d 48 01             	lea    0x1(%eax),%ecx
c010550e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105511:	89 d0                	mov    %edx,%eax
c0105513:	01 c0                	add    %eax,%eax
c0105515:	01 d0                	add    %edx,%eax
c0105517:	c1 e0 02             	shl    $0x2,%eax
c010551a:	05 28 df 11 c0       	add    $0xc011df28,%eax
c010551f:	89 08                	mov    %ecx,(%eax)
	for(int i=0;i<temp/(1<<level);i++){
c0105521:	ff 45 e8             	incl   -0x18(%ebp)
c0105524:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105527:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010552a:	88 c1                	mov    %al,%cl
c010552c:	d3 ea                	shr    %cl,%edx
c010552e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105531:	39 c2                	cmp    %eax,%edx
c0105533:	0f 87 24 ff ff ff    	ja     c010545d <buddy_init_memmap+0xf6>
	}
	temp = temp % (1 << level);
c0105539:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010553c:	ba 01 00 00 00       	mov    $0x1,%edx
c0105541:	88 c1                	mov    %al,%cl
c0105543:	d3 e2                	shl    %cl,%edx
c0105545:	89 d0                	mov    %edx,%eax
c0105547:	48                   	dec    %eax
c0105548:	21 45 f0             	and    %eax,-0x10(%ebp)
	level--;
c010554b:	ff 4d ec             	decl   -0x14(%ebp)
     while(level>=0){
c010554e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105552:	0f 89 f9 fe ff ff    	jns    c0105451 <buddy_init_memmap+0xea>
     }
}
c0105558:	90                   	nop
c0105559:	c9                   	leave  
c010555a:	c3                   	ret    

c010555b <buddy_my_partial>:

static void
buddy_my_partial(struct Page *base, size_t n, int level) {
c010555b:	55                   	push   %ebp
c010555c:	89 e5                	mov    %esp,%ebp
c010555e:	83 ec 78             	sub    $0x78,%esp
    if (level < 0) return;
c0105561:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105565:	0f 88 20 02 00 00    	js     c010578b <buddy_my_partial+0x230>
    size_t temp = n;
c010556b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010556e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (level >= 0) {
c0105571:	e9 7a 01 00 00       	jmp    c01056f0 <buddy_my_partial+0x195>
        for (int i = 0; i < temp / (1 << level); i++) {
c0105576:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010557d:	e9 44 01 00 00       	jmp    c01056c6 <buddy_my_partial+0x16b>
            base->property = (1 << level);
c0105582:	8b 45 10             	mov    0x10(%ebp),%eax
c0105585:	ba 01 00 00 00       	mov    $0x1,%edx
c010558a:	88 c1                	mov    %al,%cl
c010558c:	d3 e2                	shl    %cl,%edx
c010558e:	89 d0                	mov    %edx,%eax
c0105590:	89 c2                	mov    %eax,%edx
c0105592:	8b 45 08             	mov    0x8(%ebp),%eax
c0105595:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(base);
c0105598:	8b 45 08             	mov    0x8(%ebp),%eax
c010559b:	83 c0 04             	add    $0x4,%eax
c010559e:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c01055a5:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01055a8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01055ab:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01055ae:	0f ab 10             	bts    %edx,(%eax)
            // add pages in order
            struct Page* p = NULL;
c01055b1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
            list_entry_t* le = list_next(&(free_area[level].free_list));
c01055b8:	8b 55 10             	mov    0x10(%ebp),%edx
c01055bb:	89 d0                	mov    %edx,%eax
c01055bd:	01 c0                	add    %eax,%eax
c01055bf:	01 d0                	add    %edx,%eax
c01055c1:	c1 e0 02             	shl    $0x2,%eax
c01055c4:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01055c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return listelm->next;
c01055cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01055cf:	8b 40 04             	mov    0x4(%eax),%eax
c01055d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01055d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return listelm->prev;
c01055db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01055de:	8b 00                	mov    (%eax),%eax
            list_entry_t* bfle = list_prev(le);
c01055e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
            while (le != &(free_area[level].free_list)) {
c01055e3:	eb 37                	jmp    c010561c <buddy_my_partial+0xc1>
                p = le2page(le, page_link);
c01055e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055e8:	83 e8 0c             	sub    $0xc,%eax
c01055eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
                if (base + base->property < le) break;
c01055ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f1:	8b 50 08             	mov    0x8(%eax),%edx
c01055f4:	89 d0                	mov    %edx,%eax
c01055f6:	c1 e0 02             	shl    $0x2,%eax
c01055f9:	01 d0                	add    %edx,%eax
c01055fb:	c1 e0 02             	shl    $0x2,%eax
c01055fe:	89 c2                	mov    %eax,%edx
c0105600:	8b 45 08             	mov    0x8(%ebp),%eax
c0105603:	01 d0                	add    %edx,%eax
c0105605:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105608:	77 2a                	ja     c0105634 <buddy_my_partial+0xd9>
                bfle = bfle->next;
c010560a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010560d:	8b 40 04             	mov    0x4(%eax),%eax
c0105610:	89 45 e8             	mov    %eax,-0x18(%ebp)
                le = le->next;
c0105613:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105616:	8b 40 04             	mov    0x4(%eax),%eax
c0105619:	89 45 ec             	mov    %eax,-0x14(%ebp)
            while (le != &(free_area[level].free_list)) {
c010561c:	8b 55 10             	mov    0x10(%ebp),%edx
c010561f:	89 d0                	mov    %edx,%eax
c0105621:	01 c0                	add    %eax,%eax
c0105623:	01 d0                	add    %edx,%eax
c0105625:	c1 e0 02             	shl    $0x2,%eax
c0105628:	05 20 df 11 c0       	add    $0xc011df20,%eax
c010562d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105630:	75 b3                	jne    c01055e5 <buddy_my_partial+0x8a>
c0105632:	eb 01                	jmp    c0105635 <buddy_my_partial+0xda>
                if (base + base->property < le) break;
c0105634:	90                   	nop
            }
            list_add(bfle, &(base->page_link));
c0105635:	8b 45 08             	mov    0x8(%ebp),%eax
c0105638:	8d 50 0c             	lea    0xc(%eax),%edx
c010563b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010563e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0105641:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0105644:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105647:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010564a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010564d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    __list_add(elm, listelm, listelm->next);
c0105650:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105653:	8b 40 04             	mov    0x4(%eax),%eax
c0105656:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0105659:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c010565c:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010565f:	89 55 b0             	mov    %edx,-0x50(%ebp)
c0105662:	89 45 ac             	mov    %eax,-0x54(%ebp)
    prev->next = next->prev = elm;
c0105665:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105668:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010566b:	89 10                	mov    %edx,(%eax)
c010566d:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105670:	8b 10                	mov    (%eax),%edx
c0105672:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105675:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105678:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010567b:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010567e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105681:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105684:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0105687:	89 10                	mov    %edx,(%eax)
            base += (1 << level);
c0105689:	8b 45 10             	mov    0x10(%ebp),%eax
c010568c:	ba 14 00 00 00       	mov    $0x14,%edx
c0105691:	88 c1                	mov    %al,%cl
c0105693:	d3 e2                	shl    %cl,%edx
c0105695:	89 d0                	mov    %edx,%eax
c0105697:	01 45 08             	add    %eax,0x8(%ebp)
            free_area[level].nr_free++;
c010569a:	8b 55 10             	mov    0x10(%ebp),%edx
c010569d:	89 d0                	mov    %edx,%eax
c010569f:	01 c0                	add    %eax,%eax
c01056a1:	01 d0                	add    %edx,%eax
c01056a3:	c1 e0 02             	shl    $0x2,%eax
c01056a6:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01056ab:	8b 00                	mov    (%eax),%eax
c01056ad:	8d 48 01             	lea    0x1(%eax),%ecx
c01056b0:	8b 55 10             	mov    0x10(%ebp),%edx
c01056b3:	89 d0                	mov    %edx,%eax
c01056b5:	01 c0                	add    %eax,%eax
c01056b7:	01 d0                	add    %edx,%eax
c01056b9:	c1 e0 02             	shl    $0x2,%eax
c01056bc:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01056c1:	89 08                	mov    %ecx,(%eax)
        for (int i = 0; i < temp / (1 << level); i++) {
c01056c3:	ff 45 f0             	incl   -0x10(%ebp)
c01056c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01056c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01056cc:	88 c1                	mov    %al,%cl
c01056ce:	d3 ea                	shr    %cl,%edx
c01056d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056d3:	39 c2                	cmp    %eax,%edx
c01056d5:	0f 87 a7 fe ff ff    	ja     c0105582 <buddy_my_partial+0x27>
        }
        temp = temp % (1 << level);
c01056db:	8b 45 10             	mov    0x10(%ebp),%eax
c01056de:	ba 01 00 00 00       	mov    $0x1,%edx
c01056e3:	88 c1                	mov    %al,%cl
c01056e5:	d3 e2                	shl    %cl,%edx
c01056e7:	89 d0                	mov    %edx,%eax
c01056e9:	48                   	dec    %eax
c01056ea:	21 45 f4             	and    %eax,-0xc(%ebp)
        level--;
c01056ed:	ff 4d 10             	decl   0x10(%ebp)
    while (level >= 0) {
c01056f0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01056f4:	0f 89 7c fe ff ff    	jns    c0105576 <buddy_my_partial+0x1b>
    }
    cprintf("alloc_page check: \n");
c01056fa:	c7 04 24 3c 7e 10 c0 	movl   $0xc0107e3c,(%esp)
c0105701:	e8 8c ab ff ff       	call   c0100292 <cprintf>
    for (int i = MAXLEVEL; i >= 0; i--) {
c0105706:	c7 45 e4 0c 00 00 00 	movl   $0xc,-0x1c(%ebp)
c010570d:	eb 74                	jmp    c0105783 <buddy_my_partial+0x228>
        list_entry_t* le = list_next(&(free_area[i].free_list));
c010570f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105712:	89 d0                	mov    %edx,%eax
c0105714:	01 c0                	add    %eax,%eax
c0105716:	01 d0                	add    %edx,%eax
c0105718:	c1 e0 02             	shl    $0x2,%eax
c010571b:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105720:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return listelm->next;
c0105723:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105726:	8b 40 04             	mov    0x4(%eax),%eax
c0105729:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
c010572c:	eb 3c                	jmp    c010576a <buddy_my_partial+0x20f>
            struct Page* page = le2page(le, page_link);
c010572e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105731:	83 e8 0c             	sub    $0xc,%eax
c0105734:	89 45 dc             	mov    %eax,-0x24(%ebp)
            cprintf("%d - %llx\n", i, page->page_link);
c0105737:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010573a:	8b 50 10             	mov    0x10(%eax),%edx
c010573d:	8b 40 0c             	mov    0xc(%eax),%eax
c0105740:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105744:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105748:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010574b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010574f:	c7 04 24 50 7e 10 c0 	movl   $0xc0107e50,(%esp)
c0105756:	e8 37 ab ff ff       	call   c0100292 <cprintf>
c010575b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010575e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0105761:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105764:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
c0105767:	89 45 e0             	mov    %eax,-0x20(%ebp)
        while (le != &(free_area[i].free_list)) {
c010576a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010576d:	89 d0                	mov    %edx,%eax
c010576f:	01 c0                	add    %eax,%eax
c0105771:	01 d0                	add    %edx,%eax
c0105773:	c1 e0 02             	shl    $0x2,%eax
c0105776:	05 20 df 11 c0       	add    $0xc011df20,%eax
c010577b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010577e:	75 ae                	jne    c010572e <buddy_my_partial+0x1d3>
    for (int i = MAXLEVEL; i >= 0; i--) {
c0105780:	ff 4d e4             	decl   -0x1c(%ebp)
c0105783:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105787:	79 86                	jns    c010570f <buddy_my_partial+0x1b4>
c0105789:	eb 01                	jmp    c010578c <buddy_my_partial+0x231>
    if (level < 0) return;
c010578b:	90                   	nop
        }
    }
}
c010578c:	c9                   	leave  
c010578d:	c3                   	ret    

c010578e <buddy_my_merge>:

static void
buddy_my_merge(int level) {
c010578e:	55                   	push   %ebp
c010578f:	89 e5                	mov    %esp,%ebp
c0105791:	83 ec 68             	sub    $0x68,%esp
    cprintf("before merge.\n");
c0105794:	c7 04 24 5b 7e 10 c0 	movl   $0xc0107e5b,(%esp)
c010579b:	e8 f2 aa ff ff       	call   c0100292 <cprintf>
    //bds_selfcheck();
    while (level < MAXLEVEL) {
c01057a0:	e9 dc 01 00 00       	jmp    c0105981 <buddy_my_merge+0x1f3>
        if (free_area[level].nr_free <= 1) {
c01057a5:	8b 55 08             	mov    0x8(%ebp),%edx
c01057a8:	89 d0                	mov    %edx,%eax
c01057aa:	01 c0                	add    %eax,%eax
c01057ac:	01 d0                	add    %edx,%eax
c01057ae:	c1 e0 02             	shl    $0x2,%eax
c01057b1:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01057b6:	8b 00                	mov    (%eax),%eax
c01057b8:	83 f8 01             	cmp    $0x1,%eax
c01057bb:	77 08                	ja     c01057c5 <buddy_my_merge+0x37>
            level++;
c01057bd:	ff 45 08             	incl   0x8(%ebp)
            continue;
c01057c0:	e9 bc 01 00 00       	jmp    c0105981 <buddy_my_merge+0x1f3>
        }
        list_entry_t* le = list_next(&(free_area[level].free_list));
c01057c5:	8b 55 08             	mov    0x8(%ebp),%edx
c01057c8:	89 d0                	mov    %edx,%eax
c01057ca:	01 c0                	add    %eax,%eax
c01057cc:	01 d0                	add    %edx,%eax
c01057ce:	c1 e0 02             	shl    $0x2,%eax
c01057d1:	05 20 df 11 c0       	add    $0xc011df20,%eax
c01057d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01057d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057dc:	8b 40 04             	mov    0x4(%eax),%eax
c01057df:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01057e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->prev;
c01057e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057eb:	8b 00                	mov    (%eax),%eax
        list_entry_t* bfle = list_prev(le);
c01057ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while (le != &(free_area[level].free_list)) {
c01057f0:	e9 6f 01 00 00       	jmp    c0105964 <buddy_my_merge+0x1d6>
c01057f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return listelm->next;
c01057fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01057fe:	8b 40 04             	mov    0x4(%eax),%eax
            bfle = list_next(bfle);
c0105801:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105804:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105807:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010580a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010580d:	8b 40 04             	mov    0x4(%eax),%eax
            le = list_next(le);
c0105810:	89 45 f4             	mov    %eax,-0xc(%ebp)
            struct Page* ple = le2page(le, page_link);
c0105813:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105816:	83 e8 0c             	sub    $0xc,%eax
c0105819:	89 45 ec             	mov    %eax,-0x14(%ebp)
            struct Page* pbf = le2page(bfle, page_link); 
c010581c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010581f:	83 e8 0c             	sub    $0xc,%eax
c0105822:	89 45 e8             	mov    %eax,-0x18(%ebp)
            cprintf("bfle addr is: %llx\n", pbf->page_link);
c0105825:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105828:	8b 50 10             	mov    0x10(%eax),%edx
c010582b:	8b 40 0c             	mov    0xc(%eax),%eax
c010582e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105832:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105836:	c7 04 24 6a 7e 10 c0 	movl   $0xc0107e6a,(%esp)
c010583d:	e8 50 aa ff ff       	call   c0100292 <cprintf>
            cprintf("le addr is: %llx\n", ple->page_link);
c0105842:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105845:	8b 50 10             	mov    0x10(%eax),%edx
c0105848:	8b 40 0c             	mov    0xc(%eax),%eax
c010584b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010584f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105853:	c7 04 24 7e 7e 10 c0 	movl   $0xc0107e7e,(%esp)
c010585a:	e8 33 aa ff ff       	call   c0100292 <cprintf>
            if (pbf + pbf->property == ple) {            
c010585f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105862:	8b 50 08             	mov    0x8(%eax),%edx
c0105865:	89 d0                	mov    %edx,%eax
c0105867:	c1 e0 02             	shl    $0x2,%eax
c010586a:	01 d0                	add    %edx,%eax
c010586c:	c1 e0 02             	shl    $0x2,%eax
c010586f:	89 c2                	mov    %eax,%edx
c0105871:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105874:	01 d0                	add    %edx,%eax
c0105876:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105879:	0f 85 e5 00 00 00    	jne    c0105964 <buddy_my_merge+0x1d6>
c010587f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105882:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0105885:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105888:	8b 40 04             	mov    0x4(%eax),%eax
                bfle = list_next(bfle);
c010588b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010588e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105891:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0105894:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105897:	8b 40 04             	mov    0x4(%eax),%eax
                le = list_next(le);
c010589a:	89 45 f4             	mov    %eax,-0xc(%ebp)
                pbf->property = pbf->property << 1;
c010589d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058a0:	8b 40 08             	mov    0x8(%eax),%eax
c01058a3:	8d 14 00             	lea    (%eax,%eax,1),%edx
c01058a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058a9:	89 50 08             	mov    %edx,0x8(%eax)
                ClearPageProperty(ple);
c01058ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058af:	83 c0 04             	add    $0x4,%eax
c01058b2:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c01058b9:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01058bc:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01058bf:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01058c2:	0f b3 10             	btr    %edx,(%eax)
                list_del(&(pbf->page_link));
c01058c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058c8:	83 c0 0c             	add    $0xc,%eax
c01058cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_del(listelm->prev, listelm->next);
c01058ce:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01058d1:	8b 40 04             	mov    0x4(%eax),%eax
c01058d4:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01058d7:	8b 12                	mov    (%edx),%edx
c01058d9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c01058dc:	89 45 c0             	mov    %eax,-0x40(%ebp)
    prev->next = next;
c01058df:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01058e2:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01058e5:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01058e8:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01058eb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01058ee:	89 10                	mov    %edx,(%eax)
                list_del(&(ple->page_link));
c01058f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058f3:	83 c0 0c             	add    $0xc,%eax
c01058f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01058f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01058fc:	8b 40 04             	mov    0x4(%eax),%eax
c01058ff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105902:	8b 12                	mov    (%edx),%edx
c0105904:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0105907:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next;
c010590a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010590d:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105910:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105913:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105916:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105919:	89 10                	mov    %edx,(%eax)
                buddy_my_partial(pbf, pbf->property, level + 1);             
c010591b:	8b 45 08             	mov    0x8(%ebp),%eax
c010591e:	8d 50 01             	lea    0x1(%eax),%edx
c0105921:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105924:	8b 40 08             	mov    0x8(%eax),%eax
c0105927:	89 54 24 08          	mov    %edx,0x8(%esp)
c010592b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010592f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105932:	89 04 24             	mov    %eax,(%esp)
c0105935:	e8 21 fc ff ff       	call   c010555b <buddy_my_partial>
                free_area[level].nr_free -= 2;              
c010593a:	8b 55 08             	mov    0x8(%ebp),%edx
c010593d:	89 d0                	mov    %edx,%eax
c010593f:	01 c0                	add    %eax,%eax
c0105941:	01 d0                	add    %edx,%eax
c0105943:	c1 e0 02             	shl    $0x2,%eax
c0105946:	05 28 df 11 c0       	add    $0xc011df28,%eax
c010594b:	8b 00                	mov    (%eax),%eax
c010594d:	8d 48 fe             	lea    -0x2(%eax),%ecx
c0105950:	8b 55 08             	mov    0x8(%ebp),%edx
c0105953:	89 d0                	mov    %edx,%eax
c0105955:	01 c0                	add    %eax,%eax
c0105957:	01 d0                	add    %edx,%eax
c0105959:	c1 e0 02             	shl    $0x2,%eax
c010595c:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105961:	89 08                	mov    %ecx,(%eax)
                continue;
c0105963:	90                   	nop
        while (le != &(free_area[level].free_list)) {
c0105964:	8b 55 08             	mov    0x8(%ebp),%edx
c0105967:	89 d0                	mov    %edx,%eax
c0105969:	01 c0                	add    %eax,%eax
c010596b:	01 d0                	add    %edx,%eax
c010596d:	c1 e0 02             	shl    $0x2,%eax
c0105970:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105975:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105978:	0f 85 77 fe ff ff    	jne    c01057f5 <buddy_my_merge+0x67>
            } 
        }
        level++;
c010597e:	ff 45 08             	incl   0x8(%ebp)
    while (level < MAXLEVEL) {
c0105981:	83 7d 08 0b          	cmpl   $0xb,0x8(%ebp)
c0105985:	0f 8e 1a fe ff ff    	jle    c01057a5 <buddy_my_merge+0x17>
    }
    //bds_selfcheck();
}
c010598b:	90                   	nop
c010598c:	c9                   	leave  
c010598d:	c3                   	ret    

c010598e <buddy_alloc_page>:

static struct Page*
buddy_alloc_page(size_t n){
c010598e:	55                   	push   %ebp
c010598f:	89 e5                	mov    %esp,%ebp
c0105991:	83 ec 58             	sub    $0x58,%esp
     assert(n>0);
c0105994:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105998:	75 24                	jne    c01059be <buddy_alloc_page+0x30>
c010599a:	c7 44 24 0c fc 7d 10 	movl   $0xc0107dfc,0xc(%esp)
c01059a1:	c0 
c01059a2:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c01059a9:	c0 
c01059aa:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c01059b1:	00 
c01059b2:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c01059b9:	e8 2b aa ff ff       	call   c01003e9 <__panic>
     if(n>buddy_nr_free_page()){
c01059be:	e8 67 f9 ff ff       	call   c010532a <buddy_nr_free_page>
c01059c3:	39 45 08             	cmp    %eax,0x8(%ebp)
c01059c6:	76 0a                	jbe    c01059d2 <buddy_alloc_page+0x44>
	return NULL;
c01059c8:	b8 00 00 00 00       	mov    $0x0,%eax
c01059cd:	e9 62 01 00 00       	jmp    c0105b34 <buddy_alloc_page+0x1a6>
     }
     int level=0;
c01059d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     while((1<<level)<n){
c01059d9:	eb 03                	jmp    c01059de <buddy_alloc_page+0x50>
	level++;
c01059db:	ff 45 f4             	incl   -0xc(%ebp)
     while((1<<level)<n){
c01059de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059e1:	ba 01 00 00 00       	mov    $0x1,%edx
c01059e6:	88 c1                	mov    %al,%cl
c01059e8:	d3 e2                	shl    %cl,%edx
c01059ea:	89 d0                	mov    %edx,%eax
c01059ec:	39 45 08             	cmp    %eax,0x8(%ebp)
c01059ef:	77 ea                	ja     c01059db <buddy_alloc_page+0x4d>
     }
     //n=1<<level;
     for(int i=level;i<=MAXLEVEL;i++){
c01059f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059f7:	eb 22                	jmp    c0105a1b <buddy_alloc_page+0x8d>
	if(free_area[i].nr_free!=0){
c01059f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01059fc:	89 d0                	mov    %edx,%eax
c01059fe:	01 c0                	add    %eax,%eax
c0105a00:	01 d0                	add    %edx,%eax
c0105a02:	c1 e0 02             	shl    $0x2,%eax
c0105a05:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105a0a:	8b 00                	mov    (%eax),%eax
c0105a0c:	85 c0                	test   %eax,%eax
c0105a0e:	74 08                	je     c0105a18 <buddy_alloc_page+0x8a>
	   level=i;
c0105a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    break;
c0105a16:	eb 09                	jmp    c0105a21 <buddy_alloc_page+0x93>
     for(int i=level;i<=MAXLEVEL;i++){
c0105a18:	ff 45 f0             	incl   -0x10(%ebp)
c0105a1b:	83 7d f0 0c          	cmpl   $0xc,-0x10(%ebp)
c0105a1f:	7e d8                	jle    c01059f9 <buddy_alloc_page+0x6b>
	}
     }
     if(level>MAXLEVEL){return NULL;}
c0105a21:	83 7d f4 0c          	cmpl   $0xc,-0xc(%ebp)
c0105a25:	7e 0a                	jle    c0105a31 <buddy_alloc_page+0xa3>
c0105a27:	b8 00 00 00 00       	mov    $0x0,%eax
c0105a2c:	e9 03 01 00 00       	jmp    c0105b34 <buddy_alloc_page+0x1a6>
     list_entry_t *le=&free_area[level].free_list;
c0105a31:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a34:	89 d0                	mov    %edx,%eax
c0105a36:	01 c0                	add    %eax,%eax
c0105a38:	01 d0                	add    %edx,%eax
c0105a3a:	c1 e0 02             	shl    $0x2,%eax
c0105a3d:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105a42:	89 45 ec             	mov    %eax,-0x14(%ebp)
     struct Page* page=le2page(le,page_link);
c0105a45:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a48:	83 e8 0c             	sub    $0xc,%eax
c0105a4b:	89 45 e8             	mov    %eax,-0x18(%ebp)
     if (page != NULL) {
c0105a4e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105a52:	0f 84 cd 00 00 00    	je     c0105b25 <buddy_alloc_page+0x197>
        SetPageReserved(page);
c0105a58:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a5b:	83 c0 04             	add    $0x4,%eax
c0105a5e:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
c0105a65:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105a68:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105a6b:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105a6e:	0f ab 10             	bts    %edx,(%eax)
        // deal with partial work
        buddy_my_partial(page, page->property - n, level - 1);
c0105a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a74:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105a77:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a7a:	8b 40 08             	mov    0x8(%eax),%eax
c0105a7d:	2b 45 08             	sub    0x8(%ebp),%eax
c0105a80:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105a84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a88:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a8b:	89 04 24             	mov    %eax,(%esp)
c0105a8e:	e8 c8 fa ff ff       	call   c010555b <buddy_my_partial>
        ClearPageReserved(page);
c0105a93:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a96:	83 c0 04             	add    $0x4,%eax
c0105a99:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
c0105aa0:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105aa3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105aa6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105aa9:	0f b3 10             	btr    %edx,(%eax)
        ClearPageProperty(page);
c0105aac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105aaf:	83 c0 04             	add    $0x4,%eax
c0105ab2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
c0105ab9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105abc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105abf:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105ac2:	0f b3 10             	btr    %edx,(%eax)
        list_del(&(page->page_link));
c0105ac5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ac8:	83 c0 0c             	add    $0xc,%eax
c0105acb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105ace:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ad1:	8b 40 04             	mov    0x4(%eax),%eax
c0105ad4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105ad7:	8b 12                	mov    (%edx),%edx
c0105ad9:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0105adc:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c0105adf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ae2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105ae5:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105ae8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105aeb:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105aee:	89 10                	mov    %edx,(%eax)
        free_area[level].nr_free--;
c0105af0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105af3:	89 d0                	mov    %edx,%eax
c0105af5:	01 c0                	add    %eax,%eax
c0105af7:	01 d0                	add    %edx,%eax
c0105af9:	c1 e0 02             	shl    $0x2,%eax
c0105afc:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105b01:	8b 00                	mov    (%eax),%eax
c0105b03:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105b06:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b09:	89 d0                	mov    %edx,%eax
c0105b0b:	01 c0                	add    %eax,%eax
c0105b0d:	01 d0                	add    %edx,%eax
c0105b0f:	c1 e0 02             	shl    $0x2,%eax
c0105b12:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105b17:	89 08                	mov    %ecx,(%eax)
        buddy_my_merge(0);
c0105b19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105b20:	e8 69 fc ff ff       	call   c010578e <buddy_my_merge>
    }
    cprintf("after allocate & merge\n");
c0105b25:	c7 04 24 90 7e 10 c0 	movl   $0xc0107e90,(%esp)
c0105b2c:	e8 61 a7 ff ff       	call   c0100292 <cprintf>
    //bds_selfcheck();
    return page;
c0105b31:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
c0105b34:	c9                   	leave  
c0105b35:	c3                   	ret    

c0105b36 <buddy_free_page>:

static void 
buddy_free_page(struct Page* base, size_t n){
c0105b36:	55                   	push   %ebp
c0105b37:	89 e5                	mov    %esp,%ebp
c0105b39:	83 ec 48             	sub    $0x48,%esp
     assert(n > 0);
c0105b3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105b40:	75 24                	jne    c0105b66 <buddy_free_page+0x30>
c0105b42:	c7 44 24 0c a8 7e 10 	movl   $0xc0107ea8,0xc(%esp)
c0105b49:	c0 
c0105b4a:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0105b51:	c0 
c0105b52:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0105b59:	00 
c0105b5a:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c0105b61:	e8 83 a8 ff ff       	call   c01003e9 <__panic>
    struct Page* p = base;
c0105b66:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b69:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++) {
c0105b6c:	e9 9d 00 00 00       	jmp    c0105c0e <buddy_free_page+0xd8>
        assert(!PageReserved(p) && !PageProperty(p));
c0105b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b74:	83 c0 04             	add    $0x4,%eax
c0105b77:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105b7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105b81:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b84:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105b87:	0f a3 10             	bt     %edx,(%eax)
c0105b8a:	19 c0                	sbb    %eax,%eax
c0105b8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0105b8f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105b93:	0f 95 c0             	setne  %al
c0105b96:	0f b6 c0             	movzbl %al,%eax
c0105b99:	85 c0                	test   %eax,%eax
c0105b9b:	75 2c                	jne    c0105bc9 <buddy_free_page+0x93>
c0105b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ba0:	83 c0 04             	add    $0x4,%eax
c0105ba3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0105baa:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105bad:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105bb0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105bb3:	0f a3 10             	bt     %edx,(%eax)
c0105bb6:	19 c0                	sbb    %eax,%eax
c0105bb8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0105bbb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105bbf:	0f 95 c0             	setne  %al
c0105bc2:	0f b6 c0             	movzbl %al,%eax
c0105bc5:	85 c0                	test   %eax,%eax
c0105bc7:	74 24                	je     c0105bed <buddy_free_page+0xb7>
c0105bc9:	c7 44 24 0c b0 7e 10 	movl   $0xc0107eb0,0xc(%esp)
c0105bd0:	c0 
c0105bd1:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0105bd8:	c0 
c0105bd9:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
c0105be0:	00 
c0105be1:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c0105be8:	e8 fc a7 ff ff       	call   c01003e9 <__panic>
        p->flags = 0;
c0105bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bf0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0105bf7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105bfe:	00 
c0105bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c02:	89 04 24             	mov    %eax,(%esp)
c0105c05:	e8 b8 f6 ff ff       	call   c01052c2 <set_page_ref>
    for (; p != base + n; p++) {
c0105c0a:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0105c0e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105c11:	89 d0                	mov    %edx,%eax
c0105c13:	c1 e0 02             	shl    $0x2,%eax
c0105c16:	01 d0                	add    %edx,%eax
c0105c18:	c1 e0 02             	shl    $0x2,%eax
c0105c1b:	89 c2                	mov    %eax,%edx
c0105c1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c20:	01 d0                	add    %edx,%eax
c0105c22:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105c25:	0f 85 46 ff ff ff    	jne    c0105b71 <buddy_free_page+0x3b>
    }
    // free pages
    base->property = n;
c0105c2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c2e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105c31:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0105c34:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c37:	83 c0 04             	add    $0x4,%eax
c0105c3a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0105c41:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105c44:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105c47:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105c4a:	0f ab 10             	bts    %edx,(%eax)
    int level = 0;
c0105c4d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    while ((1 << level) != n) { level++; }
c0105c54:	eb 03                	jmp    c0105c59 <buddy_free_page+0x123>
c0105c56:	ff 45 f0             	incl   -0x10(%ebp)
c0105c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c5c:	ba 01 00 00 00       	mov    $0x1,%edx
c0105c61:	88 c1                	mov    %al,%cl
c0105c63:	d3 e2                	shl    %cl,%edx
c0105c65:	89 d0                	mov    %edx,%eax
c0105c67:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0105c6a:	75 ea                	jne    c0105c56 <buddy_free_page+0x120>
    buddy_my_partial(base, n, level);
c0105c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c6f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105c73:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c7d:	89 04 24             	mov    %eax,(%esp)
c0105c80:	e8 d6 f8 ff ff       	call   c010555b <buddy_my_partial>
    //bds_selfcheck();
    free_area[level].nr_free++;
c0105c85:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105c88:	89 d0                	mov    %edx,%eax
c0105c8a:	01 c0                	add    %eax,%eax
c0105c8c:	01 d0                	add    %edx,%eax
c0105c8e:	c1 e0 02             	shl    $0x2,%eax
c0105c91:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105c96:	8b 00                	mov    (%eax),%eax
c0105c98:	8d 48 01             	lea    0x1(%eax),%ecx
c0105c9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105c9e:	89 d0                	mov    %edx,%eax
c0105ca0:	01 c0                	add    %eax,%eax
c0105ca2:	01 d0                	add    %edx,%eax
c0105ca4:	c1 e0 02             	shl    $0x2,%eax
c0105ca7:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0105cac:	89 08                	mov    %ecx,(%eax)
    buddy_my_merge(level); 
c0105cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cb1:	89 04 24             	mov    %eax,(%esp)
c0105cb4:	e8 d5 fa ff ff       	call   c010578e <buddy_my_merge>
    //buddy_selfcheck();
}
c0105cb9:	90                   	nop
c0105cba:	c9                   	leave  
c0105cbb:	c3                   	ret    

c0105cbc <buddy_check>:

static void
buddy_check(void) {
c0105cbc:	55                   	push   %ebp
c0105cbd:	89 e5                	mov    %esp,%ebp
c0105cbf:	81 ec f8 00 00 00    	sub    $0xf8,%esp
    int count = 0, total = 0;
c0105cc5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105ccc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) {
c0105cd3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105cda:	e9 a4 00 00 00       	jmp    c0105d83 <buddy_check+0xc7>
        list_entry_t* free_list = &(free_area[i].free_list);
c0105cdf:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105ce2:	89 d0                	mov    %edx,%eax
c0105ce4:	01 c0                	add    %eax,%eax
c0105ce6:	01 d0                	add    %edx,%eax
c0105ce8:	c1 e0 02             	shl    $0x2,%eax
c0105ceb:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0105cf0:	89 45 d0             	mov    %eax,-0x30(%ebp)
        list_entry_t* le = free_list;
c0105cf3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105cf6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        while ((le = list_next(le)) != free_list) {
c0105cf9:	eb 6a                	jmp    c0105d65 <buddy_check+0xa9>
            struct Page* p = le2page(le, page_link);
c0105cfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105cfe:	83 e8 0c             	sub    $0xc,%eax
c0105d01:	89 45 cc             	mov    %eax,-0x34(%ebp)
            assert(PageProperty(p));
c0105d04:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105d07:	83 c0 04             	add    $0x4,%eax
c0105d0a:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0105d11:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105d14:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105d17:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105d1a:	0f a3 10             	bt     %edx,(%eax)
c0105d1d:	19 c0                	sbb    %eax,%eax
c0105d1f:	89 45 c0             	mov    %eax,-0x40(%ebp)
    return oldbit != 0;
c0105d22:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0105d26:	0f 95 c0             	setne  %al
c0105d29:	0f b6 c0             	movzbl %al,%eax
c0105d2c:	85 c0                	test   %eax,%eax
c0105d2e:	75 24                	jne    c0105d54 <buddy_check+0x98>
c0105d30:	c7 44 24 0c d5 7e 10 	movl   $0xc0107ed5,0xc(%esp)
c0105d37:	c0 
c0105d38:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0105d3f:	c0 
c0105d40:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0105d47:	00 
c0105d48:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c0105d4f:	e8 95 a6 ff ff       	call   c01003e9 <__panic>
            count++;
c0105d54:	ff 45 f4             	incl   -0xc(%ebp)
            total += p->property;
c0105d57:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105d5a:	8b 50 08             	mov    0x8(%eax),%edx
c0105d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d60:	01 d0                	add    %edx,%eax
c0105d62:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d65:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d68:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return listelm->next;
c0105d6b:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105d6e:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != free_list) {
c0105d71:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105d74:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d77:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105d7a:	0f 85 7b ff ff ff    	jne    c0105cfb <buddy_check+0x3f>
    for (int i = 0; i <= MAXLEVEL; i++) {
c0105d80:	ff 45 ec             	incl   -0x14(%ebp)
c0105d83:	83 7d ec 0c          	cmpl   $0xc,-0x14(%ebp)
c0105d87:	0f 8e 52 ff ff ff    	jle    c0105cdf <buddy_check+0x23>
        }
    }
    assert(total == buddy_nr_free_page());
c0105d8d:	e8 98 f5 ff ff       	call   c010532a <buddy_nr_free_page>
c0105d92:	89 c2                	mov    %eax,%edx
c0105d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d97:	39 c2                	cmp    %eax,%edx
c0105d99:	74 24                	je     c0105dbf <buddy_check+0x103>
c0105d9b:	c7 44 24 0c e5 7e 10 	movl   $0xc0107ee5,0xc(%esp)
c0105da2:	c0 
c0105da3:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0105daa:	c0 
c0105dab:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0105db2:	00 
c0105db3:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c0105dba:	e8 2a a6 ff ff       	call   c01003e9 <__panic>

    // basic check
    struct Page *p0, *p1, *p2;
    p0 = p1 =p2 = NULL;
c0105dbf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105dc6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105dc9:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105dcc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105dcf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("p0\n");
c0105dd2:	c7 04 24 03 7f 10 c0 	movl   $0xc0107f03,(%esp)
c0105dd9:	e8 b4 a4 ff ff       	call   c0100292 <cprintf>
    assert((p0 = alloc_page()) != NULL);
c0105dde:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105de5:	e8 5f cd ff ff       	call   c0102b49 <alloc_pages>
c0105dea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105ded:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0105df1:	75 24                	jne    c0105e17 <buddy_check+0x15b>
c0105df3:	c7 44 24 0c 07 7f 10 	movl   $0xc0107f07,0xc(%esp)
c0105dfa:	c0 
c0105dfb:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0105e02:	c0 
c0105e03:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c0105e0a:	00 
c0105e0b:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c0105e12:	e8 d2 a5 ff ff       	call   c01003e9 <__panic>
    cprintf("p1\n");
c0105e17:	c7 04 24 23 7f 10 c0 	movl   $0xc0107f23,(%esp)
c0105e1e:	e8 6f a4 ff ff       	call   c0100292 <cprintf>
    assert((p1 = alloc_page()) != NULL);
c0105e23:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e2a:	e8 1a cd ff ff       	call   c0102b49 <alloc_pages>
c0105e2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105e32:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105e36:	75 24                	jne    c0105e5c <buddy_check+0x1a0>
c0105e38:	c7 44 24 0c 27 7f 10 	movl   $0xc0107f27,0xc(%esp)
c0105e3f:	c0 
c0105e40:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0105e47:	c0 
c0105e48:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0105e4f:	00 
c0105e50:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c0105e57:	e8 8d a5 ff ff       	call   c01003e9 <__panic>
    cprintf("p2\n");
c0105e5c:	c7 04 24 43 7f 10 c0 	movl   $0xc0107f43,(%esp)
c0105e63:	e8 2a a4 ff ff       	call   c0100292 <cprintf>
    assert((p2 = alloc_page()) != NULL);
c0105e68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e6f:	e8 d5 cc ff ff       	call   c0102b49 <alloc_pages>
c0105e74:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105e77:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105e7b:	75 24                	jne    c0105ea1 <buddy_check+0x1e5>
c0105e7d:	c7 44 24 0c 47 7f 10 	movl   $0xc0107f47,0xc(%esp)
c0105e84:	c0 
c0105e85:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0105e8c:	c0 
c0105e8d:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0105e94:	00 
c0105e95:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c0105e9c:	e8 48 a5 ff ff       	call   c01003e9 <__panic>

    assert(p0 != p1 && p1 != p2 && p2 != p0);
c0105ea1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105ea4:	3b 45 d8             	cmp    -0x28(%ebp),%eax
c0105ea7:	74 10                	je     c0105eb9 <buddy_check+0x1fd>
c0105ea9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105eac:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0105eaf:	74 08                	je     c0105eb9 <buddy_check+0x1fd>
c0105eb1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105eb4:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0105eb7:	75 24                	jne    c0105edd <buddy_check+0x221>
c0105eb9:	c7 44 24 0c 64 7f 10 	movl   $0xc0107f64,0xc(%esp)
c0105ec0:	c0 
c0105ec1:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0105ec8:	c0 
c0105ec9:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0105ed0:	00 
c0105ed1:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c0105ed8:	e8 0c a5 ff ff       	call   c01003e9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0105edd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105ee0:	89 04 24             	mov    %eax,(%esp)
c0105ee3:	e8 d0 f3 ff ff       	call   c01052b8 <page_ref>
c0105ee8:	85 c0                	test   %eax,%eax
c0105eea:	75 1e                	jne    c0105f0a <buddy_check+0x24e>
c0105eec:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105eef:	89 04 24             	mov    %eax,(%esp)
c0105ef2:	e8 c1 f3 ff ff       	call   c01052b8 <page_ref>
c0105ef7:	85 c0                	test   %eax,%eax
c0105ef9:	75 0f                	jne    c0105f0a <buddy_check+0x24e>
c0105efb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105efe:	89 04 24             	mov    %eax,(%esp)
c0105f01:	e8 b2 f3 ff ff       	call   c01052b8 <page_ref>
c0105f06:	85 c0                	test   %eax,%eax
c0105f08:	74 24                	je     c0105f2e <buddy_check+0x272>
c0105f0a:	c7 44 24 0c 88 7f 10 	movl   $0xc0107f88,0xc(%esp)
c0105f11:	c0 
c0105f12:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0105f19:	c0 
c0105f1a:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0105f21:	00 
c0105f22:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c0105f29:	e8 bb a4 ff ff       	call   c01003e9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0105f2e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105f31:	89 04 24             	mov    %eax,(%esp)
c0105f34:	e8 69 f3 ff ff       	call   c01052a2 <page2pa>
c0105f39:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0105f3f:	c1 e2 0c             	shl    $0xc,%edx
c0105f42:	39 d0                	cmp    %edx,%eax
c0105f44:	72 24                	jb     c0105f6a <buddy_check+0x2ae>
c0105f46:	c7 44 24 0c c4 7f 10 	movl   $0xc0107fc4,0xc(%esp)
c0105f4d:	c0 
c0105f4e:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0105f55:	c0 
c0105f56:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0105f5d:	00 
c0105f5e:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c0105f65:	e8 7f a4 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0105f6a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105f6d:	89 04 24             	mov    %eax,(%esp)
c0105f70:	e8 2d f3 ff ff       	call   c01052a2 <page2pa>
c0105f75:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0105f7b:	c1 e2 0c             	shl    $0xc,%edx
c0105f7e:	39 d0                	cmp    %edx,%eax
c0105f80:	72 24                	jb     c0105fa6 <buddy_check+0x2ea>
c0105f82:	c7 44 24 0c e1 7f 10 	movl   $0xc0107fe1,0xc(%esp)
c0105f89:	c0 
c0105f8a:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0105f91:	c0 
c0105f92:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0105f99:	00 
c0105f9a:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c0105fa1:	e8 43 a4 ff ff       	call   c01003e9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0105fa6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105fa9:	89 04 24             	mov    %eax,(%esp)
c0105fac:	e8 f1 f2 ff ff       	call   c01052a2 <page2pa>
c0105fb1:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0105fb7:	c1 e2 0c             	shl    $0xc,%edx
c0105fba:	39 d0                	cmp    %edx,%eax
c0105fbc:	72 24                	jb     c0105fe2 <buddy_check+0x326>
c0105fbe:	c7 44 24 0c fe 7f 10 	movl   $0xc0107ffe,0xc(%esp)
c0105fc5:	c0 
c0105fc6:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0105fcd:	c0 
c0105fce:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0105fd5:	00 
c0105fd6:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c0105fdd:	e8 07 a4 ff ff       	call   c01003e9 <__panic>
    cprintf("first part of check successfully.\n");
c0105fe2:	c7 04 24 1c 80 10 c0 	movl   $0xc010801c,(%esp)
c0105fe9:	e8 a4 a2 ff ff       	call   c0100292 <cprintf>

    free_area_t temp_list[MAXLEVEL + 1];
    for (int i = 0; i <= MAXLEVEL; i++) {
c0105fee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0105ff5:	e9 c5 00 00 00       	jmp    c01060bf <buddy_check+0x403>
        temp_list[i] = free_area[i];
c0105ffa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105ffd:	89 d0                	mov    %edx,%eax
c0105fff:	01 c0                	add    %eax,%eax
c0106001:	01 d0                	add    %edx,%eax
c0106003:	c1 e0 02             	shl    $0x2,%eax
c0106006:	8d 4d f8             	lea    -0x8(%ebp),%ecx
c0106009:	01 c8                	add    %ecx,%eax
c010600b:	8d 90 20 ff ff ff    	lea    -0xe0(%eax),%edx
c0106011:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c0106014:	89 c8                	mov    %ecx,%eax
c0106016:	01 c0                	add    %eax,%eax
c0106018:	01 c8                	add    %ecx,%eax
c010601a:	c1 e0 02             	shl    $0x2,%eax
c010601d:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0106022:	8b 08                	mov    (%eax),%ecx
c0106024:	89 0a                	mov    %ecx,(%edx)
c0106026:	8b 48 04             	mov    0x4(%eax),%ecx
c0106029:	89 4a 04             	mov    %ecx,0x4(%edx)
c010602c:	8b 40 08             	mov    0x8(%eax),%eax
c010602f:	89 42 08             	mov    %eax,0x8(%edx)
        list_init(&(free_area[i].free_list));
c0106032:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106035:	89 d0                	mov    %edx,%eax
c0106037:	01 c0                	add    %eax,%eax
c0106039:	01 d0                	add    %edx,%eax
c010603b:	c1 e0 02             	shl    $0x2,%eax
c010603e:	05 20 df 11 c0       	add    $0xc011df20,%eax
c0106043:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    elm->prev = elm->next = elm;
c0106046:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106049:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010604c:	89 50 04             	mov    %edx,0x4(%eax)
c010604f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106052:	8b 50 04             	mov    0x4(%eax),%edx
c0106055:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106058:	89 10                	mov    %edx,(%eax)
        assert(list_empty(&(free_area[i])));
c010605a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010605d:	89 d0                	mov    %edx,%eax
c010605f:	01 c0                	add    %eax,%eax
c0106061:	01 d0                	add    %edx,%eax
c0106063:	c1 e0 02             	shl    $0x2,%eax
c0106066:	05 20 df 11 c0       	add    $0xc011df20,%eax
c010606b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return list->next == list;
c010606e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106071:	8b 40 04             	mov    0x4(%eax),%eax
c0106074:	39 45 b8             	cmp    %eax,-0x48(%ebp)
c0106077:	0f 94 c0             	sete   %al
c010607a:	0f b6 c0             	movzbl %al,%eax
c010607d:	85 c0                	test   %eax,%eax
c010607f:	75 24                	jne    c01060a5 <buddy_check+0x3e9>
c0106081:	c7 44 24 0c 3f 80 10 	movl   $0xc010803f,0xc(%esp)
c0106088:	c0 
c0106089:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c0106090:	c0 
c0106091:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0106098:	00 
c0106099:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c01060a0:	e8 44 a3 ff ff       	call   c01003e9 <__panic>
        free_area[i].nr_free = 0;
c01060a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01060a8:	89 d0                	mov    %edx,%eax
c01060aa:	01 c0                	add    %eax,%eax
c01060ac:	01 d0                	add    %edx,%eax
c01060ae:	c1 e0 02             	shl    $0x2,%eax
c01060b1:	05 28 df 11 c0       	add    $0xc011df28,%eax
c01060b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    for (int i = 0; i <= MAXLEVEL; i++) {
c01060bc:	ff 45 e4             	incl   -0x1c(%ebp)
c01060bf:	83 7d e4 0c          	cmpl   $0xc,-0x1c(%ebp)
c01060c3:	0f 8e 31 ff ff ff    	jle    c0105ffa <buddy_check+0x33e>
    }
    assert(alloc_page() == NULL);
c01060c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01060d0:	e8 74 ca ff ff       	call   c0102b49 <alloc_pages>
c01060d5:	85 c0                	test   %eax,%eax
c01060d7:	74 24                	je     c01060fd <buddy_check+0x441>
c01060d9:	c7 44 24 0c 5b 80 10 	movl   $0xc010805b,0xc(%esp)
c01060e0:	c0 
c01060e1:	c7 44 24 08 00 7e 10 	movl   $0xc0107e00,0x8(%esp)
c01060e8:	c0 
c01060e9:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c01060f0:	00 
c01060f1:	c7 04 24 15 7e 10 c0 	movl   $0xc0107e15,(%esp)
c01060f8:	e8 ec a2 ff ff       	call   c01003e9 <__panic>
    cprintf("clean successfully.\n");
c01060fd:	c7 04 24 70 80 10 c0 	movl   $0xc0108070,(%esp)
c0106104:	e8 89 a1 ff ff       	call   c0100292 <cprintf>
    cprintf("p0\n");
c0106109:	c7 04 24 03 7f 10 c0 	movl   $0xc0107f03,(%esp)
c0106110:	e8 7d a1 ff ff       	call   c0100292 <cprintf>
    free_page(p0);
c0106115:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010611c:	00 
c010611d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106120:	89 04 24             	mov    %eax,(%esp)
c0106123:	e8 59 ca ff ff       	call   c0102b81 <free_pages>
    cprintf("p1\n");
c0106128:	c7 04 24 23 7f 10 c0 	movl   $0xc0107f23,(%esp)
c010612f:	e8 5e a1 ff ff       	call   c0100292 <cprintf>
    free_page(p1);
c0106134:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010613b:	00 
c010613c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010613f:	89 04 24             	mov    %eax,(%esp)
c0106142:	e8 3a ca ff ff       	call   c0102b81 <free_pages>
    cprintf("p2\n");
c0106147:	c7 04 24 43 7f 10 c0 	movl   $0xc0107f43,(%esp)
c010614e:	e8 3f a1 ff ff       	call   c0100292 <cprintf>
    free_page(p2);
c0106153:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010615a:	00 
c010615b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010615e:	89 04 24             	mov    %eax,(%esp)
c0106161:	e8 1b ca ff ff       	call   c0102b81 <free_pages>
    total = 0;
c0106166:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
c010616d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0106174:	eb 1e                	jmp    c0106194 <buddy_check+0x4d8>
        total += free_area[i].nr_free;
c0106176:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106179:	89 d0                	mov    %edx,%eax
c010617b:	01 c0                	add    %eax,%eax
c010617d:	01 d0                	add    %edx,%eax
c010617f:	c1 e0 02             	shl    $0x2,%eax
c0106182:	05 28 df 11 c0       	add    $0xc011df28,%eax
c0106187:	8b 10                	mov    (%eax),%edx
c0106189:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010618c:	01 d0                	add    %edx,%eax
c010618e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (int i = 0; i <= MAXLEVEL; i++) 
c0106191:	ff 45 e0             	incl   -0x20(%ebp)
c0106194:	83 7d e0 0c          	cmpl   $0xc,-0x20(%ebp)
c0106198:	7e dc                	jle    c0106176 <buddy_check+0x4ba>

    //assert((p0 = alloc_page()) != NULL);
    //assert((p1 = alloc_page()) != NULL);
    //assert((p2 = alloc_page()) != NULL);
    //assert(alloc_page() == NULL);
}
c010619a:	90                   	nop
c010619b:	c9                   	leave  
c010619c:	c3                   	ret    

c010619d <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010619d:	55                   	push   %ebp
c010619e:	89 e5                	mov    %esp,%ebp
c01061a0:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01061a3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01061aa:	eb 03                	jmp    c01061af <strlen+0x12>
        cnt ++;
c01061ac:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c01061af:	8b 45 08             	mov    0x8(%ebp),%eax
c01061b2:	8d 50 01             	lea    0x1(%eax),%edx
c01061b5:	89 55 08             	mov    %edx,0x8(%ebp)
c01061b8:	0f b6 00             	movzbl (%eax),%eax
c01061bb:	84 c0                	test   %al,%al
c01061bd:	75 ed                	jne    c01061ac <strlen+0xf>
    }
    return cnt;
c01061bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01061c2:	c9                   	leave  
c01061c3:	c3                   	ret    

c01061c4 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01061c4:	55                   	push   %ebp
c01061c5:	89 e5                	mov    %esp,%ebp
c01061c7:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01061ca:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01061d1:	eb 03                	jmp    c01061d6 <strnlen+0x12>
        cnt ++;
c01061d3:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01061d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01061d9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01061dc:	73 10                	jae    c01061ee <strnlen+0x2a>
c01061de:	8b 45 08             	mov    0x8(%ebp),%eax
c01061e1:	8d 50 01             	lea    0x1(%eax),%edx
c01061e4:	89 55 08             	mov    %edx,0x8(%ebp)
c01061e7:	0f b6 00             	movzbl (%eax),%eax
c01061ea:	84 c0                	test   %al,%al
c01061ec:	75 e5                	jne    c01061d3 <strnlen+0xf>
    }
    return cnt;
c01061ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01061f1:	c9                   	leave  
c01061f2:	c3                   	ret    

c01061f3 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c01061f3:	55                   	push   %ebp
c01061f4:	89 e5                	mov    %esp,%ebp
c01061f6:	57                   	push   %edi
c01061f7:	56                   	push   %esi
c01061f8:	83 ec 20             	sub    $0x20,%esp
c01061fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01061fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106201:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106204:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0106207:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010620a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010620d:	89 d1                	mov    %edx,%ecx
c010620f:	89 c2                	mov    %eax,%edx
c0106211:	89 ce                	mov    %ecx,%esi
c0106213:	89 d7                	mov    %edx,%edi
c0106215:	ac                   	lods   %ds:(%esi),%al
c0106216:	aa                   	stos   %al,%es:(%edi)
c0106217:	84 c0                	test   %al,%al
c0106219:	75 fa                	jne    c0106215 <strcpy+0x22>
c010621b:	89 fa                	mov    %edi,%edx
c010621d:	89 f1                	mov    %esi,%ecx
c010621f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0106222:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0106225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0106228:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c010622b:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010622c:	83 c4 20             	add    $0x20,%esp
c010622f:	5e                   	pop    %esi
c0106230:	5f                   	pop    %edi
c0106231:	5d                   	pop    %ebp
c0106232:	c3                   	ret    

c0106233 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0106233:	55                   	push   %ebp
c0106234:	89 e5                	mov    %esp,%ebp
c0106236:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0106239:	8b 45 08             	mov    0x8(%ebp),%eax
c010623c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010623f:	eb 1e                	jmp    c010625f <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0106241:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106244:	0f b6 10             	movzbl (%eax),%edx
c0106247:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010624a:	88 10                	mov    %dl,(%eax)
c010624c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010624f:	0f b6 00             	movzbl (%eax),%eax
c0106252:	84 c0                	test   %al,%al
c0106254:	74 03                	je     c0106259 <strncpy+0x26>
            src ++;
c0106256:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0106259:	ff 45 fc             	incl   -0x4(%ebp)
c010625c:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c010625f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106263:	75 dc                	jne    c0106241 <strncpy+0xe>
    }
    return dst;
c0106265:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106268:	c9                   	leave  
c0106269:	c3                   	ret    

c010626a <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010626a:	55                   	push   %ebp
c010626b:	89 e5                	mov    %esp,%ebp
c010626d:	57                   	push   %edi
c010626e:	56                   	push   %esi
c010626f:	83 ec 20             	sub    $0x20,%esp
c0106272:	8b 45 08             	mov    0x8(%ebp),%eax
c0106275:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106278:	8b 45 0c             	mov    0xc(%ebp),%eax
c010627b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010627e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106281:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106284:	89 d1                	mov    %edx,%ecx
c0106286:	89 c2                	mov    %eax,%edx
c0106288:	89 ce                	mov    %ecx,%esi
c010628a:	89 d7                	mov    %edx,%edi
c010628c:	ac                   	lods   %ds:(%esi),%al
c010628d:	ae                   	scas   %es:(%edi),%al
c010628e:	75 08                	jne    c0106298 <strcmp+0x2e>
c0106290:	84 c0                	test   %al,%al
c0106292:	75 f8                	jne    c010628c <strcmp+0x22>
c0106294:	31 c0                	xor    %eax,%eax
c0106296:	eb 04                	jmp    c010629c <strcmp+0x32>
c0106298:	19 c0                	sbb    %eax,%eax
c010629a:	0c 01                	or     $0x1,%al
c010629c:	89 fa                	mov    %edi,%edx
c010629e:	89 f1                	mov    %esi,%ecx
c01062a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01062a3:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01062a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c01062a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01062ac:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01062ad:	83 c4 20             	add    $0x20,%esp
c01062b0:	5e                   	pop    %esi
c01062b1:	5f                   	pop    %edi
c01062b2:	5d                   	pop    %ebp
c01062b3:	c3                   	ret    

c01062b4 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01062b4:	55                   	push   %ebp
c01062b5:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01062b7:	eb 09                	jmp    c01062c2 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c01062b9:	ff 4d 10             	decl   0x10(%ebp)
c01062bc:	ff 45 08             	incl   0x8(%ebp)
c01062bf:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01062c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01062c6:	74 1a                	je     c01062e2 <strncmp+0x2e>
c01062c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01062cb:	0f b6 00             	movzbl (%eax),%eax
c01062ce:	84 c0                	test   %al,%al
c01062d0:	74 10                	je     c01062e2 <strncmp+0x2e>
c01062d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01062d5:	0f b6 10             	movzbl (%eax),%edx
c01062d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01062db:	0f b6 00             	movzbl (%eax),%eax
c01062de:	38 c2                	cmp    %al,%dl
c01062e0:	74 d7                	je     c01062b9 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c01062e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01062e6:	74 18                	je     c0106300 <strncmp+0x4c>
c01062e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01062eb:	0f b6 00             	movzbl (%eax),%eax
c01062ee:	0f b6 d0             	movzbl %al,%edx
c01062f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01062f4:	0f b6 00             	movzbl (%eax),%eax
c01062f7:	0f b6 c0             	movzbl %al,%eax
c01062fa:	29 c2                	sub    %eax,%edx
c01062fc:	89 d0                	mov    %edx,%eax
c01062fe:	eb 05                	jmp    c0106305 <strncmp+0x51>
c0106300:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106305:	5d                   	pop    %ebp
c0106306:	c3                   	ret    

c0106307 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0106307:	55                   	push   %ebp
c0106308:	89 e5                	mov    %esp,%ebp
c010630a:	83 ec 04             	sub    $0x4,%esp
c010630d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106310:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0106313:	eb 13                	jmp    c0106328 <strchr+0x21>
        if (*s == c) {
c0106315:	8b 45 08             	mov    0x8(%ebp),%eax
c0106318:	0f b6 00             	movzbl (%eax),%eax
c010631b:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010631e:	75 05                	jne    c0106325 <strchr+0x1e>
            return (char *)s;
c0106320:	8b 45 08             	mov    0x8(%ebp),%eax
c0106323:	eb 12                	jmp    c0106337 <strchr+0x30>
        }
        s ++;
c0106325:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0106328:	8b 45 08             	mov    0x8(%ebp),%eax
c010632b:	0f b6 00             	movzbl (%eax),%eax
c010632e:	84 c0                	test   %al,%al
c0106330:	75 e3                	jne    c0106315 <strchr+0xe>
    }
    return NULL;
c0106332:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106337:	c9                   	leave  
c0106338:	c3                   	ret    

c0106339 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0106339:	55                   	push   %ebp
c010633a:	89 e5                	mov    %esp,%ebp
c010633c:	83 ec 04             	sub    $0x4,%esp
c010633f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106342:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0106345:	eb 0e                	jmp    c0106355 <strfind+0x1c>
        if (*s == c) {
c0106347:	8b 45 08             	mov    0x8(%ebp),%eax
c010634a:	0f b6 00             	movzbl (%eax),%eax
c010634d:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0106350:	74 0f                	je     c0106361 <strfind+0x28>
            break;
        }
        s ++;
c0106352:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0106355:	8b 45 08             	mov    0x8(%ebp),%eax
c0106358:	0f b6 00             	movzbl (%eax),%eax
c010635b:	84 c0                	test   %al,%al
c010635d:	75 e8                	jne    c0106347 <strfind+0xe>
c010635f:	eb 01                	jmp    c0106362 <strfind+0x29>
            break;
c0106361:	90                   	nop
    }
    return (char *)s;
c0106362:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106365:	c9                   	leave  
c0106366:	c3                   	ret    

c0106367 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0106367:	55                   	push   %ebp
c0106368:	89 e5                	mov    %esp,%ebp
c010636a:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010636d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0106374:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010637b:	eb 03                	jmp    c0106380 <strtol+0x19>
        s ++;
c010637d:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0106380:	8b 45 08             	mov    0x8(%ebp),%eax
c0106383:	0f b6 00             	movzbl (%eax),%eax
c0106386:	3c 20                	cmp    $0x20,%al
c0106388:	74 f3                	je     c010637d <strtol+0x16>
c010638a:	8b 45 08             	mov    0x8(%ebp),%eax
c010638d:	0f b6 00             	movzbl (%eax),%eax
c0106390:	3c 09                	cmp    $0x9,%al
c0106392:	74 e9                	je     c010637d <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0106394:	8b 45 08             	mov    0x8(%ebp),%eax
c0106397:	0f b6 00             	movzbl (%eax),%eax
c010639a:	3c 2b                	cmp    $0x2b,%al
c010639c:	75 05                	jne    c01063a3 <strtol+0x3c>
        s ++;
c010639e:	ff 45 08             	incl   0x8(%ebp)
c01063a1:	eb 14                	jmp    c01063b7 <strtol+0x50>
    }
    else if (*s == '-') {
c01063a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01063a6:	0f b6 00             	movzbl (%eax),%eax
c01063a9:	3c 2d                	cmp    $0x2d,%al
c01063ab:	75 0a                	jne    c01063b7 <strtol+0x50>
        s ++, neg = 1;
c01063ad:	ff 45 08             	incl   0x8(%ebp)
c01063b0:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01063b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01063bb:	74 06                	je     c01063c3 <strtol+0x5c>
c01063bd:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01063c1:	75 22                	jne    c01063e5 <strtol+0x7e>
c01063c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01063c6:	0f b6 00             	movzbl (%eax),%eax
c01063c9:	3c 30                	cmp    $0x30,%al
c01063cb:	75 18                	jne    c01063e5 <strtol+0x7e>
c01063cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01063d0:	40                   	inc    %eax
c01063d1:	0f b6 00             	movzbl (%eax),%eax
c01063d4:	3c 78                	cmp    $0x78,%al
c01063d6:	75 0d                	jne    c01063e5 <strtol+0x7e>
        s += 2, base = 16;
c01063d8:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c01063dc:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c01063e3:	eb 29                	jmp    c010640e <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c01063e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01063e9:	75 16                	jne    c0106401 <strtol+0x9a>
c01063eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01063ee:	0f b6 00             	movzbl (%eax),%eax
c01063f1:	3c 30                	cmp    $0x30,%al
c01063f3:	75 0c                	jne    c0106401 <strtol+0x9a>
        s ++, base = 8;
c01063f5:	ff 45 08             	incl   0x8(%ebp)
c01063f8:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c01063ff:	eb 0d                	jmp    c010640e <strtol+0xa7>
    }
    else if (base == 0) {
c0106401:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106405:	75 07                	jne    c010640e <strtol+0xa7>
        base = 10;
c0106407:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010640e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106411:	0f b6 00             	movzbl (%eax),%eax
c0106414:	3c 2f                	cmp    $0x2f,%al
c0106416:	7e 1b                	jle    c0106433 <strtol+0xcc>
c0106418:	8b 45 08             	mov    0x8(%ebp),%eax
c010641b:	0f b6 00             	movzbl (%eax),%eax
c010641e:	3c 39                	cmp    $0x39,%al
c0106420:	7f 11                	jg     c0106433 <strtol+0xcc>
            dig = *s - '0';
c0106422:	8b 45 08             	mov    0x8(%ebp),%eax
c0106425:	0f b6 00             	movzbl (%eax),%eax
c0106428:	0f be c0             	movsbl %al,%eax
c010642b:	83 e8 30             	sub    $0x30,%eax
c010642e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106431:	eb 48                	jmp    c010647b <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0106433:	8b 45 08             	mov    0x8(%ebp),%eax
c0106436:	0f b6 00             	movzbl (%eax),%eax
c0106439:	3c 60                	cmp    $0x60,%al
c010643b:	7e 1b                	jle    c0106458 <strtol+0xf1>
c010643d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106440:	0f b6 00             	movzbl (%eax),%eax
c0106443:	3c 7a                	cmp    $0x7a,%al
c0106445:	7f 11                	jg     c0106458 <strtol+0xf1>
            dig = *s - 'a' + 10;
c0106447:	8b 45 08             	mov    0x8(%ebp),%eax
c010644a:	0f b6 00             	movzbl (%eax),%eax
c010644d:	0f be c0             	movsbl %al,%eax
c0106450:	83 e8 57             	sub    $0x57,%eax
c0106453:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106456:	eb 23                	jmp    c010647b <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0106458:	8b 45 08             	mov    0x8(%ebp),%eax
c010645b:	0f b6 00             	movzbl (%eax),%eax
c010645e:	3c 40                	cmp    $0x40,%al
c0106460:	7e 3b                	jle    c010649d <strtol+0x136>
c0106462:	8b 45 08             	mov    0x8(%ebp),%eax
c0106465:	0f b6 00             	movzbl (%eax),%eax
c0106468:	3c 5a                	cmp    $0x5a,%al
c010646a:	7f 31                	jg     c010649d <strtol+0x136>
            dig = *s - 'A' + 10;
c010646c:	8b 45 08             	mov    0x8(%ebp),%eax
c010646f:	0f b6 00             	movzbl (%eax),%eax
c0106472:	0f be c0             	movsbl %al,%eax
c0106475:	83 e8 37             	sub    $0x37,%eax
c0106478:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010647b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010647e:	3b 45 10             	cmp    0x10(%ebp),%eax
c0106481:	7d 19                	jge    c010649c <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0106483:	ff 45 08             	incl   0x8(%ebp)
c0106486:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106489:	0f af 45 10          	imul   0x10(%ebp),%eax
c010648d:	89 c2                	mov    %eax,%edx
c010648f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106492:	01 d0                	add    %edx,%eax
c0106494:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0106497:	e9 72 ff ff ff       	jmp    c010640e <strtol+0xa7>
            break;
c010649c:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c010649d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01064a1:	74 08                	je     c01064ab <strtol+0x144>
        *endptr = (char *) s;
c01064a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064a6:	8b 55 08             	mov    0x8(%ebp),%edx
c01064a9:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01064ab:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01064af:	74 07                	je     c01064b8 <strtol+0x151>
c01064b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01064b4:	f7 d8                	neg    %eax
c01064b6:	eb 03                	jmp    c01064bb <strtol+0x154>
c01064b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c01064bb:	c9                   	leave  
c01064bc:	c3                   	ret    

c01064bd <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c01064bd:	55                   	push   %ebp
c01064be:	89 e5                	mov    %esp,%ebp
c01064c0:	57                   	push   %edi
c01064c1:	83 ec 24             	sub    $0x24,%esp
c01064c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064c7:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c01064ca:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c01064ce:	8b 55 08             	mov    0x8(%ebp),%edx
c01064d1:	89 55 f8             	mov    %edx,-0x8(%ebp)
c01064d4:	88 45 f7             	mov    %al,-0x9(%ebp)
c01064d7:	8b 45 10             	mov    0x10(%ebp),%eax
c01064da:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c01064dd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01064e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01064e4:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01064e7:	89 d7                	mov    %edx,%edi
c01064e9:	f3 aa                	rep stos %al,%es:(%edi)
c01064eb:	89 fa                	mov    %edi,%edx
c01064ed:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01064f0:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c01064f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01064f6:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c01064f7:	83 c4 24             	add    $0x24,%esp
c01064fa:	5f                   	pop    %edi
c01064fb:	5d                   	pop    %ebp
c01064fc:	c3                   	ret    

c01064fd <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c01064fd:	55                   	push   %ebp
c01064fe:	89 e5                	mov    %esp,%ebp
c0106500:	57                   	push   %edi
c0106501:	56                   	push   %esi
c0106502:	53                   	push   %ebx
c0106503:	83 ec 30             	sub    $0x30,%esp
c0106506:	8b 45 08             	mov    0x8(%ebp),%eax
c0106509:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010650c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010650f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106512:	8b 45 10             	mov    0x10(%ebp),%eax
c0106515:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0106518:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010651b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010651e:	73 42                	jae    c0106562 <memmove+0x65>
c0106520:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106523:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106526:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106529:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010652c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010652f:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106532:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106535:	c1 e8 02             	shr    $0x2,%eax
c0106538:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010653a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010653d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106540:	89 d7                	mov    %edx,%edi
c0106542:	89 c6                	mov    %eax,%esi
c0106544:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106546:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106549:	83 e1 03             	and    $0x3,%ecx
c010654c:	74 02                	je     c0106550 <memmove+0x53>
c010654e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106550:	89 f0                	mov    %esi,%eax
c0106552:	89 fa                	mov    %edi,%edx
c0106554:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0106557:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010655a:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010655d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c0106560:	eb 36                	jmp    c0106598 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0106562:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106565:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106568:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010656b:	01 c2                	add    %eax,%edx
c010656d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106570:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0106573:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106576:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0106579:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010657c:	89 c1                	mov    %eax,%ecx
c010657e:	89 d8                	mov    %ebx,%eax
c0106580:	89 d6                	mov    %edx,%esi
c0106582:	89 c7                	mov    %eax,%edi
c0106584:	fd                   	std    
c0106585:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106587:	fc                   	cld    
c0106588:	89 f8                	mov    %edi,%eax
c010658a:	89 f2                	mov    %esi,%edx
c010658c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010658f:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106592:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0106595:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0106598:	83 c4 30             	add    $0x30,%esp
c010659b:	5b                   	pop    %ebx
c010659c:	5e                   	pop    %esi
c010659d:	5f                   	pop    %edi
c010659e:	5d                   	pop    %ebp
c010659f:	c3                   	ret    

c01065a0 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01065a0:	55                   	push   %ebp
c01065a1:	89 e5                	mov    %esp,%ebp
c01065a3:	57                   	push   %edi
c01065a4:	56                   	push   %esi
c01065a5:	83 ec 20             	sub    $0x20,%esp
c01065a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01065ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01065ae:	8b 45 0c             	mov    0xc(%ebp),%eax
c01065b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01065b4:	8b 45 10             	mov    0x10(%ebp),%eax
c01065b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01065ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01065bd:	c1 e8 02             	shr    $0x2,%eax
c01065c0:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01065c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01065c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065c8:	89 d7                	mov    %edx,%edi
c01065ca:	89 c6                	mov    %eax,%esi
c01065cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01065ce:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01065d1:	83 e1 03             	and    $0x3,%ecx
c01065d4:	74 02                	je     c01065d8 <memcpy+0x38>
c01065d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01065d8:	89 f0                	mov    %esi,%eax
c01065da:	89 fa                	mov    %edi,%edx
c01065dc:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01065df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01065e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c01065e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c01065e8:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c01065e9:	83 c4 20             	add    $0x20,%esp
c01065ec:	5e                   	pop    %esi
c01065ed:	5f                   	pop    %edi
c01065ee:	5d                   	pop    %ebp
c01065ef:	c3                   	ret    

c01065f0 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c01065f0:	55                   	push   %ebp
c01065f1:	89 e5                	mov    %esp,%ebp
c01065f3:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c01065f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01065f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c01065fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01065ff:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0106602:	eb 2e                	jmp    c0106632 <memcmp+0x42>
        if (*s1 != *s2) {
c0106604:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106607:	0f b6 10             	movzbl (%eax),%edx
c010660a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010660d:	0f b6 00             	movzbl (%eax),%eax
c0106610:	38 c2                	cmp    %al,%dl
c0106612:	74 18                	je     c010662c <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0106614:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106617:	0f b6 00             	movzbl (%eax),%eax
c010661a:	0f b6 d0             	movzbl %al,%edx
c010661d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106620:	0f b6 00             	movzbl (%eax),%eax
c0106623:	0f b6 c0             	movzbl %al,%eax
c0106626:	29 c2                	sub    %eax,%edx
c0106628:	89 d0                	mov    %edx,%eax
c010662a:	eb 18                	jmp    c0106644 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c010662c:	ff 45 fc             	incl   -0x4(%ebp)
c010662f:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0106632:	8b 45 10             	mov    0x10(%ebp),%eax
c0106635:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106638:	89 55 10             	mov    %edx,0x10(%ebp)
c010663b:	85 c0                	test   %eax,%eax
c010663d:	75 c5                	jne    c0106604 <memcmp+0x14>
    }
    return 0;
c010663f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106644:	c9                   	leave  
c0106645:	c3                   	ret    

c0106646 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0106646:	55                   	push   %ebp
c0106647:	89 e5                	mov    %esp,%ebp
c0106649:	83 ec 58             	sub    $0x58,%esp
c010664c:	8b 45 10             	mov    0x10(%ebp),%eax
c010664f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106652:	8b 45 14             	mov    0x14(%ebp),%eax
c0106655:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0106658:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010665b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010665e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106661:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0106664:	8b 45 18             	mov    0x18(%ebp),%eax
c0106667:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010666a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010666d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106670:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106673:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0106676:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106679:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010667c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106680:	74 1c                	je     c010669e <printnum+0x58>
c0106682:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106685:	ba 00 00 00 00       	mov    $0x0,%edx
c010668a:	f7 75 e4             	divl   -0x1c(%ebp)
c010668d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0106690:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106693:	ba 00 00 00 00       	mov    $0x0,%edx
c0106698:	f7 75 e4             	divl   -0x1c(%ebp)
c010669b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010669e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01066a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01066a4:	f7 75 e4             	divl   -0x1c(%ebp)
c01066a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01066aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01066ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01066b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01066b3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01066b6:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01066b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01066bc:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01066bf:	8b 45 18             	mov    0x18(%ebp),%eax
c01066c2:	ba 00 00 00 00       	mov    $0x0,%edx
c01066c7:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c01066ca:	72 56                	jb     c0106722 <printnum+0xdc>
c01066cc:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c01066cf:	77 05                	ja     c01066d6 <printnum+0x90>
c01066d1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01066d4:	72 4c                	jb     c0106722 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c01066d6:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01066d9:	8d 50 ff             	lea    -0x1(%eax),%edx
c01066dc:	8b 45 20             	mov    0x20(%ebp),%eax
c01066df:	89 44 24 18          	mov    %eax,0x18(%esp)
c01066e3:	89 54 24 14          	mov    %edx,0x14(%esp)
c01066e7:	8b 45 18             	mov    0x18(%ebp),%eax
c01066ea:	89 44 24 10          	mov    %eax,0x10(%esp)
c01066ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01066f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01066f4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01066f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01066fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01066ff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106703:	8b 45 08             	mov    0x8(%ebp),%eax
c0106706:	89 04 24             	mov    %eax,(%esp)
c0106709:	e8 38 ff ff ff       	call   c0106646 <printnum>
c010670e:	eb 1b                	jmp    c010672b <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0106710:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106713:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106717:	8b 45 20             	mov    0x20(%ebp),%eax
c010671a:	89 04 24             	mov    %eax,(%esp)
c010671d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106720:	ff d0                	call   *%eax
        while (-- width > 0)
c0106722:	ff 4d 1c             	decl   0x1c(%ebp)
c0106725:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106729:	7f e5                	jg     c0106710 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010672b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010672e:	05 30 81 10 c0       	add    $0xc0108130,%eax
c0106733:	0f b6 00             	movzbl (%eax),%eax
c0106736:	0f be c0             	movsbl %al,%eax
c0106739:	8b 55 0c             	mov    0xc(%ebp),%edx
c010673c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106740:	89 04 24             	mov    %eax,(%esp)
c0106743:	8b 45 08             	mov    0x8(%ebp),%eax
c0106746:	ff d0                	call   *%eax
}
c0106748:	90                   	nop
c0106749:	c9                   	leave  
c010674a:	c3                   	ret    

c010674b <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010674b:	55                   	push   %ebp
c010674c:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010674e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0106752:	7e 14                	jle    c0106768 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0106754:	8b 45 08             	mov    0x8(%ebp),%eax
c0106757:	8b 00                	mov    (%eax),%eax
c0106759:	8d 48 08             	lea    0x8(%eax),%ecx
c010675c:	8b 55 08             	mov    0x8(%ebp),%edx
c010675f:	89 0a                	mov    %ecx,(%edx)
c0106761:	8b 50 04             	mov    0x4(%eax),%edx
c0106764:	8b 00                	mov    (%eax),%eax
c0106766:	eb 30                	jmp    c0106798 <getuint+0x4d>
    }
    else if (lflag) {
c0106768:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010676c:	74 16                	je     c0106784 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010676e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106771:	8b 00                	mov    (%eax),%eax
c0106773:	8d 48 04             	lea    0x4(%eax),%ecx
c0106776:	8b 55 08             	mov    0x8(%ebp),%edx
c0106779:	89 0a                	mov    %ecx,(%edx)
c010677b:	8b 00                	mov    (%eax),%eax
c010677d:	ba 00 00 00 00       	mov    $0x0,%edx
c0106782:	eb 14                	jmp    c0106798 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0106784:	8b 45 08             	mov    0x8(%ebp),%eax
c0106787:	8b 00                	mov    (%eax),%eax
c0106789:	8d 48 04             	lea    0x4(%eax),%ecx
c010678c:	8b 55 08             	mov    0x8(%ebp),%edx
c010678f:	89 0a                	mov    %ecx,(%edx)
c0106791:	8b 00                	mov    (%eax),%eax
c0106793:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0106798:	5d                   	pop    %ebp
c0106799:	c3                   	ret    

c010679a <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010679a:	55                   	push   %ebp
c010679b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010679d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01067a1:	7e 14                	jle    c01067b7 <getint+0x1d>
        return va_arg(*ap, long long);
c01067a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01067a6:	8b 00                	mov    (%eax),%eax
c01067a8:	8d 48 08             	lea    0x8(%eax),%ecx
c01067ab:	8b 55 08             	mov    0x8(%ebp),%edx
c01067ae:	89 0a                	mov    %ecx,(%edx)
c01067b0:	8b 50 04             	mov    0x4(%eax),%edx
c01067b3:	8b 00                	mov    (%eax),%eax
c01067b5:	eb 28                	jmp    c01067df <getint+0x45>
    }
    else if (lflag) {
c01067b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01067bb:	74 12                	je     c01067cf <getint+0x35>
        return va_arg(*ap, long);
c01067bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01067c0:	8b 00                	mov    (%eax),%eax
c01067c2:	8d 48 04             	lea    0x4(%eax),%ecx
c01067c5:	8b 55 08             	mov    0x8(%ebp),%edx
c01067c8:	89 0a                	mov    %ecx,(%edx)
c01067ca:	8b 00                	mov    (%eax),%eax
c01067cc:	99                   	cltd   
c01067cd:	eb 10                	jmp    c01067df <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01067cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01067d2:	8b 00                	mov    (%eax),%eax
c01067d4:	8d 48 04             	lea    0x4(%eax),%ecx
c01067d7:	8b 55 08             	mov    0x8(%ebp),%edx
c01067da:	89 0a                	mov    %ecx,(%edx)
c01067dc:	8b 00                	mov    (%eax),%eax
c01067de:	99                   	cltd   
    }
}
c01067df:	5d                   	pop    %ebp
c01067e0:	c3                   	ret    

c01067e1 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01067e1:	55                   	push   %ebp
c01067e2:	89 e5                	mov    %esp,%ebp
c01067e4:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01067e7:	8d 45 14             	lea    0x14(%ebp),%eax
c01067ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01067ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01067f4:	8b 45 10             	mov    0x10(%ebp),%eax
c01067f7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01067fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01067fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106802:	8b 45 08             	mov    0x8(%ebp),%eax
c0106805:	89 04 24             	mov    %eax,(%esp)
c0106808:	e8 03 00 00 00       	call   c0106810 <vprintfmt>
    va_end(ap);
}
c010680d:	90                   	nop
c010680e:	c9                   	leave  
c010680f:	c3                   	ret    

c0106810 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0106810:	55                   	push   %ebp
c0106811:	89 e5                	mov    %esp,%ebp
c0106813:	56                   	push   %esi
c0106814:	53                   	push   %ebx
c0106815:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0106818:	eb 17                	jmp    c0106831 <vprintfmt+0x21>
            if (ch == '\0') {
c010681a:	85 db                	test   %ebx,%ebx
c010681c:	0f 84 bf 03 00 00    	je     c0106be1 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0106822:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106825:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106829:	89 1c 24             	mov    %ebx,(%esp)
c010682c:	8b 45 08             	mov    0x8(%ebp),%eax
c010682f:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0106831:	8b 45 10             	mov    0x10(%ebp),%eax
c0106834:	8d 50 01             	lea    0x1(%eax),%edx
c0106837:	89 55 10             	mov    %edx,0x10(%ebp)
c010683a:	0f b6 00             	movzbl (%eax),%eax
c010683d:	0f b6 d8             	movzbl %al,%ebx
c0106840:	83 fb 25             	cmp    $0x25,%ebx
c0106843:	75 d5                	jne    c010681a <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0106845:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0106849:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0106850:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106853:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0106856:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010685d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106860:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0106863:	8b 45 10             	mov    0x10(%ebp),%eax
c0106866:	8d 50 01             	lea    0x1(%eax),%edx
c0106869:	89 55 10             	mov    %edx,0x10(%ebp)
c010686c:	0f b6 00             	movzbl (%eax),%eax
c010686f:	0f b6 d8             	movzbl %al,%ebx
c0106872:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0106875:	83 f8 55             	cmp    $0x55,%eax
c0106878:	0f 87 37 03 00 00    	ja     c0106bb5 <vprintfmt+0x3a5>
c010687e:	8b 04 85 54 81 10 c0 	mov    -0x3fef7eac(,%eax,4),%eax
c0106885:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0106887:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010688b:	eb d6                	jmp    c0106863 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010688d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0106891:	eb d0                	jmp    c0106863 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0106893:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010689a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010689d:	89 d0                	mov    %edx,%eax
c010689f:	c1 e0 02             	shl    $0x2,%eax
c01068a2:	01 d0                	add    %edx,%eax
c01068a4:	01 c0                	add    %eax,%eax
c01068a6:	01 d8                	add    %ebx,%eax
c01068a8:	83 e8 30             	sub    $0x30,%eax
c01068ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01068ae:	8b 45 10             	mov    0x10(%ebp),%eax
c01068b1:	0f b6 00             	movzbl (%eax),%eax
c01068b4:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01068b7:	83 fb 2f             	cmp    $0x2f,%ebx
c01068ba:	7e 38                	jle    c01068f4 <vprintfmt+0xe4>
c01068bc:	83 fb 39             	cmp    $0x39,%ebx
c01068bf:	7f 33                	jg     c01068f4 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c01068c1:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c01068c4:	eb d4                	jmp    c010689a <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c01068c6:	8b 45 14             	mov    0x14(%ebp),%eax
c01068c9:	8d 50 04             	lea    0x4(%eax),%edx
c01068cc:	89 55 14             	mov    %edx,0x14(%ebp)
c01068cf:	8b 00                	mov    (%eax),%eax
c01068d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01068d4:	eb 1f                	jmp    c01068f5 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c01068d6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01068da:	79 87                	jns    c0106863 <vprintfmt+0x53>
                width = 0;
c01068dc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01068e3:	e9 7b ff ff ff       	jmp    c0106863 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c01068e8:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01068ef:	e9 6f ff ff ff       	jmp    c0106863 <vprintfmt+0x53>
            goto process_precision;
c01068f4:	90                   	nop

        process_precision:
            if (width < 0)
c01068f5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01068f9:	0f 89 64 ff ff ff    	jns    c0106863 <vprintfmt+0x53>
                width = precision, precision = -1;
c01068ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106902:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106905:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010690c:	e9 52 ff ff ff       	jmp    c0106863 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0106911:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0106914:	e9 4a ff ff ff       	jmp    c0106863 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0106919:	8b 45 14             	mov    0x14(%ebp),%eax
c010691c:	8d 50 04             	lea    0x4(%eax),%edx
c010691f:	89 55 14             	mov    %edx,0x14(%ebp)
c0106922:	8b 00                	mov    (%eax),%eax
c0106924:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106927:	89 54 24 04          	mov    %edx,0x4(%esp)
c010692b:	89 04 24             	mov    %eax,(%esp)
c010692e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106931:	ff d0                	call   *%eax
            break;
c0106933:	e9 a4 02 00 00       	jmp    c0106bdc <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0106938:	8b 45 14             	mov    0x14(%ebp),%eax
c010693b:	8d 50 04             	lea    0x4(%eax),%edx
c010693e:	89 55 14             	mov    %edx,0x14(%ebp)
c0106941:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0106943:	85 db                	test   %ebx,%ebx
c0106945:	79 02                	jns    c0106949 <vprintfmt+0x139>
                err = -err;
c0106947:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0106949:	83 fb 06             	cmp    $0x6,%ebx
c010694c:	7f 0b                	jg     c0106959 <vprintfmt+0x149>
c010694e:	8b 34 9d 14 81 10 c0 	mov    -0x3fef7eec(,%ebx,4),%esi
c0106955:	85 f6                	test   %esi,%esi
c0106957:	75 23                	jne    c010697c <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0106959:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010695d:	c7 44 24 08 41 81 10 	movl   $0xc0108141,0x8(%esp)
c0106964:	c0 
c0106965:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106968:	89 44 24 04          	mov    %eax,0x4(%esp)
c010696c:	8b 45 08             	mov    0x8(%ebp),%eax
c010696f:	89 04 24             	mov    %eax,(%esp)
c0106972:	e8 6a fe ff ff       	call   c01067e1 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0106977:	e9 60 02 00 00       	jmp    c0106bdc <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c010697c:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0106980:	c7 44 24 08 4a 81 10 	movl   $0xc010814a,0x8(%esp)
c0106987:	c0 
c0106988:	8b 45 0c             	mov    0xc(%ebp),%eax
c010698b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010698f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106992:	89 04 24             	mov    %eax,(%esp)
c0106995:	e8 47 fe ff ff       	call   c01067e1 <printfmt>
            break;
c010699a:	e9 3d 02 00 00       	jmp    c0106bdc <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010699f:	8b 45 14             	mov    0x14(%ebp),%eax
c01069a2:	8d 50 04             	lea    0x4(%eax),%edx
c01069a5:	89 55 14             	mov    %edx,0x14(%ebp)
c01069a8:	8b 30                	mov    (%eax),%esi
c01069aa:	85 f6                	test   %esi,%esi
c01069ac:	75 05                	jne    c01069b3 <vprintfmt+0x1a3>
                p = "(null)";
c01069ae:	be 4d 81 10 c0       	mov    $0xc010814d,%esi
            }
            if (width > 0 && padc != '-') {
c01069b3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01069b7:	7e 76                	jle    c0106a2f <vprintfmt+0x21f>
c01069b9:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01069bd:	74 70                	je     c0106a2f <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01069bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01069c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069c6:	89 34 24             	mov    %esi,(%esp)
c01069c9:	e8 f6 f7 ff ff       	call   c01061c4 <strnlen>
c01069ce:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01069d1:	29 c2                	sub    %eax,%edx
c01069d3:	89 d0                	mov    %edx,%eax
c01069d5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01069d8:	eb 16                	jmp    c01069f0 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c01069da:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01069de:	8b 55 0c             	mov    0xc(%ebp),%edx
c01069e1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01069e5:	89 04 24             	mov    %eax,(%esp)
c01069e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01069eb:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c01069ed:	ff 4d e8             	decl   -0x18(%ebp)
c01069f0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01069f4:	7f e4                	jg     c01069da <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01069f6:	eb 37                	jmp    c0106a2f <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c01069f8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01069fc:	74 1f                	je     c0106a1d <vprintfmt+0x20d>
c01069fe:	83 fb 1f             	cmp    $0x1f,%ebx
c0106a01:	7e 05                	jle    c0106a08 <vprintfmt+0x1f8>
c0106a03:	83 fb 7e             	cmp    $0x7e,%ebx
c0106a06:	7e 15                	jle    c0106a1d <vprintfmt+0x20d>
                    putch('?', putdat);
c0106a08:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a0f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0106a16:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a19:	ff d0                	call   *%eax
c0106a1b:	eb 0f                	jmp    c0106a2c <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0106a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a24:	89 1c 24             	mov    %ebx,(%esp)
c0106a27:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a2a:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106a2c:	ff 4d e8             	decl   -0x18(%ebp)
c0106a2f:	89 f0                	mov    %esi,%eax
c0106a31:	8d 70 01             	lea    0x1(%eax),%esi
c0106a34:	0f b6 00             	movzbl (%eax),%eax
c0106a37:	0f be d8             	movsbl %al,%ebx
c0106a3a:	85 db                	test   %ebx,%ebx
c0106a3c:	74 27                	je     c0106a65 <vprintfmt+0x255>
c0106a3e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106a42:	78 b4                	js     c01069f8 <vprintfmt+0x1e8>
c0106a44:	ff 4d e4             	decl   -0x1c(%ebp)
c0106a47:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106a4b:	79 ab                	jns    c01069f8 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0106a4d:	eb 16                	jmp    c0106a65 <vprintfmt+0x255>
                putch(' ', putdat);
c0106a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a52:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a56:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0106a5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a60:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0106a62:	ff 4d e8             	decl   -0x18(%ebp)
c0106a65:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106a69:	7f e4                	jg     c0106a4f <vprintfmt+0x23f>
            }
            break;
c0106a6b:	e9 6c 01 00 00       	jmp    c0106bdc <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0106a70:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106a73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a77:	8d 45 14             	lea    0x14(%ebp),%eax
c0106a7a:	89 04 24             	mov    %eax,(%esp)
c0106a7d:	e8 18 fd ff ff       	call   c010679a <getint>
c0106a82:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106a85:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0106a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106a8e:	85 d2                	test   %edx,%edx
c0106a90:	79 26                	jns    c0106ab8 <vprintfmt+0x2a8>
                putch('-', putdat);
c0106a92:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a99:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0106aa0:	8b 45 08             	mov    0x8(%ebp),%eax
c0106aa3:	ff d0                	call   *%eax
                num = -(long long)num;
c0106aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106aa8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106aab:	f7 d8                	neg    %eax
c0106aad:	83 d2 00             	adc    $0x0,%edx
c0106ab0:	f7 da                	neg    %edx
c0106ab2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106ab5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0106ab8:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106abf:	e9 a8 00 00 00       	jmp    c0106b6c <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0106ac4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106acb:	8d 45 14             	lea    0x14(%ebp),%eax
c0106ace:	89 04 24             	mov    %eax,(%esp)
c0106ad1:	e8 75 fc ff ff       	call   c010674b <getuint>
c0106ad6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106ad9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0106adc:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106ae3:	e9 84 00 00 00       	jmp    c0106b6c <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0106ae8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106aef:	8d 45 14             	lea    0x14(%ebp),%eax
c0106af2:	89 04 24             	mov    %eax,(%esp)
c0106af5:	e8 51 fc ff ff       	call   c010674b <getuint>
c0106afa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106afd:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0106b00:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0106b07:	eb 63                	jmp    c0106b6c <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0106b09:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b10:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0106b17:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b1a:	ff d0                	call   *%eax
            putch('x', putdat);
c0106b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b23:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0106b2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b2d:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0106b2f:	8b 45 14             	mov    0x14(%ebp),%eax
c0106b32:	8d 50 04             	lea    0x4(%eax),%edx
c0106b35:	89 55 14             	mov    %edx,0x14(%ebp)
c0106b38:	8b 00                	mov    (%eax),%eax
c0106b3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0106b44:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0106b4b:	eb 1f                	jmp    c0106b6c <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0106b4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b50:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b54:	8d 45 14             	lea    0x14(%ebp),%eax
c0106b57:	89 04 24             	mov    %eax,(%esp)
c0106b5a:	e8 ec fb ff ff       	call   c010674b <getuint>
c0106b5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b62:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0106b65:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0106b6c:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0106b70:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b73:	89 54 24 18          	mov    %edx,0x18(%esp)
c0106b77:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106b7a:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106b7e:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b85:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106b88:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106b8c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106b90:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b93:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b97:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b9a:	89 04 24             	mov    %eax,(%esp)
c0106b9d:	e8 a4 fa ff ff       	call   c0106646 <printnum>
            break;
c0106ba2:	eb 38                	jmp    c0106bdc <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0106ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ba7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bab:	89 1c 24             	mov    %ebx,(%esp)
c0106bae:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bb1:	ff d0                	call   *%eax
            break;
c0106bb3:	eb 27                	jmp    c0106bdc <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0106bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bbc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0106bc3:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bc6:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0106bc8:	ff 4d 10             	decl   0x10(%ebp)
c0106bcb:	eb 03                	jmp    c0106bd0 <vprintfmt+0x3c0>
c0106bcd:	ff 4d 10             	decl   0x10(%ebp)
c0106bd0:	8b 45 10             	mov    0x10(%ebp),%eax
c0106bd3:	48                   	dec    %eax
c0106bd4:	0f b6 00             	movzbl (%eax),%eax
c0106bd7:	3c 25                	cmp    $0x25,%al
c0106bd9:	75 f2                	jne    c0106bcd <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0106bdb:	90                   	nop
    while (1) {
c0106bdc:	e9 37 fc ff ff       	jmp    c0106818 <vprintfmt+0x8>
                return;
c0106be1:	90                   	nop
        }
    }
}
c0106be2:	83 c4 40             	add    $0x40,%esp
c0106be5:	5b                   	pop    %ebx
c0106be6:	5e                   	pop    %esi
c0106be7:	5d                   	pop    %ebp
c0106be8:	c3                   	ret    

c0106be9 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0106be9:	55                   	push   %ebp
c0106bea:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0106bec:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bef:	8b 40 08             	mov    0x8(%eax),%eax
c0106bf2:	8d 50 01             	lea    0x1(%eax),%edx
c0106bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bf8:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bfe:	8b 10                	mov    (%eax),%edx
c0106c00:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c03:	8b 40 04             	mov    0x4(%eax),%eax
c0106c06:	39 c2                	cmp    %eax,%edx
c0106c08:	73 12                	jae    c0106c1c <sprintputch+0x33>
        *b->buf ++ = ch;
c0106c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c0d:	8b 00                	mov    (%eax),%eax
c0106c0f:	8d 48 01             	lea    0x1(%eax),%ecx
c0106c12:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106c15:	89 0a                	mov    %ecx,(%edx)
c0106c17:	8b 55 08             	mov    0x8(%ebp),%edx
c0106c1a:	88 10                	mov    %dl,(%eax)
    }
}
c0106c1c:	90                   	nop
c0106c1d:	5d                   	pop    %ebp
c0106c1e:	c3                   	ret    

c0106c1f <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0106c1f:	55                   	push   %ebp
c0106c20:	89 e5                	mov    %esp,%ebp
c0106c22:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0106c25:	8d 45 14             	lea    0x14(%ebp),%eax
c0106c28:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0106c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106c32:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c35:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106c39:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c3c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c40:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c43:	89 04 24             	mov    %eax,(%esp)
c0106c46:	e8 08 00 00 00       	call   c0106c53 <vsnprintf>
c0106c4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0106c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106c51:	c9                   	leave  
c0106c52:	c3                   	ret    

c0106c53 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0106c53:	55                   	push   %ebp
c0106c54:	89 e5                	mov    %esp,%ebp
c0106c56:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0106c59:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c62:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106c65:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c68:	01 d0                	add    %edx,%eax
c0106c6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c6d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0106c74:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106c78:	74 0a                	je     c0106c84 <vsnprintf+0x31>
c0106c7a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106c7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c80:	39 c2                	cmp    %eax,%edx
c0106c82:	76 07                	jbe    c0106c8b <vsnprintf+0x38>
        return -E_INVAL;
c0106c84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0106c89:	eb 2a                	jmp    c0106cb5 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0106c8b:	8b 45 14             	mov    0x14(%ebp),%eax
c0106c8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106c92:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c95:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106c99:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0106c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ca0:	c7 04 24 e9 6b 10 c0 	movl   $0xc0106be9,(%esp)
c0106ca7:	e8 64 fb ff ff       	call   c0106810 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0106cac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106caf:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0106cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106cb5:	c9                   	leave  
c0106cb6:	c3                   	ret    
