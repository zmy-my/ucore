# OS第一次实验报告
---
【姓名】任慧垚
【学号】1911561

## exercise 3

### 使用A20Gate的原因
由于原先的数据传输地址为16位地址加上偏移量来完成，当寻址超过1mb,会发生回卷。后来增加了地址线，可以寻址20位以上的地址，这样之前发生回卷的地址，现在不会发生回卷，造成寻址错误。为了使其可以向下兼容，因此出现A20Gate,来模仿其回卷特性。

---
### A20使能
代码及分析如下
```
    # Enable A20:
    #  For backwards compatibility with the earliest PCs, physical
    #  address line 20 is tied low, so that addresses higher than
    #  1MB wrap around to zero by default. This code undoes this.
seta20.1:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.1
```
检测io是否结束，未结束则继续检测
```
    movb $0xd1, %al                                 # 0xd1 -> port 0x64
    outb %al, $0x64                                 # 0xd1 means: write data to 8042's P2 port
```
将0xd1指令发送至0x64端口
```
seta20.2:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.2
```
检测io是否结束，未结束则继续检测
```
    movb $0xdf, %al                                 # 0xdf -> port 0x60
    outb %al, $0x60                                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1
```
向0x60端口发送0x6f指令，使得A20使能

###初始化GDT表
```
lgdt gdtdesc
```
---
### 进入保护模式
通过将cr0寄存器PE位置1便开启了保护模式

cr0的第0位为1表示处于保护模式

```
    movl %cr0, %eax
    orl $CR0_PE_ON, %eax
    movl %eax, %cr0
```
进入保护模式后，对各寄存器进行初始化

---

## exercise 6
### 2
```c++
void
idt_init(void) {
     /* LAB1 YOUR CODE : STEP 2 */
     /* (1) Where are the entry addrs of each Interrupt Service Routine (ISR)?
      *     All ISR's entry addrs are stored in __vectors. where is uintptr_t __vectors[] ?
      *     __vectors[] is in kern/trap/vector.S which is produced by tools/vector.c
      *     (try "make" command in lab1, then you will find vector.S in kern/trap DIR)
      *     You can use  "extern uintptr_t __vectors[];" to define this extern variable which will be used later.
      * (2) Now you should setup the entries of ISR in Interrupt Description Table (IDT).
      *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	for(int i=0;i<256;i++){
		SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL)
	}
	lidt(&idt_pd);
}
```
按照提示进行编码。首先获得__vectors变量。
在trap.c中定义了idt[256],所以用循环将每个idt赋值。根据实验指导书中的提示，使用mmu.h中的宏SETGATE来填充idt数组的内容。

SETGATE定义：
```c
/* *
 * Set up a normal interrupt/trap gate descriptor
 *   - istrap: 1 for a trap (= exception) gate, 0 for an interrupt gate
 *   - sel: Code segment selector for interrupt/trap handler
 *   - off: Offset in code segment for interrupt/trap handler
 *   - dpl: Descriptor Privilege Level - the privilege level required
 *          for software to invoke this interrupt/trap gate explicitly
 *          using an int instruction.
 * */
#define SETGATE(gate, istrap, sel, off, dpl) 
```
参数gate为目标地址，调用时将其赋值为idt[i];

参数istrap表示是否为特权切换，本题不涉及此内容，因此设为false；

参数sel表示段选择子,在vectors.s的开头可以看出中断地址设置在代码段，且特权等级为DPL_KERNEL，因此参数选择GD_KTEXT；

参数off为偏移量，在__vectors中存储；

参数dpl为特权等级，本联系中应设为DPL_KERNEL。

### 3
代码如下
```c
ticks+=1;
	if(ticks%TICK_NUM==0){
		print_ticks();	
	}
```