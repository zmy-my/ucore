# OS ucore lab1

## 1. 练习1

### 题目

通过静态分析代码来了解：

Ⅰ. 操作系统镜像文件ucore.img是如何一步一步生成的？(需要比较详细地解释Makefile中每一条相关命令和命令参数的含义，以及说明命令导致的结果)

Ⅱ. 一个被系统认为是符合规范的硬盘主引导扇区的特征是什么？

### 解答
**· 相关命令和参数的含义**

if=文件名: input file

of=文件名: output file

count=blocks：仅拷贝blocks个块

conv=conversion：用指定的参数转换文件

参见 https://baike.baidu.com/item/dd%E5%91%BD%E4%BB%A4

gcc编译命令：
```
+ cc kern/debug/kdebug.c
gcc -Ikern/debug/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/debug/kdebug.c -o obj/kern/debug/kdebug.o
```
-march: 指定进行优化的型号

-fno-builtin: 除非用_builtin_前缀，否则不进行builtin函数的优化

-fno-PIC:不生成与位置无关的代码

-Wall: 编译后显示所有警告

-ggdb: 尽可能的生成gdb的可以使用的调试信息

-m32: 生成适用于32位环境的代码

-gstabs:以stabs格式声称调试信息，但是不包括gdb调试信息

-nostdinc:使编译器不在系统缺省的头文件目录里面找头文件

-fno-stack-protector: 不生成用于检测缓冲区溢出的代码

ld链接命令：

```
+ ld bin/bootblock
ld -m    elf_i386 -nostdlib -N -e start -Ttext 0x7C00 obj/boot/bootasm.o obj/boot/bootmain.o -o obj/bootblock.o
```

-o: 指定生成的输出文件

-c:将汇编输出文件.s编译输出.o文件/仅执行编译操作，不进行连接操作

-m: 类似march

-N: 设置全读写权限

-e:设置全读写权限

-Ttxt: 指定代码段的开始位置

**· ucore.img的生成**

makefile文件中
生成ucore.img的代码：
```c
# create ucore.img
UCOREIMG	:= $(call totarget,ucore.img)

$(UCOREIMG): $(kernel) $(bootblock)
	$(V)dd if=/dev/zero of=$@ count=10000
	$(V)dd if=$(bootblock) of=$@ conv=notrunc
	$(V)dd if=$(kernel) of=$@ seek=1 conv=notrunc

$(call create_target,ucore.img)
```
观察生成ucore.img的代码，发现要先生成kernel和bootblock：
```c
# create kernel target
kernel = $(call totarget,kernel)

$(kernel): tools/kernel.ld

$(kernel): $(KOBJS)
	@echo + ld $@
	$(V)$(LD) $(LDFLAGS) -T tools/kernel.ld -o $@ $(KOBJS)
	@$(OBJDUMP) -S $@ > $(call asmfile,kernel)
	@$(OBJDUMP) -t $@ | $(SED) '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(call symfile,kernel)

$(call create_target,kernel)
```
```c
# create bootblock
bootfiles = $(call listf_cc,boot)
$(foreach f,$(bootfiles),$(call cc_compile,$(f),$(CC),$(CFLAGS) -Os -nostdinc))

bootblock = $(call totarget,bootblock)

$(bootblock): $(call toobj,$(bootfiles)) | $(call totarget,sign)
	@echo + ld $@
	$(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 $^ -o $(call toobj,bootblock)
	@$(OBJDUMP) -S $(call objfile,bootblock) > $(call asmfile,bootblock)
	@$(OBJCOPY) -S -O binary $(call objfile,bootblock) $(call outfile,bootblock)
	@$(call totarget,sign) $(call outfile,bootblock) $(bootblock)

$(call create_target,bootblock)
```
bootblock是磁盘第一个扇区，该扇区为引导扇区，包括一些准备的内容，bootblock依赖于bootasm.o（）, bootmain.o（读磁盘扇区）文件与sign（硬盘主引导扇区的要求）文件，调用了/tool/sign.c来生成写入一个合法的引导扇区

kernel是内核

*ucore.img文件生产的详细过程参考： https://www.jianshu.com/p/2f95d38afa1d*

