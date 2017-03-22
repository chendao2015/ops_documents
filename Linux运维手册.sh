				Linux运维手册
		
0 说明{

		手册制作：忘情
		更新日期：2017-03-22
		
		欢迎加入“shell/python运维开发群”，QQ群号：323779636
		
		请使用“notepad++”或其它编辑器打开此手册，“alt+0”将函数折叠后方便查阅
		请勿删除信息，转载请注明出处，抑制不道德行为
		错误在所难免，若发现错误欢迎告知我改正！
		
		github更新下载地址：	https://github.com/chendao2015/ops_documents
}

1 设备{
	/proc/cpuinfo：查看CPU信息
	lsusb：查看USB信息
	lspci：查看PCI接口信息
	hal-device：Hardware Abstract Layer，硬件抽象层
	
	终端类型{
		console：控制台
		pty：物理终端，也叫物理控制台（VGA）
		tty#：虚拟终端，附属在物理控制台上虚拟出来的（VGA）
		ttyS#：串行终端，一个字符一个字符显示出来的
		pts/#：伪终端，远程登录的
	}
	
	设备类型{
		块设备：按块为单位，随机访问的设备
		字符设备：按字符为单位，线性设备，如鼠标键盘
	}
	
	创建设备文件{
		mknod [option]... name type [maior minor]
		option{
			-m mode
		}
	}	
	
	磁盘管理{
		硬盘设备的设备接口类型{
			IDE：并行
			SATA：串行
			USB：串行
			SCSI：并行
			SAS：串行的SCSI硬盘，体积比SCSI硬盘小，容量小，转速快
		}
	
		硬盘设备的设备文件名{
			IDE(ATA)：hd{
				第一个IDE口：主盘(hda)、从盘(hdb)
				第二个IDE口：主盘(hdc)、从盘(hdd)
			}
			SATA：sd
			SCSI：sd
			USB：sd
			
			a,b,c,...来区别同一种类型下的不同设备
		}
	
		查看当前系统识别了几块硬盘{
			fdisk -l [/dev/to/some_device_file]
		}
		
		管理磁盘分区{分区管理工具主要有：fdisk、parted和sfdisk
			fdisk{对于一块硬盘来说，最多只能管理15个分区
				语法{
					fdisk [options] <device>
					fdisk -l [device]
				}
				fdisk /dev/sda{
					p：显示当前硬盘的分区，包括没保存的改动
					n：创建新分区{
						e：扩展分区
						p：主分区
					}
					d：删除一个分区
					w：保存退出
					q：不保存退出
					t：修改分区类型{
						L：显示所支持的所有类型
					}
					l：显示所支持的所有类型
				}
				通知内核重新读取硬盘分区表{
					用fdisk命令创建分区后要重读一下分区表，让内核可以识别刚刚创建的分区。内核可以识别的分区信息保存在/proc/partitions文件中
					partx{
						partx -a /dev/device{
							-n M:N
						}
					}
					
					kpartx{
						kpartx -a /dev/device{
							-f：force
						}
					}
					
					Centos5使用partprobe命令{
						partprobe [/dev/device]
					}					
				}
				
			}
		}
	
		Raid{独立冗余磁盘阵列
			raid级别{仅代表磁盘组织方式不同，没有上下之分
				0：条带，整个逻辑盘的数据被分条分布在多个硬盘上，可以并行读/写，提供最快的速度，无冗余、容错能力，至少要2块硬盘，硬盘利用率100%
				1：镜像，n+n，至少要2块硬盘，1块硬盘做数据存储，1块硬盘做镜像，写性能下降，读性能提升，只允许损坏一块硬盘，硬盘利用率为1/2
				5：校验码，n+1，至少要3块硬盘，2块硬盘做数据存储，1块硬盘做校验，读写均提升，只允许损坏一块硬盘，硬盘利用率为(n-1)/n
				6：校验码，n+2，至少要4块硬盘，2块硬盘做数据存储，2块硬盘做校验，读写均提升，允许损坏两块硬盘，硬盘利用率为(n-2)/n
				1+0：先做镜像，再做条带，至少要4块硬盘，可以提高读/写能力，数据相同的硬盘只允许损坏一块，硬盘利用率为1/2
				0+1：先做条带，再做镜像，至少要4块硬盘，可以提高读/写能力，数据相同的硬盘只允许损坏一块，硬盘利用率为1/2
				5+0：先做校验，再做条带，至少要6块硬盘，可以提高读/写能力，允许损坏2块硬盘，硬盘利用率为(n-2)/n
			}
			
			raid实现的方式{
				外接式磁盘阵列：通过扩展卡提供适配能力
				内接式RAID：主板集成RAID控制器
				软件RAID：要把RAID的硬盘分区类型设为fd
			}
			
			raid类型{
				硬件RAID
				软件RAID：记得要把做RAID的硬盘分区类型设为fd
				/proc/mdstat中保存着所有系统中已经启用的RAID设备的情况
			}
			
			mdadm（multi disk admin）{将任何块设备做成RAID，是一个用户空间工具，管理工具。基于内核的md模块（multi devices）
				语法{
					mdadm [mode] <raiddevice> [options] <component-devices>
						<raiddevice>：/dev/md#
						<component-devices>：任意块设备
				}
				
				mdadm支持的RAID级别{
					LINEAR
					RAID0
					RAID1
					RAID4
					RAID5
					RAID6
					RAID10
				}
				
				mdadm模式{mdadm是一个模式化的命令
					创建模式：-C 设备名{
						-l：级别
						-n #：设备个数，使用#个块设备来创建些raid
						-a {yes|no}：是否自动为其创建设备文件
						-c：CHUNK大小，2^n，默认为64k
						-x #：指定空闲盘个数
					}					
					管理模式：--add，--remove，--fail{
						mdadm /dev/md# --fail /dev/sd1    （把md#阵列中的/dev/sd1硬盘标记为损坏）
						mdadm /dev/md# --remove /dev/sd1    （把sd1从md#阵列中移除）
						mdadm /dev/md# --add /dev/sd1    （把sd1添加到md#阵列）
					}					
					监控模式：-F
					增长模式：-G
					装配模式：-A{
						mdadm -A /dev/md#
					} 
				}
				
				查看RAID阵列的详细信息{
					mdadm -D /dev/md#
				}
				 
				停止阵列{
					mdadm -S /dev/md#
				}
				
				将当前RAID信息保存至配置文件，以便以后进行装配{
					mdadm -D --scan > /etc/mdadm.conf
				}
			}
			
		}
	
		Jbod：将多块硬盘连在一起，逻辑上组成一个硬盘，这种技术只能提高硬盘的容量，不能提高读/写速度，也不能做冗余，其中任何一块硬盘损坏数据都会丢失
		MD：Multi Device，多设备，是一种实现逻辑设备的机制。主要领域是软RAID
		DM：Device Mapper，设备映射，是一种实现逻辑设备的机制。主要领域是LVM
		
	}
	
	设备挂载{将新的文件系统关联至当前根文件系统
		mount{
			语法：mount [options] [-o options] 设备 挂载点
			{
				-a：表示重新挂载/etc/fstab文件中指定的所有的文件系统
				-n：默认情况下，mount命令每挂载一个设备，都会把挂载的设备信息保存至/etc/mtab文件中。使用-n选项意味着挂载设备时不把信息写入/etc/mtab文件。
				-t VFSTYPE：指定正在挂载的设备上的文件系统的类型。不使用此选项时，mount会调用blkid命令获取对应文件系统的类型
				-r：只读挂载，挂载光盘时常用此选项
				-w：读写挂载 
				-L 'LABLE'：根据卷标进行挂载
				-U 'UUID'：根据UUID进行挂载
				-B，--bind：绑定目录到另一个目录上
				-o：指定额外的挂载选项，也即指定文件系统启用的属性。{
					async：异步模式挂载。文件被修改后不立即同步，由内核来决定何时同步到硬盘。一般推荐使用此种模式挂载
					sync：同步模式挂载。文件被修改后立即同步到硬盘的模式。同步模式数据安全性高，但性能很差
					atime/noatime：每个文件和目录被访问时更新/不更新访问时间戳。默认情况下使用的是atime{
						一般建议使用noatime，降低磁盘IO
						因为时间戳是保存在磁盘中的，而有些文件可能被经常性的访问，若每次访问都更新时间戳则会增加IO操作
					}
					diratime/nodiratime：每个目录被访问时更新/不更新访问时间戳
					auto/noauto：是否支持自动挂载。默认为auto
					exec/noexec：是否支持将文件系统上的应用程序运行为进程
					dev/nodev：是否支持在此文件系统上使用设备文件、激活设备文件
					suid/nosuid：是否支持suid
					remount：重新挂载当前文件系统
					ro：挂载为只读
					rw：读写挂载
					user/nouser：是否允许普通用户挂载此设备。默认情况下只有管理员有权限挂载设备
					acl：启用此文件系统上的acl功能。centos7默认已启用
					loop：挂载本地回环设备，常用来挂载ISO镜像文件
				}
				注意{
					上述选项可多个同时使用，彼此使用逗号分隔
					默认挂载选项：defaults{
						rw、suid、dev、exec、auto、nouser、async
					}
				}
			}
			
			mount命令不带任何参数能通过查看/etc/mtab文件来显示当前系统中已挂载的设备及挂载点信息{
				设备：
					设备文件：/dev/sda5
					卷标：LABEL=""
					UUID：UUID=""
					伪文件系统名称：proc、sysfs、devtmpfs、configfs
					
				挂载点：
					要求：
					a) 此目录没有被其它进程使用
					b) 目录必须事先存在
					c) 目录中原有的文件将会暂时隐藏，卸载后可见
			}
			
			当前文件系统的挂载信息存在两个文件中{
				/etc/mtab
				/proc/mounts
				
				使用mount -n选项时，挂载信息不会写入/etc/mtab，但可以在/proc/mounts中找到
			}
		}
		
		挂载交换分区{
			启用：swapon [options]... [device]
				-a：激活所有的交换分区，使用此选项后面不需跟device
				-p PRIORITY：指定优先级 
			禁用：swapoff [options]... [device]
		}
		
		卸载{将某文件系统与当前根文件系统的关联关系予以移除
			umount{
				语法{
					umount 设备
					umount 挂载点
				}
				卸载注意事项{
					挂载的设备必须没有被进程使用
				}
			}
			
			fuser{验证进程正在使用的文件或套接字文件
				-v：查看某文件上正在运行的进程
				-km 挂载点：终止正在访问此挂载点的所有进程
			}
		}
		
	}
	
	
}

