# azure-aks-virtual-kubelet-test

Simple test of Virtual Kubelets in Azure AKS. This project was made to test how ACI works.

## Links

* [How to create the AKS cluster](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough)
* [This page was used to create this sample project](https://docs.microsoft.com/en-us/azure/aks/virtual-kubelet)

# Run with `azure` networking (CNI)

Running a pod in the AKS cluster works fine. `/etc/resolv.conf` looks like this:

```
nameserver 10.0.0.10
search default.svc.cluster.local svc.cluster.local cluster.local uihh301jmvxezbmnbf2p5eusoh.ax.internal.cloudapp.net
options ndots:5
```

`/etc/resolv.conf` on the ACI pod looks like this:
```
nameserver 168.63.129.16
search gsalx0bzurvu5fpkozo1aesd4h.ax.internal.cloudapp.net
```

and it is not possible to ping 10.0.0.10
