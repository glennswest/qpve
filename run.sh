rm -r -f gw
mkdir gw
cp install-config.yaml gw
openshift-install create ignition-configs --dir=gw
cp gw/worker.ign ~ 2>/dev/null || true
rm -f ~/.kube/config
mkdir -p ~/.kube
cp gw/auth/kubeconfig ~/.kube/config
scp -r gw/* root@boot.gw.lo:/tftp
./poweroff-all-vms.sh
sleep 5
./erase-all-vms.sh
sleep 3

# Start CSR approval early - runs throughout entire install
echo "Starting automatic CSR approval..."
echo 1 > .approvecsr.dat
./approvecsr.sh &
CSR_PID=$!

# Power on bootstrap and control plane
echo "Powering on bootstrap and control plane..."
./poweron-vm.sh bootstrap.gw.lo &
./poweron-vm.sh control0.gw.lo &
./poweron-vm.sh control1.gw.lo &
./poweron-vm.sh control2.gw.lo &
wait

openshift-install --dir=gw wait-for bootstrap-complete --log-level debug
./poweroff-vm.sh bootstrap.gw.lo

# Start workers after bootstrap is done
echo "Powering on workers..."
./poweron-vm.sh worker0.gw.lo &
./poweron-vm.sh worker1.gw.lo &
./poweron-vm.sh worker2.gw.lo &
wait

openshift-install --dir=gw wait-for install-complete --log-level debug

# Stop CSR approval loop
echo 0 > .approvecsr.dat
wait $CSR_PID 2>/dev/null





