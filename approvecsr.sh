echo 1 > .approvecsr.dat
thevalue=`cat .approvecsr.dat`

# Use the kubeconfig from the current install
export KUBECONFIG=gw/auth/kubeconfig

# During early bootstrap, certs rotate and oc can't verify them
# Use --insecure-skip-tls-verify until certs stabilize
OC_OPTS="--insecure-skip-tls-verify"

while [ $thevalue -gt 0  ]
do
   # Get pending CSRs, suppress errors during early bootstrap
   pending=$(oc $OC_OPTS get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' 2>/dev/null)
   if [ -n "$pending" ]; then
      echo "Approving CSRs: $pending"
      echo "$pending" | xargs oc $OC_OPTS adm certificate approve
   fi
   sleep 5
   thevalue=`cat .approvecsr.dat`
done

