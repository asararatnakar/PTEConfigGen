
const fs = require('fs');
const path = require('path');

var channelName = process.env.CHANNEL || 'firstchannel';
var mspIds = process.env.MSP_ID || 'org1,org2';
var processes = process.env.PROCESSES || "8";
var keyStart = process.env.KEY_START || "0";
var duration = process.env.DURATION || "60";
var chaincodeID = process.env.CHAINCODE_NAME || "marblescc";

function readAllFiles(dir) {
	var files = fs.readdirSync(dir);
	files.forEach((fileName) => {
		if (fileName.indexOf('.json') > 0){
			let filePath = path.join(dir,fileName);
			let data = JSON.parse(fs.readFileSync(filePath));
			data.channelOpt.name = channelName;
			data.chaincodeID = chaincodeID;
			data.channelOpt.orgName = [];
			let mspIdList = mspIds.split(',');
			if (fileName.indexOf('ins') < 0){
				data.targetPeers = "AllPeers";
				data.nProcPerOrg = processes
				data.nRequest = "0";
				data.runDur = duration;
				data.ccOpt.keyStart = keyStart;
				data.channelOpt.orgName.push(mspIdList[0]);
			} else {
				for (i=0;i<mspIdList.length;i++){
					data.channelOpt.orgName.push(mspIdList[i]);
				}
			}
			//TODO: enable endorsement policy ?
			// if (mspIdList.length == 2 && fileName.indexOf('instantiate') > 0){
			// 	// data.nProcPerOrg = processes/2 ??
			// 	// Add endorsement policy
			// 	data.deploy.endorsement = {
			// 		"identities": [
			// 		 { "role": { "name": "peer", "mspId": ""+mspIdList[0] }},
			// 		 { "role": { "name": "peer", "mspId": ""+mspIdList[1] }}
			// 			],
			// 		"policy": {
			// 		   "2-of": [{ "signed-by": 0 }, { "signed-by": 1 }]
			// 		  }
			// 	   };
			// }
			fs.writeFile(filePath, JSON.stringify(data, null, 2), function (err) {
				if (err) return console.log(err);
				// console.log('writing to ' + filePath);
			  });
		}
	});
}

readAllFiles(path.join(__dirname, 'inputFiles/run1'));