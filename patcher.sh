#/bin/bash

#Get list of ingress-controller pods
kubectl get pods -n ingress-nginx | grep Running | grep ingress-nginx-controller | awk '{print $1}' > /root/controller-pods.list && cat /root/controller-pods.list

#Get IP of nodes that contains this pods
for pod in $(cat /root/controller-pods.list); do kubectl -n ingress-nginx get pod $pod --template '{{.status.hostIP}}'; echo ""; done > /root/controller-ip.list && cat /root/controller-ip.list

#Collecting a variable
ingress_ips=$(sed ':a;N;$!ba;s/\n/","/g; s/^/"/; s/$/"/' /root/controller-ip.list)

#Patch ingress-controller service
ip_number=$(wc -l /root/controller-ip.list | awk '{print $1}')
if [ "$ip_number" == "1" ]
then
        kubectl patch service ingress-nginx -n ingress-nginx -p '{"spec": {"externalIPs": ["'$ingress_ips'"]}}'
else
        kubectl patch service ingress-nginx -n ingress-nginx -p '{"spec": {"externalIPs": ['$ingress_ips']}}'
fi
