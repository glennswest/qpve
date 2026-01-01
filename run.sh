rm -r -f gw
mkdir gw
cp install-config.yaml gw
openshift-install create ignition-configs --dir=gw
# Copy worker.ign locally for manual worker additions (optional)
cp gw/worker.ign ~ 2>/dev/null || true
rm -f ~/.kube/config
cp gw/auth/kubeconfig ~/.kube/config
scp -r gw/* root@boot.gw.lo:/tftp || { echo "Failed to copy ignition configs to boot server"; exit 1; }
./poweroff-all-vms.sh
sleep 5
./erase-all-vms.sh
sleep 5
./poweron-vm.sh bootstrap.gw.lo
./poweron-vm.sh control0.gw.lo
./poweron-vm.sh control1.gw.lo
./poweron-vm.sh control2.gw.lo
openshift-install --dir=gw wait-for bootstrap-complete --log-level debug
./poweroff-vm.sh bootstrap.gw.lo

# Start CSR approval in background before workers boot
echo "Starting automatic CSR approval..."
echo 1 > .approvecsr.dat
./approvecsr.sh &
CSR_PID=$!

./poweron-vm.sh worker0.gw.lo
./poweron-vm.sh worker1.gw.lo
./poweron-vm.sh worker2.gw.lo
openshift-install --dir=gw wait-for install-complete --log-level debug

# Stop CSR approval loop
echo 0 > .approvecsr.dat
wait $CSR_PID 2>/dev/null