2 文件系统{
	rootfs：根文件系统
	
	FHS：文件层级系统{
		/：可以单独分区，LVM分区
		/boot：系统启动相关的文件，如内核（vmlinuz）、initrd（initramfs），以及grub（bootloader）。建议单独分区，基本分区
		/dev：设备文件。不能单独分区{
			设备文件：关联至一个设备驱动程序，进而能够与之对应硬件设备进行通信{
				块设备：随机访问，数据块（比如硬盘）
				字符设备：也叫线性设备，线性访问，按字符为单位（比如鼠标、显示器）
				设备号：主设备号（major）和次设备号（minor）{
					主设备号标识设备类型
					次设备号标识同一类型下的不同设备
				}
			}
			设备文件只有元数据，没有数据
		}
		/etc：配置文件
		/home：用户的家目录，每一个用户的家目录通常默认为/home/USERNAME。建议单独分区
		/root：管理员的家目录，没有也没关系。不该单独分区
		/lib：库文件{
			静态库：.a
			动态库：.dll,.so(shared object)
			/lib/modules：内核模块文件
		}
		/media：挂载点目录，通常用来挂载移动设备
		/mnt：挂载点目录，通常用来挂载额外的临时文件系统，比如另一块硬盘
		/opt：可选目录，早期通常用来安装第三方程序
		/proc：伪文件系统，内核映射文件（伪文件系统实际上里面是没有任何内容的，开机之后才映射上去的）。不能单独分区
		/sys：伪文件系统，跟硬件设备相关的属性映射文件（伪文件系统实际上里面是没有任何内容的，开机之后才映射上去的）。不能单独分区
		/tmp：临时文件,/var/tmp
		/var：可变化的文件，比如log、cache。存放日志信息、pid文件、lock文件，建议单独分区
		/bin：可执行文件，用户命令
		/sbin：管理命令
		/usr：shared,read-only，全局共享只读文件。提供操作系统核心功能，可以单独分区{
			/usr/bin
			/usr/sbin
			/usr/lib
		}
		/usr/local：第三方软件安装路径{
			/usr/local/bin
			/usr/local/sbin
			/usr/local/lib
			/usr/local/etc
			/usr/local/man
		}
		
		/etc，/bin，/sbin，/lib内是系统启动就需要用到的程序，这些目录不能挂载额外的分区，必须在根文件系统的分区上
		/usr/bin，/usr/sbin，/usr/lib提供操作系统核心功能，/usr可以单独分区
		/usr/local/bin，/usr/local/sbin，/usr/local/lib，/usr/local/etc，/usr/local/man等等在/usr/local目录下的内容都是第三方软件，建议单独分区
	}
	
	mkfs{make file system
		mkfs命令两种创建文件系统的方式{
			mkfs.FSTYPE /dev/DEVICE
			mkfs -t FSTYPE /dev/DEVICE
		}
		mkfs命令常用的选项{
			-L "LABLE"：设定卷标
		}
	}
	
	mke2fs{专门管理ext系列文件系统的工具
		-j：创建ext3类型文件系统
		-b BLOCK_SIZE：指定块大小，默认为4096，可用取值为1024、2048或4096
		-L LABEL：指定分区卷标
		-m #：指定预留给超级用户的块数百分比，#代表数字，#为10表示10%
		-i inode_size：指定为多少字节的空间创建一个inode，默认为8192，这里给出的数值应该为块大小的2^n倍
		-N #：指定inode个数
		-O FEATURE [,....]：启用指定特性
		-O ^FEATURE [,...]：关闭指定特性
		-F：强制创建文件系统
		-E：用于指定额外的文件系统属性
	}
	
	blkid{查询或查看磁盘设备的相关属性，例：blkid /dev/sda5
		可以查看UUID、TYPE、LABEL等信息
		-U UUID：根据UUID查找对应的设备
		-L LABLE：根据LABLE查找对应的设备	
	}
	
	e2label{用于查看或定义卷标，例：e2label /dev/sda5 mydata
		e2label 设备文件 卷标
	}
	
	tune2fs{调整ext系列文件系统的相关属性
		在需要重新创建文件系统的情况下，如果直接重新创建文件系统会损坏原有文件，这个时候就需要用到调整文件系统属性的命令tune2fs了
		-j：不损坏原有数据，将ex2升级为ext3
		-L LABEL：设定或修改卷标
		-m #：调整预留给超级用户的块数百分比，#代表数字，#为10表示10%
		-r #：指定预留给超级用户的块数，#代表数字，#为10表示10块
		-O：文件系统属性启用或禁用{
			-O FEATURE [,....]：启用指定特性
			-O ^FEATURE [,...]：关闭指定特性
		}
		-o：设定默认挂载选项
		-c #：指定挂载次数达到#次之后进行自检，0或-1表示关闭此功能
		-i #：每挂载使用#天以后进行自检，0或-1表示关闭此功能
		-l：显示文件系统超级块中的信息		
	}
	
	dumpe2fs{显示文件系统属性信息
		-h：只显示超级块信息
	}
	
	fsck{检查并修复Linux文件系统
		-t FSTYPE：指定文件系统类型
		-a：自动修复
		-r：交互式修复
	}
	
	e2fsck{专用于修复ext2/ext3文件系统
		-y：自动回答yes
		-f：强制检查
		-p：自动修复		
	}	
}

