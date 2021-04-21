# Lab2

## 实验目的

1、理解基于段页式内存地址的转换机制

2、理解页表的建立和使用方法

3、理解物理内存的管理方法

## 一些笔记
#### 与lab1的区别：

1、bootloader增加了物理内存资源探测，以便于后续根据探测出的情况进行物理内存管理初始化。

2、增加kern_entry函数，为执行kern_init建立一个运行环境，且建立段映射关系。

#### 重点：

bootasm.S中内存探测（从probe_memory到finish_probe的代码）

管理每个物理页的Page数据结构（在mm/memlayout.h中）

实现连续物理内存分配算法的物理内存页管理器框架pmm_manager

设定二级页表和建立页表项以完成虚实地址映射关系boot_map_segment函数、get_pte函数

#### 内存探测：
本实验采用中断获取内存布局（e820h），e820h必须在实模式下进行探测，因此在bootloader进入保护模式前进行。

e820map结构：
```c
struct e820map {
    int nr_map;
    struct {
        uint64_t addr;
        uint64_t size;
        uint32_t type;
    } __attribute__((packed)) map[E820MAX];
};
```
```c
probe_memory:
    movl $0, 0x8000 //0x8000处存放探测出的内存布局结构e820map
    xorl %ebx, %ebx //ebx=0
    movw $0x8004, %di
start_probe:
    movl $0xE820, %eax //eax:e820h INT15的中断调用参数
    movl $20, %ecx //保存地址范围描述符的内存大小,应该大于等于20字节
    movl $SMAP, %edx //这只是一个签名而已
    int $0x15 //若INT 15中断执行成功，则CF不置位，否则置位
    jnc cont // CF=0,探测成功则跳转到cont
    movw $12345, 0x8000 //探测失败则直接结束探测
    jmp finish_probe
cont:
    addw $20, %di //递增（+20）
    incl 0x8000 //自增
    cmpl $0, %ebx //如果是第一次调用或内存区域扫描完毕，则为0。 如果不是，则存放上次调用之后的计数值
    jnz start_probe
finish_probe:
```
#### Page物理页
4KB
```c
/* *
 * struct Page - Page descriptor structures. Each Page describes one
 * physical page. In kern/mm/pmm.h, you can find lots of useful functions
 * that convert Page to other data types, such as phyical address.
 * */
struct Page {
    int ref;                        // page frame's reference counter
    //这个页被页表的引用记数，也就是映射此物理页的虚拟页个数
    uint32_t flags;                 // array of flags that describe the status of the page frame
    //此物理页的状态标记,1的时候,代表这一页是free状态，可以被分配，但不能对它进行释放；如果为0，那么说明这个页已经分配了，不能被分配，但是可以被释放掉
    unsigned int property;          // the num of free block, used in first fit pm manager
    //用来记录某连续空闲页的数量，这里需要注意的是用到此成员变量的这个Page一定是连续内存块的开始地址
    list_entry_t page_link;         // free list link
    //把多个连续内存空闲块链接在一起的双向链表指针,用到此变量的同样是连续空闲块的第一个
};
```
另外，用一个数据结构free_area_t来管理空闲块：
```c
/* free_area_t - maintains a doubly linked list 双向链表指针to record free (unused) pages */
typedef struct {
    list_entry_t free_list;         // the list header
    unsigned int nr_free;           // # of free pages in this free list
    //当前空闲页个数
} free_area_t;
```
#### 管理页级物理内存空间所需的Page结构的内存空间从哪里开始，占多大空间？

从0开始。

npage = maxpa / PGSIZE

sizeof(struct Page) * npage

#### 空闲内存空间的起始地址在哪里？

pages是Page结构占用的空间，是加载ucore结束的地址大小按照页划分（向上取整），
从地址0到地址pages+ sizeof(struct Page) * npage)结束的物理内存空间设定为已占用物理内存空间，以上的空间为空闲物理内存空间，空闲空间起始地址为
```c
uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
```
要标识处空间的空闲状态，先把所有的page都标识为占用（flags），再探测空闲物理空间，将空闲的空间标识为空闲（init_memmap),并且加到空闲链表里。

## 练习三

### 题目

释放一个包含某虚地址的物理内存页时，需要让对应此物理内存页的管理数据结构Page做相关的清除处理，使得此物理内存页成为空闲；另外还需把表示虚地址与物理地址对应关系的二级页表项清除，查看和理解page_remove_pte函数中的注释。补全在 kern/mm/pmm.c中的page_remove_pte函数。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

1、数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

2、如果希望虚拟地址与物理地址相等，则需要如何修改lab2，完成此事？ 鼓励通过编程来具体完成这个问题

### 代码段
```
//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
    /* LAB2 EXERCISE 3: YOUR CODE
     *
     * Please check if ptep is valid, and tlb must be manually updated if mapping is updated
     *
     * Maybe you want help comment, BELOW comments can help you finish the code
     *
     * Some Useful MACROs and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   struct Page *page pte2page(*ptep): get the according page from the value of a ptep
     *   free_page : free a page
     *   page_ref_dec(page) : decrease page->ref. NOTICE: ff page->ref == 0 , then this page should be free.
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
#if 0
    if (0) {                      //(1) check if this page table entry is present
        struct Page *page = NULL; //(2) find corresponding page to pte
                                  //(3) decrease page reference
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
```
