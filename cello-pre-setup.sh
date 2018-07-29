#!/bin/bash
WORKING_DIR=${PWD##*/}
if [ "$WORKING_DIR" != "fabric-test" ]; then
    echo "Make sure you run this command from fabric-test root directory"
    exit 1
fi

function teardown() {
    cd tools/ATD
    ansible-playbook --extra-vars "chaincode=samplejs testcase=FAB-7334-4i testcase_query=FAB-7204-4q" -e "mode=destroy env=vb1st tool_type=ptek8s pteenv=2channels" ptesetup.yml
    cd -
    cd cello/src/agent/ansible
    ansible-playbook -e "mode=destroy env=vb1st deploy_type=k8s" setupfabric.yml --skip-tags="composersetup,clientdown"
    cd -
}

function start(){
    cd cello/src/agent/ansible
    ansible-playbook -e "mode=apply env=vb1st deploy_type=k8s" setupfabric.yml --skip-tags="composersetup"
    cd -
    cd tools/ATD
    ansible-playbook --extra-vars "chaincode=samplejs testcase=FAB-7334-4i testcase_query=FAB-7204-4q" -e "mode=apply env=vb1st tool_type=ptek8s pteenv=2channels" ptesetup.yml
    cd -
}

# Print the usage message
function printHelp () {
    echo "Usage: "
    echo "        ./k8s_setup.sh -c|-s"
    echo "        -s  Setup the network | PTE on IKS"
    echo "        -c  clear the setup"
}


# Parse commandline args
while getopts "h?cs" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    c)  teardown
    ;;
    s)  start
    ;;
  esac
done