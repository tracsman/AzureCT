<properties
   pageTitle="Network Architecture Reference | Microsoft Azure"
   description="See design patterns for common scenarios in Azure network environments"
   services="virtual-network"
   documentationCenter="na"
   authors="tracsman"
   manager="rossort"
   editor=""/>

<tags
   ms.service="virtual-network"
   ms.devlang="na"
   ms.topic="article"
   ms.tgt_pltfrm="na"
   ms.workload="infrastructure-services"
   ms.date="04/01/2016"
   ms.author="jonor"/>

# Microsoft Azure Network Architecture Patterns

## Overview
This page contains many diagrams of successful network architectures. Each diagram is also click-able to see more detailed information on each design.




The page is divided into four sections from the perspective of an Azure VNet:

1. [Inbound Flows](#inbound-flows) - These patterns are focused on traffic inbound from the internet to a Virtual Network in Azure, optionally with connections back to an on-premise network.

2. [Outbound Flows](#outbound-flows) - These patterns are focused on traffic outbound from an Azure Virtual Network heading towards either the internet, an on-premise network, or another Azure VNet (Site-to-Site or VNet Peering connected).

3. [Bi-Directional Flows](#bi-directional-flows) - These patterns are focused on traffic both inbound and outbound between different networks, a combination of the above two sections.

4. [Forced Tunneling Flows](#forced-tunneling-flows) - These patterns are focused on scenarios using ExpressRoute with the forced tunneling feature turned on, usually with no direct inbound or outbound Internet connection to the Azure VNet.

## Inbound Flows
These patterns are focused on traffic inbound from the internet to a Virtual Network in Azure, optionally with connections back to an on-premise network.

### Direct To On Premises
![0]

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut vel ornare lorem. In sapien nisl, pellentesque vel justo at, facilisis finibus diam. Donec aliquet id dolor sit amet luctus. Donec sed nulla in justo pulvinar faucibus. In dignissim elit et neque faucibus sodales at vitae sem. Vivamus aliquet dapibus orci vel auctor. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Praesent elementum ligula lectus, eget convallis mauris pulvinar non. Aenean velit enim, varius at mauris id, sagittis facilisis orci. Aliquam dui felis, porta et ultrices at, blandit vel sapien. Etiam dignissim posuere augue, a dapibus dolor euismod vitae. Proin bibendum lacus ut arcu pretium lacinia. Nam facilisis placerat ornare.

### Monolythic Application
![1]

Vivamus id convallis orci. Phasellus nec sem gravida, luctus nisl ac, placerat arcu. Donec blandit ex quis nibh faucibus, ac convallis diam aliquet. Sed eget nunc non felis interdum efficitur. Nam nec ipsum luctus, interdum justo at, pretium ex. Suspendisse consectetur orci quis dignissim rutrum. Proin id sapien egestas, aliquet nunc id, tincidunt metus. Duis volutpat a sapien ac volutpat. Aenean a sagittis nisi. 

### Monolythic App NVA
![2]

Sed et dictum nisi. Vivamus non imperdiet nisi, quis tempor sem. Maecenas sit amet ex ante. Aliquam porta mi at lorem egestas, eu fermentum diam iaculis. Duis venenatis ligula ipsum, a ornare magna venenatis vel. Fusce pretium mattis lorem vitae blandit. Morbi sed nisl libero. Suspendisse potenti. Vestibulum ultricies, eros vel sodales feugiat, tortor erat varius metus, vel posuere nisl dui at velit. Aliquam erat volutpat. Integer sit amet augue nulla. Etiam auctor bibendum nulla in auctor. Suspendisse potenti. Sed pretium iaculis turpis, eget finibus velit facilisis vestibulum. Cras vel sem vitae eros mattis lobortis. 

### Multiple NVA Stack
![3]

Etiam convallis magna et porta lacinia. Mauris fermentum leo nec velit rutrum scelerisque. Integer nisi lacus, ultrices et malesuada vitae, lacinia quis metus. Suspendisse non augue eros. Quisque ut dolor varius, lobortis mauris ac, consectetur lacus. Nam porttitor ullamcorper ante semper elementum. Aliquam faucibus in metus eu vulputate. Nam fringilla magna ac augue faucibus semper. Nullam nec velit suscipit, convallis sem sit amet, ullamcorper nisl. Donec sapien diam, ultricies vel urna at, feugiat facilisis elit. Vivamus suscipit a lorem nec feugiat. Sed vitae faucibus velit, eget porta est. Etiam eu quam augue. Aliquam eget volutpat diam. Maecenas lacinia nisi ac nunc cursus luctus. Suspendisse vitae sollicitudin justo, at molestie leo. 

### Shared Security Stack
![6]

Maecenas sodales urna id nisl commodo consequat. Praesent sed erat mi. Phasellus at vestibulum felis. Suspendisse fringilla, turpis sit amet tincidunt porta, nibh orci gravida lacus, vel tincidunt sapien purus at metus. Proin quam dui, placerat a hendrerit vel, convallis eget felis. Sed facilisis pharetra eros, eu vestibulum erat cursus sit amet. Cras commodo odio at elit sollicitudin congue. Donec blandit purus nec elementum feugiat. 

### NVA VPM
![4]

Nullam eu mi ac elit efficitur blandit et non purus. Nunc rutrum dolor eu feugiat consequat. Nullam mollis enim varius sapien sodales pellentesque. In sit amet erat scelerisque, venenatis est vel, convallis velit. Morbi eget lectus vel enim aliquam faucibus. Vestibulum fermentum semper arcu ac tristique. Cras gravida dui augue, sed ullamcorper neque rhoncus vel. Nam a nulla tellus. Morbi molestie quam non sem rutrum, nec scelerisque metus ultrices. Sed lacinia ex non neque facilisis, quis tempor nulla vulputate. 

### Sandwich DMZ
![7]

Cras mattis massa vitae eros tempus dignissim. Integer molestie eros vitae semper luctus. Maecenas posuere enim id metus porta interdum. Nullam vitae enim in dolor mattis aliquam. Fusce nisl neque, condimentum et ante nec, suscipit blandit magna. Donec sapien risus, porta nec nulla quis, viverra viverra nisi. Interdum et malesuada fames ac ante ipsum primis in faucibus. 

## Outbound Flows
These patterns are focused on traffic outbound from an Azure Virtual Network heading towards either the internet, an on-premise network, or another Azure VNet (Site-to-Site or VNet Peering connected).



## Bi-directional Flows
These patterns are focused on traffic both inbound and outbound between different networks, a combination of the above two sections.



## Forced Tunneling Flows
These patterns are focused on scenarios using ExpressRoute with the forced tunneling feature turned on, usually with no direct inbound or outbound Internet connection to the Azure VNet.

### Public Peering
![5]

Nulla ut lobortis arcu. Praesent nec rhoncus sem. Duis consectetur ante et dolor vestibulum rhoncus. Ut nec accumsan diam, id ultrices est. Nulla sollicitudin vehicula metus, et bibendum nibh malesuada et. Proin interdum magna a odio finibus, ac fermentum dui tincidunt. Curabitur viverra quam eget nulla facilisis, vel fermentum nulla faucibus. Praesent bibendum porta ante vitae convallis. In at tellus fringilla arcu vehicula rutrum. Fusce hendrerit turpis vel leo ornare vehicula. Ut consectetur ex sed lobortis bibendum. Maecenas ac tortor commodo, consectetur leo quis, rutrum diam. 



## Appendix - Comments on High Availability
Proin ut felis luctus, viverra nunc et, elementum lectus. Vivamus mattis nibh pharetra ultrices consectetur. Cras non pellentesque diam. In ultricies quam nisi, eu tincidunt mauris aliquam eget. Praesent quis mattis velit. Nam egestas, justo luctus vehicula pretium, eros elit dictum nulla, in egestas elit velit eu risus. Aliquam commodo tellus nibh, at fermentum ante aliquam consequat. Nunc ante nulla, fringilla a molestie sit amet, varius ac metus. Sed at lacus consequat, condimentum velit nec, porttitor mauris. Duis nec dolor maximus, rhoncus erat at, eleifend diam. Cras sed lorem sit amet sem suscipit ultricies in ut purus. Sed ut egestas sapien, eget laoreet nisi. Nulla facilisi. Maecenas aliquet est et facilisis porta. 

## Appendix - Protocol Chart
| Layer | Protocol | Works Across VNet | Works Across VPN | Works Across ExpressRoute | Works Across Azure Edge |
|:-----:|:---------|:-----------------:|:----------------:|:-------------------------:|:-----------------------:|
| 2 | ARP
| 2 | CDP
| 2 | Ethernet
| 2 | L2TP
| 2 | LLDP
| 2 | MPLS
| 2 | PPP
| 2 | STP
| 3 | ICMP
| 3 | IGMP
| 3 | IPSec
| 3 | IPv4
| 3 | IPv6
| 3 | PIM-DM
| 3 | PIM-SM
| 3 | RIP
| 4 | FCP
| 4 | TCP
| 4 | UDP
| 5 | PPTP
| 5 | RPC
| 7 | HTTP
| 7 | LDAP
| 7 | NFS
| 7 | NTP
| 7 | RDP
| 7 | SMB
| 7 | SMTP
| 7 | SSH
| 7 | TLS/SSL



<!--Image References-->
[0]: ./DirectToOnPremises50.png "Direct To On Premises Diagram"
[1]: ./MonolythicApplication50.png "Monolythic Application Diagram"
[2]: ./MonolythicAppNVA50.png "Monolythic App NVA Diagram"
[3]: ./MultipleNVAStack50.png "Multiple NVA Stack Diagram"
[4]: ./NVAVPN50.png "NVA VPN Diagram"
[5]: ./Publicpeering50.png "Public Peering Diagram"
[6]: ./SharedSecurityStack50.png "Shared Security Stack Diagram"
[7]: ./SandwichDMZ25.png "Sandwich DMZ Diagram"

<!--Link References-->
[Link1]: https://github.com/tracsman/AzureCT/archive/master.zip "Download Zip File Here"
[Link2]: ./media/RunOneMinute.md