3 内核/编译{
	内核{
		内核设计风格{
			单内核：把所有功能全部做进内核。不论哪个模块损坏都会影响到整个系统的正常工作。引用微内核的模块化设计{
				linux是单内核的，linux中的线程被称作轻量级进程(LWP)。内核由核心与内核模块组成
				核心：/boot/vmlinuz-version
				内核模块：ko（kernel object）动态加载外围内核模块，/lib/modules/内核版本号命名的目录
			}
			微内核：只有一个核心，把所有功能做成子系统，需要用到哪个功能就去调度这个子系统。看起来更安全，某个子系统损坏不影响其他子系统工作。{
				windows，solaris是微内核的，微内核是真正意义上的支持线程的
			}
			ldd：显示共享库依赖关系
		}
		内核模块管理{
			lsmod：显示当前系统中有哪些内核模块
			insmod /PATH/TO/MODULE_FILE：装载某模块
			rmmod MOD_NAME：卸载某模块
			modprobe{模块管理工具
				modprobe MOD_NAME：装载某模块
				modprobe -r MOD_NAME：卸载某模块
			}
			depmod /PATH/TO/MODULES_DIR：生成模块依赖关系并保存在此模块目录当中
			modinfo MOD_NAME：查看模块的具体信息
		
			内核模块位置：/lib/modules/KERNEL_VERSION/
		}
	
		内核中的功能除了核心功能之外，在编译时，大多功能都有以下三种选择{
			a) 不使用此功能
			b) 编译成内核模块
			c) 编译进内核
		}
	
		用户空间访问、监控内核的方式{	通过查看或修改/proc、/sys目录中的某些文件来访问、监控、设定内核参数
			/proc/sys：此目录中的很多文件是可读写的{
				echo 1 > /proc/sys/vm/drop_caches表示清除page cache
				echo 2 > /proc/sys/vm/drop_caches表示清除回收slab分配器中的对象（包括目录项缓存和inode缓存）
				echo 3 > /proc/sys/vm/drop_caches表示清除page cache和slab分配器中的缓存对象
				slab分配器是内核中管理内存的一种机制，其中很多缓存数据实现都是用的page cache
			}
			/sys：此目录中的某些文件是可写的
		}
	
		设定内核参数值的方法{
			echo value > /proc/sys/TO/SOMEFILE
			sysctl -w kernel.hostname="xx"    表示设定/proc/sys/kernel/hostname文件的内容为xx
			以上两种设定内核参数的方法能立即生效，但无法永久有效，主机重启后会失效。
			要想永久有效要个性配置文件/etc/sysctl.conf，修改配置文件能永久有效但不是立即生效，要想立即生效需要执行sysctl -p命令重读配置文件。
			sysctl -p：重读/etc/sysctl.conf文件
			sysctl -a：显示所有内核参数及其值
		}
	
		内核优化{
			/proc/sys/kernel/hostname：设定主机名
			/proc/sys/net/ipv4/ip_forward：设定路由转发
			/proc/sys/vm/drop_caches：是否清空内存缓冲、缓存区
		}
	}
	
	编译{
		内核编译{
			a) 安装编译、开发环境（yum -y groupinstall "development libraries" "development tools"）
			b) 下载内核文件（www.kernel.org）
			c) 解压内核至/usr/src下并链接为/usr/src/linux
			d) 拷贝/boot/config-version文件至/usr/src/linux/.config
			e) 进入/usr/src/linux目录中执行make menuconfig命令
			f) 执行make命令
			g) 执行make bzImage命令生成内核文件vmlinuz
			h) 执行make modules命令编译模块
			i) 执行make modules_install命令安装内核模块
			j) 执行make install命令
			
			内核模块安装位置：/lib/modules/KERNEL_VERSION/
		}
	
		busybox编译{
			a) 下载busybox源码解压并进入解压后的目录中
			b) 执行make menuconfig命令选择要编译的模块
			c) 执行make install
			
			busybox不支持运行级别。
		}
	
		initrd或initramfs文件生成{	mkinitrd initrd文件路径 内核版本号
			mkinitrd /boot/initrd-`uname -r`.img `uname -r`
		}
	
		展开系统中的initrd文件至当前目录{
			zcat /boot/initrd-version.img | cpio -id
		}
		
		修改好init脚本以后重新压缩initrd文件{
			find . |cpio -H newc --quiet -o | gzip -9 >/path/to/initrd.gz
		}
	
		二次编译时清理，清理前，如果有需要，请先备份.config文件{
			make clean
			make mrproper
		}
	
		部分编译{
			只编译某子目录下的相关代码{
				语法：make DIR/
				如：make drivers/net/	表示只编译网络驱动相关的代码
			}
			只编译部分模块{
				make M=drivers/net/
			}
			只编译某一个模块{
				make drivers/net/pcnet32.ko
			}
			将编译完成的结果放置于别的目录中{
				make O=/tmp/kernel
			}
			交叉编译{
				make ARCH=arm(目标平台类型)
			}
		}
	
	}
}

