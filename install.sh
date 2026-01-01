# Clean up SSH known_hosts for cluster nodes
echo "Cleaning up SSH known_hosts entries for cluster nodes..."
ssh-keygen -R bootstrap.gw.lo 2>/dev/null || true
ssh-keygen -R control0.gw.lo 2>/dev/null || true
ssh-keygen -R control1.gw.lo 2>/dev/null || true
ssh-keygen -R control2.gw.lo 2>/dev/null || true
ssh-keygen -R worker0.gw.lo 2>/dev/null || true
ssh-keygen -R worker1.gw.lo 2>/dev/null || true
ssh-keygen -R worker2.gw.lo 2>/dev/null || true
echo "SSH known_hosts cleanup complete."

./pull-install.sh $1
rm -r -f wip
mkdir wip
cd wip
openshift-install version
rm *.gz
cd ..
./run.sh
