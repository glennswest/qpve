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

# Power on bootstrap and control plane
echo ""
echo "=========================================="
echo "Starting bootstrap and control plane..."
echo "=========================================="
./poweron-vm.sh bootstrap.gw.lo &
./poweron-vm.sh control0.gw.lo &
./poweron-vm.sh control1.gw.lo &
./poweron-vm.sh control2.gw.lo &
wait

echo ""
echo "=========================================="
echo "Waiting for bootstrap to complete..."
echo "=========================================="
openshift-install --dir=gw wait-for bootstrap-complete --log-level debug

echo ""
echo "=========================================="
echo "Bootstrap complete - shutting down bootstrap VM"
echo "=========================================="
./poweroff-vm.sh bootstrap.gw.lo

# Start CSR approval now - needed for workers
echo "Starting automatic CSR approval..."
echo 1 > .approvecsr.dat
./approvecsr.sh &
CSR_PID=$!

echo ""
echo "=========================================="
echo "Starting workers..."
echo "=========================================="
./poweron-vm.sh worker0.gw.lo &
./poweron-vm.sh worker1.gw.lo &
./poweron-vm.sh worker2.gw.lo &
wait

echo ""
echo "=========================================="
echo "Waiting for install to complete..."
echo "=========================================="
openshift-install --dir=gw wait-for install-complete --log-level debug

echo ""
echo "=========================================="
echo "Install complete!"
echo "=========================================="

# Stop CSR approval loop
echo 0 > .approvecsr.dat
wait $CSR_PID 2>/dev/null





