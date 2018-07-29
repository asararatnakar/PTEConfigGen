
const fs = require('fs');
const path = require('path');

var channelName = process.env.CHANNEL || 'firstchannel';
var mspIds = process.env.MSP_ID || 'org1,org2';
var processes = process.env.PROCESSES || '8';
var keyStart = process.env.KEY_START || '0';
var duration = process.env.DURATION || '60';
var chaincodeID = process.env.CHAINCODE_NAME || 'samplecc';

function readAllFiles(dir) {
	var files = fs.readdirSync(dir);
	files.forEach((fileName) => {
		if (fileName.indexOf('.json') > 0){
			let filePath = path.join(dir,fileName);
			let data = JSON.parse(fs.readFileSync(filePath));
			//TODO: I know this looks ugly , let me think meanwhile
			if (fileName.indexOf('ccDfnOpt.json') < 0 && fileName.indexOf('txCfgOpt.json') < 0) {
				data.channelOpt.name = channelName;
				data.chaincodeID = chaincodeID;
				data.channelOpt.orgName = [];
			}

			let mspIdList = mspIds.split(',');
			if (fileName.indexOf('query.json') >= 0 || fileName.indexOf('txCfgOpt.json') >= 0){
				data.targetPeers = 'AllPeers';
				data.nProcPerOrg = processes
				data.nRequest = '0';
				data.runDur = duration;
				if (fileName.indexOf('query.json') >= 0) {
					data.ccOpt.keyStart = keyStart;
					data.channelOpt.orgName.push(mspIdList[0]);
				}
			} else if (fileName.indexOf('invoke') >= 0){
				data.channelOpt.orgName.push(mspIdList[0]);
				data.txCfgPtr = 'inputFiles/run2/txCfgOpt.json';
				data.ccDfnPtr = 'inputFiles/run2/ccDfnOpt.json';
			} else if (fileName.indexOf('ins') >= 0){
				// Install / Instantiate
				for (i=0;i<mspIdList.length;i++){
					data.channelOpt.orgName.push(mspIdList[i]);
				}
			} else if (fileName.indexOf('ccDfnOpt.json') >= 0){
				data.ccOpt.payLoadType = 'Fixed';
				data.ccOpt.payLoadMin = '20480';
				data.ccOpt.payLoadMax = '20480';
				data.ccOpt.keyStart = keyStart;
			} 
			fs.writeFile(filePath, JSON.stringify(data, null, 2), function (err) {
				if (err) return console.log(err);
				// console.log('writing to ' + filePath);
			  });
		}
	});
}

readAllFiles(path.join(__dirname, 'inputFiles/run2'));