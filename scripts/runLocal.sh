# Remove the existing staging directory
rm -r out/.staging

# Create a new staging directory
mkdir -p out/.staging

# Copy source files, components, images, and manifest to the staging directory
cp -R source components images manifest out/.staging

# Change to the staging directory
cd out/.staging

# Modify the manifest file to set runTests to true
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' 's/runTests=false/runTests=true/' manifest
else
    # Linux and other Unix-like systems
    sed -i 's/runTests=false/runTests=true/' manifest
fi

# Create a zip file of the staged content
zip -FS -9r ../roku-deploy.zip .

# Return to the original directory
cd ../../

# Run the BrightScript CLI with the created zip file
yarn run brs-cli out/roku-deploy.zip