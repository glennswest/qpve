screen -t "Install" -dm bash -c './install.sh $1' 
screen -t "CSR Approval" -dm bash -c './approvecsr.sh' 
screen -t "Operator Status" -dm bash -c './clusteroperator.sh'
screen -t "Install" htop
focus
focus

