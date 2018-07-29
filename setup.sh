#!/bin/bash

starttime=$(date +%s)

init (){
    git checkout release-1.1
    git pull origin release-1.1
    rm -rf inputFiles node_modules/ package-lock.json tmp.json
    git submodule update --init --recursive
    git submodule foreach git pull origin master
    npm install
    cp CITest/CISCFiles/config-chan1-TLS.json SCFiles/config-chan1-TLS.json
    jq -s '.[0] * {"gopath": "GOPATH"}' SCFiles/config-chan1-TLS.json > tmp.json
    mv tmp.json SCFiles/config-chan1-TLS.json
    ## add gopath to the SCFile
    mkdir -p inputFiles/run1
    mkdir -p inputFiles/run2
}

function exec(){
    NODE_FILE=$1
    printf "\n ========== G E N E R A T E    C O N F I G    F I L E S ==========\n"
    node $NODE_FILE

    sleep 2
    printf "\n ========== I N S T A L L  C H A I N C O D E ==========\n"
    ./pte_driver.sh ${DEST}/install.txt

    sleep 2
    printf "\n ========== I N S T A N T I A T E   C H A I N C O D E  ==========\n"
    ./pte_driver.sh ${DEST}/instantiate.txt

    sleep 2
    printf "\n ========== S E N D   I N V O K E S  ==========\n"
    M_FACTOR=10000
    for ((i=0;i<7;i++))
    do
        printf "\n ========== I N V O K E    I T E R A T I O N - ${i} ============\n"
        if [ $i -eq 6 ];then
            export DURATION=300;
        fi
        export KEY_START=$(($M_FACTOR * $i));
        printf "\n ========== R E - G E N E R A T E   C F G   F I L E S ==========\n"
        node $NODE_FILE
        ./pte_driver.sh ${DEST}/invoke.txt
        sleep 2
    done
    #  5 runs with each run changing the keyStart value
    export DURATION=60;
    printf "\n ========== R E S E T   D U R A T I O N    T O  60 secs ==========\n"
    node $NODE_FILE
    sleep 2
    printf "\n ========== S E N D   Q U E R I E S ========== \n"
    for ((i=0;i<5;i++))
    do
        printf "\n ========== Q U E R Y   I T E R A T I O N - ${i} ============\n"
        ./pte_driver.sh ${DEST}/query.txt
    done
}

##### Scenario 1
function execScenario1(){

    DEST=inputFiles/run1
    echo "Copy files from marblesccInputs dir to ${DEST}"
    cp marblesccInputs/marblescc-chan1-install-TLS.json ${DEST}/marbles-install.json
    cp marblesccInputs/marblescc-chan1-instantiate-TLS.json ${DEST}/marbles-instantiate.json
    cp marblesccInputs/marblescc-chan1-constant-i-TLS.json ${DEST}/marbles-invoke.json
    cp marblesccInputs/marblescc-chan1-constant-q-TLS.json ${DEST}/marbles-query.json
    #### genetate txt files
    echo "sdk=node ${DEST}/marbles-install.json" >& ${DEST}/install.txt
    echo "sdk=node ${DEST}/marbles-instantiate.json" >& ${DEST}/instantiate.txt
    echo "sdk=node ${DEST}/marbles-invoke.json" >& ${DEST}/invoke.txt
    echo "sdk=node ${DEST}/marbles-query.json" >& ${DEST}/query.txt

    export CHAINCODE_NAME=marbles
    
    exec generateMarbleCfgFiles.js
}

##### Scenario 2
function execScenario2(){
    DEST=inputFiles/run2
    echo "Copy files from sampleccInputs dir to ${DEST}"
    cp sampleccInputs/samplecc-chan1-install-TLS.json ${DEST}/samplecc-install.json
    cp sampleccInputs/samplecc-chan1-instantiate-TLS.json ${DEST}/samplecc-instantiate.json
    cp sampleccInputs/samplecc-chan1-constant-i-TLS.json ${DEST}/samplecc-invoke.json
    cp sampleccInputs/samplecc-chan1-constant-q-TLS.json ${DEST}/samplecc-query.json
    cp sampleccInputs/ccDfnOpt.json ${DEST}/ccDfnOpt.json
    cp sampleccInputs/txCfgOpt.json ${DEST}/txCfgOpt.json

    #### genetate txt files
    echo "sdk=node ${DEST}/samplecc-install.json" >& ${DEST}/install.txt
    echo "sdk=node ${DEST}/samplecc-instantiate.json" >& ${DEST}/instantiate.txt
    echo "sdk=node ${DEST}/samplecc-invoke.json" >& ${DEST}/invoke.txt
    echo "sdk=node ${DEST}/samplecc-query.json" >& ${DEST}/query.txt

    export CHAINCODE_NAME=samplecc

    exec generateSampleccCfgFiles.js
}

function end() {
    printf "\nTotal execution time : $(($(date +%s)-starttime)) secs ...\n"
    printf "\n ========== A L L   D O N E ============\n"

    cat pteReport.txt
    cat pteReport.txt | grep TPS | awk '{print $3}'
}

init
execScenario1
execScenario2
end
