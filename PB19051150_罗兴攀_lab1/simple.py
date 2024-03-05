import m5
from m5.objects import *
#其他对象的父对象
system=System()
#设置时钟
system.clk_domain=SrcClockDomain()
#时钟频率
system.clk_domain.clock = '1GHz'
#设置电压域为默认
system.clk_domain.voltage_domain = VoltageDomain()
#时序模式模拟内存
system.mem_mode = 'timing'
#单个内存大小为512MB
system.mem_ranges = [AddrRange('512MB')]
#创建CPU
#system.cpu=X86TimingSimpleCPU() #官方文档给的写法，无法找到X86TimingSimpleCPU()
system.cpu =TimingSimpleCPU()
#创建内存总线
system.membus = SystemXBar()
#本次模拟没有缓存，故直接将I-cache和D-cache端口直接连接到membus
system.cpu.icache_port = system.membus.cpu_side_ports
system.cpu.dcache_port = system.membus.cpu_side_ports
#将PIO和中断端口连接到内存总线，这是X86的特定要求
system.cpu.createInterruptController()
system.cpu.interrupts[0].pio = system.membus.mem_side_ports
system.cpu.interrupts[0].int_requestor = system.membus.cpu_side_ports
system.cpu.interrupts[0].int_responder = system.membus.mem_side_ports
system.system_port = system.membus.cpu_side_ports
#创建一个内存控制器并将其连接到内存总线
system.mem_ctrl = MemCtrl()
system.mem_ctrl.dram = DDR3_1600_8x8()
system.mem_ctrl.dram.range = system.mem_ranges[0]
system.mem_ctrl.port = system.membus.mem_side_ports
#完整系统仿真（FS）和系统调用仿真（SE）
"""
* 如果不需要对操作系统建模，而是想要专注于模拟CPU和内存系统，建议使用SE模式。
* 如果需要系统的高保真建模，应该使用FS模式。
* SE模式更容易配置，性能更好
"""
#使用SE模式仿真
#要运行的程序地址
binary = 'tests/test-progs/hello/bin/x86/linux/hello'
# for gem5 V21 and beyond
system.workload = SEWorkload.init_compatible(binary)
process = Process()
process.cmd = [binary]
system.cpu.workload = process
system.cpu.createThreads()
#实例化系统并开始执行
root = Root(full_system = False, system = system)
m5.instantiate()
#开始实际的模拟
print("Beginning simulation!")
exit_event = m5.simulate()
#检查系统的状态
print('Exiting @ tick {} because {}'
      .format(m5.curTick(), exit_event.getCause()))