4 bash{
	bash支持的引号{
		``：反引号，命令替换
		""：双引号，弱引用，可以实现变量替换
		''：单引号，强引用，不完成变量替换
	}

	光标跳转{
		Ctrl+a：跳到命令行首
		Ctrl+e：跳到命令行尾
		Ctrl+u：删除光标至命令行首的内容
		Ctrl+k：删除光标至命令行尾的内容
		Ctrl+<--：光标定位到离自己最近的一个单词前面
		Ctrl+l：清屏
	}
	
	命令历史{
		history{
			-c：清空命令历史
			-d OFFSET [n]：删除指定位置的命令历史，如history -d 500就是删除命令历史中的第500条命令的历史
			-w：保存命令历史至历史文件（~/.bash_history）中
		}
		
		命令历史的使用技巧{
			!n：执行命令历史中的第n条命令
			!-n：执行命令历史中倒数第n条命令
			!!：执行上一条命令
			!string：执行命令历史中最近一个以指定字符串开头的命令
			!$：引用前一个命令的最后一个参数
			esc,.：按下esc松开后按“.“点号，引用前一个命令的最后一个参数
		}
		
		控制命令历史的记录方式{
			环境变量HISTCONTROL{
				ignoredups：忽略重复的命令（连续且相同方为”重复“）
				ignorespace：忽略所有以空格开头的命令，如” ls -l“
				ignoreboth：ignoredups和ignorespace均生效
			}
			修改环境变量HISTCONTROL值的方式{
				export HISTCONTROL=ignoreboth
			}
		}
	}
	
	命令补全{
		搜索PATH环境变量所指定的每个路径下以我们给出的字符串开头的可执行文件，如果多于一个，两次tab，可以给出列表，否则将直接补全
	}
	
	路径补全{
		搜索我们给出的起始路径下的每个文件名，并试图补全
	}
	
	环境变量{
		HISTCONTROL：控制命令历史的记录方式
		HISTSIZE：命令历史缓冲区大小
		PATH：命令搜索路径
		SHELL：当前正在使用的shell
		RANDOM：保存着0-32768之间的随机数
	}
	
	命令别名{
		alias CMDALIAS='COMMAND [options] [arguments]'
		在shell中定义的别名仅在当前shell生命周期中有效，别名的有效范围为当前的shell进程。
	}
	
	命令替换{
		$(COMMAND)或`COMMAND`
		把命令中某个子命令替换为其执行结果的过程，就叫做命令替换
	}
	
	文件名通配（glob）{
		*：匹配任意长度的任意字符
		?：匹配任意单个字符
		[]：匹配指定范围内的任意单个字符{
			[abc]，[a-m]，[0-9]
			[[:space:]]    表示空白字符
			[[:punct:]]    表示标点符号
			[[:lower:]]    表示小写字母
			[[:upper:]]    表示大写字母
			[[:alpha:]]    表示大小写字母
			[[:digit:]]    表示数字
			[[:alnum:]]    表示数字和大小写字母
			使用man 7 glob命令可以获得以上字符集合的帮助信息！！！
		}
		[^]：匹配指定范围之外的任意单个字符
	}
	
	随机数生成器：熵池{
		/dev/random：这里生成的随机数用尽时会阻塞用户进程，待生成更多的随机数里即恢复，比较安全
		/dev/urandom：这里生成的随机数用尽时会通过软件模拟生成更多的随机数进来，不会阻塞用户进程，比较好用
	}

	截取变量的字符串{
		FILE=/usr/local/src
		echo ${FILE#*/}    结果为    usr/local/src
		echo ${FILE##*/}    结果为    src
		echo ${FILE%/*}    结果为    /usr/local
		echo ${FILE%%/*}    结果为    /usr
	}
	
}

5 系统管理{
	type{显示指定命令属于哪种类型
		type COMMAND
	}

	file{显示指定文件的文件类型
		file /path/to/file
	}
	
	date{时间管理
		
	}
	
	whatis{查看指定命令在man手册的哪一章节中
		whatis COMMAND，如whatis ls
	}
	
	man{命令的帮助手册
		语法：man COMMAND
		man是分章节的，每章节包含的内容介绍{
			第1章：用户命令（如/bin，/usr/bin，/usr/local/bin等）
			第2章：系统调用
			第3章：库调用
			第4章：特殊文件（设备文件）
			第5章：文件格式（配置文件的语法）
			第6章：游戏
			第7章：杂项（Miscellaneous）
			第8章：管理命令（如/sbin，/usr/sbin，/usr/local/sbin等）
		}
		man手册注意事项{
			[]：可选
			<>：必选
			...：可以出现多次
			|：多选一
			{}：分组
			NAME：命令名称及功能简要说明
			SYNOPSIS：用法说明，包括可用的选项
			DESCRIPTION：命令功能的详尽说明，可能包括每一个选项的意义
			OPTIONS：说明每一个选项的意义
			FILES：此命令相关的配置文件
			BUGS：报告bug
			EXAMPLES：使用示例
			SEE ALSO：另外参照
		}
		man翻屏{
			SPACE：空格，向后翻一屏
			b：向前翻一屏
			enter：向后翻一行
			k：向前翻一行
		}
		man查找{
			/KEYWORD：向后查找匹配指定关键字的内容
			?/KEYWORD：向前查找匹配指定关键字的内容
			n：定位到下一个匹配的关键字
			N：定位到前一个匹配的关键字
			q：退出
		}
		man手册放置的位置{
			/usr/share/doc
		}
	}

	du{显示目录下每个文件占用的空间大小
		-s：只显示整个目录包括子目录所占的空间总大小
		-h：单位换算
	}
	
	df{报告文件系统磁盘空间使用情况
		-h：单位换算
		-i：显示inode情况。不加-i选项默认是统计磁盘块使用情况
		-P：显示时不换行
	}
	
	watch{周期性地执行指定命令，并以全屏方式显示结果
		-n #：指定周期长度，单位为秒，默认为2秒
		格式：watch -n # 'COMMAND'
	}
	
}

6 文件{
	touch{
		语法：touch /path/to/file
		若文件不存在才创建文件，否则修改该文件的时间戳
	}
	
	stat{
		显示文件或文件系统的状态
	}
	
	rm{
		删除文件，删除命令默认会提示是否需要删除，如果要使用命令本身可以在命令前加一个\，如\rm，这样删除就不会有提示了
	}
	
	cp{复制文件，一个文件到一个文件，多个文件到一个目录
		-a：归档复制，常用于备份
		-r：递归复制
	}
	
	mv{移动文件/目录
	
	}
	
	install{复制文件并且设置属性
		
	}
	
	mktemp{创建临时文件或目录，默认创建为文件
		语法：mktemp [options] /tmp/file.XX
		options{
			-d：创建为目录
		}
	}
	
	压缩、解压缩{
		压缩格式：gz,bz2,xz,zip,Z
		压缩算法：算法不同，压缩比也会不同
		compress{用此命令压缩的文件其文件名为FILENAME.Z
			解压用uncompress
		}
		
		gzip{
			用此命令压缩的文件其文件名为FILENAME.gz
			压缩完成后会删除原文件
			语法：gzip [options] /path/to/somefile
			options{
				-d：解压缩，解压完成后会删除原文件
				-c：将结果输出至标准输出
				-#：#用1-9代替，指定压缩比，默认为6
			}
		}
		gunzip{
			解压完成后会删除原文件
			gunzip /path/to/some_compress_file.gz
		}
		zcat{不解压的情况下查看文本文件的内容
			zcat /path/to/somefile.gz
		}
		
		bzip2{
			用此命令压缩的文件其文件名为FILENAME.bz2
			比gzip有着更大压缩比的压缩工具，使用格式近似。压缩完成后会删除原文件
			语法：bzip2 [options] /path/to/somefile
			options{
				-d：解压缩，解压完成后会删除原文件
				-#：#用1-9代替，指定压缩比，默认为6
				-k：keep,压缩时保留原文件
			}
		}
		bunzip2{
			解压完成后会删除原文件
			bunzip2 /path/to/some_compress_file.bz2
		}
		bzcat{不解压的情况下查看文本文件的内容
			bzcat /path/to/somefile.bz2
		}
		
		xz{
			用此命令压缩的文件其文件名为FILENAME.xz
			比bzip2有着更大压缩比的压缩工具，使用格式近似。压缩完成后会删除原文件
			语法：xz [options] /path/to/somefile
			options{
				-d：解压缩，解压完成后会删除原文件
				-#：#用1-9代替，指定压缩比，默认为6
				-k：keep,压缩时保留原文件
			}
		}
		unxz{
			解压完成后会删除原文件
			unxz /path/to/some_compress_file.xz
		}
		xzcat{不解压的情况下查看文本文件的内容
			xzcat /path/to/somefile.xz
		}
		
		zip{既归档又压缩的工具。zip可以压缩目录，gz、bz2、xz都只能压缩文件，zip压缩后不会删除原文件
			zip filename.zip file1 file2 ...
			zip filename.zip DIR/*
		}
		unzip{
			unzip filename.zip
		}
		
		archive：归档，归档本身并不意味着压缩{
			tar{归档工具，只归档不压缩
				-c：创建归档文件
				-C：将展开的归档文件保存至指定目录下
				-f file.tar：操作的归档文件
				-x：还原归档
				-v：显示归档过程
				-p：归档时保留权限信息。只有管理员才有权限用此选项
				--delete：从归档文件中删除文件
				--xattrs：在归档时保留文件的扩展属性信息
				
				常用的组合选项{
					-tf /path/to/file.tar：不展开归档，直接查看归档了哪些文件
					-zcf：归档并调用gzip压缩
					-zxf：调用gzip解压缩并展开归档
					
					-jcf：归档并调用bzip2压缩
					-jxf：调用bzip2解压缩并展开归档
					
					-Jcf：归档并调用xz压缩
					-Jxf：调用xz解压缩并展开归档
				}
			}
			cpio{归档工具
				
			}
		}
		
	}
	
	文件查找{在文件系统上查找符合条件的文件
		locate{
			语法：locate KEYWORD
			特点{
				非实时，模糊匹配，查找是根据全系统文件数据库进行的，查找的速度快
				依赖于事先构建的索引。索引的构建是在系统较为空闲时自动进行（周期性任务）
				手动生成文件数据库：updatedb
				索引构建过程需要遍历整个根文件系统，极消耗资源
			}
		}
		
		find{
			实时查找，精确性强，遍历指定目录中所有文件完成查找，查找速度慢，支持众多查找标准。
			语法：find [OPTION...] 查找路径 查找标准 查找到以后的处理动作{
				查找路径：默认为当前目录
				查找标准：默认为指定路径下的所有文件{
					-name 'filename'：对文件名作精确匹配.支持glob通配符机制
					-iname 'filename'：文件名匹配时不区分大小写
					-regex pattern：基于正则表达式进行文件名匹配.以pattern匹配整个文件路径字符串，而不仅仅是文件名称
					-user username：根本属主来查找
					-group groupname：根据属组来查找
					-uid：根据UID进行查找，当用户被删除以后文件的属主会变为此用户的UID
					-gid：根据GID进行查找，当用户被删除以后文件的属组会变为此用户的GID
					-nouser：查找没有属主的文件.用户被删除的情况下产生的文件，只有uid没有属主
					-nogroup：查找没有属组的文件.组被删除的情况下产生的文件，只有gid没有属组
					-type：根据文件类型来查找（f,d,c,b,l,p,s）
					-size：根据文件大小进行查找。{
						如1k、1M，+10k、+10M，-1k、-1M，+表示大于，-表示小于
						[+|-]
						#K、#M、#G
						#Unit表示（从#-1到#之间的范围大小）
						-#Unit表示（从0到#-1的范围大小）
						+#Unit表示（大于#的所有）
					}
					-mtime：修改时间
					-ctime：改变时间
					-atime：访问时间{
						+5：5天前
						-5：5天以内,6天以下
					}
					-mmin：多少分钟修改过
					-cmin：多少分钟改变过
					-amin：多少分钟访问过{
						+5：5分钟前
						-5：5分钟以内,6分钟以下
					}
					-perm mode：根据权限精确查找
					-perm -mode：文件权限能完全包含此mode时才符合条件
					-perm /mode：9位权限中有任何一位权限匹配都视为符合查找条件
					
					组合条件{
						-a
						-o
						-not
						!
						例：
							!A -a !B = !(A -o B)
							!A -o !B = !(A -a B)
					}
					
				}
				处理动作：默认为显示到屏幕上{
					-print：显示
					-ls：类似ls -l的形式显示每一个文件的详细信息
					-delete：删除查找到的文件
					-fls /path/to/somefile：查找到的所有文件的长格式信息保存至指定文件中
					-ok COMMAND {} \;：对查找到的每个文件执行COMMAND，每一次操作都需要用户确认
					-exec COMMAND {} \;：对查找到的每个文件执行COMMAND，操作不需要确认
					
					注意：find传递查找到的文件至后面指定的命令时，查找到所有符合条件的文件一次性传递给后面的命令，而有些命令不能接受过多参数，此时命令执行可能会失败。而xargs可规避此问题。
					xargs：通过管道将查找到的内容给xargs处理，xargs后面直接跟命令即可
				}
			}
		}
	
	}
	
	ln{创建硬链接/符号链接
		ln [-s -v] SRC DEST
	}
	
	
}

7 目录{
	ls{显示目录的内容
		-l：长格式{
			-rw-------. 1 root root 1175 3月  15 19:28 anaconda-ks.cfg
			第一列{-rw-------.
				第一个-表示文件类型，常见的文件类型有{
					-：普通文件（f）
					d：目录文件
					b：块设备文件（block）
					c：字符设备文件（character）
					l：符号链接文件（symbolic link file）
					p：命令管道（pipe）
					s：套接字文件（socket）
				}
				第二个到第十个-表示文件权限{
					文件权限共9位，每3位为一组，每一组：rwx（读、写、执行）
				}
			}
			第二列{1
				文件硬链接的次数
			}
			第三列{root
				文件的属主（owner）
			}
			第四列{root
				文件的属组（group）
			}
			第五列{1175
				文件的大小（size），单位是字节
			}
			第六列{3月  15 19:28
				时间戳（timestamp），最近一次被修改的时间
			}
			第七列{anaconda-ks.cfg
				文件名
			}
		}
		-h：做单位转换，以更人性化的方式显示大小
		-a：显示所有文件，包括所有以.开头的隐藏文件
		-A：显示不包括”.“和”..“的所有文件，包括所有以.开头的隐藏文件
		-d：显示目录自身属性
		-i：显示文件的inode（index node）
		-r：逆序显示
		-R：递归（recursive）显示
	}

	cd{切换目录}
	
	pwd{显示当前所在的目录}
	
	mkdir{创建空目录}
	
	rmdir{删除目录，只能删除空目录}
	
	tree{查看目录树
		-d：只显示目录
		-L level：指定显示的层级数目
		-P pattern：只显示由指定pattern匹配到的路径
	}


}

8 文本{
	查看文本{
		cat{}
		tac{
		
		}
		more{}
		less{}
		head{}
		tail{}
	}
	
	文本处理{
		cut{
			-d：指定字段分隔符，默认是空格
			-f：指定要显示的字段{
				-f 1,3    显示1和3
				-f 1-3    显示1到3
			}
		}
		join{}
		sed{}
		awk{}
	}
	
	文本排序{
		sort{默认升序排序，不是按数值大小排序的
			-n：根据数值大小进行排序
			-r：逆序排序
			-t：字段分隔符
			-k：以哪个字段为关键字进行排序
			-u：去重，排序后相同的行只显示一次
			-f：排序时忽略字符大小写
		}
		
		uniq{报告重复的行（连续且完全相同方为重复）
			-c：显示文件中行重复的次数
			-d：只显示重复的行
			-u：只显示未重复的行
		}
	}
	
	文本统计{
		wc（word count）{
			-c：显示字节数
			-l：显示行数
			-w：显示单词数
		}
	}
	
	字符处理{
		tr{转换或删除字符
			语法：tr [option]... set1 [set2]
			例如：tr 'ab' 'AB'，表示把小写的ab转换成大小的AB
			-d：删除出现在字符集中的所有字符，例：tr -d 'ab'，表示删除所有ab字符
		}
	}
	
	文本查找{grep，egrep，fgrep
		grep{根据模式搜索文本，并将符合模式的文本行显示出来。使用基本正则表达式定义的模式来过滤文本的命令。
			Pattern(模式)：文本字符和正则表达式的元字符组合而成的匹配条件{
				-i：忽略大小写
				--color：匹配到的内容高亮显示
				-v：显示没有被模式匹配到的行
				-o：只显示被模式匹配到的字符串
				-E：使用扩展正则表达式。grep -E相当于使用egrep
				-q：静默模式，不输出任何信息
				-A 1：被模式匹配到的内容以及其后面一行的内容都显示出来，如果把1改成2就表示被模式匹配到的内容以及其后面2行的内容均显示出来
				-B 1：被模式匹配到的内容以及其前面一行的内容都显示出来，如果把1改成2就表示被模式匹配到的内容以及其前面2行的内容均显示出来
				-C 1：被模式匹配到的内容以及其前后的行各显示1行，如果把1改成2 就表示被模式匹配到的内容以及其前后的行各显示2行。
			}
		}
		fgrep{不支持正则表达式，执行速度快
			
		}
	}
	
	
}

9 正则{
	正则表达式：REGEXP，REGular EXPression
	正则表达式分类{
		Basic REGEXP：基本正则表达式
		Extended REGEXP：扩展正则表达式
	}
	Pattern(模式)：文本字符和正则表达式的元字符组合而成的匹配条件{
		基本正则表达式{
			元字符{
				.：任意单个字符
				[]：匹配指定范围内的任意单个字符
				[^]：匹配指定范围外的任意单个字符
			}
			匹配次数（贪婪模式）{
				*：匹配其前面的字符任意次
				.*：任意长度的任意字符
				\?：匹配其前面的字符1次或0次
				\+：匹配其前面的字符至少1次
				\{m,n\}：匹配其前面的字符至少m次，至多n次
			}
			位置锚定{
				^：锚定行首，此字符后面的任意内容必须出现在行首
				$：锚定行尾，此字符前面的任意内容必须出现在行尾
				^$：空白行
				\<或\b：锚定词首，其后面的任意字符必须作为单词首部出现
				\>或\b：锚定词尾，其前面的任意字符必须作为单词尾部出现
			}
			分组{
				\(\)
				例：\(ab\)*
				后向引用{
					\1：引用第一个左括号以及与之对应的右括号所包括的所有内容
					\2：引用第二个左括号以及与之对应的右括号所包括的所有内容
				}
			}
		}
		
		扩展正则表达式{
			字符匹配{
				.：任意单个字符
				[]：匹配指定范围内的任意单个字符
				[^]：匹配指定范围外的任意单个字符
			}
			次数匹配{
				*：匹配其前面的字符任意次
				?：匹配其前面的字符1次或0次
				+：匹配其前面的字符至少1次
				{m,n}：匹配其前面的字符至少m次，至多n次
			}
			位置锚定{
				^：锚定行首，此字符后面的任意内容必须出现在行首
				$：锚定行尾，此字符前面的任意内容必须出现在行尾
				^$：空白行
				\<或\b：锚定词首，其后面的任意字符必须作为单词首部出现
				\>或\b：锚定词尾，其前面的任意字符必须作为单词尾部出现
			}
			分组{
				()：分组
				\1，\2，\3，....
				例：(ab)*
				后向引用{
					\1：引用第一个左括号以及与之对应的右括号所包括的所有内容
					\2：引用第二个左括号以及与之对应的右括号所包括的所有内容
				}
			}
			或者{
				|：or    默认匹配｜的整个左侧或者整个右侧的内容
				例：C|cat表示C或者cat，要想表示Cat或者cat则需要使用分组，如(C|c)at
			}
		}
	}
}

10 软件管理{


}

11 进程守护{
	screen{
		screen -ls：显示已经建立的屏幕
		screen：直接打开一个新的屏幕
		ctrl+a，d：按下ctrl+a键，松开后立即按d键，拆除屏幕
		screen -r ID：还原回某屏幕
		exit：退出
	}	
}