读sign.c文件
```c
char buf[512];
    memset(buf, 0, sizeof(buf));
    FILE *ifp = fopen(argv[1], "rb");
    int size = fread(buf, 1, st.st_size, ifp);
    if (size != st.st_size) {
        fprintf(stderr, "read '%s' error, size is %d.\n", argv[1], size);
        return -1;
    }
    fclose(ifp);
    buf[510] = 0x55;
    buf[511] = 0xAA;
    FILE *ofp = fopen(argv[2], "wb+");
    size = fwrite(buf, 1, 512, ofp);
```
一个磁盘主引导扇区大小为512字节，第510字节为0x55，第511字节为0xAA

## 4. 练习4

### 题目

通过阅读bootmain.c，了解bootloader如何加载ELF文件。通过分析源代码和通过qemu来运行并调试bootloader&OS，

Ⅰ. bootloader如何读取硬盘扇区的？

Ⅱ. bootloader是如何加载ELF格式的OS？

###  解答

kernel内核程序是以ELF格式存储的，（*ELF的文件头中标识了一个可执行程序中包含了哪些部分，比如代码段、数据段(只读数据段、可读写数据段)、栈段等等，分别存储在哪里；并指明了需要为这些段分配多少内存空间、需要被加载到内存的什么地址(虚拟地址)等*）。

bootmain.c的任务就是将kernel内核部分从磁盘中读出并载入内存，并将程序的控制流转移至指定的内核入口处。

内核程序是从第二个扇区开始的，因此在可以发现bootmain函数是从第二个扇区开始读的。

```c
/* waitdisk - wait for disk ready */
static void
waitdisk(void) {
    while ((inb(0x1F7) & 0xC0) != 0x40)
        /* do nothing */;
}
```
waitdisk函数：等待磁盘准备好，0x1F7是状态和命令寄存器。

```c
/* readsect - read a single sector at @secno into @dst */
static void
readsect(void *dst, uint32_t secno) {
    // wait for disk to be ready
    waitdisk();

    outb(0x1F2, 1);                         // count = 1
    outb(0x1F3, secno & 0xFF);
    outb(0x1F4, (secno >> 8) & 0xFF);
    outb(0x1F5, (secno >> 16) & 0xFF);
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    outb(0x1F7, 0x20);                      // cmd 0x20 - read sectors

    // wait for disk to be ready
    waitdisk();

    // read a sector
    insl(0x1F0, dst, SECTSIZE / 4);
}
```
readsect函数：读取磁盘扇区。0x1F2是读取扇区的数目，此函数用于读取一个磁盘扇区。

按照四个步骤进行读取:等待磁盘准备好，发出读磁盘扇区的命令，等待磁盘准备好，开始读磁盘扇区。

```c
/* *
 * readseg - read @count bytes at @offset from kernel into virtual address @va,
 * might copy more than asked.
 * */
static void
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    uintptr_t end_va = va + count;

    // round down to sector boundary
    va -= offset % SECTSIZE;

    // translate from bytes to sectors; kernel starts at sector 1
    uint32_t secno = (offset / SECTSIZE) + 1;//从第二个扇区开始读

    // If this is too slow, we could read lots of sectors at a time.
    // We'd write more to memory than asked, but it doesn't matter --
    // we load in increasing order.
    for (; va < end_va; va += SECTSIZE, secno ++) {
        readsect((void *)va, secno);
    }
}
```
readseg函数：通过使用readsect函数迭代读取了更多个扇区

```c
/* bootmain - the entry of bootloader */
void
bootmain(void) {
    // read the 1st page off disk
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);

    // is this a valid ELF?
    if (ELFHDR->e_magic != ELF_MAGIC) {
        goto bad;
    }
```
读ELF文件头，判断ELF文件是否合法（magic must equal ELF_MAGIC），如果合法就向下执行，用readseg函数读取扇区到内存里。
```
    struct proghdr *ph, *eph;

    // load each program segment (ignores ph flags)
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    for (; ph < eph; ph ++) {
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    }

    // call the entry point from the ELF header
    // note: does not return
    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();
```
用ph指针指向第一个要读取的磁盘扇区，eph指针指向最后一个扇区的头部，用readseg函数迭代一直读，直到结束。