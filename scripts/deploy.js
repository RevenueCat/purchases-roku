var rokuDeploy = require('roku-deploy');
const fs = require('fs');
const path = require('path');

// Using a script instead of the roku-deploy CLI so we can:
// - Use environment variables for the host and password
// - Modify the manifest file to run tests
rokuDeploy.deploy({
    host: process.env.ROKU_IP_ADDRESS,
    password: process.env.ROKU_PASSWORD,
}, (info) => {
    // Modify the manifest file to run tests if the environment variable is set
    if (process.env.ROKU_RUN_TESTS === 'true') {
        const manifestPath = path.join(info.stagingDir, 'manifest');
        let manifestContent = fs.readFileSync(manifestPath, 'utf8');
        manifestContent = manifestContent.replace('runTests=false', 'runTests=true');
        fs.writeFileSync(manifestPath, manifestContent);
    }
}).then(function(){
    //it was successful
}, function(error) {
    console.error(error);
});