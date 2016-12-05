This file explains the rows in the table device_performance_data

| row name	| description	|
| ------------- | ------------- |
| state		| if the agent works on the device we know if it's online or not	|
| last_check	| date with time when the last run of the agent was to push the information to the management server	|
| uptime	| uptime stores in seconds.	|
| architecture	| stores the type of architecture	|
| kernel_version	| Version of the kernel	|
| net_speed	| speed of the network interface	|
| net_ip	| ip address of the network interface	|
| net_type	| type how we get the ip address (dhcp or static)	|
| net_subnetmask	| stores the network mask	|
| net_gateway	| gateway ip of the network	|
| net_dns1	| ip of the first dns server	|
| net_dns2	| ip of the second dns server	|
| cpu_family	| family of the cpu (Intel Celeron)	|
| cpu_speed	| speed of the cpu (MHz)	|
| cpu_cores	| number of cores	|
| memory_total	| total memory available in MB	|
| memory_free	| memory which is free in MB	|
