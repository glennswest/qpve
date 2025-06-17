./pull-install.sh $1
rm -r -f wip
mkdir wip
cd wip
openshift-install version
rm *.gz
cd ..
./runsno.sh
