echo 1 > .approvecsr.dat
thevalue=`cat .approvecsr.dat`
while [ $thevalue -gt 0  ]
do
   oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve
   sleep 20
   thevalue=`cat .approvecsr.dat`
done

